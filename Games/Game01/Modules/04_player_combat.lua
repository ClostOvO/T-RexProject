-- T-RexProject/Games/Game01/Modules/04_player_combat.lua
-- Character Protection (Instant Prompts, Anti-Ragdoll, Anti-Trap, Invisibility + Keybind, Anti-AFK),
-- Movement (Velocity SpeedBoost, Infinite Jump + JumpPower, SafeZone/Rift Warps),
-- Combat (AutoHit 3 modes, HitAura, Weapon Swap, Friend Skip, Hunt/Chase Lead & Sweep).

local TRex = (_G :: any).TRex
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = TRex.Core
local UI = TRex.UI

local Combat = {}
TRex.Combat = Combat

local IGNORE_PROMPT_NAMES = {
	ClaimLostPart = true,
	CatchPrompt = true,
}

local RAGDOLL_STATES = {
	[Enum.HumanoidStateType.Physics] = true,
	[Enum.HumanoidStateType.Ragdoll] = true,
	[Enum.HumanoidStateType.FallingDown] = true,
}

local SavedPromptHold: { [ProximityPrompt]: number } = {}
local DisabledCatchConns: { [any]: boolean } = {}
local SavedTrapTouch: { [BasePart]: boolean } = {}
local FriendCache: { [Player]: boolean } = {}
local ChaseTrack: { [Player]: { s: Vector3, hd: Vector3? } } = {}

local HitStatusRow = nil
local RagdollMod = nil
local DefaultJumpPower: number? = nil
local SeqCounter = 0
local LastSwingAt = 0
local LastScramAt = 0
local LastAuraAt = 0
local SwapClock = 0
local SwapIdx = 1
local SpeedApplied = false
local WasJumping = false
local NextJumpAt = 0
local StarPromptBusy = false
local AntiTrapConn: RBXScriptConnection? = nil
local PromptAddedConn: RBXScriptConnection? = nil
local RagAttrConn: RBXScriptConnection? = nil
local RagRemConn: RBXScriptConnection? = nil

local function setHitStatus(text: string)
	TRex.State.HitStatus = text
	if HitStatusRow and HitStatusRow.Set then
		HitStatusRow:Set(text)
	end
end

local function refreshFriend(plr: Player)
	local lp = Players.LocalPlayer
	if not lp or plr == lp then
		return
	end
	task.spawn(function()
		local ok, res = pcall(lp.IsFriendsWith, lp, plr.UserId)
		if ok then
			FriendCache[plr] = res == true
		end
	end)
end

local function isMeleeBat(tool: Instance): (boolean, number)
	if not tool or not tool:IsA("Tool") then
		return false, 0
	end
	local lower = tool.Name:lower()
	local isScram = lower:find("scrambl", 1, true) ~= nil or tool:GetAttribute("IsScrambler") == true
	if isScram then
		return true, 0
	end
	if tool:GetAttribute("IsBat") == true then
		return true, tonumber(tool:GetAttribute("RangeBonus")) or 0
	end
	if tool:GetAttribute("ItemType") ~= nil or tool:GetAttribute("GearName") ~= nil then
		return false, 0
	end
	if lower:find("bat", 1, true) or lower:find("club", 1, true) or lower:find("hammer", 1, true) or lower:find("sword", 1, true) then
		return true, tonumber(tool:GetAttribute("RangeBonus")) or 0
	end
	return false, 0
end

local function collectMeleeTools(): { { tool: Tool, bonus: number, scram: boolean } }
	local out = {}
	local lp = Players.LocalPlayer
	local char = Core.getCharacter()
	local bp = lp and lp:FindFirstChildOfClass("Backpack")
	for _, parent in ipairs({ char, bp }) do
		if parent then
			for _, child in ipairs(parent:GetChildren()) do
				local ok, bonus = isMeleeBat(child)
				if ok and child:IsA("Tool") then
					local lower = child.Name:lower()
					local isScram = lower:find("scrambl", 1, true) ~= nil or child:GetAttribute("IsScrambler") == true
					table.insert(out, { tool = child, bonus = bonus, scram = isScram })
				end
			end
		end
	end
	table.sort(out, function(a, b)
		if a.scram ~= b.scram then
			return not a.scram
		end
		if a.bonus ~= b.bonus then
			return a.bonus > b.bonus
		end
		return a.tool.Name < b.tool.Name
	end)
	return out
end

function Combat.findBatTool(): (Tool?, number)
	local tools = collectMeleeTools()
	if #tools == 0 then
		return nil, 0
	end
	if TRex.Config.SwapWeapons and #tools >= 2 then
		local now = os.clock()
		if now - SwapClock >= 0.35 then
			SwapClock = now
			SwapIdx = (SwapIdx % math.min(2, #tools)) + 1
		end
		local picked = tools[math.min(SwapIdx, #tools)]
		return picked.tool, picked.bonus
	end
	return tools[1].tool, tools[1].bonus
end

local function computeHitReach(bonus: number?): number
	local mult = Workspace:GetAttribute("DragonEggEventActive") and 2.5 or 1
	return (17 + (tonumber(bonus) or 0)) * mult - 1
end

local function isEligibleTarget(plr: Player, allowRagdolled: boolean?): BasePart?
	local lp = Players.LocalPlayer
	if not plr or plr == lp or plr.Parent ~= Players then
		return nil
	end
	if TRex.Config.SkipFriends and FriendCache[plr] then
		return nil
	end
	local ch = plr.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp or not hrp:IsA("BasePart") or hum.Health <= 0 then
		return nil
	end
	if ch:GetAttribute("IsTrapped") == true or plr:GetAttribute("InBossArena") == true then
		return nil
	end
	if Core.isInSafeZone(hrp.Position) then
		return nil
	end
	if not allowRagdolled and (tonumber(plr:GetAttribute("RagdollEndTime")) or 0) > Core.getServerNow() then
		return nil
	end
	return hrp
end

local function swingAtPlayer(targetPlr: Player, targetRoot: BasePart, batOverride: Tool?)
	if Workspace:GetAttribute("PvPDisabled") == true then
		return
	end
	local bat, bonus = batOverride, 0
	if not bat then
		bat, bonus = Combat.findBatTool()
	else
		local _, b = isMeleeBat(bat)
		bonus = b
	end
	local myRoot = Core.getRoot()
	if not bat or not myRoot or not Core.needBody() then
		return
	end

	local hum = Core.getHumanoid()
	local char = Core.getCharacter()
	if hum and char and bat.Parent ~= char then
		pcall(hum.EquipTool, hum, bat)
	end
	if not char or bat.Parent ~= char then
		return
	end

	local lower = bat.Name:lower()
	local isScram = lower:find("scrambl", 1, true) ~= nil or bat:GetAttribute("IsScrambler") == true
	if isScram then
		if os.clock() - LastScramAt > 0.3 then
			LastScramAt = os.clock()
			pcall(bat.Activate, bat)
		end
		return
	end

	local ping = Core.getPing()
	local reach = computeHitReach(bonus)
	local myLeadPos = myRoot.Position - myRoot.AssemblyLinearVelocity * 0.18
	local predTarget = targetRoot.Position + targetRoot.AssemblyLinearVelocity * ping
	if (predTarget - myLeadPos).Magnitude > reach and (targetRoot.Position - myLeadPos).Magnitude > reach then
		return
	end

	local cdEnd = tonumber(bat:GetAttribute("CooldownEndTime")) or 0
	if Core.getServerNow() < cdEnd - ping * 0.5 then
		return
	end
	if os.clock() - LastSwingAt < math.max(0.12, ping * 1.5) then
		return
	end
	LastSwingAt = os.clock()
	SeqCounter += 1
	local lp = Players.LocalPlayer
	local uid = lp and lp.UserId or 0
	Core.fireRemote("RE/BatSwing/Trigger", targetPlr, ("%d:%d:%d"):format(uid, SeqCounter, math.floor(Core.getServerNow() * 1000)))
	pcall(bat.Activate, bat)
end

function Combat.chaseStep(targetPlr: Player, targetRoot: BasePart, batTool: Tool?)
	local myRoot = Core.getRoot()
	local hum = Core.getHumanoid()
	if not myRoot or not hum or not targetRoot then
		return
	end
	local cfg = TRex.Config
	if cfg.HitTween == false then
		hum.PlatformStand = false
		hum:MoveTo(targetRoot.Position)
		swingAtPlayer(targetPlr, targetRoot, batTool)
		return
	end

	hum.PlatformStand = true
	local dt = 0.0166
	local tr = ChaseTrack[targetPlr]
	if not tr then
		tr = { s = Vector3.zero, hd = nil }
		ChaseTrack[targetPlr] = tr
	end

	local tVelFlat = Vector3.new(targetRoot.AssemblyLinearVelocity.X, 0, targetRoot.AssemblyLinearVelocity.Z)
	tr.s = tr.s:Lerp(tVelFlat, 0.25)
	if tr.s.Magnitude > 1 then
		local nextHd = tr.hd and tr.hd:Lerp(tr.s.Unit, 0.25) or tr.s.Unit
		tr.hd = nextHd.Magnitude > 0.01 and nextHd.Unit or tr.s.Unit
	end

	local spdMag = tr.s.Magnitude
	local toMeFlat = Vector3.new(myRoot.Position.X - targetRoot.Position.X, 0, myRoot.Position.Z - targetRoot.Position.Z)
	local heading = tr.hd or (toMeFlat.Magnitude > 0.1 and toMeFlat.Unit or Vector3.new(0, 0, 1))
	local ping = Core.getPing()
	local leadTime = ping + 0.38 + (tonumber(cfg.HitLead) or -275) / 1000
	local baseAim = targetRoot.Position + tr.s * leadTime + (spdMag > 1 and tr.s.Unit * 3.6 or Vector3.zero)

	local perp = Vector3.new(-heading.Z, 0, heading.X)
	if perp:Dot(myRoot.Position - baseAim) < 0 then
		perp = -perp
	end

	local _, bonus = Combat.findBatTool()
	local reach = computeHitReach(bonus)
	local sweepPct = math.clamp(tonumber(cfg.HitSweep) or 60, 0, 250) / 100
	local sweepAmp = math.max(5, math.min(reach * 0.7, 6 + spdMag * 0.07)) * sweepPct
	local omega = os.clock() * math.pi * 2
	local desiredPos = baseAim
		+ heading * (math.sin(omega / 1.1) * 0.5 + 0.5) * sweepAmp
		+ perp * (spdMag < 35 and 3 or 1.5)
		+ Vector3.new(0, math.sin(omega / 0.8) * 2.5, 0)

	local chaseSpd = math.clamp(tonumber(cfg.HitChaseSpeed) or 400, 100, 1000)
	local maxSpd = math.clamp(tonumber(cfg.HitMaxRange) or 750, 100, 1000)
	local cap = (toMeFlat.Magnitude > 60) and 1000 or math.min(chaseSpd + spdMag, math.max(chaseSpd, maxSpd))

	local vel = tr.s + (desiredPos - myRoot.Position) / math.max(0.12, dt)
	if vel.Magnitude > cap then
		vel = vel.Unit * cap
	end

	local lookDir = Vector3.new(targetRoot.Position.X - myRoot.Position.X, 0, targetRoot.Position.Z - myRoot.Position.Z)
	if lookDir.Magnitude > 0.05 then
		Core.setRootCFrame(CFrame.lookAt(myRoot.Position, myRoot.Position + lookDir.Unit))
	end
	myRoot.AssemblyLinearVelocity = vel + Vector3.new(0, Workspace.Gravity * dt * 0.5, 0)
	myRoot.AssemblyAngularVelocity = Vector3.zero

	swingAtPlayer(targetPlr, targetRoot, batTool)
end

local function handlePromptInstance(inst: Instance)
	if not inst:IsA("ProximityPrompt") then
		return
	end
	if inst.Name == "CatchPrompt" then
		local getconns = TRex.resolveGlobalFunc("getconnections")
		if getconns then
			local ok, conns = pcall(getconns, inst.PromptButtonHoldEnded)
			if ok and type(conns) == "table" then
				for _, conn in ipairs(conns) do
					if not DisabledCatchConns[conn] and type(conn.Disable) == "function" then
						DisabledCatchConns[conn] = true
						pcall(conn.Disable, conn)
					end
				end
			end
		end
		if not StarPromptBusy then
			StarPromptBusy = true
			task.spawn(function()
				local ok, st = Core.invokeRemote("RF/ShootingStar/AskState")
				if ok and type(st) == "table" and st.Id then
					local dur = (tonumber(st.HoldSeconds) or 1.6) + 0.3
					local t0 = os.clock()
					local okDist = true
					while os.clock() - t0 < dur do
						local root = Core.getRoot()
						local parent = inst.Parent
						if not root or not parent or not parent:IsA("BasePart") or (root.Position - parent.Position).Magnitude > inst.MaxActivationDistance + 2 then
							okDist = false
							break
						end
						task.wait(0.1)
					end
					if okDist then
						Core.fireRemote("RE/ShootingStar/Catch", st.Id)
					else
						Core.fireRemote("RE/ShootingStar/Hold", st.Id, false)
					end
				end
				StarPromptBusy = false
			end)
		end
	elseif inst.HoldDuration > 0 and not IGNORE_PROMPT_NAMES[inst.Name] then
		if SavedPromptHold[inst] == nil then
			SavedPromptHold[inst] = inst.HoldDuration
		end
		inst.HoldDuration = 0
	end
end

local function applyInstantPrompts(enabled: boolean)
	if PromptAddedConn then
		PromptAddedConn:Disconnect()
		PromptAddedConn = nil
	end
	if not enabled then
		for prompt, dur in pairs(SavedPromptHold) do
			if prompt and prompt.Parent then
				pcall(function()
					prompt.HoldDuration = dur
				end)
			end
		end
		table.clear(SavedPromptHold)
		for conn in pairs(DisabledCatchConns) do
			pcall(function()
				if type(conn.Enable) == "function" then
					conn:Enable()
				end
			end)
		end
		table.clear(DisabledCatchConns)
		return
	end

	for _, desc in ipairs(Workspace:GetDescendants()) do
		if desc:IsA("ProximityPrompt") then
			handlePromptInstance(desc)
		end
	end
	PromptAddedConn = Workspace.DescendantAdded:Connect(function(desc)
		if TRex.Config.InstantPrompts and desc:IsA("ProximityPrompt") then
			task.defer(pcall, handlePromptInstance, desc)
		end
	end)
end

local function clearRagdollOnce()
	if Core.isAntiGuardBusy() then
		return
	end
	local char = Core.getCharacter()
	local hum = Core.getHumanoid()
	local root = Core.getRoot()
	if not char or not hum or not root then
		return
	end

	local vel = root.AssemblyLinearVelocity
	local flat = Vector3.new(vel.X, 0, vel.Z)
	local cap = Core.getWalkSpeed() + 5
	if flat.Magnitude > cap then
		flat = flat.Unit * cap
	end
	root.AssemblyLinearVelocity = Vector3.new(flat.X, math.min(vel.Y, 0), flat.Z)

	if type(RagdollMod) == "table" then
		if type(RagdollMod.ClearClientRagdoll) == "function" then
			pcall(RagdollMod.ClearClientRagdoll)
		end
		if type(RagdollMod.Unragdoll) == "function" then
			pcall(RagdollMod.Unragdoll, char)
		end
	end

	for _, d in ipairs(char:GetDescendants()) do
		if d:IsA("BallSocketConstraint") or d:IsA("NoCollisionConstraint") or d:IsA("HingeConstraint") then
			pcall(d.Destroy, d)
		elseif (d:IsA("Motor6D") or d:IsA("AnimationConstraint")) and not d.Enabled then
			d.Enabled = true
		end
	end

	if RAGDOLL_STATES[hum:GetState()] then
		pcall(hum.ChangeState, hum, Enum.HumanoidStateType.Running)
	end
	if not Core.getActiveMover() then
		hum.PlatformStand = false
	end
	if Workspace.CurrentCamera then
		Workspace.CurrentCamera.CameraSubject = hum
	end
end

local function triggerRagdollBurst()
	if not TRex.Config.AntiRagdoll or Core.isAntiGuardBusy() then
		return
	end
	task.spawn(function()
		for _ = 1, 15 do
			if not TRex.Config.AntiRagdoll then
				break
			end
			pcall(clearRagdollOnce)
			task.wait(0.033)
		end
	end)
end

local function applyAntiRagdoll(enabled: boolean)
	if RagAttrConn then
		RagAttrConn:Disconnect()
		RagAttrConn = nil
	end
	if RagRemConn then
		RagRemConn:Disconnect()
		RagRemConn = nil
	end
	if not enabled then
		return
	end
	local lp = Players.LocalPlayer
	if lp then
		RagAttrConn = lp:GetAttributeChangedSignal("RagdollEndTime"):Connect(function()
			if Core.isRagdolled() then
				triggerRagdollBurst()
			end
		end)
	end
	if type(RagdollMod) == "table" and typeof(RagdollMod.ClientRagdollRemote) == "Instance" then
		local rem = RagdollMod.ClientRagdollRemote
		if rem:IsA("RemoteEvent") then
			RagRemConn = rem.OnClientEvent:Connect(triggerRagdollBurst)
		end
	end
end

local function disableTrapPart(trap: Instance)
	local lp = Players.LocalPlayer
	if lp and trap:GetAttribute("Owner") == lp.Name then
		return
	end
	local targets = { trap }
	for _, d in ipairs(trap:GetDescendants()) do
		table.insert(targets, d)
	end
	for _, inst in ipairs(targets) do
		if inst:IsA("BasePart") and inst.CanTouch then
			SavedTrapTouch[inst] = true
			inst.CanTouch = false
		end
	end
end

local function applyAntiTrap(enabled: boolean)
	if AntiTrapConn then
		AntiTrapConn:Disconnect()
		AntiTrapConn = nil
	end
	if not enabled then
		for part in pairs(SavedTrapTouch) do
			if part and part.Parent then
				pcall(function()
					part.CanTouch = true
				end)
			end
		end
		table.clear(SavedTrapTouch)
		return
	end

	AntiTrapConn = CollectionService:GetInstanceAddedSignal("PlacedTrap"):Connect(function(inst)
		if TRex.Config.AntiTrap then
			task.defer(pcall, disableTrapPart, inst)
		end
	end)
	for _, inst in ipairs(CollectionService:GetTagged("PlacedTrap")) do
		pcall(disableTrapPart, inst)
	end
end

local function toggleInvisibility(want: boolean)
	if want and (TRex.Config.AutoHit or TRex.Config.HitAura) then
		TRex.Config.AutoHit = false
		TRex.Config.HitAura = false
		UI.refreshAll()
	end
	Core.setInvisibility(want)
end

local function findNearestTarget(maxDist: number, eggHoldersOnly: boolean): (Player?, BasePart?)
	local myRoot = Core.getRoot()
	if not myRoot then
		return nil, nil
	end
	local holderSet: { [number]: boolean }? = nil
	if eggHoldersOnly then
		local set: { [number]: boolean } = {}
		local farm = TRex.Farm
		local eggs = farm and type(farm.getFieldEggs) == "function" and farm.getFieldEggs() or {}
		for _, rec in pairs(type(eggs) == "table" and eggs or {}) do
			if type(rec) == "table" and rec.State == "Carried" then
				local cid = tonumber(rec.CarrierUserId)
				if cid then
					set[cid] = true
				end
			end
		end
		holderSet = set
	end

	local bestPlr, bestRoot, bestDist = nil, nil, maxDist
	for _, plr in ipairs(Players:GetPlayers()) do
		if not holderSet or holderSet[plr.UserId] then
			local pRoot = isEligibleTarget(plr, false)
			if pRoot then
				local d = (pRoot.Position - myRoot.Position).Magnitude
				if d < bestDist then
					bestDist = d
					bestPlr = plr
					bestRoot = pRoot
				end
			end
		end
	end
	return bestPlr, bestRoot
end

local function findChosenPlayerTarget(): (Player?, BasePart?)
	local query = tostring(TRex.Config.HitTargetPlayer or ""):gsub("^%s+", ""):gsub("%s+$", ""):lower()
	if query == "" then
		return nil, nil
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Name:lower():find(query, 1, true) or plr.DisplayName:lower():find(query, 1, true) then
			local pRoot = isEligibleTarget(plr, false)
			if pRoot then
				return plr, pRoot
			end
		end
	end
	return nil, nil
end

local function pickCombatTarget(): (Player?, BasePart?)
	local mode = tostring(TRex.Config.HitMode or "Egg Holders"):lower()
	if mode:find("chosen", 1, true) then
		return findChosenPlayerTarget()
	elseif mode:find("holder", 1, true) then
		return findNearestTarget(math.huge, true)
	else
		return findNearestTarget(math.huge, false)
	end
end

local function registerCombatTask()
	Core.registerTask({
		Name = "Combat",
		Priority = 7,
		Gap = 0.25,
		NeedsMover = true,
		On = function()
			return TRex.Config.AutoHit == true and not TRex.Config.Invisibility
		end,
		Want = function()
			if Workspace:GetAttribute("PvPDisabled") == true then
				setHitStatus("เซิร์ฟเวอร์ปิดการต่อสู้ชั่วคราว")
				return nil
			end
			local bat = Combat.findBatTool()
			if not bat then
				setHitStatus("ไม่พบไม้เบสบอลหรืออาวุธ")
				return nil
			end
			local plr, root = pickCombatTarget()
			if not plr or not root then
				setHitStatus("กำลังมองหาเป้าหมาย")
				return nil
			end
			return { plr = plr, root = root }
		end,
		Run = function(job, shouldContinue)
			local targetPlr: Player = job.plr
			if not Core.needBody() then
				return
			end
			while shouldContinue() and TRex.Config.AutoHit and not TRex.Config.Invisibility do
				local tRoot = isEligibleTarget(targetPlr, true)
				local bat = Combat.findBatTool()
				if not tRoot or not bat then
					break
				end
				setHitStatus("กำลังไล่ตี " .. tostring(targetPlr.DisplayName))
				Combat.chaseStep(targetPlr, tRoot, bat)
				RunService.Heartbeat:Wait()
			end
			local hum = Core.getHumanoid()
			if hum and not Core.getActiveMover() then
				hum.PlatformStand = false
			end
			setHitStatus("รอ / พัก")
		end,
	})
end

function Combat.restoreCharacterStats()
	local hum = Core.getHumanoid()
	if hum then
		hum.PlatformStand = false
		hum.AutoRotate = true
		if DefaultJumpPower then
			pcall(function()
				hum.JumpPower = DefaultJumpPower
			end)
		end
	end
	local root = Core.getRoot()
	if root and SpeedApplied then
		SpeedApplied = false
		pcall(function()
			root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
		end)
	end
	applyInstantPrompts(false)
	applyAntiRagdoll(false)
	applyAntiTrap(false)
	if Core.isInvisible() then
		Core.setInvisibility(false)
	end
	Core.restoreAntiAFK()
end

function Combat.init()
	local shared = ReplicatedStorage:FindFirstChild("Shared")
	local mods = shared and shared:FindFirstChild("Modules")
	local ragMod = mods and mods:FindFirstChild("Ragdoll")
	if ragMod and ragMod:IsA("ModuleScript") then
		local ok, m = pcall(require, ragMod)
		if ok then
			RagdollMod = m
		end
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		refreshFriend(plr)
	end
	TRex.connectSignal(Players.PlayerAdded, refreshFriend)
	TRex.connectSignal(Players.PlayerRemoving, function(plr)
		FriendCache[plr] = nil
		ChaseTrack[plr] = nil
	end)

	TRex.connectSignal(UserInputService.InputBegan, function(input, processed)
		if processed then
			return
		end
		local bindName = tostring(TRex.Config.InvisibilityKey or "None")
		if bindName ~= "None" and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == bindName then
			local nextVal = not TRex.Config.Invisibility
			TRex.Config.Invisibility = nextVal
			toggleInvisibility(nextVal)
			UI.refreshAll()
		end
	end)

	local lp = Players.LocalPlayer
	if lp then
		TRex.connectSignal(lp.CharacterAdded, function()
			DefaultJumpPower = nil
			task.delay(0.8, function()
				if TRex.IsRunning and TRex.Config.AntiAFK then
					Core.applyAntiAFK(true)
				end
			end)
		end)
	end

	TRex.registerCleanupHook(Combat.restoreCharacterStats)
end

function Combat.buildUI(ui)
	local tab = ui.addTab("combat", "tab.combat", 3)

	local secChar = tab:addSection("sec.character")
	secChar:addToggle({
		key = "InstantPrompts",
		label = "opt.instant_prompts",
		onChanged = function(val)
			applyInstantPrompts(val == true)
		end,
	})
	secChar:addToggle({
		key = "AntiRagdoll",
		label = "opt.anti_ragdoll",
		onChanged = function(val)
			applyAntiRagdoll(val == true)
		end,
	})
	secChar:addToggle({
		key = "AntiTrap",
		label = "opt.anti_trap",
		onChanged = function(val)
			applyAntiTrap(val == true)
		end,
	})
	local tgInvis = secChar:addToggle({
		key = "Invisibility",
		label = "opt.invisibility",
		onChanged = function(val)
			toggleInvisibility(val == true)
		end,
	})
	secChar:addKeybindPicker({ key = "InvisibilityKey", label = "opt.invis_key" }):When(tgInvis, true)
	secChar:addToggle({
		key = "AntiAFK",
		label = "opt.anti_afk",
		onChanged = function(val)
			Core.applyAntiAFK(val ~= false)
		end,
	})

	local secMove = tab:addSection("sec.movement")
	local tgSpeed = secMove:addToggle({
		key = "SpeedBoost",
		label = "opt.custom_speed",
		onChanged = function(val)
			if not val then
				local root = Core.getRoot()
				if root and SpeedApplied then
					SpeedApplied = false
					root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
				end
			end
		end,
	})
	secMove:addSlider({ key = "BoostSpeed", label = "opt.walk_speed", min = 20, max = 1000, step = 5, suffix = " studs/s" }):When(tgSpeed, true)
	local tgJump = secMove:addToggle({
		key = "InfiniteJump",
		label = "opt.infinite_jump",
		onChanged = function(val)
			if not val and DefaultJumpPower then
				local hum = Core.getHumanoid()
				if hum then
					hum.JumpPower = DefaultJumpPower
				end
			end
		end,
	})
	secMove:addSlider({ key = "JumpPowerValue", label = "opt.jump_power", min = 20, max = 300, step = 5 }):When(tgJump, true)
	secMove:addButton({
		label = "btn.warp_safe",
		primary = true,
		onClick = function()
			Core.setRootCFrame(CFrame.new(Core.getSeparationBouncePos()))
		end,
	})
	secMove:addButton({
		label = "btn.warp_rift",
		onClick = function()
			Core.setRootCFrame(CFrame.new(Core.getRiftMachinePos()))
		end,
	})

	local secCombat = tab:addSection("sec.combat")
	HitStatusRow = secCombat:addText({ key = "_HitStatus", label = "สถานะการโจมตี", text = "รอ / พัก" })
	local tgHit = secCombat:addToggle({
		key = "AutoHit",
		label = "opt.auto_hit",
		onChanged = function(val)
			if val and TRex.Config.Invisibility then
				TRex.Config.Invisibility = false
				Core.setInvisibility(false)
				UI.refreshAll()
			end
		end,
	})
	local ddHitMode = secCombat:addDropdown({
		key = "HitMode",
		label = "opt.hit_mode",
		items = { "Egg Holders", "Nearest Player", "Chosen Player" },
	}):When(tgHit, true)
	secCombat:addTextInput({
		key = "HitTargetPlayer",
		label = "opt.hit_player",
		placeholderKey = "msg.player_placeholder",
	}):When(function()
		return TRex.Config.AutoHit == true and tostring(TRex.Config.HitMode) == "Chosen Player"
	end)
	local _ = ddHitMode
	secCombat:addToggle({
		key = "HitAura",
		label = "opt.hit_aura",
		onChanged = function(val)
			if val and TRex.Config.Invisibility then
				TRex.Config.Invisibility = false
				Core.setInvisibility(false)
				UI.refreshAll()
			end
		end,
	})
	secCombat:addToggle({ key = "SwapWeapons", label = "opt.swap_weapons" })
	secCombat:addToggle({ key = "SkipFriends", label = "opt.skip_friends" })
	secCombat:addToggle({ key = "HitTween", label = "opt.hit_tween" })
	secCombat:addSlider({ key = "HitMaxRange", label = "opt.hit_max_range", min = 100, max = 1000, step = 10, suffix = " studs/s" })
	secCombat:addSlider({ key = "HitChaseSpeed", label = "opt.hit_chase_speed", min = 100, max = 1000, step = 10, suffix = " studs/s" })
	secCombat:addSlider({ key = "HitLead", label = "opt.hit_lead", min = -400, max = 100, step = 5 })
	secCombat:addSlider({ key = "HitSweep", label = "opt.hit_sweep", min = 0, max = 250, step = 5, suffix = "%" })
end

function Combat.startLoop()
	local cfg = TRex.Config
	applyInstantPrompts(cfg.InstantPrompts == true)
	applyAntiRagdoll(cfg.AntiRagdoll == true)
	applyAntiTrap(cfg.AntiTrap == true)
	Core.applyAntiAFK(cfg.AntiAFK ~= false)
	if cfg.Invisibility then
		Core.setInvisibility(true)
	end

	registerCombatTask()

	TRex.connectSignal(RunService.Heartbeat, function()
		if not TRex.IsRunning then
			return
		end
		local c = TRex.Config
		local hum = Core.getHumanoid()
		local root = Core.getRoot()
		if not hum or not root then
			return
		end
		if not DefaultJumpPower then
			DefaultJumpPower = hum.JumpPower
		end

		-- SpeedBoost velocity glide (respect active scheduler mover)
		if c.SpeedBoost and not Core.getActiveMover() and not root.Anchored then
			local dir = hum.MoveDirection
			if dir.Magnitude > 0.1 then
				local boost = math.clamp(tonumber(c.BoostSpeed) or 65, 20, 1000)
				root.AssemblyLinearVelocity = Vector3.new(dir.X, 0, dir.Z).Unit * boost + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
				SpeedApplied = true
			elseif SpeedApplied then
				root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
				SpeedApplied = false
			end
		elseif SpeedApplied then
			SpeedApplied = false
		end

		-- Infinite Jump + JumpPower
		local jumping = hum.Jump
		if c.InfiniteJump then
			local jp = math.clamp(tonumber(c.JumpPowerValue) or 50, 20, 300)
			if math.abs(hum.JumpPower - jp) > 0.5 then
				hum.JumpPower = jp
			end
			if jumping and (not WasJumping or os.clock() > NextJumpAt) then
				NextJumpAt = os.clock() + 0.25
				if root.Anchored and not Core.getActiveMover() then
					pcall(Core.invokeNS, "Treadmill", "AskDoff")
				elseif not root.Anchored then
					pcall(hum.ChangeState, hum, Enum.HumanoidStateType.Jumping)
				end
			end
		end
		WasJumping = jumping

		-- Invisibility AutoRotate facing
		local char = Core.getCharacter()
		if char and (Core.isInvisible() or char:GetAttribute("InvisApplied") == true) then
			if Core.getActiveMover() or root.Anchored then
				hum.AutoRotate = true
			elseif hum.MoveDirection.Magnitude > 0.1 then
				hum.AutoRotate = false
				root.CFrame = CFrame.lookAt(root.Position, root.Position + hum.MoveDirection)
			else
				hum.AutoRotate = true
			end
		end

		-- Hit Aura when no higher priority mover is active
		if c.HitAura and not c.Invisibility and os.clock() - LastAuraAt >= 0.06 then
			local mv = Core.getActiveMover()
			if not mv or (mv ~= "Steal" and mv ~= "Bloom" and mv ~= "Capture") then
				LastAuraAt = os.clock()
				local bat, bonus = Combat.findBatTool()
				if bat then
					local plr, pRoot = findNearestTarget(computeHitReach(bonus) + 6, false)
					if plr and pRoot then
						swingAtPlayer(plr, pRoot, bat)
					end
				end
			end
		end
	end)

	task.spawn(function()
		while TRex.IsRunning do
			if TRex.Config.AntiAFK ~= false then
				Core.applyAntiAFK(true)
			end
			task.wait(60)
		end
	end)
end

return Combat
