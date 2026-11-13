
return function(ctx)
	ctx = ctx or {}

	local randomName = ctx.randomName or function() return "lh" end
	local hui = ctx.hui
	local colorPalette = ctx.colorPalette or {}
	local antiGuard = ctx.antiGuard or {}
	local guardConnections = ctx.guardConnections or {}
	local panelHeight = ctx.panelHeight or 52
	local carryState = ctx.carryState or {}
	local LinkhiveLib = ctx.LinkhiveLib or {}
	local localPlayer = ctx.localPlayer
	local isGuardArmed = ctx.isGuardArmed or function() return true end

	local services = ctx.services or {}
	local RunService = services.RunService or game:GetService("RunService")
	local TweenService = services.TweenService or game:GetService("TweenService")
	local GuiService = services.GuiService or game:GetService("GuiService")
	local StarterGui = services.StarterGui or game:GetService("StarterGui")
	local CoreGui = services.CoreGui or game:GetService("CoreGui")
	local UserInputService = services.UserInputService or game:GetService("UserInputService")

	if not localPlayer then
		local ok, players = pcall(function() return game:GetService("Players") end)
		localPlayer = ok and players.LocalPlayer or nil
	end

local createInstance

local function createInstanceImpl(className, parent, instanceProperties)
	local instance = Instance.new(className)
	instance.Name = randomName()
	local pairs = pairs
	local propertyTable = instanceProperties or {}

	for k, propValue in pairs(propertyTable) do
		instance[k] = propValue
	end

	instance.Parent = parent
	return instance
end
createInstance = createInstanceImpl

local tweenInstance

local function tweenInstanceImpl(tweenTarget, tweenDuration, tweenGoal, easingStyle)
	local ok, result = pcall(function()
		local tweenService = TweenService
		local create = tweenService.Create
		local tweenInfo = TweenInfo.new
		local easingStyleOverride = easingStyle
		local quint

		if easingStyle then
			quint = easingStyleOverride
		else
			quint = Enum.EasingStyle.Quint
		end

		return create(tweenService, tweenTarget, tweenInfo(tweenDuration, quint, Enum.EasingDirection.Out), tweenGoal)
	end)

	if ok and result then
		result:Play()
	end
end
tweenInstance = tweenInstanceImpl

local ScreenGui

ScreenGui = createInstance("ScreenGui", nil, {
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = -100,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

local Frame

Frame = createInstance("Frame", ScreenGui, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 1, -120),
	Size = UDim2.fromOffset(226, 52),
	BackgroundTransparency = 1,
})

local UIScale = createInstance("UIScale", Frame, { Scale = 1 })
local Frame2 = createInstance("Frame", Frame, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = colorPalette.Card, BorderSizePixel = 0, Active = true })
createInstance("UICorner", Frame2, { CornerRadius = UDim.new(0, 14) })
local UIScale2 = createInstance("UIScale", Frame2, { Scale = 0.86 })
createInstance("UIGradient", Frame2, { Color = ColorSequence.new(colorPalette.CardTop, colorPalette.Card), Rotation = 90 })
local UIGradient, Frame3, render, setFlashRequest

do
	local UIStroke = createInstance("UIStroke", Frame2, {
		Thickness = 1.5,
		Color = colorPalette.Stroke,
		Transparency = 0.2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})

	UIGradient = createInstance("UIGradient", UIStroke, { Color = ColorSequence.new(colorPalette.Stroke, colorPalette.Stroke) })

	Frame3 = createInstance("Frame", Frame2, {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 10, 0.5, 0),
		Size = UDim2.fromOffset(36, 36),
		BackgroundColor3 = Color3.fromRGB(255, 246, 220),
		BorderSizePixel = 0,
		ZIndex = 2,
	})

	createInstance("UICorner", Frame3, { CornerRadius = UDim.new(0, 11) })
	local UIStroke2 = createInstance("UIStroke", Frame3, { Thickness = 1.5, Color = colorPalette.Off, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })

	local ImageLabel = createInstance("ImageLabel", Frame3, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.86, 0.86),
		BackgroundTransparency = 1,
		Image = "",
		ImageTransparency = 0.35,
		ScaleType = Enum.ScaleType.Crop,
		ZIndex = 3,
	})

	createInstance("UICorner", ImageLabel, { CornerRadius = UDim.new(0, 8) })

	createInstance("ImageLabel", Frame3, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(28, 28),
		BackgroundTransparency = 1,
		Image = "rbxassetid://95796400321273",
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = 3,
	})
	local UIScale3 = createInstance("UIScale", ImageLabel, { Scale = 1 })

	createInstance("UIGradient", createInstance("TextLabel", Frame2, {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 56, 0, 7),
		Size = UDim2.new(1, -112, 0, 15),
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = colorPalette.Text,
		Text = "Linkhive",
		ZIndex = 2,
	}), { Color = ColorSequence.new(Color3.fromRGB(43, 31, 0), Color3.fromRGB(92, 66, 0)) })

	local guardTitle = createInstance("TextLabel", Frame2, {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 56, 0, 22),
		Size = UDim2.new(1, -112, 0, 20),
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = colorPalette.Text,
		Text = "Anti Guard",
		ZIndex = 2,
	})
	createInstance("UIGradient", guardTitle, { Color = ColorSequence.new(Color3.fromRGB(92, 66, 0), Color3.fromRGB(43, 31, 0)) })

	local TextButton = createInstance("TextButton", Frame2, {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(42, 22),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Text = "",
		ZIndex = 2,
	})

	createInstance("UICorner", TextButton, { CornerRadius = UDim.new(1, 0) })
	local UIGradient2 = createInstance("UIGradient", TextButton, { Color = ColorSequence.new(colorPalette.Off, colorPalette.Off) })

	local Frame4 = createInstance("Frame", TextButton, {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = Color3.fromRGB(255, 250, 235),
		BorderSizePixel = 0,
		ZIndex = 3,
	})

	createInstance("UICorner", Frame4, { CornerRadius = UDim.new(1, 0) })

	local function accentColor()
		return antiGuard.Enabled and colorPalette.AccentA or colorPalette.Off
	end

	render = function(renderEnabled)
		local renderDuration = renderEnabled and 0 or 0.28

		if antiGuard.Enabled then
			UIGradient2.Color = ColorSequence.new(colorPalette.AccentA, colorPalette.AccentB)
			local strokeGradient = UIGradient
			local colorSequence = ColorSequence.new
			local keypointList = {}
			local keypointStart = ColorSequenceKeypoint.new(0, colorPalette.Stroke)
			local keypointMidA = ColorSequenceKeypoint.new(0.45, colorPalette.AccentA)
			local keypointMidB = ColorSequenceKeypoint.new(0.55, colorPalette.AccentB)
			local new = ColorSequenceKeypoint.new
			local stroke = colorPalette.Stroke
			keypointList[1] = keypointStart
			keypointList[2] = keypointMidA
			keypointList[3] = keypointMidB

			do
				local values = table.pack(new(1, stroke))
				table.move(values, 1, values.n, 4, keypointList)
			end

			strokeGradient.Color = colorSequence(keypointList)
			tweenInstance(Frame4, renderDuration, { Position = UDim2.new(1, -19, 0.5, 0) }, Enum.EasingStyle.Back)
			tweenInstance(ImageLabel, renderDuration, { ImageTransparency = 0 })
			tweenInstance(UIStroke, 0.3, { Transparency = 0 })
		else
			UIGradient2.Color = ColorSequence.new(colorPalette.Off, colorPalette.Off)
			UIGradient.Color = ColorSequence.new(colorPalette.Stroke, colorPalette.Stroke)
			tweenInstance(Frame4, renderDuration, { Position = UDim2.new(0, 3, 0.5, 0) }, Enum.EasingStyle.Back)
			tweenInstance(ImageLabel, renderDuration, { ImageTransparency = 0.35 })
			tweenInstance(UIStroke, 0.3, { Transparency = 0.2 })
		end

		if carryState.FlashUntil <= os.clock() then
			tweenInstance(UIStroke2, renderDuration, { Color = accentColor() })
		end
	end

	setFlashRequest = function(flashColor, flashHold)
		carryState.FlashRequest = { Color = flashColor, Hold = flashHold }
	end

	local function applyFlashRequest()
		local flashRequest = carryState.FlashRequest
		if not flashRequest then
			return
		end
		carryState.FlashRequest = nil
		carryState.FlashUntil = os.clock() + (flashRequest.Hold or 0)
		tweenInstance(UIStroke2, 0.2, { Color = flashRequest.Color })

		if flashRequest.Hold then
			task.delay(flashRequest.Hold, function()
				local flag5 = isGuardArmed()

				if isGuardArmed() then
					local flashUntil = carryState.FlashUntil
					flag5 = os.clock() >= flashUntil
				end

				if flag5 then
					tweenInstance(UIStroke2, 0.3, { Color = accentColor() })
				end
			end)
		end
	end

	local function setGuardHandle(handleEnabled)
		local handle = antiGuard.Handle
		if type(handle) ~= "table" then
			return
		end

		for _, handleMethodName in ipairs({ "Set", "SetValue" }) do
			local ok, result = pcall(function()
				return handle[handleMethodName]
			end)

			if ok and type(result) == "function" and pcall(result, handle, handleEnabled) then
				return
			end
		end
	end

	antiGuard.Render = render

	local TextButton2 = createInstance("TextButton", Frame2, {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		ZIndex = 10,
	})

	guardConnections[#guardConnections + 1] = TextButton2.MouseButton1Click:Connect(function()
		antiGuard.Enabled = not antiGuard.Enabled
		render(false)
		setGuardHandle(antiGuard.Enabled)
		tweenInstance(UIScale3, 0.12, { Scale = 1.15 })

		task.delay(0.12, function()
			if isGuardArmed() then
				tweenInstance(UIScale3, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
			end
		end)
	end)

	local size = TextButton.Size

	guardConnections[#guardConnections + 1] = TextButton2.MouseEnter:Connect(function()
		tweenInstance(TextButton, 0.15, { Size = size + UDim2.fromOffset(2, 2) })
	end)

	guardConnections[#guardConnections + 1] = TextButton2.MouseLeave:Connect(function()
		tweenInstance(TextButton, 0.15, { Size = size })
	end)

	local coreGuiNameSet = {
		Hotbar = true,
		HotBar = true,
		Toolbar = true,
		ToolBar = true,
		Backpack = true,
		Inventory = true,
	}

	local coreGuiObjects = {}
	local huge = math.huge
	local huge2 = math.huge
	local rotation = 0
	local cachedBottomOffset = nil

	local function isGuiVisible(visibilityGuiObject)
		while visibilityGuiObject do
			if visibilityGuiObject:IsA("GuiObject") and not visibilityGuiObject.Visible then
				return false
			end

			if visibilityGuiObject:IsA("LayerCollector") then
				return visibilityGuiObject.Enabled
			end
			visibilityGuiObject = visibilityGuiObject.Parent
		end

		return false
	end

	local function getGuiInsetY()
		local ok, result = pcall(function()
			return GuiService:GetGuiInset().Y
		end)

		return ok and result or 0
	end

	local function findTopButtonY(topButtonGuiObject)
		local minY = nil

		for _, descendant in ipairs(topButtonGuiObject:GetDescendants()) do
			if descendant:IsA("GuiButton") and descendant.Visible and descendant.AbsoluteSize.Y > 8 and descendant.AbsoluteSize.X > 8 then
				local y = descendant.AbsolutePosition.Y

				if not minY or y < minY then
					minY = y
				end
			end
		end

		return minY or topButtonGuiObject.AbsolutePosition.Y
	end

	local function collectCoreGuiObjects()
		table.clear(coreGuiObjects)
		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
		if not playerGui then
			return
		end

		for _, descendant in ipairs(playerGui:GetDescendants()) do
			if descendant:IsA("GuiObject") and coreGuiNameSet[descendant.Name] then
				coreGuiObjects[#coreGuiObjects + 1] = descendant
			end
		end
	end

	local function gatherTrackedGui()
		local guiElements = {}

		pcall(function()
			if not StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack) then
				return
			end

			for _, child in ipairs(CoreGui.RobloxGui.Backpack:GetChildren()) do
				if child:IsA("GuiObject") then
					guiElements[#guiElements + 1] = child
				end
			end
		end)

		for _, trackedGuiObject in ipairs(coreGuiObjects) do
			if trackedGuiObject.Parent then
				guiElements[#guiElements + 1] = trackedGuiObject
			end
		end

		return guiElements
	end

	local function repositionPanel()
		local currentCamera = workspace.CurrentCamera
		if not currentCamera then
			return
		end
		local viewportSize = currentCamera.ViewportSize
		if viewportSize.X < 10 or viewportSize.Y < 10 then
			return
		end
		local flag5 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
		local viewportScale = math.min(viewportSize.X / 1280, viewportSize.Y / 720)
		local scale = (flag5 and math.clamp(viewportScale * 1.05, 0.6, 0.8) * 0.97 or math.clamp(viewportScale, 0.8, 1.1)) * 1.2
		UIScale.Scale = scale
		local backgroundTransparency = flag5 and 0.3 or 0

		if Frame2.BackgroundTransparency ~= backgroundTransparency then
			Frame2.BackgroundTransparency = backgroundTransparency
			Frame3.BackgroundTransparency = backgroundTransparency
		end

		local bottomY = viewportSize.Y - 8 * scale
		local flag6 = false

		for _, measuredGuiObject in ipairs(gatherTrackedGui()) do
			local ok, result = pcall(isGuiVisible, measuredGuiObject)

			if ok and result then
				local absoluteSize = measuredGuiObject.AbsoluteSize
				local y = measuredGuiObject.AbsolutePosition.Y

				if absoluteSize.X > 20 and absoluteSize.Y > 20 and absoluteSize.Y < viewportSize.Y * 0.4 and y + absoluteSize.Y / 2 > viewportSize.Y * 0.5 then
					local ok2, result2 = pcall(findTopButtonY, measuredGuiObject)
					y = ok2 and result2 or y
					flag6 = true
					bottomY = math.min(bottomY, y + getGuiInsetY())
				end
			end
		end

		if flag6 then
			cachedBottomOffset = viewportSize.Y - bottomY
		elseif cachedBottomOffset then
			bottomY = viewportSize.Y - cachedBottomOffset
		end

		local panelY = math.max(bottomY - (flag5 and 4 or 6) * scale - panelHeight * scale / 2, panelHeight * scale / 2 + 8)
		Frame.Position = UDim2.new(0.5, 0, 0, panelY)
	end

	local function renderAntiGuard(deltaTime)
		applyFlashRequest()
		huge += deltaTime
		huge2 += deltaTime

		if huge >= 3 then
			huge = 0
			pcall(collectCoreGuiObjects)
		end

		if huge2 >= 0.2 then
			huge2 = 0
			pcall(repositionPanel)
		end

		if antiGuard.Enabled and not LinkhiveLib.NoAnim then
			rotation = (rotation + deltaTime * (carryState.Active and 360 or 90)) % 360
			UIGradient.Rotation = rotation
		end
	end

	guardConnections[#guardConnections + 1] = RunService.RenderStepped:Connect(renderAntiGuard)
end

render(true)

antiGuard.ShowPanel = function(panelShown)
	ScreenGui.Enabled = panelShown == true
end

LinkhiveLib.ThemeHooks[#LinkhiveLib.ThemeHooks + 1] = function(mapColor, mapSeq, recolorTree)
	for _, key in ipairs({ "Card", "CardTop", "Stroke", "AccentA", "AccentB" }) do
		colorPalette[key] = mapColor(colorPalette[key])
	end
	pcall(recolorTree, ScreenGui)
	pcall(render, false)
end
LinkhiveLib.RunThemeHooksFrom("Moon")

ScreenGui.Enabled = antiGuard.PanelShown == true
ScreenGui.Parent = hui
tweenInstance(UIScale2, 0.45, { Scale = 1 }, Enum.EasingStyle.Back)
	return {
		Render = render,
		SetFlash = setFlashRequest,
		ScreenGui = ScreenGui,
		Frame = Frame,
		Frame2 = Frame2,
		Tween = tweenInstance,
	}
end
