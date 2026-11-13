-- T-Rex Hub • Game01 (Steal An Egg) | Thai Clean UI Build
-- Built from UniversalCode/* + Games/Game01/Modules/01..07 + Games/Game01/Lang/{th,en-us,vi,zh}.json

-- ============================================================================
-- [UniversalCode/00_env_io.lua]
-- ============================================================================
-- T-RexProject/UniversalCode/00_env_io.lua
-- Shared environment shims, Roblox services, path/folder helpers, asset loader, and singleton lifecycle.

local TRex = {}
TRex.GameId = "Game01"
TRex.Version = "1.0.0"

local function getService(name)
	return game:GetService(name)
end

TRex.Services = {
	Players = getService("Players"),
	ReplicatedStorage = getService("ReplicatedStorage"),
	RunService = getService("RunService"),
	TweenService = getService("TweenService"),
	UserInputService = getService("UserInputService"),
	CollectionService = getService("CollectionService"),
	Lighting = getService("Lighting"),
	SoundService = getService("SoundService"),
	HttpService = getService("HttpService"),
	TeleportService = getService("TeleportService"),
	GuiService = getService("GuiService"),
	StarterGui = getService("StarterGui"),
	Workspace = getService("Workspace"),
	CoreGui = getService("CoreGui"),
}

TRex.LocalPlayer = TRex.Services.Players.LocalPlayer or TRex.Services.Players.PlayerAdded:Wait()

function TRex.resolveGlobalFunc(name)
	local okGenv, genv = pcall(function()
		return type(getgenv) == "function" and getgenv() or nil
	end)
	if okGenv and type(genv) == "table" and type(genv[name]) == "function" then
		return genv[name]
	end
	if type(_G) == "table" and type(_G[name]) == "function" then
		return _G[name]
	end
	return nil
end

TRex.GlobalEnv = (type(getgenv) == "function" and getgenv()) or _G

function TRex.normalizePath(relPath)
	if type(relPath) ~= "string" then
		return ""
	end
	local p = relPath:gsub("\\", "/")
	p = p:gsub("^%./", "")
	p = p:gsub("/+", "/")
	return p
end

function TRex.ensureFolderChain(relFolder)
	local isfolderFn = TRex.resolveGlobalFunc("isfolder")
	local makefolderFn = TRex.resolveGlobalFunc("makefolder")
	if not isfolderFn or not makefolderFn then
		return false
	end
	local norm = TRex.normalizePath(relFolder)
	if norm == "" then
		return false
	end
	local current = ""
	for segment in norm:gmatch("[^/]+") do
		current = (current == "") and segment or (current .. "/" .. segment)
		local okCheck, exists = pcall(isfolderFn, current)
		if not okCheck or not exists then
			local okMake = pcall(makefolderFn, current)
			if not okMake then
				return false
			end
		end
	end
	return true
end

function TRex.hasFileIO()
	return TRex.resolveGlobalFunc("isfile") ~= nil
		and TRex.resolveGlobalFunc("readfile") ~= nil
		and TRex.resolveGlobalFunc("writefile") ~= nil
		and TRex.resolveGlobalFunc("isfolder") ~= nil
		and TRex.resolveGlobalFunc("makefolder") ~= nil
end

function TRex.safeReadFile(relPath)
	local isfileFn = TRex.resolveGlobalFunc("isfile")
	local readfileFn = TRex.resolveGlobalFunc("readfile")
	if not isfileFn or not readfileFn then
		return nil
	end
	local p = TRex.normalizePath(relPath)
	local okExists, exists = pcall(isfileFn, p)
	if not okExists or not exists then
		return nil
	end
	local okRead, content = pcall(readfileFn, p)
	if okRead and type(content) == "string" then
		return content
	end
	return nil
end

function TRex.safeWriteFile(relPath, content)
	local writefileFn = TRex.resolveGlobalFunc("writefile")
	if not writefileFn then
		return false
	end
	local p = TRex.normalizePath(relPath)
	local parentFolder = p:match("^(.*)/[^/]+$")
	if parentFolder and parentFolder ~= "" then
		TRex.ensureFolderChain(parentFolder)
	end
	local ok = pcall(writefileFn, p, tostring(content))
	return ok
end

function TRex.loadTRexLogoAsset()
	local isfileFn = TRex.resolveGlobalFunc("isfile")
	local getcustomassetFn = TRex.resolveGlobalFunc("getcustomasset") or TRex.resolveGlobalFunc("getsynasset")
	if not isfileFn or not getcustomassetFn then
		return nil
	end
	local logoPath = TRex.normalizePath("T-RexProject/Assets/T-RexLogo.png")
	local okExists, exists = pcall(isfileFn, logoPath)
	if not okExists or not exists then
		return nil
	end
	local okAsset, assetId = pcall(getcustomassetFn, logoPath)
	if okAsset and type(assetId) == "string" and assetId ~= "" then
		return assetId
	end
	return nil
end

function TRex.cloneTable(tbl)
	if type(tbl) ~= "table" then
		return tbl
	end
	local copy = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			copy[k] = TRex.cloneTable(v)
		else
			copy[k] = v
		end
	end
	return copy
end

function TRex.safeEnumFont(fontName, fallback)
	local ok, res = pcall(function()
		return Enum.Font[fontName]
	end)
	if ok and res then
		return res
	end
	return fallback or Enum.Font.GothamMedium
end

function TRex.safeKeyCode(keyName)
	if type(keyName) ~= "string" or keyName == "" then
		return nil
	end
	local ok, res = pcall(function()
		return Enum.KeyCode[keyName]
	end)
	if ok and res then
		return res
	end
	return nil
end

function TRex.isTextBoxFocused()
	local ok, focused = pcall(TRex.Services.UserInputService.GetFocusedTextBox, TRex.Services.UserInputService)
	return ok and focused ~= nil
end

-- Lifecycle & Singleton Cleanup
TRex.IsRunning = true
TRex.ActiveConnections = {}
TRex.CleanupHooks = {}
TRex.ReportFailure = nil

function TRex.runPreviousCleanup(gameId)
	local key = "__TRexCleanup_" .. tostring(gameId or TRex.GameId)
	if type(TRex.GlobalEnv[key]) == "function" then
		pcall(TRex.GlobalEnv[key])
	end
	if type(TRex.GlobalEnv.__ThaiCleanHubCleanup) == "function" then
		pcall(TRex.GlobalEnv.__ThaiCleanHubCleanup)
	end
end

function TRex.registerCleanupHook(fn)
	if type(fn) == "function" then
		table.insert(TRex.CleanupHooks, fn)
	end
end

function TRex.connectSignal(sig, fn)
	if not sig then
		return nil
	end
	local okConn, conn = pcall(function()
		return sig:Connect(function(...)
			if not TRex.IsRunning then
				return
			end
			local ok, err = pcall(fn, ...)
			if not ok and TRex.ReportFailure then
				TRex.ReportFailure("Signal", err)
			end
		end)
	end)
	if not okConn or not conn then
		return nil
	end
	table.insert(TRex.ActiveConnections, conn)
	if #TRex.ActiveConnections % 64 == 0 then
		for i = #TRex.ActiveConnections, 1, -1 do
			if not TRex.ActiveConnections[i].Connected then
				table.remove(TRex.ActiveConnections, i)
			end
		end
	end
	return conn
end

function TRex.bindClick(button, callback)
	local downPos = nil
	local function trigger()
		if not TRex.IsRunning then
			return
		end
		local ok, err = pcall(callback)
		if not ok and TRex.ReportFailure then
			TRex.ReportFailure("UI", err)
		end
	end
	if button:IsA("GuiButton") then
		TRex.connectSignal(button.Activated, trigger)
	else
		TRex.connectSignal(button.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				downPos = input.Position
			end
		end)
		TRex.connectSignal(button.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if downPos and (input.Position - downPos).Magnitude <= 20 then
					downPos = nil
					trigger()
				else
					downPos = nil
				end
			end
		end)
	end
end

function TRex.mountScreenGui(gui)
	local gethuiFn = TRex.resolveGlobalFunc("gethui")
	if gethuiFn then
		pcall(function()
			local hui = gethuiFn()
			local old = hui and hui:FindFirstChild(gui.Name)
			if old then
				old:Destroy()
			end
		end)
	end
	pcall(function()
		local old = TRex.Services.CoreGui:FindFirstChild(gui.Name)
		if old then
			old:Destroy()
		end
	end)
	local pGui = TRex.LocalPlayer:FindFirstChildOfClass("PlayerGui") or TRex.LocalPlayer:WaitForChild("PlayerGui", 10)
	if pGui then
		local okP = pcall(function()
			local old = pGui:FindFirstChild(gui.Name)
			if old then
				old:Destroy()
			end
			gui.DisplayOrder = 999999
			gui.Parent = pGui
		end)
		if okP and gui.Parent == pGui then
			return pGui
		end
	end
	if gethuiFn then
		local ok, hui = pcall(gethuiFn)
		if ok and hui then
			local okMount = pcall(function()
				gui.Parent = hui
			end)
			if okMount and gui.Parent == hui then
				return hui
			end
		end
	end
	return nil
end

function TRex.cleanup()
	if not TRex.IsRunning then
		return
	end
	TRex.IsRunning = false
	for i = #TRex.CleanupHooks, 1, -1 do
		pcall(TRex.CleanupHooks[i])
	end
	table.clear(TRex.CleanupHooks)
	for _, conn in ipairs(TRex.ActiveConnections) do
		pcall(function()
			conn:Disconnect()
		end)
	end
	table.clear(TRex.ActiveConnections)
	TRex.GlobalEnv["__TRexCleanup_" .. tostring(TRex.GameId)] = nil
	TRex.GlobalEnv["__TRex" .. tostring(TRex.GameId) .. "API"] = nil
end

-- ============================================================================
-- [UniversalCode/01_config_lang.lua]
-- ============================================================================
-- T-RexProject/UniversalCode/01_config_lang.lua
-- Shared JSON Config persistence and 4-language i18n engine (th default, en-us, vi, zh).

local HttpService = TRex.Services.HttpService

TRex.ConfigDir = "T-RexProject/Games/" .. TRex.GameId .. "/Config"
TRex.LangDir = "T-RexProject/Games/" .. TRex.GameId .. "/Lang"

TRex.SUPPORTED_LANGUAGES = {
	{ code = "th", label = "ไทย" },
	{ code = "en-us", label = "English (US)" },
	{ code = "vi", label = "Tiếng Việt" },
	{ code = "zh", label = "中文" },
}

TRex.DEFAULT_CONFIG = {
	SchemaVersion = 1,
	Language = "th",
	Theme = "ชมพูซากุระ",
	Font = "โกธิคทันสมัย",
	FontSize = 14,
	GuiScalePercent = 100,
	BackgroundTransparency = 0.04,
	BackgroundBlur = false,
	ToggleKey = "RightControl",
	PanicKey = "End",
	AntiAFK = true,
	-- Core & Farm
	AutoSteal = false,
	StealGoMode = "Teleport",
	StealReturnMode = "FastTween",
	StealSortMode = "Best Rarity",
	StealMinRarity = "Rare",
	StealSafeCrossing = true,
	AutoTreadmill = false,
	AutoTreadmillTier = false,
	AutoBuyTrail = false,
	AutoUpgradeBase = false,
	AutoPlaceEgg = false,
	AutoHatch = false,
	AutoFusery = false,
	FuseMaxRarity = "Mythic",
	FuseSkipMutated = true,
	AutoMutate = false,
	AutoSellPets = false,
	AutoSellEggs = false,
	WearBestPet = false,
	-- Events & Minigames
	AutoButterfly = false,
	ButterflyPriority = "Nearest",
	ButterflySpeed = 120,
	AutoClaimNet = true,
	AutoTradeButterfly = false,
	AutoCraftEssence = false,
	AutoWispQuest = false,
	AutoAdminAbuse = false,
	AutoFishing = false,
	AutoShootingStar = false,
	AutoAlienLagoon = false,
	AutoBanjoCricket = false,
	AutoCollectAway = false,
	AutoRedeemCodex = false,
	-- Movement & Combat
	FastTween = false,
	TweenSpeed = 3300,
	VelocityGlide = false,
	RagdollTP = false,
	CustomSpeedEnabled = false,
	WalkSpeedValue = 32,
	JumpPowerValue = 50,
	AutoBatSwing = false,
	BatAimPredict = true,
	-- Server & Webhooks
	AutoHop = false,
	HopMode = "LeastPlayers",
	HopCondition = "UntilEggMatches",
	WebhookEnabled = false,
	WebhookUrl = "",
	-- Render & ESP
	PlayerESP = false,
	PlayerTracker = false,
	GuardESP = false,
	EggESP = false,
	OwnBaseEggESP = false,
	OtherBaseEggESP = false,
	RevealEggContent100 = false,
	ShowSafeZoneMarker = false,
	ShowFPSPingHUD = false,
	-- Optimizer
	Disable3DRender = false,
	FPSCapEnabled = false,
	FPSCapValue = 60,
	LowPowerMode = false,
	LowGraphics = false,
	HideGameUI = false,
	HideTreadmill = false,
}

TRex.Config = TRex.cloneTable(TRex.DEFAULT_CONFIG)
TRex.CurrentProfileName = "Default"
TRex.ProfilesStore = {}

local VALID_LANG_SET = { ["th"] = true, ["en-us"] = true, ["vi"] = true, ["zh"] = true }

local function sanitizeValue(defaultVal, incomingVal)
	local dType = type(defaultVal)
	if dType == "boolean" then
		if type(incomingVal) == "boolean" then
			return incomingVal
		end
		return defaultVal
	elseif dType == "number" then
		if type(incomingVal) == "number" and incomingVal == incomingVal and math.abs(incomingVal) < math.huge then
			return incomingVal
		end
		return defaultVal
	elseif dType == "string" then
		if type(incomingVal) == "string" then
			return incomingVal
		end
		return defaultVal
	elseif dType == "table" then
		if type(incomingVal) ~= "table" then
			return TRex.cloneTable(defaultVal)
		end
		local merged = {}
		for k, v in pairs(defaultVal) do
			merged[k] = sanitizeValue(v, incomingVal[k])
		end
		return merged
	end
	return defaultVal
end

function TRex.sanitizeConfig(tbl)
	local out = TRex.cloneTable(TRex.DEFAULT_CONFIG)
	if type(tbl) ~= "table" then
		return out
	end
	for k, defVal in pairs(TRex.DEFAULT_CONFIG) do
		out[k] = sanitizeValue(defVal, tbl[k])
	end
	if not VALID_LANG_SET[out.Language] then
		out.Language = "th"
	end
	out.FontSize = math.clamp(math.floor(out.FontSize + 0.5), 8, 40)
	out.GuiScalePercent = math.clamp(math.floor(out.GuiScalePercent + 0.5), 50, 200)
	out.BackgroundTransparency = math.clamp(out.BackgroundTransparency, 0, 0.9)
	out.TweenSpeed = math.clamp(out.TweenSpeed, 20, 1000)
	out.ButterflySpeed = math.clamp(out.ButterflySpeed, 20, 600)
	out.WalkSpeedValue = math.clamp(out.WalkSpeedValue, 16, 500)
	out.JumpPowerValue = math.clamp(out.JumpPowerValue, 20, 300)
	out.FPSCapValue = math.clamp(math.floor(out.FPSCapValue + 0.5), 10, 360)
	return out
end

function TRex.applyProfileTableToConfig(tbl)
	local clean = TRex.sanitizeConfig(tbl)
	for k, v in pairs(clean) do
		TRex.Config[k] = v
	end
end

function TRex.saveConfig(profileName)
	local name = tostring(profileName or TRex.CurrentProfileName or "Default"):gsub("[^%w_%-%s]", "")
	if name == "" then
		name = "Default"
	end
	TRex.CurrentProfileName = name
	TRex.ProfilesStore[name] = TRex.cloneTable(TRex.Config)
	if not TRex.hasFileIO() then
		return false, "no_io"
	end
	TRex.ensureFolderChain(TRex.ConfigDir)
	local okEnc, encoded = pcall(HttpService.JSONEncode, HttpService, TRex.Config)
	if not okEnc or type(encoded) ~= "string" then
		return false, "encode_failed"
	end
	local okWrite = TRex.safeWriteFile(TRex.ConfigDir .. "/" .. name .. ".json", encoded)
	local okMetaEnc, metaJson = pcall(HttpService.JSONEncode, HttpService, { ActiveProfile = name })
	if okMetaEnc then
		TRex.safeWriteFile(TRex.ConfigDir .. "/Meta.json", metaJson)
	end
	return okWrite, okWrite and "ok" or "write_failed"
end

function TRex.loadConfig(profileName)
	if not TRex.hasFileIO() then
		TRex.applyProfileTableToConfig(TRex.DEFAULT_CONFIG)
		return false, "no_io"
	end
	TRex.ensureFolderChain(TRex.ConfigDir)
	local targetName = profileName
	if not targetName then
		local metaRaw = TRex.safeReadFile(TRex.ConfigDir .. "/Meta.json")
		if metaRaw then
			local okMeta, metaTbl = pcall(HttpService.JSONDecode, HttpService, metaRaw)
			if okMeta and type(metaTbl) == "table" and type(metaTbl.ActiveProfile) == "string" then
				targetName = metaTbl.ActiveProfile
			end
		end
	end
	targetName = tostring(targetName or "Default"):gsub("[^%w_%-%s]", "")
	if targetName == "" then
		targetName = "Default"
	end
	TRex.CurrentProfileName = targetName
	local raw = TRex.safeReadFile(TRex.ConfigDir .. "/" .. targetName .. ".json")
	if raw then
		local okDec, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
		if okDec and type(decoded) == "table" then
			TRex.applyProfileTableToConfig(decoded)
			TRex.ProfilesStore[targetName] = TRex.cloneTable(TRex.Config)
			return true, "loaded"
		end
	end
	TRex.applyProfileTableToConfig(TRex.DEFAULT_CONFIG)
	TRex.saveConfig(targetName)
	return true, "created_default"
end

function TRex.listProfiles()
	local names = { "Default" }
	local seen = { Default = true }
	for k in pairs(TRex.ProfilesStore) do
		if not seen[k] then
			seen[k] = true
			table.insert(names, k)
		end
	end
	local listfilesFn = TRex.resolveGlobalFunc("listfiles")
	if listfilesFn and TRex.hasFileIO() then
		local ok, files = pcall(listfilesFn, TRex.normalizePath(TRex.ConfigDir))
		if ok and type(files) == "table" then
			for _, f in ipairs(files) do
				local base = tostring(f):gsub("\\", "/"):match("([^/]+)%.json$")
				if base and base ~= "Meta" and base ~= "AutoHopCache" and not seen[base] then
					seen[base] = true
					table.insert(names, base)
				end
			end
		end
	end
	table.sort(names)
	return names
end

-- Multi-language engine
TRex.EmbeddedLang = {
	["th"] = {},
	["en-us"] = {},
	["vi"] = {},
	["zh"] = {},
}
TRex.ActiveLang = {}
TRex.ThaiDefaultLang = {}
TRex.LanguageChangedCallbacks = {}

function TRex.registerEmbeddedLang(packs)
	if type(packs) ~= "table" then
		return
	end
	for code, dict in pairs(packs) do
		if TRex.EmbeddedLang[code] and type(dict) == "table" then
			for k, v in pairs(dict) do
				TRex.EmbeddedLang[code][k] = v
			end
		end
	end
end

function TRex.initLangPacks()
	TRex.ThaiDefaultLang = TRex.cloneTable(TRex.EmbeddedLang["th"] or {})
	if TRex.hasFileIO() then
		TRex.ensureFolderChain(TRex.LangDir)
		for _, langInfo in ipairs(TRex.SUPPORTED_LANGUAGES) do
			local code = langInfo.code
			local path = TRex.LangDir .. "/" .. code .. ".json"
			local existing = TRex.safeReadFile(path)
			local merged = TRex.cloneTable(TRex.EmbeddedLang[code] or {})
			local needsWrite = false
			if existing then
				local okDec, decoded = pcall(HttpService.JSONDecode, HttpService, existing)
				if okDec and type(decoded) == "table" then
					for k, v in pairs(merged) do
						if type(decoded[k]) ~= "string" then
							decoded[k] = v
							needsWrite = true
						end
					end
					merged = decoded
				else
					needsWrite = true
				end
			else
				needsWrite = true
			end
			if needsWrite then
				local okEnc, encoded = pcall(HttpService.JSONEncode, HttpService, merged)
				if okEnc then
					TRex.safeWriteFile(path, encoded)
				end
			end
			if code == "th" then
				TRex.ThaiDefaultLang = merged
			end
		end
	end
	TRex.setLanguage(TRex.Config.Language or "th", true)
end

function TRex.setLanguage(langCode, silent)
	local code = VALID_LANG_SET[langCode] and langCode or "th"
	TRex.Config.Language = code
	local loaded = TRex.cloneTable(TRex.EmbeddedLang[code] or {})
	if TRex.hasFileIO() then
		local raw = TRex.safeReadFile(TRex.LangDir .. "/" .. code .. ".json")
		if raw then
			local okDec, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
			if okDec and type(decoded) == "table" then
				for k, v in pairs(decoded) do
					if type(v) == "string" then
						loaded[k] = v
					end
				end
			end
		end
	end
	TRex.ActiveLang = loaded
	if not silent then
		for _, cb in ipairs(TRex.LanguageChangedCallbacks) do
			pcall(cb, code)
		end
	end
end

function TRex.onLanguageChanged(cb)
	if type(cb) == "function" then
		table.insert(TRex.LanguageChangedCallbacks, cb)
	end
end

function TRex.t(key, params)
	local str = TRex.ActiveLang[key]
		or TRex.ThaiDefaultLang[key]
		or (TRex.EmbeddedLang["th"] and TRex.EmbeddedLang["th"][key])
		or key
	if type(params) == "table" then
		str = str:gsub("{([%w_%.]+)}", function(pKey)
			local val = params[pKey]
			if val ~= nil then
				return tostring(val)
			end
			return "{" .. pKey .. "}"
		end)
	end
	return str
end

-- ============================================================================
-- [UniversalCode/02_thai_clean_ui.lua]
-- ============================================================================
-- T-RexProject/UniversalCode/02_thai_clean_ui.lua
-- Canonical thai-clean-ui 740x460 dashboard framework with theme/font registries,
-- circular toggle overlay, toast stack, status banner, profile UI, and settings.

local TweenService = TRex.Services.TweenService
local UserInputService = TRex.Services.UserInputService
local Lighting = TRex.Services.Lighting
local Workspace = TRex.Services.Workspace

local UI = {}
TRex.UI = UI

UI.THEMES = {
	["ชมพูซากุระ"] = {
		Bg = Color3.fromRGB(31, 16, 26),
		Sidebar = Color3.fromRGB(23, 11, 19),
		Card = Color3.fromRGB(52, 27, 43),
		CardHover = Color3.fromRGB(68, 36, 56),
		Accent = Color3.fromRGB(244, 114, 182),
		AccentSoft = Color3.fromRGB(219, 39, 119),
		Text = Color3.fromRGB(253, 242, 248),
		SubText = Color3.fromRGB(249, 168, 212),
		Border = Color3.fromRGB(99, 48, 79),
	},
	["มืดคราม"] = {
		Bg = Color3.fromRGB(15, 23, 42),
		Sidebar = Color3.fromRGB(11, 17, 32),
		Card = Color3.fromRGB(30, 41, 59),
		CardHover = Color3.fromRGB(40, 53, 74),
		Accent = Color3.fromRGB(56, 189, 248),
		AccentSoft = Color3.fromRGB(14, 116, 144),
		Text = Color3.fromRGB(248, 250, 252),
		SubText = Color3.fromRGB(148, 163, 184),
		Border = Color3.fromRGB(51, 65, 85),
	},
	["เขียวมรกต"] = {
		Bg = Color3.fromRGB(12, 26, 22),
		Sidebar = Color3.fromRGB(8, 19, 16),
		Card = Color3.fromRGB(20, 44, 37),
		CardHover = Color3.fromRGB(28, 59, 49),
		Accent = Color3.fromRGB(16, 185, 129),
		AccentSoft = Color3.fromRGB(5, 150, 105),
		Text = Color3.fromRGB(240, 253, 244),
		SubText = Color3.fromRGB(134, 239, 172),
		Border = Color3.fromRGB(34, 78, 64),
	},
	["ม่วงอเมทิสต์"] = {
		Bg = Color3.fromRGB(22, 16, 36),
		Sidebar = Color3.fromRGB(16, 11, 28),
		Card = Color3.fromRGB(38, 28, 60),
		CardHover = Color3.fromRGB(50, 37, 78),
		Accent = Color3.fromRGB(168, 85, 247),
		AccentSoft = Color3.fromRGB(126, 34, 206),
		Text = Color3.fromRGB(250, 245, 255),
		SubText = Color3.fromRGB(216, 180, 254),
		Border = Color3.fromRGB(76, 53, 117),
	},
	["ทองคำมืด"] = {
		Bg = Color3.fromRGB(20, 19, 16),
		Sidebar = Color3.fromRGB(14, 13, 11),
		Card = Color3.fromRGB(36, 33, 27),
		CardHover = Color3.fromRGB(48, 44, 36),
		Accent = Color3.fromRGB(250, 204, 21),
		AccentSoft = Color3.fromRGB(202, 138, 4),
		Text = Color3.fromRGB(254, 252, 232),
		SubText = Color3.fromRGB(253, 224, 71),
		Border = Color3.fromRGB(71, 63, 47),
	},
	["สว่างสะอาด"] = {
		Bg = Color3.fromRGB(241, 245, 249),
		Sidebar = Color3.fromRGB(226, 232, 240),
		Card = Color3.fromRGB(255, 255, 255),
		CardHover = Color3.fromRGB(248, 250, 252),
		Accent = Color3.fromRGB(14, 165, 233),
		AccentSoft = Color3.fromRGB(2, 132, 199),
		Text = Color3.fromRGB(15, 23, 42),
		SubText = Color3.fromRGB(100, 116, 139),
		Border = Color3.fromRGB(203, 213, 225),
	},
}

UI.THEME_ORDER = {
	"ชมพูซากุระ",
	"มืดคราม",
	"เขียวมรกต",
	"ม่วงอเมทิสต์",
	"ทองคำมืด",
	"สว่างสะอาด",
}

UI.THAI_FONTS = {
	["โกธิคทันสมัย"] = { Regular = "GothamMedium", Bold = "GothamBold", Fallback = Enum.Font.SourceSans },
	["โกธิคหนา"] = { Regular = "GothamBold", Bold = "GothamBold", Fallback = Enum.Font.SourceSansBold },
	["ซอร์สแซนส์"] = { Regular = "SourceSans", Bold = "SourceSansBold", Fallback = Enum.Font.SourceSans },
	["ซอร์สแซนส์หนา"] = { Regular = "SourceSansBold", Bold = "SourceSansBold", Fallback = Enum.Font.SourceSansBold },
	["อารีย์"] = { Regular = "Arial", Bold = "ArialBold", Fallback = Enum.Font.SourceSans },
}

UI.FONT_ORDER = {
	"โกธิคทันสมัย",
	"โกธิคหนา",
	"ซอร์สแซนส์",
	"ซอร์สแซนส์หนา",
	"อารีย์",
}

UI.KEYCODE_THAI_NAMES = {
	RightControl = "คอนโทรลขวา",
	LeftControl = "คอนโทรลซ้าย",
	RightShift = "ชิฟต์ขวา",
	LeftShift = "ชิฟต์ซ้าย",
	RightAlt = "อัลต์ขวา",
	LeftAlt = "อัลต์ซ้าย",
	Insert = "อินเสิร์ต",
	Home = "โฮม",
	End = "เอนด์",
	Delete = "ดีลีท",
	PageUp = "เพจอัป",
	PageDown = "เพจดาวน์",
	F1 = "เอฟ 1",
	F2 = "เอฟ 2",
	F3 = "เอฟ 3",
	F4 = "เอฟ 4",
	F5 = "เอฟ 5",
	F6 = "เอฟ 6",
	F7 = "เอฟ 7",
	F8 = "เอฟ 8",
	F9 = "เอฟ 9",
	F10 = "เอฟ 10",
	F11 = "เอฟ 11",
	F12 = "เอฟ 12",
}

local ThemeRegistry = {}
local TextRegistry = {}
local RefreshCallbacks = {}
local FeatureStatusMap = {}

function UI.getTheme()
	return UI.THEMES[TRex.Config.Theme] or UI.THEMES["ชมพูซากุระ"]
end

function UI.getFont(isBold)
	local preset = UI.THAI_FONTS[TRex.Config.Font] or UI.THAI_FONTS["โกธิคทันสมัย"]
	local name = isBold and preset.Bold or preset.Regular
	return TRex.safeEnumFont(name, preset.Fallback)
end

function UI.registerTheme(inst, prop, role)
	table.insert(ThemeRegistry, { Instance = inst, Property = prop, Role = role })
	local theme = UI.getTheme()
	pcall(function()
		inst[prop] = theme[role]
	end)
end

function UI.registerText(inst, baseSize, isBold)
	table.insert(TextRegistry, { Instance = inst, BaseSize = baseSize or 14, IsBold = isBold == true })
	pcall(function()
		inst.Font = UI.getFont(isBold == true)
		inst.TextSize = math.clamp(math.floor(((baseSize or 14) * (TRex.Config.FontSize or 14) / 14) + 0.5), 1, 100)
	end)
end

function UI.registerRefresh(fn)
	if type(fn) == "function" then
		table.insert(RefreshCallbacks, fn)
	end
end

function UI.formatKeyCode(keyName)
	if type(keyName) ~= "string" or keyName == "" then
		return TRex.t("msg.none")
	end
	return UI.KEYCODE_THAI_NAMES[keyName] or keyName
end

local ScreenGui, MainWindow, MainScale, BlurEffect
local CircleOverlay, OverlayLabel, ToastContainer
local StatusDot, StatusBannerLabel, ProgressFill
local ActiveProfileBadge, HeaderTitleLabel
local SidebarList, ContentContainer
local Tabs = {}
local ActiveTabId = nil
local IsWindowOpen = true
local StopAllCallback = nil

function UI.setStatusBanner(stateKind, text, progressRatio)
	if not StatusDot or not StatusBannerLabel then
		return
	end
	local color = Color3.fromRGB(16, 185, 129)
	if stateKind == "warn" or stateKind == "wait" then
		color = Color3.fromRGB(245, 158, 11)
	elseif stateKind == "error" then
		color = Color3.fromRGB(239, 68, 68)
	end
	StatusDot.BackgroundColor3 = color
	StatusBannerLabel.Text = tostring(text or "")
	if ProgressFill and type(progressRatio) == "number" then
		ProgressFill.Size = UDim2.new(math.clamp(progressRatio, 0, 1), 0, 1, 0)
	end
end

function UI.toast(title, message, kind)
	if not ToastContainer or not TRex.IsRunning then
		return
	end
	local theme = UI.getTheme()
	local accent = theme.Accent
	if kind == "ok" then
		accent = Color3.fromRGB(16, 185, 129)
	elseif kind == "warn" then
		accent = Color3.fromRGB(245, 158, 11)
	elseif kind == "err" or kind == "error" then
		accent = Color3.fromRGB(239, 68, 68)
	end

	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 42)
	card.BackgroundColor3 = theme.Card
	card.BackgroundTransparency = 0.08
	card.BorderSizePixel = 0
	card.Parent = ToastContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1.2
	stroke.Color = accent
	stroke.Parent = card

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 4, 1, 0)
	bar.BackgroundColor3 = accent
	bar.BorderSizePixel = 0
	bar.Parent = card

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Position = UDim2.fromOffset(10, 4)
	lbl.Size = UDim2.new(1, -16, 1, -8)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextWrapped = true
	lbl.TextColor3 = theme.Text
	lbl.Font = UI.getFont(false)
	lbl.TextSize = 12
	lbl.Text = (title and title ~= "" and (tostring(title) .. " • ") or "") .. tostring(message or "")
	lbl.Parent = card

	task.delay(2.3, function()
		if not card or not card.Parent then
			return
		end
		pcall(function()
			TweenService:Create(card, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
			TweenService:Create(lbl, TweenInfo.new(0.25), { TextTransparency = 1 }):Play()
			TweenService:Create(stroke, TweenInfo.new(0.25), { Transparency = 1 }):Play()
			TweenService:Create(bar, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
		end)
		task.delay(0.28, function()
			if card and card.Parent then
				card:Destroy()
			end
		end)
	end)
end

TRex.ReportFailure = function(source, err)
	local msg = tostring(source) .. ": " .. tostring(err)
	UI.setStatusBanner("error", msg)
end

function UI.applyAppearance()
	local theme = UI.getTheme()
	for i = #ThemeRegistry, 1, -1 do
		local entry = ThemeRegistry[i]
		if entry.Instance and entry.Instance.Parent then
			pcall(function()
				entry.Instance[entry.Property] = theme[entry.Role]
			end)
		else
			table.remove(ThemeRegistry, i)
		end
	end
	local fontSize = tonumber(TRex.Config.FontSize) or 14
	for i = #TextRegistry, 1, -1 do
		local entry = TextRegistry[i]
		if entry.Instance and entry.Instance.Parent then
			pcall(function()
				entry.Instance.Font = UI.getFont(entry.IsBold)
				entry.Instance.TextSize = math.clamp(math.floor((entry.BaseSize * fontSize / 14) + 0.5), 1, 100)
			end)
		else
			table.remove(TextRegistry, i)
		end
	end
	if MainWindow then
		MainWindow.BackgroundTransparency = math.clamp(tonumber(TRex.Config.BackgroundTransparency) or 0.04, 0, 0.9)
	end
	if MainScale then
		local desired = math.clamp((tonumber(TRex.Config.GuiScalePercent) or 100) / 100, 0.5, 2)
		local cam = Workspace.CurrentCamera
		if cam then
			local vp = cam.ViewportSize
			if vp.X > 0 and vp.Y > 0 then
				local maxScale = math.min((vp.X - 24) / 740, (vp.Y - 24) / 460)
				if maxScale > 0.35 then
					desired = math.min(desired, maxScale)
				end
			end
		end
		MainScale.Scale = desired
	end
	if BlurEffect then
		BlurEffect.Enabled = (TRex.Config.BackgroundBlur == true) and IsWindowOpen
	end
	if ActiveProfileBadge then
		ActiveProfileBadge.Text = TRex.t("ui.profile_badge", { name = TRex.CurrentProfileName })
	end
	if HeaderTitleLabel then
		HeaderTitleLabel.Text = TRex.t("ui.title")
	end
end

function UI.refreshAll()
	UI.applyAppearance()
	for _, cb in ipairs(RefreshCallbacks) do
		pcall(cb)
	end
end

function UI.setWindowOpen(open)
	IsWindowOpen = open == true
	if MainWindow then
		MainWindow.Visible = IsWindowOpen
	end
	if OverlayLabel then
		OverlayLabel.Text = IsWindowOpen and TRex.t("ui.hide_menu") or TRex.t("ui.open_menu")
	end
	if BlurEffect then
		BlurEffect.Enabled = (TRex.Config.BackgroundBlur == true) and IsWindowOpen
	end
end

function UI.setFeatureStatus(key, stateKind, desc)
	FeatureStatusMap[key] = { Kind = stateKind or "idle", Text = desc }
end

local function makeDraggable(frame, dragHandle, onClickIfNotDragged)
	local dragging = false
	local dragged = false
	local dragStart = nil
	local startPos = nil

	TRex.connectSignal(dragHandle.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragged = false
			dragStart = input.Position
			startPos = frame.Position
		end
	end)

	TRex.connectSignal(UserInputService.InputChanged, function(input)
		if not dragging or not dragStart then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			if delta.Magnitude > 6 then
				dragged = true
				frame.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end
	end)

	TRex.connectSignal(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if dragging then
				local wasDragged = dragged
				dragging = false
				dragStart = nil
				task.defer(function()
					dragged = false
				end)
				if not wasDragged and type(onClickIfNotDragged) == "function" then
					onClickIfNotDragged()
				end
			end
		end
	end)
end

function UI.selectTab(tabId)
	local theme = UI.getTheme()
	ActiveTabId = tabId
	for id, tab in pairs(Tabs) do
		local isActive = (id == tabId)
		tab.Page.Visible = isActive
		tab.Indicator.Visible = isActive
		tab.Button.BackgroundColor3 = isActive and theme.Card or theme.Sidebar
		tab.Label.TextColor3 = isActive and theme.Accent or theme.Text
	end
end

function UI.addTab(tabId, labelKeyOrText)
	if Tabs[tabId] then
		return Tabs[tabId]
	end
	local theme = UI.getTheme()

	local btn = Instance.new("TextButton")
	btn.Name = "Tab_" .. tostring(tabId)
	btn.Size = UDim2.new(1, 0, 0, 38)
	btn.BackgroundColor3 = theme.Sidebar
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Text = ""
	btn.Parent = SidebarList
	UI.registerTheme(btn, "BackgroundColor3", "Sidebar")

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0, 4, 0, 20)
	indicator.Position = UDim2.new(0, 2, 0.5, -10)
	indicator.BorderSizePixel = 0
	indicator.Visible = false
	indicator.Parent = btn
	UI.registerTheme(indicator, "BackgroundColor3", "Accent")
	local indCorner = Instance.new("UICorner")
	indCorner.CornerRadius = UDim.new(1, 0)
	indCorner.Parent = indicator

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Position = UDim2.fromOffset(12, 0)
	lbl.Size = UDim2.new(1, -16, 1, 0)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = TRex.t(labelKeyOrText)
	lbl.Parent = btn
	UI.registerTheme(lbl, "TextColor3", "Text")
	UI.registerText(lbl, 13, true)

	local page = Instance.new("ScrollingFrame")
	page.Name = "Page_" .. tostring(tabId)
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.ScrollBarThickness = 4
	page.Visible = false
	page.Parent = ContentContainer
	UI.registerTheme(page, "ScrollBarImageColor3", "Accent")

	local pageLayout = Instance.new("UIListLayout")
	pageLayout.Padding = UDim.new(0, 10)
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.Parent = page

	local pagePad = Instance.new("UIPadding")
	pagePad.PaddingRight = UDim.new(0, 6)
	pagePad.PaddingBottom = UDim.new(0, 10)
	pagePad.Parent = page

	local tabObj = {
		Id = tabId,
		LabelKey = labelKeyOrText,
		Button = btn,
		Indicator = indicator,
		Label = lbl,
		Page = page,
	}
	Tabs[tabId] = tabObj

	TRex.bindClick(btn, function()
		UI.selectTab(tabId)
	end)

	TRex.onLanguageChanged(function()
		lbl.Text = TRex.t(labelKeyOrText)
	end)

	if not ActiveTabId then
		UI.selectTab(tabId)
	end

	function tabObj:addSection(titleKeyOrText)
		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, 0, 0, 0)
		card.AutomaticSize = Enum.AutomaticSize.Y
		card.BackgroundTransparency = 0.12
		card.BorderSizePixel = 0
		card.Parent = page
		UI.registerTheme(card, "BackgroundColor3", "Card")

		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = UDim.new(0, 11)
		cardCorner.Parent = card

		local cardStroke = Instance.new("UIStroke")
		cardStroke.Thickness = 1
		cardStroke.Parent = card
		UI.registerTheme(cardStroke, "Color", "Border")

		local cardPad = Instance.new("UIPadding")
		cardPad.PaddingTop = UDim.new(0, 12)
		cardPad.PaddingBottom = UDim.new(0, 12)
		cardPad.PaddingLeft = UDim.new(0, 14)
		cardPad.PaddingRight = UDim.new(0, 14)
		cardPad.Parent = card

		local cardLayout = Instance.new("UIListLayout")
		cardLayout.Padding = UDim.new(0, 8)
		cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
		cardLayout.Parent = card

		local secTitle = Instance.new("TextLabel")
		secTitle.Size = UDim2.new(1, 0, 0, 22)
		secTitle.BackgroundTransparency = 1
		secTitle.TextXAlignment = Enum.TextXAlignment.Left
		secTitle.Text = TRex.t(titleKeyOrText)
		secTitle.Parent = card
		UI.registerTheme(secTitle, "TextColor3", "Accent")
		UI.registerText(secTitle, 15, true)

		TRex.onLanguageChanged(function()
			secTitle.Text = TRex.t(titleKeyOrText)
		end)

		local sec = {}

		function sec:addLabel(textKeyOrText)
			local lblRow = Instance.new("TextLabel")
			lblRow.Size = UDim2.new(1, 0, 0, 0)
			lblRow.AutomaticSize = Enum.AutomaticSize.Y
			lblRow.BackgroundTransparency = 1
			lblRow.TextXAlignment = Enum.TextXAlignment.Left
			lblRow.TextWrapped = true
			lblRow.Text = TRex.t(textKeyOrText)
			lblRow.Parent = card
			UI.registerTheme(lblRow, "TextColor3", "SubText")
			UI.registerText(lblRow, 12, false)
			TRex.onLanguageChanged(function()
				lblRow.Text = TRex.t(textKeyOrText)
			end)
			return lblRow
		end

		function sec:addToggle(opts)
			local configKey = opts.key
			local labelKey = opts.label
			local descKey = opts.desc
			local onChanged = opts.onChanged

			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 0)
			row.AutomaticSize = Enum.AutomaticSize.Y
			row.BackgroundTransparency = 1
			row.Parent = card

			local topRow = Instance.new("Frame")
			topRow.Size = UDim2.new(1, 0, 0, 26)
			topRow.BackgroundTransparency = 1
			topRow.Parent = row

			local titleLbl = Instance.new("TextLabel")
			titleLbl.BackgroundTransparency = 1
			titleLbl.Size = UDim2.new(1, -130, 1, 0)
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left
			titleLbl.Text = TRex.t(labelKey)
			titleLbl.Parent = topRow
			UI.registerTheme(titleLbl, "TextColor3", "Text")
			UI.registerText(titleLbl, 13, false)

			local badge = Instance.new("TextLabel")
			badge.Size = UDim2.fromOffset(72, 20)
			badge.Position = UDim2.new(1, -122, 0.5, -10)
			badge.BorderSizePixel = 0
			badge.Text = TRex.t("badge.idle")
			badge.Parent = topRow
			UI.registerTheme(badge, "BackgroundColor3", "Sidebar")
			UI.registerTheme(badge, "TextColor3", "SubText")
			UI.registerText(badge, 10, true)
			local bCorner = Instance.new("UICorner")
			bCorner.CornerRadius = UDim.new(1, 0)
			bCorner.Parent = badge

			local switchBtn = Instance.new("TextButton")
			switchBtn.Size = UDim2.fromOffset(44, 22)
			switchBtn.Position = UDim2.new(1, -44, 0.5, -11)
			switchBtn.BorderSizePixel = 0
			switchBtn.Text = ""
			switchBtn.AutoButtonColor = false
			switchBtn.Parent = topRow
			local swCorner = Instance.new("UICorner")
			swCorner.CornerRadius = UDim.new(1, 0)
			swCorner.Parent = switchBtn

			local knob = Instance.new("Frame")
			knob.Size = UDim2.fromOffset(16, 16)
			knob.Position = UDim2.fromOffset(3, 3)
			knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			knob.BorderSizePixel = 0
			knob.Parent = switchBtn
			local kCorner = Instance.new("UICorner")
			kCorner.CornerRadius = UDim.new(1, 0)
			kCorner.Parent = knob

			local descLbl = Instance.new("TextLabel")
			descLbl.Position = UDim2.fromOffset(0, 26)
			descLbl.Size = UDim2.new(1, 0, 0, 0)
			descLbl.AutomaticSize = Enum.AutomaticSize.Y
			descLbl.BackgroundTransparency = 1
			descLbl.TextXAlignment = Enum.TextXAlignment.Left
			descLbl.TextWrapped = true
			descLbl.Text = descKey and TRex.t(descKey) or ""
			descLbl.Visible = (descKey ~= nil)
			descLbl.Parent = row
			UI.registerTheme(descLbl, "TextColor3", "SubText")
			UI.registerText(descLbl, 11, false)

			local function syncVisual()
				local active = TRex.Config[configKey] == true
				local t = UI.getTheme()
				switchBtn.BackgroundColor3 = active and t.AccentSoft or t.Sidebar
				knob.Position = active and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3)
				local st = FeatureStatusMap[configKey]
				if active then
					badge.Text = (st and st.Kind == "confirmed") and TRex.t("badge.confirmed") or TRex.t("badge.active")
					badge.TextColor3 = t.Accent
				else
					badge.Text = TRex.t("badge.idle")
					badge.TextColor3 = t.SubText
				end
			end

			TRex.bindClick(switchBtn, function()
				TRex.Config[configKey] = not (TRex.Config[configKey] == true)
				syncVisual()
				if type(onChanged) == "function" then
					onChanged(TRex.Config[configKey])
				end
				TRex.saveConfig(TRex.CurrentProfileName)
			end)

			UI.registerRefresh(syncVisual)
			TRex.onLanguageChanged(function()
				titleLbl.Text = TRex.t(labelKey)
				if descKey then
					descLbl.Text = TRex.t(descKey)
				end
				syncVisual()
			end)
			syncVisual()
			return syncVisual
		end

		function sec:addNumericInput(opts)
			local configKey = opts.key
			local labelKey = opts.label
			local minVal = opts.min or 0
			local maxVal = opts.max or 1000
			local isInt = opts.integer == true
			local onChanged = opts.onChanged

			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 32)
			row.BackgroundTransparency = 1
			row.Parent = card

			local lbl = Instance.new("TextLabel")
			lbl.BackgroundTransparency = 1
			lbl.Size = UDim2.new(1, -110, 1, 0)
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Text = TRex.t(labelKey)
			lbl.Parent = row
			UI.registerTheme(lbl, "TextColor3", "Text")
			UI.registerText(lbl, 13, false)

			local box = Instance.new("TextBox")
			box.Size = UDim2.fromOffset(96, 28)
			box.Position = UDim2.new(1, -96, 0.5, -14)
			box.ClearTextOnFocus = false
			box.BorderSizePixel = 0
			box.Text = tostring(TRex.Config[configKey] or minVal)
			box.Parent = row
			UI.registerTheme(box, "BackgroundColor3", "Sidebar")
			UI.registerTheme(box, "TextColor3", "Text")
			UI.registerText(box, 12, false)
			local boxCorner = Instance.new("UICorner")
			boxCorner.CornerRadius = UDim.new(0, 7)
			boxCorner.Parent = box
			local boxStroke = Instance.new("UIStroke")
			boxStroke.Thickness = 1
			boxStroke.Parent = box
			UI.registerTheme(boxStroke, "Color", "Border")

			local function syncBox()
				if UserInputService:GetFocusedTextBox() ~= box then
					box.Text = tostring(TRex.Config[configKey] or minVal)
				end
			end

			TRex.connectSignal(box.FocusLost, function()
				local raw = tostring(box.Text or ""):gsub(",", ""):gsub("%s+", "")
				local v = tonumber(raw)
				if type(v) ~= "number" or v ~= v or math.abs(v) >= math.huge then
					box.Text = tostring(TRex.Config[configKey] or minVal)
					UI.toast(TRex.t("msg.notice"), TRex.t("msg.invalid_number"), "warn")
					return
				end
				v = math.clamp(v, minVal, maxVal)
				if isInt then
					v = math.floor(v + 0.5)
				end
				TRex.Config[configKey] = v
				box.Text = tostring(v)
				if type(onChanged) == "function" then
					onChanged(v)
				end
				TRex.saveConfig(TRex.CurrentProfileName)
			end)

			UI.registerRefresh(syncBox)
			TRex.onLanguageChanged(function()
				lbl.Text = TRex.t(labelKey)
			end)
			return box
		end

		function sec:addDropdown(opts)
			local configKey = opts.key
			local labelKey = opts.label
			local items = opts.items or {}
			local getItemsFn = opts.getItems
			local onChanged = opts.onChanged

			local wrapper = Instance.new("Frame")
			wrapper.Size = UDim2.new(1, 0, 0, 0)
			wrapper.AutomaticSize = Enum.AutomaticSize.Y
			wrapper.BackgroundTransparency = 1
			wrapper.Parent = card

			local header = Instance.new("Frame")
			header.Size = UDim2.new(1, 0, 0, 32)
			header.BackgroundTransparency = 1
			header.Parent = wrapper

			local lbl = Instance.new("TextLabel")
			lbl.BackgroundTransparency = 1
			lbl.Size = UDim2.new(0.48, 0, 1, 0)
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Text = TRex.t(labelKey)
			lbl.Parent = header
			UI.registerTheme(lbl, "TextColor3", "Text")
			UI.registerText(lbl, 13, false)

			local dropBtn = Instance.new("TextButton")
			dropBtn.Size = UDim2.new(0.5, 0, 0, 28)
			dropBtn.Position = UDim2.new(0.5, 0, 0.5, -14)
			dropBtn.BorderSizePixel = 0
			dropBtn.AutoButtonColor = false
			dropBtn.Text = ""
			dropBtn.Parent = header
			UI.registerTheme(dropBtn, "BackgroundColor3", "Sidebar")
			UI.registerTheme(dropBtn, "TextColor3", "Text")
			UI.registerText(dropBtn, 12, false)
			local dCorner = Instance.new("UICorner")
			dCorner.CornerRadius = UDim.new(0, 7)
			dCorner.Parent = dropBtn
			local dStroke = Instance.new("UIStroke")
			dStroke.Thickness = 1
			dStroke.Parent = dropBtn
			UI.registerTheme(dStroke, "Color", "Border")

			local listFrame = Instance.new("Frame")
			listFrame.Position = UDim2.fromOffset(0, 36)
			listFrame.Size = UDim2.new(1, 0, 0, 0)
			listFrame.AutomaticSize = Enum.AutomaticSize.Y
			listFrame.Visible = false
			listFrame.BorderSizePixel = 0
			listFrame.Parent = wrapper
			UI.registerTheme(listFrame, "BackgroundColor3", "Sidebar")
			local lCorner = Instance.new("UICorner")
			lCorner.CornerRadius = UDim.new(0, 8)
			lCorner.Parent = listFrame
			local lLayout = Instance.new("UIListLayout")
			lLayout.Padding = UDim.new(0, 4)
			lLayout.Parent = listFrame
			local lPad = Instance.new("UIPadding")
			lPad.PaddingTop = UDim.new(0, 4)
			lPad.PaddingBottom = UDim.new(0, 4)
			lPad.PaddingLeft = UDim.new(0, 6)
			lPad.PaddingRight = UDim.new(0, 6)
			lPad.Parent = listFrame

			local function resolveItemDisplay(val)
				local currentList = getItemsFn and getItemsFn() or items
				for _, entry in ipairs(currentList) do
					if type(entry) == "table" then
						if entry.value == val then
							return entry.labelKey and TRex.t(entry.labelKey) or tostring(entry.label or entry.value)
						end
					elseif entry == val then
						return tostring(entry)
					end
				end
				return tostring(val or "")
			end

			local function syncHeader()
				local arrow = listFrame.Visible and " ▲" or " ▼"
				dropBtn.Text = resolveItemDisplay(TRex.Config[configKey]) .. arrow
			end

			local function rebuildList()
				for _, child in ipairs(listFrame:GetChildren()) do
					if child:IsA("GuiObject") then
						child:Destroy()
					end
				end
				local currentList = getItemsFn and getItemsFn() or items
				for _, entry in ipairs(currentList) do
					local val = type(entry) == "table" and entry.value or entry
					local text = type(entry) == "table" and (entry.labelKey and TRex.t(entry.labelKey) or tostring(entry.label or val)) or tostring(entry)
					local optBtn = Instance.new("TextButton")
					optBtn.Size = UDim2.new(1, 0, 0, 26)
					optBtn.BorderSizePixel = 0
					optBtn.AutoButtonColor = false
					optBtn.Text = (TRex.Config[configKey] == val and "✓ " or "") .. text
					optBtn.Parent = listFrame
					UI.registerTheme(optBtn, "BackgroundColor3", "Card")
					UI.registerTheme(optBtn, "TextColor3", "Text")
					UI.registerText(optBtn, 12, false)
					local oCorner = Instance.new("UICorner")
					oCorner.CornerRadius = UDim.new(0, 6)
					oCorner.Parent = optBtn
					TRex.bindClick(optBtn, function()
						TRex.Config[configKey] = val
						listFrame.Visible = false
						syncHeader()
						if type(onChanged) == "function" then
							onChanged(val)
						end
						TRex.saveConfig(TRex.CurrentProfileName)
					end)
				end
			end

			TRex.bindClick(dropBtn, function()
				listFrame.Visible = not listFrame.Visible
				if listFrame.Visible then
					rebuildList()
				end
				syncHeader()
			end)

			UI.registerRefresh(syncHeader)
			TRex.onLanguageChanged(function()
				lbl.Text = TRex.t(labelKey)
				syncHeader()
			end)
			syncHeader()
		end

		function sec:addKeybindPicker(opts)
			local configKey = opts.key
			local labelKey = opts.label
			local listening = false

			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 32)
			row.BackgroundTransparency = 1
			row.Parent = card

			local lbl = Instance.new("TextLabel")
			lbl.BackgroundTransparency = 1
			lbl.Size = UDim2.new(1, -150, 1, 0)
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Text = TRex.t(labelKey)
			lbl.Parent = row
			UI.registerTheme(lbl, "TextColor3", "Text")
			UI.registerText(lbl, 13, false)

			local pickBtn = Instance.new("TextButton")
			pickBtn.Size = UDim2.fromOffset(140, 28)
			pickBtn.Position = UDim2.new(1, -140, 0.5, -14)
			pickBtn.BorderSizePixel = 0
			pickBtn.AutoButtonColor = false
			pickBtn.Text = UI.formatKeyCode(TRex.Config[configKey])
			pickBtn.Parent = row
			UI.registerTheme(pickBtn, "BackgroundColor3", "Sidebar")
			UI.registerTheme(pickBtn, "TextColor3", "Accent")
			UI.registerText(pickBtn, 12, true)
			local pCorner = Instance.new("UICorner")
			pCorner.CornerRadius = UDim.new(0, 7)
			pCorner.Parent = pickBtn

			TRex.bindClick(pickBtn, function()
				listening = true
				pickBtn.Text = TRex.t("msg.press_key")
			end)

			TRex.connectSignal(UserInputService.InputBegan, function(input, gameProcessed)
				if not listening or gameProcessed then
					return
				end
				if input.UserInputType == Enum.UserInputType.Keyboard then
					listening = false
					if input.KeyCode == Enum.KeyCode.Escape then
						pickBtn.Text = UI.formatKeyCode(TRex.Config[configKey])
						return
					elseif input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
						TRex.Config[configKey] = ""
					else
						TRex.Config[configKey] = input.KeyCode.Name
					end
					pickBtn.Text = UI.formatKeyCode(TRex.Config[configKey])
					TRex.saveConfig(TRex.CurrentProfileName)
				end
			end)

			UI.registerRefresh(function()
				if not listening then
					pickBtn.Text = UI.formatKeyCode(TRex.Config[configKey])
				end
			end)
			TRex.onLanguageChanged(function()
				lbl.Text = TRex.t(labelKey)
				if not listening then
					pickBtn.Text = UI.formatKeyCode(TRex.Config[configKey])
				end
			end)
		end

		function sec:addButton(opts)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 32)
			btn.BorderSizePixel = 0
			btn.AutoButtonColor = false
			btn.Text = TRex.t(opts.label)
			btn.Parent = card
			local role = opts.primary and "AccentSoft" or "Sidebar"
			UI.registerTheme(btn, "BackgroundColor3", role)
			UI.registerTheme(btn, "TextColor3", "Text")
			UI.registerText(btn, 13, true)
			local bCorner = Instance.new("UICorner")
			bCorner.CornerRadius = UDim.new(0, 8)
			bCorner.Parent = btn

			if opts.danger then
				btn.BackgroundColor3 = Color3.fromRGB(185, 28, 28)
			end

			TRex.bindClick(btn, function()
				if type(opts.onClick) == "function" then
					opts.onClick()
				end
			end)

			TRex.onLanguageChanged(function()
				btn.Text = TRex.t(opts.label)
			end)
			return btn
		end

		function sec:addTextInput(opts)
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 32)
			row.BackgroundTransparency = 1
			row.Parent = card

			local lbl = Instance.new("TextLabel")
			lbl.BackgroundTransparency = 1
			lbl.Size = UDim2.new(0.42, 0, 1, 0)
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Text = TRex.t(opts.label)
			lbl.Parent = row
			UI.registerTheme(lbl, "TextColor3", "Text")
			UI.registerText(lbl, 13, false)

			local box = Instance.new("TextBox")
			box.Size = UDim2.new(0.56, 0, 0, 28)
			box.Position = UDim2.new(0.44, 0, 0.5, -14)
			box.ClearTextOnFocus = false
			box.BorderSizePixel = 0
			box.Text = opts.key and tostring(TRex.Config[opts.key] or "") or ""
			box.PlaceholderText = opts.placeholderKey and TRex.t(opts.placeholderKey) or ""
			box.Parent = row
			UI.registerTheme(box, "BackgroundColor3", "Sidebar")
			UI.registerTheme(box, "TextColor3", "Text")
			UI.registerText(box, 12, false)
			local bCorner = Instance.new("UICorner")
			bCorner.CornerRadius = UDim.new(0, 7)
			bCorner.Parent = box

			if opts.key then
				TRex.connectSignal(box.FocusLost, function()
					TRex.Config[opts.key] = tostring(box.Text or "")
					TRex.saveConfig(TRex.CurrentProfileName)
				end)
				UI.registerRefresh(function()
					if UserInputService:GetFocusedTextBox() ~= box then
						box.Text = tostring(TRex.Config[opts.key] or "")
					end
				end)
			end
			TRex.onLanguageChanged(function()
				lbl.Text = TRex.t(opts.label)
			end)
			return box
		end

		return sec
	end

	return tabObj
end

function UI.buildShell(stopAllFn)
	StopAllCallback = stopAllFn

	ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "TRexThaiCleanUI_" .. TRex.GameId
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	TRex.mountScreenGui(ScreenGui)
	UI.ScreenGui = ScreenGui

	-- Dedicated ESP & Render folders (never parent BillboardGui inside 2D Frames)
	local espFolder = Instance.new("Folder")
	espFolder.Name = "ESPFolder"
	espFolder.Parent = ScreenGui
	UI.ESPFolder = espFolder

	local renderLayer = Instance.new("Frame")
	renderLayer.Name = "RenderLayer"
	renderLayer.Size = UDim2.fromScale(1, 1)
	renderLayer.BackgroundTransparency = 1
	renderLayer.ZIndex = 1
	renderLayer.Parent = ScreenGui
	UI.RenderLayer = renderLayer

	local okBlur, blur = pcall(function()
		local b = Instance.new("BlurEffect")
		b.Name = "TRexBlur_" .. TRex.GameId
		b.Size = 10
		b.Enabled = false
		b.Parent = Lighting
		return b
	end)
	if okBlur then
		BlurEffect = blur
	end

	TRex.registerCleanupHook(function()
		if BlurEffect then
			pcall(function()
				BlurEffect:Destroy()
			end)
			BlurEffect = nil
		end
		if ScreenGui then
			pcall(function()
				ScreenGui:Destroy()
			end)
			ScreenGui = nil
		end
	end)

	-- MainWindow 740x460
	MainWindow = Instance.new("Frame")
	MainWindow.Name = "MainWindow"
	MainWindow.Size = UDim2.fromOffset(740, 460)
	MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
	MainWindow.Position = UDim2.fromScale(0.5, 0.5)
	MainWindow.BorderSizePixel = 0
	MainWindow.ZIndex = 10
	MainWindow.Parent = ScreenGui
	UI.registerTheme(MainWindow, "BackgroundColor3", "Bg")

	MainScale = Instance.new("UIScale")
	MainScale.Scale = 1
	MainScale.Parent = MainWindow

	local winCorner = Instance.new("UICorner")
	winCorner.CornerRadius = UDim.new(0, 14)
	winCorner.Parent = MainWindow

	local winStroke = Instance.new("UIStroke")
	winStroke.Thickness = 1.5
	winStroke.Parent = MainWindow
	UI.registerTheme(winStroke, "Color", "Border")

	-- TopBar (50px)
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 50)
	topBar.BorderSizePixel = 0
	topBar.Parent = MainWindow
	UI.registerTheme(topBar, "BackgroundColor3", "Sidebar")
	local tbCorner = Instance.new("UICorner")
	tbCorner.CornerRadius = UDim.new(0, 14)
	tbCorner.Parent = topBar
	local tbCover = Instance.new("Frame")
	tbCover.Size = UDim2.new(1, 0, 0, 14)
	tbCover.Position = UDim2.new(0, 0, 1, -14)
	tbCover.BorderSizePixel = 0
	tbCover.Parent = topBar
	UI.registerTheme(tbCover, "BackgroundColor3", "Sidebar")

	local logoAsset = TRex.loadTRexLogoAsset()
	if logoAsset then
		local logoImg = Instance.new("ImageLabel")
		logoImg.Size = UDim2.fromOffset(24, 24)
		logoImg.Position = UDim2.fromOffset(12, 13)
		logoImg.BackgroundTransparency = 1
		logoImg.Image = logoAsset
		logoImg.Parent = topBar
	else
		local accentDot = Instance.new("Frame")
		accentDot.Size = UDim2.fromOffset(10, 10)
		accentDot.Position = UDim2.fromOffset(17, 20)
		accentDot.BorderSizePixel = 0
		accentDot.Parent = topBar
		UI.registerTheme(accentDot, "BackgroundColor3", "Accent")
		local dotCorner = Instance.new("UICorner")
		dotCorner.CornerRadius = UDim.new(1, 0)
		dotCorner.Parent = accentDot
	end

	HeaderTitleLabel = Instance.new("TextLabel")
	HeaderTitleLabel.BackgroundTransparency = 1
	HeaderTitleLabel.Position = UDim2.fromOffset(42, 0)
	HeaderTitleLabel.Size = UDim2.new(0, 340, 1, 0)
	HeaderTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	HeaderTitleLabel.Text = TRex.t("ui.title")
	HeaderTitleLabel.Parent = topBar
	UI.registerTheme(HeaderTitleLabel, "TextColor3", "Text")
	UI.registerText(HeaderTitleLabel, 17, true)

	ActiveProfileBadge = Instance.new("TextLabel")
	ActiveProfileBadge.Size = UDim2.fromOffset(160, 26)
	ActiveProfileBadge.Position = UDim2.new(1, -276, 0.5, -13)
	ActiveProfileBadge.BorderSizePixel = 0
	ActiveProfileBadge.Text = TRex.t("ui.profile_badge", { name = TRex.CurrentProfileName })
	ActiveProfileBadge.Parent = topBar
	UI.registerTheme(ActiveProfileBadge, "BackgroundColor3", "Card")
	UI.registerTheme(ActiveProfileBadge, "TextColor3", "SubText")
	UI.registerText(ActiveProfileBadge, 11, true)
	local apCorner = Instance.new("UICorner")
	apCorner.CornerRadius = UDim.new(1, 0)
	apCorner.Parent = ActiveProfileBadge

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.fromOffset(96, 28)
	closeBtn.Position = UDim2.new(1, -108, 0.5, -14)
	closeBtn.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
	closeBtn.BorderSizePixel = 0
	closeBtn.AutoButtonColor = false
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Text = TRex.t("ui.close_window")
	closeBtn.Parent = topBar
	UI.registerText(closeBtn, 12, true)
	local cCorner = Instance.new("UICorner")
	cCorner.CornerRadius = UDim.new(0, 8)
	cCorner.Parent = closeBtn
	TRex.bindClick(closeBtn, function()
		UI.setWindowOpen(false)
	end)
	TRex.onLanguageChanged(function()
		closeBtn.Text = TRex.t("ui.close_window")
	end)

	makeDraggable(MainWindow, topBar, nil)

	-- Sidebar (175px)
	SidebarList = Instance.new("ScrollingFrame")
	SidebarList.Name = "Sidebar"
	SidebarList.Position = UDim2.fromOffset(0, 50)
	SidebarList.Size = UDim2.new(0, 175, 1, -50)
	SidebarList.BorderSizePixel = 0
	SidebarList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	SidebarList.CanvasSize = UDim2.new(0, 0, 0, 0)
	SidebarList.ScrollBarThickness = 2
	SidebarList.Parent = MainWindow
	UI.registerTheme(SidebarList, "BackgroundColor3", "Sidebar")

	local sbPad = Instance.new("UIPadding")
	sbPad.PaddingTop = UDim.new(0, 12)
	sbPad.PaddingLeft = UDim.new(0, 10)
	sbPad.PaddingRight = UDim.new(0, 10)
	sbPad.Parent = SidebarList
	local sbLayout = Instance.new("UIListLayout")
	sbLayout.Padding = UDim.new(0, 6)
	sbLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sbLayout.Parent = SidebarList

	-- StatusBanner
	local statusBanner = Instance.new("Frame")
	statusBanner.Position = UDim2.fromOffset(185, 56)
	statusBanner.Size = UDim2.new(1, -195, 0, 48)
	statusBanner.BorderSizePixel = 0
	statusBanner.Parent = MainWindow
	UI.registerTheme(statusBanner, "BackgroundColor3", "Card")
	local sbCorner = Instance.new("UICorner")
	sbCorner.CornerRadius = UDim.new(0, 8)
	sbCorner.Parent = statusBanner
	local sbStroke = Instance.new("UIStroke")
	sbStroke.Thickness = 1
	sbStroke.Parent = statusBanner
	UI.registerTheme(sbStroke, "Color", "Border")

	StatusDot = Instance.new("Frame")
	StatusDot.Size = UDim2.fromOffset(8, 8)
	StatusDot.Position = UDim2.fromOffset(12, 14)
	StatusDot.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
	StatusDot.BorderSizePixel = 0
	StatusDot.Parent = statusBanner
	local sdCorner = Instance.new("UICorner")
	sdCorner.CornerRadius = UDim.new(1, 0)
	sdCorner.Parent = StatusDot

	StatusBannerLabel = Instance.new("TextLabel")
	StatusBannerLabel.BackgroundTransparency = 1
	StatusBannerLabel.Position = UDim2.fromOffset(26, 4)
	StatusBannerLabel.Size = UDim2.new(1, -34, 0, 26)
	StatusBannerLabel.TextXAlignment = Enum.TextXAlignment.Left
	StatusBannerLabel.TextWrapped = true
	StatusBannerLabel.Text = TRex.t("status.ready")
	StatusBannerLabel.Parent = statusBanner
	UI.registerTheme(StatusBannerLabel, "TextColor3", "Text")
	UI.registerText(StatusBannerLabel, 12, false)

	local progTrack = Instance.new("Frame")
	progTrack.Position = UDim2.fromOffset(12, 36)
	progTrack.Size = UDim2.new(1, -24, 0, 5)
	progTrack.BorderSizePixel = 0
	progTrack.Parent = statusBanner
	UI.registerTheme(progTrack, "BackgroundColor3", "Sidebar")
	local ptCorner = Instance.new("UICorner")
	ptCorner.CornerRadius = UDim.new(1, 0)
	ptCorner.Parent = progTrack

	ProgressFill = Instance.new("Frame")
	ProgressFill.Size = UDim2.new(1, 0, 1, 0)
	ProgressFill.BorderSizePixel = 0
	ProgressFill.Parent = progTrack
	UI.registerTheme(ProgressFill, "BackgroundColor3", "Accent")
	local pfCorner = Instance.new("UICorner")
	pfCorner.CornerRadius = UDim.new(1, 0)
	pfCorner.Parent = ProgressFill

	-- ContentContainer
	ContentContainer = Instance.new("Frame")
	ContentContainer.Position = UDim2.fromOffset(185, 110)
	ContentContainer.Size = UDim2.new(1, -195, 1, -120)
	ContentContainer.BackgroundTransparency = 1
	ContentContainer.Parent = MainWindow

	-- Floating Circular Overlay (64x64)
	CircleOverlay = Instance.new("Frame")
	CircleOverlay.Name = "CircleOverlay"
	CircleOverlay.Size = UDim2.fromOffset(64, 64)
	CircleOverlay.Position = UDim2.new(1, -88, 1, -88)
	CircleOverlay.BorderSizePixel = 0
	CircleOverlay.ZIndex = 40
	CircleOverlay.Parent = ScreenGui
	UI.registerTheme(CircleOverlay, "BackgroundColor3", "Sidebar")
	local coCorner = Instance.new("UICorner")
	coCorner.CornerRadius = UDim.new(1, 0)
	coCorner.Parent = CircleOverlay
	local coStroke = Instance.new("UIStroke")
	coStroke.Thickness = 2.5
	coStroke.Parent = CircleOverlay
	UI.registerTheme(coStroke, "Color", "Accent")

	OverlayLabel = Instance.new("TextLabel")
	OverlayLabel.Size = UDim2.fromScale(1, 1)
	OverlayLabel.BackgroundTransparency = 1
	OverlayLabel.TextWrapped = true
	OverlayLabel.Text = TRex.t("ui.hide_menu")
	OverlayLabel.ZIndex = 41
	OverlayLabel.Parent = CircleOverlay
	UI.registerTheme(OverlayLabel, "TextColor3", "Text")
	UI.registerText(OverlayLabel, 11, true)

	makeDraggable(CircleOverlay, CircleOverlay, function()
		UI.setWindowOpen(not IsWindowOpen)
	end)

	TRex.onLanguageChanged(function()
		OverlayLabel.Text = IsWindowOpen and TRex.t("ui.hide_menu") or TRex.t("ui.open_menu")
	end)

	-- ToastContainer (290x220)
	ToastContainer = Instance.new("Frame")
	ToastContainer.Name = "ToastContainer"
	ToastContainer.Size = UDim2.fromOffset(290, 220)
	ToastContainer.Position = UDim2.new(1, -310, 1, -240)
	ToastContainer.BackgroundTransparency = 1
	ToastContainer.ZIndex = 50
	ToastContainer.Parent = ScreenGui
	local tLayout = Instance.new("UIListLayout")
	tLayout.Padding = UDim.new(0, 6)
	tLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	tLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tLayout.Parent = ToastContainer

	-- Global Toggle & Panic Hotkeys
	TRex.connectSignal(UserInputService.InputBegan, function(input, gameProcessed)
		if gameProcessed or TRex.isTextBoxFocused() then
			return
		end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			local toggleKc = TRex.safeKeyCode(TRex.Config.ToggleKey)
			if toggleKc and input.KeyCode == toggleKc then
				UI.setWindowOpen(not IsWindowOpen)
				return
			end
			local panicKc = TRex.safeKeyCode(TRex.Config.PanicKey)
			if panicKc and input.KeyCode == panicKc then
				if type(StopAllCallback) == "function" then
					StopAllCallback()
				end
				UI.toast(TRex.t("msg.notice"), TRex.t("msg.stopped_all"), "warn")
			end
		end
	end)

	local cam = Workspace.CurrentCamera
	if cam then
		TRex.connectSignal(cam:GetPropertyChangedSignal("ViewportSize"), function()
			UI.applyAppearance()
		end)
	end
end

function UI.buildSettingsAndProfileTabs()
	-- Profile Tab
	local profileTab = UI.addTab("profiles", "tab.profiles")
	local profSec = profileTab:addSection("sec.profile_manage")
	local newNameBox = profSec:addTextInput({
		label = "opt.profile_name",
		placeholderKey = "msg.profile_placeholder",
	})
	profSec:addDropdown({
		key = "ActiveProfileSelector",
		label = "opt.select_profile",
		getItems = function()
			return TRex.listProfiles()
		end,
		onChanged = function(selected)
			if type(selected) == "string" and selected ~= "" then
				TRex.loadConfig(selected)
				UI.refreshAll()
				UI.toast(TRex.t("tab.profiles"), TRex.t("msg.profile_loaded", { name = selected }), "ok")
			end
		end,
	})
	profSec:addButton({
		label = "btn.save_profile",
		primary = true,
		onClick = function()
			local target = tostring(newNameBox.Text or ""):gsub("[^%w_%-%s]", "")
			if target == "" then
				target = TRex.CurrentProfileName
			end
			local ok = TRex.saveConfig(target)
			UI.refreshAll()
			UI.toast(TRex.t("tab.profiles"), ok and TRex.t("msg.profile_saved", { name = target }) or TRex.t("msg.io_unavailable"), ok and "ok" or "warn")
		end,
	})

	-- Settings Tab
	local settingsTab = UI.addTab("settings", "tab.settings")
	local appearSec = settingsTab:addSection("sec.appearance")

	local langItems = {}
	for _, info in ipairs(TRex.SUPPORTED_LANGUAGES) do
		table.insert(langItems, { value = info.code, label = info.label })
	end
	appearSec:addDropdown({
		key = "Language",
		label = "opt.language",
		items = langItems,
		onChanged = function(code)
			TRex.setLanguage(code, false)
			UI.refreshAll()
			UI.toast(TRex.t("tab.settings"), TRex.t("msg.lang_changed"), "ok")
		end,
	})
	appearSec:addDropdown({
		key = "Theme",
		label = "opt.theme",
		items = UI.THEME_ORDER,
		onChanged = function()
			UI.applyAppearance()
		end,
	})
	appearSec:addDropdown({
		key = "Font",
		label = "opt.font",
		items = UI.FONT_ORDER,
		onChanged = function()
			UI.applyAppearance()
		end,
	})
	appearSec:addNumericInput({
		key = "FontSize",
		label = "opt.font_size",
		min = 8,
		max = 40,
		integer = true,
		onChanged = function()
			UI.applyAppearance()
		end,
	})
	appearSec:addNumericInput({
		key = "GuiScalePercent",
		label = "opt.gui_scale",
		min = 50,
		max = 200,
		integer = true,
		onChanged = function()
			UI.applyAppearance()
		end,
	})
	appearSec:addNumericInput({
		key = "BackgroundTransparency",
		label = "opt.bg_transparency",
		min = 0,
		max = 0.9,
		onChanged = function()
			UI.applyAppearance()
		end,
	})
	appearSec:addToggle({
		key = "BackgroundBlur",
		label = "opt.bg_blur",
		onChanged = function()
			UI.applyAppearance()
		end,
	})

	local bindSec = settingsTab:addSection("sec.hotkeys")
	bindSec:addKeybindPicker({ key = "ToggleKey", label = "opt.toggle_key" })
	bindSec:addKeybindPicker({ key = "PanicKey", label = "opt.panic_key" })

	local sysSec = settingsTab:addSection("sec.system_actions")
	sysSec:addButton({
		label = "btn.stop_all",
		onClick = function()
			if type(StopAllCallback) == "function" then
				StopAllCallback()
			end
			UI.refreshAll()
			UI.toast(TRex.t("tab.settings"), TRex.t("msg.stopped_all"), "warn")
		end,
	})
	sysSec:addButton({
		label = "btn.reset_defaults",
		onClick = function()
			if type(StopAllCallback) == "function" then
				StopAllCallback()
			end
			TRex.applyProfileTableToConfig(TRex.DEFAULT_CONFIG)
			TRex.setLanguage(TRex.Config.Language, false)
			TRex.saveConfig(TRex.CurrentProfileName)
			UI.applyAppearance()
			UI.refreshAll()
			UI.toast(TRex.t("tab.settings"), TRex.t("msg.reset_done"), "ok")
		end,
	})
	sysSec:addButton({
		label = "btn.unload",
		danger = true,
		onClick = function()
			TRex.cleanup()
		end,
	})
end

-- ============================================================================
-- [Games/Game01/Modules/01_core_security.lua]
-- ============================================================================
-- T-RexProject/Games/Game01/Modules/01_core_security.lua
-- Core Engine & Security for Game01 (Steal An Egg)
-- Resolves Shared.Remotes & Packages.Networking, Client/Shared game modules, Plot/Save/Carry state,
-- SeparationLine/RiftMachine coordinates, and safe Anti-AFK (no VirtualUser instantiation).

local ReplicatedStorage = TRex.Services.ReplicatedStorage
local Workspace = TRex.Services.Workspace

local Core = {}
TRex.Core = Core

local NetworkingFolder = nil
local GameModulePaths = {
	Remotes = "Shared.Remotes",
	Egg = "Client.EggState",
	Assets = "Data.Assets",
	Mut = "Shared.Modules.Mutations",
	Save = "Shared.Save",
	Cycle = "Shared.Util.AreaEggCycle",
	Wall = "Client.AreaEggResetWall",
	Plot = "Client.PlotState",
	BaseUpgrade = "Client.BaseUpgrade",
	Rec = "Shared.Util.EggRecords",
	AssetItems = "Shared.Util.AssetItems",
	SlotId = "Shared.Util.AreaEggSlotIdentity",
	Fuse = "Shared.Util.FuseKernel",
	Balance = "Shared.Flags.GameplayBalance",
	EggLimits = "Shared.Types.Eggs",
	Bases = "Data.Bases",
	Tread = "Data.Treadmills",
	TreadUtil = "Shared.Util.TreadmillUtil",
	Trails = "Data.Trails",
	Gears = "Data.Gears",
	Areas = "Data.Areas",
	Guards = "Data.Guards",
	Wisp = "Data.WispQuests",
	Cat = "Shared.Modules.ButterflyCatalog",
	Fmt = "Packages.FormatNumber.Simple",
}

local GameModuleCache = setmetatable({}, {
	__index = function(self, key)
		local pathStr = GameModulePaths[key]
		if not pathStr then
			return nil
		end
		local cur = ReplicatedStorage
		for seg in pathStr:gmatch("[^.]+") do
			cur = cur and cur:FindFirstChild(seg)
		end
		if cur and cur:IsA("ModuleScript") then
			local ok, mod = pcall(require, cur)
			if ok and mod ~= nil then
				rawset(self, key, mod)
				return mod
			end
		end
		return nil
	end,
})

Core.Modules = GameModuleCache

function Core.getNetworking()
	if NetworkingFolder and NetworkingFolder.Parent then
		return NetworkingFolder
	end
	local pkgs = ReplicatedStorage:FindFirstChild("Packages")
	NetworkingFolder = pkgs and pkgs:FindFirstChild("Networking") or nil
	return NetworkingFolder
end

-- Resolves either full path ("RF/EggWorld/AskFieldEggCarry") or (namespace, name, kind)
function Core.getRemote(remoteNameOrNs, optName, optKind)
	if optName then
		local remTbl = GameModuleCache.Remotes
		local group = type(remTbl) == "table" and remTbl[remoteNameOrNs] or nil
		local direct = type(group) == "table" and group[optName] or nil
		if direct then
			return direct
		end
		local prefix = (optKind == "event") and "RE" or "RF"
		local net = Core.getNetworking()
		return net and net:FindFirstChild(prefix .. "/" .. remoteNameOrNs .. "/" .. optName) or nil
	end
	local net = Core.getNetworking()
	local found = net and net:FindFirstChild(remoteNameOrNs) or nil
	if found then
		return found
	end
	local _, ns, name = tostring(remoteNameOrNs):match("^(R[FE])/([^/]+)/([^/]+)$")
	if ns and name then
		local remTbl = GameModuleCache.Remotes
		local group = type(remTbl) == "table" and remTbl[ns] or nil
		return type(group) == "table" and group[name] or nil
	end
	return nil
end

local function invokeRemoteInstance(remote, ...)
	if not remote or not remote:IsA("RemoteFunction") then
		return false, "missing_remote"
	end
	local args = table.pack(...)
	local done = false
	local result = nil
	local thread = coroutine.running()
	local yielded = false
	local timeoutTask = nil

	local function finish(res)
		if done then
			return
		end
		done = true
		result = res
		if timeoutTask then
			pcall(task.cancel, timeoutTask)
		end
		if yielded then
			task.spawn(thread)
		end
	end

	task.spawn(function()
		finish(table.pack(pcall(remote.InvokeServer, remote, table.unpack(args, 1, args.n))))
	end)

	if not done then
		timeoutTask = task.delay(15, function()
			finish({ false, "timeout", n = 2 })
		end)
		yielded = true
		coroutine.yield()
	end
	return table.unpack(result, 1, result.n)
end

function Core.invokeRemote(remoteName, ...)
	return invokeRemoteInstance(Core.getRemote(remoteName), ...)
end

function Core.invokeNS(ns, name, ...)
	return invokeRemoteInstance(Core.getRemote(ns, name, "function"), ...)
end

function Core.invokeServerBoolean(remoteName, ...)
	local ok, res = invokeRemoteInstance(Core.getRemote(remoteName), ...)
	return ok == true and res ~= false
end

function Core.invokeNSBoolean(ns, name, ...)
	local ok, res = invokeRemoteInstance(Core.getRemote(ns, name, "function"), ...)
	return ok == true and res ~= false
end

function Core.fireRemote(remoteName, ...)
	local remote = Core.getRemote(remoteName)
	if remote and remote:IsA("RemoteEvent") then
		pcall(remote.FireServer, remote, ...)
		return true
	end
	return false
end

function Core.fireNS(ns, name, ...)
	local remote = Core.getRemote(ns, name, "event")
	if remote and remote:IsA("RemoteEvent") then
		pcall(remote.FireServer, remote, ...)
		return true
	end
	return false
end

function Core.callModule(modKey, fnName, ...)
	local mod = GameModuleCache[modKey]
	if type(mod) == "table" and type(mod[fnName]) == "function" then
		local ok, a, b = pcall(mod[fnName], ...)
		if ok then
			return a, b
		end
	end
	return nil
end

function Core.getSaveData()
	local saveMod = GameModuleCache.Save
	if type(saveMod) ~= "table" then
		return nil
	end
	for _, fnName in ipairs({ "Get", "Read", "GetData", "GetSave" }) do
		if type(saveMod[fnName]) == "function" then
			local ok, data = pcall(saveMod[fnName])
			if ok and type(data) == "table" then
				return data
			end
		end
	end
	if type(saveMod.Data) == "table" then
		return saveMod.Data
	end
	return nil
end

function Core.getPlot()
	local plot = Core.callModule("Plot", "ResolvePlot")
	if type(plot) == "table" and plot.PlotFolder then
		return plot
	end
	local plotsFolder = Core.findWorldPath("Plots") or Workspace:FindFirstChild("Plots")
	local lp = TRex.LocalPlayer
	if plotsFolder and lp then
		for _, folder in ipairs(plotsFolder:GetChildren()) do
			local ownerId = folder:GetAttribute("OwnerUserId") or folder:GetAttribute("OwnerId")
			if (ownerId and tonumber(ownerId) == lp.UserId) or folder.Name == lp.Name or folder.Name == tostring(lp.UserId) then
				return {
					PlotFolder = folder,
					PetArea = folder:FindFirstChild("PetArea", true),
					RespawnPointCFrame = (function()
						local rp = folder:FindFirstChild("RespawnPoint", true)
						return rp and rp:IsA("BasePart") and rp.CFrame or nil
					end)(),
					CenterPoint = folder:FindFirstChild("CenterPoint", true),
				}
			end
		end
	end
	return nil
end

function Core.getCarryState()
	local eggState = GameModuleCache.Egg
	if type(eggState) == "table" then
		for _, fnName in ipairs({ "ReadCarryState", "GetCarryState" }) do
			if type(eggState[fnName]) == "function" then
				local ok, st = pcall(eggState[fnName])
				if ok and type(st) == "table" then
					return st
				end
			end
		end
	end
	local char = Core.getCharacter()
	if char then
		for _, child in ipairs(char:GetChildren()) do
			if child:IsA("Tool") and child:GetAttribute("ItemType") == "AssetEgg" then
				return { IsCarrying = true, Uid = child:GetAttribute("Uid") }
			end
		end
	end
	return { IsCarrying = false }
end

function Core.isCarryingEgg()
	local st = Core.getCarryState()
	return st and st.IsCarrying == true
end

function Core.getCharacter()
	return TRex.LocalPlayer and TRex.LocalPlayer.Character or nil
end

function Core.getHumanoid()
	local char = Core.getCharacter()
	return char and char:FindFirstChildOfClass("Humanoid") or nil
end

function Core.getRoot()
	local char = Core.getCharacter()
	return char and char:FindFirstChild("HumanoidRootPart") or nil
end

function Core.isAlive()
	local hum = Core.getHumanoid()
	return hum ~= nil and hum.Health > 0 and Core.getRoot() ~= nil
end

function Core.getServerNow()
	local ok, now = pcall(function()
		return Workspace:GetServerTimeNow()
	end)
	return (ok and type(now) == "number") and now or os.time()
end

function Core.getPing()
	local ok, ping = pcall(TRex.LocalPlayer.GetNetworkPing, TRex.LocalPlayer)
	return ok and math.clamp(tonumber(ping) or 0.2, 0, 1) or 0.2
end

function Core.findWorldPath(...)
	local cur = Workspace:FindFirstChild("World") or Workspace:FindFirstChild("__OBJECTS")
	for _, seg in ipairs({ ... }) do
		cur = cur and cur:FindFirstChild(seg) or nil
	end
	return cur
end

local CachedSeparationLine = nil
function Core.getSeparationLinePos()
	if not (CachedSeparationLine and CachedSeparationLine.Parent) then
		local part = Core.findWorldPath("Areas", "SeparationLine")
		CachedSeparationLine = (part and part:IsA("BasePart")) and part or nil
	end
	return CachedSeparationLine and CachedSeparationLine.Position or Vector3.new(552.2, 67.67, 0)
end

function Core.getRiftMachinePos()
	local portal = Core.findWorldPath("Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003")
	if portal and portal:IsA("BasePart") then
		return portal.CFrame:PointToWorldSpace(Vector3.new(-26.776, 1.75, 18.665))
	end
	return Vector3.new(528.7, 70.57, -364.11)
end

function Core.isInSafeZone(pos)
	if typeof(pos) ~= "Vector3" then
		return false
	end
	return pos.X < Core.getSeparationLinePos().X and pos.Y < 1000
end

Core.RARITY_ORDER = {
	"Common", "Uncommon", "Rare", "Epic", "Legendary",
	"Mythic", "Cosmic", "Secret", "Eternal", "Divine",
}
Core.RARITY_RANK = {}
for idx, name in ipairs(Core.RARITY_ORDER) do
	Core.RARITY_RANK[name] = idx
end

local ActiveMover = nil
local ActiveMoverPriority = -1
local ActiveMoverUntil = 0

function Core.acquireMover(name, priority, ttl)
	local now = os.clock()
	local pri = tonumber(priority) or 1
	if ActiveMover and ActiveMover ~= name and now < ActiveMoverUntil and ActiveMoverPriority > pri then
		return false
	end
	ActiveMover = name
	ActiveMoverPriority = pri
	ActiveMoverUntil = now + (tonumber(ttl) or 2.5)
	return true
end

function Core.releaseMover(name)
	if not name or ActiveMover == name then
		ActiveMover = nil
		ActiveMoverPriority = -1
		ActiveMoverUntil = 0
	end
end

function Core.computeEggInfo(rec)
	if type(rec) ~= "table" then
		return { Rarity = "Common", RarityRank = 1, WeightKg = 0, Value = 0, MutCount = 0 }
	end
	local assets = GameModuleCache.Assets
	local dir = assets and assets.Directory
	local cat = rec.AssetCategory or rec.PetCategory or rec.OutcomeCategory
	local entry = dir and cat and dir[cat]
	local r = rec.Rarity
	if type(r) == "table" then
		r = r._id or r.Id or r.DisplayName
	end
	if (type(r) ~= "string" or r == "") and entry and entry.Rarity then
		r = type(entry.Rarity) == "table" and (entry.Rarity._id or entry.Rarity.DisplayName) or entry.Rarity
	end
	local rarityName = tostring(r or "Common")
	local rarityRank = Core.RARITY_RANK[rarityName] or 1

	local scale = tonumber(rec.Scale) or 1
	local weightKg = tonumber(rec.WeightKg) or 0
	local recUtil = GameModuleCache.Rec
	if weightKg <= 0 and type(recUtil) == "table" and type(recUtil.WeightKgForScale) == "function" then
		local okW, w = pcall(recUtil.WeightKgForScale, cat, scale)
		if okW and type(w) == "number" then
			weightKg = w
		end
	end

	local mutCount = 0
	if type(rec.Mutations) == "table" then
		for _, v in pairs(rec.Mutations) do
			if v == true or (type(v) == "string" and v ~= "") then
				mutCount = mutCount + 1
			end
		end
	end

	local value = tonumber(rec.EarningsPerSecond or rec.Value) or 0
	local mutMod = GameModuleCache.Mut
	if value <= 0 and type(mutMod) == "table" and type(mutMod.EarningsFor) == "function" and entry then
		local okV, v = pcall(mutMod.EarningsFor, entry.BaseEarnings or 0, rec.Mutations, scale)
		if okV and type(v) == "number" then
			value = v
		end
	end
	if value <= 0 and entry and type(entry.BaseEarnings) == "number" then
		value = entry.BaseEarnings * (1 + mutCount * 0.5) * scale
	end

	return {
		Rarity = rarityName,
		RarityRank = rarityRank,
		WeightKg = weightKg,
		Value = value,
		MutCount = mutCount,
	}
end

function Core.getWalkSpeed()
	local hum = Core.getHumanoid()
	return math.max(hum and hum.WalkSpeed or 16, 16)
end

function Core.fireTouchInterest(partA, partB)
	local fti = TRex.resolveGlobalFunc("firetouchinterest")
	if fti and partA and partB then
		pcall(fti, partA, partB, 0)
		pcall(fti, partA, partB, 1)
		return true
	end
	return false
end

function Core.setRootCFrame(cf)
	local root = Core.getRoot()
	if not root then
		return false
	end
	if root.Anchored then
		pcall(Core.invokeNS, "Treadmill", "AskDoff")
		pcall(function()
			root.Anchored = false
		end)
	end
	pcall(function()
		root.CFrame = cf
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end)
	return true
end

function Core.isRagdolled()
	local endTime = tonumber(TRex.LocalPlayer:GetAttribute("RagdollEndTime")) or 0
	return endTime > Core.getServerNow()
end

function Core.cleanRespawn()
	pcall(Core.invokeNS, "Treadmill", "AskDoff")
	local char = Core.getCharacter()
	local hum = Core.getHumanoid()
	if hum then
		pcall(function()
			hum:ChangeState(Enum.HumanoidStateType.Dead)
			hum.BreakJointsOnDeath = true
			hum.RequiresNeck = true
			hum.Health = 0
		end)
	end
	if char then
		pcall(char.BreakJoints, char)
	end
end

function Core.triggerRigSync()
	Core.fireNS("RigSync", "AskRigWipe")
	Core.fireNS("RigSync", "Refresh")
end

local DisabledIdleConns = {}

function Core.restoreAntiAFK()
	for _, conn in ipairs(DisabledIdleConns) do
		pcall(function()
			if conn.Enabled == false and type(conn.Enable) == "function" then
				conn:Enable()
			end
		end)
	end
	table.clear(DisabledIdleConns)
end

function Core.applyAntiAFK(enabled)
	if not enabled then
		Core.restoreAntiAFK()
		return
	end
	local getconns = TRex.resolveGlobalFunc("getconnections")
	if not getconns or not TRex.LocalPlayer then
		return
	end
	local ok, conns = pcall(getconns, TRex.LocalPlayer.Idled)
	if ok and type(conns) == "table" then
		for _, conn in ipairs(conns) do
			if conn.Enabled ~= false and type(conn.Disable) == "function" then
				local okDis = pcall(conn.Disable, conn)
				if okDis and conn.Enabled == false then
					table.insert(DisabledIdleConns, conn)
				end
			end
		end
	end
end

local TRUST_CLEAR_KEYS = {
	"CandidateGroundedSample", "CandidateGroundedStartedAt", "HighestYSinceGround",
	"LastConfirmedGroundSample", "LastGameplayTrustedSample", "LastGoodSample",
	"LastObservedSample", "LastSample", "LastSupportedAt",
	"LastValidatedGroundedSample", "LastValidatedSample", "SupportStartedAt",
	"ValidationStartedAt", "PreMovementSafeSample", "CorrectionContext", "FirstSuspiciousAt",
}
local TrustTables = {}
local TrustChar = nil
local TrustNextScanAt = 0
local TrustScanBackoff = 2
local TrustScanning = false

local function isTrustTable(t)
	if type(t) ~= "table" then
		return false
	end
	local ev = rawget(t, "Evidence")
	return type(ev) == "table" and (rawget(t, "ThreatLevel") ~= nil or rawget(t, "MovementMode") ~= nil)
end

local function scanMovementTrustTables()
	local char = Core.getCharacter()
	if TrustChar == char and #TrustTables > 0 then
		return
	end
	if os.clock() < TrustNextScanAt or TrustScanning then
		return
	end
	TrustScanning = true
	TrustTables = {}
	TrustChar = char
	local getconns = TRex.resolveGlobalFunc("getconnections")
	local getupvals = debug and debug.getupvalues
	local RunService = TRex.Services.RunService
	if getconns and getupvals and RunService and RunService.PostSimulation then
		local okC, conns = pcall(getconns, RunService.PostSimulation)
		if okC and type(conns) == "table" then
			for _, conn in ipairs(conns) do
				local okU, uvs = pcall(getupvals, conn.Function)
				if okU and type(uvs) == "table" then
					for _, val in pairs(uvs) do
						if isTrustTable(val) and not table.find(TrustTables, val) then
							table.insert(TrustTables, val)
						end
					end
				end
			end
		end
	end
	if #TrustTables == 0 then
		local getgcFn = TRex.resolveGlobalFunc("getgc")
		if getgcFn then
			local okG, gc = pcall(getgcFn, true)
			if okG and type(gc) == "table" then
				for i, val in ipairs(gc) do
					if isTrustTable(val) then
						table.insert(TrustTables, val)
					end
					if i % 40000 == 0 then
						task.wait()
					end
				end
			end
		end
	end
	TrustScanBackoff = (#TrustTables > 0) and 2 or math.min(TrustScanBackoff * 2, 120)
	TrustNextScanAt = os.clock() + TrustScanBackoff
	TrustScanning = false
end

function Core.trustMovement()
	local char = Core.getCharacter()
	if TrustChar ~= char or #TrustTables == 0 then
		if not TrustScanning and os.clock() >= TrustNextScanAt then
			task.spawn(scanMovementTrustTables)
		end
		return
	end
	for _, tbl in ipairs(TrustTables) do
		local ev = rawget(tbl, "Evidence")
		if type(ev) == "table" then
			ev.Speed = 0
			ev.Teleport = 0
			ev.Flight = 0
		end
		for _, k in ipairs(TRUST_CLEAR_KEYS) do
			rawset(tbl, k, nil)
		end
		if rawget(tbl, "ThreatLevel") == "Observing" then
			rawset(tbl, "ThreatLevel", "Trusted")
		end
		if rawget(tbl, "MovementMode") == "Correcting" then
			rawset(tbl, "MovementMode", "Grounded")
		end
	end
end

-- RigSync & Anti-AFK listeners (without instantiating VirtualUser)
function Core.init()
	local rigRemotes = {
		"RE/RigSync/CorrectionBegan",
		"RE/RigSync/ProbeSatchel",
		"RE/RigSync/SeedSatchel",
		"RE/GearSatchel/Lost",
		"RE/GearSatchel/Gained",
	}
	for _, rName in ipairs(rigRemotes) do
		local rem = Core.getRemote(rName)
		if rem and rem:IsA("RemoteEvent") then
			TRex.connectSignal(rem.OnClientEvent, function()
				Core.LastRigSyncAt = os.clock()
			end)
		end
	end

	local RunService = TRex.Services.RunService
	local function onMovementStep()
		if TRex.Config.AutoSteal or TRex.Config.FastTween or TRex.Config.VelocityGlide or TRex.Config.CustomSpeedEnabled then
			Core.trustMovement()
		end
	end
	if RunService then
		TRex.connectSignal(RunService.Heartbeat, onMovementStep)
		TRex.connectSignal(RunService.Stepped, onMovementStep)
		if RunService.PreSimulation then
			TRex.connectSignal(RunService.PreSimulation, onMovementStep)
		end
	end

	TRex.registerCleanupHook(Core.restoreAntiAFK)
	if TRex.Config.AntiAFK then
		Core.applyAntiAFK(true)
	end
end

-- ============================================================================
-- [Games/Game01/Modules/02_auto_farm_pets.lua]
-- ============================================================================
-- T-RexProject/Games/Game01/Modules/02_auto_farm_pets.lua
-- Auto Farm, Steal, Guard Avoidance, Treadmill, Progression, Pen/Hatch/Mutate/Fusery/Sell for Game01

local Workspace = TRex.Services.Workspace
local Core = TRex.Core

local Farm = {}
TRex.Farm = Farm

local CachedFieldRecords = {}
local LastSnapshotFetchAt = 0
local SnapshotBusy = false
local BadStealUntil = {}
local BadPlaceUntil = {}
local BadHatchUntil = {}
local BadMutateUntil = {}

local LastWearBestAt = 0
local LastSellAt = 0
local LastSellEggAt = 0
local LastPlaceAt = 0
local LastHatchAt = 0
local LastFuseryAt = 0
local LastMutateAt = 0
local LastTreadmillAt = 0
local LastTreadmillTierAt = 0
local LastProgressionAt = 0
local LastRedeemVerdictAt = 0
local RedeemListenerHooked = false

local function ensureRedeemListener()
	if RedeemListenerHooked then
		return
	end
	RedeemListenerHooked = true
	local rem = Core.getRemote("RE/EggWorld/FieldEggRedeemVerdict")
	if rem and rem:IsA("RemoteEvent") then
		TRex.connectSignal(rem.OnClientEvent, function()
			LastRedeemVerdictAt = os.clock()
		end)
	end
end

local function buildSlotKey(rec)
	if type(rec) ~= "table" then
		return nil
	end
	if type(rec.AreaId) == "string" and rec.AreaId ~= "" and type(rec.NestId) == "string" and rec.NestId ~= "" then
		return rec.AreaId .. ":" .. rec.NestId
	end
	return nil
end

local function fireCarryAreaEggPrompt(eggPos)
	if typeof(eggPos) ~= "Vector3" or type(fireproximityprompt) ~= "function" then
		return false
	end
	local fired = false
	for _, child in ipairs(Workspace:GetChildren()) do
		if child.Name == "SmartPromptPart" and child:IsA("BasePart") then
			local prompt = child:FindFirstChild("CarryAreaEgg")
			if prompt and prompt:IsA("ProximityPrompt") then
				local xzDist = Vector3.new(child.Position.X - eggPos.X, 0, child.Position.Z - eggPos.Z).Magnitude
				if xzDist < 12 then
					pcall(function()
						prompt.HoldDuration = 0
					end)
					pcall(fireproximityprompt, prompt)
					fired = true
				end
			end
		end
	end
	return fired
end

local DEEP_MULTI_LEG_AREAS = {
	Prehistoric = true,
	Cosmic = true,
	["Cherry Blossom"] = true,
}

local function getCarryReturnLegs(areaId, distX)
	if DEEP_MULTI_LEG_AREAS[tostring(areaId or "")] then
		return 4
	end
	if distX and distX > 900 then
		return 2
	end
	return 1
end

local function formatMutations(muts)
	if type(muts) ~= "table" then
		return tostring(muts or "")
	end
	local parts = {}
	for k, v in pairs(muts) do
		if v == true then
			table.insert(parts, tostring(k))
		elseif type(v) == "string" and v ~= "" then
			table.insert(parts, v)
		end
	end
	return table.concat(parts, ",")
end

local function hasMutation(muts, mutId)
	if type(muts) ~= "table" then
		return false
	end
	if muts[mutId] == true then
		return true
	end
	for _, v in pairs(muts) do
		if v == mutId then
			return true
		end
	end
	return false
end

local function isFavorited(item)
	return type(item) == "table" and (item.IsFavorite == true or item.Favourite == true)
end

local function moveByMode(mode, targetPos, shouldContinue)
	if mode == "Teleport" then
		if TRex.Combat and TRex.Combat.teleportTo then
			return TRex.Combat.teleportTo(targetPos, shouldContinue)
		end
		return Core.setRootCFrame(CFrame.new(targetPos))
	end
	if TRex.Combat and TRex.Combat.fastTweenTo then
		return TRex.Combat.fastTweenTo(targetPos, TRex.Config.TweenSpeed, shouldContinue)
	end
	return Core.setRootCFrame(CFrame.new(targetPos))
end

local function moveGo(targetPos, shouldContinue)
	return moveByMode(TRex.Config.StealGoMode or "Teleport", targetPos, shouldContinue)
end

local function moveReturn(targetPos, shouldContinue)
	return moveByMode(TRex.Config.StealReturnMode or "FastTween", targetPos, shouldContinue)
end

local function dropCarriedEgg()
	local res = Core.callModule("Egg", "DropFieldEgg", "PlayerRequest")
	if res == nil then
		if not Core.fireNS("EggWorld", "DropFieldEgg", "PlayerRequest") then
			Core.fireRemote("DropFieldEgg")
		end
	end
end

local function getPlotReturnAnchor(plot)
	local renders = Workspace:FindFirstChild("PlacedEggRenders")
	local lp = TRex.LocalPlayer
	if renders and lp then
		local prefix = tostring(lp.UserId) .. "_"
		local sum = Vector3.zero
		local count = 0
		for _, child in ipairs(renders:GetChildren()) do
			if child.Name:sub(1, #prefix) == prefix then
				local pos = child:IsA("BasePart") and child.Position or (child:IsA("Model") and child:GetPivot().Position or nil)
				if pos then
					sum = sum + pos
					count = count + 1
				end
			end
		end
		if count > 0 then
			return sum / count
		end
	end
	return plot and (plot.RespawnPointCFrame and plot.RespawnPointCFrame.Position or (plot.PetArea and plot.PetArea.Position)) or nil
end

local function isGuardChasingCarry()
	local st = Core.getCarryState()
	if not (type(st) == "table" and st.IsCarrying and st.GuardDisabled ~= true and st.AreaId) then
		return false
	end
	local guardAreas = Core.findWorldPath("Areas", "GuardAreas")
	local areaFolder = guardAreas and guardAreas:FindFirstChild(tostring(st.AreaId))
	local guard = areaFolder and areaFolder:FindFirstChild("Guard")
	if not guard then
		return false
	end
	local gState = tostring(guard:GetAttribute("GuardState") or "")
	if gState == "Sleeping" or gState == "" then
		return false
	end
	local lpId = TRex.LocalPlayer and TRex.LocalPlayer.UserId
	local target = tonumber(guard:GetAttribute("TargetPlayer"))
	local wakeTarget = tonumber(guard:GetAttribute("WakeTargetPlayer"))
	return target == lpId or wakeTarget == lpId
end

function Farm.getFieldEggs()
	local snapshot = Core.callModule("Egg", "ReadFieldEggs")
	if type(snapshot) == "table" and type(snapshot.Records) == "table" then
		CachedFieldRecords = snapshot.Records
		LastSnapshotFetchAt = os.clock()
	elseif not SnapshotBusy and os.clock() - LastSnapshotFetchAt >= 3 then
		SnapshotBusy = true
		LastSnapshotFetchAt = os.clock()
		task.spawn(function()
			local ok, res = Core.invokeNS("EggWorld", "AskFieldEggSnapshot")
			SnapshotBusy = false
			if ok and type(res) == "table" and type(res.Records) == "table" then
				CachedFieldRecords = res.Records
			end
		end)
	end

	local list = {}
	for _, rec in pairs(CachedFieldRecords) do
		if type(rec) == "table" and rec.Uid then
			local cf = rec.BoundsCFrame or rec.BottomCFrame
			local pos = typeof(cf) == "CFrame" and cf.Position or (typeof(rec.Position) == "Vector3" and rec.Position or nil)
			if pos and rec.State ~= "Carried" then
				local info = Core.computeEggInfo(rec)
				table.insert(list, {
					Uid = rec.Uid,
					AreaId = rec.AreaId,
					NestId = rec.NestId,
					AssetCategory = rec.AssetCategory,
					Name = tostring(rec.AssetCategory or rec.Name or rec.Uid),
					Rarity = info.Rarity,
					RarityRank = info.RarityRank,
					WeightKg = info.WeightKg,
					Value = info.Value,
					MutCount = info.MutCount,
					Mutation = formatMutations(rec.Mutations),
					Position = pos,
					Record = rec,
				})
			end
		end
	end
	return list
end

local function isEggBetter(a, b, sortMode, rootPos)
	if not b then
		return true
	end
	if sortMode == "Biggest Weight" then
		if a.WeightKg ~= b.WeightKg then
			return a.WeightKg > b.WeightKg
		end
	elseif sortMode == "Best Mutation" then
		if a.MutCount ~= b.MutCount then
			return a.MutCount > b.MutCount
		end
	elseif sortMode == "Highest Value" then
		if a.Value ~= b.Value then
			return a.Value > b.Value
		end
	elseif sortMode == "Lowest Value" then
		if a.Value ~= b.Value then
			return a.Value < b.Value
		end
	end
	if a.RarityRank ~= b.RarityRank then
		return a.RarityRank > b.RarityRank
	end
	return (a.Position - rootPos).Magnitude < (b.Position - rootPos).Magnitude
end

local function findEggRecordByUid(uid)
	for _, egg in ipairs(Farm.getFieldEggs()) do
		if egg.Uid == uid then
			return egg
		end
	end
	return nil
end

local function stealChase(uid, shouldContinue)
	if not uid then
		return false
	end
	local deadline = os.clock() + 8
	local RunService = TRex.Services.RunService
	local lp = TRex.LocalPlayer
	local lpId = lp and lp.UserId or 0
	while os.clock() < deadline and TRex.IsRunning and Core.isAlive() and not Core.isCarryingEgg() do
		if type(shouldContinue) == "function" and not shouldContinue() then
			return false
		end
		local root = Core.getRoot()
		if not root then
			return false
		end
		local eggPos = nil
		local model = Workspace:FindFirstChild(tostring(uid))
		if model and model:IsA("Model") then
			eggPos = model:GetPivot().Position
		else
			local rec = findEggRecordByUid(uid)
			if rec then
				eggPos = rec.Position
			end
		end
		if not eggPos then
			return false
		end
		local snap = Core.callModule("Egg", "ReadFieldEggs")
		if type(snap) == "table" and type(snap.Records) == "table" then
			local r = snap.Records[uid]
			if type(r) == "table" and r.State == "Carried" and tonumber(r.CarrierUserId) ~= lpId then
				return false
			end
		end
		local flat = Vector3.new(eggPos.X - root.Position.X, 0, eggPos.Z - root.Position.Z)
		if flat.Magnitude > 600 then
			return false
		end
		if flat.Magnitude > 3 then
			local spd = math.min(Core.getWalkSpeed() * 0.95, flat.Magnitude / 0.05)
			pcall(function()
				root.AssemblyLinearVelocity = flat.Unit * spd + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
			end)
		end
		if flat.Magnitude < 12 then
			local liveRec = findEggRecordByUid(uid)
			Core.callModule("Egg", "CarryFieldEgg", uid, buildSlotKey(liveRec))
			fireCarryAreaEggPrompt(eggPos)
		end
		RunService.Heartbeat:Wait()
	end
	return Core.isCarryingEgg()
end

local function stepWalkNear(targetPos, shouldContinue, timeout)
	local RunService = TRex.Services.RunService
	local deadline = os.clock() + (timeout or 4)
	while os.clock() < deadline and TRex.IsRunning and Core.isAlive() do
		if type(shouldContinue) == "function" and not shouldContinue() then
			return false
		end
		local root = Core.getRoot()
		if not root then
			return false
		end
		local flat = Vector3.new(targetPos.X - root.Position.X, 0, targetPos.Z - root.Position.Z)
		if flat.Magnitude <= 3 then
			pcall(function()
				root.AssemblyLinearVelocity = Vector3.zero
			end)
			return true
		end
		local spd = math.min(Core.getWalkSpeed() * 0.95, flat.Magnitude / 0.05)
		pcall(function()
			root.AssemblyLinearVelocity = flat.Unit * spd + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
		end)
		RunService.Heartbeat:Wait()
	end
	return false
end

function Farm.stepAutoSteal()
	ensureRedeemListener()
	if not TRex.Config.AutoSteal or not Core.isAlive() or Core.isRagdolled() then
		return
	end
	if not Core.acquireMover("Steal", 10, 8) then
		return
	end
	local root = Core.getRoot()
	local hum = Core.getHumanoid()
	if not root or not hum then
		Core.releaseMover("Steal")
		return
	end
	local sepPos = Core.getSeparationLinePos()
	local sepX = sepPos.X

	-- If already carrying an egg, return across SeparationLine into Safe Zone (multi-leg if far)
	if Core.isCarryingEgg() then
		local carrySt = Core.getCarryState()
		local carriedUid = type(carrySt) == "table" and (carrySt.Uid or carrySt.FieldEggUid) or nil
		local carriedArea = type(carrySt) == "table" and carrySt.AreaId or nil
		if isGuardChasingCarry() and not Core.isInSafeZone(root.Position) then
			Core.trustMovement()
			Core.setRootCFrame(CFrame.new(sepX - 15, math.max(root.Position.Y, sepPos.Y + 4), root.Position.Z))
			if isGuardChasingCarry() then
				dropCarriedEgg()
			end
			Core.releaseMover("Steal")
			return
		end
		local targetZ = math.clamp(root.Position.Z, -415, -305)
		if not Core.isInSafeZone(root.Position) then
			Core.trustMovement()
			local RunService = TRex.Services.RunService
			local safeX = sepX - 15
			local retMode = TRex.Config.StealReturnMode or "FastTween"
			local legs = getCarryReturnLegs(carriedArea, root.Position.X - safeX)
			local startX = root.Position.X
			local flyY = math.min(math.max(root.Position.Y - 3, sepPos.Y), sepPos.Y + 12)
			local pullSpd = math.max(tonumber(TRex.Config.TweenSpeed) or 3300, 60)

			if retMode == "Teleport" then
				local step = math.max(Core.getWalkSpeed() * 1.515, 40)
				local curX = root.Position.X
				local nextLeg = 1
				local stepY = math.max(root.Position.Y, sepPos.Y) + 42
				while TRex.IsRunning and Core.isAlive() and Core.isCarryingEgg() and curX > safeX do
					if not TRex.Config.AutoSteal then
						break
					end
					Core.trustMovement()
					curX = math.max(safeX, curX - step)
					local legThreshold = startX - (startX - safeX) * (nextLeg / legs)
					Core.setRootCFrame(CFrame.new(curX, stepY, targetZ))
					if nextLeg < legs and curX <= legThreshold then
						nextLeg = nextLeg + 1
						local hold = 0
						local need = 0.19 + Core.getPing()
						while hold < need and Core.isCarryingEgg() and TRex.Config.AutoSteal do
							Core.trustMovement()
							Core.setRootCFrame(CFrame.new(curX, stepY, targetZ))
							hold = hold + RunService.Heartbeat:Wait()
						end
						if carriedUid and Core.isCarryingEgg() then
							dropCarriedEgg()
							local tw = 0
							while Core.isCarryingEgg() and tw < 1.2 do
								tw = tw + RunService.Heartbeat:Wait()
							end
							if not Core.isCarryingEgg() then
								stealChase(carriedUid, function()
									return TRex.Config.AutoSteal
								end)
							end
						end
					else
						local tw = 0
						while tw < 0.1 and Core.isCarryingEgg() and TRex.Config.AutoSteal do
							Core.trustMovement()
							Core.setRootCFrame(CFrame.new(curX, stepY, targetZ))
							tw = tw + RunService.Heartbeat:Wait()
						end
					end
				end
			else
				for leg = 1, legs do
					if not TRex.Config.AutoSteal or not Core.isAlive() or not Core.isCarryingEgg() then
						break
					end
					local legX = startX - (startX - safeX) * (leg / legs)
					while TRex.IsRunning and Core.isAlive() and Core.isCarryingEgg() and TRex.Config.AutoSteal do
						Core.trustMovement()
						local r = Core.getRoot()
						if not r or r.Position.X <= legX then
							break
						end
						local dt = RunService.Heartbeat:Wait()
						local dx = math.min(pullSpd * math.clamp(dt, 0.005, 0.1), 250, r.Position.X - legX)
						local nx = r.Position.X - dx
						local nz = r.Position.Z + (targetZ - r.Position.Z) * 0.03
						Core.setRootCFrame(CFrame.new(nx, flyY, nz))
					end
					if leg < legs and carriedUid and Core.isCarryingEgg() then
						dropCarriedEgg()
						local tw = 0
						while Core.isCarryingEgg() and tw < 1.2 do
							tw = tw + RunService.Heartbeat:Wait()
						end
						if not Core.isCarryingEgg() then
							stealChase(carriedUid, function()
								return TRex.Config.AutoSteal
							end)
						end
					end
				end
			end
		end
		root = Core.getRoot()
		if root and Core.isInSafeZone(root.Position) and Core.isCarryingEgg() then
			local riftDest = Core.getRiftMachinePos() + Vector3.new(0, 3, 0)
			local t0 = os.clock()
			Core.trustMovement()
			Core.setRootCFrame(CFrame.new(riftDest))
			local deadline = t0 + 1.5 + Core.getPing() * 3
			local RunService = TRex.Services.RunService
			while os.clock() < deadline and TRex.Config.AutoSteal and Core.isAlive() and Core.isCarryingEgg() do
				if LastRedeemVerdictAt >= t0 then
					break
				end
				RunService.Heartbeat:Wait()
			end
			-- If server did not redeem yet, step briefly outside SeparationLine and re-cross to RiftMachine
			if Core.isCarryingEgg() and TRex.Config.AutoSteal and Core.isAlive() then
				Core.trustMovement()
				Core.setRootCFrame(CFrame.new(sepX + 18, sepPos.Y + 3, targetZ))
				local waitOut = os.clock() + 0.3 + Core.getPing()
				while os.clock() < waitOut and TRex.Config.AutoSteal and Core.isAlive() and Core.isCarryingEgg() do
					RunService.Heartbeat:Wait()
				end
				if Core.isCarryingEgg() then
					Core.trustMovement()
					Core.setRootCFrame(CFrame.new(riftDest))
					local waitBack = os.clock() + 1.2 + Core.getPing() * 2
					while os.clock() < waitBack and TRex.Config.AutoSteal and Core.isAlive() and Core.isCarryingEgg() do
						if LastRedeemVerdictAt >= t0 then
							break
						end
						RunService.Heartbeat:Wait()
					end
				end
			end
		end
		Core.releaseMover("Steal")
		return
	end

	local now = os.clock()
	local minRank = Core.RARITY_RANK[TRex.Config.StealMinRarity] or 3
	local sortMode = TRex.Config.StealSortMode or "Best Rarity"
	local eggs = Farm.getFieldEggs()
	local best = nil
	for _, egg in ipairs(eggs) do
		if not tostring(egg.Uid):find("^FirstAreaEgg") and egg.RarityRank >= minRank and (BadStealUntil[egg.Uid] or 0) <= now then
			if isEggBetter(egg, best, sortMode, root.Position) then
				best = egg
			end
		end
	end
	if not best then
		Core.releaseMover("Steal")
		return
	end

	-- Cross SeparationLine safely before teleporting/tweening deep into field
	if TRex.Config.StealSafeCrossing and Core.isInSafeZone(root.Position) and best.Position.X >= sepX then
		moveGo(Vector3.new(sepX + 6, math.max(root.Position.Y, sepPos.Y + 3), best.Position.Z), function()
			return TRex.Config.AutoSteal and not Core.isCarryingEgg() and findEggRecordByUid(best.Uid) ~= nil
		end)
		if (TRex.Config.StealGoMode or "Teleport") == "Teleport" then
			task.wait(0.06)
		end
		if not TRex.Config.AutoSteal or not Core.isAlive() then
			Core.releaseMover("Steal")
			return
		end
	end

	local live = findEggRecordByUid(best.Uid)
	if not live then
		Core.releaseMover("Steal")
		return
	end
	root = Core.getRoot()
	if root and (root.Position - live.Position).Magnitude > 6.5 then
		moveGo(live.Position + Vector3.new(0, 3, 0), function()
			return TRex.Config.AutoSteal and not Core.isCarryingEgg() and findEggRecordByUid(best.Uid) ~= nil
		end)
	end
	if not TRex.Config.AutoSteal or not Core.isAlive() then
		Core.releaseMover("Steal")
		return
	end

	pcall(hum.UnequipTools, hum)
	local slotKey = buildSlotKey(live)
	local triedGameplayWalk = false
	for _ = 1, 5 do
		local okCall, carryRes = pcall(Core.callModule, "Egg", "CarryFieldEgg", best.Uid, slotKey)
		if (okCall and carryRes == true) or Core.isCarryingEgg() then
			Core.releaseMover("Steal")
			return
		end
		fireCarryAreaEggPrompt(live.Position)
		if Core.isCarryingEgg() then
			Core.releaseMover("Steal")
			return
		end
		if not triedGameplayWalk and type(carryRes) == "string" and carryRes:lower():find("gameplay area") then
			triedGameplayWalk = true
			task.wait(0.6)
			stepWalkNear(live.Position, function()
				return TRex.Config.AutoSteal and not Core.isCarryingEgg()
			end, 3.5)
		else
			task.wait(0.08)
		end
	end

	local firstAreaKey = nil
	local slotIdMod = Core.Modules.SlotId
	if type(slotIdMod) == "table" and type(slotIdMod.LooksLikeFirstAreaUid) == "function" and slotIdMod.LooksLikeFirstAreaUid(best.Uid) then
		local okKey, key = pcall(slotIdMod.SlotKey, best.AreaId, best.NestId)
		if okKey then
			firstAreaKey = key
		end
	end

	local okCarry = Core.invokeNSBoolean("EggWorld", "AskFieldEggCarry", {
		Uid = best.Uid,
		FirstAreaSlotKey = firstAreaKey or slotKey,
	})
	if not okCarry then
		okCarry = Core.invokeServerBoolean("AskCarryEgg", best.Uid)
	end
	if not okCarry and not Core.isCarryingEgg() then
		okCarry = stealChase(best.Uid, function()
			return TRex.Config.AutoSteal
		end)
	end
	if not okCarry and not Core.isCarryingEgg() then
		BadStealUntil[best.Uid] = os.clock() + 8
	end
	Core.releaseMover("Steal")
end

function Farm.stepTreadmill()
	if not Core.isAlive() or Core.isRagdolled() then
		return
	end
	local now = os.clock()
	if TRex.Config.AutoTreadmill and now - LastTreadmillAt >= 2 then
		LastTreadmillAt = now
		local root = Core.getRoot()
		if root and not root.Anchored and Core.acquireMover("Treadmill", 3, 2) then
			local adminTread = Workspace:FindFirstChild("AdminTreadmill")
			local pad = adminTread and (adminTread:FindFirstChild("Pad", true) or adminTread:FindFirstChildWhichIsA("BasePart", true))
			local plot = Core.getPlot()
			local bottom = pad or (plot and plot.PlotFolder and plot.PlotFolder:FindFirstChild("TreadmillBottom", true))
			if bottom and bottom:IsA("BasePart") then
				if (root.Position - bottom.Position).Magnitude > 4 then
					moveByMode("FastTween", bottom.Position + Vector3.new(0, 3, 0), function()
						return TRex.Config.AutoTreadmill and not TRex.Config.AutoSteal
					end)
				end
			end
			Core.invokeNSBoolean("Treadmill", "AskWearStill")
			Core.releaseMover("Treadmill")
		end
	end

	if TRex.Config.AutoTreadmillTier and now - LastTreadmillTierAt >= 1.5 then
		LastTreadmillTierAt = now
		local save = Core.getSaveData()
		local treadMod = Core.Modules.Tread
		if save and type(treadMod) == "table" and type(treadMod.GetByUpgradeLevel) == "function" then
			local okTier, nextTier = pcall(treadMod.GetByUpgradeLevel, (save.TreadmillUpgradeLevel or 0) + 1)
			if okTier and type(nextTier) == "table" and type(nextTier.Price) == "number" and (save.Money or 0) >= nextTier.Price then
				Core.invokeNSBoolean("Treadmill", "AskTierRaise", nextTier._id)
			end
		end
	end

	if (TRex.Config.AutoBuyTrail or TRex.Config.AutoUpgradeBase) and now - LastProgressionAt >= 4 then
		LastProgressionAt = now
		local save = Core.getSaveData()
		if save then
			if TRex.Config.AutoBuyTrail and type(Core.Modules.Trails) == "table" and type(Core.Modules.Trails.Directory) == "table" then
				local owned = type(save.TrailInventory) == "table" and save.TrailInventory or {}
				for id, info in pairs(Core.Modules.Trails.Directory) do
					if type(info) == "table" and not owned[id] and type(info.Price) == "number" and (save.Money or 0) >= info.Price then
						if not Core.invokeNSBoolean("Trails", "AskBuy", id) then
							Core.fireNS("Trails", "AskBuy", id)
						end
						break
					end
				end
			end
			if TRex.Config.AutoUpgradeBase and type(Core.Modules.Bases) == "table" then
				local curLevel = tonumber(save.BaseLevel or save.BaseTier) or 0
				local maxFn = Core.Modules.Bases.GetMaxBaseLevel
				local maxLevel = type(maxFn) == "function" and select(2, pcall(maxFn)) or 99
				if curLevel < (tonumber(maxLevel) or 99) then
					Core.fireNS("Homestead", "AskBaseTierRaise")
				end
			end
		end
	end
end

function Farm.doffTreadmill()
	Core.invokeNS("Treadmill", "AskDoff")
end

local function equipEggToolByUid(uid)
	if Core.callModule("Egg", "WearEggTool", uid) == true then
		return true
	end
	local hum = Core.getHumanoid()
	local lp = TRex.LocalPlayer
	local char = Core.getCharacter()
	if hum and lp then
		local backpack = lp:FindFirstChildOfClass("Backpack")
		for _, container in ipairs({ char, backpack }) do
			if container then
				for _, tool in ipairs(container:GetChildren()) do
					if tool:IsA("Tool") and tool:GetAttribute("UID") == uid then
						pcall(hum.EquipTool, hum, tool)
						return true
					end
				end
			end
		end
	end
	return Core.invokeNSBoolean("EggWorld", "AskWearTool", uid)
end

function Farm.stepPenAndHatch()
	if not Core.isAlive() or Core.isRagdolled() then
		return
	end
	local now = os.clock()
	local save = Core.getSaveData()

	if TRex.Config.AutoPlaceEgg and now - LastPlaceAt >= 2.5 and Core.acquireMover("Place", 6, 3) then
		LastPlaceAt = now
		local plot = Core.getPlot()
		local petArea = plot and plot.PetArea
		if save and type(save.EggInventory) == "table" and petArea and petArea:IsA("BasePart") then
			local placedCount = 0
			local unplacedUid = nil
			for uid, egg in pairs(save.EggInventory) do
				if type(egg) == "table" then
					if egg.Placement then
						placedCount = placedCount + 1
					elseif not unplacedUid and (BadPlaceUntil[uid] or 0) <= now then
						unplacedUid = uid
					end
				end
			end
			if unplacedUid and placedCount < 30 then
				local root = Core.getRoot()
				if root and (root.Position - petArea.Position).Magnitude > 22 then
					moveByMode("FastTween", petArea.Position + Vector3.new(0, 3, 0), function()
						return TRex.Config.AutoPlaceEgg and not TRex.Config.AutoSteal
					end)
				end
				if equipEggToolByUid(unplacedUid) then
					task.wait(0.15)
					local placed = false
					for attempt = 1, 4 do
						local ox = math.random(-8, 8) + attempt * 0.5
						local oz = math.random(-8, 8)
						if Core.invokeNSBoolean("EggWorld", "AskPlaceEgg", {
							Uid = unplacedUid,
							LocalCFrame = CFrame.new(ox, 0, oz),
						}) then
							placed = true
							break
						end
					end
					if not placed then
						BadPlaceUntil[unplacedUid] = os.clock() + 10
					end
					Core.callModule("Egg", "DoffEggTool")
				end
			end
		end
		Core.releaseMover("Place")
	end

	if TRex.Config.AutoHatch and now - LastHatchAt >= 1.5 then
		LastHatchAt = now
		local eggs = Core.callModule("Egg", "ReadOwnerEggs", TRex.LocalPlayer.UserId) or (save and save.EggInventory)
		if type(eggs) == "table" then
			local serverNow = Core.getServerNow()
			local hatchedCount = 0
			for uid, egg in pairs(eggs) do
				if hatchedCount >= 4 then
					break
				end
				if type(egg) == "table" and egg.Placement and (BadHatchUntil[uid] or 0) <= now then
					local ready = Core.callModule("Egg", "IsReadyToHatch", uid) == true
						or (type(egg.Placement.ReadyAt) == "number" and egg.Placement.ReadyAt <= serverNow)
					if ready then
						if Core.invokeNSBoolean("EggWorld", "AskHatch", uid) then
							Core.invokeNSBoolean("EggWorld", "AskFinishHatch", uid)
							hatchedCount = hatchedCount + 1
						else
							BadHatchUntil[uid] = os.clock() + 10
						end
						task.wait(0.15)
					end
				end
			end
		end
	end
end

local function findMutationConsumables()
	local tools = {}
	local lp = TRex.LocalPlayer
	local char = Core.getCharacter()
	local backpack = lp and lp:FindFirstChildOfClass("Backpack")
	for _, container in ipairs({ char, backpack }) do
		if container then
			for _, tool in ipairs(container:GetChildren()) do
				if tool:IsA("Tool") and tool:GetAttribute("ItemType") == "MutationConsumable" then
					local mutId = tool:GetAttribute("MutationId") or tool:GetAttribute("MutationTemplate")
					if mutId then
						table.insert(tools, { Tool = tool, MutId = tostring(mutId) })
					end
				end
			end
		end
	end
	return tools
end

function Farm.stepFuseryAndMutate()
	if not Core.isAlive() or Core.isRagdolled() then
		return
	end
	local now = os.clock()
	local save = Core.getSaveData()

	if TRex.Config.AutoFusery and save and now - LastFuseryAt >= 3 then
		LastFuseryAt = now
		if type(save.FusionEggReward) == "table" then
			Core.invokeNSBoolean("Fusery", "FinishReveal")
		elseif not save.FusionLocked and type(save.Inventory) == "table" then
			local maxRank = Core.RARITY_RANK[TRex.Config.FuseMaxRarity or "Mythic"] or 6
			local skipMutated = TRex.Config.FuseSkipMutated ~= false
			local bySpecies = {}
			local equippedSet = {}
			for _, eqUid in ipairs(save.EquippedAssets or {}) do
				equippedSet[eqUid] = true
			end
			for uid, item in pairs(save.Inventory) do
				if type(item) == "table" and not equippedSet[uid] and not isFavorited(item) and item.AssetCategory then
					local info = Core.computeEggInfo(item)
					if info.RarityRank <= maxRank and (not skipMutated or info.MutCount == 0) then
						bySpecies[item.AssetCategory] = bySpecies[item.AssetCategory] or {}
						table.insert(bySpecies[item.AssetCategory], uid)
					end
				end
			end
			for _, uids in pairs(bySpecies) do
				if #uids >= 3 then
					if Core.invokeNSBoolean("Fusery", "ConfirmBriefing") then
						local loaded = true
						for i = 1, 3 do
							if not Core.invokeNSBoolean("Fusery", "LoadPet", uids[i], false) then
								loaded = false
								break
							end
							task.wait(0.3)
						end
						if loaded then
							Core.invokeNSBoolean("Fusery", "BeginFuse")
						else
							for s = 1, 3 do
								Core.invokeNS("Fusery", "EjectPet", s)
							end
						end
					end
					break
				end
			end
		end
	end

	if TRex.Config.AutoMutate and save and now - LastMutateAt >= 3 and Core.acquireMover("Mutate", 5, 3) then
		LastMutateAt = now
		local consumables = findMutationConsumables()
		local plot = Core.getPlot()
		local petArea = plot and plot.PetArea
		local eggs = Core.callModule("Egg", "ReadOwnerEggs", TRex.LocalPlayer.UserId) or save.EggInventory
		if #consumables > 0 and type(eggs) == "table" and petArea and petArea:IsA("BasePart") then
			local hum = Core.getHumanoid()
			for _, c in ipairs(consumables) do
				local targetUid, targetPos = nil, nil
				for uid, egg in pairs(eggs) do
					if type(egg) == "table" and egg.Placement and not hasMutation(egg.Mutations, c.MutId) and (BadMutateUntil[uid .. ":" .. c.MutId] or 0) <= now then
						targetUid = uid
						if typeof(egg.Placement.LocalCFrame) == "CFrame" then
							targetPos = (petArea.CFrame * egg.Placement.LocalCFrame).Position
						else
							targetPos = petArea.Position
						end
						break
					end
				end
				if targetUid and targetPos and hum then
					moveByMode("FastTween", targetPos + Vector3.new(0, 3, 4), function()
						return TRex.Config.AutoMutate and not TRex.Config.AutoSteal
					end)
					pcall(hum.EquipTool, hum, c.Tool)
					task.wait(0.25)
					local okMut = Core.invokeNSBoolean("BossMastery", "AskUseMutationConsumable", targetUid)
					if not okMut then
						BadMutateUntil[targetUid .. ":" .. c.MutId] = os.clock() + 600
					end
					pcall(hum.UnequipTools, hum)
					break
				end
			end
		end
		Core.releaseMover("Mutate")
	end

	if TRex.Config.WearBestPet and now - LastWearBestAt >= 5 then
		LastWearBestAt = now
		local okStatus, shouldWear = Core.invokeNS("Haul", "FetchWearBestStatus")
		if okStatus and shouldWear then
			Core.invokeNS("Haul", "WearBest")
		end
	end

	if TRex.Config.AutoSellPets and save and now - LastSellAt >= 4.5 then
		LastSellAt = now
		local equippedSet = {}
		for _, eqUid in ipairs(save.EquippedAssets or {}) do
			equippedSet[eqUid] = true
		end
		local sellAssets = {}
		for uid, item in pairs(save.Inventory or {}) do
			if type(item) == "table" and not equippedSet[uid] and not isFavorited(item) then
				table.insert(sellAssets, uid)
				if #sellAssets >= 25 then
					break
				end
			end
		end
		if #sellAssets > 0 then
			Core.fireNS("PetSatchel", "SellSelection", { Eggs = {}, Assets = sellAssets })
		end
	end

	if TRex.Config.AutoSellEggs and save and type(save.EggInventory) == "table" and now - LastSellEggAt >= 4 then
		LastSellEggAt = now
		local unplaced = {}
		for uid, egg in pairs(save.EggInventory) do
			if type(egg) == "table" and not egg.Placement then
				local info = Core.computeEggInfo(egg)
				table.insert(unplaced, { Uid = uid, Value = info.Value, MutCount = info.MutCount })
			end
		end
		if #unplaced >= 105 then
			table.sort(unplaced, function(a, b)
				return a.Value < b.Value
			end)
			for _, e in ipairs(unplaced) do
				if e.MutCount == 0 then
					Core.fireNS("PetSatchel", "SellSelection", { Eggs = { e.Uid }, Assets = {} })
					break
				end
			end
		end
	end
end

function Farm.buildUI(ui)
	local tab = ui.addTab("farm", "tab.farm")

	local stealSec = tab:addSection("sec.steal")
	stealSec:addToggle({ key = "AutoSteal", label = "opt.auto_steal", desc = "desc.auto_steal" })
	stealSec:addDropdown({ key = "StealGoMode", label = "opt.steal_go_mode", items = { "Teleport", "FastTween" } })
	stealSec:addDropdown({ key = "StealReturnMode", label = "opt.steal_return_mode", items = { "FastTween", "Teleport" } })
	stealSec:addDropdown({
		key = "StealSortMode",
		label = "opt.steal_sort",
		items = { "Best Rarity", "Biggest Weight", "Best Mutation", "Highest Value", "Lowest Value" },
	})
	stealSec:addDropdown({ key = "StealMinRarity", label = "opt.steal_rarity", items = Core.RARITY_ORDER })
	stealSec:addToggle({ key = "StealSafeCrossing", label = "opt.safe_crossing" })

	local treadSec = tab:addSection("sec.treadmill")
	treadSec:addToggle({
		key = "AutoTreadmill",
		label = "opt.auto_treadmill",
		onChanged = function(enabled)
			if not enabled then
				Farm.doffTreadmill()
			end
		end,
	})
	treadSec:addToggle({ key = "AutoTreadmillTier", label = "opt.auto_treadmill_tier" })
	treadSec:addToggle({ key = "AutoBuyTrail", label = "opt.auto_buy_trail" })
	treadSec:addToggle({ key = "AutoUpgradeBase", label = "opt.auto_upgrade_base" })

	local petSec = tab:addSection("sec.pets_fusery")
	petSec:addToggle({ key = "AutoPlaceEgg", label = "opt.auto_place_egg" })
	petSec:addToggle({ key = "AutoHatch", label = "opt.auto_hatch" })
	petSec:addToggle({ key = "AutoFusery", label = "opt.auto_fusery" })
	petSec:addDropdown({ key = "FuseMaxRarity", label = "opt.fuse_max_rarity", items = Core.RARITY_ORDER })
	petSec:addToggle({ key = "FuseSkipMutated", label = "opt.fuse_skip_mutated" })
	petSec:addToggle({ key = "AutoMutate", label = "opt.auto_mutate" })
	petSec:addToggle({ key = "WearBestPet", label = "opt.wear_best" })
	petSec:addToggle({ key = "AutoSellPets", label = "opt.auto_sell" })
	petSec:addToggle({ key = "AutoSellEggs", label = "opt.auto_sell_eggs" })
end

function Farm.startLoop()
	task.spawn(function()
		while TRex.IsRunning do
			pcall(Farm.stepAutoSteal)
			pcall(Farm.stepTreadmill)
			pcall(Farm.stepPenAndHatch)
			pcall(Farm.stepFuseryAndMutate)
			task.wait(0.35)
		end
	end)
end

-- ============================================================================
-- [Games/Game01/Modules/03_events_minigames.lua]
-- ============================================================================
-- T-RexProject/Games/Game01/Modules/03_events_minigames.lua
-- Events & Minigames Engine for Game01 (Butterfly Bloom, Shooting Star, Fishing, Alien Lagoon, Banjo Cricket, Admin Abuse)

local Workspace = TRex.Services.Workspace
local ReplicatedStorage = TRex.Services.ReplicatedStorage
local Core = TRex.Core

local Events = {}
TRex.Events = Events

Events.State = {
	ActiveStar = nil,
	NetClaimed = false,
	RunningLiveEvents = {},
	ServerButterflies = {},
	CurrentButterflyId = nil,
	IslandWarsState = nil,
}

local SwarmController = nil
local TIER_WEIGHT = { Green = 1, Emerald = 1, Blue = 2, Sapphire = 2, Purple = 3, Amethyst = 3, Golden = 4, Radiant = 4 }
local ENCHANTED_TREE_POS = Vector3.new(6700, 74, -364)

local LastAwayAt = 0
local LastCodexAt = 0
local LastAdminAt = 0
local LastFishAt = 0
local LastAlienAt = 0
local LastBanjoAt = 0
local LastTradeAt = 0

local function getSwarmController()
	if SwarmController then
		return SwarmController
	end
	local ok, mod = pcall(function()
		return require(ReplicatedStorage.Controllers.Game.AdminAbuseClientController.Events.ButterflyBloom.Swarm)
	end)
	if ok and type(mod) == "table" then
		SwarmController = mod
	end
	return SwarmController
end

local function findToolByPredicate(pred)
	local char = Core.getCharacter()
	local lp = TRex.LocalPlayer
	local bp = lp and lp:FindFirstChildOfClass("Backpack")
	local found = {}
	for _, container in ipairs({ char, bp }) do
		if container then
			for _, tool in ipairs(container:GetChildren()) do
				if tool:IsA("Tool") and pred(tool) then
					table.insert(found, tool)
				end
			end
		end
	end
	return found
end

local function findButterflyNet()
	local nets = findToolByPredicate(function(tool)
		return tool:GetAttribute("ButterflyNet") == true
			or tool:GetAttribute("ItemType") == "ButterflyNet"
			or tool.Name == "Butterfly Net"
	end)
	return nets[1]
end

local function isTreeUnlocked()
	local lp = TRex.LocalPlayer
	if lp and lp:GetAttribute("EnchantedTreeUnlocked") == true then
		return true
	end
	local save = Core.getSaveData()
	return type(save) == "table" and type(save.Butterflies) == "table" and save.Butterflies.NetClaimed == true
end

local function claimNetAtTree()
	if Events.State.NetClaimed or isTreeUnlocked() then
		Events.State.NetClaimed = true
		return true
	end
	local lp = TRex.LocalPlayer
	local netStand = Core.findWorldPath("Machines", "ButterflyStation", "NetStand")
	if netStand and netStand:IsA("BasePart") and lp then
		pcall(function()
			lp:RequestStreamAroundAsync(netStand.Position)
		end)
		Core.setRootCFrame(CFrame.new(netStand.Position + Vector3.new(0, 3, 4)))
		task.wait(0.25)
	end
	for _ = 1, 5 do
		if Core.invokeNSBoolean("Butterflies", "AskClaimNet") then
			Events.State.NetClaimed = true
			return true
		end
		task.wait(0.35)
	end
	return false
end

function Events.init()
	local starFall = Core.getRemote("ShootingStar", "Fall", "event")
	if starFall and starFall:IsA("RemoteEvent") then
		TRex.connectSignal(starFall.OnClientEvent, function(payload)
			if type(payload) == "table" and payload.Id ~= nil then
				Events.State.ActiveStar = payload
			end
		end)
	end
	for _, evName in ipairs({ "Claimed", "Expired" }) do
		local rem = Core.getRemote("ShootingStar", evName, "event")
		if rem and rem:IsA("RemoteEvent") then
			TRex.connectSignal(rem.OnClientEvent, function(id)
				if Events.State.ActiveStar and Events.State.ActiveStar.Id == id then
					Events.State.ActiveStar = nil
				end
			end)
		end
	end

	local bSpawn = Core.getRemote("Butterflies", "Spawned", "event")
	if bSpawn and bSpawn:IsA("RemoteEvent") then
		TRex.connectSignal(bSpawn.OnClientEvent, function(flight)
			if type(flight) == "table" and flight.Id ~= nil then
				Events.State.ServerButterflies[flight.Id] = flight
			end
		end)
	end
	for _, evName in ipairs({ "Escaped", "Removed" }) do
		local rem = Core.getRemote("Butterflies", evName, "event")
		if rem and rem:IsA("RemoteEvent") then
			TRex.connectSignal(rem.OnClientEvent, function(id)
				Events.State.ServerButterflies[id] = nil
			end)
		end
	end

	local liveBegan = Core.getRemote("LiveEvents", "Began", "event")
	if liveBegan and liveBegan:IsA("RemoteEvent") then
		TRex.connectSignal(liveBegan.OnClientEvent, function(ev)
			if type(ev) == "table" and ev.Id then
				Events.State.RunningLiveEvents[ev.Id] = ev
			end
		end)
	end
	local liveEnded = Core.getRemote("LiveEvents", "Ended", "event")
	if liveEnded and liveEnded:IsA("RemoteEvent") then
		TRex.connectSignal(liveEnded.OnClientEvent, function(id)
			Events.State.RunningLiveEvents[id] = nil
		end)
	end
	local iwState = Core.getRemote("IslandWars", "State", "event")
	if iwState and iwState:IsA("RemoteEvent") then
		TRex.connectSignal(iwState.OnClientEvent, function(st)
			Events.State.IslandWarsState = st
		end)
	end
end

function Events.stepButterfly()
	if not Core.isAlive() or Core.isRagdolled() then
		return
	end
	local now = os.clock()
	if (TRex.Config.AutoTradeButterfly or TRex.Config.AutoCraftEssence) and now - LastTradeAt >= 5 then
		LastTradeAt = now
		if TRex.Config.AutoTradeButterfly then
			for _, tier in ipairs({ "Green", "Blue", "Purple" }) do
				Core.invokeNSBoolean("Butterflies", "AskTradeUp", tier)
			end
		end
		if TRex.Config.AutoCraftEssence and Workspace:GetAttribute("Event_ButterflyBloom") ~= true and isTreeUnlocked() then
			Core.invokeNSBoolean("Butterflies", "AskCraftEssence")
		end
	end

	if not TRex.Config.AutoButterfly then
		return
	end
	if TRex.Config.AutoClaimNet and not Events.State.NetClaimed then
		claimNetAtTree()
	end

	local root = Core.getRoot()
	local hum = Core.getHumanoid()
	if not root or not hum then
		return
	end

	local bestId, bestPos = nil, nil
	local bestScore = math.huge
	local spd = math.max(tonumber(TRex.Config.ButterflySpeed) or 120, 20)
	local swarm = getSwarmController()
	if swarm and type(swarm.Each) == "function" then
		pcall(function()
			for id, entry in swarm.Each() do
				local flight = type(entry) == "table" and entry.Flight
				local body = type(entry) == "table" and entry.Body
				if type(flight) == "table" and typeof(body) == "Instance" then
					local pos = body:IsA("BasePart") and body.Position or (body:IsA("Model") and body:GetPivot().Position or nil)
					if pos then
						local weight = (TRex.Config.ButterflyPriority ~= "Nearest") and (TIER_WEIGHT[flight.Tier] or 0) or 0
						local stickBonus = (id == Events.State.CurrentButterflyId) and 1 or 0
						local score = ((pos - root.Position).Magnitude / spd) - (weight * 1000) - stickBonus
						if score < bestScore then
							bestScore = score
							bestId = id
							bestPos = pos
						end
					end
				end
			end
		end)
	end

	-- Fallback to server-replicated ButterflyCatalog prediction
	if not bestPos and type(Core.Modules.Cat) == "table" and type(Core.Modules.Cat.PositionAt) == "function" then
		local serverNow = Core.getServerNow()
		for id, flight in pairs(Events.State.ServerButterflies) do
			local okP, pos = pcall(Core.Modules.Cat.PositionAt, flight, serverNow)
			if okP and typeof(pos) == "Vector3" then
				local weight = (TRex.Config.ButterflyPriority ~= "Nearest") and (TIER_WEIGHT[flight.Tier] or 0) or 0
				local score = ((pos - root.Position).Magnitude / spd) - (weight * 1000)
				if score < bestScore then
					bestScore = score
					bestId = id
					bestPos = pos
				end
			end
		end
	end

	if bestPos and Core.acquireMover("Butterfly", 4, 2) then
		Events.State.CurrentButterflyId = bestId
		local net = findButterflyNet()
		if net and net.Parent ~= Core.getCharacter() then
			pcall(hum.EquipTool, hum, net)
		end
		if TRex.Combat and TRex.Combat.fastTweenTo then
			TRex.Combat.fastTweenTo(bestPos, spd, function()
				return TRex.Config.AutoButterfly and not TRex.Config.AutoSteal
			end)
		end
		if net and net.Parent == Core.getCharacter() then
			pcall(net.Activate, net)
		end
		Core.releaseMover("Butterfly")
	elseif Workspace:GetAttribute("Event_ButterflyBloom") == true and (root.Position - ENCHANTED_TREE_POS).Magnitude > 300 and isTreeUnlocked() then
		if Core.acquireMover("Butterfly", 4, 2) then
			Core.setRootCFrame(CFrame.new(ENCHANTED_TREE_POS))
			Core.releaseMover("Butterfly")
		end
	end
end

function Events.stepMinigames()
	if not Core.isAlive() or Core.isRagdolled() then
		return
	end
	local now = os.clock()
	local root = Core.getRoot()
	local hum = Core.getHumanoid()

	-- Wisp Quest
	if TRex.Config.AutoWispQuest and isTreeUnlocked() then
		Core.invokeNS("WispCompanion", "Request", "Claim")
	end

	-- Admin Abuse / Live Events
	if TRex.Config.AutoAdminAbuse and now - LastAdminAt >= 3 then
		LastAdminAt = now
		local okL, running = Core.invokeNS("LiveEvents", "FetchRunning")
		if okL and type(running) == "table" then
			Events.State.RunningLiveEvents = running
		end
		local okI, iw = Core.invokeNS("IslandWars", "Fetch")
		if okI and type(iw) == "table" then
			Events.State.IslandWarsState = iw
		end
		if Workspace:GetAttribute("Event_CaptureTheEgg") == true then
			local eggPart = Workspace:FindFirstChild("CaptureTheEggSpawn", true) or Workspace:FindFirstChild("AdminAbuseEggSpawn", true)
			if eggPart and eggPart:IsA("BasePart") and root and Core.acquireMover("AdminAbuse", 5, 2) then
				Core.setRootCFrame(CFrame.new(eggPart.Position + Vector3.new(0, 3, 0)))
				Core.releaseMover("AdminAbuse")
			end
		end
	end

	-- Fishing (equip rod, Hold, charge, Cast(chargeTime, aimVector3))
	if TRex.Config.AutoFishing and now - LastFishAt >= 3.5 and root and hum then
		LastFishAt = now
		local rods = findToolByPredicate(function(tool)
			return tool:GetAttribute("IsRod") == true or tool.Name:lower():find("rod") ~= nil
		end)
		local bestRod = rods[1]
		if bestRod then
			if bestRod.Parent ~= Core.getCharacter() then
				pcall(hum.EquipTool, hum, bestRod)
				task.wait(0.15)
			end
			local aimPos = root.Position + root.CFrame.LookVector * 28 + Vector3.new(0, -6, 0)
			Core.fireNS("Fishing", "Hold")
			local chargeTime = 0.85
			task.wait(chargeTime)
			if TRex.Config.AutoFishing then
				Core.invokeNSBoolean("Fishing", "Cast", chargeTime, aimPos)
			else
				Core.fireNS("Fishing", "Cancel")
			end
		end
	end

	-- Shooting Star (Hold for HoldSeconds within range, then Catch)
	if TRex.Config.AutoShootingStar and Events.State.ActiveStar and root then
		local star = Events.State.ActiveStar
		local pos = star.Position or star.TargetPosition
		if typeof(pos) == "Vector3" and Core.acquireMover("ShootingStar", 7, 3) then
			if (root.Position - pos).Magnitude > 12 then
				if TRex.Combat and TRex.Combat.fastTweenTo then
					TRex.Combat.fastTweenTo(pos + Vector3.new(0, 3, 0), TRex.Config.TweenSpeed, function()
						return TRex.Config.AutoShootingStar and Events.State.ActiveStar == star
					end)
				end
			end
			local holdSec = tonumber(star.HoldSeconds) or 1.6
			Core.fireNS("ShootingStar", "Hold", star.Id, true)
			local t0 = os.clock()
			local okHold = true
			while os.clock() - t0 < holdSec do
				if not TRex.Config.AutoShootingStar or not Core.isAlive() or Events.State.ActiveStar ~= star then
					okHold = false
					break
				end
				task.wait(0.1)
			end
			if okHold then
				Core.fireNS("ShootingStar", "Catch", star.Id)
				Events.State.ActiveStar = nil
			else
				Core.fireNS("ShootingStar", "Hold", star.Id, false)
			end
			Core.releaseMover("ShootingStar")
		end
	end

	-- Alien Lagoon (Arrive, Request, Trade)
	if TRex.Config.AutoAlienLagoon and now - LastAlienAt >= 3 then
		LastAlienAt = now
		Core.invokeNS("AlienLagoon", "Arrive")
		Core.invokeNS("AlienLagoon", "Request")
		Core.invokeNS("AlienLagoon", "Trade")
	end

	-- Banjo Cricket
	if TRex.Config.AutoBanjoCricket and now - LastBanjoAt >= 3 and isTreeUnlocked() then
		LastBanjoAt = now
		Core.invokeNS("BanjoCricket", "AskClaim")
	end

	-- Away Earnings
	if TRex.Config.AutoCollectAway and now - LastAwayAt >= 12 then
		LastAwayAt = now
		local okSum, summary = Core.invokeNS("AwayEarnings", "FetchSummary")
		if okSum and type(summary) == "table" and (tonumber(summary.PendingOfflineMoney) or 0) > 0 then
			Core.invokeNSBoolean("AwayEarnings", "AskCollect", { Kind = "Claim" })
		end
	end

	-- Codex
	if TRex.Config.AutoRedeemCodex and now - LastCodexAt >= 15 then
		LastCodexAt = now
		Core.invokeNS("Codex", "AskRedeemAll")
		for _, cat in ipairs({ "LimitedEgg", "BrainrotEgg", "MonsterEgg" }) do
			Core.invokeNS("Codex", "AskRedeemLimitedEgg", cat)
		end
	end
end

function Events.buildUI(ui)
	local tab = ui.addTab("events", "tab.events")

	local bSec = tab:addSection("sec.butterfly")
	bSec:addToggle({ key = "AutoButterfly", label = "opt.auto_butterfly" })
	bSec:addDropdown({ key = "ButterflyPriority", label = "opt.butterfly_priority", items = { "Nearest", "Tier" } })
	bSec:addNumericInput({ key = "ButterflySpeed", label = "opt.butterfly_speed", min = 40, max = 300, integer = true })
	bSec:addToggle({ key = "AutoClaimNet", label = "opt.auto_claim_net" })
	bSec:addToggle({ key = "AutoTradeButterfly", label = "opt.auto_trade_butterfly" })
	bSec:addToggle({ key = "AutoCraftEssence", label = "opt.auto_craft_essence" })
	bSec:addToggle({ key = "AutoWispQuest", label = "opt.auto_wisp" })

	local mSec = tab:addSection("sec.minigames")
	mSec:addToggle({ key = "AutoAdminAbuse", label = "opt.auto_admin" })
	mSec:addToggle({ key = "AutoFishing", label = "opt.auto_fishing" })
	mSec:addToggle({ key = "AutoShootingStar", label = "opt.auto_star" })
	mSec:addToggle({ key = "AutoAlienLagoon", label = "opt.auto_alien" })
	mSec:addToggle({ key = "AutoBanjoCricket", label = "opt.auto_banjo" })
	mSec:addToggle({ key = "AutoCollectAway", label = "opt.auto_away" })
	mSec:addToggle({ key = "AutoRedeemCodex", label = "opt.auto_codex" })
end

function Events.startLoop()
	task.spawn(function()
		while TRex.IsRunning do
			pcall(Events.stepButterfly)
			pcall(Events.stepMinigames)
			task.wait(0.25)
		end
	end)
end

-- ============================================================================
-- [Games/Game01/Modules/04_player_combat.lua]
-- ============================================================================
-- T-RexProject/Games/Game01/Modules/04_player_combat.lua
-- Player Movement & Combat Engine for Game01
-- Features: Fast Tween (Heartbeat stepped), Teleport, Velocity Glide, Ragdoll TP, Auto Bat Swing
-- Remotes: RE/BatSwing/Trigger (target, "%d:%d:%d") + tool:Activate()

local RunService = TRex.Services.RunService
local Players = TRex.Services.Players
local Workspace = TRex.Services.Workspace
local Core = TRex.Core

local Combat = {}
TRex.Combat = Combat

local SeqCounter = 0
local DefaultWalkSpeed = nil
local DefaultJumpPower = nil
local LastRagdollEscapeAt = 0
local LastSwingAt = 0

local function findGuardForArea(areaId)
	local guardAreas = Core.findWorldPath("Areas", "GuardAreas")
	if not guardAreas then
		return nil
	end
	local folder = areaId and guardAreas:FindFirstChild(tostring(areaId))
	local guard = folder and folder:FindFirstChild("Guard")
	if guard and guard:IsA("BasePart") then
		return guard
	end
	local forest = guardAreas:FindFirstChild("Forest")
	local fGuard = forest and forest:FindFirstChild("Guard")
	return (fGuard and fGuard:IsA("BasePart")) and fGuard or nil
end

function Combat.ragdollTeleportTo(targetPos, shouldContinue)
	if typeof(targetPos) ~= "Vector3" then
		return false
	end
	local strike = Core.getRemote("RE/GuardPatrol/ForestStrike")
	local root = Core.getRoot()
	if not strike or not root or Core.isCarryingEgg() or Core.isRagdolled() then
		return false
	end
	local tried = {}
	local picked = nil
	for _ = 1, 3 do
		root = Core.getRoot()
		if not root or (type(shouldContinue) == "function" and not shouldContinue()) then
			break
		end
		local bestCand, bestDist = nil, 600
		local snap = Core.callModule("Egg", "ReadFieldEggs")
		local records = (type(snap) == "table" and type(snap.Records) == "table") and snap.Records or {}
		for _, rec in pairs(records) do
			if type(rec) == "table" and type(rec.Uid) == "string" and not tried[rec.Uid] and rec.State == "Slot" and typeof(rec.BottomCFrame) == "CFrame" then
				local areaId = type(rec.AreaId) == "string" and rec.AreaId or nil
				local nestId = type(rec.NestId) == "string" and rec.NestId or nil
				local slotKey = (areaId and nestId) and (areaId .. ":" .. nestId) or nil
				local guard = slotKey and findGuardForArea(areaId)
				if guard then
					local pos = rec.BottomCFrame.Position
					local d = Vector3.new(pos.X - root.Position.X, 0, pos.Z - root.Position.Z).Magnitude
					if d <= bestDist then
						bestDist = d
						bestCand = { uid = rec.Uid, slot = slotKey, guard = guard, at = pos }
					end
				end
			end
		end
		if not bestCand then
			break
		end
		local held = 0
		while not Core.isCarryingEgg(bestCand.uid) and held < 2.5 and TRex.IsRunning and Core.isAlive() do
			if type(shouldContinue) == "function" and not shouldContinue() then
				return false
			end
			Core.trustMovement()
			Core.setRootCFrame(CFrame.new(bestCand.at + Vector3.new(0, 3, 0)))
			local ok, res = pcall(Core.callModule, "Egg", "CarryFieldEgg", bestCand.uid, bestCand.slot)
			if ok ~= true and type(res) == "string" then
				if res:lower():find("full") then
					return false
				end
				if held > 0.4 and not res:lower():find("closer") then
					break
				end
			end
			held = held + RunService.Heartbeat:Wait()
		end
		if Core.isCarryingEgg(bestCand.uid) then
			picked = bestCand
			break
		end
		tried[bestCand.uid] = true
	end
	if not picked then
		return false
	end

	local landed = false
	local conn = TRex.LocalPlayer:GetAttributeChangedSignal("RagdollEndTime"):Connect(function()
		if not landed and Core.isRagdolled() then
			landed = true
			Core.trustMovement()
			Core.setRootCFrame(CFrame.new(targetPos))
		end
	end)
	pcall(strike.FireServer, strike, {
		EggUid = picked.uid,
		GuardCFrame = picked.guard.CFrame,
	})
	local waited = 0
	while not landed and waited < 3 and TRex.IsRunning and Core.isAlive() do
		if type(shouldContinue) == "function" and not shouldContinue() then
			break
		end
		waited = waited + RunService.Heartbeat:Wait()
	end
	pcall(conn.Disconnect, conn)
	if Core.isCarryingEgg(picked.uid) then
		pcall(Core.callModule, "Egg", "DropFieldEgg", "PlayerRequest")
	end
	if landed then
		task.spawn(function()
			local hum = Core.getHumanoid()
			local deadline = os.clock() + 1.5
			local clearStates = {
				[Enum.HumanoidStateType.Freefall] = true,
				[Enum.HumanoidStateType.Physics] = true,
				[Enum.HumanoidStateType.Ragdoll] = true,
				[Enum.HumanoidStateType.FallingDown] = true,
				[Enum.HumanoidStateType.None] = true,
			}
			while hum and hum.Parent and os.clock() < deadline do
				if clearStates[hum:GetState()] then
					pcall(hum.ChangeState, hum, Enum.HumanoidStateType.GettingUp)
				end
				if hum.PlatformStand then
					hum.PlatformStand = false
				end
				RunService.Heartbeat:Wait()
			end
		end)
	end
	root = Core.getRoot()
	return landed and root ~= nil and (root.Position - targetPos).Magnitude <= 30
end

function Combat.teleportTo(targetPos, shouldContinue)
	if typeof(targetPos) ~= "Vector3" then
		return false
	end
	local root = Core.getRoot()
	if not root then
		return false
	end
	local dest = targetPos + Vector3.new(0, 3, 0)
	if (root.Position - dest).Magnitude > 1500 and not Core.isCarryingEgg() and not Core.isRagdolled() then
		Combat.ragdollTeleportTo(dest, shouldContinue)
		root = Core.getRoot()
		if not root then
			return false
		end
	end
	local step = math.max(Core.getWalkSpeed() * 1.515, 40)
	local cur = Vector3.new(root.Position.X, math.max(root.Position.Y, targetPos.Y), root.Position.Z)
	while TRex.IsRunning and Core.isAlive() do
		if type(shouldContinue) == "function" and not shouldContinue() then
			return false
		end
		local flat = Vector3.new(targetPos.X - cur.X, 0, targetPos.Z - cur.Z)
		if flat.Magnitude <= step then
			break
		end
		cur = cur + flat.Unit * step
		local held = 0
		while held < 0.1 and TRex.IsRunning and Core.isAlive() do
			if type(shouldContinue) == "function" and not shouldContinue() then
				return false
			end
			Core.trustMovement()
			Core.setRootCFrame(CFrame.new(cur))
			held = held + RunService.Heartbeat:Wait()
		end
	end
	if type(shouldContinue) == "function" and not shouldContinue() then
		return false
	end
	Core.trustMovement()
	return Core.setRootCFrame(CFrame.new(dest))
end

function Combat.fastTweenTo(targetPos, speed, shouldContinue)
	local root = Core.getRoot()
	if not root or typeof(targetPos) ~= "Vector3" then
		return false
	end
	local spd = math.max(tonumber(speed) or TRex.Config.TweenSpeed or 3300, 20)
	while TRex.IsRunning and Core.isAlive() do
		if type(shouldContinue) == "function" and not shouldContinue() then
			return false
		end
		root = Core.getRoot()
		if not root then
			return false
		end
		local delta = targetPos - root.Position
		local dist = delta.Magnitude
		if dist <= 3.5 then
			Core.trustMovement()
			Core.setRootCFrame(CFrame.new(targetPos))
			return true
		end
		local dt = RunService.Heartbeat:Wait()
		local stepDist = math.min(dist, spd * math.clamp(dt, 0.005, 0.1), 250)
		local nextPos = root.Position + delta.Unit * stepDist
		Core.trustMovement()
		Core.setRootCFrame(CFrame.new(nextPos))
	end
	return false
end

function Combat.moveTo(targetPos, shouldContinue)
	if TRex.Config.FastTween then
		return Combat.fastTweenTo(targetPos, TRex.Config.TweenSpeed, shouldContinue)
	end
	return Combat.teleportTo(targetPos)
end

function Combat.warpToSafeZone()
	local sep = Core.getSeparationLinePos()
	return Combat.moveTo(Vector3.new(sep.X - 24, sep.Y + 4, sep.Z))
end

function Combat.warpToRiftMachine()
	return Combat.moveTo(Core.getRiftMachinePos())
end

local function isMeleeWeapon(tool)
	if not tool or not tool:IsA("Tool") then
		return false
	end
	if tool:GetAttribute("ItemType") ~= nil or tool:GetAttribute("GearName") ~= nil then
		return false
	end
	if tool:GetAttribute("IsBat") == true then
		return true
	end
	local lower = tool.Name:lower()
	return lower:find("bat") ~= nil or lower:find("sword") ~= nil or lower:find("hammer") ~= nil
end

function Combat.findBestBat()
	local char = Core.getCharacter()
	local backpack = TRex.LocalPlayer:FindFirstChildOfClass("Backpack")
	local now = Core.getServerNow()
	local ping = Core.getPing()
	for _, container in ipairs({ char, backpack }) do
		if container then
			for _, child in ipairs(container:GetChildren()) do
				if isMeleeWeapon(child) then
					local cdEnd = tonumber(child:GetAttribute("CooldownEndTime")) or 0
					if now >= cdEnd - ping * 0.5 then
						return child
					end
				end
			end
		end
	end
	return nil
end

function Combat.findNearestTargetPlayer()
	local root = Core.getRoot()
	if not root then
		return nil
	end
	local bestPlr = nil
	local bestDist = math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= TRex.LocalPlayer and plr.Character then
			local pRoot = plr.Character:FindFirstChild("HumanoidRootPart")
			local pHum = plr.Character:FindFirstChildOfClass("Humanoid")
			if pRoot and pHum and pHum.Health > 0 then
				local d = (pRoot.Position - root.Position).Magnitude
				if d < bestDist then
					bestDist = d
					bestPlr = plr
				end
			end
		end
	end
	return bestPlr, bestDist
end

function Combat.stepCombat()
	if not Core.isAlive() then
		return
	end
	local hum = Core.getHumanoid()
	local root = Core.getRoot()
	if hum then
		if not DefaultWalkSpeed then
			DefaultWalkSpeed = hum.WalkSpeed
			DefaultJumpPower = hum.JumpPower
		end
		if TRex.Config.CustomSpeedEnabled then
			hum.WalkSpeed = math.clamp(tonumber(TRex.Config.WalkSpeedValue) or 32, 16, 500)
			hum.JumpPower = math.clamp(tonumber(TRex.Config.JumpPowerValue) or 50, 20, 300)
		end
	end

	-- Ragdoll TP: warp safely to safe-zone when ragdolled
	if TRex.Config.RagdollTP and root and Core.isRagdolled() then
		local nowClk = os.clock()
		if nowClk - LastRagdollEscapeAt >= 1.2 then
			LastRagdollEscapeAt = nowClk
			local sep = Core.getSeparationLinePos()
			Core.setRootCFrame(CFrame.new(sep.X - 24, sep.Y + 8, root.Position.Z))
		end
	end

	-- Velocity Glide: smooth forward velocity along MoveDirection
	if TRex.Config.VelocityGlide and hum and root and hum.MoveDirection.Magnitude > 0.1 then
		local spd = math.clamp(tonumber(TRex.Config.TweenSpeed) or 120, 24, 300)
		pcall(function()
			root.AssemblyLinearVelocity = Vector3.new(
				hum.MoveDirection.X * spd,
				math.max(root.AssemblyLinearVelocity.Y, 0),
				hum.MoveDirection.Z * spd
			)
		end)
	end

	if TRex.Config.AutoBatSwing and root and Workspace:GetAttribute("PvPDisabled") ~= true then
		local ping = Core.getPing()
		local nowClk = os.clock()
		if nowClk - LastSwingAt >= math.max(0.12, ping * 1.5) then
			local weapon = Combat.findBestBat()
			local target, dist = Combat.findNearestTargetPlayer()
			local enemyRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
			local enemyRagdoll = target and (tonumber(target:GetAttribute("RagdollEndTime")) or 0) > Core.getServerNow()
			if weapon and target and enemyRoot and dist and not enemyRagdoll then
				local reach = 17 * (Workspace:GetAttribute("DragonEggEventActive") and 2.5 or 1) - 1
				local myPos = TRex.Config.BatAimPredict
					and (root.Position - root.AssemblyLinearVelocity * 0.18)
					or root.Position
				local predictedPos = TRex.Config.BatAimPredict
					and (enemyRoot.Position + enemyRoot.AssemblyLinearVelocity * ping)
					or enemyRoot.Position
				if (predictedPos - myPos).Magnitude <= reach or (enemyRoot.Position - myPos).Magnitude <= reach then
					local char = Core.getCharacter()
					if hum and weapon.Parent ~= char then
						pcall(hum.EquipTool, hum, weapon)
					end
					LastSwingAt = nowClk
					SeqCounter += 1
					local tsMs = math.floor(Core.getServerNow() * 1000)
					local seqPayload = ("%d:%d:%d"):format(TRex.LocalPlayer.UserId, SeqCounter, tsMs)
					Core.fireNS("BatSwing", "Trigger", target, seqPayload)
					pcall(weapon.Activate, weapon)
				end
			end
		end
	end
end

function Combat.restoreCharacterStats()
	local hum = Core.getHumanoid()
	if hum and DefaultWalkSpeed then
		pcall(function()
			hum.WalkSpeed = DefaultWalkSpeed
			if DefaultJumpPower then
				hum.JumpPower = DefaultJumpPower
			end
		end)
	end
end

function Combat.buildUI(ui)
	local tab = ui.addTab("combat", "tab.combat")

	local moveSec = tab:addSection("sec.movement")
	moveSec:addToggle({ key = "FastTween", label = "opt.fast_tween" })
	moveSec:addNumericInput({ key = "TweenSpeed", label = "opt.tween_speed", min = 20, max = 4500, integer = true })
	moveSec:addToggle({ key = "VelocityGlide", label = "opt.velocity_glide" })
	moveSec:addToggle({ key = "RagdollTP", label = "opt.ragdoll_tp" })
	moveSec:addToggle({
		key = "CustomSpeedEnabled",
		label = "opt.custom_speed",
		onChanged = function(enabled)
			if not enabled then
				Combat.restoreCharacterStats()
			end
		end,
	})
	moveSec:addNumericInput({ key = "WalkSpeedValue", label = "opt.walk_speed", min = 16, max = 500, integer = true })
	moveSec:addNumericInput({ key = "JumpPowerValue", label = "opt.jump_power", min = 20, max = 300, integer = true })
	moveSec:addButton({
		label = "btn.warp_safe",
		primary = true,
		onClick = function()
			Combat.warpToSafeZone()
		end,
	})
	moveSec:addButton({
		label = "btn.warp_rift",
		onClick = function()
			Combat.warpToRiftMachine()
		end,
	})

	local combatSec = tab:addSection("sec.combat")
	combatSec:addToggle({ key = "AutoBatSwing", label = "opt.auto_bat" })
	combatSec:addToggle({ key = "BatAimPredict", label = "opt.bat_predict" })
	combatSec:addToggle({
		key = "AntiAFK",
		label = "opt.anti_afk",
		onChanged = function(enabled)
			Core.applyAntiAFK(enabled)
		end,
	})
end

function Combat.init()
	TRex.registerCleanupHook(Combat.restoreCharacterStats)
end

function Combat.startLoop()
	task.spawn(function()
		while TRex.IsRunning do
			pcall(Combat.stepCombat)
			task.wait(0.15)
		end
	end)
end

-- ============================================================================
-- [Games/Game01/Modules/05_server_config.lua]
-- ============================================================================
-- T-RexProject/Games/Game01/Modules/05_server_config.lua
-- Server Hopping, JobId Join, and Discord Webhook Alerts for Game01

local HttpService = TRex.Services.HttpService
local TeleportService = TRex.Services.TeleportService

local Server = {}
TRex.Server = Server

local HOP_CACHE_PATH = "T-RexProject/Games/Game01/Config/AutoHopCache.json"
local CACHE_TTL_SECONDS = 1800
local LastHopAttemptAt = 0

local function loadHopCache()
	local raw = TRex.safeReadFile(HOP_CACHE_PATH)
	if not raw then
		return {}
	end
	local ok, tbl = pcall(HttpService.JSONDecode, HttpService, raw)
	if not ok or type(tbl) ~= "table" then
		return {}
	end
	local now = os.time()
	local cleaned = {}
	for jobId, ts in pairs(tbl) do
		if type(ts) == "number" and (now - ts) < CACHE_TTL_SECONDS then
			cleaned[jobId] = ts
		end
	end
	return cleaned
end

local function saveHopCache(cache)
	local ok, encoded = pcall(HttpService.JSONEncode, HttpService, cache)
	if ok then
		TRex.safeWriteFile(HOP_CACHE_PATH, encoded)
	end
end

local FailedJobIds = {}
local CachedServers = nil
local CachedServersAt = 0
local LastHopJobId = nil

function Server.hopServer(mode)
	local hopMode = mode or TRex.Config.HopMode or "LeastPlayers"
	local order = (hopMode == "MostPlayers") and "Desc" or "Asc"
	local maxPages = (hopMode == "Random") and 3 or 6

	if not CachedServers or os.clock() - CachedServersAt > 60 then
		local list = {}
		local cursor = nil
		for _ = 1, maxPages do
			local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=%s&excludeFullGames=true&limit=100%s"):format(
				game.PlaceId,
				order,
				cursor and ("&cursor=" .. HttpService:UrlEncode(cursor)) or ""
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
				if type(srv) == "table" and type(srv.id) == "string" then
					table.insert(list, srv)
				end
			end
			cursor = decoded.nextPageCursor
			if not cursor or cursor == "" then
				break
			end
		end
		if #list == 0 then
			TRex.UI.toast(TRex.t("tab.server"), TRex.t("msg.hop_fetch_failed"), "err")
			return false
		end
		CachedServers = list
		CachedServersAt = os.clock()
	end

	local cache = loadHopCache()
	cache[game.JobId] = os.time()

	local function collect(minFree)
		local out = {}
		for _, srv in ipairs(CachedServers) do
			if srv.id ~= game.JobId and not cache[srv.id] and not FailedJobIds[srv.id] then
				local free = (tonumber(srv.maxPlayers) or 0) - (tonumber(srv.playing) or 0)
				if free >= minFree then
					table.insert(out, srv)
				end
			end
		end
		return out
	end

	local candidates = collect(2)
	if #candidates == 0 then
		candidates = collect(1)
	end
	if #candidates == 0 then
		TRex.UI.toast(TRex.t("tab.server"), TRex.t("msg.hop_no_server"), "warn")
		CachedServers = nil
		return false
	end

	local chosen
	if hopMode == "Random" then
		chosen = candidates[math.random(1, #candidates)]
	else
		chosen = candidates[math.random(1, math.min(5, #candidates))]
	end
	LastHopJobId = chosen.id
	cache[chosen.id] = os.time()
	saveHopCache(cache)
	TRex.UI.toast(TRex.t("tab.server"), TRex.t("msg.hopping"), "ok")
	local okTp = pcall(TeleportService.TeleportToPlaceInstance, TeleportService, game.PlaceId, chosen.id, TRex.LocalPlayer)
	return okTp
end

function Server.rejoinServer()
	pcall(TeleportService.TeleportToPlaceInstance, TeleportService, game.PlaceId, game.JobId, TRex.LocalPlayer)
end

function Server.copyJobId()
	local setclip = TRex.resolveGlobalFunc("setclipboard") or TRex.resolveGlobalFunc("toclipboard")
	if setclip then
		pcall(setclip, tostring(game.JobId))
		TRex.UI.toast(TRex.t("tab.server"), TRex.t("msg.job_copied"), "ok")
	else
		TRex.UI.toast(TRex.t("tab.server"), tostring(game.JobId), "warn")
	end
end

function Server.sendWebhook(title, description)
	if not TRex.Config.WebhookEnabled then
		return false
	end
	local url = tostring(TRex.Config.WebhookUrl or "")
	if not url:match("^https?://") then
		return false
	end
	local reqFn = TRex.resolveGlobalFunc("request") or TRex.resolveGlobalFunc("http_request")
	if not reqFn then
		return false
	end
	local payloadOk, body = pcall(HttpService.JSONEncode, HttpService, {
		embeds = {
			{
				title = tostring(title),
				description = tostring(description),
				color = 16019894,
			},
		},
	})
	if not payloadOk then
		return false
	end
	pcall(reqFn, {
		Url = url,
		Method = "POST",
		Headers = { ["Content-Type"] = "application/json" },
		Body = body,
	})
	return true
end

function Server.stepAutoHop()
	if not TRex.Config.AutoHop then
		return
	end
	local now = os.clock()
	if now - LastHopAttemptAt < 10 then
		return
	end
	local eggs = TRex.Farm and TRex.Farm.getFieldEggs() or {}
	local minRank = (TRex.Core and TRex.Core.RARITY_RANK and TRex.Core.RARITY_RANK[TRex.Config.StealMinRarity]) or 3
	local hasMatch = false
	for _, egg in ipairs(eggs) do
		if egg.RarityRank >= minRank then
			hasMatch = true
			break
		end
	end
	local cond = TRex.Config.HopCondition
	if cond == "UntilEggMatches" and not hasMatch then
		LastHopAttemptAt = now
		Server.hopServer()
	elseif cond == "StealThenHop" then
		local carrying = TRex.Core and TRex.Core.isCarryingEgg and TRex.Core.isCarryingEgg() or false
		if not hasMatch and not carrying then
			LastHopAttemptAt = now
			Server.hopServer()
		end
	elseif cond == "AfterRareSpawns" and hasMatch then
		Server.sendWebhook("T-Rex Hub • Game01", "Rare egg detected in server " .. tostring(game.JobId))
		LastHopAttemptAt = now
		Server.hopServer()
	end
end

function Server.init()
	TRex.connectSignal(TeleportService.TeleportInitFailed, function(player)
		if player == TRex.LocalPlayer then
			if LastHopJobId then
				FailedJobIds[LastHopJobId] = true
			end
			if TRex.Config.AutoHop then
				task.delay(1.5, function()
					if TRex.IsRunning and TRex.Config.AutoHop then
						Server.hopServer()
					end
				end)
			end
		end
	end)
end

function Server.startLoop()
	task.spawn(function()
		while TRex.IsRunning do
			pcall(Server.stepAutoHop)
			task.wait(2)
		end
	end)
end

function Server.buildUI(ui)
	local tab = ui.addTab("server", "tab.server")

	local hopSec = tab:addSection("sec.server_hop")
	hopSec:addToggle({ key = "AutoHop", label = "opt.auto_hop" })
	hopSec:addDropdown({ key = "HopMode", label = "opt.hop_mode", items = { "LeastPlayers", "MostPlayers", "Random" } })
	hopSec:addDropdown({ key = "HopCondition", label = "opt.hop_condition", items = { "UntilEggMatches", "StealThenHop", "AfterRareSpawns" } })
	hopSec:addButton({
		label = "btn.hop_now",
		primary = true,
		onClick = function()
			Server.hopServer()
		end,
	})
	hopSec:addButton({
		label = "btn.rejoin",
		onClick = function()
			Server.rejoinServer()
		end,
	})
	hopSec:addButton({
		label = "btn.copy_job",
		onClick = function()
			Server.copyJobId()
		end,
	})

	local hookSec = tab:addSection("sec.webhook")
	hookSec:addToggle({ key = "WebhookEnabled", label = "opt.webhook_enabled" })
	hookSec:addTextInput({ key = "WebhookUrl", label = "opt.webhook_url", placeholderKey = "msg.webhook_placeholder" })
end

-- ============================================================================
-- [Games/Game01/Modules/06_render_esp.lua]
-- ============================================================================
-- T-RexProject/Games/Game01/Modules/06_render_esp.lua
-- Render, Visuals & ESP Engine for Game01
-- Supports EggState.ReadFieldEggs() records (with anchor parts under UI.ESPFolder),
-- OwnBaseEggESP via EggState.ReadOwnerEggs, GuardESP, PlayerESP + 2D Tracker, and SafeZone/Rift Markers.

local Players = TRex.Services.Players
local RunService = TRex.Services.RunService
local Workspace = TRex.Services.Workspace
local CollectionService = TRex.Services.CollectionService
local Core = TRex.Core

local Render = {}
TRex.Render = Render

local PlayerEntries = {}
local EggEntries = {}
local OwnBaseEggEntries = {}
local GuardEntries = {}
local MarkerEntries = {}

local function destroyEntry(entry)
	if entry.Billboard then
		pcall(function()
			entry.Billboard:Destroy()
		end)
	end
	if entry.Line then
		pcall(function()
			entry.Line:Destroy()
		end)
	end
	if entry.Part then
		pcall(function()
			entry.Part:Destroy()
		end)
	end
	if entry.Highlight then
		pcall(function()
			entry.Highlight:Destroy()
		end)
	end
end

function Render.clearPlayerESP(plr)
	if plr then
		local entry = PlayerEntries[plr]
		if entry then
			destroyEntry(entry)
			PlayerEntries[plr] = nil
		end
	else
		for p, entry in pairs(PlayerEntries) do
			destroyEntry(entry)
			PlayerEntries[p] = nil
		end
	end
end

function Render.clearEggESP()
	for key, entry in pairs(EggEntries) do
		destroyEntry(entry)
		EggEntries[key] = nil
	end
end

function Render.clearOwnBaseEggESP()
	for key, entry in pairs(OwnBaseEggEntries) do
		destroyEntry(entry)
		OwnBaseEggEntries[key] = nil
	end
end

function Render.clearGuardESP()
	for inst, entry in pairs(GuardEntries) do
		destroyEntry(entry)
		GuardEntries[inst] = nil
	end
end

function Render.clearMarkers()
	for k, entry in pairs(MarkerEntries) do
		destroyEntry(entry)
		MarkerEntries[k] = nil
	end
end

function Render.clearAll()
	Render.clearPlayerESP(nil)
	Render.clearEggESP()
	Render.clearOwnBaseEggESP()
	Render.clearGuardESP()
	Render.clearMarkers()
end

local function createBillboardEntry(name, adornee, color, tempPart)
	local espFolder = TRex.UI.ESPFolder
	if not espFolder then
		return nil
	end
	local bb = Instance.new("BillboardGui")
	bb.Name = name
	bb.Adornee = adornee
	bb.AlwaysOnTop = true
	bb.Size = UDim2.fromOffset(180, 56)
	bb.StudsOffset = Vector3.new(0, 3.2, 0)
	bb.Parent = espFolder

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = color
	lbl.TextStrokeTransparency = 0.3
	lbl.Font = TRex.UI.getFont(true)
	lbl.TextSize = 13
	lbl.Text = ""
	lbl.Parent = bb

	local line = Instance.new("Frame")
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.BorderSizePixel = 0
	line.BackgroundColor3 = color
	line.Visible = false
	line.Parent = TRex.UI.RenderLayer

	return { Billboard = bb, Label = lbl, Line = line, Part = tempPart }
end

local function createAnchorPart(name, pos)
	local espFolder = TRex.UI.ESPFolder
	if not espFolder then
		return nil
	end
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Transparency = 1
	p.Size = Vector3.new(0.2, 0.2, 0.2)
	p.Position = pos
	p.Parent = espFolder
	return p
end

local function updateTrackerLine(line, fromPt, toPt, color)
	if not line then
		return
	end
	local delta = toPt - fromPt
	local len = delta.Magnitude
	if len < 1 then
		line.Visible = false
		return
	end
	local mid = (fromPt + toPt) * 0.5
	line.BackgroundColor3 = color
	line.Position = UDim2.fromOffset(mid.X, mid.Y)
	line.Size = UDim2.fromOffset(len, 1.5)
	line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
	line.Visible = true
end

function Render.step()
	if not TRex.IsRunning then
		return
	end
	local cam = Workspace.CurrentCamera
	local localRoot = Core.getRoot()
	local theme = TRex.UI.getTheme()

	-- Player ESP
	if TRex.Config.PlayerESP then
		local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
		local bottomCenter = Vector2.new(vp.X * 0.5, vp.Y)
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= TRex.LocalPlayer then
				local char = plr.Character
				local pRoot = char and char:FindFirstChild("HumanoidRootPart")
				local pHum = char and char:FindFirstChildOfClass("Humanoid")
				if pRoot and pHum and pHum.Health > 0 then
					local entry = PlayerEntries[plr]
					if not entry or not entry.Billboard or not entry.Billboard.Parent or entry.Billboard.Adornee ~= pRoot then
						Render.clearPlayerESP(plr)
						entry = createBillboardEntry("ESP_" .. plr.Name, pRoot, theme.Accent)
						if entry then
							entry.Billboard.MaxDistance = math.huge
							local hl = Instance.new("Highlight")
							hl.Name = "TRexPlayerHighlight"
							hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
							hl.FillColor = theme.Accent
							hl.OutlineColor = theme.Accent
							hl.FillTransparency = 0.76
							hl.OutlineTransparency = 0.02
							hl.Adornee = char
							hl.Parent = TRex.UI.ESPFolder
							entry.Highlight = hl
							pcall(function()
								pHum.NameDisplayDistance = 0
							end)
						end
						PlayerEntries[plr] = entry
					end
					if entry then
						local dist = localRoot and math.floor((pRoot.Position - localRoot.Position).Magnitude) or 0
						local status = ""
						for _, child in ipairs(char:GetChildren()) do
							if child:IsA("Tool") then
								status = (child:GetAttribute("ItemType") == "AssetEgg") and " • ถือไข่" or " • ถืออาวุธ"
								break
							end
						end
						entry.Label.TextColor3 = theme.Accent
						entry.Label.Font = TRex.UI.getFont(true)
						entry.Label.TextSize = math.clamp(13 * (TRex.Config.FontSize or 14) / 14, 8, 28)
						entry.Label.Text = ("%s\n[%dm • HP %d]%s"):format(plr.DisplayName, dist, math.floor(pHum.Health), status)
						entry.Billboard.Enabled = true
						if TRex.Config.PlayerTracker and cam then
							local pt, onScreen = cam:WorldToViewportPoint(pRoot.Position)
							if onScreen then
								updateTrackerLine(entry.Line, bottomCenter, Vector2.new(pt.X, pt.Y), theme.Accent)
							else
								entry.Line.Visible = false
							end
						else
							entry.Line.Visible = false
						end
					end
				else
					Render.clearPlayerESP(plr)
				end
			end
		end
	else
		Render.clearPlayerESP(nil)
	end

	-- Guard ESP
	if TRex.Config.GuardESP then
		local activeGuards = {}
		local candidates = {}
		local guardsFolder = Core.findWorldPath("Guards") or Workspace:FindFirstChild("Guards")
		if guardsFolder then
			for _, g in ipairs(guardsFolder:GetChildren()) do
				table.insert(candidates, g)
			end
		end
		for _, g in ipairs(CollectionService:GetTagged("Guard")) do
			table.insert(candidates, g)
		end
		for _, g in ipairs(candidates) do
			local gRoot = g:IsA("BasePart") and g or g:FindFirstChild("HumanoidRootPart") or g:FindFirstChildWhichIsA("BasePart")
			if gRoot then
				activeGuards[g] = true
				local entry = GuardEntries[g]
				if not entry or not entry.Billboard or not entry.Billboard.Parent then
					entry = createBillboardEntry("GuardESP_" .. g.Name, gRoot, Color3.fromRGB(239, 68, 68))
					GuardEntries[g] = entry
				end
				if entry then
					local dist = localRoot and math.floor((gRoot.Position - localRoot.Position).Magnitude) or 0
					entry.Label.Text = ("การ์ด %s\n[%dm]"):format(g.Name, dist)
					entry.Billboard.Enabled = true
				end
			end
		end
		for inst, entry in pairs(GuardEntries) do
			if not activeGuards[inst] then
				destroyEntry(entry)
				GuardEntries[inst] = nil
			end
		end
	else
		Render.clearGuardESP()
	end

	-- Field Egg ESP (from EggState.ReadFieldEggs / AskFieldEggSnapshot)
	if TRex.Config.EggESP then
		local activeEggs = {}
		local eggs = TRex.Farm and TRex.Farm.getFieldEggs() or {}
		for _, egg in ipairs(eggs) do
			local key = egg.Uid
			activeEggs[key] = true
			local entry = EggEntries[key]
			if not entry or not entry.Billboard or not entry.Billboard.Parent or not entry.Part or not entry.Part.Parent then
				local anchor = createAnchorPart("EggAnchor_" .. tostring(key), egg.Position)
				if anchor then
					entry = createBillboardEntry("EggESP_" .. egg.Name, anchor, Color3.fromRGB(250, 204, 21), anchor)
					EggEntries[key] = entry
				end
			elseif entry.Part then
				entry.Part.Position = egg.Position
			end
			if entry then
				local dist = localRoot and math.floor((egg.Position - localRoot.Position).Magnitude) or 0
				local mut = (egg.Mutation ~= "" and (" [" .. egg.Mutation .. "]") or "")
				local rec = egg.Record
				local petName = TRex.Config.RevealEggContent100 and rec and (rec.PetCategory or rec.OutcomeCategory or rec.AssetCategory)
				local petTag = petName and ("\n-> " .. tostring(petName)) or ""
				entry.Label.Text = ("%s%s\n%s • %dm%s"):format(egg.Name, mut, egg.Rarity, dist, petTag)
				entry.Billboard.Enabled = true
			end
		end
		for key, entry in pairs(EggEntries) do
			if not activeEggs[key] then
				destroyEntry(entry)
				EggEntries[key] = nil
			end
		end
	else
		Render.clearEggESP()
	end

	-- Own Base Egg ESP (via EggState.ReadOwnerEggs + PlotState)
	if TRex.Config.OwnBaseEggESP then
		local activeOwn = {}
		local plot = Core.getPlot()
		local petArea = plot and plot.PetArea
		local ownerEggs = Core.callModule("Egg", "ReadOwnerEggs", TRex.LocalPlayer.UserId)
		if type(ownerEggs) == "table" and petArea and petArea:IsA("BasePart") then
			for uid, rec in pairs(ownerEggs) do
				if type(rec) == "table" and rec.Placement then
					local lcf = rec.Placement.LocalCFrame
					local pos = typeof(lcf) == "CFrame" and (petArea.CFrame * lcf).Position or petArea.Position
					activeOwn[uid] = true
					local entry = OwnBaseEggEntries[uid]
					if not entry or not entry.Billboard or not entry.Billboard.Parent or not entry.Part or not entry.Part.Parent then
						local anchor = createAnchorPart("OwnEggAnchor_" .. tostring(uid), pos)
						if anchor then
							entry = createBillboardEntry("OwnEggESP_" .. tostring(uid), anchor, Color3.fromRGB(56, 189, 248), anchor)
							OwnBaseEggEntries[uid] = entry
						end
					elseif entry.Part then
						entry.Part.Position = pos
					end
					if entry then
						local dist = localRoot and math.floor((pos - localRoot.Position).Magnitude) or 0
						local cat = tostring(rec.AssetCategory or uid)
						entry.Label.Text = ("[ฐาน] %s\n%dm"):format(cat, dist)
						entry.Billboard.Enabled = true
					end
				end
			end
		end
		for key, entry in pairs(OwnBaseEggEntries) do
			if not activeOwn[key] then
				destroyEntry(entry)
				OwnBaseEggEntries[key] = nil
			end
		end
	else
		Render.clearOwnBaseEggESP()
	end

	-- Other Base Egg ESP (PlacedEggRenders not owned by LocalPlayer)
	if TRex.Config.OtherBaseEggESP then
		local activeOther = {}
		local renders = Workspace:FindFirstChild("PlacedEggRenders")
		local lpPrefix = TRex.LocalPlayer and (tostring(TRex.LocalPlayer.UserId) .. "_") or ""
		if renders then
			for _, child in ipairs(renders:GetChildren()) do
				if child.Name:sub(1, #lpPrefix) ~= lpPrefix then
					local pos = child:IsA("BasePart") and child.Position or (child:IsA("Model") and child:GetPivot().Position or nil)
					if pos then
						local key = "Other_" .. child.Name
						activeOther[key] = true
						local entry = EggEntries[key]
						if not entry or not entry.Billboard or not entry.Billboard.Parent or not entry.Part or not entry.Part.Parent then
							local anchor = createAnchorPart("OtherEggAnchor_" .. child.Name, pos)
							if anchor then
								entry = createBillboardEntry("OtherEggESP_" .. child.Name, anchor, Color3.fromRGB(244, 114, 182), anchor)
								EggEntries[key] = entry
							end
						elseif entry.Part then
							entry.Part.Position = pos
						end
						if entry then
							local dist = localRoot and math.floor((pos - localRoot.Position).Magnitude) or 0
							local cat = tostring(child:GetAttribute("AssetCategory") or child.Name)
							entry.Label.Text = ("[ฐานอื่น] %s\n%dm"):format(cat, dist)
							entry.Billboard.Enabled = true
						end
					end
				end
			end
		end
		for key, entry in pairs(EggEntries) do
			if tostring(key):sub(1, 6) == "Other_" and not activeOther[key] then
				destroyEntry(entry)
				EggEntries[key] = nil
			end
		end
	end

	-- Safe Zone & Rift Machine Markers
	if TRex.Config.ShowSafeZoneMarker then
		if not MarkerEntries.SafeZone then
			local sepPart = Core.findWorldPath("Areas", "SeparationLine")
			if sepPart and sepPart:IsA("BasePart") then
				local entry = createBillboardEntry("SafeZoneMarker", sepPart, Color3.fromRGB(16, 185, 129))
				if entry then
					entry.Label.Text = "เส้นแบ่งเขตปลอดภัย"
					MarkerEntries.SafeZone = entry
				end
			end
		end
		if not MarkerEntries.RiftMachine then
			local riftPart = Core.findWorldPath("Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003")
			local tempPart = nil
			if not (riftPart and riftPart:IsA("BasePart")) then
				tempPart = createAnchorPart("RiftMarkerAnchor", Core.getRiftMachinePos())
				riftPart = tempPart
			end
			if riftPart and riftPart:IsA("BasePart") then
				local entry = createBillboardEntry("RiftMachineMarker", riftPart, Color3.fromRGB(168, 85, 247), tempPart)
				if entry then
					entry.Label.Text = "เครื่อง Rift"
					MarkerEntries.RiftMachine = entry
				elseif tempPart then
					tempPart:Destroy()
				end
			end
		end
	else
		Render.clearMarkers()
	end
end

function Render.init()
	TRex.registerCleanupHook(Render.clearAll)
	TRex.connectSignal(Players.PlayerRemoving, function(plr)
		Render.clearPlayerESP(plr)
	end)
	TRex.connectSignal(RunService.RenderStepped, function()
		Render.step()
	end)
end

function Render.buildUI(ui)
	local tab = ui.addTab("render", "tab.render")

	local espSec = tab:addSection("sec.esp")
	espSec:addToggle({ key = "PlayerESP", label = "opt.player_esp" })
	espSec:addToggle({ key = "PlayerTracker", label = "opt.player_tracker" })
	espSec:addToggle({ key = "GuardESP", label = "opt.guard_esp" })
	espSec:addToggle({ key = "EggESP", label = "opt.egg_esp" })
	espSec:addToggle({ key = "OwnBaseEggESP", label = "opt.own_egg_esp" })
	espSec:addToggle({ key = "OtherBaseEggESP", label = "opt.other_base_egg_esp" })
	espSec:addToggle({ key = "RevealEggContent100", label = "opt.reveal_egg" })
	espSec:addToggle({ key = "ShowSafeZoneMarker", label = "opt.safe_marker" })
end

-- ============================================================================
-- [Games/Game01/Modules/07_optimizer.lua]
-- ============================================================================
-- T-RexProject/Games/Game01/Modules/07_optimizer.lua
-- Optimizer & Performance Engine for Game01
-- Features: Disable 3D Render (with 180s 2s wake pulse), FPS Cap, Low Graphics, Hide UI, Hide Treadmill

local RunService = TRex.Services.RunService
local Lighting = TRex.Services.Lighting
local StarterGui = TRex.Services.StarterGui
local Workspace = TRex.Services.Workspace

local Optimizer = {}
TRex.Optimizer = Optimizer

local OriginalShadows = nil
local OriginalQuality = nil
local HiddenTreadParts = {}
local HiddenGuis = {}
local LastWakeAt = os.clock()

function Optimizer.apply3DRender(disabled)
	pcall(function()
		RunService:Set3dRenderingEnabled(not disabled)
	end)
end

function Optimizer.applyFPSCap()
	local capFn = TRex.resolveGlobalFunc("setfpscap")
	if not capFn then
		return
	end
	if TRex.Config.LowPowerMode then
		pcall(capFn, 40)
	elseif TRex.Config.FPSCapEnabled then
		pcall(capFn, math.clamp(tonumber(TRex.Config.FPSCapValue) or 60, 10, 360))
	else
		pcall(capFn, 0)
	end
end

function Optimizer.applyLowGraphics(enabled)
	pcall(function()
		if enabled then
			if OriginalShadows == nil then
				OriginalShadows = Lighting.GlobalShadows
			end
			Lighting.GlobalShadows = false
			local okSet, renderSettings = pcall(function()
				return settings().Rendering
			end)
			if okSet and renderSettings then
				if OriginalQuality == nil then
					OriginalQuality = renderSettings.QualityLevel
				end
				renderSettings.QualityLevel = Enum.QualityLevel.Level01
			end
		else
			if OriginalShadows ~= nil then
				Lighting.GlobalShadows = OriginalShadows
			end
			if OriginalQuality ~= nil then
				local okSet, renderSettings = pcall(function()
					return settings().Rendering
				end)
				if okSet and renderSettings then
					renderSettings.QualityLevel = OriginalQuality
				end
			end
		end
	end)
end

function Optimizer.applyHideGameUI(enabled)
	local pGui = TRex.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	if pGui then
		for _, gui in ipairs(pGui:GetChildren()) do
			if gui:IsA("ScreenGui") and not gui.Name:match("^TRexThaiCleanUI_") then
				if enabled then
					if HiddenGuis[gui] == nil then
						HiddenGuis[gui] = gui.Enabled
					end
					gui.Enabled = false
				elseif HiddenGuis[gui] ~= nil then
					gui.Enabled = HiddenGuis[gui]
					HiddenGuis[gui] = nil
				end
			end
		end
	end
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, not enabled)
	end)
end

function Optimizer.applyHideTreadmill(enabled)
	if not enabled then
		for part, state in pairs(HiddenTreadParts) do
			if part and part.Parent then
				pcall(function()
					part.CanCollide = state.CanCollide
					part.CanTouch = state.CanTouch
					part.LocalTransparencyModifier = state.Trans
				end)
			end
			HiddenTreadParts[part] = nil
		end
		return
	end
	for _, desc in ipairs(Workspace:GetDescendants()) do
		if desc:IsA("BasePart") and (desc.Name:find("TreadmillBottom") or desc.Name:find("TreadmillUpgrade")) then
			if HiddenTreadParts[desc] == nil then
				HiddenTreadParts[desc] = {
					CanCollide = desc.CanCollide,
					CanTouch = desc.CanTouch,
					Trans = desc.LocalTransparencyModifier,
				}
			end
			pcall(function()
				desc.CanCollide = false
				desc.CanTouch = false
				desc.LocalTransparencyModifier = 1
			end)
		end
	end
end

local FPSHudGui = nil
local FPSHudLabel = nil
local LastFpsTime = os.clock()
local FrameCount = 0

function Optimizer.applyFPSPingHUD(enabled)
	if not enabled then
		if FPSHudGui then
			pcall(FPSHudGui.Destroy, FPSHudGui)
			FPSHudGui = nil
			FPSHudLabel = nil
		end
		return
	end
	if FPSHudGui and FPSHudGui.Parent then
		return
	end
	local gui = Instance.new("ScreenGui")
	gui.Name = "TRexFPSPingHUD"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 50
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromOffset(170, 26)
	lbl.Position = UDim2.new(0, 12, 0, 12)
	lbl.BackgroundColor3 = Color3.fromRGB(15, 18, 25)
	lbl.BackgroundTransparency = 0.25
	lbl.TextColor3 = Color3.fromRGB(240, 244, 255)
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 13
	lbl.Text = "FPS: -- | Ping: --ms"
	lbl.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = lbl
	gui.Parent = TRex.Services.CoreGui
	FPSHudGui = gui
	FPSHudLabel = lbl
end

function Optimizer.restoreAll()
	Optimizer.apply3DRender(false)
	Optimizer.applyLowGraphics(false)
	Optimizer.applyHideGameUI(false)
	Optimizer.applyHideTreadmill(false)
	Optimizer.applyFPSPingHUD(false)
	local capFn = TRex.resolveGlobalFunc("setfpscap")
	if capFn then
		pcall(capFn, 0)
	end
end

function Optimizer.init()
	TRex.registerCleanupHook(Optimizer.restoreAll)
	local pGui = TRex.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	if pGui then
		TRex.connectSignal(pGui.ChildAdded, function(child)
			if TRex.Config.HideGameUI and child:IsA("ScreenGui") and not child.Name:match("^TRexThaiCleanUI_") then
				HiddenGuis[child] = child.Enabled
				child.Enabled = false
			end
		end)
	end
	TRex.connectSignal(RunService.RenderStepped, function()
		if TRex.Config.ShowFPSPingHUD and FPSHudLabel then
			FrameCount = FrameCount + 1
			local now = os.clock()
			if now - LastFpsTime >= 0.5 then
				local fps = math.floor(FrameCount / (now - LastFpsTime))
				local pingMs = math.floor((TRex.Core and TRex.Core.getPing and TRex.Core.getPing() or 0) * 1000)
				FPSHudLabel.Text = ("FPS: %d | Ping: %dms"):format(fps, pingMs)
				FrameCount = 0
				LastFpsTime = now
			end
		end
	end)
	Optimizer.applyFPSCap()
	if TRex.Config.LowGraphics then
		Optimizer.applyLowGraphics(true)
	end
	if TRex.Config.HideGameUI then
		Optimizer.applyHideGameUI(true)
	end
	if TRex.Config.HideTreadmill then
		Optimizer.applyHideTreadmill(true)
	end
	if TRex.Config.ShowFPSPingHUD then
		Optimizer.applyFPSPingHUD(true)
	end
end

function Optimizer.startLoop()
	task.spawn(function()
		while TRex.IsRunning do
			if TRex.Config.Disable3DRender then
				local now = os.clock()
				if now - LastWakeAt >= 180 then
					Optimizer.apply3DRender(false)
					task.wait(2)
					LastWakeAt = os.clock()
				end
				if TRex.IsRunning and TRex.Config.Disable3DRender then
					Optimizer.apply3DRender(true)
				end
			end
			task.wait(1)
		end
	end)
end

function Optimizer.buildUI(ui)
	local tab = ui.addTab("optimizer", "tab.optimizer")

	local optSec = tab:addSection("sec.optimizer")
	optSec:addToggle({
		key = "Disable3DRender",
		label = "opt.no3d",
		desc = "desc.no3d",
		onChanged = function(enabled)
			Optimizer.apply3DRender(enabled)
		end,
	})
	optSec:addToggle({
		key = "LowPowerMode",
		label = "opt.low_power",
		onChanged = function()
			Optimizer.applyFPSCap()
		end,
	})
	optSec:addToggle({
		key = "FPSCapEnabled",
		label = "opt.fps_cap_enable",
		onChanged = function()
			Optimizer.applyFPSCap()
		end,
	})
	optSec:addNumericInput({
		key = "FPSCapValue",
		label = "opt.fps_cap_value",
		min = 10,
		max = 360,
		integer = true,
		onChanged = function()
			Optimizer.applyFPSCap()
		end,
	})
	optSec:addToggle({
		key = "LowGraphics",
		label = "opt.low_graphics",
		onChanged = function(enabled)
			Optimizer.applyLowGraphics(enabled)
		end,
	})
	optSec:addToggle({
		key = "HideGameUI",
		label = "opt.hide_ui",
		onChanged = function(enabled)
			Optimizer.applyHideGameUI(enabled)
		end,
	})
	optSec:addToggle({
		key = "HideTreadmill",
		label = "opt.hide_tread",
		onChanged = function(enabled)
			Optimizer.applyHideTreadmill(enabled)
		end,
	})
	optSec:addToggle({
		key = "ShowFPSPingHUD",
		label = "opt.fps_ping_hud",
		onChanged = function(enabled)
			Optimizer.applyFPSPingHUD(enabled)
		end,
	})
end

-- ============================================================================
-- [Bootstrap & Entrypoint]
-- ============================================================================
TRex.registerEmbeddedLang({
	["th"] = TRex.Services.HttpService:JSONDecode([===[{
  "ui.title": "ทีเร็กซ์ ฮับ • เกม 01",
  "ui.profile_badge": "โปรไฟล์: {name}",
  "ui.close_window": "ปิดหน้าต่าง",
  "ui.hide_menu": "ซ่อนเมนู",
  "ui.open_menu": "เปิดเมนู",
  "status.ready": "สถานะระบบ: พร้อมทำงาน • ไม่มีความขัดแย้งของฟังก์ชัน",
  "badge.idle": "รอ / พัก",
  "badge.active": "เปิดใช้งาน",
  "badge.confirmed": "ยืนยันแล้ว",
  "msg.none": "ไม่มี",
  "msg.notice": "แจ้งเตือน",
  "msg.invalid_number": "ตัวเลขที่กรอกใช้ไม่ได้ จึงใช้ค่าเดิม",
  "msg.press_key": "กดปุ่มใหม่ • Esc เพื่อยกเลิก",
  "msg.stopped_all": "ปิดการทำงานทุกฟังก์ชันแล้ว",
  "msg.reset_done": "คืนค่ามาตรฐานเรียบร้อยแล้ว",
  "msg.lang_changed": "เปลี่ยนภาษาเรียบร้อยแล้ว",
  "msg.profile_placeholder": "ตั้งชื่อโปรไฟล์ใหม่",
  "msg.profile_loaded": "โหลดโปรไฟล์ {name} แล้ว",
  "msg.profile_saved": "บันทึกโปรไฟล์ {name} แล้ว",
  "msg.io_unavailable": "สภาพแวดล้อมนี้ไม่รองรับการบันทึกไฟล์",
  "msg.hop_fetch_failed": "ดึงรายการเซิร์ฟเวอร์ไม่สำเร็จ",
  "msg.hop_no_server": "ไม่พบเซิร์ฟเวอร์ที่ว่าง",
  "msg.hopping": "กำลังย้ายเซิร์ฟเวอร์...",
  "msg.job_copied": "คัดลอกรหัสเซิร์ฟเวอร์แล้ว",
  "msg.webhook_placeholder": "วางลิงก์เว็บฮุกดิสคอร์ดที่นี่",
  "tab.farm": "ฟาร์มและสัตว์เลี้ยง",
  "tab.events": "กิจกรรมและมินิเกม",
  "tab.combat": "เคลื่อนที่และต่อสู้",
  "tab.server": "เซิร์ฟเวอร์",
  "tab.render": "แสดงผลและมองทะลุ",
  "tab.optimizer": "เพิ่มประสิทธิภาพ",
  "tab.profiles": "โปรไฟล์",
  "tab.settings": "ตั้งค่า",
  "sec.steal": "ระบบขโมยไข่อัตโนมัติ",
  "sec.treadmill": "สายพานวิ่งอัตโนมัติ",
  "sec.pets_fusery": "จัดการคอก ฟักไข่ และผสมสัตว์เลี้ยง",
  "sec.butterfly": "กิจกรรมผีเสื้อและวิญญาณนำทาง",
  "sec.minigames": "มินิเกมและรางวัล",
  "sec.movement": "การเคลื่อนที่และวาร์ป",
  "sec.combat": "การต่อสู้และป้องกันหลุด",
  "sec.server_hop": "ย้ายเซิร์ฟเวอร์อัตโนมัติ",
  "sec.webhook": "แจ้งเตือนดิสคอร์ด",
  "sec.esp": "มองทะลุและจุดสังเกต",
  "sec.optimizer": "ลดแล็กและประหยัดทรัพยากร",
  "sec.profile_manage": "จัดการโปรไฟล์การตั้งค่า",
  "sec.appearance": "หน้าตาเมนูและภาษา",
  "sec.hotkeys": "ปุ่มลัด",
  "sec.system_actions": "คำสั่งระบบ",
  "opt.auto_steal": "ขโมยไข่อัตโนมัติ",
  "opt.steal_go_mode": "วิธีเคลื่อนที่ขาไป",
  "opt.steal_return_mode": "วิธีเคลื่อนที่ขากลับ",
  "opt.steal_sort": "จัดลำดับเลือกไข่",
  "opt.auto_buy_trail": "ซื้อทางเดิน (Trail) อัตโนมัติ",
  "opt.auto_upgrade_base": "อัปเกรดฐานอัตโนมัติ",
  "opt.fuse_max_rarity": "ระดับสูงสุดที่ผสม",
  "opt.fuse_skip_mutated": "ข้ามสัตว์กลายพันธุ์เมื่อผสม",
  "opt.auto_sell_eggs": "ขายไข่อัตโนมัติ (เมื่อเต็ม)",
  "opt.auto_trade_butterfly": "แลกผีเสื้ออัตโนมัติ",
  "opt.auto_craft_essence": "คราฟต์ Essence อัตโนมัติ",
  "opt.other_base_egg_esp": "ESP ไข่ฐานคนอื่น",
  "opt.fps_ping_hud": "แสดงแถบ FPS / Ping",
  "desc.auto_steal": "ค้นหาไข่ตามระดับความแรร์และพากลับเขตปลอดภัย",
  "opt.steal_rarity": "ระดับไข่ขั้นต่ำ",
  "opt.safe_crossing": "ข้ามเขตแดนแบบปลอดภัย",
  "opt.auto_treadmill": "วิ่งสายพานอัตโนมัติ",
  "opt.auto_treadmill_tier": "อัปเกรดระดับสายพานอัตโนมัติ",
  "opt.auto_place_egg": "วางไข่ลงคอกอัตโนมัติ",
  "opt.auto_hatch": "ฟักไข่อัตโนมัติ",
  "opt.auto_fusery": "ผสมสัตว์เลี้ยงอัตโนมัติ",
  "opt.auto_mutate": "ใช้น้ำยากลายพันธุ์อัตโนมัติ",
  "opt.wear_best": "สวมสัตว์เลี้ยงที่ดีที่สุด",
  "opt.auto_sell": "ขายสัตว์เลี้ยงอัตโนมัติ",
  "opt.auto_butterfly": "จับผีเสื้ออัตโนมัติ",
  "opt.auto_claim_net": "รับตาข่ายอัตโนมัติ",
  "opt.butterfly_priority": "ลำดับความสำคัญผีเสื้อ",
  "opt.butterfly_speed": "ความเร็วบินจับผีเสื้อ",
  "opt.auto_wisp": "ทำเควสต์วิญญาณนำทางอัตโนมัติ",
  "opt.auto_admin_abuse": "เข้าร่วมกิจกรรมแอดมินอัตโนมัติ",
  "opt.auto_fishing": "ตกปลาอัตโนมัติ",
  "opt.auto_star": "เก็บดาวตกอัตโนมัติ",
  "opt.auto_alien": "ทำกิจกรรมทะเลสาบเอเลี่ยน",
  "opt.auto_banjo": "เก็บกิจกรรมแบนโจคริกเก็ต",
  "opt.auto_away": "รับรายได้ออฟไลน์อัตโนมัติ",
  "opt.auto_codex": "รับรางวัลสารานุกรมทั้งหมด",
  "opt.fast_tween": "เคลื่อนที่แบบทวีนความเร็วสูง",
  "opt.tween_speed": "ความเร็วทวีน",
  "opt.velocity_glide": "ลอยตัวด้วยความเร็วคงที่",
  "opt.ragdoll_tp": "วาร์ปหลบสถานะล้ม",
  "opt.custom_speed": "กำหนดความเร็ววิ่งและกระโดดเอง",
  "opt.walk_speed": "ความเร็วในการวิ่ง",
  "opt.jump_power": "พลังกระโดด",
  "opt.auto_bat": "หวดไม้เบสบอลอัตโนมัติ",
  "opt.bat_predict": "คำนวณระยะชดเชยการตี",
  "opt.anti_afk": "ป้องกันหลุดเมื่อไม่อยู่หน้าจอ",
  "opt.auto_hop": "ย้ายเซิร์ฟเวอร์อัตโนมัติ",
  "opt.hop_mode": "โหมดเลือกเซิร์ฟเวอร์",
  "opt.hop_condition": "เงื่อนไขการย้ายเซิร์ฟเวอร์",
  "opt.webhook_enabled": "เปิดแจ้งเตือนผ่านเว็บฮุก",
  "opt.webhook_url": "ลิงก์เว็บฮุก",
  "opt.player_esp": "มองทะลุผู้เล่น",
  "opt.player_tracker": "เส้นนำสายตาผู้เล่น",
  "opt.guard_esp": "มองทะลุการ์ดผู้พิทักษ์",
  "opt.egg_esp": "มองทะลุไข่ในสนาม",
  "opt.own_egg_esp": "มองทะลุไข่ในคอกตัวเอง",
  "opt.reveal_egg": "แสดงข้อมูลไข่จริง",
  "opt.safe_marker": "แสดงเส้นเขตปลอดภัย",
  "opt.no3d": "ปิดการเรนเดอร์ 3 มิติ",
  "desc.no3d": "ปลุกการเรนเดอร์อัตโนมัติทุก 180 วินาทีเพื่อป้องกันค้าง",
  "opt.low_power": "โหมดประหยัดพลังงาน 40 เฟรม",
  "opt.fps_cap_enable": "เปิดจำกัดเฟรมเรต",
  "opt.fps_cap_value": "จำนวนเฟรมเรตสูงสุด",
  "opt.low_graphics": "บังคับกราฟิกต่ำสุดและปิดเงา",
  "opt.hide_ui": "ซ่อนหน้าต่างเกม",
  "opt.hide_tread": "ซ่อนโมเดลสายพานวิ่ง",
  "opt.profile_name": "ชื่อโปรไฟล์",
  "opt.select_profile": "เลือกโปรไฟล์",
  "opt.language": "ภาษา",
  "opt.theme": "ธีมสีเมนู",
  "opt.font": "รูปแบบตัวอักษร",
  "opt.font_size": "ขนาดตัวอักษร",
  "opt.gui_scale": "ขนาดเมนู %",
  "opt.bg_transparency": "ความจางพื้นหลัง",
  "opt.bg_blur": "เบลอฉากหลังเมื่อเปิดเมนู",
  "opt.toggle_key": "ปุ่มเปิดปิดเมนู",
  "opt.panic_key": "ปุ่มหยุดฉุกเฉิน",
  "btn.warp_safe": "วาร์ปกลับเขตปลอดภัย",
  "btn.warp_rift": "วาร์ปไปแท่นริฟต์",
  "btn.hop_now": "ย้ายเซิร์ฟเวอร์ทันที",
  "btn.rejoin": "เข้าเซิร์ฟเวอร์เดิมใหม่",
  "btn.copy_job": "คัดลอกรหัสเซิร์ฟเวอร์",
  "btn.save_profile": "บันทึกโปรไฟล์",
  "btn.stop_all": "ปิดทุกค่าที่เปิดทั้งหมด",
  "btn.reset_defaults": "คืนค่ามาตรฐาน",
  "btn.unload": "หยุดและนำเมนูออก"
}]===]),
	["en-us"] = TRex.Services.HttpService:JSONDecode([===[{
  "ui.title": "T-Rex Hub • Game 01",
  "ui.profile_badge": "Profile: {name}",
  "ui.close_window": "Close",
  "ui.hide_menu": "Hide Menu",
  "ui.open_menu": "Open Menu",
  "status.ready": "System Ready • No feature conflicts",
  "badge.idle": "Idle",
  "badge.active": "Active",
  "badge.confirmed": "Confirmed",
  "msg.none": "None",
  "msg.notice": "Notice",
  "msg.invalid_number": "Invalid number, keeping previous value",
  "msg.press_key": "Press a key • Esc to cancel",
  "msg.stopped_all": "Disabled all active features",
  "msg.reset_done": "Restored default settings",
  "msg.lang_changed": "Language updated",
  "msg.profile_placeholder": "New profile name",
  "msg.profile_loaded": "Loaded profile {name}",
  "msg.profile_saved": "Saved profile {name}",
  "msg.io_unavailable": "File I/O is unavailable in this environment",
  "msg.hop_fetch_failed": "Failed to fetch server list",
  "msg.hop_no_server": "No available server found",
  "msg.hopping": "Hopping to new server...",
  "msg.job_copied": "Copied JobId to clipboard",
  "msg.webhook_placeholder": "Paste Discord Webhook URL",
  "tab.farm": "Farm & Pets",
  "tab.events": "Events & Minigames",
  "tab.combat": "Movement & Combat",
  "tab.server": "Server",
  "tab.render": "Render & ESP",
  "tab.optimizer": "Optimizer",
  "tab.profiles": "Profiles",
  "tab.settings": "Settings",
  "sec.steal": "Auto Steal Eggs",
  "sec.treadmill": "Auto Treadmill",
  "sec.pets_fusery": "Pen, Hatch & Fusery",
  "sec.butterfly": "Butterfly Bloom & Wisp",
  "sec.minigames": "Minigames & Rewards",
  "sec.movement": "Movement & Warps",
  "sec.combat": "Combat & Anti-AFK",
  "sec.server_hop": "Auto Server Hop",
  "sec.webhook": "Discord Webhook",
  "sec.esp": "ESP & Markers",
  "sec.optimizer": "Performance Optimizer",
  "sec.profile_manage": "Profile Management",
  "sec.appearance": "Appearance & Language",
  "sec.hotkeys": "Hotkeys",
  "sec.system_actions": "System Actions",
  "opt.auto_steal": "Auto Steal Eggs",
  "opt.steal_go_mode": "Steal Go Mode",
  "opt.steal_return_mode": "Steal Return Mode",
  "opt.steal_sort": "Steal Priority",
  "opt.auto_buy_trail": "Auto Buy Trail",
  "opt.auto_upgrade_base": "Auto Upgrade Base",
  "opt.fuse_max_rarity": "Max Fuse Rarity",
  "opt.fuse_skip_mutated": "Skip Mutated Pets",
  "opt.auto_sell_eggs": "Auto Sell Eggs (Near Full)",
  "opt.auto_trade_butterfly": "Auto Trade Butterflies",
  "opt.auto_craft_essence": "Auto Craft Essence",
  "opt.other_base_egg_esp": "Other Base Egg ESP",
  "opt.fps_ping_hud": "Show FPS / Ping HUD",
  "desc.auto_steal": "Finds eggs matching rarity filter and returns to safe zone",
  "opt.steal_rarity": "Minimum Egg Rarity",
  "opt.safe_crossing": "Safe Boundary Crossing",
  "opt.auto_treadmill": "Auto Treadmill",
  "opt.auto_treadmill_tier": "Auto Upgrade Treadmill Tier",
  "opt.auto_place_egg": "Auto Place Egg",
  "opt.auto_hatch": "Auto Hatch Eggs",
  "opt.auto_fusery": "Auto Fusery",
  "opt.auto_mutate": "Auto Use Mutation Consumable",
  "opt.wear_best": "Wear Best Pet",
  "opt.auto_sell": "Auto Sell Pets",
  "opt.auto_butterfly": "Auto Catch Butterflies",
  "opt.auto_claim_net": "Auto Claim Net",
  "opt.butterfly_priority": "Butterfly Priority",
  "opt.butterfly_speed": "Butterfly Speed",
  "opt.auto_wisp": "Auto Wisp Quest",
  "opt.auto_admin_abuse": "Auto Admin Abuse Events",
  "opt.auto_fishing": "Auto Fishing",
  "opt.auto_star": "Auto Catch Shooting Star",
  "opt.auto_alien": "Auto Alien Lagoon",
  "opt.auto_banjo": "Auto Banjo Cricket",
  "opt.auto_away": "Auto Collect Away Earnings",
  "opt.auto_codex": "Auto Redeem Codex",
  "opt.fast_tween": "Fast Tween",
  "opt.tween_speed": "Tween Speed",
  "opt.velocity_glide": "Velocity Glide",
  "opt.ragdoll_tp": "Ragdoll TP",
  "opt.custom_speed": "Custom WalkSpeed & JumpPower",
  "opt.walk_speed": "WalkSpeed",
  "opt.jump_power": "JumpPower",
  "opt.auto_bat": "Auto Bat Swing",
  "opt.bat_predict": "Ping Aim Prediction",
  "opt.anti_afk": "Anti-AFK",
  "opt.auto_hop": "Auto Hop",
  "opt.hop_mode": "Hop Mode",
  "opt.hop_condition": "Hop Condition",
  "opt.webhook_enabled": "Enable Webhook",
  "opt.webhook_url": "Webhook URL",
  "opt.player_esp": "Player ESP",
  "opt.player_tracker": "Player Tracker Lines",
  "opt.guard_esp": "Guard ESP",
  "opt.egg_esp": "Field Egg ESP",
  "opt.own_egg_esp": "Own Base Egg ESP",
  "opt.reveal_egg": "Reveal Real Egg Content",
  "opt.safe_marker": "Safe Zone Marker",
  "opt.no3d": "Disable 3D Render",
  "desc.no3d": "Wakes 3D rendering for 2s every 180s to prevent freeze",
  "opt.low_power": "Low-Power 40 FPS Mode",
  "opt.fps_cap_enable": "Enable FPS Cap",
  "opt.fps_cap_value": "Max FPS",
  "opt.low_graphics": "Force Lowest Graphics",
  "opt.hide_ui": "Hide Game UI",
  "opt.hide_tread": "Hide Treadmill Mesh",
  "opt.profile_name": "Profile Name",
  "opt.select_profile": "Select Profile",
  "opt.language": "Language",
  "opt.theme": "Theme",
  "opt.font": "Font",
  "opt.font_size": "Font Size",
  "opt.gui_scale": "Menu Scale %",
  "opt.bg_transparency": "Background Transparency",
  "opt.bg_blur": "Background Blur",
  "opt.toggle_key": "Toggle Menu Key",
  "opt.panic_key": "Panic Stop Key",
  "btn.warp_safe": "Warp to Safe Zone",
  "btn.warp_rift": "Warp to Rift Machine",
  "btn.hop_now": "Hop Server Now",
  "btn.rejoin": "Rejoin Server",
  "btn.copy_job": "Copy JobId",
  "btn.save_profile": "Save Profile",
  "btn.stop_all": "Disable All Features",
  "btn.reset_defaults": "Reset Defaults",
  "btn.unload": "Stop & Unload Menu"
}]===]),
	["vi"] = TRex.Services.HttpService:JSONDecode([===[{
  "ui.title": "T-Rex Hub • Game 01",
  "ui.profile_badge": "Hồ sơ: {name}",
  "ui.close_window": "Đóng",
  "ui.hide_menu": "Ẩn Menu",
  "ui.open_menu": "Mở Menu",
  "status.ready": "Hệ thống sẵn sàng • Không xung đột",
  "badge.idle": "Chờ",
  "badge.active": "Đang bật",
  "badge.confirmed": "Đã xác nhận",
  "msg.none": "Không có",
  "msg.notice": "Thông báo",
  "msg.invalid_number": "Số không hợp lệ, giữ nguyên giá trị cũ",
  "msg.press_key": "Nhấn phím mới • Esc để hủy",
  "msg.stopped_all": "Đã tắt tất cả chức năng",
  "msg.reset_done": "Đã khôi phục cài đặt mặc định",
  "msg.lang_changed": "Đã đổi ngôn ngữ",
  "msg.profile_placeholder": "Tên hồ sơ mới",
  "msg.profile_loaded": "Đã tải hồ sơ {name}",
  "msg.profile_saved": "Đã lưu hồ sơ {name}",
  "msg.io_unavailable": "Môi trường không hỗ trợ lưu tệp",
  "msg.hop_fetch_failed": "Không thể lấy danh sách máy chủ",
  "msg.hop_no_server": "Không tìm thấy máy chủ trống",
  "msg.hopping": "Đang chuyển máy chủ...",
  "msg.job_copied": "Đã sao chép JobId",
  "msg.webhook_placeholder": "Dán liên kết Discord Webhook",
  "tab.farm": "Farm & Thú cưng",
  "tab.events": "Sự kiện & Minigame",
  "tab.combat": "Di chuyển & Chiến đấu",
  "tab.server": "Máy chủ",
  "tab.render": "Hiển thị & ESP",
  "tab.optimizer": "Tối ưu hóa",
  "tab.profiles": "Hồ sơ",
  "tab.settings": "Cài đặt",
  "sec.steal": "Tự động trộm trứng",
  "sec.treadmill": "Máy chạy bộ tự động",
  "sec.pets_fusery": "Chuồng, Ấp & Hợp nhất",
  "sec.butterfly": "Sự kiện Bướm & Wisp",
  "sec.minigames": "Minigame & Phần thưởng",
  "sec.movement": "Di chuyển & Dịch chuyển",
  "sec.combat": "Chiến đấu & Chống AFK",
  "sec.server_hop": "Tự động đổi máy chủ",
  "sec.webhook": "Thông báo Discord",
  "sec.esp": "ESP & Đánh dấu",
  "sec.optimizer": "Giảm lag & Tối ưu",
  "sec.profile_manage": "Quản lý hồ sơ",
  "sec.appearance": "Giao diện & Ngôn ngữ",
  "sec.hotkeys": "Phím tắt",
  "sec.system_actions": "Thao tác hệ thống",
  "opt.auto_steal": "Tự động trộm trứng",
  "opt.steal_go_mode": "Chế độ đi lấy",
  "opt.steal_return_mode": "Chế độ quay về",
  "opt.steal_sort": "Ưu tiên chọn trứng",
  "opt.auto_buy_trail": "Tự động mua Trail",
  "opt.auto_upgrade_base": "Tự động nâng cấp căn cứ",
  "opt.fuse_max_rarity": "Độ hiếm tối đa để ghép",
  "opt.fuse_skip_mutated": "Bỏ qua thú đột biến",
  "opt.auto_sell_eggs": "Tự động bán trứng (gần đầy)",
  "opt.auto_trade_butterfly": "Tự động đổi bướm",
  "opt.auto_craft_essence": "Tự động chế tạo Essence",
  "opt.other_base_egg_esp": "ESP trứng căn cứ khác",
  "opt.fps_ping_hud": "Hiện thanh FPS / Ping",
  "desc.auto_steal": "Tìm trứng theo độ hiếm và đưa về vùng an toàn",
  "opt.steal_rarity": "Độ hiếm tối thiểu",
  "opt.safe_crossing": "Vượt ranh giới an toàn",
  "opt.auto_treadmill": "Tự động chạy máy",
  "opt.auto_treadmill_tier": "Tự động nâng cấp máy chạy",
  "opt.auto_place_egg": "Tự động đặt trứng",
  "opt.auto_hatch": "Tự động ấp trứng",
  "opt.auto_fusery": "Tự động hợp nhất thú",
  "opt.auto_mutate": "Tự động dùng thuốc đột biến",
  "opt.wear_best": "Trang bị thú mạnh nhất",
  "opt.auto_sell": "Tự động bán thú",
  "opt.auto_butterfly": "Tự động bắt bướm",
  "opt.auto_claim_net": "Tự động nhận vợt",
  "opt.butterfly_priority": "Ưu tiên bắt bướm",
  "opt.butterfly_speed": "Tốc độ bắt bướm",
  "opt.auto_wisp": "Tự động nhiệm vụ Wisp",
  "opt.auto_admin_abuse": "Tự động sự kiện Admin",
  "opt.auto_fishing": "Tự động câu cá",
  "opt.auto_star": "Tự động bắt sao băng",
  "opt.auto_alien": "Tự động hồ Alien",
  "opt.auto_banjo": "Tự động Banjo Cricket",
  "opt.auto_away": "Tự động nhận thưởng ngoại tuyến",
  "opt.auto_codex": "Tự động nhận Codex",
  "opt.fast_tween": "Tween tốc độ cao",
  "opt.tween_speed": "Tốc độ Tween",
  "opt.velocity_glide": "Lướt vận tốc",
  "opt.ragdoll_tp": "Dịch chuyển khi ngã",
  "opt.custom_speed": "Tùy chỉnh tốc độ chạy & nhảy",
  "opt.walk_speed": "Tốc độ chạy",
  "opt.jump_power": "Lực nhảy",
  "opt.auto_bat": "Tự động đánh gậy",
  "opt.bat_predict": "Dự đoán Ping khi đánh",
  "opt.anti_afk": "Chống AFK",
  "opt.auto_hop": "Tự động đổi máy chủ",
  "opt.hop_mode": "Chế độ chọn máy chủ",
  "opt.hop_condition": "Điều kiện đổi máy chủ",
  "opt.webhook_enabled": "Bật Webhook",
  "opt.webhook_url": "Liên kết Webhook",
  "opt.player_esp": "ESP Người chơi",
  "opt.player_tracker": "Đường kẻ theo dõi",
  "opt.guard_esp": "ESP Bảo vệ",
  "opt.egg_esp": "ESP Trứng ngoài sân",
  "opt.own_egg_esp": "ESP Trứng trong chuồng",
  "opt.reveal_egg": "Hiện thông tin trứng thật",
  "opt.safe_marker": "Đánh dấu vùng an toàn",
  "opt.no3d": "Tắt kết xuất 3D",
  "desc.no3d": "Tự động bật lại 3D 2 giây mỗi 180 giây để tránh treo",
  "opt.low_power": "Chế độ tiết kiệm 40 FPS",
  "opt.fps_cap_enable": "Giới hạn FPS",
  "opt.fps_cap_value": "FPS tối đa",
  "opt.low_graphics": "Đồ họa thấp nhất & Tắt bóng",
  "opt.hide_ui": "Ẩn giao diện game",
  "opt.hide_tread": "Ẩn mô hình máy chạy",
  "opt.profile_name": "Tên hồ sơ",
  "opt.select_profile": "Chọn hồ sơ",
  "opt.language": "Ngôn ngữ",
  "opt.theme": "Chủ đề màu",
  "opt.font": "Phông chữ",
  "opt.font_size": "Cỡ chữ",
  "opt.gui_scale": "Tỷ lệ Menu %",
  "opt.bg_transparency": "Độ mờ nền",
  "opt.bg_blur": "Làm mờ nền khi mở",
  "opt.toggle_key": "Phím ẩn/hiện Menu",
  "opt.panic_key": "Phím dừng khẩn cấp",
  "btn.warp_safe": "Về vùng an toàn",
  "btn.warp_rift": "Đến máy Rift",
  "btn.hop_now": "Đổi máy chủ ngay",
  "btn.rejoin": "Vào lại máy chủ",
  "btn.copy_job": "Sao chép JobId",
  "btn.save_profile": "Lưu hồ sơ",
  "btn.stop_all": "Tắt tất cả chức năng",
  "btn.reset_defaults": "Khôi phục mặc định",
  "btn.unload": "Dừng & Đóng Menu"
}]===]),
	["zh"] = TRex.Services.HttpService:JSONDecode([===[{
  "ui.title": "T-Rex 中心 • 游戏 01",
  "ui.profile_badge": "配置: {name}",
  "ui.close_window": "关闭",
  "ui.hide_menu": "隐藏菜单",
  "ui.open_menu": "打开菜单",
  "status.ready": "系统就绪 • 无功能冲突",
  "badge.idle": "待机",
  "badge.active": "已开启",
  "badge.confirmed": "已确认",
  "msg.none": "无",
  "msg.notice": "提示",
  "msg.invalid_number": "数字无效，保留原值",
  "msg.press_key": "请按键 • Esc 取消",
  "msg.stopped_all": "已关闭所有功能",
  "msg.reset_done": "已恢复默认设置",
  "msg.lang_changed": "语言已切换",
  "msg.profile_placeholder": "输入新配置名称",
  "msg.profile_loaded": "已加载配置 {name}",
  "msg.profile_saved": "已保存配置 {name}",
  "msg.io_unavailable": "当前环境不支持文件读写",
  "msg.hop_fetch_failed": "获取服务器列表失败",
  "msg.hop_no_server": "未找到可用服务器",
  "msg.hopping": "正在切换服务器...",
  "msg.job_copied": "已复制服务器 ID",
  "msg.webhook_placeholder": "粘贴 Discord Webhook 链接",
  "tab.farm": "挂机与宠物",
  "tab.events": "活动与小游戏",
  "tab.combat": "移动与战斗",
  "tab.server": "服务器",
  "tab.render": "渲染与透视",
  "tab.optimizer": "性能优化",
  "tab.profiles": "配置文件",
  "tab.settings": "设置",
  "sec.steal": "自动偷蛋",
  "sec.treadmill": "自动跑步机",
  "sec.pets_fusery": "孵蛋与融合",
  "sec.butterfly": "蝴蝶与精灵任务",
  "sec.minigames": "小游戏与奖励",
  "sec.movement": "移动与传送",
  "sec.combat": "战斗与防挂机",
  "sec.server_hop": "自动换服",
  "sec.webhook": "Discord 通知",
  "sec.esp": "透视与标记",
  "sec.optimizer": "降帧与省资源",
  "sec.profile_manage": "配置管理",
  "sec.appearance": "外观与语言",
  "sec.hotkeys": "快捷键",
  "sec.system_actions": "系统操作",
  "opt.auto_steal": "自动偷蛋",
  "opt.steal_go_mode": "去程移动方式",
  "opt.steal_return_mode": "返程移动方式",
  "opt.steal_sort": "偷蛋优先级",
  "opt.auto_buy_trail": "自动购买拖尾",
  "opt.auto_upgrade_base": "自动升级基地",
  "opt.fuse_max_rarity": "融合最高稀有度",
  "opt.fuse_skip_mutated": "融合跳过变异宠物",
  "opt.auto_sell_eggs": "自动卖蛋（满包时）",
  "opt.auto_trade_butterfly": "自动升级蝴蝶",
  "opt.auto_craft_essence": "自动制作精华",
  "opt.other_base_egg_esp": "他人基地蛋透视",
  "opt.fps_ping_hud": "显示 FPS / Ping 面板",
  "desc.auto_steal": "按稀有度筛选蛋并带回安全区",
  "opt.steal_rarity": "最低蛋稀有度",
  "opt.safe_crossing": "安全越界",
  "opt.auto_treadmill": "自动跑步机",
  "opt.auto_treadmill_tier": "自动升级跑步机",
  "opt.auto_place_egg": "自动放蛋",
  "opt.auto_hatch": "自动孵蛋",
  "opt.auto_fusery": "自动融合宠物",
  "opt.auto_mutate": "自动使用突变药水",
  "opt.wear_best": "装备最强宠物",
  "opt.auto_sell": "自动出售宠物",
  "opt.auto_butterfly": "自动抓蝴蝶",
  "opt.auto_claim_net": "自动领取捕虫网",
  "opt.butterfly_priority": "蝴蝶优先级",
  "opt.butterfly_speed": "抓蝴蝶速度",
  "opt.auto_wisp": "自动精灵任务",
  "opt.auto_admin_abuse": "自动管理员活动",
  "opt.auto_fishing": "自动钓鱼",
  "opt.auto_star": "自动接流星",
  "opt.auto_alien": "自动外星湖活动",
  "opt.auto_banjo": "自动班卓蟋蟀",
  "opt.auto_away": "自动领取离线收益",
  "opt.auto_codex": "自动领取图鉴奖励",
  "opt.fast_tween": "高速平滑移动",
  "opt.tween_speed": "移动速度",
  "opt.velocity_glide": "速度滑行",
  "opt.ragdoll_tp": "倒地传送",
  "opt.custom_speed": "自定义移速与跳跃",
  "opt.walk_speed": "移动速度",
  "opt.jump_power": "跳跃高度",
  "opt.auto_bat": "自动挥棒攻击",
  "opt.bat_predict": "延迟预判",
  "opt.anti_afk": "防挂机踢出",
  "opt.auto_hop": "自动换服",
  "opt.hop_mode": "选服模式",
  "opt.hop_condition": "换服条件",
  "opt.webhook_enabled": "启用 Webhook",
  "opt.webhook_url": "Webhook 链接",
  "opt.player_esp": "玩家透视",
  "opt.player_tracker": "玩家追踪线",
  "opt.guard_esp": "守卫透视",
  "opt.egg_esp": "场地蛋透视",
  "opt.own_egg_esp": "基地蛋透视",
  "opt.reveal_egg": "显示真实蛋信息",
  "opt.safe_marker": "安全区边界线",
  "opt.no3d": "关闭 3D 渲染",
  "desc.no3d": "每 180 秒唤醒渲染 2 秒以防卡死",
  "opt.low_power": "省电 40 帧模式",
  "opt.fps_cap_enable": "启用帧率上限",
  "opt.fps_cap_value": "最大帧率",
  "opt.low_graphics": "最低画质并关闭阴影",
  "opt.hide_ui": "隐藏游戏界面",
  "opt.hide_tread": "隐藏跑步机模型",
  "opt.profile_name": "配置名称",
  "opt.select_profile": "选择配置",
  "opt.language": "语言",
  "opt.theme": "界面主题",
  "opt.font": "字体",
  "opt.font_size": "字体大小",
  "opt.gui_scale": "菜单缩放 %",
  "opt.bg_transparency": "背景透明度",
  "opt.bg_blur": "打开时模糊背景",
  "opt.toggle_key": "菜单开关键",
  "opt.panic_key": "紧急停止键",
  "btn.warp_safe": "传送回安全区",
  "btn.warp_rift": "传送到裂隙机器",
  "btn.hop_now": "立即换服",
  "btn.rejoin": "重新加入当前服",
  "btn.copy_job": "复制服务器 ID",
  "btn.save_profile": "保存配置",
  "btn.stop_all": "关闭全部功能",
  "btn.reset_defaults": "恢复默认设置",
  "btn.unload": "停止并卸载菜单"
}]===]),
})

local PRESERVED_UI_TOGGLES = {
	BackgroundBlur = true,
	AntiAFK = true,
}

local function stopAllFeatures()
	for k, v in pairs(TRex.Config) do
		if type(v) == "boolean" and not PRESERVED_UI_TOGGLES[k] then
			TRex.Config[k] = false
		end
	end
	Combat.restoreCharacterStats()
	Farm.doffTreadmill()
	Render.clearAll()
	Optimizer.restoreAll()
	UI.setStatusBanner("ready", TRex.t("msg.stopped_all"))
	UI.refreshAll()
	TRex.saveConfig(TRex.CurrentProfileName)
end

TRex.runPreviousCleanup("Game01")
TRex.GlobalEnv.__TRexCleanup_Game01 = TRex.cleanup

TRex.loadConfig()
TRex.initLangPacks()

Core.init()
Events.init()
Combat.init()
Server.init()

UI.buildShell(stopAllFeatures)
Farm.buildUI(UI)
Events.buildUI(UI)
Combat.buildUI(UI)
Server.buildUI(UI)
Render.buildUI(UI)
Optimizer.buildUI(UI)
UI.buildSettingsAndProfileTabs()

Render.init()
Optimizer.init()

UI.refreshAll()
UI.selectTab("farm")

Farm.startLoop()
Events.startLoop()
Combat.startLoop()
Server.startLoop()
Optimizer.startLoop()

TRex.GlobalEnv.__TRexGame01API = {
	TRex = TRex,
	Config = TRex.Config,
	StopAll = stopAllFeatures,
	Cleanup = TRex.cleanup,
}
