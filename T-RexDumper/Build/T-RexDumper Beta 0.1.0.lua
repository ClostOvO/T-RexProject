local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local MarketplaceService = game:GetService("MarketplaceService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local environment = type(getgenv) == "function" and getgenv() or _G
if type(environment.__ThaiScriptDumperCleanup) == "function" then
    pcall(environment.__ThaiScriptDumperCleanup)
end

local function resolveGlobalFunc(name, fallback)
    if type(fallback) == "function" then
        return fallback
    end
    if type(environment) == "table" and type(environment[name]) == "function" then
        return environment[name]
    end
    return nil
end

local getscripts = resolveGlobalFunc("getscripts", getscripts)
local getnilinstances = resolveGlobalFunc("getnilinstances", getnilinstances)
local getscripthash = resolveGlobalFunc("getscripthash", getscripthash)
local getscriptbytecode = resolveGlobalFunc("getscriptbytecode", getscriptbytecode)
local getscriptname = resolveGlobalFunc("getscriptname", nil)
local decompile = resolveGlobalFunc("decompile", decompile)
local isfolder = resolveGlobalFunc("isfolder", isfolder)
local makefolder = resolveGlobalFunc("makefolder", makefolder)
local writefile = resolveGlobalFunc("writefile", writefile)
local appendfile = resolveGlobalFunc("appendfile", appendfile)
local isfile = resolveGlobalFunc("isfile", isfile)
local readfile = resolveGlobalFunc("readfile", readfile)
local setclipboard = resolveGlobalFunc("setclipboard", setclipboard)

local defaults = {
    Threads = 1,
    Format = "lua",
    SaveMode = "single",
    SavePath = "Game Dumps/",
    ThemeName = "ชมพูซากุระ",
    FontName = "โกธิคทันสมัย",
    FontSize = 14,
    GuiScalePercent = 100,
    BackgroundBlur = false,
    KeybindsEnabled = true,
    ToggleKey = "RightControl",
}
local settings = {}

local formats = { "rbxlx", "lua", "txt", "json" }
local saveModes = { "single", "multi" }
local connections = {}
local activeRun
local activeDropdown
local cameraConnection
local selectedTab
local ignoreFloatingClick = false
local capturingKey = false
local closed = false
local decompileBusy = false
local cleanup
local startDump
local stopDump
local setStatus
local profileFile = "ThaiScriptDumper_Default.json"

local MAX_BYTECODE_BYTES = 1500000
local MAX_SOURCE_BYTES = 1500000
local MAX_CACHE_BYTES = 4 * 1024 * 1024
local MAX_SINGLE_BUFFER_BYTES = 12 * 1024 * 1024

local ui = {
    ThemeBindings = {},
    TextBindings = {},
    Refresh = {},
    Pages = {},
    Tabs = {},
    Open = true,
    State = "IDLE",
}
local colors = { Ok = Color3.fromRGB(16, 185, 129), Err = Color3.fromRGB(239, 68, 68) }

local function finite(value)
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function safeFont(name, fallback)
    local ok, font = pcall(function()
        return Enum.Font[name]
    end)
    return ok and font or fallback
end

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

local fonts = {
    ["โกธิคทันสมัย"] = safeFont("GothamMedium", Enum.Font.SourceSans),
    ["โกธิคหนา"] = safeFont("GothamBold", Enum.Font.SourceSansBold),
    ["ซอร์สแซนส์"] = Enum.Font.SourceSans,
    ["ซอร์สแซนส์หนา"] = Enum.Font.SourceSansBold,
    ["อารีย์"] = safeFont("Arial", Enum.Font.SourceSans),
}

local themeOrder = {
    "ชมพูซากุระ",
    "มืดคราม",
    "เขียวมรกต",
    "ม่วงอเมทิสต์",
    "ทองคำมืด",
    "สว่างสะอาด",
}

local fontOrder = {
    "โกธิคทันสมัย",
    "โกธิคหนา",
    "ซอร์สแซนส์",
    "ซอร์สแซนส์หนา",
    "อารีย์",
}

local keyNames = {
    RightControl = "คอนโทรลขวา",
    LeftControl = "คอนโทรลซ้าย",
    RightShift = "ชิฟต์ขวา",
    LeftShift = "ชิฟต์ซ้าย",
    Insert = "อินเสิร์ต",
    Home = "โฮม",
    End = "เอนด์",
}

local formatNames = {
    rbxlx = "โมเดล Roblox (.rbxlx)",
    lua = "โค้ด Lua (.lua)",
    txt = "ข้อความ (.txt)",
    json = "ข้อมูล JSON (.json)",
}
local modeNames = {
    single = "รวมเป็นไฟล์เดียว",
    multi = "แยกไฟล์ตามสคริปต์",
}

local function normalizePath(value)
    if type(value) ~= "string" then
        return nil
    end
    local trimmed = value:match("^%s*(.-)%s*$")
    if not trimmed then
        return nil
    end
    local path = trimmed:gsub("\\", "/")
    if path == "" or path:find("[%z\001-\031]") then
        return nil
    end
    return path:sub(-1) == "/" and path or path .. "/"
end

local function applySettings(source)
    source = type(source) == "table" and source or {}
    for key, value in pairs(defaults) do
        settings[key] = value
    end
    for key, default in pairs(defaults) do
        local value = source[key]
        if type(value) == type(default) then
            settings[key] = value
        end
    end
    settings.Threads = finite(settings.Threads) and math.clamp(math.floor(settings.Threads), 1, 8)
        or defaults.Threads
    settings.FontSize = finite(settings.FontSize) and math.clamp(settings.FontSize, 1, 100)
        or defaults.FontSize
    settings.GuiScalePercent = finite(settings.GuiScalePercent)
            and math.clamp(settings.GuiScalePercent, 1, 200)
        or defaults.GuiScalePercent
    if not table.find(formats, settings.Format) then
        settings.Format = defaults.Format
    end
    if not table.find(saveModes, settings.SaveMode) then
        settings.SaveMode = defaults.SaveMode
    end
    if not THEMES[settings.ThemeName] then
        settings.ThemeName = defaults.ThemeName
    end
    if not fonts[settings.FontName] then
        settings.FontName = defaults.FontName
    end
    settings.SavePath = normalizePath(settings.SavePath) or defaults.SavePath
    local valid, key = pcall(function()
        return Enum.KeyCode[settings.ToggleKey]
    end)
    if not valid or not key or key == Enum.KeyCode.Unknown then
        settings.ToggleKey = defaults.ToggleKey
    end
end

applySettings()
if type(isfile) == "function" and type(readfile) == "function" then
    local ok, data = pcall(function()
        if isfile(profileFile) then
            return HttpService:JSONDecode(readfile(profileFile))
        end
        return nil
    end)
    if ok and type(data) == "table" then
        applySettings(data)
    end
end

local function connect(signal, callback)
    local connection = signal:Connect(function(...)
        if closed then
            return
        end
        local ok, reason = pcall(callback, ...)
        if not ok and setStatus then
            setStatus("ERROR", colors.Err, tostring(reason))
        end
    end)
    connections[#connections + 1] = connection
    return connection
end

local function createInstance(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        if property ~= "Parent" then
            instance[property] = value
        end
    end
    instance.Parent = properties.Parent
    return instance
end

function ui.theme()
    return THEMES[settings.ThemeName] or THEMES[defaults.ThemeName]
end

function ui.bindColor(instance, property, role)
    ui.ThemeBindings[#ui.ThemeBindings + 1] =
        { Instance = instance, Property = property, Role = role }
    instance[property] = ui.theme()[role]
end

function ui.text(parent, name, text, size, role)
    local label = createInstance("TextLabel", {
        Name = name,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = text or "",
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Size = UDim2.new(1, 0, 0, 24),
        Font = fonts[settings.FontName],
        TextSize = size * settings.FontSize / 14,
        ZIndex = 14,
        Parent = parent,
    })
    ui.bindColor(label, "TextColor3", role or "Text")
    ui.TextBindings[#ui.TextBindings + 1] = { Instance = label, Size = size }
    return label
end

function ui.round(instance, radius)
    local corner = instance:FindFirstChildOfClass("UICorner")
    if not corner then
        corner = createInstance("UICorner", { Parent = instance })
    end
    corner.CornerRadius = UDim.new(0, radius)
end

function ui.border(instance, thickness)
    local stroke = createInstance(
        "UIStroke",
        { Thickness = thickness or 1, Transparency = 0, Parent = instance }
    )
    ui.bindColor(stroke, "Color", "Border")
    return stroke
end

function ui.panel(parent, name, role, properties)
    properties = properties or {}
    properties.Name, properties.Parent, properties.BorderSizePixel = name, parent, 0
    properties.ZIndex = properties.ZIndex or 12
    local panel = createInstance("Frame", properties)
    ui.bindColor(panel, "BackgroundColor3", role)
    return panel
end

function ui.button(parent, name, caption, role, callback)
    local button = createInstance("TextButton", {
        Name = name,
        Text = caption,
        Size = UDim2.new(1, 0, 0, 36),
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = fonts[settings.FontName],
        TextSize = 14 * settings.FontSize / 14,
        ZIndex = 15,
        Parent = parent,
    })
    ui.bindColor(button, "BackgroundColor3", role or "Card")
    ui.bindColor(button, "TextColor3", "Text")
    ui.TextBindings[#ui.TextBindings + 1] = { Instance = button, Size = 14 }
    ui.round(button, 8)
    if callback then
        connect(button.Activated, callback)
    end
    return button
end

function ui.closeDropdown()
    if activeDropdown then
        activeDropdown.Visible = false
        activeDropdown = nil
    end
end

local screenGui = createInstance("ScreenGui", {
    Name = "ThaiScriptDumper",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999999,
})
local mounted = false
local mountParents = {}
if type(gethui) == "function" then
    local ok, parent = pcall(gethui)
    if ok and parent then
        mountParents[#mountParents + 1] = parent
    end
end
mountParents[#mountParents + 1] = CoreGui
local localPlayer = Players.LocalPlayer
if localPlayer then
    local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
        or localPlayer:WaitForChild("PlayerGui", 5)
    if playerGui then
        mountParents[#mountParents + 1] = playerGui
    end
end
for _, parent in ipairs(mountParents) do
    if parent and not mounted then
        mounted = pcall(function()
            screenGui.Parent = parent
        end)
    end
end
if not mounted then
    screenGui:Destroy()
    return
end
local window = ui.panel(screenGui, "MainWindow", "Bg", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(740, 460),
    Active = true,
    BackgroundTransparency = 0.08,
    ZIndex = 10,
})
ui.round(window, 14)
ui.border(window, 1.5)
local mainScale = createInstance("UIScale", { Name = "MainScale", Scale = 1, Parent = window })
local titleBar = ui.panel(
    window,
    "TopBar",
    "Sidebar",
    { Size = UDim2.new(1, 0, 0, 50), Active = true, ZIndex = 11 }
)
ui.round(titleBar, 14)
ui.panel(
    titleBar,
    "HeaderBottom",
    "Sidebar",
    { Position = UDim2.new(0, 0, 1, -14), Size = UDim2.new(1, 0, 0, 14), ZIndex = 11 }
)
local titleDot = ui.panel(
    titleBar,
    "AccentDot",
    "Accent",
    { Position = UDim2.fromOffset(17, 20), Size = UDim2.fromOffset(10, 10) }
)
ui.round(titleDot, 5)
local title =
    ui.text(titleBar, "HeaderTitle", "ตัวจัดการสคริปต์", 17)
title.Position, title.Size = UDim2.fromOffset(38, 0), UDim2.new(1, -265, 1, 0)
local profileBadge = ui.text(
    titleBar,
    "ActiveProfileBadge",
    "โปรไฟล์: ค่าเริ่มต้น",
    12,
    "SubText"
)
profileBadge.Position, profileBadge.Size = UDim2.new(1, -217, 0, 9), UDim2.fromOffset(170, 32)
profileBadge.BackgroundTransparency, profileBadge.TextXAlignment = 0.15, Enum.TextXAlignment.Center
ui.bindColor(profileBadge, "BackgroundColor3", "Card")
ui.round(profileBadge, 8)
local sidebar = ui.panel(
    window,
    "Sidebar",
    "Sidebar",
    { Position = UDim2.fromOffset(0, 50), Size = UDim2.new(0, 175, 1, -50), ZIndex = 11 }
)
ui.round(sidebar, 14)
createInstance("UIPadding", {
    PaddingTop = UDim.new(0, 12),
    PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10),
    Parent = sidebar,
})
createInstance(
    "UIListLayout",
    { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = sidebar }
)
local statusBanner = ui.panel(
    window,
    "StatusBanner",
    "Card",
    { Position = UDim2.fromOffset(185, 54), Size = UDim2.new(1, -195, 0, 48) }
)
ui.round(statusBanner, 8)
ui.border(statusBanner)
local statusDot = ui.panel(
    statusBanner,
    "StatusDot",
    "Accent",
    { Position = UDim2.fromOffset(10, 13), Size = UDim2.fromOffset(8, 8) }
)
ui.round(statusDot, 4)
local statusLabel =
    ui.text(statusBanner, "StatusBannerLabel", "พร้อมใช้งาน", 12)
statusLabel.Position, statusLabel.Size = UDim2.fromOffset(24, 0), UDim2.new(1, -34, 0, 30)
local progressTrack = ui.panel(
    statusBanner,
    "ProgressTrack",
    "Bg",
    { Position = UDim2.fromOffset(24, 35), Size = UDim2.new(1, -36, 0, 5) }
)
ui.round(progressTrack, 3)
local progressFill =
    ui.panel(progressTrack, "ProgressFill", "Accent", { Size = UDim2.fromScale(0, 1) })
ui.round(progressFill, 3)
local content = createInstance("Frame", {
    Name = "ContentContainer",
    Position = UDim2.fromOffset(185, 112),
    Size = UDim2.new(1, -195, 1, -174),
    BackgroundTransparency = 1,
    ZIndex = 12,
    Parent = window,
})
local footer = createInstance("Frame", {
    Name = "Actions",
    Position = UDim2.new(0, 185, 1, -52),
    Size = UDim2.new(1, -195, 0, 38),
    BackgroundTransparency = 1,
    Parent = window,
})
local dumpButton = ui.button(
    footer,
    "Button_Start",
    "เริ่มส่งออก",
    "AccentSoft",
    function()
        if startDump then
            startDump()
        end
    end
)
dumpButton.Size = UDim2.new(0.62, -4, 1, 0)
local stopButton = ui.button(footer, "Button_Stop", "หยุดงาน", "Card", function()
    if stopDump then
        stopDump()
    end
end)
stopButton.Position, stopButton.Size = UDim2.new(0.62, 4, 0, 0), UDim2.new(0.38, -4, 1, 0)

local blur
local function syncBlur()
    local shouldEnable = ui.Open and settings.BackgroundBlur and not closed
    if shouldEnable and not blur then
        pcall(function()
            blur = createInstance("BlurEffect", {
                Name = "ThaiScriptDumperBlur",
                Size = 16,
                Enabled = true,
                Parent = Lighting,
            })
        end)
    elseif blur then
        pcall(function()
            blur.Enabled = shouldEnable
        end)
    end
end
syncBlur()

local floatingButton = ui.button(
    screenGui,
    "CircleOverlay",
    "ซ่อนเมนู",
    "Card"
)
floatingButton.AnchorPoint, floatingButton.Position = Vector2.new(1, 1), UDim2.new(1, -24, 1, -24)
floatingButton.Size, floatingButton.ZIndex = UDim2.fromOffset(64, 64), 40
ui.round(floatingButton, 32)
local floatingStroke = ui.border(floatingButton, 2.5)
ui.bindColor(floatingStroke, "Color", "Accent")

function ui.setOpen(open)
    ui.Open, window.Visible = open == true, open == true
    syncBlur()
    floatingButton.Text = ui.Open and "ซ่อนเมนู" or "เปิดเมนู"
    if not ui.Open then
        ui.closeDropdown()
    end
end

connect(floatingButton.Activated, function()
    if not ignoreFloatingClick then
        ui.setOpen(not ui.Open)
    end
end)

local closeButton = ui.button(titleBar, "Button_Hide", "×", "Sidebar", function()
    ui.setOpen(false)
end)
closeButton.Position, closeButton.Size = UDim2.new(1, -42, 0, 7), UDim2.fromOffset(32, 34)

function ui.scale()
    local camera = Workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    mainScale.Scale = math.max(
        0.01,
        math.min(settings.GuiScalePercent / 100, (viewport.X - 24) / 740, (viewport.Y - 24) / 460)
    )
end

function ui.refresh()
    for _, callback in ipairs(ui.Refresh) do
        callback()
    end
end

function ui.selectTab(name)
    selectedTab = name
    ui.closeDropdown()
    for tabName, page in pairs(ui.Pages) do
        page.Visible = tabName == name
        ui.Tabs[tabName].BackgroundColor3 = ui.theme()[tabName == name and "AccentSoft" or "Card"]
    end
end

function ui.applyAppearance()
    local theme = ui.theme()
    colors.PurpleLt, colors.TextDim = theme.Accent, theme.SubText
    for _, entry in ipairs(ui.ThemeBindings) do
        if entry.Instance.Parent then
            entry.Instance[entry.Property] = theme[entry.Role]
        end
    end
    for _, entry in ipairs(ui.TextBindings) do
        if entry.Instance.Parent then
            entry.Instance.Font = fonts[settings.FontName]
            entry.Instance.TextSize = math.clamp(entry.Size * settings.FontSize / 14, 1, 100)
        end
    end
    syncBlur()
    ui.scale()
    ui.refresh()
    if selectedTab then
        ui.selectTab(selectedTab)
    end
    if ui.State == "ERROR" then
        statusDot.BackgroundColor3 = colors.Err
    elseif ui.State == "DONE" or ui.State == "SAVED" then
        statusDot.BackgroundColor3 = colors.Ok
    end
end

function ui.page(name, order)
    local button = ui.button(sidebar, "Tab_" .. name, name, "Card", function()
        ui.selectTab(name)
    end)
    button.LayoutOrder, button.Size = order, UDim2.new(1, 0, 0, 38)
    local page = createInstance("ScrollingFrame", {
        Name = "Page_" .. name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 4,
        Visible = false,
        ZIndex = 12,
        Parent = content,
    })
    ui.bindColor(page, "ScrollBarImageColor3", "Accent")
    createInstance(
        "UIPadding",
        { PaddingBottom = UDim.new(0, 10), PaddingRight = UDim.new(0, 7), Parent = page }
    )
    createInstance(
        "UIListLayout",
        { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = page }
    )
    ui.Pages[name], ui.Tabs[name] = page, button
    return page
end

function ui.section(page, name, order)
    local card = ui.panel(page, "Section_" .. name, "Card", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = order,
        BackgroundTransparency = 0.12,
    })
    ui.round(card, 11)
    ui.border(card)
    createInstance("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
        Parent = card,
    })
    createInstance(
        "UIListLayout",
        { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = card }
    )
    local heading = ui.text(card, "SectionTitle", name, 15, "Accent")
    heading.LayoutOrder = 0
    return card
end

function ui.row(parent, name, caption, order)
    local row = ui.panel(parent, name, "Bg", {
        Size = UDim2.new(1, 0, 0, 46),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = order,
        BackgroundTransparency = 0.35,
    })
    ui.round(row, 8)
    local label = ui.text(row, "Label", caption, 13)
    label.Position, label.Size = UDim2.fromOffset(10, 8), UDim2.new(1, -180, 0, 30)
    label.AutomaticSize = Enum.AutomaticSize.Y
    ui.Refresh[#ui.Refresh + 1] = function()
        row.Size = UDim2.new(1, 0, 0, math.max(46, settings.FontSize * 2 + 16))
    end
    return row
end

function ui.editable(scope)
    return scope ~= "dump" or activeRun == nil
end

function ui.validation(row, message)
    local label = row:FindFirstChild("Validation")
    if not label and message then
        label = ui.text(row, "Validation", "", 11, "SubText")
        label.Size = UDim2.new(1, -20, 0, 28)
    end
    if label then
        label.Position = UDim2.fromOffset(10, math.max(46, settings.FontSize * 2 + 16))
        label.Text, label.Visible = message or "", message ~= nil
    end
end

function ui.input(parent, key, caption, order, numeric, scope)
    local row = ui.row(parent, "Row_" .. key, caption, order)
    local box = createInstance("TextBox", {
        Name = "Value_" .. key,
        Position = UDim2.new(1, -160, 0, 8),
        Size = UDim2.new(0, 150, 0, 30),
        Text = tostring(settings[key]),
        ClearTextOnFocus = false,
        Font = fonts[settings.FontName],
        TextSize = settings.FontSize,
        BorderSizePixel = 0,
        ZIndex = 15,
        Parent = row,
    })
    ui.bindColor(box, "BackgroundColor3", "Sidebar")
    ui.bindColor(box, "TextColor3", "Accent")
    ui.round(box, 6)
    ui.TextBindings[#ui.TextBindings + 1] = { Instance = box, Size = 14 }
    connect(box.FocusLost, function()
        if not ui.editable(scope) then
            box.Text = tostring(settings[key])
            return
        end
        local rawValue = box.Text
        local finalValue = rawValue
        if numeric then
            local cleaned = rawValue:gsub(",", "")
            local parsed = tonumber(cleaned)
            if not parsed or not finite(parsed) then
                box.Text = tostring(settings[key])
                ui.validation(
                    row,
                    "ตัวเลขที่กรอกใช้ไม่ได้ จึงใช้ค่าเดิม"
                )
                return
            end
            if key == "Threads" then
                parsed = math.clamp(math.floor(parsed), 1, 8)
            elseif key == "FontSize" then
                parsed = math.clamp(parsed, 1, 100)
            elseif key == "GuiScalePercent" then
                parsed = math.clamp(parsed, 1, 200)
            end
            finalValue = parsed
        elseif key == "SavePath" then
            local normalized = normalizePath(rawValue)
            if not normalized then
                box.Text = tostring(settings[key])
                ui.validation(
                    row,
                    "กรอกชื่อโฟลเดอร์ที่ถูกต้อง จึงจะเปลี่ยนปลายทางได้"
                )
                return
            end
            finalValue = normalized
        end
        ui.validation(row, nil)
        settings[key], box.Text = finalValue, tostring(finalValue)
        ui.applyAppearance()
    end)
    ui.Refresh[#ui.Refresh + 1] = function()
        box.TextEditable = ui.editable(scope)
        box.TextTransparency = box.TextEditable and 0 or 0.45
        if UserInputService:GetFocusedTextBox() ~= box then
            box.Text = tostring(settings[key])
        end
    end
    return box
end

function ui.dropdown(parent, key, caption, choices, labels, order, scope)
    local row = ui.row(parent, "Dropdown_" .. key, caption, order)
    local menu = ui.panel(row, "Choices", "Sidebar", {
        Position = UDim2.fromOffset(8, 47),
        Size = UDim2.new(1, -16, 0, #choices * 34 + 8),
        Visible = false,
    })
    ui.round(menu, 6)
    local button = ui.button(row, "Choice_" .. key, "", "Sidebar", function()
        if not ui.editable(scope) then
            return
        end
        local opening = activeDropdown ~= menu
        ui.closeDropdown()
        menu.Visible = opening
        if opening then
            activeDropdown = menu
        end
    end)
    button.Position, button.Size = UDim2.new(1, -160, 0, 8), UDim2.fromOffset(150, 30)
    createInstance("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        Parent = menu,
    })
    createInstance(
        "UIListLayout",
        { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = menu }
    )
    for index, value in ipairs(choices) do
        local option = ui.button(
            menu,
            "Option_" .. value,
            labels and labels[value] or value,
            "Card",
            function()
                if not ui.editable(scope) then
                    return
                end
                settings[key] = value
                ui.closeDropdown()
                ui.applyAppearance()
            end
        )
        option.LayoutOrder, option.Size = index, UDim2.new(1, 0, 0, 32)
    end
    ui.Refresh[#ui.Refresh + 1] = function()
        button.Text = (labels and labels[settings[key]] or settings[key]) .. " ▾"
        button.TextTransparency = ui.editable(scope) and 0 or 0.45
        button.Active = ui.editable(scope)
        menu.Position = UDim2.fromOffset(8, math.max(46, settings.FontSize * 2 + 16))
    end
end

function ui.toggle(parent, key, caption, order)
    local row = ui.row(parent, "Toggle_" .. key, caption, order)
    local button = ui.button(row, "Switch_" .. key, "", "Sidebar", function()
        settings[key] = not settings[key]
        ui.applyAppearance()
    end)
    button.Position, button.Size = UDim2.new(1, -78, 0, 10), UDim2.fromOffset(66, 27)
    ui.Refresh[#ui.Refresh + 1] = function()
        button.Text = settings[key] and "เปิด" or "ปิด"
        button.BackgroundColor3 = ui.theme()[settings[key] and "AccentSoft" or "Sidebar"]
    end
end

local exportPage = ui.page("ส่งออก", 1)
local settingsPage = ui.page("ตั้งค่า", 2)
local exportCard = ui.section(exportPage, "การส่งออกสคริปต์", 1)
ui.dropdown(exportCard, "Format", "รูปแบบไฟล์", formats, formatNames, 1, "dump")
ui.dropdown(
    exportCard,
    "SaveMode",
    "วิธีบันทึก",
    saveModes,
    modeNames,
    2,
    "dump"
)
ui.input(exportCard, "Threads", "จำนวนงานพร้อมกัน", 3, true, "dump")
ui.input(exportCard, "SavePath", "โฟลเดอร์ปลายทาง", 4, false, "dump")
local exportHint = ui.text(
    exportCard,
    "ExportHint",
    "ตั้งค่าแล้วกดเริ่มส่งออก • เปลี่ยนตัวเลือกได้เมื่อไม่มีงานกำลังทำ",
    11,
    "SubText"
)
exportHint.LayoutOrder, exportHint.AutomaticSize = 5, Enum.AutomaticSize.Y
local resultCard = ui.section(exportPage, "ผลลัพธ์ล่าสุด", 2)
local resultLabel = ui.text(
    resultCard,
    "ResultLabel",
    "ยังไม่มีการส่งออกในรอบนี้",
    12,
    "SubText"
)
resultLabel.LayoutOrder, resultLabel.Size, resultLabel.AutomaticSize =
    1, UDim2.new(1, 0, 0, 36), Enum.AutomaticSize.Y
local outputPath = createInstance("TextBox", {
    Name = "OutputPath",
    Text = "",
    PlaceholderText = "ตำแหน่งไฟล์จะแสดงที่นี่",
    Size = UDim2.new(1, 0, 0, 36),
    ClearTextOnFocus = false,
    TextEditable = false,
    BorderSizePixel = 0,
    Font = fonts[settings.FontName],
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    LayoutOrder = 2,
    Parent = resultCard,
})
ui.bindColor(outputPath, "BackgroundColor3", "Sidebar")
ui.bindColor(outputPath, "TextColor3", "Text")
ui.round(outputPath, 6)
ui.TextBindings[#ui.TextBindings + 1] = { Instance = outputPath, Size = 12 }
local copyButton = ui.button(
    resultCard,
    "Button_CopyPath",
    "คัดลอกตำแหน่งไฟล์",
    "AccentSoft",
    function()
        if outputPath.Text == "" then
            return
        end
        if type(setclipboard) ~= "function" then
            resultLabel.Text =
                "ตัวรันไม่รองรับการคัดลอก เลือกข้อความตำแหน่งไฟล์เพื่อคัดลอกเอง"
            return
        end
        local ok = pcall(setclipboard, outputPath.Text)
        resultLabel.Text = ok and "คัดลอกตำแหน่งไฟล์แล้ว"
            or "คัดลอกไม่สำเร็จ เลือกข้อความตำแหน่งไฟล์เพื่อคัดลอกเอง"
    end
)
copyButton.LayoutOrder = 3
local appearanceCard = ui.section(settingsPage, "หน้าตาเมนู", 1)
ui.dropdown(appearanceCard, "ThemeName", "ธีม", themeOrder, nil, 1)
ui.dropdown(appearanceCard, "FontName", "แบบอักษร", fontOrder, nil, 2)
ui.input(
    appearanceCard,
    "FontSize",
    "ขนาดตัวอักษร (สูงสุด 100)",
    3,
    true
)
ui.input(
    appearanceCard,
    "GuiScalePercent",
    "ขนาดเมนู % (สูงสุด 200)",
    4,
    true
)
ui.toggle(appearanceCard, "BackgroundBlur", "พื้นหลังเบลอ", 5)
local keybindCard = ui.section(settingsPage, "ปุ่มลัด", 2)
ui.toggle(
    keybindCard,
    "KeybindsEnabled",
    "ใช้ปุ่มลัดเปิด/ปิดเมนู",
    1
)
local keyButton = ui.button(keybindCard, "Button_Keybind", "", "Bg", function()
    capturingKey = true
    ui.refresh()
end)
keyButton.LayoutOrder = 2
ui.Refresh[#ui.Refresh + 1] = function()
    keyButton.Text = capturingKey
            and "กดปุ่มใหม่ • Esc เพื่อยกเลิก"
        or (
            "ปุ่มเปิดเมนู: "
            .. (keyNames[settings.ToggleKey] or settings.ToggleKey)
        )
end
local profileCard = ui.section(settingsPage, "ค่าเริ่มต้น", 3)
local saveDefaults = ui.button(
    profileCard,
    "Button_SaveDefaults",
    "บันทึกค่าเริ่มต้น",
    "AccentSoft",
    function()
        if type(writefile) ~= "function" then
            setStatus(
                "ERROR",
                colors.Err,
                "ตัวรันไม่รองรับการบันทึกค่าเริ่มต้น"
            )
            return
        end
        local ok, reason = pcall(writefile, profileFile, HttpService:JSONEncode(settings))
        if ok then
            setStatus(
                "SAVED",
                colors.Ok,
                "บันทึกค่าที่เลือกเป็นค่าเริ่มต้นแล้ว"
            )
        else
            setStatus("ERROR", colors.Err, tostring(reason))
        end
    end
)
saveDefaults.LayoutOrder = 1
local resetDefaults = ui.button(
    profileCard,
    "Button_ResetDefaults",
    "คืนค่ามาตรฐาน",
    "Bg",
    function()
        if activeRun then
            setStatus(
                "NOTICE",
                colors.TextDim,
                "หยุดงานก่อนคืนค่ามาตรฐาน"
            )
            return
        end
        applySettings()
        ui.applyAppearance()
        setStatus(
            "IDLE",
            colors.TextDim,
            "คืนค่ามาตรฐานแล้ว • กดบันทึกค่าเริ่มต้นหากต้องการเก็บถาวร"
        )
    end
)
resetDefaults.LayoutOrder = 2
local unloadButton = ui.button(
    profileCard,
    "Button_Unload",
    "หยุดงานและปิดเมนูทั้งหมด",
    "Bg",
    function()
        if cleanup then
            cleanup()
        end
    end
)
unloadButton.LayoutOrder = 3

local statusNames = {
    IDLE = "พร้อมใช้งาน",
    RUNNING = "กำลังส่งออก",
    EMPTY = "ไม่พบสคริปต์ที่ส่งออกได้",
    DONE = "ส่งออกสำเร็จ",
    STOPPING = "กำลังหยุด • รองานที่กำลังถอดอยู่สิ้นสุด",
    STOPPED = "หยุดงานแล้ว",
    ERROR = "ส่งออกไม่ได้",
    SAVED = "บันทึกแล้ว",
    NOTICE = "แจ้งให้ทราบ",
}
setStatus = function(state, color, result)
    if closed then
        return
    end
    ui.State = state
    statusLabel.Text = statusNames[state] or state
    statusDot.BackgroundColor3 = color or ui.theme().Accent
    if state == "RUNNING" then
        if result == "" then
            outputPath.Text = ""
            resultLabel.Text = "กำลังรวบรวมสคริปต์"
            progressFill.Size = UDim2.fromScale(0, 1)
        end
        local completed, total
        if type(result) == "string" then
            completed, total = result:match("^(%d+) / (%d+)$")
        end
        local completedNum = tonumber(completed)
        local totalNum = tonumber(total)
        if completedNum and totalNum then
            statusLabel.Text = "กำลังถอดสคริปต์ "
                .. tostring(completedNum)
                .. " / "
                .. tostring(totalNum)
            progressFill.Size = UDim2.fromScale(
                totalNum > 0 and (completedNum / totalNum) or 0,
                1
            )
            resultLabel.Text =
                "กำลังทำงานตามรูปแบบและโฟลเดอร์ที่เลือกไว้"
        end
    elseif state == "DONE" then
        local count, destination = tostring(result):match("^(%d+) file%(s%)\n(.*)$")
        outputPath.Text = destination or tostring(result or "")
        resultLabel.Text = count and ("บันทึกแล้ว " .. count .. " ไฟล์")
            or "ส่งออกสำเร็จ"
        progressFill.Size = UDim2.fromScale(1, 1)
        task.defer(function()
            if not closed and selectedTab == "ส่งออก" then
                local position = exportPage.CanvasPosition or Vector2.new(0, 0)
                exportPage.CanvasPosition = Vector2.new(
                    0,
                    math.max(
                        0,
                        resultCard.AbsolutePosition.Y
                            - exportPage.AbsolutePosition.Y
                            + position.Y
                            - 8
                    )
                )
            end
        end)
    elseif state == "STOPPED" then
        resultLabel.Text =
            "หยุดงานแล้ว • ไฟล์ที่เขียนไปแล้วจะยังอยู่ในโฟลเดอร์ปลายทาง"
    elseif result and result ~= "" then
        resultLabel.Text = tostring(result)
    end
end

function ui.capabilities()
    local missing = {}
    for _, entry in ipairs({
        { "getscripts", getscripts },
        { "getscripthash", getscripthash },
        { "decompile", decompile },
        { "isfolder", isfolder },
        { "makefolder", makefolder },
        { "writefile", writefile },
    }) do
        if type(entry[2]) ~= "function" then
            missing[#missing + 1] = entry[1]
        end
    end
    return #missing == 0, missing
end

ui.Refresh[#ui.Refresh + 1] = function()
    local supported = ui.capabilities()
    dumpButton.Active, dumpButton.TextTransparency =
        not activeRun and supported, not activeRun and supported and 0 or 0.5
    dumpButton.Text = activeRun and "กำลังทำงาน…"
        or "เริ่มส่งออก"
    stopButton.Active, stopButton.TextTransparency = activeRun ~= nil, activeRun and 0 or 0.5
end

local function makeDraggable(handle, target, clickTarget)
    local drag
    connect(handle.InputBegan, function(input)
        if
            input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
            drag = { Input = input, Start = input.Position, Position = target.Position }
        end
    end)
    connect(UserInputService.InputChanged, function(input)
        if
            not drag
            or input.UserInputType ~= Enum.UserInputType.MouseMovement and input ~= drag.Input
        then
            return
        end
        local delta = input.Position - drag.Start
        if delta.Magnitude > 5 then
            if clickTarget then
                ignoreFloatingClick = true
            end
            target.Position = UDim2.new(
                drag.Position.X.Scale,
                drag.Position.X.Offset + delta.X,
                drag.Position.Y.Scale,
                drag.Position.Y.Offset + delta.Y
            )
        end
    end)
    connect(UserInputService.InputEnded, function(input)
        if
            drag and (input == drag.Input or input.UserInputType == Enum.UserInputType.MouseButton1)
        then
            drag = nil
            task.defer(function()
                ignoreFloatingClick = false
            end)
        end
    end)
end

makeDraggable(titleBar, window, false)
makeDraggable(floatingButton, floatingButton, true)
connect(UserInputService.InputBegan, function(input, gameProcessed)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then
        return
    end
    if capturingKey then
        capturingKey = false
        if input.KeyCode ~= Enum.KeyCode.Escape and input.KeyCode ~= Enum.KeyCode.Unknown then
            settings.ToggleKey = input.KeyCode.Name
        end
        ui.refresh()
        return
    end
    if
        not gameProcessed
        and settings.KeybindsEnabled
        and not UserInputService:GetFocusedTextBox()
        and input.KeyCode == Enum.KeyCode[settings.ToggleKey]
    then
        ui.setOpen(not ui.Open)
    end
end)

function ui.watchCamera()
    if cameraConnection then
        cameraConnection:Disconnect()
        cameraConnection = nil
    end
    local camera = Workspace.CurrentCamera
    if camera and camera.GetPropertyChangedSignal then
        cameraConnection = connect(camera:GetPropertyChangedSignal("ViewportSize"), ui.scale)
    end
    ui.scale()
end

connect(Workspace:GetPropertyChangedSignal("CurrentCamera"), ui.watchCamera)
ui.watchCamera()
colors.PurpleLt, colors.TextDim = ui.theme().Accent, ui.theme().SubText

local function ensureFolder(path)
    if not isfolder(path) then
        makefolder(path)
    end
end

local function safeFullName(instance)
    local ok, fullName = pcall(function()
        return instance:GetFullName()
    end)
    if ok and type(fullName) == "string" and fullName ~= "" then
        return fullName
    end
    local okName, name = pcall(function()
        return instance.Name
    end)
    return okName and type(name) == "string" and name ~= "" and name or "Script"
end

local function getScriptHash(scriptInstance)
    local success, hash = pcall(getscripthash, scriptInstance)
    if success and type(hash) == "string" and #hash > 0 then
        return hash
    end
    return nil
end

local function getScriptName(scriptInstance)
    local isServerScript = false
    pcall(function()
        isServerScript = scriptInstance:IsA("Script")
    end)
    if isServerScript and getscriptname then
        local ok, customName = pcall(getscriptname, scriptInstance)
        if ok and type(customName) == "string" and customName ~= "" then
            return customName
        end
    end
    local okName, name = pcall(function()
        return scriptInstance.Name
    end)
    return okName and type(name) == "string" and name or "Script"
end

local function sanitizeFilename(value)
    local name = value:gsub("[^%w_%-%.]", "_")
    name = name:gsub("_+", "_"):gsub("^_", ""):gsub("_$", "")
    name = name:sub(1, 100)
    if name == "" or name == "." or name == ".." then
        return "script"
    end
    return name
end

local jsonEscapes = {
    ['"'] = '\\"',
    ["\\"] = "\\\\",
    ["\008"] = "\\b",
    ["\012"] = "\\f",
    ["\n"] = "\\n",
    ["\r"] = "\\r",
    ["\t"] = "\\t",
}
for byte = 0, 31 do
    local ch = string.char(byte)
    if not jsonEscapes[ch] then
        jsonEscapes[ch] = string.format("\\u%04x", byte)
    end
end

local function escapeJson(value)
    local escaped = tostring(value or ""):gsub('[%z\001-\031\\"]', jsonEscapes)
    return escaped
end

local xmlEscapes =
    { ["<"] = "&lt;", [">"] = "&gt;", ["&"] = "&amp;", ['"'] = "&quot;", ["'"] = "&apos;" }

local function escapeXml(value)
    local escaped = tostring(value or ""):gsub("['\"<>&]", xmlEscapes)
    return escaped
end

local function escapeCdata(value)
    local escaped = tostring(value or ""):gsub("]]>", "]]]]><![CDATA[>")
    return escaped
end

local xmlHeader =
    '<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">'

local function createRun()
    return {
        Format = settings.Format,
        SaveMode = settings.SaveMode,
        SavePath = settings.SavePath,
        Threads = 1,
        Cancelled = false,
        ActiveWorkers = 0,
        Cache = {},
        CacheBytes = 0,
        SeenHashes = {},
        Hashes = {},
        PendingHashes = {},
        Completed = 0,
    }
end

local function getCachedHash(run, scriptInstance)
    local hash = run.Hashes[scriptInstance]
    if hash == nil then
        hash = getScriptHash(scriptInstance) or false
        run.Hashes[scriptInstance] = hash
    end
    return hash or nil
end

local function isInternalPath(fullName)
    if type(fullName) ~= "string" then
        return true
    end
    if
        fullName:match("^CoreGui%.")
        or fullName:match("^CorePackages%.")
        or fullName:match("^RobloxGui%.")
        or fullName:match("^CoreScripts%.")
    then
        return true
    end
    return false
end

local function isDumpableScript(instance)
    local ok, valid = pcall(function()
        if typeof(instance) ~= "Instance" then
            return false
        end
        if instance.Parent == nil then
            return false
        end
        if not (instance:IsA("LocalScript") or instance:IsA("ModuleScript")) then
            return false
        end
        if instance:IsDescendantOf(CoreGui) or instance:IsDescendantOf(CorePackages) then
            return false
        end
        local fullName = instance:GetFullName()
        if isInternalPath(fullName) then
            return false
        end
        return true
    end)
    return ok and valid == true
end

local function collectScripts(run)
    local scripts = {}
    local seen = {}
    local inspected = 0
    local function collect(instances)
        if type(instances) ~= "table" then
            return
        end
        for _, instance in pairs(instances) do
            if run.Cancelled then
                break
            end
            inspected = inspected + 1
            if inspected % 150 == 0 then
                task.wait()
            end
            if not seen[instance] and isDumpableScript(instance) then
                seen[instance] = true
                scripts[#scripts + 1] = instance
            end
        end
    end
    local okScripts, listScripts = pcall(getscripts)
    if okScripts and type(listScripts) == "table" then
        collect(listScripts)
    end
    if #scripts == 0 and not run.Cancelled then
        local okChildren, services = pcall(game.GetChildren, game)
        if okChildren and type(services) == "table" then
            for _, service in ipairs(services) do
                if run.Cancelled then
                    break
                end
                if service ~= CoreGui and service ~= CorePackages then
                    local okDesc, descendants = pcall(service.GetDescendants, service)
                    if okDesc and type(descendants) == "table" then
                        collect(descendants)
                    end
                    task.wait()
                end
            end
        end
    end
    return scripts
end

local function checkBytecodeValid(scriptInstance)
    if type(getscriptbytecode) ~= "function" then
        return true, nil
    end
    local ok, bytecode = pcall(getscriptbytecode, scriptInstance)
    if not ok or type(bytecode) ~= "string" or #bytecode == 0 then
        return false, "-- no bytecode"
    end
    if #bytecode > MAX_BYTECODE_BYTES then
        return false, string.format("-- skipped: bytecode too large (%d bytes)", #bytecode)
    end
    return true, nil
end

local function safeDecompileWithTimeout(scriptInstance, timeoutSeconds)
    local validBc, reason = checkBytecodeValid(scriptInstance)
    if not validBc then
        return false, reason
    end
    local waitLockDeadline = os.clock() + 10
    while decompileBusy and os.clock() < waitLockDeadline do
        task.wait(0.05)
    end
    if decompileBusy then
        return false, "-- decompiler busy (previous script still locked)"
    end
    decompileBusy = true
    local finished = false
    local decompileOk = false
    local decompileResult = nil
    local workerThread = task.spawn(function()
        decompileOk, decompileResult = pcall(decompile, scriptInstance)
        finished = true
        decompileBusy = false
    end)
    local deadline = os.clock() + (timeoutSeconds or 6)
    while not finished and os.clock() < deadline do
        task.wait(0.04)
    end
    if not finished then
        if workerThread and type(task.cancel) == "function" then
            pcall(task.cancel, workerThread)
        end
        decompileBusy = false
        task.wait(0.05)
        return false, "-- decompile timed out"
    end
    if decompileOk and type(decompileResult) == "string" and decompileResult ~= "" then
        if #decompileResult > MAX_SOURCE_BYTES then
            decompileResult = decompileResult:sub(1, MAX_SOURCE_BYTES)
                .. "\n-- [truncated: source exceeded limit]"
        end
        return true, decompileResult
    end
    return false, "-- decompile failed"
end

local function storeInBoundedCache(run, hash, source)
    if not hash or type(source) ~= "string" then
        return
    end
    local len = #source
    if len > 262144 then
        return
    end
    if run.CacheBytes + len > MAX_CACHE_BYTES then
        table.clear(run.Cache)
        run.CacheBytes = 0
    end
    run.Cache[hash] = source
    run.CacheBytes = run.CacheBytes + len
end

local function decompileOrResolveSource(run, scriptInstance, cacheForXml)
    if run.Cancelled then
        return "-- cancelled"
    end
    local hash = getCachedHash(run, scriptInstance)
    if not hash then
        return "-- no bytecode"
    end
    if run.Cache[hash] ~= nil then
        return run.Cache[hash]
    end
    local firstSeenPath = run.SeenHashes[hash]
    if firstSeenPath then
        return string.format("-- Duplicate bytecode of: %s (Hash: %s)", firstSeenPath, hash)
    end
    run.SeenHashes[hash] = safeFullName(scriptInstance)
    local _, source = safeDecompileWithTimeout(scriptInstance, 6)
    if cacheForXml and not run.Cancelled then
        storeInBoundedCache(run, hash, source)
    end
    return source
end

local function getSource(run, scriptInstance)
    local hash = getCachedHash(run, scriptInstance)
    if not hash then
        return "-- no bytecode"
    end
    if run.Cache[hash] then
        return run.Cache[hash]
    end
    if run.SeenHashes[hash] then
        return string.format("-- See script: %s (Hash: %s)", run.SeenHashes[hash], hash)
    end
    return "-- failed"
end

local function prepareSources(run, scripts)
    run.ActiveWorkers = 1
    for index, scriptInstance in ipairs(scripts) do
        if run.Cancelled then
            break
        end
        pcall(decompileOrResolveSource, run, scriptInstance, true)
        run.Completed = index
        setStatus("RUNNING", colors.PurpleLt, string.format("%d / %d", run.Completed, #scripts))
        task.wait(0.02)
    end
    run.ActiveWorkers = 0
end

local function getOutputFolder(run)
    local success, product =
        pcall(MarketplaceService.GetProductInfo, MarketplaceService, game.PlaceId)
    local gameName = tostring(success and product and product.Name or "Unknown")
    gameName = gameName:gsub("[^%w%s]", ""):gsub("%s+", "_")
    if gameName == "" then
        gameName = "Unknown"
    end
    local folder = run.SavePath .. string.format("%d_%s/", game.PlaceId, gameName)
    ensureFolder(run.SavePath)
    ensureFolder(folder)
    return folder, gameName
end

local function serializeScriptXml(run, scriptInstance, source)
    local okClass, className = pcall(function()
        return scriptInstance.ClassName
    end)
    if not okClass or (className ~= "LocalScript" and className ~= "ModuleScript") then
        className = "ModuleScript"
    end
    local disabled = ""
    local isLocal = false
    pcall(function()
        isLocal = scriptInstance:IsA("LocalScript")
    end)
    if isLocal then
        local isDisabled = false
        pcall(function()
            isDisabled = scriptInstance.Disabled
        end)
        disabled = string.format('<bool name="Disabled">%s</bool>', tostring(isDisabled))
    end
    local hash = getCachedHash(run, scriptInstance) or "nil"
    return table.concat({
        xmlHeader,
        string.format('<Item class="%s" referent="RBX0"><Properties>', className),
        string.format('<string name="Name">%s</string>', escapeXml(getScriptName(scriptInstance))),
        disabled,
        string.format(
            '<ProtectedString name="Source"><![CDATA[--// Hash: %s\n%s]]></ProtectedString>',
            hash,
            escapeCdata(source)
        ),
        "</Properties></Item></roblox>",
    }, "\n")
end

local function serializeGameXml(run, scripts)
    local keep = {}
    for _, scriptInstance in ipairs(scripts) do
        local current = scriptInstance
        local depth = 0
        while current and current ~= game and depth < 64 do
            if keep[current] then
                break
            end
            keep[current] = true
            local okParent, parent = pcall(function()
                return current.Parent
            end)
            current = okParent and parent or nil
            depth = depth + 1
        end
    end
    local chunks = { xmlHeader }
    local referent = 0
    local visited = 0
    local visitedSet = {}
    local function appendInstance(instance, depth)
        if
            run.Cancelled
            or depth > 64
            or visitedSet[instance]
            or instance == screenGui
            or instance == blur
            or not keep[instance]
        then
            return
        end
        visitedSet[instance] = true
        visited = visited + 1
        if visited % 80 == 0 then
            task.wait()
        end
        local okClass, className = pcall(function()
            return instance.ClassName
        end)
        if
            not okClass
            or (
                className ~= "LocalScript"
                and className ~= "ModuleScript"
                and className ~= "RemoteEvent"
                and className ~= "RemoteFunction"
            )
        then
            className = "Folder"
        end
        referent = referent + 1
        chunks[#chunks + 1] = string.format(
            '<Item class="%s" referent="RBX%d"><Properties><string name="Name">%s</string>',
            className,
            referent,
            escapeXml(getScriptName(instance))
        )
        if className == "LocalScript" or className == "ModuleScript" then
            if className == "LocalScript" then
                local isDisabled = false
                pcall(function()
                    isDisabled = instance.Disabled
                end)
                local disabled = isDisabled or not getCachedHash(run, instance)
                chunks[#chunks + 1] =
                    string.format('<bool name="Disabled">%s</bool>', tostring(disabled))
            end
            chunks[#chunks + 1] = string.format(
                '<ProtectedString name="Source"><![CDATA[%s]]></ProtectedString>',
                escapeCdata(getSource(run, instance))
            )
        end
        chunks[#chunks + 1] = "</Properties>"
        local okChildren, children = pcall(instance.GetChildren, instance)
        if okChildren and type(children) == "table" then
            for _, child in ipairs(children) do
                if child ~= game and keep[child] and not visitedSet[child] then
                    appendInstance(child, depth + 1)
                end
            end
        end
        chunks[#chunks + 1] = "</Item>"
    end
    local okServices, services = pcall(game.GetChildren, game)
    if okServices and type(services) == "table" then
        for _, instance in ipairs(services) do
            if instance ~= CoreGui and instance ~= CorePackages and keep[instance] then
                appendInstance(instance, 1)
            end
        end
    end
    chunks[#chunks + 1] = "</roblox>"
    return table.concat(chunks)
end

local function serializeJsonEntryWithSource(run, scriptInstance, source, includeHash)
    local okClass, className = pcall(function()
        return scriptInstance.ClassName
    end)
    local fields = {
        '"name":"' .. escapeJson(safeFullName(scriptInstance)) .. '"',
        '"class":"' .. escapeJson(okClass and className or "ModuleScript") .. '"',
    }
    if includeHash then
        fields[#fields + 1] = '"hash":"'
            .. escapeJson(getCachedHash(run, scriptInstance) or "")
            .. '"'
    end
    fields[#fields + 1] = '"source":"' .. escapeJson(source) .. '"'
    return "{" .. table.concat(fields, ",") .. "}"
end

local function streamSingleFile(run, scripts, destination)
    if run.Format == "rbxlx" then
        prepareSources(run, scripts)
        if run.Cancelled then
            return
        end
        local content = serializeGameXml(run, scripts)
        if not run.Cancelled then
            writefile(destination, content)
        end
        return
    end
    run.ActiveWorkers = 1
    if appendfile then
        writefile(destination, run.Format == "json" and '{"scripts":[' or "")
        local buffer = {}
        local bufferBytes = 0
        local function flushBuffer()
            if #buffer > 0 then
                appendfile(destination, table.concat(buffer))
                table.clear(buffer)
                bufferBytes = 0
                task.wait()
            end
        end
        for index, scriptInstance in ipairs(scripts) do
            if run.Cancelled then
                break
            end
            local source = decompileOrResolveSource(run, scriptInstance, false)
            run.Completed = index
            setStatus("RUNNING", colors.PurpleLt, string.format("%d / %d", run.Completed, #scripts))
            local entry
            if run.Format == "json" then
                entry = (index > 1 and "," or "")
                    .. serializeJsonEntryWithSource(run, scriptInstance, source, false)
            elseif run.Format == "txt" then
                entry = string.format(
                    "===== %s =====\n%s\n\n",
                    safeFullName(scriptInstance),
                    source
                )
            else
                entry = string.format(
                    "--[[ %s ]]\n%s\n\n",
                    safeFullName(scriptInstance),
                    source
                )
            end
            buffer[#buffer + 1] = entry
            bufferBytes = bufferBytes + #entry
            if bufferBytes >= 65536 or index % 10 == 0 then
                flushBuffer()
            else
                task.wait(0.02)
            end
        end
        if run.Format == "json" then
            buffer[#buffer + 1] = "]}"
        end
        flushBuffer()
        run.ActiveWorkers = 0
        return
    end
    local chunks = {}
    local totalBytes = 0
    for index, scriptInstance in ipairs(scripts) do
        if run.Cancelled then
            break
        end
        local source = decompileOrResolveSource(run, scriptInstance, false)
        run.Completed = index
        setStatus("RUNNING", colors.PurpleLt, string.format("%d / %d", run.Completed, #scripts))
        local entry
        if run.Format == "json" then
            entry = serializeJsonEntryWithSource(run, scriptInstance, source, false)
        elseif run.Format == "txt" then
            entry = string.format(
                "===== %s =====\n%s\n",
                safeFullName(scriptInstance),
                source
            )
        else
            entry = string.format(
                "--[[ %s ]]\n%s\n",
                safeFullName(scriptInstance),
                source
            )
        end
        if totalBytes + #entry <= MAX_SINGLE_BUFFER_BYTES then
            chunks[#chunks + 1] = entry
            totalBytes = totalBytes + #entry
        end
        task.wait(0.02)
    end
    run.ActiveWorkers = 0
    if run.Cancelled then
        return
    end
    local content
    if run.Format == "json" then
        content = '{"scripts":[' .. table.concat(chunks, ",") .. "]}"
    else
        content = table.concat(chunks, "\n")
    end
    table.clear(chunks)
    writefile(destination, content)
end

local function writeMultipleFiles(run, scripts, folder, timestamp)
    local destination = folder .. timestamp .. "/"
    ensureFolder(destination)
    local usedNames = {}
    local count = 0
    run.ActiveWorkers = 1
    for index, scriptInstance in ipairs(scripts) do
        if run.Cancelled then
            break
        end
        local fullPathName = safeFullName(scriptInstance)
        local baseName = sanitizeFilename(fullPathName)
        local name = baseName
        local suffix = 1
        while usedNames[name] do
            suffix = suffix + 1
            name = baseName .. "_" .. suffix
        end
        usedNames[name] = true
        local source = decompileOrResolveSource(run, scriptInstance, false)
        run.Completed = index
        setStatus("RUNNING", colors.PurpleLt, string.format("%d / %d", run.Completed, #scripts))
        local content
        if run.Format == "rbxlx" then
            content = serializeScriptXml(run, scriptInstance, source)
        elseif run.Format == "json" then
            content = serializeJsonEntryWithSource(run, scriptInstance, source, true)
        else
            content = string.format(
                "--[[ %s ]]\n-- Hash: %s\n%s",
                fullPathName,
                getCachedHash(run, scriptInstance) or "nil",
                source
            )
        end
        pcall(writefile, destination .. name .. "." .. run.Format, content)
        count = count + 1
        task.wait(0.02)
    end
    run.ActiveWorkers = 0
    return count, destination
end

local function runDump(run)
    setStatus("RUNNING", colors.PurpleLt, "")
    local folder, gameName = getOutputFolder(run)
    local scripts = collectScripts(run)
    if run.Cancelled then
        return
    end
    if #scripts == 0 then
        setStatus("EMPTY", colors.TextDim, "0 scripts")
        return
    end
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local count, destination
    if run.SaveMode == "multi" then
        count, destination = writeMultipleFiles(run, scripts, folder, timestamp)
    else
        destination = folder .. gameName .. "_" .. timestamp .. "." .. run.Format
        streamSingleFile(run, scripts, destination)
        if run.Cancelled then
            return
        end
        count = 1
    end
    table.clear(run.Cache)
    table.clear(run.SeenHashes)
    table.clear(run.Hashes)
    if not run.Cancelled then
        setStatus("DONE", colors.Ok, string.format("%d file(s)\n%s", count, destination))
    end
end

startDump = function()
    if activeRun or closed then
        return
    end
    local supported, missing = ui.capabilities()
    if not supported then
        setStatus(
            "ERROR",
            colors.Err,
            "ตัวรันยังขาดความสามารถ: "
                .. table.concat(missing, ", ")
        )
        return
    end
    ui.closeDropdown()
    local run = createRun()
    activeRun = run
    ui.refresh()
    task.spawn(function()
        local success, reason = pcall(runDump, run)
        while run.ActiveWorkers > 0 do
            task.wait(0.05)
        end
        if activeRun ~= run or closed then
            return
        end
        if run.Cancelled then
            setStatus("STOPPED", colors.TextDim, nil)
        elseif not success then
            setStatus("ERROR", colors.Err, tostring(reason))
        end
        activeRun = nil
        ui.refresh()
    end)
end
stopDump = function()
    if activeRun and not activeRun.Cancelled then
        activeRun.Cancelled = true
        setStatus(
            "STOPPING",
            colors.TextDim,
            "หยุดคิวแล้ว รอการถอดสคริปต์ที่เริ่มไปแล้วสิ้นสุด"
        )
    end
end
cleanup = function()
    if closed then
        return
    end
    closed = true
    if activeRun then
        activeRun.Cancelled = true
    end
    for _, connection in ipairs(connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(connections)
    if blur then
        pcall(function()
            blur:Destroy()
        end)
        blur = nil
    end
    pcall(function()
        screenGui:Destroy()
    end)
    if environment.__ThaiScriptDumperCleanup == cleanup then
        environment.__ThaiScriptDumperCleanup = nil
    end
end
environment.__ThaiScriptDumperCleanup = cleanup
ui.applyAppearance()
ui.selectTab("ส่งออก")
local ready, missing = ui.capabilities()
if not ready then
    setStatus(
        "ERROR",
        colors.Err,
        "ตัวรันยังขาดความสามารถ: "
            .. table.concat(missing, ", ")
    )
end