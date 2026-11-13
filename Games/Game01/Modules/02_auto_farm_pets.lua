-- T-RexProject/Games/Game01/Modules/02_auto_farm_pets.lua
-- Auto Steal (Separate Go/Return Modes, Ragdoll Teleport, StepTo, Fast Tween multi-leg resync),
-- Auto Treadmill + Ads + Admin Treadmill + Priority Rotation, Auto Progression, Keep Eggs,
-- Auto Place Egg, Auto Hatch & Equip, Auto Mutation, Auto Fuse Machine, Auto Favorite, Auto Sell.

local Workspace = TRex.Services.Workspace
local Players = TRex.Services.Players
local RunService = TRex.Services.RunService
local AdService = game:GetService("AdService")

local Core = TRex.Core
local UI = TRex.UI

local Farm = {}
TRex.Farm = Farm

local SORT_FIELD_MAP = {
	["Highest Value"] = "Value",
	["Biggest"] = "Scale",
	["Best Rarity"] = "RarityRank",
	["Lowest Value"] = "LowValue",
	["Nearest"] = "Near",
}

local MUTATION_ID_MAP = {
	Fractured = "Boss",
	["Dark Matter"] = "DarkMatter",
	Abducted = "Alien",
}

local StealStatusRow = nil
local StealBlockedUntil = {}
local SafeDroppedUntil = {}
local CarrierRetryAt = {}
local LastStealAt = 0
local StealBagFullUntil = 0
local StealEmptySince = nil
local PlaceBadUntil = {}
local MutateBadUntil = {}
local ProgressCooldown = {}
local OnAdminTreadmill = false
local TreadmillEnteredAt = 0
local SpeedCheckAt = 0
local LastLeaderSpeed = -1

local function setStealStatus(text)
	TRex.State.StealStatus = text
	if StealStatusRow and StealStatusRow.Set then
		StealStatusRow:Set(text)
	end
end

local function emitWebhook(eventKind, data)
	local srv = TRex.Server
	if srv and type(srv.notifyWebhook) == "function" then
		pcall(srv.notifyWebhook, eventKind, data)
	end
end

local function readFieldEggsMap()
	local ok, map = pcall(function()
		return Core.callModule("Egg", "ReadFieldEggs")
	end)
	if ok and type(map) == "table" then
		return map
	end
	return {}
end

function Farm.getFieldEggs()
	return readFieldEggsMap()
end

local function findEggRecord(uid)
	local eggs = readFieldEggsMap()
	if type(eggs[uid]) == "table" then
		return eggs[uid]
	end
	for _, rec in pairs(eggs) do
		if type(rec) == "table" and rec.Uid == uid then
			return rec
		end
	end
	return nil
end

local function getEggWorldPos(rec, uid)
	if typeof(rec) == "table" and typeof(rec.BottomCFrame) == "CFrame" then
		return rec.BottomCFrame.Position
	end
	local model = uid and Workspace:FindFirstChild(uid)
	if model and model:IsA("Model") then
		local ok, cf, size = pcall(model.GetBoundingBox, model)
		if ok then
			return Vector3.new(cf.X, cf.Y - size.Y * 0.5, cf.Z)
		end
		return model:GetPivot().Position
	end
	return nil
end

local function findEggCarrier(uid)
	local rec = findEggRecord(uid)
	local lp = TRex.LocalPlayer
	if rec and rec.State == "Carried" then
		local cid = tonumber(rec.CarrierUserId) or 0
		local plr = cid > 0 and Players:GetPlayerByUserId(cid) or nil
		if plr and plr ~= lp then
			local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				return hrp, plr
			end
		end
	end
	local model = Workspace:FindFirstChild(uid)
	if model then
		for _, desc in ipairs(model:GetDescendants()) do
			if desc:IsA("JointInstance") or desc:IsA("WeldConstraint") or desc:IsA("RigidConstraint") then
				for _, part in ipairs({ desc.Part0, desc.Part1 }) do
					local charModel = part and not part:IsDescendantOf(model) and part:FindFirstAncestorOfClass("Model")
					local plr = charModel and Players:GetPlayerFromCharacter(charModel)
					if plr and plr ~= lp then
						return charModel:FindFirstChild("HumanoidRootPart") or part, plr
					end
				end
			end
		end
	end
	return nil, nil
end

local function getInventoryCount()
	local save = Core.getSaveData()
	local inv = save and (save.EggInventory or save.Eggs or save.Assets)
	if type(inv) ~= "table" then
		return 0
	end
	local c = 0
	for _ in pairs(inv) do
		c += 1
	end
	return c
end

local function getMaxEggInventory()
	local lim = Core.Modules.EggLimits
	return (type(lim) == "table" and tonumber(lim.MAX_INVENTORY)) or 115
end

local function getInventoryEggsTable()
	local save = Core.getSaveData()
	if type(save) ~= "table" then
		return {}
	end
	return save.EggInventory or save.Eggs or save.Assets or {}
end

local function getInventoryPetsTable()
	local save = Core.getSaveData()
	return (type(save) == "table" and type(save.Inventory) == "table") and save.Inventory or {}
end

function Farm.isProtected(uid, rec)
	local cfg = TRex.Config
	if not cfg.KeepEggs or type(rec) ~= "table" then
		return false
	end
	local info = Core.computeEggInfo(rec)
	local reqRank = Core.RARITY_RANK[cfg.KeepEggsMinRarity] or 0
	if cfg.KeepEggsMinRarity and cfg.KeepEggsMinRarity ~= "Any" and info.RarityRank >= reqRank then
		return true
	end
	local minV = tonumber(cfg.KeepEggsMinValue) or 0
	if minV > 0 and info.Value >= minV then
		return true
	end
	return false
end

local function sellCheapestEggForRoom(belowValue)
	local inv = getInventoryEggsTable()
	local bestUid, bestVal = nil, belowValue or math.huge
	local cap = tonumber(TRex.Config.KeepEggsMinValue) or math.huge
	if cap <= 0 then
		cap = math.huge
	end
	for uid, rec in pairs(inv) do
		if type(rec) == "table" and not rec.Placement and not Farm.isProtected(uid, rec) then
			local info = Core.computeEggInfo(rec)
			if info.MutCount == 0 and info.Value < bestVal and info.Value < cap then
				bestVal = info.Value
				bestUid = uid
			end
		end
	end
	if not bestUid then
		return false
	end
	Core.fireRemote("RE/PetSatchel/SellSelection", { Eggs = { bestUid }, Assets = {} })
	setStealStatus("ขายไข่ราคาถูกเพื่อเปิดช่องเก็บ")
	return true
end

function Farm.doffTreadmill()
	OnAdminTreadmill = false
	TRex.State.OnAdminTreadmill = false
	pcall(Core.invokeNS, "Treadmill", "AskDoff")
end

-- Check/ensure outside safe zone or leave Fuse/Tree when stealing
local function prepareFieldTravel(wantSafeZone, shouldContinue)
	if Core.inFuseZone() then
		Core.leaveFuseZone(8)
	end
	if Core.inHighZone() then
		local sep = Core.getSeparationBouncePos()
		Core.setRootCFrame(CFrame.new(sep))
		task.wait(0.2)
	end
	Core.needBody()
	local root = Core.getRoot()
	if not root or (shouldContinue and not shouldContinue()) then
		return false
	end
	if not wantSafeZone and Core.isInSafeZone(root.Position) then
		local sep = Core.getSeparationLinePos()
		if TRex.Config.SafeCrossing and Core.isWallSealed() then
			return false
		end
		local outside = Vector3.new(sep.X + 24, sep.Y + 3, math.clamp(root.Position.Z, -415, -305))
		Core.setRootCFrame(CFrame.new(outside))
		task.wait(0.15)
	end
	return Core.isAlive()
end

-- Bat Chase if carrier grabs target egg
local function tryChaseCarrier(uid, eggName, shouldContinue)
	if (CarrierRetryAt[uid] or 0) > os.clock() then
		return false, "Taken by someone"
	end
	local combat = TRex.Combat
	if not combat or type(combat.findBatTool) ~= "function" then
		return false, "No bat"
	end
	local bat = combat.findBatTool()
	if not bat then
		return false, "No bat"
	end
	if not Core.needBody() then
		return false, "visible"
	end

	local hrp, plr = findEggCarrier(uid)
	local root = Core.getRoot()
	if hrp and root and (hrp.Position - root.Position).Magnitude > 700 then
		Core.ragTo(function()
			local h = findEggCarrier(uid)
			return h and (h.Position + Vector3.new(0, 3, 0)) or nil
		end, shouldContinue)
	end

	local startAt = os.clock()
	local recovered = false
	while (not shouldContinue or shouldContinue()) and os.clock() - startAt < 65 do
		if Core.isCarryingEgg(uid) then
			return true, "ok"
		end
		local rec = findEggRecord(uid)
		if not rec then
			return false, "Egg disappeared"
		end
		if rec.State == "Slot" or rec.State == "Dropped" then
			recovered = true
			break
		end
		local cHrp, cPlr = findEggCarrier(uid)
		if not cHrp or not cPlr or Core.isInSafeZone(cHrp.Position) then
			CarrierRetryAt[uid] = os.clock() + 45
			return false, "The carrier got away"
		end
		setStealStatus("ไล่ตี " .. tostring(cPlr.DisplayName) .. " แย่ง " .. tostring(eggName))
		if type(combat.chaseStep) == "function" then
			combat.chaseStep(cPlr, cHrp, bat)
		else
			Core.walkTo(cHrp.Position, shouldContinue, 1.0)
			if (cHrp.Position - (Core.getRoot() and Core.getRoot().Position or Vector3.zero)).Magnitude < 14 then
				Core.fireRemote("RE/BatSwing/Trigger", cPlr.Character, cHrp.Position)
			end
		end
		RunService.Heartbeat:Wait()
	end
	if recovered then
		local rec = findEggRecord(uid)
		local p = getEggWorldPos(rec, uid)
		if p then
			Core.setRootCFrame(CFrame.new(p + Vector3.new(0, 3, 0)))
		end
		return true, "recovered"
	end
	return false, "The carrier got away"
end

-- Grab egg once near it (supports CarryFieldEgg + SmartPromptPart fallback + CarryChanged confirm)
local function grabEgg(uid, slot, eggPos, eggName, shouldContinue)
	setStealStatus("กำลังเก็บ " .. tostring(eggName))
	local deadAt = os.clock() + 20
	local promptAt = 0
	local carryPending = 0
	local tpAreaAt = 0
	while not Core.isCarryingEgg(uid) and os.clock() < deadAt and (not shouldContinue or shouldContinue()) do
		if not Core.isAlive() then
			return false, "dead"
		end
		local rec = findEggRecord(uid)
		if not rec or rec.State == "GuardCarried" then
			return false, "Guard took it"
		end
		if rec.State == "Carried" and tonumber(rec.CarrierUserId) ~= (TRex.LocalPlayer and TRex.LocalPlayer.UserId) then
			return false, "Taken by someone"
		end
		local curPos = getEggWorldPos(rec, uid) or eggPos
		local root = Core.getRoot()
		if curPos and root then
			if (curPos - root.Position).Magnitude > 14 then
				if (curPos - root.Position).Magnitude > 300 then
					return false, "Egg went back to its nest"
				end
				Core.walkTo(curPos, function()
					return (not shouldContinue or shouldContinue()) and not Core.isCarryingEgg(uid)
				end, 0.95)
			else
				local hum = Core.getHumanoid()
				Core.setRootCFrame(CFrame.new(curPos + Vector3.new(0, (hum and hum.HipHeight or 2) + 1, 0)) * root.CFrame.Rotation)
			end
		end

		if os.clock() >= promptAt then
			promptAt = os.clock() + 0.15
			local fpp = TRex.resolveGlobalFunc("fireproximityprompt")
			if fpp and curPos then
				local prompt = Core.getPromptNear(curPos, 16)
				if prompt then
					pcall(function()
						prompt.HoldDuration = 0
						fpp(prompt)
					end)
				end
			end
		end

		if carryPending < 3 then
			carryPending += 1
			task.spawn(function()
				local okC, errC = Core.callModule("Egg", "CarryFieldEgg", uid, slot)
				carryPending -= 1
				if type(errC) == "string" then
					local lo = errC:lower()
					if lo:find("full") then
						StealBagFullUntil = os.clock() + 30
					elseif lo:find("gameplay area") and tpAreaAt == 0 then
						tpAreaAt = os.clock()
					end
				end
				if okC == nil then
					Core.invokeRemote("RF/EggWorld/AskFieldEggCarry", uid, slot)
				end
			end)
		end

		RunService.Heartbeat:Wait()
	end
	return Core.isCarryingEgg(uid), Core.isCarryingEgg(uid) and "ok" or "Failed to pick up"
end

-- Exact multi-leg resync when returning via Fast Tween or Instant/Quick Steps
local function resyncMultiLegDrop(uid, groundPos, rotCF, eggName, shouldContinue)
	Core.setRootCFrame(CFrame.new(groundPos) * rotCF)
	local settle = 0
	while settle < 0.12 and Core.isCarryingEgg(uid) and (not shouldContinue or shouldContinue()) do
		settle += RunService.Heartbeat:Wait()
	end

	local droppedSeen = false
	local repicked = false
	local conn = nil
	local eggMod = Core.Modules.Egg
	if type(eggMod) == "table" and eggMod.CarryChanged then
		conn = eggMod.CarryChanged:Connect(function(payload)
			if type(payload) == "table" then
				if payload.IsCarrying and droppedSeen then
					repicked = true
				elseif not payload.IsCarrying then
					droppedSeen = true
				end
			end
		end)
	end

	task.spawn(function()
		Core.callModule("Egg", "DropFieldEgg", "PlayerRequest")
	end)

	local waitDeadline = 0
	local warpedToDrop = false
	local pending = 0
	while not repicked and waitDeadline < 1.5 and (not shouldContinue or shouldContinue()) do
		if droppedSeen and not warpedToDrop then
			local rec = findEggRecord(uid)
			if rec and rec.State == "Dropped" and typeof(rec.BottomCFrame) == "CFrame" then
				warpedToDrop = true
				local r = Core.getRoot()
				if r and (rec.BottomCFrame.Position - r.Position).Magnitude > 6 then
					Core.setRootCFrame(CFrame.new(rec.BottomCFrame.Position + Vector3.new(0, 3, 0)) * rotCF)
				end
			end
		end
		if pending < 3 then
			pending += 1
			task.spawn(function()
				Core.callModule("Egg", "CarryFieldEgg", uid)
				pending -= 1
			end)
		end
		waitDeadline += RunService.Heartbeat:Wait()
	end

	if conn then
		conn:Disconnect()
	end

	if Core.isCarryingEgg(uid) then
		return true
	end
	local okChase = tryChaseCarrier(uid, eggName, shouldContinue)
	return okChase
end

-- Deliver egg across SeparationLine + RiftMachine / DropSafeZone
local function deliverEggBack(target, shouldContinue)
	local cfg = TRex.Config
	local uid = target.Uid
	local areaId = target.AreaId
	local sepPos = Core.getSeparationLinePos()
	local root = Core.getRoot()
	if not root then
		return false, "no root"
	end

	local clampedZ = math.clamp(root.Position.Z, -415, -305)
	local rotCF = root.CFrame.Rotation
	local dir = (sepPos.X <= root.Position.X) and 1 or -1

	local isTpZone = (cfg.MoveToEgg == "Teleport")
		and table.find(Core.TELEPORT_ZONES, areaId) ~= nil
		and table.find(cfg.TeleportZones or {}, areaId) ~= nil

	local returnMode
	if isTpZone then
		returnMode = cfg.TeleportDelivery or "Fast Tween"
	else
		returnMode = cfg.DeliveryMode or "Fast Tween"
	end

	setStealStatus("กำลังนำไข่ " .. tostring(target.Name) .. " กลับฐาน (" .. returnMode .. ")")

	-- Instant Steal V3 shortcut when AdminTreadmill is up & not dropping at safe zone
	if cfg.InstantStealV3 and not cfg.DropEggsAtSafeZone and (Workspace:GetAttribute("AdminBoost_Treadmill") or Workspace:FindFirstChild("AdminTreadmill")) then
		local tMark = os.clock()
		Core.setRootCFrame(CFrame.new(Core.getRiftMachinePos()) * rotCF)
		while os.clock() - tMark < 1.5 + Core.getPing() * 3 and Core.isCarryingEgg(uid) and (not shouldContinue or shouldContinue()) do
			if Core.getRedeemVerdictAt() >= tMark then
				return true, "ok"
			end
			RunService.Heartbeat:Wait()
		end
		if not Core.isCarryingEgg(uid) then
			return true, "ok"
		end
	end

	if returnMode == "Instant Steps" or returnMode == "Quick Steps" then
		local curX = root.Position.X
		local flyY = root.Position.Y + 42
		local stepSize = math.max(Core.getWalkSpeed() * 1.515, 40)
		local numSteps = (returnMode == "Quick Steps") and Core.getAreaLegs(areaId) or math.clamp(tonumber(cfg.StepCount) or 3, 1, 6)
		local splits = {}
		for k = 1, numSteps - 1 do
			splits[k] = curX - (curX - sepPos.X) * k / numSteps
		end
		local splitIdx = 1
		while Core.isCarryingEgg(uid) and (not shouldContinue or shouldContinue()) and (curX - sepPos.X) * dir > stepSize do
			while Core.isAntiGuardBusy() and Core.isCarryingEgg(uid) and (not shouldContinue or shouldContinue()) do
				RunService.Heartbeat:Wait()
			end
			curX -= stepSize * dir
			if splits[splitIdx] and (curX - splits[splitIdx]) * dir <= 0 then
				splitIdx += 1
				local landPos = Vector3.new(curX, sepPos.Y, clampedZ)
				Core.setRootCFrame(CFrame.new(landPos) * rotCF)
				local w = 0
				while w < 0.19 + Core.getPing() and Core.isCarryingEgg(uid) do
					w += RunService.Heartbeat:Wait()
				end
				if not resyncMultiLegDrop(uid, landPos, rotCF, target.Name, shouldContinue) then
					return false, "Dropped on leg"
				end
				local nr = Core.getRoot()
				if nr then
					curX = nr.Position.X
				end
				task.wait(0.1)
			end
			local holdPos = CFrame.new(curX, flyY, clampedZ) * rotCF
			local hEl = 0
			while hEl < 0.1 and Core.isCarryingEgg(uid) and (not shouldContinue or shouldContinue()) do
				Core.setRootCFrame(holdPos)
				hEl += RunService.Heartbeat:Wait()
			end
		end
		if Core.isCarryingEgg(uid) then
			Core.setRootCFrame(CFrame.new(sepPos) * rotCF)
		end

	elseif returnMode == "Fast Tween" then
		local flyY = sepPos.Y
		local legs = Core.getAreaLegs(areaId)
		local startX = root.Position.X
		local splits = {}
		for k = 1, legs - 1 do
			splits[k] = startX - (startX - sepPos.X) * k / legs
		end
		local splitIdx = 1
		local pullSpd = math.clamp(tonumber(cfg.FastTweenSpeed) or 3300, 3000, 4500)
		local dt = 0.0166
		while Core.isCarryingEgg(uid) and (not shouldContinue or shouldContinue()) do
			root = Core.getRoot()
			if not root then
				return false, "no root"
			end
			if Core.isAntiGuardBusy() then
				dt = RunService.Heartbeat:Wait()
				continue
			end
			local pos = root.Position
			if (pos.X - sepPos.X) * dir <= 36 then
				break
			end
			if splits[splitIdx] and (pos.X - splits[splitIdx]) * dir <= 0 then
				splitIdx += 1
				local okResync = resyncMultiLegDrop(uid, Vector3.new(pos.X, sepPos.Y, pos.Z), rotCF, target.Name, shouldContinue)
				if not okResync then
					return false, "Dropped on leg"
				end
				dt = RunService.Heartbeat:Wait()
				continue
			end
			local stepX = math.min(pullSpd * math.clamp(dt, 0.005, 0.08), 250, (pos.X - sepPos.X) * dir)
			local nextZ = pos.Z + (clampedZ - pos.Z) * 0.03
			Core.setRootCFrame(CFrame.new(pos.X - dir * stepX, flyY, nextZ) * rotCF)
			dt = RunService.Heartbeat:Wait()
		end

	else
		-- Walk delivery
		local walkMult = math.clamp(tonumber(cfg.DeliverySpeed) or 95, 80, 110) / 100
		local targetY = sepPos.Y + 3
		while Core.isCarryingEgg(uid) and (not shouldContinue or shouldContinue()) do
			root = Core.getRoot()
			if not root then
				return false, "no root"
			end
			if Core.isAntiGuardBusy() then
				RunService.Heartbeat:Wait()
				continue
			end
			if (root.Position.X - sepPos.X) * dir <= 36 then
				break
			end
			if math.abs(root.Position.Y - targetY) > 2 then
				local ch = Core.getCharacter()
				if ch then
					pcall(ch.PivotTo, ch, CFrame.new(root.Position.X, targetY, root.Position.Z) * root.CFrame.Rotation)
				end
			end
			local vx = Vector3.new(-dir, 0, math.clamp((clampedZ - root.Position.Z) * 0.03, -0.3, 0.3)).Unit * Core.getWalkSpeed() * walkMult
			pcall(function()
				root.AssemblyLinearVelocity = vx
			end)
			RunService.Heartbeat:Wait()
		end
	end

	-- Final Crossing / Safe Drop vs RiftMachine Redeem
	if cfg.DropEggsAtSafeZone then
		local safeSpot = Vector3.new(sepPos.X - 18, sepPos.Y + 3, clampedZ)
		Core.setRootCFrame(CFrame.new(safeSpot) * rotCF)
		task.wait(0.15)
		Core.callModule("Egg", "DropFieldEgg", "PlayerRequest")
		SafeDroppedUntil[uid] = os.clock() + 300
		return true, "Dropped at safe zone"
	end

	setStealStatus("กำลังนำเข้าจุดปลอดภัย (Rift)")
	for attempt = 1, 2 do
		if not Core.isCarryingEgg(uid) then
			return true, "ok"
		end
		local tCross = os.clock()
		Core.setRootCFrame(CFrame.new(Core.getRiftMachinePos()) * rotCF)
		while (not shouldContinue or shouldContinue()) and os.clock() - tCross < 1.5 + Core.getPing() * 3 and Core.getRedeemVerdictAt() < tCross and Core.isCarryingEgg(uid) do
			RunService.Heartbeat:Wait()
		end
		if Core.getRedeemVerdictAt() >= tCross or not Core.isCarryingEgg(uid) then
			return true, "ok"
		end
		if attempt == 1 then
			Core.setRootCFrame(CFrame.new(sepPos) * rotCF)
			local w = 0
			while w < 0.3 + Core.getPing() do
				w += RunService.Heartbeat:Wait()
			end
		end
	end
	return false, "Crossing failed"
end

-- Select best matching field eggs sorted by priority
local function selectStealTargets()
	local cfg = TRex.Config
	local eggs = readFieldEggsMap()
	local root = Core.getRoot()
	local rootPos = root and root.Position
	local lp = TRex.LocalPlayer
	local now = os.clock()
	local list = {}
	local mgUid = TRex.State.MinigameEggUid

	for k, rec in pairs(eggs) do
		local uid = type(rec) == "table" and (rec.Uid or k) or nil
		if type(uid) == "string" and (rec.State == "Slot" or rec.State == "Dropped" or rec.State == "GuardCarried" or rec.State == "Carried") then
			if (StealBlockedUntil[uid] or 0) <= now and (SafeDroppedUntil[uid] or 0) <= now then
				local info = Core.computeEggInfo(rec)
				local pos = getEggWorldPos(rec, uid)
				if pos then
					local isPick = (mgUid ~= nil and uid == mgUid)
					local isIdx = cfg.StealMissingIndex and Core.isMissingInIndex(info.Category)
					local isMatch = Core.filterMatches(info, "Steal", {
						minValueKey = "MinStealValue",
						areasKey = "TargetAreas",
						specificKey = "TargetSpecificEggs",
					})
					local isCarriedByOther = (rec.State == "Carried" and tonumber(rec.CarrierUserId) ~= (lp and lp.UserId or 0))
					if isPick or isIdx or isMatch then
						local tier = isPick and 3 or (isIdx and 2 or 1)
						local flatDist = rootPos and Vector3.new(pos.X - rootPos.X, 0, pos.Z - rootPos.Z).Magnitude or 99999
						local slot = (uid:sub(1, 13) == "FirstAreaEgg_") and uid:match("_([%w ]+:Slot_%d+)$")
							or (type(rec.AreaId) == "string" and type(rec.NestId) == "string" and (rec.AreaId .. ":" .. rec.NestId) or nil)
						table.insert(list, {
							Uid = uid,
							Slot = slot,
							Pos = pos,
							AreaId = info.AreaId,
							Name = info.Name,
							Rarity = info.Rarity,
							RarityRank = info.RarityRank,
							Scale = info.Scale,
							Value = info.Value,
							Tier = tier,
							Near = -flatDist,
							LowValue = -info.Value,
							Held = isCarriedByOther,
						})
					end
				end
			end
		end
	end

	local sortKey = SORT_FIELD_MAP[cfg.StealPriority] or "Value"
	table.sort(list, function(a, b)
		if a.Tier ~= b.Tier then
			return a.Tier > b.Tier
		end
		if a[sortKey] ~= b[sortKey] then
			return (a[sortKey] or 0) > (b[sortKey] or 0)
		end
		return a.Value > b.Value
	end)
	return list
end

local function registerStealTask()
	Core.registerTask({
		Name = "Steal",
		Priority = 2,
		Gap = 0.2,
		NeedsMover = true,
		On = function()
			return TRex.Config.AutoSteal == true
		end,
		Want = function()
			if Core.isNightPhase() then
				setStealStatus("รอเวลากลางวัน")
				return nil
			end
			if os.clock() < StealBagFullUntil then
				setStealStatus("กระเป๋าเต็ม กำลังรอ...")
				return nil
			end
			local targets = selectStealTargets()
			if #targets == 0 then
				StealEmptySince = StealEmptySince or os.clock()
				setStealStatus("ไม่พบไข่ที่ตรงเงื่อนไข")
				return nil
			end
			StealEmptySince = nil
			local chosen = nil
			local hasBat = TRex.Combat and type(TRex.Combat.findBatTool) == "function" and TRex.Combat.findBatTool() ~= nil
			for _, cand in ipairs(targets) do
				if not cand.Held or hasBat then
					chosen = cand
					break
				end
			end
			if not chosen then
				setStealStatus("ไข่เป้าหมายอยู่ในมือผู้เล่นอื่น")
				return nil
			end
			if getInventoryCount() >= getMaxEggInventory() then
				if TRex.Config.KeepEggs and sellCheapestEggForRoom(chosen.Value) then
					return nil
				end
				StealBagFullUntil = os.clock() + 30
				setStealStatus("กระเป๋าไข่เต็ม")
				return nil
			end
			return chosen
		end,
		Run = function(target, shouldContinue)
			if Core.isCarryingEgg() and not Core.isCarryingEgg(target.Uid) then
				Core.callModule("Egg", "DropFieldEgg", "PlayerRequest")
				task.wait(0.25)
			end
			if not prepareFieldTravel(false, shouldContinue) then
				return
			end

			local cfg = TRex.Config
			local okGo = true
			if target.Held then
				okGo = tryChaseCarrier(target.Uid, target.Name, shouldContinue)
			else
				setStealStatus("กำลังเดินทางไป " .. tostring(target.Name))
				local isTpZone = (cfg.MoveToEgg == "Teleport")
					and table.find(Core.TELEPORT_ZONES, target.AreaId) ~= nil
					and table.find(cfg.TeleportZones or {}, target.AreaId) ~= nil

				if isTpZone then
					local root = Core.getRoot()
					local flatDist = root and Vector3.new(target.Pos.X - root.Position.X, 0, target.Pos.Z - root.Position.Z).Magnitude or 9999
					if flatDist > 1500 and not Core.isNightPhase() then
						Core.ragTo(target.Pos + Vector3.new(0, 3, 0), shouldContinue)
						root = Core.getRoot()
						flatDist = root and Vector3.new(target.Pos.X - root.Position.X, 0, target.Pos.Z - root.Position.Z).Magnitude or 9999
					end
					if flatDist > 14 then
						Core.stepTo(target.Pos, shouldContinue, 3)
					end
				else
					local walkMult = math.clamp(tonumber(cfg.DeliverySpeed) or 95, 80, 110) / 100
					okGo = Core.walkTo(target.Pos, shouldContinue, walkMult)
				end

				if okGo and (not shouldContinue or shouldContinue()) then
					okGo = grabEgg(target.Uid, target.Slot, target.Pos, target.Name, shouldContinue)
				end
			end

			if not okGo or not Core.isCarryingEgg(target.Uid) then
				if Core.isCarryingEgg() and not cfg.DropEggsAtSafeZone then
					Core.callModule("Egg", "DropFieldEgg", "PlayerRequest")
				end
				StealBlockedUntil[target.Uid] = os.clock() + 3
				return
			end

			local okBack, errBack = deliverEggBack(target, shouldContinue)
			if okBack then
				LastStealAt = os.clock()
				setStealStatus("ขโมยสำเร็จ: " .. tostring(target.Name))
				UI.notify("notif.done", "ขโมย " .. tostring(target.Name) .. " สำเร็จ", 2.5)
				emitWebhook("Egg Stolen", target)
			else
				setStealStatus(tostring(errBack or "ส่งกลับไม่สำเร็จ"))
				if Core.isCarryingEgg() and not cfg.DropEggsAtSafeZone then
					Core.callModule("Egg", "DropFieldEgg", "PlayerRequest")
				end
				StealBlockedUntil[target.Uid] = os.clock() + 4
			end
		end,
	})
end

-- Auto Treadmill, Ads, Admin Treadmill & Priority Rotation
local function registerTreadmillAndRotation()
	local speedRE = Core.getRemote("RE/Treadmill/SpeedGained")
	if speedRE and speedRE:IsA("RemoteEvent") then
		TRex.connectSignal(speedRE.OnClientEvent, function()
			SpeedCheckAt = os.clock()
		end)
	end

	-- Rotation timer loop (Treadmill <-> Alien Fishing)
	task.spawn(function()
		TRex.State.RotationTurn = "tread"
		local turnDeadline = os.clock() + 60
		local lastDay = Core.isNightPhase()
		while TRex.IsRunning do
			task.wait(1)
			local cfg = TRex.Config
			if cfg.RotateFishingAndTreadmill then
				local switchMode = cfg.RotationSwitch or "Every Day"
				if switchMode == "Timer" then
					if os.clock() >= turnDeadline then
						if TRex.State.RotationTurn == "tread" then
							TRex.State.RotationTurn = "fish"
							turnDeadline = os.clock() + math.max(1, tonumber(cfg.FishingMinutes) or 1) * 60
							Farm.doffTreadmill()
						else
							TRex.State.RotationTurn = "tread"
							turnDeadline = os.clock() + math.max(1, tonumber(cfg.TreadmillMinutes) or 1) * 60
						end
					end
				elseif switchMode == "By Event" then
					local night = Core.isNightPhase()
					TRex.State.RotationTurn = night and "fish" or "tread"
				else
					local night = Core.isNightPhase()
					if night ~= lastDay then
						lastDay = night
						TRex.State.RotationTurn = (TRex.State.RotationTurn == "tread") and "fish" or "tread"
						if TRex.State.RotationTurn == "fish" then
							Farm.doffTreadmill()
						end
					end
				end
			else
				TRex.State.RotationTurn = "tread"
			end
		end
	end)

	-- Auto Watch Ads (AdService)
	task.spawn(function()
		local adCooldowns = { egg = 0, cash = 0 }
		local function adAvailable()
			local ok, res = pcall(AdService.GetAdAvailabilityNowAsync, AdService, Enum.AdFormat.RewardedVideo)
			return ok and res and res.AdAvailabilityResult == Enum.AdAvailabilityResult.IsAvailable
		end
		while TRex.IsRunning do
			task.wait(3)
			if TRex.Config.AutoWatchAds and adAvailable() then
				local adRemFolder = TRex.Services.ReplicatedStorage:FindFirstChild("AdEggBoostRemotes")
				local askEgg = adRemFolder and adRemFolder:FindFirstChild("AskAdGrowthBoost")
				if askEgg and askEgg:IsA("RemoteFunction") and os.clock() >= adCooldowns.egg then
					local okA, resA = pcall(askEgg.InvokeServer, askEgg)
					adCooldowns.egg = os.clock() + ((okA and type(resA) == "table" and resA.completed == true) and 30 or 120)
				end
				local rv = Workspace:FindFirstChild("RVBillboard_Cash_Reward")
				local remFolder = rv and rv:FindFirstChild("Remotes")
				local showAd = remFolder and remFolder:FindFirstChild("ShowAd")
				if showAd and showAd:IsA("RemoteEvent") and os.clock() >= adCooldowns.cash then
					pcall(showAd.FireServer, showAd)
					adCooldowns.cash = os.clock() + 30
				end
			end
		end
	end)

	Core.registerTask({
		Name = "Treadmill",
		Priority = 9,
		Gap = 1.5,
		NeedsMover = true,
		On = function()
			local cfg = TRex.Config
			if cfg.RotateFishingAndTreadmill and TRex.State.RotationTurn == "fish" then
				return false
			end
			local adminReady = cfg.AdminTreadmill and (Workspace:GetAttribute("AdminBoost_Treadmill") ~= nil or Workspace:FindFirstChild("AdminTreadmill") ~= nil)
			return cfg.AutoTreadmill == true or adminReady
		end,
		Want = function()
			if not prepareFieldTravel(true) then
				return nil
			end
			local cfg = TRex.Config
			local adminModel = Workspace:FindFirstChild("AdminTreadmill")
			if cfg.AdminTreadmill and (Workspace:GetAttribute("AdminBoost_Treadmill") ~= nil or adminModel ~= nil) then
				local p = adminModel and (adminModel:IsA("BasePart") and adminModel.Position or adminModel:GetPivot().Position)
					or Core.getRiftMachinePos()
				return { pos = p, admin = true }
			end
			if cfg.AutoTreadmill then
				local plot = Core.getPlot()
				local tm = plot and plot.PlotFolder and plot.PlotFolder:FindFirstChild("TreadmillBottom", true)
				if tm then
					local p = tm:IsA("BasePart") and tm.Position or tm:GetPivot().Position
					return { pos = p, admin = false }
				end
			end
			return nil
		end,
		Run = function(info, shouldContinue)
			if not Core.walkTo(info.pos + Vector3.new(0, 3, 0), shouldContinue, 0.95) then
				return
			end
			local ok = Core.invokeNSBoolean("Treadmill", "AskWearStill")
			OnAdminTreadmill = ok and info.admin == true
			TRex.State.OnAdminTreadmill = OnAdminTreadmill
			TreadmillEnteredAt = os.clock()
			SpeedCheckAt = os.clock()

			local ls = TRex.LocalPlayer and TRex.LocalPlayer:FindFirstChild("leaderstats")
			local sp = ls and ls:FindFirstChild("Speed")
			LastLeaderSpeed = sp and tonumber(sp.Value) or -1

			while shouldContinue() and TRex.IsRunning do
				if not Core.isAlive() then
					break
				end
				if info.admin and os.clock() - TreadmillEnteredAt > 6 and os.clock() - SpeedCheckAt > 6 then
					local curSp = sp and tonumber(sp.Value) or -1
					if curSp == LastLeaderSpeed then
						Farm.doffTreadmill()
						break
					end
					LastLeaderSpeed = curSp
				end
				local root = Core.getRoot()
				if not root or not root.Anchored then
					Core.invokeNSBoolean("Treadmill", "AskWearStill")
				end
				task.wait(0.8)
			end
			Farm.doffTreadmill()
		end,
	})
end

-- Auto Progression
local function registerProgressionTask()
	Core.registerTask({
		Name = "Progression",
		Priority = 12,
		Gap = 5,
		NeedsMover = false,
		On = function()
			local cfg = TRex.Config
			return cfg.AutoClaimMoney or cfg.AutoClaimIndex or cfg.AutoBuyTrail or cfg.AutoUpgradeTreadmill or cfg.AutoUpgradeBase
		end,
		Want = function()
			return true
		end,
		Run = function()
			local cfg = TRex.Config
			local save = Core.getSaveData()
			if not save then
				return
			end
			local money = tonumber(save.Money) or 0

			if cfg.AutoClaimMoney then
				local okS, sum = Core.invokeRemote("RF/AwayEarnings/FetchSummary")
				if okS and type(sum) == "table" and (tonumber(sum.ClaimableAmount) or 0) > 0 then
					Core.invokeRemote("RF/AwayEarnings/AskCollect", { Kind = "Claim" })
				end
			end

			if cfg.AutoClaimIndex then
				local idx = type(save.Index) == "table" and save.Index or {}
				local claimed = type(save.IndexClaimedCategories) == "table" and save.IndexClaimedCategories or {}
				for cat, unlocked in pairs(idx) do
					if unlocked == true and claimed[cat] ~= true then
						Core.invokeRemote("RF/Codex/AskRedeemAll")
						break
					end
				end
			end

			if cfg.AutoUpgradeBase then
				local bases = Core.Modules.Bases
				local lv = tonumber(save.BaseUpgradeLevel) or 1
				local nextBase = type(bases) == "table" and type(bases.BASES) == "table" and bases.BASES[lv + 1]
				local maxLv = Core.callModule("Bases", "GetMaxBaseLevel")
				if nextBase and money >= (tonumber(nextBase.Cost) or math.huge) and (not maxLv or lv < maxLv) then
					Core.fireRemote("RE/Homestead/AskBaseTierRaise")
					return
				end
			end

			if cfg.AutoUpgradeTreadmill then
				local lv = tonumber(save.TreadmillUpgradeLevel) or 0
				local nextTm = Core.callModule("Tread", "GetByUpgradeLevel", lv + 1)
				if type(nextTm) == "table" and nextTm._id and money >= (tonumber(nextTm.Price) or math.huge) then
					Core.invokeRemote("RF/Treadmill/AskTierRaise", nextTm._id)
					return
				end
			end

			if cfg.AutoBuyTrail then
				local owned = type(save.TrailInventory) == "table" and save.TrailInventory or {}
				local trailsMod = Core.Modules.Trails
				local dir = type(trailsMod) == "table" and trailsMod.Directory or nil
				local bestId, bestCost = nil, math.huge
				if type(dir) == "table" then
					for idKey, entry in pairs(dir) do
						local tid = type(entry) == "table" and (entry._id or idKey) or idKey
						local cost = type(entry) == "table" and tonumber(entry.Price)
						if cost and cost <= money and owned[tid] ~= true and not ProgressCooldown[tid] and cost < bestCost then
							bestCost = cost
							bestId = tid
						end
					end
				end
				if bestId then
					if not Core.invokeServerBoolean("RF/Trailwear/AskPurchase", bestId) then
						ProgressCooldown[bestId] = true
					end
				end
			end
		end,
	})
end

-- Auto Place Egg
local function buildPlacementCandidates(centerPos, placedRecs)
	local out = {}
	local occupied = {}
	for _, r in pairs(placedRecs or {}) do
		local cf = type(r.Placement) == "table" and r.Placement.LocalCFrame
		if typeof(cf) == "CFrame" then
			table.insert(occupied, cf.Position)
		end
	end
	for gx = -32, 32, 8 do
		for gz = -32, 32, 8 do
			local candidate = Vector3.new(gx, 0, gz)
			local blocked = false
			for _, occ in ipairs(occupied) do
				if (occ - candidate).Magnitude < 6 then
					blocked = true
					break
				end
			end
			if not blocked then
				table.insert(out, { CFrame.new(candidate) })
			end
		end
	end
	return out
end

local function registerPlaceEggTask()
	Core.registerTask({
		Name = "Place",
		Priority = 4,
		Gap = 8,
		NeedsMover = true,
		On = function()
			local cfg = TRex.Config
			return cfg.AutoPlaceEgg == true or cfg.PlaceMissingIndex == true
		end,
		Want = function()
			local cfg = TRex.Config
			local when = cfg.PlaceEggRule or "Always"
			if when == "Steal is idle" and cfg.AutoSteal and not StealEmptySince then
				return nil
			elseif when == "Right after a steal" and os.clock() - LastStealAt >= 12 then
				return nil
			elseif when == "Only at night" and not Core.isNightPhase() then
				return nil
			end

			local inv = getInventoryEggsTable()
			local placed, placedCats, list, idxList = {}, {}, {}, {}
			local placedCount = 0
			for uid, rec in pairs(inv) do
				if type(rec) == "table" and rec.Placement then
					placedCount += 1
					placed[uid] = rec
					placedCats[tostring(rec.AssetCategory or rec.Category or "")] = true
				end
			end
			if placedCount >= 30 then
				return nil
			end

			local minV = tonumber(cfg.MinPlaceValue) or 0
			local maxV = tonumber(cfg.MaxPlaceValue) or math.huge
			if maxV <= 0 or maxV >= 1e12 then
				maxV = math.huge
			end
			for uid, rec in pairs(inv) do
				if type(rec) == "table" and not rec.Placement and (PlaceBadUntil[uid] or 0) < os.clock() and not Farm.isProtected(uid, rec) then
					local info = Core.computeEggInfo(rec)
					info.Uid = uid
					if cfg.PlaceMissingIndex and Core.isMissingInIndex(info.Category) and not placedCats[info.Category] then
						placedCats[info.Category] = true
						table.insert(idxList, info)
					elseif cfg.AutoPlaceEgg then
						local rarList = cfg.PlaceRarities
						local rarOk = (type(rarList) ~= "table" or #rarList == 0 or table.find(rarList, info.Rarity) ~= nil)
						local specOk = true
						if type(cfg.PlaceSpecificEggs) == "table" and #cfg.PlaceSpecificEggs > 0 then
							local set = Core.stripEggLabelSet(cfg.PlaceSpecificEggs)
							specOk = (set[info.Name] == true or set[info.Category] == true)
						end
						if rarOk and specOk and info.Value >= minV and info.Value < maxV then
							table.insert(list, info)
						end
					end
				end
			end

			if #list + #idxList == 0 then
				return nil
			end

			local order = cfg.PlaceEggOrder or "Highest Value"
			if order ~= "Backpack" then
				local field = ({ ["Biggest Size"] = "Scale", ["Smallest Size"] = "Scale", ["Best Rarity"] = "RarityRank", ["Lowest Value"] = "Value" })[order] or "Value"
				local asc = (order == "Smallest Size" or order == "Lowest Value")
				table.sort(list, function(a, b)
					if asc then
						return a[field] < b[field]
					end
					if a[field] ~= b[field] then
						return a[field] > b[field]
					end
					return a.Value > b.Value
				end)
			end
			for i, item in ipairs(idxList) do
				table.insert(list, i, item)
			end
			return { list = list, room = 30 - placedCount, placed = placed }
		end,
		Run = function(work, shouldContinue)
			local plot = Core.getPlot()
			local penPos = plot and plot.PetArea and plot.PetArea.Position
			if not penPos then
				return
			end
			if not Core.walkTo(penPos + Vector3.new(0, 3, 0), shouldContinue, 0.95) then
				return
			end
			local cands = buildPlacementCandidates(plot.CenterPoint and plot.CenterPoint.Position or penPos, work.placed)
			local candIdx, placedOk = 0, 0
			local count = math.min(work.room, #work.list)
			for i = 1, count do
				if not shouldContinue() then
					break
				end
				local item = work.list[i]
				if Core.callModule("Egg", "WearEggTool", item.Uid) ~= false then
					local didPlace = false
					for _ = 1, 8 do
						candIdx += 1
						local c = cands[candIdx]
						if not c then
							break
						end
						if Core.invokeServerBoolean("RF/EggWorld/AskPlaceEgg", { Uid = item.Uid, LocalCFrame = c[1] }) then
							placedOk += 1
							didPlace = true
							break
						end
					end
					if not didPlace then
						PlaceBadUntil[item.Uid] = os.clock() + 60
					end
					task.wait(0.25)
				else
					PlaceBadUntil[item.Uid] = os.clock() + 20
				end
			end
			Core.callModule("Egg", "DoffEggTool")
			if placedOk > 0 then
				UI.notify("notif.done", "วางไข่แล้ว " .. tostring(placedOk) .. " ฟอง", 2.5)
			end
		end,
	})
end

-- Auto Hatch & Equip
local function getPlacedEggWorldPos(uid, rec)
	local folder = Workspace:FindFirstChild("PlacedEggRenders")
	local lp = TRex.LocalPlayer
	local m = folder and lp and folder:FindFirstChild(tostring(lp.UserId) .. "_" .. tostring(uid))
	if m then
		return m:GetPivot().Position
	end
	local plot = Core.getPlot()
	local lcf = type(rec) == "table" and type(rec.Placement) == "table" and rec.Placement.LocalCFrame
	if plot and plot.CenterPoint and typeof(lcf) == "CFrame" then
		return (plot.CenterPoint.CFrame * lcf).Position
	end
	return nil
end

local function registerHatchAndMutation()
	Core.registerTask({
		Name = "Hatch",
		Priority = 5,
		Gap = 2,
		NeedsMover = true,
		On = function()
			return TRex.Config.AutoHatch == true
		end,
		Want = function()
			local cfg = TRex.Config
			local inv = getInventoryEggsTable()
			local nowServer = Core.getServerNow()
			local readyList = {}
			local specSet = Core.stripEggLabelSet(cfg.HatchSpecificEggs)
			local minV = tonumber(cfg.HatchMinValue) or 0
			for uid, rec in pairs(inv) do
				if type(rec) == "table" and rec.Placement then
					local readyAt = tonumber(rec.Placement.ReadyAt or rec.ReadyAt) or 0
					if nowServer >= readyAt then
						local info = Core.computeEggInfo(rec)
						local specOk = (not specSet) or specSet[info.Name] or specSet[info.Category]
						if specOk and info.Value >= minV then
							info.Uid = uid
							info.Pos = getPlacedEggWorldPos(uid, rec)
							table.insert(readyList, info)
						end
					end
				end
			end
			if #readyList == 0 then
				return nil
			end
			return readyList
		end,
		Run = function(list, shouldContinue)
			local cfg = TRex.Config
			for _, item in ipairs(list) do
				if not shouldContinue() then
					break
				end
				if item.Pos then
					Core.walkTo(item.Pos + Vector3.new(0, 3, 4), shouldContinue, 0.95)
				end
				if Core.invokeServerBoolean("RF/EggWorld/AskHatch", item.Uid) then
					task.wait(0.35)
					Core.invokeRemote("RF/EggWorld/AskFinishHatch", item.Uid)
				end
				if cfg.HatchMode == "One By One" then
					task.wait(0.4)
				end
			end
			if cfg.AutoEquipBest then
				local okS, st = Core.invokeRemote("RF/Haul/FetchWearBestStatus")
				if okS and (type(st) ~= "table" or st.CanWear ~= false) then
					Core.invokeRemote("RF/Haul/WearBest")
				end
			end
		end,
	})

	-- Auto Equip Best periodic fallback
	task.spawn(function()
		while TRex.IsRunning do
			task.wait(6)
			if TRex.Config.AutoEquipBest and not TRex.Config.AutoHatch then
				local okS, st = Core.invokeRemote("RF/Haul/FetchWearBestStatus")
				if okS and (type(st) ~= "table" or st.CanWear ~= false) then
					Core.invokeRemote("RF/Haul/WearBest")
				end
			end
		end
	end)

	-- Auto Mutation
	Core.registerTask({
		Name = "Mutate",
		Priority = 6,
		Gap = 2,
		NeedsMover = true,
		On = function()
			return TRex.Config.AutoMutate == true
		end,
		Want = function()
			local toolsByMut = {}
			local sources = { TRex.LocalPlayer and TRex.LocalPlayer:FindFirstChildOfClass("Backpack"), Core.getCharacter() }
			for _, src in ipairs(sources) do
				if src then
					for _, tool in ipairs(src:GetChildren()) do
						if tool:IsA("Tool") and tool:GetAttribute("ItemType") == "MutationConsumable" then
							local mId = tool:GetAttribute("MutationId") or tool:GetAttribute("MutationTemplate") or "Boss"
							toolsByMut[mId] = toolsByMut[mId] or tool
						end
					end
				end
			end
			if not next(toolsByMut) then
				return nil
			end
			local cfg = TRex.Config
			local allowedMuts = {}
			for _, label in ipairs(cfg.MutationsToUse or {}) do
				allowedMuts[MUTATION_ID_MAP[label] or label] = true
			end
			local inv = getInventoryEggsTable()
			local specSet = Core.stripEggLabelSet(cfg.MutateTargetEggs)
			local minV = tonumber(cfg.MutateMinValue) or 0
			for uid, rec in pairs(inv) do
				if type(rec) == "table" and rec.Placement then
					local info = Core.computeEggInfo(rec)
					local specOk = (not specSet) or specSet[info.Name] or specSet[info.Category]
					if specOk and info.Value >= minV then
						local curMuts = type(rec.Mutations) == "table" and rec.Mutations or {}
						for mId, tool in pairs(toolsByMut) do
							if allowedMuts[mId] and not curMuts[mId] and (MutateBadUntil[uid .. mId] or 0) < os.clock() then
								return { uid = uid, mut = mId, tool = tool, pos = getPlacedEggWorldPos(uid, rec), name = info.Name }
							end
						end
					end
				end
			end
			return nil
		end,
		Run = function(work, shouldContinue)
			if work.pos then
				Core.walkTo(work.pos + Vector3.new(0, 3, 4), shouldContinue, 0.95)
			end
			local hum = Core.getHumanoid()
			if hum and work.tool then
				pcall(hum.EquipTool, hum, work.tool)
				task.wait(0.15)
			end
			local okM = Core.invokeServerBoolean("RF/BossMastery/AskUseMutationConsumable", work.uid)
			if not okM then
				MutateBadUntil[work.uid .. work.mut] = os.clock() + 25
			else
				UI.notify("notif.done", "กลายพันธุ์ " .. tostring(work.name) .. " สำเร็จ", 2)
			end
		end,
	})
end

-- Auto Fuse Machine
local function registerFuseryTask()
	Core.registerTask({
		Name = "Fuse",
		Priority = 11,
		Gap = 3,
		NeedsMover = false,
		On = function()
			return TRex.Config.AutoFusery == true
		end,
		Want = function()
			local save = Core.getSaveData()
			if not save then
				return nil
			end
			if save.FusionLocked and type(save.FusionEggReward) == "table" and TRex.Config.AutoClaimFuse ~= false then
				return { claim = true }
			elseif save.FusionLocked then
				return nil
			end

			local cfg = TRex.Config
			local equipped = {}
			for _, id in ipairs(type(save.EquippedAssets) == "table" and save.EquippedAssets or {}) do
				equipped[id] = true
			end
			local maxRank = Core.RARITY_RANK[cfg.FuseMaxRarity] or 99
			local maxV = tonumber(cfg.FuseMaxValue) or 0
			local specSet = Core.stripEggLabelSet(cfg.FuseSpecificSpecies)

			local pool = {}
			for uid, pet in pairs(getInventoryPetsTable()) do
				if type(pet) == "table" and not pet.IsFavorite and not pet.InFuse and not equipped[uid] then
					local info = Core.computeEggInfo(pet)
					local skipMut = cfg.FuseSkipMutated and info.MutCount > 0
					local specOk = (not specSet) or specSet[info.Name] or specSet[info.Category]
					if not skipMut and specOk and info.RarityRank <= maxRank and (maxV <= 0 or info.Value <= maxV) then
						info.Uid = uid
						table.insert(pool, info)
					end
				end
			end

			if cfg.FuseMode == "Same" then
				local byCat = {}
				for _, p in ipairs(pool) do
					byCat[p.Category] = byCat[p.Category] or {}
					table.insert(byCat[p.Category], p)
				end
				for _, group in pairs(byCat) do
					if #group >= 3 then
						table.sort(group, function(a, b) return a.Value < b.Value end)
						return { uids = { group[1].Uid, group[2].Uid, group[3].Uid }, save = save }
					end
				end
			elseif #pool >= 3 then
				table.sort(pool, function(a, b)
					if a.RarityRank ~= b.RarityRank then
						return a.RarityRank < b.RarityRank
					end
					return a.Value < b.Value
				end)
				return { uids = { pool[1].Uid, pool[2].Uid, pool[3].Uid }, save = save }
			end
			return nil
		end,
		Run = function(work)
			if work.claim then
				Core.invokeRemote("RF/Fusery/FinishReveal")
				emitWebhook("Egg Fused", {})
				return
			end
			local save = work.save
			if save.FusionInfoAcknowledged == false then
				Core.invokeRemote("RF/Fusery/ConfirmBriefing")
				task.wait(0.25)
			end
			local keepMap, loadedMap = {}, {}
			for _, u in ipairs(work.uids) do
				keepMap[u] = true
			end
			for _, oldUid in ipairs(type(save.FusionSlots) == "table" and save.FusionSlots or {}) do
				if keepMap[oldUid] then
					loadedMap[oldUid] = true
				else
					Core.invokeRemote("RF/Fusery/EjectPet", oldUid)
					task.wait(0.25)
				end
			end
			for _, u in ipairs(work.uids) do
				if not loadedMap[u] then
					Core.invokeRemote("RF/Fusery/LoadPet", u)
					task.wait(0.25)
				end
			end
			if TRex.Config.AutoSubmitFuse ~= false then
				Core.invokeRemote("RF/Fusery/BeginFuse")
			end
		end,
	})
end

-- Auto Favorite & Auto Sell Pets/Eggs
local function registerFavoriteAndSellTasks()
	Core.registerTask({
		Name = "Favorite",
		Priority = 13,
		Gap = 3,
		NeedsMover = false,
		On = function()
			return TRex.Config.AutoFavoritePets == true or TRex.Config.AutoFavoriteEggs == true
		end,
		Want = function()
			return true
		end,
		Run = function()
			local cfg = TRex.Config
			if cfg.AutoFavoritePets then
				local save = Core.getSaveData()
				local inv = save and type(save.Inventory) == "table" and save.Inventory or {}
				local reqRank = Core.RARITY_RANK[cfg.FavoriteMinRarity] or 0
				local minV = tonumber(cfg.FavoriteMinValue) or 0
				local favMuts = cfg.FavoriteMutations
				local favSpec = Core.stripEggLabelSet(cfg.AlwaysFavoriteSpecies)
				for uid, pet in pairs(inv) do
					if type(pet) == "table" and not pet.IsFavorite then
						local info = Core.computeEggInfo(pet)
						local mutOk = (type(favMuts) == "table" and #favMuts > 0)
						if mutOk then
							local hasM = false
							for _, m in ipairs(info.Mutations) do
								if table.find(favMuts, m) then
									hasM = true
									break
								end
							end
							mutOk = hasM
						else
							mutOk = false
						end
						local specOk = favSpec ~= nil and (favSpec[info.Name] == true or favSpec[info.Category] == true)
						local rarOk = (cfg.FavoriteMinRarity and cfg.FavoriteMinRarity ~= "Any" and info.RarityRank >= reqRank)
						local valOk = (minV > 0 and info.Value >= minV)
						if specOk or mutOk or rarOk or valOk then
							Core.fireRemote("RE/PetSatchel/WriteFavourite", uid, true)
							task.wait(0.08)
						end
					end
				end
			end
		end,
	})

	Core.registerTask({
		Name = "Sell",
		Priority = 14,
		Gap = 5,
		NeedsMover = false,
		On = function()
			return TRex.Config.AutoSellPets == true or TRex.Config.AutoSellEggs == true
		end,
		Want = function()
			return true
		end,
		Run = function()
			local cfg = TRex.Config
			local save = Core.getSaveData()
			if not save then
				return
			end
			local sellPets, sellEggs = {}, {}

			if cfg.AutoSellPets then
				local equipped = {}
				for _, id in ipairs(type(save.EquippedAssets) == "table" and save.EquippedAssets or {}) do
					equipped[id] = true
				end
				local maxRank = (cfg.SellPetsMinRarity and cfg.SellPetsMinRarity ~= "Any") and (Core.RARITY_RANK[cfg.SellPetsMinRarity] or 99) or 99
				local maxV = tonumber(cfg.SellPetsMaxValue) or 0
				local bl = Core.stripEggLabelSet(cfg.BlacklistSellPets)
				for uid, pet in pairs(getInventoryPetsTable()) do
					if type(pet) == "table" and not pet.InFuse then
						local skipEq = cfg.KeepEquippedPets and equipped[uid]
						local skipFav = cfg.KeepFavoritedPets and pet.IsFavorite
						if not skipEq and not skipFav then
							local info = Core.computeEggInfo(pet)
							local skipMut = cfg.KeepMutatedPets and info.MutCount > 0
							local skipBl = bl and (bl[info.Name] or bl[info.Category])
							if not skipMut and not skipBl and info.RarityRank <= maxRank and (maxV <= 0 or info.Value < maxV) then
								table.insert(sellPets, uid)
							end
						end
					end
				end
			end

			if cfg.AutoSellEggs then
				local thresh = tonumber(cfg.AutoSellEggsThreshold) or 105
				if getInventoryCount() >= thresh then
					local maxV = tonumber(cfg.SellEggsMaxValue) or 0
					local bl = Core.stripEggLabelSet(cfg.BlacklistSellEggs)
					for uid, rec in pairs(getInventoryEggsTable()) do
						if type(rec) == "table" and not rec.Placement and not Farm.isProtected(uid, rec) then
							local info = Core.computeEggInfo(rec)
							local skipMut = cfg.KeepMutatedEggs and info.MutCount > 0
							local skipBl = bl and (bl[info.Name] or bl[info.Category])
							if not skipMut and not skipBl and (maxV <= 0 or info.Value < maxV) then
								table.insert(sellEggs, uid)
							end
						end
					end
				end
			end

			for i = 1, math.max(#sellPets, #sellEggs), 50 do
				local pBatch, eBatch = {}, {}
				for j = i, math.min(i + 49, #sellPets) do
					table.insert(pBatch, sellPets[j])
				end
				for j = i, math.min(i + 49, #sellEggs) do
					table.insert(eBatch, sellEggs[j])
				end
				if #pBatch > 0 or #eBatch > 0 then
					Core.fireRemote("RE/PetSatchel/SellSelection", { Assets = pBatch, Eggs = eBatch })
					task.wait(0.2)
				end
			end
		end,
	})
end

function Farm.buildUI()
	local tab = UI.addTab("farm", "tab.farm", 1)
	local cfg = TRex.Config

	local secSteal = tab:addSection("sec.steal")
	StealStatusRow = secSteal:addText({ key = "_StealStatus", label = "opt.steal_status", text = "-" })
	secSteal:addToggle({ key = "AutoSteal", label = "opt.auto_steal", desc = "desc.auto_steal" })
	secSteal:addToggle({ key = "AntiGuard", label = "opt.anti_guard" })
	secSteal:addToggle({ key = "DropEggsAtSafeZone", label = "opt.drop_safe_zone" })
	secSteal:addToggle({ key = "StealMissingIndex", label = "opt.steal_missing_index" })
	local ddGo = secSteal:addDropdown({ key = "MoveToEgg", label = "opt.steal_go_mode", items = { "Walk", "Teleport" } })
	secSteal:addDropdown({ key = "DeliveryMode", label = "opt.steal_return_mode", items = { "Walk", "Instant Steps", "Fast Tween" } }):When(ddGo, "Walk")
	secSteal:addDropdown({ key = "TeleportDelivery", label = "opt.teleport_delivery", items = { "Walk", "Quick Steps", "Fast Tween" } }):When(ddGo, "Teleport")
	secSteal:addDropdown({ key = "TeleportZones", label = "opt.teleport_zones", items = Core.TELEPORT_ZONES, multi = true }):When(ddGo, "Teleport")
	secSteal:addSlider({ key = "StepCount", label = "opt.step_count", min = 1, max = 6, step = 1 }):When(function()
		return cfg.MoveToEgg == "Walk" and cfg.DeliveryMode == "Instant Steps"
	end)
	secSteal:addSlider({ key = "DeliverySpeed", label = "opt.delivery_speed", min = 80, max = 110, step = 1, suffix = "%" })
	secSteal:addSlider({ key = "FastTweenSpeed", label = "opt.fast_tween_speed", min = 3000, max = 4500, step = 50 }):When(function()
		return (cfg.MoveToEgg == "Walk" and cfg.DeliveryMode == "Fast Tween") or (cfg.MoveToEgg == "Teleport" and cfg.TeleportDelivery == "Fast Tween")
	end)
	secSteal:addDropdown({ key = "StealPriority", label = "opt.steal_sort", items = { "Highest Value", "Biggest", "Best Rarity", "Lowest Value", "Nearest" } })
	secSteal:addDropdown({ key = "StealMinRarity", label = "opt.steal_rarity", items = Core.RARITY_ORDER })
	secSteal:addSlider({ key = "MinStealValue", label = "opt.min_steal_value", log = true })
	secSteal:addDropdown({ key = "RarityMinValue", label = "opt.rarity_min_value", items = { "None", "Cosmic", "Secret", "Eternal", "Divine" } })
	local function showForCap(minCapName)
		return (Core.RARITY_RANK[cfg.RarityMinValue] or 999) <= (Core.RARITY_RANK[minCapName] or 0)
	end
	secSteal:addSlider({ key = "CosmicMinValue", label = "opt.cosmic_min_val", log = true }):When(function() return showForCap("Cosmic") end)
	secSteal:addSlider({ key = "SecretMinValue", label = "opt.secret_min_val", log = true }):When(function() return showForCap("Secret") end)
	secSteal:addSlider({ key = "EternalMinValue", label = "opt.eternal_min_val", log = true }):When(function() return showForCap("Eternal") end)
	secSteal:addSlider({ key = "DivineMinValue", label = "opt.divine_min_val", log = true }):When(function() return showForCap("Divine") end)
	secSteal:addDropdown({ key = "TargetAreas", label = "opt.target_areas", items = Core.AREAS, multi = true })
	secSteal:addDropdown({ key = "TargetSpecificEggs", label = "opt.target_eggs", getItems = Core.eggList, multi = true })
	secSteal:addButton({ label = "btn.warp_safe", onClick = function() Core.setRootCFrame(CFrame.new(Core.getSeparationBouncePos())) end })
	secSteal:addButton({ label = "btn.warp_rift", onClick = function() Core.setRootCFrame(CFrame.new(Core.getRiftMachinePos())) end })

	local secTread = tab:addSection("sec.treadmill")
	secTread:addToggle({ key = "AutoTreadmill", label = "opt.auto_treadmill" })
	secTread:addToggle({ key = "AutoWatchAds", label = "opt.auto_watch_ads" })
	secTread:addToggle({ key = "AdminTreadmill", label = "opt.admin_treadmill" })
	local tgRot = secTread:addToggle({ key = "RotateFishingAndTreadmill", label = "opt.rotate_tread_fish" })
	local ddRot = secTread:addDropdown({ key = "RotationSwitch", label = "opt.rotation_switch", items = { "Every Day", "Timer", "By Event" } }):When(tgRot, true)
	secTread:addSlider({ key = "TreadmillMinutes", label = "opt.treadmill_minutes", min = 1, max = 120, step = 1 }):When(function() return cfg.RotateFishingAndTreadmill and cfg.RotationSwitch == "Timer" end)
	secTread:addSlider({ key = "FishingMinutes", label = "opt.fishing_minutes", min = 1, max = 120, step = 1 }):When(function() return cfg.RotateFishingAndTreadmill and cfg.RotationSwitch == "Timer" end)
	local _ = ddRot

	local secProg = tab:addSection("sec.progression")
	secProg:addToggle({ key = "AutoClaimMoney", label = "opt.auto_away" })
	secProg:addToggle({ key = "AutoClaimIndex", label = "opt.auto_codex" })
	secProg:addToggle({ key = "AutoBuyTrail", label = "opt.auto_buy_trail" })
	secProg:addToggle({ key = "AutoUpgradeTreadmill", label = "opt.auto_treadmill_tier" })
	secProg:addToggle({ key = "AutoUpgradeBase", label = "opt.auto_upgrade_base" })

	local secKeep = tab:addSection("sec.keep_eggs")
	local tgKeep = secKeep:addToggle({ key = "KeepEggs", label = "opt.keep_eggs" })
	secKeep:addDropdown({ key = "KeepEggsSort", label = "opt.keep_eggs_sort", items = { "Highest Value", "Best Rarity", "Biggest" } }):When(tgKeep, true)
	secKeep:addDropdown({ key = "KeepEggsMinRarity", label = "opt.keep_eggs_rarity", items = Core.RARITY_ORDER }):When(tgKeep, true)
	secKeep:addSlider({ key = "KeepEggsMinValue", label = "opt.keep_eggs_value", log = true }):When(tgKeep, true)

	local secPlace = tab:addSection("sec.place_egg")
	local tgPlace = secPlace:addToggle({ key = "AutoPlaceEgg", label = "opt.auto_place_egg" })
	secPlace:addToggle({ key = "PlaceMissingIndex", label = "opt.place_missing_index" })
	secPlace:addDropdown({ key = "PlaceEggRule", label = "opt.place_rule", items = { "Always", "Steal is idle", "Right after a steal", "Only at night" } }):When(tgPlace, true)
	secPlace:addDropdown({ key = "PlaceEggOrder", label = "opt.place_order", items = { "Highest Value", "Biggest Size", "Best Rarity", "Lowest Value", "Smallest Size", "Backpack" } }):When(tgPlace, true)
	secPlace:addDropdown({ key = "PlaceRarities", label = "opt.place_rarities", items = Core.RARITY_ORDER, multi = true }):When(tgPlace, true)
	secPlace:addDropdown({ key = "PlaceSpecificEggs", label = "opt.place_eggs", getItems = Core.eggList, multi = true }):When(tgPlace, true)
	secPlace:addSlider({ key = "MinPlaceValue", label = "opt.min_place_value", log = true }):When(tgPlace, true)
	secPlace:addSlider({ key = "MaxPlaceValue", label = "opt.max_place_value", log = true, maxText = "No Limit" }):When(tgPlace, true)

	local secHatch = tab:addSection("sec.hatch_equip")
	local tgHatch = secHatch:addToggle({ key = "AutoHatch", label = "opt.auto_hatch" })
	secHatch:addToggle({ key = "AutoEquipBest", label = "opt.wear_best" })
	secHatch:addDropdown({ key = "HatchMode", label = "opt.hatch_mode", items = { "All Ready", "One By One" } }):When(tgHatch, true)
	secHatch:addDropdown({ key = "HatchSpecificEggs", label = "opt.hatch_eggs", getItems = Core.eggList, multi = true }):When(tgHatch, true)
	secHatch:addSlider({ key = "HatchMinValue", label = "opt.hatch_min_value", log = true }):When(tgHatch, true)

	local secMut = tab:addSection("sec.mutation")
	local tgMut = secMut:addToggle({ key = "AutoMutate", label = "opt.auto_mutate" })
	secMut:addDropdown({ key = "MutationsToUse", label = "opt.mutate_list", items = { "Fractured", "Scrambled", "Enchanted", "Nitro", "Spectral", "Abducted", "Dark Matter" }, multi = true }):When(tgMut, true)
	secMut:addDropdown({ key = "MutateTargetEggs", label = "opt.mutate_eggs", getItems = Core.eggList, multi = true }):When(tgMut, true)
	secMut:addSlider({ key = "MutateMinValue", label = "opt.mutate_min_value", log = true }):When(tgMut, true)

	local secFuse = tab:addSection("sec.fusery")
	local tgFuse = secFuse:addToggle({ key = "AutoFusery", label = "opt.auto_fusery" })
	secFuse:addDropdown({ key = "FuseMode", label = "opt.fuse_mode", items = { "Any", "Same" } }):When(tgFuse, true)
	secFuse:addDropdown({ key = "FuseMaxRarity", label = "opt.fuse_max_rarity", items = Core.RARITY_ORDER }):When(tgFuse, true)
	secFuse:addToggle({ key = "FuseSkipMutated", label = "opt.fuse_skip_mutated" }):When(tgFuse, true)
	secFuse:addDropdown({ key = "FuseSpecificSpecies", label = "opt.fuse_species", getItems = Core.eggList, multi = true }):When(tgFuse, true)
	secFuse:addSlider({ key = "FuseMaxValue", label = "opt.fuse_max_value", log = true }):When(tgFuse, true)
	secFuse:addToggle({ key = "AutoSubmitFuse", label = "opt.fuse_submit" }):When(tgFuse, true)
	secFuse:addToggle({ key = "AutoClaimFuse", label = "opt.fuse_claim" }):When(tgFuse, true)

	local secFav = tab:addSection("sec.favorite")
	local tgFavP = secFav:addToggle({ key = "AutoFavoritePets", label = "opt.fav_pets" })
	secFav:addToggle({ key = "AutoFavoriteEggs", label = "opt.fav_eggs" })
	secFav:addDropdown({ key = "FavoriteMinRarity", label = "opt.fav_min_rarity", items = Core.RARITY_ORDER }):When(tgFavP, true)
	secFav:addSlider({ key = "FavoriteMinValue", label = "opt.fav_min_value", log = true }):When(tgFavP, true)
	secFav:addDropdown({ key = "FavoriteMutations", label = "opt.fav_mutations", items = { "Golden", "Silver", "Sakura", "GreatBloom", "Boss", "Monstrous", "Scrambled", "Rainbow", "Prismatic", "Alien", "DarkMatter" }, multi = true }):When(tgFavP, true)
	secFav:addDropdown({ key = "AlwaysFavoriteSpecies", label = "opt.fav_species", getItems = Core.eggList, multi = true }):When(tgFavP, true)

	local secSell = tab:addSection("sec.sell")
	local tgSellP = secSell:addToggle({ key = "AutoSellPets", label = "opt.auto_sell" })
	secSell:addDropdown({ key = "SellPetsMinRarity", label = "opt.sell_pets_rarity", items = Core.RARITY_ORDER }):When(tgSellP, true)
	secSell:addSlider({ key = "SellPetsMaxValue", label = "opt.sell_pets_max_val", log = true }):When(tgSellP, true)
	secSell:addDropdown({ key = "BlacklistSellPets", label = "opt.sell_pets_blacklist", getItems = Core.eggList, multi = true }):When(tgSellP, true)
	secSell:addToggle({ key = "KeepMutatedPets", label = "opt.keep_mutated_pets" }):When(tgSellP, true)
	secSell:addToggle({ key = "KeepEquippedPets", label = "opt.keep_equipped_pets" }):When(tgSellP, true)
	secSell:addToggle({ key = "KeepFavoritedPets", label = "opt.keep_fav_pets" }):When(tgSellP, true)

	local tgSellE = secSell:addToggle({ key = "AutoSellEggs", label = "opt.auto_sell_eggs" })
	secSell:addSlider({ key = "AutoSellEggsThreshold", label = "opt.sell_eggs_thresh", min = 1, max = 115, step = 1 }):When(tgSellE, true)
	secSell:addSlider({ key = "SellEggsMaxValue", label = "opt.sell_eggs_max_val", log = true }):When(tgSellE, true)
	secSell:addDropdown({ key = "BlacklistSellEggs", label = "opt.sell_eggs_blacklist", getItems = Core.eggList, multi = true }):When(tgSellE, true)
	secSell:addToggle({ key = "KeepMutatedEggs", label = "opt.keep_mutated_eggs" }):When(tgSellE, true)
end

function Farm.startLoop()
	registerStealTask()
	registerTreadmillAndRotation()
	registerProgressionTask()
	registerPlaceEggTask()
	registerHatchAndMutation()
	registerFuseryTask()
	registerFavoriteAndSellTasks()

	task.spawn(function()
		while TRex.IsRunning do
			Core.stepScheduler()
			task.wait(0.1)
		end
	end)
end
