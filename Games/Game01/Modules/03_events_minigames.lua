-- Games/Game01/Modules/03_events_minigames.lua
-- Events & Admin Abuse module: Butterfly Bloom + Net/Trade/Craft, Wisp Companion, Banjo Cricket,
-- Shooting Star & Stage, Alien Biome (Fishing, Rod, Eclipse, Relics, Mastery, Pearls),
-- Minigame Eggs (RLGL / T-Rex Run), Capture The Egg, Cursed Island Wars

local TRex = _G.TRex or TRex
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Core = TRex.Core

local Events = {}
TRex.Events = Events

local ButterflyRow
local WispRow
local StarRow
local AlienRow
local CaptureRow
local IslandWarsRow

local LiveButterflies = {}
local ButterflyFlags = nil
local ButterflySwarm = nil
local BanjoData = nil
local CosmicEclipseMod = nil
local AlienGateMod = nil
local FishCastMod = nil

local StarState = {
	Pay = nil,
	HoldAt = nil,
	Caught = 0,
	Slipped = 0,
	Jumped = {},
}

local BanjoState = {
	Notes = nil,
	ListenUntil = 0,
	WrongAt = 0,
	Acks = {},
	Solved = false,
	Done = false,
}

local CaptureState = {
	HoverTarget = nil,
	RetargetAt = 0,
	StandingText = "",
}

local IslandState = {
	Snap = nil,
	At = 0,
	SuddenDeath = false,
	ShotId = 0,
	Cooldowns = { Bat = 0, Launcher = 0 } :: { [string]: number },
}

local LagoonState = {
	OwnTrip = nil,
	Trip = nil,
	ExitAt = -99,
	SpotCache = nil,
	Deck = nil,
	DeckCanCollide = nil,
	FailCount = 0,
	RetryAt = 0,
	RelicCooldownAt = 0,
	TradeCooldownAt = 0,
}

local BUTTERFLY_TIER_FROM_LABEL = {
	Emerald = "Green",
	Sapphire = "Blue",
	Amethyst = "Purple",
	Radiant = "Golden",
}

local BUTTERFLY_RANK = {
	Green = 1,
	Blue = 2,
	Purple = 3,
	Golden = 4,
}

local BUTTERFLY_DEFAULT_COSTS = {
	Green = 10,
	Blue = 10,
	Purple = 50,
}

local ESSENCE_DEFAULT_RECIPE = {
	Green = 240,
	Blue = 115,
	Purple = 40,
	Golden = 1,
}

local BANJO_FALLBACK_POS = {
	Vector3.new(6218.93, 17159.02, 16903.8),
	Vector3.new(6257.93, 17159.02, 16912.8),
	Vector3.new(6270.93, 17159.02, 16903.8),
	Vector3.new(6244.93, 17159.02, 16918.8),
	Vector3.new(6231.93, 17159.02, 16912.8),
}

local BANJO_REF_CENTER = Vector3.new(6244.93, 17159.02, 16880)
local BANJO_NPC_FALLBACK = Vector3.new(6272.46, 17164.04, 16958.18)
local BANJO_ROOM_REF = Vector3.new(6246.9, 17161, 16887)
local BANJO_LEAP_REF = Vector3.new(6246.9, 17165, 16881.6)
local BANJO_OUT_LEAP_FALLBACK = Vector3.new(5905.63, 17027.3, 15610.83)
local BANJO_W1_FALLBACK = Vector3.new(6248.72, 17163, 16928)
local BANJO_W2_FALLBACK = Vector3.new(6248.72, 17163, 16944)

local function safeRequirePath(parts)
	local cur: Instance? = ReplicatedStorage
	for _, p in ipairs(parts) do
		cur = cur and cur:FindFirstChild(p)
	end
	if cur and cur:IsA("ModuleScript") then
		local ok, res = pcall(require, cur)
		if ok then
			return res
		end
	end
	return nil
end

local function findPath(...)
	local found = Core.findWorldPath(...)
	if found then
		return found
	end
	local cur: Instance? = Workspace
	local n = select("#", ...)
	for i = 1, n do
		local name = select(i, ...)
		cur = cur and cur:FindFirstChild(name)
	end
	return cur
end

local function getObjPos(obj: any): Vector3?
	if typeof(obj) == "Instance" then
		if obj:IsA("BasePart") then
			return obj.Position
		elseif obj:IsA("Attachment") then
			return obj.WorldPosition
		elseif obj:IsA("PVInstance") then
			return obj:GetPivot().Position
		end
	end
	return nil
end

local function setRow(row, key, val)
	if key then
		TRex.State[key] = val
	end
	if row and row.Set then
		row:Set(val)
	end
end

local function raycastGround(pos, extraExclude)
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Exclude
	local exc = {}
	local char = Core.getCharacter()
	if char then
		exc[#exc + 1] = char
	end
	if extraExclude then
		exc[#exc + 1] = extraExclude
	end
	rp.FilterDescendantsInstances = exc
	local hit = Workspace:Raycast(pos + Vector3.new(0, 25, 0), Vector3.new(0, -120, 0), rp)
	if hit then
		local hum = Core.getHumanoid()
		return Vector3.new(pos.X, hit.Position.Y + (hum and hum.HipHeight or 2) + 1, pos.Z)
	end
	return pos
end

local function waitSafe(secs, shouldContinue)
	local t0 = os.clock()
	while os.clock() - t0 < secs do
		if shouldContinue and not shouldContinue() then
			return false
		end
		RunService.Heartbeat:Wait()
	end
	return not shouldContinue or shouldContinue()
end

local function sameCharacterGuard(shouldContinue)
	local char0 = Core.getCharacter()
	return function()
		if shouldContinue and not shouldContinue() then
			return false
		end
		return Core.getCharacter() == char0 and Core.isAlive()
	end
end

local function findOwnedTools(pred)
	local out = {}
	local lp = Players.LocalPlayer
	local char = Core.getCharacter()
	local bp = lp and lp:FindFirstChildOfClass("Backpack")
	for _, parent in ipairs({ char, bp }) do
		if parent then
			for _, child in ipairs(parent:GetChildren()) do
				if child:IsA("Tool") and pred(child) then
					out[#out + 1] = child
				end
			end
		end
	end
	return out
end

local function isInAlienLagoon()
	local lp = Players.LocalPlayer
	if lp and lp:GetAttribute("InAlienLagoon") == true then
		return true
	end
	local r = Core.getRoot()
	if r and r.Position.X <= -10000 then
		return true
	end
	return false
end

local function isAlienBiomeOpen()
	if type(AlienGateMod) == "table" and type(AlienGateMod.IsOpen) == "function" then
		local ok, res = pcall(AlienGateMod.IsOpen, Core.getServerNow())
		if ok then
			return res == true
		end
	end
	return findPath("Build", "AlienBiomeZone") ~= nil
end

local function isBloomActive()
	if Workspace:GetAttribute("Event_ButterflyBloom") ~= true then
		return false
	end
	local endsAt = tonumber(Workspace:GetAttribute("ButterflyBloomEndsAt"))
	if endsAt then
		return Core.getServerNow() < endsAt
	end
	return true
end

local function exitSafeZoneIfNeeded(shouldContinue)
	local root = Core.getRoot()
	if not root or not Core.isInSafeZone(root.Position) then
		return true
	end
	local sep = Core.getSeparationLinePos()
	local target = Vector3.new(sep.X + 35, root.Position.Y, math.clamp(root.Position.Z, -415, -305))
	return Core.walkTo(target, shouldContinue, 1.0)
end

local function leaveTree()
	if not Core.inEnchantedTree() then
		return
	end
	local exitTrig = findPath("Build", "EnchantedTreeInterior", "Markers", "ExitTrigger")
	if not exitTrig or not exitTrig:IsA("BasePart") then
		return
	end
	Core.setRootCFrame(CFrame.new(exitTrig.Position + exitTrig.CFrame.LookVector * (exitTrig.Size.Z * 0.5 + 3)))
	RunService.Heartbeat:Wait()
	Core.setRootCFrame(exitTrig.CFrame)
	local deadline = os.clock() + 1.5
	while Core.inEnchantedTree() and os.clock() < deadline do
		RunService.Heartbeat:Wait()
	end
end

local function enterTree(shouldContinue)
	if Core.inEnchantedTree() then
		return true
	end
	local guard = sameCharacterGuard(shouldContinue)
	if not guard() then
		return false
	end
	if isInAlienLagoon() then
		Events.leaveLagoon(guard)
	end
	if not exitSafeZoneIfNeeded(guard) then
		return false
	end
	local prompt = findPath("Build", "EnchantedTreeInterior", "Markers", "EnterTrigger", "EnchantedTreeEntrance", "EnchantedTreePrompt")
	local enterPos = prompt and getObjPos(prompt.Parent)
	if not enterPos then
		return false
	end
	local stagingPos = enterPos + Vector3.new(0, 0, -12)
	for _ = 1, 2 do
		local root = Core.getRoot()
		if not root or not guard() or Core.isNightPhase() or (root.Position - stagingPos).Magnitude <= 500 then
			break
		end
		Core.ragTo(stagingPos + Vector3.new(0, 3, 0), guard)
	end
	if not guard() then
		return false
	end
	local root = Core.getRoot()
	if root and (root.Position - stagingPos).Magnitude > 60 then
		Core.stepTo(stagingPos, guard, 3)
	end
	local fpp = TRex.resolveGlobalFunc("fireproximityprompt")
	for _ = 1, 4 do
		if not guard() then
			return false
		end
		Core.setRootCFrame(CFrame.new(enterPos + Vector3.new(0, 3, -6)))
		if fpp and prompt then
			pcall(fpp, prompt)
		end
		local w = os.clock() + 4
		while os.clock() < w and not Core.inEnchantedTree() and guard() do
			RunService.Heartbeat:Wait()
		end
		if Core.inEnchantedTree() then
			return true
		end
	end
	return false
end

local function getButterfliesSave()
	local sd = Core.getSaveData()
	return (type(sd) == "table" and type(sd.Butterflies) == "table") and sd.Butterflies or {}
end

local function isTreeUnlocked()
	if getButterfliesSave().NetClaimed == true then
		return true
	end
	local lp = Players.LocalPlayer
	return lp and lp:GetAttribute("EnchantedTreeUnlocked") == true
end

local function getButterflyStationPos(name)
	local obj = findPath("Machines", "ButterflyStation", name)
	local p = obj and (obj:FindFirstChild("Anchor") or obj)
	return getObjPos(p)
end

local function getButterflyCostAndRecipe()
	local costs = table.clone(BUTTERFLY_DEFAULT_COSTS)
	local rec = table.clone(ESSENCE_DEFAULT_RECIPE)
	if type(ButterflyFlags) == "table" then
		pcall(function()
			local map = { Green = "GreenToBlueCost", Blue = "BlueToPurpleCost", Purple = "PurpleToGoldenCost" }
			for k, flagName in pairs(map) do
				if ButterflyFlags[flagName] and type(ButterflyFlags[flagName].Get) == "function" then
					costs[k] = tonumber(ButterflyFlags[flagName]:Get()) or costs[k]
				end
			end
			for k in pairs(rec) do
				local fn = "Essence" .. k
				if ButterflyFlags[fn] and type(ButterflyFlags[fn].Get) == "function" then
					rec[k] = tonumber(ButterflyFlags[fn]:Get()) or rec[k]
				end
			end
		end)
	end
	return costs, rec
end

local function canCraftEssence(counts, rec)
	for tier, need in pairs(rec) do
		if (counts[tier] or 0) < need then
			return false
		end
	end
	return true
end

local function computeSmartTrades(counts, costs, rec)
	local g = counts.Green or 0
	local b = counts.Blue or 0
	local p = counts.Purple or 0
	local au = counts.Golden or 0
	for k = 60, 1, -1 do
		local needAu = math.max(0, k * rec.Golden - au)
		local needP = math.max(0, k * rec.Purple + costs.Purple * needAu - p)
		local needB = math.max(0, k * rec.Blue + costs.Blue * needP - b)
		if g >= k * rec.Green + costs.Green * needB then
			return { Green = needB, Blue = needP, Purple = needAu }
		end
	end
	return nil
end

local function claimButterflyNet(shouldContinue)
	local pos = getButterflyStationPos("NetStand")
	if not pos or not enterTree(shouldContinue) then
		return false
	end
	local claimed = false
	for _ = 1, 5 do
		if shouldContinue and not shouldContinue() then
			break
		end
		local holdEnd = os.clock() + 0.6
		while os.clock() < holdEnd and (not shouldContinue or shouldContinue()) do
			Core.setRootCFrame(CFrame.new(pos + Vector3.new(0, 3, 4)))
			RunService.Heartbeat:Wait()
		end
		local ok, res = Core.invokeRemote("RF/Butterflies/AskClaimNet")
		claimed = (ok == true and res == true) or getButterfliesSave().NetClaimed == true
		if claimed then
			break
		end
		waitSafe(0.8, shouldContinue)
	end
	leaveTree()
	return claimed or getButterfliesSave().NetClaimed == true
end

local function isButterflyNetTool(tool)
	return tool:GetAttribute("ButterflyNet") == true
		or tool:GetAttribute("ItemType") == "ButterflyNet"
		or tool.Name == "Butterfly Net"
end

local function getAllowedButterflyTiers()
	local set = {}
	local arr = TRex.Config.CatchButterflies or {}
	if #arr == 0 then
		return { Green = true, Blue = true, Purple = true, Golden = true }
	end
	for _, label in ipairs(arr) do
		local first = tostring(label):match("^(%a+)")
		local tier = first and BUTTERFLY_TIER_FROM_LABEL[first]
		if tier then
			set[tier] = true
		end
	end
	if not next(set) then
		return { Green = true, Blue = true, Purple = true, Golden = true }
	end
	return set
end

local function pickBestButterfly(rootPos, curId)
	local tiers = getAllowedButterflyTiers()
	local speed = math.clamp(tonumber(TRex.Config.ButterflySpeed) or 320, 100, 600)
	local useRank = TRex.Config.ButterflyPriority ~= "Nearest"
	local best, bestScore = nil, nil
	local seen = {}
	local now = Core.getServerNow()

	local function evalBf(id, bf, pos)
		if typeof(pos) ~= "Vector3" or type(bf) ~= "table" or not tiers[bf.Tier] then
			return
		end
		local score = (pos - rootPos).Magnitude / speed
			- (useRank and ((BUTTERFLY_RANK[bf.Tier] or 0) * 1000) or 0)
			- (id == curId and 1 or 0)
		if not best or score < bestScore then
			best = { Id = id, Pos = pos, Flight = bf }
			bestScore = score
		end
	end

	if type(ButterflySwarm) == "table" and type(ButterflySwarm.Each) == "function" then
		pcall(function()
			for k, obj in ButterflySwarm.Each() do
				if type(obj) == "table" and type(obj.Flight) == "table" and typeof(obj.Body) == "Instance" then
					local id = obj.Flight.Id or k
					seen[id] = true
					evalBf(id, obj.Flight, getObjPos(obj.Body))
				end
			end
		end)
	end

	if type(ButterflySwarm) == "table" and type(ButterflySwarm.Cat) == "table" and not next(seen) then
		local cat = ButterflySwarm.Cat
		for id, bf in pairs(LiveButterflies) do
			if not seen[id] and type(cat.PositionAt) == "function" then
				local ok, p = pcall(cat.PositionAt, bf, now)
				if ok then
					evalBf(id, bf, p)
				end
			end
		end
	end

	if best then
		local vel = Vector3.zero
		if type(ButterflySwarm) == "table" and type(ButterflySwarm.Cat) == "table" and type(ButterflySwarm.Cat.VelocityAt) == "function" then
			local ok, v = pcall(ButterflySwarm.Cat.VelocityAt, best.Flight, now)
			if ok and typeof(v) == "Vector3" then
				vel = Vector3.new(v.X, 0, v.Z)
			end
		end
		best.Vel = vel
	end
	return best
end

function Events.leaveLagoon(shouldContinue)
	if not isInAlienLagoon() then
		return true
	end
	local guide = Workspace:FindFirstChild("AlienLagoonGuide")
	local gPart = guide and (guide:IsA("Model") and guide.PrimaryPart or guide:FindFirstChild("RootPart"))
	local gPos = getObjPos(gPart)
	if not gPos then
		return false
	end
	if os.clock() - LagoonState.ExitAt < 20 then
		while isInAlienLagoon() and os.clock() - LagoonState.ExitAt < 20 do
			if shouldContinue and not shouldContinue() then
				return false
			end
			RunService.Heartbeat:Wait()
		end
		if not isInAlienLagoon() then
			return waitSafe(1, shouldContinue)
		end
	end

	setRow(AlienRow, "AlienStatus", "กำลังออกจากทะเลสาบเอเลี่ยน")
	for _ = 1, 10 do
		if not isInAlienLagoon() then
			return waitSafe(1, shouldContinue)
		end
		Core.stepTo(gPos + Vector3.new(0, 3, 0), shouldContinue, 4)
		if not waitSafe(0.3, shouldContinue) then
			return false
		end
		local ok, ans = Core.invokeRemote("RF/AlienLagoon/Request")
		if ok and ans == "Exit" then
			LagoonState.OwnTrip = { Kind = "Exit", At = os.clock() }
			LagoonState.Trip = { Kind = "Exit", At = os.clock() }
			LagoonState.ExitAt = os.clock()
			while LagoonState.Trip and os.clock() - LagoonState.Trip.At < 10 and isInAlienLagoon() do
				if shouldContinue and not shouldContinue() then
					return false
				end
				RunService.Heartbeat:Wait()
			end
			if not isInAlienLagoon() then
				return waitSafe(1, shouldContinue)
			end
		end
	end
	return not isInAlienLagoon()
end

local function moveToBiomePoint(pos, shouldContinue, arriveDist)
	local root = Core.getRoot()
	if isInAlienLagoon() then
		if root and (root.Position - pos).Magnitude < 3000 then
			return Core.stepTo(pos, shouldContinue, arriveDist or 6)
		end
		if not Events.leaveLagoon(shouldContinue) then
			return false
		end
	end
	if not exitSafeZoneIfNeeded(shouldContinue) then
		return false
	end
	root = Core.getRoot()
	if root and (root.Position - pos).Magnitude > 300 then
		Core.ragTo(pos + Vector3.new(0, 3, 0), shouldContinue)
	end
	return (not shouldContinue or shouldContinue()) and Core.stepTo(pos, shouldContinue, arriveDist or 6)
end

local function getCastSeconds()
	local map = {
		["x1.5 Perfect"] = 0.875,
		["x1.2"] = 1.0,
		["x1.1"] = 0.5,
		["x1.0 Fastest"] = 0.02,
	}
	local k = map[TRex.Config.CastLuckBoost] or 0.875
	return 1.2 * (k ^ 0.7142857142857143)
end

local function getBestRodTool()
	local rods = findOwnedTools(function(t)
		if type(FishCastMod) == "table" and type(FishCastMod.IsRod) == "function" then
			local ok, r = pcall(FishCastMod.IsRod, t)
			if ok then
				return r == true
			end
		end
		return t:GetAttribute("IsRod") == true or t.Name:lower():find("rod") ~= nil
	end)
	return rods[1]
end

local function findWaterAimFrom(origin)
	if type(FishCastMod) ~= "table" or type(FishCastMod.Aim) ~= "function" or type(FishCastMod.Probe) ~= "function" or type(FishCastMod.ChargeAt) ~= "function" then
		return nil
	end
	local charge = FishCastMod.ChargeAt(getCastSeconds())
	local lp = Players.LocalPlayer
	local exc = {}
	if lp and lp.Character then
		exc[#exc + 1] = lp.Character
	end
	if LagoonState.Deck then
		exc[#exc + 1] = LagoonState.Deck
	end
	for i = 0, 15 do
		local look = CFrame.Angles(0, i * math.pi / 8, 0).LookVector
		local okAim, aimCfg = pcall(FishCastMod.Aim, origin, look, charge)
		if okAim and aimCfg then
			local okPr, hit = pcall(FishCastMod.Probe, aimCfg, exc)
			if okPr and type(hit) == "table" and hit.Water and typeof(hit.Point) == "Vector3" then
				return hit.Point
			end
		end
	end
	return nil
end

local function findFishingSpot()
	local wantLagoon = TRex.Config.FishingSpot == "Alien Lagoon" or TRex.Config.AutoCosmicEclipse == true
	local inLag = isInAlienLagoon()
	local key = tostring(TRex.Config.CastLuckBoost) .. tostring(TRex.Config.FishingSpot) .. tostring(inLag)
	if LagoonState.SpotCache and LagoonState.SpotCache.Key == key then
		if not LagoonState.SpotCache.Pad or (LagoonState.Deck and LagoonState.Deck.Parent) then
			return LagoonState.SpotCache
		end
	end

	if wantLagoon and inLag then
		local lag = Workspace:FindFirstChild("AlienLagoon")
		local waterRoot = lag and lag:FindFirstChild("Water", true)
		local bestW = nil
		local ref = Vector3.new(-14000, 0, 16000)
		for _, p in ipairs(waterRoot and waterRoot:GetDescendants() or {}) do
			if p:IsA("BasePart") then
				local d = Vector3.new(p.Position.X - ref.X, 0, p.Position.Z - ref.Z).Magnitude
				if not bestW or d < Vector3.new(bestW.Position.X - ref.X, 0, bestW.Position.Z - ref.Z).Magnitude then
					bestW = p
				end
			end
		end
		if bestW then
			local rp = RaycastParams.new()
			rp.FilterType = Enum.RaycastFilterType.Exclude
			rp.RespectCanCollide = true
			local exc: { Instance } = { waterRoot :: Instance }
			if Core.getCharacter() then
				exc[#exc + 1] = Core.getCharacter()
			end
			rp.FilterDescendantsInstances = exc
			local half = math.max(bestW.Size.X, bestW.Size.Z) * 0.5
			for _, off in ipairs({ 5, 10, 16 }) do
				for deg = 0, 345, 15 do
					local dir = CFrame.Angles(0, math.rad(deg), 0).LookVector
					local rayOrig = Vector3.new(bestW.Position.X, bestW.Position.Y + 80, bestW.Position.Z) + dir * (half + off)
					local hit = Workspace:Raycast(rayOrig, Vector3.new(0, -160, 0), rp)
					if hit then
						local stand = hit.Position + Vector3.new(0, 3, 0)
						local aim = findWaterAimFrom(stand)
						if aim then
							LagoonState.SpotCache = { At = stand, Aim = aim, Key = key }
							return LagoonState.SpotCache
						end
					end
				end
			end
		end
		local r = Core.getRoot()
		if r then
			local aim = findWaterAimFrom(r.Position)
			if aim then
				LagoonState.SpotCache = { At = r.Position, Aim = aim, Key = key }
				return LagoonState.SpotCache
			end
		end
	end

	local zone = findPath("Build", "AlienBiomeZone")
	local dock = zone and zone:FindFirstChild("Dock", true)
	local deck = nil
	for _, p in ipairs(dock and dock:GetDescendants() or {}) do
		if p:IsA("BasePart") then
			if not deck or p.Size.X * p.Size.Z > deck.Size.X * deck.Size.Z then
				deck = p
			end
		end
	end
	if deck then
		if LagoonState.Deck ~= deck then
			LagoonState.Deck = deck
			LagoonState.DeckCanCollide = deck.CanCollide
		end
		local span = math.max(deck.Size.X, deck.Size.Z)
		local y = deck.Position.Y + deck.Size.Y * 0.5 + 3
		local axis = (deck.Size.X > deck.Size.Z) and deck.CFrame.RightVector or deck.CFrame.LookVector
		local flatAxis = Vector3.new(axis.X, 0, axis.Z)
		for _, frac in ipairs({ 0.4, -0.4, 0, 0.2, -0.2 }) do
			local stand = Vector3.new(deck.Position.X, y, deck.Position.Z) + flatAxis * (span * frac)
			local aim = findWaterAimFrom(stand)
			if aim then
				LagoonState.SpotCache = { At = stand, Aim = aim, Key = key, Pad = true }
				return LagoonState.SpotCache
			end
		end
	end
	return nil
end

local function isCosmicEclipseActive()
	if not TRex.Config.AutoCosmicEclipse or type(CosmicEclipseMod) ~= "table" then
		return nil
	end
	local ok, cur = pcall(CosmicEclipseMod.Current)
	if ok and type(cur) == "table" and cur.Active then
		local okLeft, left = pcall(CosmicEclipseMod.StockLeft)
		if okLeft and left == 0 then
			return nil
		end
		return cur
	end
	return nil
end

local function findActiveCaptureEgg(): any
	local function inspectContainer(c)
		if not c then
			return nil
		end
		for _, d in ipairs(c:GetDescendants()) do
			if d:IsA("Model") or d:IsA("BasePart") then
				if d:GetAttribute("CaptureTheEgg") == true or d:GetAttribute("IsCaptureEgg") == true or d.Name:find("CaptureEgg") then
					return d
				end
			end
		end
		return nil
	end
	local ce = Workspace:FindFirstChild("CaptureTheEgg") or Workspace:FindFirstChild("CaptureTheEggEgg")
	if ce then
		return ce
	end
	local best = inspectContainer(Workspace:FindFirstChild("LiveEvents"))
	if best then
		return best
	end
	local eggs = Core.callModule("Egg", "ReadFieldEggs")
	if type(eggs) == "table" then
		for _, rec in pairs(eggs) do
			if type(rec) == "table" and (rec.IsCaptureEgg or rec.CaptureTheEgg or rec.Event == "CaptureTheEgg") then
				return rec
			end
		end
	end
	return nil
end

function Events.init()
	ButterflyFlags = safeRequirePath({ "Shared", "Flags", "ButterflyFlags" })
	ButterflySwarm = safeRequirePath({ "Controllers", "Game", "AdminAbuseClientController", "Events", "ButterflyBloom", "Swarm" })
	BanjoData = safeRequirePath({ "Data", "BanjoCricket" })
	CosmicEclipseMod = safeRequirePath({ "Shared", "Util", "CosmicEclipse" })
	AlienGateMod = safeRequirePath({ "Shared", "Util", "AlienGate" })
	FishCastMod = safeRequirePath({ "Controllers", "Game", "FishingController", "Cast" })

	for _, evName in ipairs({ "Spawned", "Escaped" }) do
		local rem = Core.getRemote("RE/Butterflies/" .. evName)
		if rem and rem:IsA("RemoteEvent") then
			TRex.trackConn(rem.OnClientEvent:Connect(function(a, b)
				local bf = type(a) == "table" and a or (type(b) == "table" and b)
				if bf and bf.Id then
					LiveButterflies[bf.Id] = bf
				end
			end))
		end
	end

	local bfRemoved = Core.getRemote("RE/Butterflies/Removed")
	if bfRemoved and bfRemoved:IsA("RemoteEvent") then
		TRex.trackConn(bfRemoved.OnClientEvent:Connect(function(id)
			LiveButterflies[id] = nil
		end))
	end

	local starFall = Core.getRemote("RE/ShootingStar/Fall")
	if starFall and starFall:IsA("RemoteEvent") then
		TRex.trackConn(starFall.OnClientEvent:Connect(function(pay)
			if type(pay) == "table" and pay.Id then
				StarState.Pay = pay
			end
		end))
	end

	local starWander = Core.getRemote("RE/ShootingStar/Wander")
	if starWander and starWander:IsA("RemoteEvent") then
		TRex.trackConn(starWander.OnClientEvent:Connect(function(id, leg)
			if StarState.Pay and StarState.Pay.Id == id and type(leg) == "table" then
				StarState.Pay.Leg = leg
			end
		end))
	end

	local starSlipped = Core.getRemote("RE/ShootingStar/Slipped")
	if starSlipped and starSlipped:IsA("RemoteEvent") then
		TRex.trackConn(starSlipped.OnClientEvent:Connect(function(id)
			if StarState.Pay and StarState.Pay.Id == id then
				StarState.Slipped += 1
			end
		end))
	end

	local starClaimed = Core.getRemote("RE/ShootingStar/Claimed")
	if starClaimed and starClaimed:IsA("RemoteEvent") then
		TRex.trackConn(starClaimed.OnClientEvent:Connect(function(id)
			if StarState.Pay and StarState.Pay.Id == id then
				StarState.Caught += 1
				StarState.Pay = nil
			end
		end))
	end

	local starExpired = Core.getRemote("RE/ShootingStar/Expired")
	if starExpired and starExpired:IsA("RemoteEvent") then
		TRex.trackConn(starExpired.OnClientEvent:Connect(function(id)
			if StarState.Pay and StarState.Pay.Id == id then
				StarState.Pay = nil
			end
		end))
	end

	local banjoFx = Core.getRemote("RE/BanjoCricket/Effect")
	if banjoFx and banjoFx:IsA("RemoteEvent") then
		TRex.trackConn(banjoFx.OnClientEvent:Connect(function(msg)
			if type(msg) ~= "table" then
				return
			end
			if msg.Kind == "Playback" and type(msg.Notes) == "table" then
				BanjoState.Notes = msg.Notes
				local playSecs = #msg.Notes * 0.65 + 0.5
				if type(BanjoData) == "table" and type(BanjoData.PlaybackSeconds) == "function" then
					local ok, s = pcall(BanjoData.PlaybackSeconds, #msg.Notes)
					if ok and tonumber(s) then
						playSecs = tonumber(s)
					end
				end
				BanjoState.ListenUntil = os.clock() + playSecs
			elseif msg.Kind == "Note" then
				BanjoState.Acks[#BanjoState.Acks + 1] = { msg.Mushroom, os.clock() }
				if #BanjoState.Acks > 40 then
					table.remove(BanjoState.Acks, 1)
				end
			elseif msg.Kind == "Wrong" then
				BanjoState.WrongAt = os.clock()
				BanjoState.Notes = nil
			elseif msg.Kind == "Reset" then
				BanjoState.Notes = nil
			elseif msg.Kind == "Solved" then
				BanjoState.Solved = true
			end
		end))
	end

	local capStandings = Core.getRemote("RE/EggCapture/StandingsRefreshed")
	if capStandings and capStandings:IsA("RemoteEvent") then
		TRex.trackConn(capStandings.OnClientEvent:Connect(function(data)
			local list = type(data) == "table" and (data.Entries or data.Standings or data)
			if type(list) ~= "table" then
				return
			end
			local myId = Players.LocalPlayer and Players.LocalPlayer.UserId
			CaptureState.StandingText = ""
			for idx, entry in ipairs(list) do
				if type(entry) == "table" and tonumber(entry.UserId) == myId then
					CaptureState.StandingText = ("  %.1f วิ  #%d"):format(tonumber(entry.Seconds) or 0, tonumber(entry.Rank) or idx)
					break
				end
			end
		end))
	end

	local lagTravel = Core.getRemote("RE/AlienLagoon/Travel")
	if lagTravel and lagTravel:IsA("RemoteEvent") then
		TRex.trackConn(lagTravel.OnClientEvent:Connect(function(kind, ticket)
			if kind == "Cancel" then
				LagoonState.Trip = nil
				return
			end
			if type(ticket) ~= "number" or not TRex.Config.FastLagoonTrips then
				return
			end
			if not LagoonState.OwnTrip or LagoonState.OwnTrip.Kind ~= kind or os.clock() - LagoonState.OwnTrip.At >= 10 then
				return
			end
			LagoonState.OwnTrip = nil
			if kind == "Exit" then
				task.spawn(function()
					Core.invokeRemote("RF/AlienLagoon/Leave", ticket)
				end)
			elseif kind == "Enter" then
				task.spawn(function()
					for _ = 1, 24 do
						local ok, res = Core.invokeRemote("RF/AlienLagoon/Arrive", ticket)
						if (ok and res == true) or isInAlienLagoon() then
							return
						end
						task.wait(0.25)
					end
				end)
			end
		end))
	end

	local iwState = Core.getRemote("RE/IslandWars/State")
	if iwState and iwState:IsA("RemoteEvent") then
		TRex.trackConn(iwState.OnClientEvent:Connect(function(snap)
			if type(snap) == "table" then
				IslandState.Snap = snap
				IslandState.At = os.clock()
			end
		end))
	end

	local iwMoment = Core.getRemote("RE/IslandWars/Moment")
	if iwMoment and iwMoment:IsA("RemoteEvent") then
		TRex.trackConn(iwMoment.OnClientEvent:Connect(function(info)
			if type(info) == "table" and info.SuddenDeath then
				IslandState.SuddenDeath = true
			end
		end))
	end

	table.insert(TRex.cleanup, function()
		if LagoonState.Deck and LagoonState.Deck.Parent and LagoonState.DeckCanCollide ~= nil then
			pcall(function()
				LagoonState.Deck.CanCollide = LagoonState.DeckCanCollide
			end)
		end
		TRex.State.MinigameEggUid = nil
		leaveTree()
	end)
end

local function registerButterflyTasks()
	Core.registerTask({
		Name = "Bloom",
		Priority = 3,
		Gap = 1,
		NeedsMover = true,
		On = function()
			return TRex.Config.AutoButterfly == true
		end,
		Want = function()
			if not isBloomActive() then
				setRow(ButterflyRow, "ButterflyStatus", "รอกิจกรรมทุ่งผีเสื้อ")
				return nil
			end
			if Core.isNightPhase() then
				setRow(ButterflyRow, "ButterflyStatus", "กลางคืน รอรอบกลางวัน")
				return nil
			end
			if not isTreeUnlocked() then
				setRow(ButterflyRow, "ButterflyStatus", "ต้องปลดล็อกต้นไม้พฤกษา (ทำเควสวิญญาณ)")
				return nil
			end
			if TRex.Config.AutoClaimNet and not getButterfliesSave().NetClaimed then
				return { ClaimOnly = true }
			end
			local root = Core.getRoot()
			local endsAt = tonumber(Workspace:GetAttribute("ButterflyBloomEndsAt"))
			local rem = endsAt and (endsAt - Core.getServerNow()) or math.huge
			if rem <= 25 and root and (root.Position - Vector3.new(6700, 74, -364)).Magnitude >= 300 then
				setRow(ButterflyRow, "ButterflyStatus", ("ใกล้หมดเวลาเหลือ %d วินาที"):format(math.max(0, math.floor(rem))))
				return nil
			end
			return findPath("Areas", "ButterflyBloom", "Bounds") or { Fallback = true }
		end,
		Run = function(bounds, shouldContinue)
			if not Core.needBody() then
				return
			end
			local guard = sameCharacterGuard(shouldContinue)
			if not getButterfliesSave().NetClaimed then
				setRow(ButterflyRow, "ButterflyStatus", "กำลังไปรับสวิงจับผีเสื้อ")
				if not claimButterflyNet(guard) then
					setRow(ButterflyRow, "ButterflyStatus", "รับสวิงจับผีเสื้อไม่สำเร็จ")
					return
				end
			end
			if type(bounds) == "table" and bounds.ClaimOnly then
				return
			end
			local center = getObjPos(bounds) or Vector3.new(6700, 74, -364)
			if not exitSafeZoneIfNeeded(guard) then
				return
			end
			local root = Core.getRoot()
			if root and (root.Position - center).Magnitude > 300 then
				setRow(ButterflyRow, "ButterflyStatus", "กำลังวาร์ปไปทุ่งผีเสื้อ")
				local okRag = false
				for _ = 1, 2 do
					okRag = Core.ragTo(raycastGround(center + Vector3.new(0, 0, 6)), guard)
					if okRag or not guard() then
						break
					end
					waitSafe(0.5, guard)
				end
				if not okRag then
					Core.stepTo(center + Vector3.new(0, 0, 6), guard, 6)
				end
			end
			if not guard() then
				return
			end

			local startAt = os.clock()
			local curId = nil
			local lastSwingAt = 0
			local collideTick = 0
			while guard() and isBloomActive() and not Core.isNightPhase() do
				root = Core.getRoot()
				local hum = Core.getHumanoid()
				if not root or not hum or (root.Position - center).Magnitude > 600 then
					break
				end
				local nets = findOwnedTools(isButterflyNetTool)
				local net = nets[1]
				if net and net.Parent ~= Core.getCharacter() then
					pcall(hum.EquipTool, hum, net)
				end
				local mode = TRex.Config.ButterflyMode or "Stand"
				if mode == "Stand" and os.clock() - collideTick >= 0.5 then
					collideTick = os.clock()
					local lp = Players.LocalPlayer
					for _, pl in ipairs(Players:GetPlayers()) do
						if pl ~= lp and pl.Character then
							for _, part in ipairs(pl.Character:GetChildren()) do
								if part:IsA("BasePart") and part.CanCollide then
									part.CanCollide = false
								end
							end
						end
					end
				end

				local targetBf = pickBestButterfly(root.Position, curId)
				curId = targetBf and targetBf.Id or nil

				if mode == "Chase" or mode == "Stick" then
					hum.PlatformStand = false
					local goalPos = targetBf and targetBf.Pos or raycastGround(center + Vector3.new(0, 0, 6))
					local flatDelta = Vector3.new(goalPos.X - root.Position.X, 0, goalPos.Z - root.Position.Z)
					local speed = math.clamp(tonumber(TRex.Config.ButterflySpeed) or 320, 100, 600)
					if targetBf and flatDelta.Magnitude <= 40 then
						setRow(ButterflyRow, "ButterflyStatus", "กำลังจับผีเสื้อ")
						local dest = Vector3.new(goalPos.X, math.max(raycastGround(goalPos).Y, goalPos.Y), goalPos.Z)
						Core.setRootCFrame(CFrame.lookAt(dest, dest + (flatDelta.Magnitude > 0.5 and flatDelta.Unit or root.CFrame.LookVector)))
						root.AssemblyLinearVelocity = targetBf.Vel
						hum.WalkSpeed = math.max(targetBf.Vel.Magnitude, 16)
						hum:MoveTo(dest + targetBf.Vel)
						if net and os.clock() - lastSwingAt >= 0.15 then
							lastSwingAt = os.clock()
							pcall(net.Activate, net)
							Core.fireRemote("RE/ToolTrigger/Trigger")
						end
					elseif flatDelta.Magnitude > 2 then
						setRow(ButterflyRow, "ButterflyStatus", "กำลังวิ่งไล่ผีเสื้อ")
						local sp = math.clamp(flatDelta.Magnitude * 8, 16, speed)
						hum.WalkSpeed = sp
						hum:MoveTo(root.Position + flatDelta)
						root.AssemblyLinearVelocity = flatDelta.Unit * sp + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
					end
				else
					hum.PlatformStand = true
					local t = os.clock() - startAt
					local speed = math.clamp(tonumber(TRex.Config.ButterflySpeed) or 320, 100, 600)
					local standPos = raycastGround(center + Vector3.new(0, 0, 6))
					if mode == "Patrol" then
						standPos = raycastGround(center + Vector3.new(math.sin(t * speed / 180) * 170, 0, 0))
					elseif mode == "Circle" then
						standPos = raycastGround(center + Vector3.new(math.cos(t * speed / 100) * 25, 0, math.sin(t * speed / 100) * 25))
					end
					local delta = standPos - root.Position
					if delta.Magnitude > 8 then
						root.AssemblyLinearVelocity = delta.Unit * math.min(speed, delta.Magnitude / 0.05)
					else
						Core.setRootCFrame(CFrame.new(standPos))
					end
					setRow(ButterflyRow, "ButterflyStatus", "กำลังรอจับผีเสื้อที่จุด")
					if net and targetBf and (targetBf.Pos - root.Position).Magnitude <= 20 and os.clock() - lastSwingAt >= 0.15 then
						lastSwingAt = os.clock()
						pcall(net.Activate, net)
						Core.fireRemote("RE/ToolTrigger/Trigger")
					end
				end
				RunService.Heartbeat:Wait()
			end
			local hum = Core.getHumanoid()
			if hum then
				hum.PlatformStand = false
				hum:Move(Vector3.zero)
			end
		end,
	})

	Core.registerTask({
		Name = "Machine",
		Priority = 6,
		Gap = 20,
		NeedsMover = true,
		On = function()
			local cfg = TRex.Config
			return cfg.AutoTradeButterfly or cfg.SmartTradeButterfly or cfg.AutoCraftEssence
		end,
		Want = function()
			if isBloomActive() or not isTreeUnlocked() then
				return nil
			end
			local cfg = TRex.Config
			local counts = getButterfliesSave().Counts or {}
			local costs, rec = getButterflyCostAndRecipe()
			if cfg.AutoCraftEssence and canCraftEssence(counts, rec) then
				return { Kind = "Do" }
			end
			if cfg.SmartTradeButterfly then
				local trades = computeSmartTrades(counts, costs, rec)
				if trades and (trades.Green + trades.Blue + trades.Purple) > 0 then
					return { Kind = "Do" }
				end
			end
			if cfg.AutoTradeButterfly then
				for _, tier in ipairs({ "Green", "Blue", "Purple" }) do
					local keep = cfg.AutoCraftEssence and (rec[tier] or 0) or 0
					if (counts[tier] or 0) - keep >= (costs[tier] or 10) then
						return { Kind = "Do" }
					end
				end
			end
			return nil
		end,
		Run = function(_, shouldContinue)
			local guard = sameCharacterGuard(shouldContinue)
			if not enterTree(guard) then
				return
			end
			local cfg = TRex.Config
			local costs, rec = getButterflyCostAndRecipe()
			local counts = getButterfliesSave().Counts or {}

			local machinePos = getButterflyStationPos("ButterflyMachine")
			if machinePos and (cfg.SmartTradeButterfly or cfg.AutoTradeButterfly) then
				Core.stepTo(machinePos + Vector3.new(0, 3, 4), guard, 5)
				if cfg.SmartTradeButterfly then
					local trades = computeSmartTrades(getButterfliesSave().Counts or counts, costs, rec)
					if trades then
						for _, tier in ipairs({ "Green", "Blue", "Purple" }) do
							for _ = 1, (trades[tier] or 0) do
								if not guard() then
									break
								end
								local ok, res = Core.invokeRemote("RF/Butterflies/AskTradeUp", "ButterflyMachine", tier)
								if not ok or res == false then
									break
								end
								waitSafe(0.15, guard)
							end
						end
					end
				elseif cfg.AutoTradeButterfly then
					for _, tier in ipairs({ "Green", "Blue", "Purple" }) do
						while guard() do
							local c = getButterfliesSave().Counts or {}
							local keep = cfg.AutoCraftEssence and (rec[tier] or 0) or 0
							if (c[tier] or 0) - keep < (costs[tier] or 10) then
								break
							end
							local ok, res = Core.invokeRemote("RF/Butterflies/AskTradeUp", "ButterflyMachine", tier)
							if not ok or res == false then
								break
							end
							waitSafe(0.15, guard)
						end
					end
				end
			end

			local shrinePos = getButterflyStationPos("MutationShrine")
			if shrinePos and cfg.AutoCraftEssence then
				Core.stepTo(shrinePos + Vector3.new(0, 3, 4), guard, 5)
				for _ = 1, 50 do
					if not guard() or not canCraftEssence(getButterfliesSave().Counts or {}, rec) then
						break
					end
					local ok, res = Core.invokeRemote("RF/Butterflies/AskCraftEssence", "MutationShrine")
					if not ok or res == false then
						break
					end
					waitSafe(0.3, guard)
				end
			end
			leaveTree()
		end,
	})
end

local function registerBanjoAndWisp()
	Core.registerTask({
		Name = "WispGo",
		Priority = 4,
		Gap = 3,
		NeedsMover = true,
		On = function()
			return TRex.Config.AutoWispQuest == true
		end,
		Want = function()
			local sd = Core.getSaveData()
			local wisp = type(sd) == "table" and type(sd.WispCompanion) == "table" and sd.WispCompanion or nil
			if not wisp then
				setRow(WispRow, "WispStatus", "กำลังอ่านข้อมูลเควสวิญญาณ")
				return nil
			end
			if wisp.Unlocked then
				setRow(WispRow, "WispStatus", "ปลดล็อกต้นไม้พฤกษาแล้ว")
				return nil
			end
			if not wisp.Accepted then
				local p = findPath("EnchantedForestZone", "WispSpawn")
				local pos = getObjPos(p)
				if pos then
					setRow(WispRow, "WispStatus", "กำลังไปรับเควสวิญญาณ")
					return { Pos = pos, Action = "Accept" }
				end
				return nil
			end

			local wispMod = safeRequirePath({ "Data", "Wisp" })
			local list = type(wispMod) == "table" and type(wispMod.List) == "table" and wispMod.List or {}
			local stage = tonumber(wisp.Stage) or 1
			local quest = list[stage]
			if quest then
				local claimed = type(wisp.Claimed) == "table" and wisp.Claimed[quest.Id]
				local prog = type(wisp.Progress) == "table" and tonumber(wisp.Progress[quest.Id]) or 0
				if not claimed and prog >= (tonumber(quest.Target) or 1) then
					Core.invokeRemote("RF/WispCompanion/Request", "Claim", quest.Id)
					setRow(WispRow, "WispStatus", "รับรางวัลขั้นตอน: " .. tostring(quest.Title))
					return nil
				end
				setRow(WispRow, "WispStatus", tostring(quest.Title) .. (" (%d/%d)"):format(prog, tonumber(quest.Target) or 1))
			end

			if stage >= #list and #list > 0 then
				if not wisp.Returning then
					Core.invokeRemote("RF/WispCompanion/Request", "BeginReturn")
				end
				local anchor = findPath("EnchantedForestZone", "Zone13Props", "EnchantedTree", "WispAnchor")
					or findPath("EnchantedForestZone", "WispAnchor")
				local pos = getObjPos(anchor)
				if pos then
					setRow(WispRow, "WispStatus", "กำลังนำวิญญาณกลับต้นไม้")
					return { Pos = pos, Action = "Return" }
				end
			end
			return nil
		end,
		Run = function(job, shouldContinue)
			local guard = sameCharacterGuard(shouldContinue)
			if not exitSafeZoneIfNeeded(guard) then
				return
			end
			if isInAlienLagoon() then
				Events.leaveLagoon(guard)
			end
			local root = Core.getRoot()
			if not root then
				return
			end
			if (root.Position - job.Pos).Magnitude > 1200 and not Core.isNightPhase() then
				Core.ragTo(job.Pos + Vector3.new(0, 3, 3), guard)
			end
			root = Core.getRoot()
			if root and (root.Position - job.Pos).Magnitude > 40 then
				if not Core.stepTo(job.Pos + Vector3.new(0, 0, 3), guard, 6) then
					return
				end
			end
			local hum = Core.getHumanoid()
			local t = 0
			while hum and guard() and t < 3 do
				root = Core.getRoot()
				if not root or (root.Position - job.Pos).Magnitude <= 6 then
					break
				end
				hum:MoveTo(job.Pos)
				t += RunService.Heartbeat:Wait()
			end
			waitSafe(0.5, guard)
			Core.invokeRemote("RF/WispCompanion/Request", job.Action)
		end,
	})

	Core.registerTask({
		Name = "Banjo",
		Priority = 7,
		Gap = 5,
		NeedsMover = true,
		On = function()
			return TRex.Config.AutoBanjoCricket == true and not BanjoState.Done
		end,
		Want = function()
			local sd = Core.getSaveData()
			local bc = type(sd) == "table" and type(sd.BanjoCricket) == "table" and sd.BanjoCricket or {}
			if bc.Claimed == true then
				BanjoState.Done = true
				setRow(WispRow, "WispStatus", "รับแบนโจจิ้งหรีดแล้ว")
				return nil
			end
			return isTreeUnlocked() and { Go = true } or nil
		end,
		Run = function(_, shouldContinue)
			local guard = sameCharacterGuard(shouldContinue)
			local function findMarkerPos(...)
				return getObjPos(findPath("Build", "EnchantedTreeInterior", "Markers", ...))
			end
			local function inSecretRoom()
				local r = Core.getRoot()
				local sp = findMarkerPos("Passages", "SecretRoomSpawn") or findMarkerPos("SecretRoomSpawn") or BANJO_ROOM_REF
				return r ~= nil and (r.Position - sp).Magnitude < 120
			end
			local function getMushroomPos(idx)
				for _, m in ipairs(CollectionService:GetTagged("BanjoCricketMushroom")) do
					if m:GetAttribute("MushroomIndex") == idx then
						local hb = m:FindFirstChild("Hitbox") or m:FindFirstChild("Hitbox Part")
						local p = getObjPos(hb) or getObjPos(m)
						if p then
							return p
						end
					end
				end
				return BANJO_FALLBACK_POS[idx]
			end

			if not enterTree(guard) then
				return
			end
			if not inSecretRoom() then
				setRow(WispRow, "WispStatus", "แบนโจ: กำลังกระโดดเข้าห้องลับ")
				local hint = findPath("Build", "EnchantedTreeInterior", "SecretLeapHint", "Streaks")
				local leapPos = getObjPos(hint) or BANJO_LEAP_REF
				local root = Core.getRoot()
				if root then
					Core.stepTo(Vector3.new(root.Position.X, leapPos.Y + 18, root.Position.Z), guard, 6)
					Core.stepTo(leapPos + Vector3.new(0, 18, 0), guard, 6)
				end
				local w = os.clock() + 8
				while os.clock() < w and guard() and not inSecretRoom() do
					task.wait(0.1)
				end
			end
			if not inSecretRoom() then
				leaveTree()
				return
			end

			local bat = TRex.Combat and type(TRex.Combat.findBatTool) == "function" and TRex.Combat.findBatTool()
			if not bat then
				setRow(WispRow, "WispStatus", "แบนโจ: ต้องใช้ไม้เบสบอลตีเห็ด")
				leaveTree()
				return
			end

			local dead = os.clock() + 240
			BanjoState.Notes = nil
			local lastWake = 0
			local attempts = 0
			while guard() and os.clock() < dead and inSecretRoom() do
				local sd = Core.getSaveData()
				local bc = type(sd) == "table" and type(sd.BanjoCricket) == "table" and sd.BanjoCricket or {}
				if BanjoState.Solved or bc.Solved == true then
					break
				end
				local notes = BanjoState.Notes
				if notes then
					if os.clock() < BanjoState.ListenUntil then
						task.wait(0.05)
					else
						BanjoState.Notes = nil
						attempts = 0
						setRow(WispRow, "WispStatus", ("แบนโจ: กำลังตีตาม %d โน้ต"):format(#notes))
						for _, noteIdx in ipairs(notes) do
							local mPos = getMushroomPos(noteIdx)
							if mPos then
								local d = Vector3.new(mPos.X - BANJO_REF_CENTER.X, 0, mPos.Z - BANJO_REF_CENTER.Z)
								local unit = d.Magnitude > 0.1 and d.Unit or Vector3.new(0, 0, 1)
								Core.stepTo(raycastGround(mPos + unit * 6.5), guard, 4)
								local r = Core.getRoot()
								if r then
									Core.setRootCFrame(CFrame.lookAt(r.Position, Vector3.new(mPos.X, r.Position.Y, mPos.Z)))
								end
								local hum = Core.getHumanoid()
								if hum and bat.Parent ~= Core.getCharacter() then
									pcall(hum.EquipTool, hum, bat)
									task.wait(0.2)
								end
								local tSent = os.clock()
								Core.fireRemote("RE/BanjoCricket/Aim", noteIdx)
								pcall(bat.Activate, bat)
								local ackDead = os.clock() + 1.6
								local noteOk = false
								while os.clock() < ackDead and guard() do
									if BanjoState.WrongAt > tSent then
										break
									end
									for _, ack in ipairs(BanjoState.Acks) do
										if ack[1] == noteIdx and ack[2] > tSent then
											noteOk = true
											break
										end
									end
									if noteOk then
										break
									end
									task.wait(0.05)
								end
								if not noteOk then
									break
								end
							end
						end
						lastWake = os.clock()
					end
				elseif os.clock() - lastWake > 4 then
					attempts += 1
					if attempts > 12 then
						break
					end
					setRow(WispRow, "WispStatus", "แบนโจ: ปลุกเห็ดฟังโน้ต")
					local rPos = getMushroomPos(3) or BANJO_FALLBACK_POS[3]
					Core.stepTo(raycastGround(rPos), guard, 5)
					local hum = Core.getHumanoid()
					if hum and bat.Parent ~= Core.getCharacter() then
						pcall(hum.EquipTool, hum, bat)
						task.wait(0.2)
					end
					Core.fireRemote("RE/BanjoCricket/Aim", 3)
					pcall(bat.Activate, bat)
					lastWake = os.clock()
				end
				task.wait(0.1)
			end

			local sdAfter = Core.getSaveData()
			local bcAfter = type(sdAfter) == "table" and type(sdAfter.BanjoCricket) == "table" and sdAfter.BanjoCricket or {}
			if BanjoState.Solved or bcAfter.Solved then
				local npc = CollectionService:GetTagged("BanjoCricketNpc")[1]
				local npcPos = getObjPos(npc) or BANJO_NPC_FALLBACK
				for _, wp in ipairs({ BANJO_W1_FALLBACK, BANJO_W2_FALLBACK, npcPos }) do
					Core.stepTo(raycastGround(wp), guard, 6)
				end
				local ok, res = Core.invokeRemote("RF/BanjoCricket/AskClaim")
				local sdClaim = Core.getSaveData()
				local claimedSave = type(sdClaim) == "table" and type(sdClaim.BanjoCricket) == "table" and sdClaim.BanjoCricket.Claimed == true
				if (ok and res == true) or claimedSave then
					BanjoState.Done = true
					setRow(WispRow, "WispStatus", "รับแบนโจสำเร็จ!")
				end
			end

			local exitPos = findMarkerPos("Passages", "SecretRoomExit") or BANJO_OUT_LEAP_FALLBACK
			Core.stepTo(exitPos, function() return true end, 6)
			leaveTree()
		end,
	})
end

local function registerStarAndStage()
	Core.registerTask({
		Name = "Star",
		Priority = 1,
		Gap = 0.5,
		NeedsMover = true,
		On = function()
			return TRex.Config.AutoShootingStar == true
		end,
		Want = function()
			local ok, st = Core.invokeRemote("RF/ShootingStar/AskState")
			if ok and type(st) == "table" and st.Id then
				StarState.Pay = st
			end
			if StarState.Pay and StarState.Pay.Id then
				setRow(StarRow, "StarStatus", "พบดาวตกกำลังตก! กำลังไปคว้า")
				return StarState.Pay
			end
			setRow(StarRow, "StarStatus", "รอดาวตกรอบถัดไป")
			return nil
		end,
		Run = function(pay, shouldContinue)
			local guard = sameCharacterGuard(shouldContinue)
			local function starPos()
				local ok, st = Core.invokeRemote("RF/ShootingStar/AskState")
				if ok and type(st) == "table" and st.Id == pay.Id then
					pay = st
					StarState.Pay = st
				end
				if type(pay.Leg) == "table" and typeof(pay.Leg.End) == "Vector3" then
					return pay.Leg.End
				end
				return typeof(pay.Position) == "Vector3" and pay.Position or nil
			end

			if not exitSafeZoneIfNeeded(guard) then
				return
			end
			local p0 = starPos()
			if not p0 then
				return
			end
			local root = Core.getRoot()
			if root and (root.Position - p0).Magnitude > 40 and not StarState.Jumped[pay.Id] then
				StarState.Jumped[pay.Id] = true
				Core.ragTo(starPos, guard)
			end
			local pNow = starPos()
			root = Core.getRoot()
			if root and pNow and (root.Position - pNow).Magnitude > 40 then
				Core.stepTo(pNow + Vector3.new(0, 3, 0), guard, 12)
			end

			local holdDur = (tonumber(pay.HoldSeconds) or 1.6) + 0.3
			local syncWait = 0.5 + Core.getPing() * 2
			local settleAt = os.clock()
			local settled = false
			local catchAt = nil
			local tries = 0
			while guard() and StarState.Pay and StarState.Pay.Id == pay.Id do
				local targetPos = starPos()
				root = Core.getRoot()
				local hum = Core.getHumanoid()
				if not targetPos or not root or not hum then
					break
				end
				local delta = (targetPos + Vector3.new(0, 3, 3)) - root.Position
				if delta.Magnitude > 60 then
					break
				end
				hum.PlatformStand = true
				local v = delta * 10
				if v.Magnitude > 200 then
					v = v.Unit * 200
				end
				root.AssemblyLinearVelocity = v
				root.AssemblyAngularVelocity = Vector3.zero

				if not settled then
					if delta.Magnitude > 8 then
						settleAt = os.clock()
					elseif os.clock() - settleAt >= syncWait then
						settled = true
					end
				elseif not StarState.HoldAt then
					StarState.HoldAt = os.clock()
					catchAt = nil
					Core.fireRemote("RE/ShootingStar/Hold", pay.Id, true)
					setRow(StarRow, "StarStatus", "กำลังจับดาวตกค้างไว้...")
				elseif os.clock() - StarState.HoldAt >= holdDur then
					if not catchAt or os.clock() - catchAt >= 2 then
						tries += 1
						catchAt = os.clock()
						Core.fireRemote("RE/ShootingStar/Catch", pay.Id)
						setRow(StarRow, "StarStatus", ("กำลังคว้าดาวตก (ครั้งที่ %d)"):format(tries))
					end
				end
				RunService.Heartbeat:Wait()
			end
			if StarState.Pay and StarState.Pay.Id == pay.Id then
				Core.fireRemote("RE/ShootingStar/Hold", pay.Id, false)
			end
			StarState.HoldAt = nil
			local hum = Core.getHumanoid()
			if hum then
				hum.PlatformStand = false
			end
		end,
	})

	Core.registerTask({
		Name = "Stage",
		Priority = 15,
		Gap = 2,
		NeedsMover = true,
		On = function()
			return TRex.Config.AutoStagePosition == true
		end,
		Want = function()
			if not Core.isNightPhase() or isInAlienLagoon() or Core.inEnchantedTree() or Core.inBossArena() then
				return nil
			end
			local root = Core.getRoot()
			if not root then
				return nil
			end
			local sep = Core.getSeparationLinePos()
			local stage = Vector3.new(sep.X - 6, root.Position.Y, math.clamp(root.Position.Z, -415, -305))
			if (root.Position - stage).Magnitude > 14 then
				return stage
			end
			return nil
		end,
		Run = function(stagePos, shouldContinue)
			Core.walkTo(stagePos, shouldContinue, 1.0)
		end,
	})
end

local function registerAlienTasks()
	Core.registerTask({
		Name = "Relic",
		Priority = 5,
		Gap = 4,
		NeedsMover = true,
		On = function()
			return TRex.Config.AutoSocketRelics == true and isAlienBiomeOpen() and type(AlienGateMod) == "table"
		end,
		Want = function()
			if os.clock() <= LagoonState.RelicCooldownAt or Core.isNightPhase() then
				return nil
			end
			local door = type(AlienGateMod.Gate) == "function" and AlienGateMod.Gate()
			local anchor = door and door:FindFirstChild("DoorAnchor")
			if not anchor or not anchor:IsA("BasePart") then
				return nil
			end
			local sd = Core.getSaveData()
			local socketed = {}
			if type(AlienGateMod.SocketedOf) == "function" then
				local ok, tbl = pcall(AlienGateMod.SocketedOf, sd)
				if ok and type(tbl) == "table" then
					for k, v in pairs(tbl) do
						socketed[type(k) == "number" and v or k] = true
					end
				end
			end
			local relics = findOwnedTools(function(t)
				return AlienGateMod.ItemType and t:GetAttribute("ItemType") == AlienGateMod.ItemType
					and not socketed[t:GetAttribute(AlienGateMod.Attributes.Relic)]
			end)
			if #relics > 0 then
				return { Pos = anchor.Position, Relics = relics }
			end
			return nil
		end,
		Run = function(job, shouldContinue)
			local guard = sameCharacterGuard(shouldContinue)
			if not moveToBiomePoint(job.Pos, guard, 6) then
				return
			end
			local placedAny = false
			for _, tool in ipairs(job.Relics) do
				if not guard() then
					return
				end
				local hum = Core.getHumanoid()
				if hum then
					pcall(hum.EquipTool, hum, tool)
				end
				if not waitSafe(0.3, guard) then
					return
				end
				local ok, res = Core.invokeRemote("RF/AlienGate/Socket")
				if ok and res == true then
					placedAny = true
					setRow(AlienRow, "AlienStatus", "เสียบชิ้นส่วนประตูเอเลี่ยนสำเร็จ")
				end
				waitSafe(1.8, guard)
			end
			if not placedAny then
				LagoonState.RelicCooldownAt = os.clock() + 120
			end
		end,
	})

	Core.registerTask({
		Name = "Fish",
		Priority = 10,
		Gap = 1,
		NeedsMover = true,
		On = function()
			return (TRex.Config.AutoFishing == true or TRex.Config.AutoGetAlienRod == true) and isAlienBiomeOpen()
		end,
		Want = function()
			if os.clock() <= LagoonState.RetryAt then
				return nil
			end
			if TRex.Config.RotateFishingAndTreadmill and TRex.State.RotationTurn == "tread" and not isCosmicEclipseActive() then
				setRow(AlienRow, "AlienStatus", "สลับงาน: กำลังวิ่งสายพาน")
				return nil
			end
			if TRex.Config.AutoGetAlienRod and not getBestRodTool() then
				local ferry = findPath("Build", "AlienBiomeZone", "Ferryman") or Workspace:FindFirstChild("AlienLagoonGuide")
				if ferry then
					return { Mode = "Rod", Ferry = ferry }
				end
			end
			if TRex.Config.AutoFishing and getBestRodTool() then
				if (TRex.Config.FishingSpot == "Alien Lagoon" or isCosmicEclipseActive() ~= nil) and not isInAlienLagoon() then
					return { Mode = "EnterLagoon" }
				end
				return { Mode = "Fish" }
			end
			return nil
		end,
		Run = function(job, shouldContinue)
			local guard = sameCharacterGuard(shouldContinue)
			if job.Mode == "Rod" then
				local p = getObjPos(job.Ferry)
				if p and moveToBiomePoint(p, guard, 8) and waitSafe(0.6, guard) then
					Core.fireRemote("RE/AlienLagoon/MetFerryman")
					waitSafe(2, guard)
				end
				return
			end

			if job.Mode == "EnterLagoon" then
				if isInAlienLagoon() then
					return
				end
				local zone = findPath("Build", "AlienBiomeZone")
				local landing = zone and zone:FindFirstChild("LagoonFerry") and zone.LagoonFerry:FindFirstChild("Landing")
				local landPos = getObjPos(landing)
				if not landPos then
					return
				end
				setRow(AlienRow, "AlienStatus", "กำลังขึ้นเรือข้ามไปทะเลสาบเอเลี่ยน")
				if not moveToBiomePoint(landPos + Vector3.new(0, 3, 0), guard, 4) then
					return
				end
				local ok, ans = Core.invokeRemote("RF/AlienLagoon/Request")
				if ok and ans == "Enter" then
					LagoonState.OwnTrip = { Kind = "Enter", At = os.clock() }
					LagoonState.Trip = { Kind = "Enter", At = os.clock() }
					local w = os.clock() + 12
					while os.clock() < w and not isInAlienLagoon() and guard() do
						RunService.Heartbeat:Wait()
					end
				end
				return
			end

			local spot = findFishingSpot()
			local rod = getBestRodTool()
			if not spot or not rod then
				setRow(AlienRow, "AlienStatus", "ไม่พบจุดตกปลาหรือคันเบ็ด")
				return
			end
			if not moveToBiomePoint(spot.At, guard, 5) then
				return
			end
			local hum = Core.getHumanoid()
			if hum and rod.Parent ~= Core.getCharacter() then
				pcall(hum.EquipTool, hum, rod)
				waitSafe(0.3, guard)
			end
			if spot.Pad and LagoonState.Deck then
				LagoonState.Deck.CanCollide = true
			end
			Core.setRootCFrame(CFrame.lookAt(spot.At, Vector3.new(spot.Aim.X, spot.At.Y, spot.Aim.Z)))

			local castSecs = getCastSeconds()
			Core.fireRemote("RE/Fishing/Hold")
			local h0 = os.clock()
			while os.clock() - h0 < castSecs do
				if not guard() then
					Core.fireRemote("RE/Fishing/Cancel")
					return
				end
				RunService.Heartbeat:Wait()
			end

			local okCast, castData, castErr = Core.invokeRemote("RF/Fishing/Cast", castSecs, spot.Aim)
			if not okCast or type(castData) ~= "table" then
				LagoonState.FailCount += 1
				LagoonState.SpotCache = nil
				setRow(AlienRow, "AlienStatus", "เหวี่ยงเบ็ดไม่สำเร็จ: " .. tostring(castErr))
				if LagoonState.FailCount >= 3 then
					LagoonState.RetryAt = os.clock() + 60
					LagoonState.FailCount = 0
				end
				return
			end
			LagoonState.FailCount = 0
			setRow(AlienRow, "AlienStatus", "รอปลากินเหยื่อ...")
			if not waitSafe(tonumber(castData.Wait) or 4, guard) then
				Core.fireRemote("RE/Fishing/Cancel", castData.Id)
				return
			end
			if castData.Mode == "Nothing" or castData.Mode == "Hint" or castData.Mode == "Quest" or castData.Mode == "GhostFish" then
				Core.fireRemote("RE/Fishing/Cancel", castData.Id)
				setRow(AlienRow, "AlienStatus", "รอบนี้ไม่มีอะไรติดเบ็ด")
				waitSafe(1.05, guard)
				return
			end

			local reelSecs = 0.9 + math.random() * 0.4
			if not waitSafe(reelSecs, guard) then
				Core.fireRemote("RE/Fishing/Cancel", castData.Id)
				return
			end
			local clicks = math.ceil((0.7 + 0.3 * reelSecs) / 0.075) + 2
			local okReel, reward = Core.invokeRemote("RF/Fishing/Reel", castData.Id, "Caught", clicks)
			if okReel and type(reward) == "table" then
				setRow(AlienRow, "AlienStatus", ("ตกได้ %s x%s"):format(tostring(reward.DisplayName or "Reward"), tostring(reward.Amount or 1)))
				local srv = TRex.Server
				if srv and type(srv.notifyWebhook) == "function" then
					pcall(srv.notifyWebhook, "egg_fished", {
						Name = reward.DisplayName or "Fished Egg",
						Value = tonumber(reward.Value) or 0,
						Rarity = reward.Rarity,
					})
				end
			else
				setRow(AlienRow, "AlienStatus", "หลุดไปเสียก่อน")
			end
			waitSafe(1.05, guard)
		end,
	})
end

local function registerAdminAbuseTasks()
	Core.registerTask({
		Name = "Capture",
		Priority = -2,
		Gap = 0.3,
		NeedsMover = true,
		Urgent = true,
		On = function()
			return TRex.Config.AutoCaptureEgg == true and findActiveCaptureEgg() ~= nil
		end,
		Want = function()
			return findActiveCaptureEgg()
		end,
		Run = function(_, shouldContinue)
			local lp = Players.LocalPlayer
			local myId = lp and lp.UserId
			local dt = 1 / 60
			while shouldContinue() and findActiveCaptureEgg() do
				local cur = findActiveCaptureEgg()
				local root = Core.getRoot()
				local hum = Core.getHumanoid()
				if not cur or not root or not hum then
					break
				end

				local holderId = nil
				local eggPos = nil
				if typeof(cur) == "Instance" then
					holderId = tonumber(cur:GetAttribute("HolderUserId") or cur:GetAttribute("CarrierUserId"))
					eggPos = getObjPos(cur)
				elseif type(cur) == "table" then
					holderId = tonumber(cur.CarrierUserId)
					eggPos = typeof(cur.BottomCFrame) == "CFrame" and cur.BottomCFrame.Position or nil
				end

				if holderId == myId or Core.isCarryingEgg() then
					local holdH = tonumber(TRex.Config.CaptureHoldHeight) or 45
					local awayDist = tonumber(TRex.Config.CaptureKeepAwayDist) or 45
					if not CaptureState.HoverTarget or os.clock() >= CaptureState.RetargetAt then
						CaptureState.RetargetAt = os.clock() + 0.25
						local sep = Core.getSeparationLinePos()
						local x = math.max(sep.X + 40, root.Position.X)
						local bestP = Vector3.new(x, root.Position.Y, math.clamp(root.Position.Z, -410, -310))
						for _, pl in ipairs(Players:GetPlayers()) do
							if pl ~= lp and pl.Character then
								local pRoot = pl.Character:FindFirstChild("HumanoidRootPart")
								if pRoot and pRoot:IsA("BasePart") and (pRoot.Position - root.Position).Magnitude < awayDist then
									local push = Vector3.new(root.Position.X - pRoot.Position.X, 0, root.Position.Z - pRoot.Position.Z)
									if push.Magnitude > 0.1 then
										bestP += push.Unit * awayDist
									end
								end
							end
						end
						local g = raycastGround(bestP)
						CaptureState.HoverTarget = Vector3.new(bestP.X, g.Y + holdH, bestP.Z)
					end
					hum.PlatformStand = true
					local d = CaptureState.HoverTarget - root.Position
					local vel = d / math.max(dt, 0.04)
					if vel.Magnitude > 220 then
						vel = vel.Unit * 220
					end
					root.AssemblyLinearVelocity = vel
					setRow(CaptureRow, "CaptureStatus", "กำลังถือไข่กิจกรรม" .. CaptureState.StandingText)
				elseif holderId and holderId > 0 then
					CaptureState.HoverTarget = nil
					local targetPlr = Players:GetPlayerByUserId(holderId)
					local combat = TRex.Combat
					local bat = combat and type(combat.findBatTool) == "function" and combat.findBatTool()
					if targetPlr and TRex.Config.CaptureTakeFromHolder and bat and type(combat.chaseStep) == "function" then
						local tRoot = targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart")
						if tRoot and tRoot:IsA("BasePart") then
							combat.chaseStep(targetPlr, tRoot, bat)
							setRow(CaptureRow, "CaptureStatus", "กำลังไล่แย่งจาก " .. tostring(targetPlr.DisplayName))
						end
					else
						setRow(CaptureRow, "CaptureStatus", "ผู้เล่นอื่นถือไข่กิจกรรมอยู่")
					end
				elseif eggPos then
					CaptureState.HoverTarget = nil
					local dist = Vector3.new(eggPos.X - root.Position.X, 0, eggPos.Z - root.Position.Z).Magnitude
					if Core.isWallSealed() or Core.isNightPhase() then
						setRow(CaptureRow, "CaptureStatus", "กำแพงสนามปิดอยู่ รอเปิด...")
					elseif dist > 220 then
						Core.ragTo(eggPos + Vector3.new(0, 3, 0), shouldContinue)
					else
						hum.PlatformStand = false
						Core.walkTo(eggPos, shouldContinue, 1.0)
						local p = Core.getPromptNear(eggPos, 16)
						local fpp = TRex.resolveGlobalFunc("fireproximityprompt")
						if p and fpp then
							pcall(fpp, p)
						end
						setRow(CaptureRow, "CaptureStatus", "กำลังเข้าเก็บไข่กิจกรรม")
					end
				end
				dt = math.clamp(RunService.Heartbeat:Wait(), 0.004, 0.05)
			end
			local hum = Core.getHumanoid()
			if hum then
				hum.PlatformStand = false
			end
		end,
	})

	Core.registerTask({
		Name = "IslandWars",
		Priority = -1,
		Gap = 0.3,
		NeedsMover = true,
		Urgent = true,
		On = function()
			local s = IslandState.Snap
			if not TRex.Config.AutoCursedIslandWars or type(s) ~= "table" then
				return false
			end
			local phases = { Active = true, Prep = true, SuddenDeath = true }
			return phases[s.Phase] == true and os.clock() - IslandState.At < 30
		end,
		Want = function()
			local s = IslandState.Snap
			local myId = Players.LocalPlayer and Players.LocalPlayer.UserId
			if type(s) ~= "table" or type(s.Entries) ~= "table" then
				return nil
			end
			for _, e in ipairs(s.Entries) do
				if type(e) == "table" and tonumber(e.UserId) == myId and e.State == "Alive" then
					return { Snap = s, Me = e }
				end
			end
			return nil
		end,
		Run = function(_, shouldContinue)
			local lp = Players.LocalPlayer
			local myId = lp and lp.UserId
			while shouldContinue() do
				local s = IslandState.Snap
				local root = Core.getRoot()
				if type(s) ~= "table" or not root then
					break
				end
				local me = nil
				for _, e in ipairs(s.Entries or {}) do
					if type(e) == "table" and tonumber(e.UserId) == myId then
						me = e
						break
					end
				end
				if not me or me.State ~= "Alive" then
					break
				end
				local enemyTeam = me.Team == "Red" and "Blue" or "Red"
				local centre = s.Island and s.Island:FindFirstChild("Centre")
				local top = centre and centre:FindFirstChild("Top")
				if top and top:IsA("BasePart") and (IslandState.SuddenDeath or s.Phase == "SuddenDeath") then
					if (root.Position - top.Position).Magnitude > 18 then
						root.AssemblyLinearVelocity = (top.Position - root.Position).Unit * 40 + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
					end
				end

				local nearEnemy, nearDist = nil, 25
				if TRex.Config.IslandWarsMode ~= "Walls and crystal" then
					for _, e in ipairs(s.Entries or {}) do
						if type(e) == "table" and e.Team == enemyTeam and e.State == "Alive" and typeof(e.Model) == "Instance" then
							local hrp = e.Model:FindFirstChild("HumanoidRootPart")
							if hrp and hrp:IsA("BasePart") then
								local d = (hrp.Position - root.Position).Magnitude
								if d < nearDist then
									nearDist = d
									nearEnemy = hrp
								end
							end
						end
					end
				end

				if s.Phase ~= "Prep" then
					local bat = findOwnedTools(function(t) return t.Name == "Bat" end)[1]
					local launcher = findOwnedTools(function(t) return t.Name == "PumpkinLauncher" end)[1]
					local now = Core.getServerNow()
					local hum = Core.getHumanoid()
					if nearEnemy and nearDist <= 10 and bat and now >= (IslandState.Cooldowns["Bat"] or 0) then
						if hum and bat.Parent ~= Core.getCharacter() then
							pcall(hum.EquipTool, hum, bat)
						end
						Core.setRootCFrame(CFrame.lookAt(root.Position, Vector3.new(nearEnemy.Position.X, root.Position.Y, nearEnemy.Position.Z)))
						Core.fireRemote("RE/IslandWars/Use", "Swing", nearEnemy)
						IslandState.Cooldowns["Bat"] = now + 0.75
						setRow(IslandWarsRow, "IslandWarsStatus", "กำลังตีศัตรูในสงครามเกาะ")
					elseif launcher and now >= (IslandState.Cooldowns["Launcher"] or 0) then
						local barrier = type(s.Barriers) == "table" and s.Barriers[enemyTeam]
						local crystal = type(s.Crystals) == "table" and s.Crystals[enemyTeam]
						local aimPos = nil
						if nearEnemy then
							aimPos = nearEnemy.Position + nearEnemy.AssemblyLinearVelocity * (nearDist / 110)
						elseif barrier and (tonumber(barrier.Health) or 0) > 0 and typeof(barrier.Model) == "Instance" then
							aimPos = getObjPos(barrier.Model:FindFirstChild("Hitbox") or barrier.Model)
						elseif crystal and (tonumber(crystal.Health) or 0) > 0 and typeof(crystal.Model) == "Instance" then
							aimPos = getObjPos(crystal.Model:FindFirstChild("Pivot", true) or crystal.Model)
						end
						if aimPos then
							if hum and launcher.Parent ~= Core.getCharacter() then
								pcall(hum.EquipTool, hum, launcher)
							end
							Core.setRootCFrame(CFrame.lookAt(root.Position, Vector3.new(aimPos.X, root.Position.Y, aimPos.Z)))
							local muz = launcher:FindFirstChild("Handle") and launcher.Handle:FindFirstChild("Muzzle")
							local orig = (muz and muz:IsA("Attachment") and muz.WorldPosition) or (root.Position + Vector3.new(0, 1.5, 0))
							if (aimPos - orig).Magnitude > 1 then
								IslandState.ShotId += 1
								Core.fireRemote("RE/IslandWars/Use", "Launch", IslandState.ShotId, orig, (aimPos - orig).Unit)
								IslandState.Cooldowns["Launcher"] = now + 1.25
								setRow(IslandWarsRow, "IslandWarsStatus", nearEnemy and "ยิงฟักทองใส่ศัตรู" or "ยิงทำลายฐานศัตรู")
							end
						end
					end
				end
				RunService.Heartbeat:Wait()
			end
		end,
	})
end

function Events.buildUI(ui)
	local tab = ui.addTab("events", "tab.events", 2)

	local secBf = tab:addSection("sec.butterfly")
	ButterflyRow = secBf:addText({ key = "ButterflyStatus", label = "สถานะทุ่งผีเสื้อ", text = "รอ / พัก" })
	local tgBf = secBf:addToggle({ key = "AutoButterfly", label = "opt.auto_butterfly" })
	secBf:addDropdown({ key = "ButterflyMode", label = "opt.butterfly_mode", items = { "Stand", "Chase", "Stick", "Circle", "Patrol" } }):When(tgBf, true)
	secBf:addDropdown({ key = "ButterflyPriority", label = "opt.butterfly_priority", items = { "Rarest", "Nearest" } }):When(tgBf, true)
	secBf:addSlider({ key = "ButterflySpeed", label = "opt.butterfly_speed", min = 100, max = 600, step = 10, suffix = " studs/s" }):When(tgBf, true)
	secBf:addDropdown({
		key = "CatchButterflies",
		label = "opt.catch_butterflies",
		items = { "Emerald Butterfly", "Sapphire Butterfly", "Amethyst Butterfly", "Radiant Butterfly" },
		multi = true,
	}):When(tgBf, true)
	secBf:addToggle({ key = "AutoClaimNet", label = "opt.auto_claim_net" })
	secBf:addToggle({ key = "AutoTradeButterfly", label = "opt.auto_trade_butterfly" })
	secBf:addToggle({ key = "SmartTradeButterfly", label = "opt.smart_trade_butterfly" })
	secBf:addToggle({ key = "AutoCraftEssence", label = "opt.auto_craft_essence" })

	local secWisp = tab:addSection("sec.banjo_wisp")
	WispRow = secWisp:addText({ key = "WispStatus", label = "สถานะเควสวิญญาณและแบนโจ", text = "ปิด" })
	secWisp:addToggle({ key = "AutoWispQuest", label = "opt.auto_wisp" })
	secWisp:addToggle({ key = "AutoBanjoCricket", label = "opt.auto_banjo" })

	local secStar = tab:addSection("sec.star_stage")
	StarRow = secStar:addText({ key = "StarStatus", label = "สถานะดาวตกและเวที", text = "รอดาวตก" })
	secStar:addToggle({ key = "AutoShootingStar", label = "opt.auto_star" })
	secStar:addToggle({ key = "AutoStagePosition", label = "opt.auto_stage" })

	local secAlien = tab:addSection("sec.alien_biome")
	AlienRow = secAlien:addText({ key = "AlienStatus", label = "สถานะทะเลสาบเอเลี่ยน", text = "ปิด" })
	local tgFish = secAlien:addToggle({ key = "AutoFishing", label = "opt.auto_fishing" })
	secAlien:addDropdown({ key = "CastLuckBoost", label = "opt.cast_luck", items = { "x1.5 Perfect", "x1.2", "x1.1", "x1.0 Fastest" } }):When(tgFish, true)
	secAlien:addDropdown({ key = "FishingSpot", label = "opt.fishing_spot", items = { "Auto", "Lagoon Dock", "Alien Lagoon", "Spot 1", "Spot 2", "Spot 3" } }):When(tgFish, true)
	secAlien:addToggle({ key = "FastLagoonTrips", label = "opt.fast_lagoon" })
	secAlien:addToggle({ key = "AutoGetAlienRod", label = "opt.auto_alien_rod" })
	secAlien:addToggle({ key = "AutoCosmicEclipse", label = "opt.auto_eclipse" })
	secAlien:addToggle({ key = "AutoSocketRelics", label = "opt.auto_relics" })
	secAlien:addToggle({ key = "AutoClaimMastery", label = "opt.auto_mastery" })
	secAlien:addToggle({ key = "AutoTradePearls", label = "opt.auto_pearls" })

	local secAdmin = tab:addSection("sec.admin_abuse")
	secAdmin:addToggle({ key = "InstantStealV3", label = "opt.instant_steal_v3" })
	secAdmin:addToggle({ key = "AutoMinigameEggs", label = "opt.minigame_eggs" })
	CaptureRow = secAdmin:addText({ key = "CaptureStatus", label = "สถานะไข่ชิงธงกิจกรรม", text = "ปิด" })
	local tgCap = secAdmin:addToggle({ key = "AutoCaptureEgg", label = "opt.capture_egg" })
	secAdmin:addSlider({ key = "CaptureHoldHeight", label = "opt.capture_height", min = 10, max = 120, step = 1, suffix = " studs" }):When(tgCap, true)
	secAdmin:addSlider({ key = "CaptureKeepAwayDist", label = "opt.capture_keep_dist", min = 10, max = 120, step = 1, suffix = " studs" }):When(tgCap, true)
	secAdmin:addToggle({ key = "CaptureTakeFromHolder", label = "opt.capture_take_holder" }):When(tgCap, true)
	IslandWarsRow = secAdmin:addText({ key = "IslandWarsStatus", label = "สถานะสงครามเกาะต้องคำสาป", text = "ปิด" })
	local tgIW = secAdmin:addToggle({ key = "AutoCursedIslandWars", label = "opt.island_wars" })
	secAdmin:addDropdown({ key = "IslandWarsMode", label = "opt.island_wars_mode", items = { "Enemies And Base", "Walls and crystal" } }):When(tgIW, true)
end

function Events.startLoop()
	registerButterflyTasks()
	registerBanjoAndWisp()
	registerStarAndStage()
	registerAlienTasks()
	registerAdminAbuseTasks()

	task.spawn(function()
		local mgEvents = {
			{ Attr = "Event_RedLightGreenLight", Key = "RLGL" },
			{ Attr = "Event_TRexRun", Key = "TRexRun" },
		}
		while TRex.IsRunning do
			local cfg = TRex.Config
			if cfg.AutoMinigameEggs then
				local activeKey = nil
				for _, ev in ipairs(mgEvents) do
					if Workspace:GetAttribute(ev.Attr) == true or typeof(Workspace:GetAttribute(ev.Key .. "_EggPosition")) == "Vector3" then
						activeKey = ev.Key
						break
					end
				end
				if activeKey then
					local eggPos = Workspace:GetAttribute(activeKey .. "_EggPosition")
					local carrierId = Workspace:GetAttribute(activeKey .. "_CarrierUserId")
					local myId = Players.LocalPlayer and Players.LocalPlayer.UserId
					if typeof(eggPos) == "Vector3" and (not carrierId or carrierId == 0 or carrierId == myId) then
						local eggs = Core.callModule("Egg", "ReadFieldEggs")
						local bestUid, bestDist = nil, 40
						for uid, rec in pairs(type(eggs) == "table" and eggs or {}) do
							if type(rec) == "table" and rec.State ~= "Carried" and rec.State ~= "Claimed" then
								local cf = rec.BottomCFrame or rec.BoundsCFrame
								if typeof(cf) == "CFrame" then
									local d = Vector3.new(cf.Position.X - eggPos.X, 0, cf.Position.Z - eggPos.Z).Magnitude
									if d < bestDist then
										bestDist = d
										bestUid = rec.Uid or uid
									end
								end
							end
						end
						if bestUid then
							TRex.State.MinigameEggUid = bestUid
							Core.pokeTasks()
						else
							TRex.State.MinigameEggUid = nil
						end
					else
						TRex.State.MinigameEggUid = nil
					end
				else
					TRex.State.MinigameEggUid = nil
				end
			else
				TRex.State.MinigameEggUid = nil
			end

			local sd = Core.getSaveData()
			if type(sd) == "table" then
				if cfg.AutoClaimMastery and type(sd.FishingMastery) == "table" and isAlienBiomeOpen() then
					local mastMod = safeRequirePath({ "Data", "FishingMastery" })
					if type(mastMod) == "table" and type(mastMod.Milestones) == "table" then
						local caught = tonumber(sd.FishingMastery.Caught) or 0
						local claimed = sd.FishingMastery.ClaimedMilestoneIds or {}
						for _, m in ipairs(mastMod.Milestones) do
							if caught >= (m.Fish or 0) and not claimed[m.Id] then
								Core.invokeRemote("RF/Fishing/AskClaimMastery", m.Id)
								break
							end
						end
					end
				end

				if cfg.AutoTradePearls and type(sd.AlienLagoon) == "table" and os.clock() > LagoonState.TradeCooldownAt then
					local pearls = tonumber(sd.AlienLagoon.VoidPearls) or 0
					if pearls >= 1750 then
						local ok, res = Core.invokeRemote("RF/AlienLagoon/Trade")
						LagoonState.TradeCooldownAt = os.clock() + ((ok and res ~= false) and 2 or 60)
					end
				end
			end

			if cfg.AutoCursedIslandWars and os.clock() - IslandState.At > 4 then
				local ok, snap = Core.invokeRemote("RF/IslandWars/Fetch")
				if ok and type(snap) == "table" then
					IslandState.Snap = snap
					IslandState.At = os.clock()
				end
			end

			task.wait(1.0)
		end
	end)
end

return Events
