-- T-RexProject/Games/Game01/Modules/06_render_esp.lua
-- Render, Visuals, ESP, Inventory Value Overlay & Draggable Farm HUD for Game01

local TRex = (_G :: any).TRex
local Services = TRex.Services
local Players = Services.Players
local RunService = Services.RunService
local Workspace = Services.Workspace
local CollectionService = Services.CollectionService
local CoreGui = Services.CoreGui
local TextService = game:GetService("TextService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local Core = TRex.Core

local Render = {}
TRex.Render = Render

local function getGuiRoot(): Instance
	local okGethui, hui = pcall(function()
		local fn = (getfenv(0) :: any).gethui or (_G :: any).gethui
		return type(fn) == "function" and fn() or nil
	end)
	if okGethui and typeof(hui) == "Instance" then
		return hui
	end
	return CoreGui
end

local function makeColorSeq(...)
	local args = { ... }
	local pts = {}
	for i = 1, #args, 4 do
		table.insert(pts, ColorSequenceKeypoint.new(args[i], Color3.fromRGB(args[i + 1], args[i + 2], args[i + 3])))
	end
	return ColorSequence.new(pts)
end

local COLOR_WHITE = Color3.new(1, 1, 1)
local COLOR_BLACK = Color3.new(0, 0, 0)
local SUFFIXES = { "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc" }

local function formatCompact(val: any): string
	local n = tonumber(val) or 0
	local idx = 0
	while math.abs(n) >= 1000 and idx < #SUFFIXES do
		n /= 1000
		idx += 1
	end
	if idx == 0 then
		return string.format("%.0f", n)
	end
	local s = string.format("%.2f", n):gsub("0+$", ""):gsub("%.$", "")
	return s .. (SUFFIXES[idx] or "")
end

local function formatClockShort(sec: number): string
	local s = math.max(0, math.floor(sec))
	if s < 60 then
		return tostring(s) .. "s"
	elseif s < 3600 then
		return string.format("%dm %ds", math.floor(s / 60), s % 60)
	end
	return string.format("%dh %dm", math.floor(s / 3600), math.floor((s % 3600) / 60))
end

local function makeTintPalette(c: Color3)
	return {
		t = ColorSequence.new({
			ColorSequenceKeypoint.new(0, c:Lerp(COLOR_WHITE, 0.5)),
			ColorSequenceKeypoint.new(0.4, c:Lerp(COLOR_WHITE, 0.1)),
			ColorSequenceKeypoint.new(1, c:Lerp(COLOR_BLACK, 0.25)),
		}),
		s = ColorSequence.new({
			ColorSequenceKeypoint.new(0, c:Lerp(COLOR_BLACK, 0.55)),
			ColorSequenceKeypoint.new(0.55, c:Lerp(COLOR_BLACK, 0.75)),
			ColorSequenceKeypoint.new(1, c:Lerp(COLOR_BLACK, 0.92)),
		}),
		o = c,
	}
end

local BLACK_STROKE = makeColorSeq(0, 8, 8, 8, 1, 8, 8, 8)
local DETAIL_PALETTE = {
	t = makeColorSeq(0, 255, 255, 255, 0.5, 222, 222, 222, 1, 255, 255, 255),
	s = BLACK_STROKE,
}
local NAME_PALETTE = {
	t = makeColorSeq(0, 255, 255, 255, 0.5, 222, 238, 255, 1, 255, 255, 255),
	s = BLACK_STROKE,
}
local SECRET_SEQ = makeColorSeq(
	0, 255, 255, 255,
	0.2, 206, 212, 224,
	0.42, 74, 80, 94,
	0.58, 42, 46, 56,
	0.78, 158, 166, 182,
	1, 250, 252, 255
)
local VALUE_PALETTE = makeTintPalette(Color3.fromRGB(77, 255, 122))
local DEFAULT_MUT_PALETTE = makeTintPalette(Color3.fromRGB(143, 227, 255))
local PLAYER_TEXT_PALETTE = {
	t = makeColorSeq(0, 138, 255, 205, 0.5, 125, 225, 255, 1, 210, 135, 255),
	s = makeColorSeq(0, 7, 73, 66, 1, 35, 17, 79),
}
local GUARD_COLORS: { [string]: any } = {
	Sleeping = {
		t = makeColorSeq(0, 170, 255, 160, 0.45, 58, 255, 55, 1, 20, 109, 0),
		s = makeColorSeq(0, 10, 52, 6, 1, 3, 16, 0),
		o = Color3.fromRGB(58, 255, 55),
	},
	Waking = {
		t = makeColorSeq(0, 255, 198, 132, 0.4, 255, 146, 40, 1, 206, 92, 0),
		s = makeColorSeq(0, 112, 54, 0, 0.55, 56, 27, 0, 1, 18, 8, 0),
		o = Color3.fromRGB(255, 194, 112),
	},
	Chasing = {
		t = makeColorSeq(0, 255, 105, 105, 0.4, 255, 28, 40, 1, 184, 0, 18),
		s = makeColorSeq(0, 124, 0, 15, 0.55, 61, 0, 9, 1, 18, 0, 3),
		o = Color3.fromRGB(255, 128, 138),
	},
}
local MUTATION_PALETTES: { [string]: any } = {
	Golden = {
		t = makeColorSeq(0, 255, 231, 158, 0.4, 255, 196, 66, 1, 214, 142, 12),
		s = makeColorSeq(0, 122, 76, 0, 0.55, 62, 38, 0, 1, 20, 12, 0),
		o = Color3.fromRGB(255, 232, 152),
	},
	Silver = {
		t = makeColorSeq(0, 255, 255, 255, 0.45, 214, 222, 232, 1, 150, 160, 175),
		s = makeColorSeq(0, 60, 66, 78, 0.55, 30, 33, 40, 1, 10, 11, 14),
	},
	Rainbow = {
		t = makeColorSeq(0, 255, 107, 107, 0.2, 255, 179, 107, 0.4, 255, 240, 107, 0.6, 107, 255, 138, 0.8, 107, 200, 255, 1, 185, 107, 255),
		s = makeColorSeq(0, 20, 20, 30, 1, 8, 8, 12),
		r = 0,
	},
	Sakura = makeTintPalette(Color3.fromRGB(255, 158, 216)),
	GreatBloom = makeTintPalette(Color3.fromRGB(124, 255, 196)),
	Boss = makeTintPalette(Color3.fromRGB(255, 122, 122)),
	Fractured = makeTintPalette(Color3.fromRGB(255, 122, 122)),
	Monstrous = makeTintPalette(Color3.fromRGB(192, 139, 255)),
	Spectral = makeTintPalette(Color3.fromRGB(145, 230, 255)),
	Nitro = makeTintPalette(Color3.fromRGB(255, 170, 60)),
	Enchanted = makeTintPalette(Color3.fromRGB(196, 120, 255)),
	Abducted = makeTintPalette(Color3.fromRGB(110, 255, 190)),
	["Dark Matter"] = makeTintPalette(Color3.fromRGB(165, 95, 255)),
	Scrambled = makeTintPalette(Color3.fromRGB(255, 225, 120)),
}

local MUTATION_ALIAS: { [string]: string } = {
	Alien = "Abducted",
	DarkMatter = "Dark Matter",
	Boss = "Fractured",
}

local FONT_GOTHAM = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold)
local FONT_FREDOKA = Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Regular)
local FONT_BODY = Font.new("rbxassetid://12187365977", Enum.FontWeight.Bold)

local function getViewportHeight(): number
	local cam = Workspace.CurrentCamera
	return cam and cam.ViewportSize.Y or 1080
end

local function scaledTextSize(scaleMult: number): number
	return math.max(6, math.floor(math.clamp(getViewportHeight() * 0.014, 13, 19) * scaleMult))
end

local function scaledWidth(base: number, scaleMult: number): number
	return math.max(30, math.floor(base * scaleMult))
end

local function getWorldMaxDist(worldW: number): number
	local cam = Workspace.CurrentCamera
	if not cam then
		return math.huge
	end
	return worldW * cam.ViewportSize.Y / (40 * math.tan(math.rad(cam.FieldOfView) * 0.5))
end

local function buildSelectedSet(arr: any, defaultAll: boolean): { [string]: boolean }
	local out: { [string]: boolean } = {}
	if type(arr) == "table" then
		for _, v in ipairs(arr) do
			if type(v) == "string" and v ~= "" then
				out[v] = true
			end
		end
	end
	if defaultAll and next(out) == nil then
		return out
	end
	return out
end

local function disconnectList(conns: { RBXScriptConnection })
	for _, c in ipairs(conns) do
		pcall(function()
			c:Disconnect()
		end)
	end
	table.clear(conns)
end

local function createBillboardRoot(parentGui: Instance)
	local bb = Instance.new("BillboardGui")
	bb.AlwaysOnTop = true
	bb.LightInfluence = 0
	bb.MaxDistance = math.huge
	bb.ResetOnSpawn = false
	bb.Parent = parentGui

	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.BorderSizePixel = 0
	holder.Size = UDim2.fromScale(1, 1)
	holder.Parent = bb

	local list = Instance.new("UIListLayout")
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = holder

	return bb, holder
end

local function createGradientTextRow(parent: Instance, fontFace: Font, order: number, scaleH: number)
	local wrap = Instance.new("Frame")
	wrap.BackgroundTransparency = 1
	wrap.BorderSizePixel = 0
	wrap.Size = UDim2.fromScale(1, scaleH)
	wrap.LayoutOrder = order
	wrap.Parent = parent

	local sh = Instance.new("TextLabel")
	sh.BackgroundTransparency = 1
	sh.Size = UDim2.fromScale(1, 1)
	sh.ZIndex = 2
	sh.FontFace = fontFace
	sh.TextScaled = true
	sh.TextColor3 = COLOR_BLACK
	sh.TextTransparency = 0.1
	sh.Text = ""
	sh.Position = UDim2.fromOffset(1, 1)
	sh.Parent = wrap

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.ZIndex = 3
	lbl.FontFace = fontFace
	lbl.TextScaled = true
	lbl.TextColor3 = COLOR_WHITE
	lbl.Text = ""
	lbl.Parent = wrap

	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	stroke.LineJoinMode = Enum.LineJoinMode.Round
	stroke.Color = COLOR_WHITE
	stroke.Transparency = 0.05
	local okSized = pcall(function()
		(stroke :: any).StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
	end)
	stroke.Thickness = okSized and 0.05 or 1.2
	stroke.Parent = lbl

	local sg = Instance.new("UIGradient")
	sg.Rotation = 90
	sg.Parent = stroke

	local tg = Instance.new("UIGradient")
	tg.Rotation = 90
	tg.Parent = lbl

	return { h = wrap, sh = sh, l = lbl, sg = sg, tg = tg, p = nil :: any }
end

local function applyTextRow(row: any, text: string, palette: any)
	if row.l.Text ~= text then
		row.l.Text = text
		row.sh.Text = text
	end
	if row.p ~= palette and palette then
		row.p = palette
		row.tg.Color = palette.t
		row.tg.Rotation = palette.r or 90
		row.sg.Color = palette.s
	end
end

-- =====================================================================
-- 1) Asset / Egg Metadata Cache (matching Temp rarity & icon lookup)
-- =====================================================================
local AssetMetaCache: { [string]: any } = {}
local SnapshotCooldownUntil = 0

local function getEggAssetMeta(cat: string)
	if AssetMetaCache[cat] then
		return AssetMetaCache[cat]
	end
	local assetsMod = Core.Modules and Core.Modules.Assets
	local dir = type(assetsMod) == "table" and assetsMod.Directory or nil
	local entry = type(dir) == "table" and dir[cat] or nil
	local rarity = type(entry) == "table" and type(entry.Rarity) == "table" and entry.Rarity or nil
	local col = (rarity and typeof(rarity.Color) == "Color3") and rarity.Color or COLOR_WHITE
	local pal = makeTintPalette(col)
	local rGrad: any = rarity and rarity.RarityGradient
	if rarity and typeof(rGrad) ~= "Instance" then
		local assetsFolder = Services.ReplicatedStorage:FindFirstChild("Assets")
		local uiFolder = assetsFolder and assetsFolder:FindFirstChild("UI")
		local gradRoot = uiFolder and uiFolder:FindFirstChild("RarityGradients")
		local gradDir = gradRoot and gradRoot:FindFirstChild(tostring(rarity._id or rarity.DisplayName or ""))
		rGrad = gradDir and gradDir:FindFirstChild("RarityGradient")
	end
	if typeof(rGrad) == "Instance" and rGrad:IsA("UIGradient") then
		pal.t = rGrad.Color
		pal.r = rGrad.Rotation
	end
	local rarityName = rarity and tostring(rarity.DisplayName or rarity._id or "") or ""
	local rarityRank = rarity and tonumber(rarity.RarityNumber or rarity.Rank) or (Core.RARITY_RANK[rarityName] or 0)
	local isSecret = rarityName:upper() == "SECRET"
	local meta = {
		Rank = rarityRank,
		RarityName = rarityName,
		RarityPalette = isSecret and { t = SECRET_SEQ, s = pal.s, r = 90 } or pal,
		BaseColor = col,
		DisplayName = tostring((type(entry) == "table" and entry.DisplayName) or cat),
		Icon = type(entry) == "table" and ((type(entry.Egg) == "table" and entry.Egg.Icon) or entry.Icon) or nil,
		PetIcon = type(entry) == "table" and entry.Icon or nil,
		Entry = entry,
	}
	AssetMetaCache[cat] = meta
	return meta
end

local function readEggIcon(rec: any, preferPetIcon: boolean): string
	if not preferPetIcon then
		local okIcon, ic = pcall(function()
			local recMod = Core.Modules and Core.Modules.Rec
			return type(recMod) == "table" and type(recMod.EggIcon) == "function" and recMod.EggIcon(rec) or nil
		end)
		if okIcon and type(ic) == "string" and ic ~= "" then
			return ic
		end
	end
	local meta = getEggAssetMeta(tostring(rec.AssetCategory or rec.Category or ""))
	if preferPetIcon and type(meta.PetIcon) == "string" and meta.PetIcon ~= "" then
		return meta.PetIcon
	end
	return tostring(meta.Icon or meta.PetIcon or "")
end

local function parseMinRarityRank(val: any): number
	if type(val) == "number" then
		return val
	end
	local s = tostring(val or "Any")
	if s == "" or s == "Any" then
		return 0
	end
	local numPrefix = tonumber(s:match("^(%d+)%s*%-"))
	if numPrefix then
		return numPrefix
	end
	return Core.RARITY_RANK[s] or 0
end

local function extractFieldEggs(): { [string]: any }
	if type(Core.readFieldEggs) == "function" then
		local r = Core.readFieldEggs()
		if type(r) == "table" then
			return r
		end
	end
	local raw = Core.callModule("Egg", "ReadFieldEggs")
	if type(raw) == "table" then
		if type(raw.Records) == "table" then
			return raw.Records
		end
		if next(raw) ~= nil then
			return raw
		end
	end
	local now = os.clock()
	if now >= SnapshotCooldownUntil then
		SnapshotCooldownUntil = now + 20
		local okSnap, snap = pcall(Core.invokeRemote, "RF/EggWorld/AskFieldEggSnapshot")
		if okSnap and type(snap) == "table" then
			if type(snap.Records) == "table" then
				return snap.Records
			end
			return snap
		end
	end
	return {}
end

local function readOwnerEggsMap(userId: number): { [string]: any }
	local raw = Core.callModule("Egg", "ReadOwnerEggs", userId)
	if type(raw) ~= "table" then
		return {}
	end
	if type(raw.Records) == "table" and raw.Records.AssetCategory == nil then
		return raw.Records
	end
	return raw
end

-- =====================================================================
-- 2) Egg ESP (Field + Own Base + Other Bases + RevealEggContent)
-- =====================================================================
local EGG_ROW_WEIGHTS = { 2.2, 1.35, 0.9, 0.85, 1.0, 0.85 }
local EggGui: ScreenGui? = nil
local EggEntries: { [string]: any } = {}
local EggConns: { RBXScriptConnection } = {}
local EggDirty = false
local EggRefreshing = false
local EggEpoch = 0
local EggLastDistTick = 0

local function destroyEggEntry(entry: any)
	if entry.b then
		pcall(function()
			entry.b:Destroy()
		end)
	end
	if entry.anc then
		pcall(function()
			entry.anc:Destroy()
		end)
	end
end

function Render.clearEggESP()
	EggEpoch += 1
	EggRefreshing = false
	EggDirty = false
	disconnectList(EggConns)
	for k, e in pairs(EggEntries) do
		destroyEggEntry(e)
		EggEntries[k] = nil
	end
	if EggGui then
		pcall(function()
			EggGui:Destroy()
		end)
		EggGui = nil
	end
end

function Render.clearOwnBaseEggESP()
	for k, e in pairs(EggEntries) do
		if tostring(k):sub(1, 5) == "base:" then
			destroyEggEntry(e)
			EggEntries[k] = nil
		end
	end
end

local function ensureEggGui(): ScreenGui
	if EggGui and EggGui.Parent then
		return EggGui
	end
	local sg = Instance.new("ScreenGui")
	sg.Name = "TRex_EggESP"
	sg.Archivable = false
	sg.ResetOnSpawn = false
	sg.IgnoreGuiInset = true
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.DisplayOrder = 48
	sg.Parent = getGuiRoot()
	EggGui = sg
	return sg
end

local function applyEggBillboardScale(entry: any)
	local cfg = TRex.Config
	local sizeMult = math.clamp((tonumber(cfg.ESPSizePercent) or 100) / 100, 0.5, 2.0)
	local fixed = cfg.ESPFixedSize == true
	local vis = entry.v
	local sumW = 0
	for i, w in ipairs(EGG_ROW_WEIGHTS) do
		if vis[i] then
			sumW += w
		end
	end
	sumW = math.max(sumW, 1)
	for i, frame in ipairs(entry.hs) do
		frame.Visible = vis[i]
		frame.Size = UDim2.fromScale(1, vis[i] and (EGG_ROW_WEIGHTS[i] / sumW) or 0)
	end
	local pxW = scaledWidth(120, sizeMult)
	local pxH = math.max(1, math.floor(scaledTextSize(sizeMult) * sumW))
	local worldW = 4.5 * sizeMult
	if entry.w ~= pxW or entry.ht ~= pxH or entry.f ~= fixed then
		entry.w = pxW
		entry.ht = pxH
		entry.f = fixed
		if fixed then
			entry.b.Size = UDim2.fromScale(worldW, worldW * pxH / pxW)
			entry.b.MaxDistance = getWorldMaxDist(worldW)
		else
			entry.b.Size = UDim2.fromOffset(pxW, pxH)
			entry.b.MaxDistance = math.huge
		end
	end
end

local function createEggEntry(): any
	local gui = ensureEggGui()
	local bb, holder = createBillboardRoot(gui)
	local iconWrap = Instance.new("Frame")
	iconWrap.BackgroundTransparency = 1
	iconWrap.BorderSizePixel = 0
	iconWrap.LayoutOrder = 0
	iconWrap.Parent = holder

	local iconImg = Instance.new("ImageLabel")
	iconImg.AnchorPoint = Vector2.new(0.5, 1)
	iconImg.BackgroundTransparency = 1
	iconImg.Position = UDim2.fromScale(0.5, 1)
	iconImg.Size = UDim2.fromScale(1, 1)
	iconImg.ScaleType = Enum.ScaleType.Fit
	iconImg.Parent = iconWrap
	local ar = Instance.new("UIAspectRatioConstraint")
	ar.DominantAxis = Enum.DominantAxis.Height
	ar.Parent = iconImg

	local fonts = { FONT_GOTHAM, FONT_FREDOKA, FONT_GOTHAM, FONT_GOTHAM, FONT_GOTHAM }
	local entry = {
		b = bb,
		ic = iconImg,
		r = {},
		hs = { iconWrap },
		v = { false, true, false, false, false, false },
		anc = nil :: Part?,
		a = nil :: Instance?,
		cf = nil :: CFrame?,
		w = nil :: number?,
		ht = nil :: number?,
		f = nil :: boolean?,
	}
	for i, fnt in ipairs(fonts) do
		local row = createGradientTextRow(holder, fnt, i, 0)
		entry.r[i] = row
		entry.hs[i + 1] = row.h
	end
	applyEggBillboardScale(entry)
	return entry
end

local function resolveEggHitbox(rec: any): BasePart?
	if typeof(rec.Model) == "Instance" then
		local p = rec.Model:FindFirstChild("Hitbox", true) or rec.Model:FindFirstChildWhichIsA("BasePart", true)
		if p and p:IsA("BasePart") then
			return p
		end
	end
	local slotsClient = Workspace:FindFirstChild("AreaEggSlotsClient")
	if slotsClient and rec.Uid then
		local m = slotsClient:FindFirstChild(tostring(rec.Uid))
		local p = m and m:IsA("Model") and m:FindFirstChild("Hitbox")
		if p and p:IsA("BasePart") then
			return p
		end
	end
	return nil
end

local function updateEggEntry(entry: any, rec: any, meta: any, showInfo: { [string]: boolean })
	local cf = rec.BottomCFrame
	local hasCF = typeof(cf) == "CFrame"
	local hitbox = resolveEggHitbox(rec)
	if hasCF then
		local target: Instance? = hitbox or entry.anc
		if not target or not target.Parent then
			local p = Instance.new("Part")
			p.Name = "EggESPAnchor"
			p.Anchored = true
			p.CanCollide = false
			p.CanTouch = false
			p.CanQuery = false
			p.Transparency = 1
			p.Size = Vector3.new(0.2, 0.2, 0.2)
			p.Position = cf.Position
			p.Parent = TRex.UI.ESPFolder or Workspace
			entry.anc = p
			target = p
		elseif hitbox and entry.anc then
			entry.anc:Destroy()
			entry.anc = nil
		end
		if target and (entry.a ~= target or entry.cf ~= cf) then
			entry.a = target
			entry.cf = cf
			entry.b.Adornee = target
			if target == entry.anc and target:IsA("BasePart") then
				target.Position = cf.Position
				entry.b.StudsOffsetWorldSpace = Vector3.new(0, 1.8, 0)
			elseif target:IsA("BasePart") then
				entry.b.StudsOffsetWorldSpace = cf.Position - target.Position + Vector3.new(0, (target.Position.Y - cf.Position.Y) + 0.8, 0)
			end
		end
	end

	local mutList = {}
	local mutSeen: { [string]: boolean } = {}
	local function addMut(m: any)
		if type(m) == "string" and m ~= "" and m ~= "Normal" and m ~= "None" and not mutSeen[m] then
			mutSeen[m] = true
			table.insert(mutList, m)
		end
	end
	addMut(rec.BaseMutation)
	if type(rec.Mutations) == "table" then
		for k, v in pairs(rec.Mutations) do
			if type(k) == "string" and v == true then
				addMut(k)
			elseif type(v) == "string" then
				addMut(v)
			end
		end
	end

	local info = Core.computeEggInfo(rec)
	local scale = tonumber(rec.AssetScale or rec.Scale) or 1
	local revealedName: string? = nil
	if TRex.Config.RevealEggContent then
		local outcome = rec.PetCategory or rec.OutcomeCategory or rec.ResultCategory or rec.HatchedCategory
			or (type(meta.Entry) == "table" and (meta.Entry.OutcomeCategory or meta.Entry.PetCategory))
		if type(outcome) == "string" and outcome ~= "" and outcome ~= rec.AssetCategory then
			revealedName = getEggAssetMeta(outcome).DisplayName
		end
	end

	local showFlags = {
		showInfo.Icon == true and (meta.Icon ~= nil or meta.PetIcon ~= nil),
		showInfo.Name == true,
		showInfo.Rarity == true and meta.RarityName ~= "",
		showInfo.Mutation == true and mutList[1] ~= nil,
		showInfo.Value == true,
		false,
	}

	if showFlags[1] then
		local ic = readEggIcon(rec, false)
		if entry.ic.Image ~= ic then
			entry.ic.Image = ic
		end
	end
	if showFlags[2] then
		local label = revealedName and (meta.DisplayName .. " -> " .. revealedName) or meta.DisplayName
		applyTextRow(entry.r[1], label, NAME_PALETTE)
	end
	if showFlags[3] then
		applyTextRow(entry.r[2], meta.RarityName:upper(), meta.RarityPalette)
	end
	if showFlags[4] then
		local dispMuts = {}
		for _, m in ipairs(mutList) do
			local mapped = (MUTATION_ALIAS[m] or m):gsub("%s*[Mm]utation$", ""):upper()
			table.insert(dispMuts, mapped)
		end
		local firstMut = MUTATION_ALIAS[mutList[1]] or mutList[1]
		applyTextRow(entry.r[3], table.concat(dispMuts, " + "), MUTATION_PALETTES[firstMut] or DEFAULT_MUT_PALETTE)
	end
	if showFlags[5] then
		applyTextRow(entry.r[4], "$" .. formatCompact(info.Value) .. "/s", VALUE_PALETTE)
	end

	local details = {}
	if showInfo.Weight then
		local w = info.WeightKg
		if w <= 0 then
			w = tonumber(Core.callModule("Rec", "WeightKgForScale", rec.AssetCategory, scale)) or 0
		end
		if w > 0 then
			table.insert(details, formatCompact(w) .. " kg")
		end
	end
	if showInfo.Size then
		table.insert(details, string.format("x%.2f", scale))
	end
	if showInfo["Sell Price"] then
		local sp = tonumber(Core.callModule("Rec", "SellPrice", rec))
		if sp and sp > 0 then
			table.insert(details, "$" .. formatCompact(sp))
		end
	end
	if showInfo.Distance and hasCF then
		local root = Core.getRoot()
		if root then
			table.insert(details, string.format("%dm", math.floor((root.Position - cf.Position).Magnitude + 0.5)))
		end
	end
	if showInfo.Area and rec.AreaId ~= nil and rec.AreaId ~= "" then
		table.insert(details, tostring(rec.AreaId))
	end
	if showInfo.State and rec.State ~= nil and rec.State ~= "Slot" then
		table.insert(details, tostring(rec.State))
	end

	showFlags[6] = #details > 0
	if showFlags[6] then
		applyTextRow(entry.r[5], table.concat(details, "  |  "), DETAIL_PALETTE)
	end

	for i = 1, 6 do
		if entry.v[i] ~= showFlags[i] then
			entry.v = showFlags
			applyEggBillboardScale(entry)
			break
		end
	end
end

local function collectBaseEggRecords(plr: Player, areaLabel: string, keyPrefix: string, targetList: { any })
	local ownerEggs = readOwnerEggsMap(plr.UserId)
	local renders = Workspace:FindFirstChild("PlacedEggRenders")
	local userPrefix = tostring(plr.UserId)
	local children: { Instance } = {}
	if renders then
		for _, ch in ipairs(renders:GetChildren()) do
			if ch.Name:find(userPrefix, 1, true) then
				table.insert(children, ch)
			end
		end
	end
	local myPlot = (plr == TRex.LocalPlayer) and Core.getPlot() or nil
	local petArea = myPlot and myPlot.PetArea

	for uid, rec in pairs(ownerEggs) do
		if type(rec) == "table" and rec.Placement ~= nil and type(rec.AssetCategory) == "string" then
			local uidStr = tostring(uid)
			local matchedModel: Instance? = nil
			for _, ch in ipairs(children) do
				if ch.Name:find(uidStr, 1, true) or ch:GetAttribute("Uid") == uidStr then
					matchedModel = ch
					break
				end
			end
			local cf: CFrame? = nil
			if matchedModel then
				local okCF, piv = pcall(function()
					return matchedModel:IsA("Model") and matchedModel:GetPivot() or (matchedModel :: BasePart).CFrame
				end)
				if okCF and typeof(piv) == "CFrame" then
					cf = piv
				end
			elseif petArea and petArea:IsA("BasePart") and typeof(rec.Placement.LocalCFrame) == "CFrame" then
				cf = petArea.CFrame * rec.Placement.LocalCFrame
			end
			if cf then
				local muts = type(rec.Mutations) == "table" and rec.Mutations or {}
				table.insert(targetList, {
					Uid = keyPrefix .. uidStr,
					AssetCategory = rec.AssetCategory,
					AssetScale = rec.AssetScale,
					Mutations = muts,
					BaseMutation = rec.BaseMutation or muts[1],
					State = "Base",
					AreaId = areaLabel,
					BottomCFrame = cf,
					Model = matchedModel,
					PetCategory = rec.PetCategory or rec.OutcomeCategory,
				})
			end
		end
	end
end

local function refreshEggESPBatches(epochSnap: number)
	local cfg = TRex.Config
	if not (cfg.EggESP or cfg.OwnBaseEggESP or cfg.OtherBaseEggESP) or epochSnap ~= EggEpoch then
		return
	end
	local minRank = parseMinRarityRank(cfg.ESPMinRarity)
	local minVal = tonumber(cfg.ESPMinValue) or 0
	local showInfo = buildSelectedSet(cfg.ESPShowInfo, false)
	if next(showInfo) == nil then
		showInfo = { Icon = true, Name = true, Value = true }
	end

	local alive: { [string]: boolean } = {}
	local budgetAt = os.clock()

	local function processRecord(rec: any): boolean
		if epochSnap ~= EggEpoch then
			return false
		end
		if type(rec) ~= "table" or type(rec.Uid) ~= "string" or type(rec.AssetCategory) ~= "string" then
			return true
		end
		if rec.State == "Claimed" then
			return true
		end
		local meta = getEggAssetMeta(rec.AssetCategory)
		if meta.Rank < minRank then
			return true
		end
		if minVal > 0 then
			local info = Core.computeEggInfo(rec)
			if info.Value < minVal then
				return true
			end
		end
		alive[rec.Uid] = true
		local entry = EggEntries[rec.Uid]
		if not entry or not entry.b or not entry.b.Parent then
			if entry then
				destroyEggEntry(entry)
			end
			entry = createEggEntry()
			EggEntries[rec.Uid] = entry
		end
		updateEggEntry(entry, rec, meta, showInfo)
		if os.clock() - budgetAt > 0.0025 then
			task.wait()
			budgetAt = os.clock()
		end
		return epochSnap == EggEpoch
	end

	if cfg.EggESP then
		local fieldEggs = extractFieldEggs()
		for k, rec in pairs(fieldEggs) do
			if type(rec) == "table" and rec.Uid == nil and type(k) == "string" then
				rec.Uid = k
			end
			if not processRecord(rec) then
				return
			end
		end
	end

	if cfg.OwnBaseEggESP and TRex.LocalPlayer then
		local ownList = {}
		collectBaseEggRecords(TRex.LocalPlayer, "Your Base", "base:", ownList)
		for _, rec in ipairs(ownList) do
			if not processRecord(rec) then
				return
			end
		end
	end

	if cfg.OtherBaseEggESP then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= TRex.LocalPlayer then
				local baseList = {}
				collectBaseEggRecords(plr, plr.DisplayName .. " Base", "base" .. tostring(plr.UserId) .. ":", baseList)
				for _, rec in ipairs(baseList) do
					if not processRecord(rec) then
						return
					end
				end
			end
		end
	end

	if epochSnap ~= EggEpoch then
		return
	end
	for k, e in pairs(EggEntries) do
		if not alive[k] then
			destroyEggEntry(e)
			EggEntries[k] = nil
		end
	end
end

function Render.scheduleEggRefresh()
	local cfg = TRex.Config
	if not (cfg.EggESP or cfg.OwnBaseEggESP or cfg.OtherBaseEggESP) then
		return
	end
	EggDirty = true
	if EggRefreshing then
		return
	end
	EggRefreshing = true
	local myEpoch = EggEpoch
	task.defer(function()
		while EggDirty and myEpoch == EggEpoch and TRex.IsRunning do
			EggDirty = false
			pcall(refreshEggESPBatches, myEpoch)
			task.wait(0.05)
		end
		EggRefreshing = false
	end)
end

local function applyAllEggScales()
	for _, entry in pairs(EggEntries) do
		entry.w = nil
		applyEggBillboardScale(entry)
	end
end

local function ensureEggWatchers()
	if #EggConns > 0 then
		return
	end
	local eggMod = Core.Modules and Core.Modules.Egg
	if type(eggMod) == "table" then
		for _, sigName in ipairs({ "FieldRefreshed", "FieldShifted", "FieldGone", "FieldClaimed", "SnapshotRefreshed" }) do
			local sig = eggMod[sigName]
			if type(sig) == "table" and sig.Connect then
				local okC, conn = pcall(sig.Connect, sig, function()
					Render.scheduleEggRefresh()
				end)
				if okC and conn then
					table.insert(EggConns, conn)
				end
			end
		end
	end
	for _, folderName in ipairs({ "AreaEggSlotsClient", "PlacedEggRenders" }) do
		local f = Workspace:FindFirstChild(folderName)
		if f then
			table.insert(EggConns, f.ChildAdded:Connect(Render.scheduleEggRefresh))
			table.insert(EggConns, f.ChildRemoved:Connect(Render.scheduleEggRefresh))
		end
	end
end

-- =====================================================================
-- 3) Guard ESP
-- =====================================================================
local GuardGui: ScreenGui? = nil
local GuardEntries: { [Instance]: any } = {}
local GuardFolderConns: { RBXScriptConnection } = {}
local GuardWatchActive = false

local function destroyGuardEntry(inst: Instance)
	local e = GuardEntries[inst]
	if not e then
		return
	end
	GuardEntries[inst] = nil
	disconnectList(e.conns)
	if e.hl then
		pcall(function()
			e.hl:Destroy()
		end)
	end
	if e.b then
		pcall(function()
			e.b:Destroy()
		end)
	end
end

function Render.clearGuardESP()
	GuardWatchActive = false
	disconnectList(GuardFolderConns)
	local keys = {}
	for inst in pairs(GuardEntries) do
		table.insert(keys, inst)
	end
	for _, inst in ipairs(keys) do
		destroyGuardEntry(inst)
	end
	if GuardGui then
		pcall(function()
			GuardGui:Destroy()
		end)
		GuardGui = nil
	end
end

local function ensureGuardGui(): ScreenGui
	if GuardGui and GuardGui.Parent then
		return GuardGui
	end
	local sg = Instance.new("ScreenGui")
	sg.Name = "TRex_GuardESP"
	sg.Archivable = false
	sg.ResetOnSpawn = false
	sg.IgnoreGuiInset = true
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.DisplayOrder = 48
	sg.Parent = getGuiRoot()
	GuardGui = sg
	return sg
end

local function formatGuardStateText(model: Instance): (string, any)
	local st = model:GetAttribute("GuardState")
	local tgt = model:GetAttribute("TargetPlayer")
	local pal = GUARD_COLORS[tostring(st or "")] or DETAIL_PALETTE
	if st == "Waking" then
		return "Waking Up", pal
	elseif st == "Chasing" then
		local myId = TRex.LocalPlayer and tostring(TRex.LocalPlayer.UserId) or ""
		if tostring(tgt) == myId then
			return "Chasing You", pal
		end
		local numId = tonumber(tgt)
		local p = numId and Players:GetPlayerByUserId(numId) or nil
		return p and ("Chasing " .. p.DisplayName) or "Chasing", pal
	end
	return st and tostring(st) or "Awake", pal
end

local function attachGuardEntry(areaLabel: string, guardInst: Instance)
	if GuardEntries[guardInst] then
		return
	end
	local part: BasePart? = if guardInst:IsA("BasePart")
		then guardInst
		elseif guardInst:IsA("Model") then (guardInst:FindFirstChild("HumanoidRootPart") :: BasePart?) or guardInst.PrimaryPart or guardInst:FindFirstChildWhichIsA("BasePart", true)
		else nil
	if not (part and part:IsA("BasePart")) then
		return
	end
	local gui = ensureGuardGui()
	local hl = Instance.new("Highlight")
	hl.Adornee = guardInst
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.FillTransparency = 0.76
	hl.OutlineTransparency = 0.02
	hl.Parent = gui

	local bb, holder = createBillboardRoot(gui)
	bb.Adornee = part
	local yOff = 6
	if guardInst:IsA("Model") then
		local okBB, cf, sz = pcall(guardInst.GetBoundingBox, guardInst)
		if okBB and typeof(cf) == "CFrame" then
			yOff = cf.Position.Y + sz.Y * 0.5 - part.Position.Y + 1
		end
	end
	bb.StudsOffsetWorldSpace = Vector3.new(0, yOff, 0)
	local titleRow = createGradientTextRow(holder, FONT_GOTHAM, 1, 0.45)
	local stateRow = createGradientTextRow(holder, FONT_GOTHAM, 2, 0.55)
	applyTextRow(titleRow, areaLabel .. " Guard", NAME_PALETTE)

	local scaleMult = math.clamp((tonumber(TRex.Config.ESPSizePercent) or 100) / 100, 0.5, 2.0)
	bb.Size = UDim2.fromOffset(scaledWidth(115, scaleMult), math.floor(scaledTextSize(scaleMult) * 1.6))

	local entry = { hl = hl, b = bb, sr = stateRow, conns = {} :: { RBXScriptConnection } }
	GuardEntries[guardInst] = entry

	local function updateGuardVisual()
		local stText, pal = formatGuardStateText(guardInst)
		local col = pal.o or COLOR_WHITE
		hl.FillColor = col
		hl.OutlineColor = col
		applyTextRow(stateRow, stText, pal)
	end
	updateGuardVisual()

	table.insert(entry.conns, guardInst:GetAttributeChangedSignal("GuardState"):Connect(updateGuardVisual))
	table.insert(entry.conns, guardInst:GetAttributeChangedSignal("TargetPlayer"):Connect(updateGuardVisual))
	table.insert(entry.conns, guardInst.AncestryChanged:Connect(function()
		if not guardInst:IsDescendantOf(Workspace) then
			destroyGuardEntry(guardInst)
		end
	end))
end

local function stepGuardESP()
	if not TRex.Config.GuardESP then
		if GuardWatchActive or next(GuardEntries) ~= nil then
			Render.clearGuardESP()
		end
		return
	end
	if not GuardWatchActive then
		GuardWatchActive = true
		local guardAreas = Core.findWorldPath("Areas", "GuardAreas")
		if guardAreas then
			local function watchArea(area: Instance)
				local g = area:FindFirstChild("Guard")
				if g and g:IsA("Model") then
					attachGuardEntry(area.Name, g)
				end
				table.insert(GuardFolderConns, area.ChildAdded:Connect(function(ch)
					if ch.Name == "Guard" and ch:IsA("Model") then
						attachGuardEntry(area.Name, ch)
					end
				end))
			end
			for _, area in ipairs(guardAreas:GetChildren()) do
				watchArea(area)
			end
			table.insert(GuardFolderConns, guardAreas.ChildAdded:Connect(watchArea))
		end
		local guardsFolder = Core.findWorldPath("Guards") or Workspace:FindFirstChild("Guards")
		if guardsFolder then
			for _, g in ipairs(guardsFolder:GetChildren()) do
				attachGuardEntry(g.Name, g)
			end
		end
		for _, g in ipairs(CollectionService:GetTagged("Guard")) do
			attachGuardEntry(g.Name, g)
		end
	end
end

-- =====================================================================
-- 4) Player ESP & 2D Player Tracker Lines
-- =====================================================================
local PlayerGui: ScreenGui? = nil
local PlayerEntries: { [Player]: any } = {}
local ToolIconCache: { [string]: string } = {}
local AvatarUrlCache: { [number]: string } = {}

local function normalizeAssetUri(s: any): string
	local str = tostring(s or "")
	if str:match("^%d+$") then
		return "rbxassetid://" .. str
	end
	return str
end

local function resolveToolIcon(tool: Tool?): string
	if not tool then
		return ""
	end
	local cached = ToolIconCache[tool.Name]
	if cached ~= nil then
		return cached
	end
	local icon = normalizeAssetUri(tool.TextureId)
	if icon == "" then
		for _, attr in ipairs({ "Icon", "Image", "Thumbnail", "TextureId" }) do
			local v = tool:GetAttribute(attr)
			if type(v) == "string" and normalizeAssetUri(v) ~= "" then
				icon = normalizeAssetUri(v)
				break
			end
		end
	end
	if icon == "" then
		for _, d in ipairs(tool:GetDescendants()) do
			if d:IsA("Decal") or d:IsA("Texture") then
				icon = normalizeAssetUri(d.Texture)
			elseif d:IsA("ImageLabel") or d:IsA("ImageButton") then
				icon = normalizeAssetUri(d.Image)
			end
			if icon ~= "" then
				break
			end
		end
	end
	ToolIconCache[tool.Name] = icon
	return icon
end

local function measurePlayerTextWidth(text: string, fontSize: number): number
	local params = Instance.new("GetTextBoundsParams")
	params.Text = text
	params.Font = FONT_GOTHAM
	params.Size = fontSize
	params.Width = 1000
	local ok, bounds = pcall(TextService.GetTextBoundsAsync, TextService, params)
	params:Destroy()
	if ok and bounds then
		return bounds.X
	end
	return (utf8.len(text) or #text) * fontSize * 0.56
end

function Render.clearPlayerESP(plr: Player?)
	if plr then
		local e = PlayerEntries[plr]
		if e then
			PlayerEntries[plr] = nil
			disconnectList(e.conns)
			if e.nh and e.nh.Parent and e.nd ~= nil then
				pcall(function()
					e.nh.NameDisplayDistance = e.nd
				end)
			end
			if e.hl then
				pcall(function()
					e.hl:Destroy()
				end)
			end
			if e.b then
				pcall(function()
					e.b:Destroy()
				end)
			end
			if e.line then
				pcall(function()
					e.line:Destroy()
				end)
			end
		end
	else
		local list = {}
		for p in pairs(PlayerEntries) do
			table.insert(list, p)
		end
		for _, p in ipairs(list) do
			Render.clearPlayerESP(p)
		end
		if PlayerGui then
			pcall(function()
				PlayerGui:Destroy()
			end)
			PlayerGui = nil
		end
	end
end

local function ensurePlayerGui(): ScreenGui
	if PlayerGui and PlayerGui.Parent then
		return PlayerGui
	end
	local sg = Instance.new("ScreenGui")
	sg.Name = "TRex_PlayerESP"
	sg.Archivable = false
	sg.ResetOnSpawn = false
	sg.IgnoreGuiInset = true
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.DisplayOrder = 48
	sg.Parent = getGuiRoot()
	PlayerGui = sg
	return sg
end

local function layoutPlayerBillboard(entry: any, infoSet: { [string]: boolean }, scaleMult: number)
	local plr = entry.pl :: Player
	local h = math.max(1, math.floor(math.clamp(getViewportHeight() * 0.024, 26, 35) * scaleMult))
	local showName = infoSet.Name == true or infoSet.Username == true
	local showAvatar = infoSet.Avatar == true
	local showTool = infoSet.Tool == true and entry.ti.Image ~= ""
	local avSize = showAvatar and math.floor(h * 0.72) or 0
	local toolSize = showTool and math.floor(h * 0.82) or 0
	local textH = math.floor(h * 0.7)
	local pad = math.max(1, math.floor(h * 0.04))

	local baseName = infoSet.Username == true and plr.Name or plr.DisplayName
	local extras = {}
	if infoSet.Distance then
		local myRoot = Core.getRoot()
		local pRoot = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if myRoot and pRoot then
			table.insert(extras, tostring(math.floor((pRoot.Position - myRoot.Position).Magnitude)) .. "m")
		end
	end
	if infoSet.Carrying and plr.Character then
		local t = plr.Character:FindFirstChildOfClass("Tool")
		if t and (t:GetAttribute("ItemType") or ""):find("Asset", 1, true) then
			table.insert(extras, "Egg")
		end
	end
	local dispText = (#extras > 0) and (baseName .. " [" .. table.concat(extras, " • ") .. "]") or baseName
	local layoutSig = string.format("%s|%s|%s|%s|%s|%.2f", dispText, tostring(showName), tostring(showAvatar), tostring(showTool), tostring(entry.ti.Image), scaleMult)
	if entry.layoutSig == layoutSig then
		return
	end
	entry.layoutSig = layoutSig
	entry.n.Text = dispText
	entry.s.Text = dispText

	local textW = showName and math.floor(math.clamp(measurePlayerTextWidth(dispText, textH) + 4, textH, 260)) or 0
	local avBlock = avSize > 0 and (avSize + pad) or 0
	local nameEnd = showName and (avBlock + textW) or avSize
	local beforeTool = nameEnd > 0 and (nameEnd + pad) or 0
	local totalW = math.max(showTool and (beforeTool + toolSize) or nameEnd, 1)

	entry.b.Size = UDim2.fromOffset(totalW, h)
	entry.a.Visible = showAvatar
	entry.n.Visible = showName
	entry.s.Visible = showName
	entry.ti.Visible = showTool
	entry.ts.Visible = showTool

	local px = 1 / totalW
	local py = 1 / h
	entry.a.Position = UDim2.fromScale(0, 0.5)
	entry.a.Size = UDim2.fromScale(avSize / totalW, avSize / h)
	local nSize = UDim2.fromScale(textW / totalW, textH / h)
	entry.n.Position = UDim2.fromScale(avBlock / totalW, 0.5)
	entry.n.Size = nSize
	entry.s.Position = UDim2.fromScale(avBlock / totalW + px, 0.5 + py)
	entry.s.Size = nSize
	local tSize = UDim2.fromScale(toolSize / totalW, toolSize / h)
	entry.ti.Position = UDim2.fromScale(beforeTool / totalW, 0.5)
	entry.ti.Size = tSize
	entry.ts.Position = UDim2.fromScale(beforeTool / totalW + px, 0.5 + py)
	entry.ts.Size = tSize
end

local function setupPlayerEntry(plr: Player, char: Model, infoSet: { [string]: boolean }, scaleMult: number)
	Render.clearPlayerESP(plr)
	local hrp = char:FindFirstChild("HumanoidRootPart") :: BasePart?
	local head = (char:FindFirstChild("Head") or hrp) :: BasePart?
	if not (head and head:IsA("BasePart")) then
		return
	end
	local gui = ensurePlayerGui()
	local hl = Instance.new("Highlight")
	hl.Adornee = char
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.FillTransparency = 0.76
	hl.OutlineTransparency = 0.02
	hl.FillColor = Color3.fromRGB(0, 67, 148)
	hl.OutlineColor = Color3.fromRGB(72, 207, 255)
	hl.Parent = gui

	local adornee = hrp or head
	local bb = Instance.new("BillboardGui")
	bb.Adornee = adornee
	bb.AlwaysOnTop = true
	bb.LightInfluence = 0
	bb.MaxDistance = math.huge
	bb.Size = UDim2.fromOffset(1, 1)
	bb.StudsOffsetWorldSpace = Vector3.new(0, adornee ~= head and math.clamp(head.Position.Y - adornee.Position.Y + 3.1, 3.8, 6) or 3.1, 0)
	bb.Parent = gui

	local wrap = Instance.new("Frame")
	wrap.Size = UDim2.fromScale(1, 1)
	wrap.BackgroundTransparency = 1
	wrap.Parent = bb

	local av = Instance.new("ImageLabel")
	av.AnchorPoint = Vector2.new(0, 0.5)
	av.BackgroundTransparency = 1
	av.ScaleType = Enum.ScaleType.Crop
	av.ZIndex = 2
	av.Parent = wrap
	local avAspect = Instance.new("UIAspectRatioConstraint")
	avAspect.Parent = av
	local avCorner = Instance.new("UICorner")
	avCorner.CornerRadius = UDim.new(1, 0)
	avCorner.Parent = av

	if AvatarUrlCache[plr.UserId] then
		av.Image = AvatarUrlCache[plr.UserId]
	else
		av.Image = ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(plr.UserId)
		task.spawn(function()
			local ok, url, ready = pcall(Players.GetUserThumbnailAsync, Players, plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
			if ok and ready and type(url) == "string" and av.Parent then
				AvatarUrlCache[plr.UserId] = url
				av.Image = url
			end
		end)
	end

	local sh = Instance.new("TextLabel")
	sh.AnchorPoint = Vector2.new(0, 0.5)
	sh.BackgroundTransparency = 1
	sh.TextScaled = true
	sh.FontFace = FONT_GOTHAM
	sh.ZIndex = 1
	sh.TextColor3 = Color3.fromRGB(7, 19, 34)
	sh.TextTransparency = 0.05
	sh.Parent = wrap

	local nm = Instance.new("TextLabel")
	nm.AnchorPoint = Vector2.new(0, 0.5)
	nm.BackgroundTransparency = 1
	nm.TextScaled = true
	nm.FontFace = FONT_GOTHAM
	nm.ZIndex = 2
	nm.TextColor3 = COLOR_WHITE
	nm.Parent = wrap

	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	stroke.LineJoinMode = Enum.LineJoinMode.Round
	stroke.Color = COLOR_WHITE
	local okS = pcall(function()
		(stroke :: any).StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
	end)
	stroke.Thickness = okS and 0.044 or 1.4
	stroke.Parent = nm
	local sg = Instance.new("UIGradient")
	sg.Rotation = 90
	sg.Color = PLAYER_TEXT_PALETTE.s
	sg.Parent = stroke
	local tg = Instance.new("UIGradient")
	tg.Rotation = 90
	tg.Color = PLAYER_TEXT_PALETTE.t
	tg.Parent = nm

	local ts = Instance.new("ImageLabel")
	ts.AnchorPoint = Vector2.new(0, 0.5)
	ts.BackgroundTransparency = 1
	ts.ScaleType = Enum.ScaleType.Fit
	ts.ZIndex = 1
	ts.ImageColor3 = COLOR_BLACK
	ts.ImageTransparency = 0.35
	ts.Parent = wrap
	local ar1 = Instance.new("UIAspectRatioConstraint")
	ar1.Parent = ts

	local ti = Instance.new("ImageLabel")
	ti.AnchorPoint = Vector2.new(0, 0.5)
	ti.BackgroundTransparency = 1
	ti.ScaleType = Enum.ScaleType.Fit
	ti.ZIndex = 2
	ti.Parent = wrap
	local ar2 = Instance.new("UIAspectRatioConstraint")
	ar2.Parent = ti

	local line = Instance.new("Frame")
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.BorderSizePixel = 0
	line.BackgroundColor3 = TRex.UI.getTheme().Accent
	line.Visible = false
	line.Parent = TRex.UI.RenderLayer or gui

	local hum = char:FindFirstChildOfClass("Humanoid")
	local nd: number? = nil
	if hum then
		nd = hum.NameDisplayDistance
		pcall(function()
			hum.NameDisplayDistance = 0
		end)
	end

	local entry = {
		pl = plr,
		ch = char,
		hl = hl,
		b = bb,
		a = av,
		s = sh,
		n = nm,
		ts = ts,
		ti = ti,
		line = line,
		nh = hum,
		nd = nd,
		conns = {} :: { RBXScriptConnection },
	}
	PlayerEntries[plr] = entry

	local function refreshTool()
		if not PlayerEntries[plr] then
			return
		end
		local tool = char:FindFirstChildOfClass("Tool")
		local ic = resolveToolIcon(tool)
		ti.Image = ic
		ts.Image = ic
		layoutPlayerBillboard(entry, infoSet, scaleMult)
	end
	refreshTool()
	table.insert(entry.conns, char.ChildAdded:Connect(function(ch)
		if ch:IsA("Tool") or ch:IsA("Humanoid") then
			task.defer(refreshTool)
		end
	end))
	table.insert(entry.conns, char.ChildRemoved:Connect(function(ch)
		if ch:IsA("Tool") then
			task.defer(refreshTool)
		end
	end))
end

local function stepPlayerESPAndTracker()
	local cfg = TRex.Config
	if not (cfg.PlayerESP or cfg.PlayerTracker) then
		if next(PlayerEntries) ~= nil then
			Render.clearPlayerESP(nil)
		end
		return
	end
	local infoSet = buildSelectedSet(cfg.ESPPlayerInfo, false)
	if next(infoSet) == nil then
		infoSet = { Name = true, Tool = true }
	end
	local scaleMult = math.clamp((tonumber(cfg.ESPSizePercent) or 100) / 100, 0.5, 2.0)
	local cam = Workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	local bottomCenter = Vector2.new(vp.X * 0.5, vp.Y)
	local accent = TRex.UI.getTheme().Accent

	local activePlrs: { [Player]: boolean } = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= TRex.LocalPlayer then
			local char = plr.Character
			local pRoot = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
			local pHum = char and char:FindFirstChildOfClass("Humanoid")
			if char and char:IsDescendantOf(Workspace) and pRoot and (not pHum or pHum.Health > 0) then
				activePlrs[plr] = true
				local entry = PlayerEntries[plr]
				if not entry or entry.ch ~= char or not entry.b or not entry.b.Parent then
					setupPlayerEntry(plr, char, infoSet, scaleMult)
					entry = PlayerEntries[plr]
				end
				if entry then
					entry.hl.Enabled = cfg.PlayerESP == true
					entry.b.Enabled = cfg.PlayerESP == true
					if cfg.PlayerESP then
						layoutPlayerBillboard(entry, infoSet, scaleMult)
					end
					if cfg.PlayerTracker and cam then
						local pt, onScreen = cam:WorldToViewportPoint(pRoot.Position)
						if onScreen and pt.Z > 0 then
							local toPt = Vector2.new(pt.X, pt.Y)
							local delta = toPt - bottomCenter
							local len = delta.Magnitude
							if len >= 2 then
								local mid = (bottomCenter + toPt) * 0.5
								entry.line.BackgroundColor3 = accent
								entry.line.Position = UDim2.fromOffset(mid.X, mid.Y)
								entry.line.Size = UDim2.fromOffset(len, 1.5)
								entry.line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
								entry.line.Visible = true
							else
								entry.line.Visible = false
							end
						else
							entry.line.Visible = false
						end
					else
						entry.line.Visible = false
					end
				end
			end
		end
	end
	for plr in pairs(PlayerEntries) do
		if not activePlrs[plr] then
			Render.clearPlayerESP(plr)
		end
	end
end

-- =====================================================================
-- 5) Safe Zone & Rift Machine Markers
-- =====================================================================
local MarkerEntries: { [string]: any } = {}

function Render.clearMarkers()
	for k, e in pairs(MarkerEntries) do
		if e.bb then
			pcall(function()
				e.bb:Destroy()
			end)
		end
		if e.part then
			pcall(function()
				e.part:Destroy()
			end)
		end
		MarkerEntries[k] = nil
	end
end

local function createMarker(key: string, adornee: BasePart, text: string, color: Color3, ownedPart: Part?)
	local folder = TRex.UI.ESPFolder
	if not folder then
		return
	end
	local bb = Instance.new("BillboardGui")
	bb.Name = "TRexMarker_" .. key
	bb.Adornee = adornee
	bb.AlwaysOnTop = true
	bb.Size = UDim2.fromOffset(170, 32)
	bb.StudsOffset = Vector3.new(0, 3.5, 0)
	bb.Parent = folder
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 1
	lbl.FontFace = FONT_GOTHAM
	lbl.TextSize = 14
	lbl.TextColor3 = color
	lbl.TextStrokeTransparency = 0.25
	lbl.Text = text
	lbl.Parent = bb
	MarkerEntries[key] = { bb = bb, part = ownedPart }
end

local function stepMarkers()
	if not TRex.Config.ShowSafeZoneMarker then
		if next(MarkerEntries) ~= nil then
			Render.clearMarkers()
		end
		return
	end
	if not MarkerEntries.SafeZone then
		local sep = Core.findWorldPath("Areas", "SeparationLine")
		if sep and sep:IsA("BasePart") then
			createMarker("SafeZone", sep, "เส้นแบ่งเขตปลอดภัย", Color3.fromRGB(16, 185, 129), nil)
		end
	end
	if not MarkerEntries.RiftMachine then
		local rift = Core.findWorldPath("Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003")
		local temp: Part? = nil
		if not (rift and rift:IsA("BasePart")) then
			local p = Instance.new("Part")
			p.Name = "RiftMarkerAnchor"
			p.Anchored = true
			p.CanCollide = false
			p.CanTouch = false
			p.CanQuery = false
			p.Transparency = 1
			p.Size = Vector3.new(0.2, 0.2, 0.2)
			p.Position = Core.getRiftMachinePos()
			p.Parent = TRex.UI.ESPFolder or Workspace
			temp = p
			rift = p
		end
		if rift and rift:IsA("BasePart") then
			createMarker("RiftMachine", rift, "เครื่อง Rift", Color3.fromRGB(168, 85, 247), temp)
		elseif temp then
			temp:Destroy()
		end
	end
end

-- =====================================================================
-- 6) Inventory Values Overlay (Temp 40_esp#2 parity)
-- =====================================================================
local InvGui: ScreenGui? = nil
local InvClip: Frame? = nil
local InvLabels: { [any]: { l: TextLabel, k: UIStroke } } = {}
local InvToolRateCache: { [any]: { string | number } } = setmetatable({}, { __mode = "k" }) :: any
local InvSlotMap: { [GuiButton]: any } = setmetatable({}, { __mode = "k" }) :: any
local InvCachedSlots: { any }? = nil
local InvNextScanAt = 0

function Render.clearInventoryValues()
	InvCachedSlots = nil
	InvNextScanAt = 0
	for k, v in pairs(InvLabels) do
		if v.l then
			pcall(function()
				v.l:Destroy()
			end)
		end
		InvLabels[k] = nil
	end
	InvClip = nil
	if InvGui then
		pcall(function()
			InvGui:Destroy()
		end)
		InvGui = nil
	end
end

local function ensureInvGui()
	if InvGui and InvGui.Parent and InvClip and InvClip.Parent == InvGui then
		return InvGui, InvClip
	end
	if InvGui then
		pcall(function()
			InvGui:Destroy()
		end)
	end
	local sg = Instance.new("ScreenGui")
	sg.Name = "TRex_InvValues"
	sg.ResetOnSpawn = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.DisplayOrder = 49
	sg.Enabled = false
	sg.Parent = getGuiRoot()
	local clip = Instance.new("Frame")
	clip.BackgroundTransparency = 1
	clip.ClipsDescendants = true
	clip.Parent = sg
	InvGui = sg
	InvClip = clip
	table.clear(InvLabels)
	return sg, clip
end

local function findSlotTableInUpvalues(val: any, btn: GuiButton, depth: number, visited: { [any]: boolean }): any
	if depth > 4 or visited[val] then
		return nil
	end
	visited[val] = true
	local env = getfenv(0) :: any
	local debugLib = (env.debug or debug) :: any
	if type(val) == "function" then
		local isl = env.islclosure or (_G :: any).islclosure
		if type(isl) == "function" and not isl(val) then
			return nil
		end
		if type(debugLib) == "table" and type(debugLib.getupvalues) == "function" then
			local ok, ups = pcall(debugLib.getupvalues, val)
			if ok and type(ups) == "table" then
				for _, up in pairs(ups) do
					local found = findSlotTableInUpvalues(up, btn, depth + 1, visited)
					if found then
						return found
					end
				end
			end
		end
	elseif type(val) == "table" then
		if rawget(val, "Frame") == btn then
			return val
		end
		for _, child in pairs(val) do
			if type(child) == "table" or type(child) == "function" then
				local found = findSlotTableInUpvalues(child, btn, depth + 1, visited)
				if found then
					return found
				end
			end
		end
	end
	return nil
end

local function scanBackpackSlots(): { any }?
	local lp = TRex.LocalPlayer
	local pGui = lp and lp:FindFirstChildOfClass("PlayerGui")
	local bpGui = pGui and pGui:FindFirstChild("BackpackGui")
	local bp = bpGui and bpGui:FindFirstChild("Backpack")
	if not bp then
		return nil
	end
	local env = getfenv(0) :: any
	local getConns = env.getconnections or (_G :: any).getconnections
	local debugLib = env.debug or debug
	if type(getConns) ~= "function" or type(debugLib) ~= "table" or type(debugLib.getupvalues) ~= "function" then
		return nil
	end
	local main = bp:FindFirstChild("Main")
	local inv = main and main:FindFirstChild("Inventory")
	local scroll = inv and inv:FindFirstChild("ScrollingFrame")
	local out = {}
	for _, container in ipairs({ bp:FindFirstChild("Hotbar"), scroll }) do
		if container then
			for _, btn in ipairs(container:GetChildren()) do
				if btn:IsA("GuiButton") then
					local cached = InvSlotMap[btn]
					if cached == nil or (type(cached) == "number" and os.clock() - cached > 30) then
						local okC, conns = pcall(getConns, btn.Activated)
						local found: any = nil
						if okC and type(conns) == "table" then
							for _, c in ipairs(conns) do
								if c.Function then
									found = findSlotTableInUpvalues(c.Function, btn, 0, {})
									if found then
										break
									end
								end
							end
						end
						cached = found or os.clock()
						InvSlotMap[btn] = cached
					end
					if type(cached) == "table" then
						table.insert(out, cached)
					end
				end
			end
		end
	end
	return out
end

local function safeGetToolAttr(tool: any, name: string): any
	if typeof(tool) == "Instance" then
		local ok, v = pcall(tool.GetAttribute, tool, name)
		return ok and v or nil
	elseif type(tool) == "table" and type(rawget(tool, "GetAttribute")) == "function" then
		local fn = rawget(tool, "GetAttribute") :: (...any) -> (...any)
		local ok, v = pcall(fn, tool, name)
		return ok and v or nil
	end
	return nil
end

local function computeToolRate(tool: any): number
	local cat = safeGetToolAttr(tool, "Category")
	local sc = safeGetToolAttr(tool, "Scale")
	local bm = safeGetToolAttr(tool, "BaseMutation")
	local mutsAttr = safeGetToolAttr(tool, "Mutations")
	local cacheKey = string.format("%s|%s|%s|%s", tostring(cat), tostring(sc), tostring(bm), tostring(mutsAttr))
	local cached = InvToolRateCache[tool]
	if cached and cached[1] == cacheKey then
		return tonumber(cached[2]) or 0
	end
	local mutList = {}
	local seen: { [string]: boolean } = {}
	local function addMut(s: any)
		local str = type(s) == "string" and (s:match("^%s*(.-)%s*$") or "") or ""
		if str ~= "" and str ~= "Normal" and str ~= "None" and not seen[str] then
			seen[str] = true
			table.insert(mutList, str)
		end
	end
	addMut(bm)
	for token in tostring(mutsAttr or ""):gmatch("[^,]+") do
		addMut(token)
	end
	local scale = tonumber(sc)
	if not scale then
		local w = tonumber(safeGetToolAttr(tool, "Weight"))
		local unitW = tonumber(Core.callModule("Rec", "WeightKgForScale", cat, 1))
		scale = (w and unitW and unitW > 0) and ((w / unitW) ^ (1 / 3)) or 1
	end
	local info = Core.computeEggInfo({
		AssetCategory = cat,
		AssetScale = scale,
		Mutations = mutList,
	})
	InvToolRateCache[tool] = { cacheKey, info.Value }
	return info.Value
end

local function isGuiChainVisible(obj: Instance?, stopAt: Instance): boolean
	local cur: Instance? = obj
	while cur and cur ~= stopAt do
		if cur:IsA("GuiObject") and not cur.Visible then
			return false
		end
		cur = cur.Parent
	end
	return cur == stopAt
end

local function createInvValueBadge()
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.FontFace = FONT_GOTHAM
	lbl.TextScaled = true
	lbl.TextColor3 = COLOR_WHITE
	lbl.Text = ""
	lbl.ZIndex = 5
	local grad = Instance.new("UIGradient")
	grad.Rotation = 90
	grad.Color = makeColorSeq(0, 196, 255, 176, 0.5, 88, 255, 74, 1, 32, 176, 14)
	grad.Parent = lbl
	local stroke = Instance.new("UIStroke")
	stroke.Color = COLOR_WHITE
	stroke.Thickness = 1.6
	stroke.Transparency = 0.05
	stroke.LineJoinMode = Enum.LineJoinMode.Round
	stroke.Parent = lbl
	local sGrad = Instance.new("UIGradient")
	sGrad.Rotation = 90
	sGrad.Color = ColorSequence.new(Color3.fromRGB(10, 70, 0), Color3.fromRGB(2, 22, 0))
	sGrad.Parent = stroke
	return { l = lbl, k = stroke }
end

local function stepInventoryValues()
	if not TRex.Config.ShowInventoryValues then
		if InvGui and InvGui.Enabled then
			InvGui.Enabled = false
		end
		return
	end
	local lp = TRex.LocalPlayer
	local pGui = lp and lp:FindFirstChildOfClass("PlayerGui")
	local bpGui = pGui and pGui:FindFirstChild("BackpackGui") :: ScreenGui?
	if not (bpGui and bpGui:IsA("ScreenGui") and bpGui.Enabled) then
		if InvGui and InvGui.Enabled then
			InvGui.Enabled = false
		end
		return
	end
	local sg, clip = ensureInvGui()
	if os.clock() > InvNextScanAt then
		InvNextScanAt = os.clock() + 2
		InvCachedSlots = scanBackpackSlots() or InvCachedSlots
	end
	if not InvCachedSlots then
		sg.Enabled = false
		return
	end
	sg.Enabled = true
	sg.IgnoreGuiInset = bpGui.IgnoreGuiInset
	sg.ScreenInsets = bpGui.ScreenInsets
	sg.DisplayOrder = bpGui.DisplayOrder + 1

	local bp = bpGui:FindFirstChild("Backpack")
	local main = bp and bp:FindFirstChild("Main")
	local inv = main and main:FindFirstChild("Inventory")
	local scroll = inv and inv:FindFirstChild("ScrollingFrame") :: GuiObject?
	local scrollVis = scroll ~= nil and isGuiChainVisible(scroll, bpGui)
	local guiOrigin = sg.AbsolutePosition
	clip.Visible = scrollVis
	if scrollVis and scroll then
		local relPos = scroll.AbsolutePosition - guiOrigin
		clip.Position = UDim2.fromOffset(relPos.X, relPos.Y)
		clip.Size = UDim2.fromOffset(scroll.AbsoluteSize.X, scroll.AbsoluteSize.Y)
	end

	local seenSlots: { [any]: boolean } = {}
	for _, slot in ipairs(InvCachedSlots) do
		local frame = type(slot) == "table" and rawget(slot, "Frame")
		local tool = type(slot) == "table" and rawget(slot, "Tool")
		local validTool = typeof(tool) == "Instance" and tool.Parent ~= nil
			or (type(tool) == "table" and type(rawget(tool, "GetAttribute")) == "function")
		if typeof(frame) == "Instance" and frame:IsA("GuiObject") and validTool then
			local itemType = tostring(safeGetToolAttr(tool, "ItemType") or "Asset")
			local cat = safeGetToolAttr(tool, "Category")
			if itemType:sub(1, 5) == "Asset" and cat then
				local inScroll = scroll ~= nil and frame:IsDescendantOf(scroll)
				local vis = (inScroll and scrollVis or not inScroll) and isGuiChainVisible(frame, bpGui)
				local rate = vis and computeToolRate(tool) or 0
				if rate > 0 then
					local badge = InvLabels[slot] or createInvValueBadge()
					InvLabels[slot] = badge
					seenSlots[slot] = true
					local targetParent: Instance = inScroll and clip or sg
					if badge.l.Parent ~= targetParent then
						badge.l.Parent = targetParent
					end
					local origin = (inScroll and scroll) and scroll.AbsolutePosition or guiOrigin
					local absPos = frame.AbsolutePosition - origin
					local absSz = frame.AbsoluteSize
					badge.l.Position = UDim2.fromOffset(absPos.X + absSz.X * 0.06, absPos.Y + absSz.Y * 0.05)
					badge.l.Size = UDim2.fromOffset(absSz.X * 0.88, absSz.Y * 0.23)
					badge.k.Thickness = math.clamp(absSz.Y / 52, 1, 2.2)
					local txt = formatCompact(rate) .. "/s"
					if badge.l.Text ~= txt then
						badge.l.Text = txt
					end
					badge.l.Visible = true
				end
			end
		end
	end
	for slot, badge in pairs(InvLabels) do
		if not seenSlots[slot] and badge.l.Visible then
			badge.l.Visible = false
		end
	end
end

-- =====================================================================
-- 7) Farm HUD Overlay (Temp parity, T-REX HUB branded & draggable)
-- =====================================================================
local StealHistory: { any } = {}
local SessionStolenCount = 0
local TotalStolenCount = 0
local BestStealRecord: any = nil
local HudGui: ScreenGui? = nil
local HudConns: { RBXScriptConnection } = {}
local HudBuilt = false
local HudDirtyCards = false
local HudFPS = 0
local HudStartAt = os.clock()
local HudBaseMoney: number? = nil
local HudBaseSpeed: number? = nil
local HudPanels: { any } = {}
local HudItemViews: { [string]: any } = {}
local HudShowcaseSets: { any } = {}
local HudHistoryPanel: any = nil
local HudHistoryRows: { any } = {}
local HudScales: { UIScale } = {}
local HudHeaderFPS: TextLabel? = nil
local HudHeaderPing: TextLabel? = nil
local HudStatsCache: any = { At = 0, ["Top Pets"] = {}, ["Top Eggs"] = {} }
local HudPetObjCache: { [string]: any } = {}
local HudEggObjCache: { [string]: any } = {}
local HudCacheResetAt = 0
local HudNextFastAt = 0
local HudNextCardAt = 0
local HudLastFPSVal = -1
local HudLastPingVal = -1

function Render.recordSteal(recOrInfo: any)
	if type(recOrInfo) ~= "table" then
		return
	end
	local cat = tostring(recOrInfo.Category or recOrInfo.AssetCategory or "")
	if cat == "" then
		return
	end
	local info = recOrInfo.Value and recOrInfo or Core.computeEggInfo(recOrInfo)
	TotalStolenCount += 1
	SessionStolenCount += 1
	local item = {
		At = os.time(),
		Category = info.Category or cat,
		Name = info.Name or cat,
		Rarity = info.Rarity or "Common",
		RarityRank = info.RarityRank or 1,
		Value = tonumber(info.Value) or 0,
		Scale = tonumber(info.Scale) or 1,
	}
	table.insert(StealHistory, 1, item)
	if #StealHistory > 12 then
		table.remove(StealHistory)
	end
	if not BestStealRecord or item.Value > (BestStealRecord.Value or 0) then
		BestStealRecord = item
	end
	HudDirtyCards = true
end

local function getHudPositionsTable(): { [string]: any }
	if type(TRex.Config.FarmHUDPositions) ~= "table" then
		TRex.Config.FarmHUDPositions = {}
	end
	return TRex.Config.FarmHUDPositions
end

local function parseHumanNumber(raw: any): number?
	if type(raw) == "number" then
		return raw
	end
	local s = tostring(raw or ""):gsub("[%$,%s/s]+", "")
	local numPart, suf = s:match("^([%d%.%-]+)(%a*)$")
	local n = tonumber(numPart or "")
	if not n then
		return nil
	end
	local mults: { [string]: number } = { K = 1e3, M = 1e6, B = 1e9, T = 1e12, Qa = 1e15, Qi = 1e18 }
	return n * (mults[suf or ""] or 1)
end

local function readLeaderstatStr(name: string): string?
	local lp = TRex.LocalPlayer
	local ls = lp and lp:FindFirstChild("leaderstats")
	local valObj = ls and ls:FindFirstChild(name)
	if valObj and (valObj:IsA("StringValue") or valObj:IsA("NumberValue") or valObj:IsA("IntValue")) then
		return tostring((valObj :: any).Value)
	end
	return nil
end

local function readLeaderstatNum(name: string): number?
	local lp = TRex.LocalPlayer
	local ls = lp and lp:FindFirstChild("leaderstats")
	local valObj = ls and ls:FindFirstChild(name)
	if not valObj then
		return nil
	end
	if valObj:IsA("NumberValue") or valObj:IsA("IntValue") then
		return tonumber((valObj :: any).Value)
	elseif valObj:IsA("StringValue") then
		return parseHumanNumber(valObj.Value)
	end
	return nil
end

local function computePerHourRate(delta: number): string
	if delta <= 0 then
		return ""
	end
	local hrs = math.max((os.clock() - HudStartAt) / 3600, 1 / 60)
	return "+" .. formatCompact(delta / hrs) .. "/h"
end

local function readHudCollectionStats()
	if os.clock() - HudStatsCache.At < 3 then
		return HudStatsCache
	end
	HudStatsCache.At = os.clock()
	local save = Core.getSaveData()
	if type(save) ~= "table" then
		return HudStatsCache
	end
	if os.clock() >= HudCacheResetAt then
		HudCacheResetAt = os.clock() + 300
		table.clear(HudPetObjCache)
		table.clear(HudEggObjCache)
	end

	local function buildTopObj(cache: { [string]: any }, uid: string, rec: any, cat: string, scale: any, defSize: number)
		local muts = rec.Mutations
		local nMuts = type(muts) == "table" and #muts or 0
		local hit = cache[uid]
		if hit and hit.Rec == rec and hit.Cat == cat and hit.Scale == scale and hit.Mut == muts and hit.N == nMuts then
			return hit
		end
		local meta = getEggAssetMeta(cat)
		local info = Core.computeEggInfo({
			AssetCategory = cat,
			AssetScale = scale,
			Mutations = muts,
		})
		hit = {
			Uid = uid,
			Rec = rec,
			Meta = meta,
			Rank = meta.Rank,
			Cat = cat,
			Scale = scale,
			Mut = muts,
			N = nMuts,
			Size = tonumber(scale) or defSize,
			Rate = info.Value,
		}
		cache[uid] = hit
		return hit
	end

	local function insertTop6(list: { any }, item: any, cmpFn: (any, any) -> boolean)
		if #list >= 6 and not cmpFn(item, list[#list]) then
			return
		end
		local pos = #list + 1
		while pos > 1 and cmpFn(item, list[pos - 1]) do
			pos -= 1
		end
		table.insert(list, pos, item)
		if #list > 6 then
			list[#list] = nil
		end
	end

	local topPets, topEggs = {}, {}
	local petCmp = function(a: any, b: any)
		return a.Rate > b.Rate or (a.Rate == b.Rate and a.Uid < b.Uid)
	end
	local eggCmp = function(a: any, b: any)
		return a.Rank > b.Rank or (a.Rank == b.Rank and (a.Size > b.Size or (a.Size == b.Size and a.Uid < b.Uid)))
	end

	local placedCount = 0
	for _ in pairs(type(save.EquippedAssets) == "table" and save.EquippedAssets or {}) do
		placedCount += 1
	end
	local petCount = 0
	for uid, rec in pairs(type(save.Inventory) == "table" and save.Inventory or {}) do
		if type(rec) == "table" then
			petCount += 1
			insertTop6(topPets, buildTopObj(HudPetObjCache, tostring(uid), rec, tostring(rec.Category or ""), rec.Scale, 1), petCmp)
		end
	end
	local eggCount, growCount = 0, 0
	local eggsTbl = save.EggInventory or save.Eggs or save.Assets or {}
	for uid, rec in pairs(type(eggsTbl) == "table" and eggsTbl or {}) do
		if type(rec) == "table" then
			eggCount += 1
			if rec.Placement then
				growCount += 1
			end
			insertTop6(HudEggObjCache, tostring(uid), rec, tostring(rec.AssetCategory or ""), rec.AssetScale, 0), eggCmp)
		end
	end

	HudStatsCache.Pets = petCount
	HudStatsCache.Placed = placedCount
	HudStatsCache.Eggs = eggCount
	HudStatsCache.Grow = growCount
	HudStatsCache["Top Pets"] = topPets
	HudStatsCache["Top Eggs"] = topEggs
	HudStatsCache.Tread = nil
	pcall(function()
		local treadMod = Core.Modules and Core.Modules.Tread
		local lv = tonumber(save.TreadmillUpgradeLevel) or 0
		local curTm = type(treadMod) == "table" and type(treadMod.GetByUpgradeLevel) == "function" and treadMod.GetByUpgradeLevel(lv)
		if type(curTm) == "table" then
			local nextTm = treadMod.GetByUpgradeLevel(lv + 1)
			local function cleanTm(t: any): string
				return tostring(t.DisplayName or t._id or "Treadmill"):gsub("%s*Treadmill$", "")
			end
			HudStatsCache.Tread = {
				Name = cleanTm(curTm),
				Mult = tonumber(curTm.SpeedMultiplier) or 1,
				Icon = curTm.Icon and tostring(curTm.Icon) or "rbxassetid://70598530577515",
				Note = type(nextTm) == "table" and ("next " .. cleanTm(nextTm) .. " $" .. formatCompact(tonumber(nextTm.Price) or 0)) or "max treadmill",
			}
		end
	end)
	return HudStatsCache
end

local function readEggGrowText(uid: string, rec: any): string
	if type(rec.Placement) ~= "table" then
		return ""
	end
	if rec.Placement.ReadyAt ~= nil then
		return "Ready"
	end
	local okR, rem = pcall(function()
		local recMod = Core.Modules and Core.Modules.Rec
		local eggMod = Core.Modules and Core.Modules.Egg
		local owned = type(eggMod) == "table" and type(eggMod.ReadOwnedEgg) == "function" and eggMod.ReadOwnedEgg(TRex.LocalPlayer.UserId, uid)
		local target = (type(owned) == "table" and owned.Placement) and owned or rec
		local mult = (type(owned) == "table" and tonumber(owned.GrowthSpeedMultiplier)) or 1
		local nowS = Core.getServerNow()
		return recMod.WallSecondsRemaining(target, nowS, mult, recMod.CurrentNightCredit(target, nowS, mult, TRex.LocalPlayer))
	end)
	if okR and type(rem) == "number" then
		return rem <= 0 and "Ready" or formatClockShort(rem)
	end
	return ""
end

local function setCardRarityGradients(card: any, meta: any)
	for _, g in ipairs(card.G) do
		g:Destroy()
	end
	card.G = {}
	local pal = meta and meta.RarityPalette or DETAIL_PALETTE
	local function addGrad(target: Instance, rot: number?)
		local g = Instance.new("UIGradient")
		g.Rotation = rot or pal.r or 90
		g.Color = pal.t
		g.Parent = target
		table.insert(card.G, g)
	end
	addGrad(card.Stroke, 45)
	addGrad(card.Rarity, 90)
	if card.Glow then
		addGrad(card.Glow, 90)
	end
end

local function getHudScaleFactor(): number
	local cam = Workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	if vp.Y < 1 then
		vp = Vector2.new(1280, 720)
	end
	local pct = math.clamp((tonumber(TRex.Config.FarmHudSize) or 90) / 100, 0.5, 1.2)
	return math.clamp(math.min(vp.Y / 900, vp.X / 1500), 0.6, 1.7) * pct
end

local function clampPanelInViewport(panel: Frame, useHeaderMargin: boolean)
	if not HudGui then
		return
	end
	local vpSz = HudGui.AbsoluteSize
	if vpSz.X <= 0 or vpSz.Y <= 0 then
		return
	end
	local relPos = panel.AbsolutePosition - HudGui.AbsolutePosition
	local sz = panel.AbsoluteSize
	local topMargin = useHeaderMargin and math.floor(14 * getHudScaleFactor()) or 0
	local dx = relPos.X < 0 and -relPos.X or (relPos.X + sz.X > vpSz.X and vpSz.X - sz.X - relPos.X or 0)
	local dy = (relPos.Y - topMargin < 0) and (topMargin - relPos.Y) or (relPos.Y + sz.Y > vpSz.Y and vpSz.Y - sz.Y - relPos.Y or 0)
	if dx ~= 0 or dy ~= 0 then
		panel.Position += UDim2.fromOffset(math.floor(dx), math.floor(dy))
	end
end

local function syncHudHideUI(show: boolean)
	local optMod = TRex.Optimizer
	if optMod and type(optMod.setExternalHideUI) == "function" then
		optMod.setExternalHideUI(show)
	elseif optMod and type(optMod.applyHideGameUI) == "function" and not TRex.Config.HideGameUI then
		optMod.applyHideGameUI(show)
	end
end

local function destroyFarmHUD()
	disconnectList(HudConns)
	HudBuilt = false
	if HudGui then
		pcall(function()
			HudGui:Destroy()
		end)
		HudGui = nil
	end
	table.clear(HudPanels)
	table.clear(HudItemViews)
	table.clear(HudShowcaseSets)
	table.clear(HudHistoryRows)
	table.clear(HudScales)
	HudHistoryPanel = nil
	HudHeaderFPS = nil
	HudHeaderPing = nil
	HudLastFPSVal = -1
	HudLastPingVal = -1
	syncHudHideUI(false)
end

local HUD_COL_DEF = {
	{
		Id = "Economy", Col = "Left",
		c1 = Color3.fromRGB(60, 255, 0), c2 = Color3.fromRGB(136, 255, 0),
		Items = {
			{ Id = "Money", Icon = "rbxassetid://70598530577515", a = Color3.fromRGB(150, 255, 110), b = Color3.fromRGB(26, 220, 0), Read = function()
				local str = readLeaderstatStr("Money")
				local num = readLeaderstatNum("Money")
				if num then
					HudBaseMoney = HudBaseMoney or num
				end
				return str or "-", (num and HudBaseMoney) and computePerHourRate(num - HudBaseMoney) or ""
			end },
			{ Id = "Income", Icon = "rbxassetid://70598530577515", a = Color3.fromRGB(255, 240, 140), b = Color3.fromRGB(255, 196, 0), Read = function()
				local rate = readLeaderstatNum("Money/s")
				return rate and formatCompact(rate) or "-", rate and ("$" .. formatCompact(rate * 3600) .. "/h") or ""
			end },
			{ Id = "Speed", Icon = "rbxassetid://70598530577515", a = Color3.fromRGB(120, 255, 240), b = Color3.fromRGB(0, 220, 255), Read = function()
				local spd = readLeaderstatNum("Speed")
				if spd then
					HudBaseSpeed = HudBaseSpeed or spd
				end
				return spd and formatCompact(spd) or "-", (spd and HudBaseSpeed) and computePerHourRate(spd - HudBaseSpeed) or ""
			end },
			{ Id = "Treadmill", Icon = "rbxassetid://70598530577515", a = Color3.fromRGB(255, 255, 255), b = Color3.fromRGB(170, 230, 255), Read = function()
				local t = readHudCollectionStats().Tread
				if not t then
					return "-", ""
				end
				local m = t.Mult
				return t.Name .. "  x" .. (m < 100000 and tostring(math.floor(m + 0.5)) or formatCompact(m)), t.Note, t.Icon
			end },
		},
	},
	{
		Id = "Stealing", Col = "Left",
		c1 = Color3.fromRGB(255, 0, 4), c2 = Color3.fromRGB(255, 83, 86),
		Items = {
			{ Id = "Eggs Stolen", Icon = "rbxassetid://90325592797235", a = Color3.fromRGB(255, 150, 150), b = Color3.fromRGB(255, 40, 60), Read = function()
				return formatCompact(TotalStolenCount), SessionStolenCount > 0 and ("+" .. tostring(SessionStolenCount) .. " this session") or ""
			end },
			{ Id = "Best Steal", Icon = "rbxassetid://90325592797235", a = Color3.fromRGB(225, 195, 255), b = Color3.fromRGB(160, 100, 240), Read = function()
				if not BestStealRecord then
					return "None yet", ""
				end
				local meta = getEggAssetMeta(BestStealRecord.Category)
				return tostring(BestStealRecord.Name), tostring(BestStealRecord.Rarity or ""), meta.Icon
			end },
		},
	},
	{
		Id = "World", Col = "Right",
		c1 = Color3.fromRGB(70, 110, 255), c2 = Color3.fromRGB(140, 190, 255),
		Items = {
			{ Id = "Night Timer", Icon = "rbxassetid://90325592797235", a = Color3.fromRGB(255, 255, 255), b = Color3.fromRGB(200, 212, 255), Read = function()
				return readLeaderstatStr("NightTimer") or "-", "eggs reset"
			end },
			{ Id = "Session Time", Icon = "rbxassetid://90325592797235", a = Color3.fromRGB(255, 255, 255), b = Color3.fromRGB(215, 215, 230), Read = function()
				return formatClockShort(os.clock() - HudStartAt), tostring(#Players:GetPlayers()) .. " players"
			end },
		},
	},
	{
		Id = "Status", Col = "Center",
		c1 = Color3.fromRGB(255, 204, 0), c2 = Color3.fromRGB(255, 150, 30),
		Items = {
			{ Id = "Activity", Wide = true, Icon = "rbxassetid://90325592797235", a = Color3.fromRGB(255, 240, 170), b = Color3.fromRGB(255, 170, 60), Read = function()
				local mover = Core.getActiveMover and Core.getActiveMover() or nil
				local status = tostring(TRex.State.StealStatus or "")
				if Core.isCarryingEgg and Core.isCarryingEgg() then
					return status ~= "" and status or "Carrying egg", "Stealing  |  carrying"
				end
				if mover == "Steal" then
					return status ~= "" and status or "Running Auto Steal", "Stealing"
				elseif TRex.Config.AutoTreadmill then
					return "Running on treadmill", "Treadmill"
				elseif TRex.Config.AutoFishing then
					return "Fishing in lagoon", "Alien Fishing"
				end
				return status ~= "" and status or "Ready", mover or "Idle"
			end },
		},
	},
	{
		Id = "Collection", Col = "Right",
		c1 = Color3.fromRGB(255, 116, 16), c2 = Color3.fromRGB(255, 185, 87),
		Items = {
			{ Id = "Pets", Icon = "rbxassetid://90325592797235", a = Color3.fromRGB(255, 225, 170), b = Color3.fromRGB(255, 150, 60), Read = function()
				local st = readHudCollectionStats()
				return tostring(st.Pets or 0), tostring(st.Placed or 0) .. " placed"
			end },
			{ Id = "Eggs", Icon = "rbxassetid://90325592797235", a = Color3.fromRGB(255, 200, 200), b = Color3.fromRGB(255, 90, 100), Read = function()
				local st = readHudCollectionStats()
				local readyCount = 0
				local lp = TRex.LocalPlayer
				local pGui = lp and lp:FindFirstChildOfClass("PlayerGui")
				local rn = pGui and pGui:FindFirstChild("ReadyNotification", true)
				local lbl = rn and rn:FindFirstChildWhichIsA("TextLabel", true)
				if rn and (rn :: GuiObject).Visible and lbl then
					readyCount = tonumber(lbl.Text) or 0
				end
				return tostring(st.Eggs or 0), string.format("%d ready  %d growing", readyCount, st.Grow or 0)
			end },
		},
	},
}

local function makeHudText(parent: Instance, sz: number, props: { [string]: any }, thinStroke: boolean?): TextLabel
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = COLOR_WHITE
	lbl.TextSize = sz
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextTruncate = Enum.TextTruncate.AtEnd
	lbl.Text = ""
	lbl.FontFace = FONT_BODY
	lbl.Parent = parent
	for k, v in pairs(props) do
		(lbl :: any)[k] = v
	end
	local st = Instance.new("UIStroke")
	st.Color = COLOR_BLACK
	st.Thickness = thinStroke and 1.8 or 2.4
	st.LineJoinMode = Enum.LineJoinMode.Round
	st.Parent = lbl
	return lbl
end

local function makeHudPill(parent: Instance, txt: string, col1: Color3, col2: Color3, order: number, fontSize: number)
	local fr = Instance.new("Frame")
	fr.BackgroundTransparency = 1
	fr.AutomaticSize = Enum.AutomaticSize.X
	fr.LayoutOrder = order
	fr.Size = UDim2.fromOffset(0, fontSize + 5)
	fr.Visible = false
	fr.Parent = parent
	local lbl = makeHudText(fr, fontSize, {
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextTruncate = Enum.TextTruncate.None,
	})
	local g = Instance.new("UIGradient")
	g.Rotation = 90
	g.Color = ColorSequence.new(col1, col2)
	g.Parent = lbl
	return { F = fr, Text = lbl, Last = "" }
end

local function setHudPill(pill: any, text: any)
	local s = text ~= nil and tostring(text) or ""
	if pill.Last ~= s then
		pill.Last = s
		pill.Text.Text = s
		pill.F.Visible = s ~= ""
	end
end

local function wireHudPanelDrag(panel: Frame, panelId: string)
	local dragging = false
	local dragInput: InputObject? = nil
	local startMouse = Vector2.zero
	local startPos = UDim2.new()
	local grip = Instance.new("TextButton")
	grip.Active = true
	grip.AutoButtonColor = false
	grip.BackgroundTransparency = 1
	grip.Position = UDim2.fromOffset(-12, -36)
	grip.Size = UDim2.new(1, 24, 1, 45)
	grip.Text = ""
	grip.ZIndex = 30
	grip.Parent = panel

	table.insert(HudConns, grip.InputBegan:Connect(function(inp)
		if dragging or inp.UserInputState ~= Enum.UserInputState.Begin then
			return
		end
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragInput = inp.UserInputType == Enum.UserInputType.Touch and inp or nil
			startMouse = Vector2.new(inp.Position.X, inp.Position.Y)
			startPos = panel.Position
		end
	end))
	table.insert(HudConns, UserInputService.InputChanged:Connect(function(inp)
		local match = dragging and ((dragInput and inp == dragInput) or (not dragInput and inp.UserInputType == Enum.UserInputType.MouseMovement))
		if match then
			local delta = Vector2.new(inp.Position.X, inp.Position.Y) - startMouse
			panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			clampPanelInViewport(panel, true)
		end
	end))
	table.insert(HudConns, UserInputService.InputEnded:Connect(function(inp)
		local match = dragging and ((dragInput and inp == dragInput) or (not dragInput and inp.UserInputType == Enum.UserInputType.MouseButton1))
		if match then
			dragging = false
			dragInput = nil
			local pos = panel.Position
			getHudPositionsTable()[panelId] = {
				XScale = pos.X.Scale,
				XOffset = pos.X.Offset,
				YScale = pos.Y.Scale,
				YOffset = pos.Y.Offset,
				Unit = getHudScaleFactor(),
				Top = 16,
			}
			TRex.saveConfig(TRex.CurrentProfileName)
		end
	end))
end

local function createHudPanel(parentGui: ScreenGui, id: string, col: string, c1: Color3, c2: Color3, order: number)
	local fr = Instance.new("Frame")
	fr.Active = true
	fr.AnchorPoint = Vector2.new(col == "Left" and 1 or (col == "Right" and 0 or 0.5), 0)
	fr.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
	fr.BackgroundTransparency = 0.22
	fr.BorderSizePixel = 0
	fr.AutomaticSize = Enum.AutomaticSize.XY
	fr.Size = UDim2.fromOffset(0, 0)
	fr.Parent = parentGui
	local cr = Instance.new("UICorner")
	cr.CornerRadius = UDim.new(0, 14)
	cr.Parent = fr
	local st = Instance.new("UIStroke")
	st.Color = Color3.fromRGB(82, 82, 107)
	st.Thickness = 1.6
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	st.Transparency = 0.3
	st.Parent = fr
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 24)
	pad.PaddingBottom = UDim.new(0, 9)
	pad.PaddingLeft = UDim.new(0, 12)
	pad.PaddingRight = UDim.new(0, 12)
	pad.Parent = fr
	local sc = Instance.new("UIScale")
	sc.Parent = fr
	table.insert(HudScales, sc)

	local tag = Instance.new("Frame")
	tag.BackgroundColor3 = COLOR_WHITE
	tag.BorderSizePixel = 0
	tag.AutomaticSize = Enum.AutomaticSize.X
	tag.Position = UDim2.fromOffset(-2, -36)
	tag.Size = UDim2.fromOffset(0, 24)
	tag.Parent = fr
	local tcr = Instance.new("UICorner")
	tcr.CornerRadius = UDim.new(0, 8)
	tcr.Parent = tag
	local tst = Instance.new("UIStroke")
	tst.Color = COLOR_BLACK
	tst.Thickness = 2
	tst.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	tst.Transparency = 0.15
	tst.Parent = tag
	local tg = Instance.new("UIGradient")
	tg.Rotation = -90
	tg.Color = ColorSequence.new(c1, c2)
	tg.Parent = tag
	local tpad = Instance.new("UIPadding")
	tpad.PaddingLeft = UDim.new(0, 10)
	tpad.PaddingRight = UDim.new(0, 10)
	tpad.Parent = tag
	makeHudText(tag, 15, { AutomaticSize = Enum.AutomaticSize.X, Text = id:upper(), Size = UDim2.fromOffset(0, 24), TextTruncate = Enum.TextTruncate.None })

	local body = Instance.new("Frame")
	body.BackgroundTransparency = 1
	body.AutomaticSize = Enum.AutomaticSize.XY
	body.Size = UDim2.fromOffset(0, 0)
	body.Parent = fr

	local rec = { Id = id, F = fr, Col = col, Order = order, Body = body }
	table.insert(HudPanels, rec)
	wireHudPanelDrag(fr, id)
	return rec
end

local function layoutAllHudPanels()
	if not HudGui then
		return
	end
	local sf = getHudScaleFactor()
	for _, sc in ipairs(HudScales) do
		sc.Scale = sf
	end
	task.defer(function()
		if not HudGui or not HudBuilt then
			return
		end
		local centerMaxW = 0
		for _, p in ipairs(HudPanels) do
			if p.Col == "Center" and p.F.Visible then
				centerMaxW = math.max(centerMaxW, p.F.AbsoluteSize.X)
			end
		end
		local hdr = HudPanels[1].F :: Frame
		hdr.Position = UDim2.new(0.5, 0, 0, 16)
		local y0 = 16 + hdr.AbsoluteSize.Y + math.floor(46 * sf)
		local colY: { [string]: number } = { Left = y0, Right = y0, Center = y0 }
		local colX = math.floor(centerMaxW / 2 + 26 * sf)
		local cam = Workspace.CurrentCamera
		local vpH = cam and cam.ViewportSize.Y or 720
		local savedPos = getHudPositionsTable()
		for i = 2, #HudPanels do
			local p = HudPanels[i]
			local sp = savedPos[p.Id]
			if type(sp) == "table" and type(sp.XOffset) == "number" and type(sp.YOffset) == "number" then
				local ratio = (type(sp.Unit) == "number" and sp.Unit > 0) and (sf / sp.Unit) or 1
				p.F.Position = UDim2.new(
					tonumber(sp.XScale) or 0,
					math.floor(sp.XOffset * ratio + 0.5),
					0,
					math.floor(16 + ((tonumber(sp.YScale) or 0) * vpH + sp.YOffset - (tonumber(sp.Top) or 16)) * ratio + 0.5)
				)
			else
				local y = colY[p.Col] or y0
				local xOff = (p.Col == "Left") and -colX or (p.Col == "Right" and colX or 0)
				p.F.Position = UDim2.new(0.5, xOff, 0, y)
			end
			if p.F.Visible then
				colY[p.Col] = (colY[p.Col] or y0) + p.F.AbsoluteSize.Y + math.floor(42 * sf)
			end
		end
		for _, p in ipairs(HudPanels) do
			clampPanelInViewport(p.F, true)
		end
	end)
end

local function createShowcaseCard(parent: Instance, order: number)
	local fr = Instance.new("Frame")
	fr.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
	fr.BackgroundTransparency = 0.02
	fr.BorderSizePixel = 0
	fr.LayoutOrder = order
	fr.Size = UDim2.fromOffset(180, 200)
	fr.Visible = false
	fr.Parent = parent
	local cr = Instance.new("UICorner")
	cr.CornerRadius = UDim.new(0, 14)
	cr.Parent = fr
	local st = Instance.new("UIStroke")
	st.Color = COLOR_WHITE
	st.Thickness = 3
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	st.Parent = fr
	local glow = Instance.new("Frame")
	glow.BackgroundColor3 = COLOR_WHITE
	glow.BackgroundTransparency = 0.7
	glow.BorderSizePixel = 0
	glow.Size = UDim2.new(1, 0, 0, 136)
	glow.Parent = fr
	local gcr = Instance.new("UICorner")
	gcr.CornerRadius = UDim.new(0, 14)
	gcr.Parent = glow

	local img = Instance.new("ImageLabel")
	img.BackgroundTransparency = 1
	img.AnchorPoint = Vector2.new(0.5, 0)
	img.Position = UDim2.new(0.5, 0, 0, 6)
	img.Size = UDim2.fromOffset(126, 126)
	img.ScaleType = Enum.ScaleType.Fit
	img.Parent = fr

	local rkBox = Instance.new("Frame")
	rkBox.BackgroundColor3 = COLOR_BLACK
	rkBox.BackgroundTransparency = 0.25
	rkBox.BorderSizePixel = 0
	rkBox.Position = UDim2.fromOffset(7, 7)
	rkBox.Size = UDim2.fromOffset(32, 24)
	rkBox.Parent = fr
	local rcr = Instance.new("UICorner")
	rcr.CornerRadius = UDim.new(0, 7)
	rcr.Parent = rkBox
	local rankLbl = makeHudText(rkBox, 15, { Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center })
	local muLbl = makeHudText(fr, 13, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -7, 0, 10), Size = UDim2.new(1, -46, 0, 16), TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = Color3.fromRGB(255, 230, 120) })

	local topRow = Instance.new("Frame")
	topRow.BackgroundTransparency = 1
	topRow.Position = UDim2.new(0, 4, 0, 135)
	topRow.Size = UDim2.new(1, -8, 0, 20)
	topRow.Parent = fr
	local tl = Instance.new("UIListLayout")
	tl.FillDirection = Enum.FillDirection.Horizontal
	tl.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tl.VerticalAlignment = Enum.VerticalAlignment.Center
	tl.SortOrder = Enum.SortOrder.LayoutOrder
	tl.Padding = UDim.new(0, 5)
	tl.Parent = topRow
	local nameLbl = makeHudText(topRow, 17, { AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 1, Size = UDim2.fromOffset(0, 21) })
	local scLim = Instance.new("UISizeConstraint")
	scLim.MaxSize = Vector2.new(108, 21)
	scLim.Parent = nameLbl
	local sizePill = makeHudPill(topRow, "Size", Color3.fromRGB(255, 244, 200), Color3.fromRGB(235, 190, 95), 2, 16)

	local rarLbl = makeHudText(fr, 15, { Position = UDim2.fromOffset(6, 155), Size = UDim2.new(1, -12, 0, 16), TextXAlignment = Enum.TextXAlignment.Center })
	local botRow = Instance.new("Frame")
	botRow.BackgroundTransparency = 1
	botRow.Position = UDim2.new(0, 4, 0, 172)
	botRow.Size = UDim2.new(1, -8, 0, 23)
	botRow.Parent = fr
	local bl = Instance.new("UIListLayout")
	bl.FillDirection = Enum.FillDirection.Horizontal
	bl.HorizontalAlignment = Enum.HorizontalAlignment.Center
	bl.VerticalAlignment = Enum.VerticalAlignment.Center
	bl.SortOrder = Enum.SortOrder.LayoutOrder
	bl.Padding = UDim.new(0, 5)
	bl.Parent = botRow
	local valPill = makeHudPill(botRow, "Value", Color3.fromRGB(170, 255, 140), Color3.fromRGB(40, 230, 90), 1, 18)
	local timePill = makeHudPill(botRow, "Time", Color3.fromRGB(255, 200, 170), Color3.fromRGB(255, 120, 80), 2, 16)

	return { F = fr, Stroke = st, Glow = glow, Image = img, Rank = rankLbl, Mu = muLbl, Name = nameLbl, Rarity = rarLbl, SC = sizePill, VC = valPill, HC = timePill, G = {}, Key = "" }
end

local function createHistoryRow(parent: Instance, order: number)
	local fr = Instance.new("Frame")
	fr.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
	fr.BackgroundTransparency = 0.25
	fr.BorderSizePixel = 0
	fr.LayoutOrder = order
	fr.Size = UDim2.fromOffset(330, 52)
	fr.Visible = false
	fr.Parent = parent
	local cr = Instance.new("UICorner")
	cr.CornerRadius = UDim.new(0, 10)
	cr.Parent = fr
	local st = Instance.new("UIStroke")
	st.Color = COLOR_WHITE
	st.Thickness = 2
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	st.Parent = fr
	local img = Instance.new("ImageLabel")
	img.BackgroundTransparency = 1
	img.Position = UDim2.fromOffset(4, 3)
	img.Size = UDim2.fromOffset(46, 46)
	img.ScaleType = Enum.ScaleType.Fit
	img.Parent = fr
	local topRow = Instance.new("Frame")
	topRow.BackgroundTransparency = 1
	topRow.Position = UDim2.fromOffset(52, 3)
	topRow.Size = UDim2.new(1, -146, 0, 22)
	topRow.Parent = fr
	local tl = Instance.new("UIListLayout")
	tl.FillDirection = Enum.FillDirection.Horizontal
	tl.VerticalAlignment = Enum.VerticalAlignment.Center
	tl.SortOrder = Enum.SortOrder.LayoutOrder
	tl.Padding = UDim.new(0, 5)
	tl.Parent = topRow
	local nameLbl = makeHudText(topRow, 17, { AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 1, Size = UDim2.fromOffset(0, 21) })
	local sizePill = makeHudPill(topRow, "Size", Color3.fromRGB(255, 244, 200), Color3.fromRGB(235, 190, 95), 2, 16)

	local botRow = Instance.new("Frame")
	botRow.BackgroundTransparency = 1
	botRow.Position = UDim2.fromOffset(52, 27)
	botRow.Size = UDim2.new(1, -146, 0, 22)
	botRow.Parent = fr
	local bl = Instance.new("UIListLayout")
	bl.FillDirection = Enum.FillDirection.Horizontal
	bl.VerticalAlignment = Enum.VerticalAlignment.Center
	bl.SortOrder = Enum.SortOrder.LayoutOrder
	bl.Padding = UDim.new(0, 5)
	bl.Parent = botRow
	local rarLbl = makeHudText(botRow, 14, { AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 1, Size = UDim2.fromOffset(0, 18), TextTruncate = Enum.TextTruncate.None })
	local valPill = makeHudPill(botRow, "Value", Color3.fromRGB(170, 255, 140), Color3.fromRGB(40, 230, 90), 2, 16)
	local whenLbl = makeHudText(fr, 15, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(84, 20), TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = Color3.fromRGB(255, 194, 77) })

	return { F = fr, Stroke = st, Image = img, Name = nameLbl, Rarity = rarLbl, SC = sizePill, VC = valPill, When = { L = whenLbl, Last = "" }, G = {}, Key = "" }
end

local function buildFarmHUD()
	destroyFarmHUD()
	local sg = Instance.new("ScreenGui")
	sg.Name = "TRex_FarmHUD"
	sg.Archivable = false
	sg.DisplayOrder = -101
	sg.IgnoreGuiInset = true
	sg.ResetOnSpawn = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.Parent = getGuiRoot()
	HudGui = sg

	-- Header banner
	local hdr = Instance.new("Frame")
	hdr.Active = true
	hdr.AnchorPoint = Vector2.new(0.5, 0)
	hdr.BackgroundColor3 = Color3.fromRGB(20, 18, 24)
	hdr.BackgroundTransparency = 0.12
	hdr.BorderSizePixel = 0
	hdr.Size = UDim2.fromOffset(470, 62)
	hdr.Parent = sg
	local hcr = Instance.new("UICorner")
	hcr.CornerRadius = UDim.new(0, 16)
	hcr.Parent = hdr
	local hst = Instance.new("UIStroke")
	hst.Color = COLOR_WHITE
	hst.Thickness = 2.4
	hst.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	hst.Parent = hdr
	local hg = Instance.new("UIGradient")
	hg.Color = ColorSequence.new(Color3.fromRGB(255, 196, 60), Color3.fromRGB(255, 60, 40))
	hg.Parent = hst
	local hsc = Instance.new("UIScale")
	hsc.Parent = hdr
	table.insert(HudScales, hsc)

	local tLbl = makeHudText(hdr, 24, { Text = "T-REX HUB", Position = UDim2.fromOffset(16, 8), Size = UDim2.fromOffset(250, 26) })
	local tg = Instance.new("UIGradient")
	tg.Rotation = 90
	tg.Color = ColorSequence.new(Color3.fromRGB(255, 226, 120), Color3.fromRGB(255, 80, 40))
	tg.Parent = tLbl
	makeHudText(hdr, 12, { Text = "FARM STATS  |  STEAL AN EGG", TextColor3 = Color3.fromRGB(190, 194, 210), Position = UDim2.fromOffset(17, 36), Size = UDim2.fromOffset(250, 16) }, true)

	local div = Instance.new("Frame")
	div.BackgroundColor3 = COLOR_WHITE
	div.BackgroundTransparency = 0.82
	div.BorderSizePixel = 0
	div.Position = UDim2.fromOffset(282, 12)
	div.Size = UDim2.fromOffset(2, 38)
	div.Parent = hdr
	local dcr = Instance.new("UICorner")
	dcr.CornerRadius = UDim.new(1, 0)
	dcr.Parent = div

	HudHeaderFPS = makeHudText(hdr, 26, { Position = UDim2.fromOffset(296, 6), Size = UDim2.fromOffset(78, 30), TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = Color3.fromRGB(58, 255, 55) })
	makeHudText(hdr, 12, { Text = "FPS", TextColor3 = Color3.fromRGB(190, 194, 210), Position = UDim2.fromOffset(296, 38), Size = UDim2.fromOffset(78, 14), TextXAlignment = Enum.TextXAlignment.Center }, true)
	HudHeaderPing = makeHudText(hdr, 26, { Position = UDim2.fromOffset(380, 6), Size = UDim2.fromOffset(80, 30), TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = Color3.fromRGB(58, 255, 55) })
	makeHudText(hdr, 12, { Text = "PING MS", TextColor3 = Color3.fromRGB(190, 194, 210), Position = UDim2.fromOffset(380, 38), Size = UDim2.fromOffset(80, 14), TextXAlignment = Enum.TextXAlignment.Center }, true)

	HudPanels[1] = { F = hdr, Col = "Header", Order = 0, Id = "Header" }

	for idx, colDef in ipairs(HUD_COL_DEF) do
		local panel = createHudPanel(sg, colDef.Id, colDef.Col, colDef.c1, colDef.c2, idx)
		local ll = Instance.new("UIListLayout")
		ll.SortOrder = Enum.SortOrder.LayoutOrder
		ll.Padding = UDim.new(0, 4)
		ll.Parent = panel.Body
		for itemOrder, item in ipairs(colDef.Items) do
			local row = Instance.new("Frame")
			row.BackgroundTransparency = 1
			row.LayoutOrder = itemOrder
			row.Size = UDim2.fromOffset((item :: any).Wide and 380 or 250, 46)
			row.Parent = panel.Body
			local ic = Instance.new("ImageLabel")
			ic.BackgroundTransparency = 1
			ic.Image = item.Icon
			ic.Position = UDim2.fromOffset(0, 2)
			ic.Size = UDim2.fromOffset(42, 42)
			ic.ScaleType = Enum.ScaleType.Fit
			ic.Parent = row
			local cap = makeHudText(row, 13, { RichText = true, Text = item.Id:upper(), TextColor3 = Color3.fromRGB(190, 194, 210), Position = UDim2.fromOffset(50, 3), Size = UDim2.new(1, -50, 0, 14) }, true)
			local val = makeHudText(row, (item :: any).Wide and 18 or 24, { Position = UDim2.fromOffset(50, 18), Size = UDim2.new(1, -50, 0, 26) })
			local vg = Instance.new("UIGradient")
			vg.Rotation = 90
			vg.Color = ColorSequence.new(item.a, item.b)
			vg.Parent = val
			HudItemViews[item.Id] = { Icon = ic, Value = val, Cap = cap, Title = item.Id:upper(), Item = item, LV = "", LQ = "", LI = item.Icon }
		end
	end

	local showMeta = {
		{ Id = "Top Pets", IsEgg = false, c1 = Color3.fromRGB(255, 116, 16), c2 = Color3.fromRGB(255, 185, 87) },
		{ Id = "Top Eggs", IsEgg = true, c1 = Color3.fromRGB(255, 0, 4), c2 = Color3.fromRGB(255, 83, 86) },
	}
	for idx, sm in ipairs(showMeta) do
		local p = createHudPanel(sg, sm.Id, "Center", sm.c1, sm.c2, 100 + idx)
		local hl = Instance.new("UIListLayout")
		hl.FillDirection = Enum.FillDirection.Horizontal
		hl.SortOrder = Enum.SortOrder.LayoutOrder
		hl.Padding = UDim.new(0, 10)
		hl.Parent = p.Body
		local cards = {}
		for k = 1, 6 do
			cards[k] = createShowcaseCard(p.Body, k)
		end
		table.insert(HudShowcaseSets, { Panel = p, IsEgg = sm.IsEgg, Id = sm.Id, Cards = cards })
	end

	HudHistoryPanel = createHudPanel(sg, "Steal History", "Left", Color3.fromRGB(255, 60, 90), Color3.fromRGB(255, 140, 160), 2.5)
	local hll = Instance.new("UIListLayout")
	hll.SortOrder = Enum.SortOrder.LayoutOrder
	hll.Padding = UDim.new(0, 6)
	hll.Parent = HudHistoryPanel.Body
	for k = 1, 7 do
		HudHistoryRows[k] = createHistoryRow(HudHistoryPanel.Body, k)
	end
	HudHistoryPanel.EmptyLbl = makeHudText(HudHistoryPanel.Body, 16, { LayoutOrder = 99, Text = "No steals yet", TextColor3 = Color3.fromRGB(190, 194, 210), Size = UDim2.fromOffset(330, 30) })

	table.sort(HudPanels, function(a, b)
		return a.Order < b.Order
	end)
	local cam = Workspace.CurrentCamera
	if cam then
		table.insert(HudConns, cam:GetPropertyChangedSignal("ViewportSize"):Connect(layoutAllHudPanels))
	end
	HudBuilt = true
	HudDirtyCards = true
	layoutAllHudPanels()
	syncHudHideUI(TRex.Config.FarmHudHideGameUI == true)
end

local function refreshHudCardsAndHistory()
	if not HudBuilt then
		return
	end
	local statsData = readHudCollectionStats()
	local maxCards = math.clamp(math.floor(tonumber(TRex.Config.FarmHudCards) or 4), 1, 6)
	local usePetImage = TRex.Config.FarmHudEggImage == "Pet Image"

	for _, scSet in ipairs(HudShowcaseSets) do
		local list = statsData[scSet.Id] or {}
		for k, card in ipairs(scSet.Cards) do
			local obj = list[k]
			if obj and k <= maxCards then
				card.F.Visible = true
				local ck = tostring(obj.Uid) .. "|" .. tostring(k) .. "|" .. tostring(usePetImage)
				if card.Key ~= ck then
					card.Key = ck
					setCardRarityGradients(card, obj.Meta)
					card.Image.Image = scSet.IsEgg and readEggIcon(obj.Rec, usePetImage) or tostring(obj.Meta.PetIcon or obj.Meta.Icon or "")
					card.Rank.Text = "#" .. tostring(k)
					local mutStr = type(obj.Mut) == "table" and table.concat(obj.Mut, " ") or ""
					card.Mu.Text = mutStr
					card.Name.Text = tostring(obj.Meta.DisplayName or obj.Cat)
					card.Rarity.Text = tostring(obj.Meta.RarityName or ""):upper()
				end
				setHudPill(card.VC, "$" .. formatCompact(obj.Rate) .. "/s")
				setHudPill(card.SC, string.format("x%.2f", obj.Size))
				setHudPill(card.HC, scSet.IsEgg and readEggGrowText(obj.Uid, obj.Rec) or "")
			else
				card.F.Visible = false
			end
		end
	end

	if HudHistoryPanel then
		local anyHist = false
		for k, row in ipairs(HudHistoryRows) do
			local st = StealHistory[k]
			if st and k <= maxCards + 1 then
				anyHist = true
				row.F.Visible = true
				local hk = tostring(st.At) .. "|" .. tostring(st.Category) .. "|" .. tostring(usePetImage)
				if row.Key ~= hk then
					row.Key = hk
					local meta = getEggAssetMeta(st.Category)
					setCardRarityGradients(row, meta)
					row.Image.Image = usePetImage and tostring(meta.PetIcon or meta.Icon or "") or tostring(meta.Icon or meta.PetIcon or "")
					row.Name.Text = tostring(st.Name or st.Category)
					row.Rarity.Text = tostring(st.Rarity or ""):upper()
					setHudPill(row.VC, st.Value and ("$" .. formatCompact(st.Value) .. "/s") or "")
					setHudPill(row.SC, st.Scale and string.format("x%.2f", st.Scale) or "")
				end
				local ago = math.max(0, os.time() - (tonumber(st.At) or os.time()))
				local agoTxt = ago < 60 and (tostring(ago) .. "s ago") or (ago < 3600 and (tostring(math.floor(ago / 60)) .. "m ago") or (tostring(math.floor(ago / 3600)) .. "h ago"))
				if row.When.Last ~= agoTxt then
					row.When.Last = agoTxt
					row.When.L.Text = agoTxt
				end
			else
				row.F.Visible = false
			end
		end
		if HudHistoryPanel.EmptyLbl then
			HudHistoryPanel.EmptyLbl.Visible = not anyHist
		end
	end
end

local function stepFarmHUD(dt: number)
	if not TRex.Config.ShowFarmHUD then
		if HudBuilt then
			destroyFarmHUD()
		end
		return
	end
	if not HudBuilt then
		buildFarmHUD()
	end
	dt = math.clamp(dt, 0.001, 1)
	HudFPS = (HudFPS <= 0) and (1 / dt) or (HudFPS + (1 / dt - HudFPS) * (1 - math.exp(-dt * 8)))

	local now = os.clock()
	if now >= HudNextFastAt then
		HudNextFastAt = now + 0.5
		local fpsInt = math.floor(HudFPS + 0.5)
		if HudHeaderFPS and fpsInt ~= HudLastFPSVal then
			HudLastFPSVal = fpsInt
			HudHeaderFPS.Text = tostring(fpsInt)
			HudHeaderFPS.TextColor3 = fpsInt >= 100 and Color3.fromRGB(58, 255, 55) or (fpsInt >= 50 and Color3.fromRGB(255, 214, 84) or Color3.fromRGB(255, 96, 96))
		end
		local okP, pingRaw = pcall(function()
			return (Stats.Network :: any).ServerStatsItem["Data Ping"]:GetValue()
		end)
		local pingInt = math.floor((okP and tonumber(pingRaw) or 0) + 0.5)
		if HudHeaderPing and pingInt ~= HudLastPingVal then
			HudLastPingVal = pingInt
			HudHeaderPing.Text = tostring(pingInt)
			HudHeaderPing.TextColor3 = pingInt <= 90 and Color3.fromRGB(58, 255, 55) or (pingInt <= 180 and Color3.fromRGB(255, 214, 84) or Color3.fromRGB(255, 96, 96))
		end

		for _, view in pairs(HudItemViews) do
			local okR, vStr, noteStr, ovIcon = pcall(view.Item.Read)
			if okR then
				local valTxt = tostring(vStr or "-")
				local nTxt = tostring(noteStr or "")
				local icTxt = tostring(ovIcon or view.Item.Icon)
				if valTxt ~= view.LV then
					view.LV = valTxt
					view.Value.Text = valTxt
				end
				if nTxt ~= view.LQ then
					view.LQ = nTxt
					view.Cap.Text = nTxt ~= "" and (view.Title .. "  <font color=\"#a0a4b8\">" .. nTxt .. "</font>") or view.Title
				end
				if icTxt ~= view.LI then
					view.LI = icTxt
					view.Icon.Image = icTxt
				end
			end
		end
	end
	if now >= HudNextCardAt or HudDirtyCards then
		HudNextCardAt = now + 1
		HudDirtyCards = false
		pcall(refreshHudCardsAndHistory)
	end
end

-- =====================================================================
-- 8) Lifecycle, Step Loop & UI Builder
-- =====================================================================
function Render.clearAll()
	Render.clearEggESP()
	Render.clearGuardESP()
	Render.clearPlayerESP(nil)
	Render.clearMarkers()
	Render.clearInventoryValues()
	destroyFarmHUD()
end

function Render.step(dt: number?)
	if not TRex.IsRunning then
		return
	end
	local cfg = TRex.Config
	if cfg.EggESP or cfg.OwnBaseEggESP or cfg.OtherBaseEggESP then
		ensureEggWatchers()
		if os.clock() >= EggLastDistTick then
			EggLastDistTick = os.clock() + 1.0
			Render.scheduleEggRefresh()
		end
	elseif EggGui or next(EggEntries) ~= nil then
		Render.clearEggESP()
	end
	stepGuardESP()
	stepPlayerESPAndTracker()
	stepMarkers()
	stepInventoryValues()
	stepFarmHUD(dt or (1 / 60))
end

function Render.init()
	TRex.registerCleanupHook(Render.clearAll)
	TRex.connectSignal(Players.PlayerRemoving, function(plr)
		Render.clearPlayerESP(plr)
	end)
	local cam = Workspace.CurrentCamera
	if cam then
		TRex.connectSignal(cam:GetPropertyChangedSignal("ViewportSize"), applyAllEggScales)
	end
	TRex.connectSignal(RunService.RenderStepped, function(dt)
		Render.step(dt)
	end)
end

local function buildRarityOptions(): { string }
	local out = { "Any" }
	local seenNum: { [number]: string } = {}
	local nums = {}
	local assets = Core.Modules and Core.Modules.Assets
	local dir = type(assets) == "table" and assets.Directory or nil
	if type(dir) == "table" then
		for _, item in pairs(dir) do
			local r = type(item) == "table" and type(item.Rarity) == "table" and item.Rarity or nil
			local n = r and tonumber(r.RarityNumber or r.Rank) or nil
			if n and not seenNum[n] then
				seenNum[n] = tostring(r.DisplayName or r._id or n)
				table.insert(nums, n)
			end
		end
	end
	if #nums > 0 then
		table.sort(nums)
		for _, n in ipairs(nums) do
			table.insert(out, string.format("%d - %s", n, seenNum[n]))
		end
	else
		for _, name in ipairs(Core.RARITY_ORDER or {}) do
			table.insert(out, name)
		end
	end
	return out
end

function Render.buildUI(ui)
	local tab = ui.addTab("render", "tab.render")

	local espSec = tab:addSection("sec.esp")
	espSec:addToggle({
		key = "EggESP",
		label = "opt.egg_esp",
		onChanged = function(on)
			if on or TRex.Config.OwnBaseEggESP or TRex.Config.OtherBaseEggESP then
				Render.scheduleEggRefresh()
			else
				Render.clearEggESP()
			end
		end,
	})
	espSec:addToggle({
		key = "OwnBaseEggESP",
		label = "opt.own_egg_esp",
		onChanged = function()
			Render.scheduleEggRefresh()
		end,
	})
	espSec:addToggle({
		key = "OtherBaseEggESP",
		label = "opt.other_base_egg_esp",
		onChanged = function()
			Render.scheduleEggRefresh()
		end,
	})
	espSec:addToggle({
		key = "RevealEggContent",
		label = "opt.reveal_egg",
		onChanged = function()
			Render.scheduleEggRefresh()
		end,
	})
	espSec:addDropdown({
		key = "ESPMinRarity",
		label = "opt.esp_min_rarity",
		getItems = buildRarityOptions,
		onChanged = function()
			Render.scheduleEggRefresh()
		end,
	}):When(function()
		return TRex.Config.EggESP or TRex.Config.OwnBaseEggESP or TRex.Config.OtherBaseEggESP
	end)
	espSec:addSlider({
		key = "ESPMinValue",
		label = "opt.esp_min_value",
		log = true,
		logMax = 1e12,
		minText = "Any",
		onChanged = function()
			Render.scheduleEggRefresh()
		end,
	}):When(function()
		return TRex.Config.EggESP or TRex.Config.OwnBaseEggESP or TRex.Config.OtherBaseEggESP
	end)
	espSec:addToggle({
		key = "ESPFixedSize",
		label = "opt.esp_fixed_size",
		onChanged = function()
			applyAllEggScales()
		end,
	}):When(function()
		return TRex.Config.EggESP or TRex.Config.OwnBaseEggESP or TRex.Config.OtherBaseEggESP
	end)
	espSec:addSlider({
		key = "ESPSizePercent",
		label = "opt.esp_size",
		min = 50,
		max = 200,
		step = 5,
		unit = "%",
		onChanged = function()
			applyAllEggScales()
		end,
	})
	espSec:addDropdown({
		key = "ESPShowInfo",
		label = "opt.esp_show_info",
		items = { "Icon", "Name", "Rarity", "Mutation", "Value", "Weight", "Size", "Sell Price", "Distance", "Area", "State" },
		multi = true,
		emptyLabel = "None",
		onChanged = function()
			Render.scheduleEggRefresh()
		end,
	}):When(function()
		return TRex.Config.EggESP or TRex.Config.OwnBaseEggESP or TRex.Config.OtherBaseEggESP
	end)

	local pgSec = tab:addSection("sec.player_guard_esp")
	local plrTog = pgSec:addToggle({ key = "PlayerESP", label = "opt.player_esp" })
	pgSec:addToggle({ key = "PlayerTracker", label = "opt.player_tracker" })
	pgSec:addDropdown({
		key = "ESPPlayerInfo",
		label = "opt.esp_player_info",
		items = { "Name", "Username", "Avatar", "Tool", "Distance", "Carrying" },
		multi = true,
		emptyLabel = "None",
	}):When(plrTog)
	pgSec:addToggle({ key = "GuardESP", label = "opt.guard_esp" })

	local hudSec = tab:addSection("sec.hud_panels")
	hudSec:addToggle({ key = "ShowSafeZoneMarker", label = "opt.safe_marker" })
	hudSec:addToggle({ key = "ShowInventoryValues", label = "opt.inv_values" })
	local hudTog = hudSec:addToggle({
		key = "ShowFarmHUD",
		label = "opt.farm_hud",
		onChanged = function(on)
			if not on then
				destroyFarmHUD()
			end
		end,
	})
	hudSec:addToggle({
		key = "FarmHudHideGameUI",
		label = "opt.farm_hud_hide_ui",
		onChanged = function(on)
			if TRex.Config.ShowFarmHUD then
				syncHudHideUI(on == true)
			end
		end,
	}):When(hudTog)
	hudSec:addSlider({
		key = "FarmHudCards",
		label = "opt.farm_hud_cards",
		min = 1,
		max = 6,
		step = 1,
		onChanged = function()
			HudDirtyCards = true
		end,
	}):When(hudTog)
	hudSec:addSlider({
		key = "FarmHudSize",
		label = "opt.farm_hud_size",
		min = 50,
		max = 120,
		step = 5,
		unit = "%",
		onChanged = function()
			layoutAllHudPanels()
		end,
	}):When(hudTog)
	hudSec:addDropdown({
		key = "FarmHudEggImage",
		label = "opt.farm_hud_image",
		items = { "Egg Image", "Pet Image" },
		onChanged = function()
			HudDirtyCards = true
		end,
	}):When(hudTog)
end
