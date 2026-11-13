-- T-RexProject/UniversalCode/02_thai_clean_ui.lua
-- Canonical thai-clean-ui 740x460 dashboard framework with theme/font registries,
-- sliders (linear & log), single/multi dropdowns, live text rows, :When() visibility,
-- draggable circular toggle overlay, toast stack, status banner, profile & settings tabs.

local TweenService = TRex.Services.TweenService
local UserInputService = TRex.Services.UserInputService
local Lighting = TRex.Services.Lighting
local Workspace = TRex.Services.Workspace

local UI = {}
TRex.UI = UI

UI.THEMES = {
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

UI.THEME_ORDER = {
	"ชมพูซากุระ",
	"มืดคราม",
	"เขียวมรกต",
	"ม่วงอเมทิสต์",
	"ทองคำมืด",
	"สว่างสะอาด",
}

UI.THAI_FONTS = {
	["โกธิคทันสมัย"] = { Regular = "GothamMedium", Bold = "GothamBold", Fallback = Enum.Font.SourceSans },
	["โกธิคหนา"] = { Regular = "GothamBold", Bold = "GothamBold", Fallback = Enum.Font.SourceSansBold },
	["ซอร์สแซนส์"] = { Regular = "SourceSans", Bold = "SourceSansBold", Fallback = Enum.Font.SourceSans },
	["ซอร์สแซนส์หนา"] = { Regular = "SourceSansBold", Bold = "SourceSansBold", Fallback = Enum.Font.SourceSansBold },
	["อารีย์"] = { Regular = "Arial", Bold = "ArialBold", Fallback = Enum.Font.SourceSans },
}

UI.FONT_ORDER = {
	"โกธิคทันสมัย",
	"โกธิคหนา",
	"ซอร์สแซนส์",
	"ซอร์สแซนส์หนา",
	"อารีย์",
}

UI.KEYCODE_THAI_NAMES = {
	RightControl = "คอนโทรลขวา",
	LeftControl = "คอนโทรลซ้าย",
	RightShift = "ชิฟต์ขวา",
	LeftShift = "ชิฟต์ซ้าย",
	RightAlt = "อัลต์ขวา",
	LeftAlt = "อัลต์ซ้าย",
	Insert = "อินเสิร์ต",
	Home = "โฮม",
	End = "เอนด์",
	Delete = "ดีลีท",
	PageUp = "เพจอัป",
	PageDown = "เพจดาวน์",
	F1 = "เอฟ 1",
	F2 = "เอฟ 2",
	F3 = "เอฟ 3",
	F4 = "เอฟ 4",
	F5 = "เอฟ 5",
	F6 = "เอฟ 6",
	F7 = "เอฟ 7",
	F8 = "เอฟ 8",
	F9 = "เอฟ 9",
	F10 = "เอฟ 10",
	F11 = "เอฟ 11",
	F12 = "เอฟ 12",
}

local ThemeRegistry = {}
local TextRegistry = {}
local RefreshCallbacks = {}
local ConditionalRows = {}
local FeatureStatusMap = {}

local ScreenGui, MainWindow, MainScale, BlurEffect
local CircleOverlay, OverlayLabel, ToastContainer, PopupLayer
local TitleLabel, ProfileBadgeLabel, StatusLabel, StatusDot, HideButtonLabel
local SidebarScroll, ContentArea, TabOrder, Tabs = nil, nil, {}, {}
local ActiveTabId = nil
local StopAllCallback = nil
local ActivePopup = nil
local CloseActivePopup = nil
local ProfileInputBox = nil
local ProfileDropdownCtrl = nil

local function makeCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = parent
	return corner
end

local function makeStroke(parent, role, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = thickness or 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	UI.registerTheme(stroke, "Color", role or "Border")
	return stroke
end

local function makePadding(parent, top, right, bottom, left)
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, top or 0)
	pad.PaddingRight = UDim.new(0, right or top or 0)
	pad.PaddingBottom = UDim.new(0, bottom or top or 0)
	pad.PaddingLeft = UDim.new(0, left or right or top or 0)
	pad.Parent = parent
	return pad
end

local function resolveLabel(keyOrText)
	if type(keyOrText) ~= "string" or keyOrText == "" then
		return ""
	end
	local translated = TRex.t(keyOrText)
	if translated and translated ~= "" and translated ~= keyOrText then
		return translated
	end
	return keyOrText
end

function UI.formatCompactMoney(n)
	n = tonumber(n) or 0
	if n <= 0 then
		return "$0"
	end
	local suffixes = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx" }
	local idx = 1
	local v = n
	while v >= 1000 and idx < #suffixes do
		v = v / 1000
		idx = idx + 1
	end
	if idx == 1 then
		return "$" .. tostring(math.floor(v + 0.5))
	end
	local txt = string.format("%.2f", v):gsub("0+$", ""):gsub("%.$", "")
	return "$" .. txt .. suffixes[idx]
end

function UI.parseMoneyInput(text)
	if type(text) ~= "string" then
		return tonumber(text)
	end
	local clean = text:gsub("[%$,/sS%s,]", ""):upper()
	if clean == "" then
		return nil
	end
	local mult = 1
	local body = clean
	local map = {
		SX = 1e21,
		QI = 1e18,
		QA = 1e15,
		T = 1e12,
		B = 1e9,
		M = 1e6,
		K = 1e3,
	}
	for suf, factor in pairs(map) do
		if clean:sub(-#suf) == suf then
			mult = factor
			body = clean:sub(1, #clean - #suf)
			break
		end
	end
	local num = tonumber(body)
	if not num then
		return nil
	end
	return num * mult
end

function UI.getTheme()
	return UI.THEMES[TRex.Config.Theme] or UI.THEMES["ชมพูซากุระ"]
end

function UI.getFont(isBold)
	local preset = UI.THAI_FONTS[TRex.Config.Font] or UI.THAI_FONTS["โกธิคทันสมัย"]
	local name = isBold and preset.Bold or preset.Regular
	return TRex.safeEnumFont(name, preset.Fallback)
end

function UI.registerTheme(inst, prop, role)
	table.insert(ThemeRegistry, { Instance = inst, Property = prop, Role = role })
	local theme = UI.getTheme()
	pcall(function()
		inst[prop] = theme[role]
	end)
end

function UI.registerText(inst, baseSize, isBold)
	table.insert(TextRegistry, { Instance = inst, BaseSize = baseSize or 14, IsBold = isBold == true })
	pcall(function()
		inst.Font = UI.getFont(isBold == true)
		inst.TextSize = math.clamp(math.floor(((baseSize or 14) * (TRex.Config.FontSize or 14) / 14) + 0.5), 1, 100)
	end)
end

function UI.registerRefresh(fn)
	if type(fn) == "function" then
		table.insert(RefreshCallbacks, fn)
	end
end

function UI.formatKeyCode(keyName)
	if type(keyName) ~= "string" or keyName == "" or keyName == "None" then
		return TRex.t("msg.none")
	end
	return UI.KEYCODE_THAI_NAMES[keyName] or keyName
end

function UI.getScreenGui()
	return ScreenGui
end

function UI.evaluateConditionals()
	for _, entry in ipairs(ConditionalRows) do
		local inst = entry.Row
		if inst and inst.Parent then
			local okAll = true
			for _, checkFn in ipairs(entry.Checks) do
				local ok, res = pcall(checkFn)
				if not ok or not res then
					okAll = false
					break
				end
			end
			inst.Visible = okAll
			if not okAll and ActivePopup and ActivePopup.Owner == entry.Row then
				CloseActivePopup()
			end
		end
	end
end

function UI.applyTheme()
	local theme = UI.getTheme()
	for i = #ThemeRegistry, 1, -1 do
		local entry = ThemeRegistry[i]
		if entry.Instance and entry.Instance.Parent then
			pcall(function()
				entry.Instance[entry.Property] = theme[entry.Role]
			end)
		else
			table.remove(ThemeRegistry, i)
		end
	end
	if MainWindow then
		MainWindow.BackgroundTransparency = math.clamp(tonumber(TRex.Config.BackgroundTransparency) or 0.04, 0, 0.4)
	end
end

function UI.applyTypography()
	local scaleCfg = math.clamp(tonumber(TRex.Config.GuiScalePercent) or 100, 70, 140) / 100
	local viewport = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
	local fitScale = math.min((viewport.X - 24) / 740, (viewport.Y - 24) / 460)
	if MainScale then
		MainScale.Scale = math.clamp(math.min(scaleCfg, math.max(0.55, fitScale)), 0.55, 1.45)
	end
	for i = #TextRegistry, 1, -1 do
		local entry = TextRegistry[i]
		if entry.Instance and entry.Instance.Parent then
			pcall(function()
				entry.Instance.Font = UI.getFont(entry.IsBold)
				entry.Instance.TextSize = math.clamp(math.floor((entry.BaseSize * (TRex.Config.FontSize or 14) / 14) + 0.5), 1, 100)
			end)
		else
			table.remove(TextRegistry, i)
		end
	end
end

local function updateBlur()
	if BlurEffect then
		BlurEffect.Size = (MainWindow and MainWindow.Visible and TRex.Config.BackgroundBlur) and 14 or 0
	end
end

function UI.setStatusBanner(state, textOrKey)
	local translated = resolveLabel(textOrKey or "status.ready")
	if StatusLabel then
		StatusLabel.Text = translated
	end
	if StatusDot then
		if state == "busy" or state == "active" then
			StatusDot.BackgroundColor3 = Color3.fromRGB(52, 211, 153)
		elseif state == "warn" or state == "error" then
			StatusDot.BackgroundColor3 = Color3.fromRGB(251, 191, 36)
		else
			StatusDot.BackgroundColor3 = UI.getTheme().Accent
		end
	end
end

function UI.refreshAll()
	UI.applyTheme()
	UI.applyTypography()
	if TitleLabel then
		TitleLabel.Text = resolveLabel("ui.title")
	end
	if ProfileBadgeLabel then
		ProfileBadgeLabel.Text = TRex.t("ui.profile_badge", { name = TRex.CurrentProfileName or "Default" })
	end
	if HideButtonLabel then
		HideButtonLabel.Text = resolveLabel("ui.hide_menu")
	end
	if OverlayLabel then
		OverlayLabel.Text = "T-Rex"
	end
	for _, fn in ipairs(RefreshCallbacks) do
		pcall(fn)
	end
	UI.evaluateConditionals()
	updateBlur()
end

function UI.notify(titleKeyOrText, messageKeyOrText, duration)
	if not ToastContainer or not ToastContainer.Parent then
		return
	end
	local theme = UI.getTheme()
	local titleText = resolveLabel(titleKeyOrText)
	local msgText = resolveLabel(messageKeyOrText)

	local toast = Instance.new("Frame")
	toast.Size = UDim2.new(1, 0, 0, msgText ~= "" and 56 or 38)
	toast.BackgroundColor3 = theme.Sidebar
	toast.BackgroundTransparency = 0.06
	toast.BorderSizePixel = 0
	toast.Parent = ToastContainer
	makeCorner(toast, 10)
	makeStroke(toast, "Accent", 1)
	makePadding(toast, 8, 12, 8, 12)

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 3, 1, 0)
	bar.BackgroundColor3 = theme.Accent
	bar.BorderSizePixel = 0
	bar.Parent = toast
	makeCorner(bar, 2)

	local titleLbl = Instance.new("TextLabel")
	titleLbl.BackgroundTransparency = 1
	titleLbl.Position = UDim2.fromOffset(10, 0)
	titleLbl.Size = UDim2.new(1, -12, 0, 18)
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Text = titleText
	titleLbl.TextColor3 = theme.Text
	titleLbl.Parent = toast
	UI.registerText(titleLbl, 13, true)

	if msgText ~= "" then
		local descLbl = Instance.new("TextLabel")
		descLbl.BackgroundTransparency = 1
		descLbl.Position = UDim2.fromOffset(10, 20)
		descLbl.Size = UDim2.new(1, -12, 0, 20)
		descLbl.TextXAlignment = Enum.TextXAlignment.Left
		descLbl.TextTruncate = Enum.TextTruncate.AtEnd
		descLbl.Text = msgText
		descLbl.TextColor3 = theme.SubText
		descLbl.Parent = toast
		UI.registerText(descLbl, 12, false)
	end

	task.delay(duration or 3.2, function()
		if toast and toast.Parent then
			local tw = TweenService:Create(toast, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1,
			})
			tw:Play()
			task.delay(0.24, function()
				if toast and toast.Parent then
					toast:Destroy()
				end
			end)
		end
	end)
end

function UI.setWindowVisible(visible)
	if MainWindow then
		MainWindow.Visible = visible == true
	end
	if not visible and CloseActivePopup then
		CloseActivePopup()
	end
	updateBlur()
end

function UI.toggleWindow()
	if MainWindow then
		UI.setWindowVisible(not MainWindow.Visible)
	end
end

function UI.selectTab(tabId)
	if CloseActivePopup then
		CloseActivePopup()
	end
	ActiveTabId = tabId
	for id, tab in pairs(Tabs) do
		local selected = (id == tabId)
		tab.Page.Visible = selected
		tab.Button.BackgroundColor3 = selected and UI.getTheme().AccentSoft or UI.getTheme().Card
		tab.ButtonLabel.TextColor3 = selected and Color3.fromRGB(255, 255, 255) or UI.getTheme().Text
	end
end

CloseActivePopup = function()
	if ActivePopup then
		if ActivePopup.Frame and ActivePopup.Frame.Parent then
			ActivePopup.Frame:Destroy()
		end
		ActivePopup = nil
	end
end

local function makeWidgetHandle(row, getFn, setFn)
	local handle = {
		Row = row,
		Get = getFn,
		Set = setFn,
	}
	function handle:SetVisible(vis)
		if self.Row then
			self.Row.Visible = vis == true
		end
		return self
	end
	function handle:When(dep, pred)
		local checkFn
		if type(dep) == "function" then
			checkFn = dep
		else
			local depKey = (type(dep) == "table" and dep.Key) or tostring(dep)
			if type(pred) == "function" then
				checkFn = function()
					return pred(TRex.Config[depKey]) == true
				end
			elseif pred ~= nil then
				checkFn = function()
					return TRex.Config[depKey] == pred
				end
			else
				checkFn = function()
					return TRex.Config[depKey] == true
				end
			end
		end
		local existing = nil
		for _, item in ipairs(ConditionalRows) do
			if item.Row == row then
				existing = item
				break
			end
		end
		if not existing then
			existing = { Row = row, Checks = {} }
			table.insert(ConditionalRows, existing)
		end
		table.insert(existing.Checks, checkFn)
		UI.evaluateConditionals()
		return self
	end
	return handle
end

local function attachSectionMethods(page)
	local tabObj = { Page = page }

	function tabObj:addSection(titleKeyOrText)
		local secFrame = Instance.new("Frame")
		secFrame.Size = UDim2.new(1, 0, 0, 0)
		secFrame.AutomaticSize = Enum.AutomaticSize.Y
		secFrame.BorderSizePixel = 0
		secFrame.Parent = page
		UI.registerTheme(secFrame, "BackgroundColor3", "Sidebar")
		makeCorner(secFrame, 10)
		makeStroke(secFrame, "Border", 1)
		makePadding(secFrame, 10, 10, 10, 10)

		local secLayout = Instance.new("UIListLayout")
		secLayout.SortOrder = Enum.SortOrder.LayoutOrder
		secLayout.Padding = UDim.new(0, 6)
		secLayout.Parent = secFrame

		local headerLbl = Instance.new("TextLabel")
		headerLbl.LayoutOrder = 0
		headerLbl.BackgroundTransparency = 1
		headerLbl.Size = UDim2.new(1, 0, 0, 22)
		headerLbl.TextXAlignment = Enum.TextXAlignment.Left
		headerLbl.Text = resolveLabel(titleKeyOrText)
		headerLbl.Parent = secFrame
		UI.registerTheme(headerLbl, "TextColor3", "Accent")
		UI.registerText(headerLbl, 14, true)

		UI.registerRefresh(function()
			headerLbl.Text = resolveLabel(titleKeyOrText)
		end)

		local nextOrder = 1
		local function takeOrder()
			nextOrder = nextOrder + 1
			return nextOrder
		end

		local sec = { Frame = secFrame }

		function sec:addLabel(textKeyOrText)
			local lbl = Instance.new("TextLabel")
			lbl.LayoutOrder = takeOrder()
			lbl.BackgroundTransparency = 1
			lbl.Size = UDim2.new(1, 0, 0, 20)
			lbl.AutomaticSize = Enum.AutomaticSize.Y
			lbl.TextWrapped = true
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Text = resolveLabel(textKeyOrText)
			lbl.Parent = secFrame
			UI.registerTheme(lbl, "TextColor3", "SubText")
			UI.registerText(lbl, 12, false)

			UI.registerRefresh(function()
				if type(textKeyOrText) == "string" then
					lbl.Text = resolveLabel(textKeyOrText)
				end
			end)
			return makeWidgetHandle(lbl, function()
				return lbl.Text
			end, function(_, v)
				lbl.Text = resolveLabel(tostring(v or ""))
			end)
		end

		function sec:addText(opts)
			opts = opts or {}
			local row = Instance.new("Frame")
			row.LayoutOrder = takeOrder()
			row.Size = UDim2.new(1, 0, 0, 34)
			row.AutomaticSize = Enum.AutomaticSize.Y
			row.BorderSizePixel = 0
			row.Parent = secFrame
			UI.registerTheme(row, "BackgroundColor3", "Card")
			makeCorner(row, 8)
			makePadding(row, 6, 10, 6, 10)

			local titleLbl = Instance.new("TextLabel")
			titleLbl.BackgroundTransparency = 1
			titleLbl.Size = UDim2.new(0.45, -6, 0, 22)
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left
			titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
			titleLbl.Text = resolveLabel(opts.label or opts.key or "")
			titleLbl.Parent = row
			UI.registerTheme(titleLbl, "TextColor3", "SubText")
			UI.registerText(titleLbl, 12, true)

			local valLbl = Instance.new("TextLabel")
			valLbl.BackgroundTransparency = 1
			valLbl.Position = UDim2.new(0.45, 0, 0, 0)
			valLbl.Size = UDim2.new(0.55, 0, 0, 22)
			valLbl.AutomaticSize = Enum.AutomaticSize.Y
			valLbl.TextWrapped = true
			valLbl.TextXAlignment = Enum.TextXAlignment.Right
			valLbl.Text = tostring(opts.text or "-")
			valLbl.Parent = row
			UI.registerTheme(valLbl, "TextColor3", "Text")
			UI.registerText(valLbl, 12, false)

			UI.registerRefresh(function()
				titleLbl.Text = resolveLabel(opts.label or opts.key or "")
			end)

			local handle = makeWidgetHandle(row, function()
				return valLbl.Text
			end, function(_, newText)
				valLbl.Text = tostring(newText or "-")
			end)
			return handle
		end

		function sec:addToggle(opts)
			local key = opts.key
			local hasDesc = opts.desc ~= nil and opts.desc ~= ""
			local row = Instance.new("Frame")
			row.LayoutOrder = takeOrder()
			row.Size = UDim2.new(1, 0, 0, hasDesc and 50 or 38)
			row.BorderSizePixel = 0
			row.Parent = secFrame
			UI.registerTheme(row, "BackgroundColor3", "Card")
			makeCorner(row, 8)
			makePadding(row, 6, 10, 6, 10)

			local titleLbl = Instance.new("TextLabel")
			titleLbl.BackgroundTransparency = 1
			titleLbl.Position = UDim2.fromOffset(0, 1)
			titleLbl.Size = UDim2.new(1, -135, 0, 20)
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left
			titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
			titleLbl.Parent = row
			UI.registerTheme(titleLbl, "TextColor3", "Text")
			UI.registerText(titleLbl, 13, true)

			local descLbl
			if hasDesc then
				descLbl = Instance.new("TextLabel")
				descLbl.BackgroundTransparency = 1
				descLbl.Position = UDim2.fromOffset(0, 21)
				descLbl.Size = UDim2.new(1, -135, 0, 16)
				descLbl.TextXAlignment = Enum.TextXAlignment.Left
				descLbl.TextTruncate = Enum.TextTruncate.AtEnd
				descLbl.Parent = row
				UI.registerTheme(descLbl, "TextColor3", "SubText")
				UI.registerText(descLbl, 11, false)
			end

			local badge = Instance.new("TextLabel")
			badge.AnchorPoint = Vector2.new(1, 0.5)
			badge.Position = UDim2.new(1, -54, 0.5, 0)
			badge.Size = UDim2.fromOffset(66, 20)
			badge.BorderSizePixel = 0
			badge.Text = TRex.t("badge.idle")
			badge.Parent = row
			makeCorner(badge, 6)
			UI.registerText(badge, 11, true)

			local switchBtn = Instance.new("TextButton")
			switchBtn.AnchorPoint = Vector2.new(1, 0.5)
			switchBtn.Position = UDim2.new(1, 0, 0.5, 0)
			switchBtn.Size = UDim2.fromOffset(44, 22)
			switchBtn.Text = ""
			switchBtn.AutoButtonColor = false
			switchBtn.BorderSizePixel = 0
			switchBtn.Parent = row
			makeCorner(switchBtn, 11)

			local knob = Instance.new("Frame")
			knob.AnchorPoint = Vector2.new(0, 0.5)
			knob.Size = UDim2.fromOffset(16, 16)
			knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			knob.BorderSizePixel = 0
			knob.Parent = switchBtn
			makeCorner(knob, 8)

			local function syncVisual(animate)
				local theme = UI.getTheme()
				local enabled = TRex.Config[key] == true
				titleLbl.Text = resolveLabel(opts.label or key)
				if descLbl then
					descLbl.Text = resolveLabel(opts.desc)
				end
				badge.Text = enabled and (FeatureStatusMap[key] or TRex.t("badge.active")) or TRex.t("badge.idle")
				badge.BackgroundColor3 = enabled and theme.AccentSoft or theme.Bg
				badge.TextColor3 = enabled and Color3.fromRGB(255, 255, 255) or theme.SubText

				local targetBg = enabled and theme.Accent or theme.Bg
				local targetPos = enabled and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
				if animate then
					TweenService:Create(switchBtn, TweenInfo.new(0.14), { BackgroundColor3 = targetBg }):Play()
					TweenService:Create(knob, TweenInfo.new(0.14), { Position = targetPos }):Play()
				else
					switchBtn.BackgroundColor3 = targetBg
					knob.Position = targetPos
				end
			end

			local function applyValue(newVal, silent)
				local b = newVal == true
				TRex.Config[key] = b
				syncVisual(true)
				UI.evaluateConditionals()
				if not silent and opts.onChanged then
					pcall(opts.onChanged, b)
				end
				if not silent then
					TRex.saveConfig(TRex.CurrentProfileName)
				end
			end

			TRex.bindClick(switchBtn, function()
				applyValue(not (TRex.Config[key] == true), false)
			end)

			UI.registerRefresh(function()
				syncVisual(false)
			end)
			syncVisual(false)

			local handle = makeWidgetHandle(row, function()
				return TRex.Config[key] == true
			end, function(_, v, silent)
				applyValue(v == true, silent == true)
			end)
			handle.Key = key
			return handle
		end

		function sec:addSlider(opts)
			local key = opts.key
			local isLog = opts.log == true
			local sliderMin = isLog and 0 or (tonumber(opts.min) or 0)
			local sliderMax = isLog and 1000 or (tonumber(opts.max) or 100)
			local step = tonumber(opts.step) or 1
			local suffix = opts.unit or opts.suffix or ""
			local maxRealVal = tonumber(opts.logMax) or 1e12

			local function valueToPos(v)
				v = tonumber(v) or 0
				if not isLog then
					return math.clamp(v, sliderMin, sliderMax)
				end
				if v <= 0 then
					return 0
				end
				local ratio = math.log10(math.max(1, v)) / math.log10(math.max(10, maxRealVal))
				return math.clamp(math.floor(ratio * 1000 + 0.5), 1, 1000)
			end

			local function posToValue(pos)
				if not isLog then
					local clamped = math.clamp(pos, sliderMin, sliderMax)
					if step > 0 then
						clamped = math.floor((clamped - sliderMin) / step + 0.5) * step + sliderMin
					end
					return math.clamp(clamped, sliderMin, sliderMax)
				end
				local p = math.clamp(math.floor(pos + 0.5), 0, 1000)
				if p <= 0 then
					return 0
				end
				local exp = (p / 1000) * math.log10(math.max(10, maxRealVal))
				local raw = 10 ^ exp
				if raw < 10 then
					return math.floor(raw + 0.5)
				end
				local mag = 10 ^ math.max(0, math.floor(math.log10(raw)) - 2)
				return math.floor(raw / mag + 0.5) * mag
			end

			local function formatDisplay(val)
				if isLog then
					if (tonumber(val) or 0) <= 0 then
						return opts.minText or "$0"
					end
					if opts.maxText and (tonumber(val) or 0) >= maxRealVal then
						return opts.maxText
					end
					return UI.formatCompactMoney(val) .. suffix
				end
				if opts.valueLabels and opts.valueLabels[val] then
					return tostring(opts.valueLabels[val])
				end
				if step >= 1 then
					return tostring(math.floor((tonumber(val) or 0) + 0.5)) .. suffix
				end
				return string.format("%.2f", tonumber(val) or 0):gsub("0+$", ""):gsub("%.$", "") .. suffix
			end

			local hasDesc = opts.desc ~= nil and opts.desc ~= ""
			local row = Instance.new("Frame")
			row.LayoutOrder = takeOrder()
			row.Size = UDim2.new(1, 0, 0, hasDesc and 68 or 54)
			row.BorderSizePixel = 0
			row.Parent = secFrame
			UI.registerTheme(row, "BackgroundColor3", "Card")
			makeCorner(row, 8)
			makePadding(row, 6, 10, 6, 10)

			local topRow = Instance.new("Frame")
			topRow.BackgroundTransparency = 1
			topRow.Size = UDim2.new(1, 0, 0, 22)
			topRow.Parent = row

			local titleLbl = Instance.new("TextLabel")
			titleLbl.BackgroundTransparency = 1
			titleLbl.Size = UDim2.new(1, -104, 1, 0)
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left
			titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
			titleLbl.Parent = topRow
			UI.registerTheme(titleLbl, "TextColor3", "Text")
			UI.registerText(titleLbl, 13, true)

			local valueBox = Instance.new("TextBox")
			valueBox.AnchorPoint = Vector2.new(1, 0.5)
			valueBox.Position = UDim2.new(1, 0, 0.5, 0)
			valueBox.Size = UDim2.fromOffset(96, 22)
			valueBox.ClearTextOnFocus = false
			valueBox.BorderSizePixel = 0
			valueBox.TextXAlignment = Enum.TextXAlignment.Center
			valueBox.Parent = topRow
			UI.registerTheme(valueBox, "BackgroundColor3", "Sidebar")
			UI.registerTheme(valueBox, "TextColor3", "Text")
			UI.registerText(valueBox, 12, true)
			makeCorner(valueBox, 6)
			makeStroke(valueBox, "Border", 1)

			if hasDesc then
				local descLbl = Instance.new("TextLabel")
				descLbl.BackgroundTransparency = 1
				descLbl.Position = UDim2.fromOffset(0, 22)
				descLbl.Size = UDim2.new(1, 0, 0, 14)
				descLbl.TextXAlignment = Enum.TextXAlignment.Left
				descLbl.TextTruncate = Enum.TextTruncate.AtEnd
				descLbl.Parent = row
				UI.registerTheme(descLbl, "TextColor3", "SubText")
				UI.registerText(descLbl, 11, false)
				UI.registerRefresh(function()
					descLbl.Text = resolveLabel(opts.desc)
				end)
				descLbl.Text = resolveLabel(opts.desc)
			end

			local trackY = hasDesc and 44 or 30
			local track = Instance.new("Frame")
			track.Position = UDim2.fromOffset(0, trackY)
			track.Size = UDim2.new(1, 0, 0, 8)
			track.BorderSizePixel = 0
			track.Parent = row
			UI.registerTheme(track, "BackgroundColor3", "Bg")
			makeCorner(track, 4)

			local fill = Instance.new("Frame")
			fill.Size = UDim2.new(0, 0, 1, 0)
			fill.BorderSizePixel = 0
			fill.Parent = track
			UI.registerTheme(fill, "BackgroundColor3", "Accent")
			makeCorner(fill, 4)

			local knob = Instance.new("Frame")
			knob.AnchorPoint = Vector2.new(0.5, 0.5)
			knob.Position = UDim2.new(0, 0, 0.5, 0)
			knob.Size = UDim2.fromOffset(14, 14)
			knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			knob.BorderSizePixel = 0
			knob.Parent = track
			makeCorner(knob, 7)

			local hitBtn = Instance.new("TextButton")
			hitBtn.BackgroundTransparency = 1
			hitBtn.Position = UDim2.fromOffset(0, trackY - 6)
			hitBtn.Size = UDim2.new(1, 0, 0, 20)
			hitBtn.Text = ""
			hitBtn.Parent = row

			local dragging = false

			local function syncVisual()
				titleLbl.Text = resolveLabel(opts.label or key)
				local curVal = tonumber(TRex.Config[key])
				if curVal == nil then
					curVal = tonumber(TRex.DEFAULT_CONFIG[key]) or sliderMin
				end
				local pos = valueToPos(curVal)
				local span = math.max(1e-6, sliderMax - sliderMin)
				local frac = math.clamp((pos - sliderMin) / span, 0, 1)
				fill.Size = UDim2.new(frac, 0, 1, 0)
				knob.Position = UDim2.new(frac, 0, 0.5, 0)
				if not valueBox:IsFocused() then
					valueBox.Text = formatDisplay(curVal)
				end
			end

			local function commitValue(newVal, saveNow, silent)
				local val = tonumber(newVal) or 0
				if not isLog then
					if step > 0 then
						val = math.floor((val - sliderMin) / step + 0.5) * step + sliderMin
					end
					val = math.clamp(val, sliderMin, sliderMax)
				else
					val = math.max(0, math.floor(val + 0.5))
				end
				TRex.Config[key] = val
				syncVisual()
				UI.evaluateConditionals()
				if not silent and opts.onChanged then
					pcall(opts.onChanged, val)
				end
				if saveNow and not silent then
					TRex.saveConfig(TRex.CurrentProfileName)
				end
			end

			local function updateFromInputX(inputX, saveNow)
				local width = track.AbsoluteSize.X
				if width <= 1 then
					return
				end
				local rel = math.clamp((inputX - track.AbsolutePosition.X) / width, 0, 1)
				local pos = sliderMin + rel * (sliderMax - sliderMin)
				commitValue(posToValue(pos), saveNow, false)
			end

			TRex.connectSignal(hitBtn.InputBegan, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					updateFromInputX(input.Position.X, false)
				end
			end)

			TRex.connectSignal(UserInputService.InputChanged, function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					updateFromInputX(input.Position.X, false)
				end
			end)

			TRex.connectSignal(UserInputService.InputEnded, function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
					dragging = false
					updateFromInputX(input.Position.X, true)
				end
			end)

			TRex.connectSignal(valueBox.FocusLost, function()
				local parsed = isLog and UI.parseMoneyInput(valueBox.Text) or tonumber((valueBox.Text:gsub("[^%d%.%-]", "")))
				if parsed ~= nil then
					commitValue(parsed, true, false)
				else
					UI.notify("msg.notice", "msg.invalid_number", 2.2)
					syncVisual()
				end
			end)

			UI.registerRefresh(syncVisual)
			syncVisual()

			local handle = makeWidgetHandle(row, function()
				return TRex.Config[key]
			end, function(_, v, silent)
				commitValue(v, not silent, silent == true)
			end)
			handle.Key = key
			return handle
		end

		function sec:addNumericInput(opts)
			local key = opts.key
			local minVal = opts.min or 0
			local maxVal = opts.max or 999999
			local row = Instance.new("Frame")
			row.LayoutOrder = takeOrder()
			row.Size = UDim2.new(1, 0, 0, 38)
			row.BorderSizePixel = 0
			row.Parent = secFrame
			UI.registerTheme(row, "BackgroundColor3", "Card")
			makeCorner(row, 8)
			makePadding(row, 6, 10, 6, 10)

			local titleLbl = Instance.new("TextLabel")
			titleLbl.BackgroundTransparency = 1
			titleLbl.Size = UDim2.new(1, -110, 1, 0)
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left
			titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
			titleLbl.Parent = row
			UI.registerTheme(titleLbl, "TextColor3", "Text")
			UI.registerText(titleLbl, 13, true)

			local box = Instance.new("TextBox")
			box.AnchorPoint = Vector2.new(1, 0.5)
			box.Position = UDim2.new(1, 0, 0.5, 0)
			box.Size = UDim2.fromOffset(96, 24)
			box.ClearTextOnFocus = false
			box.BorderSizePixel = 0
			box.Parent = row
			UI.registerTheme(box, "BackgroundColor3", "Sidebar")
			UI.registerTheme(box, "TextColor3", "Text")
			UI.registerText(box, 12, true)
			makeCorner(box, 6)
			makeStroke(box, "Border", 1)

			local function syncVisual()
				titleLbl.Text = resolveLabel(opts.label or key)
				if not box:IsFocused() then
					box.Text = tostring(TRex.Config[key] or minVal)
				end
			end

			TRex.connectSignal(box.FocusLost, function()
				local parsed = tonumber(box.Text)
				if not parsed then
					UI.notify("msg.notice", "msg.invalid_number", 2.2)
					syncVisual()
					return
				end
				if opts.integer then
					parsed = math.floor(parsed + 0.5)
				end
				parsed = math.clamp(parsed, minVal, maxVal)
				TRex.Config[key] = parsed
				syncVisual()
				UI.evaluateConditionals()
				if opts.onChanged then
					pcall(opts.onChanged, parsed)
				end
				TRex.saveConfig(TRex.CurrentProfileName)
			end)

			UI.registerRefresh(syncVisual)
			syncVisual()

			local handle = makeWidgetHandle(row, function()
				return TRex.Config[key]
			end, function(_, v, silent)
				local parsed = math.clamp(tonumber(v) or minVal, minVal, maxVal)
				if opts.integer then
					parsed = math.floor(parsed + 0.5)
				end
				TRex.Config[key] = parsed
				syncVisual()
				if not silent and opts.onChanged then
					pcall(opts.onChanged, parsed)
				end
			end)
			handle.Key = key
			return handle
		end

		function sec:addDropdown(opts)
			local key = opts.key
			local isMulti = opts.multi == true
			local emptyLabel = opts.emptyLabel or "msg.all_selected"
			local row = Instance.new("Frame")
			row.LayoutOrder = takeOrder()
			row.Size = UDim2.new(1, 0, 0, 38)
			row.BorderSizePixel = 0
			row.Parent = secFrame
			UI.registerTheme(row, "BackgroundColor3", "Card")
			makeCorner(row, 8)
			makePadding(row, 6, 10, 6, 10)

			local titleLbl = Instance.new("TextLabel")
			titleLbl.BackgroundTransparency = 1
			titleLbl.Size = UDim2.new(0.46, 0, 1, 0)
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left
			titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
			titleLbl.Parent = row
			UI.registerTheme(titleLbl, "TextColor3", "Text")
			UI.registerText(titleLbl, 13, true)

			local dropBtn = Instance.new("TextButton")
			dropBtn.AnchorPoint = Vector2.new(1, 0.5)
			dropBtn.Position = UDim2.new(1, 0, 0.5, 0)
			dropBtn.Size = UDim2.new(0.52, -4, 0, 26)
			dropBtn.AutoButtonColor = false
			dropBtn.TextTruncate = Enum.TextTruncate.AtEnd
			dropBtn.BorderSizePixel = 0
			dropBtn.Parent = row
			UI.registerTheme(dropBtn, "BackgroundColor3", "Sidebar")
			UI.registerTheme(dropBtn, "TextColor3", "Text")
			UI.registerText(dropBtn, 12, false)
			makeCorner(dropBtn, 6)
			makeStroke(dropBtn, "Border", 1)

			local function getCurrentItems()
				if type(opts.getItems) == "function" then
					local ok, list = pcall(opts.getItems)
					if ok and type(list) == "table" then
						return list
					end
				end
				return opts.items or {}
			end

			local function getMultiTable()
				local raw = TRex.Config[key]
				if type(raw) ~= "table" then
					raw = {}
					TRex.Config[key] = raw
				end
				return raw
			end

			local function formatButtonText()
				if not isMulti then
					return tostring(TRex.Config[key] or "")
				end
				local list = getMultiTable()
				if #list == 0 then
					local txt = resolveLabel(emptyLabel)
					return txt ~= "" and txt or "ทั้งหมด"
				elseif #list == 1 then
					return tostring(list[1])
				end
				return TRex.t("msg.selected_count", { count = #list })
			end

			local function syncVisual()
				titleLbl.Text = resolveLabel(opts.label or key)
				dropBtn.Text = formatButtonText() .. "  ▾"
			end

			local function applySingle(itemVal, silent)
				TRex.Config[key] = itemVal
				syncVisual()
				UI.evaluateConditionals()
				if not silent and opts.onChanged then
					pcall(opts.onChanged, itemVal)
				end
				if not silent then
					TRex.saveConfig(TRex.CurrentProfileName)
				end
			end

			local function toggleMulti(itemVal)
				local list = getMultiTable()
				local idx = table.find(list, itemVal)
				if idx then
					table.remove(list, idx)
				else
					table.insert(list, itemVal)
				end
				syncVisual()
				UI.evaluateConditionals()
				if opts.onChanged then
					pcall(opts.onChanged, list)
				end
				TRex.saveConfig(TRex.CurrentProfileName)
			end

			local function openPopup()
				if not PopupLayer or not MainScale then
					return
				end
				if ActivePopup and ActivePopup.Owner == row then
					CloseActivePopup()
					return
				end
				CloseActivePopup()

				local items = getCurrentItems()
				local scale = math.max(0.55, MainScale.Scale)
				local btnPos = dropBtn.AbsolutePosition
				local btnSize = dropBtn.AbsoluteSize
				local menuWidth = math.max(180, btnSize.X / scale)
				local itemHeight = 26
				local extraRows = isMulti and 1 or 0
				local contentCount = #items + extraRows
				local menuHeight = math.min(220, math.max(36, contentCount * itemHeight + 8))

				local vp = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
				local xPx = math.clamp(btnPos.X, 8, math.max(8, vp.X - menuWidth * scale - 8))
				local yPx = btnPos.Y + btnSize.Y + 4
				if yPx + menuHeight * scale > vp.Y - 8 then
					yPx = math.max(8, btnPos.Y - menuHeight * scale - 4)
				end

				local menu = Instance.new("Frame")
				menu.Position = UDim2.fromOffset(xPx, yPx)
				menu.Size = UDim2.fromOffset(menuWidth * scale, menuHeight * scale)
				menu.ZIndex = 100
				menu.BorderSizePixel = 0
				menu.Parent = PopupLayer
				UI.registerTheme(menu, "BackgroundColor3", "Sidebar")
				makeCorner(menu, 8)
				makeStroke(menu, "Accent", 1)
				makePadding(menu, 4, 4, 4, 4)

				local scroll = Instance.new("ScrollingFrame")
				scroll.BackgroundTransparency = 1
				scroll.Size = UDim2.fromScale(1, 1)
				scroll.BorderSizePixel = 0
				scroll.ScrollBarThickness = 4
				scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
				scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
				scroll.ZIndex = 101
				scroll.Parent = menu

				local listLayout = Instance.new("UIListLayout")
				listLayout.SortOrder = Enum.SortOrder.LayoutOrder
				listLayout.Padding = UDim.new(0, 2)
				listLayout.Parent = scroll

				ActivePopup = { Owner = row, Frame = menu }

				local itemButtons = {}
				local function repaintPopupItems()
					local theme = UI.getTheme()
					local multiList = isMulti and getMultiTable() or nil
					for _, rec in ipairs(itemButtons) do
						local selected = isMulti and (table.find(multiList, rec.Value) ~= nil) or (TRex.Config[key] == rec.Value)
						rec.Button.BackgroundColor3 = selected and theme.AccentSoft or theme.Card
						rec.Button.TextColor3 = selected and Color3.fromRGB(255, 255, 255) or theme.Text
						rec.Button.Text = (selected and "✓  " or "   ") .. tostring(rec.Value)
					end
				end

				if isMulti then
					local clearBtn = Instance.new("TextButton")
					clearBtn.LayoutOrder = 0
					clearBtn.Size = UDim2.new(1, -4, 0, itemHeight - 2)
					clearBtn.AutoButtonColor = false
					clearBtn.BorderSizePixel = 0
					clearBtn.ZIndex = 102
					clearBtn.Text = TRex.t("btn.clear_selection")
					clearBtn.Parent = scroll
					UI.registerTheme(clearBtn, "BackgroundColor3", "Bg")
					UI.registerTheme(clearBtn, "TextColor3", "SubText")
					UI.registerText(clearBtn, 11, true)
					makeCorner(clearBtn, 5)
					TRex.bindClick(clearBtn, function()
						table.clear(getMultiTable())
						syncVisual()
						repaintPopupItems()
						UI.evaluateConditionals()
						if opts.onChanged then
							pcall(opts.onChanged, getMultiTable())
						end
						TRex.saveConfig(TRex.CurrentProfileName)
					end)
				end

				for idx, itemVal in ipairs(items) do
					local optBtn = Instance.new("TextButton")
					optBtn.LayoutOrder = idx
					optBtn.Size = UDim2.new(1, -4, 0, itemHeight - 2)
					optBtn.AutoButtonColor = false
					optBtn.TextXAlignment = Enum.TextXAlignment.Left
					optBtn.TextTruncate = Enum.TextTruncate.AtEnd
					optBtn.BorderSizePixel = 0
					optBtn.ZIndex = 102
					optBtn.Parent = scroll
					UI.registerText(optBtn, 12, false)
					makeCorner(optBtn, 5)

					table.insert(itemButtons, { Value = itemVal, Button = optBtn })
					TRex.bindClick(optBtn, function()
						if isMulti then
							toggleMulti(itemVal)
							repaintPopupItems()
						else
							CloseActivePopup()
							applySingle(itemVal, false)
						end
					end)
				end

				repaintPopupItems()
			end

			TRex.bindClick(dropBtn, openPopup)
			UI.registerRefresh(syncVisual)
			syncVisual()

			local handle = makeWidgetHandle(row, function()
				return TRex.Config[key]
			end, function(_, v, silent)
				if isMulti then
					TRex.Config[key] = type(v) == "table" and v or {}
					syncVisual()
					UI.evaluateConditionals()
					if not silent and opts.onChanged then
						pcall(opts.onChanged, TRex.Config[key])
					end
				else
					applySingle(v, silent == true)
				end
			end)
			handle.Key = key
			return handle
		end

		function sec:addKeybindPicker(opts)
			local key = opts.key
			local row = Instance.new("Frame")
			row.LayoutOrder = takeOrder()
			row.Size = UDim2.new(1, 0, 0, 38)
			row.BorderSizePixel = 0
			row.Parent = secFrame
			UI.registerTheme(row, "BackgroundColor3", "Card")
			makeCorner(row, 8)
			makePadding(row, 6, 10, 6, 10)

			local titleLbl = Instance.new("TextLabel")
			titleLbl.BackgroundTransparency = 1
			titleLbl.Size = UDim2.new(1, -135, 1, 0)
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left
			titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
			titleLbl.Parent = row
			UI.registerTheme(titleLbl, "TextColor3", "Text")
			UI.registerText(titleLbl, 13, true)

			local bindBtn = Instance.new("TextButton")
			bindBtn.AnchorPoint = Vector2.new(1, 0.5)
			bindBtn.Position = UDim2.new(1, 0, 0.5, 0)
			bindBtn.Size = UDim2.fromOffset(124, 24)
			bindBtn.AutoButtonColor = false
			bindBtn.BorderSizePixel = 0
			bindBtn.Parent = row
			UI.registerTheme(bindBtn, "BackgroundColor3", "Sidebar")
			UI.registerTheme(bindBtn, "TextColor3", "Text")
			UI.registerText(bindBtn, 12, true)
			makeCorner(bindBtn, 6)
			makeStroke(bindBtn, "Border", 1)

			local listening = false

			local function syncVisual()
				titleLbl.Text = resolveLabel(opts.label or key)
				bindBtn.Text = listening and TRex.t("msg.press_key") or UI.formatKeyCode(TRex.Config[key])
			end

			TRex.bindClick(bindBtn, function()
				if listening then
					return
				end
				listening = true
				syncVisual()
				local conn
				conn = TRex.connectSignal(UserInputService.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.Keyboard then
						if conn then
							conn:Disconnect()
						end
						listening = false
						if input.KeyCode == Enum.KeyCode.Escape then
							TRex.Config[key] = "None"
						else
							TRex.Config[key] = input.KeyCode.Name
						end
						syncVisual()
						if opts.onChanged then
							pcall(opts.onChanged, TRex.Config[key])
						end
						TRex.saveConfig(TRex.CurrentProfileName)
					end
				end)
			end)

			UI.registerRefresh(syncVisual)
			syncVisual()

			local handle = makeWidgetHandle(row, function()
				return TRex.Config[key]
			end, function(_, v)
				TRex.Config[key] = v
				syncVisual()
			end)
			handle.Key = key
			return handle
		end

		function sec:addTextInput(opts)
			local key = opts.key
			local row = Instance.new("Frame")
			row.LayoutOrder = takeOrder()
			row.Size = UDim2.new(1, 0, 0, 38)
			row.BorderSizePixel = 0
			row.Parent = secFrame
			UI.registerTheme(row, "BackgroundColor3", "Card")
			makeCorner(row, 8)
			makePadding(row, 6, 10, 6, 10)

			local titleLbl = Instance.new("TextLabel")
			titleLbl.BackgroundTransparency = 1
			titleLbl.Size = UDim2.new(0.42, 0, 1, 0)
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left
			titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
			titleLbl.Parent = row
			UI.registerTheme(titleLbl, "TextColor3", "Text")
			UI.registerText(titleLbl, 13, true)

			local box = Instance.new("TextBox")
			box.AnchorPoint = Vector2.new(1, 0.5)
			box.Position = UDim2.new(1, 0, 0.5, 0)
			box.Size = UDim2.new(0.56, -4, 0, 24)
			box.ClearTextOnFocus = false
			box.TextTruncate = Enum.TextTruncate.AtEnd
			box.BorderSizePixel = 0
			box.Parent = row
			UI.registerTheme(box, "BackgroundColor3", "Sidebar")
			UI.registerTheme(box, "TextColor3", "Text")
			UI.registerTheme(box, "PlaceholderColor3", "SubText")
			UI.registerText(box, 12, false)
			makeCorner(box, 6)
			makeStroke(box, "Border", 1)

			local function syncVisual()
				titleLbl.Text = resolveLabel(opts.label or key)
				box.PlaceholderText = opts.placeholderKey and resolveLabel(opts.placeholderKey) or ""
				if key and not box:IsFocused() then
					box.Text = tostring(TRex.Config[key] or "")
				end
			end

			TRex.connectSignal(box.FocusLost, function()
				local val = box.Text or ""
				if key then
					TRex.Config[key] = val
					TRex.saveConfig(TRex.CurrentProfileName)
				end
				if opts.onChanged then
					pcall(opts.onChanged, val)
				end
			end)

			UI.registerRefresh(syncVisual)
			syncVisual()

			local handle = makeWidgetHandle(row, function()
				return box.Text
			end, function(_, v, silent)
				box.Text = tostring(v or "")
				if key then
					TRex.Config[key] = box.Text
				end
				if not silent and opts.onChanged then
					pcall(opts.onChanged, box.Text)
				end
			end)
			handle.Key = key
			handle.Box = box
			return handle
		end

		function sec:addButton(opts)
			local btn = Instance.new("TextButton")
			btn.LayoutOrder = takeOrder()
			btn.Size = UDim2.new(1, 0, 0, 34)
			btn.AutoButtonColor = false
			btn.BorderSizePixel = 0
			btn.Parent = secFrame
			if opts.danger then
				btn.BackgroundColor3 = Color3.fromRGB(185, 28, 28)
				btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			elseif opts.primary then
				UI.registerTheme(btn, "BackgroundColor3", "AccentSoft")
				btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			else
				UI.registerTheme(btn, "BackgroundColor3", "Card")
				UI.registerTheme(btn, "TextColor3", "Text")
				makeStroke(btn, "Border", 1)
			end
			UI.registerText(btn, 13, true)
			makeCorner(btn, 8)

			local function syncVisual()
				btn.Text = resolveLabel(opts.label or "")
			end

			TRex.bindClick(btn, function()
				if opts.onClick then
					pcall(opts.onClick)
				end
			end)

			UI.registerRefresh(syncVisual)
			syncVisual()

			return makeWidgetHandle(btn, function()
				return btn.Text
			end, function(_, v)
				btn.Text = resolveLabel(tostring(v or ""))
			end)
		end

		return sec
	end

	return tabObj
end

function UI.addTab(id, titleKeyOrText, order)
	if Tabs[id] then
		return Tabs[id].Controller
	end

	local tabBtn = Instance.new("TextButton")
	tabBtn.LayoutOrder = order or (#TabOrder + 1)
	tabBtn.Size = UDim2.new(1, 0, 0, 36)
	tabBtn.AutoButtonColor = false
	tabBtn.Text = ""
	tabBtn.BorderSizePixel = 0
	tabBtn.Parent = SidebarScroll
	UI.registerTheme(tabBtn, "BackgroundColor3", "Card")
	makeCorner(tabBtn, 8)
	makePadding(tabBtn, 0, 10, 0, 10)

	local btnLbl = Instance.new("TextLabel")
	btnLbl.BackgroundTransparency = 1
	btnLbl.Size = UDim2.fromScale(1, 1)
	btnLbl.TextXAlignment = Enum.TextXAlignment.Left
	btnLbl.TextTruncate = Enum.TextTruncate.AtEnd
	btnLbl.Text = resolveLabel(titleKeyOrText)
	btnLbl.Parent = tabBtn
	UI.registerTheme(btnLbl, "TextColor3", "Text")
	UI.registerText(btnLbl, 13, true)

	local page = Instance.new("ScrollingFrame")
	page.BackgroundTransparency = 1
	page.Size = UDim2.fromScale(1, 1)
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 5
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.Visible = false
	page.Parent = ContentArea
	UI.registerTheme(page, "ScrollBarImageColor3", "Accent")
	makePadding(page, 2, 6, 12, 2)

	local pageLayout = Instance.new("UIListLayout")
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.Padding = UDim.new(0, 10)
	pageLayout.Parent = page

	local ctrl = attachSectionMethods(page)
	Tabs[id] = {
		Id = id,
		TitleKey = titleKeyOrText,
		Button = tabBtn,
		ButtonLabel = btnLbl,
		Page = page,
		Controller = ctrl,
	}
	table.insert(TabOrder, id)

	TRex.bindClick(tabBtn, function()
		UI.selectTab(id)
	end)

	UI.registerRefresh(function()
		btnLbl.Text = resolveLabel(titleKeyOrText)
	end)

	return ctrl
end

function UI.buildShell(stopAllCallback)
	StopAllCallback = stopAllCallback

	ScreenGui = TRex.mountScreenGui("TRex_Dashboard_Game01")
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local existingBlur = Lighting:FindFirstChild("TRexMenuBlur")
	if existingBlur then
		existingBlur:Destroy()
	end
	BlurEffect = Instance.new("BlurEffect")
	BlurEffect.Name = "TRexMenuBlur"
	BlurEffect.Size = 0
	BlurEffect.Parent = Lighting
	TRex.registerCleanup(function()
		if BlurEffect and BlurEffect.Parent then
			BlurEffect:Destroy()
		end
	end)

	MainWindow = Instance.new("Frame")
	MainWindow.Name = "MainWindow"
	MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
	MainWindow.Position = UDim2.fromScale(0.5, 0.5)
	MainWindow.Size = UDim2.fromOffset(740, 460)
	MainWindow.BorderSizePixel = 0
	MainWindow.Parent = ScreenGui
	UI.registerTheme(MainWindow, "BackgroundColor3", "Bg")
	makeCorner(MainWindow, 12)
	makeStroke(MainWindow, "Border", 1.5)

	MainScale = Instance.new("UIScale")
	MainScale.Scale = 1
	MainScale.Parent = MainWindow

	-- Header bar (draggable)
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 44)
	header.BorderSizePixel = 0
	header.Parent = MainWindow
	UI.registerTheme(header, "BackgroundColor3", "Sidebar")
	makeCorner(header, 12)

	local headerBottomFix = Instance.new("Frame")
	headerBottomFix.Position = UDim2.new(0, 0, 1, -10)
	headerBottomFix.Size = UDim2.new(1, 0, 0, 10)
	headerBottomFix.BorderSizePixel = 0
	headerBottomFix.Parent = header
	UI.registerTheme(headerBottomFix, "BackgroundColor3", "Sidebar")

	local logoImg = Instance.new("ImageLabel")
	logoImg.BackgroundTransparency = 1
	logoImg.Position = UDim2.fromOffset(12, 9)
	logoImg.Size = UDim2.fromOffset(26, 26)
	logoImg.ScaleType = Enum.ScaleType.Fit
	logoImg.Image = TRex.loadTRexLogoAsset()
	logoImg.Parent = header
	makeCorner(logoImg, 6)

	TitleLabel = Instance.new("TextLabel")
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Position = UDim2.fromOffset(46, 0)
	TitleLabel.Size = UDim2.new(0.45, 0, 1, 0)
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = header
	UI.registerTheme(TitleLabel, "TextColor3", "Text")
	UI.registerText(TitleLabel, 15, true)

	ProfileBadgeLabel = Instance.new("TextLabel")
	ProfileBadgeLabel.AnchorPoint = Vector2.new(1, 0.5)
	ProfileBadgeLabel.Position = UDim2.new(1, -148, 0.5, 0)
	ProfileBadgeLabel.Size = UDim2.fromOffset(170, 24)
	ProfileBadgeLabel.BorderSizePixel = 0
	ProfileBadgeLabel.TextTruncate = Enum.TextTruncate.AtEnd
	ProfileBadgeLabel.Parent = header
	UI.registerTheme(ProfileBadgeLabel, "BackgroundColor3", "Card")
	UI.registerTheme(ProfileBadgeLabel, "TextColor3", "SubText")
	UI.registerText(ProfileBadgeLabel, 11, true)
	makeCorner(ProfileBadgeLabel, 6)

	local hideBtn = Instance.new("TextButton")
	hideBtn.AnchorPoint = Vector2.new(1, 0.5)
	hideBtn.Position = UDim2.new(1, -46, 0.5, 0)
	hideBtn.Size = UDim2.fromOffset(92, 26)
	hideBtn.AutoButtonColor = false
	hideBtn.BorderSizePixel = 0
	hideBtn.Text = ""
	hideBtn.Parent = header
	UI.registerTheme(hideBtn, "BackgroundColor3", "Card")
	makeCorner(hideBtn, 6)
	makeStroke(hideBtn, "Border", 1)

	HideButtonLabel = Instance.new("TextLabel")
	HideButtonLabel.BackgroundTransparency = 1
	HideButtonLabel.Size = UDim2.fromScale(1, 1)
	HideButtonLabel.Parent = hideBtn
	UI.registerTheme(HideButtonLabel, "TextColor3", "Text")
	UI.registerText(HideButtonLabel, 12, true)
	TRex.bindClick(hideBtn, function()
		UI.setWindowVisible(false)
	end)

	local closeBtn = Instance.new("TextButton")
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.Position = UDim2.new(1, -10, 0.5, 0)
	closeBtn.Size = UDim2.fromOffset(28, 26)
	closeBtn.AutoButtonColor = false
	closeBtn.BackgroundColor3 = Color3.fromRGB(185, 28, 28)
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Text = "×"
	closeBtn.BorderSizePixel = 0
	closeBtn.Parent = header
	UI.registerText(closeBtn, 16, true)
	makeCorner(closeBtn, 6)
	TRex.bindClick(closeBtn, function()
		UI.setWindowVisible(false)
	end)

	-- Dragging MainWindow via header
	local dragWin, dragStartPos, winStartPos = false, nil, nil
	TRex.connectSignal(header.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragWin = true
			dragStartPos = input.Position
			winStartPos = MainWindow.Position
		end
	end)
	TRex.connectSignal(UserInputService.InputChanged, function(input)
		if dragWin and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStartPos
			MainWindow.Position = UDim2.new(winStartPos.X.Scale, winStartPos.X.Offset + delta.X, winStartPos.Y.Scale, winStartPos.Y.Offset + delta.Y)
		end
	end)
	TRex.connectSignal(UserInputService.InputEnded, function(input)
		if dragWin and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragWin = false
		end
	end)

	-- Status Banner
	local statusBar = Instance.new("Frame")
	statusBar.Position = UDim2.fromOffset(10, 50)
	statusBar.Size = UDim2.new(1, -20, 0, 26)
	statusBar.BorderSizePixel = 0
	statusBar.Parent = MainWindow
	UI.registerTheme(statusBar, "BackgroundColor3", "Sidebar")
	makeCorner(statusBar, 7)
	makeStroke(statusBar, "Border", 1)

	StatusDot = Instance.new("Frame")
	StatusDot.AnchorPoint = Vector2.new(0, 0.5)
	StatusDot.Position = UDim2.new(0, 10, 0.5, 0)
	StatusDot.Size = UDim2.fromOffset(8, 8)
	StatusDot.BorderSizePixel = 0
	StatusDot.Parent = statusBar
	makeCorner(StatusDot, 4)

	StatusLabel = Instance.new("TextLabel")
	StatusLabel.BackgroundTransparency = 1
	StatusLabel.Position = UDim2.fromOffset(24, 0)
	StatusLabel.Size = UDim2.new(1, -30, 1, 0)
	StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
	StatusLabel.TextTruncate = Enum.TextTruncate.AtEnd
	StatusLabel.Parent = statusBar
	UI.registerTheme(StatusLabel, "TextColor3", "SubText")
	UI.registerText(StatusLabel, 12, false)
	UI.setStatusBanner("ready", "status.ready")

	-- Body split: Sidebar + ContentArea
	local sidebarFrame = Instance.new("Frame")
	sidebarFrame.Position = UDim2.fromOffset(10, 82)
	sidebarFrame.Size = UDim2.new(0, 168, 1, -92)
	sidebarFrame.BorderSizePixel = 0
	sidebarFrame.Parent = MainWindow
	UI.registerTheme(sidebarFrame, "BackgroundColor3", "Sidebar")
	makeCorner(sidebarFrame, 10)
	makeStroke(sidebarFrame, "Border", 1)
	makePadding(sidebarFrame, 6, 6, 6, 6)

	SidebarScroll = Instance.new("ScrollingFrame")
	SidebarScroll.BackgroundTransparency = 1
	SidebarScroll.Size = UDim2.fromScale(1, 1)
	SidebarScroll.BorderSizePixel = 0
	SidebarScroll.ScrollBarThickness = 3
	SidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	SidebarScroll.Parent = sidebarFrame
	UI.registerTheme(SidebarScroll, "ScrollBarImageColor3", "Accent")

	local sbLayout = Instance.new("UIListLayout")
	sbLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sbLayout.Padding = UDim.new(0, 5)
	sbLayout.Parent = SidebarScroll

	ContentArea = Instance.new("Frame")
	ContentArea.BackgroundTransparency = 1
	ContentArea.Position = UDim2.fromOffset(186, 82)
	ContentArea.Size = UDim2.new(1, -196, 1, -92)
	ContentArea.Parent = MainWindow

	-- Popup layer above MainWindow for unclipped dropdown lists
	PopupLayer = Instance.new("Frame")
	PopupLayer.Name = "PopupLayer"
	PopupLayer.BackgroundTransparency = 1
	PopupLayer.Size = UDim2.fromScale(1, 1)
	PopupLayer.ZIndex = 90
	PopupLayer.Parent = ScreenGui

	-- Close popup if clicking outside
	TRex.connectSignal(UserInputService.InputBegan, function(input)
		if ActivePopup and ActivePopup.Frame and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			local p = input.Position
			local f = ActivePopup.Frame
			local ap, as = f.AbsolutePosition, f.AbsoluteSize
			if p.X < ap.X or p.X > ap.X + as.X or p.Y < ap.Y or p.Y > ap.Y + as.Y then
				task.defer(function()
					if ActivePopup and ActivePopup.Frame == f then
						CloseActivePopup()
					end
				end)
			end
		end
	end)

	-- Toast container (bottom right)
	ToastContainer = Instance.new("Frame")
	ToastContainer.Name = "ToastContainer"
	ToastContainer.BackgroundTransparency = 1
	ToastContainer.AnchorPoint = Vector2.new(1, 1)
	ToastContainer.Position = UDim2.new(1, -16, 1, -16)
	ToastContainer.Size = UDim2.fromOffset(300, 340)
	ToastContainer.ZIndex = 120
	ToastContainer.Parent = ScreenGui

	local toastLayout = Instance.new("UIListLayout")
	toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
	toastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	toastLayout.Padding = UDim.new(0, 6)
	toastLayout.Parent = ToastContainer

	-- Circular draggable overlay button
	CircleOverlay = Instance.new("TextButton")
	CircleOverlay.Name = "ToggleCircle"
	CircleOverlay.Position = UDim2.new(0, 18, 0.5, -24)
	CircleOverlay.Size = UDim2.fromOffset(48, 48)
	CircleOverlay.AutoButtonColor = false
	CircleOverlay.Text = ""
	CircleOverlay.BorderSizePixel = 0
	CircleOverlay.ZIndex = 110
	CircleOverlay.Parent = ScreenGui
	UI.registerTheme(CircleOverlay, "BackgroundColor3", "Sidebar")
	makeCorner(CircleOverlay, 24)
	makeStroke(CircleOverlay, "Accent", 2)

	local overlayIcon = Instance.new("ImageLabel")
	overlayIcon.BackgroundTransparency = 1
	overlayIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	overlayIcon.Position = UDim2.fromScale(0.5, 0.5)
	overlayIcon.Size = UDim2.fromOffset(34, 34)
	overlayIcon.ScaleType = Enum.ScaleType.Fit
	overlayIcon.Image = TRex.loadTRexLogoAsset()
	overlayIcon.ZIndex = 111
	overlayIcon.Parent = CircleOverlay

	OverlayLabel = Instance.new("TextLabel")
	OverlayLabel.BackgroundTransparency = 1
	OverlayLabel.Size = UDim2.fromScale(1, 1)
	OverlayLabel.Text = "T-Rex"
	OverlayLabel.Visible = (overlayIcon.Image == "")
	OverlayLabel.ZIndex = 112
	OverlayLabel.Parent = CircleOverlay
	UI.registerTheme(OverlayLabel, "TextColor3", "Accent")
	UI.registerText(OverlayLabel, 11, true)

	local dragOv, ovStart, ovPos, ovMoved = false, nil, nil, false
	TRex.connectSignal(CircleOverlay.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragOv = true
			ovMoved = false
			ovStart = input.Position
			ovPos = CircleOverlay.Position
		end
	end)
	TRex.connectSignal(UserInputService.InputChanged, function(input)
		if dragOv and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - ovStart
			if d.Magnitude > 6 then
				ovMoved = true
			end
			CircleOverlay.Position = UDim2.new(ovPos.X.Scale, ovPos.X.Offset + d.X, ovPos.Y.Scale, ovPos.Y.Offset + d.Y)
		end
	end)
	TRex.connectSignal(UserInputService.InputEnded, function(input)
		if dragOv and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragOv = false
			if not ovMoved then
				UI.toggleWindow()
			end
		end
	end)

	-- Global ToggleKey / PanicKey listener (with focused TextBox guard)
	TRex.connectSignal(UserInputService.InputBegan, function(input, gameProcessed)
		if gameProcessed or UserInputService:GetFocusedTextBox() then
			return
		end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			local keyName = input.KeyCode.Name
			if keyName == TRex.Config.ToggleKey then
				UI.toggleWindow()
			elseif keyName == TRex.Config.PanicKey and StopAllCallback then
				StopAllCallback()
			end
		end
	end)

	local cam = Workspace.CurrentCamera
	if cam then
		TRex.connectSignal(cam:GetPropertyChangedSignal("ViewportSize"), function()
			UI.applyTypography()
		end)
	end
end

function UI.buildSettingsAndProfileTabs()
	-- Profiles Tab
	local profTab = UI.addTab("profiles", "tab.profiles", 90)
	local profSec = profTab:addSection("sec.profile_manage")
	ProfileInputBox = profSec:addTextInput({
		label = "opt.profile_name",
		placeholderKey = "msg.profile_placeholder",
	})
	ProfileDropdownCtrl = profSec:addDropdown({
		key = "_SelectedProfile",
		label = "opt.select_profile",
		getItems = function()
			return TRex.listProfiles()
		end,
		onChanged = function(selectedName)
			if selectedName and selectedName ~= "" then
				TRex.loadConfig(selectedName)
				UI.refreshAll()
				UI.notify("msg.notice", TRex.t("msg.profile_loaded", { name = selectedName }), 2.5)
			end
		end,
	})
	TRex.Config._SelectedProfile = TRex.CurrentProfileName or "Default"
	profSec:addButton({
		label = "btn.save_profile",
		primary = true,
		onClick = function()
			local name = ProfileInputBox and ProfileInputBox:Get() or ""
			name = name:match("^%s*(.-)%s*$")
			if name == "" then
				name = TRex.CurrentProfileName or "Default"
			end
			TRex.saveConfig(name)
			TRex.Config._SelectedProfile = name
			UI.refreshAll()
			UI.notify("msg.notice", TRex.t("msg.profile_saved", { name = name }), 2.5)
		end,
	})
	profSec:addButton({
		label = "btn.stop_all",
		danger = true,
		onClick = function()
			if StopAllCallback then
				StopAllCallback()
			end
		end,
	})
	profSec:addButton({
		label = "btn.reset_defaults",
		onClick = function()
			for k, v in pairs(TRex.DEFAULT_CONFIG) do
				if type(v) == "table" then
					local copy = {}
					for ik, iv in ipairs(v) do
						copy[ik] = iv
					end
					TRex.Config[k] = copy
				else
					TRex.Config[k] = v
				end
			end
			TRex.saveConfig(TRex.CurrentProfileName)
			UI.refreshAll()
			UI.notify("msg.notice", "msg.reset_done", 2.5)
		end,
	})

	-- Settings Tab
	local setTab = UI.addTab("settings", "tab.settings", 100)
	local appSec = setTab:addSection("sec.appearance")
	appSec:addDropdown({
		key = "Language",
		label = "opt.language",
		items = { "th", "en-us", "vi", "zh" },
		onChanged = function(lang)
			TRex.setLanguage(lang)
			UI.refreshAll()
			UI.notify("msg.notice", "msg.lang_changed", 2.2)
		end,
	})
	appSec:addDropdown({
		key = "Theme",
		label = "opt.theme",
		items = UI.THEME_ORDER,
		onChanged = function()
			UI.applyTheme()
			UI.refreshAll()
		end,
	})
	appSec:addDropdown({
		key = "Font",
		label = "opt.font",
		items = UI.FONT_ORDER,
		onChanged = function()
			UI.applyTypography()
		end,
	})
	appSec:addSlider({
		key = "FontSize",
		label = "opt.font_size",
		min = 10,
		max = 20,
		step = 1,
		onChanged = function()
			UI.applyTypography()
		end,
	})
	appSec:addSlider({
		key = "GuiScalePercent",
		label = "opt.gui_scale",
		min = 70,
		max = 140,
		step = 5,
		unit = "%",
		onChanged = function()
			UI.applyTypography()
		end,
	})
	appSec:addSlider({
		key = "BackgroundTransparency",
		label = "opt.bg_transparency",
		min = 0,
		max = 0.4,
		step = 0.02,
		onChanged = function()
			UI.applyTheme()
		end,
	})
	appSec:addToggle({
		key = "BackgroundBlur",
		label = "opt.bg_blur",
		onChanged = function()
			updateBlur()
		end,
	})

	local keySec = setTab:addSection("sec.hotkeys")
	keySec:addKeybindPicker({ key = "ToggleKey", label = "opt.toggle_key" })
	keySec:addKeybindPicker({ key = "PanicKey", label = "opt.panic_key" })

	local sysSec = setTab:addSection("sec.system_actions")
	sysSec:addButton({
		label = "btn.unload",
		danger = true,
		onClick = function()
			if StopAllCallback then
				pcall(StopAllCallback)
			end
			TRex.cleanup()
		end,
	})
end
