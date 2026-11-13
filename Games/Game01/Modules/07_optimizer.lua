-- T-RexProject/Games/Game01/Modules/07_optimizer.lua
-- Optimizer & Performance Engine for Game01 (1:1 Temp Parity)
-- Features: Chunked Workspace Optimizer (Balanced/Strong/Max + Controller/Animator Throttle),
-- HideMyEggs/HideOtherEggs, HideTreadmill, Disable 3D Render (White/Black overlay, <=40 FPS, 180s/2s wake),
-- HideGameUI (PlayerGui LayerCollectors + CoreGuiType save/restore), FPS Cap (10..1000),
-- and Draggable EWMA FPS/Ping HUD (auto-suppressed while Farm HUD is open).

local TRex = (_G :: any).TRex

local Players = TRex.Services.Players
local RunService = TRex.Services.RunService
local Lighting = TRex.Services.Lighting
local StarterGui = TRex.Services.StarterGui
local Workspace = TRex.Services.Workspace
local UserInputService = TRex.Services.UserInputService
local CoreGui = TRex.Services.CoreGui
local StatsService = game:GetService("Stats")

local Optimizer = {}
TRex.Optimizer = Optimizer

local SetFpsCapFn = TRex.resolveGlobalFunc("setfpscap")
local GetConnectionsFn = TRex.resolveGlobalFunc("getconnections")
local GetHuiFn = TRex.resolveGlobalFunc("gethui")

local FX_CLASSES: { [string]: string } = {
	ParticleEmitter = "Enabled",
	Trail = "Enabled",
	Beam = "Enabled",
	Fire = "Enabled",
	Smoke = "Enabled",
	Sparkles = "Enabled",
	PointLight = "Enabled",
	SpotLight = "Enabled",
	SurfaceLight = "Enabled",
	Explosion = "Visible",
}

local PART_CLASSES: { [string]: boolean } = {
	Part = true,
	MeshPart = true,
	UnionOperation = true,
	WedgePart = true,
	CornerWedgePart = true,
	TrussPart = true,
}

local STRONG_CONTROLLERS = {
	"LeaderboardsController",
	"KrakenController",
	"Mushrooms",
	"Scenery",
	"WorkspaceRainbowPartsController",
	"SubBiomesController",
	"PlotSignManagerController",
	"AssetHoverDataDisplay",
	"AssetBillboardController",
	"WallTimer",
	"StaffTagController",
	"HalloweenDimensionController",
}

local MAX_CONTROLLERS = {
	"PlacedEggRenderer",
	"OfflineMoneyInPlotUIController",
	"EggHolders",
}

local RUN_SIGNAL_NAMES = {
	"Heartbeat",
	"RenderStepped",
	"Stepped",
	"PreRender",
	"PreSimulation",
	"PostSimulation",
	"PreAnimation",
}

local EGG_RENDER_CONTAINERS: { [string]: boolean } = {
	ClientRenderedAssets = true,
	PlacedEggRenders = true,
}

-- Chunked Optimizer State & Restore Tables
local EnvSaved: { { Instance | any } } = {}
local PartSaved: { [Instance]: { [string]: any } } = setmetatable({}, { __mode = "k" }) :: any
local TrackedAnimators: { [Instance]: boolean } = setmetatable({}, { __mode = "k" }) :: any
local PausedTracks: { [AnimationTrack]: number } = setmetatable({}, { __mode = "k" }) :: any
local DisabledConns: { [any]: string } = {}

local OptQueue: { any } = {}
local OptQueueIdx = 1
local OptWorkerConn: RBXScriptConnection? = nil
local OptDescConn: RBXScriptConnection? = nil
local OptLevel = 0
local LastThrottleAt = 0

-- Hide My/Other Eggs State
local HiddenEggFolder = Instance.new("Folder")
HiddenEggFolder.Name = "TRexHiddenEggRenders"
local HiddenEggOrigins: { [Instance]: Instance? } = setmetatable({}, { __mode = "k" }) :: any
local HideEggsConns: { RBXScriptConnection } = {}

-- Hide Treadmill State
local HiddenTreadParts: { [BasePart]: { CanCollide: boolean, CanTouch: boolean, Trans: number } } = {}
local TreadConns: { RBXScriptConnection } = {}
local TempHideTreadUntil = 0

-- 3D Render Overlay & Wake Pulse State
local No3DGui: ScreenGui? = nil
local No3DFrame: Frame? = nil
local No3DOldQuality: Enum.QualityLevel? = nil
local Next3DWakeAt = math.huge
local Wake3DUntil = 0

-- Hide Game UI State (coordinated with FarmHUD)
local ManualHideUI = false
local ExternalHideUI = false
local HideUIActive = false
local HideUIChildConn: RBXScriptConnection? = nil
local HideUIPropConns: { RBXScriptConnection } = {}
local SavedGuis: { [Instance]: boolean } = setmetatable({}, { __mode = "k" }) :: any
local SuppressCount: { [Instance]: number } = setmetatable({}, { __mode = "k" }) :: any
local SavedCoreGuis: { Enum.CoreGuiType } = {}

-- Draggable FPS/Ping HUD State
local FPS_FONT = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold)
local COL_GOOD = Color3.fromRGB(58, 255, 55)
local COL_WARN = Color3.fromRGB(255, 214, 84)
local COL_BAD = Color3.fromRGB(255, 96, 96)
local COL_MUTED = Color3.fromRGB(150, 150, 158)

local FPSHudGui: ScreenGui? = nil
local FPSHudFrame: Frame? = nil
local FPSHudScale: UIScale? = nil
local FPSHudFpsLbl: TextLabel? = nil
local FPSHudPingLbl: TextLabel? = nil
local FPSHudDragConns: { RBXScriptConnection } = {}
local FPSHudViewportConn: RBXScriptConnection? = nil
local FPSSmoothed = 0
local LastFPSUpdate = 0
local LastFPSStr: string? = nil
local LastPingStr: string? = nil
local LoopStarted = false

local function disconnectConn(conn: RBXScriptConnection?)
	if conn then
		pcall(function()
			conn:Disconnect()
		end)
	end
end

local function disconnectList(list: { RBXScriptConnection })
	for _, conn in ipairs(list) do
		pcall(function()
			conn:Disconnect()
		end)
	end
	table.clear(list)
end

local function getUiMountTarget(): Instance
	if GetHuiFn then
		local okH, hui = pcall(GetHuiFn)
		if okH and hui then
			return hui
		end
	end
	return CoreGui
end

-- =========================================================================
-- FPS Cap
-- =========================================================================
function Optimizer.applyFPSCap()
	local capFn = SetFpsCapFn or TRex.resolveGlobalFunc("setfpscap")
	if not capFn then
		return
	end
	SetFpsCapFn = capFn
	local cfg = TRex.Config
	local rawVal = math.clamp(math.floor(tonumber(cfg.FPSCapValue) or 60), 10, 1000)
	if cfg.Disable3DRender then
		pcall(capFn, math.min(rawVal, 40))
	elseif cfg.FPSCapEnabled then
		pcall(capFn, rawVal)
	else
		pcall(capFn, 0)
	end
end

-- =========================================================================
-- Chunked Workspace Optimizer (Balanced / Strong / Max)
-- =========================================================================
local function saveAndSetEnv(obj: any, prop: string, val: any)
	local okGet, cur = pcall(function()
		return obj[prop]
	end)
	if okGet and cur ~= val then
		table.insert(EnvSaved, { obj, prop, cur })
		pcall(function()
			obj[prop] = val
		end)
	end
end

local function recordPartProp(obj: Instance, prop: string, oldVal: any)
	local bucket = PartSaved[obj]
	if not bucket then
		bucket = {}
		PartSaved[obj] = bucket
	end
	if bucket[prop] == nil then
		bucket[prop] = oldVal
	end
end

local function setPartProp(obj: any, prop: string, newVal: any)
	local okGet, cur = pcall(function()
		return obj[prop]
	end)
	if okGet and cur ~= newVal then
		recordPartProp(obj, prop, cur)
		pcall(function()
			obj[prop] = newVal
		end)
	end
end

local function isAnyPlayerCharacter(inst: Instance): boolean
	for _, plr in ipairs(Players:GetPlayers()) do
		local char = plr.Character
		if char and (inst == char or inst:IsDescendantOf(char)) then
			return true
		end
	end
	return false
end

local function applyInstanceOpt(inst: Instance)
	local cls = inst.ClassName
	if PART_CLASSES[cls] then
		setPartProp(inst, "CastShadow", false)
		if OptLevel >= 2 then
			local part = inst :: BasePart
			local mat = part.Material
			if mat ~= Enum.Material.SmoothPlastic and mat ~= Enum.Material.ForceField then
				recordPartProp(inst, "Material", mat)
				part.Material = Enum.Material.SmoothPlastic
			end
			if part.Reflectance > 0 then
				setPartProp(inst, "Reflectance", 0)
			end
		end
		if OptLevel >= 3 and cls == "MeshPart" then
			setPartProp(inst, "TextureID", "")
		end
	elseif FX_CLASSES[cls] then
		setPartProp(inst, FX_CLASSES[cls], false)
	elseif cls == "Animator" then
		TrackedAnimators[inst] = true
	else
		if OptLevel >= 2 and (cls == "Decal" or cls == "Texture") then
			setPartProp(inst, "Transparency", 1)
		elseif OptLevel >= 2 and cls == "Highlight" then
			setPartProp(inst, "Enabled", false)
		elseif OptLevel >= 3 and cls == "SpecialMesh" then
			setPartProp(inst, "TextureId", "")
		elseif OptLevel >= 3 and cls == "SurfaceAppearance" then
			setPartProp(inst, "Parent", nil)
		end
	end
end

local function kickOptQueueWorker()
	if OptWorkerConn then
		return
	end
	OptWorkerConn = RunService.Heartbeat:Connect(function()
		local startAt = os.clock()
		while OptQueueIdx <= #OptQueue and (os.clock() - startAt) < 0.001 do
			local item = OptQueue[OptQueueIdx]
			OptQueueIdx += 1
			if type(item) == "function" then
				pcall(item)
			elseif typeof(item) == "Instance" and item.Parent and not (item:IsA("Model") and Players:GetPlayerFromCharacter(item)) then
				for _, child in ipairs(item:GetChildren()) do
					table.insert(OptQueue, child)
				end
				if OptLevel > 0 and item ~= Workspace then
					pcall(applyInstanceOpt, item)
				end
			end
		end
		if OptQueueIdx > #OptQueue then
			table.clear(OptQueue)
			OptQueueIdx = 1
			disconnectConn(OptWorkerConn)
			OptWorkerConn = nil
		end
	end)
end

local function onWorkspaceDescendantAdded(inst: Instance)
	if OptLevel <= 0 then
		return
	end
	local cls = inst.ClassName
	local match = PART_CLASSES[cls] ~= nil
		or FX_CLASSES[cls] ~= nil
		or cls == "Animator"
		or (OptLevel >= 2 and (cls == "Decal" or cls == "Texture" or cls == "Highlight"))
		or (OptLevel >= 3 and (cls == "SpecialMesh" or cls == "SurfaceAppearance"))
	if match and not isAnyPlayerCharacter(inst) then
		pcall(applyInstanceOpt, inst)
	end
end

local function syncControllerConnections(targetNames: { [string]: boolean }?)
	for conn, ctrlName in pairs(DisabledConns) do
		if not targetNames or not targetNames[ctrlName] then
			pcall(function()
				conn:Enable()
			end)
			DisabledConns[conn] = nil
		end
	end
	if not targetNames then
		return
	end
	local gcFn = GetConnectionsFn or TRex.resolveGlobalFunc("getconnections")
	if not gcFn then
		return
	end
	GetConnectionsFn = gcFn
	for _, sigName in ipairs(RUN_SIGNAL_NAMES) do
		local okSig, sig = pcall(function()
			return (RunService :: any)[sigName]
		end)
		if okSig and sig then
			local okConns, conns = pcall(gcFn, sig)
			if okConns and type(conns) == "table" then
				for _, conn in ipairs(conns) do
					local fn = (conn :: any).Function
					if type(fn) == "function" then
						local okInfo, src = pcall(function()
							return debug.info(fn, "s")
						end)
						local ctrlName = okInfo and type(src) == "string" and src:match("([%w_]+)$") or nil
						if ctrlName and targetNames[ctrlName] and not DisabledConns[conn] then
							if pcall(function()
								conn:Disable()
							end) then
								DisabledConns[conn] = ctrlName
							end
						end
					end
				end
			end
		end
	end
end

local function syncDistantAnimators(active: boolean, maxDist: number?)
	local cam = Workspace.CurrentCamera
	local camPos = cam and cam.CFrame.Position or nil
	local localChar = TRex.LocalPlayer.Character
	for anim in pairs(TrackedAnimators) do
		local model = anim.Parent and anim:FindFirstAncestorOfClass("Model")
		if model then
			local shouldPause = active
				and camPos ~= nil
				and maxDist ~= nil
				and not (localChar and model:IsDescendantOf(localChar))
				and (model:GetPivot().Position - camPos).Magnitude > maxDist
			local okTracks, tracks = pcall(function()
				return (anim :: Animator):GetPlayingAnimationTracks()
			end)
			if okTracks and type(tracks) == "table" then
				for _, track in ipairs(tracks) do
					if shouldPause and not PausedTracks[track] then
						PausedTracks[track] = track.Speed
						pcall(function()
							track:AdjustSpeed(0)
						end)
					elseif not shouldPause and PausedTracks[track] then
						pcall(function()
							track:AdjustSpeed(PausedTracks[track])
						end)
						PausedTracks[track] = nil
					end
				end
			end
		else
			TrackedAnimators[anim] = nil
		end
	end
	if not active then
		for track, speed in pairs(PausedTracks) do
			pcall(function()
				track:AdjustSpeed(speed)
			end)
		end
		table.clear(PausedTracks)
	end
end

local function runControllerAndAnimatorThrottle()
	if OptLevel < 2 then
		return
	end
	local targetSet: { [string]: boolean } = {}
	for _, name in ipairs(STRONG_CONTROLLERS) do
		targetSet[name] = true
	end
	if OptLevel >= 3 then
		for _, name in ipairs(MAX_CONTROLLERS) do
			targetSet[name] = true
		end
	end
	syncControllerConnections(targetSet)
	syncDistantAnimators(true, OptLevel >= 3 and 60 or 120)
end

local function restoreOptimizer()
	OptLevel = 0
	disconnectConn(OptDescConn)
	OptDescConn = nil
	syncControllerConnections(nil)
	syncDistantAnimators(false, nil)

	for i = #EnvSaved, 1, -1 do
		local entry = EnvSaved[i]
		pcall(function()
			entry[1][entry[2]] = entry[3]
		end)
	end
	table.clear(EnvSaved)

	-- Re-assert Level01 if Disable3DRender is still active after Optimizer turns off
	if TRex.Config.Disable3DRender then
		pcall(function()
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		end)
	end

	table.clear(OptQueue)
	OptQueueIdx = 1
	for obj, props in pairs(PartSaved) do
		table.insert(OptQueue, function()
			for prop, oldVal in pairs(props) do
				pcall(function()
					(obj :: any)[prop] = oldVal
				end)
			end
		end)
	end
	table.clear(PartSaved)
	table.clear(TrackedAnimators)
	kickOptQueueWorker()
end

function Optimizer.applyOptimizer()
	restoreOptimizer()
	if not TRex.Config.OptimizerEnabled then
		return
	end
	local mode = TRex.Config.OptimizerMode
	OptLevel = mode == "Max" and 3 or (mode == "Balanced" and 1 or 2)

	local okRender, renderSettings = pcall(function()
		return settings().Rendering
	end)
	if okRender and renderSettings then
		saveAndSetEnv(renderSettings, "QualityLevel", Enum.QualityLevel.Level01)
		saveAndSetEnv(renderSettings, "MeshPartDetailLevel", Enum.MeshPartDetailLevel.Level01)
	end
	pcall(function()
		local ugs = UserSettings():GetService("UserGameSettings")
		saveAndSetEnv(ugs, "SavedQualityLevel", Enum.SavedQualitySetting.QualityLevel1)
	end)

	local lightingProps: { [string]: any } = {
		GlobalShadows = false,
		ShadowSoftness = 0,
		FogEnd = 9000000000,
		EnvironmentDiffuseScale = 0,
		EnvironmentSpecularScale = 0,
		Brightness = math.min(Lighting.Brightness, 2),
	}
	for prop, val in pairs(lightingProps) do
		saveAndSetEnv(Lighting, prop, val)
	end
	if OptLevel >= 3 then
		saveAndSetEnv(Lighting, "Technology", Enum.Technology.Compatibility)
	end

	local terrain = Workspace:FindFirstChildOfClass("Terrain")
	if terrain then
		local terrainProps: { [string]: any } = {
			Decoration = false,
			WaterWaveSize = 0,
			WaterWaveSpeed = 0,
			WaterReflectance = 0,
			WaterTransparency = 1,
		}
		for prop, val in pairs(terrainProps) do
			saveAndSetEnv(terrain, prop, val)
		end
	end

	for _, child in ipairs(Lighting:GetChildren()) do
		if child:IsA("PostEffect") then
			saveAndSetEnv(child, "Enabled", false)
		elseif child:IsA("Atmosphere") then
			saveAndSetEnv(child, "Density", 0)
			saveAndSetEnv(child, "Haze", 0)
			saveAndSetEnv(child, "Glare", 0)
		elseif child:IsA("Clouds") then
			saveAndSetEnv(child, "Enabled", false)
		end
	end

	OptDescConn = TRex.connectSignal(Workspace.DescendantAdded, onWorkspaceDescendantAdded)
	table.insert(OptQueue, Workspace)
	kickOptQueueWorker()
	LastThrottleAt = 0
	runControllerAndAnimatorThrottle()
end

-- =========================================================================
-- Hide My Eggs / Hide Other Eggs
-- =========================================================================
local function isOwnEggRender(obj: Instance): boolean
	local attrId = obj:GetAttribute("OwnerUserId")
	local nameId = obj.Name:match("^(%d+)_")
	return tonumber(attrId or nameId) == TRex.LocalPlayer.UserId
end

local function shouldHideEggRender(obj: Instance): boolean
	local cfg = TRex.Config
	if isOwnEggRender(obj) then
		return cfg.HideMyEggs == true
	end
	return cfg.HideOtherEggs == true
end

local function processEggRenderChild(obj: Instance)
	if obj.Parent ~= HiddenEggFolder and shouldHideEggRender(obj) then
		HiddenEggOrigins[obj] = obj.Parent
		pcall(function()
			obj.Parent = HiddenEggFolder
		end)
	end
end

function Optimizer.applyHideEggs()
	for obj, origParent in pairs(HiddenEggOrigins) do
		if not shouldHideEggRender(obj) then
			HiddenEggOrigins[obj] = nil
			if origParent and origParent.Parent and obj.Parent == HiddenEggFolder then
				pcall(function()
					obj.Parent = origParent
				end)
			end
		end
	end

	disconnectList(HideEggsConns)
	local active = (TRex.Config.HideMyEggs == true) or (TRex.Config.HideOtherEggs == true)
	if not active then
		return
	end

	for containerName in pairs(EGG_RENDER_CONTAINERS) do
		local container = Workspace:FindFirstChild(containerName)
		if container then
			for _, child in ipairs(container:GetChildren()) do
				processEggRenderChild(child)
			end
			local cAdded = TRex.connectSignal(container.ChildAdded, function(child)
				task.defer(processEggRenderChild, child)
			end)
			if cAdded then
				table.insert(HideEggsConns, cAdded)
			end
		end
	end

	local wAdded = TRex.connectSignal(Workspace.ChildAdded, function(child)
		if EGG_RENDER_CONTAINERS[child.Name] then
			task.defer(Optimizer.applyHideEggs)
		end
	end)
	if wAdded then
		table.insert(HideEggsConns, wAdded)
	end
end

-- =========================================================================
-- Hide Treadmill (Permanent toggle + Temp Hide on respawn)
-- =========================================================================
local function setTreadPartHidden(part: BasePart)
	if HiddenTreadParts[part] == nil then
		HiddenTreadParts[part] = {
			CanCollide = part.CanCollide,
			CanTouch = part.CanTouch,
			Trans = part.LocalTransparencyModifier,
		}
	end
	pcall(function()
		part.CanCollide = false
		part.CanTouch = false
		part.LocalTransparencyModifier = 1
	end)
end

local function restoreTreadParts()
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
end

local function applyTreadmillScan()
	local plots = Workspace:FindFirstChild("Plots")
	if plots then
		for _, plot in ipairs(plots:GetChildren()) do
			for _, targetName in ipairs({ "TreadmillBottom", "TreadmillUpgrade" }) do
				local node = plot:FindFirstChild(targetName, true)
				if node then
					if node:IsA("BasePart") then
						setTreadPartHidden(node)
					end
					for _, desc in ipairs(node:GetDescendants()) do
						if desc:IsA("BasePart") then
							setTreadPartHidden(desc)
						end
					end
				end
			end
		end
	else
		for _, desc in ipairs(Workspace:GetDescendants()) do
			if desc:IsA("BasePart") and (desc.Name:find("TreadmillBottom") or desc.Name:find("TreadmillUpgrade")) then
				setTreadPartHidden(desc)
			end
		end
	end
end

function Optimizer.applyHideTreadmill(enabled: boolean?)
	local want = if enabled ~= nil then (enabled == true) else (TRex.Config.HideTreadmill == true)
	disconnectList(TreadConns)
	if not want and os.clock() >= TempHideTreadUntil then
		restoreTreadParts()
		return
	end
	applyTreadmillScan()
	local plots = Workspace:FindFirstChild("Plots")
	if plots then
		local conn = TRex.connectSignal(plots.DescendantAdded, function(desc)
			if TRex.Config.HideTreadmill and desc:IsA("BasePart") and (desc.Name:find("TreadmillBottom") or desc.Name:find("TreadmillUpgrade")) then
				setTreadPartHidden(desc)
			end
		end)
		if conn then
			table.insert(TreadConns, conn)
		end
	end
end

function Optimizer.hideTreadmillTemporary(seconds: number)
	TempHideTreadUntil = math.max(TempHideTreadUntil, os.clock() + (tonumber(seconds) or 6))
	applyTreadmillScan()
end

-- =========================================================================
-- Disable 3D Render (Overlay + <=40 FPS + 180s/2s wake pulse)
-- =========================================================================
local function ensureNo3DOverlay()
	if No3DGui and No3DGui.Parent and No3DFrame then
		return
	end
	local gui = Instance.new("ScreenGui")
	gui.Name = "TRexNo3DOverlay"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = -1000
	gui.Enabled = false

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BorderSizePixel = 0
	frame.BackgroundColor3 = (TRex.Config.No3DBackground == "Black") and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
	frame.Parent = gui

	gui.Parent = getUiMountTarget()
	No3DGui = gui
	No3DFrame = frame
end

function Optimizer.apply3DBackground()
	if No3DFrame then
		No3DFrame.BackgroundColor3 = (TRex.Config.No3DBackground == "Black") and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
	end
end

function Optimizer.apply3DRender(disabled: boolean?)
	local on = if disabled ~= nil then (disabled == true) else (TRex.Config.Disable3DRender == true)
	ensureNo3DOverlay()
	Optimizer.apply3DBackground()

	pcall(function()
		RunService:Set3dRenderingEnabled(not on)
	end)
	Optimizer.applyFPSCap()

	pcall(function()
		local renderSettings = settings().Rendering
		if on then
			No3DOldQuality = No3DOldQuality or renderSettings.QualityLevel
			renderSettings.QualityLevel = Enum.QualityLevel.Level01
		elseif No3DOldQuality then
			if not TRex.Config.OptimizerEnabled then
				renderSettings.QualityLevel = No3DOldQuality
			end
			No3DOldQuality = nil
		end
	end)

	if No3DGui then
		No3DGui.Enabled = on
	end
	Wake3DUntil = 0
	Next3DWakeAt = on and (os.clock() + 180) or math.huge
end

-- =========================================================================
-- Hide Game UI (PlayerGui LayerCollectors + CoreGuiTypes)
-- =========================================================================
local function suppressLayerCollector(lc: LayerCollector)
	SuppressCount[lc] = (SuppressCount[lc] or 0) + 1
	pcall(function()
		lc.Enabled = false
	end)
end

local function watchLayerCollector(inst: Instance)
	if not inst:IsA("LayerCollector") then
		return
	end
	if inst == No3DGui or inst == FPSHudGui or inst.Name:sub(1, 4) == "TRex" then
		return
	end
	if SavedGuis[inst] ~= nil then
		return
	end
	SavedGuis[inst] = inst.Enabled
	local conn = inst:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not HideUIActive then
			return
		end
		if inst.Enabled then
			SavedGuis[inst] = true
			suppressLayerCollector(inst)
		else
			local cnt = SuppressCount[inst]
			if cnt and cnt > 0 then
				SuppressCount[inst] = cnt - 1
			else
				SavedGuis[inst] = false
			end
		end
	end)
	table.insert(HideUIPropConns, conn)
	if inst.Enabled then
		suppressLayerCollector(inst)
	end
end

local function syncHideGameUI()
	local want = ManualHideUI or ExternalHideUI
	if HideUIActive == want then
		return
	end
	HideUIActive = want

	disconnectConn(HideUIChildConn)
	HideUIChildConn = nil

	local pGui = TRex.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	if want then
		if pGui then
			for _, child in ipairs(pGui:GetChildren()) do
				watchLayerCollector(child)
			end
			HideUIChildConn = pGui.ChildAdded:Connect(watchLayerCollector)
		end
		for _, item in ipairs(Enum.CoreGuiType:GetEnumItems()) do
			if item ~= Enum.CoreGuiType.All then
				local okGet, wasOn = pcall(StarterGui.GetCoreGuiEnabled, StarterGui, item)
				if okGet and wasOn then
					table.insert(SavedCoreGuis, item)
					pcall(StarterGui.SetCoreGuiEnabled, StarterGui, item, false)
				end
			end
		end
	else
		disconnectList(HideUIPropConns)
		for inst, wasOn in pairs(SavedGuis) do
			if inst.Parent and wasOn then
				pcall(function()
					(inst :: LayerCollector).Enabled = true
				end)
			end
		end
		for _, item in ipairs(SavedCoreGuis) do
			pcall(StarterGui.SetCoreGuiEnabled, StarterGui, item, true)
		end
		table.clear(SavedGuis)
		table.clear(SuppressCount)
		table.clear(SavedCoreGuis)
	end
end

function Optimizer.setExternalHideUI(show: boolean)
	ExternalHideUI = (show == true)
	syncHideGameUI()
end

function Optimizer.applyHideGameUI(enabled: boolean?)
	if enabled ~= nil then
		ManualHideUI = (enabled == true)
	else
		ManualHideUI = (TRex.Config.HideGameUI == true)
	end
	syncHideGameUI()
end

-- =========================================================================
-- Draggable FPS & Ping HUD (Suppressed while ShowFarmHUD is true)
-- =========================================================================
function Optimizer.updateFPSPingScale()
	if not FPSHudScale then
		return
	end
	local cam = Workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	if vp.X < 1 then
		vp = Vector2.new(1280, 720)
	end
	local pct = math.clamp(tonumber(TRex.Config.FPSPingSizePercent) or 100, 60, 160) / 100
	FPSHudScale.Scale = math.clamp(vp.X * 0.085 / 132, 0.7, 1.4) * pct
end

local function destroyFPSHud()
	disconnectList(FPSHudDragConns)
	disconnectConn(FPSHudViewportConn)
	FPSHudViewportConn = nil
	if FPSHudGui then
		pcall(function()
			FPSHudGui:Destroy()
		end)
	end
	FPSHudGui = nil
	FPSHudFrame = nil
	FPSHudScale = nil
	FPSHudFpsLbl = nil
	FPSHudPingLbl = nil
	LastFPSStr = nil
	LastPingStr = nil
	FPSSmoothed = 0
end

local function makeHudTextLabel(parent: Instance, xPos: number, width: number, color: Color3, initialText: string?): TextLabel
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Position = UDim2.fromOffset(xPos, 9)
	lbl.Size = UDim2.fromOffset(width, 16)
	lbl.Text = initialText or ""
	lbl.TextColor3 = color
	lbl.TextScaled = true
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.FontFace = FPS_FONT
	lbl.Parent = parent
	return lbl
end

local function buildFPSHud()
	destroyFPSHud()
	local gui = Instance.new("ScreenGui")
	gui.Name = "TRexFPSPingHUD"
	gui.DisplayOrder = 58
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local savedPos = TRex.Config.FPSPingPosition
	local posUdim = UDim2.fromOffset(16, 16)
	if type(savedPos) == "table" and type(savedPos.XOffset) == "number" and type(savedPos.YOffset) == "number" then
		posUdim = UDim2.new(tonumber(savedPos.XScale) or 0, savedPos.XOffset, tonumber(savedPos.YScale) or 0, savedPos.YOffset)
	end

	local frame = Instance.new("Frame")
	frame.Active = true
	frame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
	frame.BackgroundTransparency = 0.28
	frame.BorderSizePixel = 0
	frame.Size = UDim2.fromOffset(132, 34)
	frame.Position = posUdim
	frame.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.new(1, 1, 1)
	stroke.Thickness = 1
	stroke.Transparency = 0.9
	stroke.Parent = frame

	local uiScale = Instance.new("UIScale")
	uiScale.Parent = frame

	local fpsLbl = makeHudTextLabel(frame, 12, 34, COL_GOOD, "--")
	makeHudTextLabel(frame, 48, 22, COL_MUTED, "FPS")

	local divider = Instance.new("Frame")
	divider.AnchorPoint = Vector2.new(0.5, 0.5)
	divider.BackgroundColor3 = Color3.new(1, 1, 1)
	divider.BackgroundTransparency = 0.85
	divider.BorderSizePixel = 0
	divider.Position = UDim2.new(0, 74, 0.5, 0)
	divider.Size = UDim2.fromOffset(1, 14)
	divider.Parent = frame

	local pingLbl = makeHudTextLabel(frame, 82, 30, COL_GOOD, "--")
	makeHudTextLabel(frame, 113, 14, COL_MUTED, "ms")

	gui.Parent = getUiMountTarget()

	FPSHudGui = gui
	FPSHudFrame = frame
	FPSHudScale = uiScale
	FPSHudFpsLbl = fpsLbl
	FPSHudPingLbl = pingLbl

	Optimizer.updateFPSPingScale()
	local cam = Workspace.CurrentCamera
	if cam then
		FPSHudViewportConn = cam:GetPropertyChangedSignal("ViewportSize"):Connect(Optimizer.updateFPSPingScale)
	end

	-- Drag handling (mouse + touch)
	local dragging = false
	local touchInput: InputObject? = nil
	local dragStart = Vector2.zero
	local startPos = UDim2.new()

	table.insert(
		FPSHudDragConns,
		frame.InputBegan:Connect(function(input)
			if not dragging and input.UserInputState == Enum.UserInputState.Begin then
				local isMouse = input.UserInputType == Enum.UserInputType.MouseButton1
				local isTouch = input.UserInputType == Enum.UserInputType.Touch
				if isMouse or isTouch then
					dragging = true
					touchInput = isTouch and input or nil
					dragStart = Vector2.new(input.Position.X, input.Position.Y)
					startPos = frame.Position
				end
			end
		end)
	)
	table.insert(
		FPSHudDragConns,
		UserInputService.InputChanged:Connect(function(input)
			if not dragging or not FPSHudFrame then
				return
			end
			local matches = if touchInput then (input == touchInput) else (input.UserInputType == Enum.UserInputType.MouseMovement)
			if matches then
				local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
				FPSHudFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	)
	table.insert(
		FPSHudDragConns,
		UserInputService.InputEnded:Connect(function(input)
			if not dragging then
				return
			end
			local matches = if touchInput then (input == touchInput) else (input.UserInputType == Enum.UserInputType.MouseButton1)
			if matches then
				dragging = false
				touchInput = nil
				if FPSHudFrame then
					local p = FPSHudFrame.Position
					TRex.Config.FPSPingPosition = {
						XScale = p.X.Scale,
						XOffset = p.X.Offset,
						YScale = p.Y.Scale,
						YOffset = p.Y.Offset,
					}
					if type(TRex.saveConfig) == "function" then
						task.spawn(TRex.saveConfig)
					end
				end
			end
		end)
	)
end

local function shouldShowFPSHud(): boolean
	return TRex.Config.ShowFPSPingHUD ~= false and TRex.Config.ShowFarmHUD ~= true
end

function Optimizer.syncFPSPingVisibility()
	local want = shouldShowFPSHud()
	if want and not (FPSHudGui and FPSHudGui.Parent) then
		buildFPSHud()
	elseif not want and FPSHudGui then
		destroyFPSHud()
	end
end

function Optimizer.applyFPSPingHUD(enabled: boolean?)
	if enabled ~= nil then
		TRex.Config.ShowFPSPingHUD = (enabled == true)
	end
	Optimizer.syncFPSPingVisibility()
end

-- =========================================================================
-- Lifecycle: restoreAll, init, step, startLoop, buildUI
-- =========================================================================
function Optimizer.restoreAll()
	if OptWorkerConn then
		disconnectConn(OptWorkerConn)
		OptWorkerConn = nil
	end
	table.clear(OptQueue)
	OptQueueIdx = 1

	restoreOptimizer()
	TRex.Config.HideMyEggs = false
	TRex.Config.HideOtherEggs = false
	Optimizer.applyHideEggs()
	for obj, origParent in pairs(HiddenEggOrigins) do
		if origParent and origParent.Parent and obj.Parent == HiddenEggFolder then
			pcall(function()
				obj.Parent = origParent
			end)
		end
		HiddenEggOrigins[obj] = nil
	end

	TempHideTreadUntil = 0
	Optimizer.applyHideTreadmill(false)
	disconnectList(TreadConns)

	ManualHideUI = false
	ExternalHideUI = false
	syncHideGameUI()

	Optimizer.apply3DRender(false)
	if No3DGui then
		pcall(function()
			No3DGui:Destroy()
		end)
		No3DGui = nil
		No3DFrame = nil
	end

	destroyFPSHud()

	local capFn = SetFpsCapFn or TRex.resolveGlobalFunc("setfpscap")
	if capFn then
		pcall(capFn, 0)
	end
end

function Optimizer.step()
	if not TRex.IsRunning then
		return
	end
	Optimizer.syncFPSPingVisibility()

	local now = os.clock()
	if OptLevel >= 2 and (now - LastThrottleAt) >= 2 then
		LastThrottleAt = now
		pcall(runControllerAndAnimatorThrottle)
	end

	if TempHideTreadUntil > 0 and now >= TempHideTreadUntil and not TRex.Config.HideTreadmill then
		TempHideTreadUntil = 0
		restoreTreadParts()
	end

	if TRex.Config.Disable3DRender then
		if Wake3DUntil > 0 then
			if now >= Wake3DUntil then
				Wake3DUntil = 0
				Next3DWakeAt = now + 180
				pcall(function()
					RunService:Set3dRenderingEnabled(false)
				end)
			end
		elseif now >= Next3DWakeAt then
			Wake3DUntil = now + 2
			pcall(function()
				RunService:Set3dRenderingEnabled(true)
			end)
		end
	end
end

function Optimizer.init()
	TRex.registerCleanupHook(Optimizer.restoreAll)

	TRex.connectSignal(TRex.LocalPlayer.CharacterAdded, function()
		Optimizer.hideTreadmillTemporary(6)
	end)

	TRex.connectSignal(RunService.RenderStepped, function(dt)
		if not (FPSHudFpsLbl and FPSHudPingLbl) then
			return
		end
		local clamped = math.clamp(dt, 0.001, 1)
		local instFps = 1 / clamped
		if FPSSmoothed <= 0 then
			FPSSmoothed = instFps
		else
			FPSSmoothed += (instFps - FPSSmoothed) * (1 - math.exp(-clamped * 8))
		end

		local now = os.clock()
		if now - LastFPSUpdate < 0.2 then
			return
		end
		LastFPSUpdate = now

		local fpsInt = math.floor(FPSSmoothed + 0.5)
		local fpsStr = tostring(fpsInt)
		if fpsStr ~= LastFPSStr then
			LastFPSStr = fpsStr
			FPSHudFpsLbl.Text = fpsStr
			FPSHudFpsLbl.TextColor3 = fpsInt >= 100 and COL_GOOD or (fpsInt >= 50 and COL_WARN or COL_BAD)
		end

		local okPing, rawPing = pcall(function()
			return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
		end)
		local pingInt = math.floor((okPing and tonumber(rawPing) or 0) + 0.5)
		local pingStr = tostring(pingInt)
		if pingStr ~= LastPingStr then
			LastPingStr = pingStr
			FPSHudPingLbl.Text = pingStr
			FPSHudPingLbl.TextColor3 = pingInt <= 90 and COL_GOOD or (pingInt <= 180 and COL_WARN or COL_BAD)
		end
	end)

	Optimizer.applyFPSCap()
	if TRex.Config.OptimizerEnabled then
		Optimizer.applyOptimizer()
	end
	if TRex.Config.HideMyEggs or TRex.Config.HideOtherEggs then
		Optimizer.applyHideEggs()
	end
	if TRex.Config.HideTreadmill then
		Optimizer.applyHideTreadmill(true)
	end
	if TRex.Config.HideGameUI then
		Optimizer.applyHideGameUI(true)
	end
	if TRex.Config.Disable3DRender then
		Optimizer.apply3DRender(true)
	end
	Optimizer.syncFPSPingVisibility()
end

function Optimizer.startLoop()
	if LoopStarted then
		return
	end
	LoopStarted = true
	task.spawn(function()
		while TRex.IsRunning do
			Optimizer.step()
			task.wait(0.5)
		end
	end)
end

function Optimizer.buildUI(ui)
	local tab = ui.addTab("optimizer", "tab.optimizer")

	local optSec = tab:addSection("sec.optimizer")
	local optTog = optSec:addToggle({
		key = "OptimizerEnabled",
		label = "opt.optimizer_enable",
		onChanged = function()
			Optimizer.applyOptimizer()
		end,
	})
	optSec:addDropdown({
		key = "OptimizerMode",
		label = "opt.optimizer_mode",
		items = { "Balanced", "Strong", "Max" },
		onChanged = function()
			if TRex.Config.OptimizerEnabled then
				Optimizer.applyOptimizer()
			end
		end,
	}):When(optTog)
	optSec:addToggle({
		key = "HideMyEggs",
		label = "opt.hide_mine",
		onChanged = function()
			Optimizer.applyHideEggs()
		end,
	})
	optSec:addToggle({
		key = "HideOtherEggs",
		label = "opt.hide_others",
		onChanged = function()
			Optimizer.applyHideEggs()
		end,
	})
	optSec:addToggle({
		key = "HideTreadmill",
		label = "opt.hide_tread",
		onChanged = function(enabled)
			Optimizer.applyHideTreadmill(enabled)
		end,
	})

	local visSec = tab:addSection("sec.visibility_perf")
	local no3dTog = visSec:addToggle({
		key = "Disable3DRender",
		label = "opt.no3d",
		desc = "desc.no3d",
		onChanged = function(enabled)
			Optimizer.apply3DRender(enabled)
		end,
	})
	visSec:addDropdown({
		key = "No3DBackground",
		label = "opt.no3d_bg",
		items = { "White", "Black" },
		onChanged = function()
			Optimizer.apply3DBackground()
		end,
	}):When(no3dTog)
	visSec:addToggle({
		key = "HideGameUI",
		label = "opt.hide_ui",
		onChanged = function(enabled)
			Optimizer.applyHideGameUI(enabled)
		end,
	})
	local fpsCapTog = visSec:addToggle({
		key = "FPSCapEnabled",
		label = "opt.fps_cap_enable",
		onChanged = function()
			Optimizer.applyFPSCap()
		end,
	})
	visSec:addSlider({
		key = "FPSCapValue",
		label = "opt.fps_cap_value",
		min = 10,
		max = 1000,
		step = 1,
		unit = " FPS",
		onChanged = function()
			Optimizer.applyFPSCap()
		end,
	}):When(fpsCapTog)
	local fpsHudTog = visSec:addToggle({
		key = "ShowFPSPingHUD",
		label = "opt.fps_ping_hud",
		onChanged = function()
			Optimizer.syncFPSPingVisibility()
		end,
	})
	visSec:addSlider({
		key = "FPSPingSizePercent",
		label = "opt.fps_ping_size",
		min = 60,
		max = 160,
		step = 1,
		unit = "%",
		onChanged = function()
			Optimizer.updateFPSPingScale()
		end,
	}):When(fpsHudTog)
end
