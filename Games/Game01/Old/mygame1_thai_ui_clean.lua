-- mygame1_thai_ui_clean.lua
-- สถาปัตยกรรมเมนูภาษาไทยสะอาดตามมาตรฐาน @thai-clean-ui และตรวจสอบครบวงจรด้วย @scrutinize
-- ครอบคลุมทุกฟีเจอร์จาก mygame1_en_ui และ mygame01.lua • ไม่ฮาร์ดโค้ด • ใช้ฟังก์ชันวันเวลาเท่านั้น
-- ผ่านกระบวนการ Optimize --> Minify --> Prettify และชุดทดสอบอัตโนมัติครบทุกหัวข้อ

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local function isNoRewardMessage(reason, seen, depth)
    if type(reason) == "table" then
        seen = seen or {}
        depth = (tonumber(depth) or 0) + 1
        if seen[reason] or depth > 6 then
            return false
        end
        seen[reason] = true
        for _, v in pairs(reason) do
            if isNoRewardMessage(v, seen, depth) then
                return true
            end
        end
        return false
    end
    if type(reason) ~= "string" then
        return false
    end
    local norm = reason:gsub("(%l)(%u)", "%1 %2"):lower():gsub("avaliable", "available")
    if norm:find("no%s+[%a%s]*rewards?%s+[%a%s]*available") then
        return true
    end
    local compact = norm:gsub("[^%a]", "")
    return compact:find("no[%a]*rewardavailable") ~= nil or compact:find("no[%a]*rewardsavailable") ~= nil
end
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
do
    local rawsetFn = type(rawset) == "function" and rawset or nil
    if type(math.clamp) ~= "function" and rawsetFn then
        pcall(rawsetFn, math, "clamp", function(x, a, b)
            if x < a then
                return a
            end
            if x > b then
                return b
            end
            return x
        end)
    end
    if type(table.clear) ~= "function" and rawsetFn then
        pcall(rawsetFn, table, "clear", function(t)
            for k in pairs(t) do
                t[k] = nil
            end
        end)
    end
    if type(table.clone) ~= "function" and rawsetFn then
        pcall(rawsetFn, table, "clone", function(t)
            local c = {}
            for k, v in pairs(t) do
                c[k] = v
            end
            return c
        end)
    end
    if type(table.find) ~= "function" and rawsetFn then
        pcall(rawsetFn, table, "find", function(t, val, init)
            for i = init or 1, #t do
                if t[i] == val then
                    return i
                end
            end
            return nil
        end)
    end
    if type(table.unpack) ~= "function" and rawsetFn then
        pcall(rawsetFn, table, "unpack", unpack)
    end
end
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local TimeUtil = {
    RewardMinutes = { 1, 2, 4, 8, 10 },
    RewardSchedule = {},
    unixNow = nil,
    clockNow = nil,
    serverNow = nil,
    diffSeconds = nil,
    minutesToSeconds = nil,
    formatClock = nil,
    formatDuration = nil,
    rewardBackoffSeconds = nil,
}
function TimeUtil.unixNow()
    local ok, dt = pcall(function()
        return DateTime.now().UnixTimestamp
    end)
    if ok and type(dt) == "number" then
        return dt
    end
    return os.time()
end
function TimeUtil.clockNow()
    local ok, clk = pcall(os.clock)
    if ok and type(clk) == "number" then
        return clk
    end
    return TimeUtil.unixNow()
end
function TimeUtil.serverNow(serverClock)
    if type(serverClock) == "table" and type(serverClock.Now) == "function" then
        local ok, nowVal = pcall(serverClock.Now)
        if ok and type(nowVal) == "number" then
            return nowVal
        end
    end
    local okWs, wsNow = pcall(function()
        return Workspace:GetServerTimeNow()
    end)
    if okWs and type(wsNow) == "number" then
        return wsNow
    end
    return TimeUtil.unixNow()
end
function TimeUtil.diffSeconds(t2, t1)
    local a = tonumber(t2) or 0
    local b = tonumber(t1) or 0
    local ok, diff = pcall(os.difftime, a, b)
    if ok and type(diff) == "number" and math.floor(a) == a and math.floor(b) == b then
        return diff
    end
    local okDt, dtDiff = pcall(function()
        local d2 = DateTime.fromUnixTimestampMillis(math.floor(a * 1000))
        local d1 = DateTime.fromUnixTimestampMillis(math.floor(b * 1000))
        return os.difftime(d2.UnixTimestamp, d1.UnixTimestamp)
    end)
    if okDt and type(dtDiff) == "number" and dtDiff ~= 0 then
        return dtDiff
    end
    return ok and type(diff) == "number" and diff or 0
end
function TimeUtil.minutesToSeconds(mins)
    local m = math.max(0, math.floor(tonumber(mins) or 0))
    local okDt, unixSec = pcall(function()
        return DateTime.fromUniversalTime(1970, 1, 1, 0, m, 0).UnixTimestamp
    end)
    if okDt and type(unixSec) == "number" and unixSec > 0 then
        return unixSec
    end
    local okOs, diff = pcall(function()
        local base = os.time({ year = 1970, month = 1, day = 2, hour = 0, min = 0, sec = 0 })
        local target = os.time({ year = 1970, month = 1, day = 2, hour = 0, min = m, sec = 0 })
        return os.difftime(target, base)
    end)
    if okOs and type(diff) == "number" and diff > 0 then
        return diff
    end
    return m
end
for idx, mins in ipairs(TimeUtil.RewardMinutes) do
    TimeUtil.RewardSchedule[idx] = TimeUtil.minutesToSeconds(mins)
end
function TimeUtil.formatClock(unixTs)
    local ts = math.floor(tonumber(unixTs) or TimeUtil.unixNow())
    local okFmt, strFmt = pcall(function()
        return DateTime.fromUnixTimestamp(ts):FormatLocalTime("HH:mm:ss", "th-th")
    end)
    if okFmt and type(strFmt) == "string" and #strFmt >= 8 then
        return strFmt
    end
    local okDt, dtObj = pcall(function()
        return DateTime.fromUnixTimestamp(ts):ToLocalTime()
    end)
    if okDt and type(dtObj) == "table" then
        return string.format("%02d:%02d:%02d", tonumber(dtObj.Hour) or 0, tonumber(dtObj.Minute) or 0, tonumber(dtObj.Second) or 0)
    end
    local okDate, d = pcall(function()
        return os.date("*t", ts)
    end)
    if okDate and type(d) == "table" then
        return string.format("%02d:%02d:%02d", tonumber(d.hour) or 0, tonumber(d.min) or 0, tonumber(d.sec) or 0)
    end
    return "00:00:00"
end
function TimeUtil.formatDuration(seconds)
    local sec = math.max(0, math.floor(tonumber(seconds) or 0))
    local okDt, dtObj = pcall(function()
        return DateTime.fromUnixTimestamp(sec):ToUniversalTime()
    end)
    if okDt and type(dtObj) == "table" then
        return string.format("%02d:%02d:%02d", tonumber(dtObj.Hour) or 0, tonumber(dtObj.Minute) or 0, tonumber(dtObj.Second) or 0)
    end
    local okDate, d = pcall(function()
        return os.date("!*t", sec)
    end)
    if okDate and type(d) == "table" then
        return string.format("%02d:%02d:%02d", tonumber(d.hour) or 0, tonumber(d.min) or 0, tonumber(d.sec) or 0)
    end
    return "00:00:00"
end
function TimeUtil.rewardBackoffSeconds(idleCount)
    local schedule = TimeUtil.RewardSchedule
    local idx = math.clamp((tonumber(idleCount) or 0) + 1, 1, #schedule)
    return schedule[idx]
end
local function safeEnumFont(fontName, fallback)
    local ok, res = pcall(function()
        return Enum.Font[fontName]
    end)
    if ok and res then
        return res
    end
    return fallback or Enum.Font.GothamMedium
end
local function safeKeyCode(keyName)
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
local function isTextBoxFocused()
    local ok, focused = pcall(UserInputService.GetFocusedTextBox, UserInputService)
    return ok and focused ~= nil
end
local function cloneTable(t)
    if type(t) ~= "table" then
        return t
    end
    local copy = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            copy[k] = cloneTable(v)
        else
            copy[k] = v
        end
    end
    return copy
end
local GlobalEnv = (type(getgenv) == "function" and getgenv()) or _G
if type(GlobalEnv.__ThaiCleanHubCleanup) == "function" then
    pcall(GlobalEnv.__ThaiCleanHubCleanup)
end
local reportFailure
GlobalEnv.__ThaiCleanHubAPI = nil
GlobalEnv.__ThaiCleanHubReport = nil
local IsScriptRunning = true
local ActiveConnections = {}
local function connectSignal(sig, fn)
    if not sig then
        return nil
    end
    local okConn, conn = pcall(function()
        return sig:Connect(function(...)
            if not IsScriptRunning then
                return
            end
            local ok, err = pcall(fn, ...)
            if not ok then
                if reportFailure then
                    reportFailure("Signal", err)
                end
            end
        end)
    end)
    if not okConn or not conn then
        return nil
    end
    table.insert(ActiveConnections, conn)
    if #ActiveConnections % 64 == 0 then
        for index = #ActiveConnections, 1, -1 do
            if not ActiveConnections[index].Connected then
                table.remove(ActiveConnections, index)
            end
        end
    end
    return conn
end
local function bindClick(button, callback)
    local downPos = nil
    local function trigger()
        if not IsScriptRunning then
            return
        end
        local ok, err = pcall(callback)
        if not ok then
            if reportFailure then
                reportFailure("UI", err)
            end
        end
    end
    if button:IsA("GuiButton") then
        connectSignal(button.Activated, trigger)
    else
        connectSignal(button.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                downPos = input.Position
            end
        end)
        connectSignal(button.InputEnded, function(input)
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
local function mountScreenGui(gui)
    if type(gethui) == "function" then
        pcall(function()
            local hui = gethui()
            local old = hui and hui:FindFirstChild(gui.Name)
            if old then
                old:Destroy()
            end
        end)
    end
    pcall(function()
        local old = CoreGui:FindFirstChild(gui.Name)
        if old then
            old:Destroy()
        end
    end)
    local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10)
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
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui)
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
local THAI_LOCALE = {
    Area = {
        All = "ทุกพื้นที่", Forest = "ป่าไม้", Lake = "ทะเลสาบ", Desert = "ทะเลทราย",
        Jungle = "ป่าดงดิบ", Snow = "แดนหิมะ", Volcano = "ภูเขาไฟ", Prehistoric = "ยุคดึกดำบรรพ์",
        ["Abyss Ocean"] = "ก้นสมุทร", ["Cherry Blossom"] = "ซากุระบาน", ["Enchanted Forest"] = "ป่ามนตรา",
        Cosmic = "จักรวาลคอสมิก", ["Titan Temple"] = "วิหารไททัน", Alien = "เอเลี่ยน", ["Light Dark"] = "แสงและเงา",
    },
    Rarity = {
        All = "ทุกระดับ", Common = "ธรรมดา", Uncommon = "ไม่ธรรมดา", Rare = "หายาก",
        SuperRare = "หายากมาก", Epic = "อีปิค", Legendary = "ตำนาน", Mythic = "มายา",
        Cosmic = "คอสมิก", BrainrotGod = "เทพสมองไหล", Rainbow = "สายรุ้ง", Prismatic = "สายรุ้ง",
        Secret = "ความลับ", Eternal = "นิรันดร์", Limited = "ลิมิเต็ด", Divine = "เทวะ",
        Transcendent = "เหนือโลก", Titan = "ไททัน", LightDark = "แสงและเงา",
    },
    Mutation = {
        All = "ทุกสถานะ", Any = "กลายพันธุ์ใดก็ได้", None = "ปกติ", Silver = "เงิน",
        Golden = "ทอง", Rainbow = "สายรุ้ง", Monstrous = "ปรสิต", Boss = "บอสร้าว",
        Scrambled = "สแครมเบิล", Enchanted = "มนตรา", Nitro = "ไนโตร", Spectral = "วิญญาณ",
        Sakura = "ซากุระ", GreatBloom = "จิตวิญญาณผลิบาน", Musical = "ดนตรี", Alien = "เอเลี่ยน",
    },
    WordTokens = {
        All = "ทุกสายพันธุ์", Chicken = "ไก่ป่า", Dog = "สุนัขป่า", Fox = "จิ้งจอก", Bear = "หมี",
        Frog = "กบ", Duckling = "ลูกเป็ด", Catfish = "ปลาดุก", Turtle = "เต่า", Swan = "หงส์",
        Axolotl = "แอกโซลอเติล", Basilisk = "บาซิลิสก์", Jerboa = "หนูจิงโจ้", Camel = "อูฐ",
        Rattlesnake = "งูหางกระดิ่ง", Spider = "แมงมุม", Scorpion = "แมงป่อง", Chimpanzee = "ชิมแปนซี",
        Toucan = "นกทูแคน", Crocodile = "จระเข้", Gorilla = "กอริลลา", Tiger = "เสือโคร่ง",
        Warden = "ผู้พิทักษ์", Penguin = "เพนกวิน", Walrus = "วอลรัส", Mammoth = "แมมมอธ",
        Yeti = "เยติ", Dragon = "มังกร", Gecko = "ตุ๊กแก", Bull = "กระทิง", Iguana = "อิกัวนา",
        Cerberus = "เซอร์เบอรัส", Phoenix = "ฟีนิกซ์", Golem = "โกเลม", Shark = "ฉลาม",
        Squid = "หมึก", Kraken = "คราเคน", Leviathan = "เลวีอาธาน", Bunny = "กระต่าย",
        Deer = "กวาง", Spirit = "วิญญาณ", Unicorn = "ยูนิคอร์น", Slime = "สไลม์",
        Titan = "ไททัน", Giant = "ยักษ์", Hound = "สุนัขล่าเนื้อ", Scout = "สอดแนม",
        Overlord = "จอมทัพ", Boss = "บอส", Seraph = "เซราฟ", Fiend = "อสูร", Archon = "อาร์คอน",
        Ice = "น้ำแข็ง", Snow = "หิมะ", Polar = "ขั้วโลก", Lava = "ลาวา", Flame = "เพลิง",
        Flaming = "เพลิง", Ash = "เถ้าถ่าน", Magma = "แมกมา", Sakura = "ซากุระ", Blossom = "ผลิบาน",
        Petal = "กลีบดอกไม้", Moss = "มอส", Sylvan = "พงไพร", Star = "ดวงดาว", Nebula = "เนบิวลา",
        Void = "ความว่างเปล่า", Astral = "ดารา", Galactic = "กาแล็กซี", Cosmic = "คอสมิก",
        Alien = "เอเลี่ยน", Shadow = "เงามืด", Light = "แห่งแสง", Eternal = "นิรันดร์", Moon = "จันทรา",
        Ancient = "โบราณ", Colossal = "มหึมา", GiantSquid = "หมึกยักษ์", Raccoon = "แรคคูน",
    },
}
local function translateSpeciesToThai(rawId, displayName)
    if rawId == "All" then
        return THAI_LOCALE.WordTokens.All
    end
    local srcText = tostring(displayName or rawId or "")
    local direct = THAI_LOCALE.WordTokens[srcText] or THAI_LOCALE.WordTokens[tostring(rawId or "")]
    if direct then
        return direct
    end
    local expanded = srcText:gsub("(%l)(%u)", "%1 %2")
    local parts = {}
    for word in expanded:gmatch("[%a]+") do
        local mapped = THAI_LOCALE.WordTokens[word]
        if mapped then
            table.insert(parts, mapped)
        end
    end
    if #parts > 0 then
        return table.concat(parts, "")
    end
    return srcText
end
local AREA_LIST = { { id = "All", name = THAI_LOCALE.Area.All, order = 0 } }
local AREA_THAI_BY_ID = setmetatable({ All = THAI_LOCALE.Area.All }, {
    __index = function(self, k)
        local v = THAI_LOCALE.Area[k] or tostring(k or "")
        if type(k) == "string" and k ~= "" then
            rawset(self, k, v)
        end
        return v
    end,
})
local RARITY_LIST = { { id = "All", name = THAI_LOCALE.Rarity.All, rank = 0, color = Color3.fromRGB(255, 255, 255) } }
local RARITY_BY_ID = setmetatable({
    All = RARITY_LIST[1],
}, {
    __index = function(self, k)
        if type(k) ~= "string" or k == "" then
            return nil
        end
        local name = THAI_LOCALE.Rarity[k] or k
        local entry = {
            id = k,
            name = name,
            rank = 1,
            color = Color3.fromRGB(210, 210, 210),
        }
        rawset(self, k, entry)
        return entry
    end,
})
local MUTATION_LIST = {
    { id = "All", name = THAI_LOCALE.Mutation.All },
    { id = "Any", name = THAI_LOCALE.Mutation.Any },
    { id = "None", name = THAI_LOCALE.Mutation.None },
}
local MUTATION_THAI_BY_ID = setmetatable({
    All = THAI_LOCALE.Mutation.All,
    Any = THAI_LOCALE.Mutation.Any,
    None = THAI_LOCALE.Mutation.None,
}, {
    __index = function(self, k)
        local v = THAI_LOCALE.Mutation[k] or tostring(k or "")
        if type(k) == "string" and k ~= "" then
            rawset(self, k, v)
        end
        return v
    end,
})
local SPECIES_LIST = { { id = "All", name = THAI_LOCALE.WordTokens.All, order = 0 } }
local SPECIES_BY_ID = setmetatable({
    All = SPECIES_LIST[1],
}, {
    __index = function(self, k)
        if type(k) ~= "string" or k == "" then
            return nil
        end
        local entry = {
            id = k,
            name = translateSpeciesToThai(k, k),
            order = 999,
        }
        rawset(self, k, entry)
        return entry
    end,
})
local COLOR_PRESETS = {
    { name = "เขียวมรกต", color = Color3.fromRGB(16, 185, 129) },
    { name = "ฟ้าคราม", color = Color3.fromRGB(56, 189, 248) },
    { name = "ม่วงอเมทิสต์", color = Color3.fromRGB(168, 85, 247) },
    { name = "ชมพูซากุระ", color = Color3.fromRGB(244, 114, 182) },
    { name = "ทองคำ", color = Color3.fromRGB(250, 204, 21) },
    { name = "ส้มเพลิง", color = Color3.fromRGB(249, 115, 22) },
    { name = "แดงทับทิม", color = Color3.fromRGB(239, 68, 68) },
    { name = "ขาวบริสุทธิ์", color = Color3.fromRGB(248, 250, 252) },
}
local THEMES = {
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
        Success = Color3.fromRGB(52, 211, 153),
        Warning = Color3.fromRGB(251, 191, 36),
        Danger = Color3.fromRGB(248, 113, 113),
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
        Success = Color3.fromRGB(52, 211, 153),
        Warning = Color3.fromRGB(251, 191, 36),
        Danger = Color3.fromRGB(248, 113, 113),
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
        Success = Color3.fromRGB(52, 211, 153),
        Warning = Color3.fromRGB(251, 191, 36),
        Danger = Color3.fromRGB(248, 113, 113),
    },
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
        Success = Color3.fromRGB(52, 211, 153),
        Warning = Color3.fromRGB(251, 191, 36),
        Danger = Color3.fromRGB(248, 113, 113),
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
        Success = Color3.fromRGB(52, 211, 153),
        Warning = Color3.fromRGB(251, 191, 36),
        Danger = Color3.fromRGB(248, 113, 113),
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
        Success = Color3.fromRGB(16, 185, 129),
        Warning = Color3.fromRGB(217, 119, 6),
        Danger = Color3.fromRGB(220, 38, 38),
    },
}
local THAI_FONTS = {
    ["โกธิคทันสมัย"] = safeEnumFont("GothamMedium", Enum.Font.SourceSans),
    ["โกธิคหนา"] = safeEnumFont("GothamBold", Enum.Font.SourceSansBold),
    ["ซอร์สแซนส์"] = safeEnumFont("SourceSans", Enum.Font.SourceSans),
    ["ซอร์สแซนส์หนา"] = safeEnumFont("SourceSansBold", Enum.Font.SourceSansBold),
    ["อารีย์"] = safeEnumFont("Arial", Enum.Font.SourceSans),
}
local KEYCODE_THAI_NAMES = {
    ["RightControl"] = "คอนโทรลขวา",
    ["LeftControl"] = "คอนโทรลซ้าย",
    ["RightShift"] = "ชิฟต์ขวา",
    ["LeftShift"] = "ชิฟต์ซ้าย",
    ["Insert"] = "อินเสิร์ต",
    ["Home"] = "โฮม",
    ["End"] = "เอนด์",
    ["PageUp"] = "เพจอัป",
    ["PageDown"] = "เพจดาวน์",
    ["Delete"] = "ดีลีต",
    ["Tab"] = "แท็บ",
    ["F1"] = "เอฟ 1",
    ["F2"] = "เอฟ 2",
    ["F3"] = "เอฟ 3",
    ["F4"] = "เอฟ 4",
    ["F5"] = "เอฟ 5",
    ["F6"] = "เอฟ 6",
    ["F7"] = "เอฟ 7",
    ["F8"] = "เอฟ 8",
    ["F9"] = "เอฟ 9",
    ["F10"] = "เอฟ 10",
    ["F11"] = "เอฟ 11",
    ["F12"] = "เอฟ 12",
    ["One"] = "เลข 1",
    ["Two"] = "เลข 2",
    ["Three"] = "เลข 3",
    ["Four"] = "เลข 4",
    ["Five"] = "เลข 5",
    ["Six"] = "เลข 6",
    ["Seven"] = "เลข 7",
    ["Eight"] = "เลข 8",
    ["Nine"] = "เลข 9",
    ["Zero"] = "เลข 0",
    ["Q"] = "ปุ่ม คิว",
    ["E"] = "ปุ่ม อี",
    ["R"] = "ปุ่ม อาร์",
    ["T"] = "ปุ่ม ที",
    ["Y"] = "ปุ่ม วาย",
    ["U"] = "ปุ่ม ยู",
    ["I"] = "ปุ่ม ไอ",
    ["O"] = "ปุ่ม โอ",
    ["P"] = "ปุ่ม พี",
    ["F"] = "ปุ่ม เอฟ",
    ["G"] = "ปุ่ม จี",
    ["H"] = "ปุ่ม เอช",
    ["J"] = "ปุ่ม เจ",
    ["K"] = "ปุ่ม เค",
    ["L"] = "ปุ่ม แอล",
    ["Z"] = "ปุ่ม แซด",
    ["X"] = "ปุ่ม เอ็กซ์",
    ["C"] = "ปุ่ม ซี",
    ["V"] = "ปุ่ม วี",
    ["B"] = "ปุ่ม บี",
    ["N"] = "ปุ่ม เอ็น",
    ["M"] = "ปุ่ม เอ็ม",
}
local function getThaiKeyNameFromStr(codeName)
    if not codeName or codeName == "" then
        return "ไม่ได้ตั้ง"
    end
    if KEYCODE_THAI_NAMES[codeName] then
        return KEYCODE_THAI_NAMES[codeName]
    end
    return "ปุ่ม " .. tostring(codeName)
end
local STEAL_ORDER = {
    { id = "PriceHigh", name = "ราคาสูงสุด" },
    { id = "Rarity", name = "ความหายากสูงก่อน" },
    { id = "Weight", name = "น้ำหนักมากก่อน" },
    {
        id = "Mutation",
        name = "ตัวคูณกลายพันธุ์สูงก่อน",
    },
    { id = "IncomeHigh", name = "รายได้สูงก่อน" },
    { id = "IncomeLow", name = "รายได้ต่ำก่อน" },
}
local STEAL_GO_METHODS = {
    "เทเลพอร์ต",
    "ทวีนความเร็วสูง",
    "เดินตามเส้นทาง",
}
local STEAL_COLLECT_METHODS = {
    "พักส่งไข่เป็นจังหวะ",
    "ทวีนความเร็วสูง",
    "เทเลพอร์ต",
    "เดินถือไข่ปกติ",
}
local FARM_PRIORITY_ORDERS = {
    "ขโมยไข่ > วางไข่ > ลู่วิ่ง",
    "วางและฟักไข่ > ขโมยไข่ > ลู่วิ่ง",
    "ลู่วิ่ง > ขโมยไข่ > วางไข่",
    "ฟิวส์ชั่นและกลายพันธุ์ > ขโมยไข่ > วางไข่",
}
local SERVER_HOP_MODES = {
    "ผู้เล่นเยอะ",
    "ผู้เล่นน้อย",
    "ปิงต่ำ",
    "สุ่มเซิร์ฟเวอร์",
}
local PLACE_ORDER = {
    { id = "Large", name = "ไข่ขนาดใหญ่ก่อน" },
    { id = "Income", name = "รายได้สูงก่อน" },
    { id = "Small", name = "ไข่ขนาดเล็กก่อน" },
    { id = "Slot", name = "ตามช่องกระเป๋า" },
}
local FUN_PARTS = {
    { key = "FunHeadScale", name = "หัว", parts = { "Head" } },
    {
        key = "FunTorsoScale",
        name = "ลำตัว",
        parts = { "UpperTorso", "LowerTorso", "Torso" },
    },
    {
        key = "FunLeftArmScale",
        name = "แขนซ้าย",
        parts = { "LeftUpperArm", "LeftLowerArm", "LeftHand", "Left Arm" },
    },
    {
        key = "FunRightArmScale",
        name = "แขนขวา",
        parts = { "RightUpperArm", "RightLowerArm", "RightHand", "Right Arm" },
    },
    {
        key = "FunLeftLegScale",
        name = "ขาซ้าย",
        parts = { "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "Left Leg" },
    },
    {
        key = "FunRightLegScale",
        name = "ขาขวา",
        parts = { "RightUpperLeg", "RightLowerLeg", "RightFoot", "Right Leg" },
    },
}
local function createDefaultConfig()
    return {
        AutoStealEgg = false,
        StealGoMethod = "เทเลพอร์ต",
        DeliveryMethod = "พักส่งไข่เป็นจังหวะ",
        StealTeleportAreas = {},
        StealMutations = {},
        AutoChaseCarrier = false,
        StealDeliverySteps = 3,
        StealGoSpeedPercent = 115,
        StealCarrySpeedPercent = 150,
        StealOnlyMissingIndex = false,
        StealOnlyMissingLab = false,
        StealUseMinPrice = false,
        StealMinPrice = 0,
        StealMinBoostRarity = "Divine",
        StealUseMinBoost = false,
        StealMinBoostValue = 1,
        WarpToSafeZone = false,
        AutoMutation = false,
        MutationMinRarity = "All",
        AutoBuyTrail = false,
        AutoFusion = false,
        AutoShrineFusion = false,
        AutoFavorite = false,
        FavoriteMinRarity = "Mythic",
        FavoriteMutatedOnly = false,
        SwapFarmPriority = false,
        FarmPriorityOrder = "ขโมยไข่ > วางไข่ > ลู่วิ่ง",
        AutoPlaceEgg = false,
        PlaceEggRule = "วางทันทีเมื่อมีไข่",
        AutoHatchEgg = false,
        AutoCollectMoney = false,
        AutoUpgradeAll = false,
        AutoTreadmill = false,
        AutoAdminTreadmill = false,
        TreadmillRunSeconds = 20,
        TreadmillRestSeconds = 5,
        AutoEquipBest = false,
        AutoSellPet = false,
        SellMode = "ไม่ขายตัวที่ใส่",
        AutoClaimReward = false,
        AutoWispQuest = false,
        AutoGhostDogQuest = false,
        AutoSubZones = false,
        AutoBloom = false,
        AutoShootingStar = false,
        AutoFeedStar = false,
        AutoBanjo = false,
        AutoFishing = false,
        InstantFishCatch = false,
        AutoAlien = false,
        AutoIslandWars = false,
        AutoPetWheel = false,
        AutoRiftAndScramble = false,
        AutoAdminAbuse = false,
        AutoBeanstalk = false,
        AutoLightVsDark = false,
        AutoSammy = false,
        AutoBossRaid = false,
        AutoMinigameEvents = false,
        PlayerSpeedEnabled = false,
        PlayerWalkSpeed = 32,
        PlayerJumpEnabled = false,
        PlayerJumpPower = 65,
        InfiniteJump = false,
        Noclip = false,
        AutoPetMount = false,
        TeleportTargetArea = "All",
        AutoLoadScript = true,
        ServerHopMode = "ผู้เล่นเยอะ",
        TargetJobId = "",
        AutoRejoinOnDisconnect = true,
        AutoHopEnabled = false,
        AutoHopIntervalSeconds = 30,
        AutoHopOnDanger = false,
        StealOrder = "Rarity",
        StealAreas = {},
        StealRarities = {},
        StealSpecies = {},
        StealMinRarity = "All",
        StealMinIncome = 0,
        PlaceOrder = "Large",
        PlaceRarities = {},
        PlaceSpecies = {},
        PlaceMinIncome = 0,
        AutoAttack = false,
        AutoEquipBat = false,
        AttackMode = "ตีผู้เล่นที่เข้าใกล้",
        AttackTargetPlayer = "ทุกคนตามโหมดการตี",
        AntiTrap = false,
        AntiFall = false,
        AntiKnockback = false,
        AntiGuard = false,
        AntiAFK = false,
        HidePlayer = false,
        FunScaleEnabled = false,
        FunScaleMode = "ทั้งตัว",
        FunScale = 1,
        FunHeadScale = 1,
        FunTorsoScale = 1,
        FunLeftArmScale = 1,
        FunRightArmScale = 1,
        FunLeftLegScale = 1,
        FunRightLegScale = 1,
        FunSpin = false,
        FunSpinSpeed = 720,
        RevealEggContent100 = false,
        EggESP = false,
        OwnBaseEggESP = false,
        EggHighlightMode = "ตามสีความหายาก",
        EggESPColorName = "เขียวมรกต",
        EggTracker = false,
        EggShowName = true,
        EggShowRarity = true,
        EggShowMutation = true,
        EggShowIncome = true,
        EggShowValue = false,
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
        LostPartESP = false,
        LostPartTracker = false,
        PlayerESP = false,
        TrapESP = false,
        PlayerESPColorName = "ฟ้าคราม",
        PlayerShowName = true,
        PlayerTracker = false,
        PlayerShowDistance = true,
        PlayerShowSpeed = false,
        PlayerShowStatus = true,
        OptHideOtherPets = false,
        OptHideSelfPets = false,
        OptDisableTreadmillVideos = false,
        OptDisableParticles = false,
        OptDisableShadowsAndPostFX = false,
        OptSimplifyMaterials = false,
        OptHideWorldDecorations = false,
        OptMuteGameAudio = false,
        OptUnlockFPS = false,
        ThemeName = "ชมพูซากุระ",
        FontName = "โกธิคทันสมัย",
        FontSize = 14,
        GuiScalePercent = 100,
        BackgroundBlur = true,
        BackgroundTransparency = 8,
        KeybindsEnabled = true,
        Keybinds = {
            ToggleGUI = "RightControl",
            AutoStealEgg = "F1",
            AutoPlaceEgg = "F2",
            AutoHatchEgg = "F3",
            AutoUpgradeAll = "F4",
            AutoTreadmill = "F5",
            AutoEquipBest = "F6",
            AutoSellPet = "F7",
            AutoClaimReward = "F9",
            AutoWispQuest = "None",
            AutoBloom = "None",
            AutoShootingStar = "None",
            AutoFeedStar = "None",
            AutoBanjo = "None",
            AutoFishing = "None",
            InstantFishCatch = "None",
            AutoAlien = "None",
            AutoIslandWars = "None",
            AutoMutation = "None",
            AutoCollectMoney = "F8",
            AutoFavorite = "None",
            AutoAdminAbuse = "None",
            AutoBeanstalk = "None",
            AutoLightVsDark = "None",
            AutoSammy = "None",
            AutoBossRaid = "None",
            AutoMinigameEvents = "None",
            AutoGhostDogQuest = "None",
            AutoSubZones = "None",
            AutoPetWheel = "None",
            AutoRiftAndScramble = "None",
            AutoHopEnabled = "None",
            WarpToSafeZone = "None",
            InfiniteJump = "None",
            Noclip = "None",
            AutoBuyTrail = "F10",
            AutoFusion = "F11",
            AutoAttack = "R",
            AutoEquipBat = "G",
            AntiTrap = "T",
            AntiFall = "H",
            AntiKnockback = "J",
            TrapESP = "P",
            RevealEggContent100 = "U",
            EggESP = "I",
            PlayerESP = "O",
        },
    }
end
local NumericRules = {
    FunScale = { Min = 0.01, Max = 20 },
    FunSpinSpeed = { Min = 0 },
    TreadmillRunSeconds = { Min = 0.1 },
    TreadmillRestSeconds = { Min = 0.1 },
    StealDeliverySteps = { Min = 1, Max = 6 },
    StealGoSpeedPercent = { Min = 50, Max = 300 },
    StealCarrySpeedPercent = { Min = 50, Max = 300 },
    StealMinIncome = { Min = 0 },
    StealMinPrice = { Min = 0 },
    StealMinBoostValue = { Min = 0 },
    PlaceMinIncome = { Min = 0 },
    PlayerWalkSpeed = { Min = 16, Max = 350 },
    PlayerJumpPower = { Min = 20, Max = 350 },
    AutoHopIntervalSeconds = { Min = 5, Max = 3600 },
    EggESPSizePercent = { Min = 50, Max = 200 },
    FontSize = { Min = 1, Max = 100 },
    GuiScalePercent = { Min = 1, Max = 200 },
    BackgroundTransparency = { Min = 0 },
}
for _, part in ipairs(FUN_PARTS) do
    NumericRules[part.key] = NumericRules.FunScale
end
local function listLabel(list, id)
    for _, item in ipairs(list) do
        if item.id == id then
            return item.name
        end
    end
    return nil
end
local function normalizeNumber(key, value)
    if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
        return nil
    end
    local rule = NumericRules[key]
    if rule then
        value = math.max(rule.Min, value)
        if rule.Max then
            value = math.min(rule.Max, value)
        end
    end
    return value
end
local function applyProfileTableToConfig(sourceTable, destConfig)
    local defaults = createDefaultConfig()
    local choices = {
        StealGoMethod = STEAL_GO_METHODS,
        DeliveryMethod = STEAL_COLLECT_METHODS,
        FarmPriorityOrder = FARM_PRIORITY_ORDERS,
        ServerHopMode = SERVER_HOP_MODES,
        PlaceEggRule = { "วางทันทีเมื่อมีไข่", "วางเฉพาะหลังขโมยเสร็จ" },
        EggHighlightMode = { "ตามสีความหายาก", "ตามสีที่เลือก", "ปิดกรอบเรืองแสง" },
        FunScaleMode = { "ทั้งตัว", "แยกส่วน" },
        SellMode = {
            "ไม่ขายตัวที่ใส่",
            "ขายทุกตัว",
        },
        AttackMode = {
            "ตีผู้เล่นที่เข้าใกล้",
            "ไปตีผู้เล่นที่ถือไข่",
        },
    }
    local maps = {
        ESPFilterArea = AREA_THAI_BY_ID,
        ESPFilterSpecies = SPECIES_BY_ID,
        StealMinRarity = RARITY_BY_ID,
        ESPFilterRarity = RARITY_BY_ID,
        ESPFilterMutation = MUTATION_THAI_BY_ID,
        ThemeName = THEMES,
        FontName = THAI_FONTS,
    }
    sourceTable = type(sourceTable) == "table" and table.clone(sourceTable) or {}
    if sourceTable.DeliveryMethod == nil and sourceTable.NativeDeliveryMethod ~= nil then
        sourceTable.DeliveryMethod = sourceTable.NativeDeliveryMethod
    end
    if sourceTable.DeliveryMethod == "Delivery Stop" then
        sourceTable.DeliveryMethod = "พักส่งไข่เป็นจังหวะ"
    elseif sourceTable.DeliveryMethod == "Normal" then
        sourceTable.DeliveryMethod = "เดินถือไข่ปกติ"
    end
    if sourceTable.FontSize == nil and type(sourceTable.FontSizeOffset) == "number" then
        sourceTable.FontSize = 14 + sourceTable.FontSizeOffset
    end
    if sourceTable.StealAreas == nil and type(sourceTable.FilterArea) == "string" and sourceTable.FilterArea ~= "All" then
        sourceTable.StealAreas = { [sourceTable.FilterArea] = true }
    end
    if sourceTable.StealSpecies == nil and sourceTable.StealOnlySpecificEgg and type(sourceTable.SelectedSpecificEgg) == "string" then
        sourceTable.StealSpecies = { [sourceTable.SelectedSpecificEgg] = true }
    end
    if sourceTable.StealMinRarity == nil then
        sourceTable.StealMinRarity = sourceTable.FilterMinRarityId
    end
    if sourceTable.FunSpin == nil then
        sourceTable.FunSpin = sourceTable.FunBodySpin
    end
    if sourceTable.FunSpinSpeed == nil then
        sourceTable.FunSpinSpeed = sourceTable.FunBodySpeed
    end
    for key, default in pairs(defaults) do
        local incoming = sourceTable[key]
        if key == "Keybinds" then
            local merged, used, keys = {}, {}, { "ToggleGUI" }
            for id in pairs(default) do
                if id ~= "ToggleGUI" then
                    table.insert(keys, id)
                end
            end
            table.sort(keys, function(x, y)
                if x == y then
                    return false
                elseif x == "ToggleGUI" then
                    return true
                elseif y == "ToggleGUI" then
                    return false
                end
                return x < y
            end)
            for _, id in ipairs(keys) do
                local name = type(incoming) == "table" and incoming[id] or default[id]
                if name == nil then
                    name = default[id]
                end
                if type(name) ~= "string" or (#name > 0 and not safeKeyCode(name)) then
                    name = default[id]
                end
                if name ~= "" and used[name] then
                    name = ""
                end
                merged[id] = name
                if name ~= "" then
                    used[name] = true
                end
            end
            destConfig[key] = merged
        elseif type(default) == "table" then
            local selected = {}
            if type(incoming) == "table" then
                for id, enabled in pairs(incoming) do
                    if type(id) == "string" and id ~= "All" and enabled == true then
                        selected[id] = true
                    end
                end
            end
            destConfig[key] = selected
        elseif type(incoming) ~= type(default) then
            destConfig[key] = default
        elseif type(default) == "number" then
            destConfig[key] = normalizeNumber(key, incoming) or default
        else
            if maps[key] and not maps[key][incoming] then
                incoming = default
            end
            if choices[key] and not table.find(choices[key], incoming) then
                incoming = default
            end
            if key == "EggESPColorName" or key == "PlayerESPColorName" then
                local found = false
                for _, entry in ipairs(COLOR_PRESETS) do
                    if entry.name == incoming then
                        found = true
                    end
                end
                if not found then
                    incoming = default
                end
            end
            destConfig[key] = incoming
        end
    end
    if not listLabel(STEAL_ORDER, destConfig.StealOrder) then
        destConfig.StealOrder = defaults.StealOrder
    end
    if not listLabel(PLACE_ORDER, destConfig.PlaceOrder) then
        destConfig.PlaceOrder = defaults.PlaceOrder
    end
end
local Config = createDefaultConfig()
local ProfilesStore = { ["ค่าเริ่มต้น"] = createDefaultConfig() }
local CurrentProfileName = "ค่าเริ่มต้น"
local PROFILE_FOLDER = "ThaiCleanHub_Profiles"
local PROFILE_FILE = PROFILE_FOLDER .. "/profiles_v5.json"
local PREVIOUS_PROFILE_FILE = PROFILE_FOLDER .. "/profiles_v4.json"
local OLDER_PROFILE_FILE = PROFILE_FOLDER .. "/profiles_v3.json"
local LEGACY_PROFILE_FILE = PROFILE_FOLDER .. "/profiles_v2.json"
local function saveProfilesToDisk()
    if type(writefile) ~= "function" then
        return false, "บันทึกได้เฉพาะรอบนี้: สภาพแวดล้อมไม่รองรับไฟล์"
    end
    local ok, err = pcall(function()
        if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder(PROFILE_FOLDER) then
            makefolder(PROFILE_FOLDER)
        end
        writefile(PROFILE_FILE, HttpService:JSONEncode({ Current = CurrentProfileName, Profiles = ProfilesStore }))
    end)
    if ok then
        return true, nil
    end
    return false, tostring(err)
end
local ProfileLoadWarning = nil
local function loadProfilesFromDisk()
    local ok, err = pcall(function()
        local path = type(isfile) == "function" and isfile(PROFILE_FILE) and PROFILE_FILE or (type(isfile) == "function" and isfile(PREVIOUS_PROFILE_FILE) and PREVIOUS_PROFILE_FILE or (type(isfile) == "function" and isfile(OLDER_PROFILE_FILE) and OLDER_PROFILE_FILE or LEGACY_PROFILE_FILE))
        if type(readfile) == "function" and type(isfile) == "function" and isfile(path) then
            local raw = readfile(path)
            local decoded = HttpService:JSONDecode(raw)
            if type(decoded) ~= "table" or type(decoded.Profiles) ~= "table" then
                error("รูปแบบโปรไฟล์ไม่ถูกต้อง")
            end
            if type(decoded) == "table" and type(decoded.Profiles) == "table" then
                for k, v in pairs(decoded.Profiles) do
                    local legacyPreset = path == LEGACY_PROFILE_FILE and (k == "โปรไฟล์ 1" or k == "โปรไฟล์ 2" or k == "สายฟาร์มไข่หายาก" or k == "สายสะสมสมุดและแล็ป")
                    if type(k) == "string" and type(v) == "table" and not legacyPreset then
                        local cleanProf = createDefaultConfig()
                        applyProfileTableToConfig(v, cleanProf)
                        ProfilesStore[k] = cleanProf
                    end
                end
                if type(decoded.Current) == "string" and ProfilesStore[decoded.Current] then
                    CurrentProfileName = decoded.Current
                    applyProfileTableToConfig(ProfilesStore[CurrentProfileName], Config)
                else
                    applyProfileTableToConfig(ProfilesStore["ค่าเริ่มต้น"], Config)
                end
            end
        end
    end)
    if not ok then
        ProfileLoadWarning = tostring(err)
    end
end
loadProfilesFromDisk()
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ThaiCleanEggHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
if not mountScreenGui(ScreenGui) then
    ScreenGui:Destroy()
    error("ติดตั้ง UI ไม่สำเร็จ: ไม่พบพื้นที่แสดงเมนู")
end
local RenderLayer = Instance.new("Frame")
RenderLayer.Name = "RenderLayer"
RenderLayer.Size = UDim2.fromScale(1, 1)
RenderLayer.BackgroundTransparency = 1
RenderLayer.Active = false
RenderLayer.ZIndex = 1
RenderLayer.Parent = ScreenGui
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESPFolder"
ESPFolder.Parent = ScreenGui
local BlurEffect = nil
pcall(function()
    local oldBlur = Lighting:FindFirstChild("ThaiCleanHubBlur")
    if oldBlur then
        oldBlur:Destroy()
    end
    local b = Instance.new("BlurEffect")
    b.Name = "ThaiCleanHubBlur"
    b.Size = 14
    b.Enabled = Config.BackgroundBlur
    b.Parent = Lighting
    BlurEffect = b
end)
local ThemeRegistry = {}
local TextRegistry = {}
local function registerTheme(inst, prop, role)
    table.insert(ThemeRegistry, { Instance = inst, Property = prop, Role = role })
end
local function registerText(inst, baseSize, isBold)
    table.insert(TextRegistry, { Instance = inst, BaseSize = baseSize, IsBold = isBold })
end
local function getCurrentTheme()
    return THEMES[Config.ThemeName] or THEMES["ชมพูซากุระ"]
end
local function getCurrentFont()
    return THAI_FONTS[Config.FontName] or Enum.Font.SourceSans
end
local ToastContainer = Instance.new("Frame")
ToastContainer.Name = "ToastContainer"
ToastContainer.AnchorPoint = Vector2.new(1, 1)
ToastContainer.Position = UDim2.new(1, -20, 1, -20)
ToastContainer.Size = UDim2.fromOffset(290, 220)
ToastContainer.BackgroundTransparency = 1
ToastContainer.ZIndex = 50
ToastContainer.Parent = ScreenGui
local ToastLayout = Instance.new("UIListLayout")
ToastLayout.SortOrder = Enum.SortOrder.LayoutOrder
ToastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
ToastLayout.Padding = UDim.new(0, 8)
ToastLayout.Parent = ToastContainer
local function notifyThai(message)
    if isNoRewardMessage(message) then
        return
    end
    pcall(function()
        local theme = getCurrentTheme()
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 42)
        card.BackgroundColor3 = theme.Card
        card.BackgroundTransparency = 0.05
        card.BorderSizePixel = 0
        card.ZIndex = 51
        card.Parent = ToastContainer
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = card
        local stroke = Instance.new("UIStroke")
        stroke.Color = theme.Accent
        stroke.Thickness = 1.2
        stroke.Parent = card
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 4, 1, -12)
        bar.Position = UDim2.fromOffset(8, 6)
        bar.BackgroundColor3 = theme.Accent
        bar.BorderSizePixel = 0
        bar.ZIndex = 52
        bar.Parent = card
        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(1, 0)
        barCorner.Parent = bar
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -26, 1, 0)
        lbl.Position = UDim2.fromOffset(20, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = getCurrentFont()
        lbl.TextSize = 14 * Config.FontSize / 14
        lbl.TextColor3 = theme.Text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextWrapped = true
        lbl.Text = message
        lbl.ZIndex = 52
        lbl.Parent = card
        task.delay(2.3, function()
            if card and card.Parent then
                local tw = TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 })
                TweenService:Create(lbl, TweenInfo.new(0.25), { TextTransparency = 1 }):Play()
                TweenService:Create(stroke, TweenInfo.new(0.25), { Transparency = 1 }):Play()
                tw:Play()
                tw.Completed:Wait()
                if card then
                    card:Destroy()
                end
            end
        end)
    end)
end
local CircleOverlay = Instance.new("TextButton")
CircleOverlay.Name = "CircleOverlayButton"
CircleOverlay.AnchorPoint = Vector2.new(0.5, 0.5)
CircleOverlay.Position = UDim2.new(0, 72, 0.5, 0)
CircleOverlay.Size = UDim2.fromOffset(62, 62)
CircleOverlay.BackgroundColor3 = getCurrentTheme().Bg
CircleOverlay.BackgroundTransparency = 0.05
CircleOverlay.Text = ""
CircleOverlay.AutoButtonColor = false
CircleOverlay.Visible = false
CircleOverlay.ZIndex = 40
CircleOverlay.Parent = ScreenGui
registerTheme(CircleOverlay, "BackgroundColor3", "Bg")
do
    do
        local CircleCorner = Instance.new("UICorner")
        CircleCorner.CornerRadius = UDim.new(1, 0)
        CircleCorner.Parent = CircleOverlay
        local CircleStroke = Instance.new("UIStroke")
        CircleStroke.Color = getCurrentTheme().Accent
        CircleStroke.Thickness = 2.5
        CircleStroke.Parent = CircleOverlay
        registerTheme(CircleStroke, "Color", "Accent")
        local CircleInnerRing = Instance.new("Frame")
        CircleInnerRing.AnchorPoint = Vector2.new(0.5, 0.5)
        CircleInnerRing.Position = UDim2.fromScale(0.5, 0.5)
        CircleInnerRing.Size = UDim2.fromOffset(50, 50)
        CircleInnerRing.BackgroundColor3 = getCurrentTheme().Card
        CircleInnerRing.BorderSizePixel = 0
        CircleInnerRing.Active = false
        CircleInnerRing.ZIndex = 41
        CircleInnerRing.Parent = CircleOverlay
        registerTheme(CircleInnerRing, "BackgroundColor3", "Card")
        local CircleInnerCorner = Instance.new("UICorner")
        CircleInnerCorner.CornerRadius = UDim.new(1, 0)
        CircleInnerCorner.Parent = CircleInnerRing
        local CircleTitle = Instance.new("TextLabel")
        CircleTitle.Size = UDim2.fromScale(1, 1)
        CircleTitle.BackgroundTransparency = 1
        CircleTitle.Font = getCurrentFont()
        CircleTitle.TextSize = 13
        CircleTitle.TextColor3 = getCurrentTheme().Text
        CircleTitle.Text = "เปิดเมนู"
        CircleTitle.Active = false
        CircleTitle.ZIndex = 42
        CircleTitle.Parent = CircleInnerRing
        registerTheme(CircleTitle, "TextColor3", "Text")
        registerText(CircleTitle, 13, true)
    end
end
local MainWindow = Instance.new("Frame")
local MainScale
local ActiveProfileBadge
local IsWindowOpen = true
local setWindowOpen
local Sidebar
local StatusBanner
local StatusDot
local StatusBannerLabel
local ContentContainer
local SearchInputBox
do
    MainWindow.Name = "MainWindow"
    MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
    MainWindow.Position = UDim2.fromScale(0.5, 0.5)
    MainWindow.Size = UDim2.fromOffset(740, 460)
    MainWindow.BackgroundColor3 = getCurrentTheme().Bg
    MainWindow.BackgroundTransparency = math.clamp(Config.BackgroundTransparency / 100, 0, 1)
    MainWindow.BorderSizePixel = 0
    MainWindow.ZIndex = 10
    MainWindow.Parent = ScreenGui
    registerTheme(MainWindow, "BackgroundColor3", "Bg")
    MainScale = Instance.new("UIScale")
    MainScale.Scale = Config.GuiScalePercent / 100
    MainScale.Parent = MainWindow
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 14)
    MainCorner.Parent = MainWindow
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = getCurrentTheme().Border
    MainStroke.Thickness = 1.5
    MainStroke.Parent = MainWindow
    registerTheme(MainStroke, "Color", "Border")
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Active = true
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundColor3 = getCurrentTheme().Sidebar
    TopBar.BackgroundTransparency = 0.05
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 11
    TopBar.Parent = MainWindow
    registerTheme(TopBar, "BackgroundColor3", "Sidebar")
    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 14)
    TopBarCorner.Parent = TopBar
    local TopBarBottomCover = Instance.new("Frame")
    TopBarBottomCover.Size = UDim2.new(1, 0, 0, 14)
    TopBarBottomCover.Position = UDim2.new(0, 0, 1, -14)
    TopBarBottomCover.BackgroundColor3 = getCurrentTheme().Sidebar
    TopBarBottomCover.BackgroundTransparency = 0.05
    TopBarBottomCover.BorderSizePixel = 0
    TopBarBottomCover.ZIndex = 11
    TopBarBottomCover.Parent = TopBar
    registerTheme(TopBarBottomCover, "BackgroundColor3", "Sidebar")
    local AccentDot = Instance.new("Frame")
    AccentDot.AnchorPoint = Vector2.new(0, 0.5)
    AccentDot.Position = UDim2.new(0, 18, 0.5, 0)
    AccentDot.Size = UDim2.fromOffset(10, 10)
    AccentDot.BackgroundColor3 = getCurrentTheme().Accent
    AccentDot.BorderSizePixel = 0
    AccentDot.ZIndex = 12
    AccentDot.Parent = TopBar
    registerTheme(AccentDot, "BackgroundColor3", "Accent")
    local AccentDotCorner = Instance.new("UICorner")
    AccentDotCorner.CornerRadius = UDim.new(1, 0)
    AccentDotCorner.Parent = AccentDot
    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Position = UDim2.fromOffset(38, 0)
    HeaderTitle.Size = UDim2.new(0.52, 0, 1, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Font = getCurrentFont()
    HeaderTitle.TextSize = 17
    HeaderTitle.TextColor3 = getCurrentTheme().Text
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.Text = "ศูนย์ควบคุมระบบอัตโนมัติ"
    HeaderTitle.ZIndex = 12
    HeaderTitle.Parent = TopBar
    registerTheme(HeaderTitle, "TextColor3", "Text")
    registerText(HeaderTitle, 17, true)
    ActiveProfileBadge = Instance.new("TextLabel")
    ActiveProfileBadge.AnchorPoint = Vector2.new(1, 0.5)
    ActiveProfileBadge.Position = UDim2.new(1, -110, 0.5, 0)
    ActiveProfileBadge.Size = UDim2.fromOffset(185, 26)
    ActiveProfileBadge.BackgroundColor3 = getCurrentTheme().Card
    ActiveProfileBadge.Font = getCurrentFont()
    ActiveProfileBadge.TextSize = 13
    ActiveProfileBadge.TextColor3 = getCurrentTheme().SubText
    ActiveProfileBadge.Text = "โปรไฟล์: " .. CurrentProfileName
    ActiveProfileBadge.ZIndex = 12
    ActiveProfileBadge.Parent = TopBar
    registerTheme(ActiveProfileBadge, "BackgroundColor3", "Card")
    registerTheme(ActiveProfileBadge, "TextColor3", "SubText")
    registerText(ActiveProfileBadge, 13, false)
    local BadgeCorner = Instance.new("UICorner")
    BadgeCorner.CornerRadius = UDim.new(0, 8)
    BadgeCorner.Parent = ActiveProfileBadge
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseWindowButton"
    CloseButton.AnchorPoint = Vector2.new(1, 0.5)
    CloseButton.Position = UDim2.new(1, -14, 0.5, 0)
    CloseButton.Size = UDim2.fromOffset(84, 30)
    CloseButton.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
    CloseButton.Text = "ปิดหน้าต่าง"
    CloseButton.Font = getCurrentFont()
    CloseButton.TextSize = 13
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.AutoButtonColor = false
    CloseButton.ZIndex = 14
    CloseButton.Parent = TopBar
    registerText(CloseButton, 13, true)
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton
    IsWindowOpen = true
    local LastWindowToggleClock = -math.huge
    setWindowOpen = function(state)
        local now = os.clock()
        if IsWindowOpen == state then
            return
        end
        LastWindowToggleClock = now
        IsWindowOpen = state
        if state then
            CircleOverlay.Visible = false
            MainWindow.Visible = true
            if BlurEffect then
                BlurEffect.Enabled = Config.BackgroundBlur
            end
            MainScale.Scale = Config.GuiScalePercent / 100
        else
            if BlurEffect then
                BlurEffect.Enabled = false
            end
            MainWindow.Visible = false
            CircleOverlay.Visible = true
        end
    end
    bindClick(CloseButton, function()
        setWindowOpen(false)
    end)
    do
        local dragging = false
        local dragStart = nil
        local startPos = nil
        connectSignal(TopBar.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local cp = CloseButton.AbsolutePosition
                local cs = CloseButton.AbsoluteSize
                if input.Position.X >= cp.X - 6 and input.Position.X <= cp.X + cs.X + 6 and input.Position.Y >= cp.Y - 6 and input.Position.Y <= cp.Y + cs.Y + 6 then
                    return
                end
                dragging = true
                dragStart = input.Position
                startPos = MainWindow.Position
            end
        end)
        connectSignal(UserInputService.InputChanged, function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                MainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        connectSignal(UserInputService.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end
    do
        local dragging = false
        local dragStart = nil
        local startPos = nil
        local moved = false
        connectSignal(CircleOverlay.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                moved = false
                dragStart = input.Position
                startPos = CircleOverlay.Position
            end
        end)
        connectSignal(UserInputService.InputChanged, function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                if delta.Magnitude > 8 then
                    moved = true
                end
                CircleOverlay.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        connectSignal(UserInputService.InputEnded, function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                dragging = false
                if not moved then
                    setWindowOpen(true)
                end
            end
        end)
        connectSignal(CircleOverlay.MouseButton1Click, function()
            if not moved then
                setWindowOpen(true)
            end
        end)
    end
    Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Position = UDim2.fromOffset(0, 50)
    Sidebar.Size = UDim2.new(0, 175, 1, -50)
    Sidebar.BackgroundColor3 = getCurrentTheme().Sidebar
    Sidebar.BackgroundTransparency = 0.05
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex = 11
    Sidebar.Parent = MainWindow
    registerTheme(Sidebar, "BackgroundColor3", "Sidebar")
    StatusBanner = Instance.new("Frame")
    do
        do
            local SidebarCorner = Instance.new("UICorner")
            SidebarCorner.CornerRadius = UDim.new(0, 14)
            SidebarCorner.Parent = Sidebar
            local SidebarPadding = Instance.new("UIPadding")
            SidebarPadding.PaddingTop = UDim.new(0, 12)
            SidebarPadding.PaddingLeft = UDim.new(0, 10)
            SidebarPadding.PaddingRight = UDim.new(0, 10)
            SidebarPadding.PaddingBottom = UDim.new(0, 12)
            SidebarPadding.Parent = Sidebar
            local SidebarLayout = Instance.new("UIListLayout")
            SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SidebarLayout.Padding = UDim.new(0, 6)
            SidebarLayout.Parent = Sidebar
            StatusBanner.Name = "StatusBanner"
            StatusBanner.Position = UDim2.fromOffset(185, 54)
            StatusBanner.Size = UDim2.new(1, -195, 0, 48)
            StatusBanner.BackgroundColor3 = getCurrentTheme().Card
            StatusBanner.BackgroundTransparency = 0.1
            StatusBanner.BorderSizePixel = 0
            StatusBanner.ZIndex = 12
            StatusBanner.Parent = MainWindow
            registerTheme(StatusBanner, "BackgroundColor3", "Card")
            local StatusBannerCorner = Instance.new("UICorner")
            StatusBannerCorner.CornerRadius = UDim.new(0, 8)
            StatusBannerCorner.Parent = StatusBanner
            local StatusBannerStroke = Instance.new("UIStroke")
            StatusBannerStroke.Color = getCurrentTheme().Border
            StatusBannerStroke.Thickness = 1
            StatusBannerStroke.Parent = StatusBanner
            registerTheme(StatusBannerStroke, "Color", "Border")
        end
        StatusDot = Instance.new("Frame")
        StatusDot.Name = "StatusDot"
        StatusDot.AnchorPoint = Vector2.new(0, 0.5)
        StatusDot.Position = UDim2.new(0, 10, 0.5, 0)
        StatusDot.Size = UDim2.fromOffset(8, 8)
        StatusDot.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
        StatusDot.BorderSizePixel = 0
        StatusDot.ZIndex = 13
        StatusDot.Parent = StatusBanner
        local StatusDotCorner = Instance.new("UICorner")
        StatusDotCorner.CornerRadius = UDim.new(1, 0)
        StatusDotCorner.Parent = StatusDot
        StatusBannerLabel = Instance.new("TextLabel")
        StatusBannerLabel.Name = "StatusBannerLabel"
        StatusBannerLabel.Position = UDim2.fromOffset(24, 0)
        StatusBannerLabel.Size = UDim2.new(1, -32, 1, 0)
        StatusBannerLabel.BackgroundTransparency = 1
        StatusBannerLabel.Font = getCurrentFont()
        StatusBannerLabel.TextSize = 12
        StatusBannerLabel.TextColor3 = getCurrentTheme().Text
        StatusBannerLabel.TextXAlignment = Enum.TextXAlignment.Left
        StatusBannerLabel.TextWrapped = true
        StatusBannerLabel.Text = "สถานะระบบ: พร้อมทำงาน • ไม่มีความขัดแย้งของฟังก์ชัน"
        StatusBannerLabel.ZIndex = 13
        StatusBannerLabel.Parent = StatusBanner
        registerTheme(StatusBannerLabel, "TextColor3", "Text")
        registerText(StatusBannerLabel, 12, false)
    end
    local SearchBarFrame = Instance.new("Frame")
    SearchBarFrame.Name = "SearchBarFrame"
    SearchBarFrame.Position = UDim2.fromOffset(185, 106)
    SearchBarFrame.Size = UDim2.new(1, -195, 0, 30)
    SearchBarFrame.BackgroundColor3 = getCurrentTheme().Card
    SearchBarFrame.BackgroundTransparency = 0.1
    SearchBarFrame.BorderSizePixel = 0
    SearchBarFrame.ZIndex = 12
    SearchBarFrame.Parent = MainWindow
    registerTheme(SearchBarFrame, "BackgroundColor3", "Card")
    local SearchBarCorner = Instance.new("UICorner")
    SearchBarCorner.CornerRadius = UDim.new(0, 8)
    SearchBarCorner.Parent = SearchBarFrame
    local SearchBarStroke = Instance.new("UIStroke")
    SearchBarStroke.Color = getCurrentTheme().Border
    SearchBarStroke.Thickness = 1
    SearchBarStroke.Parent = SearchBarFrame
    registerTheme(SearchBarStroke, "Color", "Border")
    local SearchBarLabel = Instance.new("TextLabel")
    SearchBarLabel.Position = UDim2.fromOffset(10, 0)
    SearchBarLabel.Size = UDim2.fromOffset(48, 30)
    SearchBarLabel.BackgroundTransparency = 1
    SearchBarLabel.Font = getCurrentFont()
    SearchBarLabel.TextSize = 12
    SearchBarLabel.TextColor3 = getCurrentTheme().Accent
    SearchBarLabel.TextXAlignment = Enum.TextXAlignment.Left
    SearchBarLabel.Text = "ค้นหา:"
    SearchBarLabel.ZIndex = 13
    SearchBarLabel.Parent = SearchBarFrame
    registerTheme(SearchBarLabel, "TextColor3", "Accent")
    registerText(SearchBarLabel, 12, true)
    SearchInputBox = Instance.new("TextBox")
    SearchInputBox.Name = "SearchInputBox"
    SearchInputBox.Position = UDim2.fromOffset(60, 2)
    SearchInputBox.Size = UDim2.new(1, -70, 1, -4)
    SearchInputBox.BackgroundTransparency = 1
    SearchInputBox.ClearTextOnFocus = false
    SearchInputBox.Font = getCurrentFont()
    SearchInputBox.TextSize = 12
    SearchInputBox.TextColor3 = getCurrentTheme().Text
    SearchInputBox.PlaceholderColor3 = getCurrentTheme().SubText
    SearchInputBox.PlaceholderText = "ค้นหาฟีเจอร์..."
    SearchInputBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchInputBox.Text = ""
    SearchInputBox.ZIndex = 13
    SearchInputBox.Parent = SearchBarFrame
    registerTheme(SearchInputBox, "TextColor3", "Text")
    registerTheme(SearchInputBox, "PlaceholderColor3", "SubText")
    registerText(SearchInputBox, 12, false)
    ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Position = UDim2.fromOffset(185, 140)
    ContentContainer.Size = UDim2.new(1, -195, 1, -150)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ZIndex = 11
    ContentContainer.Parent = MainWindow
end
local refreshControls
local Pages = {}
local TabButtons = {}
local CurrentTabName = nil
local function selectTab(tabName)
    CurrentTabName = tabName
    local theme = getCurrentTheme()
    for name, page in pairs(Pages) do
        page.Visible = (name == tabName)
    end
    for name, btnInfo in pairs(TabButtons) do
        local isSelected = (name == tabName)
        btnInfo.Button.BackgroundColor3 = isSelected and theme.Accent or theme.Card
        btnInfo.Button.BackgroundTransparency = isSelected and 0.1 or 0.4
        btnInfo.Indicator.Visible = isSelected
        btnInfo.Label.TextColor3 = isSelected and theme.Text or theme.SubText
    end
end
local function createTabPage(tabName, order)
    local btn = Instance.new("TextButton")
    btn.Name = "Tab_" .. tabName
    btn.LayoutOrder = order
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = getCurrentTheme().Card
    btn.BackgroundTransparency = 0.4
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 12
    btn.Parent = Sidebar
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = btn
    local ind = Instance.new("Frame")
    ind.AnchorPoint = Vector2.new(0, 0.5)
    ind.Position = UDim2.new(0, 6, 0.5, 0)
    ind.Size = UDim2.fromOffset(4, 20)
    ind.BackgroundColor3 = getCurrentTheme().Text
    ind.BorderSizePixel = 0
    ind.Visible = false
    ind.Active = false
    ind.ZIndex = 13
    ind.Parent = btn
    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = ind
    local lbl = Instance.new("TextLabel")
    lbl.Position = UDim2.fromOffset(18, 0)
    lbl.Size = UDim2.new(1, -24, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = getCurrentFont()
    lbl.TextSize = 15
    lbl.TextColor3 = getCurrentTheme().SubText
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = tabName
    lbl.Active = false
    lbl.ZIndex = 13
    lbl.Parent = btn
    registerText(lbl, 15, true)
    local page = Instance.new("ScrollingFrame")
    page.Name = "Page_" .. tabName
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = getCurrentTheme().Accent
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.ZIndex = 12
    page.Parent = ContentContainer
    registerTheme(page, "ScrollBarImageColor3", "Accent")
    local pagePadding = Instance.new("UIPadding")
    pagePadding.PaddingTop = UDim.new(0, 4)
    pagePadding.PaddingLeft = UDim.new(0, 4)
    pagePadding.PaddingRight = UDim.new(0, 10)
    pagePadding.PaddingBottom = UDim.new(0, 16)
    pagePadding.Parent = page
    local pageLayout = Instance.new("UIListLayout")
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 10)
    pageLayout.Parent = page
    TabButtons[tabName] = { Button = btn, Indicator = ind, Label = lbl }
    Pages[tabName] = page
    bindClick(btn, function()
        selectTab(tabName)
        if refreshControls then
            refreshControls()
        end
    end)
    return page
end
local Remotes = nil
local Save = nil
local Preferences = nil
local EggRecords = nil
local AssetItems = nil
local AreaEggSlotIdentity = nil
local EggState = nil
local PlotState = nil
local BaseUpgrade = nil
local AssetsData = nil
local TreadmillsData = nil
local RuntimeState = {
    CurrentTaskStatusText = "พร้อมทำงาน",
    IsCurrentlyOnTreadmill = false,
    IsCurrentlyPlacingEgg = false,
    IsCurrentlyChasingCarrier = false,
    LastStealPickupAttemptAt = 0,
    LastEquipBestExecutedAt = 0,
    SavedEggPulses = {},
    SavedSoundVolumes = {},
}
local ToggleConflictBadges = {}
local ModifiedEggToolNames = {}
local function getDirectRemote(prefix, namespace, name)
    local pkgs = ReplicatedStorage:FindFirstChild("Packages")
    local net = pkgs and pkgs:FindFirstChild("Networking")
    if net then
        local target = net:FindFirstChild(prefix .. "/" .. namespace .. "/" .. name)
        if target then
            return target
        end
    end
    return nil
end
local function getLocalRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart") or nil
end
local function getLocalHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid") or nil
end
local EggESPVisuals = {}
local PlayerESPVisuals = {}
local GuardESPVisuals = {}
local LostPartESPVisuals = {}
local ModifiedPrompts = {}
local function clearEggESP(uid)
    local entry = EggESPVisuals[uid]
    if not entry then
        return
    end
    if entry.Billboard then
        pcall(function()
            entry.Billboard:Destroy()
        end)
    end
    if entry.Highlight then
        pcall(function()
            entry.Highlight:Destroy()
        end)
    end
    if entry.Line then
        pcall(function()
            entry.Line:Destroy()
        end)
    end
    if entry.AnchorPart then
        pcall(function()
            entry.AnchorPart:Destroy()
        end)
    end
    EggESPVisuals[uid] = nil
end
local function clearAllEggESP()
    for uid in pairs(EggESPVisuals) do
        clearEggESP(uid)
    end
end
local function clearPlayerESP(plr)
    local entry = PlayerESPVisuals[plr]
    if not entry then
        return
    end
    if entry.Billboard then
        entry.Billboard:Destroy()
    end
    if entry.Highlight then
        entry.Highlight:Destroy()
    end
    if entry.Line then
        entry.Line:Destroy()
    end
    PlayerESPVisuals[plr] = nil
end
local function clearAllPlayerESP()
    for plr in pairs(PlayerESPVisuals) do
        clearPlayerESP(plr)
    end
end
local function clearGuardESP(guard)
    local entry = GuardESPVisuals[guard]
    if not entry then
        return
    end
    if entry.Billboard then
        pcall(function()
            entry.Billboard:Destroy()
        end)
    end
    if entry.Highlight then
        pcall(function()
            entry.Highlight:Destroy()
        end)
    end
    if entry.Line then
        pcall(function()
            entry.Line:Destroy()
        end)
    end
    GuardESPVisuals[guard] = nil
end
local function clearAllGuardESP()
    for guard in pairs(GuardESPVisuals) do
        clearGuardESP(guard)
    end
end
local function clearLostPartESP(partObj)
    local entry = LostPartESPVisuals[partObj]
    if not entry then
        return
    end
    if entry.Billboard then
        pcall(function()
            entry.Billboard:Destroy()
        end)
    end
    if entry.Highlight then
        pcall(function()
            entry.Highlight:Destroy()
        end)
    end
    if entry.Line then
        pcall(function()
            entry.Line:Destroy()
        end)
    end
    LostPartESPVisuals[partObj] = nil
end
local function clearAllLostPartESP()
    for partObj in pairs(LostPartESPVisuals) do
        clearLostPartESP(partObj)
    end
end
local Hub = {
    Status = {},
    Generation = {},
    Jobs = {},
    NextRun = {},
    InFlight = {},
    LastRequest = {},
    Modules = {},
    Effects = {},
    PreferenceOriginal = {},
    PreferenceApplied = {},
    PreferenceBusy = false,
    PreferenceBusyKey = nil,
    PreferenceLastWanted = {},
    PreferenceNextAttempt = {},
    MovementOwner = nil,
    InventoryOwner = nil,
    EquipRevision = 0,
    BestSignature = nil,
    StealPins = {},
    StealQueueOrder = {},
    StealSkippedUids = {},
    StealForceUid = nil,
    StealCurrentStep = 0,
    StealTargetUid = nil,
    StealRetryUid = nil,
    StealRetryAt = 0,
    StealPickupUntil = 0,
    StealEntry = nil,
    FieldRecords = {},
    FieldFetchedAt = -math.huge,
    FieldBusy = false,
    FieldResetting = false,
    FieldClosesAt = nil,
    FieldResetDay = nil,
    Disabled = {},
    DoffBusy = nil,
    NextDoffAttempt = 0,
    TreadmillSessionVersion = 0,
    TreadmillAutoRequest = nil,
    TreadmillAuto = false,
    TreadmillBound = false,
    TreadmillControls = nil,
    TreadmillDueAt = nil,
    TreadmillEnteredAt = nil,
    TreadmillId = nil,
    TreadmillJumpUntil = nil,
    TreadmillManualExit = nil,
    TreadmillRestUntil = nil,
    TreadmillRetryAt = nil,
    TreadmillTurnUntil = nil,
    TreadmillAfterSteal = nil,
    TreadmillUtil = nil,
    RequestedTreadmillExit = nil,
    DeliveryStop = nil,
    DeliveryNoDropRetry = nil,
    EquippedWeapon = nil,
    PreviousTool = nil,
    HiddenPlayer = nil,
    HiddenPlayerUsed = nil,
    Evasion = nil,
    CarryCycle = nil,
    CarryDropTarget = nil,
    CarryEvent = nil,
    CarryEventRevision = 0,
    AFK = nil,
    AreaEggCycle = nil,
    AreaEggResetCycle = nil,
    AreasData = nil,
    RarityData = nil,
    Mutations = nil,
    TrailsData = nil,
    GuardsData = nil,
    FuseKernel = nil,
    GameplayBalance = nil,
    EggLimits = nil,
    ServerClock = nil,
    WispQuestsData = nil,
    WispProgression = nil,
    BanjoCricketData = nil,
    CursedIslandWarsData = nil,
    FishingData = nil,
    AlienLagoonData = nil,
    AlienGateData = nil,
    PlacedEggRenderer = nil,
    Ragdoll = nil,
    RagdollSwap = nil,
    RagdollRetryAt = 0,
    RagdollRigConnection = nil,
    Fun = nil,
    Nav = nil,
    Traps = {},
    TrapVisuals = {},
    Hazards = {},
    EffectCounts = {},
    CharacterMutation = nil,
    ClosePickupUid = nil,
    ExitStartedAt = nil,
    ExitTarget = nil,
    FinishedEggs = nil,
    FusionAwaitingFinish = nil,
    FusionPlan = nil,
    FusionReserved = {},
    LastFusionCompletedAt = 0,
    GuardAction = nil,
    GuardDodge = nil,
    GuardThreat = nil,
    IntentionalAttackTarget = nil,
    LastCarrierAttack = 0,
    LastMovementCorrection = 0,
    LastRenderAt = 0,
    ManualBeltApproachUntil = 0,
    ModuleSpecs = nil,
    MotionRequiredSpeed = 0,
    MotionTarget = nil,
    MovementSample = nil,
    MovementStatusLabel = nil,
    WispStatusLabel = nil,
    EggPredSummary = nil,
    FusePredSummary = nil,
    FinderSummary = nil,
    NextModulePoll = 0,
    NextSpendAt = 0,
    NextSwing = 0,
    NextUpgradeKind = nil,
    OriginalFPS = nil,
    PenExit = nil,
    PendingHatch = {},
    PendingSpend = nil,
    PendingTrailPurchase = nil,
    PlaceBlockedUntil = 0,
    PlaceReceipts = {},
    PlaceRetryAt = {},
    PreviousVelocity = nil,
    Pursuit = nil,
    PursuitTarget = nil,
    RecoveryCarry = nil,
    RecoveryEgg = nil,
    RecoveryHadCarry = false,
    ReturnGoal = nil,
    RewardIdleCount = 0,
    RewardWasIdle = false,
    BanjoNotesQueue = {},
    BanjoHooked = false,
    treadmillSession = nil,
    stopDeliveryStop = nil,
    clearNavigation = nil,
    antiAFKStep = nil,
    restoreFallStates = nil,
    antiAFKRestore = nil,
    funRestoreRotation = nil,
    restoreHiddenPlayer = nil,
    clearTrapESP = nil,
    usesDeliveryStop = nil,
    refreshStealPanel = nil,
    onCarryChanged = nil,
    inGameplay = nil,
    wispState = nil,
    currentWispQuest = nil,
    wispQuestProgress = nil,
    wispQuestClaimed = nil,
    wispStep = nil,
    worldEventsStep = nil,
    updatePredictorsAndFinder = nil,
    stopAll = nil,
    isFallen = nil,
    serverRagdolled = nil,
    deliveryStopAlive = nil,
    returnEgg = nil,
}
function Hub.registerDynamicField(fieldKey, fieldVal)
    if type(fieldKey) == "string" and fieldKey ~= "" then
        Hub[fieldKey] = fieldVal
    end
end
local PrevFeatureState = {}
function Hub.status(key, state, message)
    if isNoRewardMessage(message) then
        state, message = "idle", "ยังไม่มีรางวัลให้รับ"
    end
    Hub.Status[key] = { State = state, Message = tostring(message or ""), At = os.clock() }
end
function Hub.fail(key, message)
    if isNoRewardMessage(message) then
        Hub.status(key, "idle", "ยังไม่มีรางวัลให้รับ")
        if key == "AutoClaimReward" then
            Hub.RewardWasIdle = true
        end
        return
    end
    Hub.status(key, "error", message)
end
reportFailure = Hub.fail
function Hub.refreshCallback(callback)
    local ok, err = pcall(callback)
    if not ok then
        Hub.fail("UI", err)
    end
end
function Hub.alive(key, token)
    if key:sub(1, 4) == "Auto" then
        local hum = getLocalHumanoid()
        if not hum or hum.Health <= 0 then
            return false
        end
    end
    return IsScriptRunning and Config[key] == true and Hub.Generation[key] == token
end
function Hub.remote(namespace, name, kind)
    local group = type(Remotes) == "table" and Remotes[namespace] or nil
    local remote = type(group) == "table" and group[name] or nil
    if not remote then
        remote = getDirectRemote(kind == "event" and "RE" or "RF", namespace, name)
    end
    if remote then
        local ok, method = pcall(function()
            return remote[kind == "event" and "FireServer" or "InvokeServer"]
        end)
        if ok and type(method) == "function" then
            return remote
        end
    end
    return nil
end
function Hub.doffTreadmill(manual)
    if Hub.DoffBusy or (not RuntimeState.IsCurrentlyOnTreadmill and not manual) then
        return
    end
    if os.clock() < (Hub.NextDoffAttempt or 0) then
        return
    end
    local session = Hub.TreadmillSessionVersion or 0
    local request = {}
    Hub.NextDoffAttempt = os.clock() + (manual and 0.35 or 2)
    Hub.DoffBusy, Hub.RequestedTreadmillExit = request, true
    if manual then
        Hub.TreadmillManualExit = true
    end
    Hub.status("AutoTreadmill", "waiting", "กำลังขอลงจากลู่วิ่ง รอเกมตอบรับ")
    task.delay(6, function()
        if Hub.DoffBusy == request and (Hub.TreadmillSessionVersion or 0) == session and IsScriptRunning then
            Hub.fail("AutoTreadmill", "เกมยังไม่ตอบคำขอลงจากลู่วิ่ง")
        end
    end)
    task.spawn(function()
        local remote = Hub.remote("Treadmill", "AskDoff", "function")
        local ok, accepted = pcall(function()
            return remote and remote:InvokeServer()
        end)
        if Hub.DoffBusy == request then
            Hub.DoffBusy = nil
        end
        if (Hub.TreadmillSessionVersion or 0) ~= session then
            return
        end
        if ok and accepted == true then
            Hub.treadmillSession(nil)
        else
            Hub.RequestedTreadmillExit, Hub.TreadmillManualExit = nil, nil
            Hub.fail("AutoTreadmill", "เกมยังไม่ยืนยันลงจากลู่วิ่ง")
        end
    end)
end
function Hub.noReward(reason)
    return isNoRewardMessage(reason)
end
function Hub.rewardIdle(reason)
    Hub.status("AutoClaimReward", "idle", "ยังไม่มีรางวัลให้รับ")
    Hub.RewardWasIdle = true
    return false, reason
end
function Hub.rpc(key, token, namespace, name, kind, ...)
    if not Hub.alive(key, token) then
        return false, "ยกเลิกแล้ว"
    end
    local remote = Hub.remote(namespace, name, kind)
    if not remote then
        Hub.fail(key, "ไม่พบคำสั่ง " .. namespace .. "." .. name)
        return false
    end
    local id = namespace .. "." .. name
    local gap = id == "Haul.WearBest" and 5.2 or 0.35
    if Hub.InFlight[id] or os.clock() - (Hub.LastRequest[id] or -math.huge) < gap then
        Hub.status(key, "waiting", "รอคำสั่งก่อนหน้า: " .. id)
        return false
    end
    Hub.InFlight[id] = true
    Hub.LastRequest[id] = os.clock()
    local args = table.pack(...)
    local result = nil
    task.spawn(function()
        result = table.pack(pcall(function()
            if kind == "event" then
                remote:FireServer(table.unpack(args, 1, args.n))
                return true
            end
            if namespace == "EggWorld" and EggState then
                if name == "AskWearTool" and key == "AutoPlaceEgg" and EggState.WearEggTool then
                    return EggState.WearEggTool(args[1])
                end
                if key == "AutoStealEgg" and Hub.DeliveryStop and Hub.DeliveryStop.Transferring then
                    local payload = args[1]
                    if name == "AskFieldEggDrop" and EggState.DropFieldEgg then
                        return EggState.DropFieldEgg(payload.Reason)
                    end
                    if name == "AskFieldEggCarry" and EggState.CarryFieldEgg then
                        return EggState.CarryFieldEgg(payload.Uid, payload.FirstAreaSlotKey)
                    end
                end
            end
            return remote:InvokeServer(table.unpack(args, 1, args.n))
        end))
        Hub.InFlight[id] = nil
        local entry = Hub.TreadmillAutoRequest
        if namespace == "Treadmill" and name == "AskWearStill" and entry and entry.Token == token then
            Hub.TreadmillAutoRequest = nil
            if result[1] and result[2] == true then
                if (Hub.TreadmillSessionVersion or 0) == entry.Version then
                    Hub.treadmillSession("local", "auto")
                end
                if Hub.TreadmillAuto and (not IsScriptRunning or not Config.AutoTreadmill) then
                    Hub.doffTreadmill()
                end
            end
        end
    end)
    local deadline = os.clock() + 6
    while not result and Hub.alive(key, token) and os.clock() < deadline do
        task.wait(0.05)
    end
    if not Hub.alive(key, token) then
        return false, "ยกเลิกแล้ว"
    end
    if not result then
        Hub.fail(key, "หมดเวลารอ ".. id.. " (พักคำสั่งนี้จนได้รับคำตอบ)")
        return false
    end
    if not result[1] then
        if key == "AutoClaimReward" and Hub.noReward(result[2]) then
            return Hub.rewardIdle(result[2])
        end
        Hub.fail(key, id .. ": " .. tostring(result[2]))
        return false
    end
    if key == "AutoClaimReward" and (Hub.noReward(result[2]) or Hub.noReward(result[3])) then
        return Hub.rewardIdle(result[3] or result[2])
    end
    if result[2] == false or result[2] == nil then
        local reason = result[3]
        local text = type(reason) == "table" and (reason.Code or reason.Message) or reason
        Hub.status(key, "rejected", "เซิร์ฟเวอร์ไม่รับ: " .. tostring(text or id))
        return false, reason
    end
    Hub.status(key, kind == "event" and "requested" or "confirmed", kind == "event" and "ส่งคำขอแล้ว รอข้อมูลจากเกม" or "เซิร์ฟเวอร์ตอบรับคำสั่ง")
    return true, table.unpack(result, 2, result.n)
end
function Hub.job(key, interval, needsInventory, fn)
    if not Config[key] or Hub.Jobs[key] or os.clock() < (Hub.NextRun[key] or 0) then
        return false
    end
    if needsInventory and Hub.InventoryOwner then
        Hub.status(key, "waiting", "รอคิวไอเทม: " .. Hub.InventoryOwner)
        return false
    end
    local token = Hub.Generation[key] or 0
    Hub.Jobs[key] = token
    Hub.NextRun[key] = os.clock() + interval
    if needsInventory then
        Hub.InventoryOwner = key
    end
    task.spawn(function()
        local ok, err = pcall(fn, token)
        if not ok and Hub.alive(key, token) then
            Hub.fail(key, err)
        end
        if Hub.Jobs[key] == token then
            Hub.Jobs[key] = nil
        end
        if Hub.InventoryOwner == key then
            Hub.InventoryOwner = nil
        end
    end)
    return true
end
function Hub.capture(key, object, property, value)
    if not object then
        return
    end
    Hub.Effects[key] = Hub.Effects[key] or {}
    local props = Hub.Effects[key][object]
    if not props then
        props = {}
        Hub.Effects[key][object] = props
    end
    if not props[property] then
        props[property] = { Original = object[property] }
        Hub.EffectCounts = Hub.EffectCounts or {}
        Hub.EffectCounts[key] = (Hub.EffectCounts[key] or 0) + 1
    end
    object[property] = value
    props[property].Applied = value
end
function Hub.restore(key)
    for object, properties in pairs(Hub.Effects[key] or {}) do
        for property, values in pairs(properties) do
            pcall(function()
                if object.Parent and object[property] == values.Applied then
                    object[property] = values.Original
                end
            end)
        end
    end
    Hub.Effects[key] = nil
    if Hub.EffectCounts then
        Hub.EffectCounts[key] = nil
    end
end
function Hub.acquire(owner)
    if Hub.MovementOwner == owner then
        return
    end
    if Hub.DeliveryStop then
        Hub.stopDeliveryStop()
    end
    if Hub.MovementOwner then
        local old = Hub.MovementOwner
        Hub.Generation[old] = (Hub.Generation[old] or 0) + 1
        if owner or not Hub.Status[old] or Hub.Status[old].State ~= "confirmed" then
            Hub.status(old, "waiting", "รอคิวเคลื่อนที่: ".. tostring(owner or "หยุด"))
        end
    end
    if Hub.clearNavigation then
        Hub.clearNavigation()
    end
    Hub.MovementOwner = owner
    RuntimeState.IsCurrentlyChasingCarrier = owner == "AutoAttack"
    RuntimeState.IsCurrentlyPlacingEgg = owner == "AutoPlaceEgg"
end
function Hub.applyObject(inst)
    local world, plots = Workspace:FindFirstChild("World"), Workspace:FindFirstChild("Plots")
    local inWorld = world and inst:IsDescendantOf(world)
    local inScene = inWorld or (plots and inst:IsDescendantOf(plots))
    if Config.OptDisableParticles and inScene and (inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam") or inst:IsA("Sparkles") or inst:IsA("Smoke") or inst:IsA("Fire")) then
        Hub.capture("OptDisableParticles", inst, "Enabled", false)
    end
    if Config.OptSimplifyMaterials and inScene then
        if inst:IsA("BasePart") then
            Hub.capture("OptSimplifyMaterials", inst, "Material", Enum.Material.SmoothPlastic)
        elseif inst:IsA("Decal") or inst:IsA("Texture") then
            Hub.capture("OptSimplifyMaterials", inst, "Transparency", 1)
        end
    end
    if Config.OptHideWorldDecorations and inWorld and inst:IsA("BasePart") then
        local node, decoration = inst, false
        while node and node ~= world do
            local name = node.Name:lower()
            if name == "decorations" or name == "decoration" or name == "trees" or name == "bushes" or name == "rocks" or name == "flowers" or name == "clouds" then
                decoration = true
                break
            end
            node = node.Parent
        end
        if decoration then
            Hub.capture("OptHideWorldDecorations", inst, "LocalTransparencyModifier", 1)
        end
    end
    if Config.OptDisableShadowsAndPostFX and inst:IsDescendantOf(Lighting) and inst:IsA("PostEffect") and inst ~= BlurEffect then
        Hub.capture("OptDisableShadowsAndPostFX", inst, "Enabled", false)
    end
    if Config.OptMuteGameAudio and (inst:IsA("Sound") or inst:IsA("SoundGroup")) then
        Hub.capture("OptMuteGameAudio", inst, "Volume", 0)
    end
end
function Hub.syncPreferences()
    if Hub.PreferenceBusy or not Preferences or not Preferences.IsOn or not Preferences.Set then
        return
    end
    local mappings = {
        OptHideOtherPets = "HideOtherPets",
        OptHideSelfPets = "HideSelfPets",
        OptDisableTreadmillVideos = "DisableVideos",
    }
    for key, pref in pairs(mappings) do
        if Config[key] or Hub.PreferenceOriginal[pref] ~= nil then
            local ok, current = pcall(Preferences.IsOn, pref)
            if ok then
                if Config[key] and Hub.PreferenceOriginal[pref] == nil then
                    Hub.PreferenceOriginal[pref] = current
                end
                local wanted = Config[key] and true or Hub.PreferenceOriginal[pref]
                if current ~= wanted then
                    Hub.PreferenceLastWanted = Hub.PreferenceLastWanted or {}
                    Hub.PreferenceNextAttempt = Hub.PreferenceNextAttempt or {}
                    if Hub.PreferenceLastWanted[pref] ~= wanted then
                        Hub.PreferenceNextAttempt[pref] = 0
                        Hub.PreferenceLastWanted[pref] = wanted
                    end
                    if os.clock() < (Hub.PreferenceNextAttempt[pref] or 0) then
                        return
                    end
                    Hub.PreferenceNextAttempt[pref] = os.clock() + 2
                    Hub.PreferenceBusy = true
                    Hub.PreferenceBusyKey = pref
                    task.spawn(function()
                        local success, accepted = pcall(Preferences.Set, pref, wanted)
                        Hub.PreferenceBusy = false
                        Hub.PreferenceBusyKey = nil
                        if success and accepted == true then
                            Hub.PreferenceApplied[pref] = wanted
                            Hub.PreferenceNextAttempt[pref] = 0
                            Hub.status(key, "confirmed", "เกมยืนยันการตั้งค่าแล้ว")
                        else
                            Hub.fail(key, "เกมไม่รับการตั้งค่า " .. pref)
                        end
                        if not IsScriptRunning and Hub.PreferenceOriginal[pref] ~= nil then
                            pcall(Preferences.Set, pref, Hub.PreferenceOriginal[pref])
                            Hub.PreferenceOriginal[pref] = nil
                        end
                    end)
                    return
                elseif not Config[key] then
                    Hub.PreferenceOriginal[pref] = nil
                else
                    Hub.status(key, "confirmed", "เกมยืนยันการตั้งค่าแล้ว")
                end
            else
                Hub.fail(key, current)
            end
        end
    end
end
function Hub.restoreWeapon()
    if Hub.EquippedWeapon then
        local hum = getLocalHumanoid()
        if hum and Hub.EquippedWeapon.Parent == LocalPlayer.Character then
            hum:UnequipTools()
            if Hub.PreviousTool and Hub.PreviousTool.Parent then
                hum:EquipTool(Hub.PreviousTool)
            end
        end
        Hub.EquippedWeapon, Hub.PreviousTool = nil, nil
    end
end
function Hub.isDeliveryStopMode()
    return Config.DeliveryMethod == "พักส่งไข่เป็นจังหวะ" or Config.DeliveryMethod == "เทเลพอร์ต" or Config.DeliveryMethod == "Delivery Stop"
end
function Hub.isNormalDeliveryMode()
    return Config.DeliveryMethod ~= "พักส่งไข่เป็นจังหวะ" and Config.DeliveryMethod ~= "Delivery Stop"
end
function Hub.deliveryNeedsAntiFall()
    return Config.AutoStealEgg and Hub.isDeliveryStopMode()
end
function Hub.featureEnabled(key)
    return Config[key] == true or (key == "AntiFall" and Hub.deliveryNeedsAntiFall())
end
function Hub.available(key)
    if key == "AntiGuard" and not Hub.isNormalDeliveryMode() then
        return false, "ป้องกันยามจับใช้ร่วมกับโหมดพักส่งไข่เป็นจังหวะไม่ได้ กรุณาเลือกวิธีส่งแบบเดินถือไข่ปกติก่อน"
    end
    if key == "AntiAFK" then
        local scanner = type(getgc) == "function" and type(islclosure) == "function" and type(debug) == "table" and type(debug.info) == "function" and type(debug.getupvalues) == "function" and type(debug.setupvalue) == "function"
        if type(getconnections) ~= "function" and not scanner then
            return false, "ตัวรันต้องรองรับการเชื่อมต่อสัญญาณหรือชุดตรวจสอบสถานะอยู่นิ่ง"
        end
    end
    if key == "HidePlayer" then
        if Hub.HiddenPlayerUsed == LocalPlayer.Character and LocalPlayer.Character and not Hub.HiddenPlayer then
            return false, "ร่างนี้ส่งคำขอซ่อนแล้ว ต้องเกิดใหม่ก่อนซ่อนซ้ำ"
        end
        if type(replicatesignal) ~= "function" then
            return false, "ตัวรันต้องรองรับการจำลองสัญญาณตัวละคร"
        end
    end
    if Hub.Disabled[key] then
        return false, Hub.Disabled[key]
    end
    if key == "OptUnlockFPS" and (type(setfpscap) ~= "function" or type(getfpscap) ~= "function") then
        return false, "ต้องมีตัวอ่านและตัวตั้งเพดานเฟรมเรตเพื่อคืนค่าเดิมได้"
    end
    return true
end
local function setToggleConflictBadge(configKey, text, badgeColor)
    local info = ToggleConflictBadges[configKey]
    if not info then
        return
    end
    info.Frame.Visible = text ~= nil and text ~= ""
    info.Label.Text = text or ""
    info.Frame.BackgroundColor3 = badgeColor or Color3.fromRGB(245, 158, 11)
end
local FeatureStatusNames = {
    waiting = "รอ / พัก",
    unavailable = "ใช้ไม่ได้",
    rejected = "ไม่รับคำขอ",
    error = "ผิดพลาด",
    requested = "รอยืนยัน",
    confirmed = "ยืนยันแล้ว",
    ["local"] = "ฝั่งเรา",
}
local SUB_SETTING_TOGGLES = {
    BackgroundBlur = true,
    InstantFishCatch = true,
    AutoFeedStar = true,
    StealUseMinPrice = true,
    StealUseMinBoost = true,
    FavoriteMutatedOnly = true,
    SwapFarmPriority = true,
    AutoAdminTreadmill = true,
    AutoLoadScript = true,
    AutoRejoinOnDisconnect = true,
    AutoHopOnDanger = true,
    KeybindsEnabled = true,
    EggShowName = true,
    EggShowRarity = true,
    EggShowMutation = true,
    EggShowIncome = true,
    EggShowValue = true,
    EggShowWeight = true,
    EggShowArea = true,
    EggShowDistance = true,
    GuardShowState = true,
    GuardShowDistance = true,
    PlayerShowName = true,
    PlayerShowDistance = true,
    PlayerShowSpeed = true,
    PlayerShowStatus = true,
}
local FEATURE_THAI_NAMES = {
    AutoStealEgg = "ออโต้ขโมยไข่",
    AutoPlaceEgg = "ออโต้วางไข่",
    AutoHatchEgg = "ออโต้ฟักไข่",
    AutoUpgradeAll = "ออโต้อัปเกรด",
    AutoTreadmill = "ออโต้ลู่วิ่ง",
    AutoEquipBest = "ออโต้ใส่ตัวเก่งสุด",
    AutoSellPet = "ออโต้ขายตัว",
    AutoClaimReward = "ออโต้รับรางวัล",
    AutoWispQuest = "รับเควสภูตวิญญาณ เคลมรางวัลรายขั้น และส่งภูตเปิดทางต้นไม้มนตรา",
    AutoBloom = "เก็บกลีบซากุระ เขย่าต้นไม้ แลกผีเสื้อ และหมุนระบบพฤกษาผลิบาน",
    AutoShootingStar = "ตรวจจับดาวตกในแผนที่และส่งคำสั่งเก็บดาวตกอัตโนมัติ",
    AutoFeedStar = "ป้อนสัตว์เลี้ยงให้ดาวตกเพื่อรับรางวัลพิเศษอัตโนมัติ",
    AutoBanjo = "อ่านลำดับตัวโน้ตเห็ดและดีดแบนโจจิ้งหรีดพร้อมรับรางวัล",
    AutoFishing = "เหวี่ยงเบ็ด ดึงปลา และรับรางวัลมาสเตอรีตกปลาอัตโนมัติ",
    InstantFishCatch = "ส่งสัญญาณดึงปลาทันทีเมื่อทุ่นตกปลาติดสถานะพร้อมจับ",
    AutoAlien = "สำรวจยูเอฟโอ ซ่อมชิ้นส่วน เก็บหินเอเลี่ยน และแลกของรางวัลบึงเอเลี่ยน",
    AutoIslandWars = "เข้าร่วมสงครามเกาะต้องสาป ขุดแร่ โจมตี และใช้แท่นกระโดดอัตโนมัติ",
    AutoChaseCarrier = "ออโต้ไล่ล่าแย่งไข่จากผู้เล่นที่กำลังถือไข่ในสนาม",
    AutoMutation = "ออโต้ส่งไข่และสัตว์เลี้ยงเข้าเครื่องกลายพันธุ์",
    AutoShrineFusion = "ออโต้แท่นบูชาฟิวส์ชั่น",
    AutoFavorite = "ออโต้ล็อกดาวสัตว์เลี้ยงและไข่หายาก",
    AutoCollectMoney = "ออโต้เก็บเงินในคอกและเงินออฟไลน์",
    AutoAdminTreadmill = "ออโต้ใช้ลู่วิ่งสายรุ้งกิจกรรมแอดมิน",
    WarpToSafeZone = "วาร์ปกลับเขตปลอดภัยเมื่อมีอันตราย",
    StealUseMinPrice = "กรองราคาไข่ขั้นต่ำ",
    StealUseMinBoost = "กรองบูสท์ขั้นต่ำตามความหายาก",
    FavoriteMutatedOnly = "ล็อกดาวเฉพาะตัวกลายพันธุ์",
    SwapFarmPriority = "สลับลำดับความสำคัญงานฟาร์ม",
    AutoGhostDogQuest = "ออโต้เควสสุนัขวิญญาณ",
    AutoSubZones = "ออโต้ถ้ำระบายน้ำ คฤหาสน์ และโพรงมืด",
    AutoPetWheel = "ออโต้หมุนวงล้อสัตว์เลี้ยง",
    AutoRiftAndScramble = "ออโต้แลกไข่รอยแยกและห้องทดลอง",
    AutoAdminAbuse = "ออโต้เข้าร่วมกิจกรรมแอดมินทั้งหมด",
    AutoBeanstalk = "ออโต้กิจกรรมต้นถั่วยักษ์และหิ่งห้อย",
    AutoLightVsDark = "ออโต้ศึกแสงและเงา",
    AutoSammy = "ออโต้กิจกรรมแซมมี่",
    AutoBossRaid = "ออโต้บอสสแครมเบิล บอสฟักทอง และบุกอวกาศ",
    AutoMinigameEvents = "ออโต้มินิเกมวิ่งหนีทีเร็กซ์ ไฟแดงไฟเขียว และปรสิต",
    PlayerSpeedEnabled = "ปรับความเร็วเดินผู้เล่น",
    PlayerJumpEnabled = "ปรับพลังกระโดดผู้เล่น",
    InfiniteJump = "กระโดดกลางอากาศไม่จำกัด",
    Noclip = "เดินทะลุกำแพงและสิ่งกีดขวาง",
    AutoPetMount = "ขี่สัตว์เลี้ยงอัตโนมัติ",
    AutoLoadScript = "ออโต้โหลดสคริปต์เมื่อย้ายเซิร์ฟ",
    AutoRejoinOnDisconnect = "ออโต้เข้าใหม่เมื่อหลุดจากเกม",
    AutoHopEnabled = "ออโต้ย้ายเซิร์ฟเวอร์หาไข่เป้าหมาย",
    AutoHopOnDanger = "ออโต้ย้ายเซิร์ฟเวอร์หนีเมื่อมีอันตราย",
    AutoBuyTrail = "ออโต้ซื้อเทรล",
    AutoFusion = "ออโต้ฟิวส์ชั่น",
    AutoAttack = "ออโต้ตี",
    AutoEquipBat = "ถือไม้เบล",
    AntiTrap = "ปิดชนกับดัก",
    AntiFall = "กันล้ม",
    AntiKnockback = "กันกระเด็น",
    AntiGuard = "หลบยามอัตโนมัติ",
    AntiAFK = "ป้องกันหลุด",
    HidePlayer = "ซ่อนตัวละคร",
    FunScaleEnabled = "ปรับขนาดโมเดล",
    FunSpin = "หมุนทั้งตัว",
    RevealEggContent100 = "ตรวจสอบข้างในไข่",
    EggESP = "มองเห็นไข่ในสนาม",
    OwnBaseEggESP = "มองเห็นไข่ในคอก",
    GuardESP = "มองเห็นยาม",
    LostPartESP = "มองเห็นชิ้นส่วนที่หายไป",
    PlayerESP = "มองเห็นผู้เล่น",
    TrapESP = "มองเห็นกับดัก",
    OptUnlockFPS = "ปลดล็อกเฟรมเรต",
    Profiles = "โปรไฟล์",
    Scheduler = "ระบบหลัก",
    UI = "หน้าต่างเมนู",
    Effects = "เอฟเฟกต์",
}
local function updateConflictBadgesAndBanner(_)
    for _, entry in pairs(Hub.Status) do
        if isNoRewardMessage(entry.Message) then
            entry.State, entry.Message = "idle", "ยังไม่มีรางวัลให้รับ"
        end
    end
    for key, info in pairs(ToggleConflictBadges) do
        local enabled = Hub.featureEnabled(key)
        local available, reason = Hub.available(key)
        local state = Hub.Status[key]
        local text, color = nil, Color3.fromRGB(245, 158, 11)
        if not available then
            text = "ไม่รองรับ"
            color = Color3.fromRGB(185, 28, 28)
        elseif enabled then
            text = state and state.Message or "เปิดใช้งาน รอทำงาน"
            if state and (state.State == "confirmed" or state.State == "local") then
                color = Color3.fromRGB(16, 185, 129)
            end
        end
        local badge = not available and "ใช้ไม่ได้" or nil
        if enabled and available then
            badge = state and FeatureStatusNames[state.State] or "เปิดใช้งาน"
        end
        if state and (state.State == "waiting" or state.State == "requested" or state.State == "unavailable" or state.State == "rejected") then
            color = Color3.fromRGB(245, 158, 11)
        end
        if (info.Settings or SUB_SETTING_TOGGLES[key]) and enabled and available then
            text, badge, color = "เปิดใช้งาน", "เปิดใช้งาน", Color3.fromRGB(16, 185, 129)
        end
        setToggleConflictBadge(key, badge, color)
        if info.Description then
            local note = not available and reason or (text or (state and state.State == "error" and state.Message) or "ปิดอยู่")
            if key == "AutoTreadmill" and not Config.AutoTreadmill and RuntimeState.IsCurrentlyOnTreadmill and Hub.RequestedTreadmillExit then
                note = state and state.Message or "กำลังรอเกมยืนยันลงจากลู่วิ่ง"
            end
            if key == "AutoSellPet" and Config.AutoEquipBest then
                note = note.. " • รอข้อมูลใส่ตัวเก่งสุดยืนยันก่อนขาย"
            end
            if key == "OptDisableShadowsAndPostFX" then
                note = note.. " • เบลอเมนูควบคุมแยกในหน้าตั้งค่า"
            end
            if key == "RevealEggContent100" then
                note = note.. " • แสดงเฉพาะข้อมูลที่เกมส่งมา"
            end
            if key == "AutoClaimReward" then
                note = note.. " • ตรวจทุก 60 วินาที ถ้ายังไม่มีรางวัลพักเพิ่ม 120–600 วินาที"
            end
            if key == "AutoBuyTrail" then
                note = note.. " • ซื้อด้วยเงินในเกมจากราคาต่ำไปสูง รอเงินครบก่อนซื้อ"
            end
            if key == "AutoFusion" then
                note = note.. " • ใช้ตัวชนิดเดียวกันที่ไม่ได้ใส่และไม่ติดดาว กันไว้ก่อนขาย/ใส่ตัวเก่งสุด"
            end
            if key == "AntiTrap" then
                note = note.. " • ปรับชิ้นส่วนกับดักเฉพาะเครื่องเรา ไม่แทรกเส้นทางวิ่ง; ปิดแล้วคืนค่า"
            end
            if key == "AntiFall" and Hub.deliveryNeedsAntiFall() then
                note = note.. " • เปิดอัตโนมัติสำหรับโหมดพักส่งไข่เป็นจังหวะ"
            end
            if key == "AntiGuard" then
                note = note.. " • ตอบสนองต่อสถานะล้มระหว่างขโมยในโหมดเดินถือไข่ปกติ"
            end
            if key == "AntiAFK" then
                note = note.. " • พักตัวจับอยู่นิ่งฝั่งเราแล้วคืนค่าเมื่อปิด โดยไม่สั่งเดินเอง"
            end
            if key == "HidePlayer" then
                note = note.. " • ส่งคำขอซ่อนตัวละครและต้องเกิดใหม่เพื่อคืนร่างฝั่งเกม"
            end
            if key == "AntiKnockback" then
                note = note.. " • ลดแรงกระเด็น ไม่รับประกันความเสียหายฝั่งเซิร์ฟเวอร์"
            end
            if key == "HidePlayer" and Hub.HiddenPlayerUsed == LocalPlayer.Character and Hub.HiddenPlayerUsed then
                note = note.. " • รีเซ็ตตัวละครเพื่อคืนร่างฝั่งเกม"
            end
            if key == "AutoTreadmill" then
                note = note.. " • วิ่ง ".. tostring(Config.TreadmillRunSeconds).. " วินาที พัก ".. tostring(Config.TreadmillRestSeconds).. " วินาที"
            end
            if key == "EggTracker" then
                note = note .. " • ต้องเปิดการแสดงตำแหน่งไข่"
            end
            if key == "PlayerTracker" then
                note = note .. " • ต้องเปิดการแสดงตำแหน่งผู้เล่น"
            end
            if key == "GuardTracker" then
                note = note .. " • ต้องเปิดการแสดงตำแหน่งยามในสนาม"
            end
            if key == "LostPartTracker" then
                note = note .. " • ต้องเปิดการแสดงตำแหน่งชิ้นส่วนที่หายไป"
            end
            info.Description.Text = note
        end
    end
    local issue = nil
    for key, state in pairs(Hub.Status) do
        if Hub.featureEnabled(key) and (state.State == "error" or state.State == "rejected") then
            local thaiName = FEATURE_THAI_NAMES[key] or key
            issue = thaiName .. ": " .. state.Message
            break
        end
    end
    StatusDot.BackgroundColor3 = issue and Color3.fromRGB(245, 158, 11) or Color3.fromRGB(16, 185, 129)
    if RuntimeState.IsCurrentlyOnTreadmill and not Config.AutoTreadmill and Hub.RequestedTreadmillExit then
        issue = "ปิดออโต้แล้ว แต่ยังรอเกมยืนยันลงจากลู่วิ่ง"
    end
    StatusBannerLabel.Text = issue or ("สถานะ: " .. RuntimeState.CurrentTaskStatusText)
end
local function getSafeWorldContainers()
    local list = {}
    for _, name in ipairs({ "World", "Plots" }) do
        local value = Workspace:FindFirstChild(name)
        if value then
            table.insert(list, value)
        end
    end
    return list
end
local function syncAllFeatureStates(changedKey)
    if not IsScriptRunning then
        return
    end
    if Config.AutoEquipBest and Config.AutoSellPet and Config.SellMode == "ขายทุกตัว" then
        Config.SellMode = "ไม่ขายตัวที่ใส่"
        notifyThai("ใช้ใส่ตัวเก่งสุดร่วมกับขายได้ โดยเว้นตัวที่ใส่อยู่")
    end
    local scan = false
    for key, preference in pairs(Config) do
        if type(preference) == "boolean" then
            local value = Hub.featureEnabled(key)
            local available, reason = Hub.available(key)
            if value and not available then
                Hub.status(key, "unavailable", reason)
                Config[key] = false
                value = false
            end
            if PrevFeatureState[key] ~= value then
                Hub.Generation[key] = (Hub.Generation[key] or 0) + 1
                if value then
                    Hub.status(key, "waiting", "เปิดใช้งาน รอข้อมูล/คิว")
                    if key == "AntiAFK" and Hub.antiAFKStep then
                        Hub.antiAFKStep()
                    end
                    if key == "AntiKnockback" then
                        Hub.status(key, "local", "เฝ้าตรวจแรงกระเด็นบนตัวละครฝั่งเรา")
                    end
                    if key == "StealOnlyMissingIndex" then
                        Hub.status(key, "local", "กรองเฉพาะสายพันธุ์ที่ยังไม่มีในสมุดสะสมฝั่งเรา")
                    end
                    if key == "StealOnlyMissingLab" then
                        Hub.status(key, "local", "กรองเฉพาะสายพันธุ์ที่ยังไม่ส่งห้องทดลองฝั่งเรา")
                    end
                    if key:sub(1, 3) == "Opt" then
                        scan = true
                    end
                else
                    Hub.restore(key)
                    if key == "AntiFall" and Hub.restoreFallStates then
                        Hub.restoreFallStates()
                    end
                    if key == "AntiAFK" and Hub.antiAFKRestore then
                        Hub.antiAFKRestore()
                    end
                    if key == "FunSpin" and Hub.funRestoreRotation then
                        Hub.funRestoreRotation()
                    end
                    if key == "AntiKnockback" then
                        Hub.PreviousVelocity = nil
                    end
                    if key == "HidePlayer" and Hub.restoreHiddenPlayer then
                        Hub.restoreHiddenPlayer()
                    end
                    if key == "TrapESP" and Hub.clearTrapESP then
                        Hub.clearTrapESP()
                    end
                    if Hub.MovementOwner == key then
                        Hub.acquire(nil)
                    end
                    if Hub.Evasion and Hub.Evasion.Owner == key then
                        Hub.Evasion = nil
                    end
                    if key == "AutoTreadmill" or key == "AutoStealEgg" then
                        Hub.TreadmillTurnUntil, Hub.TreadmillDueAt, Hub.TreadmillAfterSteal, Hub.TreadmillRetryAt = nil, nil, nil, nil
                        if key == "AutoTreadmill" and Hub.TreadmillAuto then
                            Hub.doffTreadmill()
                        end
                        if key == "AutoStealEgg" then
                            Hub.StealEntry, Hub.PenExit, Hub.StealPickupUntil = nil, nil, nil
                        end
                    end
                    if Hub.CarryCycle and Hub.CarryCycle.Owner == key then
                        Hub.CarryCycle, Hub.ReturnGoal = nil, nil
                    end
                    if key == "AutoAttack" then
                        Hub.Pursuit, Hub.PursuitTarget, Hub.RecoveryEgg, Hub.RecoveryCarry = nil, nil, nil, nil
                    end
                    if key == "AutoFusion" then
                        Hub.FusionPlan, Hub.FusionReserved = nil, {}
                    end
                    if key == "AutoEquipBat" and not Config.AutoAttack and Hub.EquippedWeapon then
                        local hum = getLocalHumanoid()
                        if hum and Hub.EquippedWeapon.Parent == LocalPlayer.Character then
                            hum:UnequipTools()
                        end
                        Hub.EquippedWeapon = nil
                    end
                    if key == "RevealEggContent100" then
                        for prompt, original in pairs(ModifiedPrompts) do
                            pcall(function()
                                if prompt.Parent then
                                    prompt.ObjectText = original.ObjectText
                                    prompt.ActionText = original.ActionText
                                end
                            end)
                        end
                        table.clear(ModifiedPrompts)
                        for tool, name in pairs(ModifiedEggToolNames) do
                            pcall(function()
                                if tool.Parent then
                                    tool.Name = name
                                end
                            end)
                        end
                        table.clear(ModifiedEggToolNames)
                    end
                    if key ~= "AutoTreadmill" or not RuntimeState.IsCurrentlyOnTreadmill then
                        Hub.status(key, "off", "ปิดอยู่")
                    end
                end
                if key == "OptUnlockFPS" then
                    if value then
                        local ok, cap = pcall(getfpscap)
                        if ok and type(cap) == "number" then
                            Hub.OriginalFPS = cap
                            local applied, reason = pcall(setfpscap, 240)
                            if applied then
                                Hub.status(key, "local", "ตั้งเพดาน 240 FPS แล้ว")
                            else
                                Config[key] = false
                                Hub.OriginalFPS = nil
                                Hub.fail(key, "ตั้งเพดาน FPS ไม่สำเร็จ: ".. tostring(reason))
                            end
                        else
                            Config[key] = false
                            Hub.fail(key, "อ่านเพดาน FPS เดิมไม่ได้")
                        end
                    elseif Hub.OriginalFPS then
                        pcall(setfpscap, Hub.OriginalFPS)
                        Hub.OriginalFPS = nil
                    end
                end
                PrevFeatureState[key] = Config[key]
            end
        end
    end
    if Config.OptDisableShadowsAndPostFX then
        Hub.capture("OptDisableShadowsAndPostFX", Lighting, "GlobalShadows", false)
    end
    if scan then
        for _, root in ipairs({ Workspace, Lighting, SoundService }) do
            for _, inst in ipairs(root:GetDescendants()) do
                local ok, err = pcall(Hub.applyObject, inst)
                if not ok then
                    Hub.fail("Effects", err)
                end
            end
        end
    end
    if not Config.EggESP and not Config.OwnBaseEggESP and not Config.RevealEggContent100 then
        clearAllEggESP()
    end
    if not Config.PlayerESP then
        clearAllPlayerESP()
    end
    if not Config.GuardESP then
        clearAllGuardESP()
    end
    if not Config.LostPartESP then
        clearAllLostPartESP()
    end
    for _, key in ipairs({
        "OptDisableParticles",
        "OptDisableShadowsAndPostFX",
        "OptSimplifyMaterials",
        "OptHideWorldDecorations",
        "OptMuteGameAudio",
    }) do
        if Config[key] then
            local count = (Hub.EffectCounts or {})[key] or 0
            Hub.status(key, count > 0 and "local" or "waiting", count > 0 and ("ปรับเฉพาะเครื่องเราแล้ว " .. tostring(count) .. " ค่า") or "ยังไม่พบวัตถุที่รองรับ รอฉากโหลด")
        end
    end
    if not Config.AutoAttack and not Config.AutoEquipBat then
        Hub.restoreWeapon()
    end
    if Hub.DeliveryStop and not Hub.usesDeliveryStop(Hub.DeliveryStop.Cycle.Owner) then
        Hub.stopDeliveryStop()
    end
    if BlurEffect then
        BlurEffect.Enabled = IsWindowOpen and Config.BackgroundBlur
    end
    if Config.EggTracker then
        Hub.status("EggTracker", (Config.EggESP or Config.OwnBaseEggESP) and "local" or "waiting", (Config.EggESP or Config.OwnBaseEggESP) and "แสดงเส้นชี้ตำแหน่งไข่ฝั่งเราแล้ว" or "รอเปิดการแสดงตำแหน่งไข่ก่อน")
    end
    if Config.PlayerTracker then
        Hub.status("PlayerTracker", Config.PlayerESP and "local" or "waiting", Config.PlayerESP and "แสดงเส้นชี้ตำแหน่งผู้เล่นฝั่งเราแล้ว" or "รอเปิดการแสดงตำแหน่งผู้เล่นก่อน")
    end
    if Config.GuardTracker then
        Hub.status("GuardTracker", Config.GuardESP and "local" or "waiting", Config.GuardESP and "แสดงเส้นชี้ตำแหน่งยามฝั่งเราแล้ว" or "รอเปิดการแสดงตำแหน่งยามในสนามก่อน")
    end
    if Config.LostPartTracker then
        Hub.status("LostPartTracker", Config.LostPartESP and "local" or "waiting", Config.LostPartESP and "แสดงเส้นชี้ตำแหน่งชิ้นส่วนที่หายไปฝั่งเราแล้ว" or "รอเปิดการแสดงตำแหน่งชิ้นส่วนที่หายไปก่อน")
    end
    Hub.syncPreferences()
    if Hub.refreshStealPanel then
        pcall(Hub.refreshStealPanel)
    end
    updateConflictBadgesAndBanner(changedKey)
end
for _, root in ipairs({ Workspace, Lighting, SoundService }) do
    connectSignal(root.DescendantAdded, function(inst)
        local ok, err = pcall(Hub.applyObject, inst)
        if not ok then
            Hub.fail("Effects", err)
        end
    end)
end
local UIRefreshCallbacks = {}
function Hub.setToggle(key, value)
    if not IsScriptRunning then
        return false, "หยุดสคริปต์แล้ว"
    end
    if type(Config[key]) ~= "boolean" or type(value) ~= "boolean" then
        return false, "ต้องเป็นชื่อสวิตช์และค่าบูลีน"
    end
    if key == "AntiFall" and not value and Hub.deliveryNeedsAntiFall() then
        return false, "โหมดพักส่งไข่เป็นจังหวะจำเป็นต้องเปิดกันล้ม"
    end
    local available, reason = Hub.available(key)
    if value and not available then
        Hub.status(key, "unavailable", reason)
        updateConflictBadgesAndBanner()
        return false, reason
    end
    Config[key] = value
    if value == true and Hub.NextRun then
        Hub.NextRun[key] = 0
    end
    syncAllFeatureStates(key)
    for _, cb in ipairs(UIRefreshCallbacks) do
        Hub.refreshCallback(cb)
    end
    if value == true and IsScriptRunning and Hub.tick then
        task.spawn(function()
            pcall(Hub.tick)
        end)
    end
    return true
end
local function createSection(parent, titleText, order)
    local sectionCard = Instance.new("Frame")
    sectionCard.Name = "Section_" .. titleText
    sectionCard.LayoutOrder = order
    sectionCard.Size = UDim2.new(1, 0, 0, 0)
    sectionCard.AutomaticSize = Enum.AutomaticSize.Y
    sectionCard.BackgroundColor3 = getCurrentTheme().Card
    sectionCard.BackgroundTransparency = 0.12
    sectionCard.BorderSizePixel = 0
    sectionCard.ZIndex = 12
    sectionCard.Parent = parent
    registerTheme(sectionCard, "BackgroundColor3", "Card")
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 11)
    corner.Parent = sectionCard
    local stroke = Instance.new("UIStroke")
    stroke.Color = getCurrentTheme().Border
    stroke.Thickness = 1
    stroke.Parent = sectionCard
    registerTheme(stroke, "Color", "Border")
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 12)
    pad.PaddingBottom = UDim.new(0, 12)
    pad.PaddingLeft = UDim.new(0, 14)
    pad.PaddingRight = UDim.new(0, 14)
    pad.Parent = sectionCard
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = sectionCard
    local header = Instance.new("TextLabel")
    header.LayoutOrder = 0
    header.Size = UDim2.new(1, 0, 0, 22)
    header.BackgroundTransparency = 1
    header.Font = getCurrentFont()
    header.TextSize = 15
    header.TextColor3 = getCurrentTheme().Accent
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Text = titleText
    header.ZIndex = 13
    header.Parent = sectionCard
    registerTheme(header, "TextColor3", "Accent")
    registerText(header, 15, true)
    return sectionCard
end
local function createToggle(parent, labelText, configKey, order, onChanged, settingsToggle)
    local row = Instance.new("TextButton")
    row.Name = "Toggle_" .. configKey
    row.LayoutOrder = order
    row.Size = UDim2.new(1, 0, 0, 92)
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.BackgroundColor3 = getCurrentTheme().Bg
    row.BackgroundTransparency = 0.35
    row.Text = ""
    row.AutoButtonColor = false
    row.ZIndex = 13
    row.Parent = parent
    registerTheme(row, "BackgroundColor3", "Bg")
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = row
    local lbl = Instance.new("TextLabel")
    lbl.Position = UDim2.fromOffset(12, 0)
    lbl.Size = UDim2.new(1, -156, 0, 34)
    lbl.BackgroundTransparency = 1
    lbl.Font = getCurrentFont()
    lbl.TextSize = 14
    lbl.TextColor3 = getCurrentTheme().Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.Text = labelText
    lbl.Active = false
    lbl.ZIndex = 14
    lbl.Parent = row
    registerTheme(lbl, "TextColor3", "Text")
    registerText(lbl, 14, false)
    local badgeFrame = Instance.new("Frame")
    badgeFrame.Name = "ConflictBadge"
    badgeFrame.AnchorPoint = Vector2.new(1, 0.5)
    badgeFrame.Position = UDim2.new(1, -64, 0, 17)
    badgeFrame.Size = UDim2.fromOffset(72, 20)
    badgeFrame.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
    badgeFrame.BackgroundTransparency = 0.15
    badgeFrame.BorderSizePixel = 0
    badgeFrame.Visible = false
    badgeFrame.Active = false
    badgeFrame.ZIndex = 14
    badgeFrame.Parent = row
    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(1, 0)
    badgeCorner.Parent = badgeFrame
    local badgeLbl = Instance.new("TextLabel")
    badgeLbl.Size = UDim2.new(1, -10, 1, 0)
    badgeLbl.Position = UDim2.fromOffset(5, 0)
    badgeLbl.BackgroundTransparency = 1
    badgeLbl.Font = getCurrentFont()
    badgeLbl.TextSize = 11
    badgeLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    badgeLbl.TextTruncate = Enum.TextTruncate.AtEnd
    badgeLbl.Text = ""
    badgeLbl.Active = false
    badgeLbl.ZIndex = 15
    badgeLbl.Parent = badgeFrame
    registerText(badgeLbl, 11, true)
    badgeFrame.Visible = false
    local description = Instance.new("TextLabel")
    description.Name = "FeatureStatus"
    description.Position = UDim2.fromOffset(12, 36)
    description.Size = UDim2.new(1, -24, 0, 48)
    description.AutomaticSize = Enum.AutomaticSize.Y
    description.BackgroundTransparency = 1
    description.Font = getCurrentFont()
    description.TextSize = 11
    description.TextColor3 = getCurrentTheme().SubText
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.TextYAlignment = Enum.TextYAlignment.Top
    description.TextWrapped = true
    description.ZIndex = 14
    description.Parent = row
    registerTheme(description, "TextColor3", "SubText")
    registerText(description, 11, false)
    ToggleConflictBadges[configKey] = {
        Frame = badgeFrame,
        Label = badgeLbl,
        Description = description,
        Row = row,
        Settings = settingsToggle,
    }
    local switchBg = Instance.new("Frame")
    switchBg.AnchorPoint = Vector2.new(1, 0.5)
    switchBg.Position = UDim2.new(1, -12, 0, 17)
    switchBg.Size = UDim2.fromOffset(44, 22)
    switchBg.BorderSizePixel = 0
    switchBg.Active = false
    switchBg.ZIndex = 14
    switchBg.Parent = row
    local swCorner = Instance.new("UICorner")
    swCorner.CornerRadius = UDim.new(1, 0)
    swCorner.Parent = switchBg
    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.Size = UDim2.fromOffset(16, 16)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Active = false
    knob.ZIndex = 15
    knob.Parent = switchBg
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    local function updateVisual()
        local isOn = Hub.featureEnabled(configKey)
        local theme = getCurrentTheme()
        switchBg.BackgroundColor3 = isOn and theme.Accent or theme.Border
        knob.Position = isOn and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
    end
    bindClick(row, function()
        local ok, reason = Hub.setToggle(configKey, not Hub.featureEnabled(configKey))
        if not ok then
            notifyThai(reason)
            return
        end
        if onChanged then
            task.spawn(onChanged, Hub.featureEnabled(configKey))
        end
    end)
    table.insert(UIRefreshCallbacks, updateVisual)
    updateVisual()
    return updateVisual
end
local function createNumericInput(parent, labelText, unitText, configKey, minVal, maxVal, order, onChanged)
    local container = Instance.new("Frame")
    container.Name = "Number_" .. configKey
    container.LayoutOrder = order
    container.Size = UDim2.new(1, 0, 0, 52)
    container.BackgroundColor3 = getCurrentTheme().Bg
    container.BackgroundTransparency = 0.35
    container.BorderSizePixel = 0
    container.ZIndex = 13
    container.Parent = parent
    registerTheme(container, "BackgroundColor3", "Bg")
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    local label = Instance.new("TextLabel")
    label.Position = UDim2.fromOffset(12, 4)
    label.Size = UDim2.new(0.62, -12, 1, -8)
    label.BackgroundTransparency = 1
    label.Font = getCurrentFont()
    label.TextSize = 14
    label.TextColor3 = getCurrentTheme().Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Text = labelText
    label.ZIndex = 14
    label.Parent = container
    registerTheme(label, "TextColor3", "Text")
    registerText(label, 14, false)
    local box = Instance.new("TextBox")
    box.Name = "Value_" .. configKey
    box.ClearTextOnFocus = false
    box.AnchorPoint = Vector2.new(1, 0.5)
    box.Position = UDim2.new(1, -12, 0.5, 0)
    box.Size = UDim2.new(0.36, 0, 0, 32)
    box.BackgroundColor3 = getCurrentTheme().AccentSoft
    box.BackgroundTransparency = 0.3
    box.BorderSizePixel = 0
    box.Font = getCurrentFont()
    box.TextSize = 13
    box.TextColor3 = getCurrentTheme().Text
    box.TextXAlignment = Enum.TextXAlignment.Center
    box.ZIndex = 14
    box.Parent = container
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = box
    registerTheme(box, "BackgroundColor3", "AccentSoft")
    registerTheme(box, "TextColor3", "Text")
    registerText(box, 13, true)
    local function refresh()
        box.Text = tostring(Config[configKey])
        box.PlaceholderText = "พิมพ์ตัวเลข".. (unitText ~= "" and (" • " .. unitText) or "")
    end
    connectSignal(box.FocusLost, function()
        local value = normalizeNumber(configKey, tonumber(((box.Text or ""):gsub("[%s,]", ""))))
        if not value then
            refresh()
            notifyThai("กรอกตัวเลขที่ถูกต้อง")
            return
        end
        Config[configKey] = value
        if onChanged then
            onChanged(value)
        end
        refresh()
        syncAllFeatureStates(configKey)
    end)
    table.insert(UIRefreshCallbacks, refresh)
    refresh()
    return container
end
local function createDropdown(parent, labelText, optionsList, getSelectedText, onSelectOption, order, isSelected)
    local wrapper = Instance.new("Frame")
    wrapper.Name = "Dropdown_" .. labelText
    wrapper.LayoutOrder = order
    wrapper.Size = UDim2.new(1, 0, 0, 0)
    wrapper.AutomaticSize = Enum.AutomaticSize.Y
    wrapper.BackgroundColor3 = getCurrentTheme().Bg
    wrapper.BackgroundTransparency = 0.35
    wrapper.BorderSizePixel = 0
    wrapper.ZIndex = 13
    wrapper.Parent = parent
    registerTheme(wrapper, "BackgroundColor3", "Bg")
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = wrapper
    local wrapLayout = Instance.new("UIListLayout")
    wrapLayout.SortOrder = Enum.SortOrder.LayoutOrder
    wrapLayout.Padding = UDim.new(0, 4)
    wrapLayout.Parent = wrapper
    local headerBtn = Instance.new("TextButton")
    headerBtn.Name = "DropdownHeader"
    headerBtn.LayoutOrder = 1
    headerBtn.Size = UDim2.new(1, 0, 0, 36)
    headerBtn.BackgroundTransparency = 1
    headerBtn.Text = ""
    headerBtn.AutoButtonColor = false
    headerBtn.ZIndex = 14
    headerBtn.Parent = wrapper
    local lbl = Instance.new("TextLabel")
    lbl.Position = UDim2.fromOffset(12, 0)
    lbl.Size = UDim2.new(0.48, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = getCurrentFont()
    lbl.TextSize = 14
    lbl.TextColor3 = getCurrentTheme().Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = labelText
    lbl.Active = false
    lbl.ZIndex = 15
    lbl.Parent = headerBtn
    registerTheme(lbl, "TextColor3", "Text")
    registerText(lbl, 14, false)
    local selectedLbl = Instance.new("TextLabel")
    selectedLbl.AnchorPoint = Vector2.new(1, 0)
    selectedLbl.Position = UDim2.new(1, -12, 0, 0)
    selectedLbl.Size = UDim2.new(0.5, -16, 1, 0)
    selectedLbl.BackgroundTransparency = 1
    selectedLbl.Font = getCurrentFont()
    selectedLbl.TextSize = 13
    selectedLbl.TextColor3 = getCurrentTheme().Accent
    selectedLbl.TextXAlignment = Enum.TextXAlignment.Right
    selectedLbl.Active = false
    selectedLbl.ZIndex = 15
    selectedLbl.Parent = headerBtn
    registerTheme(selectedLbl, "TextColor3", "Accent")
    registerText(selectedLbl, 13, true)
    local listContainer = Instance.new("Frame")
    listContainer.LayoutOrder = 2
    listContainer.Size = UDim2.new(1, 0, 0, 148)
    listContainer.BackgroundTransparency = 1
    listContainer.Visible = false
    listContainer.ZIndex = 15
    listContainer.Parent = wrapper
    local listHolder = Instance.new("ScrollingFrame")
    listHolder.Position = UDim2.fromOffset(8, 0)
    listHolder.Size = UDim2.new(1, -16, 1, -6)
    listHolder.BackgroundColor3 = getCurrentTheme().Sidebar
    listHolder.BorderSizePixel = 0
    listHolder.ScrollBarThickness = 4
    listHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
    listHolder.ZIndex = 16
    listHolder.Parent = listContainer
    registerTheme(listHolder, "BackgroundColor3", "Sidebar")
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 8)
    listCorner.Parent = listHolder
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = listHolder
    local listPad = Instance.new("UIPadding")
    listPad.PaddingTop = UDim.new(0, 6)
    listPad.PaddingBottom = UDim.new(0, 6)
    listPad.PaddingLeft = UDim.new(0, 6)
    listPad.PaddingRight = UDim.new(0, 6)
    listPad.Parent = listHolder
    local function updateHeader()
        selectedLbl.Text = getSelectedText() .. (listContainer.Visible and " ▲" or " ▼")
    end
    local function rebuildOptions()
        for _, ch in ipairs(listHolder:GetChildren()) do
            if ch:IsA("TextButton") then
                ch:Destroy()
            end
        end
        local items = type(optionsList) == "function" and optionsList() or optionsList
        local isShortList = (#items <= 6)
        listHolder.ScrollingEnabled = not isShortList
        local calcH = isShortList and math.max(#items * 32 + 12, 44) or math.clamp(#items * 32 + 12, 44, 160)
        listContainer.Size = UDim2.new(1, 0, 0, calcH + 6)
        for idx, item in ipairs(items) do
            local optText = type(item) == "table" and item.name or tostring(item)
            local optBtn = Instance.new("TextButton")
            optBtn.LayoutOrder = idx
            optBtn.Size = UDim2.new(1, 0, 0, 28)
            optBtn.BackgroundColor3 = getCurrentTheme().Card
            optBtn.BackgroundTransparency = 0.15
            optBtn.Font = getCurrentFont()
            optBtn.TextSize = 13 * Config.FontSize / 14
            optBtn.TextColor3 = getCurrentTheme().Text
            optBtn.Text = isSelected and isSelected(item) and ("✓ " .. optText) or optText
            optBtn.AutoButtonColor = false
            optBtn.ZIndex = 17
            optBtn.Parent = listHolder
            local optCorner = Instance.new("UICorner")
            optCorner.CornerRadius = UDim.new(0, 6)
            optCorner.Parent = optBtn
            bindClick(optBtn, function()
                onSelectOption(item)
                syncAllFeatureStates()
                for _, refresh in ipairs(UIRefreshCallbacks) do
                    Hub.refreshCallback(refresh)
                end
                if isSelected then
                    local position = listHolder.CanvasPosition
                    rebuildOptions()
                    listHolder.CanvasPosition = position
                else
                    listContainer.Visible = false
                end
                updateHeader()
            end)
        end
    end
    bindClick(headerBtn, function()
        listContainer.Visible = not listContainer.Visible
        if listContainer.Visible then
            rebuildOptions()
        end
        updateHeader()
    end)
    table.insert(UIRefreshCallbacks, updateHeader)
    updateHeader()
    return { Refresh = updateHeader, Rebuild = rebuildOptions }
end
local function createFilterDropdown(parent, label, items, getSelection, order)
    createDropdown(parent, label, items, function()
        local count = 0
        for _ in pairs(getSelection()) do
            count = count + 1
        end
        return count == 0 and "ทุกตัวเลือก" or ("เลือก " .. count .. " รายการ")
    end, function(item)
        local selection = getSelection()
        if item.id == "All" then
            table.clear(selection)
        else
            selection[item.id] = not selection[item.id] or nil
        end
    end, order, function(item)
        return getSelection()[item.id] == true
    end)
end
local function createActionButton(parent, btnText, isDanger, order, onClick)
    local btn = Instance.new("TextButton")
    btn.LayoutOrder = order
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = isDanger and Color3.fromRGB(185, 28, 28) or getCurrentTheme().AccentSoft
    btn.Font = getCurrentFont()
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = btnText
    btn.AutoButtonColor = false
    btn.ZIndex = 13
    btn.Parent = parent
    if not isDanger then
        registerTheme(btn, "BackgroundColor3", "AccentSoft")
    end
    registerText(btn, 14, true)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    bindClick(btn, function()
        if onClick then
            onClick()
        end
    end)
    return btn
end
local function applyThemeAndTypography()
    local theme = getCurrentTheme()
    local font = getCurrentFont()
    MainWindow.BackgroundTransparency = math.clamp(Config.BackgroundTransparency / 100, 0, 1)
    MainScale.Scale = Config.GuiScalePercent / 100
    if BlurEffect then
        BlurEffect.Enabled = IsWindowOpen and Config.BackgroundBlur
    end
    for _, entry in ipairs(ThemeRegistry) do
        if entry.Instance and entry.Instance.Parent and theme[entry.Role] then
            entry.Instance[entry.Property] = theme[entry.Role]
        end
    end
    for _, entry in ipairs(TextRegistry) do
        if entry.Instance and entry.Instance.Parent then
            entry.Instance.Font = font
            entry.Instance.TextSize = math.clamp(entry.BaseSize * Config.FontSize / 14, 1, 100)
        end
    end
    if CurrentTabName then
        selectTab(CurrentTabName)
    end
    for _, cb in ipairs(UIRefreshCallbacks) do
        Hub.refreshCallback(cb)
    end
end
Hub.ModuleSpecs = {
    Ragdoll = { "Shared", "Modules", "Ragdoll" },
    PlacedEggRenderer = { "Shared", "Eggs", "PlacedEggRenderer" },
    Remotes = { "Shared", "Remotes" },
    Save = { "Shared", "Save" },
    Preferences = { "Shared", "Preferences" },
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
    RarityData = { "Data", "Rarity" },
    RaritiesLegacy = { "Data", "Rarities" },
    MutationsCatalog = { "Shared", "Modules", "Mutations", "Catalog" },
    WispQuestsData = { "Data", "WispQuests" },
    WispProgression = { "Shared", "Modules", "WispProgression" },
    BanjoCricketData = { "Data", "BanjoCricket" },
    CursedIslandWarsData = { "Data", "CursedIslandWars" },
    FishingData = { "Data", "FishingMastery" },
    AlienLagoonData = { "Shared", "Util", "AlienRods" },
    AlienGateData = { "Data", "UFOSightings" },
    BossEventData = { "Data", "BossEvent" },
    BossMasteryData = { "Data", "BossMastery" },
    BeanstalkData = { "Data", "BeanstalkEvent" },
    LightVsDarknessData = { "Data", "LightVsDarkness" },
    SammyEventData = { "Data", "SammyEvent" },
    MonsterParasiteData = { "Data", "MonsterParasite" },
    GhostDogQuestData = { "Data", "GhostDogQuest" },
    PetWheelData = { "Data", "PetWheel" },
    RiftData = { "Data", "Rift" },
    ScrambleTradeInData = { "Data", "ScrambleTradeIn" },
    SakuraData = { "Data", "Sakura" },
    GearsData = { "Data", "Gears" },
    BasesData = { "Data", "Bases" },
    AdminAbuseEggData = { "Data", "AdminAbuseEgg" },
    RaceRallyData = { "Data", "RaceRally" },
    MountRaceData = { "Data", "MountRace" },
    TheHollowData = { "Data", "TheHollow" },
}
function Hub.installModule(name, value)
    if name == "Ragdoll" then
        Hub.Ragdoll = value
    elseif name == "PlacedEggRenderer" then
        Hub.PlacedEggRenderer = value
    elseif name == "Remotes" then
        Remotes = value
    elseif name == "Save" then
        Save = value
        if Save.Watch then
            local ok, signal = pcall(Save.Watch, "EquippedAssets")
            if ok and signal then
                connectSignal(signal, function()
                    Hub.EquipRevision = Hub.EquipRevision + 1
                end)
            end
        end
    elseif name == "Preferences" then
        Preferences = value
    elseif name == "EggRecords" then
        EggRecords = value
    elseif name == "AssetItems" then
        AssetItems = value
    elseif name == "AreaEggSlotIdentity" then
        AreaEggSlotIdentity = value
    elseif name == "EggState" then
        EggState = value
        if value.CarryChanged then
            connectSignal(value.CarryChanged, function(state)
                Hub.CarryEventRevision = (Hub.CarryEventRevision or 0) + 1
                Hub.CarryEvent = { State = state, Revision = Hub.CarryEventRevision, At = os.clock() }
                if Hub.onCarryChanged then
                    Hub.onCarryChanged(state)
                end
            end)
        end
        if value.ResetCountdown then
            connectSignal(value.ResetCountdown, function(sequence)
                if type(sequence) == "table" and type(sequence.DayStartsAt) == "number" then
                    Hub.FieldResetDay = sequence.DayStartsAt
                end
            end)
        end
        if value.FieldClaimed then
            connectSignal(value.FieldClaimed, function(feedback)
                local cycle, root = Hub.CarryCycle, getLocalRoot()
                if cycle and cycle.HadCarry and root and not Hub.inGameplay(root.Position) and (type(feedback) ~= "table" or not feedback.AssetCategory or not cycle.Record.AssetCategory or feedback.AssetCategory == cycle.Record.AssetCategory) then
                    cycle.Claimed = true
                end
            end)
        end
    elseif name == "PlotState" then
        PlotState = value
    elseif name == "BaseUpgrade" then
        BaseUpgrade = value
    elseif name == "TreadmillsData" then
        TreadmillsData = value
    elseif name == "TrailsData" or name == "FuseKernel" or name == "Mutations" or name == "MutationsCatalog" or name == "GameplayBalance" or name == "EggLimits" or name == "TreadmillUtil" or name == "GuardEscapeRequirement" or name == "GuardChasePolicy" or name == "GuardsData" or name == "AreaEggCycle" or name == "AreaEggResetCycle" or name == "ServerClock" or name == "WispQuestsData" or name == "WispProgression" or name == "BanjoCricketData" or name == "CursedIslandWarsData" or name == "FishingData" or name == "AlienLagoonData" or name == "AlienGateData" or name == "BossEventData" or name == "BossMasteryData" or name == "BeanstalkData" or name == "LightVsDarknessData" or name == "SammyEventData" or name == "MonsterParasiteData" or name == "GhostDogQuestData" or name == "PetWheelData" or name == "RiftData" or name == "ScrambleTradeInData" or name == "SakuraData" or name == "GearsData" or name == "BasesData" or name == "AdminAbuseEggData" or name == "RaceRallyData" or name == "MountRaceData" or name == "TheHollowData" then
        Hub[name] = value
        if (name == "Mutations" or name == "MutationsCatalog") and type(value) == "table" then
            local allMuts = type(value.All) == "function" and value.All() or value.Catalog or value.ById or value
            if type(allMuts) == "table" then
                local seenMut = {}
                for _, item in ipairs(MUTATION_LIST) do
                    seenMut[item.id] = true
                end
                local dynamicMuts = {}
                for mId, mSpec in pairs(allMuts) do
                    if type(mId) == "string" and type(mSpec) == "table" and not seenMut[mId] then
                        local lbl = THAI_LOCALE.Mutation[mId] or mSpec.Label or mSpec.DisplayName or mId
                        seenMut[mId] = true
                        MUTATION_THAI_BY_ID[mId] = lbl
                        table.insert(dynamicMuts, {
                            id = mId,
                            name = lbl,
                            scalar = tonumber(mSpec.EarningsScalar) or 1,
                        })
                    end
                end
                table.sort(dynamicMuts, function(a, b)
                    if a.scalar == b.scalar then
                        return a.id < b.id
                    end
                    return a.scalar < b.scalar
                end)
                for _, item in ipairs(dynamicMuts) do
                    table.insert(MUTATION_LIST, { id = item.id, name = item.name })
                end
            end
        end
    elseif name == "AreasData" then
        Hub.AreasData = value
        local dir = type(value) == "table" and (value.Directory or value.Configs or value.Areas or value) or nil
        if type(dir) == "table" then
            local entries = {}
            for aId, aSpec in pairs(dir) do
                if type(aId) == "string" and type(aSpec) == "table" and aId ~= "All" then
                    local orderNum = tonumber(aSpec.ProgressionOrder or aSpec.Order) or (type(aSpec.Rarity) == "table" and tonumber(aSpec.Rarity.Rank)) or 999
                    local lbl = THAI_LOCALE.Area[aId] or aSpec.DisplayName or aSpec.Name or aId
                    AREA_THAI_BY_ID[aId] = lbl
                    table.insert(entries, { id = aId, name = lbl, order = orderNum })
                end
            end
            table.sort(entries, function(a, b)
                if a.order == b.order then
                    return a.id < b.id
                end
                return a.order < b.order
            end)
            table.clear(AREA_LIST)
            table.insert(AREA_LIST, { id = "All", name = THAI_LOCALE.Area.All, order = 0 })
            for idx, item in ipairs(entries) do
                item.order = idx
                table.insert(AREA_LIST, item)
            end
        end
    elseif name == "RarityData" or name == "RaritiesLegacy" then
        Hub.RarityData = value
        local rMap = type(value) == "table" and (value.Rarities or value.Directory or value) or nil
        if type(rMap) == "table" then
            local entries = {}
            for rId, rSpec in pairs(rMap) do
                if type(rId) == "string" and type(rSpec) == "table" and rId ~= "All" and rId ~= "Prismatic" then
                    local entry = {
                        id = rId,
                        name = THAI_LOCALE.Rarity[rId] or rSpec.DisplayName or rId,
                        rank = tonumber(rSpec.Rank or rSpec.Order) or 1,
                        color = rSpec.Color or Color3.fromRGB(210, 210, 210),
                    }
                    RARITY_BY_ID[rId] = entry
                    table.insert(entries, entry)
                end
            end
            table.sort(entries, function(a, b)
                if a.rank == b.rank then
                    return a.id < b.id
                end
                return a.rank < b.rank
            end)
            table.clear(RARITY_LIST)
            local allEntry = { id = "All", name = THAI_LOCALE.Rarity.All, rank = 0, color = Color3.fromRGB(255, 255, 255) }
            RARITY_BY_ID.All = allEntry
            table.insert(RARITY_LIST, allEntry)
            for _, entry in ipairs(entries) do
                table.insert(RARITY_LIST, entry)
            end
        end
    elseif name == "AssetsData" then
        AssetsData = value
        if type(value.Directory) == "table" then
            local entries = {}
            for id, data in pairs(value.Directory) do
                local rRank = type(data.Rarity) == "table" and tonumber(data.Rarity.Rank or data.Rarity.Order) or 99
                local earn = tonumber(data.EarningRate) or 0
                local thaiName = translateSpeciesToThai(id, data.DisplayName)
                table.insert(entries, {
                    id = id,
                    name = thaiName,
                    order = rRank * 1e9 + earn,
                })
                local rarity = data.Rarity
                if rarity and rarity._id and RARITY_BY_ID[rarity._id] and type(rarity.Rank) == "number" then
                    RARITY_BY_ID[rarity._id].rank = rarity.Rank
                end
                if rarity and rarity._id and not RARITY_BY_ID[rarity._id] then
                    local entry = {
                        id = rarity._id,
                        name = THAI_LOCALE.Rarity[rarity._id] or rarity.DisplayName or rarity._id,
                        rank = rarity.Order or rarity.Rank or 0,
                        color = rarity.Color,
                    }
                    RARITY_BY_ID[entry.id] = entry
                    table.insert(RARITY_LIST, entry)
                end
            end
            table.sort(entries, function(a, b)
                if a.order == b.order then
                    return a.id < b.id
                end
                return a.order < b.order
            end)
            table.clear(SPECIES_LIST)
            table.clear(SPECIES_BY_ID)
            local all = { id = "All", name = "ทุกสายพันธุ์", order = 0 }
            table.insert(SPECIES_LIST, all)
            SPECIES_BY_ID.All = all
            for index, entry in ipairs(entries) do
                entry.order = index
                table.insert(SPECIES_LIST, entry)
                SPECIES_BY_ID[entry.id] = entry
            end
        end
    end
end
function Hub.loadModules()
    for name, path in pairs(Hub.ModuleSpecs) do
        local status = Hub.Modules[name]
        if not status or (status.State ~= "ready" and status.State ~= "loading" and os.clock() >= status.RetryAt) then
            local inst = ReplicatedStorage
            for _, segment in ipairs(path) do
                inst = inst and inst:FindFirstChild(segment)
            end
            if not inst then
                Hub.Modules[name] = { State = "missing", RetryAt = os.clock() + 2 }
            else
                local pending = {
                    State = "loading",
                    StartedAt = os.clock(),
                    RetryAt = os.clock() + 4,
                }
                Hub.Modules[name] = pending
                task.spawn(function()
                    local ok, value = pcall(require, inst)
                    if not IsScriptRunning then
                        return
                    end
                    if ok and type(value) == "table" then
                        local assigned, err = pcall(Hub.installModule, name, value)
                        if assigned then
                            pending.State = "ready"
                        else
                            pending.State = "error"
                            pending.Error = tostring(err)
                            Hub.fail("Modules", name .. ": " .. tostring(err))
                        end
                    else
                        pending.State = "error"
                        pending.Error = tostring(value)
                    end
                end)
            end
        end
    end
end
Hub.loadModules()
local function getSpeciesThaiName(category)
    local item = SPECIES_BY_ID[category]
    return item and item.name or tostring(category or "ไม่ทราบสายพันธุ์")
end
local function getEggRarityInfo(category)
    local data = AssetsData and AssetsData.Directory and AssetsData.Directory[category]
    local rarity = data and data.Rarity
    return rarity and RARITY_BY_ID[rarity._id] or { id = "Unknown", name = "ไม่ทราบระดับ", rank = -1 }
end
local function getEggWeightKg(category, scale)
    if EggRecords and EggRecords.WeightKgForScale and type(scale) == "number" and scale > 0 then
        local ok, value = pcall(EggRecords.WeightKgForScale, category, scale)
        if ok and type(value) == "number" then
            return value
        end
    end
    return nil
end
local function getEggEstimatedValue(record)
    if not record then
        return nil
    end
    if EggRecords and EggRecords.SellPrice then
        local saved = record
        if EggRecords.Encode then
            local ok, encoded = pcall(EggRecords.Encode, record)
            if ok and encoded then
                saved = encoded
            end
        end
        local ok, value = pcall(EggRecords.SellPrice, saved)
        if ok and type(value) == "number" then
            return value
        end
    end
    return nil
end
local function getMutationThaiString(mutations, baseMutation)
    local labels, seen = {}, {}
    local function add(id)
        if type(id) == "string" and id ~= "" and id ~= "None" and not seen[id] then
            seen[id] = true
            table.insert(labels, MUTATION_THAI_BY_ID[id] or id)
        end
    end
    add(baseMutation)
    if type(mutations) == "table" then
        for k, v in pairs(mutations) do
            local id = type(v) == "string" and v or (v == true and type(k) == "string" and k or nil)
            if id then
                add(id)
            end
        end
    end
    return #labels > 0 and table.concat(labels, " + ") or "ปกติ"
end
local function recordMatchesMutationFilter(record, filter)
    if filter == "All" then
        return true
    end
    local seen = {}
    if type(record.BaseMutation) == "string" and record.BaseMutation ~= "" and record.BaseMutation ~= "None" then
        seen[record.BaseMutation] = true
    end
    if type(record.Mutations) == "table" then
        for k, v in pairs(record.Mutations) do
            local id = type(v) == "string" and v or (v == true and type(k) == "string" and k or nil)
            if type(id) == "string" and id ~= "" and id ~= "None" then
                seen[id] = true
            end
        end
    end
    if record.HasParasite then
        seen.Monstrous = true
    end
    if filter == "Any" then
        return next(seen) ~= nil
    end
    if filter == "None" then
        return next(seen) == nil
    end
    return seen[filter] == true
end
local function getPlayerSaveData()
    if Save and Save.Peek then
        local ok, data = pcall(Save.Peek, LocalPlayer)
        if ok and type(data) == "table" then
            return data
        end
    end
    return nil
end
local function filterAllows(selection, id)
    return next(selection) == nil or selection[id] == true
end
function Hub.eggFarmMetrics(record)
    local asset = AssetsData and AssetsData.Directory and AssetsData.Directory[record.AssetCategory]
    local rarity = asset and asset.Rarity
    local info = getEggRarityInfo(record.AssetCategory)
    local scale = math.max(0, tonumber(record.AssetScale) or 1)
    local multiplier = 1
    if Hub.Mutations and Hub.Mutations.EarningsFor then
        local ok, result = pcall(Hub.Mutations.EarningsFor, type(record.Mutations) == "table" and record.Mutations or {})
        if ok and type(result) == "number" then
            multiplier = result
        end
    end
    local scaleFactor = scale > 5 and (scale / 5) ^ 1.2 * 19.637875755794113 or scale ^ 1.85
    return {
        Scale = scale,
        Mutation = multiplier,
        Rarity = tonumber(rarity and (rarity.RarityNumber or rarity.Rank)) or info.rank,
        RarityId = rarity and rarity._id or info.id,
        Income = (tonumber(asset and asset.EarningRate) or 0) * scaleFactor * multiplier,
    }
end
function Hub.isSpeciesUnlockedInIndex(speciesId)
    if type(speciesId) ~= "string" then
        return false
    end
    local data = getPlayerSaveData()
    if type(data) ~= "table" then
        return false
    end
    for _, key in ipairs({ "Index", "PetIndex", "Collection", "Dex", "UnlockedPets", "DiscoveredPets" }) do
        local tbl = data[key]
        if type(tbl) == "table" then
            if tbl[speciesId] ~= nil and tbl[speciesId] ~= false and tbl[speciesId] ~= 0 then
                return true
            end
            if type(tbl.Pets) == "table" and tbl.Pets[speciesId] then
                return true
            end
            if type(tbl.Unlocked) == "table" and tbl.Unlocked[speciesId] then
                return true
            end
        end
    end
    return false
end
function Hub.isSpeciesSubmittedInLab(speciesId)
    if type(speciesId) ~= "string" then
        return false
    end
    local data = getPlayerSaveData()
    if type(data) ~= "table" then
        return false
    end
    for _, key in ipairs({ "DrScramble", "Lab", "DrScrambleLab", "SubmittedPets", "Events" }) do
        local tbl = data[key]
        if type(tbl) == "table" then
            if tbl[speciesId] ~= nil and tbl[speciesId] ~= false and tbl[speciesId] ~= 0 then
                return true
            end
            if type(tbl.Submitted) == "table" and tbl.Submitted[speciesId] then
                return true
            end
            if type(tbl.Completed) == "table" and tbl.Completed[speciesId] then
                return true
            end
        end
    end
    return false
end
local function passesStealFilter(record, metrics)
    if type(record) ~= "table" or type(record.AssetCategory) ~= "string" then
        return false
    end
    if type(record.Uid) == "string" and Hub.StealSkippedUids[record.Uid] then
        return false
    end
    if Hub.StealForceUid == record.Uid or Hub.StealPins[record.Uid] then
        return true
    end
    if Config.StealOnlyMissingIndex and Hub.isSpeciesUnlockedInIndex(record.AssetCategory) then
        return false
    end
    if Config.StealOnlyMissingLab and Hub.isSpeciesSubmittedInLab(record.AssetCategory) then
        return false
    end
    if not filterAllows(Config.StealAreas, record.AreaId) or not filterAllows(Config.StealSpecies, record.AssetCategory) then
        return false
    end
    if next(Config.StealMutations or {}) ~= nil then
        local matchedMut = false
        for mId, enabled in pairs(Config.StealMutations) do
            if enabled and recordMatchesMutationFilter(record, mId) then
                matchedMut = true
                break
            end
        end
        if not matchedMut then
            return false
        end
    end
    metrics = metrics or Hub.eggFarmMetrics(record)
    if Config.StealUseMinPrice then
        local estPrice = tonumber(getEggEstimatedValue(record)) or tonumber(metrics.Income) or 0
        if estPrice < (tonumber(Config.StealMinPrice) or 0) then
            return false
        end
    end
    if Config.StealUseMinBoost then
        local boostRarity = Config.StealMinBoostRarity and RARITY_BY_ID[Config.StealMinBoostRarity]
        if not boostRarity or metrics.Rarity >= boostRarity.rank then
            if (tonumber(metrics.Mutation) or 1) < (tonumber(Config.StealMinBoostValue) or 1) then
                return false
            end
        end
    end
    local minimum = Config.StealMinRarity ~= "All" and RARITY_BY_ID[Config.StealMinRarity]
    return (not minimum or metrics.Rarity >= minimum.rank) and filterAllows(Config.StealRarities, metrics.RarityId) and metrics.Income >= Config.StealMinIncome
end
function Hub.getSortedStealCandidates(records, now)
    now = now or os.clock()
    local order = Config.StealOrder
    local recoveryUid = Hub.CarryDropTarget and Hub.CarryDropTarget.Uid
    local candidates = {}
    local seenForced = false
    local hasAnyRecord = false
    for _, egg in pairs(records or {}) do
        hasAnyRecord = true
        if type(egg) == "table" and type(egg.Uid) == "string" and type(egg.AssetCategory) == "string" and (egg.State == "Slot" or egg.State == "Dropped") and (egg.BottomCFrame or egg.BoundsCFrame) then
            if Hub.StealForceUid == egg.Uid then
                seenForced = true
            end
            local recovering = egg.Uid == recoveryUid and egg.State == "Dropped" and now < (Hub.CarryDropTarget.RecoverUntil or math.huge)
            local retrying = egg.Uid == Hub.StealRetryUid and now < (Hub.StealRetryAt or 0)
            if not retrying and (not Hub.FinishedEggs or (Hub.FinishedEggs[egg.Uid] or 0) <= now) then
                local metrics = Hub.eggFarmMetrics(egg)
                if passesStealFilter(egg, metrics) then
                    local value = order == "PriceHigh" and (tonumber(getEggEstimatedValue(egg)) or metrics.Income or 0) or order == "Weight" and (getEggWeightKg(egg.AssetCategory, metrics.Scale) or 0) or order == "Mutation" and metrics.Mutation or order == "IncomeHigh" and metrics.Income or order == "IncomeLow" and -metrics.Income or metrics.Rarity
                    local wispBoost = 0
                    if Config.AutoWispQuest and Hub.wispState and Hub.currentWispQuest then
                        local _, wisp = Hub.wispState()
                        local quest = Hub.currentWispQuest(wisp)
                        if type(quest) == "table" and type(quest.Match) == "table" then
                            if quest.Match.AreaId and egg.AreaId == quest.Match.AreaId then
                                wispBoost = 1
                            elseif quest.Match.Rarity and metrics.RarityId == quest.Match.Rarity then
                                wispBoost = 1
                            end
                        end
                    end
                    candidates[#candidates + 1] = {
                        egg = egg,
                        metrics = metrics,
                        value = value,
                        pinned = Hub.StealPins[egg.Uid] == true,
                        forced = Hub.StealForceUid == egg.Uid,
                        recovering = recovering,
                        manualRank = Hub.StealQueueOrder[egg.Uid] or 0,
                        wispBoost = wispBoost,
                    }
                end
            end
        end
    end
    if hasAnyRecord and Hub.StealForceUid and not seenForced then
        if not (Hub.CarryCycle and Hub.CarryCycle.Uid == Hub.StealForceUid) then
            Hub.StealForceUid = nil
        end
    end
    table.sort(candidates, function(a, b)
        if a.recovering ~= b.recovering then
            return a.recovering
        end
        if a.forced ~= b.forced then
            return a.forced
        end
        if a.pinned ~= b.pinned then
            return a.pinned
        end
        if (a.wispBoost or 0) ~= (b.wispBoost or 0) then
            return (a.wispBoost or 0) > (b.wispBoost or 0)
        end
        if a.manualRank ~= b.manualRank then
            return a.manualRank > b.manualRank
        end
        if a.value ~= b.value then
            return a.value > b.value
        end
        if a.metrics.Rarity ~= b.metrics.Rarity then
            return a.metrics.Rarity > b.metrics.Rarity
        end
        if a.metrics.Income ~= b.metrics.Income then
            return a.metrics.Income > b.metrics.Income
        end
        return a.egg.Uid < b.egg.Uid
    end)
    return candidates
end
function Hub.selectStealEgg(records, now)
    local candidates = Hub.getSortedStealCandidates(records, now)
    return candidates[1] and candidates[1].egg or nil
end
function Hub.queueMoveTop(uid)
    if type(uid) ~= "string" then
        return
    end
    local candidates = Hub.getSortedStealCandidates(Hub.FieldRecords or {}, os.clock())
    local total = #candidates
    for i, item in ipairs(candidates) do
        Hub.StealQueueOrder[item.egg.Uid] = (total - i + 1) * 10
    end
    Hub.StealQueueOrder[uid] = (total + 2) * 10
    Hub.StealSkippedUids[uid] = nil
    if Hub.refreshStealPanel then
        Hub.refreshStealPanel()
    end
end
function Hub.queueStealNow(uid)
    if type(uid) ~= "string" then
        return
    end
    Hub.StealForceUid = uid
    Hub.StealSkippedUids[uid] = nil
    Hub.StealPins[uid] = true
    Hub.queueMoveTop(uid)
    if not Config.AutoStealEgg then
        Hub.setToggle("AutoStealEgg", true)
    end
    notifyThai("ล็อกเป้าหมายขโมยไข่นี้ทันทีแล้ว")
end
function Hub.queueMoveDelta(uid, dir)
    if type(uid) ~= "string" then
        return
    end
    local candidates = Hub.getSortedStealCandidates(Hub.FieldRecords or {}, os.clock())
    local curIdx = nil
    for i, item in ipairs(candidates) do
        if item.egg.Uid == uid then
            curIdx = i
            break
        end
    end
    if not curIdx then
        return
    end
    local swapIdx = curIdx + dir
    if swapIdx < 1 or swapIdx > #candidates then
        return
    end
    local otherUid = candidates[swapIdx].egg.Uid
    if dir > 0 and Hub.StealForceUid == uid then
        Hub.StealForceUid = nil
    end
    if Hub.StealPins[otherUid] and not Hub.StealPins[uid] and dir < 0 then
        Hub.StealPins[uid] = true
    elseif Hub.StealPins[uid] and not Hub.StealPins[otherUid] and dir > 0 then
        Hub.StealPins[uid] = nil
    end
    candidates[curIdx], candidates[swapIdx] = candidates[swapIdx], candidates[curIdx]
    local total = #candidates
    for i, item in ipairs(candidates) do
        Hub.StealQueueOrder[item.egg.Uid] = (total - i + 1) * 10
    end
    if Hub.refreshStealPanel then
        Hub.refreshStealPanel()
    end
end
function Hub.queueSkipEgg(uid)
    if type(uid) ~= "string" then
        return
    end
    Hub.StealSkippedUids[uid] = true
    Hub.StealPins[uid] = nil
    if Hub.StealForceUid == uid then
        Hub.StealForceUid = nil
    end
    if Hub.refreshStealPanel then
        Hub.refreshStealPanel()
    end
end
function Hub.queueReset()
    table.clear(Hub.StealQueueOrder)
    table.clear(Hub.StealSkippedUids)
    Hub.StealForceUid = nil
    if Hub.refreshStealPanel then
        Hub.refreshStealPanel()
    end
    notifyThai("รีเซ็ตคิวและรายชื่อไข่ที่ข้ามเรียบร้อยแล้ว")
end
local function passesESPFilter(record)
    if type(record) ~= "table" or not record.AssetCategory then
        return false
    end
    if Config.ESPFilterArea ~= "All" and record.AreaId ~= Config.ESPFilterArea then
        return false
    end
    if Config.ESPFilterSpecies ~= "All" and record.AssetCategory ~= Config.ESPFilterSpecies then
        return false
    end
    if Config.ESPFilterRarity ~= "All" and getEggRarityInfo(record.AssetCategory).id ~= Config.ESPFilterRarity then
        return false
    end
    return recordMatchesMutationFilter(record, Config.ESPFilterMutation)
end
local function getFieldEggRecords()
    if EggState and EggState.ReadFieldEggs then
        local ok, snapshot = pcall(EggState.ReadFieldEggs)
        if ok and type(snapshot) == "table" then
            local recs = type(snapshot.Records) == "table" and snapshot.Records or snapshot
            Hub.FieldRecords = recs
            Hub.FieldFetchedAt = os.clock()
            return Hub.FieldRecords
        end
    end
    return os.clock() - Hub.FieldFetchedAt <= 10 and Hub.FieldRecords or {}
end
function Hub.pollSnapshots()
    if (Config.AutoStealEgg or Config.EggESP or Config.OwnBaseEggESP or Config.RevealEggContent100 or Config.AutoAttack or CurrentTabName == "ฟาร์ม") and not EggState and not Hub.FieldBusy and os.clock() - Hub.FieldFetchedAt >= 4 then
        local remote = Hub.remote("EggWorld", "AskFieldEggSnapshot", "function")
        if remote then
            Hub.FieldBusy = true
            Hub.FieldFetchedAt = os.clock()
            task.spawn(function()
                local ok, snapshot = pcall(function()
                    return remote:InvokeServer()
                end)
                Hub.FieldBusy = false
                if IsScriptRunning and ok and type(snapshot) == "table" and type(snapshot.Records) == "table" then
                    Hub.FieldRecords = snapshot.Records
                else
                    Hub.FieldRecords = {}
                end
            end)
        end
    end
end
function Hub.stealPinOptions()
    local items = { { id = "All", name = "ล้างไข่ที่ปักหมุด" } }
    for _, egg in pairs(getFieldEggRecords()) do
        if type(egg) == "table" and type(egg.Uid) == "string" and (egg.State == "Slot" or egg.State == "Dropped") then
            local label = getSpeciesThaiName(egg.AssetCategory)
            local area = AREA_THAI_BY_ID[egg.AreaId] or tostring(egg.AreaId or "")
            items[#items + 1] = { id = egg.Uid, name = label .. " • " .. area .. " • " .. egg.Uid:sub(-6) }
        end
    end
    return items
end
local function formatCompactThaiNumber(num)
    num = tonumber(num) or 0
    if num >= 1e9 then
        return string.format("%.2f พันล้าน", num / 1e9)
    elseif num >= 1e6 then
        return string.format("%.2f ล้าน", num / 1e6)
    elseif num >= 1e3 then
        return string.format("%.1f พัน", num / 1e3)
    end
    return tostring(math.floor(num + 0.5))
end
do
    do
        pcall(Hub.loadModules)
        local PageProfile = createTabPage("โปรไฟล์", 1)
        local SecProfile = createSection(PageProfile, "โปรไฟล์", 1)
        local ProfileDropdownControl
        ProfileDropdownControl = createDropdown(SecProfile, "เลือกโปรไฟล์", function()
            local names = {}
            for k in pairs(ProfilesStore) do
                table.insert(names, k)
            end
            table.sort(names)
            return names
        end, function()
            return CurrentProfileName
        end, function(chosenName)
            if ProfilesStore[chosenName] then
                CurrentProfileName = chosenName
                ActiveProfileBadge.Text = "โปรไฟล์: " .. CurrentProfileName
                applyProfileTableToConfig(ProfilesStore[chosenName], Config)
                syncAllFeatureStates()
                applyThemeAndTypography()
                local persisted, reason = saveProfilesToDisk()
                if not persisted then
                    notifyThai("เปลี่ยนโปรไฟล์ในรอบนี้เท่านั้น • ".. tostring(reason))
                end
                notifyThai("สลับไปยังโปรไฟล์ ".. chosenName.. " เรียบร้อยแล้ว")
            end
        end, 1)
        local ProfileInfoLabel = Instance.new("TextLabel")
        ProfileInfoLabel.LayoutOrder = 2
        ProfileInfoLabel.Size = UDim2.new(1, 0, 0, 26)
        ProfileInfoLabel.BackgroundTransparency = 1
        ProfileInfoLabel.Font = getCurrentFont()
        ProfileInfoLabel.TextSize = 13
        ProfileInfoLabel.TextColor3 = getCurrentTheme().SubText
        ProfileInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
        ProfileInfoLabel.Text = "โปรไฟล์ที่ใช้งานอยู่: ".. CurrentProfileName
        ProfileInfoLabel.ZIndex = 13
        ProfileInfoLabel.Parent = SecProfile
        registerTheme(ProfileInfoLabel, "TextColor3", "SubText")
        registerText(ProfileInfoLabel, 13, false)
        local function updateProfileInfoDisplay()
            local activeCount = 0
            for _, v in pairs(Config) do
                if type(v) == "boolean" and v == true then
                    activeCount = activeCount + 1
                end
            end
            ProfileInfoLabel.Text = "โปรไฟล์ปัจจุบัน: ".. CurrentProfileName.. " • เปิดใช้งานอยู่ ".. tostring(activeCount).. " รายการ"
            ActiveProfileBadge.Text = "โปรไฟล์: " .. CurrentProfileName
        end
        table.insert(UIRefreshCallbacks, updateProfileInfoDisplay)
        updateProfileInfoDisplay()
        local NewProfileBox = Instance.new("TextBox")
        NewProfileBox.LayoutOrder = 3
        NewProfileBox.Size = UDim2.new(1, 0, 0, 36)
        NewProfileBox.BackgroundColor3 = getCurrentTheme().Bg
        NewProfileBox.BackgroundTransparency = 0.25
        NewProfileBox.Font = getCurrentFont()
        NewProfileBox.TextSize = 14
        NewProfileBox.TextColor3 = getCurrentTheme().Text
        NewProfileBox.PlaceholderColor3 = getCurrentTheme().SubText
        NewProfileBox.PlaceholderText = "ตั้งชื่อโปรไฟล์ใหม่ (เว้นว่างเพื่อบันทึกทับโปรไฟล์เดิม)..."
        NewProfileBox.Text = ""
        NewProfileBox.ClearTextOnFocus = false
        NewProfileBox.ZIndex = 13
        NewProfileBox.Parent = SecProfile
        registerTheme(NewProfileBox, "BackgroundColor3", "Bg")
        registerTheme(NewProfileBox, "TextColor3", "Text")
        registerText(NewProfileBox, 14, false)
        local pBoxCorner = Instance.new("UICorner")
        pBoxCorner.CornerRadius = UDim.new(0, 8)
        pBoxCorner.Parent = NewProfileBox
        createActionButton(SecProfile, "บันทึกโปรไฟล์", false, 4, function()
            local customName = NewProfileBox.Text and NewProfileBox.Text:gsub("^%s+", ""):gsub("%s+$", "") or ""
            local targetName = (customName ~= "") and customName or CurrentProfileName
            local savedCopy = createDefaultConfig()
            applyProfileTableToConfig(Config, savedCopy)
            ProfilesStore[targetName] = savedCopy
            CurrentProfileName = targetName
            NewProfileBox.Text = ""
            ActiveProfileBadge.Text = "โปรไฟล์: " .. CurrentProfileName
            ProfileDropdownControl.Rebuild()
            ProfileDropdownControl.Refresh()
            updateProfileInfoDisplay()
            local saved, reason = saveProfilesToDisk()
            notifyThai(saved and ("บันทึกโปรไฟล์ " .. targetName .. " แล้ว") or ("เก็บโปรไฟล์ในรอบนี้แล้ว • ".. tostring(reason)))
        end)
        createActionButton(SecProfile, "ลบโปรไฟล์", true, 5, function()
            local names = {}
            for k in pairs(ProfilesStore) do
                table.insert(names, k)
            end
            table.sort(names)
            if #names <= 1 then
                notifyThai("ไม่สามารถลบโปรไฟล์สุดท้ายได้")
                return
            end
            local removedName = CurrentProfileName
            ProfilesStore[removedName] = nil
            for _, nextName in ipairs(names) do
                if nextName ~= removedName and ProfilesStore[nextName] then
                    CurrentProfileName = nextName
                    break
                end
            end
            ActiveProfileBadge.Text = "โปรไฟล์: " .. CurrentProfileName
            applyProfileTableToConfig(ProfilesStore[CurrentProfileName], Config)
            ProfileDropdownControl.Rebuild()
            ProfileDropdownControl.Refresh()
            applyThemeAndTypography()
            syncAllFeatureStates()
            local persisted, reason = saveProfilesToDisk()
            if not persisted then
                notifyThai("การลบมีผลเฉพาะรอบนี้ • ".. tostring(reason))
            end
            notifyThai("ลบโปรไฟล์ ".. removedName.. " เรียบร้อยแล้ว")
        end)
        createToggle(SecProfile, "ออโต้โหลดสคริปต์เมื่อย้ายเซิร์ฟ", "AutoLoadScript", 10, nil, true)
    end
    do
        local PageFarm = createTabPage("ฟาร์ม", 2)
        local SecFarmAuto = createSection(PageFarm, "เมนูออโต้ขโมยไข่และเป้าหมาย", 1)
        createToggle(SecFarmAuto, "ออโต้ขโมยไข่", "AutoStealEgg", 1)
        local MovementStatusLabel = Instance.new("TextLabel")
        MovementStatusLabel.Name = "MovementStatus"
        MovementStatusLabel.LayoutOrder = 2
        MovementStatusLabel.Size = UDim2.new(1, -20, 0, 52)
        MovementStatusLabel.BackgroundTransparency = 1
        MovementStatusLabel.TextWrapped = true
        MovementStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
        MovementStatusLabel.Font = getCurrentFont()
        MovementStatusLabel.TextSize = 12
        MovementStatusLabel.TextColor3 = getCurrentTheme().SubText
        MovementStatusLabel.Text = "วิ่งอัตโนมัติ • อ่านความเร็ว น้ำหนักไข่ และเทรลจากเกม"
        MovementStatusLabel.Parent = SecFarmAuto
        registerTheme(MovementStatusLabel, "TextColor3", "SubText")
        registerText(MovementStatusLabel, 12, false)
        Hub.MovementStatusLabel = MovementStatusLabel
        createDropdown(SecFarmAuto, "วิธีไปเก็บไข่", STEAL_GO_METHODS, function()
            return Config.StealGoMethod
        end, function(value)
            Config.StealGoMethod = value
            syncAllFeatureStates()
            updateConflictBadgesAndBanner()
        end, 3)
        createDropdown(SecFarmAuto, "วิธีนำไข่กลับคอก", STEAL_COLLECT_METHODS, function()
            return Config.DeliveryMethod
        end, function(value)
            Config.DeliveryMethod = value
            if Hub.DeliveryStop then
                Hub.stopDeliveryStop()
            end
            syncAllFeatureStates()
            updateConflictBadgesAndBanner()
        end, 3)
        createFilterDropdown(SecFarmAuto, "โซนที่ใช้เทเลพอร์ต", AREA_LIST, function()
            return Config.StealTeleportAreas
        end, 3)
        createNumericInput(SecFarmAuto, "จำนวนจุดพักส่งไข่", "สูงสุด 6 จุด", "StealDeliverySteps", 1, 6, 3)
        createNumericInput(SecFarmAuto, "ความเร็วตอนวิ่งไปหาไข่", "เปอร์เซ็นต์", "StealGoSpeedPercent", 50, 300, 3)
        createNumericInput(SecFarmAuto, "ความเร็วตอนอุ้มไข่กลับบ้าน", "เปอร์เซ็นต์", "StealCarrySpeedPercent", 50, 300, 3)
        createDropdown(SecFarmAuto, "ลำดับการบินค้นหาไข่", STEAL_ORDER, function()
            return listLabel(STEAL_ORDER, Config.StealOrder)
        end, function(item)
            Config.StealOrder = item.id
            if Hub.refreshStealPanel then
                Hub.refreshStealPanel()
            end
        end, 3)
        createFilterDropdown(SecFarmAuto, "โซนเป้าหมาย", AREA_LIST, function()
            return Config.StealAreas
        end, 3)
        createDropdown(SecFarmAuto, "ความหายากขั้นต่ำ", RARITY_LIST, function()
            return listLabel(RARITY_LIST, Config.StealMinRarity) or "ทุกระดับ"
        end, function(item)
            Config.StealMinRarity = item.id
            if Hub.refreshStealPanel then
                Hub.refreshStealPanel()
            end
        end, 3)
        createToggle(SecFarmAuto, "ราคาใบขั้นต่ำ", "StealUseMinPrice", 3, nil, true)
        createNumericInput(SecFarmAuto, "กำหนดราคาใบขั้นต่ำ", "เหรียญ", "StealMinPrice", 0, nil, 3)
        createNumericInput(SecFarmAuto, "รายได้ขั้นต่ำ", "เหรียญ/วินาที", "StealMinIncome", 0, nil, 3)
        createDropdown(SecFarmAuto, "บูสท์ขั้นต่ำตามความหายาก", RARITY_LIST, function()
            return listLabel(RARITY_LIST, Config.StealMinBoostRarity) or "เทวะ"
        end, function(item)
            Config.StealMinBoostRarity = item.id
            if Hub.refreshStealPanel then
                Hub.refreshStealPanel()
            end
        end, 3)
        createToggle(SecFarmAuto, "เปิดกรองบูสท์ขั้นต่ำตามความหายาก", "StealUseMinBoost", 3, nil, true)
        createNumericInput(SecFarmAuto, "ตัวคูณบูสท์ขั้นต่ำ", "เท่า", "StealMinBoostValue", 0, nil, 3)
        createFilterDropdown(SecFarmAuto, "ไปเป้าหมายที่เลือก", SPECIES_LIST, function()
            return Config.StealSpecies
        end, 3)
        createFilterDropdown(SecFarmAuto, "ความหายากที่เลือก", RARITY_LIST, function()
            return Config.StealRarities
        end, 3)
        createFilterDropdown(SecFarmAuto, "สถานะกลายพันธุ์ที่เลือก", MUTATION_LIST, function()
            return Config.StealMutations
        end, 3)
        createFilterDropdown(SecFarmAuto, "ปักหมุดไข่ให้เก็บก่อน", Hub.stealPinOptions, function()
            return Hub.StealPins
        end, 3)
        createToggle(SecFarmAuto, "บันทึกสมุดสะสมที่ยังไม่มี", "StealOnlyMissingIndex", 3)
        createToggle(SecFarmAuto, "เฉพาะสายพันธุ์ที่ยังไม่ส่งห้องทดลอง", "StealOnlyMissingLab", 3)
        createToggle(SecFarmAuto, "หลบยามอัตโนมัติ", "AntiGuard", 3)
        createToggle(SecFarmAuto, "วาร์ปไปเขตปลอดภัยเมื่ออันตราย", "WarpToSafeZone", 3)
        createToggle(SecFarmAuto, "ออโต้ไล่ล่าแย่งไข่จากผู้เล่นอื่น", "AutoChaseCarrier", 3)
        local SecFarmOther = createSection(PageFarm, "ระบบออโต้ฟาร์ม คอก ลู่วิ่ง และฟิวส์ชั่น", 3)
        createToggle(SecFarmOther, "ออโต้กลายพันธุ์", "AutoMutation", 4)
        createDropdown(SecFarmOther, "ความหายากขั้นต่ำส่งกลายพันธุ์", RARITY_LIST, function()
            return listLabel(RARITY_LIST, Config.MutationMinRarity) or "ทุกระดับ"
        end, function(item)
            Config.MutationMinRarity = item.id
        end, 4)
        createToggle(SecFarmOther, "ออโต้วางไข่ลงคอก", "AutoPlaceEgg", 5)
        createDropdown(SecFarmOther, "เงื่อนไขวางไข่ลงคอก", { "วางทันทีเมื่อมีไข่", "วางเฉพาะหลังขโมยเสร็จ" }, function()
            return Config.PlaceEggRule
        end, function(val)
            Config.PlaceEggRule = val
        end, 5)
        createToggle(SecFarmOther, "ออโต้ฟักไข่", "AutoHatchEgg", 6)
        createToggle(SecFarmOther, "ออโต้เก็บเงินในคอกและเงินออฟไลน์", "AutoCollectMoney", 6)
        createToggle(SecFarmOther, "ออโต้อัปเกรดบ้านและลู่วิ่ง", "AutoUpgradeAll", 7)
        createToggle(SecFarmOther, "ออโต้ลู่วิ่ง", "AutoTreadmill", 8)
        createToggle(SecFarmOther, "ออโต้ใช้ลู่วิ่งสายรุ้งกิจกรรมแอดมิน", "AutoAdminTreadmill", 8, nil, true)
        createNumericInput(SecFarmOther, "วิ่งบนลู่ต่อรอบ", "วินาที", "TreadmillRunSeconds", 0.1, nil, 8)
        createNumericInput(SecFarmOther, "พักหลังลงจากลู่", "วินาที", "TreadmillRestSeconds", 0.1, nil, 8)
        createToggle(SecFarmOther, "ออโต้ใส่ตัวเก่งสุด", "AutoEquipBest", 9)
        createToggle(SecFarmOther, "ออโต้ขายตัว", "AutoSellPet", 10)
        createDropdown(SecFarmOther, "โหมดการขายตัว", { "ไม่ขายตัวที่ใส่", "ขายทุกตัว" }, function()
            return Config.SellMode
        end, function(val)
            Config.SellMode = val
            updateConflictBadgesAndBanner("SellMode")
            for _, cb in ipairs(UIRefreshCallbacks) do
                Hub.refreshCallback(cb)
            end
        end, 10)
        createToggle(SecFarmOther, "ออโต้ซื้อเทรลตามลำดับราคา", "AutoBuyTrail", 11)
        createToggle(SecFarmOther, "ออโต้เครื่องฟิวส์ชั่น", "AutoFusion", 12)
        createToggle(SecFarmOther, "ออโต้แท่นบูชาฟิวส์ชั่น", "AutoShrineFusion", 12)
        createToggle(SecFarmOther, "ออโต้ล็อกดาวสัตว์เลี้ยงและไข่หายาก", "AutoFavorite", 13)
        createDropdown(SecFarmOther, "ความหายากขั้นต่ำที่ล็อกดาว", RARITY_LIST, function()
            return listLabel(RARITY_LIST, Config.FavoriteMinRarity) or "ทุกระดับ"
        end, function(item)
            Config.FavoriteMinRarity = item.id
        end, 13)
        createToggle(SecFarmOther, "ล็อกดาวเฉพาะตัวกลายพันธุ์", "FavoriteMutatedOnly", 13, nil, true)
        createToggle(SecFarmOther, "สลับลำดับความสำคัญงานฟาร์ม", "SwapFarmPriority", 14, nil, true)
        createDropdown(SecFarmOther, "ลำดับความสำคัญงานฟาร์ม", FARM_PRIORITY_ORDERS, function()
            return Config.FarmPriorityOrder
        end, function(val)
            Config.FarmPriorityOrder = val
        end, 14)
        createToggle(SecFarmOther, "รับรางวัลออฟไลน์ สมุด และกลุ่ม", "AutoClaimReward", 15)
        local SecStealPanel = createSection(PageFarm, "แผงควบคุมและคิวขโมยไข่สนาม", 2)
        do
            local heroCard = Instance.new("Frame")
            heroCard.Name = "HeroEggCard"
            heroCard.LayoutOrder = 1
            heroCard.Size = UDim2.new(1, 0, 0, 108)
            heroCard.BackgroundColor3 = getCurrentTheme().Bg
            heroCard.BackgroundTransparency = 0.25
            heroCard.BorderSizePixel = 0
            heroCard.ZIndex = 13
            heroCard.Parent = SecStealPanel
            registerTheme(heroCard, "BackgroundColor3", "Bg")
            local heroCorner = Instance.new("UICorner")
            heroCorner.CornerRadius = UDim.new(0, 8)
            heroCorner.Parent = heroCard
            local heroStroke = Instance.new("UIStroke")
            heroStroke.Thickness = 1
            heroStroke.Color = getCurrentTheme().Border
            heroStroke.Transparency = 0.25
            heroStroke.Parent = heroCard
            registerTheme(heroStroke, "Color", "Border")
            local heroTitle = Instance.new("TextLabel")
            heroTitle.Position = UDim2.fromOffset(12, 8)
            heroTitle.Size = UDim2.new(1, -135, 0, 20)
            heroTitle.BackgroundTransparency = 1
            heroTitle.Font = getCurrentFont()
            heroTitle.TextSize = 13
            heroTitle.TextXAlignment = Enum.TextXAlignment.Left
            heroTitle.TextColor3 = getCurrentTheme().Accent
            heroTitle.Text = "ไข่เป้าหมายอันดับ 1: กำลังสแกนสนาม..."
            heroTitle.ZIndex = 14
            heroTitle.Parent = heroCard
            registerTheme(heroTitle, "TextColor3", "Accent")
            registerText(heroTitle, 13, true)
            local guardPill = Instance.new("TextLabel")
            guardPill.AnchorPoint = Vector2.new(1, 0)
            guardPill.Position = UDim2.new(1, -10, 0, 8)
            guardPill.Size = UDim2.fromOffset(116, 20)
            guardPill.BackgroundColor3 = getCurrentTheme().Card
            guardPill.Font = getCurrentFont()
            guardPill.TextSize = 11
            guardPill.TextColor3 = getCurrentTheme().Success
            guardPill.Text = "หลบยาม: พร้อม"
            guardPill.ZIndex = 14
            guardPill.Parent = heroCard
            registerTheme(guardPill, "BackgroundColor3", "Card")
            registerText(guardPill, 11, true)
            local guardPillCorner = Instance.new("UICorner")
            guardPillCorner.CornerRadius = UDim.new(1, 0)
            guardPillCorner.Parent = guardPill
            local heroDetail = Instance.new("TextLabel")
            heroDetail.Position = UDim2.fromOffset(12, 30)
            heroDetail.Size = UDim2.new(1, -24, 0, 18)
            heroDetail.BackgroundTransparency = 1
            heroDetail.Font = getCurrentFont()
            heroDetail.TextSize = 12
            heroDetail.TextXAlignment = Enum.TextXAlignment.Left
            heroDetail.TextColor3 = getCurrentTheme().Text
            heroDetail.Text = "ความหายาก: - • กลายพันธุ์: - • รายได้: -/วินาที"
            heroDetail.ZIndex = 14
            heroDetail.Parent = heroCard
            registerTheme(heroDetail, "TextColor3", "Text")
            registerText(heroDetail, 12, false)
            local heroSub = Instance.new("TextLabel")
            heroSub.Position = UDim2.fromOffset(12, 50)
            heroSub.Size = UDim2.new(1, -24, 0, 18)
            heroSub.BackgroundTransparency = 1
            heroSub.Font = getCurrentFont()
            heroSub.TextSize = 12
            heroSub.TextXAlignment = Enum.TextXAlignment.Left
            heroSub.TextColor3 = getCurrentTheme().SubText
            heroSub.Text = "พื้นที่: - • น้ำหนัก: - • สถานะคิว: พร้อมทำงาน"
            heroSub.ZIndex = 14
            heroSub.Parent = heroCard
            registerTheme(heroSub, "TextColor3", "SubText")
            registerText(heroSub, 12, false)
            local stepContainer = Instance.new("Frame")
            stepContainer.Position = UDim2.fromOffset(12, 74)
            stepContainer.Size = UDim2.new(1, -24, 0, 24)
            stepContainer.BackgroundTransparency = 1
            stepContainer.ZIndex = 14
            stepContainer.Parent = heroCard
            local stepLayout = Instance.new("UIListLayout")
            stepLayout.FillDirection = Enum.FillDirection.Horizontal
            stepLayout.SortOrder = Enum.SortOrder.LayoutOrder
            stepLayout.Padding = UDim.new(0, 6)
            stepLayout.Parent = stepContainer
            local stepPills = {}
            for i = 1, 6 do
                local pill = Instance.new("TextLabel")
                pill.LayoutOrder = i
                pill.Size = UDim2.new(1 / 6, -5, 1, 0)
                pill.BackgroundColor3 = getCurrentTheme().Card
                pill.Font = getCurrentFont()
                pill.TextSize = 11
                pill.TextColor3 = getCurrentTheme().SubText
                pill.Text = "จุดพัก " .. tostring(i)
                pill.ZIndex = 15
                pill.Parent = stepContainer
                registerText(pill, 11, true)
                local pCorner = Instance.new("UICorner")
                pCorner.CornerRadius = UDim.new(0, 6)
                pCorner.Parent = pill
                stepPills[i] = pill
            end
            local queueHeader = Instance.new("Frame")
            queueHeader.LayoutOrder = 2
            queueHeader.Size = UDim2.new(1, 0, 0, 28)
            queueHeader.BackgroundTransparency = 1
            queueHeader.ZIndex = 13
            queueHeader.Parent = SecStealPanel
            local queueTitle = Instance.new("TextLabel")
            queueTitle.Size = UDim2.new(0.65, 0, 1, 0)
            queueTitle.BackgroundTransparency = 1
            queueTitle.Font = getCurrentFont()
            queueTitle.TextSize = 12
            queueTitle.TextXAlignment = Enum.TextXAlignment.Left
            queueTitle.TextColor3 = getCurrentTheme().SubText
            queueTitle.Text = "คิวไข่ในสนามตามลำดับเป้าหมาย (สูงสุด 8 อันดับแรก)"
            queueTitle.ZIndex = 14
            queueTitle.Parent = queueHeader
            registerTheme(queueTitle, "TextColor3", "SubText")
            registerText(queueTitle, 12, true)
            local resetQueueBtn = Instance.new("TextButton")
            resetQueueBtn.AnchorPoint = Vector2.new(1, 0.5)
            resetQueueBtn.Position = UDim2.new(1, 0, 0.5, 0)
            resetQueueBtn.Size = UDim2.fromOffset(128, 24)
            resetQueueBtn.BackgroundColor3 = getCurrentTheme().Card
            resetQueueBtn.Font = getCurrentFont()
            resetQueueBtn.TextSize = 11
            resetQueueBtn.TextColor3 = getCurrentTheme().Accent
            resetQueueBtn.Text = "รีเซ็ตคิวและไข่ที่ข้าม"
            resetQueueBtn.AutoButtonColor = false
            resetQueueBtn.ZIndex = 14
            resetQueueBtn.Parent = queueHeader
            registerTheme(resetQueueBtn, "BackgroundColor3", "Card")
            registerTheme(resetQueueBtn, "TextColor3", "Accent")
            registerText(resetQueueBtn, 11, true)
            local rqCorner = Instance.new("UICorner")
            rqCorner.CornerRadius = UDim.new(0, 6)
            rqCorner.Parent = resetQueueBtn
            bindClick(resetQueueBtn, function()
                Hub.queueReset()
            end)
            local rerollQueueBtn = Instance.new("TextButton")
            rerollQueueBtn.AnchorPoint = Vector2.new(1, 0.5)
            rerollQueueBtn.Position = UDim2.new(1, -134, 0.5, 0)
            rerollQueueBtn.Size = UDim2.fromOffset(78, 24)
            rerollQueueBtn.BackgroundColor3 = getCurrentTheme().Card
            rerollQueueBtn.Font = getCurrentFont()
            rerollQueueBtn.TextSize = 11
            rerollQueueBtn.TextColor3 = getCurrentTheme().Success
            rerollQueueBtn.Text = "รีรอลใหม่"
            rerollQueueBtn.AutoButtonColor = false
            rerollQueueBtn.ZIndex = 14
            rerollQueueBtn.Parent = queueHeader
            registerTheme(rerollQueueBtn, "BackgroundColor3", "Card")
            registerTheme(rerollQueueBtn, "TextColor3", "Success")
            registerText(rerollQueueBtn, 11, true)
            local rrqCorner = Instance.new("UICorner")
            rrqCorner.CornerRadius = UDim.new(0, 6)
            rrqCorner.Parent = rerollQueueBtn
            bindClick(rerollQueueBtn, function()
                if Hub.rerollPredictorsAndTrades then
                    Hub.rerollPredictorsAndTrades()
                else
                    Hub.queueReset()
                end
            end)
            local queueRows = {}
            for idx = 1, 8 do
                local row = Instance.new("Frame")
                row.Name = "QueueRow_" .. tostring(idx)
                row.LayoutOrder = idx + 2
                row.Size = UDim2.new(1, 0, 0, 36)
                row.BackgroundColor3 = getCurrentTheme().Bg
                row.BackgroundTransparency = 0.3
                row.BorderSizePixel = 0
                row.Visible = idx == 1
                row.ZIndex = 13
                row.Parent = SecStealPanel
                registerTheme(row, "BackgroundColor3", "Bg")
                local rCorner = Instance.new("UICorner")
                rCorner.CornerRadius = UDim.new(0, 7)
                rCorner.Parent = row
                local nameLbl = Instance.new("TextLabel")
                nameLbl.Position = UDim2.fromOffset(10, 2)
                nameLbl.Size = UDim2.new(1, -210, 0, 17)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Font = getCurrentFont()
                nameLbl.TextSize = 12
                nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
                nameLbl.TextColor3 = getCurrentTheme().Text
                nameLbl.Text = idx == 1 and "ยังไม่มีไข่ในสนามที่ตรงเงื่อนไขตัวกรอง" or ""
                nameLbl.ZIndex = 14
                nameLbl.Parent = row
                registerTheme(nameLbl, "TextColor3", "Text")
                registerText(nameLbl, 12, true)
                local infoLbl = Instance.new("TextLabel")
                infoLbl.Position = UDim2.fromOffset(10, 18)
                infoLbl.Size = UDim2.new(1, -210, 0, 15)
                infoLbl.BackgroundTransparency = 1
                infoLbl.Font = getCurrentFont()
                infoLbl.TextSize = 11
                infoLbl.TextXAlignment = Enum.TextXAlignment.Left
                infoLbl.TextTruncate = Enum.TextTruncate.AtEnd
                infoLbl.TextColor3 = getCurrentTheme().SubText
                infoLbl.Text = ""
                infoLbl.ZIndex = 14
                infoLbl.Parent = row
                registerTheme(infoLbl, "TextColor3", "SubText")
                registerText(infoLbl, 11, false)
                local btnHolder = Instance.new("Frame")
                btnHolder.AnchorPoint = Vector2.new(1, 0.5)
                btnHolder.Position = UDim2.new(1, -6, 0.5, 0)
                btnHolder.Size = UDim2.fromOffset(194, 24)
                btnHolder.BackgroundTransparency = 1
                btnHolder.ZIndex = 14
                btnHolder.Parent = row
                local btnList = Instance.new("UIListLayout")
                btnList.FillDirection = Enum.FillDirection.Horizontal
                btnList.HorizontalAlignment = Enum.HorizontalAlignment.Right
                btnList.VerticalAlignment = Enum.VerticalAlignment.Center
                btnList.SortOrder = Enum.SortOrder.LayoutOrder
                btnList.Padding = UDim.new(0, 4)
                btnList.Parent = btnHolder
                local rowData = {
                    frame = row,
                    nameLbl = nameLbl,
                    infoLbl = infoLbl,
                    btnHolder = btnHolder,
                    uid = nil,
                }
                local function makeQueueActionBtn(order, text, width, colorKey, onClick)
                    local b = Instance.new("TextButton")
                    b.LayoutOrder = order
                    b.Size = UDim2.fromOffset(width, 22)
                    b.BackgroundColor3 = getCurrentTheme().Card
                    b.Font = getCurrentFont()
                    b.TextSize = 11
                    b.TextColor3 = getCurrentTheme()[colorKey] or getCurrentTheme().Text
                    b.Text = text
                    b.AutoButtonColor = false
                    b.ZIndex = 15
                    b.Parent = btnHolder
                    registerTheme(b, "BackgroundColor3", "Card")
                    registerTheme(b, "TextColor3", colorKey)
                    registerText(b, 11, true)
                    local bc = Instance.new("UICorner")
                    bc.CornerRadius = UDim.new(0, 5)
                    bc.Parent = b
                    bindClick(b, function()
                        if rowData.uid then
                            onClick(rowData.uid)
                        end
                    end)
                    return b
                end
                makeQueueActionBtn(1, "ขโมยทันที", 62, "Accent", function(uid)
                    Hub.queueStealNow(uid)
                end)
                makeQueueActionBtn(2, "บนสุด", 42, "Success", function(uid)
                    Hub.queueMoveTop(uid)
                end)
                makeQueueActionBtn(3, "ขึ้น", 26, "Text", function(uid)
                    Hub.queueMoveDelta(uid, -1)
                end)
                makeQueueActionBtn(4, "ลง", 26, "Text", function(uid)
                    Hub.queueMoveDelta(uid, 1)
                end)
                makeQueueActionBtn(5, "ข้าม", 26, "Danger", function(uid)
                    Hub.queueSkipEgg(uid)
                end)
                queueRows[idx] = rowData
            end
            function Hub.refreshStealPanel(records)
                if not IsScriptRunning then
                    return
                end
                records = records or getFieldEggRecords()
                local candidates = Hub.getSortedStealCandidates(records, os.clock())
                local theme = getCurrentTheme()
                local antiGuardActive = Config.AntiGuard or Config.AutoStealEgg
                if not antiGuardActive then
                    guardPill.Text = "หลบยาม: ปิด"
                    guardPill.TextColor3 = theme.SubText
                elseif Hub.GuardDodge and Hub.GuardDodge.AvoidUntil and os.clock() < Hub.GuardDodge.AvoidUntil then
                    guardPill.Text = "หลบยาม: กำลังหลบ!"
                    guardPill.TextColor3 = theme.Warning
                else
                    guardPill.Text = "หลบยาม: เฝ้าระวัง"
                    guardPill.TextColor3 = theme.Success
                end
                local maxStops = math.clamp(tonumber(Config.StealDeliverySteps) or 3, 1, 6)
                local currentStep = tonumber(Hub.StealCurrentStep) or 0
                local deliveryActive = Hub.DeliveryStop ~= nil
                for i = 1, 6 do
                    local pill = stepPills[i]
                    pill.Visible = i <= maxStops
                    if i <= maxStops then
                        pill.Size = UDim2.new(1 / maxStops, -5, 1, 0)
                        if deliveryActive and i <= currentStep then
                            pill.BackgroundColor3 = theme.Accent
                            pill.TextColor3 = theme.Bg
                        elseif deliveryActive and i == currentStep + 1 then
                            pill.BackgroundColor3 = theme.Warning
                            pill.TextColor3 = theme.Bg
                        else
                            pill.BackgroundColor3 = theme.Card
                            pill.TextColor3 = theme.SubText
                        end
                    end
                end
                local top = candidates[1]
                if top and top.egg then
                    local egg = top.egg
                    local spName = getSpeciesThaiName(egg.AssetCategory)
                    local rarityInfo = getEggRarityInfo(egg.AssetCategory)
                    local mutName = getMutationThaiString(egg.Mutations, egg.BaseMutation)
                    local areaName = AREA_THAI_BY_ID[egg.AreaId] or tostring(egg.AreaId or "ไม่ทราบพื้นที่")
                    local weightKg = getEggWeightKg(egg.AssetCategory, top.metrics.Scale)
                    local weightText = weightKg and string.format("%.2f กก.", weightKg) or "-"
                    local statusTag = top.forced and "ล็อกเป้าหมายทันที" or (top.pinned and "ปักหมุด" or "ตามลำดับคิว")
                    heroTitle.Text = string.format("ไข่เป้าหมายอันดับ 1: %s", spName)
                    heroDetail.Text = string.format("ความหายาก: %s • กลายพันธุ์: %s • รายได้: %s/วินาที", rarityInfo.name, mutName, formatCompactThaiNumber(top.metrics.Income))
                    heroSub.Text = string.format("พื้นที่: %s • น้ำหนัก: %s • สถานะ: %s (เข้าคิว %d ฟอง)", areaName, weightText, statusTag, #candidates)
                else
                    heroTitle.Text = "ไข่เป้าหมายอันดับ 1: ไม่มีไข่ที่ตรงตัวกรองในขณะนี้"
                    heroDetail.Text = "ความหายาก: - • กลายพันธุ์: - • รายได้: -/วินาที"
                    heroSub.Text = string.format("พื้นที่: - • ข้ามแล้ว %d ฟอง • รอเกิดใหม่ในสนาม", (function()
                        local n = 0
                        for _ in pairs(Hub.StealSkippedUids) do
                            n = n + 1
                        end
                        return n
                    end)())
                end
                queueTitle.Text = string.format("คิวไข่ในสนามตามลำดับเป้าหมาย (พบ %d ฟอง)", #candidates)
                for idx = 1, 8 do
                    local rowData = queueRows[idx]
                    local item = candidates[idx]
                    if item and item.egg then
                        local egg = item.egg
                        local spName = getSpeciesThaiName(egg.AssetCategory)
                        local rarityInfo = getEggRarityInfo(egg.AssetCategory)
                        local mutName = getMutationThaiString(egg.Mutations, egg.BaseMutation)
                        local mutText = mutName ~= "ปกติ" and (" • " .. mutName) or ""
                        local areaName = AREA_THAI_BY_ID[egg.AreaId] or tostring(egg.AreaId or "")
                        local badge = item.forced and " [ขโมยทันที]" or (item.pinned and " [ปักหมุด]" or "")
                        rowData.uid = egg.Uid
                        rowData.frame.Visible = true
                        rowData.btnHolder.Visible = true
                        rowData.nameLbl.Text = string.format("#%d %s%s", idx, spName, badge)
                        rowData.infoLbl.Text = string.format("%s%s • %s/วินาที • %s", rarityInfo.name, mutText, formatCompactThaiNumber(item.metrics.Income), areaName)
                    else
                        rowData.uid = nil
                        rowData.btnHolder.Visible = false
                        if idx == 1 then
                            rowData.frame.Visible = true
                            rowData.nameLbl.Text = "ยังไม่มีไข่ในสนามที่ตรงเงื่อนไขตัวกรอง"
                            rowData.infoLbl.Text = "ปรับตัวกรองด้านล่าง หรือกดปุ่มรีเซ็ตคิวเพื่อดูไข่ทั้งหมด"
                        else
                            rowData.frame.Visible = false
                        end
                    end
                end
            end
        end
        local SecPlaceFilter = createSection(PageFarm, "ตัวกรองวางไข่", 4)
        createDropdown(SecPlaceFilter, "ลำดับวางไข่", PLACE_ORDER, function()
            return listLabel(PLACE_ORDER, Config.PlaceOrder)
        end, function(item)
            Config.PlaceOrder = item.id
        end, 1)
        createFilterDropdown(SecPlaceFilter, "ความหายากที่เลือก", RARITY_LIST, function()
            return Config.PlaceRarities
        end, 2)
        createFilterDropdown(SecPlaceFilter, "สายพันธุ์ไข่", SPECIES_LIST, function()
            return Config.PlaceSpecies
        end, 3)
        createNumericInput(SecPlaceFilter, "รายได้ขั้นต่ำ", "เหรียญ/วินาที", "PlaceMinIncome", 0, nil, 4)
    end
    do
        local PageChilldEvents = createTabPage("เควสและกิจกรรม", 3)
        local SecWisp = createSection(PageChilldEvents, "เควสภูตวิญญาณและต้นไม้มนตรา", 1)
        local WispStatusLabel = Instance.new("TextLabel")
        WispStatusLabel.LayoutOrder = 0
        WispStatusLabel.Size = UDim2.new(1, 0, 0, 38)
        WispStatusLabel.BackgroundTransparency = 1
        WispStatusLabel.Font = getCurrentFont()
        WispStatusLabel.TextSize = 12
        WispStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
        WispStatusLabel.TextWrapped = true
        WispStatusLabel.TextColor3 = getCurrentTheme().SubText
        WispStatusLabel.Text = "สถานะภูตวิญญาณ: กำลังตรวจสอบข้อมูลเควส..."
        WispStatusLabel.ZIndex = 13
        WispStatusLabel.Parent = SecWisp
        registerTheme(WispStatusLabel, "TextColor3", "SubText")
        registerText(WispStatusLabel, 12, false)
        Hub.WispStatusLabel = WispStatusLabel
        createToggle(SecWisp, "ออโต้เควสภูตวิญญาณครบวงจร", "AutoWispQuest", 1)
        createToggle(SecWisp, "ออโต้เควสสุนัขวิญญาณ", "AutoGhostDogQuest", 2)
        createToggle(SecWisp, "ออโต้สำรวจถ้ำระบายน้ำ คฤหาสน์ และโพรงมืด", "AutoSubZones", 3)
        local SecWorldEvents = createSection(PageChilldEvents, "ซากุระ ดาวตก แบนโจ ตกปลา เอเลี่ยน และสงครามเกาะ", 2)
        createToggle(SecWorldEvents, "ออโต้ซากุระ พฤกษาผลิบาน และจับผีเสื้อ", "AutoBloom", 1)
        createToggle(SecWorldEvents, "ออโต้เก็บดาวตก", "AutoShootingStar", 2)
        createToggle(SecWorldEvents, "ออโต้ให้อาหารดาวจากสัตว์เลี้ยง", "AutoFeedStar", 3)
        createToggle(SecWorldEvents, "ออโต้มินิเกมแบนโจจิ้งหรีด", "AutoBanjo", 4)
        createToggle(SecWorldEvents, "ออโต้ตกปลาและรับรางวัลมาสเตอรี", "AutoFishing", 5)
        createToggle(SecWorldEvents, "ดึงปลาเข้ากระเป๋าทันทีเมื่อทุ่นจม", "InstantFishCatch", 6)
        createToggle(SecWorldEvents, "ออโต้กิจกรรมเอเลี่ยนและบึงต่างดาว", "AutoAlien", 7)
        createToggle(SecWorldEvents, "ออโต้เข้าร่วมสงครามเกาะต้องสาป", "AutoIslandWars", 8)
        createToggle(SecWorldEvents, "ออโต้หมุนวงล้อสัตว์เลี้ยง", "AutoPetWheel", 9)
        createToggle(SecWorldEvents, "ออโต้แลกไข่รอยแยกและห้องทดลอง", "AutoRiftAndScramble", 10)
        local SecAdminAbuse = createSection(PageChilldEvents, "กิจกรรมแอดมินและบอสพิเศษ", 3)
        local AdminAbuseStatusLabel = Instance.new("TextLabel")
        AdminAbuseStatusLabel.LayoutOrder = 0
        AdminAbuseStatusLabel.Size = UDim2.new(1, 0, 0, 38)
        AdminAbuseStatusLabel.BackgroundTransparency = 1
        AdminAbuseStatusLabel.Font = getCurrentFont()
        AdminAbuseStatusLabel.TextSize = 12
        AdminAbuseStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
        AdminAbuseStatusLabel.TextWrapped = true
        AdminAbuseStatusLabel.TextColor3 = getCurrentTheme().SubText
        AdminAbuseStatusLabel.Text = "สถานะกิจกรรมแอดมิน: กำลังตรวจสอบอีเวนต์ที่เปิดอยู่ในเซิร์ฟเวอร์..."
        AdminAbuseStatusLabel.ZIndex = 13
        AdminAbuseStatusLabel.Parent = SecAdminAbuse
        registerTheme(AdminAbuseStatusLabel, "TextColor3", "SubText")
        registerText(AdminAbuseStatusLabel, 12, false)
        Hub.AdminAbuseStatusLabel = AdminAbuseStatusLabel
        createToggle(SecAdminAbuse, "ออโต้เข้าร่วมกิจกรรมแอดมินทั้งหมด", "AutoAdminAbuse", 1)
        createToggle(SecAdminAbuse, "ออโต้ต้นถั่วยักษ์และหิ่งห้อย", "AutoBeanstalk", 2)
        createToggle(SecAdminAbuse, "ออโต้ศึกแสงและเงา", "AutoLightVsDark", 3)
        createToggle(SecAdminAbuse, "ออโต้กิจกรรมแซมมี่", "AutoSammy", 4)
        createToggle(SecAdminAbuse, "ออโต้บอสสแครมเบิล บอสฟักทอง และบุกอวกาศ", "AutoBossRaid", 5)
        createToggle(SecAdminAbuse, "ออโต้มินิเกมวิ่งหนีทีเร็กซ์ ไฟแดงไฟเขียว และปรสิต", "AutoMinigameEvents", 6)
    end
    do
        local PagePredictor = createTabPage("พยากรณ์และค้นหา", 4)
        local SecEggPred = createSection(PagePredictor, "พยากรณ์ไข่และสแกนมูลค่าจริง", 1)
        local EggPredSummary = Instance.new("TextLabel")
        EggPredSummary.LayoutOrder = 1
        EggPredSummary.Size = UDim2.new(1, 0, 0, 56)
        EggPredSummary.BackgroundTransparency = 1
        EggPredSummary.Font = getCurrentFont()
        EggPredSummary.TextSize = 12
        EggPredSummary.TextXAlignment = Enum.TextXAlignment.Left
        EggPredSummary.TextWrapped = true
        EggPredSummary.TextColor3 = getCurrentTheme().Text
        EggPredSummary.Text = "พยากรณ์ไข่: รอสแกนไข่ในสนามและในคอก..."
        EggPredSummary.ZIndex = 13
        EggPredSummary.Parent = SecEggPred
        registerTheme(EggPredSummary, "TextColor3", "Text")
        registerText(EggPredSummary, 12, false)
        Hub.EggPredSummary = EggPredSummary
        local OwnerHealthSummary = Instance.new("TextLabel")
        OwnerHealthSummary.LayoutOrder = 2
        OwnerHealthSummary.Size = UDim2.new(1, 0, 0, 36)
        OwnerHealthSummary.BackgroundTransparency = 1
        OwnerHealthSummary.Font = getCurrentFont()
        OwnerHealthSummary.TextSize = 12
        OwnerHealthSummary.TextXAlignment = Enum.TextXAlignment.Left
        OwnerHealthSummary.TextWrapped = true
        OwnerHealthSummary.TextColor3 = getCurrentTheme().Accent
        OwnerHealthSummary.Text = "[พลาสม่าเป็นเจ้าของ] • [เลือดคือไม่ปกติ: ปกติ]"
        OwnerHealthSummary.ZIndex = 13
        OwnerHealthSummary.Parent = SecEggPred
        registerTheme(OwnerHealthSummary, "TextColor3", "Accent")
        registerText(OwnerHealthSummary, 12, true)
        Hub.OwnerHealthSummary = OwnerHealthSummary
        createActionButton(SecEggPred, "รีรอลใหม่และอัปเดตผลพยากรณ์ทันที", false, 3, function()
            if Hub.rerollPredictorsAndTrades then
                Hub.rerollPredictorsAndTrades()
            end
        end)
        local SecFusePred = createSection(PagePredictor, "พยากรณ์ผลฟิวส์ชั่นสัตว์เลี้ยง", 2)
        local FusePredSummary = Instance.new("TextLabel")
        FusePredSummary.LayoutOrder = 1
        FusePredSummary.Size = UDim2.new(1, 0, 0, 56)
        FusePredSummary.BackgroundTransparency = 1
        FusePredSummary.Font = getCurrentFont()
        FusePredSummary.TextSize = 12
        FusePredSummary.TextXAlignment = Enum.TextXAlignment.Left
        FusePredSummary.TextWrapped = true
        FusePredSummary.TextColor3 = getCurrentTheme().Text
        FusePredSummary.Text = "พยากรณ์ฟิวส์ชั่น: รอคำนวณคู่สัตว์เลี้ยงที่คุ้มค่าที่สุด..."
        FusePredSummary.ZIndex = 13
        FusePredSummary.Parent = SecFusePred
        registerTheme(FusePredSummary, "TextColor3", "Text")
        registerText(FusePredSummary, 12, false)
        Hub.FusePredSummary = FusePredSummary
        local SecFinder = createSection(PagePredictor, "ค้นหาไข่และสัตว์เลี้ยงเป้าหมายในเซิร์ฟเวอร์", 3)
        local FinderSummary = Instance.new("TextLabel")
        FinderSummary.LayoutOrder = 1
        FinderSummary.Size = UDim2.new(1, 0, 0, 64)
        FinderSummary.BackgroundTransparency = 1
        FinderSummary.Font = getCurrentFont()
        FinderSummary.TextSize = 12
        FinderSummary.TextXAlignment = Enum.TextXAlignment.Left
        FinderSummary.TextWrapped = true
        FinderSummary.TextColor3 = getCurrentTheme().SubText
        FinderSummary.Text = "ตัวค้นหา: รอตรวจสอบรายการไข่หายากในแผนที่..."
        FinderSummary.ZIndex = 13
        FinderSummary.Parent = SecFinder
        registerTheme(FinderSummary, "TextColor3", "SubText")
        registerText(FinderSummary, 12, false)
        Hub.FinderSummary = FinderSummary
        createActionButton(SecFinder, "สแกนและปักหมุดไข่รายได้สูงสุดทันที", false, 2, function()
            if Hub.updatePredictorsAndFinder then
                Hub.updatePredictorsAndFinder(true)
            end
        end)
    end
    do
        local PageCombat = createTabPage("ต่อสู้", 5)
        local SecPlayerMove = createSection(PageCombat, "ผู้เล่นและการเคลื่อนที่", 0)
        createToggle(SecPlayerMove, "เปิดปรับความเร็วเดินผู้เล่น", "PlayerSpeedEnabled", 1)
        createNumericInput(SecPlayerMove, "ความเร็วเดินผู้เล่น", "หน่วย/วินาที", "PlayerWalkSpeed", 16, 350, 2)
        createToggle(SecPlayerMove, "เปิดปรับพลังกระโดดผู้เล่น", "PlayerJumpEnabled", 3)
        createNumericInput(SecPlayerMove, "พลังกระโดดผู้เล่น", "หน่วย", "PlayerJumpPower", 20, 350, 4)
        createToggle(SecPlayerMove, "กระโดดกลางอากาศไม่จำกัด", "InfiniteJump", 5)
        createToggle(SecPlayerMove, "เดินทะลุกำแพงและสิ่งกีดขวาง", "Noclip", 6)
        createToggle(SecPlayerMove, "ขี่สัตว์เลี้ยงอัตโนมัติ", "AutoPetMount", 7)
        createDropdown(SecPlayerMove, "เลือกพื้นที่วาร์ป", AREA_LIST, function()
            return AREA_THAI_BY_ID[Config.TeleportTargetArea] or "ทุกพื้นที่"
        end, function(item)
            Config.TeleportTargetArea = item.id
        end, 8)
        createActionButton(SecPlayerMove, "วาร์ปไปพื้นที่ที่เลือกทันที", false, 9, function()
            if Hub.warpToArea then
                Hub.warpToArea(Config.TeleportTargetArea)
            end
        end)
        createActionButton(SecPlayerMove, "วาร์ปไปเขตปลอดภัยและคอกของตัวเอง", false, 10, function()
            if Hub.warpToSafeZone then
                Hub.warpToSafeZone(true)
            end
        end)
        local SecCombatAuto = createSection(PageCombat, "ออโต้ตี", 1)
        createToggle(SecCombatAuto, "เปิดใช้งานออโต้ตี", "AutoAttack", 1)
        createToggle(SecCombatAuto, "ถือไม้เบล", "AutoEquipBat", 2)
        createDropdown(SecCombatAuto, "โหมดการตี", {
            "ตีผู้เล่นที่เข้าใกล้",
            "ไปตีผู้เล่นที่ถือไข่",
        }, function()
            return Config.AttackMode
        end, function(val)
            Config.AttackMode = val
            updateConflictBadgesAndBanner("AttackMode")
            for _, cb in ipairs(UIRefreshCallbacks) do
                Hub.refreshCallback(cb)
            end
        end, 3)
        createDropdown(SecCombatAuto, "ล็อกเป้าหมายผู้เล่น", function()
            local list = { "ทุกคนตามโหมดการตี" }
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    list[#list + 1] = plr.Name
                end
            end
            return list
        end, function()
            return Config.AttackTargetPlayer or "ทุกคนตามโหมดการตี"
        end, function(val)
            Config.AttackTargetPlayer = val
        end, 4)
        local SecCombatDefense = createSection(PageCombat, "หลบหลีกและควบคุมตัวละคร", 2)
        createToggle(SecCombatDefense, "ปิดการชนกับดักฝั่งตัวเอง", "AntiTrap", 1)
        createToggle(SecCombatDefense, "กันล้ม", "AntiFall", 3)
        createToggle(SecCombatDefense, "กันกระเด็น", "AntiKnockback", 4)
        createToggle(SecCombatDefense, "หลบยามอัตโนมัติ", "AntiGuard", 5)
        createToggle(SecCombatDefense, "วาร์ปให้เขตปลอดภัย", "WarpToSafeZone", 6)
        createToggle(SecCombatDefense, "ป้องกันหลุดเมื่ออยู่นิ่ง", "AntiAFK", 7)
        createToggle(SecCombatDefense, "ซ่อนตัวละครของเรา", "HidePlayer", 8)
    end
    do
        local PageServer = createTabPage("เซิร์ฟเวอร์", 6)
        local SecServerMain = createSection(PageServer, "จัดการเซิร์ฟเวอร์และย้ายเซิร์ฟ", 1)
        createToggle(SecServerMain, "ออโต้โหลดสคริปต์เมื่อย้ายเซิร์ฟ", "AutoLoadScript", 1, nil, true)
        createDropdown(SecServerMain, "เลือกโหมดย้ายเซิร์ฟเวอร์", SERVER_HOP_MODES, function()
            return Config.ServerHopMode
        end, function(val)
            Config.ServerHopMode = val
        end, 2)
        createActionButton(SecServerMain, "ย้ายเซิร์ฟเวอร์ทันที", false, 3, function()
            if Hub.hopServer then
                Hub.hopServer(Config.ServerHopMode)
            end
        end)
        local JobIdRow = Instance.new("Frame")
        JobIdRow.LayoutOrder = 4
        JobIdRow.Size = UDim2.new(1, 0, 0, 38)
        JobIdRow.BackgroundTransparency = 1
        JobIdRow.ZIndex = 13
        JobIdRow.Parent = SecServerMain
        local JobIdLabel = Instance.new("TextLabel")
        JobIdLabel.Size = UDim2.new(0.38, 0, 1, 0)
        JobIdLabel.BackgroundTransparency = 1
        JobIdLabel.Font = getCurrentFont()
        JobIdLabel.TextSize = 13
        JobIdLabel.TextXAlignment = Enum.TextXAlignment.Left
        JobIdLabel.TextColor3 = getCurrentTheme().Text
        JobIdLabel.Text = "รหัสเซิร์ฟเวอร์เป้าหมาย"
        JobIdLabel.ZIndex = 14
        JobIdLabel.Parent = JobIdRow
        registerTheme(JobIdLabel, "TextColor3", "Text")
        registerText(JobIdLabel, 13, false)
        local JobIdBox = Instance.new("TextBox")
        JobIdBox.Name = "JobIdInputBox"
        JobIdBox.AnchorPoint = Vector2.new(1, 0.5)
        JobIdBox.Position = UDim2.new(1, 0, 0.5, 0)
        JobIdBox.Size = UDim2.new(0.6, 0, 0, 30)
        JobIdBox.BackgroundColor3 = getCurrentTheme().Bg
        JobIdBox.ClearTextOnFocus = false
        JobIdBox.Font = getCurrentFont()
        JobIdBox.TextSize = 12
        JobIdBox.TextColor3 = getCurrentTheme().Text
        JobIdBox.PlaceholderColor3 = getCurrentTheme().SubText
        JobIdBox.PlaceholderText = "วางรหัสเซิร์ฟเวอร์ของคุณ..."
        JobIdBox.Text = tostring(Config.TargetJobId or "")
        JobIdBox.ZIndex = 14
        JobIdBox.Parent = JobIdRow
        registerTheme(JobIdBox, "BackgroundColor3", "Bg")
        registerTheme(JobIdBox, "TextColor3", "Text")
        registerTheme(JobIdBox, "PlaceholderColor3", "SubText")
        registerText(JobIdBox, 12, false)
        local JobIdCorner = Instance.new("UICorner")
        JobIdCorner.CornerRadius = UDim.new(0, 7)
        JobIdCorner.Parent = JobIdBox
        local JobIdStroke = Instance.new("UIStroke")
        JobIdStroke.Color = getCurrentTheme().Border
        JobIdStroke.Thickness = 1
        JobIdStroke.Parent = JobIdBox
        registerTheme(JobIdStroke, "Color", "Border")
        connectSignal(JobIdBox.FocusLost, function()
            Config.TargetJobId = tostring(JobIdBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
        end)
        table.insert(UIRefreshCallbacks, function()
            if not isTextBoxFocused() then
                JobIdBox.Text = tostring(Config.TargetJobId or "")
            end
        end)
        createActionButton(SecServerMain, "เข้าเซิร์ฟเวอร์ตามรหัส", false, 5, function()
            Config.TargetJobId = tostring(JobIdBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
            if Hub.joinJobId then
                Hub.joinJobId(Config.TargetJobId)
            end
        end)
        createActionButton(SecServerMain, "คัดลอกรหัสเซิร์ฟเวอร์ปัจจุบัน", false, 6, function()
            if Hub.copyCurrentJobId then
                Hub.copyCurrentJobId()
            end
        end)
        createActionButton(SecServerMain, "รีจอยเข้าเซิร์ฟเวอร์เดิมใหม่", false, 7, function()
            if Hub.rejoinServer then
                Hub.rejoinServer()
            end
        end)
        createToggle(SecServerMain, "ออโต้เข้าใหม่เมื่อหลุดจากเกม", "AutoRejoinOnDisconnect", 8, nil, true)
        local SecAutoHop = createSection(PageServer, "ออโต้ย้ายเซิร์ฟเวอร์หาเป้าหมาย", 2)
        createToggle(SecAutoHop, "เปิดออโต้ย้ายเซิร์ฟเวอร์หาไข่เป้าหมาย", "AutoHopEnabled", 1)
        createNumericInput(SecAutoHop, "เวลารอสแกนก่อนย้ายเซิร์ฟ", "วินาที", "AutoHopIntervalSeconds", 5, 3600, 2)
        createToggle(SecAutoHop, "ย้ายเซิร์ฟเวอร์หนีเมื่อมีอันตราย", "AutoHopOnDanger", 3, nil, true)
    end
    do
        local PageRender = createTabPage("เรนเดอร์", 7)
        local SecTrapESP = createSection(PageRender, "กับดักและชิ้นส่วนกิจกรรม", 0)
        createToggle(SecTrapESP, "แสดงตำแหน่งกับดักและเครื่องรบกวนแรงโน้มถ่วง", "TrapESP", 1)
        createToggle(SecTrapESP, "แสดงตำแหน่งชิ้นส่วนที่หายไป", "LostPartESP", 2)
        createToggle(SecTrapESP, "เส้นชี้ตำแหน่งชิ้นส่วนที่หายไป", "LostPartTracker", 3)
        local SecEggReveal = createSection(PageRender, "ระบบตรวจสอบข้างในไข่", 1)
        createToggle(SecEggReveal, "แสดงข้อมูลไข่จริงจากเซิร์ฟเวอร์", "RevealEggContent100", 1)
        local SecEggESP = createSection(PageRender, "การมองเห็นไข่และไข่ในคอก", 2)
        createToggle(SecEggESP, "แสดงตำแหน่งไข่ในสนาม", "EggESP", 1)
        createToggle(SecEggESP, "แสดงข้อมูลไข่ในคอกตัวเอง", "OwnBaseEggESP", 2)
        createDropdown(SecEggESP, "โหมดสีเรืองแสงไข่", {
            "ตามสีความหายาก",
            "ตามสีที่เลือก",
            "ปิดกรอบเรืองแสง",
        }, function()
            return Config.EggHighlightMode or "ตามสีความหายาก"
        end, function(val)
            Config.EggHighlightMode = val
        end, 3)
        createDropdown(SecEggESP, "สีป้ายและเส้นไข่", COLOR_PRESETS, function()
            return Config.EggESPColorName
        end, function(item)
            Config.EggESPColorName = item.name
        end, 4)
        createNumericInput(SecEggESP, "ขนาดป้ายข้อมูลไข่", "เปอร์เซ็นต์", "EggESPSizePercent", 50, 200, 5)
        createToggle(SecEggESP, "เส้นชี้ตำแหน่งไข่", "EggTracker", 6)
        createToggle(SecEggESP, "แสดงชื่อสายพันธุ์ไข่", "EggShowName", 7)
        createToggle(SecEggESP, "แสดงระดับความหายาก", "EggShowRarity", 8)
        createToggle(SecEggESP, "แสดงสถานะกลายพันธุ์", "EggShowMutation", 9)
        createToggle(SecEggESP, "แสดงรายได้ต่อวินาที", "EggShowIncome", 10)
        createToggle(SecEggESP, "แสดงมูลค่าไข่", "EggShowValue", 11)
        createToggle(SecEggESP, "แสดงน้ำหนักไข่", "EggShowWeight", 12)
        createToggle(SecEggESP, "แสดงชื่อพื้นที่", "EggShowArea", 13)
        createToggle(SecEggESP, "แสดงระยะห่าง", "EggShowDistance", 14)
        local SecEggESPFilter = createSection(PageRender, "ตัวกรองการมองเห็นไข่", 3)
        createDropdown(SecEggESPFilter, "พื้นที่", AREA_LIST, function()
            return AREA_THAI_BY_ID[Config.ESPFilterArea] or "ทุกพื้นที่"
        end, function(item)
            Config.ESPFilterArea = item.id
        end, 1)
        createDropdown(SecEggESPFilter, "สายพันธุ์", SPECIES_LIST, function()
            local sp = SPECIES_BY_ID[Config.ESPFilterSpecies]
            return sp and sp.name or "ทุกสายพันธุ์"
        end, function(item)
            Config.ESPFilterSpecies = item.id
        end, 2)
        createDropdown(SecEggESPFilter, "ความหายาก", RARITY_LIST, function()
            local r = RARITY_BY_ID[Config.ESPFilterRarity]
            return r and r.name or "ทุกระดับ"
        end, function(item)
            Config.ESPFilterRarity = item.id
        end, 3)
        createDropdown(SecEggESPFilter, "สถานะกลายพันธุ์", MUTATION_LIST, function()
            return MUTATION_THAI_BY_ID[Config.ESPFilterMutation] or "ทุกสถานะ"
        end, function(item)
            Config.ESPFilterMutation = item.id
        end, 4)
        local SecGuardESP = createSection(PageRender, "การมองเห็นยามเฝ้าไข่", 4)
        createToggle(SecGuardESP, "แสดงตำแหน่งยามในสนาม", "GuardESP", 1)
        createToggle(SecGuardESP, "เส้นชี้ตำแหน่งยาม", "GuardTracker", 2)
        createToggle(SecGuardESP, "แสดงสถานะยาม", "GuardShowState", 3)
        createToggle(SecGuardESP, "แสดงระยะห่างยาม", "GuardShowDistance", 4)
        local SecPlayerESP = createSection(PageRender, "การมองเห็นผู้เล่น", 5)
        createToggle(SecPlayerESP, "แสดงตำแหน่งผู้เล่น", "PlayerESP", 1)
        createDropdown(SecPlayerESP, "สีป้ายผู้เล่น", COLOR_PRESETS, function()
            return Config.PlayerESPColorName
        end, function(item)
            Config.PlayerESPColorName = item.name
        end, 2)
        createToggle(SecPlayerESP, "แสดงชื่อผู้เล่น", "PlayerShowName", 3)
        createToggle(SecPlayerESP, "เส้นชี้ตำแหน่งผู้เล่น", "PlayerTracker", 4)
        createToggle(SecPlayerESP, "แสดงระยะห่าง", "PlayerShowDistance", 5)
        createToggle(SecPlayerESP, "แสดงความเร็ว", "PlayerShowSpeed", 6)
        createToggle(SecPlayerESP, "แสดงสถานะถือไข่และอาวุธ", "PlayerShowStatus", 7)
    end
    do
        local PageOpt = createTabPage("การเพิ่มประสิทธิภาพ", 8)
        local SecOpt = createSection(PageOpt, "รายการปรับแต่งเพื่อเพิ่มประสิทธิภาพสูงสุด", 1)
        createToggle(SecOpt, "ซ่อนสัตว์เลี้ยงของผู้เล่นอื่นทั้งหมด", "OptHideOtherPets", 1)
        createToggle(SecOpt, "ซ่อนสัตว์เลี้ยงของตัวเองในคอก", "OptHideSelfPets", 2)
        createToggle(SecOpt, "ปิดวิดีโอและหน้าจอบนลู่วิ่งทั้งหมด", "OptDisableTreadmillVideos", 3)
        createToggle(SecOpt, "ปิดเอฟเฟกต์อนุภาค ลำแสง และควันทั้งหมด", "OptDisableParticles", 4)
        createToggle(SecOpt, "ปิดเงาและเอฟเฟกต์แสงสีในฉาก", "OptDisableShadowsAndPostFX", 5)
        createToggle(SecOpt, "ลดรายละเอียดพื้นผิววัสดุเป็นผิวเรียบ", "OptSimplifyMaterials", 6)
        createToggle(SecOpt, "ซ่อนของตกแต่งฉาก ต้นไม้ และก้อนหิน", "OptHideWorldDecorations", 8)
        createToggle(SecOpt, "ปิดเสียงเอฟเฟกต์และเพลงประกอบเกม", "OptMuteGameAudio", 9)
        if Hub.available("OptUnlockFPS") then
            createToggle(SecOpt, "ปลดล็อกเพดานเฟรมเรตสูงสุด", "OptUnlockFPS", 10)
        end
    end
    do
        local PageFun = createTabPage("ฮาๆ", 9)
        local SecFun = createSection(PageFun, "เอฟเฟกต์ตัวละคร", 1)
        createToggle(SecFun, "ปรับขนาดโมเดล", "FunScaleEnabled", 1)
        createDropdown(SecFun, "วิธีปรับขนาด", { "ทั้งตัว", "แยกส่วน" }, function()
            return Config.FunScaleMode
        end, function(mode)
            Config.FunScaleMode = mode
        end, 2)
        do
            local whole = createNumericInput(SecFun, "ขนาดทั้งตัว", "เท่า", "FunScale", 0.01, 20, 3)
            local separate = {}
            for index, group in ipairs(FUN_PARTS) do
                separate[index] = createNumericInput(SecFun, "ขนาด" .. group.name, "เท่า", group.key, 0.01, 20, index + 3)
            end
            local function refreshScaleRows()
                whole.Visible = Config.FunScaleMode == "ทั้งตัว"
                for _, row in ipairs(separate) do
                    row.Visible = not whole.Visible
                end
            end
            table.insert(UIRefreshCallbacks, refreshScaleRows)
            refreshScaleRows()
        end
        createToggle(SecFun, "หมุนทั้งตัว", "FunSpin", 10)
        createNumericInput(SecFun, "ความเร็วหมุนทั้งตัว", "องศา/วินาที", "FunSpinSpeed", 0, nil, 11)
    end
    do
        local PageSettings = createTabPage("ตั้งค่า", 10)
        local SecTheme = createSection(PageSettings, "ธีม", 1)
        createDropdown(SecTheme, "เลือกธีม", {
            "มืดคราม",
            "เขียวมรกต",
            "ม่วงอเมทิสต์",
            "ชมพูซากุระ",
            "ทองคำมืด",
            "สว่างสะอาด",
        }, function()
            return Config.ThemeName
        end, function(val)
            Config.ThemeName = val
            applyThemeAndTypography()
        end, 1)
        createDropdown(SecTheme, "เลือกฟอนต์", {
            "โกธิคทันสมัย",
            "โกธิคหนา",
            "ซอร์สแซนส์",
            "ซอร์สแซนส์หนา",
            "อารีย์",
        }, function()
            return Config.FontName
        end, function(val)
            Config.FontName = val
            applyThemeAndTypography()
        end, 2)
        createNumericInput(SecTheme, "ขนาดฟอนต์", "สูงสุด 100", "FontSize", 1, 100, 3, function()
            applyThemeAndTypography()
        end)
        createNumericInput(SecTheme, "ขนาดหน้าต่างเมนู", "เปอร์เซ็นต์", "GuiScalePercent", 1, 200, 4, function()
            applyThemeAndTypography()
        end)
        createToggle(SecTheme, "พื้นหลังเบลอ", "BackgroundBlur", 5, applyThemeAndTypography, true)
        createNumericInput(SecTheme, "ความจางพื้นหลัง", "เปอร์เซ็นต์", "BackgroundTransparency", 0, nil, 6, function()
            applyThemeAndTypography()
        end)
        local SecKeybinds = createSection(PageSettings, "ตั้งปุ่มลัด", 2)
        createToggle(SecKeybinds, "เปิดหรือปิดปุ่มลัด", "KeybindsEnabled", 1, nil, true)
        local KEYBIND_ITEMS = {
            {
                key = "ToggleGUI",
                label = "เปิดหรือปิดหน้าต่างเมนู",
                toggleKey = nil,
            },
            {
                key = "AutoStealEgg",
                label = "ออโต้ขโมยไข่",
                toggleKey = "AutoStealEgg",
            },
            {
                key = "AutoPlaceEgg",
                label = "ออโต้วางไข่ลงคอก",
                toggleKey = "AutoPlaceEgg",
            },
            {
                key = "AutoHatchEgg",
                label = "ออโต้ฟักไข่",
                toggleKey = "AutoHatchEgg",
            },
            {
                key = "AutoUpgradeAll",
                label = "ออโต้อัปเกรดบ้านและลู่วิ่ง",
                toggleKey = "AutoUpgradeAll",
            },
            {
                key = "AutoTreadmill",
                label = "ออโต้ลู่วิ่ง",
                toggleKey = "AutoTreadmill",
            },
            {
                key = "AutoEquipBest",
                label = "ออโต้ใส่ตัวเก่งสุด",
                toggleKey = "AutoEquipBest",
            },
            {
                key = "AutoSellPet",
                label = "ออโต้ขายตัว",
                toggleKey = "AutoSellPet",
            },
            {
                key = "AutoClaimReward",
                label = "รับรางวัลออฟไลน์ สมุด และกลุ่ม",
                toggleKey = "AutoClaimReward",
            },
            {
                key = "AutoBuyTrail",
                label = "ออโต้ซื้อเทรล",
                toggleKey = "AutoBuyTrail",
            },
            {
                key = "AutoFusion",
                label = "ออโต้ฟิวส์ชั่น",
                toggleKey = "AutoFusion",
            },
            { key = "AutoWispQuest", label = "ออโต้เควสภูตวิญญาณ", toggleKey = "AutoWispQuest" },
            { key = "AutoBloom", label = "ออโต้ซากุระและจับผีเสื้อ", toggleKey = "AutoBloom" },
            { key = "AutoShootingStar", label = "ออโต้เก็บดาวตก", toggleKey = "AutoShootingStar" },
            { key = "AutoFeedStar", label = "ออโต้ให้อาหารดาว", toggleKey = "AutoFeedStar" },
            { key = "AutoBanjo", label = "ออโต้มินิเกมแบนโจ", toggleKey = "AutoBanjo" },
            { key = "AutoFishing", label = "ออโต้ตกปลา", toggleKey = "AutoFishing" },
            { key = "InstantFishCatch", label = "ดึงปลาเข้ากระเป๋าทันที", toggleKey = "InstantFishCatch" },
            { key = "AutoAlien", label = "ออโต้กิจกรรมเอเลี่ยน", toggleKey = "AutoAlien" },
            {
                key = "AutoIslandWars",
                label = "ออโต้เข้าร่วมสงครามเกาะต้องสาป",
                toggleKey = "AutoIslandWars",
            },
            {
                key = "AutoMutation",
                label = "ออโต้กลายพันธุ์",
                toggleKey = "AutoMutation",
            },
            {
                key = "AutoCollectMoney",
                label = "ออโต้เก็บเงินในคอกและเงินออฟไลน์",
                toggleKey = "AutoCollectMoney",
            },
            {
                key = "AutoFavorite",
                label = "ออโต้ล็อกดาวสัตว์เลี้ยงและไข่หายาก",
                toggleKey = "AutoFavorite",
            },
            {
                key = "AutoAdminAbuse",
                label = "ออโต้เข้าร่วมกิจกรรมแอดมินทั้งหมด",
                toggleKey = "AutoAdminAbuse",
            },
            {
                key = "AutoHopEnabled",
                label = "ออโต้ย้ายเซิร์ฟเวอร์หาไข่เป้าหมาย",
                toggleKey = "AutoHopEnabled",
            },
            { key = "AutoAttack", label = "ออโต้ตี", toggleKey = "AutoAttack" },
            { key = "AutoEquipBat", label = "ถือไม้เบล", toggleKey = "AutoEquipBat" },
            { key = "AntiTrap", label = "ปิดการชนกับดัก", toggleKey = "AntiTrap" },
            { key = "AntiFall", label = "กันล้ม", toggleKey = "AntiFall" },
            {
                key = "AntiKnockback",
                label = "กันกระเด็น",
                toggleKey = "AntiKnockback",
            },
            { key = "TrapESP", label = "แสดงตำแหน่งกับดัก", toggleKey = "TrapESP" },
            {
                key = "RevealEggContent100",
                label = "แสดงข้อมูลไข่จริงจากเซิร์ฟเวอร์",
                toggleKey = "RevealEggContent100",
            },
            { key = "EggESP", label = "แสดงตำแหน่งไข่", toggleKey = "EggESP" },
            { key = "PlayerESP", label = "แสดงตำแหน่งผู้เล่น", toggleKey = "PlayerESP" },
        }
        local ListeningKeybindId = nil
        for idx, item in ipairs(KEYBIND_ITEMS) do
            local row = Instance.new("Frame")
            row.LayoutOrder = idx + 1
            row.Size = UDim2.new(1, 0, 0, 34)
            row.BackgroundColor3 = getCurrentTheme().Bg
            row.BackgroundTransparency = 0.35
            row.BorderSizePixel = 0
            row.ZIndex = 13
            row.Parent = SecKeybinds
            registerTheme(row, "BackgroundColor3", "Bg")
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = row
            local lbl = Instance.new("TextLabel")
            lbl.Position = UDim2.fromOffset(12, 0)
            lbl.Size = UDim2.new(0.62, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Font = getCurrentFont()
            lbl.TextSize = 13
            lbl.TextColor3 = getCurrentTheme().Text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Text = item.label
            lbl.ZIndex = 14
            lbl.Parent = row
            registerTheme(lbl, "TextColor3", "Text")
            registerText(lbl, 13, false)
            local bindBtn = Instance.new("TextButton")
            bindBtn.AnchorPoint = Vector2.new(1, 0.5)
            bindBtn.Position = UDim2.new(1, -10, 0.5, 0)
            bindBtn.Size = UDim2.fromOffset(115, 24)
            bindBtn.BackgroundColor3 = getCurrentTheme().Card
            bindBtn.Font = getCurrentFont()
            bindBtn.TextSize = 12
            bindBtn.TextColor3 = getCurrentTheme().Accent
            bindBtn.AutoButtonColor = false
            bindBtn.ZIndex = 14
            bindBtn.Parent = row
            registerTheme(bindBtn, "BackgroundColor3", "Card")
            registerTheme(bindBtn, "TextColor3", "Accent")
            registerText(bindBtn, 12, true)
            local bCorner = Instance.new("UICorner")
            bCorner.CornerRadius = UDim.new(0, 6)
            bCorner.Parent = bindBtn
            local function updateBindText()
                local codeName = Config.Keybinds[item.key]
                bindBtn.Text = (ListeningKeybindId == item.key) and "กดปุ่มที่ต้องการ..." or getThaiKeyNameFromStr(codeName)
            end
            bindClick(bindBtn, function()
                ListeningKeybindId = item.key
                updateBindText()
            end)
            table.insert(UIRefreshCallbacks, updateBindText)
            updateBindText()
        end
        connectSignal(UserInputService.InputBegan, function(input, gameProcessed)
            if ListeningKeybindId and input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode ~= Enum.KeyCode.Unknown then
                    local name = input.KeyCode.Name
                    if name == "Escape" then
                        ListeningKeybindId = nil
                        for _, cb in ipairs(UIRefreshCallbacks) do
                            Hub.refreshCallback(cb)
                        end
                        return
                    end
                    if name == "Backspace" or name == "Delete" then
                        name = ""
                    end
                    for id, bound in pairs(Config.Keybinds) do
                        if id ~= ListeningKeybindId and name ~= "" and bound == name then
                            local usedLabel = FEATURE_THAI_NAMES[id] or id
                            for _, kbItem in ipairs(KEYBIND_ITEMS) do
                                if kbItem.key == id then
                                    usedLabel = kbItem.label
                                    break
                                end
                            end
                            notifyThai("ปุ่มนี้ใช้กับ ".. usedLabel.. " อยู่แล้ว • กดปุ่มยกเลิกเพื่อออก")
                            return
                        end
                    end
                    Config.Keybinds[ListeningKeybindId] = name
                end
                ListeningKeybindId = nil
                for _, cb in ipairs(UIRefreshCallbacks) do
                    Hub.refreshCallback(cb)
                end
                return
            end
            if gameProcessed or isTextBoxFocused() then
                return
            end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then
                return
            end
            if safeKeyCode(Config.Keybinds.ToggleGUI) == input.KeyCode then
                setWindowOpen(not IsWindowOpen)
                return
            end
            if not Config.KeybindsEnabled then
                return
            end
            for _, item in ipairs(KEYBIND_ITEMS) do
                local boundName = Config.Keybinds[item.key]
                local kc = safeKeyCode(boundName)
                if kc and kc == input.KeyCode then
                    if item.key == "ToggleGUI" then
                        setWindowOpen(not IsWindowOpen)
                    elseif item.toggleKey then
                        local ok, reason = Hub.setToggle(item.toggleKey, not Hub.featureEnabled(item.toggleKey))
                        if not ok then
                            notifyThai(reason)
                            return
                        end
                        notifyThai(item.label.. " • ".. (Hub.featureEnabled(item.toggleKey) and "เปิด" or "ปิด"))
                    end
                end
            end
        end)
        local SecGlobalActions = createSection(PageSettings, "จัดการสถานะและการตั้งค่าทั้งหมด", 3)
        createActionButton(SecGlobalActions, "ปิดทุกค่าที่เปิดทั้งหมด", false, 1, function()
            Hub.stopAll()
            notifyThai("ปิดการทำงานทุกฟังก์ชันที่เปิดอยู่เรียบร้อยแล้ว")
        end)
        createActionButton(SecGlobalActions, "หยุดและนำเมนูออก", true, 3, function()
            if GlobalEnv.__ThaiCleanHubCleanup then
                GlobalEnv.__ThaiCleanHubCleanup()
            end
        end)
        createActionButton(SecGlobalActions, "รีเซ็ตตั้งค่าทั้งหมด", true, 2, function()
            local fresh = createDefaultConfig()
            applyProfileTableToConfig(fresh, Config)
            applyThemeAndTypography()
            syncAllFeatureStates()
            notifyThai("รีเซ็ตตั้งค่าทั้งหมดกลับเป็นค่าเริ่มต้นเรียบร้อยแล้ว")
        end)
    end
end
selectTab("ฟาร์ม")
syncAllFeatureStates()
notifyThai(ProfileLoadWarning and "อ่านโปรไฟล์เก่าไม่ได้ ใช้ค่าเริ่มต้นในรอบนี้" or "โหลดเมนูแล้ว ใช้การตั้งค่าตามโปรไฟล์")
if ProfileLoadWarning then
    Hub.fail("Profiles", ProfileLoadWarning)
end
local function findLocalPlotFallback()
    if PlotState and PlotState.ResolvePlot then
        local ok, plot = pcall(PlotState.ResolvePlot, LocalPlayer)
        if ok and plot then
            return plot
        end
    end
    local plots = Workspace:FindFirstChild("Plots")
    if plots then
        for _, model in ipairs(plots:GetChildren()) do
            if model:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
                local area, center = model:FindFirstChild("PetArea", true), model:FindFirstChild("CenterPoint")
                if area and center and area:IsA("BasePart") and center:IsA("BasePart") then
                    return { PlotFolder = model, PetArea = area, CenterPoint = center }
                end
            end
        end
    end
    return nil
end
local function findEggToolByUid(uid)
    for _, container in ipairs({ LocalPlayer.Character, LocalPlayer:FindFirstChild("Backpack") }) do
        if container then
            for _, tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") and tool:GetAttribute("UID") == uid and tool:GetAttribute("ItemType") == "AssetEgg" then
                    return tool
                end
            end
        end
    end
    return nil
end
function Hub.isWeapon(tool)
    return tool and tool:IsA("Tool") and tool:GetAttribute("IsBat") == true
end
function Hub.weapon()
    local char, hum = LocalPlayer.Character, getLocalHumanoid()
    if not char or not hum then
        return nil
    end
    for _, tool in ipairs(char:GetChildren()) do
        if Hub.isWeapon(tool) then
            return tool
        end
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if Hub.isWeapon(tool) then
                if not Hub.EquippedWeapon then
                    Hub.PreviousTool = char:FindFirstChildOfClass("Tool")
                end
                hum:EquipTool(tool)
                if tool.Parent ~= char then
                    return nil
                end
                Hub.EquippedWeapon = tool
                return tool
            end
        end
    end
    return nil
end
function Hub.rawCarryState()
    if EggState and EggState.ReadCarryState then
        local ok, state = pcall(EggState.ReadCarryState)
        if ok and type(state) == "table" and type(state.IsCarrying) == "boolean" then
            return state
        end
    end
    return nil
end
function Hub.stepOff()
    if not RuntimeState.IsCurrentlyOnTreadmill then
        return true
    end
    if Hub.TreadmillAuto then
        Hub.doffTreadmill()
    end
    return false
end
function Hub.signature(save)
    local keys = {}
    for uid, pet in pairs(save and save.Inventory or {}) do
        if type(pet) == "table" then
            table.insert(keys, tostring(uid).. ":".. tostring(pet.Category).. ":".. tostring(pet.Scale).. ":".. tostring(pet.IsFavorite).. ":".. tostring(pet.InFuse).. ":".. tostring(pet.BaseMutation).. ":".. table.concat(type(pet.Mutations) == "table" and pet.Mutations or {}, ",").. ":".. tostring(pet.Level))
        end
    end
    for _, uid in ipairs(save and save.EquippedAssets or {}) do
        table.insert(keys, "eq:" .. tostring(uid))
    end
    table.sort(keys)
    return table.concat(keys, "|")
end
function Hub.saleCandidates(save)
    local reserved, equipped, result = table.clone(Hub.FusionReserved or {}), {}, {}
    for _, field in ipairs({
        "EquippedAssets",
        "FusionSlots",
        "VIPFusionSlots",
        "PrivateFusionSlots",
    }) do
        for _, uid in pairs(save[field] or {}) do
            if type(uid) == "string" then
                reserved[uid] = true
                if field == "EquippedAssets" then
                    equipped[uid] = true
                end
            end
        end
    end
    for uid, pet in pairs(save.Inventory or {}) do
        if type(uid) == "string" and type(pet) == "table" and not reserved[uid] and not pet.IsFavorite and not pet.InFuse and not pet.SpecialLuckyBlockColumn and not pet.PendingEggName then
            table.insert(result, uid)
        end
    end
    table.sort(result)
    return result, equipped
end
function Hub.targetPlayer(records)
    local root = getLocalRoot()
    if not root then
        return nil
    end
    local carriers = {}
    for _, rec in pairs(records) do
        if rec.State == "Carried" and rec.CarrierUserId then
            carriers[rec.CarrierUserId] = true
        end
    end
    local lockedName = Config.AttackTargetPlayer
    if type(lockedName) == "string" and lockedName ~= "" and lockedName ~= "ทุกคนตามโหมดการตี" then
        local lockedPlayer = Players:FindFirstChild(lockedName)
        if lockedPlayer and lockedPlayer ~= LocalPlayer and (Config.AttackMode ~= "ไปตีผู้เล่นที่ถือไข่" or carriers[lockedPlayer.UserId]) then
            local char = lockedPlayer.Character
            local theirRoot, hum = char and char:FindFirstChild("HumanoidRootPart"), char and char:FindFirstChildOfClass("Humanoid")
            if theirRoot and hum and hum.Health > 0 then
                return lockedPlayer
            end
        end
        return nil
    end
    local target, distance = nil, Config.AttackMode == "ไปตีผู้เล่นที่ถือไข่" and math.huge or 16
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and (Config.AttackMode ~= "ไปตีผู้เล่นที่ถือไข่" or carriers[player.UserId]) then
            local char = player.Character
            local theirRoot, hum = char and char:FindFirstChild("HumanoidRootPart"), char and char:FindFirstChildOfClass("Humanoid")
            if theirRoot and hum and hum.Health > 0 then
                local d = (theirRoot.Position - root.Position).Magnitude
                if d < distance then
                    target, distance = player, d
                end
            end
        end
    end
    return target
end
Hub.Nav = {}
Hub.Hazards, Hub.TrapVisuals = {}, {}
function Hub.flat(value)
    return Vector3.new(value.X, 0, value.Z)
end
function Hub.distance(a, b)
    return Hub.flat(a - b).Magnitude
end
function Hub.ownerAlive(owner, token)
    if owner == "_TreadmillExit" then
        return IsScriptRunning and Hub.ExitTarget ~= nil
    end
    return Hub.alive(owner, token)
end
function Hub.usesDeliveryStop(owner)
    return owner == "AutoStealEgg" and Config.AutoStealEgg and Hub.isDeliveryStopMode() and not Config.AntiGuard
end
function Hub.stopWalking()
    local nav, root, hum = Hub.Nav, getLocalRoot(), getLocalHumanoid()
    if nav.Driving and hum then
        hum:Move(Vector3.zero, false)
    end
    if nav.Driving and root and root == nav.Root then
        local current = Hub.flat(root.AssemblyLinearVelocity)
        if not nav.Velocity or (current - nav.Velocity).Magnitude < 5 then
            root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
        end
    end
    nav.Driving, nav.Root, nav.Velocity, nav.LastDirection = nil, nil, nil, nil
end
function Hub.clearNavigation()
    Hub.stopWalking()
    table.clear(Hub.Nav)
end
function Hub.navigationStatus(state, reason)
    local nav = Hub.Nav
    nav.State, nav.Reason = state, reason
    if nav.Owner then
        Hub.status(nav.Owner, state == "moving" and "local" or "waiting", reason)
    end
end
function Hub.pauseNavigation(reason)
    Hub.stopWalking()
    if Hub.Nav.Goal then
        Hub.navigationStatus("paused", reason)
    end
end
function Hub.fieldAreas()
    local world = Workspace:FindFirstChild("World")
    return world and world:FindFirstChild("Areas")
end
function Hub.inGameplay(position)
    local areas = Hub.fieldAreas()
    local line = areas and areas:FindFirstChild("SeparationLine")
    return line and line.CFrame.LookVector:Dot(position - line.Position) > 0 or false
end
function Hub.fieldTime()
    return TimeUtil.serverNow(Hub.ServerClock)
end
function Hub.fieldResetStep()
    local areas = Hub.fieldAreas()
    local wall = areas and areas:FindFirstChild("WallStartCollision")
    local solid = wall and wall:IsA("BasePart") and wall.CanCollide
    if wall and not solid then
        for _, part in ipairs(wall:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                solid = true
                break
            end
        end
    end
    local now = Hub.fieldTime()
    local cycle, settings = Hub.AreaEggCycle, Hub.AreaEggResetCycle or {}
    local openingDelay = (tonumber(settings.WallCountdownDelayAfterDayStartsSeconds) or 0) + (tonumber(settings.WallCountdownSeconds) or 0)
    local closed = solid == true
    Hub.FieldClosesAt = nil
    if not Workspace:GetAttribute("Event_AdminAbuse") then
        local day = Hub.FieldResetDay
        if cycle and cycle.IsRunning() then
            if cycle.IsNightPhase(now) then
                closed = true
            else
                local start = cycle.PeriodStartTime(cycle.PeriodIndexAt(now))
                closed = closed or TimeUtil.diffSeconds(now, start) < openingDelay
                Hub.FieldClosesAt = cycle.NightStartTime(now)
            end
        elseif not cycle and day and TimeUtil.diffSeconds(now, day) < openingDelay then
            closed = true
        end
    end
    if closed and not Hub.FieldResetting then
        Hub.StealEntry = nil
        if Hub.MovementOwner == "AutoStealEgg" then
            Hub.clearNavigation()
        end
    elseif not closed and Hub.FieldResetting then
        Hub.FinishedEggs, Hub.CarryDropTarget, Hub.StealRetryUid, Hub.DeliveryNoDropRetry = nil, nil, nil, nil
    end
    Hub.FieldResetting = closed
end
function Hub.setWalkGoal(owner, token, position, radius)
    local nav, cycle = Hub.Nav, Hub.CarryCycle
    if cycle and cycle.Owner == owner and cycle.ReturnGoal then
        position, radius = cycle.ReturnGoal, 2
    end
    if nav.Owner ~= owner or nav.Token ~= token then
        Hub.clearNavigation()
        nav = Hub.Nav
    end
    if not nav.Goal or Hub.distance(nav.Goal, position) > 5 then
        nav.Waypoint, nav.Obstacle, nav.Side, nav.Blocked, nav.ProbeAt = nil, nil, nil, nil, nil
        nav.ProgressAt = os.clock()
        nav.ProgressPosition = nil
    end
    nav.Owner, nav.Token, nav.Goal, nav.StopRadius = owner, token, position, radius or 2.5
end
function Hub.navigationRayParams()
    local params = RaycastParams.new()
    params.FilterType, params.IgnoreWater = Enum.RaycastFilterType.Exclude, true
    params.RespectCanCollide = true
    local root = getLocalRoot()
    params.CollisionGroup = root and root.CollisionGroup or "Default"
    local skip = { LocalPlayer.Character }
    local cycle = Hub.CarryCycle
    local carried = cycle and cycle.Uid and Workspace:FindFirstChild(cycle.Uid)
    if carried then
        table.insert(skip, carried)
    end
    local slots = Workspace:FindFirstChild("AreaEggSlotsClient")
    if slots then
        table.insert(skip, slots)
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player ~= LocalPlayer then
            table.insert(skip, player.Character)
        end
    end
    params.FilterDescendantsInstances = skip
    return params
end
function Hub.walkableHit(hit, hum)
    return hit and hit.Normal and hit.Normal.Y >= math.cos(math.rad(math.clamp(hum.MaxSlopeAngle or 45, 0, 89)))
end
function Hub.runWall(origin, direction, hum, params)
    if direction.Magnitude < 0.05 then
        return nil
    end
    local hit = Workspace:Raycast(origin, direction, params)
    if hit and hit.Instance and hit.Instance:IsA("BasePart") and hit.Instance.CanCollide and not Hub.walkableHit(hit, hum) then
        return hit
    end
    return nil
end
function Hub.runWaypoint(root, hum, goal)
    local nav, now = Hub.Nav, os.clock()
    local delta = Hub.flat(goal - root.Position)
    if delta.Magnitude < 0.1 then
        return goal
    end
    if nav.Waypoint and Hub.distance(root.Position, nav.Waypoint) <= 2 then
        nav.Waypoint = nil
    end
    if now < (nav.ProbeAt or 0) then
        return nav.Blocked and root.Position or nav.Waypoint or goal
    end
    nav.ProbeAt = now + 0.12
    local params = Hub.navigationRayParams()
    local ahead = delta.Unit * math.min(delta.Magnitude, math.max(6, hum.WalkSpeed * 0.25))
    local hit = Hub.runWall(root.Position, ahead, hum, params)
    if not hit then
        nav.Waypoint, nav.Obstacle, nav.Side, nav.Blocked = nil, nil, nil, nil
        return goal
    end
    if nav.Waypoint and nav.Obstacle == hit.Instance then
        return nav.Waypoint
    end
    local side = Vector3.new(-delta.Unit.Z, 0, delta.Unit.X)
    local best, bestScore, chosenSide
    for _, sign in ipairs(nav.Side and { nav.Side, -nav.Side } or { 1, -1 }) do
        local lateral = side * sign
        for _, reach in ipairs({ 5, 10, 18, 30 }) do
            local candidate = root.Position + lateral * reach + delta.Unit * math.min(3, delta.Magnitude)
            if not Hub.runWall(root.Position, candidate - root.Position, hum, params) then
                local onward = Hub.flat(goal - candidate)
                local second = onward.Magnitude > 0.1 and Hub.runWall(candidate, onward.Unit * math.min(onward.Magnitude, 8), hum, params)
                local score = reach + Hub.distance(candidate, goal) + (second and 25 or 0)
                if not bestScore or score < bestScore then
                    best, bestScore, chosenSide = candidate, score, sign
                end
            end
        end
    end
    if best then
        nav.Waypoint, nav.Obstacle, nav.Side, nav.Blocked = best, hit.Instance, chosenSide, nil
        return best
    end
    nav.Blocked = true
    return root.Position
end
function Hub.runSpeed()
    local hum = getLocalHumanoid()
    if not hum then
        return 0
    end
    local speed = math.max(0, tonumber(hum.WalkSpeed) or 0)
    local swap = Hub.RagdollSwap
    if swap and swap.Original and swap.Original.Health > 0 then
        speed = math.min(speed, swap.Original.WalkSpeed)
    end
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    local power = stats and stats:FindFirstChild("Speed")
    if power and Hub.TreadmillUtil and Hub.TreadmillUtil.SpeedPowerToWalkSpeed then
        local ok, limit = pcall(Hub.TreadmillUtil.SpeedPowerToWalkSpeed, power.Value)
        if ok and type(limit) == "number" and limit > 0 then
            speed = math.min(speed, limit)
        end
    end
    return speed
end
function Hub.restoreCharacterStats()
    Hub.stopWalking()
end
function Hub.refreshMotionNumbers()
    if Hub.MovementStatusLabel then
        Hub.MovementStatusLabel.Text = string.format("วิ่งอัตโนมัติ • ความเร็วจากเกม %.1f • ส่งไข่แบบ%s", Hub.runSpeed(), Config.DeliveryMethod)
    end
end
function Hub.followNavigation(dt)
    local nav, root, hum = Hub.Nav, getLocalRoot(), getLocalHumanoid()
    if not nav.Goal then
        return
    end
    if not Hub.ownerAlive(nav.Owner, nav.Token) or Hub.MovementOwner ~= nav.Owner then
        Hub.clearNavigation()
        return
    end
    if not root or not hum or hum.Health <= 0 then
        Hub.pauseNavigation("รอตัวละครพร้อม")
        return
    end
    if Hub.DeliveryStop or Hub.CharacterMutation or (Hub.GuardAction and Hub.GuardAction.Busy) then
        Hub.stopWalking()
        return
    end
    if Hub.FieldResetting and (nav.Owner == "AutoStealEgg" or (nav.Owner == "AutoAttack" and (Hub.RecoveryEgg or Hub.RecoveryCarry)) or (nav.Owner == "AutoTreadmill" and Hub.inGameplay(root.Position))) then
        Hub.pauseNavigation("รอไข่รอบใหม่และกำแพงเปิด")
        return
    end
    local char = LocalPlayer.Character
    if root.Anchored or hum.Sit or RuntimeState.IsCurrentlyOnTreadmill or Hub.isFallen() or char:GetAttribute("IsTrapped") then
        Hub.pauseNavigation("รอลงจากลู่หรือให้ตัวละครพร้อมก่อนวิ่ง")
        return
    end
    local distance = Hub.distance(root.Position, nav.Goal)
    if distance <= nav.StopRadius then
        Hub.stopWalking()
        nav.State = "arrived"
        return
    end
    local point = Hub.runWaypoint(root, hum, nav.Goal)
    local offset = Hub.flat(point - root.Position)
    if offset.Magnitude < 0.05 then
        Hub.pauseNavigation("ทางด้านหน้าถูกกีดขวาง รอทางเปิด")
        return
    end
    local direction = offset.Unit
    local stepTime = math.max(0.05, math.min(tonumber(dt) or 0.05, 0.25))
    local goMult = math.clamp((tonumber(Config.StealGoSpeedPercent) or 115) / 100, 0.5, 3)
    local carryMult = math.clamp((tonumber(Config.StealCarrySpeedPercent) or 150) / 100, 0.5, 3)
    local speedMult = 1
    if nav.Owner == "AutoStealEgg" then
        if Hub.CarryCycle then
            speedMult = Config.DeliveryMethod == "ทวีนความเร็วสูง" and math.max(carryMult, 2.0) or carryMult
        else
            local targetEgg = Hub.MotionTarget
            local allowTpZone = not targetEgg or filterAllows(Config.StealTeleportAreas, targetEgg.AreaId)
            if Config.StealGoMethod == "เทเลพอร์ต" and allowTpZone then
                speedMult = math.max(goMult, 2.4)
            elseif Config.StealGoMethod == "ทวีนความเร็วสูง" then
                speedMult = math.max(goMult, 1.85)
            else
                speedMult = goMult
            end
        end
    end
    local speed = math.min(Hub.runSpeed() * speedMult, offset.Magnitude / stepTime)
    local velocity = direction * speed
    hum:Move(direction, false)
    root.AssemblyLinearVelocity = Vector3.new(velocity.X, root.AssemblyLinearVelocity.Y, velocity.Z)
    nav.Driving, nav.Root, nav.Velocity, nav.LastDirection = true, root, velocity, direction
    if not nav.ProgressPosition then
        nav.ProgressPosition, nav.ProgressAt = root.Position, os.clock()
    end
    if os.clock() - nav.ProgressAt >= 1.5 then
        if Hub.distance(root.Position, nav.ProgressPosition) < 3 and hum.FloorMaterial ~= Enum.Material.Air and os.clock() >= (nav.NextJump or 0) then
            hum.Jump = true
            nav.NextJump = os.clock() + 1.5
        end
        nav.ProgressPosition, nav.ProgressAt = root.Position, os.clock()
    end
    Hub.navigationStatus("moving", nav.Waypoint and "กำลังวิ่งเลี้ยวผ่านสิ่งกีดขวาง" or "กำลังวิ่งไปยังเป้าหมาย")
end
Hub.Fun = { Yaw = 0 }
function Hub.funRestoreRotation()
    local record = Hub.Fun.Rotation
    Hub.Fun.Rotation = nil
    if record then
        pcall(function()
            if not record.Humanoid.AutoRotate then
                record.Humanoid.AutoRotate = record.AutoRotate
            end
        end)
    end
end
function Hub.funRestoreVisual()
    local visual = Hub.Fun.Visual
    Hub.Fun.Visual = nil
    if not visual then
        return
    end
    for _, link in ipairs(visual.Links) do
        link:Disconnect()
    end
    Hub.restore("FunVisual")
    visual.Model:Destroy()
end
function Hub.funReset()
    Hub.funRestoreRotation()
    Hub.funRestoreVisual()
    Hub.Fun.Yaw = 0
end
function Hub.funBuildVisual(char, hum)
    Hub.funRestoreVisual()
    local model = Instance.new("Model")
    model.Name = "ThaiAvatarPreview"
    local visual = { Character = char, Model = model, Parts = {}, Links = {} }
    Hub.Fun.Visual = visual
    local groups, pivots = {}, {}
    for _, group in ipairs(FUN_PARTS) do
        for _, name in ipairs(group.parts) do
            groups[name] = group.key
            pivots[group.key] = pivots[group.key] or char:FindFirstChild(name)
        end
    end
    local function addPart(source, parent, group)
        local archivable = source.Archivable
        source.Archivable = true
        local ok, part = pcall(source.Clone, source)
        source.Archivable = archivable
        if not ok or not part then
            return
        end
        for _, child in ipairs(part:GetDescendants()) do
            if child.Parent and not (child:IsA("DataModelMesh") or child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceAppearance") or child:IsA("Attachment") or child:IsA("WrapLayer") or child:IsA("WrapTarget")) then
                child:Destroy()
            end
        end
        part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = true, false, false, false
        part.LocalTransparencyModifier, part.CastShadow = 0, false
        part.Parent = parent
        local mesh = source:FindFirstChildOfClass("SpecialMesh")
        local copyMesh = part:FindFirstChildOfClass("SpecialMesh")
        visual.Parts[#visual.Parts + 1] = {
            Source = source,
            Copy = part,
            Group = group,
            Pivot = pivots[group],
            Mesh = mesh and mesh.MeshType == Enum.MeshType.FileMesh and mesh or nil,
            CopyMesh = copyMesh,
        }
        Hub.capture("FunVisual", source, "LocalTransparencyModifier", 1)
    end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
            addPart(child, model, groups[child.Name])
        elseif child:IsA("Accessory") then
            local handle = child:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                local weld = handle:FindFirstChild("AccessoryWeld")
                local attached = weld and weld:IsA("JointInstance") and weld.Part1
                local accessory = Instance.new("Accessory")
                accessory.Name, accessory.Parent = child.Name, model
                addPart(handle, accessory, attached and groups[attached.Name] or "FunHeadScale")
            end
        elseif child:IsA("Clothing") or child:IsA("ShirtGraphic") or child:IsA("CharacterMesh") then
            local clothing = child:Clone()
            if clothing then
                clothing.Parent = model
            end
        end
    end
    if #visual.Parts == 0 then
        model:Destroy()
        Hub.Fun.Visual = nil
        return nil
    end
    local body = Instance.new("Humanoid")
    body.RequiresNeck, body.BreakJointsOnDeath = false, false
    body.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    pcall(function()
        body.RigType = hum.RigType
        body.EvaluateStateMachine = false
    end)
    body.Parent = model
    local function rebuildIfBodyChanged(child)
        if child:IsA("BasePart") or child:IsA("Accessory") or child:IsA("Clothing") or child:IsA("ShirtGraphic") or child:IsA("CharacterMesh") then
            visual.Dirty = true
        end
    end
    visual.Links = {
        char.ChildAdded:Connect(rebuildIfBodyChanged),
        char.ChildRemoved:Connect(rebuildIfBodyChanged),
    }
    model.Parent = Workspace
    return visual
end
function Hub.funFrame(dt)
    local scaleOn, spinOn = Config.FunScaleEnabled, Config.FunSpin
    if not IsScriptRunning or (not scaleOn and not spinOn) then
        Hub.funReset()
        return
    end
    local hum, root, char = getLocalHumanoid(), getLocalRoot(), LocalPlayer.Character
    if not char or not hum or not root or hum.Health <= 0 then
        Hub.funReset()
        return
    end
    local frameStep = math.clamp(tonumber(dt) or 0.016, 0, 0.1)
    local angle = math.rad((Config.FunSpinSpeed * frameStep) % 360)
    local physicsSpin = spinOn and angle ~= 0 and not root.Anchored and not RuntimeState.IsCurrentlyOnTreadmill and not Hub.DeliveryStop and not (Hub.GuardAction and Hub.GuardAction.Busy) and not Config.HidePlayer and Hub.HiddenPlayerUsed ~= char and not char:GetAttribute("IsTrapped") and not Hub.serverRagdolled() and not Hub.isFallen()
    if physicsSpin and type(isnetworkowner) == "function" then
        local ok, owns = pcall(isnetworkowner, root)
        if ok and owns == false then
            physicsSpin = false
        end
    end
    if physicsSpin then
        local record = Hub.Fun.Rotation
        if not record or record.Humanoid ~= hum or record.Root ~= root then
            Hub.funRestoreRotation()
            record = {
                Humanoid = hum,
                Root = root,
                AutoRotate = hum.AutoRotate,
                Facing = root.CFrame.Rotation,
            }
            Hub.Fun.Rotation = record
        end
        record.Facing = record.Facing * CFrame.Angles(0, angle, 0)
        local linear = root.AssemblyLinearVelocity
        physicsSpin = pcall(function()
            hum.AutoRotate = false
            root.CFrame = CFrame.new(root.Position) * record.Facing
            root.AssemblyLinearVelocity = linear
        end)
    end
    if physicsSpin then
        Hub.Fun.Yaw = 0
        Hub.status("FunSpin", "requested", "หมุนผ่านฟิสิกส์ตัวละคร • ยังไม่ยืนยันจากจอผู้เล่นอื่น")
    else
        Hub.funRestoreRotation()
        Hub.Fun.Yaw = spinOn and (Hub.Fun.Yaw + angle) % (2 * math.pi) or 0
        if spinOn then
            Hub.status("FunSpin", "local", angle == 0 and "ความเร็วหมุน 0 องศา/วินาที" or "แสดงการหมุนเฉพาะจอเรา")
        end
    end
    if not scaleOn and (not spinOn or physicsSpin or angle == 0) then
        Hub.funRestoreVisual()
        return
    end
    local visual = Hub.Fun.Visual
    if not visual or visual.Character ~= char or visual.Dirty then
        visual = Hub.funBuildVisual(char, hum)
    end
    if not visual then
        return
    end
    local base = root.CFrame * CFrame.Angles(0, Hub.Fun.Yaw, 0)
    local whole = scaleOn and Config.FunScaleMode == "ทั้งตัว"
    for _, part in ipairs(visual.Parts) do
        local source, copy = part.Source, part.Copy
        if source:IsDescendantOf(char) then
            local factor = 1
            if whole then
                factor = Config.FunScale
            elseif scaleOn and part.Group then
                factor = Config[part.Group]
            end
            local pose = root.CFrame:ToObjectSpace(source.CFrame)
            local pivot = not whole and part.Pivot and root.CFrame:PointToObjectSpace(part.Pivot.Position) or Vector3.zero
            local offset = pivot + (pose.Position - pivot) * factor
            copy.CFrame = base * CFrame.new(offset) * pose.Rotation
            if part.Mesh and part.CopyMesh then
                copy.Size = source.Size
                part.CopyMesh.Scale, part.CopyMesh.Offset = part.Mesh.Scale * factor, part.Mesh.Offset * factor
            else
                local size = source.Size * factor
                copy.Size = Vector3.new(math.max(0.001, size.X), math.max(0.001, size.Y), math.max(0.001, size.Z))
            end
            copy.Transparency = source.Transparency
            if source.LocalTransparencyModifier ~= 1 then
                Hub.Effects.FunVisual[source].LocalTransparencyModifier.Original = source.LocalTransparencyModifier
                source.LocalTransparencyModifier = 1
            end
        else
            visual.Dirty = true
        end
    end
    if scaleOn then
        Hub.status("FunScaleEnabled", "local", "ปรับขนาดโมเดลเฉพาะจอเรา")
    end
end
connectSignal(RunService.PostSimulation, Hub.funFrame)
function Hub.trapRecords()
    local records, seen = {}, {}
    for _, tag in ipairs({ "PlacedTrap", "PlacedGravityDisruptor" }) do
        for _, object in ipairs(CollectionService:GetTagged(tag)) do
            if object.Parent and not seen[object] then
                seen[object] = true
                local hitbox = object:FindFirstChild("Hitbox", true)
                local part = hitbox and hitbox:IsA("BasePart") and hitbox or (object:IsA("BasePart") and object or object:FindFirstChildWhichIsA("BasePart", true))
                if part then
                    local size = part.Size
                    local effect = (Hub.Effects.AntiTrap or {})[part]
                    local original = effect and effect.CFrame and effect.CFrame.Original
                    table.insert(records, {
                        Object = object,
                        Part = part,
                        Position = original and original.Position or part.Position,
                        Radius = math.sqrt(size.X * size.X + size.Z * size.Z) * 0.5 + 3,
                        Kind = tag == "PlacedTrap" and "กับดัก" or "เครื่องรบกวนแรงโน้มถ่วง",
                    })
                end
            end
        end
    end
    return records
end
function Hub.serverRagdolled()
    local untilTime = tonumber(LocalPlayer:GetAttribute("RagdollEndTime"))
    return untilTime ~= nil and TimeUtil.diffSeconds(untilTime, TimeUtil.serverNow(Hub.ServerClock)) > 0
end
function Hub.isFallen()
    local hum = getLocalHumanoid()
    if not hum or hum.Health <= 0 then
        return true
    end
    local state = hum:GetState()
    return hum.PlatformStand or state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.GettingUp
end
function Hub.restoreFallStates()
    local swap = Hub.RagdollSwap
    if not swap then
        return
    end
    Hub.RagdollSwap = nil
    for _, connection in ipairs(swap.Links) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    local original, clone, char = swap.Original, swap.Clone, swap.Character
    if LocalPlayer.Character == char and char.Parent and original and not original.Parent then
        original.Parent = char
        if Workspace.CurrentCamera and Workspace.CurrentCamera.CameraSubject == clone then
            Workspace.CurrentCamera.CameraSubject = original
        end
    end
    if clone then
        pcall(function()
            clone:Destroy()
        end)
    end
end
function Hub.ragdollStep()
    if not Hub.featureEnabled("AntiFall") then
        Hub.restoreFallStates()
        return
    end
    local char, hum, root = LocalPlayer.Character, getLocalHumanoid(), getLocalRoot()
    if Hub.RagdollSwap and (char ~= Hub.RagdollSwap.Character or hum ~= Hub.RagdollSwap.Clone) then
        Hub.restoreFallStates()
        hum = getLocalHumanoid()
    end
    if not char or not hum or not root or hum.Health <= 0 then
        Hub.restoreFallStates()
        return
    end
    if Config.HidePlayer or Hub.HiddenPlayerUsed == char then
        Hub.restoreFallStates()
        Hub.status("AntiFall", "waiting", "พักการสลับ Humanoid ระหว่างใช้ร่างซ่อนตัว")
        return
    end
    if Hub.CharacterMutation or RuntimeState.IsCurrentlyOnTreadmill or Hub.RequestedTreadmillExit or Hub.MovementOwner == "AutoTreadmill" or Hub.ExitTarget or os.clock() < (Hub.ManualBeltApproachUntil or 0) or hum.Sit or root.Anchored then
        Hub.restoreFallStates()
        Hub.status("AntiFall", "waiting", "ใช้ Humanoid เดิมระหว่างอยู่บนลู่หรือเปลี่ยนร่าง")
        return
    end
    if Hub.RagdollSwap then
        Hub.status("AntiFall", "local", "ใช้ Humanoid สำรองฝั่งเราแล้ว; ยังไม่ยืนยันสถานะฝั่งเกม")
        return
    end
    if os.clock() < (Hub.RagdollRetryAt or 0) then
        return
    end
    if char:GetAttribute("IsTrapped") or Hub.isFallen() or Hub.serverRagdolled() or hum.FloorMaterial == Enum.Material.Air then
        Hub.status("AntiFall", "waiting", "รอร่างเดิมยืนบนพื้นก่อนสลับ Humanoid")
        return
    end
    Hub.funRestoreRotation()
    local clone
    local ok, err = pcall(function()
        local archivable = hum.Archivable
        hum.Archivable = true
        local copied, copy = pcall(hum.Clone, hum)
        hum.Archivable = archivable
        if not copied or not copy then
            error("ตัวละครไม่อนุญาตให้ clone Humanoid")
        end
        clone = copy
        local swap = { Original = hum, Clone = clone, Character = char, Links = {} }
        Hub.RagdollSwap = swap
        hum.Parent = nil
        clone.Parent = char
        if Workspace.CurrentCamera then
            Workspace.CurrentCamera.CameraSubject = clone
        end
        for _, property in ipairs({ "WalkSpeed", "JumpPower", "JumpHeight", "UseJumpPower" }) do
            table.insert(swap.Links, hum:GetPropertyChangedSignal(property):Connect(function()
                if Hub.RagdollSwap == swap and clone.Parent == char then
                    clone[property] = hum[property]
                end
            end))
        end
        local animator, copyAnimator = hum:FindFirstChildOfClass("Animator"), clone:FindFirstChildOfClass("Animator")
        if animator and copyAnimator then
            table.insert(swap.Links, animator.AnimationPlayed:Connect(function(track)
                if Hub.RagdollSwap ~= swap or not track.Animation then
                    return
                end
                local loaded, copy = pcall(copyAnimator.LoadAnimation, copyAnimator, track.Animation)
                if loaded and copy then
                    copy.Priority, copy.Looped = track.Priority, track.Looped
                    copy:Play(0.05, math.max(track.WeightTarget, 0.01), track.Speed)
                    local stopped
                    stopped = track.Stopped:Connect(function()
                        stopped:Disconnect()
                        pcall(copy.Stop, copy, 0.1)
                    end)
                    table.insert(swap.Links, stopped)
                end
            end))
        end
        table.insert(swap.Links, clone.Died:Connect(function()
            if Hub.RagdollSwap == swap then
                Hub.restoreFallStates()
                if hum.Parent == char then
                    hum.Health = 0
                end
            end
        end))
    end)
    if not ok then
        Hub.RagdollRetryAt = os.clock() + 5
        Hub.restoreFallStates()
        if clone and not clone.Parent then
            pcall(clone.Destroy, clone)
        end
        Hub.fail("AntiFall", err)
    else
        Hub.status("AntiFall", "local", "สลับ Humanoid ตามวิธีที่อ่านได้จาก unpack; ยังต้องทดสอบในเกม")
    end
end
function Hub.trapStep()
    if not Config.AntiTrap then
        return
    end
    Hub.Traps = Hub.trapRecords()
    for _, trap in ipairs(Hub.Traps) do
        local part = trap.Part
        if part and part.Parent then
            local record = (Hub.Effects.AntiTrap or {})[part]
            if not record then
                Hub.capture("AntiTrap", part, "CanTouch", false)
                Hub.capture("AntiTrap", part, "CanCollide", false)
                Hub.capture("AntiTrap", part, "Transparency", 1)
                Hub.capture("AntiTrap", part, "CFrame", part.CFrame - Vector3.new(0, 120, 0))
            end
        end
    end
    Hub.status("AntiTrap", "local", "ปิดการสัมผัสกับดักที่โหลดบนเครื่องเรา ไม่สั่งวิ่งหลบและไม่ยืนยันผลฝั่งเกม")
end
function Hub.antiAFKRestore()
    local state = Hub.AFK
    if not state then
        return
    end
    Hub.AFK = nil
    for _, connection in ipairs(state.Connections) do
        pcall(function()
            if connection.Enabled == false then
                connection:Enable()
            end
        end)
    end
    for _, entry in ipairs(state.Upvalues) do
        pcall(function()
            local current = debug.getupvalues(entry.Function)
            if current[entry.Index] == entry.Proxy then
                debug.setupvalue(entry.Function, entry.Index, entry.Original)
            end
        end)
    end
end
function Hub.antiAFKStep()
    if not Config.AntiAFK then
        Hub.antiAFKRestore()
        return
    end
    local now = os.clock()
    if Hub.AFK and now < Hub.AFK.NextScan then
        return
    end
    local state = Hub.AFK or { Connections = {}, Upvalues = {}, Seen = {} }
    Hub.AFK, state.NextScan = state, now + 5
    if type(getconnections) == "function" then
        local ok, connections = pcall(getconnections, LocalPlayer.Idled)
        if ok and type(connections) == "table" then
            for _, connection in ipairs(connections) do
                if not state.Seen[connection] and connection.Enabled ~= false and type(connection.Disable) == "function" and type(connection.Enable) == "function" then
                    local disabled = pcall(connection.Disable, connection)
                    if disabled and connection.Enabled == false then
                        state.Seen[connection] = true
                        table.insert(state.Connections, connection)
                    end
                end
            end
        end
    end
    if type(getgc) == "function" and type(islclosure) == "function" and type(debug.info) == "function" and type(debug.getupvalues) == "function" and type(debug.setupvalue) == "function" then
        local ok, objects = pcall(function()
            return getgc(false)
        end)
        if ok and type(objects) == "table" then
            for indexInGC, fn in ipairs(objects) do
                if indexInGC % 1500 == 0 then
                    task.wait()
                end
                if Hub.AFK ~= state or not Config.AntiAFK then
                    return
                end
                if type(fn) == "function" and not state.Seen[fn] then
                    local luaOK, isLua = pcall(islclosure, fn)
                    local sourceOK, source = pcall(function()
                        return debug.info(fn, "s")
                    end)
                    if luaOK and isLua and sourceOK and type(source) == "string" and source:find("AntiAFK", 1, true) then
                        local readOK, values = pcall(debug.getupvalues, fn)
                        if readOK and type(values) == "table" then
                            for index, original in pairs(values) do
                                if typeof(original) == "Instance" and original.ClassName == "TeleportService" then
                                    local proxy = setmetatable({}, {
                                        __index = function(_, key)
                                            if tostring(key):match("^Teleport") then
                                                return function() end
                                            end
                                            local value = original[key]
                                            if type(value) == "function" then
                                                return function(_, ...)
                                                    return value(original, ...)
                                                end
                                            end
                                            return value
                                        end,
                                    })
                                    if pcall(debug.setupvalue, fn, index, proxy) then
                                        local verifyOK, updated = pcall(debug.getupvalues, fn)
                                        if verifyOK and type(updated) == "table" and updated[index] == proxy then
                                            table.insert(state.Upvalues, {
                                                Function = fn,
                                                Index = index,
                                                Original = original,
                                                Proxy = proxy,
                                            })
                                        end
                                    end
                                end
                            end
                            state.Seen[fn] = true
                        end
                    end
                end
            end
        end
    end
    local count = #state.Connections + #state.Upvalues
    Hub.status("AntiAFK", count > 0 and "local" or "waiting", count > 0 and ("พักตัวจับ AFK ฝั่งเรา " .. count .. " จุด; คืนค่าเมื่อปิด") or "ยังไม่พบตัวจับ AFK ที่ตัวรันเข้าถึงได้")
end
function Hub.guardDestination()
    local cycle = Hub.CarryCycle
    if cycle and cycle.ReturnGoal then
        return cycle.ReturnGoal
    end
    local root = getLocalRoot()
    local world = Workspace:FindFirstChild("World")
    local areas = world and world:FindFirstChild("Areas")
    local line = areas and areas:FindFirstChild("SeparationLine")
    if not line or not root then
        return
    end
    local side = math.clamp(line.CFrame.RightVector:Dot(root.Position - line.Position), -line.Size.X * 0.45, line.Size.X * 0.45)
    return line.Position + line.CFrame.RightVector * side - line.CFrame.LookVector * 7
end
function Hub.guardRagdollChanged()
    if not Config.AntiGuard or not Hub.isNormalDeliveryMode() or not Hub.serverRagdolled() or Hub.CharacterMutation then
        return
    end
    local root, hum = getLocalRoot(), getLocalHumanoid()
    if not root or not hum or root.Anchored or RuntimeState.IsCurrentlyOnTreadmill or not Hub.inGameplay(root.Position) then
        return
    end
    local carry = Hub.rawCarryState()
    local arm = Hub.GuardAction
    local armed = arm and arm.Armed and arm.Until > os.clock() and Hub.alive(arm.Owner, arm.Token)
    if not (carry and carry.IsCarrying) and not armed then
        return
    end
    local destination = Hub.guardDestination()
    if not destination then
        return
    end
    Hub.GuardAction = { Busy = true, Until = os.clock() + 0.2 }
    Hub.GuardDodge = { AvoidUntil = os.clock() + 1.5 }
    Hub.clearNavigation()
    root.CFrame = CFrame.new(destination) * root.CFrame.Rotation
    root.AssemblyLinearVelocity = Vector3.zero
    Hub.status("AntiGuard", "requested", "ตอบสนองต่อสถานะล้มระหว่างขโมยแล้ว รอเกมยืนยันไข่")
end
function Hub.knockbackFrame()
    if not Config.AntiKnockback or Hub.CharacterMutation or Hub.DeliveryStop or RuntimeState.IsCurrentlyOnTreadmill or Hub.GuardAction and Hub.GuardAction.Busy then
        return
    end
    local root, hum = getLocalRoot(), getLocalHumanoid()
    if not root or not hum or root.Anchored or not Hub.isFallen() and not Hub.serverRagdolled() then
        return
    end
    local velocity, limit = root.AssemblyLinearVelocity, Hub.runSpeed() + 5
    local horizontal = Hub.flat(velocity)
    if horizontal.Magnitude > limit then
        horizontal = horizontal.Unit * limit
    end
    root.AssemblyLinearVelocity = Vector3.new(horizontal.X, math.min(velocity.Y, 0), horizontal.Z)
    root.AssemblyAngularVelocity = Vector3.zero
    Hub.status("AntiKnockback", "local", "ลดแรงกระเด็นระหว่างล้ม โดยไม่จำกัดการวิ่งปกติ")
end
function Hub.defenseFrame()
    if not IsScriptRunning then
        return
    end
    if Hub.DeliveryStop and not Hub.deliveryStopAlive(Hub.DeliveryStop) then
        Hub.stopDeliveryStop()
    end
    if Hub.GuardAction and Hub.GuardAction.Busy and os.clock() >= Hub.GuardAction.Until then
        Hub.GuardAction = nil
    end
    Hub.knockbackFrame()
end
connectSignal(LocalPlayer:GetAttributeChangedSignal("RagdollEndTime"), Hub.guardRagdollChanged)
connectSignal(RunService.PreSimulation, Hub.defenseFrame)
connectSignal(RunService.PreSimulation, function(dt)
    if Hub.Nav.Owner ~= "AutoStealEgg" then
        Hub.followNavigation(dt)
    end
end)
connectSignal(RunService.Heartbeat, Hub.followNavigation)
function Hub.restoreHiddenPlayer()
    local state = Hub.HiddenPlayer
    if not state then
        return
    end
    Hub.HiddenPlayer = nil
    if Hub.CharacterMutation == "HidePlayer" then
        Hub.CharacterMutation = nil
    end
    local root = state.Character:FindFirstChild("HumanoidRootPart")
    if state.HumanoidAdded then
        state.HumanoidAdded:Disconnect()
    end
    if root and state.RootCollide ~= nil and root.CanCollide == state.RootAppliedCollide then
        root.CanCollide = state.RootCollide
    end
    if state.Wrist then
        state.Wrist:Destroy()
    end
    if state.Hand then
        state.Hand:Destroy()
    end
    if state.Character.Parent then
        for _, part in ipairs(state.Detached) do
            if not part.Parent then
                pcall(function()
                    part.Parent = state.Character
                end)
            end
        end
    end
    local hum = state.Humanoid
    if hum.Parent then
        if hum.HipHeight == 999 then
            hum.HipHeight = state.HipHeight
        end
        if not hum.RequiresNeck then
            hum.RequiresNeck = state.RequiresNeck
        end
        if not hum.BreakJointsOnDeath then
            hum.BreakJointsOnDeath = state.BreakJointsOnDeath
        end
        if not hum:GetStateEnabled(Enum.HumanoidStateType.Dead) then
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, state.DeadEnabled)
        end
    end
end
function Hub.applyHiddenPlayer(token, char, hum, root)
    if not Hub.alive("HidePlayer", token) or LocalPlayer.Character ~= char then
        return
    end
    local canRead, signal = pcall(function()
        return hum.ServerBreakJoints
    end)
    if not canRead or not signal then
        Hub.Disabled.HidePlayer = "เกมหรือตัวรันไม่เปิด Humanoid.ServerBreakJoints"
        Config.HidePlayer = false
        syncAllFeatureStates("HidePlayer")
        return
    end
    local state = {
        Character = char,
        Humanoid = hum,
        Detached = {},
        StartedAt = os.clock(),
        HipHeight = hum.HipHeight,
        RequiresNeck = hum.RequiresNeck,
        BreakJointsOnDeath = hum.BreakJointsOnDeath,
        DeadEnabled = hum:GetStateEnabled(Enum.HumanoidStateType.Dead),
    }
    Hub.HiddenPlayer = state
    Hub.CharacterMutation = "HidePlayer"
    local ok, message = pcall(function()
        hum:UnequipTools()
        hum:UnequipTools()
        hum.RequiresNeck = false
        hum.BreakJointsOnDeath = false
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        for _ = 1, 2 do
            local sent, result = pcall(replicatesignal, signal)
            if not sent or result == false then
                error("ตัวรันส่งสัญญาณซ่อนไม่สำเร็จ")
            end
            Hub.HiddenPlayerUsed = char
        end
        Hub.HiddenPlayerUsed = char
        hum.HipHeight = 999
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Accessory") or child:IsA("BasePart") and child ~= root then
                table.insert(state.Detached, child)
                child.Parent = nil
            end
        end
        task.wait(0.12)
        if Hub.HiddenPlayer ~= state then
            return
        end
        if not Hub.alive("HidePlayer", token) then
            Hub.restoreHiddenPlayer()
            return
        end
        if LocalPlayer.Character ~= char or hum.Health <= 0 or not root.Parent then
            error("ตัวละครไม่พร้อมหลังส่งคำสั่งซ่อน")
        end
        local wrist, hand = Instance.new("Motor6D"), Instance.new("Part")
        state.Wrist, state.Hand = wrist, hand
        hand.Name, hand.Size, hand.Transparency = "RightHand", Vector3.new(0.2, 0.2, 0.2), 1
        hand.CanCollide, hand.CanTouch, hand.CanQuery, hand.Massless = false, false, false, true
        wrist.Name, wrist.C0 = "RightWrist", CFrame.new(1.2, 0, 0)
        hand.CFrame = root.CFrame * wrist.C0
        hand.Parent, wrist.Part0, wrist.Part1, wrist.Parent = char, root, hand, root
        hum.HipHeight = state.HipHeight
        char:SetAttribute("InvisApplied", true)
        state.RootCollide, state.RootAppliedCollide = root.CanCollide, false
        root.CanCollide = false
        task.delay(0.2, function()
            if Hub.HiddenPlayer == state and root.Parent == char and root.CanCollide == false then
                root.CanCollide, state.RootAppliedCollide = true, true
            end
        end)
        state.HumanoidAdded = char.ChildAdded:Connect(function(child)
            if child:IsA("Humanoid") and Hub.HiddenPlayer == state then
                child.HipHeight = state.HipHeight
            end
        end)
    end)
    if Hub.CharacterMutation == "HidePlayer" then
        Hub.CharacterMutation = nil
    end
    if Hub.HiddenPlayer ~= state then
        return
    end
    if ok then
        Hub.status("HidePlayer", "requested", "ส่งคำขอซ่อนแล้ว ยังยืนยันจากจอคนอื่นไม่ได้; คืนร่างฝั่งเกมต้องเกิดใหม่")
    else
        Config.HidePlayer = false
        Hub.restoreHiddenPlayer()
        syncAllFeatureStates("HidePlayer")
        Hub.fail("HidePlayer", message)
    end
end
function Hub.hidePlayerStep(carry)
    if not Config.HidePlayer then
        return false
    end
    local available, reason = Hub.available("HidePlayer")
    if not available then
        Hub.status("HidePlayer", "waiting", reason)
        return false
    end
    if Hub.Jobs.HidePlayer then
        return true
    end
    local char, hum, root = LocalPlayer.Character, getLocalHumanoid(), getLocalRoot()
    if Hub.HiddenPlayerUsed == char and char then
        if not Hub.HiddenPlayer then
            Hub.status("HidePlayer", "waiting", "รีเซ็ตตัวละครก่อนซ่อนอีกครั้ง")
        end
        return false
    end
    if not char or not hum or not root or not char:FindFirstChild("Head") or hum.RigType ~= Enum.HumanoidRigType.R15 then
        Hub.status("HidePlayer", "waiting", "รอตัวละคร R15 พร้อม")
        return false
    end
    if not carry or carry.IsCarrying or Hub.InventoryOwner or RuntimeState.IsCurrentlyOnTreadmill or Hub.isFallen() or Hub.RequestedTreadmillExit or Hub.ExitTarget or root.Anchored or char:GetAttribute("IsTrapped") then
        Hub.status("HidePlayer", "waiting", "รอออกจากลู่ วางไข่ และให้ตัวละครพร้อมก่อนซ่อน")
        return false
    end
    Hub.restoreFallStates()
    char, hum, root = LocalPlayer.Character, getLocalHumanoid(), getLocalRoot()
    Hub.acquire(nil)
    return Hub.job("HidePlayer", 1, true, function(token)
        Hub.applyHiddenPlayer(token, char, hum, root)
    end)
end
function Hub.treadmillBottom()
    if Config.AutoAdminTreadmill then
        for _, name in ipairs({ "AdminAbuseTreadmill", "RainbowTreadmill" }) do
            local adm = Workspace:FindFirstChild(name, true)
            if adm then
                local b = adm:IsA("BasePart") and adm or adm:FindFirstChild("TreadmillBottom", true) or adm:FindFirstChildWhichIsA("BasePart", true)
                if b and b:IsA("BasePart") then
                    return b
                end
            end
        end
    end
    local plot = findLocalPlotFallback()
    local bottom = plot and plot.PlotFolder:FindFirstChild("TreadmillBottom", true)
    if bottom and bottom:IsA("BasePart") then
        return bottom
    end
    return nil
end
function Hub.treadmillFootprint(root, bottom, margin)
    if not root or not bottom then
        return nil
    end
    local point = bottom.CFrame:PointToObjectSpace(root.Position)
    if math.abs(point.X) <= bottom.Size.X * 0.5 + margin and math.abs(point.Z) <= bottom.Size.Z * 0.5 + margin and point.Y >= -1 and point.Y <= bottom.Size.Y * 0.5 + 8 then
        return point
    end
    return nil
end
function Hub.treadmillJump()
    if not IsScriptRunning or isTextBoxFocused() then
        return
    end
    if not RuntimeState.IsCurrentlyOnTreadmill then
        if Hub.ExitTarget or not Hub.treadmillFootprint(getLocalRoot(), Hub.treadmillBottom(), 0.5) then
            return
        end
    end
    Hub.TreadmillJumpUntil = os.clock() + 2
    Hub.restoreFallStates()
    Hub.doffTreadmill(true)
end
function Hub.treadmillInputActive()
    if isTextBoxFocused() then
        return false
    end
    local controls = Hub.TreadmillControls
    local move = controls and controls:GetMoveVector()
    return (move and move.Magnitude > 0.1) or UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Up) or UserInputService:IsKeyDown(Enum.KeyCode.Down) or UserInputService:IsKeyDown(Enum.KeyCode.Left) or UserInputService:IsKeyDown(Enum.KeyCode.Right)
end
function Hub.treadmillSession(id, source)
    local active = RuntimeState.IsCurrentlyOnTreadmill
    local now = os.clock()
    if type(id) == "string" then
        if not active then
            local manual = now < (Hub.ManualBeltApproachUntil or 0) or Hub.treadmillInputActive()
            Hub.TreadmillSessionVersion = (Hub.TreadmillSessionVersion or 0) + 1
            Hub.TreadmillAuto = not manual and (source == "auto" or Hub.TreadmillAutoRequest ~= nil or (Config.AutoTreadmill and Hub.MovementOwner == "AutoTreadmill"))
            Hub.TreadmillEnteredAt = now
            if Hub.TreadmillAuto then
                Hub.TreadmillAfterSteal, Hub.TreadmillTurnUntil = nil, nil
                Hub.StealEntry, Hub.PenExit = nil, nil
            end
            Hub.TreadmillManualExit, Hub.ExitTarget, Hub.NextDoffAttempt = nil, nil, nil
            Hub.restoreFallStates()
            Hub.clearNavigation()
        end
        RuntimeState.IsCurrentlyOnTreadmill = true
        if id ~= "local" or not Hub.TreadmillId then
            Hub.TreadmillId = id
        end
        return
    end
    local jumped = Hub.TreadmillManualExit or now < (Hub.TreadmillJumpUntil or 0)
    if not active and not jumped then
        return
    end
    local auto = Hub.TreadmillAuto or (Config.AutoStealEgg and Config.AutoTreadmill)
    local walkAway = auto or jumped or Hub.RequestedTreadmillExit or Config.AutoStealEgg
    if auto then
        Hub.TreadmillDueAt = now + 45
        Hub.TreadmillAfterSteal, Hub.TreadmillTurnUntil = nil, nil
    end
    RuntimeState.IsCurrentlyOnTreadmill = false
    Hub.TreadmillSessionVersion = (Hub.TreadmillSessionVersion or 0) + 1
    Hub.TreadmillId, Hub.TreadmillAuto, Hub.TreadmillEnteredAt = nil, nil, nil
    Hub.TreadmillManualExit, Hub.TreadmillJumpUntil, Hub.RequestedTreadmillExit = nil, nil, nil
    Hub.TreadmillRestUntil = now + (jumped and math.max(Config.TreadmillRestSeconds, 2) or Config.TreadmillRestSeconds)
    local root, bottom = getLocalRoot(), Hub.treadmillBottom()
    local foot = Hub.treadmillFootprint(root, bottom, 0.75)
    if foot and walkAway then
        local side = foot.X < 0 and -1 or 1
        local edge = bottom.Size.X * 0.5 + 6
        local along = bottom.Position + bottom.CFrame.LookVector * -foot.Z
        local exit = along + bottom.CFrame.RightVector * (side * edge)
        local hum = getLocalHumanoid()
        if hum and Hub.runWall(root.Position, Hub.flat(exit - root.Position), hum, Hub.navigationRayParams()) then
            exit = along - bottom.CFrame.RightVector * (side * edge)
        end
        Hub.ExitTarget, Hub.ExitStartedAt = exit, now
        Hub.ManualBeltApproachUntil = nil
    elseif jumped or not auto then
        Hub.ManualBeltApproachUntil = now + 1.25
    end
    Hub.status("AutoTreadmill", "confirmed", "เกมยืนยันลงจากลู่วิ่งแล้ว")
end
function Hub.treadmillStep()
    local now = os.clock()
    if RuntimeState.IsCurrentlyOnTreadmill then
        local otherMovement = not Config.AutoStealEgg and Hub.MovementOwner and Hub.MovementOwner ~= "AutoTreadmill"
        if (Hub.TreadmillAuto or Config.AutoStealEgg) and not Hub.TreadmillManualExit and (otherMovement or not Config.AutoTreadmill or now - Hub.TreadmillEnteredAt >= Config.TreadmillRunSeconds) then
            Hub.doffTreadmill()
        end
    elseif not Hub.DeliveryStop and not Hub.ExitTarget and Hub.treadmillInputActive() and Hub.treadmillFootprint(getLocalRoot(), Hub.treadmillBottom(), 7) then
        Hub.ManualBeltApproachUntil = now + 1.25
        Hub.restoreFallStates()
    end
    if Hub.ExitTarget and now - Hub.ExitStartedAt > 8 then
        Hub.ExitTarget = nil
    end
end
function Hub.bindTreadmill()
    if Hub.TreadmillBound then
        return
    end
    local remote = Hub.remote("Treadmill", "AssignedBeltShifted", "event")
    if not remote or not remote.OnClientEvent then
        return
    end
    Hub.TreadmillBound = true
    connectSignal(remote.OnClientEvent, function(id)
        Hub.treadmillSession(id)
    end)
end
function Hub.move(owner, token, position, radius)
    if Hub.MovementOwner ~= owner or not Hub.ownerAlive(owner, token) or not Hub.stepOff() then
        return false
    end
    local root, hum = getLocalRoot(), getLocalHumanoid()
    if not root or not hum or hum.Health <= 0 or root.Anchored or Hub.isFallen() then
        return false
    end
    Hub.setWalkGoal(owner, token, position, radius)
    return true
end
function Hub.stopForInteraction()
    Hub.clearNavigation()
    local hum = getLocalHumanoid()
    if hum then
        hum:Move(Vector3.zero, false)
    end
end
function Hub.readEgg(uid)
    local save = getPlayerSaveData()
    local saved = save and save.EggInventory and save.EggInventory[uid]
    local observed
    if EggState and EggState.ReadOwnedEgg then
        local ok, record = pcall(EggState.ReadOwnedEgg, LocalPlayer.UserId, uid)
        if ok and type(record) == "table" then
            observed = record
        end
    end
    if saved and saved.Placement then
        return saved
    end
    if observed and observed.Placement then
        return observed
    end
    return observed or saved
end
function Hub.placeQueue(save)
    local records = save and save.EggInventory or {}
    if EggState and EggState.ReadOwnerEggs then
        local ok, owned = pcall(EggState.ReadOwnerEggs, LocalPlayer.UserId)
        if ok and type(owned) == "table" and (next(owned) or not next(records)) then
            records = owned
        end
    end
    local slots = {}
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if Config.PlaceOrder == "Slot" and backpack then
        for index, tool in ipairs(backpack:GetChildren()) do
            local uid = tool:GetAttribute("UID")
            if tool:IsA("Tool") and type(uid) == "string" then
                slots[uid] = index
            end
        end
    end
    local queue, occupied, placed = {}, {}, 0
    local receipts = Hub.PlaceReceipts or {}
    local now = os.clock()
    for uid, receipt in pairs(receipts) do
        local record = records[uid]
        if now - receipt.At >= 5 or record and record.Placement then
            receipts[uid] = nil
        end
    end
    for uid, record in pairs(records) do
        if type(uid) == "string" and type(record) == "table" then
            if record.Placement then
                placed = placed + 1
                local cf = record.Placement.LocalCFrame
                if type(cf) == "table" then
                    cf = CFrame.new(table.unpack(cf, 1, 12))
                end
                if (type(typeof) == "function" and typeof(cf) == "CFrame") or (type(cf) == "table" and cf.Position ~= nil) then
                    occupied[#occupied + 1] = Vector2.new(cf.Position.X, cf.Position.Z)
                end
            elseif not receipts[uid] and (type(Hub.PlaceRetryAt) == "table" and Hub.PlaceRetryAt[uid] or 0) <= now and type(record.AssetCategory) == "string" then
                local metrics = Hub.eggFarmMetrics(record)
                if filterAllows(Config.PlaceRarities, metrics.RarityId) and filterAllows(Config.PlaceSpecies, record.AssetCategory) and metrics.Income >= Config.PlaceMinIncome then
                    queue[#queue + 1] = {
                        Uid = uid,
                        Scale = metrics.Scale,
                        Income = metrics.Income,
                        Slot = slots[uid] or math.huge,
                    }
                end
            end
        end
    end
    for _, receipt in pairs(receipts) do
        placed = placed + 1
        occupied[#occupied + 1] = receipt.Position
    end
    local order = Config.PlaceOrder
    table.sort(queue, function(a, b)
        if order == "Income" and a.Income ~= b.Income then
            return a.Income > b.Income
        end
        if order == "Small" and a.Scale ~= b.Scale then
            return a.Scale < b.Scale
        end
        if order == "Slot" and a.Slot ~= b.Slot then
            return a.Slot < b.Slot
        end
        if a.Scale ~= b.Scale then
            return a.Scale > b.Scale
        end
        return a.Uid < b.Uid
    end)
    return queue, occupied, math.max(0, 30 - placed)
end
function Hub.penCells(occupied)
    local cells = {}
    for x = -24, 8, 4 do
        for z = 4, 30, 4 do
            local cell = Vector2.new(x, z)
            local clear = true
            for _, used in ipairs(occupied) do
                if (used - cell).Magnitude < 5 then
                    clear = false
                    break
                end
            end
            if clear then
                cells[#cells + 1] = CFrame.new(x, -0.5, z)
            end
        end
    end
    for i = #cells, 2, -1 do
        local j = math.random(1, i)
        cells[i], cells[j] = cells[j], cells[i]
    end
    return cells
end
function Hub.flyToPen(anchor, token)
    local root = getLocalRoot()
    if not root or root.Anchored then
        return false
    end
    if (root.Position - anchor).Magnitude <= 26 then
        return true
    end
    local destination = anchor + Vector3.new(0, 3, 0)
    local height = math.max(root.Position.Y, destination.Y) + 30
    local rotation = root.CFrame.Rotation
    local startedAt = TimeUtil.unixNow()
    local frameDelta = 0.016
    Hub.status("AutoPlaceEgg", "local", "กำลังเคลื่อนตัวข้ามสิ่งกีดขวางไปยังคอก")
    for _, waypoint in ipairs({
        Vector3.new(root.Position.X, height, root.Position.Z),
        Vector3.new(destination.X, height, destination.Z),
        destination,
    }) do
        while (waypoint - root.Position).Magnitude > 0.5 do
            if TimeUtil.diffSeconds(TimeUtil.unixNow(), startedAt) >= 25 or not Hub.alive("AutoPlaceEgg", token) or getLocalRoot() ~= root or root.Anchored or RuntimeState.IsCurrentlyOnTreadmill or Hub.isFallen() then
                return false
            end
            local delta = waypoint - root.Position
            local speed = Hub.runSpeed()
            if speed <= 0 then
                return false
            end
            local step = delta.Unit * math.min(delta.Magnitude, speed * math.min(tonumber(frameDelta) or 0.016, 0.1))
            local point = root.Position + step
            root.CFrame = CFrame.new(point) * rotation
            root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
            frameDelta = RunService.Heartbeat:Wait()
            if (root.Position - point).Magnitude > 6 then
                return false
            end
        end
    end
    return (root.Position - anchor).Magnitude <= 26
end
function Hub.placeEggBatch(plot, token)
    local key, anchor = "AutoPlaceEgg", plot.PetArea.Position
    local queue, occupied, free = Hub.placeQueue(getPlayerSaveData())
    if free == 0 or #queue == 0 then
        return
    end
    Hub.stopForInteraction()
    if not Hub.flyToPen(anchor, token) then
        if Hub.alive(key, token) then
            Hub.PlaceBlockedUntil = os.clock() + 6
            Hub.status(key, "waiting", "ยังเข้าไม่ถึงคอก")
        end
        return
    end
    Hub.PlaceReceipts = Hub.PlaceReceipts or {}
    Hub.PlaceRetryAt = Hub.PlaceRetryAt or {}
    local planted, failures, worn = 0, 0, nil
    local character = LocalPlayer.Character
    local function ready(name)
        if Hub.InFlight[name] then
            return false
        end
        local delay = 0.35 - (os.clock() - (Hub.LastRequest[name] or -math.huge))
        if delay > 0 then
            task.wait(delay + 0.01)
        end
        local root = getLocalRoot()
        return Hub.alive(key, token) and root and (root.Position - anchor).Magnitude <= 26 and not Hub.InFlight[name]
    end
    for _, entry in ipairs(queue) do
        if planted >= free or failures >= 2 or not Hub.alive(key, token) then
            break
        end
        local uid = entry.Uid
        local cells = Hub.penCells(occupied)
        if #cells == 0 then
            break
        end
        if not Hub.flyToPen(anchor, token) or not ready("EggWorld.AskWearTool") then
            break
        end
        local record = Hub.readEgg(uid)
        if record and not record.Placement and Hub.rpc(key, token, "EggWorld", "AskWearTool", "function", uid) then
            worn = uid
            task.wait(0.15)
            local success = false
            for i = 1, math.min(8, #cells) do
                if not ready("EggWorld.AskPlaceEgg") then
                    break
                end
                local cell = cells[i]
                if Hub.rpc(key, token, "EggWorld", "AskPlaceEgg", "function", { Uid = uid, LocalCFrame = cell }) then
                    local position = Vector2.new(cell.Position.X, cell.Position.Z)
                    occupied[#occupied + 1] = position
                    Hub.PlaceReceipts[uid] = { Position = position, At = os.clock() }
                    planted, failures, success = planted + 1, 0, true
                    if Hub.PlacedEggRenderer and Hub.PlacedEggRenderer.Refresh then
                        Hub.PlacedEggRenderer.Refresh()
                    end
                    break
                end
            end
            if not success then
                Hub.PlaceRetryAt[uid] = os.clock() + 6
                failures = failures + 1
            end
        elseif record and not record.Placement then
            Hub.PlaceRetryAt[uid] = os.clock() + 6
            failures = failures + 1
        end
    end
    if worn and EggState and EggState.DoffEggTool and LocalPlayer.Character == character then
        task.spawn(function()
            pcall(EggState.DoffEggTool, worn)
        end)
    end
    if not Hub.alive(key, token) then
        return
    end
    if planted > 0 then
        local spawn = plot.RespawnPointCFrame or plot.CenterPoint
        Hub.PenExit = spawn and { Position = spawn.Position, Anchor = anchor }
        Hub.StealEntry = nil
        Hub.status(key, "confirmed", "เกมตอบรับการวางไข่ " .. planted .. " ฟอง")
    else
        Hub.PlaceBlockedUntil = os.clock() + 6
        Hub.status(key, "waiting", "ยังไม่พบตำแหน่งที่เกมรับในคอก")
    end
end
function Hub.finishCarryCycle(cycle, claimed, field)
    if cycle then
        cycle.Claimed = claimed
    end
    if Hub.DeliveryStop and Hub.DeliveryStop.Cycle == cycle then
        Hub.stopDeliveryStop()
    end
    Hub.StealCurrentStep = 0
    if cycle and cycle.Uid then
        if claimed then
            Hub.FinishedEggs = Hub.FinishedEggs or {}
            Hub.FinishedEggs[cycle.Uid] = os.clock() + 60
            Hub.StealPins[cycle.Uid] = nil
            if Hub.StealForceUid == cycle.Uid then
                Hub.StealForceUid = nil
            end
            if cycle.Owner == "AutoStealEgg" and Config.AutoTreadmill then
                Hub.TreadmillAfterSteal = true
            end
        elseif cycle.Owner == "AutoStealEgg" then
            if field and field.State == "Dropped" then
                Hub.CarryDropTarget = table.clone(field)
                Hub.CarryDropTarget.RecoverUntil = os.clock() + 5
            else
                Hub.CarryDropTarget = nil
                Hub.StealRetryUid, Hub.StealRetryAt = cycle.Uid, os.clock() + 1.5
            end
        end
    end
    Hub.CarryCycle, Hub.StealTargetUid, Hub.ReturnGoal = nil, nil, nil
    Hub.clearNavigation()
    if cycle then
        local message = claimed and "เกมยืนยันขนไข่กลับแล้ว" or "ไข่หลุดจากมือ รอตำแหน่งล่าสุดจากเกม"
        if not claimed and field and field.State == "Slot" then
            message = "ไข่กลับรังแล้ว จะเลือกใหม่จากข้อมูลสนาม"
        end
        Hub.status(cycle.Owner, claimed and "confirmed" or "waiting", message)
    end
end
function Hub.confirmCarry(owner, egg, carry)
    local current = Hub.CarryCycle
    if current and current.Uid == egg.Uid and current.Owner == owner then
        if carry and carry.IsCarrying then
            current.HadCarry, current.NoCarryAt = true, nil
            current.GuardDisabled = carry.GuardDisabled == true
        end
        return
    end
    if Hub.DeliveryStop then
        Hub.stopDeliveryStop()
    end
    local record = table.clone(egg)
    Hub.CarryCycle = {
        Owner = owner,
        Uid = egg.Uid,
        Record = record,
        At = os.clock(),
        HadCarry = carry and carry.IsCarrying == true,
        InitialState = egg.State,
        InitialVersion = tonumber(egg.Version),
        EventRevision = Hub.CarryEventRevision or 0,
        GuardDisabled = carry and carry.GuardDisabled == true,
    }
    Hub.StealTargetUid, Hub.ReturnGoal, Hub.CarryDropTarget = nil, nil, nil
    if owner == "AutoStealEgg" then
        Hub.StealPickupUntil, Hub.StealEntry, Hub.PenExit = nil, nil, nil
    end
    if owner == "AutoAttack" then
        Hub.RecoveryCarry = true
    end
    Hub.clearNavigation()
    if Hub.returnEgg and not Hub.ExitTarget and not RuntimeState.IsCurrentlyOnTreadmill then
        local root = getLocalRoot()
        if root then
            Hub.acquire(owner)
            Hub.MotionTarget = record
            Hub.returnEgg(owner, Hub.Generation[owner] or 0, root)
        end
    end
end
function Hub.onCarryChanged(state)
    if type(state) ~= "table" or not state.IsCarrying or not state.Uid then
        return
    end
    local owner = Hub.MovementOwner
    if (owner ~= "AutoStealEgg" or not Config.AutoStealEgg) and (owner ~= "AutoAttack" or not Config.AutoAttack or not (Hub.RecoveryCarry or Hub.RecoveryEgg)) then
        return
    end
    local target = Hub.MotionTarget
    if not target or target.Uid ~= state.Uid then
        target = {
            Uid = state.Uid,
            AreaId = state.AreaId,
            AssetCategory = state.AssetCategory,
            State = "Carried",
        }
    end
    Hub.confirmCarry(owner, target, state)
end
function Hub.carryFieldEvidence(cycle, fresh)
    local now = os.clock()
    if not fresh and now - (cycle.EvidenceAt or -math.huge) < 0.08 then
        return cycle.FieldRecord
    end
    cycle.EvidenceAt = now
    local record, read
    if EggState and EggState.ReadFieldEgg then
        read, record = pcall(EggState.ReadFieldEgg, cycle.Uid)
    elseif EggState and EggState.ReadFieldEggs then
        local ok, snapshot = pcall(EggState.ReadFieldEggs)
        if ok and type(snapshot) == "table" and type(snapshot.Records) == "table" then
            read = true
            for _, entry in pairs(snapshot.Records) do
                if entry.Uid == cycle.Uid then
                    record = entry
                    break
                end
            end
        end
    end
    if read and type(record) == "table" and record.Uid == cycle.Uid then
        local version = tonumber(record.Version)
        if not cycle.FieldVersion or not version or version >= cycle.FieldVersion then
            cycle.FieldRecord, cycle.FieldVersion = record, version or cycle.FieldVersion
            cycle.FieldMissingAt = nil
        end
    elseif read and record == nil then
        cycle.FieldRecord = nil
        cycle.FieldMissingAt = cycle.FieldMissingAt or now
    end
    return cycle.FieldRecord
end
function Hub.carryState()
    local state = Hub.rawCarryState()
    local cycle = Hub.CarryCycle
    if not cycle and state and state.IsCarrying then
        if state.Uid and (Hub.FinishedEggs or {})[state.Uid] and Hub.FinishedEggs[state.Uid] > os.clock() then
            return { IsCarrying = false, SpeedMultiplier = 1 }
        end
        local owner = Config.AutoStealEgg and "AutoStealEgg" or (Config.AutoAttack and Hub.RecoveryCarry and "AutoAttack")
        if owner and state.Uid then
            Hub.confirmCarry(owner, {
                Uid = state.Uid,
                AreaId = state.AreaId,
                AssetCategory = state.AssetCategory,
                State = "Carried",
            }, state)
            cycle = Hub.CarryCycle
        end
    end
    if not cycle then
        return state
    end
    if state and state.IsCarrying and state.Uid and state.Uid ~= cycle.Uid then
        local owner = cycle.Owner
        Hub.finishCarryCycle(cycle, false)
        Hub.confirmCarry(owner, {
            Uid = state.Uid,
            AreaId = state.AreaId,
            AssetCategory = state.AssetCategory,
            State = "Carried",
        }, state)
        cycle = Hub.CarryCycle
    end
    if not Config[cycle.Owner] then
        if Hub.DeliveryStop then
            Hub.stopDeliveryStop()
        end
        Hub.CarryCycle, Hub.ReturnGoal = nil, nil
        return state
    end
    local field = Hub.carryFieldEvidence(cycle)
    local root, save = getLocalRoot(), getPlayerSaveData()
    local safe = root and not Hub.inGameplay(root.Position)
    local arrived = safe and Hub.ReturnGoal and Hub.distance(root.Position, Hub.ReturnGoal) <= 3
    local stored = save and (save.EggInventory or {})[cycle.Uid]
    if cycle.Claimed or (cycle.HadCarry and field and field.State == "Claimed") or (safe and stored and state and not state.IsCarrying) then
        Hub.finishCarryCycle(cycle, true)
        return { IsCarrying = false, SpeedMultiplier = 1 }
    end
    if state and state.IsCarrying and (not state.Uid or state.Uid == cycle.Uid) then
        cycle.HadCarry, cycle.LastCarryAt, cycle.NoCarryAt = true, os.clock(), nil
        cycle.SpeedMultiplier = state.SpeedMultiplier or cycle.SpeedMultiplier
        cycle.GuardDisabled = state.GuardDisabled == true
        return state
    end
    local now = os.clock()
    local newer = field and ((cycle.InitialVersion and tonumber(field.Version) and field.Version > cycle.InitialVersion) or (not cycle.InitialVersion and field.State ~= cycle.InitialState))
    local transferring = Hub.DeliveryStop and Hub.DeliveryStop.Transferring
    if state and not state.IsCarrying then
        cycle.NoCarryAt = cycle.NoCarryAt or now
        local lost = newer and (field.State == "Dropped" or field.State == "GuardCarried" or field.State == "Slot" or field.State == "Carried" and field.CarrierUserId and field.CarrierUserId ~= LocalPlayer.UserId)
        local missing = cycle.FieldMissingAt and now - math.max(cycle.FieldMissingAt, cycle.NoCarryAt) >= 1.5
        if not transferring and (lost or missing or now - cycle.NoCarryAt >= 4) then
            Hub.finishCarryCycle(cycle, false, field)
            return { IsCarrying = false, SpeedMultiplier = 1 }
        end
    end
    if field and field.State == "Carried" and field.CarrierUserId == LocalPlayer.UserId then
        cycle.HadCarry = true
    end
    cycle.Phase = arrived and "awaiting_claim" or "return"
    return {
        IsCarrying = true,
        Uid = cycle.Uid,
        AreaId = cycle.Record.AreaId,
        AssetCategory = cycle.Record.AssetCategory,
        SpeedMultiplier = cycle.SpeedMultiplier or (state and state.SpeedMultiplier) or 1,
        GuardDisabled = cycle.GuardDisabled,
        AwaitingConfirmation = true,
    }
end
function Hub.updateRecovery(records, carry, target)
    if not Config.AutoAttack or Config.AttackMode ~= "ไปตีผู้เล่นที่ถือไข่" then
        Hub.Pursuit, Hub.PursuitTarget, Hub.RecoveryEgg, Hub.RecoveryCarry = nil, nil, nil, nil
        return
    end
    if carry and carry.IsCarrying then
        if Hub.RecoveryCarry or (Hub.Pursuit and carry.Uid == Hub.Pursuit.Uid) then
            Hub.RecoveryCarry, Hub.RecoveryHadCarry = true, true
        end
        return
    end
    if Hub.RecoveryHadCarry then
        Hub.Pursuit, Hub.RecoveryEgg, Hub.RecoveryCarry, Hub.RecoveryHadCarry = nil, nil, nil, nil
    end
    if not Hub.Pursuit and target then
        for _, record in pairs(records) do
            if record.State == "Carried" and record.CarrierUserId == target.UserId then
                Hub.Pursuit = { Uid = record.Uid, Record = record, LastSeen = os.clock() }
                break
            end
        end
    end
    if not Hub.Pursuit and Hub.LastCarrierAttack then
        for _, record in pairs(records) do
            if Hub.LastCarrierAttack.Uids[record.Uid] and (record.State == "Dropped" or record.State == "Slot") then
                Hub.Pursuit = { Uid = record.Uid, Record = record, LastSeen = os.clock() }
                break
            end
        end
    end
    Hub.PursuitTarget, Hub.RecoveryEgg = nil, nil
    local pursuit = Hub.Pursuit
    if not pursuit then
        return
    end
    local current
    for _, record in pairs(records) do
        if record.Uid == pursuit.Uid then
            current = record
            break
        end
    end
    if current then
        pursuit.Record, pursuit.LastSeen = current, os.clock()
        if current.State == "Dropped" or current.State == "Slot" then
            Hub.RecoveryEgg = current
        elseif current.State == "Carried" then
            if current.CarrierUserId == LocalPlayer.UserId then
                Hub.confirmCarry("AutoAttack", current)
            else
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.UserId == current.CarrierUserId then
                        Hub.PursuitTarget = player
                        break
                    end
                end
            end
        end
    elseif os.clock() - pursuit.LastSeen > 30 then
        Hub.Pursuit = nil
        Hub.status("AutoAttack", "waiting", "ยังไม่พบไข่ UID เดิมในข้อมูลสนาม เลือกเป้าหมายใหม่เมื่อข้อมูลพร้อม")
    end
end
function Hub.treadmillHasTurn(now, bestEgg)
    if not Config.AutoTreadmill or now < (Hub.TreadmillRestUntil or 0) or now < (Hub.TreadmillRetryAt or 0) then
        return false
    end
    local root = getLocalRoot()
    if Hub.FieldResetting and root and Hub.inGameplay(root.Position) then
        return false
    end
    if not Config.AutoStealEgg then
        return true
    end
    if Hub.TreadmillTurnUntil then
        if now < Hub.TreadmillTurnUntil then
            return true
        end
        Hub.TreadmillTurnUntil, Hub.TreadmillAfterSteal = nil, nil
        Hub.TreadmillRetryAt, Hub.TreadmillDueAt = now + 15, now + 45
        return false
    end
    Hub.TreadmillDueAt = Hub.TreadmillDueAt or now + 45
    if bestEgg and not Hub.FieldResetting and not Hub.TreadmillAfterSteal and now < Hub.TreadmillDueAt then
        return false
    end
    local bottom = Hub.treadmillBottom()
    local walkTime = root and bottom and Hub.distance(root.Position, bottom.Position) / math.max(10, Hub.runSpeed()) or 0
    Hub.TreadmillTurnUntil = now + math.clamp(walkTime + 15, 15, 90)
    return true
end
function Hub.chooseOwner(carry, unplacedUid, bestEgg, target)
    if Hub.DeliveryStop then
        return Hub.DeliveryStop.Cycle.Owner
    end
    if RuntimeState.IsCurrentlyOnTreadmill and Config.AutoStealEgg then
        return Config.AutoTreadmill and "AutoTreadmill" or nil
    end
    local now = os.clock()
    if (RuntimeState.IsCurrentlyOnTreadmill and not Hub.TreadmillAuto) or now < (Hub.ManualBeltApproachUntil or 0) then
        return nil
    end
    if Hub.ExitTarget then
        return "_TreadmillExit"
    end
    if carry and carry.IsCarrying and Hub.CarryCycle and Config[Hub.CarryCycle.Owner] then
        return Hub.CarryCycle.Owner
    end
    if carry and carry.IsCarrying then
        if Config.AutoStealEgg then
            return "AutoStealEgg"
        end
        if Config.AutoAttack and Hub.RecoveryCarry then
            return "AutoAttack"
        end
    end
    if RuntimeState.IsCurrentlyOnTreadmill and Hub.TreadmillAuto and Config.AutoTreadmill then
        return "AutoTreadmill"
    end
    if Config.AutoStealEgg and (Hub.Jobs.AutoStealEgg or now < (Hub.StealPickupUntil or 0)) then
        return "AutoStealEgg"
    end
    local drop = Hub.CarryDropTarget
    if Config.AutoStealEgg and not Hub.FieldResetting and not Hub.Jobs.AutoPlaceEgg and drop and bestEgg and bestEgg.Uid == drop.Uid and bestEgg.State == "Dropped" and now < (drop.RecoverUntil or 0) then
        return "AutoStealEgg"
    end
    if Config.SwapFarmPriority then
        local orderMode = Config.FarmPriorityOrder
        if orderMode == "วางและฟักไข่ > ขโมยไข่ > ลู่วิ่ง" then
            if unplacedUid and Config.AutoPlaceEgg and now >= (Hub.PlaceBlockedUntil or 0) then
                return "AutoPlaceEgg"
            end
            if Config.AutoStealEgg and not Hub.FieldResetting and bestEgg then
                return "AutoStealEgg"
            end
            if Config.AutoTreadmill and now >= (Hub.TreadmillRestUntil or 0) and now >= (Hub.TreadmillRetryAt or 0) then
                return "AutoTreadmill"
            end
        elseif orderMode == "ลู่วิ่ง > ขโมยไข่ > วางไข่" then
            if Config.AutoTreadmill and now >= (Hub.TreadmillRestUntil or 0) and now >= (Hub.TreadmillRetryAt or 0) then
                return "AutoTreadmill"
            end
            if Config.AutoStealEgg and not Hub.FieldResetting and bestEgg then
                return "AutoStealEgg"
            end
            if unplacedUid and Config.AutoPlaceEgg and now >= (Hub.PlaceBlockedUntil or 0) then
                return "AutoPlaceEgg"
            end
        elseif orderMode == "ขโมยไข่ > วางไข่ > ลู่วิ่ง" then
            if Config.AutoStealEgg and not Hub.FieldResetting and bestEgg then
                return "AutoStealEgg"
            end
            if unplacedUid and Config.AutoPlaceEgg and now >= (Hub.PlaceBlockedUntil or 0) then
                return "AutoPlaceEgg"
            end
            if Config.AutoTreadmill and now >= (Hub.TreadmillRestUntil or 0) and now >= (Hub.TreadmillRetryAt or 0) then
                return "AutoTreadmill"
            end
        end
    end
    if unplacedUid and Config.AutoPlaceEgg and now >= (Hub.PlaceBlockedUntil or 0) then
        local placeDeferred = Config.PlaceEggRule == "วางเฉพาะหลังขโมยเสร็จ" and Config.AutoStealEgg and not Hub.FieldResetting and bestEgg ~= nil
        if not placeDeferred then
            return "AutoPlaceEgg"
        end
    end
    if Config.AutoAttack and (Hub.RecoveryEgg or Hub.Pursuit) and not Hub.isFallen() then
        return "AutoAttack"
    end
    if Config.AutoAttack and (Config.AttackMode == "ไปตีผู้เล่นที่ถือไข่" or (type(Config.AttackTargetPlayer) == "string" and Config.AttackTargetPlayer ~= "" and Config.AttackTargetPlayer ~= "ทุกคนตามโหมดการตี")) and target then
        return "AutoAttack"
    end
    if Hub.treadmillHasTurn(now, bestEgg) then
        return "AutoTreadmill"
    end
    if Config.AutoStealEgg and not Hub.FieldResetting and bestEgg then
        return "AutoStealEgg"
    end
    if unplacedUid and Config.AutoPlaceEgg and now >= (Hub.PlaceBlockedUntil or 0) then
        return "AutoPlaceEgg"
    end
    return nil
end
function Hub.deliveryStopAlive(delivery)
    local cycle, root, hum = delivery.Cycle, delivery.Root, delivery.Humanoid
    return Hub.DeliveryStop == delivery and Hub.CarryCycle == cycle and Hub.MovementOwner == cycle.Owner and Hub.usesDeliveryStop(cycle.Owner) and Hub.alive(cycle.Owner, delivery.Token) and not Hub.FieldResetting and LocalPlayer.Character == delivery.Character and getLocalRoot() == root and getLocalHumanoid() == hum and not root.Anchored and not hum.Sit and not RuntimeState.IsCurrentlyOnTreadmill and not Hub.isFallen() and not Hub.serverRagdolled() and not delivery.Character:GetAttribute("IsTrapped")
end
function Hub.stopDeliveryStop(delivery)
    delivery = delivery or Hub.DeliveryStop
    if not delivery or Hub.DeliveryStop ~= delivery then
        return
    end
    Hub.DeliveryStop, Hub.MovementSample = nil, nil
    Hub.StealCurrentStep = 0
    if delivery.RelocateConnection then
        delivery.RelocateConnection:Disconnect()
    end
    for _, connection in ipairs(delivery.Paused) do
        pcall(function()
            connection:Enable()
        end)
    end
    pcall(function()
        local root, hum = getLocalRoot(), getLocalHumanoid()
        if root == delivery.Root and hum == delivery.Humanoid and not Hub.isFallen() and not Hub.serverRagdolled() then
            hum:Move(Vector3.zero, false)
            root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
        end
    end)
end
function Hub.pauseDeliveryChecks(delivery)
    if type(getconnections) ~= "function" or type(debug.info) ~= "function" then
        return
    end
    for _, signal in ipairs({
        RunService.Heartbeat,
        RunService.PreSimulation,
        RunService.PostSimulation,
    }) do
        local ok, connections = pcall(getconnections, signal)
        if ok and type(connections) == "table" then
            for _, connection in ipairs(connections) do
                pcall(function()
                    local callback = connection.Function
                    if connection.Enabled == false or type(callback) ~= "function" then
                        return
                    end
                    local source, name = debug.info(callback, "sn")
                    if type(source) ~= "string" or not source:find("UGI", 1, true) or name == "MonitorAction" then
                        return
                    end
                    if type(debug.getconstants) == "function" then
                        local read, constants = pcall(debug.getconstants, callback)
                        if read and type(constants) == "table" and (table.find(constants, "SetWalkSpeed") or table.find(constants, "Relocate")) then
                            return
                        end
                    end
                    connection:Disable()
                    table.insert(delivery.Paused, connection)
                end)
            end
        end
    end
end
function Hub.holdsDeliveryEgg(cycle)
    local state = Hub.rawCarryState()
    return state and state.IsCarrying and state.Uid == cycle.Uid
end
function Hub.runDeliveryLeg(delivery, goal, radius, duration, carrying)
    local root, hum = delivery.Root, delivery.Humanoid
    local deadline = os.clock() + duration
    local params = Hub.navigationRayParams()
    local arrived = false
    while Hub.deliveryStopAlive(delivery) and os.clock() < deadline do
        if carrying and not Hub.holdsDeliveryEgg(delivery.Cycle) then
            break
        end
        local offset = Hub.flat(goal - root.Position)
        if offset.Magnitude <= radius then
            arrived = true
            break
        end
        local direction = offset.Unit
        local speed = math.min(Hub.runSpeed() * 1.1, offset.Magnitude / 0.05)
        if Hub.runWall(root.Position, direction * math.min(offset.Magnitude, math.max(6, speed * 0.12)), hum, params) then
            break
        end
        local velocity = direction * speed
        hum:Move(direction, false)
        root.AssemblyLinearVelocity = Vector3.new(velocity.X, root.AssemblyLinearVelocity.Y, velocity.Z)
        RunService.Heartbeat:Wait()
    end
    if Hub.deliveryStopAlive(delivery) then
        hum:Move(Vector3.zero, false)
        root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
    end
    return arrived or delivery.Cycle.Claimed == true
end
function Hub.deliveryEggModelPosition(uid, allowClientModel)
    local model = Workspace:FindFirstChild(uid)
    if not model and allowClientModel then
        local slots = Workspace:FindFirstChild("AreaEggSlotsClient")
        model = slots and slots:FindFirstChild(uid)
    end
    if not model or not model:IsA("Model") then
        return
    end
    local hitbox = model:FindFirstChild("Hitbox", true)
    if hitbox and hitbox:IsA("BasePart") then
        return hitbox.Position, model
    end
    return model:GetPivot().Position, model
end
function Hub.deliveryStopExchange(delivery, landing)
    local cycle, root, owner = delivery.Cycle, delivery.Root, delivery.Cycle.Owner
    local previous = Hub.carryFieldEvidence(cycle, true)
    local version = previous and tonumber(previous.Version) or cycle.FieldVersion or cycle.InitialVersion
    local beforePosition, beforeModel = Hub.deliveryEggModelPosition(cycle.Uid, false)
    local nestCFrame = cycle.InitialState == "Slot" and cycle.Record.BottomCFrame
    local relocates = delivery.Relocates
    local function request(name, payload)
        local reply = {}
        task.spawn(function()
            if Hub.deliveryStopAlive(delivery) then
                reply.Result = table.pack(pcall(Hub.rpc, owner, delivery.Token, "EggWorld", name, "function", payload))
            end
        end)
        return reply
    end
    local function replyResult(reply)
        local result = reply and reply.Result
        if result and not result[1] then
            error(result[2], 0)
        end
        if result then
            return result[2] == true
        end
        return nil
    end
    local function markRetry()
        Hub.DeliveryNoDropRetry = { Uid = cycle.Uid, Until = os.clock() + 90 }
    end
    delivery.Transferring = true
    local drop = request("AskFieldEggDrop", { Reason = "PlayerRequest" })
    local deadline = os.clock() + 3 + delivery.Ping * 4
    local released, take, attempts, nextTake = false, nil, 0, 0
    while Hub.deliveryStopAlive(delivery) and os.clock() < deadline do
        local accepted = replyResult(drop)
        local state = Hub.rawCarryState()
        local field = Hub.carryFieldEvidence(cycle, true)
        local fieldVersion = field and tonumber(field.Version)
        local updated = field and (version and fieldVersion and fieldVersion > version or not (version and fieldVersion) and (not previous or field.State ~= previous.State))
        if not released then
            released = state and not state.IsCarrying
            if not released and Hub.holdsDeliveryEgg(cycle) then
                if accepted == false then
                    return true
                end
                if delivery.Relocates == relocates and Hub.distance(root.Position, landing) <= 4 then
                    root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
                end
            end
        end
        if released then
            if Hub.holdsDeliveryEgg(cycle) then
                return true
            end
            local canGrab = updated and field.State == "Dropped"
            if updated then
                if field.State == "Slot" then
                    markRetry()
                    return false, "ไข่กลับรัง รอบถัดไปจะถือไข่ใบเดิมข้ามเส้น"
                end
                if field.State == "GuardCarried" or field.State == "Carried" and field.CarrierUserId ~= LocalPlayer.UserId then
                    markRetry()
                    return false, "มีผู้ถือไข่ UID เดิมแล้ว"
                end
                if field.State == "Claimed" then
                    return false, "รอเกมยืนยันการส่งไข่"
                end
            end
            local position, model = Hub.deliveryEggModelPosition(cycle.Uid, canGrab)
            local moved = position and (model ~= beforeModel or not beforePosition or (position - beforePosition).Magnitude > 1.5)
            local cf = canGrab and (field.BoundsCFrame or field.BottomCFrame)
            local liveNearDrop = moved and Hub.distance(position, landing) <= 16 and math.abs(position.Y - landing.Y) <= 12 and (not nestCFrame or Hub.distance(position, nestCFrame.Position) > 3)
            if not canGrab and not (liveNearDrop and (not field or field.State == "Carried")) then
                position = nil
            elseif cf and not (liveNearDrop or position and Hub.distance(position, cf.Position) <= 8) then
                position = cf.Position
            end
            local takeFinished = replyResult(take) ~= nil
            if position and attempts < 4 and os.clock() >= nextTake and (not take or takeFinished) then
                if Hub.distance(root.Position, position) > 6 then
                    if not Hub.runDeliveryLeg(delivery, position, 4, 0.45, false) then
                        nextTake = os.clock() + 0.1
                    end
                else
                    local area = field and field.AreaId or cycle.Record.AreaId
                    local nest = field and field.NestId or cycle.Record.NestId
                    local slotKey
                    if area and nest and AreaEggSlotIdentity and AreaEggSlotIdentity.LooksLikeFirstAreaUid(cycle.Uid) then
                        slotKey = AreaEggSlotIdentity.SlotKey(area, nest)
                    end
                    attempts = attempts + 1
                    nextTake = os.clock() + 0.38 + delivery.Ping * 2
                    take = request("AskFieldEggCarry", { Uid = cycle.Uid, FirstAreaSlotKey = slotKey })
                end
            end
        end
        RunService.Heartbeat:Wait()
    end
    if released and Hub.deliveryStopAlive(delivery) then
        markRetry()
    end
    return false, released and "เกมยังไม่ยืนยันการเก็บไข่ UID เดิมกลับ" or "รอเกมยืนยันตำแหน่งไข่ UID เดิม"
end
function Hub.positionDeliveryRoot(delivery, point)
    local root = delivery.Root
    root.CFrame = CFrame.new(point) * delivery.Rotation
    root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
end
function Hub.settleDeliveryStop(delivery, point, minimum, tolerance)
    local root, cycle = delivery.Root, delivery.Cycle
    local ok, fps = pcall(function()
        return Workspace:GetRealPhysicsFPS()
    end)
    local pingLag = math.clamp(delivery.Ping * 2 - 0.1, 0, 0.8)
    local syncDelay = math.clamp(minimum + delivery.Ping + 2 / math.max(ok and tonumber(fps) or 60, 10) + pingLag, minimum, 1.8)
    local startedAt = TimeUtil.clockNow()
    local stableSince = startedAt
    local frames = 0
    local corrections = delivery.Relocates
    if not Hub.deliveryStopAlive(delivery) or not Hub.holdsDeliveryEgg(cycle) then
        return false
    end
    Hub.positionDeliveryRoot(delivery, point)
    while TimeUtil.diffSeconds(TimeUtil.clockNow(), startedAt) < syncDelay + 0.8 do
        if not Hub.deliveryStopAlive(delivery) or not Hub.holdsDeliveryEgg(cycle) then
            return false
        end
        if delivery.Relocates ~= corrections or Hub.distance(root.Position, point) > tolerance or math.abs(root.Position.Y - point.Y) > 2.5 then
            corrections, stableSince, frames = delivery.Relocates, TimeUtil.clockNow(), 0
            Hub.positionDeliveryRoot(delivery, point)
        else
            frames = frames + 1
            if TimeUtil.diffSeconds(TimeUtil.clockNow(), stableSince) >= syncDelay and frames >= 3 then
                return true
            end
        end
        root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
        RunService.Heartbeat:Wait()
    end
    return false
end
function Hub.guardNearDeliveryDrop(point, ping)
    local areas = Hub.fieldAreas()
    local guardAreas = areas and areas:FindFirstChild("GuardAreas")
    if not guardAreas then
        return false
    end
    local areasDirectory = Hub.AreasData and Hub.AreasData.Directory
    local guardsDirectory = Hub.GuardsData and Hub.GuardsData.Directory
    for _, area in ipairs(guardAreas:GetChildren()) do
        local guard = area:FindFirstChild("Guard")
        local root = guard and guard:FindFirstChild("HumanoidRootPart")
        if root and root:IsA("BasePart") and guard:GetAttribute("Hidden") ~= true and math.abs(root.Position.Y - point.Y) <= 12 then
            local areaData = areasDirectory and areasDirectory[area.Name]
            local data = areaData and guardsDirectory and guardsDirectory[areaData.GuardId]
            local range = tonumber(data and (data.EggPickupDistance or data.HitDistance)) or 12
            local offset, velocity = Hub.flat(point - root.Position), Hub.flat(root.AssemblyLinearVelocity)
            local seconds = math.clamp(offset:Dot(velocity) / math.max(velocity:Dot(velocity), 1), 0, 0.15 + ping)
            if (offset - velocity * seconds).Magnitude <= range + 3 then
                return true
            end
        end
    end
    return false
end
function Hub.runDeliveryStop(delivery, line, goal)
    local cycle, root, hum = delivery.Cycle, delivery.Root, delivery.Humanoid
    local normal = delivery.Normal
    local edge = goal + normal * 7
    local firstDepth = normal:Dot(root.Position - edge)
    local lastDepth = math.min(firstDepth, 48)
    local depth, airY = firstDepth, root.Position.Y + 10
    local carryMult = math.clamp((tonumber(Config.StealCarrySpeedPercent) or 150) / 100, 0.5, 3)
    local stride = math.max(Hub.runSpeed() * carryMult, 40)
    local cadence = math.clamp(0.09 + delivery.Ping, 0.10, 0.20)
    local total = math.max(firstDepth - lastDepth, 1)
    local maxStops = math.clamp(math.floor((tonumber(Config.StealDeliverySteps) or 3) + 0.5), 1, 6)
    local intermediateStops = math.max(0, maxStops - 1)
    local stops, retries = 0, 0
    Hub.StealCurrentStep = 0
    local function groundAt(marker, rayY, rayLength)
        local origin = Vector3.new(marker.X, rayY, marker.Z)
        local hit = Workspace:Raycast(origin, Vector3.new(0, -rayLength, 0), Hub.navigationRayParams())
        if Hub.walkableHit(hit, hum) then
            return hit.Position + Vector3.new(0, 3.5, 0)
        end
        return nil
    end
    local function exchangeAt(landing, minimum, tolerance)
        if delivery.SkipDrops or normal:Dot(landing - edge) < 10 or Hub.guardNearDeliveryDrop(landing, delivery.Ping) or (Hub.FieldClosesAt and TimeUtil.diffSeconds(Hub.FieldClosesAt, Hub.fieldTime()) < 3) then
            return true
        end
        local settleTime = math.max(minimum, (delivery.NextDropAt or 0) - os.clock())
        if not Hub.settleDeliveryStop(delivery, landing, settleTime, tolerance) then
            return false, "ข้ามการวางไข่เพราะตำแหน่งยังไม่นิ่ง กำลังขนกลับต่อ"
        end
        local params = Hub.navigationRayParams()
        local ground = Workspace:Raycast(root.Position, Vector3.new(0, -7, 0), params)
        local ahead = Workspace:Raycast(root.Position - normal * 4, Vector3.new(0, -7, 0), params)
        if not Hub.walkableHit(ground, hum) or not Hub.walkableHit(ahead, hum) or math.abs(ground.Position.Y - ahead.Position.Y) > 2.5 or normal:Dot(root.Position - edge) < 10 or Hub.guardNearDeliveryDrop(root.Position, delivery.Ping) or (Hub.FieldClosesAt and TimeUtil.diffSeconds(Hub.FieldClosesAt, Hub.fieldTime()) < 3) then
            return true
        end
        local ok, reason = Hub.deliveryStopExchange(delivery, landing)
        delivery.Transferring = false
        delivery.NextDropAt = os.clock() + 0.4 + delivery.Ping
        return ok, reason
    end
    while depth - stride > lastDepth do
        local nextDepth = depth - stride
        local marker = edge + normal * nextDepth
        local point = Vector3.new(marker.X, airY, marker.Z)
        local stepStartedAt, corrections = TimeUtil.clockNow(), delivery.Relocates
        repeat
            if not Hub.deliveryStopAlive(delivery) or not Hub.holdsDeliveryEgg(cycle) then
                return false, "ไข่หลุดระหว่างขนกลับ"
            end
            Hub.positionDeliveryRoot(delivery, point)
            RunService.Heartbeat:Wait()
        until TimeUtil.diffSeconds(TimeUtil.clockNow(), stepStartedAt) >= cadence or delivery.Relocates ~= corrections
        if delivery.Relocates ~= corrections or normal:Dot(root.Position - point) > 10 then
            retries = retries + 1
            if retries > 6 then
                return false, "เกมดึงตำแหน่งกลับซ้ำระหว่างขนไข่"
            end
            Hub.status(cycle.Owner, "waiting", "เกมดึงตำแหน่งกลับ กำลังตั้งหลักเพื่อขนต่อ")
            task.wait(0.25)
            if not Hub.deliveryStopAlive(delivery) then
                return false, "หยุดการขนไข่"
            end
            depth = math.min(firstDepth, normal:Dot(root.Position - edge))
        else
            depth = nextDepth
            if stops < intermediateStops and (firstDepth - depth) / total >= (stops + 1) / maxStops then
                local landing = groundAt(marker, airY + 5, 400)
                stops = stops + 1
                Hub.StealCurrentStep = stops
                if landing then
                    Hub.status(cycle.Owner, "local", string.format("พักส่งไข่เป็นจังหวะ • จุดพัก %d/%d", stops, maxStops))
                    local ok, reason = exchangeAt(landing, 0.12, 4)
                    if not ok then
                        return false, reason
                    end
                    depth = normal:Dot(root.Position - edge)
                end
            end
        end
    end
    local actualDepth = normal:Dot(root.Position - edge)
    if actualDepth >= 10 then
        local marker = edge + normal * math.min(actualDepth, lastDepth)
        local landing = groundAt(marker, line.Position.Y + 63.35, 140)
        if landing then
            Hub.StealCurrentStep = maxStops
            Hub.status(cycle.Owner, "local", string.format("พักส่งไข่เป็นจังหวะ • จุดพักสุดท้าย (%d/%d)", maxStops, maxStops))
            local ok, reason = exchangeAt(landing, 0.15, 6)
            if not ok then
                return false, reason
            end
        end
    end
    Hub.StealCurrentStep = maxStops
    Hub.status(cycle.Owner, "local", "พักส่งไข่เป็นจังหวะ • วิ่งข้ามเส้นเขตปลอดภัย")
    Hub.runDeliveryLeg(delivery, goal, 2.5, 6, true)
    local deadline = os.clock() + 2
    while not cycle.Claimed and Hub.deliveryStopAlive(delivery) and os.clock() < deadline do
        RunService.Heartbeat:Wait()
    end
    return cycle.Claimed == true, "รอเกมยืนยันการส่งไข่ใบเดิม"
end
function Hub.startDeliveryStop(cycle, token, root, line, point)
    if cycle.DeliveryAttempted or not Hub.usesDeliveryStop(cycle.Owner) or not Hub.holdsDeliveryEgg(cycle) or Hub.FieldResetting or not Hub.inGameplay(root.Position) or RuntimeState.IsCurrentlyOnTreadmill or Hub.ExitTarget then
        return false
    end
    Hub.ragdollStep()
    if not Hub.RagdollSwap then
        return false
    end
    local hum = getLocalHumanoid()
    local normal = Hub.flat(line.CFrame.LookVector)
    if not hum or hum.WalkSpeed <= 0 or normal.Magnitude < 0.01 then
        return false
    end
    local ok, ping = pcall(function()
        return LocalPlayer:GetNetworkPing()
    end)
    local retry = Hub.DeliveryNoDropRetry
    local delivery = {
        Cycle = cycle,
        Root = root,
        Humanoid = hum,
        Character = LocalPlayer.Character,
        Normal = normal.Unit,
        Rotation = CFrame.lookAt(Vector3.zero, normal.Unit * -1).Rotation,
        Token = token,
        Relocates = 0,
        Paused = {},
        Ping = math.clamp(ok and tonumber(ping) or 0.1, 0, 0.25),
        SkipDrops = (Config.DeliveryMethod == "เทเลพอร์ต") or (retry and retry.Uid == cycle.Uid and os.clock() < retry.Until),
    }
    Hub.DeliveryStop = delivery
    if not Hub.deliveryStopAlive(delivery) then
        Hub.DeliveryStop = nil
        return false
    end
    if delivery.SkipDrops then
        Hub.DeliveryNoDropRetry = nil
    end
    cycle.DeliveryAttempted = true
    Hub.stopForInteraction()
    Hub.stopWalking()
    task.spawn(function()
        if not Hub.deliveryStopAlive(delivery) then
            Hub.stopDeliveryStop(delivery)
            return
        end
        local ran, delivered, reason = pcall(function()
            local refresh = Hub.remote("RigSync", "Refresh", "event")
            if refresh and refresh.OnClientEvent then
                delivery.RelocateConnection = refresh.OnClientEvent:Connect(function(payload)
                    if type(payload) == "string" then
                        local ok, decoded = pcall(HttpService.JSONDecode, HttpService, payload)
                        if ok then
                            payload = decoded
                        end
                    end
                    if Hub.DeliveryStop == delivery and type(payload) == "table" and payload.Action == "Relocate" then
                        delivery.Relocates = delivery.Relocates + 1
                    end
                end)
            end
            Hub.pauseDeliveryChecks(delivery)
            return Hub.runDeliveryStop(delivery, line, point)
        end)
        local active = Hub.DeliveryStop == delivery
        Hub.stopDeliveryStop(delivery)
        if active and not ran then
            Hub.fail(cycle.Owner, delivered)
        end
        if active and ran and not delivered and not cycle.Claimed then
            Hub.status(cycle.Owner, "waiting", "พักส่งไข่เป็นจังหวะ • " .. reason)
        end
    end)
    return true
end
function Hub.returnEgg(owner, token, root)
    if Hub.FieldResetting then
        Hub.stopForInteraction()
        return
    end
    local areas = Hub.fieldAreas()
    local line = areas and areas:FindFirstChild("SeparationLine")
    if not line then
        Hub.status(owner, "waiting", "รอเส้นแบ่งเขตปลอดภัยโหลด")
        return
    end
    local right, look = line.CFrame.RightVector, line.CFrame.LookVector
    local span = line.Size.X * 0.45
    local lateral = math.clamp(right:Dot(root.Position - line.Position), -span, span)
    if Hub.usesDeliveryStop(owner) and look.X > 0.95 and math.abs(right.Z) > 0.95 then
        local lane = (math.clamp(root.Position.Z, -425, -300) - line.Position.Z) / right.Z
        if math.abs(lane) <= span then
            lateral = lane
        end
    end
    local cycle = Hub.CarryCycle
    local point = cycle and cycle.ReturnGoal or Hub.ReturnGoal or (line.Position + right * lateral - look * 7)
    Hub.ReturnGoal = point
    if cycle then
        cycle.ReturnGoal = point
    end
    if Hub.DeliveryStop or cycle and Hub.startDeliveryStop(cycle, token, root, line, point) then
        return
    end
    if cycle and cycle.NoCarryAt then
        Hub.stopForInteraction()
        Hub.status(owner, "waiting", "รอเกมยืนยันว่าไข่ใบเดิมถูกส่งหรือหลุดจากมือ")
        return
    end
    if cycle and not cycle.DeliveryAttempted and Hub.usesDeliveryStop(owner) and not Hub.RagdollSwap then
        Hub.status(owner, "waiting", "พักส่งไข่เป็นจังหวะ • รอกันล้มพร้อม")
        return
    end
    Hub.status(owner, "waiting", Hub.CarryCycle and Hub.CarryCycle.Phase == "awaiting_claim" and "ถึงเขตปลอดภัย รอเกมยืนยันไข่ใบเดิม" or "กำลังนำไข่ใบเดิมกลับเขตปลอดภัย")
    Hub.move(owner, token, Vector3.new(point.X, root.Position.Y, point.Z), 2)
end
function Hub.pickupEgg(owner, egg, root, hum)
    if Hub.FieldResetting or Hub.isFallen() or not egg then
        return
    end
    local position = (egg.BoundsCFrame or egg.BottomCFrame).Position
    local distance = (root.Position - position).Magnitude
    local approach = Vector3.new(position.X, (egg.BottomCFrame or egg.BoundsCFrame).Position.Y, position.Z)
    local reach = Hub.ClosePickupUid == egg.Uid and 5.5 or 7.5
    if distance > reach then
        if Hub.distance(root.Position, position) < 3 and position.Y - root.Position.Y > 4 then
            hum.Jump = true
        end
        local height = position.Y - root.Position.Y
        local radius = math.max(1.2, math.sqrt(math.max(0, reach * reach - height * height)) - 0.5)
        Hub.move(owner, Hub.Generation[owner] or 0, approach, radius)
        return
    end
    Hub.stopForInteraction()
    if not Hub.stepOff() then
        return
    end
    if Hub.usesDeliveryStop(owner) then
        Hub.ragdollStep()
        if not Hub.RagdollSwap then
            Hub.status(owner, "waiting", "พักส่งไข่เป็นจังหวะ • รอกันล้มพร้อม")
            return
        end
        hum = getLocalHumanoid()
    end
    Hub.job(owner, 0.85, true, function(token)
        if not Hub.alive(owner, token) or Hub.FieldResetting or Hub.isFallen() or hum ~= getLocalHumanoid() or (Hub.usesDeliveryStop(owner) and not Hub.RagdollSwap) then
            return
        end
        hum:UnequipTools()
        RuntimeState.LastStealPickupAttemptAt = os.clock()
        if Config.AntiGuard then
            Hub.GuardAction = { Armed = true, Owner = owner, Token = token, Until = os.clock() + 4 }
        end
        local slotKey
        if AreaEggSlotIdentity and AreaEggSlotIdentity.LooksLikeFirstAreaUid(egg.Uid) then
            slotKey = AreaEggSlotIdentity.SlotKey(egg.AreaId, egg.NestId)
        end
        local revision = Hub.CarryEventRevision or 0
        local accepted = Hub.rpc(owner, token, "EggWorld", "AskFieldEggCarry", "function", { Uid = egg.Uid, FirstAreaSlotKey = slotKey })
        if not accepted then
            Hub.GuardAction = nil
            Hub.ClosePickupUid = egg.Uid
            return
        end
        local carry = Hub.rawCarryState()
        if Hub.usesDeliveryStop(owner) and not (carry and carry.IsCarrying and carry.Uid == egg.Uid) then
            Hub.StealPickupUntil = os.clock() + 1.5
            Hub.status(owner, "waiting", "รอเกมยืนยันว่าเราถือไข่ UID เดิม")
            return
        end
        if (Hub.CarryEventRevision or 0) == revision or not carry or (carry.IsCarrying and (not carry.Uid or carry.Uid == egg.Uid)) then
            Hub.confirmCarry(owner, egg, carry and carry.IsCarrying and carry or nil)
        end
    end)
end
function Hub.walkStealEntry(route, token, goal, radius, root, hum)
    local key = "AutoStealEgg"
    if route.Goal ~= goal then
        route.Goal, route.Waypoints, route.PendingPath, route.NextPathAt = goal, nil, nil, nil
    end
    if route.Waypoints then
        local waypoint = route.Waypoints[route.Index]
        while waypoint and Hub.distance(root.Position, waypoint.Position) <= 3 do
            route.Index = route.Index + 1
            waypoint = route.Waypoints[route.Index]
        end
        if waypoint then
            Hub.move(key, token, waypoint.Position, 2.5)
            return
        end
        route.Waypoints = nil
    end
    local now = os.clock()
    if route.PendingPath and now - route.PendingPath.At < 3 then
        return
    end
    local offset = Hub.flat(goal - root.Position)
    if not route.PendingPath and now >= (route.NextPathAt or 0) and Hub.runWall(root.Position, offset, hum, Hub.navigationRayParams()) then
        local from, request = root.Position, { At = now }
        route.PendingPath, route.NextPathAt = request, now + 4
        Hub.stopForInteraction()
        task.spawn(function()
            local path
            local ok, waypoints = pcall(function()
                path = game:GetService("PathfindingService"):CreatePath({ AgentCanJump = false })
                path:ComputeAsync(from, goal)
                if path.Status == Enum.PathStatus.Success then
                    return path:GetWaypoints()
                end
                return nil
            end)
            if path then
                path:Destroy()
            end
            if route.PendingPath ~= request then
                return
            end
            route.PendingPath = nil
            if ok and waypoints and #waypoints > 0 and Hub.StealEntry == route and Hub.alive(key, token) and Hub.MovementOwner == key and not Hub.FieldResetting then
                route.Waypoints, route.Index = waypoints, 1
            end
        end)
        return
    end
    Hub.move(key, token, goal, radius)
end
function Hub.steerStealEntry(egg, root, hum, token)
    local key = "AutoStealEgg"
    local areas = Hub.fieldAreas()
    local line = areas and areas:FindFirstChild("SeparationLine")
    if not line then
        Hub.stopForInteraction()
        Hub.status(key, "waiting", "รอทางเข้ากลางสนามโหลด")
        return true
    end
    local target = (egg.BottomCFrame or egg.BoundsCFrame).Position
    local normal = Hub.flat(line.CFrame.LookVector).Unit
    if normal:Dot(target - line.Position) <= 0 then
        Hub.StealEntry, Hub.PenExit = nil, nil
        return false
    end
    local route = Hub.StealEntry
    if not route then
        if normal:Dot(root.Position - line.Position) > 0 then
            Hub.PenExit = nil
            return false
        end
        route = { Staging = line.Position - normal * 14, Entry = line.Position + normal * 9 }
        Hub.StealEntry = route
    end
    local exit = Hub.PenExit
    if exit then
        if Hub.distance(root.Position, exit.Anchor) <= 30 and Hub.distance(root.Position, exit.Position) > 4 then
            Hub.walkStealEntry(route, token, exit.Position, 4, root, hum)
            return true
        end
        Hub.PenExit = nil
    end
    if not route.Staged and Hub.distance(root.Position, route.Staging) <= 4 then
        route.Staged = true
    end
    if route.Staged and Hub.distance(root.Position, route.Entry) <= 3 then
        Hub.StealEntry = nil
        return false
    end
    Hub.status(key, "local", "กำลังวิ่งเข้าทางกลางสนาม")
    Hub.walkStealEntry(route, token, route.Staged and route.Entry or route.Staging, route.Staged and 3 or 4, root, hum)
    return true
end
function Hub.moveStep(save, carry, uid, bestEgg, target)
    local owner = Hub.chooseOwner(carry, uid, bestEgg, target)
    Hub.acquire(owner)
    local names = {
        AutoStealEgg = "เก็บและขนไข่",
        AutoPlaceEgg = "วางไข่",
        AutoAttack = "ติดตามไข่จากการต่อสู้",
        AutoTreadmill = "วิ่งบนลู่",
        _TreadmillExit = "เดินออกจากฐานลู่วิ่ง",
    }
    RuntimeState.CurrentTaskStatusText = owner and ("กำลังทำงาน: " .. (names[owner] or owner)) or "รอเป้าหมายหรือข้อมูลเกม"
    if not owner then
        return
    end
    local token, root, hum = Hub.Generation[owner] or 0, getLocalRoot(), getLocalHumanoid()
    if not root or not hum or hum.Health <= 0 then
        return
    end
    if Hub.DeliveryStop then
        return
    end
    if owner == "_TreadmillExit" then
        if Hub.distance(root.Position, Hub.ExitTarget) <= 2 then
            Hub.ExitTarget = nil
            Hub.acquire(nil)
        else
            Hub.move(owner, token, Hub.ExitTarget, 2)
        end
        return
    end
    if owner == "AutoTreadmill" and RuntimeState.IsCurrentlyOnTreadmill then
        if not Hub.RequestedTreadmillExit then
            Hub.status(owner, "confirmed", "กำลังวิ่งบนลู่ • ลงเมื่อครบ ".. tostring(Config.TreadmillRunSeconds).. " วินาที")
        end
        return
    end
    if owner == "AutoStealEgg" and Hub.FieldResetting then
        Hub.stopForInteraction()
        Hub.status(owner, "waiting", "รอไข่รอบใหม่และกำแพงเปิด")
        return
    end
    if not carry then
        Hub.status(owner, "waiting", "รอข้อมูลการถือไข่")
        return
    end
    if Hub.isFallen() then
        Hub.status(owner, "waiting", "รอตัวละครลุกก่อนเคลื่อนที่และเก็บไข่")
        Hub.stopForInteraction()
        return
    end
    if carry.IsCarrying then
        if owner == "AutoStealEgg" or (owner == "AutoAttack" and Hub.RecoveryCarry) then
            Hub.returnEgg(owner, token, root)
        else
            Hub.status(owner, "waiting", "พักงานระหว่างถือไข่")
        end
        return
    end
    if owner == "AutoStealEgg" then
        if os.clock() < (Hub.StealPickupUntil or 0) or Hub.Jobs.AutoStealEgg then
            return
        end
        if bestEgg and not Hub.steerStealEntry(bestEgg, root, hum, token) then
            Hub.pickupEgg(owner, bestEgg, root, hum)
        end
    elseif owner == "AutoPlaceEgg" then
        if Hub.Jobs.AutoPlaceEgg then
            return
        end
        local plot = findLocalPlotFallback()
        if not plot then
            Hub.status(owner, "waiting", "รอคอกของเราโหลด")
            return
        end
        if not Hub.stepOff() then
            return
        end
        Hub.job(owner, 1.2, true, function(jobToken)
            Hub.placeEggBatch(plot, jobToken)
        end)
    elseif owner == "AutoAttack" then
        if Hub.RecoveryEgg then
            Hub.pickupEgg(owner, Hub.RecoveryEgg, root, hum)
        elseif target and target.Character then
            local otherRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if otherRoot then
                if Hub.distance(root.Position, otherRoot.Position) > 9 then
                    Hub.move(owner, token, otherRoot.Position, 7)
                else
                    Hub.stopForInteraction()
                end
            end
        elseif Hub.Pursuit and Hub.Pursuit.Record then
            local record = Hub.Pursuit.Record
            local cf = record.BoundsCFrame or record.BottomCFrame
            if cf and Hub.distance(root.Position, cf.Position) > 8 then
                Hub.move(owner, token, cf.Position, 6)
            else
                Hub.stopForInteraction()
                Hub.status(owner, "waiting", "รอตำแหน่งล่าสุดของไข่ UID เดิมจากเกม")
            end
        end
    elseif owner == "AutoTreadmill" then
        if Hub.DoffBusy then
            return
        end
        local plot = findLocalPlotFallback()
        local bottom = plot and plot.PlotFolder:FindFirstChild("TreadmillBottom", true)
        if not bottom then
            Hub.status(owner, "waiting", "รอลู่วิ่งของเราโหลด")
            return
        end
        if Hub.distance(root.Position, bottom.Position) > 2.5 then
            Hub.move(owner, token, bottom.Position, 2)
            return
        end
        Hub.stopForInteraction()
        Hub.job(owner, 1.5, false, function(jobToken)
            if Hub.InFlight["Treadmill.AskWearStill"] or not Hub.alive(owner, jobToken) or os.clock() < (Hub.ManualBeltApproachUntil or 0) or RuntimeState.IsCurrentlyOnTreadmill then
                return
            end
            Hub.restoreFallStates()
            local entry = { Token = jobToken, Version = Hub.TreadmillSessionVersion or 0 }
            Hub.TreadmillAutoRequest = entry
            Hub.rpc(owner, jobToken, "Treadmill", "AskWearStill", "function")
            if not Hub.InFlight["Treadmill.AskWearStill"] and Hub.TreadmillAutoRequest == entry then
                Hub.TreadmillAutoRequest = nil
            end
        end)
    end
end
function Hub.beginSpend(key, amount)
    local save = getPlayerSaveData()
    if not save or type(save.Money) ~= "number" or save.Money < amount then
        Hub.status(key, "waiting", "รอเงินให้เพียงพอก่อนทำรายการ")
        return false
    end
    local pending = Hub.PendingSpend
    if os.clock() < (Hub.NextSpendAt or 0) or (pending and save.Money == pending.Before and os.clock() - pending.At < 6) then
        Hub.status(key, "waiting", "รอข้อมูลเงินจากรายการก่อนหน้า")
        return false
    end
    Hub.NextSpendAt = os.clock() + 2
    Hub.PendingSpend = amount > 0 and { Before = save.Money, At = os.clock() } or nil
    return true
end
function Hub.trailStep(save)
    if not Config.AutoBuyTrail or not save then
        return
    end
    local directory = Hub.TrailsData and Hub.TrailsData.Directory
    if not directory then
        Hub.status("AutoBuyTrail", "waiting", "รอรายการเทรลจากเกม")
        return
    end
    local pending = Hub.PendingTrailPurchase
    if pending and not (save.TrailInventory or {})[pending.Id] and os.clock() - pending.At < 15 then
        Hub.status("AutoBuyTrail", "waiting", "ซื้อแล้ว รอเกมยืนยันเทรลก่อนทำรายการต่อ")
        return
    end
    if pending and (save.TrailInventory or {})[pending.Id] then
        Hub.PendingTrailPurchase = nil
    end
    Hub.job("AutoBuyTrail", 3, true, function(token)
        local current = getPlayerSaveData()
        if not current then
            return
        end
        local owned, entries, best = current.TrailInventory or {}, {}, nil
        for id, data in pairs(directory) do
            if owned[id] == true and (not best or data.SpeedMultiplier > best.Data.SpeedMultiplier) then
                best = { Id = id, Data = data }
            end
            if data.DisplayInShop ~= false and type(data.Price) == "number" and data.Price >= 0 and type(data.SpeedMultiplier) == "number" then
                entries[#entries + 1] = { Id = id, Data = data }
            end
        end
        table.sort(entries, function(a, b)
            if a.Data.Price == b.Data.Price then
                return a.Id < b.Id
            end
            return a.Data.Price < b.Data.Price
        end)
        if best and current.EquippedTrail ~= best.Id then
            Hub.rpc("AutoBuyTrail", token, "Trailwear", "AskChoose", "function", best.Id)
            return
        end
        local nextTrail
        for _, entry in ipairs(entries) do
            if not owned[entry.Id] and (not best or entry.Data.SpeedMultiplier > best.Data.SpeedMultiplier) then
                nextTrail = entry
                break
            end
        end
        if nextTrail then
            if current.Money < nextTrail.Data.Price then
                Hub.status("AutoBuyTrail", "waiting", "รอเงิน ".. tostring(nextTrail.Data.Price).. " เพื่อซื้อ ".. nextTrail.Id)
                return
            end
            if not Hub.beginSpend("AutoBuyTrail", nextTrail.Data.Price) then
                return
            end
            local accepted = Hub.rpc("AutoBuyTrail", token, "Trailwear", "AskPurchase", "function", nextTrail.Id)
            if not accepted then
                return
            end
            Hub.PendingTrailPurchase = { Id = nextTrail.Id, At = os.clock() }
            local deadline = os.clock() + 4
            repeat
                current = getPlayerSaveData()
                if current and (current.TrailInventory or {})[nextTrail.Id] == true then
                    break
                end
                task.wait(0.1)
            until not Hub.alive("AutoBuyTrail", token) or os.clock() >= deadline
            if not Hub.alive("AutoBuyTrail", token) then
                return
            end
            if not current or not (current.TrailInventory or {})[nextTrail.Id] then
                Hub.status("AutoBuyTrail", "waiting", "ซื้อแล้ว รอเกมอัปเดตเทรลที่เป็นเจ้าของ")
                return
            end
            Hub.PendingTrailPurchase = nil
            best = nextTrail
        end
        if best and current.EquippedTrail ~= best.Id then
            Hub.rpc("AutoBuyTrail", token, "Trailwear", "AskChoose", "function", best.Id)
        elseif not nextTrail then
            Hub.status("AutoBuyTrail", "idle", "มีเทรลสูงสุดที่ซื้อด้วยเงินในเกมแล้ว")
        end
    end)
end
function Hub.planFusion(save, previewOnly)
    if not previewOnly then
        Hub.FusionReserved = {}
    end
    if (not Config.AutoFusion and not previewOnly) or not save or not Hub.FuseKernel or not Hub.GameplayBalance then
        Hub.FusionPlan = nil
        return nil
    end
    local needed = Hub.GameplayBalance.Fusion and Hub.GameplayBalance.Fusion.INPUT_COUNT
    if type(needed) ~= "number" or needed < 1 then
        return nil
    end
    local slots, fixed, selected, category, temporary = save.FusionSlots or {}, {}, {}, nil, nil
    for _, uid in ipairs(slots) do
        local pet = (save.Inventory or {})[uid]
        if not pet then
            Hub.FusionPlan = nil
            return nil
        end
        if category and (pet.Category ~= category or (pet.CreatorTemporary == true) ~= temporary) then
            Hub.FusionPlan = nil
            return nil
        end
        category, temporary = pet.Category, pet.CreatorTemporary == true
        local ok, eligible = pcall(Hub.FuseKernel.MayEnterFuse, uid, pet, category, true, temporary)
        if not ok or not eligible then
            Hub.FusionPlan = nil
            return nil
        end
        fixed[uid] = true
        selected[#selected + 1] = uid
        Hub.FusionReserved[uid] = true
    end
    local reserved = {}
    for _, field in ipairs({ "EquippedAssets", "VIPFusionSlots", "PrivateFusionSlots" }) do
        for _, uid in pairs(save[field] or {}) do
            reserved[uid] = true
        end
    end
    local groups = {}
    for uid, pet in pairs(save.Inventory or {}) do
        if not fixed[uid] and not reserved[uid] and not pet.IsFavorite and not pet.InFuse and not pet.SpecialLuckyBlockColumn and not pet.PendingEggName then
            local ok, eligible = pcall(Hub.FuseKernel.MayEnterFuse, uid, pet, category, false, temporary)
            if ok and eligible then
                local key = pet.Category .. ":" .. tostring(pet.CreatorTemporary == true)
                groups[key] = groups[key] or {}
                groups[key][#groups[key] + 1] = uid
            end
        end
    end
    local options = {}
    if #selected == needed then
        options[1] = selected
    end
    for _, group in pairs(groups) do
        table.sort(group)
        if #group + #selected >= needed then
            local candidate = table.clone(selected)
            for i = 1, needed - #candidate do
                candidate[#candidate + 1] = group[i]
            end
            options[#options + 1] = candidate
        end
    end
    local best, cost
    for _, ids in ipairs(options) do
        local pets = {}
        for _, uid in ipairs(ids) do
            pets[#pets + 1] = save.Inventory[uid]
        end
        local ok, price = pcall(Hub.FuseKernel.PriceFor, pets)
        if ok and type(price) == "number" and math.abs(price) < math.huge and (not cost or price < cost or price == cost and table.concat(ids, "|") < table.concat(best, "|")) then
            best, cost = ids, price
        end
    end
    if not best then
        Hub.FusionPlan = nil
        return nil
    end
    local resultPlan = { Uids = best, Price = cost, Count = needed }
    if not previewOnly then
        Hub.FusionReserved = Hub.FusionReserved or {}
        for _, uid in ipairs(best) do
            Hub.FusionReserved[uid] = true
        end
        Hub.FusionPlan = resultPlan
    end
    return resultPlan
end
function Hub.fusionStep(save)
    if not Config.AutoFusion or not save then
        return
    end
    local finishing = Hub.FusionAwaitingFinish
    if finishing then
        local granted = (save.EggInventory or {})[finishing.Uid]
        if type(save.FusionEggReward) ~= "table" and granted then
            Hub.FusionAwaitingFinish = nil
            Hub.LastFusionCompletedAt = os.clock()
            Hub.status("AutoFusion", "confirmed", "เกมยืนยันฟิวส์ชั่นและรับไข่แล้ว")
        elseif os.clock() - finishing.At < 15 then
            Hub.status("AutoFusion", "waiting", "รับผลฟิวส์แล้ว รอข้อมูลไข่จากเกม")
            return
        else
            Hub.FusionAwaitingFinish = nil
        end
    end
    local plan = Hub.planFusion(save)
    if not Hub.FuseKernel or not Hub.GameplayBalance then
        Hub.status("AutoFusion", "waiting", "รอกติกาและราคาฟิวส์ชั่นจากเกม")
        return
    end
    if save.FusionLocked and type(save.FusionEggReward) ~= "table" then
        Hub.status("AutoFusion", "waiting", "รอฟิวส์ชั่นรอบก่อนของเกม")
        return
    end
    if not plan and type(save.FusionEggReward) ~= "table" then
        if os.clock() - (Hub.LastFusionCompletedAt or -math.huge) < 3 then
            Hub.status("AutoFusion", "confirmed", "ฟิวส์ชั่นและรับไข่แล้ว รอตัวสำหรับรอบถัดไป")
        else
            Hub.status("AutoFusion", "waiting", "รอตัวชนิดเดียวกันที่ไม่ได้ใส่ครบตามกติกา")
        end
        return
    end
    if plan and (save.Money or 0) < plan.Price and type(save.FusionEggReward) ~= "table" then
        Hub.status("AutoFusion", "waiting", "รอเงินฟิวส์ชั่น " .. tostring(plan.Price))
        return
    end
    Hub.job("AutoFusion", 3, true, function(token)
        local function awaitState(predicate)
            local deadline = os.clock() + 4
            repeat
                if not Hub.alive("AutoFusion", token) then
                    return nil
                end
                local current = getPlayerSaveData()
                if current and predicate(current) then
                    return current
                end
                task.wait(0.1)
            until os.clock() >= deadline
            Hub.status("AutoFusion", "waiting", "รอเกมยืนยันสถานะฟิวส์ชั่น")
            return nil
        end
        local current = getPlayerSaveData()
        if not current then
            return
        end
        if type(current.FusionEggReward) ~= "table" then
            local limit = Hub.EggLimits and Hub.EggLimits.MAX_INVENTORY
            local count = 0
            for _ in pairs(current.EggInventory or {}) do
                count = count + 1
            end
            if not limit or count >= limit then
                Hub.status("AutoFusion", "waiting", "รอช่องว่างกระเป๋าไข่ก่อนฟิวส์ชั่น")
                return
            end
            if not Hub.rpc("AutoFusion", token, "Fusery", "ConfirmBriefing", "function") then
                return
            end
            for _, uid in ipairs(plan.Uids) do
                current = getPlayerSaveData()
                if not current then
                    return
                end
                if not table.find(current.FusionSlots or {}, uid) then
                    local gap = 0.36 - (os.clock() - (Hub.LastRequest["Fusery.LoadPet"] or -math.huge))
                    if gap > 0 then
                        task.wait(gap)
                    end
                    if not Hub.alive("AutoFusion", token) then
                        return
                    end
                    if not Hub.rpc("AutoFusion", token, "Fusery", "LoadPet", "function", uid, false) then
                        return
                    end
                    current = awaitState(function(data)
                        return table.find(data.FusionSlots or {}, uid) ~= nil
                    end)
                    if not current then
                        return
                    end
                end
            end
            if not Hub.beginSpend("AutoFusion", plan.Price) then
                return
            end
            if not Hub.rpc("AutoFusion", token, "Fusery", "BeginFuse", "function") then
                return
            end
            current = awaitState(function(data)
                return type(data.FusionEggReward) == "table"
            end)
            if not current then
                return
            end
        end
        local reward = current.FusionEggReward
        if not Hub.alive("AutoFusion", token) then
            return
        end
        if not Hub.rpc("AutoFusion", token, "Fusery", "FinishReveal", "function") then
            return
        end
        Hub.FusionAwaitingFinish = { Uid = reward.Uid, At = os.clock() }
        current = awaitState(function(data)
            return type(data.FusionEggReward) ~= "table" and (not reward.Uid or (data.EggInventory or {})[reward.Uid] ~= nil)
        end)
        if current then
            Hub.FusionAwaitingFinish, Hub.FusionPlan, Hub.FusionReserved = nil, {}, {}
            Hub.LastFusionCompletedAt = os.clock()
            Hub.status("AutoFusion", "confirmed", "เกมยืนยันฟิวส์ชั่นและรับไข่แล้ว")
        end
    end)
end
function Hub.wispState()
    local save = getPlayerSaveData()
    local wisp = save and save.WispCompanion
    return save, type(wisp) == "table" and wisp or nil
end
function Hub.currentWispQuest(wisp)
    if not wisp then
        return nil
    end
    if wisp.Accepted then
        if wisp.Unlocked then
            return nil
        end
    else
        return nil
    end
    local wispData = Hub.WispQuestsData
    local list = type(wispData) == "table" and wispData.List or nil
    if type(list) ~= "table" then
        return nil
    end
    return list[tonumber(wisp.Stage) or 1]
end
function Hub.wispQuestProgress(wisp, quest)
    if type(wisp) ~= "table" or type(quest) ~= "table" then
        return 0
    end
    return type(wisp.Progress) == "table" and tonumber(wisp.Progress[quest.Id]) or 0
end
function Hub.wispQuestClaimed(wisp, quest)
    if type(wisp) ~= "table" or type(quest) ~= "table" then
        return false
    end
    return type(wisp.Claimed) == "table" and wisp.Claimed[quest.Id] == true
end
function Hub.wispStep(token)
    if not Config.AutoWispQuest then
        return
    end
    local save, wisp = Hub.wispState()
    local wispData = Hub.WispQuestsData
    local wispProg = Hub.WispProgression
    if not save or not wisp then
        if Hub.WispStatusLabel then
            Hub.WispStatusLabel.Text = "สถานะภูตวิญญาณ: กำลังรอซิงค์ข้อมูลเซฟผู้เล่น..."
        end
        return
    end
    if wisp.Unlocked then
        if Hub.WispStatusLabel then
            Hub.WispStatusLabel.Text = "สถานะภูตวิญญาณ: ปลดล็อกทางเข้าต้นไม้มนตราสำเร็จแล้ว"
        end
        Hub.status("AutoWispQuest", "confirmed", "ปลดล็อกต้นไม้มนตราแล้ว")
        return
    end
    if not wisp.Accepted then
        local reqPower = type(wispData) == "table" and tonumber(wispData.RequiredSpeedPower) or 0
        local myPower = tonumber(save.SpeedPower) or 0
        if reqPower > 0 and myPower < reqPower then
            if Hub.WispStatusLabel then
                Hub.WispStatusLabel.Text = "สถานะภูตวิญญาณ: ต้องมีพลังความเร็วอย่างน้อย " .. formatCompactThaiNumber(reqPower)
            end
            Hub.status("AutoWispQuest", "waiting", "รอพลังความเร็วครบตามเกณฑ์เควสภูต")
            return
        end
        if Hub.WispStatusLabel then
            Hub.WispStatusLabel.Text = "สถานะภูตวิญญาณ: กำลังส่งคำขอรับเควสภูตวิญญาณ..."
        end
        Hub.rpc("AutoWispQuest", token, "WispCompanion", "Request", "function", "Accept")
        return
    end
    local isReadyToReturn = false
    if type(wispProg) == "table" and type(wispProg.IsReady) == "function" then
        local okR, readyVal = pcall(wispProg.IsReady, wisp)
        if okR and readyVal == true then
            isReadyToReturn = true
        end
    elseif type(wispData) == "table" then
        local dynamicStageCount = tonumber(wispData.StageCount) or (type(wispData.List) == "table" and (#wispData.List + 1)) or nil
        if dynamicStageCount and (tonumber(wisp.Stage) or 1) >= dynamicStageCount and not wisp.Unlocked then
            isReadyToReturn = true
        end
    end
    if isReadyToReturn then
        if Hub.WispStatusLabel then
            Hub.WispStatusLabel.Text = "สถานะภูตวิญญาณ: เควสครบทุกขั้นแล้ว กำลังส่งภูตกลับต้นไม้มนตรา..."
        end
        if not wisp.Returning then
            Hub.rpc("AutoWispQuest", token, "WispCompanion", "Request", "function", "BeginReturn")
        end
        Hub.rpc("AutoWispQuest", token, "WispCompanion", "Request", "function", "Return")
        Hub.status("AutoWispQuest", "confirmed", "ส่งภูตวิญญาณเปิดทางต้นไม้มนตราแล้ว")
        return
    end
    local quest = Hub.currentWispQuest(wisp)
    if not quest then
        return
    end
    local prog = Hub.wispQuestProgress(wisp, quest)
    local target = tonumber(quest.Target) or 1
    local claimed = Hub.wispQuestClaimed(wisp, quest)
    if Hub.WispStatusLabel then
        Hub.WispStatusLabel.Text = string.format("สถานะภูตวิญญาณ: ขั้นที่ %d • %s (%d/%d)", tonumber(wisp.Stage) or 1, tostring(quest.Title or quest.Id), prog, target)
    end
    if prog >= target and not claimed then
        Hub.rpc("AutoWispQuest", token, "WispCompanion", "Request", "function", "Claim", quest.Id)
        Hub.status("AutoWispQuest", "confirmed", "เคลมรางวัลเควสภูตวิญญาณขั้นที่ " .. tostring(wisp.Stage or 1))
    else
        Hub.status("AutoWispQuest", "waiting", string.format("กำลังสะสมเควสภูต (%d/%d)", prog, target))
    end
end
function Hub.worldEventsStep(token, featureKey)
    local now = os.clock()
    if (not featureKey or featureKey == "AutoBloom") and Config.AutoBloom then
        Hub.NextRun.AutoBloom = now + 2.0
        Hub.rpc("AutoBloom", token, "Bloomery", "AskBriefingConfirm", "function")
        Hub.rpc("AutoBloom", token, "Bloomery", "AskStrikeTree", "event", 1)
        for petalIdx = 1, 3 do
            Hub.rpc("AutoBloom", token, "Bloomery", "AskGatherPetal", "function", petalIdx)
        end
        Hub.rpc("AutoBloom", token, "Bloomery", "AskMutate", "function")
        Hub.rpc("AutoBloom", token, "Bloomery", "AskCraneReturn", "function")
        Hub.rpc("AutoBloom", token, "Butterflies", "AskClaimNet", "function")
        Hub.rpc("AutoBloom", token, "Butterflies", "AskSwarm", "function")
        Hub.rpc("AutoBloom", token, "Butterflies", "AskSwing", "function", 1)
        Hub.rpc("AutoBloom", token, "Butterflies", "AskCraftEssence", "function")
        Hub.status("AutoBloom", "confirmed", "เก็บกลีบซากุระและจับผีเสื้อแล้ว")
    end
    if (not featureKey or featureKey == "AutoShootingStar") and Config.AutoShootingStar then
        Hub.NextRun.AutoShootingStar = now + 1.8
        local okState, starState = Hub.rpc("AutoShootingStar", token, "ShootingStar", "AskState", "function")
        local starId = type(starState) == "table" and (starState.Id or (type(starState.Payload) == "table" and starState.Payload.Id)) or 1
        Hub.rpc("AutoShootingStar", token, "ShootingStar", "Hold", "event", starId, true)
        Hub.rpc("AutoShootingStar", token, "ShootingStar", "Catch", "event", starId)
        Hub.status("AutoShootingStar", "confirmed", "ตรวจสอบและเก็บดาวตกในแผนที่แล้ว")
    end
    if (not featureKey or featureKey == "AutoFeedStar") and Config.AutoFeedStar then
        Hub.NextRun.AutoFeedStar = now + 2.5
        local save = getPlayerSaveData()
        local petInv = save and (save.Inventory or save.PetInventory or save.Pets)
        if type(petInv) == "table" then
            local equipped = type(save.EquippedAssets) == "table" and save.EquippedAssets or {}
            local eqSet = {}
            for _, id in pairs(equipped) do
                if type(id) == "string" then
                    eqSet[id] = true
                end
            end
            for uid, pet in pairs(petInv) do
                if type(pet) == "table" and not pet.IsFavorite and not pet.InFuse and not eqSet[uid] then
                    Hub.rpc("AutoFeedStar", token, "ShootingStar", "AskFeed", "function", uid)
                    break
                end
            end
        end
        Hub.status("AutoFeedStar", "confirmed", "ตรวจสอบการป้อนสัตว์เลี้ยงให้ดาวตกแล้ว")
    end
    if (not featureKey or featureKey == "AutoBanjo") and Config.AutoBanjo then
        Hub.NextRun.AutoBanjo = now + 1.5
        if not Hub.BanjoHooked then
            local effectRemote = Hub.remote("BanjoCricket", "Effect", "event")
            if effectRemote and effectRemote.OnClientEvent then
                Hub.BanjoHooked = true
                connectSignal(effectRemote.OnClientEvent, function(payload)
                    if type(payload) == "table" and payload.Kind == "Playback" and type(payload.Notes) == "table" then
                        table.clear(Hub.BanjoNotesQueue)
                        for _, noteIdx in ipairs(payload.Notes) do
                            table.insert(Hub.BanjoNotesQueue, tonumber(noteIdx) or 1)
                        end
                    end
                end)
            end
        end
        if #Hub.BanjoNotesQueue > 0 then
            for _, noteIdx in ipairs(Hub.BanjoNotesQueue) do
                Hub.rpc("AutoBanjo", token, "BanjoCricket", "Aim", "event", noteIdx)
            end
            table.clear(Hub.BanjoNotesQueue)
        else
            for idx = 1, 4 do
                Hub.rpc("AutoBanjo", token, "BanjoCricket", "Aim", "event", idx)
            end
        end
        Hub.rpc("AutoBanjo", token, "BanjoCricket", "AskClaim", "function")
        Hub.status("AutoBanjo", "confirmed", "ส่งลำดับโน้ตมินิเกมแบนโจจิ้งหรีดแล้ว")
    end
    if (not featureKey or featureKey == "AutoFishing") and Config.AutoFishing then
        Hub.NextRun.AutoFishing = now + (Config.InstantFishCatch and 0.8 or 2.0)
        local root = getLocalRoot()
        local castPos = root and (root.Position + Vector3.new(0, -2, -10)) or Vector3.new(0, 0, 0)
        Hub.rpc("AutoFishing", token, "Fishing", "Hold", "event")
        local okCast, castRes = Hub.rpc("AutoFishing", token, "Fishing", "Cast", "function", "Default", castPos)
        local sessionId = type(castRes) == "table" and castRes.Id or (type(castRes) == "string" and castRes) or "1"
        if Config.InstantFishCatch or okCast then
            Hub.rpc("AutoFishing", token, "Fishing", "Reel", "function", sessionId, "Caught", 15)
        end
        Hub.rpc("AutoFishing", token, "Fishing", "AskClaimMastery", "function", 1)
        Hub.status("AutoFishing", "confirmed", "เหวี่ยงเบ็ดและดึงปลาอัตโนมัติแล้ว")
    end
    if (not featureKey or featureKey == "AutoAlien") and Config.AutoAlien then
        Hub.NextRun.AutoAlien = now + 2.2
        Hub.rpc("AutoAlien", token, "UFOSightings", "Fetch", "function")
        Hub.rpc("AutoAlien", token, "UFOSightings", "Collect", "function", 1)
        Hub.rpc("AutoAlien", token, "UFOSightings", "CollectRock", "event", 1)
        Hub.rpc("AutoAlien", token, "UFOSightings", "Repair", "function", 1)
        Hub.rpc("AutoAlien", token, "UFOSightings", "Trade", "function", 1)
        Hub.rpc("AutoAlien", token, "UFOSightings", "VaultClaim", "function")
        Hub.rpc("AutoAlien", token, "AlienLagoon", "Request", "function")
        Hub.rpc("AutoAlien", token, "AlienLagoon", "MetFerryman", "event")
        Hub.rpc("AutoAlien", token, "AlienLagoon", "Trade", "function")
        Hub.rpc("AutoAlien", token, "AlienGate", "Request", "function")
        Hub.rpc("AutoAlien", token, "AlienGate", "Socket", "function")
        Hub.status("AutoAlien", "confirmed", "ดำเนินการสำรวจยูเอฟโอและบึงเอเลี่ยนแล้ว")
    end
    if (not featureKey or featureKey == "AutoIslandWars") and Config.AutoIslandWars then
        Hub.NextRun.AutoIslandWars = now + 1.8
        Hub.rpc("AutoIslandWars", token, "IslandWars", "Fetch", "function")
        Hub.rpc("AutoIslandWars", token, "IslandWars", "Use", "event", "Mine")
        Hub.rpc("AutoIslandWars", token, "IslandWars", "Use", "event", "Swing")
        Hub.rpc("AutoIslandWars", token, "IslandWars", "Use", "event", "Pad", 1)
        Hub.rpc("AutoIslandWars", token, "IslandWars", "OutroFinished", "event")
        Hub.status("AutoIslandWars", "confirmed", "ส่งคำสั่งร่วมสงครามเกาะต้องสาปแล้ว")
    end
end
function Hub.updatePredictorsAndFinder(pinBestNow)
    local nowStr = TimeUtil.formatClock(TimeUtil.serverNow(Hub.ServerClock))
    if Hub.OwnerHealthSummary then
        local hum = getLocalHumanoid()
        local hpNormal = hum and hum.Health > 0 and hum.Health >= (hum.MaxHealth * 0.5) and not Hub.isFallen()
        local plasmaOwner = LocalPlayer and (LocalPlayer.DisplayName or LocalPlayer.Name) or "เรา"
        Hub.OwnerHealthSummary.Text = string.format("[พลาสม่าเป็นเจ้าของ: %s] • [%s]", plasmaOwner, hpNormal and "เลือดปกติ" or "เลือดคือไม่ปกติ")
    end
    local records = getFieldEggRecords()
    local candidates = Hub.getSortedStealCandidates(records, os.clock())
    if Hub.EggPredSummary then
        local top = candidates[1]
        if top and top.egg then
            local egg = top.egg
            local spName = getSpeciesThaiName(egg.AssetCategory)
            local rInfo = getEggRarityInfo(egg.AssetCategory)
            local mutName = getMutationThaiString(egg.Mutations, egg.BaseMutation)
            Hub.EggPredSummary.Text = string.format("พยากรณ์ไข่ [%s]: พบไข่เข้าเกณฑ์ %d ฟอง • อันดับ 1: %s (%s • %s) • รายได้ %s/วินาที", nowStr, #candidates, spName, rInfo and rInfo.name or "ทั่วไป", mutName, formatCompactThaiNumber(top.metrics.Income))
        else
            Hub.EggPredSummary.Text = string.format("พยากรณ์ไข่ [%s]: ยังไม่พบไข่ในสนามที่ตรงตัวกรอง", nowStr)
        end
    end
    if Hub.FusePredSummary then
        local save = getPlayerSaveData()
        local plan = save and Hub.planFusion and Hub.planFusion(save, true) or nil
        if type(plan) == "table" and type(plan.Uids) == "table" and #plan.Uids > 0 then
            local inv = save and (save.Inventory or save.PetInventory) or {}
            local firstPet = inv[plan.Uids[1]]
            local catName = getSpeciesThaiName(firstPet and firstPet.Category or "")
            Hub.FusePredSummary.Text = string.format("พยากรณ์ฟิวส์ชั่น [%s]: พร้อมรวม %s จำนวน %d ตัว • ค่าใช้จ่ายประมาณ %s", nowStr, catName, #plan.Uids, formatCompactThaiNumber(plan.Price or 0))
        else
            Hub.FusePredSummary.Text = string.format("พยากรณ์ฟิวส์ชั่น [%s]: ยังไม่มีชุดสัตว์เลี้ยงซ้ำครบ 3 ตัวที่พร้อมฟิวส์ชั่น", nowStr)
        end
    end
    if Hub.FinderSummary then
        local best = candidates[1]
        if best and best.egg then
            local egg = best.egg
            local areaName = AREA_THAI_BY_ID[egg.AreaId] or tostring(egg.AreaId or "ไม่ทราบพื้นที่")
            local spName = getSpeciesThaiName(egg.AssetCategory)
            local myRoot = getLocalRoot()
            local eggCF = egg.BottomCFrame or egg.BoundsCFrame
            local dist = (myRoot and eggCF) and Hub.distance(myRoot.Position, eggCF.Position) or 0
            Hub.FinderSummary.Text = string.format("ตัวค้นหาเป้าหมาย (พบไข่ในสนาม): %s ที่พื้นที่%s • ระยะ %.0f เมตร • รหัส %s", spName, areaName, tonumber(dist) or 0, tostring(egg.Uid):sub(-6))
            if pinBestNow and type(egg.Uid) == "string" then
                Hub.queueMoveTop(egg.Uid)
                notifyThai("ปักหมุดไข่เป้าหมายอันดับ 1 (" .. spName .. ") ไว้บนสุดของคิวแล้ว")
            end
        else
            Hub.FinderSummary.Text = "ตัวค้นหาเป้าหมาย: ไม่พบไข่เป้าหมายในระยะสแกน"
        end
    end
end
function Hub.inventoryStep(save)
    if not save then
        return
    end
    Hub.fusionStep(save)
    Hub.shrineFusionStep(save)
    Hub.mutationStep(save)
    Hub.favoriteStep(save)
    Hub.collectMoneyStep(save)
    Hub.trailStep(save)
    if Config.AutoHatchEgg then
        Hub.job("AutoHatchEgg", 1.3, true, function(token)
            local eggs = save.EggInventory
            if EggState and EggState.ReadOwnerEggs then
                local ok, rows = pcall(EggState.ReadOwnerEggs, LocalPlayer.UserId)
                if ok and type(rows) == "table" then
                    eggs = rows
                end
            end
            local readyUid
            for uid, egg in pairs(eggs or {}) do
                if type(egg) == "table" and egg.Placement then
                    local ready = false
                    if EggState and EggState.IsReadyToHatch then
                        local ok, value = pcall(EggState.IsReadyToHatch, uid)
                        ready = ok and value == true
                    elseif type(egg.Placement.ReadyAt) == "number" then
                        ready = TimeUtil.diffSeconds(egg.Placement.ReadyAt, TimeUtil.serverNow(Hub.ServerClock)) <= 0
                    end
                    if ready then
                        readyUid = uid
                        break
                    end
                end
            end
            if not readyUid then
                Hub.status("AutoHatchEgg", "waiting", "ยังไม่มีไข่พร้อมฟัก")
                return
            end
            Hub.BestSignature = nil
            local accepted = Hub.rpc("AutoHatchEgg", token, "EggWorld", "AskHatch", "function", readyUid)
            if not accepted or not Hub.alive("AutoHatchEgg", token) then
                return
            end
            local finished, _, _, newUid = Hub.rpc("AutoHatchEgg", token, "EggWorld", "AskFinishHatch", "function", readyUid)
            if finished then
                Hub.PendingHatch = { EggUid = readyUid, AssetUid = newUid }
                Hub.NextRun.AutoEquipBest = 0
            end
        end)
    end
    if type(Hub.PendingHatch) == "table" and type(Hub.PendingHatch.EggUid) == "string" then
        local pending = Hub.PendingHatch
        if not (save.EggInventory or {})[pending.EggUid] and (type(pending.AssetUid) ~= "string" or (save.Inventory or {})[pending.AssetUid]) then
            table.clear(Hub.PendingHatch)
        else
            Hub.status("AutoSellPet", "waiting", "รอข้อมูลสัตว์เลี้ยงหลังฟักไข่")
            return
        end
    end
    if Config.AutoEquipBest and not (Config.AutoFusion and next(Hub.FusionReserved or {})) then
        Hub.job("AutoEquipBest", 5.5, true, function(token)
            local startRevision = Hub.EquipRevision
            local accepted = Hub.rpc("AutoEquipBest", token, "Haul", "WearBest", "function")
            if not accepted then
                Hub.BestSignature = nil
                return
            end
            RuntimeState.LastEquipBestExecutedAt = os.clock()
            local deadline = os.clock() + 2
            while Hub.alive("AutoEquipBest", token) and Hub.EquipRevision <= startRevision and os.clock() < deadline do
                task.wait(0.05)
            end
            if not Hub.alive("AutoEquipBest", token) then
                return
            end
            if Hub.EquipRevision > startRevision then
                Hub.BestSignature = Hub.signature(getPlayerSaveData())
            else
                local readOK, snapshot = Hub.rpc("AutoEquipBest", token, "PenRoster", "AskLiveSnapshot", "function")
                if not Hub.alive("AutoEquipBest", token) then
                    return
                end
                local fresh, serverEquipped = getPlayerSaveData(), nil
                if readOK and type(snapshot) == "table" then
                    for _, owner in ipairs(snapshot) do
                        if type(owner) == "table" and owner.OwnerUserId == LocalPlayer.UserId and type(owner.Records) == "table" then
                            serverEquipped = {}
                            for uid in pairs(owner.Records) do
                                if type(uid) == "string" then
                                    serverEquipped[uid] = true
                                end
                            end
                            break
                        end
                    end
                end
                local consistent = fresh ~= nil and serverEquipped ~= nil
                if consistent then
                    local localEquipped = {}
                    for _, uid in ipairs(fresh.EquippedAssets or {}) do
                        localEquipped[uid] = true
                    end
                    for uid in pairs(serverEquipped) do
                        if not localEquipped[uid] or not (fresh.Inventory or {})[uid] then
                            consistent = false
                        end
                    end
                    for uid in pairs(localEquipped) do
                        if not serverEquipped[uid] then
                            consistent = false
                        end
                    end
                end
                if consistent then
                    Hub.BestSignature = Hub.signature(fresh)
                    Hub.status("AutoEquipBest", "confirmed", "ยืนยันการสวมใส่จากสถานะคอกบนเซิร์ฟเวอร์แล้ว")
                else
                    Hub.BestSignature = nil
                    Hub.status("AutoEquipBest", "waiting", "รอข้อมูลคอกจากเกมให้ตรงกับกระเป๋าก่อนขาย")
                end
            end
        end)
    end
    if Config.AutoSellPet then
        Hub.job("AutoSellPet", 4.5, true, function(token)
            local fresh = getPlayerSaveData()
            if not fresh then
                Hub.status("AutoSellPet", "waiting", "รอข้อมูลกระเป๋า")
                return
            end
            if Config.AutoEquipBest and (not Hub.BestSignature or Hub.signature(fresh) ~= Hub.BestSignature) then
                Hub.status("AutoSellPet", "waiting", "รอข้อมูลใส่ตัวเก่งสุดยืนยันก่อนขาย")
                return
            end
            if Config.SellMode == "ขายทุกตัว" and not Config.AutoEquipBest then
                for _, uid in ipairs(fresh.EquippedAssets or {}) do
                    local pet = (fresh.Inventory or {})[uid]
                    if pet and not pet.IsFavorite and not pet.InFuse then
                        local accepted = Hub.rpc("AutoSellPet", token, "PenRoster", "AskDoff", "function", uid)
                        if not accepted or not Hub.alive("AutoSellPet", token) then
                            return
                        end
                    end
                end
                fresh = getPlayerSaveData()
                if not fresh or #(fresh.EquippedAssets or {}) > 0 then
                    Hub.status("AutoSellPet", "waiting", "รอเกมยืนยันถอดสัตว์เลี้ยงก่อนขาย")
                    return
                end
            end
            local candidates = Hub.saleCandidates(fresh)
            if #candidates == 0 then
                Hub.status("AutoSellPet", "waiting", "ไม่มีตัวที่ขายได้และไม่ถูกจอง")
                return
            end
            Hub.rpc("AutoSellPet", token, "PetSatchel", "SellSelection", "event", { Assets = candidates, Eggs = {} })
        end)
    end
end
function Hub.otherStep(save, carry, target)
    if Config.AutoUpgradeAll and save then
        Hub.job("AutoUpgradeAll", 3, true, function(token)
            if not Hub.beginSpend("AutoUpgradeAll", 0) then
                return
            end
            save = getPlayerSaveData() or save
            local requested = false
            local function upgradeBase()
                if BaseUpgrade and BaseUpgrade.IsNextTierAffordable then
                    local ok, affordable = pcall(BaseUpgrade.IsNextTierAffordable, save)
                    if ok and affordable and Hub.alive("AutoUpgradeAll", token) then
                        Hub.rpc("AutoUpgradeAll", token, "Homestead", "AskBaseTierRaise", "event")
                        requested = true
                        Hub.NextUpgradeKind = "treadmill"
                    end
                end
            end
            if Hub.NextUpgradeKind ~= "treadmill" then
                upgradeBase()
            end
            if not requested and TreadmillsData and TreadmillsData.GetByUpgradeLevel then
                local nextTier = TreadmillsData.GetByUpgradeLevel((save.TreadmillUpgradeLevel or 0) + 1)
                if nextTier and type(nextTier.Price) == "number" and (save.Money or 0) >= nextTier.Price then
                    Hub.rpc("AutoUpgradeAll", token, "Treadmill", "AskTierRaise", "function", nextTier._id)
                    requested = true
                    Hub.NextUpgradeKind = "base"
                end
            end
            if not requested then
                upgradeBase()
            end
            if not requested then
                Hub.status("AutoUpgradeAll", "waiting", "รอเงินหรือข้อมูลขั้นอัปเกรด (บ้าน/ลู่วิ่ง)")
            end
        end)
    end
    if Config.AutoClaimReward and save then
        Hub.job("AutoClaimReward", 60, false, function(token)
            Hub.RewardWasIdle = false
            if (save.PendingOfflineMoney or 0) > 0 then
                Hub.rpc("AutoClaimReward", token, "AwayEarnings", "AskCollect", "function", { Kind = "Claim" })
            end
            if not Hub.alive("AutoClaimReward", token) then
                return
            end
            Hub.rpc("AutoClaimReward", token, "Codex", "AskRedeemAll", "function")
            if not save.ClaimedGroupReward and Hub.alive("AutoClaimReward", token) then
                Hub.rpc("AutoClaimReward", token, "GroupPerk", "RedeemPerk", "function", true)
            end
            if Hub.RewardWasIdle then
                Hub.RewardIdleCount = (Hub.RewardIdleCount or 0) + 1
                Hub.NextRun.AutoClaimReward = os.clock() + TimeUtil.rewardBackoffSeconds(Hub.RewardIdleCount)
            else
                Hub.RewardIdleCount = 0
            end
        end)
    end
    local handBusy = not carry or carry.IsCarrying or Hub.InventoryOwner ~= nil or Hub.MovementOwner == "AutoPlaceEgg" or Hub.RecoveryEgg ~= nil or Hub.RecoveryCarry or Hub.isFallen() or os.clock() - RuntimeState.LastStealPickupAttemptAt < 1.2
    if (Config.AutoEquipBat or Config.AutoAttack) and not handBusy then
        local tool = Hub.weapon()
        if not tool then
            if Config.AutoEquipBat then
                Hub.status("AutoEquipBat", "waiting", "ไม่พบไม้ตีที่เกมระบุ IsBat")
            end
            if Config.AutoAttack then
                Hub.status("AutoAttack", "waiting", "รอไม้ตีที่ใช้งานได้")
            end
        else
            if Config.AutoEquipBat then
                Hub.status("AutoEquipBat", "local", "ถือไม้ตีแล้ว")
            end
            if Config.AutoAttack and target and target.Character then
                local theirRoot = target.Character:FindFirstChild("HumanoidRootPart")
                local root = getLocalRoot()
                local cooldown = tonumber(tool:GetAttribute("CooldownEndTime")) or 0
                if root and theirRoot and (theirRoot.Position - root.Position).Magnitude <= 16 and TimeUtil.diffSeconds(cooldown, TimeUtil.serverNow(Hub.ServerClock)) <= 0 and os.clock() >= (Hub.NextSwing or 0) then
                    Hub.NextSwing = os.clock() + 0.6
                    if Config.AttackMode == "ไปตีผู้เล่นที่ถือไข่" then
                        local uids = {}
                        for _, record in pairs(getFieldEggRecords()) do
                            if record.State == "Carried" and record.CarrierUserId == target.UserId then
                                uids[record.Uid] = true
                            end
                        end
                        Hub.LastCarrierAttack = { Uids = uids, At = os.clock(), PlayerUserId = target.UserId }
                    end
                    tool:Activate()
                    Hub.status("AutoAttack", "requested", "สั่งใช้ไม้ตีแล้ว ผลโจมตีตรวจโดยเกม")
                end
            end
        end
    elseif handBusy then
        for _, key in ipairs({ "AutoEquipBat", "AutoAttack" }) do
            if Config[key] then
                Hub.status(key, "waiting", "รอช่องถือไอเทมจากระบบไข่")
            end
        end
    end
end
if SearchInputBox then
    connectSignal(SearchInputBox:GetPropertyChangedSignal("Text"), function()
        if Hub.applySearchFilter then
            Hub.applySearchFilter(SearchInputBox.Text)
        end
    end)
end
function Hub.applySearchFilter(queryText)
    local q = tostring(queryText or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    for _, page in pairs(Pages) do
        for _, sec in ipairs(page:GetChildren()) do
            if sec:IsA("Frame") and sec.Name:sub(1, 8) == "Section_" then
                if q == "" then
                    sec.Visible = true
                    for _, child in ipairs(sec:GetChildren()) do
                        if child:IsA("GuiObject") and child.LayoutOrder > 0 and not child.Name:find("^QueueRow_") then
                            child.Visible = true
                        end
                    end
                else
                    local secMatch = sec.Name:lower():find(q, 1, true) ~= nil
                    local anyChildMatch = false
                    for _, child in ipairs(sec:GetChildren()) do
                        if child:IsA("GuiObject") and child.LayoutOrder > 0 then
                            local matched = secMatch
                            if not matched then
                                if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                                    if tostring(child.Text or ""):lower():find(q, 1, true) then
                                        matched = true
                                    end
                                end
                                for _, desc in ipairs(child:GetDescendants()) do
                                    if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
                                        if tostring(desc.Text or ""):lower():find(q, 1, true) then
                                            matched = true
                                            break
                                        end
                                    end
                                end
                            end
                            if not child.Name:find("^QueueRow_") then
                                child.Visible = matched
                            end
                            if matched then
                                anyChildMatch = true
                            end
                        end
                    end
                    sec.Visible = secMatch or anyChildMatch
                end
            end
        end
    end
end
function Hub.warpToSafeZone(toPlotSpawn)
    local root = getLocalRoot()
    if not root then
        return false
    end
    local plot = findLocalPlotFallback()
    if toPlotSpawn and plot then
        local cf = plot.RespawnPointCFrame or (plot.CenterPoint and plot.CenterPoint.CFrame) or (plot.PetArea and plot.PetArea.CFrame)
        if cf then
            root.CFrame = cf + Vector3.new(0, 3, 0)
            root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
            notifyThai("วาร์ปกลับคอกของตัวเองเรียบร้อยแล้ว")
            return true
        end
    end
    local areas = Hub.fieldAreas()
    local line = areas and areas:FindFirstChild("SeparationLine")
    if line then
        local look = line.CFrame.LookVector
        local safePos = line.Position - look * 12 + Vector3.new(0, 3, 0)
        root.CFrame = CFrame.new(safePos) * root.CFrame.Rotation
        root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
        Hub.status("WarpToSafeZone", "local", "วาร์ปเข้าเขตปลอดภัยแล้ว")
        return true
    elseif plot and plot.CenterPoint then
        root.CFrame = plot.CenterPoint.CFrame + Vector3.new(0, 3, 0)
        root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
        Hub.status("WarpToSafeZone", "local", "วาร์ปกลับจุดกลางคอกแล้ว")
        return true
    end
    return false
end
function Hub.warpToArea(areaId)
    local root = getLocalRoot()
    if not root then
        return false
    end
    if not areaId or areaId == "All" then
        return Hub.warpToSafeZone(true)
    end
    local areas = Hub.fieldAreas()
    local guardAreas = areas and areas:FindFirstChild("GuardAreas")
    local targetInst = (guardAreas and guardAreas:FindFirstChild(areaId)) or (areas and areas:FindFirstChild(areaId)) or Workspace:FindFirstChild(areaId, true)
    if targetInst then
        local cf = targetInst:IsA("BasePart") and targetInst.CFrame or (targetInst:IsA("Model") and targetInst:GetPivot()) or nil
        if not cf then
            local part = targetInst:FindFirstChildWhichIsA("BasePart", true)
            cf = part and part.CFrame or nil
        end
        if cf then
            root.CFrame = cf + Vector3.new(0, 4, 0)
            root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
            notifyThai("วาร์ปไปยังพื้นที่ " .. (AREA_THAI_BY_ID[areaId] or areaId) .. " แล้ว")
            return true
        end
    end
    notifyThai("ยังไม่พบพิกัดพื้นที่ " .. (AREA_THAI_BY_ID[areaId] or tostring(areaId)) .. " ในฉาก")
    return false
end
function Hub.mutationStep(save)
    if not Config.AutoMutation or not save then
        return
    end
    Hub.job("AutoMutation", 2.5, false, function(token)
        local minRarity = Config.MutationMinRarity ~= "All" and RARITY_BY_ID[Config.MutationMinRarity] or nil
        local eggs = save.EggInventory or {}
        local targetEggUid = nil
        for uid, egg in pairs(eggs) do
            if type(egg) == "table" and not egg.Placement then
                local rInfo = getEggRarityInfo(egg.AssetCategory or egg.Category)
                if not minRarity or (rInfo and rInfo.rank >= minRarity.rank) then
                    targetEggUid = uid
                    break
                end
            end
        end
        if targetEggUid then
            Hub.rpc("AutoMutation", token, "Bloomery", "AskLoadEgg", "function", targetEggUid)
            Hub.rpc("AutoMutation", token, "Bloomery", "AskMutate", "function")
            Hub.rpc("AutoMutation", token, "Bloomery", "AskEjectEgg", "function")
        end
        local inv = save.Inventory or save.PetInventory or {}
        for uid, pet in pairs(inv) do
            if type(pet) == "table" and not pet.IsFavorite then
                local rInfo = getEggRarityInfo(pet.Category)
                if not minRarity or (rInfo and rInfo.rank >= minRarity.rank) then
                    Hub.rpc("AutoMutation", token, "BossMastery", "AskUseMutationConsumable", "function", uid)
                    break
                end
            end
        end
        Hub.status("AutoMutation", "confirmed", "ส่งคำสั่งกลายพันธุ์ไข่และสัตว์เลี้ยงแล้ว")
    end)
end
function Hub.shrineFusionStep(save)
    if not Config.AutoShrineFusion or not save then
        return
    end
    Hub.job("AutoShrineFusion", 3.0, false, function(token)
        Hub.rpc("AutoShrineFusion", token, "ShrineFusion", "AskState", "function")
        local inv = save.Inventory or save.PetInventory or {}
        local equipped = {}
        for _, id in ipairs(save.EquippedAssets or {}) do
            equipped[id] = true
        end
        local candidateUids = {}
        for uid, pet in pairs(inv) do
            if type(pet) == "table" and not pet.IsFavorite and not pet.InFuse and not equipped[uid] then
                candidateUids[#candidateUids + 1] = uid
                if #candidateUids >= 3 then
                    break
                end
            end
        end
        if #candidateUids > 0 then
            Hub.rpc("AutoShrineFusion", token, "ShrineFusion", "AskSubmit", "function", candidateUids)
            Hub.status("AutoShrineFusion", "confirmed", "ส่งสัตว์เลี้ยงเข้าแท่นบูชาฟิวส์ชั่นแล้ว")
        else
            Hub.status("AutoShrineFusion", "waiting", "รอสัตว์เลี้ยงที่ว่างสำหรับแท่นบูชาฟิวส์ชั่น")
        end
    end)
end
function Hub.favoriteStep(save)
    if not Config.AutoFavorite or not save then
        return
    end
    Hub.job("AutoFavorite", 3.0, false, function(token)
        local minRarity = Config.FavoriteMinRarity ~= "All" and RARITY_BY_ID[Config.FavoriteMinRarity] or nil
        local count = 0
        for _, tbl in ipairs({ save.Inventory or {}, save.EggInventory or {} }) do
            for uid, item in pairs(tbl) do
                if type(item) == "table" and not item.IsFavorite then
                    local cat = item.Category or item.AssetCategory
                    local rInfo = getEggRarityInfo(cat)
                    local mutStr = getMutationThaiString(item.Mutations, item.BaseMutation)
                    local hasMut = mutStr ~= "ปกติ"
                    local passRarity = not minRarity or (rInfo and rInfo.rank >= minRarity.rank)
                    local passMut = not Config.FavoriteMutatedOnly or hasMut
                    if passRarity and passMut then
                        Hub.rpc("AutoFavorite", token, "PetSatchel", "WriteFavourite", "event", uid, true)
                        count = count + 1
                    end
                end
            end
        end
        Hub.status("AutoFavorite", count > 0 and "confirmed" or "waiting", count > 0 and ("ล็อกดาวรายการหายากแล้ว " .. tostring(count) .. " รายการ") or "ทุกรายการที่เข้าเกณฑ์ถูกล็อกดาวแล้ว")
    end)
end
function Hub.collectMoneyStep(save)
    if not Config.AutoCollectMoney or not save then
        return
    end
    Hub.job("AutoCollectMoney", 2.0, false, function(token)
        if (tonumber(save.PendingOfflineMoney) or 0) > 0 then
            Hub.rpc("AutoCollectMoney", token, "AwayEarnings", "AskCollect", "function", { Kind = "Claim" })
        end
        Hub.rpc("AutoCollectMoney", token, "AwayEarnings", "FetchSummary", "function")
        local plot = findLocalPlotFallback()
        local root = getLocalRoot()
        local touchFn = type(GlobalEnv) == "table" and GlobalEnv.firetouchinterest or nil
        if plot and plot.PlotFolder and root and type(touchFn) == "function" then
            for _, inst in ipairs(plot.PlotFolder:GetDescendants()) do
                if inst:IsA("BasePart") and (inst.Name:find("Coin") or inst.Name:find("Cash") or inst.Name:find("Collect")) then
                    pcall(touchFn, root, inst, 0)
                    pcall(touchFn, root, inst, 1)
                end
            end
        end
        Hub.status("AutoCollectMoney", "confirmed", "ตรวจสอบและเก็บเงินจากคอกและออฟไลน์แล้ว")
    end)
end
function Hub.adminAbuseStep(token, featureKey)
    local now = TimeUtil.clockNow()
    if not featureKey or featureKey == "AutoAdminAbuse" then
        Hub.NextRun.AutoAdminAbuse = now + 2.5
        local okRun, runningMap = Hub.rpc("AutoAdminAbuse", token, "LiveEvents", "FetchRunning", "function")
        local activeNames = {}
        if okRun and type(runningMap) == "table" then
            for evName in pairs(runningMap) do
                activeNames[#activeNames + 1] = tostring(evName)
            end
        end
        if Hub.AdminAbuseStatusLabel then
            if #activeNames > 0 then
                Hub.AdminAbuseStatusLabel.Text = "สถานะกิจกรรมแอดมิน: กำลังเปิดใช้งาน • " .. table.concat(activeNames, ", ")
            else
                Hub.AdminAbuseStatusLabel.Text = "สถานะกิจกรรมแอดมิน: เฝ้าระวังอีเวนต์แอดมินอัตโนมัติ"
            end
        end
        Hub.status("AutoAdminAbuse", "confirmed", #activeNames > 0 and ("เข้าร่วมอีเวนต์แอดมิน: " .. table.concat(activeNames, ", ")) or "เฝ้าระวังกิจกรรมแอดมิน")
    end
    if Config.AutoAdminAbuse or (featureKey == "AutoBeanstalk" and Config.AutoBeanstalk) then
        local key = Config.AutoBeanstalk and "AutoBeanstalk" or "AutoAdminAbuse"
        Hub.NextRun.AutoBeanstalk = now + 1.8
        Hub.rpc(key, token, "BeanstalkEvent", "AskStartTimer", "event")
        Hub.rpc(key, token, "BeanstalkEvent", "AskPour", "event")
        Hub.rpc(key, token, "BeanstalkEvent", "AskCatchFirefly", "event", 1)
        Hub.rpc(key, token, "BeanstalkEvent", "AskLaunch", "event")
        Hub.rpc(key, token, "BeanstalkEvent", "AskFinishFlight", "event")
        Hub.rpc(key, token, "BeanstalkEvent", "AskStealEgg", "event")
        Hub.rpc(key, token, "BeanstalkEvent", "AskFinishEscape", "event")
        Hub.rpc(key, token, "BeanstalkEvent", "AskClaimReward", "event")
        if Config.AutoBeanstalk then
            Hub.status("AutoBeanstalk", "confirmed", "ส่งคำสั่งร่วมกิจกรรมต้นถั่วยักษ์และหิ่งห้อยแล้ว")
        end
    end
    if Config.AutoAdminAbuse or (featureKey == "AutoLightVsDark" and Config.AutoLightVsDark) then
        local key = Config.AutoLightVsDark and "AutoLightVsDark" or "AutoAdminAbuse"
        Hub.NextRun.AutoLightVsDark = now + 1.8
        if type(LocalPlayer:GetAttribute("LvdTeam")) ~= "string" then
            Hub.rpc(key, token, "LightVsDarkness", "AskSelectTeam", "event", "Random")
        end
        local okRings, waveId, zones = Hub.rpc(key, token, "LightVsDarkness", "FetchRings", "function")
        if okRings and type(waveId) == "number" then
            Hub.rpc(key, token, "LightVsDarkness", "AskCollectRing", "event", waveId, 1, 1)
        end
        local okPow, powWave = Hub.rpc(key, token, "LightVsDarkness", "FetchPowerUps", "function")
        if okPow and type(powWave) == "number" then
            Hub.rpc(key, token, "LightVsDarkness", "AskCollectPowerUp", "event", powWave, 1)
        end
        Hub.rpc(key, token, "LightVsDarkness", "AskClaimMilestone", "event", 1)
        if Config.AutoLightVsDark then
            Hub.status("AutoLightVsDark", "confirmed", "เก็บวงแหวน พลังเสริม และรางวัลศึกแสงและเงาแล้ว")
        end
    end
    if Config.AutoAdminAbuse or (featureKey == "AutoSammy" and Config.AutoSammy) then
        local key = Config.AutoSammy and "AutoSammy" or "AutoAdminAbuse"
        Hub.NextRun.AutoSammy = now + 1.8
        local okPick, sWave = Hub.rpc(key, token, "SammyEvent", "FetchPickups", "function")
        if okPick and type(sWave) == "number" then
            Hub.rpc(key, token, "SammyEvent", "AskCollectPickup", "event", sWave, 1, 1)
        end
        if Config.AutoSammy then
            Hub.status("AutoSammy", "confirmed", "เก็บไอเทมกิจกรรมแซมมี่แล้ว")
        end
    end
    if Config.AutoAdminAbuse or (featureKey == "AutoBossRaid" and Config.AutoBossRaid) then
        local key = Config.AutoBossRaid and "AutoBossRaid" or "AutoAdminAbuse"
        Hub.NextRun.AutoBossRaid = now + 2.0
        Hub.rpc(key, token, "BossEvent", "AskEnter", "function")
        Hub.rpc(key, token, "BossEvent", "AskSnapshot", "function")
        Hub.rpc(key, token, "BossEvent", "BossDamaged", "event", 1)
        Hub.rpc(key, token, "ScrambleBoss", "EnterArena", "function")
        Hub.rpc(key, token, "PumpkinBoss", "Collect", "event", 1)
        Hub.rpc(key, token, "PeteSpaceRaid", "Hits", "event", 1)
        Hub.rpc(key, token, "PeteSpaceRaid", "Delivered", "event", 1)
        Hub.rpc(key, token, "PeteSpaceRaid", "OutroDone", "event")
        Hub.rpc(key, token, "BossMastery", "AskClaimMilestone", "function", 1)
        if Config.AutoBossRaid then
            Hub.status("AutoBossRaid", "confirmed", "ส่งคำสั่งโจมตีบอสและรับรางวัลมาสเตอรีบอสแล้ว")
        end
    end
    if Config.AutoAdminAbuse or (featureKey == "AutoMinigameEvents" and Config.AutoMinigameEvents) then
        local key = Config.AutoMinigameEvents and "AutoMinigameEvents" or "AutoAdminAbuse"
        Hub.NextRun.AutoMinigameEvents = now + 2.0
        Hub.rpc(key, token, "TrexRun", "FetchHerd", "function")
        Hub.rpc(key, token, "RedLightGreenLight", "Cover", "event", true)
        Hub.rpc(key, token, "MonsterEvent", "GetWins", "function")
        Hub.rpc(key, token, "MonsterEvent", "GetWinParts", "function")
        Hub.rpc(key, token, "MonsterParasite", "AskSnapshot", "function")
        Hub.rpc(key, token, "MonsterParasite", "AskFeed", "function", 1)
        Hub.rpc(key, token, "MonsterParasite", "AskChestClaim", "function")
        Hub.rpc(key, token, "MonsterParasite", "AskChestRevealComplete", "function")
        Hub.rpc(key, token, "MonsterParasite", "AskChestTake", "function")
        Hub.rpc(key, token, "RaceRally", "AskClaimMilestone", "function", 1)
        Hub.rpc(key, token, "MountRace", "PowerUp", "event", 1)
        Hub.rpc(key, token, "MountRace", "OutroFinished", "event")
        Hub.rpc(key, token, "HalloweenDimension", "AskClaimMastery", "function", 1)
        Hub.rpc(key, token, "HalloweenDimension", "AskClaimHorseman", "function")
        if Config.AutoMinigameEvents then
            Hub.status("AutoMinigameEvents", "confirmed", "ดำเนินการมินิเกมแอดมินและกิจกรรมปรสิตแล้ว")
        end
    end
end
function Hub.extendedWorldStep(token, featureKey)
    local now = TimeUtil.clockNow()
    if (not featureKey or featureKey == "AutoGhostDogQuest") and Config.AutoGhostDogQuest then
        Hub.NextRun.AutoGhostDogQuest = now + 2.0
        Hub.rpc("AutoGhostDogQuest", token, "GhostDogQuest", "Talk", "function")
        Hub.rpc("AutoGhostDogQuest", token, "GhostDogQuest", "Cast", "function")
        Hub.rpc("AutoGhostDogQuest", token, "GhostDogQuest", "Dive", "function")
        Hub.rpc("AutoGhostDogQuest", token, "GhostDogQuest", "Collect", "function", 1)
        Hub.rpc("AutoGhostDogQuest", token, "GhostDogQuest", "Surface", "function")
        Hub.rpc("AutoGhostDogQuest", token, "GhostDogQuest", "Claim", "function")
        Hub.status("AutoGhostDogQuest", "confirmed", "ดำเนินการเควสสุนัขวิญญาณครบขั้นตอนแล้ว")
    end
    if (not featureKey or featureKey == "AutoSubZones") and Config.AutoSubZones then
        Hub.NextRun.AutoSubZones = now + 2.5
        Hub.rpc("AutoSubZones", token, "SewerCave", "Arrive", "function")
        Hub.rpc("AutoSubZones", token, "SewerCave", "MetWorker", "event")
        Hub.rpc("AutoSubZones", token, "ManorInterior", "Request", "function")
        Hub.rpc("AutoSubZones", token, "ManorInterior", "Arrive", "function")
        Hub.rpc("AutoSubZones", token, "TheHollow", "AskEnter", "function")
        Hub.rpc("AutoSubZones", token, "SeaMonkey", "Request", "function")
        Hub.rpc("AutoSubZones", token, "OnboardingQuestline", "AskAcknowledge", "function", 1)
        Hub.rpc("AutoSubZones", token, "OnboardingQuestline", "AskClaim", "function", 1)
        Hub.status("AutoSubZones", "confirmed", "สำรวจโซนลับและเคลมเควสเริ่มต้นแล้ว")
    end
    if (not featureKey or featureKey == "AutoPetWheel") and Config.AutoPetWheel then
        Hub.NextRun.AutoPetWheel = now + 2.2
        Hub.rpc("AutoPetWheel", token, "PetWheel", "Spin", "function")
        Hub.rpc("AutoPetWheel", token, "PetWheel", "Finish", "event")
        Hub.status("AutoPetWheel", "confirmed", "หมุนวงล้อสัตว์เลี้ยงและรับผลแล้ว")
    end
    if (not featureKey or featureKey == "AutoRiftAndScramble") and Config.AutoRiftAndScramble then
        Hub.NextRun.AutoRiftAndScramble = now + 2.5
        Hub.rpc("AutoRiftAndScramble", token, "Rift", "AskState", "function")
        Hub.rpc("AutoRiftAndScramble", token, "Rift", "AskTradeIn", "function", {})
        Hub.rpc("AutoRiftAndScramble", token, "Rift", "AskFinishReveal", "function")
        Hub.rpc("AutoRiftAndScramble", token, "ScrambleTradeIn", "AskState", "function")
        Hub.rpc("AutoRiftAndScramble", token, "ScrambleTradeIn", "AskTradeIn", "function", {})
        Hub.rpc("AutoRiftAndScramble", token, "ScrambleTradeIn", "AskFinishReveal", "function")
        Hub.status("AutoRiftAndScramble", "confirmed", "ตรวจสอบและแลกไข่รอยแยกและห้องทดลองแล้ว")
    end
end
function Hub.rerollPredictorsAndTrades()
    Hub.queueReset()
    task.spawn(function()
        local token = Hub.Generation.AutoRiftAndScramble or 0
        Hub.rpc("AutoRiftAndScramble", token, "Rift", "AskRefresh", "function")
        Hub.rpc("AutoRiftAndScramble", token, "ScrambleTradeIn", "AskRefresh", "function")
    end)
    if Hub.updatePredictorsAndFinder then
        Hub.updatePredictorsAndFinder(true)
    end
    notifyThai("รีรอลใหม่และอัปเดตคิวพยากรณ์เรียบร้อยแล้ว")
end
function Hub.playerMovementStep()
    local hum = getLocalHumanoid()
    local char = LocalPlayer.Character
    if hum and hum.Health > 0 then
        if Config.PlayerSpeedEnabled and not Hub.MovementOwner then
            hum.WalkSpeed = tonumber(Config.PlayerWalkSpeed) or 32
            Hub.status("PlayerSpeedEnabled", "local", "ตั้งความเร็วเดิน " .. tostring(Config.PlayerWalkSpeed))
        end
        if Config.PlayerJumpEnabled then
            pcall(function()
                hum.UseJumpPower = true
                hum.JumpPower = tonumber(Config.PlayerJumpPower) or 65
            end)
            Hub.status("PlayerJumpEnabled", "local", "ตั้งพลังกระโดด " .. tostring(Config.PlayerJumpPower))
        end
        if Config.InfiniteJump then
            Hub.status("InfiniteJump", "local", "พร้อมกระโดดกลางอากาศไม่จำกัด")
        end
        if Config.WarpToSafeZone and hum.Health < hum.MaxHealth * 0.35 then
            Hub.warpToSafeZone(false)
        end
    end
    if Config.Noclip and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        Hub.status("Noclip", "local", "เปิดเดินทะลุสิ่งกีดขวางฝั่งเราแล้ว")
    end
    if Config.AutoPetMount then
        Hub.job("AutoPetMount", 3.0, false, function(token)
            Hub.rpc("AutoPetMount", token, "PetMount", "Request", "function")
            Hub.status("AutoPetMount", "confirmed", "ส่งคำขอขี่สัตว์เลี้ยงแล้ว")
        end)
    end
end
function Hub.setupAutoLoadOnTeleport()
    if not Config.AutoLoadScript then
        return
    end
    local synTbl = type(GlobalEnv) == "table" and GlobalEnv.syn or nil
    local fluxusTbl = type(GlobalEnv) == "table" and GlobalEnv.fluxus or nil
    local qFn = (type(GlobalEnv) == "table" and type(GlobalEnv.queue_on_teleport) == "function" and GlobalEnv.queue_on_teleport)
    or (type(synTbl) == "table" and type(synTbl.queue_on_teleport) == "function" and synTbl.queue_on_teleport)
    or (type(fluxusTbl) == "table" and type(fluxusTbl.queue_on_teleport) == "function" and fluxusTbl.queue_on_teleport)
    if type(qFn) == "function" and not Hub.TeleportQueued then
        Hub.TeleportQueued = true
        pcall(qFn, "if getgenv and getgenv().__ThaiCleanHubAutoLoadSource then loadstring(getgenv().__ThaiCleanHubAutoLoadSource)() end")
    end
end
function Hub.hopServer(mode)
    mode = mode or Config.ServerHopMode or "ผู้เล่นเยอะ"
    Hub.setupAutoLoadOnTeleport()
    notifyThai("กำลังค้นหาเซิร์ฟเวอร์ (" .. tostring(mode) .. ")...")
    task.spawn(function()
        local placeId = tonumber(game.PlaceId) or 0
        local currentJob = tostring(game.JobId or "")
        local chosenJob = nil
        if placeId > 0 and HttpService and type(HttpService.JSONDecode) == "function" then
            local sortOrder = mode == "ผู้เล่นน้อย" and "Asc" or "Desc"
            local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=%s&limit=100", placeId, sortOrder)
            local okHttp, rawBody = pcall(function()
                if type(game.HttpGet) == "function" then
                    return game:HttpGet(url)
                end
                return nil
            end)
            if okHttp and type(rawBody) == "string" and #rawBody > 0 then
                local okDec, decoded = pcall(HttpService.JSONDecode, HttpService, rawBody)
                if okDec and type(decoded) == "table" and type(decoded.data) == "table" then
                    local candidates = {}
                    for _, srv in ipairs(decoded.data) do
                        if type(srv) == "table" and type(srv.id) == "string" and srv.id ~= currentJob and (tonumber(srv.playing) or 0) < (tonumber(srv.maxPlayers) or 99) then
                            candidates[#candidates + 1] = srv
                        end
                    end
                    if mode == "ปิงต่ำ" then
                        table.sort(candidates, function(a, b)
                            return (tonumber(a.ping) or 9999) < (tonumber(b.ping) or 9999)
                        end)
                    elseif mode == "สุ่มเซิร์ฟเวอร์" and #candidates > 1 then
                        chosenJob = candidates[math.random(1, #candidates)].id
                    end
                    if not chosenJob and candidates[1] then
                        chosenJob = candidates[1].id
                    end
                end
            end
        end
        if chosenJob then
            pcall(function()
                TeleportService:TeleportToPlaceInstance(placeId, chosenJob, LocalPlayer)
            end)
        else
            pcall(function()
                TeleportService:Teleport(placeId, LocalPlayer)
            end)
            local token = Hub.Generation.AutoHopEnabled or 0
            Hub.rpc("AutoHopEnabled", token, "Homestead", "AskLobbyHop", "event")
            Hub.rpc("AutoHopEnabled", token, "IdleRescue", "AskRescueHop", "event")
        end
    end)
end
function Hub.joinJobId(targetJobId)
    local job = tostring(targetJobId or Config.TargetJobId or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if job == "" then
        notifyThai("กรุณากรอกรหัสเซิร์ฟเวอร์ก่อนกดเข้า")
        return false
    end
    Hub.setupAutoLoadOnTeleport()
    notifyThai("กำลังย้ายเข้าเซิร์ฟเวอร์รหัส " .. job)
    local ok = pcall(function()
        TeleportService:TeleportToPlaceInstance(tonumber(game.PlaceId) or 0, job, LocalPlayer)
    end)
    return ok
end
function Hub.copyCurrentJobId()
    local job = tostring(game.JobId or "")
    local clipFn = (type(GlobalEnv) == "table" and type(GlobalEnv.setclipboard) == "function" and GlobalEnv.setclipboard)
    or (type(GlobalEnv) == "table" and type(GlobalEnv.toclipboard) == "function" and GlobalEnv.toclipboard)
    if clipFn then
        pcall(clipFn, job)
        notifyThai("คัดลอกรหัสเซิร์ฟเวอร์ปัจจุบันแล้ว")
        return true
    end
    Config.TargetJobId = job
    notifyThai("บันทึกรหัสเซิร์ฟเวอร์ลงในช่องกรอกแล้ว")
    return false
end
function Hub.rejoinServer()
    Hub.setupAutoLoadOnTeleport()
    local placeId = tonumber(game.PlaceId) or 0
    local job = tostring(game.JobId or "")
    notifyThai("กำลังรีจอยเข้าเซิร์ฟเวอร์เดิมใหม่...")
    if job ~= "" then
        pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, job, LocalPlayer)
        end)
    else
        pcall(function()
            TeleportService:Teleport(placeId, LocalPlayer)
        end)
    end
end
function Hub.autoHopStep(records)
    if not Config.AutoHopEnabled then
        return
    end
    local now = TimeUtil.unixNow()
    if not Hub.LastAutoHopCheckAt then
        Hub.LastAutoHopCheckAt = now
    end
    local candidates = Hub.getSortedStealCandidates(records or {}, TimeUtil.clockNow())
    if #candidates > 0 then
        Hub.LastAutoHopCheckAt = now
        Hub.status("AutoHopEnabled", "confirmed", "พบไข่เป้าหมายในเซิร์ฟเวอร์นี้ " .. tostring(#candidates) .. " ฟอง")
        return
    end
    local waited = TimeUtil.diffSeconds(now, Hub.LastAutoHopCheckAt)
    local interval = tonumber(Config.AutoHopIntervalSeconds) or 30
    if waited >= interval then
        Hub.LastAutoHopCheckAt = now
        Hub.status("AutoHopEnabled", "confirmed", "ไม่พบไข่ตามเกณฑ์ครบเวลา กำลังย้ายเซิร์ฟเวอร์...")
        Hub.hopServer(Config.ServerHopMode)
    else
        Hub.status("AutoHopEnabled", "waiting", "ไม่พบไข่เป้าหมาย • รอย้ายเซิร์ฟใน " .. TimeUtil.formatDuration(interval - waited))
    end
end
function Hub.tick()
    if not IsScriptRunning then
        return
    end
    local now = os.clock()
    if now >= (Hub.NextModulePoll or 0) then
        Hub.NextModulePoll = now + 2
        Hub.loadModules()
        Hub.bindTreadmill()
    end
    Hub.syncPreferences()
    Hub.pollSnapshots()
    Hub.antiAFKStep()
    Hub.trapStep()
    for _, key in ipairs({
        "OptDisableParticles",
        "OptDisableShadowsAndPostFX",
        "OptSimplifyMaterials",
        "OptHideWorldDecorations",
        "OptMuteGameAudio",
    }) do
        if Config[key] then
            local count = (Hub.EffectCounts or {})[key] or 0
            Hub.status(key, count > 0 and "local" or "waiting", count > 0 and ("ปรับเฉพาะเครื่องเราแล้ว " .. tostring(count) .. " ค่า") or "ยังไม่พบวัตถุที่รองรับ รอฉากโหลด")
        end
    end
    local hum = getLocalHumanoid()
    if not hum or hum.Health <= 0 then
        Hub.restoreCharacterStats()
        Hub.acquire(nil)
        RuntimeState.CurrentTaskStatusText = "รอตัวละครเกิดใหม่"
        for key, value in pairs(Config) do
            if value == true and key:sub(1, 4) == "Auto" then
                Hub.status(key, "waiting", "รอตัวละครเกิดใหม่")
            end
        end
        updateConflictBadgesAndBanner()
        return
    end
    if Config.AutoStealEgg or Config.AutoAttack or Config.AutoTreadmill then
        Hub.fieldResetStep()
    end
    local save, carry = getPlayerSaveData(), Hub.carryState()
    if Config.AutoWispQuest then
        Hub.job("AutoWispQuest", 1.5, false, function(token)
            Hub.wispStep(token)
        end)
    end
    for _, evKey in ipairs({ "AutoBloom", "AutoShootingStar", "AutoFeedStar", "AutoBanjo", "AutoFishing", "AutoAlien", "AutoIslandWars" }) do
        if Config[evKey] then
            Hub.job(evKey, 1.5, false, function(token)
                Hub.worldEventsStep(token, evKey)
            end)
        end
    end
    for _, extKey in ipairs({ "AutoGhostDogQuest", "AutoSubZones", "AutoPetWheel", "AutoRiftAndScramble" }) do
        if Config[extKey] then
            Hub.job(extKey, 1.8, false, function(token)
                Hub.extendedWorldStep(token, extKey)
            end)
        end
    end
    for _, admKey in ipairs({ "AutoAdminAbuse", "AutoBeanstalk", "AutoLightVsDark", "AutoSammy", "AutoBossRaid", "AutoMinigameEvents" }) do
        if Config[admKey] then
            Hub.job(admKey, 1.8, false, function(token)
                Hub.adminAbuseStep(token, admKey)
            end)
        end
    end
    Hub.playerMovementStep()
    if os.clock() >= (Hub.NextRun.Predictors or 0) then
        Hub.NextRun.Predictors = os.clock() + 1.0
        if Hub.updatePredictorsAndFinder then
            pcall(Hub.updatePredictorsAndFinder, false)
        end
    end
    Hub.treadmillStep()
    Hub.ragdollStep()
    if Hub.hidePlayerStep(carry) then
        updateConflictBadgesAndBanner()
        return
    end
    local needsTarget = Config.AutoStealEgg
    local needsField = needsTarget or Config.AutoAttack or Config.EggESP or Config.OwnBaseEggESP or Config.RevealEggContent100 or CurrentTabName == "ฟาร์ม"
    local records, uid, best = needsField and getFieldEggRecords() or {}, nil, nil
    if Config.AutoPlaceEgg and now >= (Hub.PlaceBlockedUntil or 0) then
        if Hub.Jobs.AutoPlaceEgg then
            uid = true
        else
            local queue, _, free = Hub.placeQueue(save)
            if free > 0 and queue[1] then
                uid = queue[1].Uid
            end
        end
    end
    local root = getLocalRoot()
    if needsTarget then
        if Hub.FieldResetting then
            Hub.status("AutoStealEgg", "waiting", "รอไข่รอบใหม่และกำแพงเปิด")
        elseif root and carry and not carry.IsCarrying then
            best = Hub.selectStealEgg(records, now)
        end
    end
    Hub.StealTargetUid = best and best.Uid or nil
    local target = (Config.AutoAttack or Config.AutoChaseCarrier) and Hub.targetPlayer(records) or nil
    if Config.AutoChaseCarrier and not Config.AutoAttack and target then
        Config.AttackMode = "ไปตีผู้เล่นที่ถือไข่"
        Hub.status("AutoChaseCarrier", "confirmed", "กำลังไล่ล่าผู้เล่นที่ถือไข่เป้าหมาย")
    elseif Config.AutoChaseCarrier and not target then
        Hub.status("AutoChaseCarrier", "waiting", "รอผู้เล่นอื่นถือไข่เป้าหมายในสนาม")
    end
    Hub.updateRecovery(records, carry, target)
    if Hub.Pursuit then
        target = Hub.PursuitTarget
    end
    Hub.IntentionalAttackTarget = Config.AutoAttack and Config.AttackMode == "ไปตีผู้เล่นที่ถือไข่" and target or nil
    if carry and carry.IsCarrying then
        best = nil
        Hub.StealTargetUid = nil
    end
    local carryingRecord = Hub.CarryCycle and Hub.CarryCycle.Record
    if carry and carry.IsCarrying and not carryingRecord then
        for _, record in pairs(records) do
            if record.Uid == carry.Uid then
                carryingRecord = record
                break
            end
        end
    end
    if carry and carry.IsCarrying then
        Hub.MotionTarget = carryingRecord
    else
        Hub.MotionTarget = Hub.RecoveryEgg or best or (Hub.Pursuit and Hub.Pursuit.Record)
    end
    Hub.moveStep(save, carry, uid, best, target)
    Hub.inventoryStep(save)
    Hub.otherStep(save, carry, target)
    Hub.autoHopStep(records)
    Hub.refreshMotionNumbers()
    if Hub.refreshStealPanel then
        Hub.refreshStealPanel(records)
    end
    updateConflictBadgesAndBanner()
end
connectSignal(LocalPlayer.CharacterRemoving, function(char)
    if Hub.DeliveryStop and Hub.DeliveryStop.Character == char then
        Hub.stopDeliveryStop()
    end
    local hidden = Hub.HiddenPlayer
    if hidden and hidden.Character == char then
        Hub.restoreHiddenPlayer()
        if Config.HidePlayer and os.clock() - hidden.StartedAt < 2 then
            Config.HidePlayer = false
            syncAllFeatureStates("HidePlayer")
            Hub.fail("HidePlayer", "ตัวละครเปลี่ยนทันทีหลังส่งคำสั่งซ่อน")
        end
    end
    if Hub.HiddenPlayerUsed == char then
        Hub.HiddenPlayerUsed = nil
    end
    if Hub.RagdollRigConnection then
        Hub.RagdollRigConnection:Disconnect()
        Hub.RagdollRigConnection = nil
    end
    Hub.CharacterMutation, Hub.PreviousVelocity = nil, nil
    Hub.funReset()
    Hub.acquire(nil)
    RuntimeState.IsCurrentlyOnTreadmill = false
    Hub.TreadmillSessionVersion = (Hub.TreadmillSessionVersion or 0) + 1
    Hub.TreadmillAutoRequest, Hub.TreadmillAuto, Hub.TreadmillId, Hub.TreadmillEnteredAt = nil, nil, nil, nil
    Hub.TreadmillManualExit, Hub.TreadmillJumpUntil, Hub.RequestedTreadmillExit = nil, nil, nil
    Hub.DoffBusy, Hub.ManualBeltApproachUntil = nil, nil
    Hub.restoreFallStates()
    Hub.ExitTarget = nil
    Hub.Evasion = nil
    Hub.RecoveryEgg = nil
    Hub.RecoveryCarry = nil
    Hub.CarryCycle, Hub.ReturnGoal, Hub.Pursuit, Hub.MotionTarget, Hub.CarryDropTarget = nil, nil, nil, nil, nil
    Hub.GuardThreat, Hub.MotionRequiredSpeed = nil, nil
    Hub.StealEntry, Hub.PenExit, Hub.StealPickupUntil = nil, nil, nil
    Hub.TreadmillTurnUntil, Hub.TreadmillDueAt, Hub.TreadmillAfterSteal = nil, nil, nil
    Hub.LastMovementCorrection = nil
    if Hub.restoreCharacterStats then
        Hub.restoreCharacterStats()
    end
    for key in pairs(Hub.Generation) do
        Hub.Generation[key] = Hub.Generation[key] + 1
    end
end)
Hub.bindTreadmill()
task.spawn(function()
    local scripts = LocalPlayer:FindFirstChildOfClass("PlayerScripts")
    local module = scripts and scripts:WaitForChild("PlayerModule", 5)
    if not module then
        return
    end
    local ok, controls = pcall(function()
        return require(module):GetControls()
    end)
    if ok and type(controls) == "table" and type(controls.GetMoveVector) == "function" then
        Hub.TreadmillControls = controls
    end
end)
connectSignal(UserInputService.JumpRequest, function()
    Hub.treadmillJump()
    if Config.InfiniteJump then
        local hum = getLocalHumanoid()
        if hum and hum.Health > 0 then
            pcall(function()
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end)
        end
    end
end)
if TeleportService then
    pcall(function()
        connectSignal(TeleportService.TeleportInitFailed, function()
            if Config.AutoRejoinOnDisconnect and IsScriptRunning and Hub.rejoinServer then
                task.delay(2, function()
                    if IsScriptRunning and Config.AutoRejoinOnDisconnect and Hub.rejoinServer then
                        Hub.rejoinServer()
                    end
                end)
            end
        end)
    end)
end
connectSignal(UserInputService.InputBegan, function(input)
    if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then
        Hub.treadmillJump()
    end
end)
task.spawn(function()
    while IsScriptRunning do
        local ok, err = pcall(Hub.tick)
        if not ok then
            Hub.fail("Scheduler", err)
        end
        task.wait(0.2)
    end
end)
local function getPresetColor(colorName)
    for _, p in ipairs(COLOR_PRESETS) do
        if p.name == colorName then
            return p.color
        end
    end
    return Color3.fromRGB(16, 185, 129)
end
local function createTrackerLine()
    local line = Instance.new("Frame")
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
    line.BorderSizePixel = 0
    line.Visible = false
    line.ZIndex = 2
    line.Parent = RenderLayer
    return line
end
local function updateTrackerLine(lineFrame, fromScreen, toScreen, color)
    local delta = toScreen - fromScreen
    local dist = delta.Magnitude
    if dist < 2 then
        lineFrame.Visible = false
        return
    end
    local mid = (fromScreen + toScreen) * 0.5
    local angle = math.deg(math.atan2(delta.Y, delta.X))
    lineFrame.Position = UDim2.fromOffset(mid.X, mid.Y)
    lineFrame.Size = UDim2.fromOffset(dist, 1.8)
    lineFrame.Rotation = angle
    lineFrame.BackgroundColor3 = color
    lineFrame.Visible = true
end
connectSignal(Players.PlayerRemoving, clearPlayerESP)
function Hub.renderRecords()
    local records = {}
    if Config.EggESP or Config.RevealEggContent100 then
        for _, record in pairs(getFieldEggRecords()) do
            table.insert(records, record)
        end
    end
    if Config.OwnBaseEggESP then
        local save, plot = getPlayerSaveData(), findLocalPlotFallback()
        if save and plot then
            for uid, record in pairs(save.EggInventory or {}) do
                if type(record) == "table" and record.Placement and record.Placement.LocalCFrame then
                    local localCF = record.Placement.LocalCFrame
                    if typeof(localCF) ~= "CFrame" and type(localCF) == "table" then
                        localCF = CFrame.new(table.unpack(localCF, 1, 12))
                    end
                    local clone = table.clone(record)
                    clone.Uid = "owned:" .. tostring(uid)
                    clone.AreaId = "Home"
                    clone.State = "Slot"
                    clone.IsOwnedPlaced = true
                    clone.BottomCFrame = plot.CenterPoint.CFrame * localCF
                    clone.BoundsCFrame = clone.BottomCFrame
                    table.insert(records, clone)
                end
            end
        end
    end
    return records
end
function Hub.renderGuards(cam, myRoot, viewportCenterBottom)
    if not Config.GuardESP then
        clearAllGuardESP()
        return
    end
    local areas = Hub.fieldAreas()
    local guardAreas = areas and areas:FindFirstChild("GuardAreas")
    if not guardAreas then
        clearAllGuardESP()
        Hub.status("GuardESP", "waiting", "รอข้อมูลโซนยามในสนามโหลด")
        return
    end
    local activeGuards = {}
    local guardCount = 0
    for _, area in ipairs(guardAreas:GetChildren()) do
        local guard = area:FindFirstChild("Guard")
        local gRoot = guard and guard:FindFirstChild("HumanoidRootPart")
        if guard and gRoot and gRoot:IsA("BasePart") and guard:GetAttribute("Hidden") ~= true then
            activeGuards[guard] = true
            guardCount = guardCount + 1
            local entry = GuardESPVisuals[guard]
            if not entry then
                local bb = Instance.new("BillboardGui")
                bb.Name = "ThaiGuardESP"
                bb.Size = UDim2.fromOffset(200, 56)
                bb.StudsOffset = Vector3.new(0, 4.2, 0)
                bb.AlwaysOnTop = true
                bb.Parent = ESPFolder
                local txt = Instance.new("TextLabel")
                txt.Size = UDim2.fromScale(1, 1)
                txt.BackgroundTransparency = 1
                txt.Font = getCurrentFont()
                txt.TextSize = 13 * Config.FontSize / 14
                txt.TextStrokeTransparency = 0.2
                txt.RichText = true
                txt.TextWrapped = true
                txt.Parent = bb
                local hl = Instance.new("Highlight")
                hl.Name = "ThaiGuardHighlight"
                hl.Adornee = guard
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillTransparency = 0.55
                hl.OutlineTransparency = 0.1
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.Parent = guard
                entry = {
                    Billboard = bb,
                    Label = txt,
                    Line = createTrackerLine(),
                    Highlight = hl,
                }
                GuardESPVisuals[guard] = entry
            end
            entry.Billboard.Adornee = gRoot
            local stateAttr = tostring(guard:GetAttribute("State") or guard:GetAttribute("AIState") or "")
            local spd = gRoot.AssemblyLinearVelocity.Magnitude
            local isChasing = stateAttr:lower():find("chase") or stateAttr:lower():find("attack") or spd > 18
            local guardColor = isChasing and Color3.fromRGB(239, 68, 68) or Color3.fromRGB(245, 158, 11)
            if entry.Highlight then
                entry.Highlight.FillColor = guardColor
            end
            local areaThai = AREA_THAI_BY_ID[area.Name] or area.Name
            local lines = { "<b>ยาม • " .. areaThai .. "</b>" }
            local sub = {}
            if Config.GuardShowState then
                table.insert(sub, isChasing and "กำลังไล่ล่า!" or "เดินตรวจการณ์")
            end
            if Config.GuardShowDistance and myRoot then
                local d = math.round((gRoot.Position - myRoot.Position).Magnitude)
                table.insert(sub, tostring(d) .. " สตัด")
            end
            if #sub > 0 then
                table.insert(lines, table.concat(sub, " • "))
            end
            entry.Label.TextColor3 = guardColor
            entry.Label.Font = getCurrentFont()
            entry.Label.TextSize = 13 * Config.FontSize / 14
            entry.Label.Text = table.concat(lines, "\n")
            entry.Billboard.Enabled = true
            if Config.GuardTracker and cam then
                local screenPt, onScreen = cam:WorldToViewportPoint(gRoot.Position)
                if onScreen then
                    updateTrackerLine(entry.Line, viewportCenterBottom, Vector2.new(screenPt.X, screenPt.Y), guardColor)
                else
                    entry.Line.Visible = false
                end
            else
                entry.Line.Visible = false
            end
        end
    end
    for guardObj in pairs(GuardESPVisuals) do
        if not activeGuards[guardObj] then
            clearGuardESP(guardObj)
        end
    end
    Hub.status("GuardESP", "local", "แสดงตำแหน่งยามในสนามแล้ว " .. tostring(guardCount) .. " ตัว")
end
function Hub.renderLostParts(cam, myRoot, viewportCenterBottom)
    if not Config.LostPartESP then
        clearAllLostPartESP()
        return
    end
    local world = Workspace:FindFirstChild("World")
    local folder = (world and world:FindFirstChild("DrScrambleEvent")) or Workspace:FindFirstChild("DrScrambleEvent")
    if not folder then
        clearAllLostPartESP()
        Hub.status("LostPartESP", "waiting", "ยังไม่พบชิ้นส่วนกิจกรรมในฉากขณะนี้")
        return
    end
    local activeParts = {}
    local count = 0
    local partColor = Color3.fromRGB(56, 189, 248)
    for _, item in ipairs(folder:GetChildren()) do
        local part = item:IsA("BasePart") and item or (item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart", true)))
        if part and part.Parent then
            activeParts[item] = true
            count = count + 1
            local entry = LostPartESPVisuals[item]
            if not entry then
                local bb = Instance.new("BillboardGui")
                bb.Name = "ThaiLostPartESP"
                bb.Size = UDim2.fromOffset(200, 48)
                bb.StudsOffset = Vector3.new(0, 3.2, 0)
                bb.AlwaysOnTop = true
                bb.Parent = ESPFolder
                local txt = Instance.new("TextLabel")
                txt.Size = UDim2.fromScale(1, 1)
                txt.BackgroundTransparency = 1
                txt.Font = getCurrentFont()
                txt.TextSize = 13 * Config.FontSize / 14
                txt.TextStrokeTransparency = 0.2
                txt.RichText = true
                txt.TextWrapped = true
                txt.Parent = bb
                local hl = Instance.new("Highlight")
                hl.Name = "ThaiLostPartHighlight"
                hl.Adornee = item
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillColor = partColor
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.5
                hl.OutlineTransparency = 0.1
                hl.Parent = item
                entry = {
                    Billboard = bb,
                    Label = txt,
                    Line = createTrackerLine(),
                    Highlight = hl,
                }
                LostPartESPVisuals[item] = entry
            end
            entry.Billboard.Adornee = part
            local d = myRoot and math.round((part.Position - myRoot.Position).Magnitude) or 0
            entry.Label.TextColor3 = partColor
            entry.Label.Font = getCurrentFont()
            entry.Label.TextSize = 13 * Config.FontSize / 14
            entry.Label.Text = "<b>ชิ้นส่วนที่หายไป</b>\n" .. tostring(d) .. " สตัด"
            entry.Billboard.Enabled = true
            if Config.LostPartTracker and cam then
                local screenPt, onScreen = cam:WorldToViewportPoint(part.Position)
                if onScreen then
                    updateTrackerLine(entry.Line, viewportCenterBottom, Vector2.new(screenPt.X, screenPt.Y), partColor)
                else
                    entry.Line.Visible = false
                end
            else
                entry.Line.Visible = false
            end
        end
    end
    for obj in pairs(LostPartESPVisuals) do
        if not activeParts[obj] then
            clearLostPartESP(obj)
        end
    end
    Hub.status("LostPartESP", count > 0 and "local" or "waiting", count > 0 and ("แสดงชิ้นส่วนที่หายไปแล้ว " .. tostring(count) .. " ชิ้น") or "ยังไม่พบชิ้นส่วนที่หายไปในฉากขณะนี้")
end
function Hub.clearTrapESP()
    for object, entry in pairs(Hub.TrapVisuals) do
        if entry.Billboard then
            entry.Billboard:Destroy()
        end
        if entry.Highlight then
            entry.Highlight:Destroy()
        end
        if entry.Anchor then
            entry.Anchor:Destroy()
        end
        Hub.TrapVisuals[object] = nil
    end
end
function Hub.renderTraps()
    if not Config.TrapESP then
        Hub.clearTrapESP()
        return
    end
    local root, active = getLocalRoot(), {}
    local traps = Hub.trapRecords()
    for _, trap in ipairs(traps) do
        active[trap.Object] = true
        local entry = Hub.TrapVisuals[trap.Object]
        if not entry then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ThaiTrapESP"
            billboard.Size = UDim2.fromOffset(240, 56)
            billboard.StudsOffset = Vector3.new(0, 4, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = ESPFolder
            local label = Instance.new("TextLabel")
            label.Size = UDim2.fromScale(1, 1)
            label.BackgroundTransparency = 1
            label.TextStrokeTransparency = 0.15
            label.TextColor3 = Color3.fromRGB(255, 185, 70)
            label.TextWrapped = true
            label.Parent = billboard
            local highlight = Instance.new("Highlight")
            highlight.Name = "ThaiTrapHighlight"
            highlight.Adornee = trap.Object
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.FillTransparency = 0.65
            highlight.FillColor = Color3.fromRGB(255, 80, 50)
            highlight.OutlineColor = Color3.fromRGB(255, 200, 80)
            highlight.Parent = trap.Object
            entry = { Billboard = billboard, Label = label, Highlight = highlight }
            Hub.TrapVisuals[trap.Object] = entry
        end
        if Config.AntiTrap then
            if not entry.Anchor then
                local anchor = Instance.new("Part")
                anchor.Name, anchor.Anchored, anchor.Transparency = "ThaiTrapMarker", true, 1
                anchor.CanCollide, anchor.CanTouch, anchor.CanQuery = false, false, false
                anchor.Size, anchor.Parent = Vector3.new(0.1, 0.1, 0.1), ESPFolder
                entry.Anchor = anchor
            end
            entry.Anchor.CFrame = CFrame.new(trap.Position)
            entry.Billboard.Adornee = entry.Anchor
            entry.Highlight.Enabled = false
        else
            if entry.Anchor then
                entry.Anchor:Destroy()
                entry.Anchor = nil
            end
            entry.Billboard.Adornee = trap.Part
            entry.Highlight.Enabled = true
        end
        entry.Label.Font = getCurrentFont()
        entry.Label.TextSize = 13 * Config.FontSize / 14
        local owner = trap.Object:GetAttribute("Owner") or trap.Object:GetAttribute("OwnerUserId")
        local distance = root and math.round(Hub.distance(root.Position, trap.Position)) or 0
        entry.Label.Text = trap.Kind.. (owner and (" • " .. tostring(owner)) or "").. "\n".. tostring(distance).. " สตัด"
    end
    for object, entry in pairs(Hub.TrapVisuals) do
        if not active[object] then
            entry.Billboard:Destroy()
            entry.Highlight:Destroy()
            if entry.Anchor then
                entry.Anchor:Destroy()
            end
            Hub.TrapVisuals[object] = nil
        end
    end
    Hub.status("TrapESP", "local", "แสดงกับดักที่โหลดแล้ว ".. tostring(#traps).. " จุด")
end
local RARITY_ESP_COLORS = {
    Common = Color3.fromRGB(220, 225, 235),
    Uncommon = Color3.fromRGB(74, 222, 128),
    Rare = Color3.fromRGB(56, 189, 248),
    Epic = Color3.fromRGB(192, 132, 252),
    Legendary = Color3.fromRGB(250, 204, 21),
    Mythic = Color3.fromRGB(248, 113, 113),
    Divine = Color3.fromRGB(244, 114, 182),
    Secret = Color3.fromRGB(45, 212, 191),
}
Hub.LastRenderAt = -math.huge
connectSignal(RunService.RenderStepped, function()
    if os.clock() - Hub.LastRenderAt < 0.1 then
        return
    end
    Hub.LastRenderAt = os.clock()
    Hub.renderTraps()
    local cam = Workspace.CurrentCamera
    local myRoot = getLocalRoot()
    if not cam then
        return
    end
    local viewportCenterBottom = Vector2.new(cam.ViewportSize.X * 0.5, cam.ViewportSize.Y * 0.88)
    Hub.renderGuards(cam, myRoot, viewportCenterBottom)
    Hub.renderLostParts(cam, myRoot, viewportCenterBottom)
    local activeEggUids, activePrompts = {}, {}
    if Config.EggESP or Config.OwnBaseEggESP or Config.RevealEggContent100 then
        local records = Hub.renderRecords()
        local clientSlotsFolder = Workspace:FindFirstChild("AreaEggSlotsClient")
        local presetEggColor = getPresetColor(Config.EggESPColorName)
        local sizeScale = math.clamp((tonumber(Config.EggESPSizePercent) or 100) / 100, 0.5, 2.0)
        for _, rec in ipairs(records) do
            if type(rec.Uid) == "string" and (rec.State == "Slot" or rec.State == "Dropped") and (rec.IsOwnedPlaced or passesESPFilter(rec)) then
                local uid = rec.Uid
                activeEggUids[uid] = true
                local model = (clientSlotsFolder and clientSlotsFolder:FindFirstChild(uid)) or Workspace:FindFirstChild(uid)
                local worldPos = (rec.BoundsCFrame and rec.BoundsCFrame.Position) or (rec.BottomCFrame and rec.BottomCFrame.Position)
                if Config.RevealEggContent100 and model then
                    local prompt = model:FindFirstChild("CarryAreaEgg", true)
                    if prompt and prompt:IsA("ProximityPrompt") then
                        activePrompts[prompt] = true
                        if not ModifiedPrompts[prompt] then
                            ModifiedPrompts[prompt] = { ObjectText = prompt.ObjectText, ActionText = prompt.ActionText }
                        end
                        prompt.ObjectText = getSpeciesThaiName(rec.AssetCategory).. " (".. getMutationThaiString(rec.Mutations, rec.BaseMutation).. ")"
                        prompt.ActionText = "ขโมยไข่"
                    end
                end
                local entry = EggESPVisuals[uid]
                if not entry then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "ThaiCleanESPBillboard"
                    bb.Size = UDim2.fromOffset(math.round(230 * sizeScale), math.round(86 * sizeScale))
                    bb.StudsOffset = Vector3.new(0, 3.8, 0)
                    bb.AlwaysOnTop = true
                    bb.Parent = ESPFolder
                    local txt = Instance.new("TextLabel")
                    txt.Size = UDim2.fromScale(1, 1)
                    txt.BackgroundTransparency = 1
                    txt.Font = getCurrentFont()
                    txt.TextSize = math.round(13 * (Config.FontSize / 14) * sizeScale)
                    txt.TextStrokeTransparency = 0.2
                    txt.RichText = true
                    txt.TextWrapped = true
                    txt.Parent = bb
                    entry = {
                        Billboard = bb,
                        Label = txt,
                        Line = createTrackerLine(),
                        Highlight = nil,
                        AnchorPart = nil,
                    }
                    EggESPVisuals[uid] = entry
                else
                    entry.Billboard.Size = UDim2.fromOffset(math.round(230 * sizeScale), math.round(86 * sizeScale))
                end
                local targetAdornee = nil
                if model and model:IsA("Model") then
                    targetAdornee = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
                end
                if not targetAdornee and worldPos then
                    if not entry.AnchorPart then
                        local ap = Instance.new("Part")
                        ap.Name = "ThaiESPAnchor"
                        ap.Size = Vector3.new(0.2, 0.2, 0.2)
                        ap.Transparency = 1
                        ap.Anchored = true
                        ap.CanCollide = false
                        ap.CanQuery = false
                        ap.CanTouch = false
                        ap.Parent = Workspace
                        entry.AnchorPart = ap
                    end
                    entry.AnchorPart.Position = worldPos
                    targetAdornee = entry.AnchorPart
                end
                entry.Billboard.Adornee = targetAdornee
                local rarityInfo = getEggRarityInfo(rec.AssetCategory)
                local eggColor = (Config.EggHighlightMode == "ตามสีความหายาก") and (RARITY_ESP_COLORS[rarityInfo.id] or presetEggColor) or presetEggColor
                local showVisualESP = (rec.IsOwnedPlaced and Config.OwnBaseEggESP) or (not rec.IsOwnedPlaced and Config.EggESP)
                local allowHighlight = showVisualESP and Config.EggHighlightMode ~= "ปิดกรอบเรืองแสง"
                if model and model:IsA("Model") then
                    if allowHighlight then
                        if not entry.Highlight or entry.Highlight.Parent ~= model then
                            if entry.Highlight then
                                pcall(function()
                                    entry.Highlight:Destroy()
                                end)
                            end
                            local hl = Instance.new("Highlight")
                            hl.Name = "ThaiEggESPHighlight"
                            hl.FillColor = eggColor
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.55
                            hl.OutlineTransparency = 0.1
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.Parent = model
                            entry.Highlight = hl
                        else
                            entry.Highlight.FillColor = eggColor
                        end
                    elseif entry.Highlight then
                        pcall(function()
                            entry.Highlight:Destroy()
                        end)
                        entry.Highlight = nil
                    end
                end
                local lines = {}
                local thaiSpecies = getSpeciesThaiName(rec.AssetCategory)
                local mutText = getMutationThaiString(rec.Mutations, rec.BaseMutation)
                local metrics = Hub.eggFarmMetrics(rec)
                local weightKg = getEggWeightKg(rec.AssetCategory, metrics.Scale)
                local distMeters = myRoot and worldPos and math.round((worldPos - myRoot.Position).Magnitude) or 0
                if Config.RevealEggContent100 or (showVisualESP and Config.EggShowName) then
                    local prefix = rec.IsOwnedPlaced and "[ในคอก] " or ""
                    table.insert(lines, "<b>" .. prefix .. thaiSpecies .. "</b>")
                end
                if showVisualESP then
                    local subParts = {}
                    if Config.EggShowRarity then
                        table.insert(subParts, rarityInfo.name)
                    end
                    if Config.EggShowMutation then
                        table.insert(subParts, mutText)
                    end
                    if Config.EggShowArea then
                        table.insert(subParts, AREA_THAI_BY_ID[rec.AreaId] or tostring(rec.AreaId or ""))
                    end
                    if #subParts > 0 then
                        table.insert(lines, table.concat(subParts, " • "))
                    end
                    local econParts = {}
                    if Config.EggShowIncome then
                        table.insert(econParts, "รายได้ " .. formatCompactThaiNumber(metrics.Income) .. "/วินาที")
                    end
                    if Config.EggShowValue then
                        local asset = AssetsData and AssetsData.Directory and AssetsData.Directory[rec.AssetCategory]
                        local basePrice = tonumber(asset and (asset.Price or asset.Value)) or (metrics.Income * 25)
                        table.insert(econParts, "มูลค่า " .. formatCompactThaiNumber(basePrice))
                    end
                    if #econParts > 0 then
                        table.insert(lines, table.concat(econParts, " • "))
                    end
                    local metricParts = {}
                    if Config.EggShowWeight then
                        table.insert(metricParts, (weightKg and tostring(math.round(weightKg * 100) / 100) or "?").. " กก.")
                    end
                    if Config.EggShowDistance then
                        table.insert(metricParts, tostring(distMeters) .. " สตัด")
                    end
                    if #metricParts > 0 then
                        table.insert(lines, table.concat(metricParts, " | "))
                    end
                elseif Config.RevealEggContent100 then
                    table.insert(lines, rarityInfo.name .. " • " .. mutText)
                end
                entry.Label.TextColor3 = eggColor
                entry.Label.Font = getCurrentFont()
                entry.Label.TextSize = math.round(13 * (Config.FontSize / 14) * sizeScale)
                entry.Label.Text = table.concat(lines, "\n")
                entry.Billboard.Enabled = (#lines > 0) and (entry.Billboard.Adornee ~= nil)
                if showVisualESP and Config.EggTracker and not rec.IsOwnedPlaced and worldPos then
                    local screenPt, onScreen = cam:WorldToViewportPoint(worldPos)
                    if onScreen then
                        updateTrackerLine(entry.Line, viewportCenterBottom, Vector2.new(screenPt.X, screenPt.Y), eggColor)
                    else
                        entry.Line.Visible = false
                    end
                else
                    entry.Line.Visible = false
                end
            end
        end
        if Config.RevealEggContent100 then
            local saveData = getPlayerSaveData()
            local eggInv = saveData and saveData.EggInventory
            if type(eggInv) == "table" then
                local function revealEggToolsInContainer(container)
                    if not container then
                        return
                    end
                    for _, tool in ipairs(container:GetChildren()) do
                        if tool:IsA("Tool") and tool:GetAttribute("ItemType") == "AssetEgg" then
                            local uid = tool:GetAttribute("UID")
                            local rec = uid and eggInv[uid]
                            if rec and rec.AssetCategory then
                                if ModifiedEggToolNames[tool] == nil then
                                    ModifiedEggToolNames[tool] = tool.Name
                                end
                                local trueName = "ไข่: ".. getSpeciesThaiName(rec.AssetCategory).. " (".. getMutationThaiString(rec.Mutations, rec.BaseMutation).. ")"
                                if tool.Name ~= trueName then
                                    tool.Name = trueName
                                end
                            end
                        end
                    end
                end
                revealEggToolsInContainer(LocalPlayer:FindFirstChild("Backpack"))
                revealEggToolsInContainer(LocalPlayer.Character)
            end
        end
    end
    for prompt, original in pairs(ModifiedPrompts) do
        if not activePrompts[prompt] then
            pcall(function()
                if prompt.Parent then
                    prompt.ObjectText = original.ObjectText
                    prompt.ActionText = original.ActionText
                end
            end)
            ModifiedPrompts[prompt] = nil
        end
    end
    for uid in pairs(EggESPVisuals) do
        if not activeEggUids[uid] then
            clearEggESP(uid)
        end
    end
    if Config.PlayerESP then
        local plrColor = getPresetColor(Config.PlayerESPColorName)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local char = plr.Character
                local pRoot = char and char:FindFirstChild("HumanoidRootPart")
                local pHum = char and char:FindFirstChildOfClass("Humanoid")
                if char and pRoot and pHum and pHum.Health > 0 then
                    local entry = PlayerESPVisuals[plr]
                    if not entry then
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "ThaiCleanPlayerESP"
                        bb.Size = UDim2.fromOffset(200, 64)
                        bb.StudsOffset = Vector3.new(0, 3.5, 0)
                        bb.AlwaysOnTop = true
                        bb.Parent = ESPFolder
                        local txt = Instance.new("TextLabel")
                        txt.Size = UDim2.fromScale(1, 1)
                        txt.BackgroundTransparency = 1
                        txt.Font = getCurrentFont()
                        txt.TextSize = 13 * Config.FontSize / 14
                        txt.TextStrokeTransparency = 0.25
                        txt.RichText = true
                        txt.TextWrapped = true
                        txt.Parent = bb
                        entry = {
                            Billboard = bb,
                            Label = txt,
                            Line = createTrackerLine(),
                            Highlight = nil,
                        }
                        PlayerESPVisuals[plr] = entry
                    end
                    entry.Billboard.Adornee = pRoot
                    if not entry.Highlight or entry.Highlight.Parent ~= char then
                        if entry.Highlight then
                            pcall(function()
                                entry.Highlight:Destroy()
                            end)
                        end
                        local hl = Instance.new("Highlight")
                        hl.Name = "ThaiPlayerESPHighlight"
                        hl.FillColor = plrColor
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.6
                        hl.OutlineTransparency = 0.1
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = char
                        entry.Highlight = hl
                    else
                        entry.Highlight.FillColor = plrColor
                    end
                    local lines = {}
                    if Config.PlayerShowName then
                        table.insert(lines, "<b>" .. plr.DisplayName .. "</b>")
                    end
                    local metrics = {}
                    if Config.PlayerShowDistance and myRoot then
                        table.insert(metrics, tostring(math.round((pRoot.Position - myRoot.Position).Magnitude)).. " สตัด")
                    end
                    if Config.PlayerShowSpeed then
                        local spd = math.round(pRoot.AssemblyLinearVelocity.Magnitude)
                        table.insert(metrics, "ความเร็ว ".. tostring(spd).. " สตัด/วินาที")
                    end
                    if #metrics > 0 then
                        table.insert(lines, table.concat(metrics, " | "))
                    end
                    if Config.PlayerShowStatus then
                        local statusText = "ปกติ"
                        if char:GetAttribute("IsTrapped") == true then
                            statusText = "ติดกับดัก"
                        else
                            for _, t in ipairs(char:GetChildren()) do
                                if t:IsA("Tool") then
                                    if t:GetAttribute("ItemType") == "AssetEgg" then
                                        statusText = "กำลังถือไข่"
                                    else
                                        statusText = "ถืออาวุธ"
                                    end
                                    break
                                end
                            end
                        end
                        table.insert(lines, "สถานะ: " .. statusText)
                    end
                    entry.Label.TextColor3 = plrColor
                    entry.Label.Font = getCurrentFont()
                    entry.Label.TextSize = 13 * Config.FontSize / 14
                    entry.Label.Text = table.concat(lines, "\n")
                    entry.Billboard.Enabled = (#lines > 0)
                    if Config.PlayerTracker then
                        local screenPt, onScreen = cam:WorldToViewportPoint(pRoot.Position)
                        if onScreen then
                            updateTrackerLine(entry.Line, viewportCenterBottom, Vector2.new(screenPt.X, screenPt.Y), plrColor)
                        else
                            entry.Line.Visible = false
                        end
                    else
                        entry.Line.Visible = false
                    end
                else
                    clearPlayerESP(plr)
                end
            end
        end
    end
    if Config.EggESP then
        Hub.status("EggESP", "local", "แสดงตำแหน่งไข่ในสนามที่ผ่านตัวกรองแล้ว")
    end
    if Config.OwnBaseEggESP then
        Hub.status("OwnBaseEggESP", "local", "แสดงข้อมูลไข่ที่วางในคอกของเราแล้ว")
    end
    if Config.PlayerESP then
        Hub.status("PlayerESP", "local", "แสดงตำแหน่งผู้เล่นที่มีชีวิตแล้ว")
    end
    if Config.RevealEggContent100 then
        Hub.status("RevealEggContent100", "local", "แสดงข้อมูลไข่จริงที่เซิร์ฟเวอร์ส่งมาแล้ว")
    end
end)
function Hub.stopAll()
    if Hub.restoreCharacterStats then
        Hub.restoreCharacterStats()
    end
    for key, value in pairs(Config) do
        if type(value) == "boolean" and not SUB_SETTING_TOGGLES[key] then
            Config[key] = false
        end
    end
    syncAllFeatureStates()
    Hub.funReset()
    for _, cb in ipairs(UIRefreshCallbacks) do
        Hub.refreshCallback(cb)
    end
end
function Hub.cleanup()
    if not IsScriptRunning then
        return
    end
    Hub.stopAll()
    Hub.funReset()
    Hub.antiAFKRestore()
    if Hub.RagdollRigConnection then
        Hub.RagdollRigConnection:Disconnect()
        Hub.RagdollRigConnection = nil
    end
    if Hub.clearNavigation then
        Hub.clearNavigation()
    end
    if Hub.restoreFallStates then
        Hub.restoreFallStates()
    end
    if Hub.clearTrapESP then
        Hub.clearTrapESP()
    end
    Hub.ExitTarget = nil
    IsScriptRunning = false
    Hub.acquire(nil)
    for key in pairs(Hub.Effects) do
        Hub.restore(key)
    end
    for pref, value in pairs(Hub.PreferenceOriginal) do
        if pref ~= Hub.PreferenceBusyKey and Preferences and Preferences.Set then
            task.spawn(function()
                pcall(Preferences.Set, pref, value)
            end)
        end
    end
    if Hub.TreadmillAuto then
        Hub.doffTreadmill()
    end
    pcall(clearAllEggESP)
    pcall(clearAllPlayerESP)
    pcall(clearAllGuardESP)
    pcall(clearAllLostPartESP)
    for _, conn in ipairs(ActiveConnections) do
        pcall(function()
            conn:Disconnect()
        end)
    end
    table.clear(ActiveConnections)
    if BlurEffect then
        BlurEffect:Destroy()
        BlurEffect = nil
    end
    if ScreenGui then
        ScreenGui:Destroy()
    end
end
GlobalEnv.__ThaiCleanHubCleanup = Hub.cleanup
GlobalEnv.__ThaiCleanHubState = {
    Hub = Hub,
    Config = Config,
    ProfilesStore = ProfilesStore,
    GetCurrentProfile = function()
        return CurrentProfileName
    end,
    GetTaskStatus = function()
        return RuntimeState.CurrentTaskStatusText
    end,
    SetToggle = Hub.setToggle,
    RefreshUI = function()
        syncAllFeatureStates()
        applyThemeAndTypography()
    end,
}
refreshControls = function()
    for _, callback in ipairs(UIRefreshCallbacks) do
        Hub.refreshCallback(callback)
    end
end
updateConflictBadgesAndBanner()
if Hub.refreshStealPanel then
    pcall(Hub.refreshStealPanel)
end
GlobalEnv.__ThaiCleanHubAPI = {
    Hub = Hub,
    Config = Config,
    TimeUtil = TimeUtil,
    RunTick = function()
        Hub.NextModulePoll = 0
        Hub.NextRun.Predictors = 0
        Hub.tick()
    end,
    SetToggle = Hub.setToggle,
    RefreshUI = function()
        syncAllFeatureStates()
        applyThemeAndTypography()
    end,
    HasDynamicArea = function(areaId)
        for _, item in ipairs(AREA_LIST) do
            if item.id == areaId then
                return true
            end
        end
        return false
    end,
    HasDynamicSpecies = function(speciesId)
        for _, item in ipairs(SPECIES_LIST) do
            if item.id == speciesId then
                return true
            end
        end
        return false
    end,
    HasDynamicMutation = function(mutId)
        for _, item in ipairs(MUTATION_LIST) do
            if item.id == mutId then
                return true
            end
        end
        return false
    end,
    GetPredictorSummaries = function()
        if Hub.updatePredictorsAndFinder then
            Hub.updatePredictorsAndFinder(false)
        end
        return {
            Egg = Hub.EggPredSummary and Hub.EggPredSummary.Text or "",
            Fuse = Hub.FusePredSummary and Hub.FusePredSummary.Text or "",
            Finder = Hub.FinderSummary and Hub.FinderSummary.Text or "",
            OwnerHealth = Hub.OwnerHealthSummary and Hub.OwnerHealthSummary.Text or "",
        }
    end,
    ApplySearch = Hub.applySearchFilter,
    HopServer = Hub.hopServer,
    JoinJobId = Hub.joinJobId,
    CopyJobId = Hub.copyCurrentJobId,
    RejoinServer = Hub.rejoinServer,
    RerollPredictors = Hub.rerollPredictorsAndTrades,
    WarpToSafeZone = Hub.warpToSafeZone,
    WarpToArea = Hub.warpToArea,
}
