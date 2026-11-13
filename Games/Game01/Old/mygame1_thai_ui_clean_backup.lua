--!strict
-- ระบบช่วยเล่นครบวงจร ออกแบบสะอาดตา ภาษาไทยล้วน ไม่มีแผงแยกซ้อนทับ

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local TeleportService = game:GetService("TeleportService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local StatsService = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")

local okVU, VirtualUser = pcall(function()
	return game:GetService("VirtualUser")
end)
if not okVU then
	VirtualUser = nil :: any
end

local LocalPlayer = Players.LocalPlayer :: Player
local ExecEnv: { [string]: any } = (type(getgenv) == "function" and getgenv()) or (_G :: any)

if type(ExecEnv.__MYGAME1_THAI_UI_CLEANUP) == "function" then
	pcall(ExecEnv.__MYGAME1_THAI_UI_CLEANUP)
end

-- ตัวช่วยคำสั่งระดับตัวรันพร้อมระบบป้องกันความผิดพลาด
local Exec = {}
do
	local function fnOf(name: string): ((...any) -> ...any)?
		local v = ExecEnv[name]
		if type(v) == "function" then
			return v
		end
		return nil
	end

	Exec.hookMeta = fnOf("hookmetamethod") or (type(hookmetamethod) == "function" and hookmetamethod :: any) or nil
	Exec.getMethod = fnOf("getnamecallmethod") or (type(getnamecallmethod) == "function" and getnamecallmethod :: any) or nil
	Exec.isCaller = fnOf("checkcaller") or (type(checkcaller) == "function" and checkcaller :: any) or nil
	Exec.getConns = fnOf("getconnections") or (type(getconnections) == "function" and getconnections :: any) or nil
	Exec.firePrompt = fnOf("fireproximityprompt") or (type(fireproximityprompt) == "function" and fireproximityprompt :: any) or nil
	Exec.fireTouch = fnOf("firetouchinterest") or (type(firetouchinterest) == "function" and firetouchinterest :: any) or nil
	Exec.setFps = fnOf("setfpscap") or (type(setfpscap) == "function" and setfpscap :: any) or nil
	Exec.readFile = fnOf("readfile") or (type(readfile) == "function" and readfile :: any) or nil
	Exec.writeFile = fnOf("writefile") or (type(writefile) == "function" and writefile :: any) or nil
	Exec.isFile = fnOf("isfile") or (type(isfile) == "function" and isfile :: any) or nil
	Exec.makeFolder = fnOf("makefolder") or (type(makefolder) == "function" and makefolder :: any) or nil
	Exec.isFolder = fnOf("isfolder") or (type(isfolder) == "function" and isfolder :: any) or nil
	Exec.getHui = fnOf("gethui") or (type(gethui) == "function" and gethui :: any) or nil
end

local Runtime = {
	Running = true,
	Connections = {} :: { RBXScriptConnection },
	Cleanups = {} :: { () -> () },
	WindowOpen = true,
	CurrentTab = "ออโต้และฟาร์ม",
	StatusText = "พร้อมใช้งานเต็มระบบ",
	StatusState = "idle",
	StatusProgress = 0,
	LastActionAt = 0,
	BlockedStrikes = 0,
	EquipRevision = 0,
	CarryRevision = 0,
	LastCarryState = nil :: any,
	FieldResetting = false,
	FieldClosesAt = nil :: number?,
	FieldResetDay = nil :: number?,
	OnTreadmill = false,
	ManualTreadmillStop = false,
	IsChasingCarrier = false,
	StaffDetected = {} :: { [number]: string },
	LastStaffAlertAt = 0,
	OrigNamecall = nil :: any,
	HookInstalled = false,
}

local function trackConn(signal: RBXScriptSignal, cb: (...any) -> ()): RBXScriptConnection
	local conn = signal:Connect(function(...)
		if not Runtime.Running then
			return
		end
		cb(...)
	end)
	table.insert(Runtime.Connections, conn)
	return conn
end

local function onCleanup(fn: () -> ())
	table.insert(Runtime.Cleanups, fn)
end

local function getChar(): Model?
	return LocalPlayer and LocalPlayer.Character or nil
end

local function getRoot(): BasePart?
	local char = getChar()
	if not char then
		return nil
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp and hrp:IsA("BasePart") then
		return hrp
	end
	return nil
end

local function getHum(): Humanoid?
	local char = getChar()
	if not char then
		return nil
	end
	local h = char:FindFirstChildOfClass("Humanoid")
	return h
end

local function getGuiParent(): Instance
	if Exec.getHui then
		local ok, hui = pcall(Exec.getHui)
		if ok and typeof(hui) == "Instance" then
			return hui
		end
	end
	local okCG, cg = pcall(function()
		return CoreGui:FindFirstChild("RobloxGui") or CoreGui
	end)
	if okCG and typeof(cg) == "Instance" then
		return CoreGui
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

-- ข้อมูลภาษาไทยล้วนสำหรับธีม ฟอนต์ พื้นที่ ความหายาก การกลายพันธุ์ และคีย์ลัด
local Data = {}

Data.Themes = {
	["ชมพูซากุระ"] = {
		Bg = Color3.fromRGB(11, 9, 14),
		Sidebar = Color3.fromRGB(17, 14, 20),
		Header = Color3.fromRGB(17, 14, 20),
		Card = Color3.fromRGB(24, 19, 30),
		CardHover = Color3.fromRGB(34, 27, 42),
		Border = Color3.fromRGB(54, 42, 64),
		Accent = Color3.fromRGB(255, 92, 141),
		AccentDark = Color3.fromRGB(190, 56, 98),
		Text = Color3.fromRGB(247, 240, 245),
		SubText = Color3.fromRGB(175, 158, 173),
		Success = Color3.fromRGB(72, 224, 152),
		Warning = Color3.fromRGB(255, 186, 73),
		Danger = Color3.fromRGB(248, 86, 108),
	},
	["ดาร์กไซเบอร์"] = {
		Bg = Color3.fromRGB(9, 12, 18),
		Sidebar = Color3.fromRGB(13, 18, 28),
		Header = Color3.fromRGB(13, 18, 28),
		Card = Color3.fromRGB(18, 25, 38),
		CardHover = Color3.fromRGB(26, 36, 54),
		Border = Color3.fromRGB(40, 58, 84),
		Accent = Color3.fromRGB(56, 208, 255),
		AccentDark = Color3.fromRGB(28, 138, 185),
		Text = Color3.fromRGB(238, 246, 255),
		SubText = Color3.fromRGB(148, 168, 194),
		Success = Color3.fromRGB(68, 226, 160),
		Warning = Color3.fromRGB(255, 192, 74),
		Danger = Color3.fromRGB(250, 92, 112),
	},
	["อเมทิสต์"] = {
		Bg = Color3.fromRGB(12, 9, 18),
		Sidebar = Color3.fromRGB(18, 13, 27),
		Header = Color3.fromRGB(18, 13, 27),
		Card = Color3.fromRGB(26, 19, 39),
		CardHover = Color3.fromRGB(36, 27, 54),
		Border = Color3.fromRGB(64, 48, 92),
		Accent = Color3.fromRGB(176, 110, 255),
		AccentDark = Color3.fromRGB(122, 68, 196),
		Text = Color3.fromRGB(246, 240, 255),
		SubText = Color3.fromRGB(174, 158, 202),
		Success = Color3.fromRGB(76, 224, 164),
		Warning = Color3.fromRGB(255, 194, 82),
		Danger = Color3.fromRGB(246, 92, 118),
	},
	["มรกตเข้ม"] = {
		Bg = Color3.fromRGB(8, 14, 12),
		Sidebar = Color3.fromRGB(12, 21, 18),
		Header = Color3.fromRGB(12, 21, 18),
		Card = Color3.fromRGB(17, 29, 25),
		CardHover = Color3.fromRGB(24, 41, 35),
		Border = Color3.fromRGB(40, 68, 58),
		Accent = Color3.fromRGB(58, 224, 152),
		AccentDark = Color3.fromRGB(32, 162, 108),
		Text = Color3.fromRGB(238, 252, 245),
		SubText = Color3.fromRGB(148, 184, 168),
		Success = Color3.fromRGB(88, 240, 172),
		Warning = Color3.fromRGB(255, 196, 78),
		Danger = Color3.fromRGB(248, 92, 108),
	},
	["เพลิงส้ม"] = {
		Bg = Color3.fromRGB(14, 10, 9),
		Sidebar = Color3.fromRGB(22, 15, 13),
		Header = Color3.fromRGB(22, 15, 13),
		Card = Color3.fromRGB(30, 20, 17),
		CardHover = Color3.fromRGB(42, 28, 24),
		Border = Color3.fromRGB(74, 46, 38),
		Accent = Color3.fromRGB(255, 132, 56),
		AccentDark = Color3.fromRGB(196, 86, 28),
		Text = Color3.fromRGB(255, 244, 238),
		SubText = Color3.fromRGB(194, 164, 150),
		Success = Color3.fromRGB(80, 224, 156),
		Warning = Color3.fromRGB(255, 204, 84),
		Danger = Color3.fromRGB(252, 86, 94),
	},
	["กลางคืนเงิน"] = {
		Bg = Color3.fromRGB(12, 13, 16),
		Sidebar = Color3.fromRGB(18, 20, 24),
		Header = Color3.fromRGB(18, 20, 24),
		Card = Color3.fromRGB(25, 28, 34),
		CardHover = Color3.fromRGB(35, 39, 48),
		Border = Color3.fromRGB(58, 64, 78),
		Accent = Color3.fromRGB(214, 222, 238),
		AccentDark = Color3.fromRGB(142, 152, 172),
		Text = Color3.fromRGB(246, 248, 252),
		SubText = Color3.fromRGB(168, 174, 190),
		Success = Color3.fromRGB(82, 224, 158),
		Warning = Color3.fromRGB(255, 198, 86),
		Danger = Color3.fromRGB(248, 92, 108),
	},
}

Data.ThemeNames = {
	"ชมพูซากุระ",
	"ดาร์กไซเบอร์",
	"อเมทิสต์",
	"มรกตเข้ม",
	"เพลิงส้ม",
	"กลางคืนเงิน",
}

Data.Fonts = {
	["ไทยโมเดิร์นหนา"] = Enum.Font.GothamBold,
	["โกธิคอ่านง่าย"] = Enum.Font.GothamMedium,
	["ตัวมนสดใส"] = Enum.Font.FredokaOne,
	["อักษรเรียบคม"] = Enum.Font.SourceSansBold,
	["เส้นโค้งทันสมัย"] = Enum.Font.Nunito,
}

Data.FontNames = {
	"ไทยโมเดิร์นหนา",
	"โกธิคอ่านง่าย",
	"ตัวมนสดใส",
	"อักษรเรียบคม",
	"เส้นโค้งทันสมัย",
}

Data.AreaThaiById = {
	All = "ทุกพื้นที่",
	Volcano = "ภูเขาไฟ",
	Snow = "หิมะน้ำแข็ง",
	Prehistoric = "ดึกดำบรรพ์",
	Lake = "ทะเลสาบ",
	Jungle = "ป่าดงดิบ",
	Forest = "ป่าไม้",
	Desert = "ทะเลทราย",
	Cosmic = "จักรวาล",
	["Cherry Blossom"] = "ซากุระผลิบาน",
	["Abyss Ocean"] = "มหาสมุทรห้วงลึก",
	["Titan Temple"] = "วิหารไททัน",
	["Light Dark"] = "วิถีแสงและเงา",
	["Enchanted Forest"] = "ป่าต้องมนต์",
	Alien = "เอเลี่ยนต่างดาว",
}

Data.RarityList = {
	{ id = "All", name = "ทุกระดับความหายาก", rank = 0, color = Color3.fromRGB(220, 220, 230) },
	{ id = "Common", name = "ธรรมดา", rank = 1, color = Color3.fromRGB(190, 195, 205) },
	{ id = "Uncommon", name = "ไม่ธรรมดา", rank = 2, color = Color3.fromRGB(115, 224, 130) },
	{ id = "Rare", name = "หายาก", rank = 3, color = Color3.fromRGB(84, 174, 255) },
	{ id = "Epic", name = "มหากาพย์", rank = 4, color = Color3.fromRGB(186, 108, 255) },
	{ id = "Legendary", name = "ตำนาน", rank = 5, color = Color3.fromRGB(255, 198, 68) },
	{ id = "Mythic", name = "เทพนิยาย", rank = 6, color = Color3.fromRGB(255, 92, 138) },
	{ id = "Secret", name = "ลับสุดยอด", rank = 7, color = Color3.fromRGB(255, 68, 86) },
	{ id = "Exclusive", name = "พิเศษสุด", rank = 8, color = Color3.fromRGB(74, 245, 232) },
	{ id = "Divine", name = "ศักดิ์สิทธิ์", rank = 9, color = Color3.fromRGB(255, 240, 145) },
}

Data.RarityById = {} :: { [string]: any }
for _, item in ipairs(Data.RarityList) do
	Data.RarityById[item.id] = item
end

Data.MutationThaiById = {
	All = "ทุกการกลายพันธุ์",
	None = "ปกติไม่กลายพันธุ์",
	Gold = "ทองคำ",
	Diamond = "เพชร",
	Rainbow = "สายรุ้ง",
	Emerald = "มรกต",
	Ruby = "ทับทิม",
	Cosmic = "คอสมิก",
	Corrupted = "มืดแปดเปื้อน",
	Scrambled = "สแครมเบิล",
	Sakura = "ซากุระ",
	Ghost = "วิญญาณ",
	Alien = "เอเลี่ยน",
	Spooky = "ฮาโลวีน",
	Lightning = "สายฟ้า",
}

Data.AreaList = {} :: { { id: string, name: string } }
for id, th in pairs(Data.AreaThaiById) do
	table.insert(Data.AreaList, { id = id, name = th })
end
table.sort(Data.AreaList, function(a, b)
	if a.id == "All" then return true end
	if b.id == "All" then return false end
	return a.id < b.id
end)

Data.MutationList = {} :: { { id: string, name: string } }
for id, th in pairs(Data.MutationThaiById) do
	table.insert(Data.MutationList, { id = id, name = th })
end
table.sort(Data.MutationList, function(a, b)
	if a.id == "All" then return true end
	if b.id == "All" then return false end
	return a.id < b.id
end)

Data.SpeciesList = { { id = "All", name = "ทุกสายพันธุ์", order = 0 } } :: { { id: string, name: string, order: number } }
Data.SpeciesById = { All = Data.SpeciesList[1] } :: { [string]: { id: string, name: string, order: number } }

Data.EspColors = {
	["ชมพูซากุระ"] = Color3.fromRGB(255, 92, 141),
	["เขียวมรกต"] = Color3.fromRGB(72, 232, 152),
	["ฟ้าคราม"] = Color3.fromRGB(64, 198, 255),
	["เหลืองทอง"] = Color3.fromRGB(255, 208, 74),
	["ส้มเพลิง"] = Color3.fromRGB(255, 134, 62),
	["ม่วงอเมทิสต์"] = Color3.fromRGB(182, 112, 255),
	["แดงสการ์เล็ต"] = Color3.fromRGB(252, 84, 96),
	["ขาวพิสุทธิ์"] = Color3.fromRGB(246, 248, 255),
}

Data.EspColorNames = {
	"ชมพูซากุระ",
	"เขียวมรกต",
	"ฟ้าคราม",
	"เหลืองทอง",
	"ส้มเพลิง",
	"ม่วงอเมทิสต์",
	"แดงสการ์เล็ต",
	"ขาวพิสุทธิ์",
}

Data.StealSortOrders = {
	{ id = "IncomeHigh", name = "รายได้สูงสุดก่อน" },
	{ id = "Rarity", name = "ความหายากสูงสุดก่อน" },
	{ id = "Mutation", name = "ตัวคูณกลายพันธุ์สูงก่อน" },
	{ id = "Weight", name = "น้ำหนักมากสุดก่อน" },
	{ id = "Distance", name = "ระยะใกล้สุดก่อน" },
	{ id = "IncomeLow", name = "รายได้ต่ำสุดก่อน" },
}

Data.PlaceSortOrders = {
	{ id = "Income", name = "รายได้สูงสุดก่อน" },
	{ id = "Large", name = "ไข่ขนาดใหญ่ก่อน" },
	{ id = "Small", name = "ไข่ขนาดเล็กก่อน" },
	{ id = "Slot", name = "เรียงตามช่องกระเป๋า" },
}

Data.DeliveryModes = {
	"สายฟ้าเหินเวหาเร็วสุด",
	"พักส่งไข่เป็นจังหวะ",
	"เดินถือไข่ความเร็วสูง",
}

Data.OutboundModes = {
	"เหินเวหาข้ามยามอัตโนมัติ",
	"วิ่งบนพื้นความเร็วสูง",
}

Data.FunParts = {
	{ key = "FunHeadScale", name = "หัว", parts = { "Head" } },
	{ key = "FunTorsoScale", name = "ลำตัว", parts = { "UpperTorso", "LowerTorso", "Torso" } },
	{ key = "FunLeftArmScale", name = "แขนซ้าย", parts = { "LeftUpperArm", "LeftLowerArm", "LeftHand", "Left Arm" } },
	{ key = "FunRightArmScale", name = "แขนขวา", parts = { "RightUpperArm", "RightLowerArm", "RightHand", "Right Arm" } },
	{ key = "FunLeftLegScale", name = "ขาซ้าย", parts = { "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "Left Leg" } },
	{ key = "FunRightLegScale", name = "ขาขวา", parts = { "RightUpperLeg", "RightLowerLeg", "RightFoot", "Right Leg" } },
}

local KeyThaiNames: { [string]: string } = {
	[""] = "ยังไม่ตั้งปุ่ม",
	RightControl = "คอนโทรลขวา",
	LeftControl = "คอนโทรลซ้าย",
	RightShift = "ชิฟต์ขวา",
	LeftShift = "ชิฟต์ซ้าย",
	RightAlt = "อัลท์ขวา",
	LeftAlt = "อัลท์ซ้าย",
	Insert = "อินเสิร์ต",
	Home = "โฮม",
	End = "เอนด์",
	PageUp = "เพจอัพ",
	PageDown = "เพจดาวน์",
	Tab = "แท็บ",
	Space = "สเปซบาร์",
	Backquote = "ปุ่มเปลี่ยนภาษา",
}

function Data.getKeyThaiName(codeName: string?): string
	if not codeName or codeName == "" then
		return "ยังไม่ตั้งปุ่ม"
	end
	if KeyThaiNames[codeName] then
		return KeyThaiNames[codeName]
	end
	if #codeName == 1 then
		return "ปุ่ม " .. string.upper(codeName)
	end
	if string.sub(codeName, 1, 1) == "F" and tonumber(string.sub(codeName, 2)) then
		return "ปุ่ม " .. codeName
	end
	return "ปุ่ม " .. codeName
end

function Data.createDefaultConfig(): { [string]: any }
	return {
		-- โหมดเล่นอัตโนมัติครบวงจร & ฟาร์ม
		FullAutoPlay = false,
		FullAutoIncludeEvents = true,
		AutoStealEgg = false,
		DeliveryMethod = "สายฟ้าเหินเวหาเร็วสุด",
		StealOutboundMode = "เหินเวหาข้ามยามอัตโนมัติ",
		StealGoSpeed = 140,
		StealReturnStride = 28,
		StealReturnCadence = 0.065,
		StealDeliverySteps = 3,
		StealCarrySpeed = 160,
		StealOnlyMissingIndex = false,
		StealOnlyMissingLab = false,
		StealOrder = "IncomeHigh",
		StealAreas = {} :: { [string]: boolean },
		StealRarities = {} :: { [string]: boolean },
		StealMutations = {} :: { [string]: boolean },
		StealSpecies = {} :: { [string]: boolean },
		StealMinRarity = "All",
		StealMinIncome = 0,

		AutoPlaceEgg = false,
		PlaceEggRule = "วางทันทีเมื่อมีไข่",
		PlaceOrder = "Income",
		PlaceRarities = {} :: { [string]: boolean },
		PlaceSpecies = {} :: { [string]: boolean },
		PlaceMinIncome = 0,
		AutoHatchEgg = false,
		AutoSkipGrowth = false,
		AutoTreadmill = false,
		TreadmillRunSeconds = 20,
		TreadmillRestSeconds = 4,
		AutoEquipBest = false,
		AutoSellPet = false,
		SellMode = "ไม่ขายตัวที่ใส่และตัวเก่ง",
		AutoFusion = false,
		AutoUpgradeBase = false,
		AutoUpgradeTreadmill = false,
		AutoBuyTrail = false,

		-- กิจกรรมและเควสอัตโนมัติ
		AutoClaimReward = false,
		AutoPetWheel = false,
		AutoFishing = false,
		InstantFishCatch = false,
		AutoAlienTrade = false,
		AutoShootingStar = false,
		AutoFeedStar = false,
		AutoButterfly = false,
		AutoBloomery = false,
		AutoMonsterParasite = false,
		AutoHalloween = false,
		AutoScrambleAndEvents = false,
		AutoBeanstalk = false,

		-- ต่อสู้และป้องกัน
		AutoAttack = false,
		AutoEquipBat = false,
		AttackMode = "ตีผู้เล่นที่เข้าใกล้",
		AttackTargetPlayer = "ทุกคนที่เข้าเงื่อนไข",
		AntiGuard = false,
		AntiGuardMode = "ครบสูตรอัตโนมัติ",
		AntiFall = false,
		AntiKnockback = false,
		AntiTrap = false,
		AntiAFK = false,

		-- เอาเปรียบระบบเกม
		DisarmObbyAntiTP = true,
		BlockHazardStrikes = true,
		SpoofWalkSpeed = false,
		CustomWalkSpeed = 48,
		SpoofJumpPower = false,
		CustomJumpPower = 72,
		InstantPrompts = false,
		NoCamShakeAndFlash = false,
		Fullbright = false,
		UnlimitedZoom = false,
		StaffDetector = true,
		AutoLeaveOnStaff = false,

		-- เรนเดอร์และตรวจจับ
		RevealEggContent100 = true,
		EggESP = false,
		OwnBaseEggESP = false,
		EggHighlightMode = "ตามสีความหายาก",
		EggESPColorName = "ชมพูซากุระ",
		EggTracker = false,
		EggShowName = true,
		EggShowRarity = true,
		EggShowMutation = true,
		EggShowIncome = true,
		EggShowWeight = true,
		EggShowArea = false,
		EggShowDistance = true,
		EggESPSizePercent = 100,
		ESPFilterArea = "All",
		ESPFilterSpecies = "All",
		ESPFilterRarity = "All",
		ESPFilterMutation = "All",
		GuardESP = false,
		GuardShowState = true,
		GuardShowDistance = true,
		GuardTracker = false,
		PlayerESP = false,
		PlayerESPColorName = "ฟ้าคราม",
		PlayerShowName = true,
		PlayerShowDistance = true,
		PlayerShowSpeed = false,
		PlayerShowStatus = true,
		PlayerTracker = false,
		TrapESP = false,
		LostPartESP = false,
		LostPartTracker = false,
		EventCollectibleESP = false,

		-- การเพิ่มประสิทธิภาพ
		OptHideOtherPets = false,
		OptHideSelfPets = false,
		OptDisableTreadmillVideos = false,
		OptDisableParticles = false,
		OptDisableShadowsAndPostFX = false,
		OptSimplifyMaterials = false,
		OptHideWorldDecorations = false,
		OptMuteGameAudio = false,
		OptUnlockFPS = false,

		-- โหมดฮาๆ และเคลื่อนไหว
		FunSpin = false,
		FunSpinMode = "หมุนแนวราบคมกริบ",
		FunSpinDir = "ตามเข็มนาฬิกา",
		FunSpinSpeed = 3600,
		FunHeadSpin = false,
		FunHeadSpinSpeed = 1440,
		FunScaleEnabled = false,
		FunScaleMode = "ทั้งตัว",
		FunScale = 1.5,
		FunHeadScale = 1,
		FunTorsoScale = 1,
		FunLeftArmScale = 1,
		FunRightArmScale = 1,
		FunLeftLegScale = 1,
		FunRightLegScale = 1,
		FunFly = false,
		FunFlySpeed = 85,
		FunNoclip = false,
		FunInfJump = false,
		FunZeroGrav = false,

		-- ตั้งค่าเมนูและปุ่มลัด
		ThemeName = "ชมพูซากุระ",
		FontName = "ไทยโมเดิร์นหนา",
		FontSize = 14,
		GuiScalePercent = 100,
		BackgroundBlur = true,
		BackgroundTransparency = 8,
		KeybindsEnabled = true,
		Keybinds = {
			ToggleGUI = "RightControl",
			FullAutoPlay = "F1",
			AutoStealEgg = "F2",
			AutoPlaceEgg = "F3",
			AutoHatchEgg = "F4",
			AutoTreadmill = "F5",
			AutoEquipBest = "F6",
			AutoClaimReward = "F7",
			AutoAttack = "R",
			AntiFall = "H",
			FunSpin = "V",
			FunFly = "Z",
			FunNoclip = "X",
			EggESP = "I",
			PlayerESP = "O",
		},
	}
end

local Config: { [string]: any } = Data.createDefaultConfig()
local ProfilesDir = "MyGame1ThaiCleanUI"
local ProfilesPath = ProfilesDir .. "/profiles.json"
local CurrentProfileName = "ค่าเริ่มต้น"
local ProfilesStore: { [string]: any } = {
	["ค่าเริ่มต้น"] = Data.createDefaultConfig(),
}

local function mergeProfileTable(src: any, dest: { [string]: any })
	local defaults = Data.createDefaultConfig()
	if type(src) ~= "table" then
		src = {}
	end
	for k, def in pairs(defaults) do
		local val = src[k]
		if k == "Keybinds" and type(def) == "table" then
			local merged = table.clone(def)
			if type(val) == "table" then
				for kbKey, kbVal in pairs(val) do
					if type(kbVal) == "string" and merged[kbKey] ~= nil then
						merged[kbKey] = kbVal
					end
				end
			end
			dest[k] = merged
		elseif type(def) == "boolean" then
			if type(val) == "boolean" then
				dest[k] = val
			else
				dest[k] = def
			end
		elseif type(def) == "number" then
			if type(val) == "number" and val == val and val ~= math.huge and val ~= -math.huge then
				dest[k] = val
			else
				dest[k] = def
			end
		elseif type(def) == "string" then
			if type(val) == "string" then
				if k == "ThemeName" and not Data.Themes[val] then
					dest[k] = def
				elseif k == "FontName" and not Data.Fonts[val] then
					dest[k] = def
				else
					dest[k] = val
				end
			else
				dest[k] = def
			end
		elseif type(def) == "table" then
			if type(val) == "table" then
				dest[k] = table.clone(val)
			else
				dest[k] = {}
			end
		end
	end
end

local function loadProfilesFromDisk()
	if not Exec.isFile or not Exec.readFile then
		return
	end
	local ok, exists = pcall(Exec.isFile, ProfilesPath)
	if not ok or not exists then
		return
	end
	local okRead, raw = pcall(Exec.readFile, ProfilesPath)
	if not okRead or type(raw) ~= "string" then
		return
	end
	local okDec, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
	if not okDec or type(decoded) ~= "table" then
		return
	end
	if type(decoded.Profiles) == "table" then
		for pName, pData in pairs(decoded.Profiles) do
			if type(pName) == "string" and type(pData) == "table" then
				local cleaned = Data.createDefaultConfig()
				mergeProfileTable(pData, cleaned)
				ProfilesStore[pName] = cleaned
			end
		end
	end
	if type(decoded.Current) == "string" and ProfilesStore[decoded.Current] then
		CurrentProfileName = decoded.Current
	end
	mergeProfileTable(ProfilesStore[CurrentProfileName], Config)
end

local function saveProfilesToDisk(): (boolean, string)
	if not Exec.writeFile then
		return false, "ตัวรันไม่รองรับการเขียนไฟล์"
	end
	if Exec.isFolder and Exec.makeFolder then
		local okHas, hasDir = pcall(Exec.isFolder, ProfilesDir)
		if okHas and not hasDir then
			pcall(Exec.makeFolder, ProfilesDir)
		end
	end
	local payload = {
		Current = CurrentProfileName,
		Profiles = ProfilesStore,
	}
	local okEnc, json = pcall(HttpService.JSONEncode, HttpService, payload)
	if not okEnc then
		return false, "แปลงข้อมูลไม่สำเร็จ"
	end
	local okW, err = pcall(Exec.writeFile, ProfilesPath, json)
	if not okW then
		return false, tostring(err)
	end
	return true, "บันทึกสำเร็จ"
end

loadProfilesFromDisk()

-- ส่วนต่อประสานผู้ใช้สไตล์ไทยคลีนยูไอ ไม่มีแผงแยกซ้อนทับ
local UI = {}
local ThemeRegistry: { { Inst: Instance, Prop: string, Role: string } } = {}
local TextRegistry: { { Inst: Instance, BaseSize: number, Bold: boolean } } = {}
local RefreshCallbacks: { () -> () } = {}
local TabButtons: { [string]: { Btn: TextButton, Ind: Frame, Label: TextLabel } } = {}
local TabPages: { [string]: ScrollingFrame } = {}
local ConflictBadges: { [string]: TextLabel } = {}

local function curTheme(): { [string]: Color3 }
	return Data.Themes[Config.ThemeName] or Data.Themes["ชมพูซากุระ"]
end

local function curFont(): Enum.Font
	return Data.Fonts[Config.FontName] or Enum.Font.GothamBold
end

local function regTheme(inst: Instance, prop: string, role: string)
	table.insert(ThemeRegistry, { Inst = inst, Prop = prop, Role = role })
	local col = curTheme()[role]
	if col then
		(inst :: any)[prop] = col
	end
end

local function regText(inst: Instance, baseSize: number, bold: boolean)
	table.insert(TextRegistry, { Inst = inst, BaseSize = baseSize, Bold = bold })
	(inst :: any).Font = curFont()
	(inst :: any).TextSize = math.clamp(baseSize * (Config.FontSize / 14), 8, 96)
end

local function makeCorner(parent: Instance, px: number?, scale: number?)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(scale or 0, px or 8)
	c.Parent = parent
	return c
end

local function makeStroke(parent: Instance, role: string, thickness: number?, trans: number?): UIStroke
	local s = Instance.new("UIStroke")
	s.Thickness = thickness or 1
	s.Transparency = trans or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	regTheme(s, "Color", role)
	return s
end

local function safeRefresh(cb: () -> ())
	pcall(cb)
end

function UI.refreshAll()
	for _, cb in ipairs(RefreshCallbacks) do
		safeRefresh(cb)
	end
end

-- สร้างหน้าจอหลักเพียงชุดเดียว
local GuiParent = getGuiParent()
for _, old in ipairs(GuiParent:GetChildren()) do
	if old.Name == "MyGame1ThaiCleanUI" or old.Name == "__MyGame1ESPFolder" then
		pcall(function()
			old:Destroy()
		end)
	end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MyGame1ThaiCleanUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 100
ScreenGui.Parent = GuiParent

local TracerLayer = Instance.new("Frame")
TracerLayer.Name = "TracerLayer"
TracerLayer.Size = UDim2.fromScale(1, 1)
TracerLayer.BackgroundTransparency = 1
TracerLayer.ZIndex = 1
TracerLayer.Parent = ScreenGui

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "__MyGame1ESPFolder"
ESPFolder.Parent = GuiParent

local BlurEffect: BlurEffect? = Instance.new("BlurEffect")
if BlurEffect then
	BlurEffect.Name = "MyGame1ThaiCleanBlur"
	BlurEffect.Size = 8
	BlurEffect.Enabled = Config.BackgroundBlur and Runtime.WindowOpen
	BlurEffect.Parent = Lighting
end

onCleanup(function()
	if BlurEffect then
		pcall(function()
			BlurEffect:Destroy()
		end)
	end
	pcall(function()
		ESPFolder:Destroy()
	end)
	pcall(function()
		ScreenGui:Destroy()
	end)
end)

-- กล่องแจ้งเตือนมุมขวาล่าง
local ToastContainer = Instance.new("Frame")
ToastContainer.Name = "ToastContainer"
ToastContainer.AnchorPoint = Vector2.new(1, 1)
ToastContainer.Position = UDim2.new(1, -18, 1, -18)
ToastContainer.Size = UDim2.fromOffset(290, 260)
ToastContainer.BackgroundTransparency = 1
ToastContainer.ZIndex = 60
ToastContainer.Parent = ScreenGui

local ToastLayout = Instance.new("UIListLayout")
ToastLayout.SortOrder = Enum.SortOrder.LayoutOrder
ToastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
ToastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ToastLayout.Padding = UDim.new(0, 8)
ToastLayout.Parent = ToastContainer

local ToastSeq = 0
local ActiveToasts: { Frame } = {}

function UI.notify(msg: string, kind: string?, duration: number?)
	if not Runtime.Running or not ScreenGui.Parent then
		return
	end
	ToastSeq += 1
	local role = "Accent"
	if kind == "success" then
		role = "Success"
	elseif kind == "warning" then
		role = "Warning"
	elseif kind == "danger" then
		role = "Danger"
	end

	while #ActiveToasts >= 4 do
		local oldest = table.remove(ActiveToasts, 1)
		if oldest and oldest.Parent then
			oldest:Destroy()
		end
	end

	local toast = Instance.new("Frame")
	toast.Name = "Toast_" .. tostring(ToastSeq)
	toast.LayoutOrder = ToastSeq
	toast.Size = UDim2.new(1, 0, 0, 44)
	toast.AutomaticSize = Enum.AutomaticSize.Y
	toast.BackgroundTransparency = 0.08
	toast.BorderSizePixel = 0
	toast.ZIndex = 61
	toast.Parent = ToastContainer
	regTheme(toast, "BackgroundColor3", "Card")
	makeCorner(toast, 10, 0)
	makeStroke(toast, role, 1.5, 0.15)

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.PaddingLeft = UDim.new(0, 12)
	pad.PaddingRight = UDim.new(0, 12)
	pad.Parent = toast

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 4, 1, 0)
	bar.BorderSizePixel = 0
	bar.ZIndex = 62
	bar.Parent = toast
	regTheme(bar, "BackgroundColor3", role)
	makeCorner(bar, 2, 0)

	local lbl = Instance.new("TextLabel")
	lbl.Position = UDim2.fromOffset(10, 0)
	lbl.Size = UDim2.new(1, -12, 0, 20)
	lbl.AutomaticSize = Enum.AutomaticSize.Y
	lbl.BackgroundTransparency = 1
	lbl.TextWrapped = true
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = msg
	lbl.ZIndex = 62
	lbl.Parent = toast
	regTheme(lbl, "TextColor3", "Text")
	regText(lbl, 13, false)

	table.insert(ActiveToasts, toast)
	task.delay(duration or 3.2, function()
		for idx, f in ipairs(ActiveToasts) do
			if f == toast then
				table.remove(ActiveToasts, idx)
				break
			end
		end
		if toast.Parent then
			toast:Destroy()
		end
	end)
end

-- หน้าต่างหลักขนาดมาตรฐาน 740x460
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
MainWindow.Position = UDim2.fromScale(0.5, 0.5)
MainWindow.Size = UDim2.fromOffset(740, 460)
MainWindow.BackgroundTransparency = math.clamp(Config.BackgroundTransparency / 100, 0, 0.92)
MainWindow.BorderSizePixel = 0
MainWindow.Visible = true
MainWindow.ZIndex = 10
MainWindow.Parent = ScreenGui
regTheme(MainWindow, "BackgroundColor3", "Bg")
makeCorner(MainWindow, 12, 0)
makeStroke(MainWindow, "Border", 1.5, 0.1)

local MainScale = Instance.new("UIScale")
MainScale.Scale = math.clamp(Config.GuiScalePercent / 100, 0.55, 1.5)
MainScale.Parent = MainWindow

-- แถบหัวเรื่อง (ลากหน้าต่างได้)
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundTransparency = 0.04
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 12
TitleBar.Parent = MainWindow
regTheme(TitleBar, "BackgroundColor3", "Header")
makeCorner(TitleBar, 12, 0)

local TitleBottomLine = Instance.new("Frame")
TitleBottomLine.AnchorPoint = Vector2.new(0, 1)
TitleBottomLine.Position = UDim2.fromScale(0, 1)
TitleBottomLine.Size = UDim2.new(1, 0, 0, 1)
TitleBottomLine.BorderSizePixel = 0
TitleBottomLine.ZIndex = 13
TitleBottomLine.Parent = TitleBar
regTheme(TitleBottomLine, "BackgroundColor3", "Border")

local TitleAccentDot = Instance.new("Frame")
TitleAccentDot.AnchorPoint = Vector2.new(0, 0.5)
TitleAccentDot.Position = UDim2.new(0, 16, 0.5, 0)
TitleAccentDot.Size = UDim2.fromOffset(10, 10)
TitleAccentDot.BorderSizePixel = 0
TitleAccentDot.ZIndex = 13
TitleAccentDot.Parent = TitleBar
regTheme(TitleAccentDot, "BackgroundColor3", "Accent")
makeCorner(TitleAccentDot, 0, 1)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Position = UDim2.fromOffset(34, 0)
TitleLabel.Size = UDim2.new(0, 260, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Text = "ระบบช่วยเล่นและเอาเปรียบเกมไข่"
TitleLabel.ZIndex = 13
TitleLabel.Parent = TitleBar
regTheme(TitleLabel, "TextColor3", "Text")
regText(TitleLabel, 16, true)

local SecurityChip = Instance.new("TextLabel")
SecurityChip.AnchorPoint = Vector2.new(1, 0.5)
SecurityChip.Position = UDim2.new(1, -220, 0.5, 0)
SecurityChip.Size = UDim2.fromOffset(145, 24)
SecurityChip.BackgroundTransparency = 0.15
SecurityChip.Text = "ป้องกันปกติ • ปลอดภัย"
SecurityChip.ZIndex = 13
SecurityChip.Parent = TitleBar
regTheme(SecurityChip, "BackgroundColor3", "Card")
regTheme(SecurityChip, "TextColor3", "Success")
regText(SecurityChip, 11, true)
makeCorner(SecurityChip, 12, 0)
makeStroke(SecurityChip, "Border", 1, 0.3)
UI.SecurityChip = SecurityChip

local ProfileChip = Instance.new("TextLabel")
ProfileChip.AnchorPoint = Vector2.new(1, 0.5)
ProfileChip.Position = UDim2.new(1, -86, 0.5, 0)
ProfileChip.Size = UDim2.fromOffset(126, 24)
ProfileChip.BackgroundTransparency = 0.2
ProfileChip.Text = "โปรไฟล์: " .. CurrentProfileName
ProfileChip.ZIndex = 13
ProfileChip.Parent = TitleBar
regTheme(ProfileChip, "BackgroundColor3", "Card")
regTheme(ProfileChip, "TextColor3", "Accent")
regText(ProfileChip, 11, true)
makeCorner(ProfileChip, 12, 0)
UI.ProfileChip = ProfileChip

local MinBtn = Instance.new("TextButton")
MinBtn.AnchorPoint = Vector2.new(1, 0.5)
MinBtn.Position = UDim2.new(1, -46, 0.5, 0)
MinBtn.Size = UDim2.fromOffset(28, 28)
MinBtn.Text = "—"
MinBtn.AutoButtonColor = false
MinBtn.ZIndex = 13
MinBtn.Parent = TitleBar
regTheme(MinBtn, "BackgroundColor3", "Card")
regTheme(MinBtn, "TextColor3", "SubText")
regText(MinBtn, 14, true)
makeCorner(MinBtn, 8, 0)

local CloseBtn = Instance.new("TextButton")
CloseBtn.AnchorPoint = Vector2.new(1, 0.5)
CloseBtn.Position = UDim2.new(1, -12, 0.5, 0)
CloseBtn.Size = UDim2.fromOffset(28, 28)
CloseBtn.Text = "✕"
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 13
CloseBtn.Parent = TitleBar
regTheme(CloseBtn, "BackgroundColor3", "Card")
regTheme(CloseBtn, "TextColor3", "Danger")
regText(CloseBtn, 14, true)
makeCorner(CloseBtn, 8, 0)

-- แถบด้านข้างซ้ายกว้าง 168px พร้อมกล่องสถานะ + ProgressBar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Position = UDim2.fromOffset(0, 50)
Sidebar.Size = UDim2.new(0, 168, 1, -50)
Sidebar.BackgroundTransparency = 0.04
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 11
Sidebar.Parent = MainWindow
regTheme(Sidebar, "BackgroundColor3", "Sidebar")

local SidebarRightLine = Instance.new("Frame")
SidebarRightLine.AnchorPoint = Vector2.new(1, 0)
SidebarRightLine.Position = UDim2.fromScale(1, 0)
SidebarRightLine.Size = UDim2.new(0, 1, 1, 0)
SidebarRightLine.BorderSizePixel = 0
SidebarRightLine.ZIndex = 12
SidebarRightLine.Parent = Sidebar
regTheme(SidebarRightLine, "BackgroundColor3", "Border")

local TabScroll = Instance.new("ScrollingFrame")
TabScroll.Name = "TabScroll"
TabScroll.Position = UDim2.fromOffset(8, 10)
TabScroll.Size = UDim2.new(1, -16, 1, -104)
TabScroll.BackgroundTransparency = 1
TabScroll.BorderSizePixel = 0
TabScroll.ScrollBarThickness = 3
TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TabScroll.ZIndex = 12
TabScroll.Parent = Sidebar
regTheme(TabScroll, "ScrollBarImageColor3", "Accent")

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 6)
TabListLayout.Parent = TabScroll

-- กล่องแสดงสถานะและแถบความคืบหน้าในแถบข้าง
local StatusCard = Instance.new("Frame")
StatusCard.Name = "StatusBanner"
StatusCard.AnchorPoint = Vector2.new(0.5, 1)
StatusCard.Position = UDim2.new(0.5, 0, 1, -10)
StatusCard.Size = UDim2.new(1, -16, 0, 78)
StatusCard.BackgroundTransparency = 0.08
StatusCard.BorderSizePixel = 0
StatusCard.ZIndex = 12
StatusCard.Parent = Sidebar
regTheme(StatusCard, "BackgroundColor3", "Card")
makeCorner(StatusCard, 10, 0)
makeStroke(StatusCard, "Border", 1, 0.25)

local StatusDot = Instance.new("Frame")
StatusDot.Position = UDim2.fromOffset(10, 12)
StatusDot.Size = UDim2.fromOffset(8, 8)
StatusDot.BorderSizePixel = 0
StatusDot.ZIndex = 13
StatusDot.Parent = StatusCard
regTheme(StatusDot, "BackgroundColor3", "Success")
makeCorner(StatusDot, 0, 1)

local StatusTitle = Instance.new("TextLabel")
StatusTitle.Position = UDim2.fromOffset(24, 6)
StatusTitle.Size = UDim2.new(1, -30, 0, 18)
StatusTitle.BackgroundTransparency = 1
StatusTitle.TextXAlignment = Enum.TextXAlignment.Left
StatusTitle.Text = "สถานะการทำงาน"
StatusTitle.ZIndex = 13
StatusTitle.Parent = StatusCard
regTheme(StatusTitle, "TextColor3", "SubText")
regText(StatusTitle, 11, true)

local StatusTextLbl = Instance.new("TextLabel")
StatusTextLbl.Position = UDim2.fromOffset(10, 26)
StatusTextLbl.Size = UDim2.new(1, -20, 0, 32)
StatusTextLbl.BackgroundTransparency = 1
StatusTextLbl.TextWrapped = true
StatusTextLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusTextLbl.TextYAlignment = Enum.TextYAlignment.Top
StatusTextLbl.Text = Runtime.StatusText
StatusTextLbl.ZIndex = 13
StatusTextLbl.Parent = StatusCard
regTheme(StatusTextLbl, "TextColor3", "Text")
regText(StatusTextLbl, 11, false)

local ProgressTrack = Instance.new("Frame")
ProgressTrack.AnchorPoint = Vector2.new(0.5, 1)
ProgressTrack.Position = UDim2.new(0.5, 0, 1, -8)
ProgressTrack.Size = UDim2.new(1, -20, 0, 6)
ProgressTrack.BorderSizePixel = 0
ProgressTrack.ZIndex = 13
ProgressTrack.Parent = StatusCard
regTheme(ProgressTrack, "BackgroundColor3", "Bg")
makeCorner(ProgressTrack, 3, 0)

local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.fromScale(0, 1)
ProgressFill.BorderSizePixel = 0
ProgressFill.ZIndex = 14
ProgressFill.Parent = ProgressTrack
regTheme(ProgressFill, "BackgroundColor3", "Accent")
makeCorner(ProgressFill, 3, 0)

function UI.setStatus(text: string, state: string?, progress: number?)
	Runtime.StatusText = text
	if state then
		Runtime.StatusState = state
	end
	if progress ~= nil then
		Runtime.StatusProgress = math.clamp(progress, 0, 1)
	end
	if StatusTextLbl.Parent then
		StatusTextLbl.Text = text
	end
	local role = "Success"
	if state == "busy" or state == "steal" then
		role = "Accent"
	elseif state == "wait" or state == "warning" then
		role = "Warning"
	elseif state == "error" or state == "danger" then
		role = "Danger"
	end
	local col = curTheme()[role]
	if col and StatusDot.Parent then
		StatusDot.BackgroundColor3 = col
	end
	if ProgressFill.Parent then
		TweenService:Create(ProgressFill, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(Runtime.StatusProgress, 1),
		}):Play()
	end
end

-- พื้นที่แสดงผลแท็บด้านขวา
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Position = UDim2.fromOffset(172, 54)
ContentContainer.Size = UDim2.new(1, -176, 1, -58)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ZIndex = 11
ContentContainer.Parent = MainWindow

-- ปุ่มวงกลมลอยสำหรับเปิดและซ่อนเมนู (กันลั่นตอนลาก)
local CircleBtn = Instance.new("TextButton")
CircleBtn.Name = "CircleOverlay"
CircleBtn.Position = UDim2.new(0, 22, 0.5, -28)
CircleBtn.Size = UDim2.fromOffset(56, 56)
CircleBtn.Text = "เมนู"
CircleBtn.AutoButtonColor = false
CircleBtn.ZIndex = 50
CircleBtn.Parent = ScreenGui
regTheme(CircleBtn, "BackgroundColor3", "Sidebar")
regTheme(CircleBtn, "TextColor3", "Accent")
regText(CircleBtn, 14, true)
makeCorner(CircleBtn, 0, 1)
makeStroke(CircleBtn, "Accent", 2, 0.08)

function UI.setWindowOpen(open: boolean)
	Runtime.WindowOpen = open
	MainWindow.Visible = open
	if BlurEffect then
		BlurEffect.Enabled = open and Config.BackgroundBlur
	end
end

local function makeDraggable(dragHandle: GuiObject, targetFrame: GuiObject, onClickNoDrag: (() -> ())?)
	local dragging = false
	local startMouse = Vector2.zero
	local startPos = targetFrame.Position
	local movedPx = 0

	trackConn(dragHandle.InputBegan, function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			movedPx = 0
			startMouse = Vector2.new(input.Position.X, input.Position.Y)
			startPos = targetFrame.Position
		end
	end)

	trackConn(UserInputService.InputChanged, function(input: InputObject)
		if not dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local delta = Vector2.new(input.Position.X, input.Position.Y) - startMouse
			movedPx = math.max(movedPx, delta.Magnitude)
			if movedPx > 6 then
				targetFrame.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end
	end)

	trackConn(UserInputService.InputEnded, function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if dragging then
				dragging = false
				if movedPx <= 6 and onClickNoDrag then
					onClickNoDrag()
				end
			end
		end
	end)
end

makeDraggable(TitleBar, MainWindow, nil)
makeDraggable(CircleBtn, CircleBtn, function()
	UI.setWindowOpen(not Runtime.WindowOpen)
end)
MinBtn.MouseButton1Click:Connect(function()
	UI.setWindowOpen(false)
end)
CloseBtn.MouseButton1Click:Connect(function()
	UI.setWindowOpen(false)
end)

function UI.selectTab(tabName: string)
	Runtime.CurrentTab = tabName
	local theme = curTheme()
	for name, page in pairs(TabPages) do
		page.Visible = (name == tabName)
	end
	for name, info in pairs(TabButtons) do
		local active = (name == tabName)
		info.Btn.BackgroundColor3 = active and theme.Accent or theme.Card
		info.Btn.BackgroundTransparency = active and 0.14 or 0.45
		info.Ind.Visible = active
		info.Label.TextColor3 = active and theme.Text or theme.SubText
	end
end

function UI.createTab(name: string, order: number): ScrollingFrame
	local btn = Instance.new("TextButton")
	btn.Name = "TabBtn_" .. name
	btn.LayoutOrder = order
	btn.Size = UDim2.new(1, 0, 0, 36)
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.BorderSizePixel = 0
	btn.ZIndex = 13
	btn.Parent = TabScroll
	makeCorner(btn, 9, 0)

	local ind = Instance.new("Frame")
	ind.AnchorPoint = Vector2.new(0, 0.5)
	ind.Position = UDim2.new(0, 6, 0.5, 0)
	ind.Size = UDim2.fromOffset(4, 18)
	ind.BorderSizePixel = 0
	ind.Visible = false
	ind.ZIndex = 14
	ind.Parent = btn
	regTheme(ind, "BackgroundColor3", "Text")
	makeCorner(ind, 2, 0)

	local lbl = Instance.new("TextLabel")
	lbl.Position = UDim2.fromOffset(15, 0)
	lbl.Size = UDim2.new(1, -18, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = name
	lbl.TextTruncate = Enum.TextTruncate.AtEnd
	lbl.ZIndex = 14
	lbl.Parent = btn
	regText(lbl, 13, true)

	local page = Instance.new("ScrollingFrame")
	page.Name = "Page_" .. name
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 4
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.Visible = false
	page.ZIndex = 12
	page.Parent = ContentContainer
	regTheme(page, "ScrollBarImageColor3", "Accent")

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 4)
	pad.PaddingLeft = UDim.new(0, 4)
	pad.PaddingRight = UDim.new(0, 10)
	pad.PaddingBottom = UDim.new(0, 14)
	pad.Parent = page

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 10)
	layout.Parent = page

	TabButtons[name] = { Btn = btn, Ind = ind, Label = lbl }
	TabPages[name] = page

	btn.MouseButton1Click:Connect(function()
		UI.selectTab(name)
		UI.refreshAll()
	end)
	return page
end

function UI.section(page: ScrollingFrame, title: string, order: number, subtitle: string?): Frame
	local card = Instance.new("Frame")
	card.Name = "Sec_" .. title
	card.LayoutOrder = order
	card.Size = UDim2.new(1, 0, 0, 40)
	card.AutomaticSize = Enum.AutomaticSize.Y
	card.BackgroundTransparency = 0.08
	card.BorderSizePixel = 0
	card.ZIndex = 12
	card.Parent = page
	regTheme(card, "BackgroundColor3", "Card")
	makeCorner(card, 10, 0)
	makeStroke(card, "Border", 1, 0.25)

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 10)
	pad.PaddingBottom = UDim.new(0, 12)
	pad.PaddingLeft = UDim.new(0, 12)
	pad.PaddingRight = UDim.new(0, 12)
	pad.Parent = card

	local list = Instance.new("UIListLayout")
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 8)
	list.Parent = card

	local head = Instance.new("TextLabel")
	head.LayoutOrder = 0
	head.Size = UDim2.new(1, 0, 0, 22)
	head.BackgroundTransparency = 1
	head.TextXAlignment = Enum.TextXAlignment.Left
	head.Text = title
	head.ZIndex = 13
	head.Parent = card
	regTheme(head, "TextColor3", "Accent")
	regText(head, 15, true)

	if subtitle and subtitle ~= "" then
		local sub = Instance.new("TextLabel")
		sub.LayoutOrder = 0
		sub.Size = UDim2.new(1, 0, 0, 16)
		sub.AutomaticSize = Enum.AutomaticSize.Y
		sub.BackgroundTransparency = 1
		sub.TextWrapped = true
		sub.TextXAlignment = Enum.TextXAlignment.Left
		sub.Text = subtitle
		sub.ZIndex = 13
		sub.Parent = card
		regTheme(sub, "TextColor3", "SubText")
		regText(sub, 12, false)
	end
	return card
end

local SyncFeatureHandler: ((string?) -> ())? = nil
function UI.setFeatureSyncHandler(fn: (string?) -> ())
	SyncFeatureHandler = fn
end

function UI.toggle(
	parent: Frame,
	title: string,
	desc: string,
	cfgKey: string,
	order: number,
	onChange: ((boolean) -> ())?
): Frame
	local row = Instance.new("Frame")
	row.Name = "Toggle_" .. cfgKey
	row.LayoutOrder = order
	row.Size = UDim2.new(1, 0, 0, 44)
	row.AutomaticSize = Enum.AutomaticSize.Y
	row.BackgroundTransparency = 0.35
	row.BorderSizePixel = 0
	row.ZIndex = 13
	row.Parent = parent
	regTheme(row, "BackgroundColor3", "Bg")
	makeCorner(row, 8, 0)

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.PaddingLeft = UDim.new(0, 10)
	pad.PaddingRight = UDim.new(0, 10)
	pad.Parent = row

	local textCol = Instance.new("Frame")
	textCol.Size = UDim2.new(1, -60, 0, 26)
	textCol.AutomaticSize = Enum.AutomaticSize.Y
	textCol.BackgroundTransparency = 1
	textCol.ZIndex = 14
	textCol.Parent = row

	local tl = Instance.new("UIListLayout")
	tl.SortOrder = Enum.SortOrder.LayoutOrder
	tl.Padding = UDim.new(0, 2)
	tl.Parent = textCol

	local titleLbl = Instance.new("TextLabel")
	titleLbl.LayoutOrder = 1
	titleLbl.Size = UDim2.new(1, 0, 0, 18)
	titleLbl.BackgroundTransparency = 1
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Text = title
	titleLbl.ZIndex = 14
	titleLbl.Parent = textCol
	regTheme(titleLbl, "TextColor3", "Text")
	regText(titleLbl, 13, true)

	if desc ~= "" then
		local descLbl = Instance.new("TextLabel")
		descLbl.LayoutOrder = 2
		descLbl.Size = UDim2.new(1, 0, 0, 14)
		descLbl.AutomaticSize = Enum.AutomaticSize.Y
		descLbl.BackgroundTransparency = 1
		descLbl.TextWrapped = true
		descLbl.TextXAlignment = Enum.TextXAlignment.Left
		descLbl.Text = desc
		descLbl.ZIndex = 14
		descLbl.Parent = textCol
		regTheme(descLbl, "TextColor3", "SubText")
		regText(descLbl, 11, false)
	end

	local badge = Instance.new("TextLabel")
	badge.Name = "ConflictBadge"
	badge.LayoutOrder = 3
	badge.Size = UDim2.new(1, 0, 0, 16)
	badge.BackgroundTransparency = 1
	badge.TextXAlignment = Enum.TextXAlignment.Left
	badge.Visible = false
	badge.Text = ""
	badge.ZIndex = 14
	badge.Parent = textCol
	regTheme(badge, "TextColor3", "Warning")
	regText(badge, 11, true)
	ConflictBadges[cfgKey] = badge

	local switchBtn = Instance.new("TextButton")
	switchBtn.AnchorPoint = Vector2.new(1, 0.5)
	switchBtn.Position = UDim2.new(1, -2, 0.5, 0)
	switchBtn.Size = UDim2.fromOffset(44, 24)
	switchBtn.Text = ""
	switchBtn.AutoButtonColor = false
	switchBtn.BorderSizePixel = 0
	switchBtn.ZIndex = 15
	switchBtn.Parent = row
	makeCorner(switchBtn, 0, 1)

	local knob = Instance.new("Frame")
	knob.AnchorPoint = Vector2.new(0, 0.5)
	knob.Size = UDim2.fromOffset(18, 18)
	knob.BorderSizePixel = 0
	knob.ZIndex = 16
	knob.Parent = switchBtn
	regTheme(knob, "BackgroundColor3", "Text")
	makeCorner(knob, 0, 1)

	local function paint()
		local on = Config[cfgKey] == true
		local t = curTheme()
		switchBtn.BackgroundColor3 = on and t.Accent or t.Border
		knob.Position = on and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
	end

	switchBtn.MouseButton1Click:Connect(function()
		local nextVal = not (Config[cfgKey] == true)
		Config[cfgKey] = nextVal
		paint()
		if SyncFeatureHandler then
			SyncFeatureHandler(cfgKey)
		end
		if onChange then
			onChange(nextVal)
		end
		UI.refreshAll()
	end)

	table.insert(RefreshCallbacks, paint)
	paint()
	return row
end

function UI.slider(
	parent: Frame,
	title: string,
	desc: string,
	cfgKey: string,
	minVal: number,
	maxVal: number,
	step: number,
	order: number,
	suffix: string?,
	onChange: ((number) -> ())?
): Frame
	local row = Instance.new("Frame")
	row.Name = "Slider_" .. cfgKey
	row.LayoutOrder = order
	row.Size = UDim2.new(1, 0, 0, 56)
	row.AutomaticSize = Enum.AutomaticSize.Y
	row.BackgroundTransparency = 0.35
	row.BorderSizePixel = 0
	row.ZIndex = 13
	row.Parent = parent
	regTheme(row, "BackgroundColor3", "Bg")
	makeCorner(row, 8, 0)

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 10)
	pad.PaddingLeft = UDim.new(0, 10)
	pad.PaddingRight = UDim.new(0, 10)
	pad.Parent = row

	local top = Instance.new("Frame")
	top.Size = UDim2.new(1, 0, 0, 20)
	top.BackgroundTransparency = 1
	top.ZIndex = 14
	top.Parent = row

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.7, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = title
	lbl.ZIndex = 14
	lbl.Parent = top
	regTheme(lbl, "TextColor3", "Text")
	regText(lbl, 13, true)

	local valBox = Instance.new("TextBox")
	valBox.AnchorPoint = Vector2.new(1, 0.5)
	valBox.Position = UDim2.new(1, 0, 0.5, 0)
	valBox.Size = UDim2.fromOffset(92, 20)
	valBox.BackgroundTransparency = 0.1
	valBox.ClearTextOnFocus = false
	valBox.TextXAlignment = Enum.TextXAlignment.Right
	valBox.ZIndex = 15
	valBox.Parent = top
	regTheme(valBox, "BackgroundColor3", "Card")
	regTheme(valBox, "TextColor3", "Accent")
	regText(valBox, 12, true)
	makeCorner(valBox, 6, 0)

	if desc ~= "" then
		local sub = Instance.new("TextLabel")
		sub.Position = UDim2.fromOffset(0, 21)
		sub.Size = UDim2.new(1, 0, 0, 14)
		sub.BackgroundTransparency = 1
		sub.TextXAlignment = Enum.TextXAlignment.Left
		sub.Text = desc
		sub.ZIndex = 14
		sub.Parent = row
		regTheme(sub, "TextColor3", "SubText")
		regText(sub, 11, false)
	end

	local trackY = (desc ~= "") and 40 or 26
	local track = Instance.new("TextButton")
	track.Position = UDim2.fromOffset(0, trackY)
	track.Size = UDim2.new(1, 0, 0, 10)
	track.Text = ""
	track.AutoButtonColor = false
	track.BorderSizePixel = 0
	track.ZIndex = 14
	track.Parent = row
	regTheme(track, "BackgroundColor3", "Card")
	makeCorner(track, 5, 0)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(0, 1)
	fill.BorderSizePixel = 0
	fill.ZIndex = 15
	fill.Parent = track
	regTheme(fill, "BackgroundColor3", "Accent")
	makeCorner(fill, 5, 0)

	local function fmt(n: number): string
		local s = (step < 1) and string.format("%.2f", n) or tostring(math.floor(n + 0.5))
		return suffix and (s .. " " .. suffix) or s
	end

	local function applyNum(raw: number)
		local stepped = math.round((raw - minVal) / step) * step + minVal
		local clamped = math.clamp(stepped, minVal, maxVal)
		Config[cfgKey] = clamped
		local ratio = (clamped - minVal) / math.max(maxVal - minVal, 0.0001)
		fill.Size = UDim2.fromScale(math.clamp(ratio, 0, 1), 1)
		valBox.Text = fmt(clamped)
		if onChange then
			onChange(clamped)
		end
	end

	local sliding = false
	local function setFromX(absX: number)
		local w = math.max(track.AbsoluteSize.X, 1)
		local rel = math.clamp((absX - track.AbsolutePosition.X) / w, 0, 1)
		applyNum(minVal + rel * (maxVal - minVal))
	end

	track.InputBegan:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true
			setFromX(input.Position.X)
		end
	end)
	trackConn(UserInputService.InputChanged, function(input: InputObject)
		if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setFromX(input.Position.X)
		end
	end)
	trackConn(UserInputService.InputEnded, function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = false
		end
	end)

	valBox.FocusLost:Connect(function()
		local numStr = string.match(valBox.Text, "[%-]?%d+%.?%d*")
		local parsed = numStr and tonumber(numStr) or nil
		if parsed then
			applyNum(parsed)
		else
			applyNum(tonumber(Config[cfgKey]) or minVal)
		end
	end)

	local function paint()
		local cur = tonumber(Config[cfgKey]) or minVal
		local ratio = (math.clamp(cur, minVal, maxVal) - minVal) / math.max(maxVal - minVal, 0.0001)
		fill.Size = UDim2.fromScale(ratio, 1)
		valBox.Text = fmt(cur)
	end
	table.insert(RefreshCallbacks, paint)
	paint()
	return row
end

function UI.dropdown(
	parent: Frame,
	title: string,
	desc: string,
	optionsFn: () -> { any },
	getFn: () -> string,
	setFn: (string) -> (),
	order: number
): { Refresh: () -> (), Rebuild: () -> () }
	local wrap = Instance.new("Frame")
	wrap.Name = "Dropdown_" .. title
	wrap.LayoutOrder = order
	wrap.Size = UDim2.new(1, 0, 0, 44)
	wrap.AutomaticSize = Enum.AutomaticSize.Y
	wrap.BackgroundTransparency = 0.35
	wrap.BorderSizePixel = 0
	wrap.ZIndex = 13
	wrap.Parent = parent
	regTheme(wrap, "BackgroundColor3", "Bg")
	makeCorner(wrap, 8, 0)

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.PaddingLeft = UDim.new(0, 10)
	pad.PaddingRight = UDim.new(0, 10)
	pad.Parent = wrap

	local wl = Instance.new("UIListLayout")
	wl.SortOrder = Enum.SortOrder.LayoutOrder
	wl.Padding = UDim.new(0, 6)
	wl.Parent = wrap

	local header = Instance.new("Frame")
	header.LayoutOrder = 1
	header.Size = UDim2.new(1, 0, 0, 28)
	header.BackgroundTransparency = 1
	header.ZIndex = 14
	header.Parent = wrap

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.54, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = title
	lbl.ZIndex = 14
	lbl.Parent = header
	regTheme(lbl, "TextColor3", "Text")
	regText(lbl, 13, true)

	local btn = Instance.new("TextButton")
	btn.AnchorPoint = Vector2.new(1, 0.5)
	btn.Position = UDim2.new(1, 0, 0.5, 0)
	btn.Size = UDim2.new(0.44, 0, 0, 26)
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.BorderSizePixel = 0
	btn.ZIndex = 15
	btn.Parent = header
	regTheme(btn, "BackgroundColor3", "Card")
	regTheme(btn, "TextColor3", "Accent")
	regText(btn, 12, true)
	makeCorner(btn, 6, 0)
	makeStroke(btn, "Border", 1, 0.2)

	if desc ~= "" then
		local sub = Instance.new("TextLabel")
		sub.LayoutOrder = 2
		sub.Size = UDim2.new(1, 0, 0, 14)
		sub.AutomaticSize = Enum.AutomaticSize.Y
		sub.BackgroundTransparency = 1
		sub.TextWrapped = true
		sub.TextXAlignment = Enum.TextXAlignment.Left
		sub.Text = desc
		sub.ZIndex = 14
		sub.Parent = wrap
		regTheme(sub, "TextColor3", "SubText")
		regText(sub, 11, false)
	end

	local drawer = Instance.new("ScrollingFrame")
	drawer.LayoutOrder = 3
	drawer.Size = UDim2.new(1, 0, 0, 120)
	drawer.BackgroundTransparency = 0.1
	drawer.BorderSizePixel = 0
	drawer.ScrollBarThickness = 3
	drawer.AutomaticCanvasSize = Enum.AutomaticSize.Y
	drawer.CanvasSize = UDim2.new(0, 0, 0, 0)
	drawer.Visible = false
	drawer.ZIndex = 15
	drawer.Parent = wrap
	regTheme(drawer, "BackgroundColor3", "Card")
	regTheme(drawer, "ScrollBarImageColor3", "Accent")
	makeCorner(drawer, 8, 0)

	local dl = Instance.new("UIListLayout")
	dl.SortOrder = Enum.SortOrder.LayoutOrder
	dl.Padding = UDim.new(0, 4)
	dl.Parent = drawer

	local function resolveLabel(id: string): string
		for _, opt in ipairs(optionsFn()) do
			if type(opt) == "table" and opt.id == id then
				return opt.name or id
			elseif type(opt) == "string" and opt == id then
				return opt
			end
		end
		return id
	end

	local function refreshText()
		btn.Text = resolveLabel(getFn()) .. " ▾"
	end

	local function rebuild()
		for _, ch in ipairs(drawer:GetChildren()) do
			if ch:IsA("TextButton") then
				ch:Destroy()
			end
		end
		local list = optionsFn()
		for idx, opt in ipairs(list) do
			local id = (type(opt) == "table") and (opt.id :: string) or (opt :: string)
			local name = (type(opt) == "table") and (opt.name :: string) or (opt :: string)
			local itemBtn = Instance.new("TextButton")
			itemBtn.LayoutOrder = idx
			itemBtn.Size = UDim2.new(1, -6, 0, 26)
			itemBtn.Text = "  " .. name
			itemBtn.TextXAlignment = Enum.TextXAlignment.Left
			itemBtn.AutoButtonColor = false
			itemBtn.BorderSizePixel = 0
			itemBtn.ZIndex = 16
			itemBtn.Parent = drawer
			regTheme(itemBtn, "BackgroundColor3", "Bg")
			regTheme(itemBtn, "TextColor3", (getFn() == id) and "Accent" or "Text")
			regText(itemBtn, 12, getFn() == id)
			makeCorner(itemBtn, 6, 0)
			itemBtn.MouseButton1Click:Connect(function()
				drawer.Visible = false
				setFn(id)
				refreshText()
				UI.refreshAll()
			end)
		end
		local targetH = math.clamp(#list * 30 + 6, 36, 150)
		drawer.Size = UDim2.new(1, 0, 0, targetH)
	end

	btn.MouseButton1Click:Connect(function()
		local nextOpen = not drawer.Visible
		if nextOpen then
			rebuild()
		end
		drawer.Visible = nextOpen
	end)

	table.insert(RefreshCallbacks, refreshText)
	refreshText()
	return { Refresh = refreshText, Rebuild = rebuild }
end

function UI.multiDropdown(
	parent: Frame,
	title: string,
	desc: string,
	optionsFn: () -> { any },
	cfgKey: string,
	allLabel: string,
	order: number
)
	local wrap = Instance.new("Frame")
	wrap.Name = "Multi_" .. cfgKey
	wrap.LayoutOrder = order
	wrap.Size = UDim2.new(1, 0, 0, 44)
	wrap.AutomaticSize = Enum.AutomaticSize.Y
	wrap.BackgroundTransparency = 0.35
	wrap.BorderSizePixel = 0
	wrap.ZIndex = 13
	wrap.Parent = parent
	regTheme(wrap, "BackgroundColor3", "Bg")
	makeCorner(wrap, 8, 0)

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.PaddingLeft = UDim.new(0, 10)
	pad.PaddingRight = UDim.new(0, 10)
	pad.Parent = wrap

	local wl = Instance.new("UIListLayout")
	wl.SortOrder = Enum.SortOrder.LayoutOrder
	wl.Padding = UDim.new(0, 6)
	wl.Parent = wrap

	local header = Instance.new("Frame")
	header.LayoutOrder = 1
	header.Size = UDim2.new(1, 0, 0, 28)
	header.BackgroundTransparency = 1
	header.ZIndex = 14
	header.Parent = wrap

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.54, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = title
	lbl.ZIndex = 14
	lbl.Parent = header
	regTheme(lbl, "TextColor3", "Text")
	regText(lbl, 13, true)

	local btn = Instance.new("TextButton")
	btn.AnchorPoint = Vector2.new(1, 0.5)
	btn.Position = UDim2.new(1, 0, 0.5, 0)
	btn.Size = UDim2.new(0.44, 0, 0, 26)
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.BorderSizePixel = 0
	btn.ZIndex = 15
	btn.Parent = header
	regTheme(btn, "BackgroundColor3", "Card")
	regTheme(btn, "TextColor3", "Accent")
	regText(btn, 12, true)
	makeCorner(btn, 6, 0)
	makeStroke(btn, "Border", 1, 0.2)

	if desc ~= "" then
		local sub = Instance.new("TextLabel")
		sub.LayoutOrder = 2
		sub.Size = UDim2.new(1, 0, 0, 14)
		sub.AutomaticSize = Enum.AutomaticSize.Y
		sub.BackgroundTransparency = 1
		sub.TextWrapped = true
		sub.TextXAlignment = Enum.TextXAlignment.Left
		sub.Text = desc
		sub.ZIndex = 14
		sub.Parent = wrap
		regTheme(sub, "TextColor3", "SubText")
		regText(sub, 11, false)
	end

	local drawer = Instance.new("ScrollingFrame")
	drawer.LayoutOrder = 3
	drawer.Size = UDim2.new(1, 0, 0, 140)
	drawer.BackgroundTransparency = 0.1
	drawer.BorderSizePixel = 0
	drawer.ScrollBarThickness = 3
	drawer.AutomaticCanvasSize = Enum.AutomaticSize.Y
	drawer.CanvasSize = UDim2.new(0, 0, 0, 0)
	drawer.Visible = false
	drawer.ZIndex = 15
	drawer.Parent = wrap
	regTheme(drawer, "BackgroundColor3", "Card")
	makeCorner(drawer, 8, 0)

	local dl = Instance.new("UIListLayout")
	dl.SortOrder = Enum.SortOrder.LayoutOrder
	dl.Padding = UDim.new(0, 4)
	dl.Parent = drawer

	local function summary(): string
		local map = Config[cfgKey] :: { [string]: boolean }
		local count = 0
		for _, v in pairs(map) do
			if v then
				count += 1
			end
		end
		if count == 0 then
			return allLabel .. " ▾"
		end
		return "เลือกไว้ " .. tostring(count) .. " รายการ ▾"
	end

	local function paintBtn()
		btn.Text = summary()
	end

	local function rebuild()
		for _, ch in ipairs(drawer:GetChildren()) do
			if ch:IsA("TextButton") then
				ch:Destroy()
			end
		end
		local map = Config[cfgKey] :: { [string]: boolean }

		local clearBtn = Instance.new("TextButton")
		clearBtn.LayoutOrder = 0
		clearBtn.Size = UDim2.new(1, -6, 0, 24)
		clearBtn.Text = "ล้างตัวกรอง (" .. allLabel .. ")"
		clearBtn.AutoButtonColor = false
		clearBtn.BorderSizePixel = 0
		clearBtn.ZIndex = 16
		clearBtn.Parent = drawer
		regTheme(clearBtn, "BackgroundColor3", "AccentDark")
		regTheme(clearBtn, "TextColor3", "Text")
		regText(clearBtn, 11, true)
		makeCorner(clearBtn, 6, 0)
		clearBtn.MouseButton1Click:Connect(function()
			Config[cfgKey] = {}
			rebuild()
			paintBtn()
			UI.refreshAll()
		end)

		local idx = 1
		for _, opt in ipairs(optionsFn()) do
			local id = (type(opt) == "table") and (opt.id :: string) or (opt :: string)
			local name = (type(opt) == "table") and (opt.name :: string) or (opt :: string)
			if id ~= "All" then
				idx += 1
				local selected = map[id] == true
				local b = Instance.new("TextButton")
				b.LayoutOrder = idx
				b.Size = UDim2.new(1, -6, 0, 24)
				b.Text = (selected and "  ✓ " or "  ○ ") .. name
				b.TextXAlignment = Enum.TextXAlignment.Left
				b.AutoButtonColor = false
				b.BorderSizePixel = 0
				b.ZIndex = 16
				b.Parent = drawer
				regTheme(b, "BackgroundColor3", "Bg")
				regTheme(b, "TextColor3", selected and "Accent" or "Text")
				regText(b, 12, selected)
				makeCorner(b, 6, 0)
				b.MouseButton1Click:Connect(function()
					local tbl = Config[cfgKey] :: { [string]: boolean }
					tbl[id] = not (tbl[id] == true)
					if not tbl[id] then
						tbl[id] = nil
					end
					rebuild()
					paintBtn()
				end)
			end
		end
	end

	btn.MouseButton1Click:Connect(function()
		local nextOpen = not drawer.Visible
		if nextOpen then
			rebuild()
		end
		drawer.Visible = nextOpen
	end)
	table.insert(RefreshCallbacks, paintBtn)
	paintBtn()
end

function UI.button(parent: Frame, title: string, style: string, order: number, onClick: () -> ()): TextButton
	local role = "CardHover"
	local txtRole = "Text"
	if style == "accent" then
		role = "Accent"
	elseif style == "danger" then
		role = "Danger"
	elseif style == "success" then
		role = "Success"
		txtRole = "Bg"
	end

	local btn = Instance.new("TextButton")
	btn.LayoutOrder = order
	btn.Size = UDim2.new(1, 0, 0, 34)
	btn.Text = title
	btn.AutoButtonColor = false
	btn.BorderSizePixel = 0
	btn.ZIndex = 13
	btn.Parent = parent
	regTheme(btn, "BackgroundColor3", role)
	regTheme(btn, "TextColor3", txtRole)
	regText(btn, 13, true)
	makeCorner(btn, 8, 0)
	if style == "subtle" then
		makeStroke(btn, "Border", 1, 0.2)
	end
	btn.MouseButton1Click:Connect(function()
		onClick()
	end)
	return btn
end

function UI.inputRow(
	parent: Frame,
	placeholder: string,
	buttonLabel: string,
	order: number,
	onSubmit: (string) -> ()
): (Frame, TextBox)
	local row = Instance.new("Frame")
	row.LayoutOrder = order
	row.Size = UDim2.new(1, 0, 0, 36)
	row.BackgroundTransparency = 1
	row.ZIndex = 13
	row.Parent = parent

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -110, 1, 0)
	box.BackgroundTransparency = 0.2
	box.PlaceholderText = placeholder
	box.Text = ""
	box.ClearTextOnFocus = false
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.BorderSizePixel = 0
	box.ZIndex = 14
	box.Parent = row
	regTheme(box, "BackgroundColor3", "Bg")
	regTheme(box, "TextColor3", "Text")
	regTheme(box, "PlaceholderColor3", "SubText")
	regText(box, 12, false)
	makeCorner(box, 8, 0)

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 10)
	pad.PaddingRight = UDim.new(0, 8)
	pad.Parent = box

	local btn = Instance.new("TextButton")
	btn.AnchorPoint = Vector2.new(1, 0)
	btn.Position = UDim2.fromScale(1, 0)
	btn.Size = UDim2.new(0, 102, 1, 0)
	btn.Text = buttonLabel
	btn.AutoButtonColor = false
	btn.BorderSizePixel = 0
	btn.ZIndex = 14
	btn.Parent = row
	regTheme(btn, "BackgroundColor3", "Accent")
	regTheme(btn, "TextColor3", "Text")
	regText(btn, 12, true)
	makeCorner(btn, 8, 0)

	btn.MouseButton1Click:Connect(function()
		onSubmit(box.Text)
	end)
	return row, box
end

local ListeningKeybindId: string? = nil
function UI.keybindRow(parent: Frame, label: string, keyId: string, order: number)
	local row = Instance.new("Frame")
	row.LayoutOrder = order
	row.Size = UDim2.new(1, 0, 0, 34)
	row.BackgroundTransparency = 0.35
	row.BorderSizePixel = 0
	row.ZIndex = 13
	row.Parent = parent
	regTheme(row, "BackgroundColor3", "Bg")
	makeCorner(row, 8, 0)

	local lbl = Instance.new("TextLabel")
	lbl.Position = UDim2.fromOffset(10, 0)
	lbl.Size = UDim2.new(0.6, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = label
	lbl.ZIndex = 14
	lbl.Parent = row
	regTheme(lbl, "TextColor3", "Text")
	regText(lbl, 12, false)

	local bindBtn = Instance.new("TextButton")
	bindBtn.AnchorPoint = Vector2.new(1, 0.5)
	bindBtn.Position = UDim2.new(1, -8, 0.5, 0)
	bindBtn.Size = UDim2.fromOffset(124, 24)
	bindBtn.AutoButtonColor = false
	bindBtn.BorderSizePixel = 0
	bindBtn.ZIndex = 14
	bindBtn.Parent = row
	regTheme(bindBtn, "BackgroundColor3", "Card")
	regTheme(bindBtn, "TextColor3", "Accent")
	regText(bindBtn, 11, true)
	makeCorner(bindBtn, 6, 0)

	local function paint()
		local code = Config.Keybinds[keyId]
		bindBtn.Text = (ListeningKeybindId == keyId) and "กดปุ่มที่ต้องการ..." or Data.getKeyThaiName(code)
	end

	bindBtn.MouseButton1Click:Connect(function()
		ListeningKeybindId = keyId
		paint()
	end)
	table.insert(RefreshCallbacks, paint)
	paint()
end

function UI.applyThemeAndTypography()
	local theme = curTheme()
	local font = curFont()
	MainWindow.BackgroundTransparency = math.clamp(Config.BackgroundTransparency / 100, 0, 0.92)
	MainScale.Scale = math.clamp(Config.GuiScalePercent / 100, 0.55, 1.5)
	if BlurEffect then
		BlurEffect.Enabled = Runtime.WindowOpen and Config.BackgroundBlur
	end
	for _, entry in ipairs(ThemeRegistry) do
		if entry.Inst and entry.Inst.Parent and theme[entry.Role] then
			(entry.Inst :: any)[entry.Prop] = theme[entry.Role]
		end
	end
	for _, entry in ipairs(TextRegistry) do
		if entry.Inst and entry.Inst.Parent then
			(entry.Inst :: any).Font = font
			(entry.Inst :: any).TextSize = math.clamp(entry.BaseSize * (Config.FontSize / 14), 8, 96)
		end
	end
	ProfileChip.Text = "โปรไฟล์: " .. CurrentProfileName
	UI.selectTab(Runtime.CurrentTab)
	UI.refreshAll()
end

-- อัพเดตป้ายความขัดแย้งระหว่างโหมดแบบอินไลน์
function UI.setConflictBadge(cfgKey: string, text: string?)
	local badge = ConflictBadges[cfgKey]
	if not badge or not badge.Parent then
		return
	end
	if text and text ~= "" then
		badge.Text = text
		badge.Visible = true
	else
		badge.Text = ""
		badge.Visible = false
	end
end

-- ตัวเชื่อมต่อข้อมูลเกมและรีโมตทั้งหมดจากสคริปต์จริงของเกม
local GameAPI = {
	Modules = {} :: { [string]: any },
	ModuleStatus = {} :: { [string]: { State: string, RetryAt: number } },
	FieldSnapshot = {} :: { [string]: any },
	LastFieldPollAt = 0,
	FieldPolling = false,
	LastCarryPollAt = 0,
	RelocateCount = 0,
	FinishedEggs = {} :: { [string]: number },
	PinnedUids = {} :: { [string]: number },
	PinSeq = 0,
	SkippedUids = {} :: { [string]: number },
	NextActionByKey = {} :: { [string]: number },
}

local ModuleSpecs: { [string]: { string } } = {
	Remotes = { "Shared", "Remotes" },
	Save = { "Shared", "Save" },
	Preferences = { "Shared", "Preferences" },
	Ragdoll = { "Shared", "Modules", "Ragdoll" },
	PlacedEggRenderer = { "Shared", "Eggs", "PlacedEggRenderer" },
	EggRecords = { "Shared", "Util", "EggRecords" },
	AssetItems = { "Shared", "Util", "AssetItems" },
	AreaEggSlotIdentity = { "Shared", "Util", "AreaEggSlotIdentity" },
	EggState = { "Client", "EggState" },
	PlotState = { "Client", "PlotState" },
	BaseUpgrade = { "Client", "BaseUpgrade" },
	AssetsData = { "Data", "Assets" },
	TreadmillsData = { "Data", "Treadmills" },
	TrailsData = { "Data", "Trails" },
	FuseKernel = { "Shared", "Util", "FuseKernel" },
	Mutations = { "Shared", "Modules", "Mutations" },
	AreasData = { "Data", "Areas" },
	GuardsData = { "Data", "Guards" },
	AreaEggCycle = { "Shared", "Util", "AreaEggCycle" },
	AreaEggResetCycle = { "Data", "AreaEggResetCycle" },
	ServerClock = { "Shared", "Util", "ServerClock" },
	GameplayBalance = { "Shared", "Flags", "GameplayBalance" },
	EggLimits = { "Shared", "Types", "Eggs" },
	TreadmillUtil = { "Shared", "Util", "TreadmillUtil" },
	GuardEscapeRequirement = { "Shared", "Modules", "GuardAreas", "GuardEscapeRequirement" },
	GuardChasePolicy = { "Shared", "Modules", "GuardAreas", "GuardChasePolicy" },
	StaffMod = { "Shared", "Modules", "Staff" },
}

local function findByPath(root: Instance, segments: { string }): Instance?
	local cur: Instance? = root
	for _, seg in ipairs(segments) do
		if not cur then
			return nil
		end
		cur = cur:FindFirstChild(seg)
	end
	return cur
end

local function installModule(name: string, val: any)
	GameAPI.Modules[name] = val
	if name == "Save" and val.Watch then
		local ok, sig = pcall(val.Watch, "EquippedAssets")
		if ok and sig and sig.Connect then
			trackConn(sig, function()
				Runtime.EquipRevision += 1
			end)
		end
	elseif name == "EggState" then
		if val.CarryChanged and val.CarryChanged.Connect then
			trackConn(val.CarryChanged, function(state)
				Runtime.CarryRevision += 1
				Runtime.LastCarryState = state
			end)
		end
		if val.ResetCountdown and val.ResetCountdown.Connect then
			trackConn(val.ResetCountdown, function(seq)
				if type(seq) == "table" and type(seq.DayStartsAt) == "number" then
					Runtime.FieldResetDay = seq.DayStartsAt
				end
			end)
		end
	elseif name == "AssetsData" and type(val.Directory) == "table" then
		local entries: { { id: string, name: string, order: number } } = {}
		for id, cfg in pairs(val.Directory) do
			if type(id) == "string" and type(cfg) == "table" then
				local old = Data.SpeciesById[id]
				table.insert(entries, {
					id = id,
					name = old and old.name or tostring(cfg.DisplayName or id),
					order = old and old.order or math.huge,
				})
				local rarity = cfg.Rarity
				if type(rarity) == "table" and type(rarity._id) == "string" then
					if Data.RarityById[rarity._id] and type(rarity.Rank) == "number" then
						Data.RarityById[rarity._id].rank = rarity.Rank
					elseif not Data.RarityById[rarity._id] then
						local rEntry = {
							id = rarity._id,
							name = tostring(rarity.DisplayName or rarity._id),
							rank = tonumber(rarity.Order or rarity.Rank) or 0,
							color = rarity.Color or Color3.fromRGB(220, 220, 230),
						}
						Data.RarityById[rEntry.id] = rEntry
						table.insert(Data.RarityList, rEntry)
					end
				end
			end
		end
		table.sort(entries, function(a, b)
			if a.order ~= b.order then
				return a.order < b.order
			end
			return a.id < b.id
		end)
		table.clear(Data.SpeciesList)
		table.clear(Data.SpeciesById)
		local allEntry = { id = "All", name = "ทุกสายพันธุ์", order = 0 }
		table.insert(Data.SpeciesList, allEntry)
		Data.SpeciesById.All = allEntry
		for i, entry in ipairs(entries) do
			entry.order = i
			table.insert(Data.SpeciesList, entry)
			Data.SpeciesById[entry.id] = entry
		end
	end
end

function GameAPI.loadModules()
	local now = os.clock()
	for name, path in pairs(ModuleSpecs) do
		local st = GameAPI.ModuleStatus[name]
		if not st or (st.State ~= "ready" and st.State ~= "loading" and now >= st.RetryAt) then
			local inst = findByPath(ReplicatedStorage, path)
			if not inst then
				GameAPI.ModuleStatus[name] = { State = "missing", RetryAt = now + 3 }
			else
				local pending = { State = "loading", RetryAt = now + 5 }
				GameAPI.ModuleStatus[name] = pending
				task.spawn(function()
					local ok, mod = pcall(require, inst :: any)
					if not Runtime.Running then
						return
					end
					if ok and type(mod) == "table" then
						installModule(name, mod)
						pending.State = "ready"
					else
						pending.State = "error"
					end
				end)
			end
		end
	end
end

function GameAPI.remote(ns: string, name: string, kind: string?): Instance?
	local rem = GameAPI.Modules.Remotes
	if rem and type(rem[ns]) == "table" and rem[ns][name] then
		return rem[ns][name]
	end
	local pkgs = ReplicatedStorage:FindFirstChild("Packages")
	local net = pkgs and pkgs:FindFirstChild("Networking")
	if net then
		local prefix = (kind == "function") and "RemoteFunction" or "RemoteEvent"
		local direct = net:FindFirstChild(prefix .. "/" .. ns .. "/" .. name)
		if direct then
			return direct
		end
		local altPrefix = (kind == "function") and "RemoteEvent" or "RemoteFunction"
		local alt = net:FindFirstChild(altPrefix .. "/" .. ns .. "/" .. name)
		if alt then
			return alt
		end
	end
	return nil
end

function GameAPI.invoke(ns: string, name: string, ...): (boolean, ...any)
	local rf = GameAPI.remote(ns, name, "function")
	if not rf or not rf:IsA("RemoteFunction") then
		return false, "ไม่พบรีโมต"
	end
	return pcall(rf.InvokeServer, rf, ...)
end

function GameAPI.fire(ns: string, name: string, ...): boolean
	local re = GameAPI.remote(ns, name, "event")
	if not re or not re:IsA("RemoteEvent") then
		return false
	end
	local ok = pcall(re.FireServer, re, ...)
	return ok
end

function GameAPI.cooldownReady(key: string, sec: number): boolean
	local now = os.clock()
	if (GameAPI.NextActionByKey[key] or 0) > now then
		return false
	end
	GameAPI.NextActionByKey[key] = now + sec
	return true
end

function GameAPI.formatNum(n: number?): string
	local v = tonumber(n) or 0
	if v >= 1e12 then
		return string.format("%.2fT", v / 1e12)
	elseif v >= 1e9 then
		return string.format("%.2fB", v / 1e9)
	elseif v >= 1e6 then
		return string.format("%.2fM", v / 1e6)
	elseif v >= 1e3 then
		return string.format("%.1fK", v / 1e3)
	end
	return tostring(math.floor(v + 0.5))
end

function GameAPI.flat(v: Vector3): Vector3
	return Vector3.new(v.X, 0, v.Z)
end

function GameAPI.distXZ(a: Vector3, b: Vector3): number
	return (Vector3.new(a.X, 0, a.Z) - Vector3.new(b.X, 0, b.Z)).Magnitude
end

function GameAPI.fieldAreas(): Folder?
	local w = Workspace:FindFirstChild("World")
	local areas = w and w:FindFirstChild("Areas")
	return (areas and areas:IsA("Folder")) and areas or nil
end

function GameAPI.separationLine(): BasePart?
	local areas = GameAPI.fieldAreas()
	local line = areas and areas:FindFirstChild("SeparationLine")
	return (line and line:IsA("BasePart")) and line or nil
end

function GameAPI.inGameplay(pos: Vector3): boolean
	local line = GameAPI.separationLine()
	if not line then
		return false
	end
	return line.CFrame.LookVector:Dot(pos - line.Position) > 0
end

function GameAPI.fieldTime(): number
	local clk = GameAPI.Modules.ServerClock
	if clk and type(clk.Now) == "function" then
		local ok, t = pcall(clk.Now)
		if ok and type(t) == "number" then
			return t
		end
	end
	return Workspace:GetServerTimeNow()
end

function GameAPI.isFieldResetting(): boolean
	local areas = GameAPI.fieldAreas()
	local wall = areas and areas:FindFirstChild("WallStartCollision")
	local solid = false
	if wall then
		if wall:IsA("BasePart") and wall.CanCollide then
			solid = true
		else
			for _, d in ipairs(wall:GetDescendants()) do
				if d:IsA("BasePart") and d.CanCollide then
					solid = true
					break
				end
			end
		end
	end
	if not Workspace:GetAttribute("Event_AdminAbuse") then
		local cycle = GameAPI.Modules.AreaEggCycle
		local cfg = GameAPI.Modules.AreaEggResetCycle or {}
		local now = GameAPI.fieldTime()
		local delaySec = (tonumber(cfg.WallCountdownDelayAfterDayStartsSeconds) or 2)
			+ (tonumber(cfg.WallCountdownSeconds) or 3)
		if cycle and type(cycle.IsRunning) == "function" then
			local okRun, isRun = pcall(cycle.IsRunning)
			if okRun and isRun then
				local okN, isNight = pcall(cycle.IsNightPhase, now)
				if okN and isNight then
					solid = true
				elseif type(cycle.PeriodIndexAt) == "function" and type(cycle.PeriodStartTime) == "function" then
					local okP, idx = pcall(cycle.PeriodIndexAt, now)
					if okP then
						local okS, startT = pcall(cycle.PeriodStartTime, idx)
						if okS and type(startT) == "number" and now < startT + delaySec + 0.35 then
							solid = true
						end
					end
				end
				if type(cycle.NightStartTime) == "function" then
					local okNS, nt = pcall(cycle.NightStartTime, now)
					if okNS and type(nt) == "number" then
						Runtime.FieldClosesAt = nt
					end
				end
			end
		elseif Runtime.FieldResetDay and now < Runtime.FieldResetDay + delaySec + 0.35 then
			solid = true
		end
	end
	Runtime.FieldResetting = solid
	return solid
end

function GameAPI.getSave(): { [string]: any }?
	local SaveMod = GameAPI.Modules.Save
	if not SaveMod then
		return nil
	end
	if type(SaveMod.Get) == "function" then
		local ok, data = pcall(SaveMod.Get)
		if ok and type(data) == "table" then
			return data
		end
	end
	if type(SaveMod.Await) == "function" then
		local ok, data = pcall(SaveMod.Await)
		if ok and type(data) == "table" then
			return data
		end
	end
	return nil
end

function GameAPI.getMyPlot(): Instance?
	local plots = Workspace:FindFirstChild("Plots")
	if not plots then
		return nil
	end
	local uid = LocalPlayer.UserId
	local uidStr = tostring(uid)
	for _, plot in ipairs(plots:GetChildren()) do
		local owner = plot:GetAttribute("OwnerUserId") or plot:GetAttribute("Owner") or plot:GetAttribute("UserId")
		if owner == uid or tostring(owner) == uidStr or plot.Name == uidStr then
			return plot
		end
		local ownerVal = plot:FindFirstChild("Owner")
		if ownerVal and ownerVal:IsA("ObjectValue") and ownerVal.Value == LocalPlayer then
			return plot
		end
		if ownerVal and (ownerVal:IsA("IntValue") or ownerVal:IsA("StringValue")) and tostring(ownerVal.Value) == uidStr then
			return plot
		end
	end
	local plotState = GameAPI.Modules.PlotState
	if plotState and type(plotState.GetMyPlot) == "function" then
		local ok, p = pcall(plotState.GetMyPlot)
		if ok and typeof(p) == "Instance" then
			return p
		end
	end
	return nil
end

function GameAPI.getCarryState(): any
	local es = GameAPI.Modules.EggState
	if es then
		local readFn = es.ReadCarryState or es.GetCarryState
		if type(readFn) == "function" then
			local ok, st = pcall(readFn)
			if ok and type(st) == "table" and type(st.IsCarrying) == "boolean" then
				Runtime.LastCarryState = st
				return st
			end
		end
	end
	if os.clock() - GameAPI.LastCarryPollAt > 0.35 then
		GameAPI.LastCarryPollAt = os.clock()
		local ok, snap = GameAPI.invoke("EggWorld", "AskLiveSnapshot")
		if ok and type(snap) == "table" and type(snap.Carry) == "table" then
			Runtime.LastCarryState = snap.Carry
		end
	end
	return Runtime.LastCarryState
end

function GameAPI.eggMetrics(record: { [string]: any }): {
	SpeciesId: string,
	DisplayName: string,
	AreaId: string,
	RarityId: string,
	RarityThai: string,
	RarityRank: number,
	RarityColor: Color3,
	MutationId: string,
	MutationThai: string,
	MutationMult: number,
	Income: number,
	Scale: number,
	CanPickUp: boolean,
}
	local cat = tostring(record.AssetCategory or record.Species or record.Category or "Unknown")
	local assetsDir = GameAPI.Modules.AssetsData and GameAPI.Modules.AssetsData.Directory
	local cfg = (type(assetsDir) == "table") and assetsDir[cat] or nil

	local rarityId = "Common"
	local rarityColor = Color3.fromRGB(190, 195, 205)
	if type(record.Rarity) == "string" then
		rarityId = record.Rarity
	elseif type(cfg) == "table" and type(cfg.Rarity) == "table" then
		rarityId = tostring(cfg.Rarity._id or cfg.Rarity.DisplayName or "Common")
		if typeof(cfg.Rarity.Color) == "Color3" then
			rarityColor = cfg.Rarity.Color
		end
	elseif type(cfg) == "table" and type(cfg.Rarity) == "string" then
		rarityId = cfg.Rarity
	end

	local rInfo = Data.RarityById[rarityId]
	local rarityRank = (type(cfg) == "table" and type(cfg.Rarity) == "table" and tonumber(cfg.Rarity.RarityNumber or cfg.Rarity.Rank))
		or (rInfo and rInfo.rank)
		or 1
	local rarityThai = rInfo and rInfo.name or rarityId
	if rInfo and typeof(rInfo.color) == "Color3" then
		rarityColor = rInfo.color
	end

	local mutId = tostring(record.Mutation or record.MutationId or "None")
	if mutId == "" or mutId == "None" then
		if type(record.Mutations) == "table" then
			for k, v in pairs(record.Mutations) do
				if v then
					mutId = (type(k) == "string") and k or tostring(v)
					break
				end
			end
		end
	end
	if mutId == "" then
		mutId = "None"
	end
	local mutThai = Data.MutationThaiById[mutId] or mutId
	local mutMult = tonumber(record.MutationMultiplier) or 1
	local mutMod = GameAPI.Modules.Mutations
	if mutMod and type(mutMod.EarningsFor) == "function" and type(record.Mutations) == "table" then
		local okE, res = pcall(mutMod.EarningsFor, record.Mutations)
		if okE and type(res) == "number" then
			mutMult = res
		end
	elseif mutMod and mutId ~= "None" and type(mutMod.Get) == "function" then
		local okM, mCfg = pcall(mutMod.Get, mutId)
		if okM and type(mCfg) == "table" then
			mutMult = tonumber(mCfg.Multiplier or mCfg.IncomeMultiplier) or mutMult
		end
	end

	local scale = math.max(0, tonumber(record.AssetScale or record.Scale or record.Weight) or 1)
	local baseIncome = (type(cfg) == "table" and tonumber(cfg.EarningRate or cfg.BaseIncome or cfg.IncomePerSecond or cfg.Earnings))
		or tonumber(record.IncomePerSecond or record.Income or record.Earnings)
		or 0
	local scaleFactor = (scale > 5) and ((scale / 5) ^ 1.2 * 19.637875755794113) or (scale ^ 1.85)
	local income = baseIncome * scaleFactor * mutMult

	local areaId = tostring(record.AreaId or record.Area or "Forest")
	local displayName = tostring((Data.SpeciesById[cat] and Data.SpeciesById[cat].name) or (cfg and cfg.DisplayName) or cat)
	local stateStr = tostring(record.State or "Slot")
	local canPick = (stateStr == "Slot" or stateStr == "Dropped")
		and record.FieldEggSpawnable ~= false
		and record.Locked ~= true
		and record.Claimed ~= true

	return {
		SpeciesId = cat,
		DisplayName = displayName,
		AreaId = areaId,
		RarityId = rarityId,
		RarityThai = rarityThai,
		RarityRank = rarityRank,
		RarityColor = rarityColor,
		MutationId = mutId,
		MutationThai = mutThai,
		MutationMult = mutMult,
		Income = income,
		Scale = scale,
		CanPickUp = canPick,
	}
end

function GameAPI.pollFieldSnapshotAsync(force: boolean?)
	local now = os.clock()
	if GameAPI.FieldPolling then
		return
	end
	if not force and now - GameAPI.LastFieldPollAt < 0.35 then
		return
	end
	GameAPI.FieldPolling = true
	GameAPI.LastFieldPollAt = now
	task.spawn(function()
		local ok, snap = GameAPI.invoke("EggWorld", "AskFieldEggSnapshot")
		if ok and type(snap) == "table" then
			GameAPI.FieldSnapshot = snap
		end
		GameAPI.FieldPolling = false
	end)
end

function GameAPI.eggWorldPos(uid: string, record: { [string]: any }?): Vector3?
	local model = Workspace:FindFirstChild(uid)
	if not model then
		local slots = Workspace:FindFirstChild("AreaEggSlotsClient")
		model = slots and slots:FindFirstChild(uid) or nil
	end
	if model and model:IsA("Model") then
		local hitbox = model:FindFirstChild("Hitbox", true)
		if hitbox and hitbox:IsA("BasePart") then
			return hitbox.Position
		end
		return model:GetPivot().Position
	end
	if record then
		local cf = record.BottomCFrame or record.BoundsCFrame
		if typeof(cf) == "CFrame" then
			return cf.Position
		elseif type(cf) == "table" and #cf >= 3 then
			return Vector3.new(tonumber(cf[1]) or 0, tonumber(cf[2]) or 0, tonumber(cf[3]) or 0)
		end
	end
	return nil
end

function GameAPI.getFieldEggs(): { { Uid: string, Record: { [string]: any }, Metrics: any, Pos: Vector3, Dist: number, PinOrder: number } }
	local out: { any } = {}
	local root = getRoot()
	local myPos = root and root.Position or Vector3.zero
	local now = os.clock()

	for uid, rec in pairs(GameAPI.FieldSnapshot) do
		if type(uid) == "string" and type(rec) == "table" then
			local skipUntil = GameAPI.SkippedUids[uid]
			if not skipUntil or now >= skipUntil then
				GameAPI.SkippedUids[uid] = nil
				local metrics = GameAPI.eggMetrics(rec)
				local pos = GameAPI.eggWorldPos(uid, rec)
				if pos and metrics.CanPickUp then
					table.insert(out, {
						Uid = uid,
						Record = rec,
						Metrics = metrics,
						Pos = pos,
						Dist = (pos - myPos).Magnitude,
						PinOrder = GameAPI.PinnedUids[uid] or math.huge,
					})
				end
			end
		end
	end
	return out
end

function GameAPI.getGuards(): { { Model: Model, Root: BasePart, Area: string, State: string, Dist: number, AlertDist: number } }
	local out: { any } = {}
	local areas = GameAPI.fieldAreas()
	local guardAreas = areas and areas:FindFirstChild("GuardAreas")
	if not guardAreas then
		return out
	end
	local root = getRoot()
	local myPos = root and root.Position or Vector3.zero
	local areasDir = GameAPI.Modules.AreasData and GameAPI.Modules.AreasData.Directory
	local guardsDir = GameAPI.Modules.GuardsData and GameAPI.Modules.GuardsData.Directory

	for _, area in ipairs(guardAreas:GetChildren()) do
		local guard = area:FindFirstChild("Guard")
		if guard and guard:IsA("Model") and guard:GetAttribute("Hidden") ~= true then
			local gRoot = guard:FindFirstChild("HumanoidRootPart")
			if gRoot and gRoot:IsA("BasePart") then
				local areaCfg = type(areasDir) == "table" and areasDir[area.Name] or nil
				local gCfg = (areaCfg and type(guardsDir) == "table") and guardsDir[areaCfg.GuardId] or nil
				local range = tonumber(gCfg and (gCfg.EggPickupDistance or gCfg.HitDistance)) or 14
				local st = tostring(guard:GetAttribute("State") or guard:GetAttribute("GuardState") or "Patrol")
				table.insert(out, {
					Model = guard,
					Root = gRoot,
					Area = area.Name,
					State = st,
					Dist = (gRoot.Position - myPos).Magnitude,
					AlertDist = range,
				})
			end
		end
	end
	return out
end

-- หยุดการตรวจจังหวะการเคลื่อนที่ฝั่งลูกข่ายระหว่างขนส่งความเร็วสูง
local PausedConns: { any } = {}
function GameAPI.pauseUGIChecks()
	Workspace:SetAttribute("ClientObbyAntiTp", false)
	if not Exec.getConns then
		return
	end
	for _, sig in ipairs({ RunService.Heartbeat, RunService.Stepped }) do
		local okC, list = pcall(Exec.getConns, sig)
		if okC and type(list) == "table" then
			for _, conn in ipairs(list) do
				local fn = conn and conn.Function
				if type(fn) == "function" then
					local src = tostring(debug.info(fn, "s") or "")
					if string.find(src, "ObbyAntiTP") or string.find(src, "UGI") or string.find(src, "IdleRescue") then
						pcall(function()
							conn:Disable()
							table.insert(PausedConns, conn)
						end)
					end
				end
			end
		end
	end
end

function GameAPI.restoreUGIChecks()
	for _, conn in ipairs(PausedConns) do
		pcall(function()
			conn:Enable()
		end)
	end
	table.clear(PausedConns)
end
onCleanup(GameAPI.restoreUGIChecks)

-- เริ่มเชื่อมต่ออีเวนต์ Relocate จากเซิร์ฟเวอร์แบบเรียลไทม์
task.spawn(function()
	while Runtime.Running do
		GameAPI.loadModules()
		local reloc = GameAPI.remote("RigSync", "Refresh", "event")
		if reloc and reloc:IsA("RemoteEvent") then
			trackConn(reloc.OnClientEvent, function(payload: any)
				if type(payload) == "string" then
					local ok, dec = pcall(HttpService.JSONDecode, HttpService, payload)
					if ok then
						payload = dec
					end
				end
				if type(payload) == "table" and payload.Action == "Relocate" then
					GameAPI.RelocateCount += 1
				end
			end)
			break
		end
		task.wait(1)
	end
end)

-- เครื่องยนต์ขโมยไข่อัจฉริยะ ระบบฟาร์ม และระบบเล่นอัตโนมัติครบวงจร
local Steal = {
	Busy = false,
	ActiveUid = nil :: string?,
	ForcedUid = nil :: string?,
	LastStealAt = 0,
	SuccessCount = 0,
	AbortRequested = false,
}

local Farm = {
	LastPlaceAt = 0,
	LastHatchAt = 0,
	LastEquipAt = 0,
	LastSellAt = 0,
	LastFuseAt = 0,
	LastUpgradeAt = 0,
	LastTrailAt = 0,
	TreadmillPhase = "idle", -- "running" | "resting" | "idle"
	TreadmillPhaseUntil = 0,
}

function GameAPI.matchesFilterMap(map: { [string]: boolean }?, value: string): boolean
	if type(map) ~= "table" or not next(map) then
		return true
	end
	return map[value] == true
end

function GameAPI.isMissingInIndex(speciesId: string): boolean
	local save = GameAPI.getSave()
	if not save then
		return false
	end
	for _, key in ipairs({ "Index", "PetIndex", "Collection", "Dex", "UnlockedPets", "DiscoveredPets" }) do
		local tbl = save[key]
		if type(tbl) == "table" then
			if (tbl[speciesId] ~= nil and tbl[speciesId] ~= false and tbl[speciesId] ~= 0)
				or (type(tbl.Pets) == "table" and tbl.Pets[speciesId])
				or (type(tbl.Unlocked) == "table" and tbl.Unlocked[speciesId]) then
				return false
			end
		end
	end
	return true
end

function GameAPI.isMissingInLab(speciesId: string): boolean
	local save = GameAPI.getSave()
	if not save then
		return false
	end
	for _, key in ipairs({ "DrScramble", "Lab", "DrScrambleLab", "SubmittedPets", "Events" }) do
		local tbl = save[key]
		if type(tbl) == "table" then
			if (tbl[speciesId] ~= nil and tbl[speciesId] ~= false and tbl[speciesId] ~= 0)
				or (type(tbl.Submitted) == "table" and tbl.Submitted[speciesId])
				or (type(tbl.Completed) == "table" and tbl.Completed[speciesId]) then
				return false
			end
		end
	end
	return true
end

function GameAPI.getSortedStealCandidates(): { any }
	local raw = GameAPI.getFieldEggs()
	local minRInfo = Data.RarityById[Config.StealMinRarity]
	local minRank = minRInfo and minRInfo.rank or 0
	local minIncome = tonumber(Config.StealMinIncome) or 0
	local bypassFilters = (Config.FullAutoPlay == true)
		and not next(Config.StealAreas)
		and not next(Config.StealRarities)
		and not next(Config.StealMutations)
		and not next(Config.StealSpecies)
		and minRank == 0
		and minIncome == 0

	local list: { any } = {}
	for _, item in ipairs(raw) do
		local m = item.Metrics
		local pinned = GameAPI.PinnedUids[item.Uid] ~= nil
		local ok = pinned or bypassFilters or (
			GameAPI.matchesFilterMap(Config.StealAreas, m.AreaId)
			and GameAPI.matchesFilterMap(Config.StealRarities, m.RarityId)
			and GameAPI.matchesFilterMap(Config.StealMutations, m.MutationId)
			and GameAPI.matchesFilterMap(Config.StealSpecies, m.SpeciesId)
			and m.RarityRank >= minRank
			and m.Income >= minIncome
			and (not Config.StealOnlyMissingIndex or GameAPI.isMissingInIndex(m.SpeciesId))
			and (not Config.StealOnlyMissingLab or GameAPI.isMissingInLab(m.SpeciesId))
		)
		if ok then
			table.insert(list, item)
		end
	end

	local order = Config.StealOrder or "IncomeHigh"
	table.sort(list, function(a, b)
		if a.PinOrder ~= b.PinOrder then
			return a.PinOrder < b.PinOrder
		end
		local ma, mb = a.Metrics, b.Metrics
		if order == "Rarity" then
			if ma.RarityRank ~= mb.RarityRank then return ma.RarityRank > mb.RarityRank end
		elseif order == "Mutation" then
			if ma.MutationMult ~= mb.MutationMult then return ma.MutationMult > mb.MutationMult end
		elseif order == "Weight" then
			if ma.Scale ~= mb.Scale then return ma.Scale > mb.Scale end
		elseif order == "Distance" then
			if math.abs(a.Dist - b.Dist) > 1 then return a.Dist < b.Dist end
		elseif order == "IncomeLow" then
			if ma.Income ~= mb.Income then return ma.Income < mb.Income end
		end
		if ma.Income ~= mb.Income then
			return ma.Income > mb.Income
		end
		return a.Dist < b.Dist
	end)
	return list
end

function GameAPI.pinTop(uid: string)
	local minOrder = math.huge
	for _, v in pairs(GameAPI.PinnedUids) do
		if v < minOrder then minOrder = v end
	end
	if minOrder == math.huge then
		GameAPI.PinSeq += 1
		GameAPI.PinnedUids[uid] = GameAPI.PinSeq
	else
		GameAPI.PinnedUids[uid] = minOrder - 1
	end
end

function GameAPI.movePin(uid: string, delta: number)
	local sorted = GameAPI.getSortedStealCandidates()
	for i, item in ipairs(sorted) do
		if item.Uid == uid then
			local targetIdx = math.clamp(i + delta, 1, #sorted)
			if targetIdx ~= i then
				local other = sorted[targetIdx]
				local myOrder = GameAPI.PinnedUids[uid] or i
				local otherOrder = GameAPI.PinnedUids[other.Uid] or targetIdx
				GameAPI.PinnedUids[uid] = otherOrder
				GameAPI.PinnedUids[other.Uid] = myOrder
			end
			break
		end
	end
end

function GameAPI.skipEgg(uid: string, sec: number?)
	GameAPI.PinnedUids[uid] = nil
	GameAPI.SkippedUids[uid] = os.clock() + (sec or 45)
end

-- ระบบเคลื่อนที่ความเร็วสูงแบบก้าวเหินเวหาและป้องกันตัวดีดกลับ
local function stepGlideTowards(
	root: BasePart,
	hum: Humanoid,
	targetPos: Vector3,
	strideLen: number,
	cadenceSec: number,
	hoverHeight: number,
	shouldStop: () -> boolean
): (boolean, boolean)
	local rot = root.CFrame.Rotation
	local relocStart = GameAPI.RelocateCount
	local curStride = strideLen
	local curCadence = cadenceSec
	local maxIter = 260

	for _ = 1, maxIter do
		if not Runtime.Running or shouldStop() or not root.Parent or hum.Health <= 0 then
			return false, false
		end
		local flatDelta = GameAPI.flat(targetPos - root.Position)
		local flatDist = flatDelta.Magnitude
		if flatDist <= 4.0 then
			local finalPt = Vector3.new(targetPos.X, targetPos.Y, targetPos.Z)
			root.CFrame = CFrame.new(finalPt) * rot
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			RunService.Heartbeat:Wait()
			return true, (GameAPI.RelocateCount > relocStart)
		end

		if GameAPI.RelocateCount > relocStart then
			relocStart = GameAPI.RelocateCount
			curStride = math.max(14, curStride - 4)
			curCadence = math.min(0.18, curCadence + 0.02)
		end

		local dir = flatDelta.Unit
		local stepDist = math.min(curStride, flatDist)
		local nextFlat = root.Position + dir * stepDist
		local flyY = math.max(root.Position.Y, targetPos.Y, hoverHeight)
		local nextPt = Vector3.new(nextFlat.X, flyY, nextFlat.Z)

		local waited = 0
		while waited < curCadence do
			if not Runtime.Running or shouldStop() or not root.Parent then
				return false, false
			end
			root.CFrame = CFrame.new(nextPt) * rot
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			waited += RunService.Heartbeat:Wait()
		end
	end
	return false, false
end

local function stepGroundRunTowards(
	root: BasePart,
	hum: Humanoid,
	targetPos: Vector3,
	speed: number,
	reach: number,
	shouldStop: () -> boolean
): boolean
	local deadline = os.clock() + 14
	local lastJump = 0
	while Runtime.Running and os.clock() < deadline and not shouldStop() and root.Parent and hum.Health > 0 do
		local delta = targetPos - root.Position
		local flat = GameAPI.flat(delta)
		if delta.Magnitude <= reach or flat.Magnitude <= reach then
			hum:Move(Vector3.zero, false)
			root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
			return true
		end
		local dir = flat.Unit
		hum.WalkSpeed = math.max(speed, 16)
		hum:Move(dir, false)
		root.AssemblyLinearVelocity = Vector3.new(dir.X * speed, root.AssemblyLinearVelocity.Y, dir.Z * speed)
		if os.clock() - lastJump > 0.35 then
			local rp = RaycastParams.new()
			rp.FilterType = Enum.RaycastFilterType.Exclude
			local ch = getChar()
			if ch then
				rp.FilterDescendantsInstances = { ch }
			end
			local wallHit = Workspace:Raycast(root.Position, dir * 5.5, rp)
			if wallHit or (targetPos.Y - root.Position.Y > 3.5 and flat.Magnitude < 12) then
				hum.Jump = true
				lastJump = os.clock()
			end
		end
		RunService.Heartbeat:Wait()
	end
	return false
end

local function armStealProtections()
	if Config.DisarmObbyAntiTP then
		Workspace:SetAttribute("ClientObbyAntiTp", false)
	end
	if Config.AntiFall or (Config.AntiGuard and Config.AntiGuardMode ~= "สกัดสัญญานยามป่า") then
		local ragMod = GameAPI.Modules.Ragdoll
		if ragMod and type(ragMod.Ragdoll) == "function" and not (ragMod :: any).__OrigRagdoll then
			(ragMod :: any).__OrigRagdoll = ragMod.Ragdoll
			ragMod.Ragdoll = function() end
		end
	end
	GameAPI.pauseUGIChecks()
end

local function computeLineGoal(targetRef: Vector3, sideSign: number): (Vector3?, Vector3?)
	local line = GameAPI.separationLine()
	if not line then
		return nil, nil
	end
	local right = GameAPI.flat(line.CFrame.RightVector).Unit
	local look = GameAPI.flat(line.CFrame.LookVector).Unit
	local span = line.Size.X * 0.45
	local lateral = math.clamp(right:Dot(targetRef - line.Position), -span, span)
	local pt = line.Position + right * lateral + look * (sideSign * 9)
	return Vector3.new(pt.X, line.Position.Y + 4, pt.Z), look
end

function Steal.attemptStealEgg(eggItem: any)
	if Steal.Busy or not Runtime.Running then
		return
	end
	local root = getRoot()
	local hum = getHum()
	if not root or not hum or hum.Health <= 0 then
		return
	end
	if GameAPI.isFieldResetting() then
		UI.setStatus("รอกำแพงสนามเปิดรอบใหม่...", "wait", 0.1)
		return
	end

	Steal.Busy = true
	Steal.ActiveUid = eggItem.Uid
	Steal.AbortRequested = false
	Runtime.ManualTreadmillStop = true
	armStealProtections()

	local m = eggItem.Metrics
	local eggLabel = m.DisplayName .. " (" .. m.RarityThai .. ")"
	local function aborted(): boolean
		return Steal.AbortRequested
			or (not Config.AutoStealEgg and not Config.FullAutoPlay and Steal.ForcedUid == nil)
			or GameAPI.isFieldResetting()
	end

	-- ขั้นตอนที่ 1: ขาไปหาไข่ให้เร็วที่สุด
	UI.setStatus("กำลังพุ่งไปขโมย: " .. eggLabel, "steal", 0.25)
	if not GameAPI.inGameplay(root.Position) then
		local entryGoal = computeLineGoal(eggItem.Pos, 1)
		if entryGoal then
			if Config.StealOutboundMode == "เหินเวหาข้ามยามอัตโนมัติ" then
				local baseH = math.max(root.Position.Y, entryGoal.Y, eggItem.Pos.Y) + 12
				stepGlideTowards(root, hum, entryGoal, math.clamp(Config.StealReturnStride, 16, 34), math.clamp(Config.StealReturnCadence, 0.04, 0.2), baseH, aborted)
			else
				stepGroundRunTowards(root, hum, entryGoal, math.clamp(Config.StealGoSpeed, 24, 300), 6, aborted)
			end
		end
	end

	if aborted() then
		Steal.Busy = false
		Steal.ActiveUid = nil
		return
	end

	local approachPos = Vector3.new(eggItem.Pos.X, eggItem.Pos.Y + 2.5, eggItem.Pos.Z)
	if Config.StealOutboundMode == "เหินเวหาข้ามยามอัตโนมัติ" then
		local baseH = math.max(root.Position.Y, eggItem.Pos.Y) + 12
		stepGlideTowards(root, hum, approachPos, math.clamp(Config.StealReturnStride, 16, 34), math.clamp(Config.StealReturnCadence, 0.04, 0.2), baseH, aborted)
	else
		stepGroundRunTowards(root, hum, approachPos, math.clamp(Config.StealGoSpeed, 24, 300), 6.5, aborted)
	end

	if aborted() then
		Steal.Busy = false
		Steal.ActiveUid = nil
		return
	end

	-- ขั้นตอนที่ 2: เก็บไข่จากเซิร์ฟเวอร์ทันที
	UI.setStatus("กำลังคว้าไข่: " .. eggLabel, "busy", 0.55)
	pcall(function()
		hum:UnequipTools()
	end)
	local slotKey: any = nil
	local idMod = GameAPI.Modules.AreaEggSlotIdentity
	if idMod and type(idMod.LooksLikeFirstAreaUid) == "function" and idMod.LooksLikeFirstAreaUid(eggItem.Uid) then
		slotKey = idMod.SlotKey(eggItem.Record.AreaId, eggItem.Record.NestId)
	end

	local carried = false
	for attempt = 1, 3 do
		if aborted() then break end
		local okInv, okCarry = GameAPI.invoke("EggWorld", "AskFieldEggCarry", {
			Uid = eggItem.Uid,
			FirstAreaSlotKey = slotKey,
		})
		if okInv and okCarry then
			carried = true
			break
		end
		-- สำรองด้วย ProximityPrompt บนโมเดลถ้ามี
		local eggModel = Workspace:FindFirstChild(eggItem.Uid)
		if eggModel and Exec.firePrompt then
			local pp = eggModel:FindFirstChildOfClass("ProximityPrompt") or eggModel:FindFirstChildWhichIsA("ProximityPrompt", true)
			if pp then
				pcall(Exec.firePrompt, pp)
			end
		end
		task.wait(0.06 * attempt)
		local st = GameAPI.getCarryState()
		if type(st) == "table" and st.IsCarrying and st.Uid == eggItem.Uid then
			carried = true
			break
		end
	end

	if not carried then
		GameAPI.skipEgg(eggItem.Uid, 8)
		Steal.Busy = false
		Steal.ActiveUid = nil
		Steal.ForcedUid = nil
		UI.setStatus("คว้าไข่ไม่ติด ข้ามชั่วคราวไปฟองถัดไป", "wait", 0.1)
		return
	end

	-- ขั้นตอนที่ 3: ขากลับฐานสุดแรงพร้อมกันโดนตีหล่น
	UI.setStatus("ได้ไข่แล้ว กำลังซิ่งกลับเขตปลอดภัย!", "steal", 0.78)
	local homeGoal = computeLineGoal(root.Position, -1)
	local myPlot = GameAPI.getMyPlot()
	local plotPos = myPlot and (myPlot :: Model):GetPivot().Position or nil
	local finalDest = homeGoal or plotPos or Vector3.new(0, 6, 0)

	local mode = Config.DeliveryMethod
	if mode == "สายฟ้าเหินเวหาเร็วสุด" then
		local flyH = math.max(root.Position.Y, finalDest.Y) + 10
		stepGlideTowards(
			root,
			hum,
			finalDest,
			math.clamp(Config.StealReturnStride, 14, 34),
			math.clamp(Config.StealReturnCadence, 0.04, 0.2),
			flyH,
			aborted
		)
	elseif mode == "พักส่งไข่เป็นจังหวะ" then
		local steps = math.clamp(math.floor(Config.StealDeliverySteps or 3), 1, 6)
		local startP = root.Position
		for s = 1, steps do
			if aborted() then break end
			local alpha = s / steps
			local wp = startP:Lerp(finalDest, alpha)
			local flyH = math.max(root.Position.Y, wp.Y) + 10
			stepGlideTowards(root, hum, wp, 24, 0.08, flyH, aborted)
			if s < steps and GameAPI.inGameplay(root.Position) then
				GameAPI.invoke("EggWorld", "AskFieldEggDrop", { Reason = "PlayerRequest" })
				task.wait(0.08)
				GameAPI.invoke("EggWorld", "AskFieldEggCarry", { Uid = eggItem.Uid, FirstAreaSlotKey = slotKey })
				task.wait(0.06)
			end
		end
	else
		stepGroundRunTowards(root, hum, finalDest, math.clamp(Config.StealCarrySpeed, 24, 300), 5, aborted)
	end

	-- แตะพื้นหลังเส้นเขตปลอดภัยชั่วครู่เพื่อให้เซิร์ฟเวอร์ยืนยันการส่งไข่
	if homeGoal and root.Parent then
		root.CFrame = CFrame.new(homeGoal) * root.CFrame.Rotation
		root.AssemblyLinearVelocity = Vector3.zero
		task.wait(0.12)
	end

	-- ข้ามเข้าเส้นเขตปลอดภัยให้แน่นอน
	if plotPos then
		local approachPen = Vector3.new(plotPos.X, plotPos.Y + 4, plotPos.Z)
		if (root.Position - approachPen).Magnitude > 22 then
			stepGlideTowards(root, hum, approachPen, 28, 0.065, math.max(root.Position.Y, approachPen.Y) + 8, aborted)
		end
	end

	local confirmEnd = os.clock() + 1.5
	while os.clock() < confirmEnd do
		local st = GameAPI.getCarryState()
		if not (type(st) == "table" and st.IsCarrying) or not GameAPI.inGameplay(root.Position) then
			break
		end
		task.wait(0.08)
	end

	Steal.SuccessCount += 1
	Steal.LastStealAt = os.clock()
	GameAPI.PinnedUids[eggItem.Uid] = nil
	Steal.ForcedUid = nil
	Steal.ActiveUid = nil
	Steal.Busy = false
	UI.setStatus("ส่งไข่สำเร็จ! สะสม " .. tostring(Steal.SuccessCount) .. " ฟอง", "success", 1.0)
	if Config.AutoPlaceEgg or Config.FullAutoPlay then
		task.spawn(Farm.placeOwnedEggs)
	end
end

-- ระบบวางไข่ลงคอก ฟักไข่ อัปเกรด เทรล ฟิวส์ชั่น ขายตัว และลู่วิ่ง
function Farm.placeOwnedEggs()
	if os.clock() - Farm.LastPlaceAt < 0.7 then
		return
	end
	Farm.LastPlaceAt = os.clock()
	local save = GameAPI.getSave()
	local records = save and save.EggInventory or {}
	local es = GameAPI.Modules.EggState
	if es and type(es.ReadOwnerEggs) == "function" then
		local ok, owned = pcall(es.ReadOwnerEggs, LocalPlayer.UserId)
		if ok and type(owned) == "table" and next(owned) then
			records = owned
		end
	end

	local occupied: { Vector2 } = {}
	local toPlace: { { Uid: string, Income: number, Scale: number } } = {}
	local placedCount = 0

	for uid, rec in pairs(records) do
		if type(uid) == "string" and type(rec) == "table" then
			if rec.Placement then
				placedCount += 1
				local cf = rec.Placement.LocalCFrame
				if typeof(cf) == "CFrame" then
					table.insert(occupied, Vector2.new(cf.Position.X, cf.Position.Z))
				elseif type(cf) == "table" and #cf >= 3 then
					table.insert(occupied, Vector2.new(tonumber(cf[1]) or 0, tonumber(cf[3]) or 0))
				end
			elseif type(rec.AssetCategory) == "string" then
				local m = GameAPI.eggMetrics(rec)
				local okFilter = Config.FullAutoPlay or (
					GameAPI.matchesFilterMap(Config.PlaceRarities, m.RarityId)
					and GameAPI.matchesFilterMap(Config.PlaceSpecies, m.SpeciesId)
					and m.Income >= (tonumber(Config.PlaceMinIncome) or 0)
				)
				if okFilter then
					table.insert(toPlace, { Uid = uid, Income = m.Income, Scale = m.Scale })
				end
			end
		end
	end

	if #toPlace == 0 or placedCount >= 30 then
		return
	end

	table.sort(toPlace, function(a, b)
		if Config.PlaceOrder == "Small" then return a.Scale < b.Scale end
		if Config.PlaceOrder == "Large" then return a.Scale > b.Scale end
		return a.Income > b.Income
	end)

	local freeCells: { CFrame } = {}
	for x = -24, 8, 4 do
		for z = 4, 30, 4 do
			local pt = Vector2.new(x, z)
			local free = true
			for _, u in ipairs(occupied) do
				if (u - pt).Magnitude < 4.5 then
					free = false
					break
				end
			end
			if free then
				table.insert(freeCells, CFrame.new(x, -0.5, z))
			end
		end
	end

	local myPlot = GameAPI.getMyPlot()
	local root = getRoot()
	local hum = getHum()
	if myPlot and root and hum and (root.Position - (myPlot :: Model):GetPivot().Position).Magnitude > 26 then
		local pPos = (myPlot :: Model):GetPivot().Position + Vector3.new(0, 4, 0)
		stepGlideTowards(root, hum, pPos, 28, 0.065, math.max(root.Position.Y, pPos.Y) + 10, function()
			return not Config.AutoPlaceEgg and not Config.FullAutoPlay
		end)
	end

	for i, item in ipairs(toPlace) do
		local cell = freeCells[i]
		if not cell or placedCount + i - 1 >= 30 then
			break
		end
		local ok = GameAPI.invoke("EggWorld", "AskPlaceEgg", {
			Uid = item.Uid,
			LocalCFrame = cell,
		})
		if ok then
			Runtime.StatusText = "วางไข่ลงคอกอัตโนมัติสำเร็จ"
		end
	end
end

function Farm.hatchStep()
	if os.clock() - Farm.LastHatchAt < 1.2 then
		return
	end
	Farm.LastHatchAt = os.clock()
	local save = GameAPI.getSave()
	local records = save and save.EggInventory or {}
	local es = GameAPI.Modules.EggState
	if es and type(es.ReadOwnerEggs) == "function" then
		local ok, rows = pcall(es.ReadOwnerEggs, LocalPlayer.UserId)
		if ok and type(rows) == "table" and next(rows) then
			records = rows
		end
	end
	for uid, rec in pairs(records) do
		if type(uid) == "string" and type(rec) == "table" and rec.Placement then
			local ready = false
			if es and type(es.IsReadyToHatch) == "function" then
				local okR, val = pcall(es.IsReadyToHatch, uid)
				ready = okR and val == true
			elseif type(rec.Placement.ReadyAt) == "number" then
				ready = rec.Placement.ReadyAt <= Workspace:GetServerTimeNow()
			end
			if Config.AutoSkipGrowth and not ready then
				GameAPI.invoke("EggWorld", "AskSkipGrowth", uid)
			end
			if ready then
				local okH = GameAPI.invoke("EggWorld", "AskHatch", uid)
				if okH then
					task.delay(0.15, function()
						GameAPI.invoke("EggWorld", "AskFinishHatch", uid)
					end)
				end
			end
		end
	end
end

function Farm.equipBestStep()
	if os.clock() - Farm.LastEquipAt < 3.5 then
		return
	end
	Farm.LastEquipAt = os.clock()
	GameAPI.invoke("Haul", "WearBest")
end

function Farm.sellPetsStep()
	if os.clock() - Farm.LastSellAt < 4 then
		return
	end
	Farm.LastSellAt = os.clock()
	local save = GameAPI.getSave()
	if not save or type(save.Inventory) ~= "table" then
		return
	end

	local equippedSet: { [string]: boolean } = {}
	if type(save.EquippedAssets) == "table" then
		for _, uid in pairs(save.EquippedAssets) do
			if type(uid) == "string" then
				equippedSet[uid] = true
			end
		end
	end

	local sellIds: { string } = {}
	for uid, rec in pairs(save.Inventory) do
		if type(uid) == "string" and type(rec) == "table" then
			local fav = rec.IsFavorite == true or rec.Favorite == true or rec.InFuse == true or rec.Locked == true
			local m = GameAPI.eggMetrics(rec)
			local isEquipped = equippedSet[uid] == true
			local keepHigh = (Config.SellMode == "ไม่ขายตัวที่ใส่และตัวเก่ง")
				and (isEquipped or m.RarityRank >= 5 or m.MutationId ~= "None")
			local keepEq = (Config.SellMode == "ไม่ขายตัวที่ใส่") and isEquipped
			if not fav and not keepHigh and not keepEq then
				table.insert(sellIds, uid)
			end
		end
	end

	if #sellIds > 0 then
		GameAPI.fire("PetSatchel", "SellSelection", { Assets = sellIds, Eggs = {} })
	end
end

function Farm.fusionStep()
	if os.clock() - Farm.LastFuseAt < 4 then
		return
	end
	Farm.LastFuseAt = os.clock()
	local save = GameAPI.getSave()
	if not save or type(save.Inventory) ~= "table" then
		return
	end
	if type(save.FusionEggReward) == "table" then
		GameAPI.invoke("Fusery", "FinishReveal")
		return
	end

	local bal = GameAPI.Modules.GameplayBalance
	local kernel = GameAPI.Modules.FuseKernel
	local needed = (bal and bal.Fusion and tonumber(bal.Fusion.INPUT_COUNT)) or 4

	local equippedSet: { [string]: boolean } = {}
	for _, field in ipairs({ "EquippedAssets", "VIPFusionSlots", "PrivateFusionSlots" }) do
		if type(save[field]) == "table" then
			for _, uid in pairs(save[field]) do
				if type(uid) == "string" then equippedSet[uid] = true end
			end
		end
	end

	local buckets: { [string]: { string } } = {}
	for uid, rec in pairs(save.Inventory) do
		if type(uid) == "string" and type(rec) == "table"
			and not rec.IsFavorite and not rec.Favorite and not rec.InFuse
			and not equippedSet[uid] and not rec.SpecialLuckyBlockColumn then
			local eligible = true
			if kernel and type(kernel.MayEnterFuse) == "function" then
				local okE, res = pcall(kernel.MayEnterFuse, uid, rec, nil, false, rec.CreatorTemporary == true)
				eligible = okE and res == true
			end
			if eligible then
				local cat = tostring(rec.Category or rec.AssetCategory or "")
				if cat ~= "" then
					buckets[cat] = buckets[cat] or {}
					table.insert(buckets[cat], uid)
				end
			end
		end
	end

	for _, group in pairs(buckets) do
		if #group >= needed then
			table.sort(group)
			GameAPI.invoke("Fusery", "ConfirmBriefing")
			for i = 1, needed do
				GameAPI.invoke("Fusery", "LoadPet", group[i], false)
				task.wait(0.12)
			end
			local okBegin = GameAPI.invoke("Fusery", "BeginFuse")
			if okBegin then
				task.delay(0.4, function()
					GameAPI.invoke("Fusery", "FinishReveal")
				end)
			end
			break
		end
	end
end

function Farm.upgradesAndTrailsStep()
	if (Config.AutoUpgradeBase or Config.AutoUpgradeTreadmill or Config.FullAutoPlay)
		and os.clock() - Farm.LastUpgradeAt >= 4 then
		Farm.LastUpgradeAt = os.clock()
		if Config.AutoUpgradeBase or Config.FullAutoPlay then
			GameAPI.fire("Homestead", "AskBaseTierRaise")
		end
		if Config.AutoUpgradeTreadmill or Config.FullAutoPlay then
			local tmData = GameAPI.Modules.TreadmillsData
			if type(tmData) == "table" and type(tmData.Directory) == "table" then
				for id in pairs(tmData.Directory) do
					GameAPI.invoke("Treadmill", "AskTierRaise", id)
				end
			else
				GameAPI.invoke("Treadmill", "AskTierRaise", "Default")
			end
		end
	end

	if (Config.AutoBuyTrail or Config.FullAutoPlay) and os.clock() - Farm.LastTrailAt >= 5 then
		Farm.LastTrailAt = os.clock()
		local trails = GameAPI.Modules.TrailsData
		if type(trails) == "table" and type(trails.Directory) == "table" then
			local list: { { Id: string, Price: number } } = {}
			for id, cfg in pairs(trails.Directory) do
				if type(cfg) == "table" then
					table.insert(list, { Id = id, Price = tonumber(cfg.Price or cfg.Cost) or 0 })
				end
			end
			table.sort(list, function(a, b) return a.Price < b.Price end)
			local save = GameAPI.getSave()
			local money = tonumber(save and save.Money) or 0
			local owned = save and save.OwnedTrails or {}
			for _, tr in ipairs(list) do
				if not owned[tr.Id] and money >= tr.Price then
					local okBuy = GameAPI.invoke("Trailwear", "AskPurchase", tr.Id)
					if okBuy then
						GameAPI.invoke("Trailwear", "AskChoose", tr.Id)
					end
				end
			end
		end
	end
end

function Farm.treadmillStep()
	if Steal.Busy or (not Config.AutoTreadmill and not Config.FullAutoPlay) then
		return
	end
	local myPlot = GameAPI.getMyPlot()
	if not myPlot then
		return
	end
	local tmPart: BasePart? = nil
	for _, desc in ipairs(myPlot:GetDescendants()) do
		if (desc:IsA("BasePart") and string.find(string.lower(desc.Name), "treadmill")) then
			tmPart = desc
			break
		end
	end
	if not tmPart then
		return
	end

	local root = getRoot()
	local hum = getHum()
	if not root or not hum or hum.Health <= 0 then
		return
	end

	local now = os.clock()
	if Farm.TreadmillPhase == "idle" or (now >= Farm.TreadmillPhaseUntil) then
		if Farm.TreadmillPhase == "running" then
			Farm.TreadmillPhase = "resting"
			Farm.TreadmillPhaseUntil = now + math.max(tonumber(Config.TreadmillRestSeconds) or 4, 0.5)
			GameAPI.invoke("Treadmill", "AskDoff")
		else
			Farm.TreadmillPhase = "running"
			Farm.TreadmillPhaseUntil = now + math.max(tonumber(Config.TreadmillRunSeconds) or 20, 1)
		end
	end

	if Farm.TreadmillPhase == "running" then
		local standPt = tmPart.Position + Vector3.new(0, 3.2, 0)
		if (root.Position - standPt).Magnitude > 5 then
			root.CFrame = CFrame.new(standPt) * root.CFrame.Rotation
		end
		hum:Move(tmPart.CFrame.LookVector, false)
	end
end

function Farm.tick()
	GameAPI.pollFieldSnapshotAsync(false)

	-- ถ้าบังคับขโมยหรือเปิดออโต้ขโมย / เล่นอัตโนมัติครบวงจร
	if not Steal.Busy then
		if Steal.ForcedUid then
			for _, item in ipairs(GameAPI.getFieldEggs()) do
				if item.Uid == Steal.ForcedUid then
					task.spawn(Steal.attemptStealEgg, item)
					break
				end
			end
		elseif Config.AutoStealEgg or Config.FullAutoPlay then
			if not GameAPI.isFieldResetting() then
				local candidates = GameAPI.getSortedStealCandidates()
				if #candidates > 0 then
					task.spawn(Steal.attemptStealEgg, candidates[1])
				elseif Config.FullAutoPlay then
					UI.setStatus("กำลังกวาดระบบหลังบ้านระหว่างรอไข่", "idle", 0.35)
				end
			end
		end
	end

	if not Steal.Busy then
		if (Config.AutoPlaceEgg and Config.PlaceEggRule ~= "วางเฉพาะหลังขโมยเสร็จ") or Config.FullAutoPlay then
			task.spawn(Farm.placeOwnedEggs)
		end
		if Config.AutoHatchEgg or Config.FullAutoPlay then
			task.spawn(Farm.hatchStep)
		end
		if Config.AutoEquipBest or Config.FullAutoPlay then
			task.spawn(Farm.equipBestStep)
		end
		if Config.AutoSellPet or Config.FullAutoPlay then
			task.spawn(Farm.sellPetsStep)
		end
		if Config.AutoFusion or Config.FullAutoPlay then
			task.spawn(Farm.fusionStep)
		end
		if Config.AutoUpgradeBase or Config.AutoUpgradeTreadmill or Config.AutoBuyTrail or Config.FullAutoPlay then
			task.spawn(Farm.upgradesAndTrailsStep)
		end
		if Config.AutoTreadmill or (Config.FullAutoPlay and not Steal.Busy) then
			Farm.treadmillStep()
		end
	end
end

-- ระบบกิจกรรม เควส ต่อสู้ ป้องกัน และการเอาเปรียบกลไกเกมจาก mygame01.lua
local Events = {
	LastRewardAt = 0,
	LastWheelAt = 0,
	LastFishAt = 0,
	LastStarAt = 0,
	LastButterflyAt = 0,
	LastBloomeryAt = 0,
	LastMonsterAt = 0,
	LastHalloweenAt = 0,
	LastBeanstalkAt = 0,
	LastScrambleAt = 0,
	ActiveCastId = nil :: any,
}

local Combat = {
	LastAttackAt = 0,
	LastTrapScanAt = 0,
	LastAFKAt = 0,
}

local Exploits = {
	SavedPrompts = {} :: { [ProximityPrompt]: { Hold: number, Dist: number } },
	OrigObbyAttr = Workspace:GetAttribute("ClientObbyAntiTp"),
	OrigLighting = {
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		Brightness = Lighting.Brightness,
		ClockTime = Lighting.ClockTime,
		FogEnd = Lighting.FogEnd,
	},
	OrigMaxZoom = LocalPlayer.CameraMaxZoomDistance,
	HookActive = false,
	OrigNamecallRef = nil :: any,
}

-- ตัวช่วยให้รีโมตอันตรายถูกสกัดอย่างปลอดภัย
local HazardRemotes: { [string]: boolean } = {
	ForestStrike = true,
	ForestHandoff = true,
	HazardHit = true,
	BlackHoleHit = true,
	SubmitIdleFlag = true,
	SubmitIdleState = true,
}

function Exploits.installHook()
	if Exploits.HookActive or not Exec.hookMeta or not Exec.getMethod or not Exec.isCaller then
		return
	end
	local hookMeta = Exec.hookMeta
	local getMethod = Exec.getMethod
	local isCaller = Exec.isCaller

	local okHook, oldFn = pcall(function()
		local prev: any
		prev = hookMeta(game, "__namecall", function(self: Instance, ...)
			if not Runtime.Running then
				return prev(self, ...)
			end
			local method = getMethod()
			if not isCaller() and (method == "FireServer" or method == "InvokeServer") then
				local rName = self and self.Name or ""
				local guardBlockOn = Config.BlockHazardStrikes or (Config.AntiGuard and Config.AntiGuardMode ~= "กันล้มและหลบหลีก")
				local blockStrike = guardBlockOn and (
					rName == "ForestStrike" or rName == "ForestHandoff"
					or rName == "HazardHit" or rName == "BlackHoleHit"
					or string.find(rName, "/ForestStrike") ~= nil
					or string.find(rName, "/ForestHandoff") ~= nil
					or string.find(rName, "/HazardHit") ~= nil
					or string.find(rName, "/BlackHoleHit") ~= nil
				)
				local blockAFK = (Config.AntiAFK or Config.BlockHazardStrikes) and (
					rName == "SubmitIdleFlag" or rName == "SubmitIdleState"
					or string.find(rName, "/SubmitIdle") ~= nil
				)
				if blockStrike or blockAFK or (HazardRemotes[rName] and guardBlockOn) then
					Runtime.BlockedStrikes += 1
					return nil
				end
			end
			return prev(self, ...)
		end)
		return prev
	end)

	if okHook and type(oldFn) == "function" then
		Exploits.HookActive = true
		Exploits.OrigNamecallRef = oldFn
	end
end

onCleanup(function()
	if Exploits.HookActive and Exploits.OrigNamecallRef and Exec.hookMeta then
		pcall(Exec.hookMeta, game, "__namecall", Exploits.OrigNamecallRef)
		Exploits.HookActive = false
	end
	Workspace:SetAttribute("ClientObbyAntiTp", Exploits.OrigObbyAttr)
	for pp, orig in pairs(Exploits.SavedPrompts) do
		if pp and pp.Parent then
			pcall(function()
				pp.HoldDuration = orig.Hold
				pp.MaxActivationDistance = orig.Dist
			end)
		end
	end
	table.clear(Exploits.SavedPrompts)
	pcall(function()
		LocalPlayer.CameraMaxZoomDistance = Exploits.OrigMaxZoom
	end)
end)

function Exploits.serverHop()
	UI.notify("กำลังค้นหาและย้ายเซิร์ฟเวอร์ใหม่...", "warning", 3)
	task.spawn(function()
		local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=50"
		local ok, raw = pcall(function()
			return (game :: any):HttpGet(url)
		end)
		if ok and type(raw) == "string" then
			local okJ, data = pcall(HttpService.JSONDecode, HttpService, raw)
			if okJ and type(data) == "table" and type(data.data) == "table" then
				for _, srv in ipairs(data.data) do
					if srv.id ~= game.JobId and (tonumber(srv.playing) or 0) < (tonumber(srv.maxPlayers) or 20) then
						TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, LocalPlayer)
						return
					end
				end
			end
		end
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
	end)
end

-- ระบบตรวจจับผู้พัฒนาและสตาฟในห้อง
local LastStaffScanAt = 0
function Exploits.scanStaff()
	if not Config.StaffDetector or os.clock() - LastStaffScanAt < 2 then
		return
	end
	LastStaffScanAt = os.clock()
	local staffMod = GameAPI.Modules.StaffMod
	local foundNames: { string } = {}
	table.clear(Runtime.StaffDetected)

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local role: string? = nil
			if staffMod and type(staffMod.RoleOf) == "function" then
				local okR, r = pcall(staffMod.RoleOf, plr)
				if okR and type(r) == "string" and r ~= "" then
					role = r
				end
			end
			if not role then
				local attrRole = plr:GetAttribute("StaffRole") or plr:GetAttribute("Role") or plr:GetAttribute("CreatorDisguiseUserId")
				if attrRole ~= nil and attrRole ~= false and attrRole ~= "" then
					role = tostring(attrRole)
				end
			end
			if role then
				Runtime.StaffDetected[plr.UserId] = role
				table.insert(foundNames, plr.Name)
			end
		end
	end

	if #foundNames > 0 then
		if UI.SecurityChip and UI.SecurityChip.Parent then
			UI.SecurityChip.Text = "เตือน: พบสตาฟ " .. tostring(#foundNames) .. " คน!"
			UI.SecurityChip.TextColor3 = curTheme().Danger
		end
		if os.clock() - Runtime.LastStaffAlertAt > 12 then
			Runtime.LastStaffAlertAt = os.clock()
			UI.notify("คำเตือน: พบสตาฟหรือผู้พัฒนาในห้อง (" .. table.concat(foundNames, ", ") .. ")", "danger", 6)
			if Config.AutoLeaveOnStaff then
				Exploits.serverHop()
			end
		end
	else
		local msg = "สกัดภัย " .. tostring(Runtime.BlockedStrikes) .. " • ปลอดภัย"
		if UI.SecurityChip and UI.SecurityChip.Parent then
			UI.SecurityChip.Text = msg
			UI.SecurityChip.TextColor3 = curTheme().Success
		end
	end
end

local LastPromptScanAt = 0
local function applyInstantPrompt(pp: ProximityPrompt)
	if not Config.InstantPrompts then return end
	if not Exploits.SavedPrompts[pp] then
		Exploits.SavedPrompts[pp] = { Hold = pp.HoldDuration, Dist = pp.MaxActivationDistance }
	end
	pp.HoldDuration = 0
	pp.MaxActivationDistance = math.max(Exploits.SavedPrompts[pp].Dist, 18)
end

trackConn((ProximityPromptService :: any).PromptShown, function(pp: ProximityPrompt)
	applyInstantPrompt(pp)
end)

function Exploits.tick()
	Exploits.installHook()
	if Config.DisarmObbyAntiTP then
		if Workspace:GetAttribute("ClientObbyAntiTp") ~= false then
			Workspace:SetAttribute("ClientObbyAntiTp", false)
		end
	elseif Workspace:GetAttribute("ClientObbyAntiTp") ~= Exploits.OrigObbyAttr then
		Workspace:SetAttribute("ClientObbyAntiTp", Exploits.OrigObbyAttr)
	end

	if Config.InstantPrompts then
		if os.clock() - LastPromptScanAt >= 2.0 then
			LastPromptScanAt = os.clock()
			for _, pp in ipairs(Workspace:GetDescendants()) do
				if pp:IsA("ProximityPrompt") then
					applyInstantPrompt(pp)
				end
			end
		end
	elseif next(Exploits.SavedPrompts) then
		for pp, orig in pairs(Exploits.SavedPrompts) do
			if pp and pp.Parent then
				pcall(function()
					pp.HoldDuration = orig.Hold
					pp.MaxActivationDistance = orig.Dist
				end)
			end
		end
		table.clear(Exploits.SavedPrompts)
	end

	if Config.Fullbright then
		Lighting.Brightness = 2.2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.Ambient = Color3.fromRGB(220, 220, 220)
		Lighting.OutdoorAmbient = Color3.fromRGB(220, 220, 220)
	end

	if Config.UnlimitedZoom then
		LocalPlayer.CameraMaxZoomDistance = 400
	end

	if Config.NoCamShakeAndFlash then
		for _, eff in ipairs(Lighting:GetChildren()) do
			if eff.Name ~= "MyGame1ThaiCleanBlur" then
				if eff:IsA("BlurEffect") or eff:IsA("ColorCorrectionEffect") then
					eff.Enabled = false
				end
			end
		end
		local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
		if pg then
			for _, obj in ipairs(pg:GetDescendants()) do
				if obj:IsA("Frame") and (string.find(string.lower(obj.Name), "flash") or string.find(string.lower(obj.Name), "vignette")) then
					obj.Visible = false
				end
			end
		end
	end

	Exploits.scanStaff()
end

-- ระบบกิจกรรมและเควสอัตโนมัติ
function Events.claimRewardsStep()
	if os.clock() - Events.LastRewardAt < 6 then
		return
	end
	Events.LastRewardAt = os.clock()
	task.spawn(function()
		GameAPI.invoke("AwayEarnings", "AskCollect", { Kind = "Claim" })
		GameAPI.invoke("Codex", "AskRedeemAll")
		GameAPI.invoke("GroupPerk", "RedeemPerk", true)
		local save = GameAPI.getSave()
		if save and type(save.OnboardingQuests) == "table" then
			for qId in pairs(save.OnboardingQuests) do
				GameAPI.invoke("OnboardingQuestline", "AskAcknowledge", qId)
				GameAPI.invoke("OnboardingQuestline", "AskClaim", qId)
			end
		end
		GameAPI.invoke("BanjoCricket", "AskClaim")
		GameAPI.fire("BeanstalkEvent", "AskClaimReward", false)
		GameAPI.invoke("GhostDogQuest", "Claim")
		for idx = 1, 5 do
			GameAPI.invoke("BossMastery", "AskClaimMilestone", idx)
		end
	end)
end

function Events.petWheelStep()
	if os.clock() - Events.LastWheelAt < 3 then
		return
	end
	Events.LastWheelAt = os.clock()
	task.spawn(function()
		local ok, spun = GameAPI.invoke("PetWheel", "Spin")
		if ok and spun ~= false then
			task.wait(0.25)
			GameAPI.fire("PetWheel", "Finish")
		end
	end)
end

function Events.fishingStep()
	if os.clock() - Events.LastFishAt < 1.8 then
		return
	end
	Events.LastFishAt = os.clock()
	task.spawn(function()
		local char = getChar()
		if not char then return end
		local rod: Tool? = nil
		for _, ch in ipairs(char:GetChildren()) do
			if ch:IsA("Tool") and (string.find(string.lower(ch.Name), "rod") or ch:GetAttribute("FishingRod")) then
				rod = ch
				break
			end
		end
		if not rod then
			local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
			if bp then
				for _, ch in ipairs(bp:GetChildren()) do
					if ch:IsA("Tool") and (string.find(string.lower(ch.Name), "rod") or ch:GetAttribute("FishingRod")) then
						rod = ch
						break
					end
				end
			end
		end
		if not rod then return end
		local hum = getHum()
		if rod.Parent ~= char and hum then
			pcall(function() hum:EquipTool(rod) end)
		end
		local root = getRoot()
		local castPt = root and (root.Position + root.CFrame.LookVector * 14 + Vector3.new(0, -3, 0)) or Vector3.zero
		GameAPI.fire("Fishing", "Hold")
		local okCast, res = GameAPI.invoke("Fishing", "Cast", 1.0, castPt)
		if okCast and type(res) == "table" and res.Id ~= nil then
			if Config.InstantFishCatch then
				local waitSec = math.clamp(tonumber(res.WaitSeconds) or 0.15, 0.08, 0.45)
				task.wait(waitSec)
				GameAPI.invoke("Fishing", "Reel", res.Id, "Caught", 18)
			end
		end
		if Config.InstantFishCatch then
			for mIdx = 1, 5 do
				GameAPI.invoke("Fishing", "AskClaimMastery", mIdx)
			end
		end
		if Config.AutoAlienTrade then
			GameAPI.invoke("AlienLagoon", "Trade")
		end
	end)
end

function Events.shootingStarStep()
	if os.clock() - Events.LastStarAt < 2.2 then
		return
	end
	Events.LastStarAt = os.clock()
	task.spawn(function()
		local ok, st = GameAPI.invoke("ShootingStar", "AskState")
		if ok and type(st) == "table" then
			local list = st.Stars or st.Active or st.List or st
			if type(list) == "table" then
				for key, item in pairs(list) do
					local id = (type(item) == "table" and (item.Id or item.id)) or key
					if id ~= nil then
						GameAPI.fire("ShootingStar", "Hold", id, true)
						task.wait(0.05)
						GameAPI.fire("ShootingStar", "Catch", id)
					end
				end
			end
		end
		if Config.AutoFeedStar then
			local save = GameAPI.getSave()
			if save and type(save.EquippedAssets) == "table" then
				for _, uid in pairs(save.EquippedAssets) do
					if type(uid) == "string" then
						GameAPI.invoke("ShootingStar", "AskFeed", uid)
						break
					end
				end
			end
		end
	end)
end

function Events.butterflyStep()
	if os.clock() - Events.LastButterflyAt < 2.5 then
		return
	end
	Events.LastButterflyAt = os.clock()
	task.spawn(function()
		local okSw, sw = GameAPI.invoke("Butterflies", "AskSwarm")
		if okSw and type(sw) == "table" then
			for k, item in pairs(sw) do
				local id = (type(item) == "table" and (item.Id or item.id)) or k
				if id ~= nil then
					GameAPI.invoke("Butterflies", "AskSwing", id)
				end
			end
		end
		GameAPI.invoke("Butterflies", "AskClaimNet")
		GameAPI.invoke("Butterflies", "AskCraftEssence")
	end)
end

function Events.bloomeryStep()
	if os.clock() - Events.LastBloomeryAt < 2.8 then
		return
	end
	Events.LastBloomeryAt = os.clock()
	task.spawn(function()
		GameAPI.invoke("Bloomery", "AskBriefingConfirm")
		for _, tagModel in ipairs(CollectionService:GetTagged("BloomeryPetal")) do
			GameAPI.invoke("Bloomery", "AskGatherPetal", tagModel:GetAttribute("Id") or tagModel)
		end
		for _, tree in ipairs(CollectionService:GetTagged("BloomeryTree")) do
			GameAPI.fire("Bloomery", "AskStrikeTree", tree)
		end
		local bloomFolder = Workspace:FindFirstChild("Bloomery") or Workspace:FindFirstChild("World")
		if bloomFolder then
			for _, obj in ipairs(bloomFolder:GetChildren()) do
				local pId = obj:GetAttribute("PetalId") or obj:GetAttribute("BloomeryPetalId")
				if pId then
					GameAPI.invoke("Bloomery", "AskGatherPetal", pId)
				elseif obj:IsA("Model") and string.find(string.lower(obj.Name), "sakura") then
					GameAPI.fire("Bloomery", "AskStrikeTree", obj)
				end
			end
		end
	end)
end

function Events.monsterAndHalloweenStep()
	local now = os.clock()
	if Config.AutoMonsterParasite and now - Events.LastMonsterAt >= 3.0 then
		Events.LastMonsterAt = now
		task.spawn(function()
			GameAPI.invoke("MonsterParasite", "AskFeed")
			for idx = 1, 3 do
				GameAPI.invoke("MonsterParasite", "AskChestClaim", idx)
			end
			GameAPI.invoke("MonsterParasite", "AskChestTake")
		end)
	end

	if Config.AutoHalloween and now - Events.LastHalloweenAt >= 1.5 then
		Events.LastHalloweenAt = now
		task.spawn(function()
			for _, egg in ipairs(CollectionService:GetTagged("HalloweenWorldEgg")) do
				if egg:GetAttribute("HalloweenEggCanPickUp") == true then
					local uid = egg:GetAttribute("HalloweenEggUid")
					if type(uid) == "string" then
						GameAPI.invoke("HalloweenDimension", "AskCarryEgg", uid)
					end
				end
			end
			GameAPI.invoke("HalloweenDimension", "AskClaimHorseman")
			for i = 1, 5 do
				GameAPI.invoke("HalloweenDimension", "AskClaimMastery", i)
			end
		end)
	end

	if Config.AutoBeanstalk and now - Events.LastBeanstalkAt >= 2.0 then
		Events.LastBeanstalkAt = now
		task.spawn(function()
			GameAPI.fire("BeanstalkEvent", "AskCatchFirefly")
			GameAPI.fire("BeanstalkEvent", "AskPour")
			GameAPI.fire("BeanstalkEvent", "AskFinishFlight")
			GameAPI.fire("BeanstalkEvent", "AskFinishEscape")
		end)
	end

	if Config.AutoScrambleAndEvents and now - Events.LastScrambleAt >= 2.5 then
		Events.LastScrambleAt = now
		task.spawn(function()
			for _, part in ipairs(CollectionService:GetTagged("ScrambleQuest")) do
				local id = part:GetAttribute("LostPartId") or part:GetAttribute("Id") or part.Name
				GameAPI.fire("Scramble", "Collect", id)
			end
			local okSnap, pickData = GameAPI.invoke("SammyEvent", "FetchPickups")
			if okSnap and type(pickData) == "table" then
				for _, pk in pairs(pickData) do
					if type(pk) == "table" and pk.Id then
						GameAPI.fire("SammyEvent", "AskCollectPickup", pk.Category or "Coin", pk.Zone, pk.Id)
					end
				end
			end
		end)
	end
end

function Events.tick()
	local fullEv = (Config.FullAutoPlay == true) and (Config.FullAutoIncludeEvents == true)
	if Config.AutoClaimReward or Config.FullAutoPlay then
		Events.claimRewardsStep()
	end
	if Config.AutoPetWheel or fullEv then
		Events.petWheelStep()
	end
	if Config.AutoFishing or fullEv then
		Events.fishingStep()
	end
	if Config.AutoShootingStar or fullEv then
		Events.shootingStarStep()
	end
	if Config.AutoButterfly or fullEv then
		Events.butterflyStep()
	end
	if Config.AutoBloomery or fullEv then
		Events.bloomeryStep()
	end
	if Config.AutoMonsterParasite or Config.AutoHalloween or Config.AutoBeanstalk or Config.AutoScrambleAndEvents or fullEv then
		Events.monsterAndHalloweenStep()
	end
end

-- ต่อสู้และป้องกัน
local function scanBatIn(container: Instance?): Tool?
	if not container then
		return nil
	end
	for _, ch in ipairs(container:GetChildren()) do
		if ch:IsA("Tool") and (ch:GetAttribute("IsBat") == true or string.find(string.lower(ch.Name), "bat")) then
			return ch
		end
	end
	return nil
end

local function findBatTool(): Tool?
	return scanBatIn(getChar()) or scanBatIn(LocalPlayer:FindFirstChildOfClass("Backpack"))
end

function Combat.tick()
	local root = getRoot()
	local hum = getHum()
	if not root or not hum or hum.Health <= 0 then
		return
	end

	-- กันกับดัก
	if Config.AntiTrap and os.clock() - Combat.LastTrapScanAt >= 0.8 then
		Combat.LastTrapScanAt = os.clock()
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if (obj.Name == "PlacedTrap" or obj.Name == "PlacedGravityDisruptor") and obj:IsA("Model") then
				for _, p in ipairs(obj:GetDescendants()) do
					if p:IsA("BasePart") then
						p.CanTouch = false
						p.CanCollide = false
					end
				end
			end
		end
	end

	-- กันล้ม
	if Config.AntiFall or (Config.AntiGuard and Config.AntiGuardMode ~= "สกัดสัญญานยามป่า" and not Steal.Busy) then
		pcall(function()
			hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
			hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		end)
		local ragMod = GameAPI.Modules.Ragdoll
		if ragMod and type(ragMod.Ragdoll) == "function" and not (ragMod :: any).__OrigRagdoll then
			(ragMod :: any).__OrigRagdoll = ragMod.Ragdoll
			ragMod.Ragdoll = function() end
		end
	end

	-- กันโดนตัดการเชื่อมต่อเพราะนิ่ง
	if Config.AntiAFK and os.clock() - Combat.LastAFKAt >= 90 then
		Combat.LastAFKAt = os.clock()
		if VirtualUser then
			pcall(function()
				VirtualUser:CaptureController()
				VirtualUser:ClickButton2(Vector2.new(0, 0))
			end)
		end
	end

	-- ถือไม้ตีอัตโนมัติ
	if Config.AutoEquipBat and not Steal.Busy then
		local bat = findBatTool()
		if bat and bat.Parent ~= getChar() then
			pcall(function()
				hum:EquipTool(bat)
			end)
		end
	end

	-- ออโต้ตีผู้เล่น
	if Config.AutoAttack and os.clock() - Combat.LastAttackAt >= 0.22 then
		local bat = findBatTool()
		if bat then
			if bat.Parent ~= getChar() and not Steal.Busy then
				pcall(function()
					hum:EquipTool(bat)
				end)
			end
			local bestTarget: Player? = nil
			local bestDist = 42
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= LocalPlayer and plr.Character then
					local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
					local tHum = plr.Character:FindFirstChildOfClass("Humanoid")
					if tRoot and tRoot:IsA("BasePart") and tHum and tHum.Health > 0 then
						local d = (tRoot.Position - root.Position).Magnitude
						local matchTarget = (Config.AttackTargetPlayer == "ทุกคนที่เข้าเงื่อนไข") or (plr.Name == Config.AttackTargetPlayer)
						local carryingEgg = plr:GetAttribute("IsCarrying") == true or plr:GetAttribute("CarryingEgg") ~= nil
						if matchTarget then
							if Config.AttackMode == "ไปตีผู้เล่นที่ถือไข่" and carryingEgg then
								if d < bestDist or bestTarget == nil then
									bestDist = d
									bestTarget = plr
								end
							elseif Config.AttackMode == "ตีผู้เล่นที่เข้าใกล้" and d <= 20 and d < bestDist then
								bestDist = d
								bestTarget = plr
							end
						end
					end
				end
			end
			if bestTarget then
				local bChar = bestTarget.Character
				local bRoot = bChar and bChar:FindFirstChild("HumanoidRootPart")
				if Config.AttackMode == "ไปตีผู้เล่นที่ถือไข่" and not Steal.Busy and bRoot and bRoot:IsA("BasePart") then
					local d = (bRoot.Position - root.Position).Magnitude
					if d > 10 then
						hum.WalkSpeed = math.max(hum.WalkSpeed, 36)
						hum:Move((bRoot.Position - root.Position).Unit, false)
					end
				end
				Combat.LastAttackAt = os.clock()
				GameAPI.fire("BatSwing", "Trigger", bestTarget, "Swing")
			end
		end
	end
end

-- ระบบตรวจจับและมองทะลุ ระบบเพิ่มประสิทธิภาพ และโหมดฮาๆ เคลื่อนไหว (ตัวหมุนซิงค์เซิร์ฟเวอร์)
local ESP = {
	Entries = {} :: { [string]: { Highlight: Highlight?, Billboard: BillboardGui?, Text: TextLabel? } },
	TracerPool = {} :: { Frame },
	UsedTracers = 0,
	LastScanAt = 0,
	LastRevealAt = 0,
	RevealedPrompts = {} :: { [ProximityPrompt]: boolean },
}

local Perf = {
	LastApplyAt = 0,
	SavedMaterials = {} :: { [BasePart]: { Mat: Enum.Material, Shadow: boolean } },
	SavedAudio = {} :: { [Sound]: number },
	SavedParticles = {} :: { [Instance]: boolean },
	OrigShadows = Lighting.GlobalShadows,
}

local Fun = {
	OrigAutoRotate = true :: boolean?,
	SpinAtt = nil :: Attachment?,
	SpinAV = nil :: AngularVelocity?,
	HeadNeck = nil :: Motor6D?,
	OrigNeckC0 = nil :: CFrame?,
	HeadAngle = 0,
	FlyAtt = nil :: Attachment?,
	FlyLV = nil :: LinearVelocity?,
	FlyAO = nil :: AlignOrientation?,
	OrigGravity = Workspace.Gravity,
	WasNoclip = false,
	ScaledChar = nil :: Model?,
	OrigCharScale = 1,
	SavedPartScales = {} :: { [BasePart]: Vector3 },
}

-- เครื่องมือวาดเส้นชี้เป้าระบบรีไซเคิล (ไม่ใช้ Drawing API ภายนอก)
local function beginTracers()
	ESP.UsedTracers = 0
end

local function drawTracer(toPt: Vector2, col: Color3)
	local cam = Workspace.CurrentCamera
	if not cam or not TracerLayer.Parent then
		return
	end
	local vp = cam.ViewportSize
	local fromPt = Vector2.new(vp.X * 0.5, vp.Y - 14)
	local diff = toPt - fromPt
	local dist = diff.Magnitude
	if dist < 4 then
		return
	end

	ESP.UsedTracers += 1
	local idx = ESP.UsedTracers
	local line = ESP.TracerPool[idx]
	if not line or not line.Parent then
		line = Instance.new("Frame")
		line.Name = "Tracer_" .. tostring(idx)
		line.AnchorPoint = Vector2.new(0.5, 0.5)
		line.BorderSizePixel = 0
		line.ZIndex = 2
		line.Parent = TracerLayer
		ESP.TracerPool[idx] = line
	end
	local mid = (fromPt + toPt) * 0.5
	line.Position = UDim2.fromOffset(mid.X, mid.Y)
	line.Size = UDim2.fromOffset(math.floor(dist), 2)
	line.Rotation = math.deg(math.atan2(diff.Y, diff.X))
	line.BackgroundColor3 = col
	line.BackgroundTransparency = 0.25
	line.Visible = true
end

local function endTracers()
	for i = ESP.UsedTracers + 1, #ESP.TracerPool do
		local line = ESP.TracerPool[i]
		if line and line.Parent then
			line.Visible = false
		end
	end
end

local function upsertEspItem(
	key: string,
	adornee: Instance,
	anchorPart: Instance,
	title: string,
	col: Color3,
	showHighlight: boolean,
	scalePct: number?,
	withTracer: boolean?
)
	if not ESPFolder.Parent then
		return
	end
	local entry: { Highlight: Highlight?, Billboard: BillboardGui?, Text: TextLabel? } = ESP.Entries[key] :: any
	if not entry then
		entry = { Highlight = nil, Billboard = nil, Text = nil }
		ESP.Entries[key] = entry
	end

	if showHighlight then
		if not entry.Highlight or not entry.Highlight.Parent then
			local hl = Instance.new("Highlight")
			hl.Name = "HL_" .. key
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.FillTransparency = 0.72
			hl.OutlineTransparency = 0.1
			hl.Parent = ESPFolder
			entry.Highlight = hl
		end
		if entry.Highlight then
			entry.Highlight.Adornee = adornee :: any
			entry.Highlight.FillColor = col
			entry.Highlight.OutlineColor = col
			entry.Highlight.Enabled = true
		end
	elseif entry.Highlight and entry.Highlight.Parent then
		entry.Highlight.Enabled = false
	end

	if title ~= "" then
		if not entry.Billboard or not entry.Billboard.Parent then
			local bb = Instance.new("BillboardGui")
			bb.Name = "BB_" .. key
			bb.AlwaysOnTop = true
			bb.StudsOffsetWorldSpace = Vector3.new(0, 3.6, 0)
			bb.Size = UDim2.fromOffset(200, 62)
			bb.Parent = ESPFolder

			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.fromScale(1, 1)
			lbl.BackgroundTransparency = 1
			lbl.TextStrokeTransparency = 0.25
			lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
			lbl.TextWrapped = true
			lbl.Font = curFont()
			lbl.TextSize = 13
			lbl.Parent = bb

			entry.Billboard = bb
			entry.Text = lbl
		end
		if entry.Billboard and entry.Text then
			local s = math.clamp((scalePct or 100) / 100, 0.5, 2.0)
			entry.Billboard.Adornee = anchorPart :: any
			entry.Billboard.Size = UDim2.fromOffset(math.floor(200 * s), math.floor(62 * s))
			entry.Billboard.Enabled = true
			entry.Text.Text = title
			entry.Text.TextColor3 = col
			entry.Text.Font = curFont()
			entry.Text.TextSize = math.clamp(math.floor(13 * s), 9, 24)
		end
	elseif entry.Billboard and entry.Billboard.Parent then
		entry.Billboard.Enabled = false
	end

	if withTracer and anchorPart:IsA("BasePart") then
		local cam = Workspace.CurrentCamera
		if cam then
			local pt, onScreen = cam:WorldToViewportPoint(anchorPart.Position)
			if onScreen and pt.Z > 0 then
				drawTracer(Vector2.new(pt.X, pt.Y), col)
			end
		end
	end
end

local function clearUnusedEsp(seen: { [string]: boolean })
	for key, entry in pairs(ESP.Entries) do
		if not seen[key] then
			if entry.Highlight then entry.Highlight:Destroy() end
			if entry.Billboard then entry.Billboard:Destroy() end
			ESP.Entries[key] = nil
		end
	end
end

function ESP.revealEggsStep()
	if not Config.RevealEggContent100 or os.clock() - ESP.LastRevealAt < 0.7 then
		return
	end
	ESP.LastRevealAt = os.clock()
	for uid, rec in pairs(GameAPI.FieldSnapshot) do
		if type(uid) == "string" and type(rec) == "table" then
			local model = Workspace:FindFirstChild(uid)
			if not model then
				local slots = Workspace:FindFirstChild("AreaEggSlotsClient")
				model = slots and slots:FindFirstChild(uid) or nil
			end
			if model then
				local pp = model:FindFirstChildOfClass("ProximityPrompt") or model:FindFirstChildWhichIsA("ProximityPrompt", true)
				if pp then
					local m = GameAPI.eggMetrics(rec)
					pp.ActionText = "ขโมย • " .. m.RarityThai
					pp.ObjectText = string.format("%s [%s | %s/วิ]", m.DisplayName, m.MutationThai, GameAPI.formatNum(m.Income))
					ESP.RevealedPrompts[pp] = true
				end
			end
		end
	end
end

function ESP.tick()
	ESP.revealEggsStep()
	beginTracers()

	local anyEsp = Config.EggESP
		or Config.OwnBaseEggESP
		or Config.GuardESP
		or Config.PlayerESP
		or Config.TrapESP
		or Config.LostPartESP
		or Config.EventCollectibleESP

	if not anyEsp then
		clearUnusedEsp({})
		endTracers()
		return
	end

	local seen: { [string]: boolean } = {}
	local root = getRoot()
	local myPos = root and root.Position or Vector3.zero
	local customEggCol = Data.EspColors[Config.EggESPColorName] or curTheme().Accent
	local plrCol = Data.EspColors[Config.PlayerESPColorName] or Color3.fromRGB(64, 198, 255)

	-- 1. Field Egg ESP
	if Config.EggESP then
		for uid, rec in pairs(GameAPI.FieldSnapshot) do
			if type(uid) == "string" and type(rec) == "table" then
				local m = GameAPI.eggMetrics(rec)
				local okFilter = (Config.ESPFilterArea == "All" or m.AreaId == Config.ESPFilterArea)
					and (Config.ESPFilterSpecies == "All" or m.SpeciesId == Config.ESPFilterSpecies)
					and (Config.ESPFilterRarity == "All" or m.RarityId == Config.ESPFilterRarity)
					and (Config.ESPFilterMutation == "All" or m.MutationId == Config.ESPFilterMutation)
				if okFilter then
					local slotsFolder = Workspace:FindFirstChild("AreaEggSlotsClient")
					local model = Workspace:FindFirstChild(uid) or (slotsFolder and slotsFolder:FindFirstChild(uid))
					local pos = GameAPI.eggWorldPos(uid, rec)
					local anchor = model and (model:FindFirstChild("Hitbox", true) or (model:IsA("Model") and model.PrimaryPart) or model)
					if model and anchor and pos then
						local dist = math.floor((pos - myPos).Magnitude)
						local parts: { string } = {}
						if Config.EggShowName then table.insert(parts, m.DisplayName) end
						local sub: { string } = {}
						if Config.EggShowRarity then table.insert(sub, m.RarityThai) end
						if Config.EggShowMutation and m.MutationId ~= "None" then table.insert(sub, m.MutationThai) end
						if #sub > 0 then table.insert(parts, table.concat(sub, " • ")) end
						local statsLine: { string } = {}
						if Config.EggShowIncome then table.insert(statsLine, GameAPI.formatNum(m.Income) .. "/วิ") end
						if Config.EggShowWeight then table.insert(statsLine, string.format("%.1fก.", m.Scale)) end
						if Config.EggShowArea then table.insert(statsLine, Data.AreaThaiById[m.AreaId] or m.AreaId) end
						if Config.EggShowDistance then table.insert(statsLine, tostring(dist) .. "ม.") end
						if #statsLine > 0 then table.insert(parts, table.concat(statsLine, " | ")) end

						local col = (Config.EggHighlightMode == "ตามสีที่เลือก") and customEggCol or m.RarityColor
						local hlOn = Config.EggHighlightMode ~= "ปิดกรอบเรืองแสง"
						local key = "FEgg_" .. uid
						seen[key] = true
						upsertEspItem(key, model, anchor, table.concat(parts, "\n"), col, hlOn, Config.EggESPSizePercent, Config.EggTracker)
					end
				end
			end
		end
	end

	-- 2. Own Base Egg ESP
	if Config.OwnBaseEggESP then
		local save = GameAPI.getSave()
		local myPlot = GameAPI.getMyPlot()
		local es = GameAPI.Modules.EggState
		if save and myPlot and type(save.EggInventory) == "table" then
			local basePos = (myPlot :: Model):GetPivot()
			local nowSrv = Workspace:GetServerTimeNow()
			for uid, rec in pairs(save.EggInventory) do
				if type(uid) == "string" and type(rec) == "table" and rec.Placement then
					local model = (myPlot :: Instance):FindFirstChild(uid, true)
					if model then
						local m = GameAPI.eggMetrics(rec)
						local ready = false
						if es and type(es.IsReadyToHatch) == "function" then
							local okR, val = pcall(es.IsReadyToHatch, uid)
							ready = okR and val == true
						elseif type(rec.Placement.ReadyAt) == "number" then
							ready = rec.Placement.ReadyAt <= nowSrv
						end
						local remain = (type(rec.Placement.ReadyAt) == "number") and math.max(0, math.ceil(rec.Placement.ReadyAt - nowSrv)) or 0
						local statusTag = ready and "พร้อมฟัก!" or (remain > 0 and ("เหลืออีก " .. tostring(remain) .. " วิ") or "กำลังโต")
						local key = "OwnEgg_" .. uid
						seen[key] = true
						local text = string.format("%s (%s)\n%s", m.DisplayName, m.RarityThai, statusTag)
						local col = ready and curTheme().Success or m.RarityColor
						local anchor = model:FindFirstChildWhichIsA("BasePart", true) or model
						upsertEspItem(key, model, anchor, text, col, true, Config.EggESPSizePercent, false)
					elseif basePos then
						-- ข้ามเมื่อไม่มีโมเดลในฉาก
					end
				end
			end
		end
	end

	-- 3. Guard ESP
	if Config.GuardESP then
		for _, g in ipairs(GameAPI.getGuards()) do
			local stThai = g.State == "Chase" and "กำลังไล่ล่า!" or (g.State == "Return" and "กำลังกลับฐาน" or "ลาดตระเวน")
			local gCol = g.State == "Chase" and curTheme().Danger or curTheme().Warning
			local lines: { string } = { "ยามเขต " .. (Data.AreaThaiById[g.Area] or g.Area) }
			if Config.GuardShowState then table.insert(lines, stThai) end
			if Config.GuardShowDistance then table.insert(lines, tostring(math.floor(g.Dist)) .. " ม.") end
			local key = "Guard_" .. g.Area
			seen[key] = true
			upsertEspItem(key, g.Model, g.Root, table.concat(lines, "\n"), gCol, true, 100, Config.GuardTracker)
		end
	end

	-- 4. Player & Staff ESP
	if Config.PlayerESP then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character then
				local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
				local tHum = plr.Character:FindFirstChildOfClass("Humanoid")
				if tRoot and tRoot:IsA("BasePart") and tHum and tHum.Health > 0 then
					local isStaff = Runtime.StaffDetected[plr.UserId] ~= nil
					local col = isStaff and curTheme().Danger or plrCol
					local lines: { string } = {}
					if Config.PlayerShowName then
						table.insert(lines, isStaff and ("[สตาฟ!] " .. plr.DisplayName) or plr.DisplayName)
					end
					local sub: { string } = {}
					if Config.PlayerShowDistance then
						table.insert(sub, tostring(math.floor((tRoot.Position - myPos).Magnitude)) .. " ม.")
					end
					if Config.PlayerShowSpeed then
						table.insert(sub, "เร็ว " .. tostring(math.floor(tRoot.AssemblyLinearVelocity.Magnitude)))
					end
					if #sub > 0 then table.insert(lines, table.concat(sub, " • ")) end
					if Config.PlayerShowStatus then
						local carry = plr:GetAttribute("IsCarrying") == true
						local tool = plr.Character:FindFirstChildOfClass("Tool")
						local stStr = carry and "กำลังถือไข่!" or (tool and ("ถือ " .. tool.Name) or "มือเปล่า")
						table.insert(lines, stStr)
					end
					local key = "Plr_" .. tostring(plr.UserId)
					seen[key] = true
					upsertEspItem(key, plr.Character, tRoot, table.concat(lines, "\n"), col, true, 100, Config.PlayerTracker)
				end
			end
		end
	end

	-- 5. Trap / Lost Part / Event ESP (รีเฟรชทุก 0.45s เพื่อความลื่น)
	if Config.TrapESP or Config.LostPartESP or Config.EventCollectibleESP then
		if Config.LostPartESP then
			for idx, part in ipairs(CollectionService:GetTagged("ScrambleQuest")) do
				local anchor = part:IsA("Model") and (part.PrimaryPart or part:FindFirstChildWhichIsA("BasePart")) or part
				if anchor and anchor:IsA("BasePart") then
					local dist = math.floor((anchor.Position - myPos).Magnitude)
					local key = "LostPart_" .. tostring(idx) .. "_" .. part.Name
					seen[key] = true
					upsertEspItem(key, part, anchor, "ชิ้นส่วนปริศนา\n" .. tostring(dist) .. " ม.", Color3.fromRGB(255, 224, 92), true, 95, Config.LostPartTracker)
				end
			end
		end
		if Config.TrapESP then
			for idx, trap in ipairs(CollectionService:GetTagged("PlacedTrap")) do
				local anchor = trap:IsA("Model") and (trap.PrimaryPart or trap:FindFirstChildWhichIsA("BasePart")) or trap
				if anchor and anchor:IsA("BasePart") then
					local key = "Trap_" .. tostring(idx) .. "_" .. trap.Name
					seen[key] = true
					upsertEspItem(key, trap, anchor, "กับดักผู้เล่น", curTheme().Danger, true, 90, false)
				end
			end
		end
		if Config.EventCollectibleESP then
			for idx, hw in ipairs(CollectionService:GetTagged("HalloweenWorldEgg")) do
				local anchor = hw:IsA("Model") and (hw.PrimaryPart or hw:FindFirstChildWhichIsA("BasePart")) or hw
				if anchor and anchor:IsA("BasePart") then
					local key = "EvHW_" .. tostring(idx)
					seen[key] = true
					upsertEspItem(key, hw, anchor, "ไข่กิจกรรมฮาโลวีน", Color3.fromRGB(255, 145, 58), true, 95, false)
				end
			end
			for idx, petal in ipairs(CollectionService:GetTagged("BloomeryPetal")) do
				local anchor = petal:IsA("Model") and (petal.PrimaryPart or petal:FindFirstChildWhichIsA("BasePart")) or petal
				if anchor and anchor:IsA("BasePart") then
					local key = "EvPetal_" .. tostring(idx)
					seen[key] = true
					upsertEspItem(key, petal, anchor, "กลีบซากุระ", Color3.fromRGB(255, 138, 198), true, 90, false)
				end
			end
		end
	end

	clearUnusedEsp(seen)
	endTracers()
end

-- ระบบเพิ่มประสิทธิภาพเครื่อง
local SavedDecor: { [BasePart]: number } = {}
local SimplifiedDone = false

function Perf.applyStep()
	if os.clock() - Perf.LastApplyAt < 2.2 then
		return
	end
	Perf.LastApplyAt = os.clock()

	if Config.OptDisableShadowsAndPostFX then
		Lighting.GlobalShadows = false
		for _, ch in ipairs(Lighting:GetChildren()) do
			if ch.Name ~= "MyGame1ThaiCleanBlur" and (ch:IsA("BloomEffect") or ch:IsA("SunRaysEffect") or ch:IsA("DepthOfFieldEffect")) then
				ch.Enabled = false
			end
		end
	elseif not Config.Fullbright then
		Lighting.GlobalShadows = Perf.OrigShadows
	end

	if Config.OptSimplifyMaterials and not SimplifiedDone then
		SimplifiedDone = true
		local ch = getChar()
		local count = 0
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("BasePart") and (not ch or not obj:IsDescendantOf(ch)) then
				if not Perf.SavedMaterials[obj] then
					Perf.SavedMaterials[obj] = { Mat = obj.Material, Shadow = obj.CastShadow }
				end
				obj.Material = Enum.Material.SmoothPlastic
				obj.CastShadow = false
				count += 1
				if count > 4500 then break end
			end
		end
	elseif not Config.OptSimplifyMaterials and SimplifiedDone then
		SimplifiedDone = false
		for part, orig in pairs(Perf.SavedMaterials) do
			if part and part.Parent then
				part.Material = orig.Mat
				part.CastShadow = orig.Shadow
			end
		end
		table.clear(Perf.SavedMaterials)
	end

	if Config.OptHideWorldDecorations and not next(SavedDecor) then
		for _, obj in ipairs(Workspace:GetChildren()) do
			if obj:IsA("Folder") or obj:IsA("Model") then
				local low = string.lower(obj.Name)
				if string.find(low, "decor") or string.find(low, "tree") or string.find(low, "foliage") or string.find(low, "prop") then
					for _, p in ipairs(obj:GetDescendants()) do
						if p:IsA("BasePart") and not p.CanCollide and SavedDecor[p] == nil then
							SavedDecor[p] = p.LocalTransparencyModifier
							p.LocalTransparencyModifier = 1
						end
					end
				end
			end
		end
	elseif not Config.OptHideWorldDecorations and next(SavedDecor) then
		for p, origT in pairs(SavedDecor) do
			if p and p.Parent then p.LocalTransparencyModifier = origT end
		end
		table.clear(SavedDecor)
	end

	if Config.OptMuteGameAudio then
		for _, s in ipairs(SoundService:GetDescendants()) do
			if s:IsA("Sound") and s.Volume > 0 then
				Perf.SavedAudio[s] = s.Volume
				s.Volume = 0
			end
		end
	elseif next(Perf.SavedAudio) then
		for s, v in pairs(Perf.SavedAudio) do
			if s and s.Parent then s.Volume = v end
		end
		table.clear(Perf.SavedAudio)
	end

	if Config.OptDisableTreadmillVideos then
		local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
		if pg then
			for _, vf in ipairs(pg:GetDescendants()) do
				if vf:IsA("VideoFrame") then
					vf.Visible = false
					vf.Playing = false
				end
			end
		end
	end

	if Config.OptDisableParticles then
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
				if obj.Enabled and Perf.SavedParticles[obj] == nil then
					Perf.SavedParticles[obj] = true
				end
				obj.Enabled = false
			end
		end
	elseif next(Perf.SavedParticles) then
		for obj in pairs(Perf.SavedParticles) do
			if obj and obj.Parent then (obj :: any).Enabled = true end
		end
		table.clear(Perf.SavedParticles)
	end

	if Config.OptHideOtherPets or Config.OptHideSelfPets then
		local plots = Workspace:FindFirstChild("Plots")
		if plots then
			local uidStr = tostring(LocalPlayer.UserId)
			for _, plot in ipairs(plots:GetChildren()) do
				local isMine = (plot:GetAttribute("OwnerUserId") == LocalPlayer.UserId) or (plot.Name == uidStr)
				local hideThis = (isMine and Config.OptHideSelfPets) or ((not isMine) and Config.OptHideOtherPets)
				local petsFolder = plot:FindFirstChild("Pets") or plot:FindFirstChild("ActiveAssets")
				if petsFolder then
					for _, part in ipairs(petsFolder:GetDescendants()) do
						if part:IsA("BasePart") then
							part.LocalTransparencyModifier = hideThis and 1 or 0
						end
					end
				end
			end
		end
	end

	if Config.OptUnlockFPS and Exec.setFps then
		pcall(Exec.setFps, 240)
	elseif Exec.setFps then
		pcall(Exec.setFps, 60)
	end
end

-- ระบบโหมดฮาๆ เคลื่อนไหว และตัวหมุนซิงค์เซิร์ฟเวอร์ให้คนอื่นเห็น
function Fun.cleanupPhysics()
	if Fun.SpinAV then pcall(function() Fun.SpinAV:Destroy() end); Fun.SpinAV = nil end
	if Fun.SpinAtt then pcall(function() Fun.SpinAtt:Destroy() end); Fun.SpinAtt = nil end
	if Fun.FlyLV then pcall(function() Fun.FlyLV:Destroy() end); Fun.FlyLV = nil end
	if Fun.FlyAO then pcall(function() Fun.FlyAO:Destroy() end); Fun.FlyAO = nil end
	if Fun.FlyAtt then pcall(function() Fun.FlyAtt:Destroy() end); Fun.FlyAtt = nil end
	local root = getRoot()
	if root and root.Parent then
		root.AssemblyAngularVelocity = Vector3.zero
	end
	local hum = getHum()
	if hum and hum.Parent and Fun.OrigAutoRotate ~= nil then
		hum.AutoRotate = Fun.OrigAutoRotate
		Fun.OrigAutoRotate = nil
	end
	if Fun.HeadNeck and Fun.HeadNeck.Parent and Fun.OrigNeckC0 then
		Fun.HeadNeck.C0 = Fun.OrigNeckC0
		Fun.HeadNeck = nil
		Fun.OrigNeckC0 = nil
	end
end

onCleanup(function()
	Fun.cleanupPhysics()
	Workspace.Gravity = Fun.OrigGravity
	local char = getChar()
	if char and Fun.ScaledChar == char then
		pcall(function()
			char:ScaleTo(Fun.OrigCharScale)
		end)
	end
end)

trackConn(UserInputService.JumpRequest, function()
	if Config.FunInfJump then
		local hum = getHum()
		if hum and hum.Health > 0 then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

function Fun.preSimulationStep(dt: number)
	local char = getChar()
	local root = getRoot()
	local hum = getHum()
	if not char or not root or not hum or hum.Health <= 0 then
		return
	end

	-- 1. แทรกแซง WalkSpeed / JumpPower ระดับ PreSimulation (ทับตัวจำกัดความเร็วเกม)
	if Config.SpoofWalkSpeed and not Steal.Busy then
		hum.WalkSpeed = math.clamp(tonumber(Config.CustomWalkSpeed) or 48, 16, 400)
	end
	if Config.SpoofJumpPower then
		hum.UseJumpPower = true
		hum.JumpPower = math.clamp(tonumber(Config.CustomJumpPower) or 72, 20, 300)
	end

	-- 2. เดินทะลุกำแพง
	if Config.FunNoclip then
		Fun.WasNoclip = true
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") and p.CanCollide then
				p.CanCollide = false
			end
		end
	elseif Fun.WasNoclip then
		Fun.WasNoclip = false
		for _, pName in ipairs({ "HumanoidRootPart", "UpperTorso", "LowerTorso", "Torso" }) do
			local p = char:FindFirstChild(pName)
			if p and p:IsA("BasePart") then p.CanCollide = true end
		end
	end

	-- 3. กันกระเด็น
	if Config.AntiKnockback and not Steal.Busy and not Config.FunFly then
		local v = root.AssemblyLinearVelocity
		if math.abs(v.X) > (hum.WalkSpeed + 28) or math.abs(v.Z) > (hum.WalkSpeed + 28) then
			root.AssemblyLinearVelocity = Vector3.new(0, math.min(v.Y, 20), 0)
		end
	end

	-- 4. ตัวหมุนความเร็วสูงแบบฟิสิกส์ซิงค์เซิร์ฟเวอร์ (คนอื่นในห้องเห็นหมุนชัดเจน!)
	if Config.FunSpin and not Steal.Busy then
		if Fun.OrigAutoRotate == nil then
			Fun.OrigAutoRotate = hum.AutoRotate
		end
		hum.AutoRotate = false

		if not Fun.SpinAtt or Fun.SpinAtt.Parent ~= root then
			if Fun.SpinAtt then pcall(function() Fun.SpinAtt:Destroy() end) end
			local att = Instance.new("Attachment")
			att.Name = "__MyGame1SpinAtt"
			att.Parent = root
			Fun.SpinAtt = att
		end
		if not Fun.SpinAV or Fun.SpinAV.Parent ~= root then
			if Fun.SpinAV then pcall(function() Fun.SpinAV:Destroy() end) end
			local av = Instance.new("AngularVelocity")
			av.Name = "__MyGame1SpinAV"
			av.Attachment0 = Fun.SpinAtt
			av.RelativeTo = Enum.ActuatorRelativeTo.World
			av.MaxTorque = 1e9
			av.Parent = root
			Fun.SpinAV = av
		end

		local degPerSec = math.clamp(tonumber(Config.FunSpinSpeed) or 3600, 60, 36000)
		local dirSign = (Config.FunSpinDir == "ทวนเข็มนาฬิกา") and 1 or -1
		local rad = math.rad(degPerSec) * dirSign
		local targetAV = (Config.FunSpinMode == "หมุนสามมิติพายุทอร์นาโด")
			and Vector3.new(rad * 0.6, rad, rad * 0.45)
			or Vector3.new(0, rad, 0)

		if Fun.SpinAV then
			Fun.SpinAV.AngularVelocity = targetAV
		end
		root.AssemblyAngularVelocity = targetAV
	else
		if Fun.SpinAV then pcall(function() Fun.SpinAV:Destroy() end); Fun.SpinAV = nil end
		if Fun.SpinAtt then pcall(function() Fun.SpinAtt:Destroy() end); Fun.SpinAtt = nil end
		if Fun.OrigAutoRotate ~= nil then
			hum.AutoRotate = Fun.OrigAutoRotate
			Fun.OrigAutoRotate = nil
		end
	end

	-- 5. หมุนหัวรอบตัว
	if Config.FunHeadSpin then
		local neck = char:FindFirstChild("Neck", true)
		if neck and neck:IsA("Motor6D") then
			if Fun.HeadNeck ~= neck then
				Fun.HeadNeck = neck
				Fun.OrigNeckC0 = neck.C0
			end
			Fun.HeadAngle = (Fun.HeadAngle + math.rad(tonumber(Config.FunHeadSpinSpeed) or 1440) * dt) % (math.pi * 2)
			if Fun.OrigNeckC0 then
				neck.C0 = Fun.OrigNeckC0 * CFrame.Angles(0, Fun.HeadAngle, 0)
			end
		end
	elseif Fun.HeadNeck and Fun.OrigNeckC0 then
		if Fun.HeadNeck.Parent then
			Fun.HeadNeck.C0 = Fun.OrigNeckC0
		end
		Fun.HeadNeck = nil
		Fun.OrigNeckC0 = nil
	end

	-- 6. ขยาย/ย่อขนาดตัวละคร (ปลอดภัยต่อข้อต่อ R15 และซิงค์เซิร์ฟเวอร์)
	if Config.FunScaleEnabled then
		local scaleVal = math.clamp(tonumber(Config.FunScale) or 1.5, 0.2, 10)
		if Fun.ScaledChar ~= char then
			Fun.ScaledChar = char
			Fun.OrigCharScale = char:GetScale()
		end
		if Config.FunScaleMode == "ทั้งตัว" then
			for _, nvName in ipairs({ "BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale" }) do
				local nv = hum:FindFirstChild(nvName)
				if nv and nv:IsA("NumberValue") and math.abs(nv.Value - scaleVal) > 0.02 then
					nv.Value = scaleVal
				end
			end
			if not hum:FindFirstChild("BodyHeightScale") and math.abs(char:GetScale() - scaleVal) > 0.02 then
				pcall(function()
					char:ScaleTo(scaleVal)
				end)
			end
		else
			local hScale = math.clamp(tonumber(Config.FunHeadScale) or 1, 0.2, 8)
			local tScale = math.clamp(tonumber(Config.FunTorsoScale) or 1, 0.2, 8)
			local wScale = math.clamp(((tonumber(Config.FunLeftArmScale) or 1) + (tonumber(Config.FunRightArmScale) or 1)) * 0.5, 0.2, 8)
			local dScale = math.clamp(((tonumber(Config.FunLeftLegScale) or 1) + (tonumber(Config.FunRightLegScale) or 1)) * 0.5, 0.2, 8)
			local r15Map: { [string]: number } = {
				HeadScale = hScale,
				BodyHeightScale = tScale,
				BodyWidthScale = wScale,
				BodyDepthScale = dScale,
			}
			for nvName, val in pairs(r15Map) do
				local nv = hum:FindFirstChild(nvName)
				if nv and nv:IsA("NumberValue") and math.abs(nv.Value - val) > 0.02 then
					nv.Value = val
				end
			end
		end
	elseif Fun.ScaledChar == char then
		pcall(function()
			char:ScaleTo(Fun.OrigCharScale)
		end)
		for _, nvName in ipairs({ "BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale" }) do
			local nv = hum:FindFirstChild(nvName)
			if nv and nv:IsA("NumberValue") then nv.Value = 1 end
		end
		Fun.ScaledChar = nil
	end

	-- 7. บินอิสระ
	if Config.FunFly and not Steal.Busy then
		local cam = Workspace.CurrentCamera
		if not Fun.FlyAtt or Fun.FlyAtt.Parent ~= root then
			if Fun.FlyAtt then pcall(function() Fun.FlyAtt:Destroy() end) end
			local a = Instance.new("Attachment")
			a.Name = "__MyGame1FlyAtt"
			a.Parent = root
			Fun.FlyAtt = a
		end
		if not Fun.FlyLV or Fun.FlyLV.Parent ~= root then
			if Fun.FlyLV then pcall(function() Fun.FlyLV:Destroy() end) end
			local lv = Instance.new("LinearVelocity")
			lv.Name = "__MyGame1FlyLV"
			lv.Attachment0 = Fun.FlyAtt
			lv.MaxForce = 1e7
			lv.RelativeTo = Enum.ActuatorRelativeTo.World
			lv.Parent = root
			Fun.FlyLV = lv
		end
		local moveVec = Vector3.zero
		if cam then
			local cf = cam.CFrame
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec += cf.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec -= cf.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec -= cf.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec += cf.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVec += Vector3.yAxis end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.C) then
				moveVec -= Vector3.yAxis
			end
		end
		local flySpeed = math.clamp(tonumber(Config.FunFlySpeed) or 85, 16, 400)
		if Fun.FlyLV then
			Fun.FlyLV.VectorVelocity = (moveVec.Magnitude > 0.01) and (moveVec.Unit * flySpeed) or Vector3.zero
		end
		root.AssemblyLinearVelocity = Fun.FlyLV and Fun.FlyLV.VectorVelocity or Vector3.zero
	else
		if Fun.FlyLV then pcall(function() Fun.FlyLV:Destroy() end); Fun.FlyLV = nil end
		if Fun.FlyAO then pcall(function() Fun.FlyAO:Destroy() end); Fun.FlyAO = nil end
		if Fun.FlyAtt then pcall(function() Fun.FlyAtt:Destroy() end); Fun.FlyAtt = nil end
	end

	-- 8. แรงโน้มถ่วงต่ำลอยตัว
	if Config.FunZeroGrav then
		Workspace.Gravity = 34
	elseif Workspace.Gravity ~= Fun.OrigGravity then
		Workspace.Gravity = Fun.OrigGravity
	end
end

-- ประกอบแท็บทั้งหมด 8 หมวดพร้อมคิวขโมยไข่อินไลน์ (ไม่มีแผงแยก)
local HeroLabel: TextLabel? = nil
local GuardRiskLabel: TextLabel? = nil
local QueueRowsUI: { { Frame: Frame, Label: TextLabel, Uid: string? } } = {}

local function syncFeatureConflictBadges(_changedKey: string?)
	local fullOn = Config.FullAutoPlay == true
	UI.setConflictBadge("AutoStealEgg", (fullOn and not Config.AutoStealEgg) and "ถูกควบคุมโดยโหมดอัตโนมัติครบวงจร" or nil)
	UI.setConflictBadge("AutoPlaceEgg", (fullOn and not Config.AutoPlaceEgg) and "ถูกควบคุมโดยโหมดอัตโนมัติครบวงจร" or nil)
	UI.setConflictBadge("AutoHatchEgg", (fullOn and not Config.AutoHatchEgg) and "ถูกควบคุมโดยโหมดอัตโนมัติครบวงจร" or nil)
	if Config.FunSpin and Config.AntiGuard == false and Config.AutoStealEgg then
		UI.setConflictBadge("FunSpin", "หยุดหมุนอัตโนมัติระหว่างกำลังพุ่งขโมยไข่")
	else
		UI.setConflictBadge("FunSpin", nil)
	end
end
UI.setFeatureSyncHandler(syncFeatureConflictBadges)

-- แท็บ 1: ออโต้และฟาร์ม + คิว Linkhive อินไลน์
do
	local page = UI.createTab("ออโต้และฟาร์ม", 1)

	local secMaster = UI.section(page, "โหมดเล่นอัตโนมัติครบวงจร", 1, "เปิดเพียงปุ่มเดียวเพื่อให้บอททำงานต่อเนื่องตั้งแต่ขโมยจนถึงฟักและอัปเกรด")
	UI.toggle(secMaster, "เปิดเล่นอัตโนมัติครบทุกอย่าง", "ขโมยไข่ วางไข่ ฟักไข่ ใส่ตัวเก่ง อัปเกรด ฟิวส์ชั่น ขายตัว วิ่งลู่ และรับรางวัลให้เองทั้งหมด", "FullAutoPlay", 1, function(on: boolean)
		UI.notify(on and "เปิดโหมดเล่นอัตโนมัติครบวงจรแล้ว" or "ปิดโหมดเล่นอัตโนมัติแล้ว", on and "success" or "warning", 2.5)
	end)
	UI.toggle(secMaster, "ทำกิจกรรมโลกควบคู่ไปด้วย", "เมื่อเปิดจะเก็บดาวตก จับผีเสื้อ ตีซากุระ ตกปลาเอเลี่ยน และเปิดกล่องอัตโนมัติระหว่างรอไข่", "FullAutoIncludeEvents", 2)

	local secQueue = UI.section(page, "ไข่เป้าหมายและคิวขโมยด่วน", 2, "รวมแผงคิวเป้าหมายไว้ในหน้าหลักโดยไม่มีหน้าต่างลอยบังจอ")

	local heroCard = Instance.new("Frame")
	heroCard.LayoutOrder = 1
	heroCard.Size = UDim2.new(1, 0, 0, 74)
	heroCard.BackgroundTransparency = 0.25
	heroCard.BorderSizePixel = 0
	heroCard.ZIndex = 13
	heroCard.Parent = secQueue
	regTheme(heroCard, "BackgroundColor3", "Bg")
	makeCorner(heroCard, 8, 0)
	makeStroke(heroCard, "Accent", 1.2, 0.25)

	local heroLbl = Instance.new("TextLabel")
	heroLbl.Position = UDim2.fromOffset(10, 6)
	heroLbl.Size = UDim2.new(1, -180, 0, 38)
	heroLbl.BackgroundTransparency = 1
	heroLbl.TextWrapped = true
	heroLbl.TextXAlignment = Enum.TextXAlignment.Left
	heroLbl.TextYAlignment = Enum.TextYAlignment.Top
	heroLbl.Text = "กำลังค้นหาไข่ดีที่สุดในสนาม..."
	heroLbl.ZIndex = 14
	heroLbl.Parent = heroCard
	regTheme(heroLbl, "TextColor3", "Text")
	regText(heroLbl, 12, true)
	HeroLabel = heroLbl

	local guardLbl = Instance.new("TextLabel")
	guardLbl.Position = UDim2.fromOffset(10, 48)
	guardLbl.Size = UDim2.new(1, -180, 0, 20)
	guardLbl.BackgroundTransparency = 1
	guardLbl.TextXAlignment = Enum.TextXAlignment.Left
	guardLbl.Text = "สถานะยาม: ปกติ"
	guardLbl.ZIndex = 14
	guardLbl.Parent = heroCard
	regTheme(guardLbl, "TextColor3", "Success")
	regText(guardLbl, 11, true)
	GuardRiskLabel = guardLbl

	local btnStealTop = Instance.new("TextButton")
	btnStealTop.AnchorPoint = Vector2.new(1, 0)
	btnStealTop.Position = UDim2.new(1, -8, 0, 8)
	btnStealTop.Size = UDim2.fromOffset(156, 28)
	btnStealTop.Text = "พุ่งขโมยฟองนี้ทันที"
	btnStealTop.AutoButtonColor = false
	btnStealTop.BorderSizePixel = 0
	btnStealTop.ZIndex = 15
	btnStealTop.Parent = heroCard
	regTheme(btnStealTop, "BackgroundColor3", "Accent")
	regTheme(btnStealTop, "TextColor3", "Text")
	regText(btnStealTop, 12, true)
	makeCorner(btnStealTop, 6, 0)
	btnStealTop.MouseButton1Click:Connect(function()
		local cands = GameAPI.getSortedStealCandidates()
		if #cands > 0 then
			Steal.ForcedUid = cands[1].Uid
			UI.notify("ล็อกเป้าพุ่งขโมย: " .. cands[1].Metrics.DisplayName, "success", 2)
		else
			UI.notify("ยังไม่มีไข่ตรงเงื่อนไขในสนาม", "warning", 2)
		end
	end)

	local btnSkipTop = Instance.new("TextButton")
	btnSkipTop.AnchorPoint = Vector2.new(1, 1)
	btnSkipTop.Position = UDim2.new(1, -8, 1, -8)
	btnSkipTop.Size = UDim2.fromOffset(156, 26)
	btnSkipTop.Text = "ข้ามไปฟองถัดไป"
	btnSkipTop.AutoButtonColor = false
	btnSkipTop.BorderSizePixel = 0
	btnSkipTop.ZIndex = 15
	btnSkipTop.Parent = heroCard
	regTheme(btnSkipTop, "BackgroundColor3", "CardHover")
	regTheme(btnSkipTop, "TextColor3", "SubText")
	regText(btnSkipTop, 11, true)
	makeCorner(btnSkipTop, 6, 0)
	btnSkipTop.MouseButton1Click:Connect(function()
		local cands = GameAPI.getSortedStealCandidates()
		if #cands > 0 then
			GameAPI.skipEgg(cands[1].Uid, 45)
			UI.notify("ข้ามฟองปัจจุบันชั่วคราวแล้ว", "warning", 2)
		end
	end)

	for r = 1, 6 do
		local qRow = Instance.new("Frame")
		qRow.LayoutOrder = r + 1
		qRow.Size = UDim2.new(1, 0, 0, 30)
		qRow.BackgroundTransparency = 0.42
		qRow.BorderSizePixel = 0
		qRow.Visible = false
		qRow.ZIndex = 13
		qRow.Parent = secQueue
		regTheme(qRow, "BackgroundColor3", "Bg")
		makeCorner(qRow, 6, 0)

		local qLbl = Instance.new("TextLabel")
		qLbl.Position = UDim2.fromOffset(8, 0)
		qLbl.Size = UDim2.new(1, -184, 1, 0)
		qLbl.BackgroundTransparency = 1
		qLbl.TextXAlignment = Enum.TextXAlignment.Left
		qLbl.TextTruncate = Enum.TextTruncate.AtEnd
		qLbl.Text = ""
		qLbl.ZIndex = 14
		qLbl.Parent = qRow
		regTheme(qLbl, "TextColor3", "Text")
		regText(qLbl, 11, false)

		local slotInfo = { Frame = qRow, Label = qLbl, Uid = nil :: string? }
		QueueRowsUI[r] = slotInfo

		local function qBtn(txt: string, xOff: number, w: number, role: string, cb: (string) -> ())
			local b = Instance.new("TextButton")
			b.AnchorPoint = Vector2.new(1, 0.5)
			b.Position = UDim2.new(1, xOff, 0.5, 0)
			b.Size = UDim2.fromOffset(w, 22)
			b.Text = txt
			b.AutoButtonColor = false
			b.BorderSizePixel = 0
			b.ZIndex = 15
			b.Parent = qRow
			regTheme(b, "BackgroundColor3", role)
			regTheme(b, "TextColor3", "Text")
			regText(b, 10, true)
			makeCorner(b, 5, 0)
			b.MouseButton1Click:Connect(function()
				if slotInfo.Uid then cb(slotInfo.Uid) end
			end)
		end

		qBtn("ปัก", -136, 36, "CardHover", function(uid) GameAPI.pinTop(uid) end)
		qBtn("ขึ้น", -96, 36, "CardHover", function(uid) GameAPI.movePin(uid, -1) end)
		qBtn("ขโมย", -46, 46, "Accent", function(uid) Steal.ForcedUid = uid end)
		qBtn("ข้าม", -6, 36, "Danger", function(uid) GameAPI.skipEgg(uid, 45) end)
	end

	UI.button(secQueue, "รีเฟรชรายชื่อไข่และล้างการข้ามทั้งหมด", "subtle", 10, function()
		table.clear(GameAPI.PinnedUids)
		table.clear(GameAPI.SkippedUids)
		GameAPI.pollFieldSnapshotAsync(true)
		UI.notify("รีเฟรชรายการไข่ในสนามเรียบร้อย", "success", 2)
	end)

	local secSteal = UI.section(page, "ตั้งค่าความเร็วและตัวกรองการขโมย", 3)
	UI.toggle(secSteal, "เปิดออโต้ขโมยไข่", "วิ่งหรือเหินไปคว้าไข่และส่งกลับเขตปลอดภัยอัตโนมัติ", "AutoStealEgg", 1)
	UI.dropdown(secSteal, "วิธีนำไข่กลับฐาน", "แนะนำสายฟ้าเหินเวหาสำหรับพื้นที่ระดับสูง", function()
		return Data.DeliveryModes
	end, function()
		return Config.DeliveryMethod
	end, function(v)
		Config.DeliveryMethod = v
	end, 2)
	UI.dropdown(secSteal, "วิธีวิ่งขาไปหาไข่", "เลือกเหินเวหาข้ามยามเพื่อไม่ให้ติดกำแพงหรือยามดัก", function()
		return Data.OutboundModes
	end, function()
		return Config.StealOutboundMode
	end, function(v)
		Config.StealOutboundMode = v
	end, 3)
	UI.slider(secSteal, "ระยะก้าวต่อรอบตอนเหินฟ้า", "ระยะก้าวที่ปลอดภัยต่อการซิงค์เซิร์ฟเวอร์สูงและเร็วสุดคือ 26 ถึง 30", "StealReturnStride", 14, 34, 1, 4, "หน่วย")
	UI.slider(secSteal, "หน่วงเวลาระหว่างก้าวเหิน", "ค่ายิ่งน้อยยิ่งส่งไวมาก หากเนตช้าให้เพิ่มเป็น 0.09", "StealReturnCadence", 0.04, 0.20, 0.005, 5, "วินาที")
	UI.slider(secSteal, "จำนวนจุดพักส่งไข่", "ใช้เฉพาะโหมดพักส่งไข่เป็นจังหวะ", "StealDeliverySteps", 1, 6, 1, 6, "จุด")
	UI.slider(secSteal, "ความเร็ววิ่งบนพื้นขาไป", "ความเร็วเมื่อใช้โหมดวิ่งบนพื้น", "StealGoSpeed", 24, 300, 2, 7, "หน่วย/วิ")
	UI.slider(secSteal, "ความเร็ววิ่งบนพื้นขากลับ", "ความเร็วเมื่ออุ้มไข่บนพื้น", "StealCarrySpeed", 24, 300, 2, 8, "หน่วย/วิ")
	UI.dropdown(secSteal, "เรียงลำดับไข่เป้าหมาย", "", function() return Data.StealSortOrders end, function() return Config.StealOrder end, function(v) Config.StealOrder = v end, 9)
	UI.dropdown(secSteal, "ความหายากขั้นต่ำที่ขโมย", "", function() return Data.RarityList end, function() return Config.StealMinRarity end, function(v) Config.StealMinRarity = v end, 10)
	UI.multiDropdown(secSteal, "เลือกพื้นที่เป้าหมาย", "", function() return Data.AreaList end, "StealAreas", "ทุกพื้นที่", 11)
	UI.multiDropdown(secSteal, "เลือกระดับความหายาก", "", function() return Data.RarityList end, "StealRarities", "ทุกระดับ", 12)
	UI.multiDropdown(secSteal, "เลือกการกลายพันธุ์", "", function() return Data.MutationList end, "StealMutations", "ทุกกลายพันธุ์", 13)
	UI.multiDropdown(secSteal, "เลือกสายพันธุ์เฉพาะ", "", function() return Data.SpeciesList end, "StealSpecies", "ทุกสายพันธุ์", 14)
	UI.slider(secSteal, "รายได้ขั้นต่ำของไข่เป้าหมาย", "ขโมยเฉพาะไข่ที่สร้างเงินต่อวินาทีไม่ต่ำกว่านี้", "StealMinIncome", 0, 5000000, 1000, 15, "/วิ")
	UI.toggle(secSteal, "เฉพาะตัวที่ยังไม่มีในสมุดสะสม", "", "StealOnlyMissingIndex", 16)
	UI.toggle(secSteal, "เฉพาะตัวที่ยังไม่มีในแล็บ", "", "StealOnlyMissingLab", 17)

	local secFarm = UI.section(page, "จัดการคอก ฟักไข่ ลู่วิ่ง และคลังสัตว์", 4)
	UI.toggle(secFarm, "ออโต้วางไข่ลงคอกอัจฉริยะ", "เหินกลับคอกและวางไข่ในช่องว่างอัตโนมัติ", "AutoPlaceEgg", 1)
	UI.dropdown(secFarm, "จังหวะการวางไข่ลงคอก", "", function()
		return { "วางทันทีเมื่อมีไข่", "วางเฉพาะหลังขโมยเสร็จ" }
	end, function() return Config.PlaceEggRule end, function(v) Config.PlaceEggRule = v end, 2)
	UI.dropdown(secFarm, "ลำดับความสำคัญการวางไข่", "", function() return Data.PlaceSortOrders end, function() return Config.PlaceOrder end, function(v) Config.PlaceOrder = v end, 3)
	UI.multiDropdown(secFarm, "กรองระดับความหายากที่จะวาง", "", function() return Data.RarityList end, "PlaceRarities", "ทุกระดับ", 4)
	UI.multiDropdown(secFarm, "กรองสายพันธุ์ที่จะวางลงคอก", "", function() return Data.SpeciesList end, "PlaceSpecies", "ทุกสายพันธุ์", 5)
	UI.slider(secFarm, "รายได้ขั้นต่ำของไข่ที่จะวาง", "", "PlaceMinIncome", 0, 5000000, 1000, 6, "/วิ")
	UI.toggle(secFarm, "ออโต้ฟักไข่ในคอก", "กดฟักและรับสัตว์เลี้ยงทันทีที่เวลาครบ", "AutoHatchEgg", 7)
	UI.toggle(secFarm, "เร่งข้ามระยะเวลาเติบโตอัตโนมัติ", "ลองส่งคำสั่งข้ามเวลาก่อนฟักทันที", "AutoSkipGrowth", 8)
	UI.toggle(secFarm, "ออโต้วิ่งลู่วิ่งเพิ่มความเร็ว", "หยุดให้อัตโนมัติเมื่อมีภารกิจขโมยไข่", "AutoTreadmill", 9)
	UI.slider(secFarm, "เวลาวิ่งบนลู่ต่อรอบ", "", "TreadmillRunSeconds", 2, 120, 1, 10, "วินาที")
	UI.slider(secFarm, "เวลาพักหลังลงลู่", "", "TreadmillRestSeconds", 0.5, 30, 0.5, 11, "วินาที")
	UI.toggle(secFarm, "ออโต้ใส่สัตว์เลี้ยงรายได้ดีที่สุด", "", "AutoEquipBest", 12)
	UI.toggle(secFarm, "ออโต้ขายสัตว์เลี้ยงส่วนเกิน", "ข้ามตัวที่ล็อก ดาวโปรด และตัวหายากไว้ให้อัตโนมัติ", "AutoSellPet", 13)
	UI.dropdown(secFarm, "เงื่อนไขความปลอดภัยตอนขาย", "", function()
		return { "ไม่ขายตัวที่ใส่และตัวเก่ง", "ไม่ขายตัวที่ใส่", "ขายทุกตัวยกเว้นตัวติดดาว" }
	end, function() return Config.SellMode end, function(v) Config.SellMode = v end, 14)
	UI.toggle(secFarm, "ออโต้ฟิวส์ชั่นสัตว์ซ้ำอัตโนมัติ", "จับตัวซ้ำที่ไม่ได้สวมใส่เข้าเครื่องฟิวส์ชั่น", "AutoFusion", 15)
	UI.toggle(secFarm, "ออโต้อัปเกรดระดับบ้าน", "", "AutoUpgradeBase", 16)
	UI.toggle(secFarm, "ออโต้อัปเกรดระดับลู่วิ่ง", "", "AutoUpgradeTreadmill", 17)
	UI.toggle(secFarm, "ออโต้ซื้อและสวมเทรลที่ดีขึ้น", "", "AutoBuyTrail", 18)
end

-- แท็บ 2: กิจกรรมและเควสอัตโนมัติ
do
	local page = UI.createTab("กิจกรรมและเควส", 2)

	local secClaim = UI.section(page, "รับรางวัล เควส และกงล้อสัตว์", 1)
	UI.toggle(secClaim, "รับรางวัลออฟไลน์ สมุด กลุ่ม และเควสประจำ", "เก็บเงินสะสมขณะออฟไลน์ เคลมสมุด รางวัลกลุ่ม และเควสบอส", "AutoClaimReward", 1)
	UI.toggle(secClaim, "หมุนกงล้อสัตว์เลี้ยงอัตโนมัติ", "ใช้สิทธิ์หมุนกงล้อและเคลมผลรางวัลทันที", "AutoPetWheel", 2)
	UI.button(secClaim, "สั่งรับรางวัลทั้งหมดในคลิกเดียวทันที", "accent", 3, function()
		Events.LastRewardAt = 0
		Events.claimRewardsStep()
		UI.notify("ส่งคำสั่งรับรางวัลและเคลมทุกหมวดหมู่แล้ว", "success", 2.5)
	end)

	local secWorld = UI.section(page, "กิจกรรมโลก ตกปลา ดาวตก ผีเสื้อ และซากุระ", 2)
	UI.toggle(secWorld, "ออโต้ตกปลาบึงเอเลี่ยน", "เหวี่ยงเบ็ดอัตโนมัติเมื่อถือคันเบ็ด", "AutoFishing", 1)
	UI.toggle(secWorld, "ดึงปลาติดทันทีไม่ต้องรอเกม", "ส่งคำสั่งจับปลาทันทีพร้อมรับแต้มความชำนาญการตกปลา", "InstantFishCatch", 2)
	UI.toggle(secWorld, "แลกของบึงเอเลี่ยนอัตโนมัติ", "", "AutoAlienTrade", 3)
	UI.toggle(secWorld, "ออโต้เก็บดาวตกกลางอากาศ", "จับดาวตกทันทีเมื่อมีดาวตกในเซิร์ฟเวอร์", "AutoShootingStar", 4)
	UI.toggle(secWorld, "ออโต้ป้อนดาวให้สัตว์ที่ใส่", "", "AutoFeedStar", 5)
	UI.toggle(secWorld, "ออโต้เรียกฝูงและหวดจับผีเสื้อ", "เรียกฝูงผีเสื้อ เหวี่ยงสวิง เคลมตาข่าย และคราฟต์เอสเซนส์", "AutoButterfly", 6)
	UI.toggle(secWorld, "ออโต้ตีต้นซากุระและเก็บกลีบดอกไม้", "", "AutoBloomery", 7)

	local secDim = UI.section(page, "มิติฮาโลวีน ปรสิต ต้นถั่ว และชิ้นส่วนปริศนา", 3)
	UI.toggle(secDim, "ออโต้ป้อนปรสิตและเปิดกล่องรางวัล", "", "AutoMonsterParasite", 1)
	UI.toggle(secDim, "ออโต้ขโมยไข่ฮาโลวีนและรับรางวัลหัวม้า", "", "AutoHalloween", 2)
	UI.toggle(secDim, "ออโต้กิจกรรมต้นถั่วและหิ่งห้อย", "จับหิ่งห้อย รดน้ำ จบบิน และหนีต้นถั่วอัตโนมัติ", "AutoBeanstalk", 3)
	UI.toggle(secDim, "ออโต้เก็บชิ้นส่วนปริศนาและของสะสมกิจกรรม", "", "AutoScrambleAndEvents", 4)
end

-- แท็บ 3: ต่อสู้และป้องกัน
do
	local page = UI.createTab("ต่อสู้และป้องกัน", 3)

	local secAtk = UI.section(page, "ระบบไม้เบสบอลและโจมตีผู้เล่น", 1)
	UI.toggle(secAtk, "ถือไม้ตีติดมืออัตโนมัติ", "หยิบไม้เบสบอลอัตโนมัติเมื่อไม่ได้กำลังขโมยไข่", "AutoEquipBat", 1)
	UI.toggle(secAtk, "ออโต้หวดผู้เล่นเป้าหมาย", "หวดเป้าหมายที่เข้าใกล้หรือถือไข่ตามโหมดที่ตั้ง", "AutoAttack", 2)
	UI.dropdown(secAtk, "รูปแบบการเลือกเป้าโจมตี", "", function()
		return { "ตีผู้เล่นที่เข้าใกล้", "ไปตีผู้เล่นที่ถือไข่" }
	end, function() return Config.AttackMode end, function(v) Config.AttackMode = v end, 3)

	UI.dropdown(secAtk, "ระบุผู้เล่นเฉพาะคน", "", function()
		local opts = { "ทุกคนที่เข้าเงื่อนไข" }
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then table.insert(opts, p.Name) end
		end
		return opts
	end, function() return Config.AttackTargetPlayer end, function(v) Config.AttackTargetPlayer = v end, 4)

	local secDef = UI.section(page, "ป้องกันยาม กับดัก ล้ม และกันเด้งออก", 2)
	UI.toggle(secDef, "เปิดระบบป้องกันยามไล่ตีครบสูตร", "ผสานสกัดสัญญาณตีกับกันล้มไม่ให้ไข่หลุดจากมือ", "AntiGuard", 1)
	UI.dropdown(secDef, "โหมดป้องกันยาม", "", function()
		return { "ครบสูตรอัตโนมัติ", "สกัดสัญญานยามป่า", "กันล้มและหลบหลีก" }
	end, function() return Config.AntiGuardMode end, function(v) Config.AntiGuardMode = v end, 2)
	UI.toggle(secDef, "กันล้มจากแรงกระแทกทุกชนิด", "ไม่เสียจังหวะและไม่ทำไข่หล่นเมื่อถูกชนหรือยามตี", "AntiFall", 3)
	UI.toggle(secDef, "กันกระเด็นจากไม้ตีและแรงผลัก", "ตัดความเร็วกระชากส่วนเกินออกทันที", "AntiKnockback", 4)
	UI.toggle(secDef, "ปิดการชนกับดักผู้เล่นอื่นทั้งหมด", "กับดักหมีและเครื่องรบกวนแรงโน้มถ่วงจะไร้ผลกับตัวเรา", "AntiTrap", 5)
	UI.toggle(secDef, "กันโดนเตะเมื่อยืนนิ่งนาน", "ส่งสัญญาณใช้งานและสกัดรีโมตแจ้งยืนนิ่งของเซิร์ฟเวอร์", "AntiAFK", 6)
end

-- แท็บ 4: เอาเปรียบระบบเกม
do
	local page = UI.createTab("เอาเปรียบระบบ", 4)

	local secExp = UI.section(page, "ปลดล็อกขีดจำกัดและสกัดการรายงานฝั่งลูกข่าย", 1, "สร้างขึ้นจากการวิเคราะห์โครงสร้างสคริปต์ฝั่งไคลเอนต์ของเกมนี้โดยตรง")
	UI.toggle(secExp, "ปิดระบบดักจับวาปฝั่งลูกข่ายอัตโนมัติ", "เขียนค่าควบคุมฝั่งไคลเอนต์ไม่ให้ฆ่าตัวละครตอนพุ่งส่งไข่เร็ว", "DisarmObbyAntiTP", 1)
	UI.toggle(secExp, "สกัดคำสั่งโดนบอสกับดักและยามป่าตีก่อนถึงเซิร์ฟเวอร์", "ดักบล็อกสัญญาณแจ้งโดนโจมตีของยามป่า บอส และยืนนิ่งโดยตรง", "BlockHazardStrikes", 2)
	UI.toggle(secExp, "เจาะบังคับความเร็วเดินทับตัวคุมเกม", "เขียนทับตัวจำกัดความเร็วเดินของเกมทุกเฟรมฟิสิกส์", "SpoofWalkSpeed", 3)
	UI.slider(secExp, "ปรับความเร็วเดินที่ต้องการ", "", "CustomWalkSpeed", 16, 400, 2, 4, "หน่วย/วิ")
	UI.toggle(secExp, "เจาะบังคับพลังกระโดดสูง", "", "SpoofJumpPower", 5)
	UI.slider(secExp, "ปรับพลังกระโดด", "", "CustomJumpPower", 20, 300, 2, 6)
	UI.toggle(secExp, "กดเก็บและโต้ตอบทันทีแบบไร้เวลารอ", "ปรับเวลาค้างของปุ่มกดทั้งหมดเป็นศูนย์และเพิ่มระยะกด", "InstantPrompts", 7)

	local secCam = UI.section(page, "มุมกล้อง แสงสว่าง และเรดาร์เตือนสตาฟ", 2)
	UI.toggle(secCam, "ลบอาการจอสั่น แสงแฟลช และจอเบลอ", "", "NoCamShakeAndFlash", 1)
	UI.toggle(secCam, "เปิดไฟสว่างเต็มแผนที่ตลอดเวลา", "", "Fullbright", 2)
	UI.toggle(secCam, "ปลดล็อกซูมกล้องถอยได้ไกลสุด 400 เมตร", "", "UnlimitedZoom", 3)
	UI.toggle(secCam, "เรดาร์ตรวจจับแอดมินและทีมงานพัฒนาเกม", "เตือนทันทีที่พบสตาฟหรือบัญชีปลอมตัวผู้พัฒนาเข้ามาในห้อง", "StaffDetector", 4)
	UI.toggle(secCam, "ย้ายเซิร์ฟเวอร์หนีอัตโนมัติเมื่อพบสตาฟ", "", "AutoLeaveOnStaff", 5)
	UI.button(secCam, "ย้ายไปเซิร์ฟเวอร์ห้องใหม่เดี๋ยวนี้", "danger", 6, Exploits.serverHop)
end

-- แท็บ 5: ตรวจจับและมองทะลุ
do
	local page = UI.createTab("ตรวจจับและมองทะลุ", 5)

	local secEgg = UI.section(page, "มองทะลุไข่ สแกนไส้ในจริง และเส้นชี้เป้า", 1)
	UI.toggle(secEgg, "เปิดเผยชื่อและรายได้ไข่จริงบนป้ายในสนาม", "", "RevealEggContent100", 1)
	UI.toggle(secEgg, "แสดงตำแหน่งไข่ในสนามทั้งหมด", "", "EggESP", 2)
	UI.toggle(secEgg, "แสดงสถานะไข่และเวลาโตในคอกตัวเอง", "", "OwnBaseEggESP", 3)
	UI.toggle(secEgg, "เส้นชี้เป้าไปยังไข่จากขอบจอล่าง", "", "EggTracker", 4)
	UI.dropdown(secEgg, "โหมดสีกรอบเรืองแสงไข่", "", function()
		return { "ตามสีความหายาก", "ตามสีที่เลือก", "ปิดกรอบเรืองแสง" }
	end, function() return Config.EggHighlightMode end, function(v) Config.EggHighlightMode = v end, 5)
	UI.dropdown(secEgg, "เลือกสีเรืองแสงแบบกำหนดเอง", "", function() return Data.EspColorNames end, function() return Config.EggESPColorName end, function(v) Config.EggESPColorName = v end, 6)
	UI.slider(secEgg, "ขนาดป้ายชื่อไข่บนจอ", "", "EggESPSizePercent", 50, 200, 5, 7, "%")
	UI.toggle(secEgg, "แสดงชื่อพันธุ์ไข่", "", "EggShowName", 8)
	UI.toggle(secEgg, "แสดงความหายาก", "", "EggShowRarity", 9)
	UI.toggle(secEgg, "แสดงการกลายพันธุ์", "", "EggShowMutation", 10)
	UI.toggle(secEgg, "แสดงรายได้ต่อวินาที", "", "EggShowIncome", 11)
	UI.toggle(secEgg, "แสดงน้ำหนักไข่", "", "EggShowWeight", 12)
	UI.toggle(secEgg, "แสดงชื่อพื้นที่บนป้าย", "", "EggShowArea", 13)
	UI.toggle(secEgg, "แสดงระยะห่าง", "", "EggShowDistance", 14)
	UI.dropdown(secEgg, "กรองพื้นที่แสดงบนจอ", "", function() return Data.AreaList end, function() return Config.ESPFilterArea end, function(v) Config.ESPFilterArea = v end, 15)
	UI.dropdown(secEgg, "กรองสายพันธุ์แสดงบนจอ", "", function() return Data.SpeciesList end, function() return Config.ESPFilterSpecies end, function(v) Config.ESPFilterSpecies = v end, 16)
	UI.dropdown(secEgg, "กรองระดับความหายากบนจอ", "", function() return Data.RarityList end, function() return Config.ESPFilterRarity end, function(v) Config.ESPFilterRarity = v end, 17)
	UI.dropdown(secEgg, "กรองการกลายพันธุ์บนจอ", "", function() return Data.MutationList end, function() return Config.ESPFilterMutation end, function(v) Config.ESPFilterMutation = v end, 18)

	local secWorldEsp = UI.section(page, "ตรวจจับยาม ผู้เล่น กับดัก ชิ้นส่วน และของกิจกรรม", 2)
	UI.toggle(secWorldEsp, "แสดงตำแหน่งและสถานะยามทุกเขต", "", "GuardESP", 1)
	UI.toggle(secWorldEsp, "แสดงสถานะการไล่ล่าของยาม", "", "GuardShowState", 2)
	UI.toggle(secWorldEsp, "แสดงระยะห่างยาม", "", "GuardShowDistance", 3)
	UI.toggle(secWorldEsp, "เส้นชี้เป้ายาม", "", "GuardTracker", 4)
	UI.toggle(secWorldEsp, "แสดงตำแหน่งผู้เล่นทุกคนและคำเตือนสตาฟ", "", "PlayerESP", 5)
	UI.dropdown(secWorldEsp, "เลือกสีเรืองแสงผู้เล่น", "", function() return Data.EspColorNames end, function() return Config.PlayerESPColorName end, function(v) Config.PlayerESPColorName = v end, 6)
	UI.toggle(secWorldEsp, "เส้นชี้เป้าผู้เล่น", "", "PlayerTracker", 7)
	UI.toggle(secWorldEsp, "แสดงชื่อผู้เล่น", "", "PlayerShowName", 8)
	UI.toggle(secWorldEsp, "แสดงระยะห่างผู้เล่น", "", "PlayerShowDistance", 9)
	UI.toggle(secWorldEsp, "แสดงสถานะถือไข่และอาวุธของผู้เล่น", "", "PlayerShowStatus", 10)
	UI.toggle(secWorldEsp, "แสดงความเร็วเคลื่อนที่ผู้เล่น", "", "PlayerShowSpeed", 11)
	UI.toggle(secWorldEsp, "แสดงตำแหน่งกับดักบนพื้น", "", "TrapESP", 12)
	UI.toggle(secWorldEsp, "แสดงตำแหน่งชิ้นส่วนปริศนาที่หายไป", "", "LostPartESP", 13)
	UI.toggle(secWorldEsp, "เส้นชี้เป้าชิ้นส่วนปริศนา", "", "LostPartTracker", 14)
	UI.toggle(secWorldEsp, "แสดงตำแหน่งไข่ฮาโลวีนและกลีบซากุระ", "", "EventCollectibleESP", 15)
end

-- แท็บ 6: ปรับแต่งภาพและเครื่อง
do
	local page = UI.createTab("ปรับแต่งภาพ", 6)
	local secPerf = UI.section(page, "ลดภาระเครื่องและปลดล็อกเฟรมเรต", 1)
	UI.toggle(secPerf, "ซ่อนสัตว์เลี้ยงของคอกผู้เล่นคนอื่น", "", "OptHideOtherPets", 1)
	UI.toggle(secPerf, "ซ่อนสัตว์เลี้ยงในคอกของตัวเอง", "", "OptHideSelfPets", 2)
	UI.toggle(secPerf, "ปิดวิดีโอบนจอลู่วิ่งทั้งหมด", "", "OptDisableTreadmillVideos", 3)
	UI.toggle(secPerf, "ปิดเอฟเฟกต์ประกายและลำแสง", "", "OptDisableParticles", 4)
	UI.toggle(secPerf, "ปิดเงาและฟิลเตอร์หลังประมวลผล", "", "OptDisableShadowsAndPostFX", 5)
	UI.toggle(secPerf, "ลดรายละเอียดพื้นผิวสิ่งก่อสร้างทั้งฉาก", "", "OptSimplifyMaterials", 6)
	UI.toggle(secPerf, "ซ่อนของตกแต่งและต้นไม้ที่ไม่ต้องชน", "", "OptHideWorldDecorations", 7)
	UI.toggle(secPerf, "ปิดเสียงเอฟเฟกต์และเพลงทั้งหมดในเกม", "", "OptMuteGameAudio", 8)
	UI.toggle(secPerf, "ปลดล็อกขีดจำกัดเฟรมเรตสูง", "", "OptUnlockFPS", 9)
end

-- แท็บ 7: โหมดฮาๆ และเคลื่อนไหว (ตัวหมุนซิงค์เซิร์ฟเวอร์!)
do
	local page = UI.createTab("โหมดฮาๆ", 7)

	local secSpin = UI.section(page, "ตัวหมุนความเร็วสูงแบบคนอื่นในเซิร์ฟเวอร์เห็นชัดเจน", 1, "ใช้แรงบิดฟิสิกส์จริงบนแกนหลักพร้อมปิดระบบหันตามตัวของเกมทำให้ซิงค์ขึ้นทุกคนในห้อง")
	UI.toggle(secSpin, "เปิดโหมดตัวหมุนความเร็วสูงซิงค์เซิร์ฟเวอร์", "ตัวละครจะปั่นสุดแรงให้ผู้เล่นทุกคนรอบข้างเห็นได้จริง", "FunSpin", 1, function(on: boolean)
		if not on then Fun.cleanupPhysics() end
	end)
	UI.dropdown(secSpin, "รูปแบบการหมุน", "", function()
		return { "หมุนแนวราบคมกริบ", "หมุนสามมิติพายุทอร์นาโด" }
	end, function() return Config.FunSpinMode end, function(v) Config.FunSpinMode = v end, 2)
	UI.dropdown(secSpin, "ทิศทางการหมุน", "", function()
		return { "ตามเข็มนาฬิกา", "ทวนเข็มนาฬิกา" }
	end, function() return Config.FunSpinDir end, function(v) Config.FunSpinDir = v end, 3)
	UI.slider(secSpin, "ความเร็วรอบในการหมุน", "ปรับได้สูงถึง 36000 องศาต่อวินาที", "FunSpinSpeed", 60, 36000, 120, 4, "องศา/วิ")
	UI.toggle(secSpin, "หมุนเฉพาะส่วนหัวรอบตัว 360 องศา", "", "FunHeadSpin", 5)
	UI.slider(secSpin, "ความเร็วหมุนส่วนหัว", "", "FunHeadSpinSpeed", 60, 7200, 60, 6, "องศา/วิ")

	local secMove = UI.section(page, "ขยายขนาดตัวละครและเคลื่อนไหวเหนือธรรมชาติ", 2)
	UI.toggle(secMove, "เปิดปรับขนาดตัวละคร", "", "FunScaleEnabled", 1)
	UI.dropdown(secMove, "โหมดปรับขนาด", "", function()
		return { "ทั้งตัว", "แยกส่วน" }
	end, function() return Config.FunScaleMode end, function(v) Config.FunScaleMode = v end, 2)
	UI.slider(secMove, "สัดส่วนขนาดตัวละครรวม", "", "FunScale", 0.2, 8.0, 0.1, 3, "เท่า")
	for idx, pDef in ipairs(Data.FunParts) do
		UI.slider(secMove, "ปรับขนาด" .. pDef.name, "", pDef.key, 0.2, 6.0, 0.1, 3 + idx, "เท่า")
	end
	UI.toggle(secMove, "เปิดโหมดบินอิสระ", "ควบคุมด้วยปุ่มเดินปกติ กดกระโดดขึ้นบน กดนั่งลงล่าง", "FunFly", 12, function(on: boolean)
		if not on then Fun.cleanupPhysics() end
	end)
	UI.slider(secMove, "ความเร็วในการบิน", "", "FunFlySpeed", 16, 400, 4, 13, "หน่วย/วิ")
	UI.toggle(secMove, "เปิดโหมดเดินทะลุสิ่งกีดขวาง", "", "FunNoclip", 14)
	UI.toggle(secMove, "กระโดดกลางอากาศไม่จำกัด", "", "FunInfJump", 15)
	UI.toggle(secMove, "ลดแรงโน้มถ่วงลอยตัวเบา", "", "FunZeroGrav", 16)
end

-- แท็บ 8: โปรไฟล์และการตั้งค่า
do
	local page = UI.createTab("ตั้งค่าและโปรไฟล์", 8)

	local secProf = UI.section(page, "จัดการโปรไฟล์และการตั้งค่า", 1)
	local profDrop = UI.dropdown(secProf, "เลือกโปรไฟล์ที่บันทึกไว้", "", function()
		local list: { string } = {}
		for k in pairs(ProfilesStore) do table.insert(list, k) end
		table.sort(list)
		return list
	end, function()
		return CurrentProfileName
	end, function(chosen: string)
		if ProfilesStore[chosen] then
			CurrentProfileName = chosen
			mergeProfileTable(ProfilesStore[chosen], Config)
			UI.applyThemeAndTypography()
			syncFeatureConflictBadges()
			saveProfilesToDisk()
			UI.notify("สลับใช้โปรไฟล์ " .. chosen .. " แล้ว", "success", 2)
		end
	end, 1)

	UI.inputRow(secProf, "พิมพ์ชื่อโปรไฟล์ใหม่ หรือเว้นว่างเพื่อเขียนทับเดิม...", "บันทึกโปรไฟล์", 2, function(txt: string)
		local trimmed = txt:gsub("^%s+", ""):gsub("%s+$", "")
		local target = (trimmed ~= "") and trimmed or CurrentProfileName
		local copy = Data.createDefaultConfig()
		mergeProfileTable(Config, copy)
		ProfilesStore[target] = copy
		CurrentProfileName = target
		profDrop.Rebuild()
		profDrop.Refresh()
		UI.applyThemeAndTypography()
		local okSave, reason = saveProfilesToDisk()
		UI.notify(okSave and ("บันทึกโปรไฟล์ " .. target .. " สำเร็จ") or ("เก็บไว้ในรอบนี้แล้ว: " .. reason), okSave and "success" or "warning", 2.5)
	end)

	UI.button(secProf, "ลบโปรไฟล์ปัจจุบัน", "danger", 3, function()
		local count = 0
		for _ in pairs(ProfilesStore) do count += 1 end
		if count <= 1 then
			UI.notify("ไม่สามารถลบโปรไฟล์สุดท้ายได้", "warning", 2.5)
			return
		end
		local removed = CurrentProfileName
		ProfilesStore[removed] = nil
		for name in pairs(ProfilesStore) do
			CurrentProfileName = name
			break
		end
		mergeProfileTable(ProfilesStore[CurrentProfileName], Config)
		profDrop.Rebuild()
		profDrop.Refresh()
		UI.applyThemeAndTypography()
		saveProfilesToDisk()
		UI.notify("ลบโปรไฟล์ " .. removed .. " แล้ว", "warning", 2.5)
	end)

	UI.button(secProf, "หยุดระบบอัตโนมัติทั้งหมดทันที", "subtle", 4, function()
		Steal.AbortRequested = true
		Steal.ForcedUid = nil
		Config.FullAutoPlay = false
		Config.AutoStealEgg = false
		Config.AutoPlaceEgg = false
		Config.AutoHatchEgg = false
		Config.AutoTreadmill = false
		Config.AutoAttack = false
		Config.FunSpin = false
		Config.FunHeadSpin = false
		Config.FunFly = false
		Fun.cleanupPhysics()
		UI.refreshAll()
		UI.setStatus("หยุดการทำงานอัตโนมัติทั้งหมดแล้ว", "idle", 0)
		UI.notify("ปิดการทำงานอัตโนมัติทั้งหมดแล้ว", "warning", 2)
	end)

	UI.button(secProf, "รีเซ็ตค่าทั้งหมดกลับเป็นค่าเริ่มต้น", "subtle", 5, function()
		mergeProfileTable(Data.createDefaultConfig(), Config)
		Fun.cleanupPhysics()
		UI.applyThemeAndTypography()
		syncFeatureConflictBadges()
		UI.notify("รีเซ็ตการตั้งค่าทั้งหมดเรียบร้อย", "success", 2.5)
	end)

	UI.button(secProf, "ถอดถอนหน้าต่างเมนูและคืนค่าตัวเกม", "danger", 6, function()
		if type(ExecEnv.__MYGAME1_THAI_UI_CLEANUP) == "function" then
			ExecEnv.__MYGAME1_THAI_UI_CLEANUP()
		end
	end)

	local secTheme = UI.section(page, "ธีมสี ตัวอักษร และความโปร่งใส", 2)
	UI.dropdown(secTheme, "เลือกธีมสีหน้าต่าง", "เปลี่ยนสีทุกส่วนประกอบทันทีแบบไร้รอยต่อ", function() return Data.ThemeNames end, function() return Config.ThemeName end, function(v)
		Config.ThemeName = v
		UI.applyThemeAndTypography()
	end, 1)
	UI.dropdown(secTheme, "เลือกฟอนต์ตัวอักษร", "", function() return Data.FontNames end, function() return Config.FontName end, function(v)
		Config.FontName = v
		UI.applyThemeAndTypography()
	end, 2)
	UI.slider(secTheme, "ขนาดตัวอักษร", "", "FontSize", 10, 22, 1, 3, "จุด", function() UI.applyThemeAndTypography() end)
	UI.slider(secTheme, "ขนาดย่อขยายหน้าต่างเมนู", "", "GuiScalePercent", 65, 140, 5, 4, "%", function() UI.applyThemeAndTypography() end)
	UI.toggle(secTheme, "เปิดพื้นหลังเบลอเมื่อเปิดเมนู", "", "BackgroundBlur", 5, function() UI.applyThemeAndTypography() end)
	UI.slider(secTheme, "ความโปร่งใสพื้นหลัง", "", "BackgroundTransparency", 0, 75, 2, 6, "%", function() UI.applyThemeAndTypography() end)

	local secKeys = UI.section(page, "ตั้งปุ่มลัดคีย์บอร์ดภาษาไทย", 3)
	UI.toggle(secKeys, "เปิดใช้งานปุ่มลัดทั้งหมด", "", "KeybindsEnabled", 1)
	local kbMeta: { { key: string, label: string } } = {
		{ key = "ToggleGUI", label = "เปิดหรือซ่อนหน้าต่างเมนู" },
		{ key = "FullAutoPlay", label = "เปิดหรือปิดโหมดเล่นอัตโนมัติครบวงจร" },
		{ key = "AutoStealEgg", label = "เปิดหรือปิดออโต้ขโมยไข่" },
		{ key = "AutoPlaceEgg", label = "เปิดหรือปิดออโต้วางไข่ลงคอก" },
		{ key = "AutoHatchEgg", label = "เปิดหรือปิดออโต้ฟักไข่" },
		{ key = "AutoTreadmill", label = "เปิดหรือปิดออโต้ลู่วิ่ง" },
		{ key = "AutoEquipBest", label = "เปิดหรือปิดใส่ตัวเก่งสุด" },
		{ key = "AutoClaimReward", label = "เปิดหรือปิดรับรางวัลอัตโนมัติ" },
		{ key = "AutoAttack", label = "เปิดหรือปิดออโต้หวดผู้เล่น" },
		{ key = "AntiFall", label = "เปิดหรือปิดกันล้ม" },
		{ key = "FunSpin", label = "เปิดหรือปิดตัวหมุนความเร็วสูง" },
		{ key = "FunFly", label = "เปิดหรือปิดบินอิสระ" },
		{ key = "FunNoclip", label = "เปิดหรือปิดเดินทะลุกำแพง" },
		{ key = "EggESP", label = "เปิดหรือปิดแสดงตำแหน่งไข่" },
		{ key = "PlayerESP", label = "เปิดหรือปิดแสดงตำแหน่งผู้เล่น" },
	}
	for i, meta in ipairs(kbMeta) do
		UI.keybindRow(secKeys, meta.label, meta.key, i + 1)
	end
end

-- อัปเดตคิวขโมยไข่อินไลน์ ปุ่มลัด ระบบลูปหลัก และตัวทำความสะอาดครบวงจร
local LastQueueUiAt = 0
local function updateInlineQueueAndSecurity()
	if os.clock() - LastQueueUiAt < 0.45 then
		return
	end
	LastQueueUiAt = os.clock()

	-- อัปเดตข้อมูลปิงและสกัดภัยบนหัวหน้าต่าง
	local pingMs = 0
	pcall(function()
		local net = StatsService and StatsService:FindFirstChild("Network")
		local ssi = net and net:FindFirstChild("ServerStatsItem")
		local dp = ssi and ssi:FindFirstChild("Data Ping")
		if dp then
			pingMs = math.floor((dp :: any):GetValue() + 0.5)
		end
	end)
	if not next(Runtime.StaffDetected) and UI.SecurityChip and UI.SecurityChip.Parent then
		UI.SecurityChip.Text = string.format("ปิง %d มส. • สกัด %d • ปลอดภัย", pingMs, Runtime.BlockedStrikes)
		UI.SecurityChip.TextColor3 = curTheme().Success
	end

	-- อัปเดตการ์ดยามอินไลน์
	if GuardRiskLabel and GuardRiskLabel.Parent then
		local guards = GameAPI.getGuards()
		local nearestDist = math.huge
		local chasingName: string? = nil
		for _, g in ipairs(guards) do
			if g.Dist < nearestDist then
				nearestDist = g.Dist
			end
			if g.State == "Chase" or g.Dist <= g.AlertDist + 8 then
				chasingName = Data.AreaThaiById[g.Area] or g.Area
			end
		end
		if chasingName then
			GuardRiskLabel.Text = string.format("เตือนภัยยามเขต %s • ห่าง %.0f ม.", chasingName, nearestDist)
			GuardRiskLabel.TextColor3 = curTheme().Warning
		elseif nearestDist < math.huge then
			GuardRiskLabel.Text = string.format("สถานะยาม: ปลอดภัย (ใกล้สุด %.0f ม. | กันตีแล้ว %d)", nearestDist, Runtime.BlockedStrikes)
			GuardRiskLabel.TextColor3 = curTheme().Success
		else
			GuardRiskLabel.Text = "สถานะยาม: ปลอดภัย (" .. tostring(Runtime.BlockedStrikes) .. " ครั้งที่สกัด)"
			GuardRiskLabel.TextColor3 = curTheme().Success
		end
	end

	-- อัปเดตเป้าหมายอันดับ 1 และคิว 6 แถวอินไลน์
	if HeroLabel and HeroLabel.Parent then
		local cands = GameAPI.getSortedStealCandidates()
		if #cands == 0 then
			HeroLabel.Text = Runtime.FieldResetting
				and "สนามกำลังรีเซ็ต • รอรอบใหม่เปิดสักครู่"
				or "ยังไม่มีไข่ตรงเงื่อนไขในสนาม (ลองปรับตัวกรองหรือรอไข่เกิด)"
		else
			local top = cands[1]
			local m = top.Metrics
			local pinPrefix = (top.PinOrder < math.huge) and "★ [ปักหมุด] " or "★ เป้าหมายอันดับหนึ่ง: "
			local areaTh = Data.AreaThaiById[m.AreaId] or m.AreaId
			HeroLabel.Text = string.format(
				"%s%s • %s\n%s • %s/วิ • %.0f ม. [%s]",
				pinPrefix,
				m.DisplayName,
				m.RarityThai,
				m.MutationThai,
				GameAPI.formatNum(m.Income),
				top.Dist,
				areaTh
			)
		end

		for i = 1, #QueueRowsUI do
			local row = QueueRowsUI[i]
			local item = cands[i]
			if item then
				local m = item.Metrics
				local pMark = (item.PinOrder < math.huge) and "★ " or ""
				row.Uid = item.Uid
				row.Label.Text = string.format(
					"%s#%d %s (%s) • %s/วิ • %.0fม.",
					pMark,
					i,
					m.DisplayName,
					m.RarityThai,
					GameAPI.formatNum(m.Income),
					item.Dist
				)
				row.Frame.Visible = true
			else
				row.Uid = nil
				row.Frame.Visible = false
			end
		end
	end
end

-- ระบบปุ่มลัดคีย์บอร์ด
trackConn(UserInputService.InputBegan, function(input: InputObject, gameProcessed: boolean)
	if input.UserInputType ~= Enum.UserInputType.Keyboard or input.KeyCode == Enum.KeyCode.Unknown then
		return
	end
	local codeName = input.KeyCode.Name

	if ListeningKeybindId then
		if codeName == "Escape" then
			ListeningKeybindId = nil
			UI.refreshAll()
			return
		end
		local nextCode = (codeName == "Backspace" or codeName == "Delete") and "" or codeName
		Config.Keybinds[ListeningKeybindId] = nextCode
		ListeningKeybindId = nil
		UI.refreshAll()
		UI.notify("ตั้งค่าปุ่มลัดเรียบร้อยแล้ว", "success", 2)
		return
	end

	if gameProcessed or not Config.KeybindsEnabled then
		return
	end

	if codeName == Config.Keybinds.ToggleGUI then
		UI.setWindowOpen(not Runtime.WindowOpen)
		return
	end

	local KeyThaiLabels: { [string]: string } = {
		FullAutoPlay = "เล่นอัตโนมัติครบวงจร",
		AutoStealEgg = "ออโต้ขโมยไข่",
		AutoPlaceEgg = "ออโต้วางไข่ลงคอก",
		AutoHatchEgg = "ออโต้ฟักไข่",
		AutoTreadmill = "ออโต้ลู่วิ่ง",
		AutoEquipBest = "ใส่ตัวเก่งสุด",
		AutoClaimReward = "รับรางวัลอัตโนมัติ",
		AutoAttack = "ออโต้หวดผู้เล่น",
		AntiFall = "กันล้ม",
		FunSpin = "ตัวหมุนความเร็วสูง",
		FunFly = "บินอิสระ",
		FunNoclip = "เดินทะลุกำแพง",
		EggESP = "แสดงตำแหน่งไข่",
		PlayerESP = "แสดงตำแหน่งผู้เล่น",
	}
	for cfgKey, boundKey in pairs(Config.Keybinds) do
		if cfgKey ~= "ToggleGUI" and boundKey == codeName and type(Config[cfgKey]) == "boolean" then
			Config[cfgKey] = not Config[cfgKey]
			if cfgKey == "FunSpin" or cfgKey == "FunFly" then
				if not Config[cfgKey] then
					Fun.cleanupPhysics()
				end
			end
			syncFeatureConflictBadges(cfgKey)
			UI.refreshAll()
			local disp = KeyThaiLabels[cfgKey] or cfgKey
			UI.notify(disp .. " : " .. (Config[cfgKey] and "เปิด" or "ปิด"), Config[cfgKey] and "success" or "warning", 1.8)
		end
	end
end)

-- ลูปฟิสิกส์ความเร็วสูง (ตัวหมุน บิน เดินเร็ว ทะลุกำแพง)
trackConn(RunService.PreSimulation, function(dt: number)
	local ok, err = pcall(Fun.preSimulationStep, dt)
	if not ok then
		warn("[ไทยคลีน] ฟิสิกส์ผิดพลาด:", err)
	end
end)

-- ลูปเรนเดอร์ภาพตรวจจับ 3 มิติ และเส้นชี้เป้า 2 มิติ
trackConn(RunService.RenderStepped, function()
	local ok, err = pcall(ESP.tick)
	if not ok then
		warn("[ไทยคลีน] ระบบเรนเดอร์ผิดพลาด:", err)
	end
end)

-- ลูปหลักบริหารฟาร์ม กิจกรรม ต่อสู้ เอาเปรียบระบบ และประสิทธิภาพ
local LastSlowStepAt = 0
trackConn(RunService.Heartbeat, function()
	pcall(Farm.tick)
	if os.clock() - LastSlowStepAt >= 0.22 then
		LastSlowStepAt = os.clock()
		pcall(Events.tick)
		pcall(Combat.tick)
		pcall(Exploits.tick)
		pcall(Perf.applyStep)
		pcall(updateInlineQueueAndSecurity)
	end
end)

-- ตัวทำความสะอาดถอดถอนหน้าต่างและคืนค่าตัวเกมสมบูรณ์
ExecEnv.__MYGAME1_THAI_UI_CLEANUP = function()
	if not Runtime.Running then
		return
	end
	Runtime.Running = false
	Steal.AbortRequested = true

	for _, conn in ipairs(Runtime.Connections) do
		pcall(function()
			conn:Disconnect()
		end)
	end
	table.clear(Runtime.Connections)

	for _, fn in ipairs(Runtime.Cleanups) do
		pcall(fn)
	end
	table.clear(Runtime.Cleanups)

	local ragMod = GameAPI.Modules and GameAPI.Modules.Ragdoll
	if ragMod then
		local rm = ragMod :: any
		if type(rm.__OrigRagdoll) == "function" then
			ragMod.Ragdoll = rm.__OrigRagdoll
			rm.__OrigRagdoll = nil
		end
	end

	ExecEnv.__MYGAME1_THAI_UI_CLEANUP = nil
end

-- เปิดแท็บแรกและปรับธีมเริ่มต้นพร้อมแจ้งเตือนพร้อมใช้งาน
UI.selectTab("ออโต้และฟาร์ม")
UI.applyThemeAndTypography()
syncFeatureConflictBadges()
UI.setStatus("พร้อมทำงานเต็มประสิทธิภาพ", "success", 1)
UI.notify("โหลดเมนูไทยครบวงจรสำเร็จ กดปุ่มวงกลมหรือคอนโทรลขวาเพื่อเปิด/ซ่อน", "success", 4)

