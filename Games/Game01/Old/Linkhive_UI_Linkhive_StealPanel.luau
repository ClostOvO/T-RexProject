
return function(ctx)
	ctx = ctx or {}
	local ui = ctx.ui
	if not (ui and ui.C) then return {} end

	local C = ui.C
	local gui = ctx.gui
	local corner = ui.corner
	local stroke = ui.stroke
	local label = ui.label
	local liveGrad = ui.liveGrad
	local addLivingStroke = ui.addLivingStroke
	local compatRow = ui.compatRow
	local drag = ui.drag
	local TweenService = ui.Tween or game:GetService("TweenService")
	local UIS = (ctx.services and ctx.services.UserInputService) or game:GetService("UserInputService")
	-- A module runs in its own chunk, so bare service globals are nil here.
	local RunService = (ctx.services and ctx.services.RunService) or game:GetService("RunService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local newSignalList = ui.newSignalList or function() return {Connect = function() return {Disconnect = function() end} end, Fire = function() end} end
	local store = ctx.store or {}
	local setStored = ctx.setStored or function() end
	local pathKey = ctx.pathKey or function(_, name) return tostring(name) end

	local LinkhiveLib = ctx.LinkhiveLib
	local addCleanup = ctx.addCleanup
	local autoStealToggle = ctx.autoStealToggle
	local espModule = ctx.espModule
	local generateRandomId = ctx.generateRandomId
	local linkhiveWindow = ctx.linkhiveWindow
	local localPlayer = ctx.localPlayer
	local networking = ctx.networking
	local saeApi = ctx.saeApi
	local stealPriority = ctx.stealPriority
	local stealPriorityOptions = ctx.stealPriorityOptions
	local tbl = ctx.tbl

	local compatSection = {}
	compatSection.__index = compatSection

	local function sectionStartsOpen(cfg)
		return cfg.Expanded ~= false
	end

	function compatSection:CreateSlider(cfg)
		local key = pathKey(self, cfg.Name)
		local minV, maxV = tonumber(cfg.Min) or 0, tonumber(cfg.Max) or 100
		local inc = tonumber(cfg.Increment) or 1
		local value = tonumber(cfg.Default) or minV
		local restored = false
		if type(store[key]) == "number" then value = store[key]; restored = value ~= (tonumber(cfg.Default) or minV) end
		local subs = newSignalList()
		local h = {Name = cfg.Name, Kind = "Slider"}
		local row = compatRow(self, cfg, 40)
		local valBox = Instance.new("TextBox", row)
		valBox.Size = UDim2.new(0, 80, 0, 18); valBox.Position = UDim2.new(1, -88, 0, 4)
		valBox.BackgroundTransparency = 1; valBox.TextColor3 = C.ACCENT2
		valBox.Font = Enum.Font.GothamBold; valBox.TextSize = 10.5
		valBox.TextXAlignment = Enum.TextXAlignment.Right; valBox.ClearTextOnFocus = false
		local track = Instance.new("Frame", row)
		track.Size = UDim2.new(1, -20, 0, 6); track.Position = UDim2.new(0, 10, 1, -12)
		track.BackgroundColor3 = C.TRACKOFF; track.BorderSizePixel = 0; corner(track, 3)
		local fill = Instance.new("Frame", track)
		fill.Size = UDim2.new(0, 0, 1, 0); fill.BackgroundColor3 = C.ACCENT; fill.BorderSizePixel = 0; corner(fill, 3)
		local thumb = Instance.new("Frame", track)
		thumb.Size = UDim2.new(0, 14, 0, 14); thumb.AnchorPoint = Vector2.new(0.5, 0.5)
		thumb.BackgroundColor3 = C.WHITE; thumb.BorderSizePixel = 0; corner(thumb, 7); stroke(thumb, C.ACCENT, 2)
		local function isFocused()
			local ok, r = pcall(function() return valBox:IsFocused() end)
			return ok and r == true
		end
		local paint = function()
			local t = maxV > minV and (value - minV) / (maxV - minV) or 0
			fill.Size = UDim2.new(t, 0, 1, 0); thumb.Position = UDim2.new(t, 0, 0.5, 0)
			if not isFocused() then
				valBox.Text = (inc % 1 ~= 0) and string.format("%g", value) or tostring(math.floor(value + 0.5))
				if cfg.Unit and cfg.Unit ~= "" then valBox.Text = valBox.Text .. " " .. cfg.Unit end
			end
		end
		local dragging = false
		track.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = true end
		end)
		UIS.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
		end)
		UIS.InputChanged:Connect(function(inp)
			if not dragging then return end
			if inp.UserInputType ~= Enum.UserInputType.MouseMovement and inp.UserInputType ~= Enum.UserInputType.Touch then return end
			local a, s = track.AbsolutePosition, track.AbsoluteSize
			local rel = math.clamp((inp.Position.X - a.X) / math.max(s.X, 1), 0, 1)
			h:Set(minV + (maxV - minV) * rel, true)
		end)
		valBox.FocusLost:Connect(function()
			local n = tonumber(string.match(valBox.Text, "-?%d+%.?%d*"))
			if n then h:Set(n, true) else paint() end
		end)
		paint()

		h.Set = function(_, v, fire)
			v = tonumber(v) or value
			v = math.clamp(v, minV, maxV)
			if inc > 0 and inc % 1 == 0 then v = minV + math.floor((v - minV) / inc + 0.5) * inc end
			if v == value then paint(); return end
			value = v
			paint()
			setStored(key, v)
			if fire ~= false and cfg.Callback then task.spawn(cfg.Callback, v) end
			subs.Fire(v)
		end
		function h.Get() return value end
		function h.GetValue() return value end
		function h.Subscribe(_, fn) return subs.Connect(fn) end
		if cfg.Callback and (value or restored) then task.spawn(cfg.Callback, value) end
		return h
	end

	local compatTab = {}
	compatTab.__index = compatTab

	function compatTab:CreateSection(cfg)
		local sec = setmetatable({
			name = cfg.Name, tab = self, window = self.window, mode = "compat", count = 0,
		}, compatSection)
		local page = self.page
		local head = Instance.new("TextButton", page)
		head.Size = UDim2.new(1, 0, 0, 26); head.BackgroundTransparency = 1; head.Text = ""
		self.secCount = (self.secCount or 0) + 1
		head.LayoutOrder = self.secCount * 10
		local accent = Instance.new("Frame", head)
		accent.Size = UDim2.new(0, 3, 0, 14); accent.Position = UDim2.new(0, 2, 0.5, -7)
		accent.BackgroundColor3 = C.MOON; accent.BorderSizePixel = 0; corner(accent, 2)
		local lbl = label(head, tostring(cfg.Name), UDim2.new(1, -30, 1, 0), C.TEXT, Enum.Font.GothamBold)
		lbl.TextSize = 12; lbl.Position = UDim2.new(0, 12, 0, 0)
		local arrow = label(head, ">", UDim2.new(0, 16, 1, 0), C.MOON2, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
		arrow.Position = UDim2.new(1, -18, 0, 0); arrow.TextSize = 10
		local body = Instance.new("Frame", page)
		body.Size = UDim2.new(1, 0, 0, 0); body.AutomaticSize = Enum.AutomaticSize.Y
		body.BackgroundTransparency = 1; body.LayoutOrder = self.secCount * 10 + 1
		local bl = Instance.new("UIListLayout", body)
		bl.Padding = UDim.new(0, 4); bl.SortOrder = Enum.SortOrder.LayoutOrder
		sec.body = body
		local open = sectionStartsOpen(cfg)
		body.Visible = open; arrow.Rotation = open and 90 or 0
		head.MouseButton1Click:Connect(function()
			open = not open; body.Visible = open
			TweenService:Create(arrow, TweenInfo.new(0.16), {Rotation = open and 90 or 0}):Play()
		end)
		return sec
	end
	for _, name in ipairs({"CreateSlider"}) do
		compatTab[name] = function(self, cfg)
			self._default = self._default or self:CreateSection({Name = "General", Expanded = true})
			return self._default[name](self._default, cfg)
		end
	end

	local function newToolWindow(cfg)
		local w = tonumber(cfg.w) or 262
		local h = tonumber(cfg.h) or 410
		local frame = Instance.new("Frame", gui)
		frame.Name = cfg.frameName or ("LinkhiveTool_" .. tostring(cfg.name or "tool"))
		frame.Size = UDim2.new(0, w, 0, h)
		frame.Position = cfg.pos or UDim2.new(1, -(w + 12), 0.5, -math.floor(h / 2))
		frame.BackgroundColor3 = C.BG
		frame.BackgroundTransparency = 0.06
		frame.BorderSizePixel = 0
		frame.Active = true
		frame.ClipsDescendants = true
		frame.Visible = false
		frame.ZIndex = 40
		corner(frame, 10); addLivingStroke(frame, 1.5)

		local header = Instance.new("Frame", frame)
		header.Name = "Header"
		header.Size = UDim2.new(1, 0, 0, 30)
		header.BackgroundColor3 = C.HEADER; header.BackgroundTransparency = 0.15
		header.BorderSizePixel = 0
		corner(header, 10)
		local title = label(header, tostring(cfg.title or "Tool"), UDim2.new(1, -70, 1, 0), C.TEXT, Enum.Font.GothamBold)
		title.Position = UDim2.new(0, 10, 0, 0); title.TextSize = 12
		liveGrad(title)
		local close = Instance.new("TextButton", header)
		close.Size = UDim2.new(0, 20, 0, 20); close.Position = UDim2.new(1, -26, 0.5, -10)
		close.BackgroundColor3 = C.DEEP2; close.Text = "X"; close.TextSize = 10
		close.TextColor3 = C.RED; close.Font = Enum.Font.GothamBold; close.BorderSizePixel = 0
		corner(close, 6); stroke(close, C.BORDER, 1)

		local content = Instance.new("Frame", frame)
		content.Name = "Content"
		content.Size = UDim2.new(1, 0, 1, -30); content.Position = UDim2.new(0, 0, 0, 30)
		content.BackgroundTransparency = 1; content.ClipsDescendants = true

		local page = Instance.new("ScrollingFrame", content)
		page.Name = cfg.tabName or "Tool"
		page.Size = UDim2.new(1, 0, 1, 0)
		page.BackgroundTransparency = 1; page.BorderSizePixel = 0
		page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = C.ACCENT
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		local pl = Instance.new("UIListLayout", page)
		pl.Padding = UDim.new(0, 5); pl.SortOrder = Enum.SortOrder.LayoutOrder
		local pp = Instance.new("UIPadding", page)
		pp.PaddingTop = UDim.new(0, 4); pp.PaddingLeft = UDim.new(0, 6)
		pp.PaddingRight = UDim.new(0, 6); pp.PaddingBottom = UDim.new(0, 10)

		local tab = setmetatable({name = cfg.tabName or "Tool", mode = "compat", page = page}, compatTab)
		local win = {tab = tab, content = content, frame = frame, title = title, name = cfg.name}
		tab.window = win
		win.OnClose = newSignalList()
		win.wantOpen = false
		function win.SetOpen(on)
			on = on == true
			if win.wantOpen == on and frame.Visible == on then return end
			win.wantOpen = on
			frame.Visible = on
			win.OnClose.Fire(on)
		end
		function win.IsOpen() return win.wantOpen end
		function win.Select() win.SetOpen(true) end
		close.MouseButton1Click:Connect(function() win.SetOpen(false) end)
		drag(header, frame)
		return win
	end

	local slideInTime = 3
	local stealScanInterval = 0.002
	local snapshotTimeout = 4
	local slideOvershoot = 1.03
	local tweenInfo3 = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local tweenInfo4 = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local tweenInfo5 = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local TweenService = game:GetService("TweenService")
	local color3 = Color3.fromRGB
	local makeColorSequence

	makeColorSequence = function(keypointList)
		local keypoints = {}

		for i, keypoint in ipairs(keypointList) do
			keypoints[i] = ColorSequenceKeypoint.new(keypoint[1], keypoint[2])
		end

		return ColorSequence.new(keypoints)
	end

	local stealStyles = {}

	do
		local hud = {}
		local hudKeypoints = {}
		local hudStart = { 0, color3(0, 118, 255) }
		local hudEnd = { 1, color3(72, 204, 255) }
		hudKeypoints[1] = hudStart
		hudKeypoints[2] = hudEnd
		hud.Color = makeColorSequence(hudKeypoints)
		hud.Rotation = -90
		hud.Stroke = color3(0, 28, 76)
		hud.Light = color3(172, 226, 255)
		stealStyles.Hud = hud
	end

	do
		local steal = {}
		local stealKeypoints = {}
		local stealStart = { 0, color3(60, 255, 0) }
		local stealEnd = { 1, color3(136, 255, 0) }
		stealKeypoints[1] = stealStart
		stealKeypoints[2] = stealEnd
		steal.Color = makeColorSequence(stealKeypoints)
		steal.Rotation = -90
		steal.Stroke = color3(11, 72, 0)
		steal.Light = color3(190, 255, 180)
		stealStyles.Steal = steal
	end

	do
		local queued = {}
		local queuedKeypoints = {}
		local queuedStart = { 0, color3(118, 118, 132) }
		local queuedEnd = { 1, color3(172, 172, 186) }
		queuedKeypoints[1] = queuedStart
		queuedKeypoints[2] = queuedEnd
		queued.Color = makeColorSequence(queuedKeypoints)
		queued.Rotation = -90
		queued.Stroke = color3(28, 28, 34)
		queued.Light = color3(214, 214, 226)
		stealStyles.Queued = queued
	end

	do
		local priorityOn = {}
		local priorityKeypoints = {}
		local priorityStart = { 0, color3(255, 247, 0) }
		local priorityEnd = { 1, color3(255, 136, 0) }
		priorityKeypoints[1] = priorityStart
		priorityKeypoints[2] = priorityEnd
		priorityOn.Color = makeColorSequence(priorityKeypoints)
		priorityOn.Rotation = 90
		priorityOn.Stroke = color3(0, 0, 0)
		priorityOn.Light = color3(132, 112, 0)
		stealStyles.PriorityOn = priorityOn
	end

	do
		local cancel = {}
		local cancelKeypoints = {}
		local cancelStart = { 0, color3(214, 17, 17) }
		local cancelEnd = { 1, color3(253, 20, 20) }
		cancelKeypoints[1] = cancelStart
		cancelKeypoints[2] = cancelEnd
		cancel.Color = makeColorSequence(cancelKeypoints)
		cancel.Rotation = -90
		cancel.Stroke = color3(72, 0, 0)
		cancel.Light = color3(255, 103, 103)
		stealStyles.Cancel = cancel
	end

	do
		local Linkhive = {}
		local linkhiveKeypoints = {}
		local linkhiveStart = { 0, color3(132, 74, 255) }
		local linkhiveMid1 = { 0.34, color3(178, 74, 255) }
		local linkhiveMid2 = { 0.6, color3(255, 104, 206) }
		local linkhiveMid3 = { 0.78, color3(255, 168, 232) }
		local linkhiveEnd = { 1, color3(146, 66, 255) }
		linkhiveKeypoints[1] = linkhiveStart
		linkhiveKeypoints[2] = linkhiveMid1
		linkhiveKeypoints[3] = linkhiveMid2
		linkhiveKeypoints[4] = linkhiveMid3
		linkhiveKeypoints[5] = linkhiveEnd
		Linkhive.Color = makeColorSequence(linkhiveKeypoints)
		Linkhive.Rotation = -115
		Linkhive.Stroke = color3(44, 10, 80)
		Linkhive.Light = color3(226, 178, 255)
		stealStyles.Linkhive = Linkhive
	end

	do
		local c3 = Color3.fromRGB
		-- Active/selected states must read as part of the yellow Linkhive theme, not as a
		-- dark brown slab: amber fill + dark ink, and a brown accent border for contrast.
		local ACTIVE_FILL = c3(255, 208, 46)
		local ACTIVE_INK = c3(43, 31, 0)
		local SOFT_FILL = c3(255, 233, 168)
		local SOFT_INK = c3(92, 66, 0)
		local function moonStyle(style, a, b, strokeColor, fill, midTint)
			style.Color = ColorSequence.new(a, b)
			style.Rotation = 0
			style.Stroke = strokeColor
			style.StrokeSeq = ColorSequence.new({
				ColorSequenceKeypoint.new(0, strokeColor),
				ColorSequenceKeypoint.new(0.5, strokeColor:Lerp(midTint or c3(58, 42, 0), 0.65)),
				ColorSequenceKeypoint.new(1, strokeColor),
			})
			style.Fill = fill or c3(0, 0, 0)
			style.Light = strokeColor
		end
		local UC = ui.C
		moonStyle(stealStyles.Hud, UC.TEXT, UC.TEXT, UC.BORDER, UC.DEEP1)
		moonStyle(stealStyles.Steal, ACTIVE_INK, ACTIVE_INK, UC.MOON, ACTIVE_FILL, c3(199, 148, 0))
		moonStyle(stealStyles.Queued, UC.TEXT, UC.SILVER, UC.BORDER, UC.ROW)
		moonStyle(stealStyles.PriorityOn, SOFT_INK, SOFT_INK, UC.BORDER, SOFT_FILL, c3(199, 148, 0))
		moonStyle(stealStyles.Cancel, UC.RED, UC.RED, UC.RED, UC.DEEP1)

		LinkhiveLib.ThemeHooks[#LinkhiveLib.ThemeHooks + 1] = function(mapColor, mapSeq)
			for _, st in pairs(stealStyles) do
				if type(st) == "table" then
					for k, v in pairs(st) do
						local t = typeof(v)

						if t == "Color3" then
							st[k] = mapColor(v)
						elseif t == "ColorSequence" then
							st[k] = mapSeq(v)
						end
					end
				end
			end
		end
		LinkhiveLib.RunThemeHooksFrom("Moon")
	end

	local buildEggStyle

	do
		local secretKeypoints = {}
		local secretStart = { 0, color3(255, 255, 255) }
		local secretMid1 = { 0.2, color3(206, 212, 224) }
		local secretMid2 = { 0.42, color3(74, 80, 94) }
		local secretMid3 = { 0.58, color3(42, 46, 56) }
		local secretMid4 = { 0.78, color3(158, 166, 182) }
		local secretEnd = { 1, color3(250, 252, 255) }
		secretKeypoints[1] = secretStart
		secretKeypoints[2] = secretMid1
		secretKeypoints[3] = secretMid2
		secretKeypoints[4] = secretMid3
		secretKeypoints[5] = secretMid4
		secretKeypoints[6] = secretEnd
		local secretSequence = makeColorSequence(secretKeypoints)
		local eggStyleCache = {}
		local rarityGradients = nil

		buildEggStyle = function(assetCategory)
			local cachedStyle = eggStyleCache[assetCategory]
			if cachedStyle then
				return cachedStyle
			end
			local directory = tbl.Assets and tbl.Assets.Directory
			local flag4 = type(directory) == "table" and directory[assetCategory] or nil
			local rarity = type(flag4) == "table" and type(flag4.Rarity) == "table" and flag4.Rarity or nil
			local rarityGradient = rarity and rarity.RarityGradient or nil

			if rarity and typeof(rarityGradient) ~= "Instance" then
				if rarityGradients == nil then
					local assets = ReplicatedStorage:FindFirstChild("Assets")
					assets = assets and assets:FindFirstChild("UI")
					rarityGradients = assets and assets:FindFirstChild("RarityGradients") or false
				end

				rarityGradient = rarityGradients

				if rarityGradients then
					rarityGradient = rarityGradients:FindFirstChild(tostring(rarity._id or rarity.DisplayName or ""))
				end

				rarityGradient = rarityGradient and rarityGradient:FindFirstChild("RarityGradient") or nil
			end

			local str

			if rarity then
				str = tostring(rarity.DisplayName or rarity._id or "")
			else
				str = rarity
			end

			str = str or ""
			local color4 = rarity and typeof(rarity.Color) == "Color3" and rarity.Color or color3(255, 255, 255)
			local color5 = makeColorSequence({ { 0, color4 }, { 1, color4 } })
			local gradientRotation

			if string.upper(str) == "SECRET" then
				gradientRotation = 90
				color5 = secretSequence
			else
				local isUIGradient = typeof(rarityGradient) == "Instance" and rarityGradient:IsA("UIGradient")
				gradientRotation = 90

				if isUIGradient then
					color5 = rarityGradient.Color
					gradientRotation = rarityGradient.Rotation
				end
			end

			local icon = type(flag4) == "table" and flag4.Icon or nil

			if tonumber(icon) then
				icon = "rbxassetid://" .. tostring(icon)
			end

			local styleRecord = {}
			local flag5 = type(flag4) == "table"
			local name

			if flag5 then
				name = tostring(flag4.DisplayName or assetCategory)
			else
				name = flag5
			end

			styleRecord.Name = name or tostring(assetCategory)
			styleRecord.Icon = icon and tostring(icon) or ""
			local rarityNumber

			if rarity then
				rarityNumber = tonumber(rarity.RarityNumber or rarity.Rank)
			else
				rarityNumber = rarity
			end

			styleRecord.RarityNumber = rarityNumber or 0
			styleRecord.GradientColor = color5
			styleRecord.GradientRotation = gradientRotation
			styleRecord.EarningRate = type(flag4) == "table" and tonumber(flag4.EarningRate) or 0
			eggStyleCache[assetCategory] = styleRecord
			return styleRecord
		end
	end

	local computeEggValue

	computeEggValue = function(egg, styleInfo)
		local assetScale = tonumber(egg.AssetScale) or 1
		local scaleFactor = assetScale > 5 and (assetScale / 5) ^ 1.2 * 19.637875755794113 or assetScale ^ 1.85
		local mutations = type(egg.Mutations) == "table" and egg.Mutations or {}

		if #mutations == 0 and type(egg.BaseMutation) == "string" and egg.BaseMutation ~= "" then
			mutations = { egg.BaseMutation }
		end

		local mutations2 = tbl.Mutations
		local flag4 = type(mutations2) == "table" and type(mutations2.EarningsFor) == "function"
		local mutationMultiplier = 1

		if flag4 then
			local ok, result = pcall(mutations2.EarningsFor, mutations)
			ok = ok and type(result) == "number"
			local defaultMultiplier = 1

			if ok then
				mutationMultiplier = result
			else
				mutationMultiplier = defaultMultiplier
			end
		end

		return styleInfo.EarningRate * scaleFactor * mutationMultiplier
	end

	local formatMoney
	local unitSuffixes = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx" }

	formatMoney = function(amount)
		local numericValue = tonumber(amount) or 0
		local suffixIndex = 1

		while numericValue >= 1000 and suffixIndex < #unitSuffixes do
			numericValue /= 1000
			suffixIndex += 1
		end

		local str = suffixIndex == 1 and tostring(math.floor(numericValue)) or string.format("%.1f", math.floor(numericValue * 10) / 10)
		local str2 = unitSuffixes[suffixIndex] .. "/s"
		return "$" .. string.gsub(str, "%.0$", "") .. str2
	end

	local setLabelText

	setLabelText = function(label, text)
		if label and label.Text ~= text then
			label.Text = text
		end
	end

	local flag4 = false
	local panelGeneration = 0
	local hudRefs = nil
	local spareOverlay = nil
	local spareButton = nil
	local imageLabel = nil
	local windowFrame = nil
	local panelFrame = nil
	local position = nil
	local title = nil
	local sparePanelSlot = nil
	local eggListFrame = nil
	local sparePanelFrame = nil
	local flag6 = false
	local panelOpenState = linkhiveWindow:CreateState({ Name = "Steal Panel Open", Default = true })
	local flag7 = false
	local tween = nil
	local tween2 = nil
	local sparePanelTimer = 0
	local toolbar = nil
	local stealPanelRefs = nil
	local spareSortIndex = 1
	local rowByUid = {}
	local recordByUid = {}
	local stealPanelConnections = {}
	local uiStroke, thickness, flag8, flag9, flag10, ensureStealPanel, findGameHudRefs, cloneWithoutScripts, scrambleNames, uiMetrics
	local applyStrokeRatios, refreshStrokeRatios

	do
		local obj = setmetatable({}, { __mode = "k" })
		uiStroke = nil
		thickness = nil
		flag8 = false
		flag9 = false
		flag10 = false
		ensureStealPanel = nil

		findGameHudRefs = function()
			local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
			local hud = playerGui and playerGui:FindFirstChild("HUD")
			local gameHUD = hud and hud:FindFirstChild("GameHUD")
			local rightButtons = gameHUD and gameHUD:FindFirstChild("RightButtons")
			local activePets = playerGui and playerGui:FindFirstChild("ActivePets")

			local hudElementRefs = {
				Hud = hud,
				GameHud = gameHUD,
				Column = rightButtons,
				Eggs = rightButtons and rightButtons:FindFirstChild("EggsButton"),
				Pets = rightButtons and rightButtons:FindFirstChild("PetsButton"),
				ActivePets = activePets,
				GrowingEggs = playerGui and playerGui:FindFirstChild("GrowingEggs"),
			}

			if not (hud and gameHUD and rightButtons and hudElementRefs.Eggs and hudElementRefs.Pets and activePets and activePets:FindFirstChild("Frame")) then
				return nil
			end
			return hudElementRefs
		end

		cloneWithoutScripts = function(sourceInst)
			local ok, result = pcall(function()
				return sourceInst:Clone()
			end)

			if not ok or typeof(result) ~= "Instance" then
				return nil
			end

			for _, descendant in ipairs(result:GetDescendants()) do
				if descendant:IsA("LuaSourceContainer") then
					descendant:Destroy()
				end
			end

			return result
		end

		scrambleNames = function(targetInst)
			targetInst.Name = generateRandomId()

			for _, descendant in ipairs(targetInst:GetDescendants()) do
				descendant.Name = generateRandomId()
			end
		end

		local basePanelThickness = 2.3120369911193848
		local panelRefWidth = 556
		local buttonRefWidth = 86.24
		uiMetrics = { Panel = basePanelThickness, Hud = basePanelThickness }

		local function computeStrokeThickness(usePanelWidth)
			if usePanelWidth then
				local x = panelFrame and panelFrame.AbsoluteSize.X or 0
				return x > 0 and basePanelThickness * x / panelRefWidth or nil
			end
			local button = spareButton and spareButton.Button
			button = button and button.Size.X.Offset or 0
			return button > 0 and basePanelThickness * button / buttonRefWidth or nil
		end

		local function applyStrokeThickness(strokeInst, ratioInfo)
			local thickness = computeStrokeThickness(ratioInfo.Panel)

			if thickness and strokeInst.Parent then
				strokeInst.Thickness = ratioInfo.Ratio * thickness
			end
		end

		applyStrokeRatios = function(rootInst, usePanel)
			local panel = usePanel and uiMetrics.Panel or uiMetrics.Hud

			if not panel or panel <= 0 then
				panel = 2.3120369911193848
			end

			for _, descendant in ipairs(rootInst:GetDescendants()) do
				if descendant:IsA("UIStroke") then
					local ok, result = pcall(function()
						return descendant.StrokeSizingMode
					end)

					if not ok or result ~= Enum.StrokeSizingMode.ScaledSize then
						local ratioRecord = { Ratio = descendant.Thickness / panel, Panel = usePanel == true }
						obj[descendant] = ratioRecord
						applyStrokeThickness(descendant, ratioRecord)
					end
				end
			end
		end

		refreshStrokeRatios = function()
			for k, storedRatio in pairs(obj) do
				applyStrokeThickness(k, storedRatio)
			end
		end
	end

	local applyStyle

	local function applyStyleImpl(widget, style)
		if not widget or widget.Style == style then
			return
		end
		local hadStyle = widget.Style ~= nil
		widget.Style = style
		if hadStyle and widget.Pulse then
			task.spawn(widget.Pulse)
		end

		if widget.Gradient then
			widget.Gradient.Color = style.Color
			widget.Gradient.Rotation = style.Rotation
		end

		if widget.Stroke then
			if widget.Stroke:IsA("UIGradient") then
				widget.Stroke.Color = style.StrokeSeq or ColorSequence.new(style.Stroke)
			else
				widget.Stroke.Color = style.Stroke
			end
		end

		if style.Fill and widget.Button then
			widget.Button.BackgroundColor3 = style.Fill
		end

		if widget.Light then
			widget.Light.Color = style.Light
		end
	end
	applyStyle = applyStyleImpl

	local setupHoverFx

	local function setupHoverFxImpl(buttonWidget)
		if not buttonWidget then
			return
		end
		local scale = buttonWidget.Scale

		if not scale then
			scale = Instance.new("UIScale")
			scale.Parent = buttonWidget.Button
			buttonWidget.Scale = scale
		end

		local function tweenScale(scaleValue)
			TweenService:Create(scale, tweenInfo5, { Scale = scaleValue }):Play()
		end

		buttonWidget.Button.MouseEnter:Connect(function()
			tweenScale(1.08)
		end)

		buttonWidget.Button.MouseLeave:Connect(function()
			tweenScale(1)
		end)

		buttonWidget.Button.MouseButton1Down:Connect(function()
			tweenScale(0.94)
		end)

		buttonWidget.Button.MouseButton1Up:Connect(function()
			tweenScale(1.08)
		end)
	end
	setupHoverFx = setupHoverFxImpl

	local playShimmer

	do
		local tweenInfo6 = TweenInfo.new(2.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		local tweenInfo7 = TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		local tweenInfo8 = TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		local activeShimmerTweens = {}

		local function playShimmerImpl(styledWidget)
			for _, shimmerTween in ipairs(activeShimmerTweens) do
				pcall(function()
					shimmerTween:Cancel()
				end)
			end

			table.clear(activeShimmerTweens)
			if not styledWidget or LinkhiveLib.NoAnim then
				return
			end

			local function trackTween(tween3)
				activeShimmerTweens[#activeShimmerTweens + 1] = tween3
				tween3:Play()
			end

			local gradient = styledWidget.Gradient

			if gradient then
				gradient.Rotation = -115
				gradient.Offset = Vector2.new(-0.30000001192092896, 0)
				trackTween(TweenService:Create(gradient, tweenInfo6, { Offset = Vector2.new(0.30000001192092896, 0) }))
				trackTween(TweenService:Create(gradient, tweenInfo7, { Rotation = -65 }))
			end

			local light = styledWidget.Light

			if light then
				light.Color = color3(255, 233, 168)
				trackTween(TweenService:Create(light, tweenInfo8, { Color = color3(255, 252, 235) }))
			end
		end
		playShimmer = playShimmerImpl
	end

	do
		local setIdentity = setthreadidentity or set_thread_identity

		local function readFieldRecords()
			local eggState = tbl.EggState

			if type(eggState) == "table" and type(eggState.ReadFieldEggs) == "function" then
				local records = nil

				task.spawn(function()
					local ok, result = pcall(eggState.ReadFieldEggs)

					if ok and type(result) == "table" and type(result.Records) == "table" and next(result.Records) ~= nil then
						records = result.Records
					end
				end)

				if type(setIdentity) == "function" then
					pcall(setIdentity, 8)
				end

				if records then
					return records
				end
			end

			local rfEggWorldAskFieldEggSnapshot = networking:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
			if not rfEggWorldAskFieldEggSnapshot or not rfEggWorldAskFieldEggSnapshot:IsA("RemoteFunction") then
				return nil
			end
			local flag11 = false
			local records = nil

			task.spawn(function()
				local ok, result = pcall(rfEggWorldAskFieldEggSnapshot.InvokeServer, rfEggWorldAskFieldEggSnapshot)

				if ok and type(result) == "table" and type(result.Records) == "table" then
					records = result.Records
				end

				flag11 = true
			end)

			local now = os.clock()

			while not flag11 and os.clock() - now < snapshotTimeout do
				RunService.Heartbeat:Wait()
			end

			return records
		end

		local function isGrowingEggsOpen()
			local flag11 = hudRefs ~= nil

			if flag11 then
				flag11 = hudRefs.ActivePets and hudRefs.ActivePets.Enabled or hudRefs.GrowingEggs and hudRefs.GrowingEggs.Enabled
			end

			return flag11 or false
		end

		local function slideHudColumn(slideOut, instant)
			local column = hudRefs and hudRefs.Column
			if not column or not column.Parent then
				return
			end

			if tween2 then
				tween2:Cancel()
				tween2 = nil
			end

			local position2 = column.Position
			local udim2 = UDim2.new(position2.X.Scale, slideOut and math.ceil(column.AbsoluteSize.X * slideOvershoot) or 0, position2.Y.Scale, position2.Y.Offset)
			if instant then
				column.Position = udim2
				return
			end
			tween2 = TweenService:Create(column, slideOut and tweenInfo3 or tweenInfo4, { Position = udim2 })
			tween2:Play()
		end

		local unusedScanDelay = 0.106

		local function setButtonVisible(targetRow, visible)
			if targetRow and targetRow.Button.Visible ~= visible then
				targetRow.Button.Visible = visible
			end
		end

		local function updateRowRank(row, rank, badgeStyle, totalCount)
			local visible = rank ~= nil
			row.Rank = rank
			setButtonVisible(row.Steal, not visible)
			setButtonVisible(row.Up, visible)
			setButtonVisible(row.Down, visible)
			setButtonVisible(row.Cancel, visible)

			if visible then
				applyStyle(row.Up, rank > 1 and stealStyles.Hud or stealStyles.Queued)
				applyStyle(row.Down, rank < (totalCount or rank) and stealStyles.Hud or stealStyles.Queued)
			end

			applyStyle(row.Star, rank == 1 and stealStyles.PriorityOn or stealStyles.Queued)

			if row.Badge then
				if row.Badge.Visible ~= visible then
					row.Badge.Visible = visible
				end

				if visible then
					setLabelText(row.Badge, "#" .. rank)
					badgeStyle = badgeStyle and stealStyles.Steal or stealStyles.PriorityOn

					if row.BadgeStyle ~= badgeStyle and row.BadgeGradient then
						row.BadgeStyle = badgeStyle
						row.BadgeGradient.Color = badgeStyle.Color
						row.BadgeGradient.Rotation = 90
					end
				end
			end
		end

		local flagReady = false
		local win = nil

		local function syncToolbar()
			if not toolbar then
				return
			end
			local autoStealOn = saeApi.Toggle(autoStealToggle, false)

			if toolbar.On ~= autoStealOn then
				toolbar.On = autoStealOn
				toolbar.ToggleHandle:Set(autoStealOn, false)
			end

			local method = saeApi.Method.Current()

			if toolbar.Mode ~= method then
				toolbar.Mode = method
				toolbar.GuardHandle:Set(method)
				local methodHandle = saeApi.SafeCarry.MethodHandle

				if saeApi.MethodReady and methodHandle and type(methodHandle.Set) == "function" then
					pcall(methodHandle.Set, methodHandle, method, false)
				end
			end

			if toolbar.SortShown ~= stealPriority then
				toolbar.SortShown = stealPriority
				toolbar.SortHandle.SetText(tostring(stealPriority))
			end
		end

		local cancelCooldown = 4
		local cancelUntilByUid = {}
		local orderByUid = {}

		local function rebuildRows()
			if not eggListFrame then
				return
			end
			syncToolbar()
			local sortedRows = {}

			for _, record in pairs(recordByUid) do
				table.insert(sortedRows, record)
			end

			local planOrder = {}
			local planHeroUid = nil

			if type(saeApi.StealPlan) == "function" then
				task.spawn(function()
					local ok, result, result2 = pcall(saeApi.StealPlan)

					if ok and type(result) == "table" then
						planOrder = result
						planHeroUid = result2
					end
				end)
			end

			local planIndexByUid = {}

			for i, planUid in ipairs(planOrder) do
				if planIndexByUid[planUid] == nil then
					planIndexByUid[planUid] = i
				end
			end

			local sortMode = stealPriority

			table.sort(sortedRows, function(rowA, rowB)
				local indexA = planIndexByUid[rowA.Uid]
				local indexB = planIndexByUid[rowB.Uid]
				if indexA ~= nil ~= (indexB ~= nil) then
					return indexA ~= nil
				end

				if indexA and indexB then
					return indexA < indexB
				end

				if sortMode == stealPriorityOptions[1] and rowA.Style.RarityNumber ~= rowB.Style.RarityNumber then
					return rowA.Style.RarityNumber > rowB.Style.RarityNumber
				end
				local flag11 = sortMode == stealPriorityOptions[2]

				if flag11 then
					flag11 = (rowA.Weight or 0) ~= (rowB.Weight or 0)
				end

				if flag11 then
					return (rowA.Weight or 0) > (rowB.Weight or 0)
				end

				if sortMode == stealPriorityOptions[5] and rowA.Value ~= rowB.Value then
					return rowA.Value < rowB.Value
				end

				if rowA.Value ~= rowB.Value then
					return rowA.Value > rowB.Value
				end
				return rowA.Uid < rowB.Uid
			end)

			local now = os.clock()
			local unpinnedRows = {}
			local pinnedRows = {}

			for _, sortedRow in ipairs(sortedRows) do
				local cancelUntil = cancelUntilByUid[sortedRow.Uid]

				if cancelUntil and cancelUntil > now and orderByUid[sortedRow.Uid] then
					table.insert(pinnedRows, sortedRow)
				else
					cancelUntilByUid[sortedRow.Uid] = nil
					table.insert(unpinnedRows, sortedRow)
				end
			end

			table.sort(pinnedRows, function(pinnedA, pinnedB)
				return orderByUid[pinnedA.Uid] < orderByUid[pinnedB.Uid]
			end)

			for _, pinnedRow in ipairs(pinnedRows) do
				table.insert(unpinnedRows, math.clamp(orderByUid[pinnedRow.Uid], 1, #unpinnedRows + 1), pinnedRow)
			end

			table.clear(orderByUid)

			for i, unpinnedRow in ipairs(unpinnedRows) do
				orderByUid[unpinnedRow.Uid] = i
				local rowUi = rowByUid[unpinnedRow.Uid]

				if rowUi then
					if rowUi.Frame.LayoutOrder ~= i then
						rowUi.Frame.LayoutOrder = i
					end

					updateRowRank(rowUi, planIndexByUid[unpinnedRow.Uid], unpinnedRow.Uid == planHeroUid, #planOrder)
				end
			end
		end

		local function mkBtn(parent, text, size, pos, anchor, style)
			local U = ui
			local button = Instance.new("TextButton")
			button.AutoButtonColor = false
			button.BackgroundColor3 = U.C.ROW
			button.BackgroundTransparency = 0.05
			button.BorderSizePixel = 0
			button.Text = ""
			button.Size = size
			button.Position = pos or UDim2.new()
			button.AnchorPoint = anchor or Vector2.new(0, 0)
			button.ZIndex = 3
			U.corner(button, 8)
			local liveStroke = U.addLivingStroke(button, 1)
			liveStroke.Color = U.C.DEEP4
			local strokeObj = liveStroke:FindFirstChildOfClass("UIGradient")
			local gradient = Instance.new("UIGradient")
			local lbl = Instance.new("TextLabel")
			lbl.Name = "Label"
			lbl.BackgroundTransparency = 1
			lbl.Size = UDim2.fromScale(1, 1)
			lbl.Font = Enum.Font.GothamBold
			lbl.TextSize = 10
			lbl.TextColor3 = U.C.TEXT
			lbl.Text = text or ""
			lbl.ZIndex = 4
			lbl.Parent = button
			gradient.Parent = lbl
			local scale = Instance.new("UIScale")
			scale.Parent = button
			button.Parent = parent

			local function bounce(value, time, easing)
				TweenService:Create(scale, TweenInfo.new(time, easing or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = value }):Play()
			end

			button.MouseButton1Down:Connect(function()
				bounce(0.92, 0.08)
			end)
			button.MouseButton1Up:Connect(function()
				bounce(1, 0.22, Enum.EasingStyle.Back)
			end)
			button.MouseLeave:Connect(function()
				bounce(1, 0.15)
			end)

			local w = { Button = button, Gradient = gradient, Stroke = strokeObj, Label = lbl }
			w.Pulse = function()
				scale.Scale = 1.14
				bounce(1, 0.38, Enum.EasingStyle.Back)
			end

			if style then
				applyStyle(w, style)
			end
			return w
		end

		local function createRow(uid)
			local U = ui
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 52)
			row.BackgroundColor3 = U.C.ROW
			row.BackgroundTransparency = 0.15
			row.BorderSizePixel = 0
			U.corner(row, 8)
			U.addLivingStroke(row, 1)

			local rowScale = Instance.new("UIScale")
			rowScale.Scale = 0.9
			rowScale.Parent = row

			local accent = Instance.new("Frame")
			accent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			accent.BorderSizePixel = 0
			accent.Position = UDim2.new(0, 4, 0.5, -16)
			accent.Size = UDim2.fromOffset(3, 32)
			accent.ZIndex = 2
			U.corner(accent, 2)
			local accentGradient = Instance.new("UIGradient")
			accentGradient.Rotation = 90
			accentGradient.Parent = accent
			accent.Parent = row

			local iconHolder = Instance.new("Frame")
			iconHolder.BackgroundColor3 = U.C.DEEP1
			iconHolder.BorderSizePixel = 0
			iconHolder.Position = UDim2.new(0, 11, 0.5, -18)
			iconHolder.Size = UDim2.fromOffset(36, 36)
			iconHolder.ZIndex = 2
			U.corner(iconHolder, 9)
			iconHolder.Parent = row

			local icon = Instance.new("ImageLabel")
			icon.BackgroundTransparency = 1
			icon.AnchorPoint = Vector2.new(0.5, 0.5)
			icon.Position = UDim2.fromScale(0.5, 0.5)
			icon.Size = UDim2.fromScale(0.92, 0.92)
			icon.ScaleType = Enum.ScaleType.Fit
			icon.ZIndex = 3
			icon.Parent = iconHolder

			local nameLabel = Instance.new("TextLabel")
			nameLabel.BackgroundTransparency = 1
			nameLabel.Position = UDim2.new(0, 54, 0, 4)
			nameLabel.Size = UDim2.new(1, -60, 0, 14)
			nameLabel.Font = Enum.Font.GothamBold
			nameLabel.TextSize = 11
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
			nameLabel.TextColor3 = U.C.TEXT
			nameLabel.Text = ""
			nameLabel.ZIndex = 2
			nameLabel.Parent = row
			local nameGradient = Instance.new("UIGradient")
			nameGradient.Parent = nameLabel
			if U.Shimmer then U.Shimmer(nameGradient) end

			local valueLabel = Instance.new("TextLabel")
			valueLabel.BackgroundTransparency = 1
			valueLabel.Position = UDim2.new(0, 54, 0, 18)
			valueLabel.Size = UDim2.fromOffset(70, 13)
			valueLabel.Font = Enum.Font.GothamBold
			valueLabel.TextSize = 10
			valueLabel.TextXAlignment = Enum.TextXAlignment.Left
			valueLabel.TextColor3 = Color3.fromRGB(30, 122, 60)
			valueLabel.Text = ""
			valueLabel.ZIndex = 2
			valueLabel.Parent = row

			local detailLabel = Instance.new("TextLabel")
			detailLabel.BackgroundTransparency = 1
			detailLabel.Position = UDim2.new(0, 126, 0, 18)
			detailLabel.Size = UDim2.new(1, -132, 0, 13)
			detailLabel.Font = Enum.Font.GothamMedium
			detailLabel.TextSize = 9
			detailLabel.TextXAlignment = Enum.TextXAlignment.Left
			detailLabel.TextTruncate = Enum.TextTruncate.AtEnd
			detailLabel.TextColor3 = U.C.SILVER2
			detailLabel.Text = ""
			detailLabel.ZIndex = 2
			detailLabel.Parent = row

			local badge = Instance.new("TextLabel")
			badge.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			badge.BorderSizePixel = 0
			badge.Position = UDim2.new(0, 5, 0, 2)
			badge.Size = UDim2.fromOffset(24, 13)
			badge.Font = Enum.Font.GothamBold
			badge.TextSize = 9.5
			badge.TextColor3 = Color3.fromRGB(20, 14, 0)
			badge.Text = "#1"
			badge.Visible = false
			badge.ZIndex = 6
			U.corner(badge, 6)
			local badgeGradient = Instance.new("UIGradient")
			badgeGradient.Parent = badge
			badge.Parent = row

			local rowWidget = {
				Uid = uid,
				Rank = nil,
				Frame = row,
				Icon = icon,
				Label = nameLabel,
				ValueLabel = valueLabel,
				DetailLabel = detailLabel,
				Gradient = nameGradient,
				AccentGradient = accentGradient,
				Badge = badge,
				BadgeGradient = badgeGradient,
			}

			rowWidget.Steal = mkBtn(row, "Steal", UDim2.fromOffset(54, 20), UDim2.new(1, -6, 0, 38), Vector2.new(1, 0.5), stealStyles.Steal)
			rowWidget.Cancel = mkBtn(row, "X", UDim2.fromOffset(22, 20), UDim2.new(1, -6, 0, 38), Vector2.new(1, 0.5), stealStyles.Cancel)
			rowWidget.Down = mkBtn(row, "v", UDim2.fromOffset(22, 20), UDim2.new(1, -30, 0, 38), Vector2.new(1, 0.5), stealStyles.Hud)
			rowWidget.Up = mkBtn(row, "^", UDim2.fromOffset(22, 20), UDim2.new(1, -54, 0, 38), Vector2.new(1, 0.5), stealStyles.Hud)
			rowWidget.Star = mkBtn(row, "TOP", UDim2.fromOffset(30, 20), UDim2.new(1, -78, 0, 38), Vector2.new(1, 0.5), stealStyles.Queued)
			rowWidget.Cancel.Button.Visible = false
			rowWidget.Down.Button.Visible = false
			rowWidget.Up.Button.Visible = false
			rowWidget.Star.Label.TextSize = 8.5
			rowWidget.Steal.Label.TextSize = 9.5

			for _, moveBtn in ipairs({ { rowWidget.Up, -1 }, { rowWidget.Down, 1 } }) do
				moveBtn[1].Button.Activated:Connect(function()
					if type(saeApi.MoveInPlan) == "function" then
						saeApi.MoveInPlan(rowWidget.Uid, moveBtn[2])
					end

					saeApi.UiDefer(rebuildRows)
				end)
			end

			rowWidget.Steal.Button.Activated:Connect(function()
				if rowWidget.Rank == nil and type(saeApi.StealNow) == "function" then
					saeApi.StealNow(rowWidget.Uid, false)
				end

				saeApi.UiDefer(rebuildRows)
			end)

			rowWidget.Cancel.Button.Activated:Connect(function()
				cancelUntilByUid[rowWidget.Uid] = os.clock() + cancelCooldown

				if type(saeApi.CancelSteal) == "function" then
					saeApi.CancelSteal(rowWidget.Uid)
				end

				saeApi.UiDefer(rebuildRows)
			end)

			rowWidget.Star.Button.Activated:Connect(function()
				if type(saeApi.PrioritizeSteal) == "function" then
					saeApi.PrioritizeSteal(rowWidget.Uid)
				end

				saeApi.UiDefer(rebuildRows)
			end)

			row.Parent = eggListFrame
			TweenService:Create(rowScale, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
			return rowWidget
		end

		local function updateRow(rowState, recordData)
			local style = recordData.Style

			if rowState.Category ~= recordData.Category then
				rowState.Category = recordData.Category

				if rowState.Icon then
					rowState.Icon.Image = style.Icon
				end

				if rowState.Gradient then
					rowState.Gradient.Color = style.GradientColor
					rowState.Gradient.Rotation = style.GradientRotation
					if rowState.AccentGradient then
						rowState.AccentGradient.Color = style.GradientColor
					end
				end
			end

			setLabelText(rowState.Label, style.Name)
			setLabelText(rowState.ValueLabel, formatMoney(recordData.Value))
			setLabelText(rowState.DetailLabel, recordData.Detail or "")
		end

		local function formatWeight(weight)
			local weightValue = tonumber(weight) or 0
			local str = weightValue >= 1000 and string.format("%.0f", weightValue) or string.format("%.2f", weightValue)
			local intPart, decPart = string.match(str, "^(%-?%d+)(%.%d+)$")
			intPart = intPart or str
			local formatted

			while true do
				local subCount
				formatted, subCount = string.gsub(intPart, "^(%-?%d+)(%d%d%d)", "%1,%2")

				if subCount == 0 then
					break
				else
					intPart = formatted
				end
			end

			return formatted .. (decPart or "") .. " Kg"
		end

		local function formatDetail(categoryId, scale)
			local str = string.format("x%.2f", scale)
			local eggRecords = tbl.EggRecords
			local flag11 = type(eggRecords) == "table" and type(eggRecords.WeightKgForScale) == "function"
			local weightKg = 0

			if flag11 then
				local ok, result = pcall(eggRecords.WeightKgForScale, categoryId, scale)

				if ok and tonumber(result) then
					weightKg = tonumber(result)
					str ..= "  " .. utf8.char(183) .. "  " .. formatWeight(result)
				end
			end

			return str, weightKg
		end

		local schedulePanelRefresh = nil

		local function refreshRecords(generation)
			local records = readFieldRecords()

			if records and generation == panelGeneration and flag4 then
				local seenUids = {}
				local now = os.clock()
				local bestValue = -1
				local bestRecord = nil

				for _, fieldRecord in pairs(records) do
					local uid = type(fieldRecord) == "table" and fieldRecord.Uid or nil
					local flag11 = fieldRecord.State == "Slot" or fieldRecord.State == "Dropped" or fieldRecord.State == "Carried"

					if type(uid) == "string" and flag11 and type(fieldRecord.AssetCategory) == "string" then
						seenUids[uid] = true
						local eggStyle = buildEggStyle(fieldRecord.AssetCategory)
						local recordEntry = recordByUid[uid]

						if not recordEntry then
							recordEntry = { Uid = uid }
							recordByUid[uid] = recordEntry
						end

						local scale = tonumber(fieldRecord.AssetScale) or 1

						if recordEntry.Detail == nil or recordEntry.Scale ~= scale or recordEntry.Category ~= fieldRecord.AssetCategory then
							recordEntry.Scale = scale
							local detailText, weightKgResult = formatDetail(fieldRecord.AssetCategory, scale)
							recordEntry.Detail = detailText
							recordEntry.Weight = weightKgResult
						end

						recordEntry.Category = fieldRecord.AssetCategory
						recordEntry.Style = eggStyle
						recordEntry.Value = computeEggValue(fieldRecord, eggStyle)
						recordEntry.Position = typeof(fieldRecord.BottomCFrame) == "CFrame" and fieldRecord.BottomCFrame.Position or nil

						if (fieldRecord.State == "Slot" or fieldRecord.State == "Dropped") and eggStyle.Icon ~= "" and recordEntry.Value > bestValue then
							bestValue = recordEntry.Value
							bestRecord = recordEntry
						end

						if flag6 and eggListFrame then
							local existingRowUi = rowByUid[uid]

							if not existingRowUi then
								local createdRow = createRow(uid)
								rowByUid[uid] = createdRow
								existingRowUi = createdRow
							end

							updateRow(existingRowUi, recordEntry)
						end
					end

					if not (stealScanInterval < os.clock() - now) then
						continue
					end
					RunService.Heartbeat:Wait()
					now = os.clock()
					if generation ~= panelGeneration or not flag4 then
						return
					end
				end

				for k in pairs(recordByUid) do
					if not seenUids[k] then
						recordByUid[k] = nil
						local staleRow = rowByUid[k]

						if staleRow then
							rowByUid[k] = nil
							staleRow.Frame:Destroy()
						end
					end
				end

				if imageLabel and bestRecord and imageLabel.Image ~= bestRecord.Style.Icon then
					imageLabel.Image = bestRecord.Style.Icon
				elseif imageLabel and not bestRecord then
					imageLabel.Image = ""
				end

				local hero = saeApi.Hero
				if hero and hero.Name and hero.Name.Parent then
					hero.Name.Text = bestRecord and tostring(bestRecord.Style.Name) or "None"

					hero.Value.Text = bestRecord and formatMoney(bestRecord.Value) or ""
				end

				rebuildRows()
			end
		end

		local lastRefreshAt = 0

		local function refreshPanel(refreshGeneration)
			if flag9 and os.clock() - lastRefreshAt < 10 then
				flag10 = true
				return
			end
			flag9 = true
			lastRefreshAt = os.clock()
			pcall(refreshRecords, refreshGeneration)

			if lastRefreshAt == lastRefreshAt then
				flag9 = false
			end

			if flag10 then
				flag10 = false
				schedulePanelRefresh()
			end
		end

		schedulePanelRefresh = function()
			if flag8 or not flag4 then
				return
			end
			flag8 = true
			local scheduledGeneration = panelGeneration

			task.delay(flag6 and 0.3 or 1, function()
				flag8 = false

				if flag4 and scheduledGeneration == panelGeneration then
					task.spawn(pcall, refreshPanel, scheduledGeneration)
				end
			end)
		end

		local function openStealPanel(selectTab)
			if not win then
				return
			end
			flag6 = true

			if selectTab then
				panelOpenState:Set(true)
			end

			win.SetOpen(true)
			if win.frame then
				win.frame.Visible = true
			end
			task.spawn(pcall, refreshPanel, panelGeneration)
		end

		local function closeStealPanel(panelOpenState2, syncToggleState)
			if not flag6 or not win then
				return
			end
			flag6 = false

			if syncToggleState then
				panelOpenState:Set(false)
			end

			win.SetOpen(false)
		end

		local function buildStealPanel()
			local U = ui
			win = newToolWindow({
				name = "steal",
				tabName = "StealPanel",
				frameName = "LinkhiveSteal",
				title = "Steal Panel",
				tabTitle = "Steal",
				w = 262,
				h = 410,
				pos = UDim2.new(1, -274, 0.5, -math.floor(math.min(410, math.max(240, ((workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.Y) or 600) - 60)) / 2)),
			})
			local tab = win.tab

			local page = tab.page
			local bar = Instance.new("Frame")
			bar.Name = "Bar"
			bar.BackgroundTransparency = 1
			bar.Size = UDim2.new(1, 0, 0, 82)
			bar.Position = UDim2.new(0, 0, 0, 66)
			bar.Parent = win.content
			page.Position = UDim2.new(0, 0, 0, 148)
			page.Size = UDim2.new(1, 0, 1, -148)

			local hero = Instance.new("Frame")
			hero.Name = "Hero"
			hero.BackgroundColor3 = U.C.ROW
			hero.BackgroundTransparency = 0.15
			hero.BorderSizePixel = 0
			hero.Position = UDim2.new(0, 8, 0, 4)
			hero.Size = UDim2.new(1, -16, 0, 58)
			U.corner(hero, 12)
			U.addLivingStroke(hero, 1)
			hero.Parent = win.content
			local heroIcon = Instance.new("ImageLabel")
			heroIcon.BackgroundTransparency = 1
			heroIcon.Position = UDim2.new(0, 6, 0, 3)
			heroIcon.Size = UDim2.fromOffset(52, 52)
			heroIcon.ScaleType = Enum.ScaleType.Fit
			heroIcon.Image = ""
			heroIcon.Parent = hero
			local heroTag = U.label(hero, "STRONGEST EGG", UDim2.new(1, -70, 0, 12), U.C.SILVER, Enum.Font.GothamBold)
			heroTag.Position = UDim2.new(0, 64, 0, 6)
			heroTag.TextSize = 8.5
			local heroName = U.label(hero, "None", UDim2.new(1, -70, 0, 18), U.C.TEXT, Enum.Font.GothamBold)
			heroName.Position = UDim2.new(0, 64, 0, 19)
			heroName.TextSize = 13
			heroName.TextTruncate = Enum.TextTruncate.AtEnd
			local heroValue = U.label(hero, "", UDim2.new(1, -70, 0, 14), Color3.fromRGB(30, 122, 60), Enum.Font.GothamBold)
			heroValue.Position = UDim2.new(0, 64, 0, 38)
			heroValue.TextSize = 11
			imageLabel = heroIcon
			saeApi.Hero = { Name = heroName, Value = heroValue }

			local function makeSwitchButton(text, pos, onChange)
				local btn = mkBtn(bar, text .. ": OFF", UDim2.new(0.5, -11, 0, 26), pos, nil, stealStyles.Queued)
				btn.Label.TextSize = 10
				local obj = { State = false }

				function obj:Set(v)
					v = v == true

					if v == self.State then
						return
					end
					self.State = v
					applyStyle(btn, v and stealStyles.Steal or stealStyles.Queued)
					btn.Label.Text = text .. (v and ": ON" or ": OFF")
				end

				btn.Button.Activated:Connect(function()
					onChange(not obj.State)
				end)

				return obj
			end

			local toggleHandle = makeSwitchButton("Auto Steal", UDim2.new(0, 8, 0, 4), function(v)
				local handle = autoStealToggle

				if handle and type(handle.Set) == "function" then
					pcall(handle.Set, handle, v == true)
				end

				saeApi.UiDefer(syncToolbar)
			end)

			local modeButton = mkBtn(bar, "Mode: Normal", UDim2.new(0, 112, 0, 22), UDim2.new(0, 8, 0, 35), nil, stealStyles.Queued)
			modeButton.Label.TextSize = 8.5
			modeButton.Label.TextTruncate = Enum.TextTruncate.AtEnd

			local modeBadge = Instance.new("Frame")
			modeBadge.Name = "ModeBadge"
			modeBadge.BackgroundColor3 = U.C.ROW
			modeBadge.BackgroundTransparency = 0.15
			modeBadge.BorderSizePixel = 0
			modeBadge.Position = UDim2.new(0, 126, 0, 35)
			modeBadge.Size = UDim2.new(1, -162, 0, 22)
			U.corner(modeBadge, 11)
			U.addLivingStroke(modeBadge, 1.2)
			modeBadge.Parent = bar
			local modeBadgeTitle = U.label(modeBadge, "Normal", UDim2.new(1, -10, 0, 11), U.C.TEXT, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
			modeBadgeTitle.Position = UDim2.new(0, 5, 0, 1)
			modeBadgeTitle.TextSize = 9
			modeBadgeTitle.TextTruncate = Enum.TextTruncate.AtEnd
			U.liveGrad(modeBadgeTitle)
			local modeBadgeHint = U.label(modeBadge, "< editable with Mode", UDim2.new(1, -10, 0, 9), U.C.SILVER2, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
			modeBadgeHint.Position = UDim2.new(0, 5, 0, 11)
			modeBadgeHint.TextSize = 7

			local function layoutMode()
				if modeBadge.Visible then
					modeButton.Button.Size = UDim2.new(0, 112, 0, 22)
				else
					modeButton.Button.Size = UDim2.new(1, -46, 0, 22)
				end
			end

			local function hideGuide()
				modeBadge.Visible = false
				layoutMode()
				LinkhiveLib.MarkGuideSeen()
			end

			local helpButton = mkBtn(bar, "?", UDim2.fromOffset(24, 22), UDim2.new(1, -32, 0, 35), nil, stealStyles.Hud)
			helpButton.Label.TextSize = 11
			local guideCard = Instance.new("Frame")
			guideCard.Name = "DeliveryGuide"
			guideCard.BackgroundColor3 = U.C.BG
			guideCard.BackgroundTransparency = 0.12
			guideCard.BorderSizePixel = 0
			guideCard.Position = UDim2.new(0, 8, 0, 4)
			guideCard.Size = UDim2.new(1, -16, 1, -8)
			guideCard.ZIndex = 90
			guideCard.Visible = false
			U.corner(guideCard, 12)
			U.addLivingStroke(guideCard, 1.5)
			guideCard.Parent = win.content
			local guideScroll = Instance.new("ScrollingFrame")
			guideScroll.BackgroundTransparency = 1
			guideScroll.BorderSizePixel = 0
			guideScroll.Position = UDim2.new(0, 6, 0, 6)
			guideScroll.Size = UDim2.new(1, -12, 1, -44)
			guideScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
			guideScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
			guideScroll.ScrollBarThickness = 3
			guideScroll.ScrollBarImageColor3 = U.C.MOON
			guideScroll.ZIndex = 91
			guideScroll.Parent = guideCard
			local guideText = U.label(guideScroll, "", UDim2.new(1, -8, 0, 0), U.C.SILVER, Enum.Font.GothamMedium)
			guideText.AutomaticSize = Enum.AutomaticSize.Y
			guideText.TextWrapped = true
			guideText.RichText = true
			guideText.TextSize = 10
			guideText.TextYAlignment = Enum.TextYAlignment.Top
			guideText.ZIndex = 92
			guideText.Text = "<b>HOW DELIVERY WORKS</b>\n"
				.. "<b>Normal</b>: you carry the egg home on foot. Slowest, but the least risky.\n"
				.. "<b>Instant TP</b>: you hop to the line, put the egg down, take it back, then cross. Fast.\n"
				.. "<b>Delivery Stop</b>: the same trip with pauses (Delivery Steps). Slower, safer.\n\n"
				.. "<b>RISKS</b>\n"
				.. "- Above 115% speed the server rejects the delivery or pulls you back.\n"
				.. "- A guard hit can send the egg back to its nest.\n"
				.. "- Fewer Delivery Steps is faster but works less often.\n"
				.. "- Keep Anti Guard on to slip past the guard when you grab the egg."
			local guideClose = mkBtn(guideCard, "Got it", UDim2.new(1, -16, 0, 24), UDim2.new(0, 8, 1, -30), nil, stealStyles.Steal)
			guideClose.Label.TextSize = 10

			local function openGuide()
				guideCard.Visible = true
				page.ScrollingEnabled = false
			end

			local function closeGuide()
				guideCard.Visible = false
				page.ScrollingEnabled = true
				hideGuide()
			end

			helpButton.Button.Activated:Connect(openGuide)
			guideClose.Button.Activated:Connect(closeGuide)
			local badgeTap = Instance.new("TextButton")
			badgeTap.BackgroundTransparency = 1
			badgeTap.Text = ""
			badgeTap.Size = UDim2.new(1, 0, 1, 0)
			badgeTap.ZIndex = 5
			badgeTap.Parent = modeBadge
			badgeTap.Activated:Connect(openGuide)

			if LinkhiveLib.GuideSeen() then
				modeBadge.Visible = false
			else
				task.delay(40, hideGuide)
			end
			layoutMode()
			local modeStyles = { Normal = stealStyles.Queued, ["Instant TP"] = stealStyles.Steal, ["Delivery Stop"] = stealStyles.PriorityOn, ["Instant Steal"] = stealStyles.Steal }
			local guardHandle = { Name = "Normal" }

			function guardHandle:Set(name)
				if not modeStyles[name] then
					return
				end
				self.Name = name
				applyStyle(modeButton, modeStyles[name])
				modeButton.Label.Text = "Mode: " .. name
			end

			local branch = nil
			local branchButtons = {}

			local function refreshBranch()
				for _, entry in ipairs(branchButtons) do
					applyStyle(entry.Button, entry.Name == entry.Group.Current() and stealStyles.Steal or stealStyles.Queued)
				end
			end

			modeButton.Button.Activated:Connect(function()
				hideGuide()
				if not branch then
					local groups = {
						{ Title = "DELIVER", Names = saeApi.Method.Names, Current = saeApi.Method.Current, Apply = saeApi.Method.Apply },
						{ Title = "GO METHOD", Names = saeApi.GoMethod.Names, Current = saeApi.GoMethod.Current, Apply = saeApi.GoMethod.Apply },
					}
					local total = 8

					for _, group in ipairs(groups) do
						total += 22 + math.ceil(#group.Names / 2) * 26
					end

					branch = Instance.new("ScrollingFrame")
					branch.Name = "ModeBranch"
					branch.CanvasSize = UDim2.new(0, 0, 0, total)
					branch.ScrollBarThickness = 3
					branch.ScrollBarImageColor3 = U.C.MOON
					branch.ScrollingDirection = Enum.ScrollingDirection.Y
					branch.BackgroundColor3 = U.C.BG
					branch.BackgroundTransparency = 0.05
					branch.BorderSizePixel = 0
					branch.Position = UDim2.new(0, 8, 0, 126)
					branch.Size = UDim2.new(1, -16, 0, math.min(total, 170))
					branch.Active = true
					branch.ScrollingEnabled = true
					branch.ZIndex = 60
					branch.Visible = false
					U.corner(branch, 8)
					U.addLivingStroke(branch, 1)
					branch.Parent = win.content

					local cursor = 6

					for _, group in ipairs(groups) do
						local title = U.label(branch, group.Title, UDim2.new(1, -16, 0, 14), U.C.MOON2, Enum.Font.GothamBold)
						title.Position = UDim2.new(0, 10, 0, cursor)
						title.TextSize = 9
						cursor += 18

						for i, name in ipairs(group.Names) do
							local col = (i - 1) % 2
							local y = cursor + math.floor((i - 1) / 2) * 26
							local optionButton = mkBtn(branch, name, UDim2.new(0.5, -11, 0, 22),
								UDim2.new(col == 0 and 0 or 0.5, col == 0 and 8 or 3, 0, y), nil, stealStyles.Queued)
							optionButton.Label.TextSize = 9.5
							optionButton.Label.TextTruncate = Enum.TextTruncate.AtEnd
							branchButtons[#branchButtons + 1] = { Button = optionButton, Name = name, Group = group }
							optionButton.Button.Activated:Connect(function()
								group.Apply(name)
								refreshBranch()
								saeApi.UiDefer(syncToolbar)
							end)
						end
						cursor += math.ceil(#group.Names / 2) * 26 + 4
					end
				end

				branch.Visible = not branch.Visible
				page.ScrollingEnabled = not branch.Visible
				refreshBranch()
			end)

			local lastSortCycleTime = 0

			local function cycleSort()
				if os.clock() - lastSortCycleTime < 0.25 then
					return
				end
				lastSortCycleTime = os.clock()
				local nextSortMode = stealPriorityOptions[(table.find(stealPriorityOptions, stealPriority) or 4) % #stealPriorityOptions + 1]
				local priorityHandle = saeApi.Steal.PriorityHandle

				if priorityHandle and type(priorityHandle.Set) == "function" then
					pcall(priorityHandle.Set, priorityHandle, nextSortMode)
				end

				if stealPriority ~= nextSortMode then
					stealPriority = nextSortMode

					if type(saeApi.ResortSteal) == "function" then
						saeApi.ResortSteal()
					end
				end

				saeApi.UiDefer(function()
					syncToolbar()
					rebuildRows()
				end)
			end

			local sortButton = mkBtn(bar, "Sort: " .. tostring(stealPriority), UDim2.new(0.5, -11, 0, 26), UDim2.new(0.5, 3, 0, 4), nil, stealStyles.Hud)
			sortButton.Label.TextSize = 9
			sortButton.Label.TextTruncate = Enum.TextTruncate.AtEnd
			sortButton.Button.Activated:Connect(function()
				sortButton.Pulse()
				cycleSort()
			end)
			local sortHandle = {
				SetText = function(t)
					sortButton.Label.Text = "Sort: " .. tostring(t)
				end,
			}

			local strip = Instance.new("Frame")
			strip.Name = "Strip"
			strip.BackgroundTransparency = 1
			strip.Position = UDim2.new(0, 8, 0, 62)
			strip.Size = UDim2.new(1, -16, 0, 16)
			strip.Parent = bar

			local guardDot = Instance.new("Frame")
			guardDot.Position = UDim2.new(0, 0, 0.5, -3)
			guardDot.Size = UDim2.fromOffset(7, 7)
			guardDot.BackgroundColor3 = U.C.DIM
			guardDot.BorderSizePixel = 0
			U.corner(guardDot, 4)
			guardDot.Parent = strip

			local guardText = U.label(strip, "AG", UDim2.fromOffset(20, 16), U.C.DIM, Enum.Font.GothamBold)
			guardText.Position = UDim2.new(0, 11, 0, 0)
			guardText.TextSize = 9

			local phaseText = U.label(strip, "Idle", UDim2.fromOffset(92, 16), U.C.SILVER, Enum.Font.GothamMedium)
			phaseText.Position = UDim2.new(0, 34, 0, 0)
			phaseText.TextSize = 9
			phaseText.TextTruncate = Enum.TextTruncate.AtEnd

			local track = Instance.new("Frame")
			track.BackgroundColor3 = U.C.DEEP1
			track.BorderSizePixel = 0
			track.Position = UDim2.new(0, 130, 0.5, -3)
			track.Size = UDim2.new(1, -130, 0, 6)
			U.corner(track, 3)
			track.Parent = strip

			local fill = Instance.new("Frame")
			fill.BackgroundColor3 = U.C.MOON2
			fill.BorderSizePixel = 0
			fill.Size = UDim2.new(0, 0, 1, 0)
			U.corner(fill, 3)
			local fillGradient = Instance.new("UIGradient")
			fillGradient.Color = ColorSequence.new(U.C.DEEP3, U.C.MOON2)
			fillGradient.Parent = fill
			fill.Parent = track

			local ticks = {}

			for i = 1, 6 do
				local tick = Instance.new("Frame")
				tick.BackgroundColor3 = U.C.MOON2
				tick.BackgroundTransparency = 0.3
				tick.BorderSizePixel = 0
				tick.Size = UDim2.fromOffset(2, 10)
				tick.AnchorPoint = Vector2.new(0.5, 0.5)
				tick.Visible = false
				tick.ZIndex = 3
				tick.Parent = track
				ticks[i] = tick
			end

			local shownStops = -1

			local function updateStrip()
				local now = os.clock()
				local trip = saeApi.Trip
				local fresh = trip ~= nil and now - (trip.At or 0) < 1.5
				local text = "Idle"
				local progress = 0
				local stops = 0

				if fresh and (trip.Phase == "Hopping" or trip.Phase == "Stop") then
					stops = trip.Stops or 0
					progress = trip.Progress or 0

					if trip.Phase == "Stop" then
						text = string.format("Step %d/%d done", trip.Stop or 0, stops)
					elseif stops > 1 then
						text = string.format("Hopping, step %d/%d", trip.Stop or 1, stops)
					else
						text = "Hopping"
					end
				elseif saeApi.Steal.Carrying then
					text = "Carrying the egg"
				elseif saeApi.Steal.Active then
					text = "Going to the egg"
				end

				if stops ~= shownStops then
					shownStops = stops

					for i, tick in ipairs(ticks) do
						tick.Visible = i <= stops - 1
						tick.Position = UDim2.new(i / math.max(stops, 1), 0, 0.5, 0)
					end
				end

				phaseText.Text = text
				modeBadgeTitle.Text = tostring(saeApi.Method.Current()) .. " | " .. tostring(saeApi.GoMethod.Current())
				fill.Size = UDim2.new(math.clamp(progress, 0, 1), 0, 1, 0)

				local guard = saeApi.AntiGuard
				local running = guard.Busy == true
				guardDot.BackgroundColor3 = running and U.C.MOON2 or (guard.Enabled and U.C.MOON or U.C.DIM)
				guardText.TextColor3 = running and U.C.MOON2 or (guard.Enabled and U.C.MOON or U.C.DIM)
			end

			local stripWin = win
			task.spawn(function()
				while flag4 and win == stripWin and stripWin.frame.Parent do
					task.wait(0.2)

					if flag6 then
						pcall(updateStrip)
					end
				end
			end)

			local speed = tab:CreateSection({ Name = "Speed", Expanded = false })

			local function linkSlider(name, minV, maxV, handle, unit, fallback)
				local start = fallback or 100

				if handle and type(handle.Get) == "function" then
					local ok, v = pcall(handle.Get, handle)
					start = ok and tonumber(v) or start
				end

				local mine
				mine = speed:CreateSlider({
					Name = name,
					Min = minV,
					Max = maxV,
					Default = start,
					Increment = 1,
					Unit = unit or "%",
					Callback = function(v)
						if flagReady and handle and type(handle.Set) == "function" then
							pcall(handle.Set, handle, v, true)
						end
					end,
				})

				if handle and type(handle.Subscribe) == "function" then
					local ok, connection = pcall(handle.Subscribe, handle, function(v)
						mine:Set(v, false)
					end)

					if ok and connection then
						table.insert(stealPanelConnections, connection)
					end
				end

				mine:Set(start, false)
				return mine
			end

			linkSlider("Go Speed", 50, 115, saeApi.SafeCarry.RunHandle)
			linkSlider("Carry Speed", 80, 115, saeApi.SafeCarry.CarryHandle)
			linkSlider("Delivery Steps", 1, 6, saeApi.SafeCarry.StopsHandle, "", 3)

			local eggs = tab:CreateSection({ Name = "Field Eggs", Expanded = true })
			local list = Instance.new("Frame")
			list.Name = "EggList"
			list.BackgroundTransparency = 1
			list.Size = UDim2.new(1, -6, 0, 0)
			list.AutomaticSize = Enum.AutomaticSize.Y
			list.LayoutOrder = 1
			list.Parent = eggs.body
			local layout = Instance.new("UIListLayout")
			layout.Padding = UDim.new(0, 4)
			layout.SortOrder = Enum.SortOrder.LayoutOrder
			layout.Parent = list

			local emptyLabel = U.label(list, "No eggs on the field", UDim2.new(1, 0, 0, 28), U.C.DIM, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
			emptyLabel.TextSize = 10.5
			emptyLabel.LayoutOrder = -1

			local function refreshEmpty()
				local count = 0

				for _, child in ipairs(list:GetChildren()) do
					if child:IsA("Frame") then
						count += 1
					end
				end

				emptyLabel.Visible = count == 0
			end

			table.insert(stealPanelConnections, list.ChildAdded:Connect(function()
				task.defer(refreshEmpty)
			end))
			table.insert(stealPanelConnections, list.ChildRemoved:Connect(function()
				task.defer(refreshEmpty)
			end))

			toolbar = { ToggleHandle = toggleHandle, GuardHandle = guardHandle, SortHandle = sortHandle }

			saeApi.StealPanelSync = function()
				saeApi.UiDefer(syncToolbar)
			end

			title = win.title
			eggListFrame = list
			panelFrame = win.frame
			windowFrame = win.frame
			position = win.frame.Position
			stealPanelRefs = {}

			win.OnClose.Connect(function(on)
				if on == true then
					openStealPanel(true)
				else
					closeStealPanel(true, true)
				end
			end)

			refreshEmpty()
			return true
		end

		local function teardownStealPanel()
			if not flag4 then
				return
			end
			flag4 = false
			panelGeneration += 1
			flag8 = false
			flag10 = false

			if flag6 then
				flag6 = false

				if not isGrowingEggsOpen() then
					slideHudColumn(false, true)
				end
			end

			if tween then
				tween:Cancel()
				tween = nil
			end

			espModule.DisconnectAll(stealPanelConnections)
			table.clear(rowByUid)
			table.clear(recordByUid)

			if windowFrame then
				windowFrame:Destroy()
			end

			if sparePanelFrame then
				sparePanelFrame:Destroy()
			end

			windowFrame = nil
			panelFrame = nil
			win = nil
			position = nil
			title = nil
			sparePanelSlot = nil
			eggListFrame = nil
			sparePanelFrame = nil
			sparePanelTimer = 0
			toolbar = nil
			stealPanelRefs = nil
			spareSortIndex = 1
			hudRefs = nil
		end

		local function openStealPanelImpl()
			if flag4 then
				return
			end

			hudRefs = {}
			flag4 = true
			panelGeneration += 1
			local panelSessionId = panelGeneration

			if not buildStealPanel() then
				teardownStealPanel()
				return
			end

			if flag7 or panelOpenState:Get() == true then
				flag7 = false
				openStealPanel(false)
			end

			table.insert(stealPanelConnections, panelOpenState:Subscribe(function(on)
				if not flag4 or panelSessionId ~= panelGeneration then
					return
				end

				if on == true then
					openStealPanel(false)
				else
					closeStealPanel(false, false)
				end
			end))

			local eggState = tbl.EggState

			if type(eggState) == "table" then
				for _, fieldEventName in ipairs({ "FieldRefreshed", "FieldShifted", "FieldGone", "FieldClaimed", "SnapshotRefreshed" }) do
					local fieldEventSignal = eggState[fieldEventName]

					if type(fieldEventSignal) == "table" and type(fieldEventSignal.Connect) == "function" then
						local ok, result = pcall(fieldEventSignal.Connect, fieldEventSignal, schedulePanelRefresh)

						if ok and result then
							table.insert(stealPanelConnections, result)
						end
					end
				end
			end

			local areaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")

			if areaEggSlotsClient then
				table.insert(stealPanelConnections, areaEggSlotsClient.ChildAdded:Connect(schedulePanelRefresh))
				table.insert(stealPanelConnections, areaEggSlotsClient.ChildRemoved:Connect(schedulePanelRefresh))
			end

			task.spawn(function()
				local refreshElapsed = 0

				while flag4 and panelSessionId == panelGeneration do
					refreshElapsed += task.wait(0.5)

					if not flag4 or panelSessionId ~= panelGeneration then
						break
					end

					if not (win and win.frame and win.frame.Parent) then
						task.defer(function()
							teardownStealPanel()

							if saeApi.Toggle(ctx.stealPanelToggle or saeApi.StealPanelToggle, true) then
								ensureStealPanel()
							end
						end)

						break
					end

					if flag6 then
						if refreshElapsed >= slideInTime then
							schedulePanelRefresh()
							refreshElapsed = 0
						else
							rebuildRows()
						end
					end
				end
			end)

			task.spawn(pcall, refreshPanel, panelSessionId)
		end
		ensureStealPanel = openStealPanelImpl

		addCleanup(function()
			teardownStealPanel()

			if spareOverlay then
				spareOverlay:Destroy()
			end

			playShimmer(nil)
			spareOverlay = nil
			spareButton = nil
			imageLabel = nil
		end)

		saeApi.OpenStealPanel = function(show)
			if show == false then
				closeStealPanel(true, true)
			else
				if not (flag4 and windowFrame) then
					flag4 = false
					flag7 = true
					openStealPanelImpl()
				end
				openStealPanel(true)
				if win and win.frame then
					win.frame.Visible = true
				end
			end
		end

		saeApi.RestoreStealPanel = function()
			flagReady = true

			local methodHandle = saeApi.SafeCarry.MethodHandle
			local savedMode = methodHandle and type(methodHandle.Get) == "function" and methodHandle.Get() or "Instant Steal"
			pcall(saeApi.Method.Apply, savedMode)
			saeApi.MethodReady = true

			panelOpenState:Set(true)

			if not (flag4 and windowFrame) then
				flag4 = false
				flag7 = true
				openStealPanelImpl()
			end

			openStealPanel(true)
			if win and win.frame then
				win.frame.Visible = true
			end
		end
	end

	task.defer(ensureStealPanel)

	return { newToolWindow = newToolWindow, ensureStealPanel = ensureStealPanel }
end