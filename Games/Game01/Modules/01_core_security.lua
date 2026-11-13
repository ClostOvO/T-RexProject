-- T-RexProject/Games/Game01/Modules/01_core_security.lua
-- Core Engine & Security for Game01 (Steal An Egg)
-- Combines exact Game01 client module / networking discovery & movement trust clearing
-- with Temp (SAE v2188) scheduler, egg info/filter math, stepTo/ragTo/fastTweenTo/walkTo,
-- VenyxAG anti-guard recovery, invisibility arbitration, and safe Anti-AFK (no VirtualUser).

local ReplicatedStorage = TRex.Services.ReplicatedStorage
local Workspace = TRex.Services.Workspace
local RunService = TRex.Services.RunService
local Stats = TRex.Services.Stats

local Core = {}
TRex.Core = Core

Core.AREAS = {
	"Forest",
	"Desert",
	"Snow",
	"Lake",
	"Jungle",
	"Volcano",
	"Prehistoric",
	"Cosmic",
	"Abyss Ocean",
	"Cherry Blossom",
	"Light Dark",
	"Titan Temple",
	"Enchanted Forest",
	"Alien",
}

Core.TELEPORT_ZONES = {
	"Prehistoric",
	"Cosmic",
	"Cherry Blossom",
	"Titan Temple",
	"Light Dark",
	"Enchanted Forest",
	"Alien",
}

Core.TELEPORT_RANGES = {
	Prehistoric = 2300,
	Cosmic = 4300,
	["Cherry Blossom"] = 4300,
}

Core.MULTI_LEG_AREAS = {
	Prehistoric = true,
	Cosmic = true,
	["Cherry Blossom"] = true,
	["Titan Temple"] = true,
	["Light Dark"] = true,
	["Enchanted Forest"] = true,
	Alien = true,
}

Core.VOID_ANCHOR = CFrame.new(5846, 17010.1, 15699.4)

Core.RARITY_ORDER = {
	"Any",
	"Common",
	"Uncommon",
	"Rare",
	"Epic",
	"Legendary",
	"Mythic",
	"Cosmic",
	"Secret",
	"Eternal",
	"Divine",
}

Core.RARITY_RANK = {}
for i, name in ipairs(Core.RARITY_ORDER) do
	if i > 1 then
		Core.RARITY_RANK[name] = i - 1
	end
end

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
	Codex = "Client.CodexState",
	Relics = "Shared.Modules.Relics",
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
		return (net and net:FindFirstChild(prefix .. "/" .. remoteNameOrNs .. "/" .. optName))
			or ReplicatedStorage:FindFirstChild(prefix .. "/" .. remoteNameOrNs .. "/" .. optName, true)
	end
	local net = Core.getNetworking()
	local found = (net and net:FindFirstChild(remoteNameOrNs))
		or ReplicatedStorage:FindFirstChild(remoteNameOrNs, true)
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
	return ok == true and res ~= false and (type(res) ~= "table" or res.Success ~= false)
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

function Core.findWorldPath(...)
	local cur = Workspace:FindFirstChild("World") or Workspace:FindFirstChild("__OBJECTS")
	for _, seg in ipairs({ ... }) do
		cur = cur and cur:FindFirstChild(seg) or nil
	end
	return cur
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

local RedeemVerdictAt = 0
local LastCarryState = { IsCarrying = false, Uid = nil }

function Core.getRedeemVerdictAt()
	return RedeemVerdictAt
end

function Core.getCarryState()
	local eggState = GameModuleCache.Egg
	if type(eggState) == "table" then
		for _, fnName in ipairs({ "ReadCarryState", "GetCarryState" }) do
			if type(eggState[fnName]) == "function" then
				local ok, st = pcall(eggState[fnName])
				if ok and type(st) == "table" then
					LastCarryState = st
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
	if LastCarryState and LastCarryState.IsCarrying == true then
		return LastCarryState
	end
	return { IsCarrying = false }
end

function Core.isCarryingEgg(targetUid)
	local st = Core.getCarryState()
	if not (st and st.IsCarrying == true) then
		return false
	end
	if targetUid then
		return st.Uid == targetUid
	end
	return true
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

Core.serverTime = Core.getServerNow

function Core.getPing()
	local ok, pVal = pcall(function()
		return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
	end)
	if ok and type(pVal) == "number" then
		return math.clamp(pVal, 0.02, 1.0)
	end
	local okNet, ping = pcall(TRex.LocalPlayer.GetNetworkPing, TRex.LocalPlayer)
	return okNet and math.clamp(tonumber(ping) or 0.12, 0.02, 1.0) or 0.12
end

function Core.getWalkSpeed()
	local hum = Core.getHumanoid()
	if hum and hum.WalkSpeed >= 16 then
		return hum.WalkSpeed
	end
	local ok, spdVal = pcall(function()
		local lp = TRex.LocalPlayer
		local ls = lp and lp:FindFirstChild("leaderstats")
		local sp = ls and ls:FindFirstChild("Speed")
		if sp and GameModuleCache.TreadUtil and type(GameModuleCache.TreadUtil.SpeedPowerToWalkSpeed) == "function" then
			return GameModuleCache.TreadUtil.SpeedPowerToWalkSpeed(sp.Value)
		end
		return nil
	end)
	if ok and tonumber(spdVal) and spdVal >= 16 then
		return spdVal
	end
	return math.max(hum and hum.WalkSpeed or 16, 16)
end

local CachedSeparationLine = nil
function Core.getSeparationLinePos()
	if not (CachedSeparationLine and CachedSeparationLine.Parent) then
		local part = Core.findWorldPath("Areas", "SeparationLine") or Workspace:FindFirstChild("SeparationLine", true)
		CachedSeparationLine = (part and part:IsA("BasePart")) and part or nil
	end
	return CachedSeparationLine and CachedSeparationLine.Position or Vector3.new(552.2, 67.67, 0)
end

function Core.getRiftMachinePos()
	local portal = Core.findWorldPath("Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003")
	if portal and portal:IsA("BasePart") then
		return portal.CFrame:PointToWorldSpace(Vector3.new(-26.776, 1.75, 18.665))
	end
	local rift = Core.findWorldPath("Machines", "RiftMachine") or Workspace:FindFirstChild("RiftMachine", true)
	if rift then
		return rift:IsA("BasePart") and rift.Position or rift:GetPivot().Position
	end
	return Vector3.new(528.7, 70.57, -364.11)
end

function Core.getSeparationBouncePos()
	local sep = Core.getSeparationLinePos()
	local root = Core.getRoot()
	local curZ = root and math.clamp(root.Position.Z, -415, -305) or -360
	return Vector3.new(sep.X - 18, sep.Y + 4, curZ)
end

function Core.isInSafeZone(pos)
	local p = pos
	if typeof(p) ~= "Vector3" then
		local root = Core.getRoot()
		p = root and root.Position or nil
	end
	if typeof(p) ~= "Vector3" then
		return false
	end
	return p.X < Core.getSeparationLinePos().X and p.Y < 1000
end

function Core.inFuseZone()
	local root = Core.getRoot()
	local build = Workspace:FindFirstChild("Build")
	local zone = build and build:FindFirstChild("FuseBiomeZone")
	local exitPart = (zone and zone:FindFirstChild("ExitPart", true)) or Workspace:FindFirstChild("FuseBiomeZone", true)
	if not root or not exitPart then
		return false
	end
	local p = exitPart:IsA("BasePart") and exitPart.Position or exitPart:GetPivot().Position
	return (root.Position - p).Magnitude < 1200 or (root.Position.Y > 1000 and not Core.inEnchantedTree() and not Core.inBossArena())
end

function Core.leaveFuseZone(maxWait)
	local build = Workspace:FindFirstChild("Build")
	local zone = build and build:FindFirstChild("FuseBiomeZone")
	local exitPart = zone and zone:FindFirstChild("ExitPart", true)
	if not exitPart then
		return true
	end
	local deadline = os.clock() + (maxWait or 12)
	while Core.inFuseZone() and os.clock() < deadline do
		local root = Core.getRoot()
		if not root then
			break
		end
		Core.setRootCFrame(CFrame.new(exitPart.Position + Vector3.new(0, 3, 0)))
		Core.fireTouchInterest(root, exitPart)
		task.wait(0.1)
	end
	return not Core.inFuseZone()
end

function Core.inEnchantedTree()
	return TRex.LocalPlayer and TRex.LocalPlayer:GetAttribute("InEnchantedTree") == true
end

function Core.inBossArena()
	return TRex.LocalPlayer and TRex.LocalPlayer:GetAttribute("InBossArena") == true
end

function Core.inHighZone()
	return Core.inEnchantedTree() or Core.inBossArena()
end

function Core.isNightPhase()
	local cyc = GameModuleCache.Cycle
	if type(cyc) == "table" and type(cyc.IsNightPhase) == "function" then
		local ok, isNight = pcall(cyc.IsNightPhase, Core.getServerNow())
		if ok then
			return isNight == true
		end
	end
	return false
end

function Core.isWallSealed()
	local wall = GameModuleCache.Wall
	if type(wall) == "table" and type(wall.IsSealed) == "function" then
		local ok, sealed = pcall(wall.IsSealed)
		if ok then
			return sealed == true
		end
	end
	return false
end

function Core.getAreaLegs(areaId)
	if Core.MULTI_LEG_AREAS[tostring(areaId or "")] then
		return 4
	end
	local guardArea = Core.findWorldPath("Areas", "GuardAreas", tostring(areaId or ""))
	local esc = guardArea and guardArea:GetAttribute("GuardEscapeSpeeds")
	if typeof(esc) == "Vector2" and Core.getWalkSpeed() * 0.9 < esc.Y * 1.05 then
		return 2
	end
	return 1
end

local ActiveMover = nil
local ActiveMoverPriority = -1
local ActiveMoverUntil = 0
local MoverToken = 0
local TaskList = {}
local RespawnAt = -99

function Core.acquireMover(name, priority, ttl)
	local now = os.clock()
	local pri = tonumber(priority) or 1
	if ActiveMover and ActiveMover ~= name and now < ActiveMoverUntil and ActiveMoverPriority > pri then
		return false
	end
	ActiveMover = name
	ActiveMoverPriority = pri
	ActiveMoverUntil = now + (tonumber(ttl) or 2.5)
	MoverToken = MoverToken + 1
	return true
end

function Core.releaseMover(name)
	if not name or ActiveMover == name then
		ActiveMover = nil
		ActiveMoverPriority = -1
		ActiveMoverUntil = 0
	end
end

function Core.getActiveMover()
	return ActiveMover
end

function Core.registerTask(def)
	def.Name = def.Name or ("Task" .. tostring(#TaskList + 1))
	def.Priority = def.Priority or 10
	def.Gap = def.Gap or 0.5
	def.NextAt = def.NextAt or 0
	def.Busy = false
	table.insert(TaskList, def)
	return def
end

function Core.pokeTasks()
	for _, tDef in ipairs(TaskList) do
		if not tDef.Busy then
			tDef.NextAt = 0
		end
	end
end

function Core.stepScheduler()
	local now = os.clock()
	table.sort(TaskList, function(a, b)
		return a.Priority < b.Priority
	end)
	for _, tDef in ipairs(TaskList) do
		if not tDef.Busy and now >= tDef.NextAt then
			local okOn, enabled = pcall(tDef.On)
			if okOn and enabled then
				local okWant, wantArg = pcall(tDef.Want)
				if okWant and wantArg then
					local acquired = (not tDef.NeedsMover) or Core.acquireMover(tDef.Name, 20 - math.clamp(tDef.Priority, 1, 19), 8)
					if acquired then
						tDef.Busy = true
						task.spawn(function()
							local shouldContinue = function()
								local sOk, sEn = pcall(tDef.On)
								return sOk and sEn and (not tDef.NeedsMover or ActiveMover == tDef.Name)
							end
							pcall(tDef.Run, wantArg, shouldContinue)
							tDef.Busy = false
							tDef.NextAt = os.clock() + tDef.Gap
							if tDef.NeedsMover then
								Core.releaseMover(tDef.Name)
							end
						end)
						if tDef.NeedsMover then
							break
						end
					end
				else
					tDef.NextAt = now + math.min(tDef.Gap, 0.5)
				end
			else
				tDef.NextAt = now + math.min(tDef.Gap, 0.8)
			end
		end
	end
end

function Core.computeEggInfo(rec)
	if type(rec) ~= "table" then
		return {
			Category = "Egg",
			Name = "Egg",
			Rarity = "Common",
			RarityRank = 1,
			RarityNum = 1,
			WeightKg = 0,
			Value = 0,
			Scale = 1,
			MutCount = 0,
			Mutations = {},
			AreaId = "",
		}
	end
	local assets = GameModuleCache.Assets
	local dir = assets and assets.Directory
	local cat = tostring(rec.AssetCategory or rec.PetCategory or rec.OutcomeCategory or rec.Category or "Egg")
	local entry = dir and dir[cat]
	local r = rec.Rarity
	if type(r) == "table" then
		r = r._id or r.Id or r.DisplayName
	end
	if (type(r) ~= "string" or r == "") and entry and entry.Rarity then
		r = type(entry.Rarity) == "table" and (entry.Rarity.DisplayName or entry.Rarity._id) or entry.Rarity
	end
	local rarityName = tostring(r or "Common")
	local rNumFromAssets = (entry and type(entry.Rarity) == "table" and tonumber(entry.Rarity.RarityNumber or entry.Rarity.Rank)) or nil
	local rarityRank = rNumFromAssets or Core.RARITY_RANK[rarityName] or 1

	local scale = tonumber(rec.AssetScale or rec.Scale) or 1
	local weightKg = tonumber(rec.WeightKg) or 0
	local recUtil = GameModuleCache.Rec
	if weightKg <= 0 and type(recUtil) == "table" and type(recUtil.WeightKgForScale) == "function" then
		local okW, w = pcall(recUtil.WeightKgForScale, cat, scale)
		if okW and type(w) == "number" then
			weightKg = w
		end
	end

	local mutList = {}
	if type(rec.Mutations) == "table" then
		for k, v in pairs(rec.Mutations) do
			if v == true then
				table.insert(mutList, tostring(k))
			elseif type(v) == "string" and v ~= "" then
				table.insert(mutList, v)
			end
		end
	elseif type(rec.BaseMutation) == "string" and rec.BaseMutation ~= "" then
		table.insert(mutList, rec.BaseMutation)
	end

	local value = tonumber(rec.EarningsPerSecond or rec.Value) or 0
	local mutMod = GameModuleCache.Mut
	if value <= 0 and entry then
		local baseRate = tonumber(entry.EarningRate or entry.BaseEarnings) or 0
		local mutMult = 1
		if type(mutMod) == "table" and type(mutMod.EarningsFor) == "function" then
			local okV, v = pcall(mutMod.EarningsFor, mutList)
			if okV and type(v) == "number" then
				mutMult = v
			else
				local okV2, v2 = pcall(mutMod.EarningsFor, baseRate, rec.Mutations, scale)
				if okV2 and type(v2) == "number" then
					value = v2
				end
			end
		end
		if value <= 0 and baseRate > 0 then
			local scaleCurve = scale > 5 and ((scale / 5) ^ 1.2 * 19.637875755794113) or (scale ^ 1.85)
			value = baseRate * scaleCurve * mutMult
		end
	end

	return {
		Category = cat,
		Name = tostring((entry and entry.DisplayName) or rec.DisplayName or cat),
		Rarity = rarityName,
		RarityRank = rarityRank,
		RarityNum = rarityRank,
		WeightKg = weightKg,
		Value = value,
		Scale = scale,
		MutCount = #mutList,
		Mutations = mutList,
		AreaId = tostring(rec.AreaId or ""),
	}
end

local CachedEggList = nil
function Core.eggList()
	if CachedEggList then
		return CachedEggList
	end
	local rows, seen = {}, {}
	local assets = GameModuleCache.Assets
	if assets and type(assets.Directory) == "table" then
		for cat, entry in pairs(assets.Directory) do
			if type(entry) == "table" and type(entry.Rarity) == "table" then
				local rNum = tonumber(entry.Rarity.RarityNumber or entry.Rarity.Rank) or 0
				local rName = tostring(entry.Rarity.DisplayName or entry.Rarity._id or rNum)
				table.insert(rows, {
					n = tostring(entry.DisplayName or cat),
					r = rNum,
					rn = rName,
					c = tostring(cat),
				})
			end
		end
	end
	table.sort(rows, function(a, b)
		if a.r ~= b.r then
			return a.r > b.r
		end
		return a.n < b.n
	end)
	local out = {}
	for _, row in ipairs(rows) do
		local lbl = row.n .. " [" .. row.rn .. "]"
		if seen[lbl] then
			lbl = lbl .. " (" .. row.c .. ")"
		end
		seen[lbl] = true
		table.insert(out, lbl)
	end
	CachedEggList = out
	return out
end

function Core.stripEggLabelSet(arr)
	if type(arr) ~= "table" or #arr == 0 then
		return nil
	end
	local set = {}
	for _, s in ipairs(arr) do
		local clean = tostring(s):gsub(" %(.-%)$", ""):gsub(" %[[^%]]*%]$", "")
		set[clean] = true
		set[tostring(s)] = true
	end
	return set
end

function Core.filterMatches(info, cfgPrefix, extraOpts)
	extraOpts = extraOpts or {}
	local cfg = TRex.Config
	local minRarKey = extraOpts.minRarityKey or (cfgPrefix .. "MinRarity")
	local minValKey = extraOpts.minValueKey or (cfgPrefix .. "MinValue")
	local areasKey = extraOpts.areasKey
	local specificKey = extraOpts.specificKey

	local reqRar = cfg[minRarKey]
	if reqRar and reqRar ~= "Any" and reqRar ~= "Off" then
		local reqRank = Core.RARITY_RANK[reqRar] or 0
		if info.RarityRank < reqRank then
			return false
		end
	end

	local minVal = tonumber(cfg[minValKey]) or 0
	if minVal > 0 and info.Value < minVal then
		return false
	end

	if cfgPrefix == "Steal" and cfg.RarityMinValue and cfg.RarityMinValue ~= "None" then
		local capRank = Core.RARITY_RANK[cfg.RarityMinValue] or 0
		if info.RarityRank >= capRank then
			local perRarMin = tonumber(cfg[info.Rarity .. "MinValue"]) or 0
			if perRarMin > 0 and info.Value < perRarMin then
				return false
			end
		end
	end

	if areasKey and type(cfg[areasKey]) == "table" and #cfg[areasKey] > 0 then
		if info.AreaId ~= "" and not table.find(cfg[areasKey], info.AreaId) then
			return false
		end
	end

	if specificKey and type(cfg[specificKey]) == "table" and #cfg[specificKey] > 0 then
		local allowed = Core.stripEggLabelSet(cfg[specificKey])
		if allowed and not allowed[info.Name] and not allowed[info.Category] then
			return false
		end
	end

	return true
end

function Core.isMissingInIndex(category)
	local save = Core.getSaveData()
	local unlocked = save and (save.UnlockedAssets or save.Codex or save.Index)
	if type(unlocked) == "table" then
		return unlocked[category] ~= true
	end
	return false
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

function Core.getPromptNear(pos, maxDist)
	local best, bestD = nil, maxDist or 18
	for _, desc in ipairs(Workspace:GetDescendants()) do
		if desc:IsA("ProximityPrompt") and desc.Enabled then
			local par = desc.Parent
			local pPos = nil
			if par and par:IsA("Attachment") then
				pPos = par.WorldPosition
			elseif par and par:IsA("BasePart") then
				pPos = par.Position
			elseif par and par:IsA("Model") then
				pPos = par:GetPivot().Position
			end
			if pPos then
				local d = (pPos - pos).Magnitude
				if d < bestD then
					bestD = d
					best = desc
				end
			end
		end
	end
	return best
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
	if rawget(t, "SampleHistory") ~= nil and rawget(t, "Player") == TRex.LocalPlayer and rawget(t, "Character") == TrustChar then
		return true
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

function Core.setRootCFrame(cf)
	local root = Core.getRoot()
	if not root then
		return false
	end
	Core.trustMovement()
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
	local endTime = tonumber(TRex.LocalPlayer and TRex.LocalPlayer:GetAttribute("RagdollEndTime")) or 0
	return endTime > Core.getServerNow()
end

function Core.cleanRespawn()
	RespawnAt = os.clock()
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

-- Motion Primitives matching Temp (`stepTo`, `ragTo`, `fastTweenTo`, `walkTo`)
local function clampFloorY(posXZ, refY)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local char = Core.getCharacter()
	if char then
		params.FilterDescendantsInstances = { char }
	end
	local res = Workspace:Raycast(Vector3.new(posXZ.X, math.max(refY, posXZ.Y) + 18, posXZ.Z), Vector3.new(0, -140, 0), params)
	if res then
		return math.max(refY, res.Position.Y + 3.2)
	end
	return refY
end

function Core.stepTo(targetPos, shouldContinue, hoverOffset)
	local root = Core.getRoot()
	if not root then
		return false
	end
	local stepSize = math.max(Core.getWalkSpeed() * 1.515, 40)
	local cur = Vector3.new(root.Position.X, math.max(root.Position.Y, targetPos.Y + (hoverOffset or 0)), root.Position.Z)
	while (not shouldContinue or shouldContinue()) and TRex.IsRunning do
		root = Core.getRoot()
		if not root or not Core.isAlive() then
			return false
		end
		local flat = Vector3.new(targetPos.X - cur.X, 0, targetPos.Z - cur.Z)
		local dist = flat.Magnitude
		if dist <= stepSize then
			Core.setRootCFrame(CFrame.new(targetPos + Vector3.new(0, hoverOffset or 3, 0)))
			return true
		end
		cur = cur + flat.Unit * stepSize
		local safeY = clampFloorY(cur, math.max(cur.Y, targetPos.Y + (hoverOffset or 0)))
		cur = Vector3.new(cur.X, safeY, cur.Z)
		local elapsed = 0
		while elapsed < 0.1 and (not shouldContinue or shouldContinue()) and TRex.IsRunning do
			Core.setRootCFrame(CFrame.new(cur))
			elapsed += RunService.Heartbeat:Wait()
		end
	end
	return false
end

function Core.fastTweenTo(targetPos, shouldContinue, speed)
	local root = Core.getRoot()
	if not root then
		return false
	end
	local spd = math.clamp(tonumber(speed) or TRex.Config.FastTweenSpeed or 3300, 120, 5000)
	while (not shouldContinue or shouldContinue()) and TRex.IsRunning do
		root = Core.getRoot()
		if not root or not Core.isAlive() then
			return false
		end
		local dt = RunService.Heartbeat:Wait()
		local delta = targetPos - root.Position
		local dist = delta.Magnitude
		if dist <= 6 then
			Core.setRootCFrame(CFrame.new(targetPos))
			return true
		end
		local step = math.min(spd * math.clamp(dt, 0.005, 0.08), 240, dist)
		Core.setRootCFrame(CFrame.new(root.Position + delta.Unit * step))
	end
	return false
end

function Core.walkTo(targetPos, shouldContinue, speedMult)
	local hum = Core.getHumanoid()
	local root = Core.getRoot()
	if not hum or not root then
		return false
	end
	local mult = speedMult or 0.95
	local bestDist = math.huge
	local progressAt = os.clock()
	while (not shouldContinue or shouldContinue()) and TRex.IsRunning do
		root = Core.getRoot()
		hum = Core.getHumanoid()
		if not root or not hum or not Core.isAlive() then
			return false
		end
		if root.Anchored then
			pcall(Core.invokeNS, "Treadmill", "AskDoff")
		end
		local diff = targetPos - root.Position
		local flat = Vector3.new(diff.X, 0, diff.Z)
		if flat.Magnitude < 3.5 then
			Core.setRootCFrame(CFrame.new(targetPos) * root.CFrame.Rotation)
			return true
		end
		Core.trustMovement()
		local speed = math.max(16, hum.WalkSpeed * mult)
		local vx = flat.Unit * math.min(speed, flat.Magnitude / 0.05)
		pcall(function()
			root.AssemblyLinearVelocity = Vector3.new(vx.X, root.AssemblyLinearVelocity.Y, vx.Z)
		end)
		if flat.Magnitude < bestDist - 3 then
			bestDist = flat.Magnitude
			progressAt = os.clock()
		elseif os.clock() - progressAt > 4 then
			if os.clock() - RespawnAt > 10 then
				Core.cleanRespawn()
			end
			return false
		end
		RunService.Heartbeat:Wait()
	end
	if root then
		pcall(function()
			root.AssemblyLinearVelocity = Vector3.zero
		end)
	end
	return false
end

local function findGuardPartForArea(areaName)
	local ga = Core.findWorldPath("Areas", "GuardAreas", tostring(areaName or ""))
	local g = ga and ga:FindFirstChild("Guard")
	if not g then
		return nil
	end
	if g:IsA("BasePart") then
		return g
	end
	return g:FindFirstChild("HumanoidRootPart", true) or g.PrimaryPart or g:FindFirstChildWhichIsA("BasePart", true)
end

local function findNearestStrikeEgg(fromPos, triedUids)
	local eggMod = GameModuleCache.Egg
	if not (type(eggMod) == "table" and type(eggMod.ReadFieldEggs) == "function") then
		return nil
	end
	local okR, eggs = pcall(eggMod.ReadFieldEggs)
	if not okR or type(eggs) ~= "table" then
		return nil
	end
	local lp = TRex.LocalPlayer
	local prefix = lp and ("FirstAreaEgg_" .. tostring(lp.UserId)) or ""
	local best, bestDist = nil, 600
	for k, rec in pairs(eggs) do
		local uid = type(rec) == "table" and (rec.Uid or k) or nil
		if type(uid) == "string" and not triedUids[uid] and typeof(rec.BottomCFrame) == "CFrame" then
			if rec.State == nil or rec.State == "Slot" or rec.State == "Dropped" then
				local isFirst = prefix ~= "" and uid:sub(1, #prefix) == prefix
				local slot = nil
				if uid:sub(1, 13) == "FirstAreaEgg_" then
					if isFirst then
						slot = uid:match("_([%w ]+:Slot_%d+)$")
					end
				elseif type(rec.AreaId) == "string" and type(rec.NestId) == "string" then
					slot = rec.AreaId .. ":" .. rec.NestId
				end
				if slot then
					local areaFromSlot = isFirst and slot:match("^([%w ]+):Slot_%d+$") or nil
					local guard = findGuardPartForArea(rec.AreaId)
						or (areaFromSlot and findGuardPartForArea(areaFromSlot))
						or (isFirst and findGuardPartForArea("Forest"))
					if guard then
						local p = rec.BottomCFrame.Position
						local d = Vector3.new(p.X - fromPos.X, 0, p.Z - fromPos.Z).Magnitude
						if d <= 600 and d < bestDist then
							bestDist = d
							best = { uid = uid, slot = slot, guard = guard, at = p }
						end
					end
				end
			end
		end
	end
	return best
end

Core.IsRagTeleBusy = false

function Core.ragTo(targetPosOrFn, shouldContinue)
	local strikeRE = Core.getRemote("RE/GuardPatrol/ForestStrike")
	local eggMod = GameModuleCache.Egg
	local root = Core.getRoot()
	local lp = TRex.LocalPlayer
	if not strikeRE or not strikeRE:IsA("RemoteEvent") or not eggMod or not root or not lp then
		return false
	end
	if Core.isCarryingEgg() or Core.isRagdolled() then
		return false
	end
	local getPos = (type(targetPosOrFn) == "function") and targetPosOrFn or function()
		return targetPosOrFn
	end
	Core.IsRagTeleBusy = true
	local tried, chosen = {}, nil
	for _ = 1, 3 do
		local curRoot = Core.getRoot()
		local cand = findNearestStrikeEgg((curRoot or root).Position, tried)
		if not cand or (shouldContinue and not shouldContinue()) then
			break
		end
		local tStart = 0
		while not Core.isCarryingEgg(cand.uid) and tStart < 2.5 and (not shouldContinue or shouldContinue()) do
			Core.setRootCFrame(CFrame.new(cand.at + Vector3.new(0, 3, 0)))
			local okC, errC = pcall(eggMod.CarryFieldEgg, cand.uid, cand.slot)
			if not okC and type(errC) == "string" and errC:lower():find("full") then
				Core.IsRagTeleBusy = false
				return false
			end
			if okC ~= true and type(errC) == "string" and tStart > 0.4 and not errC:lower():find("closer") then
				break
			end
			tStart += RunService.Heartbeat:Wait()
		end
		if Core.isCarryingEgg(cand.uid) then
			chosen = cand
			break
		end
		tried[cand.uid] = true
	end

	if not chosen then
		Core.IsRagTeleBusy = false
		return false
	end

	local teleported = false
	local ragConn = lp:GetAttributeChangedSignal("RagdollEndTime"):Connect(function()
		if teleported or not Core.isRagdolled() then
			return
		end
		local dst = getPos()
		if dst then
			teleported = true
			Core.setRootCFrame(CFrame.new(dst))
		end
	end)

	pcall(strikeRE.FireServer, strikeRE, {
		EggUid = chosen.uid,
		GuardCFrame = chosen.guard.CFrame,
	})

	local waited = 0
	while not teleported and waited < 3 and (not shouldContinue or shouldContinue()) do
		waited += RunService.Heartbeat:Wait()
	end
	ragConn:Disconnect()

	if Core.isCarryingEgg(chosen.uid) then
		pcall(eggMod.DropFieldEgg, "PlayerRequest")
	end
	Core.IsRagTeleBusy = false

	if teleported then
		task.spawn(function()
			local hum = Core.getHumanoid()
			local deadAt = os.clock() + 1.5
			while hum and hum.Parent and os.clock() < deadAt do
				local st = hum:GetState()
				if st == Enum.HumanoidStateType.Freefall
					or st == Enum.HumanoidStateType.Physics
					or st == Enum.HumanoidStateType.Ragdoll
					or st == Enum.HumanoidStateType.FallingDown
					or st == Enum.HumanoidStateType.None
				then
					pcall(hum.ChangeState, hum, Enum.HumanoidStateType.GettingUp)
				end
				if hum.PlatformStand then
					hum.PlatformStand = false
				end
				RunService.Heartbeat:Wait()
			end
		end)
	end

	local dst = getPos()
	local nowRoot = Core.getRoot()
	return teleported and dst ~= nil and nowRoot ~= nil and (nowRoot.Position - dst).Magnitude <= 30
end

-- VenyxAG Anti-Guard System
local AgBusy = false
local AgFinishedAt = 0
local SavedCameraType = nil

function Core.isAntiGuardBusy()
	return AgBusy or (os.clock() - AgFinishedAt < 0.7)
end

local function setupAntiGuard()
	local function onGrabbed(hitboxPart)
		if TRex.Config.AntiGuard ~= true or AgBusy or Core.IsRagTeleBusy then
			return
		end
		local root = Core.getRoot()
		if not root then
			return
		end
		AgBusy = true
		local cam = Workspace.CurrentCamera
		if cam then
			SavedCameraType = cam.CameraType
			cam.CameraType = Enum.CameraType.Scriptable
		end

		pcall(function()
			local bounce = Core.getSeparationBouncePos()
			local stepMid = Vector3.new((root.Position.X + bounce.X) * 0.5, math.max(root.Position.Y, bounce.Y) + 18, math.clamp(root.Position.Z, -415, -305))
			Core.setRootCFrame(CFrame.new(stepMid))
			task.wait(0.05)
			Core.setRootCFrame(CFrame.new(bounce))
			if hitboxPart and hitboxPart.Parent then
				for _, w in ipairs(root:GetChildren()) do
					if w:IsA("Weld") or w:IsA("WeldConstraint") or w:IsA("Motor6D") then
						if w.Part0 == hitboxPart or w.Part1 == hitboxPart then
							w:Destroy()
						end
					end
				end
			end
		end)

		task.delay(0.25, function()
			if cam then
				if SavedCameraType then
					cam.CameraType = SavedCameraType
				elseif cam.CameraType == Enum.CameraType.Scriptable then
					cam.CameraType = Enum.CameraType.Custom
				end
			end
			AgBusy = false
			AgFinishedAt = os.clock()
		end)
	end

	TRex.connectSignal(Workspace.DescendantAdded, function(desc)
		if TRex.Config.AntiGuard ~= true then
			return
		end
		if desc.Name == "Hitbox" and desc:IsA("BasePart") then
			local root = Core.getRoot()
			if root and (desc.Position - root.Position).Magnitude < 16 then
				local guardModel = desc.Parent
				local st = guardModel and guardModel:GetAttribute("GuardState")
				if st ~= "Sleeping" then
					onGrabbed(desc)
				end
			end
		end
	end)
end

-- Invisibility Arbitration
local InvisibleActive = false
local InvisBusy = false

function Core.isInvisible()
	return InvisibleActive
end

function Core.setInvisibility(enabled)
	local want = enabled == true
	if InvisibleActive == want or InvisBusy then
		return
	end
	InvisBusy = true
	InvisibleActive = want
	local root = Core.getRoot()
	local savedCf = root and root.CFrame
	local char = Core.getCharacter()
	if want and char then
		pcall(function()
			local rh = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
			local wrist = rh and (rh:FindFirstChild("RightWrist") or rh:FindFirstChildOfClass("Motor6D"))
			if wrist then
				wrist:Destroy()
			end
		end)
		Core.fireNS("RigSync", "ServerBreakJoints")
	elseif not want and savedCf then
		Core.cleanRespawn()
		task.delay(0.45, function()
			Core.setRootCFrame(savedCf)
		end)
	end
	InvisBusy = false
end

function Core.needBody()
	if not InvisibleActive then
		return true
	end
	if TRex.Config.Invisibility then
		Core.setInvisibility(false)
		task.wait(0.25)
	end
	return not InvisibleActive
end

-- Anti-AFK (no VirtualUser)
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
	if enabled == false then
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

function Core.init()
	if GameModuleCache.Assets and type(GameModuleCache.Assets.Directory) == "table" then
		for _, item in pairs(GameModuleCache.Assets.Directory) do
			if type(item) == "table" and type(item.Rarity) == "table" then
				local rNum = tonumber(item.Rarity.RarityNumber or item.Rarity.Rank)
				local rName = tostring(item.Rarity.DisplayName or item.Rarity._id or "")
				if rNum and rName ~= "" then
					Core.RARITY_RANK[rName] = rNum
				end
			end
		end
	end

	local eggMod = GameModuleCache.Egg
	if type(eggMod) == "table" and eggMod.CarryChanged then
		TRex.connectSignal(eggMod.CarryChanged, function(payload)
			if type(payload) == "table" then
				LastCarryState = payload
			end
		end)
	end

	local verdictRE = Core.getRemote("RE/EggWorld/FieldEggRedeemVerdict")
	if verdictRE and verdictRE:IsA("RemoteEvent") then
		TRex.connectSignal(verdictRE.OnClientEvent, function()
			RedeemVerdictAt = os.clock()
		end)
	end

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

	local function onMovementStep()
		local cfg = TRex.Config
		if cfg.AutoSteal or cfg.SpeedBoost or cfg.AutoButterfly or cfg.AutoHit or cfg.AutoShootingStar or cfg.AutoCaptureEgg then
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

	setupAntiGuard()
	TRex.registerCleanupHook(Core.restoreAntiAFK)
	if TRex.Config.AntiAFK then
		Core.applyAntiAFK(true)
	end
end
