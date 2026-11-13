-- T-RexProject/Games/Game01/Modules/05_server_config.lua
-- Server Hop (Visited Cache + Public Servers API v1 + Steal Filter & Condition Sync + Auto Rejoin + Auto Load Script),
-- Egg & Fuse Predictor Panel (Owned Eggs + Fuse Machine SCALE_BANDS Probability Calculator),
-- Discord Webhook (PNG Thumbnail Encoder + Thumbnails API Fallback + 429 Queue + Event Monitors).

local TRex = (_G :: any).TRex
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local AssetService = game:GetService("AssetService")
local CoreGui = game:GetService("CoreGui")

local Core = TRex.Core
local UI = TRex.UI

local Server = {}
TRex.Server = Server

local HOP_CACHE_PATH = "T-RexProject/Games/Game01/Config/AutoHopCache.json"
local CACHE_TTL_SECONDS = 1800

local SCALE_BANDS = {
	{ min = 0.85, max = 1.05, weight = 2000 },
	{ min = 1.45, max = 1.55, weight = 250 },
	{ min = 1.9, max = 2.1, weight = 125 },
	{ min = 2.85, max = 3.15, weight = 62.5 },
	{ min = 3.8, max = 4.2, weight = 31.25 },
	{ min = 0.3, max = 0.45, weight = 18 },
	{ min = 0.1, max = 0.2, weight = 5 },
	{ min = 5.8, max = 6.2, weight = 15.625 },
	{ min = 9.5, max = 12.5, weight = 3 },
	{ min = 12, max = 17, weight = 0.05 },
	{ min = 20, max = 35, weight = 1.0e-4 },
}

local CRC32_TABLE: { [number]: number } = {}
for i = 0, 255 do
	local c = i
	for _ = 1, 8 do
		c = if bit32.band(c, 1) == 1 then bit32.bxor(0xEDB88320, bit32.rshift(c, 1)) else bit32.rshift(c, 1)
	end
	CRC32_TABLE[i] = c
end

local HopStatusRow = nil
local PredictorSummaryRow = nil
local WebhookStatusRow = nil

local SessionStartAt = os.clock()
local LastTeleportAt = 0
local CarriedSince: number? = nil
local RareWindowUntil = 0
local FailedJobIds: { [string]: boolean } = {}
local CachedServers: { any }? = nil
local CachedServersAt = 0
local HopPendingJob: string? = nil
local TeleportStarted = false
local IsHopping = false
local IsRejoining = false
local NeedsHopAfterSteal = false

local WebhookQueue: { any } = {}
local WebhookSending = false
local WebhookSentCount = 0
local IconPngCache: { [string]: any } = {}
local AssetUrlCache: { [string]: any } = {}
local AvatarHeadshotUrl: string? = nil
local AvatarFetched = false
local InventoryFullAlerted = false
local SeenFusedUids: { [string]: boolean } = {}
local InitialFuseScanned = false

local PredictorGui: ScreenGui? = nil
local PredictorRowsFrame: Frame? = nil
local PredictorFuseLbl: TextLabel? = nil
local PredictorLastRefresh = 0

local function setHopStatus(text: string)
	TRex.State.HopStatus = text
	if HopStatusRow and HopStatusRow.Set then
		HopStatusRow:Set(text)
	end
end

local function setWebhookStatus()
	local txt = ("ส่ง %d • รอคิว %d"):format(WebhookSentCount, #WebhookQueue)
	if WebhookStatusRow and WebhookStatusRow.Set then
		WebhookStatusRow:Set(txt)
	end
end

local function loadHopCache(): { [string]: number }
	local raw = TRex.safeReadFile(HOP_CACHE_PATH)
	if not raw or raw == "" then
		return {}
	end
	local ok, tbl = pcall(HttpService.JSONDecode, HttpService, raw)
	if not ok or type(tbl) ~= "table" then
		return {}
	end
	local cutoff = os.time() - CACHE_TTL_SECONDS
	local out: { [string]: number } = {}
	for jobId, ts in pairs(tbl) do
		if type(jobId) == "string" and type(ts) == "number" and ts >= cutoff then
			out[jobId] = ts
		end
	end
	return out
end

local function saveHopCache(cache: { [string]: number })
	local ok, enc = pcall(HttpService.JSONEncode, HttpService, cache)
	if ok and type(enc) == "string" then
		TRex.safeWriteFile(HOP_CACHE_PATH, enc)
	end
end

function Server.queueAutoLoadScript(enabled: boolean?)
	local on = if enabled == nil then (TRex.Config.AutoLoadScript == true) else (enabled == true)
	pcall(function()
		TeleportService:SetTeleportSetting("__TRexAutoLoadScriptEnabled", on)
	end)
	if not on then
		return
	end
	local qfn = TRex.resolveGlobalFunc("queue_on_teleport")
		or TRex.resolveGlobalFunc("queueonteleport")
		or (type((_G :: any).syn) == "table" and (_G :: any).syn.queue_on_teleport)
		or (type((_G :: any).fluxus) == "table" and (_G :: any).fluxus.queue_on_teleport)
	if type(qfn) ~= "function" or TRex.GlobalEnv.__TRexAutoLoadQueued == true then
		return
	end
	local loaderCode = [[
local ok, on = pcall(function() return game:GetService("TeleportService"):GetTeleportSetting("__TRexAutoLoadScriptEnabled") end)
if ok and on == true then
	if not game:IsLoaded() then game.Loaded:Wait() end
	if type(readfile) == "function" and type(isfile) == "function" then
		local p1 = "T-RexProject/Games/Game01/Build/mygame1_thai_ui_clean.lua"
		local p2 = "T-RexProject/Games/Game01/Loader.lua"
		local src = isfile(p1) and readfile(p1) or (isfile(p2) and readfile(p2) or nil)
		if type(src) == "string" and src ~= "" then
			local fn = loadstring(src)
			if fn then fn() end
		end
	end
end
]]
	local ok = pcall(qfn, loaderCode)
	if ok then
		TRex.GlobalEnv.__TRexAutoLoadQueued = true
	end
end

local function normalizeHopMode(raw: any): string
	local s = tostring(raw or "Least Players")
	if s == "MostPlayers" or s == "Most Players" then
		return "Most Players"
	elseif s == "Random" then
		return "Random"
	end
	return "Least Players"
end

local function normalizeHopCondition(raw: any): string
	local s = tostring(raw or "Match Steal Filter")
	if s == "UntilEggMatches" or s == "Until An Egg Matches" or s == "Match Steal Filter" then
		return "Match Steal Filter"
	elseif s == "StealThenHop" or s == "Steal Then Hop" then
		return "Steal Then Hop"
	elseif s == "AfterRareSpawns" or s == "After A Rare Spawns" then
		return "After A Rare Spawns"
	end
	return "Match Steal Filter"
end

function Server.hopServer(mode: string?): boolean
	if IsHopping then
		return true
	end
	local hopMode = normalizeHopMode(mode or TRex.Config.HopMode)
	local sortOrder = (hopMode == "Most Players") and "Desc" or "Asc"
	local maxPages = (hopMode == "Random") and 3 or 6
	IsHopping = true

	if not CachedServers or os.clock() - CachedServersAt > 60 then
		local collected: { any } = {}
		local cursor = ""
		for _ = 1, maxPages do
			local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=%s&excludeFullGames=true&limit=100%s"):format(
				game.PlaceId,
				sortOrder,
				cursor
			)
			local okGet, body = pcall(game.HttpGet, game, url)
			if not okGet or type(body) ~= "string" then
				break
			end
			local okDec, decoded = pcall(HttpService.JSONDecode, HttpService, body)
			if not okDec or type(decoded) ~= "table" or type(decoded.data) ~= "table" then
				break
			end
			for _, srv in ipairs(decoded.data) do
				if type(srv) == "table" and type(srv.id) == "string" and srv.id ~= game.JobId then
					table.insert(collected, srv)
				end
			end
			if #collected > 0 and hopMode ~= "Random" then
				break
			end
			local nextCur = decoded.nextPageCursor
			if type(nextCur) ~= "string" or nextCur == "" then
				break
			end
			cursor = "&cursor=" .. HttpService:UrlEncode(nextCur)
		end
		if #collected == 0 then
			IsHopping = false
			setHopStatus("ดึงรายการเซิร์ฟเวอร์ไม่สำเร็จ")
			UI.notify("tab.server", "msg.hop_fetch_failed", 2.5)
			return false
		end
		CachedServers = collected
		CachedServersAt = os.clock()
	end

	local cache = loadHopCache()
	cache[game.JobId] = os.time()

	local list = CachedServers or {}
	local picked: any = nil
	for pass = 1, 2 do
		for _, minFree in ipairs({ 2, 1 }) do
			local pool: { any } = {}
			for _, srv in ipairs(list) do
				local free = (tonumber(srv.maxPlayers) or 0) - (tonumber(srv.playing) or 0)
				if free >= minFree and not FailedJobIds[srv.id] then
					if pass == 2 or not cache[srv.id] then
						table.insert(pool, srv)
					end
				end
			end
			if #pool > 0 then
				table.sort(pool, function(a, b)
					local pa, pb = tonumber(a.playing) or 0, tonumber(b.playing) or 0
					if hopMode == "Most Players" then
						return pa > pb
					end
					return pa < pb
				end)
				local maxIdx = (hopMode == "Random") and #pool or math.min(#pool, 100)
				picked = pool[math.random(1, maxIdx)]
				break
			end
		end
		if picked then
			break
		end
	end

	if not picked then
		FailedJobIds = {}
		CachedServers = nil
		IsHopping = false
		setHopStatus("ไม่พบเซิร์ฟเวอร์ที่เหมาะสม")
		UI.notify("tab.server", "msg.hop_no_server", 2.5)
		return false
	end

	HopPendingJob = picked.id
	TeleportStarted = false
	cache[picked.id] = os.time()
	saveHopCache(cache)
	Server.queueAutoLoadScript()

	setHopStatus(("กำลังย้าย (%d คน)"):format(tonumber(picked.playing) or 0))
	UI.notify("tab.server", "msg.hopping", 2.5)
	local okTp = pcall(TeleportService.TeleportToPlaceInstance, TeleportService, game.PlaceId, picked.id, Players.LocalPlayer)
	if not okTp then
		FailedJobIds[picked.id] = true
		IsHopping = false
		return false
	end

	local targetId = picked.id
	task.delay(6, function()
		if IsHopping and HopPendingJob == targetId and not TeleportStarted then
			FailedJobIds[targetId] = true
			IsHopping = false
			if TRex.IsRunning and TRex.Config.AutoHop then
				task.spawn(Server.hopServer)
			end
		end
	end)
	return true
end

function Server.joinJobId(rawId: string?)
	local clean = tostring(rawId or TRex.Config.JobId or ""):match("%x+%-%x+%-%x+%-%x+%-%x+")
	if not clean then
		UI.notify("tab.server", "รูปแบบรหัสเซิร์ฟเวอร์ไม่ถูกต้อง", 2.5)
		return false
	end
	Server.queueAutoLoadScript()
	pcall(TeleportService.TeleportToPlaceInstance, TeleportService, game.PlaceId, clean, Players.LocalPlayer)
	return true
end

function Server.rejoinServer()
	Server.queueAutoLoadScript()
	pcall(TeleportService.TeleportToPlaceInstance, TeleportService, game.PlaceId, game.JobId, Players.LocalPlayer)
end

function Server.copyJobId()
	local setclip = TRex.resolveGlobalFunc("setclipboard") or TRex.resolveGlobalFunc("toclipboard")
	if setclip then
		pcall(setclip, tostring(game.JobId))
		UI.notify("tab.server", "msg.job_copied", 2.2)
	else
		UI.notify("tab.server", tostring(game.JobId), 3)
	end
end

function Server.markEggStolen(rec: any)
	if normalizeHopCondition(TRex.Config.HopCondition) == "Steal Then Hop" and type(rec) == "table" then
		local info = Core.computeEggInfo(rec)
		if Core.filterMatches(info, "Steal", { areasKey = "TargetAreas", specificKey = "TargetSpecificEggs" }) then
			NeedsHopAfterSteal = true
		end
	end
end

local function stepAutoHop()
	if not TRex.Config.AutoHop or IsHopping then
		if not TRex.Config.AutoHop then
			setHopStatus("รอ / พัก")
		end
		return
	end
	if Core.isNightPhase() then
		setHopStatus("กลางคืน รอสนามรีเซ็ต")
		return
	end
	local delaySec = math.clamp(tonumber(TRex.Config.HopDelaySeconds) or 8, 1, 60)
	if os.clock() - SessionStartAt < delaySec then
		setHopStatus(("กำลังสแกน (%.0fวิ)"):format(delaySec - (os.clock() - SessionStartAt)))
		return
	end
	local mv = Core.getActiveMover()
	if mv == "Steal" or Core.isCarryingEgg() then
		setHopStatus("กำลังขโมย รอก่อนย้าย")
		return
	end
	if Core.inFuseZone() or Core.inBossArena() or Workspace:GetAttribute("PeteRaidLockdown") == true then
		setHopStatus("ติดอีเวนต์/ห้องหลอม รอก่อนย้าย")
		return
	end

	local farm = TRex.Farm
	local eggs = farm and type(farm.getFieldEggs) == "function" and farm.getFieldEggs() or {}
	local readyMatches, carriedMatches, rareFound = 0, 0, false
	for _, rec in pairs(type(eggs) == "table" and eggs or {}) do
		if type(rec) == "table" and rec.State ~= "Claimed" and type(rec.Uid) == "string" and not rec.Uid:find("^FirstAreaEgg") then
			local info = Core.computeEggInfo(rec)
			if info.RarityRank >= 7 then
				rareFound = true
			end
			if Core.filterMatches(info, "Steal", { areasKey = "TargetAreas", specificKey = "TargetSpecificEggs" }) then
				if rec.State == "Carried" then
					carriedMatches += 1
				else
					readyMatches += 1
				end
			end
		end
	end

	local cond = normalizeHopCondition(TRex.Config.HopCondition)
	if rareFound and cond == "After A Rare Spawns" then
		RareWindowUntil = Core.getServerNow() + 60
	end

	if NeedsHopAfterSteal and cond == "Steal Then Hop" then
		NeedsHopAfterSteal = false
		Server.hopServer()
		return
	end

	if readyMatches > 0 then
		if cond ~= "Steal Then Hop" or TRex.Config.AutoSteal then
			CarriedSince = nil
			setHopStatus(("พบไข่ตรงเงื่อนไข %d ฟอง"):format(readyMatches))
			return
		end
	end

	if carriedMatches > 0 then
		if not CarriedSince then
			CarriedSince = os.clock()
		end
		if os.clock() - (CarriedSince :: number) < 20 then
			setHopStatus("มีคนถือไข่เป้าหมาย รอสักครู่")
			return
		end
	end
	CarriedSince = nil

	if cond == "After A Rare Spawns" and Core.getServerNow() <= RareWindowUntil then
		setHopStatus("รอรอบไข่หายาก...")
		return
	end

	Server.hopServer()
end

-- Discord Webhook & Pure-Luau PNG Encoder
local function computeCrc32(buf: buffer, startIdx: number, endIdx: number): number
	local crc = 0xFFFFFFFF
	for i = startIdx, endIdx do
		local b = buffer.readu8(buf, i)
		crc = bit32.bxor(CRC32_TABLE[bit32.band(bit32.bxor(crc, b), 255)], bit32.rshift(crc, 8))
	end
	return bit32.bxor(crc, 0xFFFFFFFF)
end

local function encodeRgbaPng(pixels: buffer, w: number, h: number): string
	local rowBytes = w * 4 + 1
	local rawLen = rowBytes * h
	local zlibLen = 2 + math.ceil(rawLen / 65535) * 5 + rawLen + 4
	local out = buffer.create(45 + zlibLen + 12)
	local pos = 0

	local function putByte(v: number)
		buffer.writeu8(out, pos, v)
		pos += 1
	end
	local function putU32BE(v: number)
		for shift = 24, 0, -8 do
			putByte(bit32.band(bit32.rshift(v, shift), 255))
		end
	end

	for _, b in ipairs({ 137, 80, 78, 71, 13, 10, 26, 10 }) do
		putByte(b)
	end
	putU32BE(13)
	local ihdrStart = pos
	putU32BE(0x49484452)
	putU32BE(w)
	putU32BE(h)
	for _, b in ipairs({ 8, 6, 0, 0, 0 }) do
		putByte(b)
	end
	putU32BE(computeCrc32(out, ihdrStart, pos - 1))

	local raw = buffer.create(rawLen)
	for y = 0, h - 1 do
		buffer.copy(raw, y * rowBytes + 1, pixels, y * w * 4, w * 4)
	end

	putU32BE(zlibLen)
	local idatStart = pos
	putU32BE(0x49444154)
	putByte(0x78)
	putByte(0x01)

	local off = 0
	while off < rawLen do
		local chunk = math.min(65535, rawLen - off)
		local isLast = (off + chunk >= rawLen) and 1 or 0
		putByte(isLast)
		putByte(bit32.band(chunk, 255))
		putByte(bit32.rshift(chunk, 8))
		local nlen = bit32.band(bit32.bnot(chunk), 65535)
		putByte(bit32.band(nlen, 255))
		putByte(bit32.rshift(nlen, 8))
		buffer.copy(out, pos, raw, off, chunk)
		pos += chunk
		off += chunk
	end

	local s1, s2 = 1, 0
	for i = 0, rawLen - 1 do
		s1 = (s1 + buffer.readu8(raw, i)) % 65521
		s2 = (s2 + s1) % 65521
	end
	putU32BE(s2 * 65536 + s1)
	putU32BE(computeCrc32(out, idatStart, pos - 1))

	putU32BE(0)
	local iendStart = pos
	putU32BE(0x49454E44)
	putU32BE(computeCrc32(out, iendStart, pos - 1))

	return buffer.tostring(out)
end

local function fetchIconPng(assetId: string): string?
	if assetId == "" then
		return nil
	end
	if IconPngCache[assetId] ~= nil then
		return IconPngCache[assetId] or nil
	end
	local ok, png = pcall(function()
		local img = AssetService:CreateEditableImageAsync(Content.fromUri("rbxassetid://" .. assetId))
		local sz = img.Size
		local ow, oh = math.floor(sz.X), math.floor(sz.Y)
		local buf = img:ReadPixelsBuffer(Vector2.zero, sz)
		pcall(img.Destroy, img)
		local sc = math.min(1, 200 / math.max(ow, oh, 1))
		local nw, nh = math.max(1, math.floor(ow * sc)), math.max(1, math.floor(oh * sc))
		local resized = buffer.create(nw * nh * 4)
		for y = 0, nh - 1 do
			local sy = math.min(oh - 1, math.floor(y / sc))
			for x = 0, nw - 1 do
				buffer.copy(resized, (y * nw + x) * 4, buf, (sy * ow + math.min(ow - 1, math.floor(x / sc))) * 4, 4)
			end
		end
		return encodeRgbaPng(resized, nw, nh)
	end)
	IconPngCache[assetId] = (ok and type(png) == "string") and png or false
	return IconPngCache[assetId] or nil
end

local function fetchThumbnailUrl(url: string, requireImagePath: boolean): string?
	local okGet, body = pcall(game.HttpGet, game, url)
	if not okGet or type(body) ~= "string" then
		return nil
	end
	local okDec, dec = pcall(HttpService.JSONDecode, HttpService, body)
	local row = okDec and type(dec) == "table" and type(dec.data) == "table" and dec.data[1]
	local imgUrl = type(row) == "table" and row.state == "Completed" and row.imageUrl
	if type(imgUrl) == "string" and (not requireImagePath or imgUrl:find("/Image/", 1, true) ~= nil) then
		return imgUrl
	end
	return nil
end

local function getAssetFallbackUrl(assetId: string): string?
	if assetId == "" then
		return nil
	end
	if AssetUrlCache[assetId] == nil then
		AssetUrlCache[assetId] = fetchThumbnailUrl(
			"https://thumbnails.roblox.com/v1/assets?assetIds=" .. assetId .. "&returnPolicy=PlaceHolder&size=420x420&format=Png&isCircular=false",
			true
		) or false
	end
	return AssetUrlCache[assetId] or nil
end

local function getLocalAvatarUrl(): string?
	if not AvatarFetched then
		AvatarFetched = true
		local lp = Players.LocalPlayer
		if lp then
			AvatarHeadshotUrl = fetchThumbnailUrl(
				"https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. tostring(lp.UserId) .. "&size=150x150&format=Png&isCircular=false",
				false
			)
		end
	end
	return AvatarHeadshotUrl
end

local function isValidWebhookUrl(raw: string?): string?
	local clean = tostring(raw or TRex.Config.WebhookUrl or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if clean:match("^https://[%w%.]*discord[%w]*%.com/api/webhooks/%d+/[%w%-_]+") then
		return clean
	end
	return nil
end

local function processWebhookQueue()
	if WebhookSending then
		return
	end
	WebhookSending = true
	while #WebhookQueue > 0 do
		local url = isValidWebhookUrl()
		local reqFn = TRex.resolveGlobalFunc("request") or TRex.resolveGlobalFunc("http_request")
			or (type((_G :: any).syn) == "table" and (_G :: any).syn.request)
			or (type((_G :: any).http) == "table" and (_G :: any).http.request)
		if not url or type(reqFn) ~= "function" then
			table.clear(WebhookQueue)
			break
		end
		local item = table.remove(WebhookQueue, 1)
		local req: { [string]: any } = { Url = url, Method = "POST" }
		if item.png then
			local boundary = "TRex" .. HttpService:GenerateGUID(false):gsub("-", "")
			req.Headers = { ["Content-Type"] = "multipart/form-data; boundary=" .. boundary }
			req.Body = table.concat({
				"--", boundary,
				'\r\nContent-Disposition: form-data; name="payload_json"\r\nContent-Type: application/json\r\n\r\n',
				HttpService:JSONEncode(item.payload),
				"\r\n--", boundary,
				'\r\nContent-Disposition: form-data; name="files[0]"; filename="egg.png"\r\nContent-Type: image/png\r\n\r\n',
				item.png,
				"\r\n--", boundary, "--\r\n",
			})
		else
			req.Headers = { ["Content-Type"] = "application/json" }
			req.Body = HttpService:JSONEncode(item.payload)
		end

		local okReq, res = pcall(reqFn, req)
		local code = okReq and type(res) == "table" and tonumber(res.StatusCode) or 0
		if code == 429 and (item.tries or 0) < 3 then
			item.tries = (item.tries or 0) + 1
			table.insert(WebhookQueue, 1, item)
			task.wait(3)
		elseif code ~= 200 and code ~= 204 and item.png then
			item.png = nil
			item.payload.attachments = nil
			if item.payload.embeds and item.payload.embeds[1] then
				item.payload.embeds[1].thumbnail = item.alt and { url = item.alt } or nil
			end
			table.insert(WebhookQueue, 1, item)
		else
			WebhookSentCount += 1
		end
		setWebhookStatus()
		task.wait(1.2)
	end
	WebhookSending = false
	setWebhookStatus()
end

local function enqueueWebhookEmbed(embed: { [string]: any }, iconAssetId: string?)
	if not isValidWebhookUrl() then
		return
	end
	local lp = Players.LocalPlayer
	embed.author = {
		name = lp and lp.DisplayName or "Player",
		icon_url = getLocalAvatarUrl(),
	}
	embed.footer = { text = "T-Rex Hub • Game01" }
	embed.timestamp = DateTime.now():ToIsoDate()

	local payload: { [string]: any } = {
		username = "T-Rex Hub",
		embeds = { embed },
	}
	local png = iconAssetId and fetchIconPng(iconAssetId) or nil
	local altUrl = iconAssetId and getAssetFallbackUrl(iconAssetId) or nil
	if png then
		embed.thumbnail = { url = "attachment://egg.png" }
		payload.attachments = { { id = 0, filename = "egg.png" } }
	elseif altUrl then
		embed.thumbnail = { url = altUrl }
	end

	local contentParts = {}
	if TRex.Config.WebhookPingEveryone then
		table.insert(contentParts, "@everyone")
		payload.allowed_mentions = { parse = { "everyone" } }
	end
	table.insert(contentParts, tostring(game.JobId))
	payload.content = table.concat(contentParts, "\n")

	if #WebhookQueue >= 20 then
		table.remove(WebhookQueue, 1)
	end
	table.insert(WebhookQueue, { payload = payload, png = png, alt = altUrl, tries = 0 })
	setWebhookStatus()
	task.spawn(processWebhookQueue)
end

local function hasNotifySelection(name: string): boolean
	local list = TRex.Config.WebhookNotifyOn
	if type(list) ~= "table" then
		return true
	end
	return table.find(list, name) ~= nil
end

function Server.notifyWebhook(eventKind: string, data: any)
	local kindLower = tostring(eventKind or ""):lower()
	if kindLower == "egg stolen" or kindLower == "egg_stolen" then
		Server.markEggStolen(data)
	end
	if not TRex.Config.WebhookEnabled or not isValidWebhookUrl() then
		return
	end

	if kindLower == "inventory full" or kindLower == "inventory_full" then
		if not hasNotifySelection("Inventory Full") then
			return
		end
		local cnt = type(data) == "table" and (tonumber(data.count) or tonumber(data.Count)) or 115
		local cap = type(data) == "table" and (tonumber(data.max) or tonumber(data.Max)) or 115
		enqueueWebhookEmbed({
			title = "Egg Bag Full!",
			color = 16732245,
			description = ("**Eggs:** %d / %d\nPlace, hatch or sell to make room."):format(cnt, cap),
		}, nil)
		return
	end

	local rec = type(data) == "table" and data or {}
	if (kindLower == "egg fused" or kindLower == "egg_fused") and next(rec) == nil then
		return
	end

	local info = Core.computeEggInfo(rec)
	if kindLower == "egg_fished" or kindLower == "egg fished" then
		if not TRex.Config.WebhookPostFished then
			return
		end
		local minFish = tonumber(TRex.Config.WebhookFishedMinValue) or 0
		if minFish > 0 and info.Value < minFish then
			return
		end
	elseif kindLower == "egg fused" or kindLower == "egg_fused" then
		if not hasNotifySelection("Egg Fused") then
			return
		end
		if not Core.filterMatches(info, "Webhook", { specificKey = "WebhookEggs" }) then
			return
		end
	else
		if not hasNotifySelection("Egg Stolen") then
			return
		end
		if not Core.filterMatches(info, "Webhook", { specificKey = "WebhookEggs" }) then
			return
		end
	end

	local assets = Core.Modules and Core.Modules.Assets
	local entry = assets and type(assets.Directory) == "table" and assets.Directory[info.Category] or nil
	local col = (entry and type(entry.Rarity) == "table" and typeof(entry.Rarity.Color) == "Color3") and entry.Rarity.Color or nil
	local colorNum = col and (math.floor(col.R * 255 + 0.5) * 65536 + math.floor(col.G * 255 + 0.5) * 256 + math.floor(col.B * 255 + 0.5)) or 16019894
	local iconRaw = entry and ((kindLower:find("fused", 1, true) and entry.Egg and entry.Egg.Icon) or entry.Icon) or nil
	local iconId = iconRaw and tostring(iconRaw):match("%d+") or nil

	local title = if kindLower:find("fished", 1, true) then "Egg Fished!"
		elseif kindLower:find("fused", 1, true) then "Egg Fused!"
		else "Egg Stolen!"
	local areaTxt = tostring(rec.AreaId or rec.Area or "Field")
	local mutTxt = #info.Mutations > 0 and table.concat(info.Mutations, ", ") or "None"
	local desc = table.concat({
		("**%s** • %s"):format(info.Name, info.Rarity),
		("**Value:** $%s/s"):format(UI.formatCompactMoney(info.Value):gsub("^%$", "")),
		("**Size:** x%.2f • %.2f kg"):format(info.Scale, info.WeightKg),
		("**Mutation:** %s"):format(mutTxt),
		("**Area:** %s"):format(areaTxt),
	}, "\n")

	enqueueWebhookEmbed({ title = title, color = colorNum, description = desc }, iconId)
end

-- Egg & Fuse Predictor
local function computePredictorSnapshot(): (string, { { name: string, status: string, value: number, rarity: string, scale: number, rank: number } }, string)
	local lp = Players.LocalPlayer
	local eggsOut: { { name: string, status: string, value: number, rarity: string, scale: number, rank: number } } = {}
	local okRead, owned = pcall(function()
		return lp and Core.callModule("Egg", "ReadOwnerEggs", lp.UserId) or nil
	end)
	local filterMode = tostring(TRex.Config.PredictorFilter or "All")
	local now = Core.getServerNow()

	if okRead and type(owned) == "table" then
		for uid, rec in pairs(owned) do
			if type(rec) == "table" then
				local info = Core.computeEggInfo(rec)
				local st = "Inventory"
				if rec.Placement ~= nil then
					local okR, isReady = pcall(Core.callModule, "Egg", "IsReadyToHatch", uid)
					if okR and isReady == true then
						st = "Ready"
					else
						st = "Growing"
					end
				end
				if filterMode == "All" or st == filterMode then
					table.insert(eggsOut, {
						name = info.Name,
						status = st,
						value = info.Value,
						rarity = info.Rarity,
						scale = info.Scale,
						rank = info.RarityRank,
					})
				end
			end
		end
	end

	local sortKey = tostring(TRex.Config.PredictorSort or "Value")
	table.sort(eggsOut, function(a, b)
		if sortKey == "Rarity" and a.rank ~= b.rank then
			return a.rank > b.rank
		elseif sortKey == "Size" and a.scale ~= b.scale then
			return a.scale > b.scale
		elseif a.value ~= b.value then
			return a.value > b.value
		end
		return a.name < b.name
	end)

	local fuseSummary = "เครื่องหลอม: ว่าง"
	local save = Core.getSaveData()
	if type(save) == "table" then
		local slots = type(save.FusionSlots) == "table" and save.FusionSlots or {}
		local inv = type(save.Inventory) == "table" and save.Inventory or {}
		local loaded: { { cat: string, scale: number } } = {}
		for i = 1, 3 do
			local uid = slots[i]
			local pet = uid and inv[uid]
			if type(pet) == "table" then
				table.insert(loaded, { cat = tostring(pet.Category), scale = tonumber(pet.Scale) or 1 })
			end
		end
		local rw = save.FusionEggReward
		if type(rw) == "table" and type(rw.Egg) == "table" then
			local info = Core.computeEggInfo(rw.Egg)
			fuseSummary = ("ผลลัพธ์ยืนยันแล้ว: %s (x%.2f • %s/s)"):format(info.Name, info.Scale, UI.formatCompactMoney(info.Value))
		elseif save.FusionLocked and (tonumber(save.FusionDuration) or 0) > now then
			fuseSummary = ("กำลังหลอม: เหลืออีก %.0f วิ"):format(math.max(0, (tonumber(save.FusionDuration) or 0) - now))
		elseif #loaded == 3 then
			local avgScale = (loaded[1].scale + loaded[2].scale + loaded[3].scale) / 3
			local scales = { loaded[1].scale, loaded[2].scale, loaded[3].scale }
			local totalW, topBand, topW = 0, SCALE_BANDS[1], 0
			for _, band in ipairs(SCALE_BANDS) do
				local okBias, bias = pcall(Core.callModule, "Fuse", "BandWeightBias", scales, band.min, band.max)
				local w = band.weight * (okBias and tonumber(bias) or 1)
				totalW += w
				if w > topW then
					topW = w
					topBand = band
				end
			end
			local infoSample = Core.computeEggInfo({ AssetCategory = loaded[1].cat, AssetScale = (topBand.min + topBand.max) / 2 })
			local topPct = totalW > 0 and (topW / totalW * 100) or 0
			fuseSummary = ("ทำนายหลอม %s: เฉลี่ย x%.2f • เด่นสุด %.2fx-%.2fx (%.1f%%) ≈ %s/s"):format(
				infoSample.Name,
				avgScale,
				topBand.min,
				topBand.max,
				topPct,
				UI.formatCompactMoney(infoSample.Value)
			)
		elseif #loaded > 0 then
			fuseSummary = ("เครื่องหลอม: ใส่แล้ว %d/3 ตัว"):format(#loaded)
		end
	end

	local topStr = #eggsOut > 0 and ("ไข่ %d ฟอง • สูงสุด %s (%s/s)"):format(#eggsOut, eggsOut[1].name, UI.formatCompactMoney(eggsOut[1].value)) or "ยังไม่มีไข่ตามตัวกรอง"
	return topStr .. " | " .. fuseSummary, eggsOut, fuseSummary
end

local function destroyPredictorOverlay()
	if PredictorGui then
		pcall(PredictorGui.Destroy, PredictorGui)
		PredictorGui = nil
		PredictorRowsFrame = nil
		PredictorFuseLbl = nil
	end
end

local function ensurePredictorOverlay(): boolean
	if PredictorGui and PredictorGui.Parent then
		return true
	end
	local gui = Instance.new("ScreenGui")
	gui.Name = "TRexPredictorOverlay"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 45
	gui.Parent = TRex.getGuiParent(gui) or CoreGui

	local panel = Instance.new("Frame")
	panel.Size = UDim2.fromOffset(330, 260)
	panel.Position = UDim2.new(1, -346, 0.5, -130)
	panel.BackgroundColor3 = Color3.fromRGB(22, 20, 30)
	panel.BackgroundTransparency = 0.08
	panel.BorderSizePixel = 0
	panel.Active = true
	panel.Draggable = true
	panel.Parent = gui
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(236, 72, 153)
	stroke.Thickness = 1.2
	stroke.Transparency = 0.25
	stroke.Parent = panel

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -16, 0, 26)
	title.Position = UDim2.fromOffset(8, 4)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 13
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Color3.fromRGB(255, 224, 240)
	title.Text = "ตัวทำนายไข่และเครื่องหลอม"
	title.Parent = panel

	local fuseLbl = Instance.new("TextLabel")
	fuseLbl.Size = UDim2.new(1, -16, 0, 32)
	fuseLbl.Position = UDim2.fromOffset(8, 30)
	fuseLbl.BackgroundColor3 = Color3.fromRGB(34, 28, 44)
	fuseLbl.BorderSizePixel = 0
	fuseLbl.Font = Enum.Font.GothamMedium
	fuseLbl.TextSize = 11
	fuseLbl.TextWrapped = true
	fuseLbl.TextColor3 = Color3.fromRGB(167, 243, 208)
	fuseLbl.Text = "เครื่องหลอม: ว่าง"
	fuseLbl.Parent = panel
	Instance.new("UICorner", fuseLbl).CornerRadius = UDim.new(0, 6)

	local body = Instance.new("Frame")
	body.Size = UDim2.new(1, -16, 1, -72)
	body.Position = UDim2.fromOffset(8, 66)
	body.BackgroundTransparency = 1
	body.Parent = panel
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.Parent = body

	for i = 1, 7 do
		local r = Instance.new("TextLabel")
		r.Name = "Row" .. i
		r.Size = UDim2.new(1, 0, 0, 22)
		r.BackgroundColor3 = Color3.fromRGB(30, 26, 40)
		r.BorderSizePixel = 0
		r.Font = Enum.Font.Gotham
		r.TextSize = 11
		r.TextXAlignment = Enum.TextXAlignment.Left
		r.TextColor3 = Color3.fromRGB(241, 245, 249)
		r.Text = ""
		r.Visible = false
		r.Parent = body
		Instance.new("UICorner", r).CornerRadius = UDim.new(0, 5)
	end

	PredictorGui = gui
	PredictorRowsFrame = body
	PredictorFuseLbl = fuseLbl
	return true
end

local function updatePredictor()
	local summary, eggs, fuseTxt = computePredictorSnapshot()
	if PredictorSummaryRow and PredictorSummaryRow.Set then
		PredictorSummaryRow:Set(summary)
	end
	if not TRex.Config.PredictorEnabled then
		destroyPredictorOverlay()
		return
	end
	if ensurePredictorOverlay() and PredictorFuseLbl and PredictorRowsFrame then
		PredictorFuseLbl.Text = fuseTxt
		for i = 1, 7 do
			local lbl = PredictorRowsFrame:FindFirstChild("Row" .. i)
			if lbl and lbl:IsA("TextLabel") then
				local row = eggs[i]
				if row then
					lbl.Visible = true
					lbl.Text = (" #%d %s [%s] x%.2f • %s/s (%s)"):format(
						i,
						row.name,
						row.rarity,
						row.scale,
						UI.formatCompactMoney(row.value),
						row.status
					)
				else
					lbl.Visible = false
				end
			end
		end
	end
end

function Server.init()
	TRex.registerCleanupHook(destroyPredictorOverlay)

	TRex.connectSignal(TeleportService.TeleportInitFailed, function(plr)
		if plr == Players.LocalPlayer then
			if HopPendingJob then
				FailedJobIds[HopPendingJob] = true
			end
			IsHopping = false
			if TRex.IsRunning and TRex.Config.AutoHop then
				task.delay(1.5, function()
					if TRex.IsRunning and TRex.Config.AutoHop then
						Server.hopServer()
					end
				end)
			end
		end
	end)

	local lp = Players.LocalPlayer
	if lp then
		TRex.connectSignal(lp.OnTeleport, function(state)
			LastTeleportAt = os.clock()
			if state == Enum.TeleportState.Started or state == Enum.TeleportState.InProgress then
				TeleportStarted = true
				Server.queueAutoLoadScript()
			end
		end)
	end

	TRex.connectSignal(GuiService.ErrorMessageChanged, function(msg)
		if not TRex.IsRunning or not TRex.Config.AutoRejoin or IsRejoining or IsHopping then
			return
		end
		local lower = tostring(msg or ""):lower()
		if lower == "" or lower:find("teleport") or lower:find("full") or lower:find("ban") or lower:find("same account") or lower:find("duplicate") then
			return
		end
		if os.clock() - LastTeleportAt < 45 then
			return
		end
		local okErr, errCode = pcall(function()
			return GuiService:GetErrorCode().Value
		end)
		if okErr and type(errCode) == "number" and errCode >= 769 and errCode <= 779 then
			return
		end
		IsRejoining = true
		task.spawn(function()
			local closed = lower:find("shut") ~= nil or lower:find("no longer") ~= nil or lower:find("closed") ~= nil
			for attempt = 1, 20 do
				if not TRex.IsRunning or not TRex.Config.AutoRejoin then
					break
				end
				Server.queueAutoLoadScript()
				if closed or attempt > 2 then
					pcall(TeleportService.Teleport, TeleportService, game.PlaceId, Players.LocalPlayer)
				else
					pcall(TeleportService.TeleportToPlaceInstance, TeleportService, game.PlaceId, game.JobId, Players.LocalPlayer)
				end
				task.wait(closed and 5 or 4)
			end
			IsRejoining = false
		end)
	end)
end

function Server.buildUI(ui)
	local tab = ui.addTab("server", "tab.server", 4)

	local secHop = tab:addSection("sec.server_hop")
	HopStatusRow = secHop:addText({ key = "_HopStatus", label = "สถานะย้ายเซิร์ฟเวอร์", text = "รอ / พัก" })
	secHop:addToggle({
		key = "AutoHop",
		label = "opt.auto_hop",
		onChanged = function(v)
			if not v then
				setHopStatus("รอ / พัก")
			end
		end,
	})
	secHop:addDropdown({
		key = "HopMode",
		label = "opt.hop_mode",
		items = { "Least Players", "Most Players", "Random" },
	})
	secHop:addDropdown({
		key = "HopCondition",
		label = "opt.hop_condition",
		items = { "Match Steal Filter", "Until An Egg Matches", "Steal Then Hop", "After A Rare Spawns" },
	})
	secHop:addSlider({ key = "HopDelaySeconds", label = "opt.hop_delay", min = 1, max = 30, step = 1, suffix = " วิ" })
	secHop:addToggle({ key = "AutoRejoin", label = "opt.auto_rejoin" })
	secHop:addToggle({
		key = "AutoLoadScript",
		label = "opt.auto_load",
		onChanged = function(v)
			Server.queueAutoLoadScript(v == true)
		end,
	})
	secHop:addTextInput({ key = "JobId", label = "opt.job_id", placeholderKey = "msg.jobid_placeholder" })
	secHop:addButton({
		label = "btn.hop_now",
		primary = true,
		onClick = function()
			task.spawn(Server.hopServer)
		end,
	})
	secHop:addButton({
		label = "btn.join_job",
		onClick = function()
			Server.joinJobId()
		end,
	})
	secHop:addButton({
		label = "btn.rejoin",
		onClick = function()
			Server.rejoinServer()
		end,
	})
	secHop:addButton({
		label = "btn.copy_job",
		onClick = function()
			Server.copyJobId()
		end,
	})

	local secPred = tab:addSection("sec.predictor")
	PredictorSummaryRow = secPred:addText({ key = "_PredStatus", label = "สรุปการทำนาย", text = "-" })
	secPred:addToggle({
		key = "PredictorEnabled",
		label = "opt.predictor_enable",
		onChanged = function()
			updatePredictor()
		end,
	})
	secPred:addDropdown({
		key = "PredictorSort",
		label = "opt.predictor_sort",
		items = { "Value", "Rarity", "Size" },
		onChanged = function()
			updatePredictor()
		end,
	})
	secPred:addDropdown({
		key = "PredictorFilter",
		label = "opt.predictor_filter",
		items = { "All", "Ready", "Growing", "Inventory" },
		onChanged = function()
			updatePredictor()
		end,
	})

	local secWh = tab:addSection("sec.webhook")
	WebhookStatusRow = secWh:addText({ key = "_WhStatus", label = "สถานะเว็บฮุก", text = "ส่ง 0 • รอคิว 0" })
	local tgWh = secWh:addToggle({ key = "WebhookEnabled", label = "opt.webhook_enabled" })
	secWh:addTextInput({ key = "WebhookUrl", label = "opt.webhook_url", placeholderKey = "msg.webhook_placeholder" }):When(tgWh, true)
	secWh:addToggle({ key = "WebhookPingEveryone", label = "opt.wh_ping" }):When(tgWh, true)
	secWh:addDropdown({
		key = "WebhookNotifyOn",
		label = "opt.wh_notify_on",
		items = { "Egg Stolen", "Egg Fused", "Inventory Full" },
		multi = true,
		emptyLabel = "msg.none",
	}):When(tgWh, true)
	secWh:addDropdown({ key = "WebhookMinRarity", label = "opt.wh_min_rarity", items = Core.RARITY_ORDER }):When(tgWh, true)
	secWh:addSlider({ key = "WebhookMinValue", label = "opt.wh_min_value", log = true }):When(tgWh, true)
	secWh:addDropdown({ key = "WebhookEggs", label = "opt.wh_eggs", getItems = Core.eggList, multi = true }):When(tgWh, true)
	local tgFish = secWh:addToggle({ key = "WebhookPostFished", label = "opt.wh_post_fished" }):When(tgWh, true)
	secWh:addSlider({ key = "WebhookFishedMinValue", label = "opt.wh_fish_min_val", log = true }):When(function()
		return TRex.Config.WebhookEnabled == true and TRex.Config.WebhookPostFished == true
	end)
	local _ = tgFish
	secWh:addButton({
		label = "btn.test_webhook",
		onClick = function()
			if not isValidWebhookUrl() then
				UI.notify("tab.server", "กรุณากรอกลิงก์เว็บฮุกดิสคอร์ดให้ถูกต้องก่อน", 2.5)
				return
			end
			enqueueWebhookEmbed({
				title = "T-Rex Hub Webhook Test",
				color = 16019894,
				description = "การเชื่อมต่อเว็บฮุกดิสคอร์ดพร้อมใช้งานแล้ว!",
			}, nil)
			UI.notify("tab.server", "ส่งข้อความทดสอบเข้าคิวเว็บฮุกแล้ว", 2.5)
		end,
	}):When(tgWh, true)
end

function Server.startLoop()
	Server.queueAutoLoadScript()

	task.spawn(function()
		while TRex.IsRunning do
			pcall(stepAutoHop)

			if os.clock() - PredictorLastRefresh >= 1 then
				PredictorLastRefresh = os.clock()
				pcall(updatePredictor)
			end

			local save = Core.getSaveData()
			if type(save) == "table" then
				local invCount = 0
				for _ in pairs(type(save.EggInventory) == "table" and save.EggInventory or {}) do
					invCount += 1
				end
				local isFull = invCount >= 115
				if isFull and not InventoryFullAlerted then
					Server.notifyWebhook("Inventory Full", { count = invCount, max = 115 })
				end
				InventoryFullAlerted = isFull

				local rw = save.FusionEggReward
				local uid = type(rw) == "table" and rw.Uid and tostring(rw.Uid) or nil
				if not InitialFuseScanned then
					InitialFuseScanned = true
					if uid then
						SeenFusedUids[uid] = true
					end
				elseif uid and not SeenFusedUids[uid] then
					SeenFusedUids[uid] = true
					local eggRec = type(rw.Egg) == "table" and rw.Egg or {}
					Server.notifyWebhook("Egg Fused", eggRec)
				end
			end

			task.wait(0.8)
		end
	end)
end

return Server
