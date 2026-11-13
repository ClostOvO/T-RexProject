--[[
    mygame2_thai_ui_clean.lua
    ระบบช่วยเหลือการเล่นเกมตกปลา (Fisch) แบบอัตโนมัติครบวงจร รูปแบบภาษาไทยมาตรฐานสะอาด
    ออกแบบตามสถาปัตยกรรม thai-clean-ui และอิงการทำงานจริงจากสคริปต์ตัวเกม mygame02.lua
--]]

local GlobalEnv: any = (type(getgenv) == "function" and getgenv()) or _G
if type(GlobalEnv.__FischThaiCleanV2Cleanup) == "function" then
    pcall(GlobalEnv.__FischThaiCleanV2Cleanup)
end
if type(_G.__FischThaiCleanV2Cleanup) == "function" and _G.__FischThaiCleanV2Cleanup ~= GlobalEnv.__FischThaiCleanV2Cleanup then
    pcall(_G.__FischThaiCleanV2Cleanup)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local PathfindingService = game:GetService("PathfindingService")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- ============================================================================
-- 1. เครื่องมือความปลอดภัย วงจรชีวิต และป้องกันการทำงานซ้ำ
-- ============================================================================

local IsScriptRunning = true
local ActiveConnections = {}
local reportFailure: ((string, any) -> ())? = nil

local function connectSignal(sig: RBXScriptSignal, fn: (...any) -> ()): RBXScriptConnection
    local conn = sig:Connect(function(...: any)
        if not IsScriptRunning then
            return
        end
        local ok, err = pcall(fn, ...)
        if not ok and reportFailure then
            reportFailure("สัญญาณ", err)
        end
    end)
    table.insert(ActiveConnections, conn)
    if #ActiveConnections % 64 == 0 then
        for idx = #ActiveConnections, 1, -1 do
            if not ActiveConnections[idx].Connected then
                table.remove(ActiveConnections, idx)
            end
        end
    end
    return conn
end

local function isTextBoxFocused(): boolean
    local ok, focused = pcall(UserInputService.GetFocusedTextBox, UserInputService)
    return ok and focused ~= nil
end

local function safeRequire(inst: Instance?): any
    if not inst then
        return nil
    end
    local reqFn: any = require
    local ok, mod = pcall(reqFn, inst)
    if ok then
        return mod
    end
    return nil
end

local function clearExistingGui(name: string)
    if type(gethui) == "function" then
        pcall(function()
            local hui = gethui()
            local old = hui and hui:FindFirstChild(name)
            if old then
                old:Destroy()
            end
        end)
    end
    pcall(function()
        local oldCore = CoreGui:FindFirstChild(name)
        if oldCore then
            oldCore:Destroy()
        end
    end)
    pcall(function()
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        local oldPg = pg and pg:FindFirstChild(name)
        if oldPg then
            oldPg:Destroy()
        end
    end)
end

local function mountScreenGui(gui: ScreenGui): Instance?
    clearExistingGui(gui.Name)
    if type(gethui) == "function" then
        local okHui, hui = pcall(gethui)
        if okHui and hui then
            local okMount = pcall(function()
                gui.Parent = hui
            end)
            if okMount and gui.Parent == hui then
                return hui
            end
        end
    end
    local okCore = pcall(function()
        gui.Parent = CoreGui
    end)
    if okCore and gui.Parent == CoreGui then
        return CoreGui
    end
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10)
    if pg then
        gui.Parent = pg
        return pg
    end
    return nil
end

-- ============================================================================
-- 2. ชุดสีมาตรฐาน ฟอนต์ภาษาไทย และข้อมูลแผนที่อ้างอิง
-- ============================================================================

local THEMES = {
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

local THAI_FONTS = {
    ["โกธิคทันสมัย"] = Enum.Font.GothamMedium,
    ["โกธิคหนา"] = Enum.Font.GothamBold,
    ["ซอร์สแซนส์"] = Enum.Font.SourceSans,
    ["ซอร์สแซนส์หนา"] = Enum.Font.SourceSansBold,
    ["อารีย์"] = Enum.Font.Arial,
}

local KEYCODE_THAI_NAMES = {
    [Enum.KeyCode.RightControl] = "คอนโทรลขวา",
    [Enum.KeyCode.LeftControl] = "คอนโทรลซ้าย",
    [Enum.KeyCode.RightShift] = "ชิฟต์ขวา",
    [Enum.KeyCode.LeftShift] = "ชิฟต์ซ้าย",
    [Enum.KeyCode.RightAlt] = "อัลต์ขวา",
    [Enum.KeyCode.LeftAlt] = "อัลต์ซ้าย",
    [Enum.KeyCode.Insert] = "อินเสิร์ต",
    [Enum.KeyCode.Home] = "โฮม",
    [Enum.KeyCode.End] = "เอนด์",
    [Enum.KeyCode.PageUp] = "เพจอัป",
    [Enum.KeyCode.PageDown] = "เพจดาวน์",
    [Enum.KeyCode.F1] = "เอฟ 1",
    [Enum.KeyCode.F2] = "เอฟ 2",
    [Enum.KeyCode.F3] = "เอฟ 3",
    [Enum.KeyCode.F4] = "เอฟ 4",
    [Enum.KeyCode.F5] = "เอฟ 5",
    [Enum.KeyCode.F6] = "เอฟ 6",
    [Enum.KeyCode.F7] = "เอฟ 7",
    [Enum.KeyCode.F8] = "เอฟ 8",
    [Enum.KeyCode.F9] = "เอฟ 9",
    [Enum.KeyCode.F10] = "เอฟ 10",
    [Enum.KeyCode.F11] = "เอฟ 11",
    [Enum.KeyCode.F12] = "เอฟ 12",
}

local function getThaiKeyName(code: Enum.KeyCode?): string
    if not code then
        return "ไม่ได้ตั้งค่า"
    end
    return KEYCODE_THAI_NAMES[code] or code.Name
end

local ISLAND_DOCKS = {
    { Name = "เกาะมูสวูด", Pos = Vector3.new(290, 134, 230) },
    { Name = "อ่าวรอสลิต", Pos = Vector3.new(-1475, 134, 675) },
    { Name = "เกาะหินสุริยัน", Pos = Vector3.new(-925, 224, -995) },
    { Name = "เกาะเต่าเทอร์ราพิน", Pos = Vector3.new(-175, 145, 1935) },
    { Name = "เกาะยอดหิมะสโนว์แคป", Pos = Vector3.new(2620, 140, 2395) },
    { Name = "ป่าพรุมัชโกรฟ", Pos = Vector3.new(2445, 134, -695) },
    { Name = "เกาะโบราณแอนเชียน", Pos = Vector3.new(5950, 174, 380) },
    { Name = "หลุมลึกเวอร์ติโก", Pos = Vector3.new(-110, -514, 1070) },
    { Name = "ทะเลลึกเดโซเลต", Pos = Vector3.new(-1650, -214, -2840) },
    { Name = "แท่นปลุกพลังผู้รักษา", Pos = Vector3.new(1310, -802, -100) },
}

-- ============================================================================
-- 3. ค่าตั้งต้นและโครงสร้างสถานะระบบ
-- ============================================================================

local DefaultConfig = {
    ThemeName = "ชมพูซากุระ",
    FontName = "โกธิคทันสมัย",
    FontSize = 14,
    GuiScalePercent = 100,
    BackgroundTransparency = 8,
    BackgroundBlur = false,
    MenuKeybindCode = "RightControl",

    -- ระบบออโต้ครบวงจร
    AutoFish = false,
    AutoSkipOnboarding = true,
    AutoWalkToWater = true,
    WalkRangeLimit = 180,
    AutoFaceWater = true,
    AutoStepAdjustOnFail = true,
    AntiFallWater = true,
    AutoEquipRod = true,
    AutoEquipBait = false,
    PreferredBait = "ไม่เปลี่ยนอัตโนมัติ",
    AutoCast = true,
    CastPower = 100,
    AlwaysPerfectCast = true,
    CastStuckTimeout = 18,
    FastShake = true,
    ShakeDelayMs = 280,
    HideShakeOverlay = false,
    AutoReel = true,
    ReelLockCenter = true,
    ReelBigBar = true,
    ReelAlwaysPerfect = true,
    InstantReel = false,
    ReelFinishDelayMs = 250,
    ReelSpeedBoost = 120,
    AutoResetOnLand = true,

    -- การขายปลา และกรงดักปู
    AutoSell = false,
    AutoSellInterval = 45,
    WalkToMerchantToSell = false,
    AutoCrabCagePlace = false,
    AutoCrabCageClaim = false,

    -- เก็บของ เสกของ และรางวัลอัตโนมัติ
    AutoDailyReward = true,
    AutoClaimChallenges = false,
    AutoClaimMeteors = false,
    AutoCollectItemSpawns = false,
    AutoCollectAllMap = false,
    AutoClaimEventRewards = false,
    SpawnerCategory = "ปลาในสารานุกรม",
    SpawnerItemName = "Megalodon",
    SpawnerScalePercent = 100,
    SpawnerShiny = false,
    SpawnerSparkling = false,

    -- ระบบดึงเอนทีตี้ไปยังจุดหมาย
    EntityPullCategory = "ทุกประเภท",
    EntityPullSearchName = "",
    EntityPullTargetName = "ทุกตัวในหมวด",
    EntityPullDestMode = "ด้านหน้าตัวเรา",
    EntityPullDestIsland = "เกาะมูสวูด",
    EntityPullCustomCoords = "290, 136, 230",
    EntityPullFrontDist = 10,
    EntityPullGridSpacing = 4,
    EntityPullNoCollide = true,
    EntityPullLoop = false,

    -- สายตรวจจับและเรดาร์
    UnlockGameRadar = false,
    ESPPlayers = false,
    ESPBobbers = false,
    ESPHuntZones = false,
    ESPChestsAndMeteors = false,
    ESPNPCs = false,
    ESPCrabCages = false,
    ESPTracers = false,

    -- โหมดหรรษา (หมวดฮาๆ)
    Spinbot = false,
    SpinSpeedDeg = 3600,
    HeadSpin = false,
    WalkOnWater = false,
    FloatMode = false,
    FlyMode = false,
    FlySpeed = 65,
    InfiniteJump = false,
    Noclip = false,

    -- เอาเปรียบระบบเกมและตัวละคร
    BypassSpeedLock = true,
    FastWalk = false,
    WalkSpeedValue = 42,
    HighJump = false,
    JumpPowerValue = 90,
    AntiDrown = true,
    AntiFreezeSlow = true,
    AntiAFK = true,
    BoatSpeedBoost = false,
    BoatSpeedMultiplier = 2,
    RemoveDarkScreen = true,
    UnlockMaxZoom = true,
    ClearUnderwaterVision = false,
}

local Config: {[string]: any} = {}
for k, v in pairs(DefaultConfig) do
    Config[k] = v
end

local Runtime = {
    BotStateText = "พร้อมทำงาน • รอรับคำสั่ง",
    ProgressRatio = 0,
    CatchesCount = 0,
    IsNavigating = false,
    LastShoreSpot = nil :: Vector3?,
    LastWaterTarget = nil :: Vector3?,
    LastNavDestination = nil :: Vector3?,
}

-- ============================================================================
-- 4. จัดการโปรไฟล์และการตรวจสอบค่าตัวเลข
-- ============================================================================

local ProfilePath = "FischCleanUI_Profile_v2.json"

local function sanitizeConfig(raw: any)
    if type(raw) ~= "table" then
        return
    end
    for k, defaultVal in pairs(DefaultConfig) do
        local incoming = raw[k]
        if incoming ~= nil and type(incoming) == type(defaultVal) then
            if type(defaultVal) == "number" then
                if incoming == incoming and math.abs(incoming) < math.huge then
                    Config[k] = incoming
                end
            else
                Config[k] = incoming
            end
        end
    end
    if not THEMES[Config.ThemeName] then
        Config.ThemeName = DefaultConfig.ThemeName
    end
    if not THAI_FONTS[Config.FontName] then
        Config.FontName = DefaultConfig.FontName
    end
    Config.FontSize = math.clamp(math.round(Config.FontSize), 10, 24)
    Config.GuiScalePercent = math.clamp(math.round(Config.GuiScalePercent), 60, 150)
    Config.BackgroundTransparency = math.clamp(math.round(Config.BackgroundTransparency), 0, 85)
    Config.CastPower = math.clamp(math.round(Config.CastPower), 10, 100)
    Config.ShakeDelayMs = math.clamp(math.round(Config.ShakeDelayMs), 250, 800)
    Config.ReelFinishDelayMs = math.clamp(math.round(Config.ReelFinishDelayMs), 0, 2500)
    Config.ReelSpeedBoost = math.clamp(math.round(Config.ReelSpeedBoost), 20, 500)
    Config.SpinSpeedDeg = math.clamp(math.round(Config.SpinSpeedDeg), 60, 14400)
    Config.WalkSpeedValue = math.clamp(math.round(Config.WalkSpeedValue), 16, 200)
    Config.JumpPowerValue = math.clamp(math.round(Config.JumpPowerValue), 50, 250)
    Config.FlySpeed = math.clamp(math.round(Config.FlySpeed), 20, 250)
    Config.BoatSpeedMultiplier = math.clamp(Config.BoatSpeedMultiplier, 1, 6)
    Config.SpawnerScalePercent = math.clamp(math.round(Config.SpawnerScalePercent), 25, 300)
    Config.EntityPullFrontDist = math.clamp(math.round(Config.EntityPullFrontDist), 2, 120)
    Config.EntityPullGridSpacing = math.clamp(math.round(Config.EntityPullGridSpacing), 0, 30)
    local validPullCats = {
        ["ทุกประเภท"] = true,
        ["ผู้เล่นอื่น"] = true,
        ["พ่อค้าและตัวละครระบบ"] = true,
        ["เรือทั้งหมด"] = true,
        ["ปลาและบอสในฉาก"] = true,
        ["ไอเทม หีบสมบัติ และกรงปู"] = true,
        ["สิ่งมีชีวิตทั่วไปในฉาก"] = true,
    }
    if not validPullCats[Config.EntityPullCategory] then
        Config.EntityPullCategory = DefaultConfig.EntityPullCategory
    end
    local validPullDestModes = {
        ["ด้านหน้าตัวเรา"] = true,
        ["จุดที่ปักหมุดไว้"] = true,
        ["ตำแหน่งเมาส์ชี้"] = true,
        ["เกาะหรือจุดเกิดที่เลือก"] = true,
        ["พิกัดกำหนดเอง"] = true,
    }
    if not validPullDestModes[Config.EntityPullDestMode] then
        Config.EntityPullDestMode = DefaultConfig.EntityPullDestMode
    end
    local validCats = {
        ["ปลาในสารานุกรม"] = true,
        ["ไอเทมทั่วไป"] = true,
        ["เบ็ดตกปลา"] = true,
        ["เรือและยานพาหนะ"] = true,
        ["เหยื่อตกปลา"] = true,
    }
    if not validCats[Config.SpawnerCategory] then
        Config.SpawnerCategory = DefaultConfig.SpawnerCategory
    end
end

local function saveProfile(): boolean
    if type(writefile) ~= "function" then
        return false
    end
    local ok = pcall(function()
        local payload = {}
        for k, v in pairs(Config) do
            payload[k] = v
        end
        writefile(ProfilePath, HttpService:JSONEncode(payload))
    end)
    return ok
end

local function loadProfile(): boolean
    if type(isfile) ~= "function" or type(readfile) ~= "function" then
        return false
    end
    local ok = pcall(function()
        if isfile(ProfilePath) then
            local decoded = HttpService:JSONDecode(readfile(ProfilePath))
            sanitizeConfig(decoded)
        end
    end)
    return ok
end

loadProfile()

local function getMenuKeyCode(): Enum.KeyCode?
    if type(Config.MenuKeybindCode) ~= "string" or Config.MenuKeybindCode == "" then
        return nil
    end
    local ok, kc = pcall(function()
        return Enum.KeyCode[Config.MenuKeybindCode]
    end)
    return ok and kc or nil
end

-- ============================================================================
-- 5. การเข้าถึงรีโมตและโมดูลเกมจริงจาก mygame02.lua
-- ============================================================================

local NetCache: {[string]: Instance} = {}
local CachedControllers = {
    Net = nil :: any,
    Backpack = nil :: any,
    Reel = nil :: any,
    Stab = nil :: any,
    Data = nil :: any,
    CrabCage = nil :: any,
    Environment = nil :: any,
    Zone = nil :: any,
}

local function resolveModule(pathParts: {string}): any
    local curr: Instance = ReplicatedStorage
    for _, part in ipairs(pathParts) do
        local nextChild = curr:FindFirstChild(part)
        if not nextChild then
            return nil
        end
        curr = nextChild
    end
    return safeRequire(curr)
end

local function getNetModule(): any
    if not CachedControllers.Net then
        CachedControllers.Net = resolveModule({"packages", "Net"})
    end
    return CachedControllers.Net
end

local function getBackpackUI(): any
    if not CachedControllers.Backpack then
        CachedControllers.Backpack = resolveModule({"client", "modules", "ui", "Backpack"})
    end
    return CachedControllers.Backpack
end

local function getReelController(): any
    if not CachedControllers.Reel then
        CachedControllers.Reel = resolveModule({"client", "legacyControllers", "ReelController"})
    end
    return CachedControllers.Reel
end

local function getStabController(): any
    if not CachedControllers.Stab then
        CachedControllers.Stab = resolveModule({"client", "legacyControllers", "StabController"})
    end
    return CachedControllers.Stab
end

local function getDataController(): any
    if not CachedControllers.Data then
        CachedControllers.Data = resolveModule({"client", "legacyControllers", "DataController"})
    end
    return CachedControllers.Data
end

local function getCrabCageController(): any
    if not CachedControllers.CrabCage then
        CachedControllers.CrabCage = resolveModule({"client", "legacyControllers", "CrabCageController"})
    end
    return CachedControllers.CrabCage
end

local function getEnvironmentController(): any
    if not CachedControllers.Environment then
        CachedControllers.Environment = resolveModule({"client", "legacyControllers", "EnvironmentResourceController"})
    end
    return CachedControllers.Environment
end

local function getZoneController(): any
    if not CachedControllers.Zone then
        CachedControllers.Zone = resolveModule({"client", "legacyControllers", "ZoneController"})
    end
    return CachedControllers.Zone
end

local function getNetRemote(category: string, name: string): any
    local prefix = (category == "RF" or category == "RemoteFunction") and "RF/" or "RE/"
    local cacheKey = prefix .. name
    local cached = NetCache[cacheKey]
    if cached and cached.Parent then
        return cached
    end

    local packages = ReplicatedStorage:FindFirstChild("packages")
    local netFolder = packages and packages:FindFirstChild("Net")
    if netFolder then
        local direct = netFolder:FindFirstChild(cacheKey)
        if direct then
            NetCache[cacheKey] = direct
            return direct
        end
    end

    local netMod = getNetModule()
    if netMod then
        local ok, r = pcall(function()
            if prefix == "RF/" then
                return netMod:RemoteFunction(name, -1)
            else
                return netMod:RemoteEvent(name, -1)
            end
        end)
        if ok and r then
            NetCache[cacheKey] = r
            return r
        end
    end
    return nil
end

local function getEventsRemote(name: string): any
    local events = ReplicatedStorage:FindFirstChild("events")
    return events and events:FindFirstChild(name) or nil
end

-- ============================================================================
-- 6. สถาปัตยกรรมหน้าต่างหลักมาตรฐาน 740x460 (THAI CLEAN UI)
-- ============================================================================

local ThemeRegistry = {}
local TextRegistry = {}
local UIRefreshCallbacks: {() -> ()} = {}
local TabPages: {[string]: ScrollingFrame} = {}
local TabButtons: {[string]: {Button: TextButton, Indicator: Frame}} = {}
local ActiveTabName = ""

local function registerTheme(inst: Instance, prop: string, role: string)
    table.insert(ThemeRegistry, { Instance = inst, Property = prop, Role = role })
end

local function registerText(inst: Instance, baseSize: number, isBold: boolean?)
    table.insert(TextRegistry, { Instance = inst, BaseSize = baseSize, IsBold = isBold or false })
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FischThaiCleanUI_V2"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
mountScreenGui(ScreenGui)

-- โฟลเดอร์แยกสำหรับ 3D BillboardGui / Highlight และ Layer แยกสำหรับ 2D Tracers (ตาม Gotchas)
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESPFolder"
ESPFolder.Parent = ScreenGui

local RenderLayer = Instance.new("Frame")
RenderLayer.Name = "RenderLayer"
RenderLayer.Size = UDim2.fromScale(1, 1)
RenderLayer.BackgroundTransparency = 1
RenderLayer.BorderSizePixel = 0
RenderLayer.ZIndex = 1
RenderLayer.Parent = ScreenGui

local BlurEffect: BlurEffect? = nil
local function ensureBlurEffect(): BlurEffect?
    if not BlurEffect or not BlurEffect.Parent then
        local existing = Lighting:FindFirstChild("FischCleanUIBlur")
        if existing and existing:IsA("BlurEffect") then
            BlurEffect = existing
        else
            local created = Instance.new("BlurEffect")
            created.Name = "FischCleanUIBlur"
            created.Size = 10
            created.Enabled = false
            created.Parent = Lighting
            BlurEffect = created
        end
    end
    return BlurEffect
end

local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.fromOffset(740, 460)
MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
MainWindow.Position = UDim2.fromScale(0.5, 0.5)
MainWindow.BorderSizePixel = 0
MainWindow.ClipsDescendants = true
MainWindow.ZIndex = 10
MainWindow.Parent = ScreenGui

local MainScale = Instance.new("UIScale")
MainScale.Name = "MainScale"
MainScale.Parent = MainWindow

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainWindow

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainWindow

registerTheme(MainWindow, "BackgroundColor3", "Bg")
registerTheme(MainStroke, "Color", "Border")

-- แถบหัวเรื่อง (TopBar สูง 50 พิกเซล)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BorderSizePixel = 0
TopBar.Active = true
TopBar.ZIndex = 12
TopBar.Parent = MainWindow

local TopBarCover = Instance.new("Frame")
TopBarCover.Name = "TopBarCover"
TopBarCover.Size = UDim2.new(1, 0, 0, 14)
TopBarCover.Position = UDim2.new(0, 0, 1, -14)
TopBarCover.BorderSizePixel = 0
TopBarCover.ZIndex = 12
TopBarCover.Parent = TopBar

registerTheme(TopBar, "BackgroundColor3", "Sidebar")
registerTheme(TopBarCover, "BackgroundColor3", "Sidebar")

local AccentDot = Instance.new("Frame")
AccentDot.Name = "AccentDot"
AccentDot.Size = UDim2.fromOffset(10, 10)
AccentDot.Position = UDim2.new(0, 18, 0.5, -5)
AccentDot.BorderSizePixel = 0
AccentDot.ZIndex = 13
AccentDot.Parent = TopBar

local AccentDotCorner = Instance.new("UICorner")
AccentDotCorner.CornerRadius = UDim.new(1, 0)
AccentDotCorner.Parent = AccentDot
registerTheme(AccentDot, "BackgroundColor3", "Accent")

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Name = "HeaderTitle"
HeaderTitle.Size = UDim2.new(0, 320, 1, 0)
HeaderTitle.Position = UDim2.fromOffset(38, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "ศูนย์ช่วยเหลือเกมตกปลาครบวงจร"
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.ZIndex = 13
HeaderTitle.Parent = TopBar
registerTheme(HeaderTitle, "TextColor3", "Text")
registerText(HeaderTitle, 17, true)

local ActiveProfileBadge = Instance.new("TextLabel")
ActiveProfileBadge.Name = "ActiveProfileBadge"
ActiveProfileBadge.AnchorPoint = Vector2.new(1, 0.5)
ActiveProfileBadge.Position = UDim2.new(1, -108, 0.5, 0)
ActiveProfileBadge.Size = UDim2.fromOffset(175, 28)
ActiveProfileBadge.BorderSizePixel = 0
ActiveProfileBadge.Text = "โปรไฟล์: ค่าบันทึกหลัก"
ActiveProfileBadge.ZIndex = 13
ActiveProfileBadge.Parent = TopBar

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, 12)
BadgeCorner.Parent = ActiveProfileBadge

local BadgeStroke = Instance.new("UIStroke")
BadgeStroke.Thickness = 1
BadgeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
BadgeStroke.Parent = ActiveProfileBadge

registerTheme(ActiveProfileBadge, "BackgroundColor3", "Card")
registerTheme(ActiveProfileBadge, "TextColor3", "SubText")
registerTheme(BadgeStroke, "Color", "Border")
registerText(ActiveProfileBadge, 12, false)

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.AnchorPoint = Vector2.new(1, 0.5)
CloseButton.Position = UDim2.new(1, -14, 0.5, 0)
CloseButton.Size = UDim2.fromOffset(84, 30)
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "ปิดหน้าต่าง"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.AutoButtonColor = false
CloseButton.ZIndex = 14
CloseButton.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton
registerText(CloseButton, 12, true)

-- แถบนำทางด้านซ้าย (Sidebar กว้าง 175 พิกเซล)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Position = UDim2.fromOffset(0, 50)
Sidebar.Size = UDim2.new(0, 175, 1, -50)
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 11
Sidebar.Parent = MainWindow
registerTheme(Sidebar, "BackgroundColor3", "Sidebar")

local SidebarScroll = Instance.new("ScrollingFrame")
SidebarScroll.Size = UDim2.fromScale(1, 1)
SidebarScroll.BackgroundTransparency = 1
SidebarScroll.BorderSizePixel = 0
SidebarScroll.ScrollBarThickness = 2
SidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
SidebarScroll.CanvasSize = UDim2.fromScale(0, 0)
SidebarScroll.ZIndex = 12
SidebarScroll.Parent = Sidebar
registerTheme(SidebarScroll, "ScrollBarImageColor3", "Accent")

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 12)
SidebarPadding.PaddingBottom = UDim.new(0, 12)
SidebarPadding.PaddingLeft = UDim.new(0, 10)
SidebarPadding.PaddingRight = UDim.new(0, 10)
SidebarPadding.Parent = SidebarScroll

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.Parent = SidebarScroll

-- แถบสถานะด้านบนเนื้อหา (StatusBanner สูง 48 พิกเซล)
local StatusBanner = Instance.new("Frame")
StatusBanner.Name = "StatusBanner"
StatusBanner.Position = UDim2.fromOffset(185, 56)
StatusBanner.Size = UDim2.new(1, -195, 0, 48)
StatusBanner.BorderSizePixel = 0
StatusBanner.ZIndex = 12
StatusBanner.Parent = MainWindow

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusBanner

local StatusStroke = Instance.new("UIStroke")
StatusStroke.Thickness = 1
StatusStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
StatusStroke.Parent = StatusBanner

local StatusDot = Instance.new("Frame")
StatusDot.Name = "StatusDot"
StatusDot.Size = UDim2.fromOffset(8, 8)
StatusDot.Position = UDim2.fromOffset(12, 13)
StatusDot.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
StatusDot.BorderSizePixel = 0
StatusDot.ZIndex = 13
StatusDot.Parent = StatusBanner

local StatusDotCorner = Instance.new("UICorner")
StatusDotCorner.CornerRadius = UDim.new(1, 0)
StatusDotCorner.Parent = StatusDot

local StatusBannerLabel = Instance.new("TextLabel")
StatusBannerLabel.Name = "StatusBannerLabel"
StatusBannerLabel.Position = UDim2.fromOffset(28, 3)
StatusBannerLabel.Size = UDim2.new(1, -36, 0, 28)
StatusBannerLabel.BackgroundTransparency = 1
StatusBannerLabel.Text = "สถานะระบบ: พร้อมทำงาน • รอรับคำสั่ง"
StatusBannerLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusBannerLabel.TextWrapped = true
StatusBannerLabel.TextTruncate = Enum.TextTruncate.AtEnd
StatusBannerLabel.ZIndex = 13
StatusBannerLabel.Parent = StatusBanner

local ProgressTrack = Instance.new("Frame")
ProgressTrack.Name = "ProgressTrack"
ProgressTrack.Position = UDim2.fromOffset(12, 36)
ProgressTrack.Size = UDim2.new(1, -24, 0, 5)
ProgressTrack.BorderSizePixel = 0
ProgressTrack.ZIndex = 13
ProgressTrack.Parent = StatusBanner

local ProgressTrackCorner = Instance.new("UICorner")
ProgressTrackCorner.CornerRadius = UDim.new(1, 0)
ProgressTrackCorner.Parent = ProgressTrack

local ProgressFill = Instance.new("Frame")
ProgressFill.Name = "ProgressFill"
ProgressFill.Size = UDim2.fromScale(0, 1)
ProgressFill.BorderSizePixel = 0
ProgressFill.ZIndex = 14
ProgressFill.Parent = ProgressTrack

local ProgressFillCorner = Instance.new("UICorner")
ProgressFillCorner.CornerRadius = UDim.new(1, 0)
ProgressFillCorner.Parent = ProgressFill

registerTheme(StatusBanner, "BackgroundColor3", "Card")
registerTheme(StatusStroke, "Color", "Border")
registerTheme(StatusBannerLabel, "TextColor3", "Text")
registerTheme(ProgressTrack, "BackgroundColor3", "Sidebar")
registerTheme(ProgressFill, "BackgroundColor3", "Accent")
registerText(StatusBannerLabel, 12, false)

local function setStatus(msg: string, level: string?, progress: number?)
    Runtime.BotStateText = msg
    if StatusBannerLabel and StatusBannerLabel.Parent then
        StatusBannerLabel.Text = "สถานะระบบ: " .. msg
    end
    if StatusDot and StatusDot.Parent then
        if level == "error" then
            StatusDot.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
        elseif level == "warn" then
            StatusDot.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
        else
            StatusDot.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
        end
    end
    if progress ~= nil and ProgressFill and ProgressFill.Parent then
        Runtime.ProgressRatio = math.clamp(progress, 0, 1)
        ProgressFill.Size = UDim2.fromScale(Runtime.ProgressRatio, 1)
    end
end

reportFailure = function(scope: string, err: any)
    setStatus("พบข้อผิดพลาดในระบบ" .. scope .. " • " .. tostring(err), "error")
end

-- กล่องแสดงเนื้อหาแต่ละแท็บ (ContentContainer)
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Position = UDim2.fromOffset(185, 112)
ContentContainer.Size = UDim2.new(1, -195, 1, -120)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ZIndex = 11
ContentContainer.Parent = MainWindow

-- วงกลมลอยสลับหน้าต่าง (CircleOverlay)
local CircleOverlay = Instance.new("TextButton")
CircleOverlay.Name = "CircleOverlay"
CircleOverlay.AnchorPoint = Vector2.new(1, 1)
CircleOverlay.Position = UDim2.new(1, -24, 1, -24)
CircleOverlay.Size = UDim2.fromOffset(64, 64)
CircleOverlay.BorderSizePixel = 0
CircleOverlay.Text = "ซ่อนเมนู"
CircleOverlay.AutoButtonColor = false
CircleOverlay.ZIndex = 50
CircleOverlay.Parent = ScreenGui

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = CircleOverlay

local CircleStroke = Instance.new("UIStroke")
CircleStroke.Thickness = 2.5
CircleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
CircleStroke.Parent = CircleOverlay

registerTheme(CircleOverlay, "BackgroundColor3", "Card")
registerTheme(CircleOverlay, "TextColor3", "Accent")
registerTheme(CircleStroke, "Color", "Accent")
registerText(CircleOverlay, 13, true)

-- กล่องแจ้งเตือนป็อปอัปมุมขวาล่าง (ToastContainer)
local ToastContainer = Instance.new("Frame")
ToastContainer.Name = "ToastContainer"
ToastContainer.AnchorPoint = Vector2.new(1, 1)
ToastContainer.Position = UDim2.new(1, -24, 1, -98)
ToastContainer.Size = UDim2.fromOffset(290, 220)
ToastContainer.BackgroundTransparency = 1
ToastContainer.ZIndex = 60
ToastContainer.Parent = ScreenGui

local ToastLayout = Instance.new("UIListLayout")
ToastLayout.SortOrder = Enum.SortOrder.LayoutOrder
ToastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
ToastLayout.Padding = UDim.new(0, 6)
ToastLayout.Parent = ToastContainer

local function showToast(message: string, duration: number?)
    if not IsScriptRunning or not ToastContainer.Parent then
        return
    end
    local dur = duration or 2.3
    local curTheme = THEMES[Config.ThemeName] or THEMES["ชมพูซากุระ"]
    local curFont = THAI_FONTS[Config.FontName] or Enum.Font.GothamMedium

    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(1, 0, 0, 42)
    toast.BackgroundColor3 = curTheme.Card
    toast.BorderSizePixel = 0
    toast.ZIndex = 61
    toast.Parent = ToastContainer

    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(0, 8)
    tCorner.Parent = toast

    local tStroke = Instance.new("UIStroke")
    tStroke.Thickness = 1.2
    tStroke.Color = curTheme.Accent
    tStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    tStroke.Parent = toast

    local leftBar = Instance.new("Frame")
    leftBar.Size = UDim2.new(0, 4, 1, 0)
    leftBar.BackgroundColor3 = curTheme.Accent
    leftBar.BorderSizePixel = 0
    leftBar.ZIndex = 62
    leftBar.Parent = toast

    local lCorner = Instance.new("UICorner")
    lCorner.CornerRadius = UDim.new(0, 4)
    lCorner.Parent = leftBar

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -18, 1, 0)
    label.Position = UDim2.fromOffset(12, 0)
    label.BackgroundTransparency = 1
    label.Text = message
    label.TextColor3 = curTheme.Text
    label.Font = curFont
    label.TextSize = 12
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 62
    label.Parent = toast

    task.delay(dur, function()
        if toast and toast.Parent then
            local info = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tw = TweenService:Create(toast, info, { BackgroundTransparency = 1 })
            TweenService:Create(label, info, { TextTransparency = 1 }):Play()
            TweenService:Create(leftBar, info, { BackgroundTransparency = 1 }):Play()
            TweenService:Create(tStroke, info, { Transparency = 1 }):Play()
            tw:Play()
            tw.Completed:Connect(function()
                if toast and toast.Parent then
                    toast:Destroy()
                end
            end)
        end
    end)
end

-- ระบบลากหน้าต่างและป้องกันคลิกลั่น (Drag vs Click Guard)
local function makeDraggable(target: GuiObject, handle: GuiObject, onClick: (() -> ())?)
    local dragging = false
    local hasMoved = false
    local dragStart = Vector2.zero
    local startPos = UDim2.new()

    connectSignal(handle.InputBegan, function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if handle == TopBar then
                local cp = CloseButton.AbsolutePosition
                local cs = CloseButton.AbsoluteSize
                if input.Position.X >= cp.X - 6 and input.Position.X <= cp.X + cs.X + 6 and input.Position.Y >= cp.Y - 6 and input.Position.Y <= cp.Y + cs.Y + 6 then
                    return
                end
            end
            dragging = true
            hasMoved = false
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos = target.Position
        end
    end)

    connectSignal(UserInputService.InputChanged, function(input: InputObject)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            if delta.Magnitude > 6 then
                hasMoved = true
                target.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end
    end)

    connectSignal(UserInputService.InputEnded, function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                local wasMoved = hasMoved
                task.defer(function()
                    hasMoved = false
                end)
                if not wasMoved and onClick then
                    onClick()
                end
            end
        end
    end)
end

local IsWindowOpen = true
local function setWindowOpen(state: boolean)
    IsWindowOpen = state
    MainWindow.Visible = state
    CircleOverlay.Text = state and "ซ่อนเมนู" or "เปิดเมนู"
    local blur = ensureBlurEffect()
    if blur then
        blur.Enabled = state and Config.BackgroundBlur
    end
end

makeDraggable(MainWindow, TopBar, nil)
makeDraggable(CircleOverlay, CircleOverlay, function()
    setWindowOpen(not IsWindowOpen)
end)

connectSignal(CloseButton.MouseButton1Click, function()
    setWindowOpen(false)
end)

-- การผูกสีและฟอนต์แบบไดนามิก
local function applyAppearance()
    local pal = THEMES[Config.ThemeName] or THEMES["ชมพูซากุระ"]
    local font = THAI_FONTS[Config.FontName] or Enum.Font.GothamMedium

    for _, entry in ipairs(ThemeRegistry) do
        local inst = entry.Instance
        if inst and inst.Parent then
            local color = pal[entry.Role]
            if color then
                if entry.Property == "BackgroundColor3" and inst:IsA("GuiObject") then
                    inst.BackgroundColor3 = color
                elseif entry.Property == "TextColor3" and (inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox")) then
                    inst.TextColor3 = color
                elseif entry.Property == "Color" and inst:IsA("UIStroke") then
                    inst.Color = color
                elseif entry.Property == "ScrollBarImageColor3" and inst:IsA("ScrollingFrame") then
                    inst.ScrollBarImageColor3 = color
                end
            end
        end
    end

    for _, entry in ipairs(TextRegistry) do
        local inst = entry.Instance
        if inst and inst.Parent and (inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox")) then
            inst.Font = font
            inst.TextSize = math.clamp(math.round(entry.BaseSize * Config.FontSize / 14), 8, 36)
        end
    end

    for tabName, data in pairs(TabButtons) do
        local current = (tabName == ActiveTabName)
        data.Indicator.Visible = current
        data.Button.BackgroundColor3 = current and pal.CardHover or pal.Card
        data.Button.TextColor3 = current and pal.Accent or pal.Text
    end

    MainWindow.BackgroundTransparency = math.clamp(Config.BackgroundTransparency / 100, 0, 0.85)

    local desiredScale = math.clamp(Config.GuiScalePercent / 100, 0.6, 1.5)
    local cam = Workspace.CurrentCamera
    if cam and cam.ViewportSize.X > 0 and cam.ViewportSize.Y > 0 then
        local maxFitX = (cam.ViewportSize.X * 0.94) / 740
        local maxFitY = (cam.ViewportSize.Y * 0.92) / 460
        desiredScale = math.min(desiredScale, maxFitX, maxFitY)
    end
    MainScale.Scale = math.max(desiredScale, 0.45)

    local blur = ensureBlurEffect()
    if blur then
        blur.Enabled = IsWindowOpen and Config.BackgroundBlur
    end
end

local function refreshAllUI()
    applyAppearance()
    for _, cb in ipairs(UIRefreshCallbacks) do
        pcall(cb)
    end
end

-- ============================================================================
-- 7. ตัวสร้างส่วนติดต่อผู้ใช้แบบแยกส่วน (UI BUILDERS)
-- ============================================================================

local function createTabPage(name: string): ScrollingFrame
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Page_" .. name
    scroll.Size = UDim2.fromScale(1, 1)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageTransparency = 0.2
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.fromScale(0, 0)
    scroll.Visible = false
    scroll.ZIndex = 12
    scroll.Parent = ContentContainer

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 2)
    pad.PaddingBottom = UDim.new(0, 14)
    pad.PaddingLeft = UDim.new(0, 2)
    pad.PaddingRight = UDim.new(0, 8)
    pad.Parent = scroll

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = scroll

    registerTheme(scroll, "ScrollBarImageColor3", "Accent")
    TabPages[name] = scroll
    return scroll
end

local function selectTab(name: string)
    ActiveTabName = name
    for tabName, page in pairs(TabPages) do
        page.Visible = (tabName == name)
    end
    applyAppearance()
end

local function createTabButton(name: string, order: number)
    local btn = Instance.new("TextButton")
    btn.Name = "TabBtn_" .. name
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.AutoButtonColor = false
    btn.LayoutOrder = order
    btn.ZIndex = 13
    btn.Parent = SidebarScroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = btn

    local ind = Instance.new("Frame")
    ind.Name = "Indicator"
    ind.Size = UDim2.new(0, 4, 0, 20)
    ind.Position = UDim2.new(0, 3, 0.5, -10)
    ind.BorderSizePixel = 0
    ind.Visible = false
    ind.ZIndex = 14
    ind.Parent = btn

    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(0, 2)
    indCorner.Parent = ind

    registerTheme(ind, "BackgroundColor3", "Accent")
    registerText(btn, 13, true)

    TabButtons[name] = { Button = btn, Indicator = ind }
    connectSignal(btn.MouseButton1Click, function()
        selectTab(name)
    end)
end

local function createSectionCard(parent: Instance, title: string, order: number?): Frame
    local card = Instance.new("Frame")
    card.Name = "Card_" .. title
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundTransparency = 0.12
    card.BorderSizePixel = 0
    card.LayoutOrder = order or 0
    card.ZIndex = 12
    card.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 11)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = card

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 12)
    pad.PaddingBottom = UDim.new(0, 12)
    pad.PaddingLeft = UDim.new(0, 14)
    pad.PaddingRight = UDim.new(0, 14)
    pad.Parent = card

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = card

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 22)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.LayoutOrder = 0
    titleLabel.ZIndex = 13
    titleLabel.Parent = card

    registerTheme(card, "BackgroundColor3", "Card")
    registerTheme(stroke, "Color", "Border")
    registerTheme(titleLabel, "TextColor3", "Accent")
    registerText(titleLabel, 15, true)
    return card
end

local function createToggleRow(parent: Instance, title: string, desc: string, configKey: string, onChanged: ((boolean) -> ())?)
    local row = Instance.new("Frame")
    row.Name = "Toggle_" .. configKey
    row.Size = UDim2.new(1, 0, 0, 0)
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.BackgroundTransparency = 1
    row.ZIndex = 13
    row.Parent = parent

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -78, 0, 20)
    titleLabel.Position = UDim2.fromOffset(0, 2)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextWrapped = true
    titleLabel.AutomaticSize = Enum.AutomaticSize.Y
    titleLabel.ZIndex = 14
    titleLabel.Parent = row

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -78, 0, 0)
    descLabel.Position = UDim2.fromOffset(0, 24)
    descLabel.AutomaticSize = Enum.AutomaticSize.Y
    descLabel.BackgroundTransparency = 1
    descLabel.Text = desc
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 14
    descLabel.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(66, 27)
    btn.Position = UDim2.new(1, -66, 0, 2)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.ZIndex = 14
    btn.Parent = row

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    registerTheme(titleLabel, "TextColor3", "Text")
    registerTheme(descLabel, "TextColor3", "SubText")
    registerText(titleLabel, 13, true)
    registerText(descLabel, 11, false)
    registerText(btn, 12, true)

    local function updateVisual()
        local active = Config[configKey] == true
        local pal = THEMES[Config.ThemeName] or THEMES["ชมพูซากุระ"]
        btn.Text = active and "เปิด" or "ปิด"
        btn.BackgroundColor3 = active and pal.AccentSoft or pal.Sidebar
        btn.TextColor3 = active and Color3.fromRGB(255, 255, 255) or pal.SubText
    end
    updateVisual()

    connectSignal(btn.MouseButton1Click, function()
        local newVal = not (Config[configKey] == true)
        Config[configKey] = newVal
        updateVisual()
        if onChanged then
            onChanged(newVal)
        end
    end)

    table.insert(UIRefreshCallbacks, updateVisual)
end

local function createBoxInputRowShell(parent: Instance, rowName: string, title: string, desc: string, boxWidth: number, initialText: string): TextBox
    local row = Instance.new("Frame")
    row.Name = rowName
    row.Size = UDim2.new(1, 0, 0, 0)
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.BackgroundTransparency = 1
    row.ZIndex = 13
    row.Parent = parent

    local textMargin = -(boxWidth + 10)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, textMargin, 0, 20)
    titleLabel.Position = UDim2.fromOffset(0, 2)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 14
    titleLabel.Parent = row

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, textMargin, 0, 0)
    descLabel.Position = UDim2.fromOffset(0, 22)
    descLabel.AutomaticSize = Enum.AutomaticSize.Y
    descLabel.BackgroundTransparency = 1
    descLabel.Text = desc
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 14
    descLabel.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.fromOffset(boxWidth, 27)
    box.Position = UDim2.new(1, -boxWidth, 0, 2)
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    box.Text = initialText
    box.ZIndex = 14
    box.Parent = row

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = box

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = box

    registerTheme(titleLabel, "TextColor3", "Text")
    registerTheme(descLabel, "TextColor3", "SubText")
    registerTheme(box, "BackgroundColor3", "Sidebar")
    registerTheme(box, "TextColor3", "Text")
    registerTheme(stroke, "Color", "Border")
    registerText(titleLabel, 13, true)
    registerText(descLabel, 11, false)
    registerText(box, 12, false)

    return box
end

local function createNumericInputRow(parent: Instance, title: string, desc: string, configKey: string, minVal: number, maxVal: number, onChanged: ((number) -> ())?)
    local box = createBoxInputRowShell(
        parent,
        "Numeric_" .. configKey,
        title,
        desc .. " [" .. tostring(minVal) .. "-" .. tostring(maxVal) .. "]",
        80,
        tostring(Config[configKey])
    )

    connectSignal(box.FocusLost, function()
        local cleaned = box.Text:gsub("%s+", ""):gsub(",", "")
        local num = tonumber(cleaned)
        if type(num) == "number" and num == num and math.abs(num) < math.huge then
            local clamped = math.clamp(num, minVal, maxVal)
            Config[configKey] = clamped
            box.Text = tostring(clamped)
            if onChanged then
                onChanged(clamped)
            end
        else
            box.Text = tostring(Config[configKey])
            showToast("ตัวเลขที่กรอกใช้ไม่ได้ จึงใช้ค่าเดิม")
        end
    end)

    table.insert(UIRefreshCallbacks, function()
        if UserInputService:GetFocusedTextBox() ~= box then
            box.Text = tostring(Config[configKey])
        end
    end)
end

local function createTextInputRow(parent: Instance, title: string, desc: string, configKey: string, onChanged: ((string) -> ())?, allowEmpty: boolean?)
    local box = createBoxInputRowShell(
        parent,
        "Text_" .. configKey,
        title,
        desc,
        158,
        tostring(Config[configKey] or "")
    )

    connectSignal(box.FocusLost, function()
        local trimmed = box.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if trimmed ~= "" or allowEmpty == true then
            Config[configKey] = trimmed
            box.Text = trimmed
            if onChanged then
                onChanged(trimmed)
            end
        else
            box.Text = tostring(Config[configKey] or "")
        end
    end)

    table.insert(UIRefreshCallbacks, function()
        if UserInputService:GetFocusedTextBox() ~= box then
            box.Text = tostring(Config[configKey] or "")
        end
    end)
end

local function createActionRow(parent: Instance, title: string, desc: string, btnText: string, isDanger: boolean, callback: () -> ())
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 0)
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.BackgroundTransparency = 1
    row.ZIndex = 13
    row.Parent = parent

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -124, 0, 20)
    titleLabel.Position = UDim2.fromOffset(0, 2)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.ZIndex = 14
    titleLabel.Parent = row

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -124, 0, 0)
    descLabel.Position = UDim2.fromOffset(0, 22)
    descLabel.AutomaticSize = Enum.AutomaticSize.Y
    descLabel.BackgroundTransparency = 1
    descLabel.Text = desc
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 14
    descLabel.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(116, 28)
    btn.Position = UDim2.new(1, -116, 0, 2)
    btn.BorderSizePixel = 0
    btn.Text = btnText
    btn.AutoButtonColor = false
    btn.ZIndex = 14
    btn.Parent = row

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    registerTheme(titleLabel, "TextColor3", "Text")
    registerTheme(descLabel, "TextColor3", "SubText")
    registerText(titleLabel, 13, true)
    registerText(descLabel, 11, false)
    registerText(btn, 12, true)

    if isDanger then
        btn.BackgroundColor3 = Color3.fromRGB(185, 28, 28)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        registerTheme(btn, "BackgroundColor3", "AccentSoft")
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    connectSignal(btn.MouseButton1Click, callback)
end

local function createDropdownRow(parent: Instance, title: string, desc: string, configKey: string?, optionsProvider: {string} | (() -> {string}), defaultText: string, onSelect: (string) -> ()): () -> ()
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 0)
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.BackgroundTransparency = 1
    row.ZIndex = 13
    row.Parent = parent

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -166, 0, 20)
    titleLabel.Position = UDim2.fromOffset(0, 2)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 14
    titleLabel.Parent = row

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -166, 0, 0)
    descLabel.Position = UDim2.fromOffset(0, 22)
    descLabel.AutomaticSize = Enum.AutomaticSize.Y
    descLabel.BackgroundTransparency = 1
    descLabel.Text = desc
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 14
    descLabel.Parent = row

    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.fromOffset(158, 28)
    headerBtn.Position = UDim2.new(1, -158, 0, 2)
    headerBtn.BorderSizePixel = 0
    headerBtn.AutoButtonColor = false
    headerBtn.TextTruncate = Enum.TextTruncate.AtEnd
    headerBtn.ZIndex = 14
    headerBtn.Parent = row

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = headerBtn

    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1, 0, 0, 120)
    listFrame.Position = UDim2.fromOffset(0, 48)
    listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listFrame.CanvasSize = UDim2.fromScale(0, 0)
    listFrame.ScrollBarThickness = 3
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.ZIndex = 15
    listFrame.Parent = row

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 8)
    listCorner.Parent = listFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = listFrame

    registerTheme(titleLabel, "TextColor3", "Text")
    registerTheme(descLabel, "TextColor3", "SubText")
    registerTheme(headerBtn, "BackgroundColor3", "Sidebar")
    registerTheme(headerBtn, "TextColor3", "Text")
    registerTheme(listFrame, "BackgroundColor3", "Sidebar")
    registerTheme(listFrame, "ScrollBarImageColor3", "Accent")
    registerText(titleLabel, 13, true)
    registerText(descLabel, 11, false)
    registerText(headerBtn, 12, false)

    local isOpen = false
    local currentText = (configKey and tostring(Config[configKey])) or defaultText

    local function updateHeader()
        if configKey then
            currentText = tostring(Config[configKey])
        end
        headerBtn.Text = currentText .. (isOpen and " ▴" or " ▾")
    end

    local function rebuildOptions()
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        local opts = if type(optionsProvider) == "function" then (optionsProvider :: () -> {string})() else (optionsProvider :: {string})
        for idx, opt in ipairs(opts) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, -6, 0, 26)
            optBtn.BackgroundTransparency = 1
            optBtn.Text = "  " .. opt
            optBtn.TextXAlignment = Enum.TextXAlignment.Left
            optBtn.LayoutOrder = idx
            optBtn.ZIndex = 16
            optBtn.Parent = listFrame
            registerTheme(optBtn, "TextColor3", opt == currentText and "Accent" or "SubText")
            registerText(optBtn, 12, opt == currentText)

            connectSignal(optBtn.MouseButton1Click, function()
                currentText = opt
                if configKey then
                    Config[configKey] = opt
                end
                isOpen = false
                listFrame.Visible = false
                updateHeader()
                onSelect(opt)
                applyAppearance()
            end)
        end
        local count = math.min(math.max(#opts, 1), 5)
        listFrame.Size = UDim2.new(1, 0, 0, count * 28 + 4)
    end

    connectSignal(headerBtn.MouseButton1Click, function()
        isOpen = not isOpen
        if isOpen then
            rebuildOptions()
        end
        listFrame.Visible = isOpen
        updateHeader()
    end)

    rebuildOptions()
    updateHeader()
    table.insert(UIRefreshCallbacks, updateHeader)
    return rebuildOptions
end

local function createKeybindRow(parent: Instance, title: string, desc: string)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 0)
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.BackgroundTransparency = 1
    row.ZIndex = 13
    row.Parent = parent

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -158, 0, 20)
    titleLabel.Position = UDim2.fromOffset(0, 2)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 14
    titleLabel.Parent = row

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -158, 0, 0)
    descLabel.Position = UDim2.fromOffset(0, 22)
    descLabel.AutomaticSize = Enum.AutomaticSize.Y
    descLabel.BackgroundTransparency = 1
    descLabel.Text = desc
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 14
    descLabel.Parent = row

    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.fromOffset(150, 28)
    bindBtn.Position = UDim2.new(1, -150, 0, 2)
    bindBtn.BorderSizePixel = 0
    bindBtn.AutoButtonColor = false
    bindBtn.ZIndex = 14
    bindBtn.Parent = row

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = bindBtn

    registerTheme(titleLabel, "TextColor3", "Text")
    registerTheme(descLabel, "TextColor3", "SubText")
    registerTheme(bindBtn, "BackgroundColor3", "Sidebar")
    registerTheme(bindBtn, "TextColor3", "Accent")
    registerText(titleLabel, 13, true)
    registerText(descLabel, 11, false)
    registerText(bindBtn, 12, true)

    local listening = false
    local function updateLabel()
        if listening then
            bindBtn.Text = "กดปุ่มใหม่ • ยกเลิก"
        else
            bindBtn.Text = getThaiKeyName(getMenuKeyCode())
        end
    end
    updateLabel()

    connectSignal(bindBtn.MouseButton1Click, function()
        listening = true
        updateLabel()
    end)

    connectSignal(UserInputService.InputBegan, function(input: InputObject, _processed: boolean)
        if not listening then
            return
        end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            if input.KeyCode == Enum.KeyCode.Escape then
                updateLabel()
                return
            elseif input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
                Config.MenuKeybindCode = ""
                saveProfile()
                updateLabel()
                showToast("ล้างปุ่มลัดเมนูแล้ว")
                return
            end
            Config.MenuKeybindCode = input.KeyCode.Name
            saveProfile()
            updateLabel()
            showToast("เปลี่ยนปุ่มลัดเมนูเป็น " .. getThaiKeyName(input.KeyCode))
        end
    end)

    table.insert(UIRefreshCallbacks, updateLabel)
end

-- ============================================================================
-- 8. ระบบตรวจจับสภาพแวดล้อม น้ำจริง และสแกนหาจุดตกปลาริมน้ำ
-- ============================================================================

local waterPlatform: Part? = nil

local function getCharacterParts(): (Model?, Humanoid?, any)
    local char = LocalPlayer.Character
    if not char then
        return nil, nil, nil
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp: any = char:FindFirstChild("HumanoidRootPart")
    return char, hum, hrp
end

local function buildWorldRaycastParams(ignoreWater: boolean, respectCollide: boolean?): RaycastParams
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local exclude: {Instance} = {}
    local char = LocalPlayer.Character
    if char then
        table.insert(exclude, char)
    end
    if waterPlatform then
        table.insert(exclude, waterPlatform)
    end
    params.FilterDescendantsInstances = exclude
    params.IgnoreWater = ignoreWater
    if respectCollide ~= nil then
        params.RespectCanCollide = respectCollide
    end
    return params
end

local function isPartWaterInstance(inst: Instance?): boolean
    if not inst then
        return false
    end
    if CollectionService:HasTag(inst, "PartWater") then
        return true
    end
    local zonesFolder = Workspace:FindFirstChild("zones")
    local fishingFolder = zonesFolder and zonesFolder:FindFirstChild("fishing")
    if fishingFolder and inst:IsDescendantOf(fishingFolder) then
        return true
    end
    return false
end

local function detectWaterSurfaceAt(x: number, refY: number, z: number): number?
    local origin = Vector3.new(x, refY + 45, z)
    local params = buildWorldRaycastParams(false, nil)

    local res = Workspace:Raycast(origin, Vector3.new(0, -160, 0), params)
    if res then
        if res.Material == Enum.Material.Water or isPartWaterInstance(res.Instance) then
            return res.Position.Y
        end
        if res.Instance and res.Instance:IsA("BasePart") and res.Instance.CanCollide == false and res.Instance.Name:lower():find("water") then
            return res.Position.Y
        end
    end

    for _, part in ipairs(CollectionService:GetTagged("PartWater")) do
        if part:IsA("BasePart") then
            local localPos = part.CFrame:PointToObjectSpace(Vector3.new(x, refY, z))
            if math.abs(localPos.X) <= part.Size.X * 0.5 + 4 and math.abs(localPos.Z) <= part.Size.Z * 0.5 + 4 then
                return part.Position.Y + part.Size.Y * 0.5
            end
        end
    end
    return nil
end

local function detectSolidFloorAt(x: number, refY: number, z: number): Vector3?
    local params = buildWorldRaycastParams(true, true)

    local res = Workspace:Raycast(Vector3.new(x, refY + 8, z), Vector3.new(0, -40, 0), params)
    if res and res.Instance and res.Instance:IsA("BasePart") and res.Instance.CanCollide and res.Material ~= Enum.Material.Water then
        if res.Normal.Y >= 0.7 and math.abs(res.Position.Y - refY) <= 24 then
            return res.Position
        end
    end
    return nil
end

local function isClearWaterCast(fromPos: Vector3, waterPos: Vector3): boolean
    local params = buildWorldRaycastParams(true, true)

    local startP = fromPos + Vector3.new(0, 3.2, 0)
    local endP = waterPos + Vector3.new(0, 3.2, 0)
    local hit = Workspace:Raycast(startP, endP - startP, params)
    return hit == nil
end

-- สแกนจุดยืนริมตลิ่งหรือท่าเรือที่ปลอดภัยและหันหน้าลงแหล่งน้ำจริงได้ทันที
local function findBestShorelineSpot(originPos: Vector3, maxRadius: number): (Vector3?, Vector3?)
    local bestScore = math.huge
    local bestStand: Vector3? = nil
    local bestWater: Vector3? = nil

    -- ตรวจสอบจุดใกล้ตัวก่อน 8 ทิศทาง
    for _, radius in ipairs({ 6, 16, 28, 44, 65, 95, 130, 165 }) do
        if radius > maxRadius then
            break
        end
        local steps = radius <= 30 and 12 or 16
        for i = 0, steps - 1 do
            local ang = (math.pi * 2 / steps) * i
            local dir = Vector3.new(math.cos(ang), 0, math.sin(ang))
            local probePos = originPos + dir * radius
            local floorPos = detectSolidFloorAt(probePos.X, originPos.Y, probePos.Z)
            if floorPos then
                for _, outAngleOffset in ipairs({ 0, 45, -45, 90, -90, 135, -135, 180 }) do
                    local outRad = ang + math.rad(outAngleOffset)
                    local outDir = Vector3.new(math.cos(outRad), 0, math.sin(outRad))
                    local waterProbe = floorPos + outDir * 22
                    local waterY = detectWaterSurfaceAt(waterProbe.X, floorPos.Y, waterProbe.Z)
                    if waterY and waterY <= floorPos.Y + 4 and waterY >= floorPos.Y - 35 then
                        local waterTarget = Vector3.new(waterProbe.X, waterY, waterProbe.Z)
                        if isClearWaterCast(floorPos, waterTarget) then
                            -- ให้คะแนนความใกล้ + ความปลอดภัยริมตลิ่ง
                            local innerProbe = floorPos + outDir * 5
                            local innerFloor = detectSolidFloorAt(innerProbe.X, floorPos.Y, innerProbe.Z)
                            local distCost = (floorPos - originPos).Magnitude + (innerFloor and 0 or 8)
                            if distCost < bestScore then
                                bestScore = distCost
                                bestStand = floorPos + Vector3.new(0, 3, 0)
                                bestWater = waterTarget
                            end
                        end
                    end
                end
            end
        end
        if bestStand and bestScore <= 45 then
            break
        end
    end

    return bestStand, bestWater
end

-- ============================================================================
-- 9. ระบบนำทางและเดินเท้าอัตโนมัติ (PATHFINDING & AUTO-WALK)
-- ============================================================================

local function faceDirection(targetPos: Vector3)
    local _, _, hrp = getCharacterParts()
    if hrp then
        local lookPoint = Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)
        if (lookPoint - hrp.Position).Magnitude > 0.2 then
            local rootObj: any = hrp
            rootObj.CFrame = CFrame.lookAt(hrp.Position, lookPoint)
        end
    end
end

local function walkToTarget(destination: Vector3, maxWait: number?, stopCheck: (() -> boolean)?): boolean
    local char, hum, hrp = getCharacterParts()
    if not (char and hum and hrp and hum.Health > 0) then
        return false
    end

    if (hrp.Position - destination).Magnitude <= 4.5 then
        return true
    end

    Runtime.IsNavigating = true
    Runtime.LastNavDestination = destination
    local limit = maxWait or 16
    local startTime = tick()

    local path = PathfindingService:CreatePath({
        AgentRadius = 2.2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentCanClimb = false,
        WaypointSpacing = 4,
    })

    local okCompute = pcall(function()
        path:ComputeAsync(hrp.Position, destination)
    end)

    local function shouldAbort(): boolean
        if not IsScriptRunning or not Runtime.IsNavigating then
            return true
        end
        if stopCheck and stopCheck() then
            return true
        end
        local c, h, r = getCharacterParts()
        if not (c and h and r and h.Health > 0) then
            return true
        end
        return false
    end

    if okCompute and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for idx = 2, #waypoints do
            if shouldAbort() then
                break
            end
            local wp = waypoints[idx]
            local nextFloorWater = detectWaterSurfaceAt(wp.Position.X, wp.Position.Y, wp.Position.Z)
            local nextFloorSolid = detectSolidFloorAt(wp.Position.X, wp.Position.Y, wp.Position.Z)
            if nextFloorWater and not nextFloorSolid and not Config.WalkOnWater then
                -- หยุดก่อนเดินลงน้ำลึกโดยไม่ตั้งใจ
                break
            end
            if wp.Action == Enum.PathWaypointAction.Jump then
                hum.Jump = true
            end
            hum:MoveTo(wp.Position)

            local wpStart = tick()
            local lastPos = hrp.Position
            local lastProgressTick = tick()
            while tick() - wpStart < 3.0 and tick() - startTime < limit do
                if shouldAbort() then
                    break
                end
                local dist = (hrp.Position - wp.Position).Magnitude
                if dist <= 3.6 then
                    break
                end
                if (hrp.Position - lastPos).Magnitude > 0.8 then
                    lastPos = hrp.Position
                    lastProgressTick = tick()
                elseif tick() - lastProgressTick > 1.1 then
                    -- แก้ติดสิ่งกีดขวางโดยกระโดดและสั่งเดินซ้ำ
                    hum.Jump = true
                    hum:MoveTo(wp.Position)
                    lastProgressTick = tick()
                end
                task.wait(0.06)
            end
        end
    else
        -- ระยะใกล้ที่ปลอดภัย ใช้เดินตรงโดยเช็กว่าไม่พุ่งลงทะเล
        local distDirect = (hrp.Position - destination).Magnitude
        if distDirect <= 55 then
            hum:MoveTo(destination)
            while (hrp.Position - destination).Magnitude > 4.5 and (tick() - startTime < math.min(limit, 8)) do
                if shouldAbort() then
                    break
                end
                if hum:GetState() == Enum.HumanoidStateType.Swimming and not Config.WalkOnWater then
                    hum:MoveTo(hrp.Position)
                    break
                end
                task.wait(0.1)
            end
        end
    end

    Runtime.IsNavigating = false
    local finalDist = hrp and (hrp.Position - destination).Magnitude or math.huge
    return finalDist <= 7.0
end

-- ค้นหาตำแหน่งพ่อค้าหรือตัวละคร NPC จริงตาม mygame02.lua
local function getAllLiveNPCs(): { { Name: string, NpcType: string, Pos: Vector3, Model: Model } }
    local out = {}
    local seen: {[Instance]: boolean} = {}
    local candidates = {}

    for _, inst in ipairs(CollectionService:GetTagged("NewNpc")) do
        table.insert(candidates, inst)
    end
    for _, inst in ipairs(CollectionService:GetTagged("LegacyNpc")) do
        table.insert(candidates, inst)
    end
    local world = Workspace:FindFirstChild("world")
    local npcsFolder = world and world:FindFirstChild("npcs")
    if npcsFolder then
        for _, inst in ipairs(npcsFolder:GetChildren()) do
            table.insert(candidates, inst)
        end
    end

    for _, npc in ipairs(candidates) do
        if npc:IsA("Model") and npc:IsDescendantOf(Workspace) and not seen[npc] then
            seen[npc] = true
            local pivot = npc:GetPivot().Position
            local npcType = tostring(npc:GetAttribute("NpcType") or "")
            table.insert(out, {
                Name = npc.Name,
                NpcType = npcType,
                Pos = pivot,
                Model = npc,
            })
        end
    end
    return out
end

local function findNearestMerchant(): ({ Name: string, Pos: Vector3, Model: Model }?)
    local _, _, hrp = getCharacterParts()
    local myPos = hrp and hrp.Position or Vector3.zero
    local best = nil
    local bestDist = math.huge

    for _, npc in ipairs(getAllLiveNPCs()) do
        local nLower = npc.Name:lower()
        local isMerch = (npc.NpcType == "Merchant") or (nLower:find("merchant") ~= nil) or (npc.Model:GetAttribute("UID") == "merchant_moosewood")
        if isMerch then
            local d = (npc.Pos - myPos).Magnitude
            if d < bestDist then
                bestDist = d
                best = { Name = npc.Name, Pos = npc.Pos, Model = npc.Model }
            end
        end
    end
    return best
end

-- ============================================================================
-- 10. ระบบตกปลา สวมใส่เบ็ด เขย่าทุ่น ดึงสาย และขายปลาอัจฉริยะ
-- ============================================================================

local function getEquippedRodTool(): Tool?
    local char = LocalPlayer.Character
    if not char then
        return nil
    end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            if CollectionService:HasTag(child, "RodTool") or child:FindFirstChild("rodClient") or child:FindFirstChild("values") or child.Name:lower():find("rod") then
                return child
            end
        end
    end
    return nil
end

local function findRodInBackpack(): Tool?
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not bp then
        return nil
    end
    for _, child in ipairs(bp:GetChildren()) do
        if child:IsA("Tool") then
            if CollectionService:HasTag(child, "RodTool") or child:FindFirstChild("rodClient") or child:FindFirstChild("values") or child.Name:lower():find("rod") then
                return child
            end
        end
    end
    return nil
end

local function getCurrentRodName(): string?
    local attrRod = LocalPlayer:GetAttribute("CurrentRod")
    if type(attrRod) == "string" and attrRod ~= "" then
        return attrRod
    end
    local dataCtrl = getDataController()
    if dataCtrl and dataCtrl.PlayerDataReplicator then
        local ok, rName = pcall(function()
            return dataCtrl.PlayerDataReplicator:TryIndex({"Stats", "rod"})
        end)
        if ok and type(rName) == "string" and rName ~= "" then
            return rName
        end
    end
    return nil
end

-- ระบบสวมใส่เบ็ดที่รองรับ Custom Hotbar/Backpack ของ Fisch จริงๆ
local function equipFishingRod(): Tool?
    local already = getEquippedRodTool()
    if already then
        return already
    end

    local _, hum = getCharacterParts()
    local bpTool = findRodInBackpack()
    if bpTool and hum then
        pcall(function()
            hum:EquipTool(bpTool)
        end)
        task.wait(0.15)
        local eq = getEquippedRodTool()
        if eq then
            return eq
        end
    end

    -- วิธีที่ 1: เรียก Backpack.equipRod() ของตัวเกมโดยตรง
    local bpUi = getBackpackUI()
    if bpUi and type(bpUi.equipRod) == "function" then
        pcall(function()
            bpUi.equipRod()
        end)
        task.wait(0.25)
        local eq = getEquippedRodTool()
        if eq then
            return eq
        end
    end

    -- วิธีที่ 2: สั่ง Backpack/Equip ผ่าน RemoteEvent ด้วยชื่อเบ็ดปัจจุบัน
    local rodName = getCurrentRodName()
    if rodName then
        local equipRE = getNetRemote("RE", "Backpack/Equip")
        if equipRE then
            local remoteObj: any = equipRE
            pcall(function()
                remoteObj:FireServer(rodName)
            end)
            task.wait(0.35)
        end
    end

    return getEquippedRodTool()
end

local function getOwnedRodsList(): {string}
    local list = {}
    local dataCtrl = getDataController()
    if dataCtrl and dataCtrl.PlayerDataReplicator then
        local ok, rods = pcall(function()
            return dataCtrl.PlayerDataReplicator:TryIndex({"Rods"})
        end)
        if ok and type(rods) == "table" then
            for rodName, _ in pairs(rods) do
                if type(rodName) == "string" then
                    table.insert(list, rodName)
                end
            end
        end
    end
    if #list == 0 then
        local cur = getCurrentRodName()
        table.insert(list, cur or "Training Rod")
    end
    table.sort(list)
    return list
end

local function getOwnedBaitsList(): {string}
    local list = { "ไม่เปลี่ยนอัตโนมัติ" }
    local legacyDataMod = resolveModule({"client", "modules", "legacyLocalPlayerData"})
    if legacyDataMod and type(legacyDataMod.fetch) == "function" then
        local ok, folder = pcall(function()
            local data = legacyDataMod.fetch()
            local stats = data and data:FindFirstChild("Stats")
            return stats and stats:FindFirstChild("bait")
        end)
        if ok and folder then
            for _, child in ipairs(folder:GetChildren()) do
                if child:IsA("IntValue") or child:IsA("NumberValue") then
                    if child.Value > 0 and child.Name:sub(1, 5) == "bait_" then
                        table.insert(list, child.Name:sub(6))
                    end
                end
            end
        end
    end
    return list
end

local function equipSpecificRod(rodName: string): boolean
    local equipRodRF = getNetRemote("RF", "Rod/Equip")
    if equipRodRF then
        local rfObj: any = equipRodRF
        local ok = pcall(function()
            rfObj:InvokeServer(rodName)
        end)
        if ok then
            task.wait(0.2)
            equipFishingRod()
            return true
        end
    end
    return false
end

local function equipSpecificBait(baitName: string): boolean
    if baitName == "" or baitName == "ไม่เปลี่ยนอัตโนมัติ" then
        return false
    end
    local baitRE = getNetRemote("RE", "Bait/Equip")
    if baitRE then
        local reObj: any = baitRE
        return pcall(function()
            reObj:FireServer(baitName)
        end)
    end
    return false
end

local function previewSellTotal(): number?
    local rf = getEventsRemote("PreviewSellAll")
    if rf and rf:IsA("RemoteFunction") then
        local rfObj: any = rf
        local ok, val = pcall(function()
            return rfObj:InvokeServer(false)
        end)
        if ok and type(val) == "number" then
            return val
        end
    end
    return nil
end

local function sellAllFishNow(atMerchant: boolean?): boolean
    -- ลำดับการขาย: ลอง SellAll และ selleverything
    local sellAll = getEventsRemote("SellAll")
    local sellEverything = getEventsRemote("selleverything")

    if atMerchant and sellAll and sellAll:IsA("RemoteFunction") then
        local rfObj: any = sellAll
        local ok, res = pcall(function()
            return rfObj:InvokeServer()
        end)
        if ok and res then
            showToast("ขายปลาทั้งหมดกับพ่อค้าสำเร็จ")
            return true
        end
    end

    if sellEverything and sellEverything:IsA("RemoteFunction") then
        local rfObj: any = sellEverything
        local ok, res = pcall(function()
            return rfObj:InvokeServer()
        end)
        if ok and res then
            showToast("ขายปลาทั้งหมดเรียบร้อยแล้ว")
            return true
        end
    end

    if sellAll and sellAll:IsA("RemoteFunction") then
        local rfObj: any = sellAll
        local ok, res = pcall(function()
            return rfObj:InvokeServer()
        end)
        if ok and res then
            showToast("ขายปลาทั้งหมดเรียบร้อยแล้ว")
            return true
        end
    end
    return false
end

-- ระบบดึงสายความเร็วแสง/สมบูรณ์แบบ ทำงานทุกเฟรมบน RenderStepped (ป้องกันยิงซ้ำ)
local EndedReels = setmetatable({}, { __mode = "k" })
local ReelStartTimes = setmetatable({}, { __mode = "k" })
local ReelReadyTimes = setmetatable({}, { __mode = "k" })

local function processMinigameController(ctrl: any, dt: number)
    if not ctrl or not ctrl.ActiveReel then
        return
    end
    local ar = ctrl.ActiveReel
    if EndedReels[ar] then
        return
    end

    local now = tick()
    if not ReelStartTimes[ar] then
        ReelStartTimes[ar] = now
    end

    local totalElapsedMs = (now - ReelStartTimes[ar]) * 1000
    local isReady = (ar.ready == true) or (ar.active == true and totalElapsedMs >= 2600)
    if isReady and not ReelReadyTimes[ar] then
        ReelReadyTimes[ar] = now
    end

    pcall(function()
        ar.frozenUntil = 0
        if Config.ReelAlwaysPerfect then
            ar.perfect = true
        end
        if Config.ReelBigBar then
            ar.barSize = math.max(ar.barSize or 0.3, 1.0)
        end
        if Config.ReelLockCenter and type(ar.fishPosition) == "number" then
            ar.barPosition = ar.fishPosition
            ar.onbar = true
            if ar.reel_playerbar and ar.reel_playerbar.Parent then
                ar.reel_playerbar.Position = UDim2.fromScale(ar.barPosition, 0.5)
            end
        end

        if isReady then
            if Config.InstantReel then
                local readyElapsedMs = (now - (ReelReadyTimes[ar] or now)) * 1000
                if readyElapsedMs >= Config.ReelFinishDelayMs and ar.loaded ~= false then
                    EndedReels[ar] = true
                    Runtime.CatchesCount = Runtime.CatchesCount + 1
                    ar:EndMinigame(true)
                end
            elseif type(ar.progress) == "number" then
                local addProg = (Config.ReelSpeedBoost / 100) * 65 * dt
                ar.progress = math.clamp(ar.progress + addProg, 0, 100)
                if ar.progress >= 100 and ar.loaded ~= false then
                    EndedReels[ar] = true
                    Runtime.CatchesCount = Runtime.CatchesCount + 1
                    ar:EndMinigame(true)
                end
            end
        end
    end)
end

connectSignal(RunService.RenderStepped, function(dt: number)
    if not Config.AutoReel then
        return
    end
    processMinigameController(getReelController(), dt)
    processMinigameController(getStabController(), dt)
end)

-- ลูปเขย่าทุ่นอัตโนมัติผ่าน LureShake/Shake โดยเคารพคูลดาวน์ 0.25 วินาทีของเกมเพื่อไม่ให้สายถูกรีเซ็ต
task.spawn(function()
    local lastShakeUIInst: Instance? = nil
    local shakeUISeenAt = 0
    local lastShakeSentAt = 0

    while IsScriptRunning do
        task.wait(0.05)
        if not (Config.FastShake and Config.AutoFish) then
            lastShakeUIInst = nil
            continue
        end

        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        local shakeUI = pg and pg:FindFirstChild("shakeui")
        if shakeUI and shakeUI:IsA("ScreenGui") and shakeUI.Enabled then
            local now = tick()
            if shakeUI ~= lastShakeUIInst then
                lastShakeUIInst = shakeUI
                shakeUISeenAt = now
            end
            if Config.HideShakeOverlay then
                local sz = shakeUI:FindFirstChild("safezone")
                if sz and sz:IsA("GuiObject") then
                    sz.Visible = false
                end
            end

            local intervalSec = math.clamp(Config.ShakeDelayMs, 250, 800) / 1000
            if (now - shakeUISeenAt >= 0.27) and (now - lastShakeSentAt >= intervalSec) then
                local shakeRE = getNetRemote("RE", "LureShake/Shake")
                if shakeRE then
                    lastShakeSentAt = now
                    local reObj: any = shakeRE
                    pcall(function()
                        reObj:FireServer()
                    end)
                end
            end
        else
            lastShakeUIInst = nil
            shakeUISeenAt = 0
        end
    end
end)

-- ลูปหลักของระบบตกปลาและเดินอัตโนมัติครบวงจร (Zero-to-Fish Loop)
task.spawn(function()
    local lastSellTime = tick()
    local castStartedAt = 0
    local lastCastAttemptAt = 0
    local castFailStreak = 0

    while IsScriptRunning do
        task.wait(0.18)
        if not Config.AutoFish then
            Runtime.ProgressRatio = 0
            continue
        end

        local char, hum, hrp = getCharacterParts()
        if not (char and hum and hrp and hum.Health > 0) then
            setStatus("กำลังรอตัวละครเกิดใหม่...", "warn", 0)
            task.wait(0.8)
            continue
        end

        -- 0. ข้ามโหมดสอนเล่นอัตโนมัติถ้าเปิดไว้และยังติด Onboarding
        if Config.AutoSkipOnboarding then
            local dataCtrl = getDataController()
            if dataCtrl and dataCtrl.PlayerDataReplicator then
                local okOb, canSkip = pcall(function()
                    return dataCtrl.PlayerDataReplicator:TryIndex({"Onboarding", "CanSkip"})
                end)
                if okOb and canSkip == true then
                    local skipRE = getNetRemote("RE", "Onboarding/Skip")
                    if skipRE then
                        local reObj: any = skipRE
                        pcall(function() reObj:FireServer() end)
                    end
                end
            end
        end

        -- เช็กว่ากำลังอยู่ในหน้ามินิเกมดึงสายหรือไม่
        local reelCtrl = getReelController()
        local stabCtrl = getStabController()
        if (reelCtrl and reelCtrl.ActiveReel) or (stabCtrl and stabCtrl.ActiveReel) then
            castStartedAt = 0
            castFailStreak = 0
            setStatus("กำลังดึงปลาขึ้นฝั่งอัตโนมัติ • จับได้แล้ว " .. Runtime.CatchesCount .. " ตัว", "ok", 0.9)
            continue
        end

        -- อ่านสถานะเบ็ดปัจจุบันก่อนเดินหรือเหวี่ยงซ้ำ (ป้องกันเดินหนีหรือโยนซ้ำตอนสายอยู่ในน้ำแล้ว)
        local rod = getEquippedRodTool()
        local isCasted = false
        local bobber: Instance? = nil
        local rodState = 3
        if rod then
            local values = rod:FindFirstChild("values")
            local castedVal = values and values:FindFirstChild("casted")
            isCasted = castedVal and castedVal:IsA("BoolValue") and castedVal.Value or false
            local stateVal = values and values:FindFirstChild("state")
            if stateVal and (stateVal:IsA("IntValue") or stateVal:IsA("NumberValue")) then
                rodState = (stateVal :: any).Value
            elseif isCasted then
                rodState = 6
            end
            bobber = rod:FindFirstChild("bobber")
        end
        local hasActiveCast = isCasted or (bobber ~= nil) or (rodState >= 4 and rodState <= 8)

        -- 1. ตรวจสอบและเดินไปยังริมแหล่งน้ำที่ยืนตกได้จริง (ทำเฉพาะตอนยังไม่ได้เหวี่ยงสายลงน้ำ)
        if Config.AutoWalkToWater and not hasActiveCast then
            local needScan = (Runtime.LastShoreSpot == nil) or ((hrp.Position - Runtime.LastShoreSpot).Magnitude > 14)
            if not needScan and Runtime.LastWaterTarget then
                if not isClearWaterCast(hrp.Position, Runtime.LastWaterTarget) then
                    needScan = true
                end
            end

            if needScan then
                setStatus("กำลังสแกนหาจุดยืนริมน้ำที่เหมาะสม...", "ok", 0.15)
                local standPos, waterPos = findBestShorelineSpot(hrp.Position, Config.WalkRangeLimit)
                if standPos and waterPos then
                    Runtime.LastShoreSpot = standPos
                    Runtime.LastWaterTarget = waterPos
                else
                    setStatus("ไม่พบแหล่งน้ำในระยะเดิน ลองวาร์ปไปที่เกาะอื่น", "warn", 0.1)
                end
            end

            if Runtime.LastShoreSpot and (hrp.Position - Runtime.LastShoreSpot).Magnitude > 5.5 then
                setStatus("กำลังเดินนำทางไปยังริมตลิ่งอัตโนมัติ...", "ok", 0.3)
                local arrived = walkToTarget(Runtime.LastShoreSpot, 16, function()
                    return not Config.AutoFish
                end)
                if not arrived then
                    Runtime.LastShoreSpot = nil
                elseif Config.AutoFaceWater and Runtime.LastWaterTarget then
                    faceDirection(Runtime.LastWaterTarget)
                end
                task.wait(0.2)
                continue
            end
        end

        -- 2. สวมใส่เบ็ดตกปลาและเหยื่ออัตโนมัติ
        if Config.AutoEquipRod and not rod then
            setStatus("กำลังหยิบเบ็ดตกปลาจากกระเป๋า...", "ok", 0.4)
            rod = equipFishingRod()
            if Config.AutoEquipBait and Config.PreferredBait ~= "ไม่เปลี่ยนอัตโนมัติ" then
                equipSpecificBait(Config.PreferredBait)
            end
            task.wait(0.25)
            continue
        end

        if rod then
            local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            local shakeUI = pg and pg:FindFirstChild("shakeui")
            local isShaking = shakeUI ~= nil and shakeUI:IsA("ScreenGui") and shakeUI.Enabled
            local sellWalkPending = Config.AutoSell and Config.WalkToMerchantToSell and (tick() - lastSellTime >= Config.AutoSellInterval)

            if not hasActiveCast and not isShaking and not sellWalkPending and Config.AutoCast and (rodState == 3) and (tick() - lastCastAttemptAt >= 1.8) then
                castStartedAt = 0
                if Config.AutoFaceWater and Runtime.LastWaterTarget then
                    faceDirection(Runtime.LastWaterTarget)
                end

                if hum:GetState() == Enum.HumanoidStateType.Swimming then
                    setStatus("กำลังถอยขึ้นตลิ่งก่อนเหวี่ยงเบ็ด...", "warn", 0.2)
                    Runtime.LastShoreSpot = nil
                    task.wait(0.3)
                    continue
                end

                local castRF = getNetRemote("RF", "FishingRod/Cast")
                if castRF then
                    local rfObj: any = castRF
                    local pwr = Config.AlwaysPerfectCast and 100 or math.clamp(Config.CastPower, 10, 100)
                    local isPerf = Config.AlwaysPerfectCast or (pwr >= 96)
                    lastCastAttemptAt = tick()
                    local okInvoke, accepted = pcall(function()
                        return rfObj:InvokeServer(pwr, isPerf)
                    end)
                    if okInvoke and accepted then
                        castStartedAt = tick()
                        castFailStreak = 0
                        setStatus("เหวี่ยงเบ็ดลงน้ำสมบูรณ์ • กำลังรอปลากินเหยื่อ", "ok", 0.65)
                        task.wait(0.6)
                    else
                        castFailStreak = castFailStreak + 1
                        setStatus("จุดยืนปัจจุบันเหวี่ยงไม่ถึงน้ำ กำลังปรับตำแหน่ง...", "warn", 0.2)
                        if Config.AutoStepAdjustOnFail and castFailStreak >= 2 then
                            local _, newWater = findBestShorelineSpot(hrp.Position, 50)
                            if newWater then
                                Runtime.LastWaterTarget = newWater
                                faceDirection(newWater)
                            else
                                local rootObj: any = hrp
                                rootObj.CFrame = rootObj.CFrame * CFrame.Angles(0, math.rad(75), 0)
                            end
                            castFailStreak = 0
                        end
                        task.wait(0.35)
                    end
                end
            elseif hasActiveCast then
                if castStartedAt == 0 then
                    castStartedAt = tick()
                end
                -- ตรวจสอบกรณีทุ่นตกบนพื้นบก (เช็กเฉพาะช่วงค้นหาและยังไม่มีหน้าต่างเขย่าทุ่น) หรือสายค้างเกินกำหนด
                local resetRE = getNetRemote("RE", "FishingRod/Reset")
                if Config.AutoResetOnLand and not isShaking and rodState <= 5 and bobber and bobber:IsA("BasePart") and (tick() - castStartedAt > 2.8) then
                    local waterAtBobber = detectWaterSurfaceAt(bobber.Position.X, bobber.Position.Y, bobber.Position.Z)
                    if not waterAtBobber and resetRE then
                        local reObj: any = resetRE
                        pcall(function() reObj:FireServer() end)
                        Runtime.LastShoreSpot = nil
                        castStartedAt = 0
                        lastCastAttemptAt = tick()
                        setStatus("ทุ่นตกนอกผิวน้ำ กำลังเก็บสายและหาแนวใหม่...", "warn", 0.3)
                        task.wait(0.4)
                    end
                end
                if rodState < 7 and castStartedAt > 0 and (tick() - castStartedAt > Config.CastStuckTimeout) and resetRE then
                    local reObj: any = resetRE
                    pcall(function() reObj:FireServer() end)
                    castStartedAt = 0
                    lastCastAttemptAt = tick()
                    setStatus("สายเบ็ดค้างนานเกินกำหนด กำลังเริ่มเหวี่ยงใหม่...", "warn", 0.4)
                    task.wait(0.4)
                end
            end
        end

        -- 3. ตรวจสอบรอบเวลาขายปลาอัตโนมัติ (รอให้เหวี่ยงรอบปัจจุบันจบก่อนจึงค่อยเดินไปหาพ่อค้า)
        if Config.AutoSell and (tick() - lastSellTime >= Config.AutoSellInterval) and (not Config.WalkToMerchantToSell or (not hasActiveCast and castStartedAt == 0)) then
            lastSellTime = tick()
            if Config.WalkToMerchantToSell then
                local merch = findNearestMerchant()
                if merch then
                    local savedSpot = Runtime.LastShoreSpot or hrp.Position
                    setStatus("กำลังเดินไปหา " .. merch.Name .. " เพื่อขายปลา...", "ok", 0.5)
                    local sellSpot = merch.Pos + Vector3.new(0, 2, 4)
                    local reached = walkToTarget(sellSpot, 18, function()
                        return not Config.AutoFish or not Config.WalkToMerchantToSell
                    end)
                    if reached then
                        faceDirection(merch.Pos)
                        local prompt = merch.Model:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt and type(fireproximityprompt) == "function" then
                            pcall(fireproximityprompt, prompt)
                        end
                        sellAllFishNow(true)
                        task.wait(0.5)
                    end
                    setStatus("กำลังเดินกลับไปยังจุดตกปลา...", "ok", 0.4)
                    walkToTarget(savedSpot, 18, function()
                        return not Config.AutoFish
                    end)
                    if Config.AutoFaceWater and Runtime.LastWaterTarget then
                        faceDirection(Runtime.LastWaterTarget)
                    end
                else
                    sellAllFishNow(false)
                end
            else
                sellAllFishNow(false)
            end
        end
    end
end)

-- ============================================================================
-- 11. ระบบเสริมอัตโนมัติอื่นๆ (กรงปู ดาวตก รางวัลรายวัน ภารกิจ ไอเทมเกิด)
-- ============================================================================

local function tryPlaceAndClaimCrabCages()
    local crabCtrl = getCrabCageController()
    if Config.AutoCrabCageClaim and crabCtrl and type(crabCtrl.ActiveCages) == "table" then
        for _, cage in pairs(crabCtrl.ActiveCages) do
            if type(cage) == "table" and cage.data and cage.data.s == 2 and not cage.pending then
                pcall(function()
                    crabCtrl:Claim(cage)
                end)
                task.wait(0.2)
            end
        end
    end
    if Config.AutoCrabCagePlace then
        local _, _, hrp = getCharacterParts()
        if hrp then
            local placeRF = getNetRemote("RF", "CrabCage/Place")
            if placeRF then
                local cagesLib = resolveModule({"shared", "modules", "library", "crabcages"})
                local cageEntry = cagesLib and type(cagesLib.byName) == "table" and cagesLib.byName["Crab Cage"] or nil
                local cageId = (cageEntry and cageEntry.Id) or nil
                if cageId ~= nil then
                    local ox = hrp.Position.X + math.random(-6, 6)
                    local oz = hrp.Position.Z + math.random(-6, 6)
                    local targetWaterY = detectWaterSurfaceAt(ox + 6, hrp.Position.Y, oz)
                    if targetWaterY then
                        local cf = CFrame.new(ox + 6, targetWaterY, oz)
                        local rfObj: any = placeRF
                        pcall(function()
                            rfObj:InvokeServer(cf, cageId)
                        end)
                    end
                end
            end
        end
    end
end

task.spawn(function()
    local lastDaily = 0
    local lastChallenge = 0
    local lastCage = 0
    local lastEventClaim = 0
    while IsScriptRunning do
        task.wait(2.5)
        local now = tick()

        if Config.AutoDailyReward and (now - lastDaily >= 45) then
            lastDaily = now
            local claimRE = getNetRemote("RE", "DailyReward/Claim")
            if claimRE then
                local reObj: any = claimRE
                pcall(function() reObj:FireServer() end)
            end
        end

        if Config.AutoClaimChallenges and (now - lastChallenge >= 20) then
            lastChallenge = now
            local claimRF = getNetRemote("RF", "Challenges/Claim")
            if claimRF then
                local rfObj: any = claimRF
                pcall(function() rfObj:InvokeServer("Daily") end)
                pcall(function() rfObj:InvokeServer("Weekly") end)
            end
        end

        if Config.AutoClaimMeteors then
            local claimRE = getNetRemote("RE", "Meteor/Claim")
            for _, item in ipairs(CollectionService:GetTagged("MeteorItem")) do
                local id = item:GetAttribute("ID")
                if id and claimRE then
                    local reObj: any = claimRE
                    pcall(function() reObj:FireServer(id) end)
                end
            end
        end

        if Config.AutoCollectItemSpawns or Config.AutoCollectAllMap then
            local collectRF = getNetRemote("RF", "ItemSpawnCollect")
            local _, _, hrp = getCharacterParts()
            if collectRF and (hrp or Config.AutoCollectAllMap) then
                local rfObj: any = collectRF
                for _, item in ipairs(CollectionService:GetTagged("ItemSpawn")) do
                    if Config.AutoCollectAllMap then
                        pcall(function() rfObj:InvokeServer(item.Name) end)
                    elseif hrp then
                        local pos = item:IsA("Model") and item:GetPivot().Position or (item:IsA("BasePart") and item.Position or nil)
                        if pos and (pos - hrp.Position).Magnitude <= 140 then
                            pcall(function() rfObj:InvokeServer(item.Name) end)
                        end
                    end
                end
            end
            if Config.AutoCollectAllMap then
                local collectorRF = getNetRemote("RF", "ItemCollectorCollect")
                if collectorRF then
                    local rfObj: any = collectorRF
                    for _, item in ipairs(CollectionService:GetTagged("ItemCollector")) do
                        local itemName = item:GetAttribute("ItemName") or item.Name
                        pcall(function() rfObj:InvokeServer(itemName) end)
                    end
                end
            end
        end

        if Config.AutoClaimEventRewards and (now - lastEventClaim >= 35) then
            lastEventClaim = now
            local devGiftRF = getNetRemote("RF", "DevGift/Claim")
            if devGiftRF then
                local rfObj: any = devGiftRF
                pcall(function() rfObj:InvokeServer() end)
            end
            local cupidRE = getNetRemote("RE", "CupidPromise/ClaimRewards")
            if cupidRE then
                local reObj: any = cupidRE
                pcall(function() reObj:FireServer() end)
            end
            local altarRE = getNetRemote("RE", "MermaidCove/AltarClaim")
            if altarRE then
                local reObj: any = altarRE
                pcall(function() reObj:FireServer() end)
            end
        end

        if (Config.AutoCrabCageClaim or Config.AutoCrabCagePlace) and (now - lastCage >= 5) then
            lastCage = now
            tryPlaceAndClaimCrabCages()
        end
    end
end)

-- ============================================================================
-- 12. หมวดฮาๆ และโทรลล์ (หมุนตัวความเร็วสูงให้คนอื่นเห็นได้ เดินบนน้ำ บิน ลอย)
-- ============================================================================

local flyBV: BodyVelocity? = nil
local flyBG: BodyGyro? = nil
local savedAutoRotate: boolean? = nil
local savedNeckC0: CFrame? = nil
local savedNeckRef: Motor6D? = nil
local headSpinAngle = 0
local antiFallHoldUntil = 0

local function updateFlyState()
    local _, _, hrp = getCharacterParts()
    if not Config.FlyMode or not hrp then
        if flyBV then flyBV:Destroy(); flyBV = nil end
        if flyBG then flyBG:Destroy(); flyBG = nil end
        return
    end
    if not flyBV or not flyBV.Parent then
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp
        flyBV = bv

        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        local rootObj: any = hrp
        bg.CFrame = rootObj.CFrame
        bg.Parent = hrp
        flyBG = bg
    end
end

connectSignal(RunService.Heartbeat, function(dt: number)
    local char, hum, hrp = getCharacterParts()
    if not (char and hum and hrp and hum.Health > 0) then
        return
    end
    local rootPart: any = hrp

    -- 1. ตัวหมุนพายุความเร็วสูง (รักษาความเร็วเดิน + รีพลิเคตให้คนอื่นในเซิร์ฟเวอร์เห็น)
    if Config.Spinbot then
        local isAnchored = rootPart.Anchored == true
        local ownsPhysics = true
        if type(isnetworkowner) == "function" then
            local okOwn, own = pcall(isnetworkowner, rootPart)
            if okOwn and own == false then
                ownsPhysics = false
            end
        end
        if not isAnchored and ownsPhysics then
            if savedAutoRotate == nil then
                savedAutoRotate = hum.AutoRotate
            end
            hum.AutoRotate = false
            local stepDeg = (Config.SpinSpeedDeg * math.clamp(dt, 0, 0.08)) % 360
            local linearVel = rootPart.AssemblyLinearVelocity
            rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(stepDeg), 0)
            rootPart.AssemblyLinearVelocity = linearVel
        end
    elseif savedAutoRotate ~= nil then
        hum.AutoRotate = savedAutoRotate
        savedAutoRotate = nil
    end

    -- 2. หมุนคอและศีรษะรวดเร็ว (รองรับ R6/R15 และคืนค่าเดิมเมื่อปิด)
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    local headInst = char:FindFirstChild("Head")
    local neckInst = (torso and torso:FindFirstChild("Neck")) or (headInst and headInst:FindFirstChild("Neck"))
    if Config.HeadSpin and neckInst and neckInst:IsA("Motor6D") then
        if savedNeckRef ~= neckInst then
            savedNeckRef = neckInst
            savedNeckC0 = neckInst.C0
        end
        headSpinAngle = (headSpinAngle + math.rad(1080) * math.clamp(dt, 0, 0.08)) % (math.pi * 2)
        if savedNeckC0 then
            if hum.RigType == Enum.HumanoidRigType.R6 then
                neckInst.C0 = savedNeckC0 * CFrame.Angles(0, 0, headSpinAngle)
            else
                neckInst.C0 = savedNeckC0 * CFrame.Angles(0, headSpinAngle, 0)
            end
        end
    elseif savedNeckRef and savedNeckC0 then
        if savedNeckRef.Parent then
            savedNeckRef.C0 = savedNeckC0
        end
        savedNeckRef = nil
        savedNeckC0 = nil
        headSpinAngle = 0
    end

    -- 3. ลอยตัวไร้แรงโน้มถ่วง
    if Config.FloatMode then
        local vel = rootPart.AssemblyLinearVelocity
        rootPart.AssemblyLinearVelocity = Vector3.new(vel.X, math.sin(tick() * 4.5) * 3.5, vel.Z)
    end

    -- 4. เดินบนผิวน้ำจริง & ป้องกันตกน้ำขณะเดิน (ตรวจวัดผิวน้ำไดนามิก ไม่ขังตัวละครใต้น้ำและไม่เด้งซ้ำ)
    if Config.WalkOnWater or (Config.AutoFish and Config.AntiFallWater) then
        local surfaceY = detectWaterSurfaceAt(rootPart.Position.X, rootPart.Position.Y, rootPart.Position.Z)
        local feetY = rootPart.Position.Y - 3.1
        local nearWater = surfaceY ~= nil and (feetY <= (surfaceY :: number) + 3.5)
        if nearWater and hum:GetState() == Enum.HumanoidStateType.Swimming then
            antiFallHoldUntil = tick() + 1.2
        end
        local onRealSolid = detectSolidFloorAt(rootPart.Position.X, rootPart.Position.Y, rootPart.Position.Z) ~= nil
        local antiFallHolding = Config.AutoFish and Config.AntiFallWater and nearWater and (not onRealSolid) and (hum:GetState() == Enum.HumanoidStateType.Swimming or tick() < antiFallHoldUntil)
        if antiFallHolding then
            antiFallHoldUntil = tick() + 0.6
        end
        local shouldSupport = (Config.WalkOnWater and surfaceY ~= nil) or antiFallHolding

        if shouldSupport and surfaceY then
            if feetY < surfaceY - 0.8 then
                rootPart.CFrame = CFrame.new(rootPart.Position.X, surfaceY + 3.25, rootPart.Position.Z) * rootPart.CFrame.Rotation
                rootPart.AssemblyLinearVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.X, 0, rootPart.AssemblyLinearVelocity.Z)
            end
            if not waterPlatform or not waterPlatform.Parent then
                local plat = Instance.new("Part")
                plat.Name = "FischClean_WaterBridge"
                plat.Size = Vector3.new(20, 1, 20)
                plat.Transparency = Config.WalkOnWater and 0.8 or 1
                plat.Material = Enum.Material.SmoothPlastic
                plat.Color = Color3.fromRGB(56, 189, 248)
                plat.Anchored = true
                plat.CanCollide = true
                plat.Parent = Workspace
                waterPlatform = plat
            end
            if waterPlatform then
                waterPlatform.CFrame = CFrame.new(rootPart.Position.X, surfaceY - 0.55, rootPart.Position.Z)
            end
        elseif waterPlatform and waterPlatform.Parent then
            waterPlatform.CFrame = CFrame.new(0, -9999, 0)
        end
    elseif waterPlatform then
        waterPlatform:Destroy()
        waterPlatform = nil
        antiFallHoldUntil = 0
    end

    -- 5. เร่งความเร็วเรือเมื่อนั่งขับ
    if Config.BoatSpeedBoost and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
        local seat = hum.SeatPart
        if seat.ThrottleFloat ~= 0 then
            local boost = seat.CFrame.LookVector * (seat.ThrottleFloat * seat.MaxSpeed * (Config.BoatSpeedMultiplier - 1))
            local curVel = seat.AssemblyLinearVelocity
            seat.AssemblyLinearVelocity = Vector3.new(curVel.X + boost.X * dt * 4, curVel.Y, curVel.Z + boost.Z * dt * 4)
        end
    end
end)

connectSignal(RunService.RenderStepped, function()
    if Config.FlyMode then
        updateFlyState()
        if flyBV and flyBG then
            local cam = Workspace.CurrentCamera
            if cam then
                local move = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
                flyBV.Velocity = move * Config.FlySpeed
                flyBG.CFrame = cam.CFrame
            end
        end
    end
end)

connectSignal(RunService.Stepped, function()
    if not Config.Noclip then
        return
    end
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

connectSignal(UserInputService.JumpRequest, function()
    if Config.InfiniteJump then
        local _, hum = getCharacterParts()
        if hum and hum.Health > 0 then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ============================================================================
-- 13. ความได้เปรียบตัวละครและระบบ (อ้างอิงจาก WalkSpeedController & EnvResources)
-- ============================================================================

local LightingBackup: {[string]: any} = {}

connectSignal(RunService.PostSimulation, function()
    local char, hum = getCharacterParts()
    if not (char and hum) then
        return
    end

    if Config.AntiFreezeSlow then
        if char:GetAttribute("SnowSlow") ~= nil then char:SetAttribute("SnowSlow", nil) end
        if char:GetAttribute("FreezingWater") ~= nil then char:SetAttribute("FreezingWater", nil) end
        if char:GetAttribute("HoneySlow") ~= nil then char:SetAttribute("HoneySlow", nil) end
    end

    if Config.BypassSpeedLock then
        if char:GetAttribute("FishingWalkSpeed") ~= nil then
            char:SetAttribute("FishingWalkSpeed", nil)
        end
        if char:GetAttribute("FishingJumpPower") ~= nil then
            char:SetAttribute("FishingJumpPower", nil)
        end
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    end

    if Config.FastWalk then
        local extra = math.max(0, Config.WalkSpeedValue - 16)
        char:SetAttribute("DeveloperBoots", extra)
        hum.WalkSpeed = Config.WalkSpeedValue
    elseif char:GetAttribute("DeveloperBoots") ~= nil then
        char:SetAttribute("DeveloperBoots", nil)
    end

    if Config.HighJump then
        hum.UseJumpPower = true
        hum.JumpPower = Config.JumpPowerValue
    end
end)

task.spawn(function()
    local deadStateSuppressed = false
    while IsScriptRunning do
        task.wait(0.4)
        local char, hum = getCharacterParts()
        if Config.AntiDrown and char and hum then
            local allowDead = hum:GetState() ~= Enum.HumanoidStateType.Swimming
            deadStateSuppressed = not allowDead
            pcall(function()
                char:SetAttribute("Oxygen", 100)
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, allowDead)
            end)
            local envCtrl = getEnvironmentController()
            if envCtrl and type(envCtrl.ResourceData) == "table" then
                for resName, data in pairs(envCtrl.ResourceData) do
                    if type(data) == "table" then
                        if tostring(resName):lower():find("oxygen") then
                            data.ServerValue = data.Max or 100
                            data.DrainRate = 0
                            data.LastUpdate = Workspace:GetServerTimeNow()
                        elseif Config.AntiFreezeSlow and tostring(resName):lower():find("temp") then
                            data.ServerValue = data.Max or 100
                            data.DrainRate = 0
                        end
                    end
                end
            end
        elseif deadStateSuppressed and hum then
            deadStateSuppressed = false
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            end)
        end

        -- เปิดเรดาร์จับปลาของเกม
        if Config.UnlockGameRadar then
            if LocalPlayer:GetAttribute("RadarEnabled") ~= true then
                LocalPlayer:SetAttribute("RadarEnabled", true)
            end
        end

        -- ปิดจอดำและคัตซีนรบกวน
        if Config.RemoveDarkScreen then
            local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if pg then
                local dim = pg:FindFirstChild("Dim")
                if dim and dim:IsA("ScreenGui") then
                    dim.Enabled = false
                end
            end
        end

        if Config.UnlockMaxZoom and LocalPlayer.CameraMaxZoomDistance < 400 then
            LocalPlayer.CameraMaxZoomDistance = 400
        end

        if Config.ClearUnderwaterVision then
            if LightingBackup.FogEnd == nil then
                LightingBackup.FogEnd = Lighting.FogEnd
                LightingBackup.Brightness = Lighting.Brightness
            end
            Lighting.FogEnd = 100000
            Lighting.Brightness = math.max(Lighting.Brightness, 2)
        elseif LightingBackup.FogEnd ~= nil then
            Lighting.FogEnd = LightingBackup.FogEnd
            Lighting.Brightness = LightingBackup.Brightness
            LightingBackup.FogEnd = nil
        end
    end
end)

-- ป้องกันหลุดเกมเมื่อยืนนิ่งนานด้วย VirtualUser ผ่านสัญญาณ Idled โดยไม่รบกวนประสิทธิภาพเฟรมเรต
connectSignal(LocalPlayer.Idled, function()
    if not (IsScriptRunning and Config.AntiAFK) then
        return
    end
    pcall(function()
        local vu: any = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end)

-- ============================================================================
-- 14. ระบบสายตรวจจับและมองเห็น (ESP IN ESPFolder & 2D TRACERS IN RenderLayer)
-- ============================================================================

type ESPTarget = { Adornee: Instance, WorldPos: Vector3, Text: string, Color: Color3 }
local ActiveESPInstances: {Instance} = {}
local ActiveTracers: { { Line: Frame, Pos: Vector3, Color: Color3 } } = {}

local function clearESP()
    for _, inst in ipairs(ActiveESPInstances) do
        if inst and inst.Parent then
            inst:Destroy()
        end
    end
    table.clear(ActiveESPInstances)
    for _, child in ipairs(RenderLayer:GetChildren()) do
        child:Destroy()
    end
    table.clear(ActiveTracers)
end

local function createBillboardTag(adornee: Instance, text: string, color: Color3): BillboardGui
    local bg = Instance.new("BillboardGui")
    bg.Name = "ESPTag"
    bg.Adornee = adornee :: any
    bg.Size = UDim2.fromOffset(170, 26)
    bg.StudsOffset = Vector3.new(0, 2.8, 0)
    bg.AlwaysOnTop = true
    bg.Parent = ESPFolder

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.TextStrokeTransparency = 0.2
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    lbl.Font = THAI_FONTS[Config.FontName] or Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.Parent = bg

    table.insert(ActiveESPInstances, bg)
    return bg
end

local function createTracerLine(worldPos: Vector3, color: Color3)
    if not Config.ESPTracers then
        return
    end
    local line = Instance.new("Frame")
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BorderSizePixel = 0
    line.BackgroundColor3 = color
    line.BackgroundTransparency = 0.25
    line.Size = UDim2.fromOffset(2, 2)
    line.Visible = false
    line.ZIndex = 2
    line.Parent = RenderLayer
    table.insert(ActiveTracers, { Line = line, Pos = worldPos, Color = color })
end

local function updateESPObjects()
    clearESP()
    local _, _, myHrp = getCharacterParts()
    local myPos = myHrp and myHrp.Position or Vector3.zero

    -- 1. ผู้เล่นอื่น
    if Config.ESPPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hrp:IsA("BasePart") and hum and hum.Health > 0 then
                    local dist = math.round((hrp.Position - myPos).Magnitude)
                    local rodAttr = tostring(plr:GetAttribute("CurrentRod") or "")
                    local suffix = rodAttr ~= "" and (" • " .. rodAttr) or ""
                    local col = Color3.fromRGB(56, 189, 248)
                    createBillboardTag(hrp, plr.DisplayName .. " • " .. dist .. "ม." .. suffix, col)
                    createTracerLine(hrp.Position, col)
                end
            end
        end
    end

    -- 2. ทุ่นเบ็ดในทะเล
    if Config.ESPBobbers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then
                for _, tool in ipairs(plr.Character:GetChildren()) do
                    if tool:IsA("Tool") then
                        local bobber = tool:FindFirstChild("bobber")
                        if bobber and bobber:IsA("BasePart") then
                            local dist = math.round((bobber.Position - myPos).Magnitude)
                            local col = Color3.fromRGB(244, 114, 182)
                            createBillboardTag(bobber, "ทุ่นของ " .. plr.DisplayName .. " • " .. dist .. "ม.", col)
                        end
                    end
                end
            end
        end
    end

    -- 3. จุดล่าบอสและบ่อปลาพิเศษ
    if Config.ESPHuntZones then
        local zones = Workspace:FindFirstChild("zones")
        local fishing = zones and zones:FindFirstChild("fishing")
        if fishing then
            for _, z in ipairs(fishing:GetChildren()) do
                local zLower = z.Name:lower()
                local isSpecial = zLower:find("hunt") or zLower:find("myth") or zLower:find("mega") or zLower:find("whirlpool") or zLower:find("isonade") or zLower:find("kraken") or zLower:find("scylla") or zLower:find("orca") or zLower:find("shark")
                if isSpecial then
                    local part: BasePart? = if z:IsA("BasePart") then z else z:FindFirstChildWhichIsA("BasePart", true)
                    if part then
                        local dist = math.round((part.Position - myPos).Magnitude)
                        local col = Color3.fromRGB(249, 115, 22)
                        createBillboardTag(part, z.Name .. " • " .. dist .. "ม.", col)
                        createTracerLine(part.Position, col)
                    end
                end
            end
        end
    end

    -- 4. กล่องสมบัติและดาวตก
    if Config.ESPChestsAndMeteors then
        for _, item in ipairs(CollectionService:GetTagged("MeteorItem")) do
            local part: BasePart? = if item:IsA("BasePart") then item else item:FindFirstChildWhichIsA("BasePart", true)
            if part then
                local dist = math.round((part.Position - myPos).Magnitude)
                local col = Color3.fromRGB(250, 204, 21)
                createBillboardTag(part, "ดาวตก • " .. dist .. "ม.", col)
                createTracerLine(part.Position, col)
            end
        end
        for _, chest in ipairs(CollectionService:GetTagged("TreasureChest")) do
            local part: BasePart? = if chest:IsA("BasePart") then chest else chest:FindFirstChildWhichIsA("BasePart", true)
            if part then
                local dist = math.round((part.Position - myPos).Magnitude)
                local col = Color3.fromRGB(250, 204, 21)
                createBillboardTag(part, "หีบสมบัติ • " .. dist .. "ม.", col)
                createTracerLine(part.Position, col)
            end
        end
    end

    -- 5. พ่อค้าและบุคคลสำคัญ
    if Config.ESPNPCs then
        for _, npc in ipairs(getAllLiveNPCs()) do
            local nl = npc.Name:lower()
            if npc.NpcType == "Merchant" or nl:find("merchant") or nl:find("apprais") or nl:find("shipwright") or nl:find("angler") then
                local part: Instance = npc.Model.PrimaryPart or npc.Model:FindFirstChildWhichIsA("BasePart") or npc.Model
                local dist = math.round((npc.Pos - myPos).Magnitude)
                local col = Color3.fromRGB(52, 211, 153)
                createBillboardTag(part, npc.Name .. " • " .. dist .. "ม.", col)
            end
        end
    end

    -- 6. กรงดักปูของเรา
    if Config.ESPCrabCages then
        local crabCtrl = getCrabCageController()
        if crabCtrl and type(crabCtrl.ActiveCages) == "table" then
            for _, cage in pairs(crabCtrl.ActiveCages) do
                if type(cage) == "table" and cage.model and cage.pos then
                    local dist = math.round((cage.pos.Position - myPos).Magnitude)
                    local readyText = (cage.data and cage.data.s == 2) and "พร้อมเก็บ" or "รอเวลา"
                    local col = (cage.data and cage.data.s == 2) and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(168, 85, 247)
                    createBillboardTag(cage.model, "กรงปู " .. readyText .. " • " .. dist .. "ม.", col)
                end
            end
        end
    end
end

connectSignal(RunService.RenderStepped, function()
    if not Config.ESPTracers or #ActiveTracers == 0 then
        return
    end
    local cam = Workspace.CurrentCamera
    if not cam then
        return
    end
    local vp = cam.ViewportSize
    local origin2D = Vector2.new(vp.X * 0.5, vp.Y * 0.94)
    for _, item in ipairs(ActiveTracers) do
        local screenPos, onScreen = cam:WorldToViewportPoint(item.Pos)
        if onScreen and screenPos.Z > 0 then
            local target2D = Vector2.new(screenPos.X, screenPos.Y)
            local diff = target2D - origin2D
            local len = diff.Magnitude
            local mid = (origin2D + target2D) * 0.5
            item.Line.Visible = true
            item.Line.Size = UDim2.fromOffset(math.max(len, 1), 1.5)
            item.Line.Position = UDim2.fromOffset(mid.X, mid.Y)
            item.Line.Rotation = math.deg(math.atan2(diff.Y, diff.X))
        else
            item.Line.Visible = false
        end
    end
end)

task.spawn(function()
    while IsScriptRunning do
        task.wait(1.8)
        if Config.ESPPlayers or Config.ESPBobbers or Config.ESPHuntZones or Config.ESPChestsAndMeteors or Config.ESPNPCs or Config.ESPCrabCages then
            pcall(updateESPObjects)
        elseif #ActiveESPInstances > 0 or #ActiveTracers > 0 then
            clearESP()
        end
    end
end)

-- ============================================================================
-- 15. การวาร์ปและการสำรวจแมพแบบไดนามิก
-- ============================================================================

local function teleportSafeTo(dest: Vector3, labelName: string)
    local _, hum, hrp = getCharacterParts()
    if not hrp then
        showToast("ไม่พบตัวละครในฉาก")
        return
    end
    Runtime.IsNavigating = false
    Runtime.LastShoreSpot = nil
    Runtime.LastWaterTarget = nil
    local rootObj: any = hrp
    rootObj.AssemblyLinearVelocity = Vector3.zero
    rootObj.CFrame = CFrame.new(dest + Vector3.new(0, 4, 0))
    if hum then
        hum.Jump = false
    end
    setStatus("ย้ายตำแหน่งไปยัง " .. labelName .. " สำเร็จแล้ว")
    showToast("เดินทางมาถึง " .. labelName .. " แล้ว")
end

local function getLiveSpawnNames(): {string}
    local names = {}
    local seen: {[string]: boolean} = {}
    for _, spot in ipairs(ISLAND_DOCKS) do
        seen[spot.Name] = true
        table.insert(names, spot.Name)
    end
    local world = Workspace:FindFirstChild("world")
    local spawns = world and world:FindFirstChild("spawns")
    if spawns then
        for _, child in ipairs(spawns:GetChildren()) do
            if not seen[child.Name] then
                seen[child.Name] = true
                table.insert(names, child.Name)
            end
        end
    end
    local fast = Workspace:FindFirstChild("FastTravels")
    if fast then
        for _, child in ipairs(fast:GetChildren()) do
            if not seen[child.Name] then
                seen[child.Name] = true
                table.insert(names, child.Name)
            end
        end
    end
    return names
end

local function resolveSpotPositionByName(name: string): Vector3?
    for _, spot in ipairs(ISLAND_DOCKS) do
        if spot.Name == name then
            return spot.Pos
        end
    end
    local world = Workspace:FindFirstChild("world")
    local spawns = world and world:FindFirstChild("spawns")
    local sp = spawns and spawns:FindFirstChild(name)
    if sp then
        local pos = sp:IsA("Model") and sp:GetPivot().Position or (sp:IsA("BasePart") and sp.Position or nil)
        if pos then
            return pos
        end
    end
    local fast = Workspace:FindFirstChild("FastTravels")
    local fp = fast and fast:FindFirstChild(name)
    if fp then
        local pos = fp:IsA("Model") and fp:GetPivot().Position or (fp:IsA("BasePart") and fp.Position or nil)
        if pos then
            return pos
        end
    end
    return nil
end

local function teleportBySpotName(name: string)
    local pos = resolveSpotPositionByName(name)
    if pos then
        teleportSafeTo(pos, name)
        return
    end
    showToast("ไม่พบพิกัดจุดหมาย " .. name)
end

-- ============================================================================
-- 15.5 ระบบเคลมของจริงทั้งแมพ และระบบเสกโมเดลไอเทม 3 มิติฝั่งเครื่อง
-- ============================================================================

local SPAWNER_CATEGORY_ASSET_MAP: {[string]: string} = {
    ["ปลาในสารานุกรม"] = "fish",
    ["ไอเทมทั่วไป"] = "item",
    ["เบ็ดตกปลา"] = "rod",
    ["เรือและยานพาหนะ"] = "vessel",
    ["เหยื่อตกปลา"] = "bait",
}

local SpawnedVisualFolder: Folder? = nil
local SpawnedVisualTools: {Tool} = {}
local VisualSpawnSeq = 0

local function getCatalogTable(assetCat: string): {[string]: any}?
    if assetCat == "fish" then
        local m = resolveModule({"shared", "modules", "library", "fish"})
        return type(m) == "table" and m or nil
    elseif assetCat == "item" then
        local m = resolveModule({"shared", "modules", "library", "items"})
        return (type(m) == "table" and type(m.Items) == "table") and m.Items or nil
    elseif assetCat == "rod" then
        local m = resolveModule({"shared", "modules", "library", "rods"})
        return type(m) == "table" and m or nil
    elseif assetCat == "vessel" then
        local m = resolveModule({"shared", "modules", "vessels"})
        return (type(m) == "table" and type(m.library) == "table") and m.library or nil
    elseif assetCat == "bait" then
        local m = resolveModule({"shared", "modules", "library", "bait"})
        return type(m) == "table" and m or nil
    end
    return nil
end

local function getSortedCatalogKeys(assetCat: string): {string}
    local tbl = getCatalogTable(assetCat)
    local out = {}
    if type(tbl) == "table" then
        for k, v in pairs(tbl) do
            if type(k) == "string" and type(v) == "table" then
                table.insert(out, k)
            end
        end
    end
    table.sort(out)
    return out
end

local function getSpawnerCatalogSuggestions(): {string}
    local assetCat = SPAWNER_CATEGORY_ASSET_MAP[Config.SpawnerCategory] or "fish"
    local allKeys = getSortedCatalogKeys(assetCat)
    if #allKeys == 0 then
        return { tostring(Config.SpawnerItemName or "Megalodon") }
    end

    local query = tostring(Config.SpawnerItemName or ""):gsub("^%s+", ""):gsub("%s+$", ""):lower()
    local filtered = {}
    if query ~= "" and query ~= "*" then
        for _, name in ipairs(allKeys) do
            if name:lower():find(query, 1, true) then
                table.insert(filtered, name)
                if #filtered >= 60 then
                    break
                end
            end
        end
    end

    if #filtered > 0 then
        return filtered
    end

    local capped = {}
    for idx = 1, math.min(#allKeys, 50) do
        table.insert(capped, allKeys[idx])
    end
    return capped
end

local function resolveCatalogItemName(assetCat: string, rawInput: string): string
    local trimmed = rawInput:gsub("^%s+", ""):gsub("%s+$", "")
    if trimmed == "" then
        return ""
    end
    local tbl = getCatalogTable(assetCat)
    if type(tbl) == "table" then
        if type(tbl[trimmed]) == "table" then
            return trimmed
        end
        local lowerTarget = trimmed:lower()
        for k, v in pairs(tbl) do
            if type(k) == "string" and type(v) == "table" and k:lower() == lowerTarget then
                return k
            end
        end
        for _, k in ipairs(getSortedCatalogKeys(assetCat)) do
            if k:lower():find(lowerTarget, 1, true) then
                return k
            end
        end
    end
    return trimmed
end

local function getVisualSpawnFolder(): Folder
    if SpawnedVisualFolder and SpawnedVisualFolder.Parent then
        return SpawnedVisualFolder
    end
    local old = Workspace:FindFirstChild("FischClean_VisualSpawns")
    if old then
        old:Destroy()
    end
    local folder = Instance.new("Folder")
    folder.Name = "FischClean_VisualSpawns"
    folder.Parent = Workspace
    SpawnedVisualFolder = folder
    return folder
end

local function clearSpawnedVisuals()
    for _, tool in ipairs(SpawnedVisualTools) do
        if tool and tool.Parent then
            pcall(function() tool:Destroy() end)
        end
    end
    table.clear(SpawnedVisualTools)
    if SpawnedVisualFolder and SpawnedVisualFolder.Parent then
        pcall(function() SpawnedVisualFolder:Destroy() end)
    end
    SpawnedVisualFolder = nil
end

local function wrapInstanceAsModel(inst: Instance, labelName: string): Model
    local cloned = inst:Clone()
    if cloned:IsA("Model") then
        if not cloned.PrimaryPart then
            local primary = cloned:FindFirstChildWhichIsA("BasePart", true)
            if primary then
                cloned.PrimaryPart = primary
            end
        end
        return cloned
    end

    local model = Instance.new("Model")
    model.Name = labelName
    if cloned:IsA("BasePart") then
        cloned.Parent = model
        model.PrimaryPart = cloned
        return model
    end

    local innerModel = cloned:FindFirstChild(labelName) or cloned:FindFirstChildWhichIsA("Model")
    if innerModel and innerModel:IsA("Model") then
        innerModel.Parent = nil
        cloned:Destroy()
        if not innerModel.PrimaryPart then
            local p = innerModel:FindFirstChildWhichIsA("BasePart", true)
            if p then
                innerModel.PrimaryPart = p
            end
        end
        return innerModel
    end

    for _, child in ipairs(cloned:GetChildren()) do
        child.Parent = model
    end
    cloned:Destroy()
    local firstPart = model:FindFirstChildWhichIsA("BasePart", true)
    if firstPart then
        model.PrimaryPart = firstPart
    end
    return model
end

local function fetchNormalizedVisualModel(assetCat: string, itemName: string): Model?
    local assetsMod = resolveModule({"shared", "utils", "assets"})
    local rawAsset: Instance? = nil
    if assetsMod and type(assetsMod.getAsync) == "function" then
        if assetCat == "fish" and Config.SpawnerShiny then
            local okShiny, resShiny = pcall(function()
                return assetsMod.getAsync("fish", "Shiny_" .. itemName, 6)
            end)
            if okShiny and resShiny then
                rawAsset = resShiny
            end
        end
        if not rawAsset then
            local okRaw, resRaw = pcall(function()
                return assetsMod.getAsync(assetCat, itemName, 8)
            end)
            if okRaw and resRaw then
                rawAsset = resRaw
            end
        end
    end

    if not rawAsset then
        local resFolder = ReplicatedStorage:FindFirstChild("resources")
        if resFolder then
            local subMap: {[string]: string} = {
                fish = "fishModels",
                item = "itemModels",
                rod = "rods",
                vessel = "vessels",
                bait = "baitModels",
            }
            local sub = resFolder:FindFirstChild(subMap[assetCat] or "")
            rawAsset = sub and sub:FindFirstChild(itemName) or nil
        end
    end

    if not rawAsset then
        return nil
    end

    local model = wrapInstanceAsModel(rawAsset, itemName)
    local scaleRatio = math.clamp(Config.SpawnerScalePercent, 25, 300) / 100
    if scaleRatio ~= 1 then
        pcall(function()
            model:ScaleTo(scaleRatio)
        end)
    end

    if Config.SpawnerSparkling then
        local attachPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
        if attachPart then
            local sparkles = Instance.new("Sparkles")
            sparkles.SparkleColor = Color3.fromRGB(255, 224, 130)
            sparkles.Parent = attachPart
            local light = Instance.new("PointLight")
            light.Range = 10
            light.Brightness = 1.6
            light.Color = Color3.fromRGB(255, 232, 160)
            light.Parent = attachPart
        end
    end

    return model
end

local function spawnVisualTool(rawName: string)
    local assetCat = SPAWNER_CATEGORY_ASSET_MAP[Config.SpawnerCategory] or "fish"
    local resolvedName = resolveCatalogItemName(assetCat, rawName)
    if resolvedName == "" then
        showToast("กรุณากรอกชื่อไอเทมหรือปลาที่ต้องการเสกก่อน")
        return
    end

    setStatus("กำลังโหลดโมเดลจำลอง " .. resolvedName .. "...", "ok", 0.45)
    local model = fetchNormalizedVisualModel(assetCat, resolvedName)
    local _, hum, hrp = getCharacterParts()
    if not model then
        setStatus("ไม่พบโมเดล 3 มิติของ " .. resolvedName, "warn", 0)
        showToast("ไม่พบโมเดล " .. resolvedName .. " ในคลังสตรีมของเกม")
        return
    end

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.4, 0.4, 0.4)
    handle.Transparency = 1
    handle.Anchored = false
    handle.CanCollide = false
    handle.CanQuery = false
    handle.CanTouch = false
    handle.Massless = true
    handle.CFrame = model:GetPivot()

    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("BasePart") then
            desc.Anchored = false
            desc.CanCollide = false
            desc.CanQuery = false
            desc.CanTouch = false
            desc.Massless = true
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = handle
            weld.Part1 = desc
            weld.Parent = handle
        elseif desc:IsA("Script") or desc:IsA("LocalScript") then
            desc:Destroy()
        end
    end

    VisualSpawnSeq += 1
    local tool = Instance.new("Tool")
    tool.Name = "Visual_" .. resolvedName .. "_" .. tostring(VisualSpawnSeq)
    tool.CanBeDropped = false
    tool:AddTag("ExternalGear")
    tool:SetAttribute("DisplayName", resolvedName)
    handle.Parent = tool
    model.Parent = tool

    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if bp then
        tool.Parent = bp
        table.insert(SpawnedVisualTools, tool)
        if hum and hrp then
            pcall(function() hum:EquipTool(tool) end)
        end
        setStatus("เสกถือจำลอง " .. resolvedName .. " สำเร็จแล้ว", "ok", 1)
        showToast("เสกถือ " .. resolvedName .. " แล้ว (แสดงผลเฉพาะฝั่งเครื่อง)")
    else
        tool:Destroy()
    end
end

local function spawnVisualWorldModel(rawName: string)
    local assetCat = SPAWNER_CATEGORY_ASSET_MAP[Config.SpawnerCategory] or "fish"
    local resolvedName = resolveCatalogItemName(assetCat, rawName)
    if resolvedName == "" then
        showToast("กรุณากรอกชื่อไอเทมหรือปลาที่ต้องการเสกก่อน")
        return
    end

    local _, _, hrp = getCharacterParts()
    if not hrp then
        showToast("ไม่พบตัวละครในฉาก")
        return
    end

    setStatus("กำลังสร้างโมเดลจำลอง " .. resolvedName .. "...", "ok", 0.5)
    local model = fetchNormalizedVisualModel(assetCat, resolvedName)
    if not model then
        setStatus("ไม่พบโมเดล 3 มิติของ " .. resolvedName, "warn", 0)
        showToast("ไม่พบโมเดล " .. resolvedName .. " ในคลังสตรีมของเกม")
        return
    end

    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("BasePart") then
            desc.Anchored = true
            desc.CanCollide = false
            desc.CanQuery = false
            desc.CanTouch = false
        elseif desc:IsA("Script") or desc:IsA("LocalScript") then
            desc:Destroy()
        end
    end

    local rootObj: any = hrp
    local targetCf = rootObj.CFrame * CFrame.new(0, 2, -10)
    model:PivotTo(targetCf)
    model.Parent = getVisualSpawnFolder()

    setStatus("วางโมเดลจำลอง " .. resolvedName .. " ในฉากแล้ว", "ok", 1)
    showToast("เสกวาง " .. resolvedName .. " ตรงหน้าแล้ว (แสดงผลเฉพาะฝั่งเครื่อง)")
end

local function triggerVisualCatchBanner(rawName: string)
    local assetCat = SPAWNER_CATEGORY_ASSET_MAP[Config.SpawnerCategory] or "fish"
    if assetCat ~= "fish" and assetCat ~= "item" then
        showToast("แบนเนอร์จับปลารองรับเฉพาะหมวดปลาในสารานุกรมหรือไอเทมทั่วไป")
        return
    end
    local resolvedName = resolveCatalogItemName(assetCat, rawName)
    local tbl = getCatalogTable(assetCat)
    local entry = type(tbl) == "table" and tbl[resolvedName] or nil
    if type(entry) ~= "table" or not entry.Rarity then
        showToast("ไม่พบข้อมูลความหายากของ " .. resolvedName .. " สำหรับแบนเนอร์จับปลา")
        return
    end

    local debugEv = getEventsRemote("debug_catch")
    if debugEv and debugEv:IsA("BindableEvent") then
        local ev: BindableEvent = debugEv
        local payload = {
            Name = resolvedName,
            Weight = math.random(150, 2400) + math.random(0, 9) / 10,
            Shiny = Config.SpawnerShiny,
            Sparkling = Config.SpawnerSparkling,
            Drop = (assetCat ~= "fish"),
            SubValues = {},
        }
        pcall(function()
            ev:Fire(payload, 0.01)
        end)
        showToast("แสดงแบนเนอร์จำลองจับ " .. resolvedName .. " บนหน้าจอแล้ว")
    else
        showToast("ไม่พบอีเวนต์แสดงแบนเนอร์จับปลาในเกม")
    end
end

local function vacuumAllMapItems()
    local claimedCount = 0
    local collectRF = getNetRemote("RF", "ItemSpawnCollect")
    if collectRF then
        local rfObj: any = collectRF
        for _, item in ipairs(CollectionService:GetTagged("ItemSpawn")) do
            local ok, res = pcall(function()
                return rfObj:InvokeServer(item.Name)
            end)
            if ok and res == true then
                claimedCount += 1
            end
        end
    end

    local collectorRF = getNetRemote("RF", "ItemCollectorCollect")
    if collectorRF then
        local rfObj: any = collectorRF
        for _, item in ipairs(CollectionService:GetTagged("ItemCollector")) do
            local itemName = item:GetAttribute("ItemName") or item.Name
            local ok, res = pcall(function()
                return rfObj:InvokeServer(itemName)
            end)
            if ok and res == true then
                claimedCount += 1
            end
        end
    end

    setStatus("ดูดเก็บไอเทมในแผนที่สำเร็จ " .. tostring(claimedCount) .. " ชิ้น", "ok", 1)
    showToast("กวาดเก็บไอเทมเกิดในแผนที่ได้ " .. tostring(claimedCount) .. " รายการ")
end

local function claimAllServerRewardsNow()
    local signalsFired = 0
    local confirmedCount = 0

    local devGiftRF = getNetRemote("RF", "DevGift/Claim")
    if devGiftRF then
        local rfObj: any = devGiftRF
        signalsFired += 1
        local ok, res = pcall(function() return rfObj:InvokeServer() end)
        if ok and res then confirmedCount += 1 end
    end

    local dailyRE = getNetRemote("RE", "DailyReward/Claim")
    if dailyRE then
        local reObj: any = dailyRE
        pcall(function() reObj:FireServer() end)
        signalsFired += 1
    end

    local challengeRF = getNetRemote("RF", "Challenges/Claim")
    if challengeRF then
        local rfObj: any = challengeRF
        signalsFired += 1
        local okD, resD = pcall(function() return rfObj:InvokeServer("Daily") end)
        local okW, resW = pcall(function() return rfObj:InvokeServer("Weekly") end)
        if (okD and resD) or (okW and resW) then
            confirmedCount += 1
        end
    end

    for _, reName in ipairs({ "CarrotService/ClaimCode", "CupidPromise/ClaimRewards", "MermaidCove/AltarClaim" }) do
        local re = getNetRemote("RE", reName)
        if re then
            local reObj: any = re
            pcall(function() reObj:FireServer() end)
            signalsFired += 1
        end
    end

    local meteorRE = getNetRemote("RE", "Meteor/Claim")
    if meteorRE then
        local reObj: any = meteorRE
        for _, item in ipairs(CollectionService:GetTagged("MeteorItem")) do
            local id = item:GetAttribute("ID")
            if id then
                pcall(function() reObj:FireServer(id) end)
                signalsFired += 1
            end
        end
    end

    local crabCtrl = getCrabCageController()
    if crabCtrl and type(crabCtrl.ActiveCages) == "table" then
        for _, cage in pairs(crabCtrl.ActiveCages) do
            if type(cage) == "table" and cage.data and cage.data.s == 2 and not cage.pending then
                local okCage = pcall(function() crabCtrl:Claim(cage) end)
                signalsFired += 1
                if okCage then confirmedCount += 1 end
            end
        end
    end

    setStatus("ส่งคำสั่งรับของรางวัลเซิร์ฟเวอร์ครบทุกจุดแล้ว", "ok", 1)
    showToast("ส่งคำสั่งเคลม " .. tostring(signalsFired) .. " ช่องทาง (ยืนยันสำเร็จ " .. tostring(confirmedCount) .. " รายการ)")
end

-- ============================================================================
-- 15.6 ระบบดึงเอนทีตี้ไปยังจุดหมายที่ต้องการหรือดึงมาหาเรา
-- ============================================================================

local EntityPull: any = {}
do
    type PullEntry = {
        Object: Instance,
        RefPart: BasePart,
        Name: string,
        Category: string,
        SearchText: string,
        Label: string,
    }

    local OriginalPivots: {[Instance]: CFrame} = {}
    local SavedCollide: {[BasePart]: boolean} = {}
    local ProcessedCollideObjects: {[Instance]: boolean} = {}
    local PinnedPos: Vector3? = nil
    local PinnedMarker: Part? = nil
    local CachedLoopTargets: {PullEntry} = {}
    local lastLoopScanAt = 0
    local lastPruneAt = 0

    local CONTAINER_NAMES: {[string]: boolean} = {
        Workspace = true,
        world = true,
        active = true,
        boats = true,
        crabcages = true,
        roamingFish = true,
        npcs = true,
        map = true,
        debrisfx = true,
        Common = true,
        Uncommon = true,
        Unusual = true,
        Rare = true,
        Legendary = true,
        Mythical = true,
        Exotic = true,
        Limited = true,
        Extinct = true,
        Secret = true,
        ["Divine Secret"] = true,
        Apex = true,
        Relic = true,
        Event = true,
    }

    local function pruneStaleRecords()
        for inst in pairs(OriginalPivots) do
            if not inst.Parent then
                OriginalPivots[inst] = nil
            end
        end
        for inst in pairs(ProcessedCollideObjects) do
            if not inst.Parent then
                ProcessedCollideObjects[inst] = nil
            end
        end
        for part in pairs(SavedCollide) do
            if not part.Parent then
                SavedCollide[part] = nil
            end
        end
    end

    local function isOurHelperInstance(inst: Instance): boolean
        if inst.Name == "FischClean_PullTargetMarker" or inst.Name == "FischClean_WaterBridge" then
            return true
        end
        if SpawnedVisualFolder and (inst == SpawnedVisualFolder or inst:IsDescendantOf(SpawnedVisualFolder)) then
            return true
        end
        local localChar = LocalPlayer.Character
        if localChar and (inst == localChar or inst:IsDescendantOf(localChar)) then
            return true
        end
        return false
    end

    local function resolveMovableRoot(inst: Instance?): (Instance?, BasePart?)
        if not inst or not inst:IsDescendantOf(Workspace) or isOurHelperInstance(inst) then
            return nil, nil
        end
        if inst:IsA("Terrain") or inst:IsA("Camera") then
            return nil, nil
        end

        local target: Instance = inst
        if target:IsA("ProximityPrompt") or target:IsA("Attachment") then
            target = target.Parent or target
        end

        if target:IsA("BasePart") then
            local p = target.Parent
            if p and p:IsA("Model") and not CONTAINER_NAMES[p.Name] and p ~= Workspace then
                if target:HasTag("RoamingFishHitbox") or p.PrimaryPart == target or p:FindFirstChildOfClass("Humanoid") ~= nil then
                    target = p
                end
            end
        elseif not target:IsA("Model") then
            local modelAncestor = target:FindFirstAncestorOfClass("Model")
            if modelAncestor and not CONTAINER_NAMES[modelAncestor.Name] and modelAncestor ~= Workspace then
                target = modelAncestor
            end
        end

        if isOurHelperInstance(target) or CONTAINER_NAMES[target.Name] or target == Workspace then
            return nil, nil
        end

        if target:IsA("Model") then
            local ref = target.PrimaryPart or target:FindFirstChild("HumanoidRootPart") or target:FindFirstChildWhichIsA("BasePart", true)
            if ref and ref:IsA("BasePart") then
                return target, ref
            end
            return nil, nil
        elseif target:IsA("BasePart") then
            return target, target
        end
        return nil, nil
    end

    local function scanPullableEntities(categoryFilter: string?, nameQuery: string?): {PullEntry}
        local cat = categoryFilter or Config.EntityPullCategory or "ทุกประเภท"
        local wantAll = (cat == "ทุกประเภท")
        local queryLower = (nameQuery or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")

        local out: {PullEntry} = {}
        local seen: {[Instance]: boolean} = {}

        local function pushCandidate(rawInst: Instance?, catLabel: string, customName: string?, extraKeys: string?)
            local target, refPart = resolveMovableRoot(rawInst)
            if not target or not refPart or seen[target] then
                return
            end
            seen[target] = true

            local dispName = (customName and customName ~= "" and customName) or target.Name
            local searchText = (dispName .. " " .. target.Name .. " " .. catLabel .. " " .. (extraKeys or "")):lower()
            if queryLower ~= "" and not searchText:find(queryLower, 1, true) then
                return
            end
            table.insert(out, {
                Object = target,
                RefPart = refPart,
                Name = dispName,
                Category = catLabel,
                SearchText = searchText,
                Label = dispName .. " • " .. catLabel,
            })
        end

        if wantAll or cat == "ผู้เล่นอื่น" then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    pushCandidate(plr.Character, "ผู้เล่นอื่น", plr.DisplayName, plr.Name)
                end
            end
        end

        if wantAll or cat == "พ่อค้าและตัวละครระบบ" then
            for _, npc in ipairs(getAllLiveNPCs()) do
                pushCandidate(npc.Model, "ตัวละครระบบ", npc.Name, npc.NpcType)
            end
            for _, tagName in ipairs({ "MisoNpc", "TidefallLostDiver", "AstraeusSpirit", "CompanionInteractionPrompt" }) do
                for _, tagged in ipairs(CollectionService:GetTagged(tagName)) do
                    pushCandidate(tagged, "ตัวละครระบบ", nil, tagName)
                end
            end
        end

        local activeFolder = Workspace:FindFirstChild("active")

        if wantAll or cat == "เรือทั้งหมด" then
            local boats = activeFolder and activeFolder:FindFirstChild("boats")
            if boats then
                for _, boat in ipairs(boats:GetChildren()) do
                    pushCandidate(boat, "เรือ", boat.Name, "boat")
                end
            end
        end

        if wantAll or cat == "ปลาและบอสในฉาก" then
            for _, hb in ipairs(CollectionService:GetTagged("RoamingFishHitbox")) do
                local fishName = hb:GetAttribute("FishName")
                pushCandidate(hb, "ปลาและบอส", fishName and tostring(fishName) or nil, "roaming fish")
            end
            local roamingFish = activeFolder and activeFolder:FindFirstChild("roamingFish")
            if roamingFish then
                for _, desc in ipairs(roamingFish:GetDescendants()) do
                    if desc:IsA("Model") and not CONTAINER_NAMES[desc.Name] then
                        pushCandidate(desc, "ปลาและบอส", desc.Name, "roaming")
                    end
                end
            end
        end

        if wantAll or cat == "ไอเทม หีบสมบัติ และกรงปู" then
            for _, tagInfo in ipairs({
                { Tag = "ItemSpawn", Label = "ไอเทมในฉาก" },
                { Tag = "ItemCollector", Label = "แท่นสะสม" },
                { Tag = "MeteorItem", Label = "ดาวตก" },
                { Tag = "TreasureChest", Label = "หีบสมบัติ" },
            }) do
                for _, inst in ipairs(CollectionService:GetTagged(tagInfo.Tag)) do
                    local attrName = inst:GetAttribute("ItemName")
                    pushCandidate(inst, tagInfo.Label, attrName and tostring(attrName) or inst.Name, tagInfo.Tag)
                end
            end
            local cages = activeFolder and activeFolder:FindFirstChild("crabcages")
            if cages then
                for _, cage in ipairs(cages:GetChildren()) do
                    pushCandidate(cage, "กรงปู", cage.Name, "crabcage")
                end
            end
            local crabCtrl = getCrabCageController()
            if crabCtrl and type(crabCtrl.ActiveCages) == "table" then
                for _, cageData in pairs(crabCtrl.ActiveCages) do
                    if type(cageData) == "table" and cageData.model then
                        pushCandidate(cageData.model, "กรงปู", "กรงดักปู", "crabcage")
                    end
                end
            end
        end

        if wantAll or cat == "สิ่งมีชีวิตทั่วไปในฉาก" then
            local worldFolder = Workspace:FindFirstChild("world")
            local roots: {Instance} = { Workspace }
            if worldFolder then table.insert(roots, worldFolder) end
            if activeFolder then table.insert(roots, activeFolder) end
            for _, container in ipairs(roots) do
                for _, child in ipairs(container:GetChildren()) do
                    if child:IsA("Model") and child:FindFirstChildOfClass("Humanoid") then
                        pushCandidate(child, "สิ่งมีชีวิต", child.Name, "humanoid")
                    end
                end
            end
        end

        local _, _, myHrp = getCharacterParts()
        local myPos = myHrp and myHrp.Position or Vector3.zero
        table.sort(out, function(a, b)
            local da = (a.RefPart.Position - myPos).Magnitude
            local db = (b.RefPart.Position - myPos).Magnitude
            if math.abs(da - db) > 1 then
                return da < db
            end
            return a.Label < b.Label
        end)

        return out
    end

    local function parseVector3String(raw: string): Vector3?
        local nums: {number} = {}
        for token in tostring(raw or ""):gmatch("[%-%+]?%d*%.?%d+") do
            local n = tonumber(token)
            if n and n == n and math.abs(n) < 1e6 then
                table.insert(nums, n)
            end
        end
        if #nums >= 3 then
            return Vector3.new(nums[1], nums[2], nums[3])
        end
        return nil
    end

    local function updateMarkerVisual()
        if PinnedPos and IsScriptRunning then
            if not PinnedMarker or not PinnedMarker.Parent then
                local m = Instance.new("Part")
                m.Name = "FischClean_PullTargetMarker"
                m.Shape = Enum.PartType.Ball
                m.Size = Vector3.new(4.2, 4.2, 4.2)
                m.Material = Enum.Material.Neon
                m.Color = Color3.fromRGB(56, 189, 248)
                m.Transparency = 0.45
                m.Anchored = true
                m.CanCollide = false
                m.CanQuery = false
                m.CanTouch = false
                m.CastShadow = false
                m.Parent = Workspace
                PinnedMarker = m
            end
            if PinnedMarker then
                PinnedMarker.CFrame = CFrame.new(PinnedPos)
            end
        elseif PinnedMarker then
            pcall(function() PinnedMarker:Destroy() end)
            PinnedMarker = nil
        end
    end

    local function getCursorAimPosition(): Vector3?
        local cam = Workspace.CurrentCamera
        if not cam then
            return nil
        end
        local loc = UserInputService:GetMouseLocation()
        local unitRay = cam:ViewportPointToRay(loc.X, loc.Y)
        local rp = buildWorldRaycastParams(false, false)
        local hit = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 900, rp)
        if hit then
            return hit.Position + Vector3.new(0, 3, 0)
        end
        local okM, mousePos = pcall(function()
            return LocalPlayer:GetMouse().Hit.Position
        end)
        if okM and typeof(mousePos) == "Vector3" then
            return mousePos + Vector3.new(0, 3, 0)
        end
        return cam.CFrame.Position + unitRay.Direction * 40
    end

    local function resolveDestinationPos(): (Vector3?, string)
        local mode = Config.EntityPullDestMode or "ด้านหน้าตัวเรา"
        local _, _, hrp = getCharacterParts()

        if mode == "ด้านหน้าตัวเรา" then
            if not hrp then
                return nil, "ไม่พบตัวละครของคุณในฉาก"
            end
            local dist = math.clamp(Config.EntityPullFrontDist or 10, 2, 120)
            return hrp.Position + hrp.CFrame.LookVector * dist, "ด้านหน้าตัวเรา"
        elseif mode == "จุดที่ปักหมุดไว้" then
            local p = PinnedPos or parseVector3String(Config.EntityPullCustomCoords)
            if not p then
                return nil, "ยังไม่ได้ปักหมุดจุดหมาย กรุณากดปักหมุดก่อน"
            end
            return p, "จุดที่ปักหมุดไว้"
        elseif mode == "ตำแหน่งเมาส์ชี้" then
            local p = getCursorAimPosition()
            if not p then
                return nil, "ไม่สามารถอ่านตำแหน่งเมาส์บนฉากได้"
            end
            return p, "ตำแหน่งเมาส์ชี้"
        elseif mode == "เกาะหรือจุดเกิดที่เลือก" then
            local spotPos = resolveSpotPositionByName(Config.EntityPullDestIsland)
            if not spotPos then
                return nil, "ไม่พบพิกัดของ " .. tostring(Config.EntityPullDestIsland)
            end
            return spotPos + Vector3.new(0, 4, 0), tostring(Config.EntityPullDestIsland)
        elseif mode == "พิกัดกำหนดเอง" then
            local customPos = parseVector3String(Config.EntityPullCustomCoords)
            if not customPos then
                return nil, "รูปแบบพิกัดไม่ถูกต้อง ต้องเป็นตัวเลข 3 ค่าคั่นด้วยจุลภาค"
            end
            return customPos, "พิกัดกำหนดเอง"
        end
        return nil, "ไม่พบโหมดจุดหมาย"
    end

    local function setTargetCollisionState(obj: Instance, disableCollide: boolean)
        if disableCollide then
            if ProcessedCollideObjects[obj] then
                return
            end
            ProcessedCollideObjects[obj] = true
            local parts: {BasePart} = {}
            if obj:IsA("BasePart") then
                table.insert(parts, obj)
            end
            for _, d in ipairs(obj:GetDescendants()) do
                if d:IsA("BasePart") then
                    table.insert(parts, d)
                end
            end
            local lc = LocalPlayer.Character
            for _, p in ipairs(parts) do
                if not (lc and p:IsDescendantOf(lc)) then
                    if SavedCollide[p] == nil then
                        SavedCollide[p] = p.CanCollide
                    end
                    p.CanCollide = false
                end
            end
        elseif ProcessedCollideObjects[obj] then
            ProcessedCollideObjects[obj] = nil
        end
    end

    local function restoreSavedCollisions()
        for part, wasCollide in pairs(SavedCollide) do
            if part and part.Parent then
                pcall(function()
                    part.CanCollide = wasCollide
                end)
            end
        end
        table.clear(SavedCollide)
        table.clear(ProcessedCollideObjects)
    end

    local function moveSingleEntry(entry: PullEntry, targetPos: Vector3, lookFromPos: Vector3?)
        local obj = entry.Object
        if not obj or not obj.Parent then
            return false
        end

        if not OriginalPivots[obj] then
            if obj:IsA("Model") then
                OriginalPivots[obj] = obj:GetPivot()
            elseif obj:IsA("BasePart") then
                OriginalPivots[obj] = obj.CFrame
            end
        end

        if Config.EntityPullNoCollide then
            setTargetCollisionState(obj, true)
        end

        local curPivot = if obj:IsA("Model") then obj:GetPivot() else (obj :: BasePart).CFrame
        local newCF: CFrame
        if lookFromPos then
            local flatLook = Vector3.new(lookFromPos.X, targetPos.Y, lookFromPos.Z)
            if (flatLook - targetPos).Magnitude > 0.1 then
                newCF = CFrame.lookAt(targetPos, flatLook)
            else
                newCF = CFrame.new(targetPos) * curPivot.Rotation
            end
        else
            newCF = CFrame.new(targetPos) * curPivot.Rotation
        end

        local okMove = pcall(function()
            local ref = entry.RefPart
            if ref and ref.Parent and not ref.Anchored then
                ref.AssemblyLinearVelocity = Vector3.zero
                ref.AssemblyAngularVelocity = Vector3.zero
            end
            if obj:IsA("Model") then
                obj:PivotTo(newCF)
            elseif obj:IsA("BasePart") then
                obj.CFrame = newCF
            end
        end)
        return okMove
    end

    local function executePullBatch(targets: {PullEntry}, destPos: Vector3, destLabel: string, silent: boolean): number
        if #targets == 0 then
            if not silent then
                showToast("ไม่พบเอนทีตี้ที่ตรงตามเงื่อนไขในฉากขณะนี้")
            end
            return 0
        end

        if type(sethiddenproperty) == "function" then
            pcall(sethiddenproperty, LocalPlayer, "SimulationRadius", math.huge)
        end

        local _, _, hrp = getCharacterParts()
        local lookPos = (Config.EntityPullDestMode == "ด้านหน้าตัวเรา" and hrp) and hrp.Position or nil
        local spacing = math.clamp(Config.EntityPullGridSpacing or 0, 0, 30)
        local count = #targets
        local cols = math.max(1, math.ceil(math.sqrt(count)))
        local rows = math.max(1, math.ceil(count / cols))
        local moved = 0

        for idx, entry in ipairs(targets) do
            local pos = destPos
            if count > 1 and spacing > 0 then
                local cIdx = (idx - 1) % cols
                local rIdx = math.floor((idx - 1) / cols)
                local ox = (cIdx - (cols - 1) * 0.5) * spacing
                local oz = (rIdx - (rows - 1) * 0.5) * spacing
                pos = destPos + Vector3.new(ox, 0, oz)
            end
            if moveSingleEntry(entry, pos, lookPos) then
                moved += 1
            end
        end

        if not silent then
            setStatus("ดึงเอนทีตี้สำเร็จ " .. tostring(moved) .. " ตัว -> " .. destLabel, "ok", 1)
            showToast("ดึงเอนทีตี้ไปยัง " .. destLabel .. " จำนวน " .. tostring(moved) .. " ตัว")
        end
        return moved
    end

    function EntityPull.GetTargetDropdownOptions(): {string}
        local opts = { "ทุกตัวในหมวด" }
        local seenLabel: {[string]: boolean} = { ["ทุกตัวในหมวด"] = true }
        local list = scanPullableEntities(Config.EntityPullCategory, Config.EntityPullSearchName)
        for idx, entry in ipairs(list) do
            if idx > 60 then
                break
            end
            if not seenLabel[entry.Label] then
                seenLabel[entry.Label] = true
                table.insert(opts, entry.Label)
            end
        end
        return opts
    end

    function EntityPull.ResolveSelectedEntries(forceAllInCategory: boolean): {PullEntry}
        local list = scanPullableEntities(Config.EntityPullCategory, Config.EntityPullSearchName)
        if forceAllInCategory then
            return list
        end
        local picked = tostring(Config.EntityPullTargetName or "ทุกตัวในหมวด")
        if picked ~= "" and picked ~= "ทุกตัวในหมวด" then
            local matched: {PullEntry} = {}
            local pickedLower = picked:lower()
            for _, entry in ipairs(list) do
                if entry.Label == picked or entry.Name == picked or entry.SearchText:find(pickedLower, 1, true) then
                    table.insert(matched, entry)
                end
            end
            return matched
        end
        if tostring(Config.EntityPullSearchName or "") ~= "" then
            return list
        end
        return {}
    end

    function EntityPull.PullNow(forceAllInCategory: boolean)
        local destPos, destLabel = resolveDestinationPos()
        if not destPos then
            showToast(destLabel)
            return
        end
        local targets = EntityPull.ResolveSelectedEntries(forceAllInCategory)
        if not forceAllInCategory and #targets == 0 and tostring(Config.EntityPullTargetName) == "ทุกตัวในหมวด" and tostring(Config.EntityPullSearchName or "") == "" then
            showToast("กรุณาเลือกเอนทีตี้หรือพิมพ์ชื่อก่อน หรือกดปุ่มดึงทุกตัวในหมวด")
            return
        end
        executePullBatch(targets, destPos, destLabel, false)
    end

    function EntityPull.PinCurrentPosition()
        local _, _, hrp = getCharacterParts()
        if not hrp then
            showToast("ไม่พบตัวละครของคุณ")
            return
        end
        local pos = hrp.Position + Vector3.new(0, 2, 0)
        PinnedPos = pos
        Config.EntityPullCustomCoords = string.format("%d, %d, %d", math.round(pos.X), math.round(pos.Y), math.round(pos.Z))
        Config.EntityPullDestMode = "จุดที่ปักหมุดไว้"
        updateMarkerVisual()
        setStatus("ปักหมุดจุดหมายที่ตำแหน่งปัจจุบันแล้ว (" .. Config.EntityPullCustomCoords .. ")", "ok", 1)
        showToast("ปักหมุดจุดหมายสำเร็จ: " .. Config.EntityPullCustomCoords)
    end

    function EntityPull.PinCameraLookPosition()
        local cam = Workspace.CurrentCamera
        if not cam then
            showToast("ไม่พบกล้องในฉาก")
            return
        end
        local rp = buildWorldRaycastParams(false, false)
        local hit = Workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * 800, rp)
        local pos = hit and (hit.Position + Vector3.new(0, 3, 0)) or (cam.CFrame.Position + cam.CFrame.LookVector * 35)
        PinnedPos = pos
        Config.EntityPullCustomCoords = string.format("%d, %d, %d", math.round(pos.X), math.round(pos.Y), math.round(pos.Z))
        Config.EntityPullDestMode = "จุดที่ปักหมุดไว้"
        updateMarkerVisual()
        setStatus("ปักหมุดจุดหมายที่กล้องเล็งแล้ว (" .. Config.EntityPullCustomCoords .. ")", "ok", 1)
        showToast("ปักหมุดจุดที่กล้องเล็งสำเร็จ: " .. Config.EntityPullCustomCoords)
    end

    function EntityPull.ClearPin()
        PinnedPos = nil
        updateMarkerVisual()
        showToast("ลบหมุดจุดหมายแล้ว")
    end

    function EntityPull.RestoreOriginalPositions()
        Config.EntityPullLoop = false
        local restored = 0
        for inst, origCF in pairs(OriginalPivots) do
            if inst and inst.Parent then
                local ok = pcall(function()
                    if inst:IsA("Model") then
                        inst:PivotTo(origCF)
                    elseif inst:IsA("BasePart") then
                        inst.CFrame = origCF
                    end
                end)
                if ok then
                    restored += 1
                end
            end
        end
        table.clear(OriginalPivots)
        restoreSavedCollisions()
        setStatus("คืนตำแหน่งเดิมให้เอนทีตี้แล้ว " .. tostring(restored) .. " ตัว", "ok", 1)
        showToast("คืนตำแหน่งเดิมแล้ว " .. tostring(restored) .. " รายการ")
    end

    function EntityPull.InvalidateCache()
        lastLoopScanAt = 0
        table.clear(CachedLoopTargets)
    end

    function EntityPull.CleanupOnUnload()
        PinnedPos = nil
        updateMarkerVisual()
        restoreSavedCollisions()
        table.clear(OriginalPivots)
        EntityPull.InvalidateCache()
    end

    function EntityPull.SyncCollisionSetting()
        if not Config.EntityPullNoCollide then
            restoreSavedCollisions()
        end
    end

    connectSignal(RunService.Stepped, function()
        if not (Config.EntityPullLoop and Config.EntityPullNoCollide) then
            return
        end
        for part in pairs(SavedCollide) do
            if part.Parent and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)

    connectSignal(RunService.Heartbeat, function()
        local now = tick()
        if now - lastPruneAt >= 3.0 then
            lastPruneAt = now
            pruneStaleRecords()
        end
        if not Config.EntityPullLoop then
            return
        end
        local destPos, destLabel = resolveDestinationPos()
        if not destPos then
            return
        end
        if now - lastLoopScanAt >= 0.45 then
            lastLoopScanAt = now
            local useAll = (tostring(Config.EntityPullTargetName or "ทุกตัวในหมวด") == "ทุกตัวในหมวด")
            CachedLoopTargets = EntityPull.ResolveSelectedEntries(useAll)
        end
        if #CachedLoopTargets > 0 then
            executePullBatch(CachedLoopTargets, destPos, destLabel, true)
        end
    end)
end

-- ============================================================================
-- 16. การประกอบหน้าแท็บทั้งหมด (10 หมวดหลักภาษาไทยสะอาด)
-- ============================================================================

createTabButton("ตกปลาอัตโนมัติ", 1)
createTabButton("อุปกรณ์และขายปลา", 2)
createTabButton("เสกของและของรางวัล", 3)
createTabButton("สำรวจและวาร์ป", 4)
createTabButton("สายตรวจจับ", 5)
createTabButton("โหมดหรรษา", 6)
createTabButton("ตัวละครและเอาเปรียบ", 7)
createTabButton("ดึงเอนทีตี้", 8)
createTabButton("ข้อมูลและเซิร์ฟเวอร์", 9)
createTabButton("ตั้งค่าระบบ", 10)

-- -------------------- แท็บ 1: ตกปลาอัตโนมัติ --------------------
do
local PageAuto = createTabPage("ตกปลาอัตโนมัติ")

local cardAutoMain = createSectionCard(PageAuto, "วงจรเดินเองและตกปลาอัตโนมัติเต็มรูปแบบ", 1)
createToggleRow(cardAutoMain, "เปิดระบบตกปลาอัตโนมัติครบวงจร", "เล่นเองตั้งแต่เริ่ม: เดินหาแหล่งน้ำ -> หันลงน้ำ -> หยิบเบ็ด -> เหวี่ยง -> เขย่า -> ดึงสาย -> เดินขายปลา", "AutoFish", function(v)
    if v then
        Runtime.LastShoreSpot = nil
        setStatus("กำลังเริ่มวงจรเดินและตกปลาอัตโนมัติ...", "ok", 0.1)
    else
        Runtime.IsNavigating = false
        setStatus("ปิดระบบตกปลาอัตโนมัติแล้ว", "ok", 0)
    end
end)
createToggleRow(cardAutoMain, "สแกนหาแหล่งน้ำและเดินไปเองอัตโนมัติ", "ใช้ระบบนำทางเดินหลบสิ่งกีดขวางไปยังริมน้ำจริงโดยไม่เดินพุ่งลงทะเล", "AutoWalkToWater", nil)
createNumericInputRow(cardAutoMain, "ระยะค้นหาแหล่งน้ำสูงสุด", "รัศมีในการสแกนหาตลิ่งหรือท่าเรือที่ใกล้ตัว", "WalkRangeLimit", 30, 300, nil)
createToggleRow(cardAutoMain, "หันหน้าเข้าหาผิวน้ำอัตโนมัติ", "หันตัวละครให้ตรงกับผิวน้ำที่ตรวจสอบแล้วก่อนเริ่มเหวี่ยงเบ็ดทุกครั้ง", "AutoFaceWater", nil)
createToggleRow(cardAutoMain, "ป้องกันการตกน้ำขณะเดินอัตโนมัติ", "วางฐานพยุงชั่วคราวตามระดับผิวน้ำจริงหากตัวละครพลาดก้าวลงน้ำ", "AntiFallWater", nil)
createToggleRow(cardAutoMain, "ข้ามบทสอนผู้เล่นใหม่ทันที", "ส่งคำสั่งข้ามช่วงแนะนำการเล่นเมื่อเข้าเล่นไอดีใหม่", "AutoSkipOnboarding", nil)

local cardCastShake = createSectionCard(PageAuto, "การหยิบเบ็ด เหวี่ยงสาย และเขย่าทุ่น", 2)
createToggleRow(cardCastShake, "หยิบเบ็ดตกปลาจากช่องลัดอัตโนมัติ", "ดึงเบ็ดจากระบบกระเป๋าของเกมมาถือแม้ไม่ได้อยู่ในกระเป๋ามาตรฐาน", "AutoEquipRod", nil)
createToggleRow(cardCastShake, "เหวี่ยงเบ็ดอัตโนมัติ", "เหวี่ยงสายลงน้ำทันทีเมื่อยืนริมตลิ่งพร้อมใช้งาน", "AutoCast", nil)
createToggleRow(cardCastShake, "เหวี่ยงสมบูรณ์แบบเสมอ", "ล็อกค่าการเหวี่ยงระดับสมบูรณ์แบบสูงสุดทุกครั้ง", "AlwaysPerfectCast", nil)
createNumericInputRow(cardCastShake, "ระดับความแรงในการเหวี่ยง %", "กำหนดความแรงสายเมื่อปิดโหมดสมบูรณ์แบบเสมอ", "CastPower", 10, 100, nil)
createNumericInputRow(cardCastShake, "เวลาเก็บสายใหม่เมื่อปลานิ่ง", "รีเซ็ตสายอัตโนมัติเมื่อปลานิ่งเกินจำนวนวินาทีที่กำหนด", "CastStuckTimeout", 8, 60, nil)
createToggleRow(cardCastShake, "เขย่าทุ่นความเร็วพอดีผ่านเซิร์ฟเวอร์", "เขย่าทุ่นทุก 0.27 วินาทีขึ้นไปตามจังหวะเกมเพื่อไม่ให้สายถูกรีเซ็ต", "FastShake", nil)
createNumericInputRow(cardCastShake, "ความถี่เขย่าทุ่นเป็นมิลลิวินาที", "แนะนำ 260 ถึง 350 เพื่อเขย่าไวโดยไม่โดนเกมรีเซ็ตสาย", "ShakeDelayMs", 250, 800, nil)
createToggleRow(cardCastShake, "ซ่อนปุ่มเขย่าทุ่นเกะกะหน้าจอ", "ซ่อนไอคอนวงกลมเขย่าทุ่นขณะที่บอทจัดการให้เอง", "HideShakeOverlay", nil)

local cardReelCtrl = createSectionCard(PageAuto, "การดึงสายและการจับปลา", 3)
createToggleRow(cardReelCtrl, "เปิดระบบดึงสายอัตโนมัติ", "ควบคุมแถบจับปลาทุกเฟรมระหว่างที่เกิดมินิเกมดึงสาย", "AutoReel", nil)
createToggleRow(cardReelCtrl, "ล็อกแถบสีขาวตามตัวปลาทุกเฟรม", "จับคู่ตำแหน่งแถบของผู้เล่นให้ตรงกับปลาตลอดเวลา", "ReelLockCenter", nil)
createToggleRow(cardReelCtrl, "ขยายแถบจับปลาเต็มหลอด", "ปรับความกว้างแถบผู้เล่นให้ครอบคลุมแทบทั้งหลอด", "ReelBigBar", nil)
createToggleRow(cardReelCtrl, "รักษาสถานะจับสมบูรณ์แบบ", "ป้องกันการหลุดสถานะสมบูรณ์แบบระหว่างมินิเกมดึงสาย", "ReelAlwaysPerfect", nil)
createToggleRow(cardReelCtrl, "ดึงสายจบเกมทันที", "จบมินิเกมดึงสายอัตโนมัติหลังเริ่มทำงานเพื่อตกปลาเร็วขึ้นมาก", "InstantReel", nil)
createNumericInputRow(cardReelCtrl, "หน่วงเวลาก่อนจบดึงสายมิลลิวินาที", "เพิ่มความปลอดภัยก่อนปิดมินิเกมดึงสายทันที", "ReelFinishDelayMs", 0, 2500, nil)
createNumericInputRow(cardReelCtrl, "อัตราเร่งความเร็วหลอดจับปลา", "ตัวคูณความเร็วในการเติมหลอดจับปลาเมื่อไม่ใช้ดึงทันที", "ReelSpeedBoost", 20, 500, nil)
end

-- -------------------- แท็บ 2: อุปกรณ์และขายปลา --------------------
do
local PageGear = createTabPage("อุปกรณ์และขายปลา")

local cardSell = createSectionCard(PageGear, "ระบบขายปลาและจัดการพ่อค้า", 1)
createToggleRow(cardSell, "เปิดขายปลาอัตโนมัติตามรอบ", "ขายปลาที่ไม่ติดดาวรายการโปรดโดยอัตโนมัติเป็นระยะ", "AutoSell", nil)
createToggleRow(cardSell, "เดินไปหาพ่อค้าเมื่อถึงรอบขายปลา", "ตัวละครจะเดินไปหาพ่อค้าใกล้ที่สุดเพื่อขาย แล้วเดินกลับมาจุดตกปลาเดิม", "WalkToMerchantToSell", nil)
createNumericInputRow(cardSell, "ระยะเวลารอบการขายปลาเป็นวินาที", "ช่วงห่างระหว่างการขายปลาแต่ละรอบ", "AutoSellInterval", 15, 600, nil)
createActionRow(cardSell, "เช็กมูลค่าปลาทั้งหมดในกระเป๋า", "คำนวณราคาประเมินของปลาทั้งหมดก่อนตัดสินใจขาย", "ประเมินราคา", false, function()
    local val = previewSellTotal()
    if val then
        showToast("มูลค่าปลารวมปัจจุบันประมาณ " .. tostring(val) .. " เหรียญ")
    else
        showToast("ไม่พบข้อมูลประเมินราคาหรือไม่มีปลาที่ขายได้")
    end
end)
createActionRow(cardSell, "ขายปลาทั้งหมดทันที", "สั่งขายปลาทั้งหมดที่ไม่ได้ล็อกไว้ทันที ณ จุดที่ยืนอยู่", "ขายปลาทันที", false, function()
    if not sellAllFishNow(false) then
        showToast("ขายไม่สำเร็จ อาจไม่มีปลาหรือต้องเดินไปใกล้พ่อค้า")
    end
end)

local cardRodGear = createSectionCard(PageGear, "สลับเบ็ดตกปลาและเหยื่อจากที่ใดก็ได้", 2)
local currentRodDisplay = getCurrentRodName() or "Training Rod"
local refreshRodDropdown = createDropdownRow(cardRodGear, "เลือกสวมใส่เบ็ดที่มีในบัญชี", "สวมใส่เบ็ดที่มีอยู่ได้ทันทีโดยไม่ต้องเดินไปเปิดคลัง", nil, getOwnedRodsList, currentRodDisplay, function(opt)
    if equipSpecificRod(opt) then
        showToast("สวมใส่เบ็ด " .. opt .. " แล้ว")
    else
        showToast("ไม่สามารถสลับเบ็ดเป็น " .. opt)
    end
end)
createToggleRow(cardRodGear, "สวมใส่เหยื่อตกปลาอัตโนมัติ", "ติดตั้งเหยื่อที่เลือกทุกครั้งเมื่อเริ่มตกปลา", "AutoEquipBait", nil)
local refreshBaitDropdown = createDropdownRow(cardRodGear, "เลือกชนิดเหยื่อที่ต้องการใช้", "ดึงรายการเหยื่อที่มีในกระเป๋าปัจจุบัน", "PreferredBait", getOwnedBaitsList, Config.PreferredBait, function(opt)
    if equipSpecificBait(opt) then
        showToast("สวมใส่เหยื่อ " .. opt .. " เรียบร้อย")
    end
end)
createActionRow(cardRodGear, "รีเฟรชรายการเบ็ดและเหยื่อ", "อัปเดตรายชื่อเบ็ดและเหยื่อที่เพิ่งได้รับใหม่ในบัญชี", "อัปเดตรายการ", false, function()
    refreshRodDropdown()
    refreshBaitDropdown()
    showToast("อัปเดตคลังเบ็ดและเหยื่อเรียบร้อยแล้ว")
end)

local cardExtraGear = createSectionCard(PageGear, "กรงดักปูและของสะสมในฉาก", 3)
createToggleRow(cardExtraGear, "วางกรงดักปูลงน้ำอัตโนมัติ", "วางกรงดักปูรอบตัวลงในผิวน้ำที่ตรวจพบอัตโนมัติ", "AutoCrabCagePlace", nil)
createToggleRow(cardExtraGear, "เก็บกรงดักปูอัตโนมัติเมื่อพร้อม", "เก็บผลผลิตจากกรงดักปูที่จับสัตว์น้ำครบแล้ว", "AutoCrabCageClaim", nil)
createToggleRow(cardExtraGear, "เก็บดาวตกหล่นอัตโนมัติ", "ส่งคำสั่งเก็บแร่ดาวตกที่ปรากฏในแผนที่ทันที", "AutoClaimMeteors", nil)
createToggleRow(cardExtraGear, "เก็บไอเทมเกิดตามพื้นใกล้ตัว", "เก็บไอเทมที่ตกอยู่บนแผนที่ในระยะ 140 เมตร", "AutoCollectItemSpawns", nil)
createToggleRow(cardExtraGear, "รับของขวัญรายวันอัตโนมัติ", "กดรับรางวัลเช็กอินประจำวันทันทีที่มีสิทธิ์", "AutoDailyReward", nil)
createToggleRow(cardExtraGear, "เคลมภารกิจท้าทายอัตโนมัติ", "ส่งคำสั่งรับรางวัลภารกิจรายวันและรายสัปดาห์อัตโนมัติ", "AutoClaimChallenges", nil)
end

-- -------------------- แท็บ 3: เสกของและของรางวัล --------------------
do
local PageSpawner = createTabPage("เสกของและของรางวัล")

local cardServerLoot = createSectionCard(PageSpawner, "รับและดูดของจริงในเซิร์ฟเวอร์", 1)
createActionRow(cardServerLoot, "ดูดเก็บไอเทมเกิดบนพื้นทั้งแมพทันที", "กวาดเก็บจุดเกิดไอเทมและแท่นสะสมในแผนที่เข้าตัวจริงเมื่อเงื่อนไขครบ", "ดูดเก็บทั้งแมพ", false, function()
    task.spawn(vacuumAllMapItems)
end)
createActionRow(cardServerLoot, "เคลมของฟรีและกิจกรรมเซิร์ฟเวอร์ทั้งหมด", "ส่งคำสั่งรับของขวัญนักพัฒนา รายวัน ภารกิจ รหัสลับ ดาวตก และกรงปูสุก", "เคลมทั้งหมดทันที", false, function()
    task.spawn(claimAllServerRewardsNow)
end)
createToggleRow(cardServerLoot, "ดูดเก็บไอเทมเกิดทั้งแผนที่อัตโนมัติ", "เก็บไอเทมเกิดและจุดสะสมทั้งแผนที่ต่อเนื่องโดยไม่จำกัดระยะ 140 เมตร", "AutoCollectAllMap", nil)
createToggleRow(cardServerLoot, "รับของขวัญกิจกรรมพิเศษอัตโนมัติ", "ตรวจสอบและเคลมของขวัญนักพัฒนาและแท่นรางวัลกิจกรรมเป็นระยะ", "AutoClaimEventRewards", nil)

local cardSpawnerCfg = createSectionCard(PageSpawner, "ตั้งค่าไอเทมที่ต้องการเสกแบบจำลองฝั่งเครื่อง", 2)
local refreshSpawnerCatalog: (() -> ()) = function() end
createDropdownRow(cardSpawnerCfg, "เลือกหมวดหมู่ที่ต้องการเสก", "โมเดลที่เสกมองเห็นเฉพาะเครื่องเราเท่านั้น ขายหรือเทรดบนเซิร์ฟเวอร์ไม่ได้", "SpawnerCategory", { "ปลาในสารานุกรม", "ไอเทมทั่วไป", "เบ็ดตกปลา", "เรือและยานพาหนะ", "เหยื่อตกปลา" }, Config.SpawnerCategory, function()
    refreshSpawnerCatalog()
    refreshAllUI()
end)
createTextInputRow(cardSpawnerCfg, "พิมพ์ชื่อไอเทม ปลา หรือคำค้นหา", "กรอกชื่อหรือคำค้นหาเพื่อกรองรายการจากฐานข้อมูลตัวเกม", "SpawnerItemName", function()
    refreshSpawnerCatalog()
    refreshAllUI()
end)
refreshSpawnerCatalog = createDropdownRow(cardSpawnerCfg, "เลือกรายชื่อที่ตรงจากคลังเกม", "แสดงรายชื่อจากฐานข้อมูลเกมจริงสูงสุด 60 รายการตามคำค้นหา", "SpawnerItemName", getSpawnerCatalogSuggestions, Config.SpawnerItemName, function(opt)
    Config.SpawnerItemName = opt
    refreshAllUI()
end)
createNumericInputRow(cardSpawnerCfg, "ขนาดโมเดล 3 มิติ %", "ปรับสัดส่วนขนาดของโมเดลปลาหรือไอเทมที่เสกขึ้นมา", "SpawnerScalePercent", 25, 300, nil)
createToggleRow(cardSpawnerCfg, "เสกแบบเงางามพิเศษ", "เลือกใช้โมเดลสีพิเศษหากปลาตัวนั้นมีรูปแบบเงางามในเกม", "SpawnerShiny", nil)
createToggleRow(cardSpawnerCfg, "ใส่เอฟเฟกต์ประกายแสงวิบวับ", "เพิ่มแสงและประกายระยิบระยับรอบโมเดลที่เสกขึ้นมา", "SpawnerSparkling", nil)

local cardSpawnerDo = createSectionCard(PageSpawner, "เสกถือ วางโมเดล และแบนเนอร์จับปลา", 3)
createActionRow(cardSpawnerDo, "เสกเข้าช่องกระเป๋าและถือในมือทันที", "สร้างไอเทมจำลองในกระเป๋าพร้อมโมเดล 3 มิติจริงของเกมสำหรับถือโชว์หรือถ่ายภาพ", "เสกถือในมือ", false, function()
    task.spawn(spawnVisualTool, Config.SpawnerItemName)
end)
createActionRow(cardSpawnerDo, "เสกวางโมเดล 3 มิติไว้ตรงหน้า", "โหลดโมเดลจากสตรีมของเกมมาวางประดับตรงหน้าตัวละครฝั่งเครื่องเรา", "เสกวางในฉาก", false, function()
    task.spawn(spawnVisualWorldModel, Config.SpawnerItemName)
end)
createActionRow(cardSpawnerDo, "จำลองแบนเนอร์จับปลาขึ้นหน้าจอ", "ยิงอีเวนต์แสดงเอฟเฟกต์ประกาศจับปลาหรือไอเทมระดับตำนานฝั่งเครื่องเรา", "แสดงแบนเนอร์", false, function()
    triggerVisualCatchBanner(Config.SpawnerItemName)
end)
createActionRow(cardSpawnerDo, "ล้างของจำลองที่เสกทั้งหมด", "ลบไอเทมถือและโมเดลจำลองทั้งหมดที่เสกไว้ออกจากตัวและฉาก", "ล้างของที่เสก", true, function()
    clearSpawnedVisuals()
    setStatus("ล้างไอเทมและโมเดลจำลองทั้งหมดแล้ว")
    showToast("ล้างของจำลองที่เสกทั้งหมดเรียบร้อย")
end)
end

-- -------------------- แท็บ 4: สำรวจและวาร์ป --------------------
do
local PageWorld = createTabPage("สำรวจและวาร์ป")

local cardHunt = createSectionCard(PageWorld, "จุดล่าบอส ปลาหายาก และตัวช่วยนำทาง", 1)
createActionRow(cardHunt, "เดินหรือหาวาร์ปไปจุดน้ำใกล้ที่สุด", "สแกนหาตลิ่งใกล้ตัวและเดินนำทางไปยืนริมน้ำทันที", "เดินหาแหล่งน้ำ", false, function()
    local _, _, hrp = getCharacterParts()
    if hrp then
        local stand, water = findBestShorelineSpot(hrp.Position, Config.WalkRangeLimit)
        if stand and water then
            task.spawn(function()
                showToast("กำลังเดินไปจุดตกปลาริมน้ำ...")
                walkToTarget(stand, 16, nil)
                faceDirection(water)
            end)
        else
            showToast("ไม่พบแหล่งน้ำใกล้ตัวในรัศมีนี้")
        end
    end
end)
createActionRow(cardHunt, "วาร์ปไปจุดล่าบอสหรือบ่อปลาพิเศษ", "ค้นหาบ่อปลาล่าบอสที่กำลังเกิดในแมพและพาไปทันที", "ค้นหาบ่อพิเศษ", false, function()
    local zones = Workspace:FindFirstChild("zones")
    local fishing = zones and zones:FindFirstChild("fishing")
    if fishing then
        for _, z in ipairs(fishing:GetChildren()) do
            local zl = z.Name:lower()
            if zl:find("hunt") or zl:find("mega") or zl:find("kraken") or zl:find("scylla") or zl:find("whirlpool") or zl:find("isonade") or zl:find("orca") then
                local part: BasePart? = if z:IsA("BasePart") then z else z:FindFirstChildWhichIsA("BasePart", true)
                if part then
                    teleportSafeTo(part.Position + Vector3.new(0, 12, 0), z.Name)
                    return
                end
            end
        end
    end
    showToast("ยังไม่มีบ่อปลาล่าบอสหรือเหตุการณ์พิเศษในขณะนี้")
end)
createActionRow(cardHunt, "วาร์ปไปหาพ่อค้าขายปลาใกล้ที่สุด", "ย้ายตำแหน่งไปยืนหน้าพ่อค้าที่ใกล้ที่สุดทันที", "ไปหาพ่อค้า", false, function()
    local merch = findNearestMerchant()
    if merch then
        teleportSafeTo(merch.Pos + Vector3.new(0, 2, 4), merch.Name)
    else
        showToast("ไม่พบพ่อค้าในแผนที่ปัจจุบัน")
    end
end)
createActionRow(cardHunt, "วาร์ปไปหาผู้ประเมินราคาปลา", "ค้นหาตัวละครผู้ประเมินราคาและพาไปหน้าเคาน์เตอร์", "ไปประเมินปลา", false, function()
    for _, npc in ipairs(getAllLiveNPCs()) do
        if npc.Name:lower():find("apprais") then
            teleportSafeTo(npc.Pos + Vector3.new(0, 2, 4), npc.Name)
            return
        end
    end
    showToast("ไม่พบผู้ประเมินราคาในแผนที่ปัจจุบัน")
end)
createActionRow(cardHunt, "วาร์ปไปหีบสมบัติจากแผนที่", "ตรวจสอบตำแหน่งหีบสมบัติในโลกและพาไปทันที", "ไปหีบสมบัติ", false, function()
    for _, chest in ipairs(CollectionService:GetTagged("TreasureChest")) do
        local p = chest:IsA("Model") and chest:GetPivot().Position or (chest:IsA("BasePart") and chest.Position or nil)
        if p then
            teleportSafeTo(p, "หีบสมบัติ")
            return
        end
    end
    local world = Workspace:FindFirstChild("world")
    local chests = world and world:FindFirstChild("chests")
    local first = chests and chests:GetChildren()[1]
    if first then
        local p = first:IsA("Model") and first:GetPivot().Position or (first:IsA("BasePart") and first.Position or nil)
        if p then
            teleportSafeTo(p, "หีบสมบัติ")
            return
        end
    end
    showToast("ยังไม่มีหีบสมบัติที่เปิดตำแหน่งแล้วในกระเป๋า")
end)
createActionRow(cardHunt, "รับรหัสลับหัวแครอท", "ส่งคำสั่งปลดล็อกรหัสลับหัวแครอทจากสคริปต์ตัวเกม", "กดรับรหัสลับ", false, function()
    local re = getNetRemote("RE", "CarrotService/ClaimCode")
    if re then
        local reObj: any = re
        pcall(function() reObj:FireServer() end)
        showToast("ส่งคำสั่งปลดล็อกรหัสลับแล้ว")
    end
end)

local cardIslands = createSectionCard(PageWorld, "วาร์ปไปยังเกาะและจุดเกิดจริงในแมพ", 2)
local chosenWorldSpot = "เกาะมูสวูด"
createDropdownRow(cardIslands, "เลือกจุดหมายจากเกาะและจุดเกิดจริงทั้งหมด", "สแกนจุดเกิดและเกาะทั้งหมดในแมพแบบเรียลไทม์", nil, getLiveSpawnNames, chosenWorldSpot, function(opt)
    chosenWorldSpot = opt
    teleportBySpotName(opt)
end)
for _, spot in ipairs(ISLAND_DOCKS) do
    createActionRow(cardIslands, spot.Name, "ย้ายตำแหน่งไปยังจุดเทียบเรือของ " .. spot.Name, "วาร์ปไปที่นี่", false, function()
        teleportSafeTo(spot.Pos, spot.Name)
    end)
end
end

-- -------------------- แท็บ 5: สายตรวจจับ --------------------
do
local PageESP = createTabPage("สายตรวจจับ")

local cardESPMain = createSectionCard(PageESP, "เรดาร์และระบบแสดงป้ายตำแหน่งในฉาก", 1)
createToggleRow(cardESPMain, "เปิดใช้งานเรดาร์ตรวจจับปลาของเกม", "เปิดคุณสมบัติเรดาร์ภายในตัวเกมเพื่อเห็นข้อมูลโซนปลา", "UnlockGameRadar", nil)
createToggleRow(cardESPMain, "ตรวจจับผู้เล่นอื่นพร้อมชื่อและเบ็ด", "แสดงป้ายชื่อ ระยะทาง และเบ็ดที่ผู้เล่นคนอื่นถืออยู่", "ESPPlayers", function(v) if not v then updateESPObjects() end end)
createToggleRow(cardESPMain, "ตรวจจับทุ่นเบ็ดในทะเล", "แสดงป้ายตำแหน่งทุ่นเบ็ดของผู้เล่นทุกคนบนผิวน้ำ", "ESPBobbers", function(v) if not v then updateESPObjects() end end)
createToggleRow(cardESPMain, "ตรวจจับบ่อล่าบอสและวังวนพิเศษ", "ชี้เป้าบ่อหายาก เช่น วังวน ปลาในตำนาน หรือบอสทะเล", "ESPHuntZones", function(v) if not v then updateESPObjects() end end)
createToggleRow(cardESPMain, "ตรวจจับหีบสมบัติและดาวตก", "แสดงตำแหน่งและระยะทางไปยังหีบสมบัติหรือแร่ดาวตก", "ESPChestsAndMeteors", function(v) if not v then updateESPObjects() end end)
createToggleRow(cardESPMain, "ตรวจจับพ่อค้าและเจ้าหน้าที่สำคัญ", "แสดงจุดยืนของพ่อค้า ผู้ประเมินปลา และช่างต่อเรือ", "ESPNPCs", function(v) if not v then updateESPObjects() end end)
createToggleRow(cardESPMain, "ตรวจจับกรงดักปูของเรา", "แสดงสถานะของกรงดักปูที่วางไว้ว่าพร้อมเก็บหรือรอเวลา", "ESPCrabCages", function(v) if not v then updateESPObjects() end end)
createToggleRow(cardESPMain, "แสดงเส้นนำสายตาชี้เป้าหมาย", "วาดเส้นจากด้านล่างหน้าจอไปยังเป้าหมายที่ตรวจพบ", "ESPTracers", function(v) if not v then updateESPObjects() end end)
end

-- -------------------- แท็บ 6: โหมดหรรษา --------------------
do
local PageFun = createTabPage("โหมดหรรษา")

local cardFunSpin = createSectionCard(PageFun, "ตัวหมุนพายุไซโคลนให้คนอื่นเห็นได้จริง", 1)
createToggleRow(cardFunSpin, "เปิดโหมดตัวหมุนความเร็วสูง", "หมุนตัวละครรอบแกนจริงบนฟิสิกส์ที่ผู้เล่นอื่นเห็นได้ พร้อมยังเดินบังคับได้ปกติ", "Spinbot", nil)
createNumericInputRow(cardFunSpin, "ความเร็วรอบหมุนเป็นองศาต่อวินาที", "ปรับได้ตั้งแต่ 60 ถึง 14400 องศาต่อวินาที", "SpinSpeedDeg", 60, 14400, nil)
createToggleRow(cardFunSpin, "หมุนคอและศีรษะรัวเร็ว", "หมุนศีรษะตัวละครอย่างรวดเร็วแบบสุดฮา", "HeadSpin", nil)

local cardFunMove = createSectionCard(PageFun, "การเคลื่อนไหวเหนือธรรมชาติ", 2)
createToggleRow(cardFunMove, "เดินบนผิวน้ำได้เหมือนพื้นแข็ง", "สร้างแผ่นรองรับเฉพาะผิวน้ำจริงอัตโนมัติโดยไม่ลอยบนเกาะ", "WalkOnWater", nil)
createToggleRow(cardFunMove, "ลอยตัวไร้แรงโน้มถ่วง", "ทำตัวละครให้ลอยขึ้นลงเบาราวกับอยู่ในอวกาศ", "FloatMode", nil)
createToggleRow(cardFunMove, "โหมดบินลอยลมเสรี", "บินสำรวจทั่วแมพด้วยปุ่มเดินและขึ้นลงอิสระ", "FlyMode", function() updateFlyState() end)
createNumericInputRow(cardFunMove, "ความเร็วการบิน", "ปรับอัตราเร็วขณะเปิดใช้งานโหมดบิน", "FlySpeed", 20, 250, nil)
createToggleRow(cardFunMove, "กระโดดกลางอากาศไม่จำกัด", "กดกระโดดซ้ำได้ตลอดเวลาแม้ตัวละครอยู่กลางอากาศ", "InfiniteJump", nil)
createToggleRow(cardFunMove, "เดินทะลุสิ่งกีดขวาง", "ปิดการชนกับกำแพงและประตูเพื่อเข้าไปสำรวจพื้นที่ลับ", "Noclip", function(v)
    if not v and LocalPlayer.Character then
        for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") and (p.Name == "HumanoidRootPart" or p.Name == "Torso" or p.Name == "UpperTorso") then
                p.CanCollide = true
            end
        end
    end
end)
end

-- -------------------- แท็บ 7: ตัวละครและเอาเปรียบ --------------------
do
local PageAbuse = createTabPage("ตัวละครและเอาเปรียบ")

local cardSpeed = createSectionCard(PageAbuse, "ปลดล็อกขีดจำกัดความเร็วและเอาเปรียบระบบ", 1)
createToggleRow(cardSpeed, "ปลดล็อกอาการช้าขณะถือเบ็ดและในโซน", "ล้างสถานะบังคับเดินช้าและปลดล็อกการกระโดดขณะตกปลา", "BypassSpeedLock", nil)
createToggleRow(cardSpeed, "ล้างสถานะหนืด น้ำแข็ง และความหนาว", "ยกเลิกผลลดความเร็วจากหิมะ น้ำเย็นจัด และน้ำผึ้ง", "AntiFreezeSlow", nil)
createToggleRow(cardSpeed, "เปิดเพิ่มความเร็วการเดินผ่านระบบเกม", "แทรกค่าความเร็วรองเท้าผู้พัฒนาเพื่อไม่โดนระบบเกมรีเซ็ต", "FastWalk", nil)
createNumericInputRow(cardSpeed, "กำหนดความเร็วการเดิน", "ปรับความเร็วในการวิ่งข้ามพื้นที่", "WalkSpeedValue", 16, 200, nil)
createToggleRow(cardSpeed, "เปิดเพิ่มพลังการกระโดด", "ปรับแรงกระโดดให้ข้ามหน้าผาหรือสิ่งกีดขวางง่ายขึ้น", "HighJump", nil)
createNumericInputRow(cardSpeed, "กำหนดพลังการกระโดด", "ปรับค่าแรงดีดตัวในการกระโดด", "JumpPowerValue", 50, 250, nil)

local cardSurvive = createSectionCard(PageAbuse, "การเอาชีวิตรอด เรือ และทัศนวิสัย", 2)
createToggleRow(cardSurvive, "ป้องกันจมน้ำตายและออกซิเจนไม่จำกัด", "คงค่าอากาศเต็มและบล็อกคำสั่งจมน้ำตายในระบบ", "AntiDrown", nil)
createToggleRow(cardSurvive, "กันหลุดเกมเมื่อยืนนิ่งนาน", "สกัดกั้นสัญญาณแจ้งสถานะว่างงานไปยังเซิร์ฟเวอร์", "AntiAFK", nil)
createToggleRow(cardSurvive, "เร่งความเร็วเรือที่ขับอยู่", "เพิ่มแรงขับเคลื่อนให้เรือแล่นข้ามทะเลได้ไวขึ้นหลายเท่า", "BoatSpeedBoost", nil)
createNumericInputRow(cardSurvive, "ตัวคูณความเร็วเรือ", "ปรับระดับแรงส่งขณะกดคันเร่งเรือ", "BoatSpeedMultiplier", 1, 6, nil)
createToggleRow(cardSurvive, "ลบหน้าจอมืดบดบังสายตา", "ซ่อนหน้าจอดำที่ปิดบังขณะเกิดเหตุการณ์หรือจับปลา", "RemoveDarkScreen", nil)
createToggleRow(cardSurvive, "ปลดล็อกระยะซูมกล้องไกลสุด", "ซูมออกดูรอบเกาะได้ไกลถึง 400 เมตรตลอดเวลา", "UnlockMaxZoom", nil)
createToggleRow(cardSurvive, "ภาพใสสว่างใต้ทะเลลึก", "ลดหมอกใต้น้ำและเพิ่มความสว่างเมื่อดำน้ำลึก", "ClearUnderwaterVision", nil)
end

-- -------------------- แท็บ 8: ดึงเอนทีตี้ --------------------
do
local PagePull = createTabPage("ดึงเอนทีตี้")

local cardPullTarget = createSectionCard(PagePull, "เลือกเอนทีตี้เป้าหมายหรือทั้งหมวด", 1)
local refreshPullTargets: (() -> ()) = function() end
createDropdownRow(cardPullTarget, "หมวดหมู่เอนทีตี้ที่ต้องการดึง", "เลือกประเภท: ผู้เล่น ตัวละครระบบ เรือ ปลาบอส หรือของในฉาก", "EntityPullCategory", {
    "ทุกประเภท",
    "ผู้เล่นอื่น",
    "พ่อค้าและตัวละครระบบ",
    "เรือทั้งหมด",
    "ปลาและบอสในฉาก",
    "ไอเทม หีบสมบัติ และกรงปู",
    "สิ่งมีชีวิตทั่วไปในฉาก",
}, Config.EntityPullCategory, function()
    Config.EntityPullTargetName = "ทุกตัวในหมวด"
    EntityPull.InvalidateCache()
    refreshPullTargets()
    refreshAllUI()
end)
createTextInputRow(cardPullTarget, "พิมพ์ชื่อเอนทีตี้เพื่อค้นหา", "พิมพ์ชื่อบางส่วนเพื่อกรองเฉพาะตัว หรือปล่อยว่างเพื่อแสดงทั้งหมด", "EntityPullSearchName", function()
    Config.EntityPullTargetName = "ทุกตัวในหมวด"
    EntityPull.InvalidateCache()
    refreshPullTargets()
    refreshAllUI()
end, true)
refreshPullTargets = createDropdownRow(cardPullTarget, "ระบุตัวที่ต้องการจากในฉาก", "สแกนรายชื่อเอนทีตี้จริงในฉากปัจจุบัน เลือกเฉพาะตัวหรือเลือกทุกตัวในหมวด", "EntityPullTargetName", EntityPull.GetTargetDropdownOptions, Config.EntityPullTargetName, function(opt)
    Config.EntityPullTargetName = opt
    EntityPull.InvalidateCache()
    refreshAllUI()
end)
createActionRow(cardPullTarget, "รีเฟรชรายชื่อเอนทีตี้สด", "สแกนหาผู้เล่น เรือ ตัวละคร และบอสที่เพิ่งเกิดใหม่ในฉากทันที", "สแกนรายชื่อใหม่", false, function()
    EntityPull.InvalidateCache()
    refreshPullTargets()
    local list = EntityPull.ResolveSelectedEntries(true)
    showToast("พบเอนทีตี้ที่ตรงเงื่อนไขจำนวน " .. tostring(#list) .. " ตัว")
end)

local cardPullDest = createSectionCard(PagePull, "กำหนดจุดหมายที่ต้องการดึงไปวาง", 2)
createDropdownRow(cardPullDest, "เลือกวิธีระบุตำแหน่งจุดหมาย", "ดึงมาด้านหน้าตัวเรา จุดที่ปักหมุด จุดที่เมาส์ชี้ เกาะ หรือพิกัดที่พิมพ์", "EntityPullDestMode", {
    "ด้านหน้าตัวเรา",
    "จุดที่ปักหมุดไว้",
    "ตำแหน่งเมาส์ชี้",
    "เกาะหรือจุดเกิดที่เลือก",
    "พิกัดกำหนดเอง",
}, Config.EntityPullDestMode, function()
    refreshAllUI()
end)
createDropdownRow(cardPullDest, "เลือกเกาะหรือจุดเกิดจุดหมาย", "ใช้เมื่อโหมดจุดหมายตั้งเป็น เกาะหรือจุดเกิดที่เลือก", "EntityPullDestIsland", getLiveSpawnNames, Config.EntityPullDestIsland, function(opt)
    Config.EntityPullDestIsland = opt
    Config.EntityPullDestMode = "เกาะหรือจุดเกิดที่เลือก"
    refreshAllUI()
end)
createTextInputRow(cardPullDest, "พิกัดกำหนดเองสามมิติ", "กรอกตัวเลขพิกัดคั่นด้วยจุลภาค ตัวอย่างเช่น 290, 136, 230", "EntityPullCustomCoords", function()
    refreshAllUI()
end)
createActionRow(cardPullDest, "ปักหมุดจุดที่เรายืนเป็นจุดหมาย", "บันทึกตำแหน่งปัจจุบันพร้อมแสดงลูกแก้วแสงฟ้าไว้เป็นเป้าหมายดึง", "ปักหมุดจุดยืน", false, function()
    EntityPull.PinCurrentPosition()
    refreshAllUI()
end)
createActionRow(cardPullDest, "ปักหมุดตรงจุดที่กล้องเล็งอยู่", "ยิงเส้นจากกล้องไปปักหมุดจุดหมายตรงตำแหน่งที่มองอยู่ทันที", "ปักหมุดตามกล้อง", false, function()
    EntityPull.PinCameraLookPosition()
    refreshAllUI()
end)
createActionRow(cardPullDest, "ลบหมุดจุดหมายบนฉาก", "ซ่อนลูกแก้วแสงระบุพิกัดที่ปักหมุดไว้ออกจากแผนที่", "ลบหมุด", false, function()
    EntityPull.ClearPin()
end)

local cardPullExec = createSectionCard(PagePull, "คำสั่งดึงเอนทีตี้และจัดระเบียบ", 3)
createActionRow(cardPullExec, "ดึงเฉพาะตัวที่กำหนดไปจุดหมาย", "ย้ายเอนทีตี้ตัวที่เลือกหรือตามคำค้นหาไปยังจุดหมายที่ตั้งไว้ทันที", "ดึงตัวที่กำหนด", false, function()
    EntityPull.PullNow(false)
end)
createActionRow(cardPullExec, "ดึงทุกตัวในหมวดไปจุดหมาย", "รวมเอนทีตี้ทั้งหมดในหมวดและคำค้นหาไปรวมที่จุดหมายในคลิกเดียว", "ดึงทุกตัวทันที", false, function()
    EntityPull.PullNow(true)
end)
createToggleRow(cardPullExec, "ดูดดึงค้างไว้ต่อเนื่องอัตโนมัติ", "คอยตรึงตัวที่กำหนดหรือทั้งหมวดให้อยู่ที่จุดหมายตลอดเวลา • วัตถุที่เราเป็นเจ้าของฟิสิกส์จะซิงค์ทั้งห้อง ส่วนตัวละครอื่นหรือจุดล็อกจะเห็นฝั่งเรา", "EntityPullLoop", nil)
createNumericInputRow(cardPullExec, "ระยะห่างด้านหน้าตัวเรา", "ระยะเป็นเมตรเมื่อเลือกดึงมาไว้ด้านหน้าตัวเรา", "EntityPullFrontDist", 2, 120, nil)
createNumericInputRow(cardPullExec, "ระยะจัดเรียงห่างกันเมื่อดึงหลายตัว", "จัดเรียงเป็นตารางไม่ให้ซ้อนทับกัน ตั้งเป็น 0 หากต้องการซ้อนจุดเดียว", "EntityPullGridSpacing", 0, 30, nil)
createToggleRow(cardPullExec, "ปิดการชนของเอนทีตี้ที่ถูกดึง", "กันไม่ให้เรือหรือตัวละครที่ถูกดึงมากระแทกตัวเราปลิวตกน้ำ", "EntityPullNoCollide", function()
    EntityPull.SyncCollisionSetting()
end)
createActionRow(cardPullExec, "คืนตำแหน่งเดิมเอนทีตี้ที่ดึงมา", "นำเอนทีตี้ทั้งหมดที่เคยดึงไว้กลับไปยังตำแหน่งเริ่มต้นและคืนค่าการชน", "คืนตำแหน่งเดิม", true, function()
    EntityPull.RestoreOriginalPositions()
    refreshAllUI()
end)
end

-- -------------------- แท็บ 9: ข้อมูลและเซิร์ฟเวอร์ --------------------
do
local PageServer = createTabPage("ข้อมูลและเซิร์ฟเวอร์")

local cardStats = createSectionCard(PageServer, "ข้อมูลตัวละครและพื้นที่ปัจจุบัน", 1)
createActionRow(cardStats, "ตรวจสอบสถานะตัวละครสด", "สรุปเลเวล เงิน เบ็ด เหยื่อ โซน และจำนวนปลาที่จับได้รอบนี้", "แสดงข้อมูลสด", false, function()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    local lvl = ls and ls:FindFirstChild("Level")
    local cash = ls and ls:FindFirstChild("C$")
    local zoneCtrl = getZoneController()
    local zoneName = (zoneCtrl and zoneCtrl.CurrentZoneName) or tostring(LocalPlayer:GetAttribute("ZoneName") or "ไม่ทราบ")
    local msg = "ระดับ " .. tostring(lvl and (lvl :: any).Value or "-")
        .. " • เงิน " .. tostring(cash and (cash :: any).Value or "-")
        .. " • เบ็ด " .. tostring(getCurrentRodName() or "-")
        .. " • พื้นที่ " .. zoneName
        .. " • จับรอบนี้ " .. tostring(Runtime.CatchesCount) .. " ตัว"
    setStatus(msg)
    showToast(msg, 4)
end)
createActionRow(cardStats, "กลับไปยังจุดเกิดหรือเกาะล่าสุด", "เรียกคำสั่งของตัวเกมเพื่อพากลับจุดปลอดภัยล่าสุด", "กลับเกาะล่าสุด", false, function()
    local re = getNetRemote("RE", "ReturnToLastIsland")
    if re then
        local reObj: any = re
        pcall(function() reObj:FireServer() end)
        showToast("ส่งคำสั่งกลับเกาะล่าสุดแล้ว")
    end
end)
createActionRow(cardStats, "สุ่มย้ายไปยังเซิร์ฟเวอร์ใหม่", "เรียกคำสั่งสุ่มห้องใหม่เพื่อหนีคนหรือหาเซิร์ฟเวอร์ที่มีบอส", "ย้ายห้องสุ่ม", false, function()
    local rf = getNetRemote("RF", "ServerBrowser/TeleportToRandom")
    if rf then
        local rfObj: any = rf
        showToast("กำลังค้นหาและย้ายไปเซิร์ฟเวอร์ใหม่...")
        pcall(function() rfObj:InvokeServer() end)
    end
end)
end

-- -------------------- แท็บ 10: ตั้งค่าระบบ --------------------
do
local PageSettings = createTabPage("ตั้งค่าระบบ")

local cardTheme = createSectionCard(PageSettings, "หน้าตาเมนู ชุดสี และรูปแบบอักษร", 1)
createDropdownRow(cardTheme, "เลือกชุดสีเมนู", "เปลี่ยนชุดสีหลักทั้งหน้าต่างทันที", "ThemeName", { "ชมพูซากุระ", "มืดคราม", "เขียวมรกต", "ม่วงอเมทิสต์", "ทองคำมืด", "สว่างสะอาด" }, Config.ThemeName, function()
    applyAppearance()
    saveProfile()
end)
createDropdownRow(cardTheme, "เลือกรูปแบบตัวอักษรภาษาไทย", "ปรับฟอนต์ที่ใช้แสดงข้อความทั้งหมด", "FontName", { "โกธิคทันสมัย", "โกธิคหนา", "ซอร์สแซนส์", "ซอร์สแซนส์หนา", "อารีย์" }, Config.FontName, function()
    applyAppearance()
    saveProfile()
end)
createNumericInputRow(cardTheme, "ขนาดตัวอักษรมาตรฐาน", "ปรับขนาดฟอนต์ให้เหมาะกับสายตา", "FontSize", 10, 24, function()
    applyAppearance()
    saveProfile()
end)
createNumericInputRow(cardTheme, "ขนาดหน้าต่างเมนู %", "ย่อหรือขยายหน้าต่างให้พอดีกับหน้าจอ", "GuiScalePercent", 60, 150, function()
    applyAppearance()
    saveProfile()
end)
createNumericInputRow(cardTheme, "ความจางพื้นหลัง %", "ปรับระดับความโปร่งแสงของหน้าต่างหลัก", "BackgroundTransparency", 0, 85, function()
    applyAppearance()
    saveProfile()
end)
createToggleRow(cardTheme, "เบลอฉากหลังเมื่อเปิดเมนู", "เปิดเอฟเฟกต์เบลอฉากหลังขณะกำลังปรับตั้งค่า", "BackgroundBlur", function()
    applyAppearance()
    saveProfile()
end)
createKeybindRow(cardTheme, "ปุ่มลัดสำหรับซ่อนหรือเปิดเมนู", "คลิกแล้วกดปุ่มที่ต้องการเพื่อสลับหน้าต่างอย่างรวดเร็ว")

local cardProfiles = createSectionCard(PageSettings, "จัดการโปรไฟล์และการควบคุมระบบ", 2)
createActionRow(cardProfiles, "บันทึกการตั้งค่าปัจจุบัน", "เก็บค่าทุกฟังก์ชันลงไฟล์โปรไฟล์บนเครื่อง", "บันทึกโปรไฟล์", false, function()
    if saveProfile() then
        showToast("บันทึกข้อมูลโปรไฟล์สำเร็จแล้ว")
    else
        showToast("ตัวรันไม่รองรับการเขียนไฟล์ลงดิสก์")
    end
end)
createActionRow(cardProfiles, "ปิดทุกฟังก์ชันที่เปิดอยู่", "ปิดสวิตช์การทำงานอัตโนมัติและตัวช่วยทั้งหมดทันที", "ปิดทุกค่าที่เปิด", false, function()
    for k, v in pairs(DefaultConfig) do
        if type(v) == "boolean" then
            Config[k] = false
        end
    end
    Runtime.IsNavigating = false
    updateFlyState()
    clearESP()
    clearSpawnedVisuals()
    EntityPull.SyncCollisionSetting()
    refreshAllUI()
    setStatus("ปิดฟังก์ชันที่เปิดทำงานทั้งหมดแล้ว")
    showToast("ปิดทุกค่าที่เปิดทั้งหมดแล้ว")
end)
createActionRow(cardProfiles, "คืนค่ามาตรฐานทั้งหมด", "รีเซ็ตการตั้งค่าทั้งหมดกลับสู่ค่าเริ่มต้นเดิม", "คืนค่ามาตรฐาน", false, function()
    for k, v in pairs(DefaultConfig) do
        Config[k] = v
    end
    Runtime.IsNavigating = false
    updateFlyState()
    clearESP()
    clearSpawnedVisuals()
    EntityPull.CleanupOnUnload()
    saveProfile()
    refreshAllUI()
    setStatus("คืนค่ามาตรฐานทั้งหมดเรียบร้อยแล้ว")
    showToast("คืนค่ามาตรฐานสำเร็จ")
end)
createActionRow(cardProfiles, "หยุดงานและนำเมนูออกทั้งหมด", "ยกเลิกการเชื่อมต่อทั้งหมด ล้างสิ่งก่อสร้าง และปิดสคริปต์ถาวร", "หยุดงานและปิดเมนู", true, function()
    if type(GlobalEnv.__FischThaiCleanV2Cleanup) == "function" then
        GlobalEnv.__FischThaiCleanV2Cleanup()
    end
end)
end

-- ============================================================================
-- 17. ปุ่มลัดและตัวล้างระบบอย่างสมบูรณ์
-- ============================================================================

selectTab("ตกปลาอัตโนมัติ")
refreshAllUI()

connectSignal(UserInputService.InputBegan, function(input: InputObject, gameProcessed: boolean)
    if gameProcessed or isTextBoxFocused() then
        return
    end
    local targetKey = getMenuKeyCode()
    if targetKey and input.KeyCode == targetKey then
        setWindowOpen(not IsWindowOpen)
    end
end)

local function performCleanup()
    IsScriptRunning = false
    Runtime.IsNavigating = false
    for k, v in pairs(DefaultConfig) do
        if type(v) == "boolean" then
            Config[k] = false
        end
    end

    for _, conn in ipairs(ActiveConnections) do
        pcall(function()
            conn:Disconnect()
        end)
    end
    table.clear(ActiveConnections)

    clearESP()
    clearSpawnedVisuals()
    EntityPull.CleanupOnUnload()

    if waterPlatform then
        pcall(function() waterPlatform:Destroy() end)
        waterPlatform = nil
    end
    if flyBV then pcall(function() flyBV:Destroy() end); flyBV = nil end
    if flyBG then pcall(function() flyBG:Destroy() end); flyBG = nil end
    if BlurEffect then pcall(function() BlurEffect:Destroy() end); BlurEffect = nil end

    if LightingBackup.FogEnd ~= nil then
        Lighting.FogEnd = LightingBackup.FogEnd
        Lighting.Brightness = LightingBackup.Brightness
    end

    if savedNeckRef and savedNeckC0 and savedNeckRef.Parent then
        savedNeckRef.C0 = savedNeckC0
    end
    savedNeckRef = nil
    savedNeckC0 = nil
    local char, hum = getCharacterParts()
    if char then
        char:SetAttribute("DeveloperBoots", nil)
        char:SetAttribute("FishingWalkSpeed", nil)
        char:SetAttribute("FishingJumpPower", nil)
    end
    if hum then
        hum.AutoRotate = true
        hum.WalkSpeed = 16
        hum.JumpPower = 50
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
    end

    if ScreenGui and ScreenGui.Parent then
        ScreenGui:Destroy()
    end
end

GlobalEnv.__FischThaiCleanV2Cleanup = performCleanup
_G.__FischThaiCleanV2Cleanup = performCleanup

setStatus("พร้อมทำงาน • ระบบเดินเองและตกปลาอัตโนมัติพร้อมใช้งาน", "ok", 0)
showToast("เปิดเมนูช่วยเหลือเกมตกปลาภาษาไทยสำเร็จ กด " .. getThaiKeyName(getMenuKeyCode()) .. " เพื่อสลับหน้าต่าง", 3.5)
