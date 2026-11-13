return function(ctx)
	ctx = ctx or {}

	local lib = ctx.lib
	local gui = ctx.gui
	local services = ctx.services or {}

	local TweenService = services.TweenService or game:GetService("TweenService")
	local UIS = services.UserInputService or game:GetService("UserInputService")
	local Players = services.Players or game:GetService("Players")

	local c3 = Color3.fromRGB

	local C = {
		BG       = Color3.fromHex("#FFC700"),
		HEADER   = Color3.fromHex("#FFC700"),
		ROW      = Color3.fromHex("#FFF0C4"),
		OFF_BG   = Color3.fromHex("#F2B900"),
		ON_BG    = Color3.fromHex("#5C4200"),
		BORDER   = Color3.fromHex("#C79400"),
		TEXT     = Color3.fromHex("#2B1F00"),
		WHITE    = Color3.fromHex("#FFFFFF"),
		SILVER   = Color3.fromHex("#7A5F00"),
		SILVER2  = Color3.fromHex("#8A6B00"),
		MOONTEXT = Color3.fromHex("#FFE9A8"),
		DIM      = Color3.fromHex("#9A7B00"),
		MOON     = Color3.fromHex("#5C4200"),
		MOON2    = Color3.fromHex("#3A2A00"),
		TABIDLE  = Color3.fromHex("#7A5F00"),
		GOLD     = Color3.fromHex("#5C4200"),
		YELLOW   = Color3.fromHex("#5C4200"),
		RED      = c3(179, 38, 30),
		GREEN    = c3(30, 122, 60),
		DEEP1    = Color3.fromHex("#FFF6DC"),
		DEEP2    = Color3.fromHex("#FFE9A8"),
		DEEP3    = Color3.fromHex("#C79400"),
		DEEP4    = Color3.fromHex("#5C4200"),
	}
	C.ACCENT, C.ACCENT2 = C.MOON, C.MOON2
	C.TRACKOFF = C.OFF_BG

	local function corner(inst, r)
		local c = Instance.new("UICorner", inst)
		c.CornerRadius = UDim.new(0, r or 8)
		return c
	end

	local function stroke(inst, col, th, tr)
		local s = Instance.new("UIStroke", inst)
		s.Color = col or C.BORDER; s.Thickness = th or 1; s.Transparency = tr or 0
		return s
	end

	local function label(parent, text, size, color, font, ax, ay)
		local l = Instance.new("TextLabel", parent)
		l.BackgroundTransparency = 1
		l.Size = size or UDim2.new(1, 0, 1, 0)
		l.Text = text or ""; l.TextSize = 13
		l.TextColor3 = color or C.TEXT
		l.Font = font or Enum.Font.GothamMedium
		l.TextXAlignment = ax or Enum.TextXAlignment.Left
		l.TextYAlignment = ay or Enum.TextYAlignment.Center
		return l
	end

	local function liveGrad(inst)
		local old = inst:FindFirstChild("TextGrad")
		if old then old:Destroy() end
		local g = Instance.new("UIGradient", inst)
		g.Name = "TextGrad"
		g.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, C.DEEP4),
			ColorSequenceKeypoint.new(0.25, C.MOON2),
			ColorSequenceKeypoint.new(0.5, C.DEEP4),
			ColorSequenceKeypoint.new(0.75, C.MOON2),
			ColorSequenceKeypoint.new(1, C.DEEP4),
		})
		return g
	end

	local function addLivingStroke(parent, thickness)
		local s = Instance.new("UIStroke", parent)
		s.Color = C.DEEP3; s.Thickness = thickness or 1.5
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		local g = Instance.new("UIGradient", s)
		g.Rotation = 45
		g.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, C.DEEP4),
			ColorSequenceKeypoint.new(0.25, C.DEEP3),
			ColorSequenceKeypoint.new(0.5, C.DEEP4),
			ColorSequenceKeypoint.new(0.75, C.DEEP3),
			ColorSequenceKeypoint.new(1, C.DEEP4),
		})
		return s
	end

	local function makeSwitch(parent, initial)
		local pill = Instance.new("Frame", parent)
		pill.Size = UDim2.new(0, 40, 0, 20)
		pill.BackgroundColor3 = initial and C.ON_BG or C.OFF_BG
		pill.BackgroundTransparency = 0.1
		pill.BorderSizePixel = 0
		corner(pill, 10); addLivingStroke(pill, 1)
		local knob = Instance.new("Frame", pill)
		knob.Size = UDim2.new(0, 14, 0, 14)
		knob.Position = initial and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
		knob.BackgroundColor3 = initial and C.WHITE or C.SILVER2
		knob.BorderSizePixel = 0
		corner(knob, 7)
		local btn = Instance.new("TextButton", pill)
		btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""
		local function setState(on)
			TweenService:Create(pill, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{BackgroundColor3 = on and C.ON_BG or C.OFF_BG}):Play()
			TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{Position = on and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
				 BackgroundColor3 = on and C.WHITE or C.SILVER2}):Play()
		end
		return pill, btn, setState
	end

	local function guiParent()
		if typeof(gethui) == "function" then
			local ok, r = pcall(gethui)
			if ok and typeof(r) == "Instance" then return r end
		end
		return game:GetService("CoreGui")
	end

	local function drag(handle, target)
		local dragging, dragStart, startPos = false, nil, nil
		handle.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				dragging = true; dragStart = inp.Position; startPos = target.Position
			end
		end)
		UIS.InputChanged:Connect(function(inp)
			if not dragging then return end
			if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
				local d = inp.Position - dragStart
				target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)
		UIS.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
	end

	local function compatRow(section, cfg, height)
		section.count = section.count + 1
		local holder = Instance.new("Frame", section.body)
		holder.Size = UDim2.new(1, 0, 0, height)
		holder.BackgroundTransparency = 1
		holder.LayoutOrder = section.count * 1000
		holder:SetAttribute("sname", string.lower(tostring(cfg.Name or "")))
		local row = Instance.new("Frame", holder)
		row.Size = UDim2.new(1, -6, 1, 0)
		row.BackgroundColor3 = C.ROW; row.BackgroundTransparency = 0.15
		row.BorderSizePixel = 0
		corner(row, 10); addLivingStroke(row, 1)
		section._lastHolder = holder
		if cfg.Name then
			local l = label(row, tostring(cfg.Name), UDim2.new(1, -104, 0, 16), C.TEXT, Enum.Font.GothamBold)
			l.Position = UDim2.new(0, 10, 0, 5); l.TextSize = 11
			l.TextTruncate = Enum.TextTruncate.AtEnd
		end
		return row, holder
	end

	local function newSignalList()
		local list = {}
		return {
			Connect = function(fn)
				local c = {fn = fn}
				table.insert(list, c)
				return {Disconnect = function() c.fn = nil end}
			end,
			Fire = function(...)
				for _, c in ipairs(list) do if c.fn then task.spawn(c.fn, ...) end end
			end,
		}
	end

	return {
		C = C,
		corner = corner,
		stroke = stroke,
		label = label,
		liveGrad = liveGrad,
		addLivingStroke = addLivingStroke,
		makeSwitch = makeSwitch,
		compatRow = compatRow,
		guiParent = guiParent,
		drag = drag,
		newSignalList = newSignalList,
		gui = gui,
		Tween = TweenService,
		Shimmer = function() end,
	}
end
