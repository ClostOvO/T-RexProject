return function(ctx)
	ctx = ctx or {}

	local espModule = ctx.espModule or {}
	local espSection = ctx.espSection
	local color = ctx.color or Color3.fromRGB
	local sequence = ctx.sequence
	local palettes = ctx.palettes or {}
	local generateRandomId = ctx.generateRandomId
	local tbl = ctx.tbl
	local localPlayer = ctx.localPlayer
	local addCleanup = ctx.addCleanup or function() end
	local saeApi = ctx.saeApi or {}
	local fixNoneLabel = ctx.fixNoneLabel
	local uiParent = ctx.uiParent
	local networking = ctx.networking
	local mutationLabel = ctx.mutationLabel
	local createValueSlider = ctx.createValueSlider

	local Players = ctx.Players or game:GetService("Players")
	local RunService = ctx.RunService or game:GetService("RunService")
	local ReplicatedStorage = ctx.ReplicatedStorage or game:GetService("ReplicatedStorage")

	if not localPlayer then
		local ok, players = pcall(function() return game:GetService("Players") end)
		localPlayer = ok and players.LocalPlayer or nil
	end

		do
			local accent = {}
			local accentTextStops = {}
			local accentTextStop1 = { 0, color(170, 255, 160) }
			local accentTextStop2 = { 0.45, color(58, 255, 55) }
			local accentTextStop3 = { 1, color(20, 109, 0) }
			accentTextStops[1] = accentTextStop1
			accentTextStops[2] = accentTextStop2
			accentTextStops[3] = accentTextStop3
			accent.Text = sequence(accentTextStops)
			local accentStrokeStops = {}
			local accentStrokeStop1 = { 0, color(10, 52, 6) }
			local accentStrokeStop2 = { 1, color(3, 16, 0) }
			accentStrokeStops[1] = accentStrokeStop1
			accentStrokeStops[2] = accentStrokeStop2
			accent.Stroke = sequence(accentStrokeStops)
			accent.Outline = color(58, 255, 55)
			palettes.Accent = accent
		end

		do
			local sheen = {}
			local sheenTextStops = {}
			local sheenTextStop1 = { 0, color(255, 255, 255) }
			local sheenTextStop2 = { 0.5, color(222, 222, 222) }
			local sheenTextStop3 = { 1, color(255, 255, 255) }
			sheenTextStops[1] = sheenTextStop1
			sheenTextStops[2] = sheenTextStop2
			sheenTextStops[3] = sheenTextStop3
			sheen.Text = sequence(sheenTextStops)
			local sheenStrokeStops = {}
			local sheenStrokeStop1 = { 0, color(8, 8, 8) }
			local sheenStrokeStop2 = { 1, color(8, 8, 8) }
			sheenStrokeStops[1] = sheenStrokeStop1
			sheenStrokeStops[2] = sheenStrokeStop2
			sheen.Stroke = sequence(sheenStrokeStops)
			sheen.Outline = color(255, 255, 255)
			palettes.Sheen = sheen
		end

		espModule.Palettes = palettes

		espModule.PaletteFromColor = function(baseColor)
			local color3 = Color3.new(1, 1, 1)
			local color4 = Color3.new(0, 0, 0)
			local palette = {}
			local sequence2 = espModule.Sequence
			local textStops = {}
			local textStop1 = { 0, baseColor:Lerp(color3, 0.5) }
			local textStop2 = { 0.4, baseColor:Lerp(color3, 0.1) }
			local textStop3 = { 1, baseColor:Lerp(color4, 0.25) }
			textStops[1] = textStop1
			textStops[2] = textStop2
			textStops[3] = textStop3
			palette.Text = sequence2(textStops)
			local sequence3 = espModule.Sequence
			local strokeStops = {}
			local strokeStop1 = { 0, baseColor:Lerp(color4, 0.55) }
			local strokeStop2 = { 0.55, baseColor:Lerp(color4, 0.75) }
			local strokeStop3 = { 1, baseColor:Lerp(color4, 0.92) }
			strokeStops[1] = strokeStop1
			strokeStops[2] = strokeStop2
			strokeStops[3] = strokeStop3
			palette.Stroke = sequence3(strokeStops)
			palette.Outline = baseColor:Lerp(color3, 0.25)
			return palette
		end

		espModule.SizeScale = 1
		local sizeListeners = {}

		espModule.OnSizeChanged = function(sizeCallback)
			table.insert(sizeListeners, sizeCallback)
		end

		espModule.SetSizeScale = function(sizeScale)
			if espModule.SizeScale == sizeScale then
				return
			end
			espModule.SizeScale = sizeScale

			for _, listener in ipairs(sizeListeners) do
				pcall(listener)
			end
		end

		espModule.RowHeight = function(scale)
			local currentCamera = workspace.CurrentCamera
			return math.max(6, math.floor(math.clamp((currentCamera and currentCamera.ViewportSize.Y or 1080) * 0.014, 13, 19) * (scale or espModule.SizeScale)))
		end

		espModule.ScaledWidth = function(widthBase, widthScale)
			return math.max(30, math.floor(widthBase * (widthScale or espModule.SizeScale)))
		end

		espModule.CreateRuntime = function()
			local screenGui = Instance.new("ScreenGui")
			screenGui.Name = generateRandomId()
			screenGui.Archivable = false
			screenGui.ResetOnSpawn = false
			screenGui.IgnoreGuiInset = true
			screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			screenGui.DisplayOrder = 48
			screenGui.Parent = uiParent
			return screenGui
		end

		espModule.CreateTag = function(parent, maxDistance)
			local billboardGui = Instance.new("BillboardGui")
			billboardGui.Name = generateRandomId()
			billboardGui.AlwaysOnTop = true
			billboardGui.LightInfluence = 0
			billboardGui.MaxDistance = maxDistance
			local frame = Instance.new("Frame")
			frame.Name = generateRandomId()
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.Size = UDim2.fromScale(1, 1)
			frame.Parent = billboardGui
			local uiListLayout = Instance.new("UIListLayout")
			uiListLayout.Name = generateRandomId()
			uiListLayout.FillDirection = Enum.FillDirection.Vertical
			uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			uiListLayout.Parent = frame
			billboardGui.Parent = parent
			return billboardGui, frame
		end

		espModule.CreateTextRow = function(parent, fontFace, layoutOrder, rowHeight)
			local frame = Instance.new("Frame")
			frame.Name = generateRandomId()
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.Size = UDim2.fromScale(1, rowHeight)
			frame.LayoutOrder = layoutOrder
			frame.Parent = parent

			local function createTextLabel(zIndex)
				local textLabel = Instance.new("TextLabel")
				textLabel.Name = generateRandomId()
				textLabel.BackgroundTransparency = 1
				textLabel.Size = UDim2.fromScale(1, 1)
				textLabel.Text = ""
				textLabel.TextScaled = true
				textLabel.TextStrokeTransparency = 1
				textLabel.TextXAlignment = Enum.TextXAlignment.Center
				textLabel.TextYAlignment = Enum.TextYAlignment.Center
				textLabel.ZIndex = zIndex

				if fontFace then
					textLabel.FontFace = fontFace
				else
					textLabel.Font = Enum.Font.GothamBold
				end

				textLabel.Parent = frame
				return textLabel
			end

			local shadowLabel = createTextLabel(2)
			shadowLabel.Position = UDim2.fromOffset(1, 1)
			shadowLabel.TextColor3 = Color3.new(0, 0, 0)
			shadowLabel.TextTransparency = 0.1
			local mainLabel = createTextLabel(3)
			mainLabel.TextColor3 = Color3.new(1, 1, 1)
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Name = generateRandomId()
			uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
			uiStroke.LineJoinMode = Enum.LineJoinMode.Round
			uiStroke.Color = Color3.new(1, 1, 1)
			uiStroke.Transparency = 0.05

			uiStroke.Thickness = pcall(function()
				uiStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
			end) and 0.05 or 1.2

			uiStroke.Parent = mainLabel
			local uiGradient = Instance.new("UIGradient")
			uiGradient.Name = generateRandomId()
			uiGradient.Rotation = 90
			uiGradient.Parent = uiStroke
			local uiGradient2 = Instance.new("UIGradient")
			uiGradient2.Name = generateRandomId()
			uiGradient2.Rotation = 90
			uiGradient2.Parent = mainLabel
			return { Holder = frame, Shadow = shadowLabel, Label = mainLabel, StrokeGradient = uiGradient, TextGradient = uiGradient2, Palette = nil }
		end

		espModule.SetRow = function(row, text, palette)
			if row.Label.Text ~= text then
				row.Label.Text = text
				row.Shadow.Text = text
			end

			if row.Palette ~= palette then
				row.Palette = palette
				row.TextGradient.Color = palette.Text
				row.TextGradient.Rotation = palette.Rotation or 90
				row.StrokeGradient.Color = palette.Stroke
			end
		end

		espModule.ReadToggle = function(toggleHandle, fallbackValue)
			if type(toggleHandle) ~= "table" then
				return fallbackValue == true
			end

			local ok, result = pcall(function()
				local controller = toggleHandle._controller
				return type(controller) == "table" and type(controller.GetValue) == "function" and controller.GetValue()
			end)

			if ok and type(result) == "boolean" then
				return result
			end

			for _, methodName in ipairs({ "Get", "GetValue" }) do
				local ok2, result2 = pcall(function()
					return toggleHandle[methodName]
				end)

				if ok2 and type(result2) == "function" then
					local ok3, result3 = pcall(result2, toggleHandle)
					if ok3 and type(result3) == "boolean" then
						return result3
					end
				end
			end

			return fallbackValue == true
		end

		espModule.SyncSoon = function(syncCallback)
			syncCallback()
			task.delay(0.35, syncCallback)
		end

		espModule.GetGuardAreas = function()
			local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
			world = world and world:FindFirstChild("Areas")
			return world and world:FindFirstChild("GuardAreas")
		end

		espModule.FindGuardRoot = function(guardInst)
			local humanoidRootPart = guardInst:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
				return humanoidRootPart
			end

			if guardInst.PrimaryPart then
				return guardInst.PrimaryPart
			end
			return guardInst:FindFirstChildWhichIsA("BasePart", true)
		end

		espModule.WatchGuards = function(guardEventCallback)
			local guardConnections = {}
			local guardAreasContainer = espModule.GetGuardAreas()
			if not guardAreasContainer then
				return guardConnections
			end

			local function watchArea(child)
				local guard = child:FindFirstChild("Guard")

				if guard and guard:IsA("Model") then
					guardEventCallback(child.Name, guard)
				end

				table.insert(guardConnections, child.ChildAdded:Connect(function(child2)
					if child2.Name == "Guard" and child2:IsA("Model") then
						guardEventCallback(child.Name, child2)
					end
				end))
			end

			for _, child in ipairs(guardAreasContainer:GetChildren()) do
				watchArea(child)
			end

			table.insert(guardConnections, guardAreasContainer.ChildAdded:Connect(watchArea))
			return guardConnections
		end

		espModule.DisconnectAll = function(connectionList)
			for _, connectionEntry in ipairs(connectionList) do
				pcall(function()
					connectionEntry:Disconnect()
				end)
			end

			table.clear(connectionList)
		end

		local maxHighlights = 18
		local allColumns

		allColumns = {
			"Icon",
			"Name",
			"Rarity",
			"Mutation",
			"Value",
			"Weight",
			"Size",
			"Sell Price",
			"Distance",
			"Area",
			"State",
		}

		local infoColumns = { "Icon", "Name", "Value" }
		local highlightModes = { "Off", "Rare Only", "All Shown" }
		local rowWeights = { Icon = 3.2, Name = 1.35, Rarity = 1.2, Mutation = 1, Value = 1.1, Info = 1 }
		local rarityFont

		local function loadRarityFont()
			local ok, result = pcall(Font.new, "rbxassetid://12187365977", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
			return ok and result or espModule.StatusFont
		end

		rarityFont = loadRarityFont()
		local secretGradient

		do
			local sequence2 = espModule.Sequence
			local secretTextStops = {}
			local secretTextStop1 = { 0, Color3.fromRGB(255, 255, 255) }
			local secretTextStop2 = { 0.2, Color3.fromRGB(206, 212, 224) }
			local secretTextStop3 = { 0.42, Color3.fromRGB(74, 80, 94) }
			local secretTextStop4 = { 0.58, Color3.fromRGB(42, 46, 56) }
			local secretTextStop5 = { 0.78, Color3.fromRGB(158, 166, 182) }
			local secretTextStop6 = { 1, Color3.fromRGB(250, 252, 255) }
			secretTextStops[1] = secretTextStop1
			secretTextStops[2] = secretTextStop2
			secretTextStops[3] = secretTextStop3
			secretTextStops[4] = secretTextStop4
			secretTextStops[5] = secretTextStop5
			secretTextStops[6] = secretTextStop6
			secretGradient = sequence2(secretTextStops)
		end

		local valuePalette = espModule.PaletteFromColor(Color3.fromRGB(77, 255, 122))
		local namePalette = {}

		do
			local sequence2 = espModule.Sequence
			local nameTextStops = {}
			local nameTextStop1 = { 0, Color3.fromRGB(255, 255, 255) }
			local nameTextStop2 = { 0.5, Color3.fromRGB(222, 238, 255) }
			local nameTextStop3 = { 1, Color3.fromRGB(255, 255, 255) }
			nameTextStops[1] = nameTextStop1
			nameTextStops[2] = nameTextStop2
			nameTextStops[3] = nameTextStop3
			namePalette.Text = sequence2(nameTextStops)
		end

		do
			local sequence2 = espModule.Sequence
			local nameStrokeStops = {}
			local nameStrokeStop1 = { 0, Color3.fromRGB(8, 8, 8) }
			local nameStrokeStop2 = { 1, Color3.fromRGB(8, 8, 8) }
			nameStrokeStops[1] = nameStrokeStop1
			nameStrokeStops[2] = nameStrokeStop2
			namePalette.Stroke = sequence2(nameStrokeStops)
		end

		namePalette.Outline = Color3.fromRGB(255, 255, 255)
		local tagHeightOffset = 0.8
		local fixedSizeScale = 4.5
		local distanceScaleFactor = 20
		local frameTimeBudget = 0.002
		local mutationPalettes = { Golden = espModule.Palettes.Gold }

		do
			local silver = {}
			local sequence2 = espModule.Sequence
			local silverTextStops = {}
			local silverTextStop1 = { 0, Color3.fromRGB(255, 255, 255) }
			local silverTextStop2 = { 0.45, Color3.fromRGB(214, 222, 232) }
			local silverTextStop3 = { 1, Color3.fromRGB(150, 160, 175) }
			silverTextStops[1] = silverTextStop1
			silverTextStops[2] = silverTextStop2
			silverTextStops[3] = silverTextStop3
			silver.Text = sequence2(silverTextStops)
			local sequence3 = espModule.Sequence
			local silverStrokeStops = {}
			local silverStrokeStop1 = { 0, Color3.fromRGB(60, 66, 78) }
			local silverStrokeStop2 = { 0.55, Color3.fromRGB(30, 33, 40) }
			local silverStrokeStop3 = { 1, Color3.fromRGB(10, 11, 14) }
			silverStrokeStops[1] = silverStrokeStop1
			silverStrokeStops[2] = silverStrokeStop2
			silverStrokeStops[3] = silverStrokeStop3
			silver.Stroke = sequence3(silverStrokeStops)
			silver.Outline = Color3.fromRGB(214, 222, 232)
			mutationPalettes.Silver = silver
		end

		mutationPalettes.Sakura = espModule.PaletteFromColor(Color3.fromRGB(255, 158, 216))
		mutationPalettes.GreatBloom = espModule.PaletteFromColor(Color3.fromRGB(124, 255, 196))
		mutationPalettes.Boss = espModule.PaletteFromColor(Color3.fromRGB(255, 122, 122))
		mutationPalettes.Monstrous = espModule.PaletteFromColor(Color3.fromRGB(192, 139, 255))

		do
			local rainbow = {}
			local sequence2 = espModule.Sequence
			local rainbowTextStops = {}
			local rainbowTextStop1 = { 0, Color3.fromRGB(255, 107, 107) }
			local rainbowTextStop2 = { 0.2, Color3.fromRGB(255, 179, 107) }
			local rainbowTextStop3 = { 0.4, Color3.fromRGB(255, 240, 107) }
			local rainbowTextStop4 = { 0.6, Color3.fromRGB(107, 255, 138) }
			local rainbowTextStop5 = { 0.8, Color3.fromRGB(107, 200, 255) }
			local rainbowTextStop6 = { 1, Color3.fromRGB(185, 107, 255) }
			rainbowTextStops[1] = rainbowTextStop1
			rainbowTextStops[2] = rainbowTextStop2
			rainbowTextStops[3] = rainbowTextStop3
			rainbowTextStops[4] = rainbowTextStop4
			rainbowTextStops[5] = rainbowTextStop5
			rainbowTextStops[6] = rainbowTextStop6
			rainbow.Text = sequence2(rainbowTextStops)
			local sequence3 = espModule.Sequence
			local rainbowStrokeStops = {}
			local rainbowStrokeStop1 = { 0, Color3.fromRGB(20, 20, 30) }
			local rainbowStrokeStop2 = { 1, Color3.fromRGB(8, 8, 12) }
			rainbowStrokeStops[1] = rainbowStrokeStop1
			rainbowStrokeStops[2] = rainbowStrokeStop2
			rainbow.Stroke = sequence3(rainbowStrokeStops)
			rainbow.Outline = Color3.fromRGB(255, 255, 255)
			rainbow.Rotation = 0
			mutationPalettes.Rainbow = rainbow
		end

		local fallbackPalette = espModule.PaletteFromColor(Color3.fromRGB(143, 227, 255))
		local rfEggWorldAskFieldEggSnapshot = networking:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
		local snapshotRetryAt = 0
		local espConfig

		espConfig = {
			Eggs = false,
			MinRarity = 5,
			Specific = {},
			MutationSet = {},
			AnyMutation = false,
			NoMutation = false,
			Info = {},
			Highlight = highlightModes[1],
			MinValue = 0,
			HighlightMin = 6,
			MaxDistance = math.huge,
			SizeScale = 0.75,
			FixedSize = false,
			OwnBase = true,
		}

		for _, infoColumn in ipairs(infoColumns) do
			espConfig.Info[infoColumn] = true
		end

		local espTags = {}
		local espConnections, lastRecords, flag4, revision, sessionId, flag5, runtimeGui, highlightCount, paletteForCategory
		local paletteCache = {}
		espConnections = {}
		lastRecords = nil
		flag4 = false
		revision = 0
		sessionId = 0
		flag5 = false
		runtimeGui = nil
		highlightCount = 0

		paletteForCategory = function(assetCategory)
			local cachedPalette = paletteCache[assetCategory]
			if cachedPalette then
				return cachedPalette
			end
			local directory = tbl.Assets and tbl.Assets.Directory
			local flag6 = type(directory) == "table" and directory[assetCategory]
			local rarity = type(flag6) == "table" and type(flag6.Rarity) == "table" and flag6.Rarity or nil
			local color3 = rarity and typeof(rarity.Color) == "Color3" and rarity.Color or Color3.new(1, 1, 1)
			local categoryPalette = espModule.PaletteFromColor(color3)
			local rarityGradient = rarity and rarity.RarityGradient

			if rarity and typeof(rarityGradient) ~= "Instance" then
				local assets = ReplicatedStorage:FindFirstChild("Assets")
				assets = assets and assets:FindFirstChild("UI")
				assets = assets and assets:FindFirstChild("RarityGradients")

				if assets then
					assets = assets:FindFirstChild(tostring(rarity._id or rarity.DisplayName or ""))
				end

				rarityGradient = assets and assets:FindFirstChild("RarityGradient") or nil
			end

			if typeof(rarityGradient) == "Instance" and rarityGradient:IsA("UIGradient") then
				categoryPalette.Text = rarityGradient.Color
				categoryPalette.Rotation = rarityGradient.Rotation
			end

			local name

			if rarity then
				name = tostring(rarity.DisplayName or rarity._id or "")
			else
				name = rarity
			end

			name = name or ""
			local rarityPalette

			if string.upper(name) ~= "SECRET" then
				rarityPalette = categoryPalette
			else
				rarityPalette = { Text = secretGradient, Stroke = categoryPalette.Stroke, Outline = categoryPalette.Outline, Rotation = 90 }
			end

			local rarityInfo = {}
			local number

			if rarity then
				number = tonumber(rarity.RarityNumber or rarity.Rank)
			else
				number = rarity
			end

			rarityInfo.Number = number or 0
			rarityInfo.Name = name
			rarityInfo.Color = color3
			rarityInfo.Palette = categoryPalette
			rarityInfo.RarityPalette = rarityPalette
			local displayName = type(flag6) == "table"

			if displayName then
				displayName = tostring(flag6.DisplayName or assetCategory)
			end

			rarityInfo.DisplayName = displayName or tostring(assetCategory)
			rarityInfo.Icon = type(flag6) == "table" and flag6.Icon or nil
			rarityInfo.EarningRate = type(flag6) == "table" and tonumber(flag6.EarningRate) or 0
			paletteCache[assetCategory] = rarityInfo
			return rarityInfo
		end

		local applyTagSize, requestTagUpdate, resizeAllTags, espControls, normalizeInfoSet

		do
			local function findAreaEggSlot(areaName)
				local areaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")
				areaEggSlotsClient = areaEggSlotsClient and areaEggSlotsClient:FindFirstChild(areaName)
				if areaEggSlotsClient and areaEggSlotsClient:IsA("Model") then
					local hitbox = areaEggSlotsClient:FindFirstChild("Hitbox")
					return areaEggSlotsClient, hitbox and hitbox:IsA("BasePart") and hitbox or nil
				end
				return nil, nil
			end

			local function ensureRuntime()
				if not runtimeGui or not runtimeGui.Parent then
					runtimeGui = espModule.CreateRuntime()
				end
			end

			local function formatCompactNumber(numberValue)
				local absValue = tonumber(numberValue) or 0
				local suffixes = { "", "K", "M", "B", "T", "Qa", "Qi" }
				local suffixIndex = 1

				while math.abs(absValue) >= 1000 and suffixIndex < #suffixes do
					absValue /= 1000
					suffixIndex += 1
				end

				return string.format(suffixIndex == 1 and "%.0f%s" or "%.2f%s", absValue, suffixes[suffixIndex])
			end

			local function distanceToSize(worldSize)
				local currentCamera = workspace.CurrentCamera
				if not currentCamera then
					return espConfig.MaxDistance
				end
				return math.min(espConfig.MaxDistance, worldSize * currentCamera.ViewportSize.Y / (2 * distanceScaleFactor * math.tan(math.rad(currentCamera.FieldOfView) * 0.5)))
			end

			local function layoutTag(tagInstance)
				local tagRows = {
					{ tagInstance.IconHolder, rowWeights.Icon, tagInstance.ShowIcon },
					{ tagInstance.NameRow.Holder, rowWeights.Name, tagInstance.ShowName },
					{ tagInstance.RarityRow.Holder, rowWeights.Rarity, tagInstance.ShowRarity },
					{ tagInstance.MutationRow.Holder, rowWeights.Mutation, tagInstance.ShowMutation },
					{ tagInstance.ValueRow.Holder, rowWeights.Value, tagInstance.ShowValue },
					{ tagInstance.ExtraRow.Holder, rowWeights.Info, tagInstance.ShowExtra },
				}

				local totalWeight = 0

				for _, tagRow in ipairs(tagRows) do
					if tagRow[3] then
						totalWeight += tagRow[2]
					end
				end

				local weightSum = math.max(totalWeight, 1)

				for _, rowEntry in ipairs(tagRows) do
					rowEntry[1].Visible = rowEntry[3]
					rowEntry[1].Size = UDim2.fromScale(1, rowEntry[3] and rowEntry[2] / weightSum or 0)
				end

				local rowWidth = espModule.ScaledWidth(120, espConfig.SizeScale)
				local height = math.max(1, math.floor(espModule.RowHeight(espConfig.SizeScale) * weightSum))

				if tagInstance.Width ~= rowWidth or tagInstance.Height ~= height or tagInstance.Fixed ~= espConfig.FixedSize then
					tagInstance.Width = rowWidth
					tagInstance.Height = height
					tagInstance.Fixed = espConfig.FixedSize

					if espConfig.FixedSize then
						local fixedPixels = fixedSizeScale * espConfig.SizeScale
						tagInstance.Billboard.Size = UDim2.fromScale(fixedPixels, fixedPixels * height / rowWidth)
						tagInstance.Billboard.MaxDistance = distanceToSize(fixedPixels)
					else
						tagInstance.Billboard.Size = UDim2.fromOffset(rowWidth, height)
						tagInstance.Billboard.MaxDistance = espConfig.MaxDistance
					end
				end
			end

			applyTagSize = function(tagHandle)
				tagHandle.Width = nil
				layoutTag(tagHandle)
			end

			local function createTag()
				local billboard, tagFrame = espModule.CreateTag(runtimeGui, espConfig.MaxDistance)
				local frame = Instance.new("Frame")
				frame.Name = generateRandomId()
				frame.BackgroundTransparency = 1
				frame.BorderSizePixel = 0
				frame.LayoutOrder = 0
				frame.Parent = tagFrame
				local imageLabel = Instance.new("ImageLabel")
				imageLabel.Name = generateRandomId()
				imageLabel.AnchorPoint = Vector2.new(0.5, 1)
				imageLabel.BackgroundTransparency = 1
				imageLabel.Position = UDim2.fromScale(0.5, 1)
				imageLabel.Size = UDim2.fromScale(1, 1)
				imageLabel.ScaleType = Enum.ScaleType.Fit
				imageLabel.Parent = frame
				local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
				uiAspectRatioConstraint.Name = generateRandomId()
				uiAspectRatioConstraint.AspectRatio = 1
				uiAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
				uiAspectRatioConstraint.Parent = imageLabel

				local tagData = {
					Billboard = billboard,
					IconHolder = frame,
					Icon = imageLabel,
					NameRow = espModule.CreateTextRow(tagFrame, espModule.MainFont, 1, 0.4),
					RarityRow = espModule.CreateTextRow(tagFrame, rarityFont, 2, 0.2),
					MutationRow = espModule.CreateTextRow(tagFrame, espModule.MainFont, 3, 0.2),
					ValueRow = espModule.CreateTextRow(tagFrame, espModule.MainFont, 4, 0.2),
					ExtraRow = espModule.CreateTextRow(tagFrame, espModule.MainFont, 5, 0.2),
					Highlight = nil,
					Anchor = nil,
					CFrame = nil,
					Width = nil,
					Height = nil,
					ShowIcon = false,
					ShowName = true,
					ShowRarity = false,
					ShowMutation = false,
					ShowValue = false,
					ShowExtra = false,
				}

				layoutTag(tagData)
				return tagData
			end

			local function removeHighlight(tagToUnhighlight)
				if tagToUnhighlight.Highlight then
					tagToUnhighlight.Highlight:Destroy()
					tagToUnhighlight.Highlight = nil
					highlightCount -= 1
				end
			end

			local function earningsFor(eggRecord, eggRarityInfo)
				local assetScale = tonumber(eggRecord.AssetScale) or 1
				local scaleFactor = assetScale > 5 and (assetScale / 5) ^ 1.2 * 19.637875755794113 or assetScale ^ 1.85
				local mutations = tbl.Mutations
				local flag6 = type(mutations) == "table" and type(mutations.EarningsFor) == "function"
				local mutationMultiplier = 1

				if flag6 then
					local ok, result = pcall(mutations.EarningsFor, type(eggRecord.Mutations) == "table" and eggRecord.Mutations or {})
					local flag7 = ok and type(result) == "number"
					local defaultMultiplier = 1

					if flag7 then
						mutationMultiplier = result
					else
						mutationMultiplier = defaultMultiplier
					end
				end

				return eggRarityInfo.EarningRate * scaleFactor * mutationMultiplier
			end

			local function readOwnBaseEggs()
				local baseRecords = {}
				local eggState = tbl.EggState
				local placedEggRenders = workspace:FindFirstChild("PlacedEggRenders")
				if not placedEggRenders or type(eggState) ~= "table" or type(eggState.ReadOwnerEggs) ~= "function" then
					return baseRecords
				end
				local ok, result = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)
				if not ok or type(result) ~= "table" then
					return baseRecords
				end
				local str = tostring(localPlayer.UserId)
				local renderChildren = {}

				for _, child in ipairs(placedEggRenders:GetChildren()) do
					if string.find(child.Name, str, 1, true) then
						renderChildren[#renderChildren + 1] = child
					end
				end

				for k, ownedRecord in pairs(result) do
					if type(ownedRecord) == "table" and ownedRecord.Placement ~= nil and type(ownedRecord.AssetCategory) == "string" then
						local base = tostring(k)
						local renderModel = nil

						for _, renderChild in ipairs(renderChildren) do
							if renderChild.Name == base or string.find(renderChild.Name, base, 1, true) or renderChild:GetAttribute("Uid") == base then
								renderModel = renderChild
								break
							end
						end

						if renderModel then
							local ok2, result2 = pcall(function()
								return renderModel:IsA("Model") and renderModel:GetPivot() or renderModel.CFrame
							end)

							local mutations = type(ownedRecord.Mutations) == "table" and ownedRecord.Mutations or {}

							baseRecords[#baseRecords + 1] = {
								Uid = "base:" .. base,
								AssetCategory = ownedRecord.AssetCategory,
								AssetScale = ownedRecord.AssetScale,
								Mutations = mutations,
								BaseMutation = ownedRecord.BaseMutation or mutations[1],
								State = "Base",
								AreaId = "Your Base",
								BottomCFrame = ok2 and result2 or nil,
								Model = renderModel,
							}
						end
					end
				end

				return baseRecords
			end

			local function passesFilters(filterEgg, filterRarity)
				if filterEgg.State == "Claimed" then
					return false
				end

				if espConfig.MinRarity > 0 and filterRarity.Number < espConfig.MinRarity then
					return false
				end
				local flag6 = espConfig.MinValue > 0

				if flag6 then
					local minValue = espConfig.MinValue
					flag6 = earningsFor(filterEgg, filterRarity) < minValue
				end

				if flag6 then
					return false
				end
				return true
			end

			local function renderEggTag(tagUi, tagEgg, tagRarity)
				local model, hitbox

				if typeof(tagEgg.Model) == "Instance" then
					model = tagEgg.Model
					hitbox = model:FindFirstChild("Hitbox", true) or model:FindFirstChildWhichIsA("BasePart", true)
					hitbox = hitbox and hitbox:IsA("BasePart") and hitbox or nil
				else
					model, hitbox = findAreaEggSlot(tagEgg.Uid)
				end

				local bottomCFrame = tagEgg.BottomCFrame

				if typeof(bottomCFrame) == "CFrame" then
					local terrain = hitbox or workspace.Terrain

					if tagUi.Anchor ~= terrain or tagUi.CFrame ~= bottomCFrame then
						tagUi.Anchor = terrain
						tagUi.CFrame = bottomCFrame
						tagUi.Billboard.Adornee = terrain
						tagUi.Billboard.StudsOffsetWorldSpace = bottomCFrame.Position - terrain.Position + Vector3.new(0, (hitbox and hitbox.Position.Y - bottomCFrame.Position.Y or 1) + tagHeightOffset, 0)
					end
				end

				local info = espConfig.Info
				local baseMutation = tagEgg.BaseMutation
				local showMutation = type(baseMutation) == "string" and baseMutation ~= ""
				local renderScale = tonumber(tagEgg.AssetScale) or 1
				local showIcon = info.Icon == true and tagRarity.Icon ~= nil

				if showIcon and tagUi.Icon.Image ~= tostring(tagRarity.Icon) then
					tagUi.Icon.Image = tostring(tagRarity.Icon)
				end

				local showName = info.Name == true

				if showName then
					espModule.SetRow(tagUi.NameRow, tagRarity.DisplayName, namePalette)
				end

				local showRarity = info.Rarity == true and tagRarity.Name ~= ""

				if showRarity then
					local rarityPalette = tagRarity.RarityPalette
					espModule.SetRow(tagUi.RarityRow, string.upper(tagRarity.Name), rarityPalette)
				end

				showMutation = info.Mutation == true and showMutation

				if showMutation then
					espModule.SetRow(tagUi.MutationRow, string.upper(mutationLabel(baseMutation)), mutationPalettes[baseMutation] or fallbackPalette)
				end

				local showValue = info.Value == true

				if showValue then
					espModule.SetRow(tagUi.ValueRow, "$" .. formatCompactNumber(earningsFor(tagEgg, tagRarity)) .. "/s", valuePalette)
				end

				local extraParts = {}
				local eggRecords = tbl.EggRecords

				if info.Weight and type(eggRecords) == "table" and type(eggRecords.WeightKgForScale) == "function" then
					local ok, result = pcall(eggRecords.WeightKgForScale, tagEgg.AssetCategory, renderScale)

					if ok and tonumber(result) then
						table.insert(extraParts, formatCompactNumber(result) .. " kg")
					end
				end

				if info.Size then
					table.insert(extraParts, string.format("x%.2f", renderScale))
				end

				if info["Sell Price"] and type(eggRecords) == "table" and type(eggRecords.SellPrice) == "function" then
					local ok, result = pcall(eggRecords.SellPrice, tagEgg)

					if ok and tonumber(result) then
						table.insert(extraParts, "$" .. formatCompactNumber(result))
					end
				end

				if info.Distance and typeof(bottomCFrame) == "CFrame" then
					local character = localPlayer.Character
					character = character and character:FindFirstChild("HumanoidRootPart")

					if character then
						table.insert(extraParts, string.format("%dm", math.floor((character.Position - bottomCFrame.Position).Magnitude + 0.5)))
					end
				end

				if info.Area and tagEgg.AreaId ~= nil then
					table.insert(extraParts, tostring(tagEgg.AreaId))
				end

				if info.State and tagEgg.State ~= nil and tagEgg.State ~= "Slot" then
					table.insert(extraParts, tostring(tagEgg.State))
				end

				local showExtra = #extraParts > 0

				if showExtra then
					espModule.SetRow(tagUi.ExtraRow, table.concat(extraParts, "  |  "), espModule.Palettes.Sheen)
				end

				if tagUi.ShowIcon ~= showIcon or tagUi.ShowName ~= showName or tagUi.ShowRarity ~= showRarity or tagUi.ShowMutation ~= showMutation or tagUi.ShowValue ~= showValue or tagUi.ShowExtra ~= showExtra then
					tagUi.ShowIcon = showIcon
					tagUi.ShowName = showName
					tagUi.ShowRarity = showRarity
					tagUi.ShowMutation = showMutation
					tagUi.ShowValue = showValue
					tagUi.ShowExtra = showExtra
					layoutTag(tagUi)
				end

				if (espConfig.Highlight == highlightModes[3] or espConfig.Highlight == highlightModes[2] and tagRarity.Number >= espConfig.HighlightMin) and model then
					if not tagUi.Highlight and highlightCount < maxHighlights then
						local highlight = Instance.new("Highlight")
						highlight.Name = generateRandomId()
						highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						highlight.FillTransparency = 0.82
						highlight.OutlineTransparency = 0.05
						highlight.FillColor = tagRarity.Color
						highlight.OutlineColor = tagRarity.Palette.Outline
						highlight.Parent = runtimeGui
						tagUi.Highlight = highlight
						highlightCount += 1
					end

					if tagUi.Highlight and tagUi.Highlight.Adornee ~= model then
						tagUi.Highlight.Adornee = model
					end
				else
					removeHighlight(tagUi)
				end
			end

			local function destroyTag(tagToDestroy)
				removeHighlight(tagToDestroy)
				tagToDestroy.Billboard:Destroy()
			end

			local function clearAllTags()
				local currentTags = espTags
				local oldRuntime = runtimeGui
				espTags = {}
				runtimeGui = nil
				highlightCount = 0

				task.spawn(function()
					local now = os.clock()

					for _, staleTag in pairs(currentTags) do
						if staleTag.Highlight then
							staleTag.Highlight:Destroy()
						end

						staleTag.Billboard:Destroy()

						if frameTimeBudget < os.clock() - now then
							RunService.Heartbeat:Wait()
							now = os.clock()
						end
					end

					if oldRuntime then
						oldRuntime:Destroy()
					end
				end)
			end

			local function updateTags(fieldRecords, updateSessionId, updateRevision)
				local function isStillCurrent()
					return updateSessionId == sessionId and updateRevision == revision and flag4
				end

				ensureRuntime()
				local seenUids = {}
				local now = os.clock()

				for _, fieldEgg in pairs(fieldRecords) do
					local uid = type(fieldEgg) == "table" and fieldEgg.Uid

					if type(uid) == "string" and type(fieldEgg.AssetCategory) == "string" then
						local eggRarity = paletteForCategory(fieldEgg.AssetCategory)

						if espConfig.Eggs and passesFilters(fieldEgg, eggRarity) then
							seenUids[uid] = true
							local eggTag = espTags[uid]

							if not eggTag then
								eggTag = createTag()
								espTags[uid] = eggTag
							end

							renderEggTag(eggTag, fieldEgg, eggRarity)
						end
					end

					if not (frameTimeBudget < os.clock() - now) then
						continue
					end
					RunService.Heartbeat:Wait()
					now = os.clock()
					if not isStillCurrent() then
						return
					end
				end

				if espConfig.Eggs and espConfig.OwnBase then
					for _, eggRecord in ipairs(readOwnBaseEggs()) do
						local eggStyleInfo = paletteForCategory(eggRecord.AssetCategory)

						if passesFilters(eggRecord, eggStyleInfo) then
							seenUids[eggRecord.Uid] = true
							local eggTagEntry = espTags[eggRecord.Uid]

							if not eggTagEntry then
								eggTagEntry = createTag()
								espTags[eggRecord.Uid] = eggTagEntry
							end

							renderEggTag(eggTagEntry, eggRecord, eggStyleInfo)
						end
					end
				end

				for k, staleEggTag in pairs(espTags) do
					if not seenUids[k] then
						espTags[k] = nil
						destroyTag(staleEggTag)
					end
				end

				return true
			end

			local flag6 = false
			local flag7 = false

			requestTagUpdate = function()
				if not flag4 or not lastRecords then
					return
				end
				flag6 = true
				if flag7 then
					return
				end
				flag7 = true

				task.defer(function()
					while flag4 and lastRecords and flag6 do
						flag6 = false
						sessionId += 1
						local ok, result = pcall(updateTags, lastRecords, sessionId, revision)

						if ok and result ~= true then
							flag6 = true
						end

						RunService.Heartbeat:Wait()
					end

					flag7 = false
				end)
			end

			local function refreshFieldEggs()
				local startGeneration = revision

				if lastRecords and next(espTags) == nil then
					requestTagUpdate()
				end

				local eggState = tbl.EggState
				local flag8 = type(eggState) == "table" and type(eggState.ReadFieldEggs) == "function"
				local records = nil

				if flag8 then
					local ok, result = pcall(eggState.ReadFieldEggs)
					ok = ok and type(result) == "table" and type(result.Records) == "table"
					records = nil

					if ok then
						records = result.Records
					end
				end

				if records == nil and rfEggWorldAskFieldEggSnapshot and os.clock() >= snapshotRetryAt then
					snapshotRetryAt = os.clock() + 30
					local ok, result = pcall(rfEggWorldAskFieldEggSnapshot.InvokeServer, rfEggWorldAskFieldEggSnapshot)

					if ok and type(result) == "table" and type(result.Records) == "table" then
						records = result.Records
					end
				end

				if startGeneration ~= revision or not flag4 then
					return
				end

				if records ~= nil then
					local recordsCopy = {}

					for k, record in pairs(records) do
						recordsCopy[k] = record
					end

					lastRecords = recordsCopy
				end

				if lastRecords then
					requestTagUpdate()
				end
			end

			local function scheduleFieldRefresh()
				task.spawn(pcall, refreshFieldEggs)
			end

			local function debouncedRefresh()
				if flag5 then
					return
				end
				flag5 = true

				task.delay(0.5, function()
					flag5 = false

					if flag4 then
						scheduleFieldRefresh()
					end
				end)
			end

			resizeAllTags = function()
				for _, eggTag in pairs(espTags) do
					applyTagSize(eggTag)
				end
			end

			local function stopEggMonitor()
				flag4 = false
				revision += 1
				sessionId += 1
				espModule.DisconnectAll(espConnections)
				clearAllTags()
			end

			local function startEggMonitor()
				if flag4 then
					scheduleFieldRefresh()
					return
				end
				flag4 = true
				local monitorGeneration = revision
				local eggState = tbl.EggState

				if type(eggState) == "table" then
					for _, eventName in ipairs({ "FieldRefreshed", "FieldShifted", "FieldGone", "FieldClaimed", "SnapshotRefreshed" }) do
						local eggEvent = eggState[eventName]

						if type(eggEvent) == "table" and type(eggEvent.Connect) == "function" then
							local ok, result = pcall(eggEvent.Connect, eggEvent, debouncedRefresh)

							if ok and result then
								table.insert(espConnections, result)
							end
						end
					end
				end

				for _, containerName in ipairs({ "AreaEggSlotsClient", "PlacedEggRenders" }) do
					local containerInst = workspace:FindFirstChild(containerName)

					if containerInst then
						table.insert(espConnections, containerInst.ChildAdded:Connect(debouncedRefresh))
						table.insert(espConnections, containerInst.ChildRemoved:Connect(debouncedRefresh))
					end
				end

				task.spawn(function()
					while monitorGeneration == revision do
						task.wait(10)
						if monitorGeneration == revision then
							debouncedRefresh()
							continue
						end
						break
					end
				end)

				task.spawn(function()
					while monitorGeneration == revision do
						task.wait(1)

						if monitorGeneration == revision then
							if espConfig.Info.Distance then
								requestTagUpdate()
							end

							continue
						end

						break
					end
				end)

				scheduleFieldRefresh()
			end

			local function syncEggMonitor()
				if espConfig.Eggs then
					startEggMonitor()
				else
					stopEggMonitor()
				end
			end

			espControls = { Eggs = nil }
			local eggToggleState = { Eggs = false }
			local flag8 = false

			local function applyEggToggle()
				if flag8 then
					return
				end
				local eggsEnabled = espModule.ReadToggle(espControls.Eggs, eggToggleState.Eggs)
				if eggsEnabled == espConfig.Eggs and flag4 == eggsEnabled then
					return
				end
				espConfig.Eggs = eggsEnabled
				syncEggMonitor()
			end

			addCleanup(function()
				flag8 = true
				espConfig.Eggs = false
				stopEggMonitor()
			end)

			normalizeInfoSet = function(infoOptions)
				local infoSet = {}

				if type(infoOptions) == "table" then
					for k, optionValue in pairs(infoOptions) do
						k = optionValue == true and type(k) == "string" and k
						local flag9

						if k then
							flag9 = k
						else
							flag9 = type(optionValue) == "string" and optionValue
						end

						flag9 = flag9 or nil

						if flag9 then
							infoSet[flag9] = true
						end
					end
				end

				return infoSet
			end

			espControls.Eggs = espSection:CreateToggle({
				Name = "ESP Eggs",
				Default = false,
				Callback = function(enabled)
					eggToggleState.Eggs = enabled == true
					espModule.SyncSoon(applyEggToggle)
				end,
			})
		end

		espSection:CreateToggle({
			Name = "ESP Fixed Size",
			Default = false,
			SubOf = espControls.Eggs,
			Callback = function(fixedSizeOn)
				local fixedSize = fixedSizeOn == true

				if espConfig.FixedSize ~= fixedSize then
					espConfig.FixedSize = fixedSize
					resizeAllTags()
				end
			end,
		})

		espSection:CreateToggle({
			Name = "ESP Own Base Eggs",
			Note = "Also show the eggs placed in your own base",
			Default = true,
			SubOf = espControls.Eggs,
			Callback = function(ownBaseOn)
				espConfig.OwnBase = ownBaseOn ~= false
				requestTagUpdate()
			end,
		})

		do
			local rarityOptions = { "Any" }
			local rarityValueByName = { Any = 0 }
			local eggNameOptions = {}
			local categoryByName = {}
			local mutationOptions = { "Any Mutation", "No Mutation" }
			local directory = tbl.Assets and tbl.Assets.Directory
			local rarityNameByNumber = {}
			local eggEntries = {}

			if type(directory) == "table" then
				for k, eggData in pairs(directory) do
					local rarity = type(eggData) == "table" and eggData.Rarity or nil
					local flag6 = type(rarity) == "table"

					if flag6 then
						flag6 = tonumber(rarity.RarityNumber or rarity.Rank)
					end

					flag6 = flag6 or nil

					if flag6 then
						local str = tostring(rarity.DisplayName or rarity._id or flag6)
						rarityNameByNumber[flag6] = rarityNameByNumber[flag6] or str

						table.insert(eggEntries, {
							Category = tostring(k),
							Name = tostring(eggData.DisplayName or k),
							Rarity = flag6,
							RarityName = str,
						})
					end
				end
			end

			local sortedRarities = {}

			for k in pairs(rarityNameByNumber) do
				table.insert(sortedRarities, k)
			end

			table.sort(sortedRarities)

			for _, rarityNumber in ipairs(sortedRarities) do
				local str = string.format("%d - %s", rarityNumber, rarityNameByNumber[rarityNumber])
				table.insert(rarityOptions, str)
				rarityValueByName[str] = rarityNumber
			end

			table.sort(eggEntries, function(entryA, entryB)
				if entryA.Rarity ~= entryB.Rarity then
					return entryA.Rarity > entryB.Rarity
				end
				return entryA.Name < entryB.Name
			end)

			for _, eggEntry in ipairs(eggEntries) do
				local str = string.format("%s [%s]", eggEntry.Name, eggEntry.RarityName)

				if categoryByName[str] then
					str = string.format("%s [%s] (%s)", eggEntry.Name, eggEntry.RarityName, eggEntry.Category)
				end

				table.insert(eggNameOptions, str)
				categoryByName[str] = eggEntry.Category
			end

			local mutationIds = {}
			local mutations = tbl.Mutations

			if type(mutations) == "table" and type(mutations.IdSet) == "table" then
				for k in pairs(mutations.IdSet) do
					table.insert(mutationIds, tostring(k))
				end
			end

			table.sort(mutationIds)

			for _, mutationId in ipairs(mutationIds) do
				table.insert(mutationOptions, mutationId)
			end

			local function rarityLabelFor(targetRarity)
				for _, rarityOption in ipairs(rarityOptions) do
					if rarityValueByName[rarityOption] == targetRarity then
						return rarityOption
					end
				end

				return rarityOptions[1]
			end

			espSection:CreateDropdown({
				Name = "ESP Min Rarity",
				Note = "Show eggs of the chosen rarity and every rarity above it",
				Options = rarityOptions,
				Default = rarityLabelFor(5),
				SubOf = espControls.Eggs,
				Callback = function(selectedRarity)
					espConfig.MinRarity = rarityValueByName[type(selectedRarity) == "table" and selectedRarity[1] or selectedRarity] or 0
					requestTagUpdate()
				end,
			})
		end

		fixNoneLabel(espSection:CreateMultiDropdown({
			Name = "ESP Show Info",
			Options = allColumns,
			Default = infoColumns,
			SubOf = espControls.Eggs,
			Callback = function(selectedInfo)
				espConfig.Info = normalizeInfoSet(selectedInfo)
				requestTagUpdate()
			end,
		}))

		do
			local unitConfig = {
				["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
				["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
				["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
			}

			local minValue = 0
			local str = "M/s"

			local function setMinValue(value, unit)
				if value ~= nil then
					minValue = math.max(0, math.floor(tonumber(value) or minValue))
				end

				if unit ~= nil then
					str = tostring(unit)
				end

				espConfig.MinValue = minValue * (unitConfig[str] or unitConfig["M/s"]).Mult
				requestTagUpdate()
			end

			createValueSlider(espSection, {
				Name = "Min ESP Value",
				SubOf = espControls.Eggs,
				Legacy = "ESP Min Value",
				SectionName = "ESP",
				OnRaw = function(rawValue)
					setMinValue(math.floor(rawValue / 1000), "K/s")
				end,
			})
		end

		espSection:CreateSlider({
			Name = "ESP Egg Size",
			Min = 50,
			Max = 200,
			Default = 75,
			Increment = 5,
			Unit = "%",
			SubOf = espControls.Eggs,
			Callback = function(sizeValue)
				local num = tonumber(sizeValue)

				if num and espConfig.SizeScale ~= num / 100 then
					espConfig.SizeScale = num / 100
					resizeAllTags()
				end
			end,
		})

		do
			local guardLabelOffset = 1
			local guardScale = 0.75

			local guardStatePalettes = {
				Sleeping = espModule.Palettes.Accent,
				Waking = espModule.Palettes.Gold,
				Chasing = espModule.Palettes.Red,
			}

			local orange = espModule.Palettes.Orange
			local guardTags = {}
			local guardWatchConnections = {}
			local flag6 = false
			local guardRuntime = nil

			local function guardStateLabel(guard)
				local attribute = guard:GetAttribute("GuardState")
				if attribute == "Sleeping" then
					return "Sleeping"
				end

				if attribute == "Waking" then
					return "Waking Up"
				end

				if attribute == "Chasing" then
					local attribute2 = guard:GetAttribute("TargetPlayer")
					if attribute2 == tostring(localPlayer.UserId) then
						return "Chasing You"
					end
					local playerByUserId = tonumber(attribute2) and Players:GetPlayerByUserId(tonumber(attribute2))
					return playerByUserId and "Chasing " .. playerByUserId.DisplayName or "Chasing"
				end

				return attribute and tostring(attribute) or "Awake"
			end

			local function applyGuardTag(tagRecord, guardInst)
				local statePalette = guardStatePalettes[guardInst:GetAttribute("GuardState")] or orange
				tagRecord.Highlight.FillColor = statePalette.Outline
				tagRecord.Highlight.OutlineColor = statePalette.Outline
				espModule.SetRow(tagRecord.StateRow, guardStateLabel(guardInst), statePalette)
			end

			local function sizeGuardTag(tagWidget)
				local floor = math.floor
				tagWidget.Tag.Size = UDim2.fromOffset(espModule.ScaledWidth(115, guardScale), floor(espModule.RowHeight(guardScale) * 1.6))
			end

			local function removeGuardTag(adornee)
				local existingTag = guardTags[adornee]
				if not existingTag then
					return
				end
				guardTags[adornee] = nil
				espModule.DisconnectAll(existingTag.Connections)
				existingTag.Highlight:Destroy()
				existingTag.Tag:Destroy()
			end

			local function addGuardTag(guardName, adornee)
				if guardTags[adornee] then
					return
				end
				local guardRoot = espModule.FindGuardRoot(adornee)
				if not guardRoot then
					return
				end

				if not guardRuntime or not guardRuntime.Parent then
					guardRuntime = espModule.CreateRuntime()
				end

				local highlight = Instance.new("Highlight")
				highlight.Name = generateRandomId()
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.FillTransparency = 0.76
				highlight.OutlineTransparency = 0.02
				highlight.Adornee = adornee
				highlight.Parent = guardRuntime
				local ok, result, result2 = pcall(adornee.GetBoundingBox, adornee)
				local flag7 = ok and typeof(result) == "CFrame"
				local tagOffsetY = 6

				if flag7 then
					tagOffsetY = result.Position.Y + result2.Y * 0.5 - guardRoot.Position.Y + guardLabelOffset
				end

				local guardBillboard, guardTagFrame = espModule.CreateTag(guardRuntime, math.huge)
				guardBillboard.Adornee = guardRoot
				guardBillboard.StudsOffsetWorldSpace = Vector3.new(0, tagOffsetY, 0)
				local guardNameRow = espModule.CreateTextRow(guardTagFrame, espModule.StatusFont, 1, 0.45)
				local guardStateRow = espModule.CreateTextRow(guardTagFrame, espModule.StatusFont, 2, 0.55)
				local sheen = espModule.Palettes.Sheen
				espModule.SetRow(guardNameRow, tostring(guardName) .. " Guard", sheen)
				local guardTagRecord = { Highlight = highlight, Tag = guardBillboard, StateRow = guardStateRow, Connections = {} }
				guardTags[adornee] = guardTagRecord
				sizeGuardTag(guardTagRecord)
				applyGuardTag(guardTagRecord, adornee)

				local function refreshGuardTag()
					applyGuardTag(guardTagRecord, adornee)
				end

				table.insert(guardTagRecord.Connections, adornee:GetAttributeChangedSignal("GuardState"):Connect(refreshGuardTag))
				table.insert(guardTagRecord.Connections, adornee:GetAttributeChangedSignal("TargetPlayer"):Connect(refreshGuardTag))

				table.insert(guardTagRecord.Connections, adornee.AncestryChanged:Connect(function()
					if not adornee:IsDescendantOf(workspace) then
						removeGuardTag(adornee)
					end
				end))
			end

			local function clearGuardTags()
				flag6 = false
				espModule.DisconnectAll(guardWatchConnections)

				for k in pairs(guardTags) do
					removeGuardTag(k)
				end

				if guardRuntime then
					guardRuntime:Destroy()
					guardRuntime = nil
				end
			end

			local function startGuardWatch()
				if flag6 then
					return
				end
				flag6 = true
				guardWatchConnections = espModule.WatchGuards(addGuardTag)
			end

			local guardsToggle = nil
			local flag7 = false
			local flag8 = false

			local function syncGuardWatch()
				if flag8 then
					return
				end

				if espModule.ReadToggle(guardsToggle, flag7) then
					startGuardWatch()
				elseif flag6 then
					clearGuardTags()
				end
			end

			addCleanup(function()
				flag8 = true
				clearGuardTags()
			end)

			guardsToggle = espSection:CreateToggle({
				Name = "ESP Guards",
				Default = false,
				Callback = function(guardsOn)
					flag7 = guardsOn == true
					espModule.SyncSoon(syncGuardWatch)
				end,
			})

			espSection:CreateSlider({
				Name = "ESP Guard Size",
				Min = 50,
				Max = 200,
				Default = 75,
				Increment = 5,
				Unit = "%",
				SubOf = guardsToggle,
				Callback = function(guardSizeValue)
					local num = tonumber(guardSizeValue)

					if num and guardScale ~= num / 100 then
						guardScale = num / 100

						for _, guardTagEntry in pairs(guardTags) do
							sizeGuardTag(guardTagEntry)
						end
					end
				end,
			})
		end

		do
			local lostPartDefs = {
				{ Id = "LostPart1", Label = "Mechanical Gear" },
				{ Id = "LostPart2", Label = "Wiring Harness" },
			}

			local defaultPalette = espModule.PaletteFromColor(Color3.fromRGB(255, 216, 61))
			local accent = espModule.Palettes.Accent
			local lostPartRuntime = nil
			local lostPartTags = {}
			local flag6 = false
			local connection = nil
			local lostPartsToggle = nil
			local flag7 = false
			local flag8 = false

			local function removeLostPartTag(partId)
				local lostPartTag = lostPartTags[partId]
				if not lostPartTag then
					return
				end
				lostPartTags[partId] = nil

				pcall(function()
					lostPartTag.Highlight:Destroy()
					lostPartTag.Tag:Destroy()
				end)
			end

			local function updateLostParts()
				local drScrambleEvent = workspace:FindFirstChild("DrScrambleEvent")

				for _, partDef in ipairs(lostPartDefs) do
					local partModel = drScrambleEvent and drScrambleEvent:FindFirstChild(partDef.Id)
					local hitbox = partModel and (partModel:FindFirstChild("Hitbox", true) or partModel.PrimaryPart or partModel:FindFirstChildWhichIsA("BasePart", true))
					local partTagState = lostPartTags[partDef.Id]

					if partTagState and (partTagState.Model ~= partModel or not hitbox) then
						removeLostPartTag(partDef.Id)
						partTagState = nil
					end

					if hitbox and not partTagState then
						if not lostPartRuntime or not lostPartRuntime.Parent then
							lostPartRuntime = espModule.CreateRuntime()
						end

						local highlight = Instance.new("Highlight")
						highlight.Name = generateRandomId()
						highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						highlight.FillTransparency = 0.7
						highlight.OutlineTransparency = 0.02
						highlight.Adornee = partModel
						highlight.Parent = lostPartRuntime
						local partBillboard, partTagFrame = espModule.CreateTag(lostPartRuntime, 25000)
						partBillboard.Adornee = hitbox
						partBillboard.StudsOffsetWorldSpace = Vector3.new(0, 4, 0)
						local floor = math.floor
						partBillboard.Size = UDim2.fromOffset(espModule.ScaledWidth(160), floor(espModule.RowHeight() * 1.6))
						local partNameRow = espModule.CreateTextRow(partTagFrame, espModule.StatusFont, 1, 0.5)
						local partInfoRow = espModule.CreateTextRow(partTagFrame, espModule.StatusFont, 2, 0.5)
						espModule.SetRow(partNameRow, partDef.Label, espModule.Palettes.Sheen)
						partTagState = { Model = partModel, Hitbox = hitbox, Highlight = highlight, Tag = partBillboard, InfoRow = partInfoRow }
						lostPartTags[partDef.Id] = partTagState
					end

					if partTagState then
						local flag9 = type(saeApi.ScrambleLostPart) == "function" and saeApi.ScrambleLostPart(partDef.Id) == true
						local rowPalette = flag9 and accent or defaultPalette
						espModule.SetRow(partTagState.InfoRow, flag9 and "Collected" or string.format("%d studs", math.floor(saeApi.DistanceTo(partTagState.Hitbox.Position))), rowPalette)
						partTagState.Highlight.FillColor = rowPalette.Outline
						partTagState.Highlight.OutlineColor = rowPalette.Outline
					end
				end
			end

			local function clearLostPartTags()
				flag6 = false

				if connection then
					connection:Disconnect()
					connection = nil
				end

				for k in pairs(lostPartTags) do
					removeLostPartTag(k)
				end

				if lostPartRuntime then
					lostPartRuntime:Destroy()
					lostPartRuntime = nil
				end
			end

			local function startLostPartWatch()
				if flag6 then
					return
				end
				flag6 = true
				local scanTimer = 1

				connection = RunService.Heartbeat:Connect(function(deltaTime)
					scanTimer += deltaTime

					if scanTimer >= 0.3 then
						scanTimer = 0
						pcall(updateLostParts)
					end
				end)
			end

			local function syncLostParts()
				if flag8 then
					return
				end

				if espModule.ReadToggle(lostPartsToggle, flag7) then
					startLostPartWatch()
				elseif flag6 then
					clearLostPartTags()
				end
			end

			addCleanup(function()
				flag8 = true
				clearLostPartTags()
			end)

			lostPartsToggle = espSection:CreateToggle({
				Name = "ESP Lost Parts",
				Default = false,
				Callback = function(lostPartsOn)
					flag7 = lostPartsOn == true
					espModule.SyncSoon(syncLostParts)
				end,
			})
		end

		local TextService = game:GetService("TextService")
		local font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
		local nameGradientSequence

		do
			local colorSequence = ColorSequence.new
			local gradientKeypoints = {}
			local gradientStart = ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 255, 205))
			local gradientMid = ColorSequenceKeypoint.new(0.5, Color3.fromRGB(125, 225, 255))
			gradientKeypoints[1] = gradientStart
			gradientKeypoints[2] = gradientMid

			do
				local values = table.pack(ColorSequenceKeypoint.new(1, Color3.fromRGB(210, 135, 255)))
				table.move(values, 1, values.n, 3, gradientKeypoints)
			end

			nameGradientSequence = colorSequence(gradientKeypoints)
		end

		local colorSequence

		colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(7, 73, 66)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 17, 79)),
		})

		local flag6 = false
		local playerEspGeneration = 0
		local playerEspRuntime = nil
		local playerTags = {}
		local playerEspConnections = {}
		local avatarCache = {}
		local playerScale, playerInfoOptions, playersToggle, flag7, flag8

		do
			local textBoundsCache = {}
			playerScale = 0.75
			playerInfoOptions = { Name = true, Username = false, Avatar = false, Tool = true }
			playersToggle = nil
			flag7 = false
			flag8 = false

			local function normalizeAssetId(textureId)
				local str = tostring(textureId or "")
				if str:match("^%d+$") then
					return "rbxassetid://" .. str
				end
				return str
			end

			local function findToolIcon(tool)
				if not tool or not tool:IsA("Tool") then
					return ""
				end
				local iconId = normalizeAssetId(tool.TextureId)
				if iconId ~= "" then
					return iconId
				end

				for _, attributeName in ipairs({ "Icon", "Image", "Thumbnail", "TextureId" }) do
					local attribute = tool:GetAttribute(attributeName)
					if type(attribute) == "string" and normalizeAssetId(attribute) ~= "" then
						return normalizeAssetId(attribute)
					end
				end

				for _, descendant in ipairs(tool:GetDescendants()) do
					if descendant:IsA("Decal") or descendant:IsA("Texture") then
						iconId = normalizeAssetId(descendant.Texture)
					elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
						iconId = normalizeAssetId(descendant.Image)
					end

					if iconId ~= "" then
						return iconId
					end
				end

				return ""
			end

			local function playerTagHeight()
				local currentCamera = workspace.CurrentCamera
				return math.max(1, math.floor(math.clamp((currentCamera and currentCamera.ViewportSize.Y or 1080) * 0.024, 26, 35) * playerScale))
			end

			local function measureText(text, size)
				local str = text .. "@" .. size
				local cachedBounds = textBoundsCache[str]
				if cachedBounds then
					return cachedBounds
				end
				local getTextBoundsParams = Instance.new("GetTextBoundsParams")
				getTextBoundsParams.Text = text
				getTextBoundsParams.Font = font
				getTextBoundsParams.Size = size
				getTextBoundsParams.Width = 1000

				local ok, result = pcall(function()
					return TextService:GetTextBoundsAsync(getTextBoundsParams)
				end)

				getTextBoundsParams:Destroy()
				ok = ok and result.X

				if not ok then
					ok = (utf8.len(text) or #text) * size * 0.56
				end

				textBoundsCache[str] = ok
				return ok
			end

			local function setupUiStroke(uiStroke, color3, scaledThickness, fallbackThickness)
				uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
				uiStroke.Color = color3
				uiStroke.LineJoinMode = Enum.LineJoinMode.Round
				uiStroke.Transparency = 0

				uiStroke.Thickness = pcall(function()
					uiStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
				end) and scaledThickness or fallbackThickness
			end

			local function createTextLabel(parent, zIndex)
				local textLabel = Instance.new("TextLabel")
				textLabel.Name = generateRandomId()
				textLabel.AnchorPoint = Vector2.new(0, 0.5)
				textLabel.BackgroundTransparency = 1
				textLabel.FontFace = font
				textLabel.Text = ""
				textLabel.TextScaled = true
				textLabel.TextStrokeTransparency = 1
				textLabel.TextXAlignment = Enum.TextXAlignment.Center
				textLabel.TextYAlignment = Enum.TextYAlignment.Center
				textLabel.ZIndex = zIndex
				textLabel.Parent = parent
				return textLabel
			end

			local function createImageLabel(parent, zIndex)
				local imageLabel = Instance.new("ImageLabel")
				imageLabel.Name = generateRandomId()
				imageLabel.AnchorPoint = Vector2.new(0, 0.5)
				imageLabel.BackgroundTransparency = 1
				imageLabel.ScaleType = Enum.ScaleType.Fit
				imageLabel.ZIndex = zIndex
				imageLabel.Parent = parent
				local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
				uiAspectRatioConstraint.Name = generateRandomId()
				uiAspectRatioConstraint.AspectRatio = 1
				uiAspectRatioConstraint.Parent = imageLabel
				return imageLabel
			end

			local function layoutPlayerTag(tagState)
				local tagHeight = playerTagHeight()
				local visible = playerInfoOptions.Name == true or playerInfoOptions.Username == true
				local visible2 = playerInfoOptions.Avatar == true
				local visible3 = playerInfoOptions.Tool == true and tagState.ToolIcon.Image ~= ""
				local avatarHeight = visible2 and math.floor(tagHeight * 0.72) or 0
				local toolHeight = visible3 and math.floor(tagHeight * 0.82) or 0
				local nameHeight = math.floor(tagHeight * 0.7)
				local gapSize = math.max(1, math.floor(tagHeight * 0.04))
				local name = playerInfoOptions.Username == true and tagState.Player.Name or tagState.Player.DisplayName
				tagState.Name.Text = name
				tagState.Shadow.Text = name
				local nameWidth = visible and math.floor(math.clamp(measureText(name, nameHeight) + 4, nameHeight, 230)) or 0
				local cursorX = 0
				local avatarOffsetX = 0

				if visible2 then
					cursorX = 0 + avatarHeight
				end

				local nameOffsetX = 0

				if visible then
					if not (cursorX > 0) then
						nameOffsetX = cursorX
					else
						nameOffsetX = cursorX + gapSize
					end

					cursorX = nameOffsetX + nameWidth
				end

				local toolOffsetX = 0

				if visible3 then
					if not (cursorX > 0) then
						toolOffsetX = cursorX
					else
						toolOffsetX = cursorX + gapSize
					end

					cursorX = toolOffsetX + toolHeight
				end

				local totalWidth = math.max(cursorX, 1)
				local shadowOffsetX = 1 / totalWidth
				local shadowOffsetY = 1 / tagHeight
				tagState.Billboard.Size = UDim2.fromOffset(totalWidth, tagHeight)
				tagState.Avatar.Visible = visible2
				tagState.Name.Visible = visible
				tagState.Shadow.Visible = visible
				tagState.ToolIcon.Visible = visible3
				tagState.ToolShadow.Visible = visible3
				tagState.Avatar.Position = UDim2.fromScale(avatarOffsetX / totalWidth, 0.5)
				tagState.Avatar.Size = UDim2.fromScale(avatarHeight / totalWidth, avatarHeight / tagHeight)
				tagState.Name.Position = UDim2.fromScale(nameOffsetX / totalWidth, 0.5)
				tagState.Name.Size = UDim2.fromScale(nameWidth / totalWidth, nameHeight / tagHeight)
				tagState.Shadow.Position = UDim2.fromScale(nameOffsetX / totalWidth + shadowOffsetX, 0.5 + shadowOffsetY)
				tagState.Shadow.Size = tagState.Name.Size
				tagState.ToolIcon.Position = UDim2.fromScale(toolOffsetX / totalWidth, 0.5)
				tagState.ToolIcon.Size = UDim2.fromScale(toolHeight / totalWidth, toolHeight / tagHeight)
				tagState.ToolShadow.Position = UDim2.fromScale(toolOffsetX / totalWidth + shadowOffsetX, 0.5 + shadowOffsetY)
				tagState.ToolShadow.Size = tagState.ToolIcon.Size
			end

			local function createPlayerTag(player, adornee, headPart, adornee2)
				local highlight = Instance.new("Highlight")
				highlight.Name = generateRandomId()
				highlight.Adornee = adornee
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.FillColor = Color3.fromRGB(0, 67, 148)
				highlight.FillTransparency = 0.76
				highlight.OutlineColor = Color3.fromRGB(72, 207, 255)
				highlight.OutlineTransparency = 0.02
				highlight.Parent = playerEspRuntime
				adornee2 = adornee2 or headPart
				local tagStudsOffset = 3.1

				if adornee2 ~= headPart then
					tagStudsOffset = math.clamp(headPart.Position.Y - adornee2.Position.Y + 3.1, 3.8, 6)
				end

				local billboardGui = Instance.new("BillboardGui")
				billboardGui.Name = generateRandomId()
				billboardGui.Adornee = adornee2
				billboardGui.AlwaysOnTop = true
				billboardGui.LightInfluence = 0
				billboardGui.MaxDistance = math.huge
				billboardGui.Size = UDim2.fromOffset(1, 1)
				billboardGui.StudsOffsetWorldSpace = Vector3.new(0, tagStudsOffset, 0)
				billboardGui.Parent = playerEspRuntime
				local frame = Instance.new("Frame")
				frame.Name = generateRandomId()
				frame.Size = UDim2.fromScale(1, 1)
				frame.BackgroundTransparency = 1
				frame.Parent = billboardGui
				local avatarImage = createImageLabel(frame, 2)
				avatarImage.ScaleType = Enum.ScaleType.Crop
				local uiCorner = Instance.new("UICorner")
				uiCorner.Name = generateRandomId()
				uiCorner.CornerRadius = UDim.new(1, 0)
				uiCorner.Parent = avatarImage
				local shadowLabel = createTextLabel(frame, 1)
				shadowLabel.TextColor3 = Color3.fromRGB(7, 19, 34)
				shadowLabel.TextTransparency = 0.05
				local nameLabel = createTextLabel(frame, 2)
				nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				local uiStroke = Instance.new("UIStroke")
				uiStroke.Name = generateRandomId()
				setupUiStroke(uiStroke, Color3.fromRGB(255, 255, 255), 0.044, 1.4)
				uiStroke.Parent = nameLabel
				local uiGradient = Instance.new("UIGradient")
				uiGradient.Name = generateRandomId()
				uiGradient.Color = colorSequence
				uiGradient.Rotation = 90
				uiGradient.Parent = uiStroke
				local uiGradient2 = Instance.new("UIGradient")
				uiGradient2.Name = generateRandomId()
				uiGradient2.Color = nameGradientSequence
				uiGradient2.Rotation = 90
				uiGradient2.Parent = nameLabel
				local toolShadowImage = createImageLabel(frame, 1)
				toolShadowImage.ImageColor3 = Color3.fromRGB(0, 0, 0)
				toolShadowImage.ImageTransparency = 0.35

				local playerTagData = {
					Player = player,
					Highlight = highlight,
					Billboard = billboardGui,
					Avatar = avatarImage,
					Shadow = shadowLabel,
					Name = nameLabel,
					ToolShadow = toolShadowImage,
					ToolIcon = createImageLabel(frame, 2),
				}

				layoutPlayerTag(playerTagData)
				return playerTagData
			end

			local function restoreNameDisplay(nameTag)
				if nameTag.NameHumanoid and nameTag.NameHumanoid.Parent and nameTag.NameDistance ~= nil then
					pcall(function()
						nameTag.NameHumanoid.NameDisplayDistance = nameTag.NameDistance
					end)
				end

				nameTag.NameHumanoid = nil
				nameTag.NameDistance = nil
			end

			local function hideNameDisplay(hideTagState, character)
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if not humanoid then
					return
				end

				if hideTagState.NameHumanoid ~= humanoid then
					restoreNameDisplay(hideTagState)
					hideTagState.NameHumanoid = humanoid
					hideTagState.NameDistance = humanoid.NameDisplayDistance
				end

				pcall(function()
					humanoid.NameDisplayDistance = 0
				end)
			end

			local function clearPlayerTag(cleanupTag)
				espModule.DisconnectAll(cleanupTag.CharacterConnections)

				if cleanupTag.Tag then
					pcall(function()
						cleanupTag.Tag.Highlight:Destroy()
					end)

					pcall(function()
						cleanupTag.Tag.Billboard:Destroy()
					end)

					cleanupTag.Tag = nil
				end

				restoreNameDisplay(cleanupTag)
				cleanupTag.Character = nil
			end

			local function refreshToolIcon(toolTag)
				if not toolTag.Tag or not toolTag.Character then
					return
				end
				local toolIconId = findToolIcon(toolTag.Character:FindFirstChildOfClass("Tool"))
				toolTag.Tag.ToolIcon.Image = toolIconId
				toolTag.Tag.ToolShadow.Image = toolIconId
				layoutPlayerTag(toolTag.Tag)
			end

			local function loadAvatarImage(avatarTag, playerInst, version)
				local image = avatarCache[playerInst.UserId]

				if image == nil then
					local ok, result = pcall(function()
						return Players:GetUserThumbnailAsync(playerInst.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
					end)

					image = ok and result or ""
					avatarCache[playerInst.UserId] = image
				end

				if flag6 and avatarTag.Version == version and avatarTag.Tag then
					avatarTag.Tag.Avatar.Image = image
				end
			end

			local function attachPlayerTag(attachTagState, ownerPlayer, character)
				clearPlayerTag(attachTagState)
				attachTagState.Version = attachTagState.Version + 1
				local version = attachTagState.Version
				if not flag6 or not character then
					return
				end
				attachTagState.Character = character

				task.spawn(function()
					local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 5)
					if not flag6 or attachTagState.Version ~= version or not head or not head:IsA("BasePart") or not character:IsDescendantOf(workspace) then
						return
					end

					if not playerEspRuntime or not playerEspRuntime.Parent then
						playerEspRuntime = espModule.CreateRuntime()
					end

					local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
					attachTagState.Tag = createPlayerTag(ownerPlayer, character, head, humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoidRootPart or nil)
					hideNameDisplay(attachTagState, character)

					local function refreshTagTool()
						task.defer(function()
							if flag6 and attachTagState.Version == version then
								refreshToolIcon(attachTagState)
							end
						end)
					end

					table.insert(attachTagState.CharacterConnections, character.ChildAdded:Connect(function(child)
						if child:IsA("Tool") then
							refreshTagTool()
						elseif child:IsA("Humanoid") then
							hideNameDisplay(attachTagState, character)
						end
					end))

					table.insert(attachTagState.CharacterConnections, character.ChildRemoved:Connect(function(child)
						if child:IsA("Tool") then
							refreshTagTool()
						end
					end))

					table.insert(attachTagState.CharacterConnections, character.AncestryChanged:Connect(function()
						if attachTagState.Version == version and not character:IsDescendantOf(workspace) then
							attachTagState.Version = attachTagState.Version + 1
							clearPlayerTag(attachTagState)
						end
					end))

					refreshToolIcon(attachTagState)
					loadAvatarImage(attachTagState, ownerPlayer, version)
				end)
			end

			local function removePlayerTag(player)
				local storedTag = playerTags[player]
				if not storedTag then
					return
				end
				storedTag.Version = storedTag.Version + 1
				clearPlayerTag(storedTag)
				espModule.DisconnectAll(storedTag.PlayerConnections)
				playerTags[player] = nil
			end

			local function addPlayerTag(player)
				if player == localPlayer or playerTags[player] then
					return
				end

				local newTagState = {
					Version = 0,
					Character = nil,
					Tag = nil,
					NameHumanoid = nil,
					NameDistance = nil,
					CharacterConnections = {},
					PlayerConnections = {},
				}

				playerTags[player] = newTagState

				table.insert(newTagState.PlayerConnections, player.CharacterAdded:Connect(function(character)
					attachPlayerTag(newTagState, player, character)
				end))

				table.insert(newTagState.PlayerConnections, player.CharacterRemoving:Connect(function(character)
					if newTagState.Character == character then
						newTagState.Version = newTagState.Version + 1
						clearPlayerTag(newTagState)
					end
				end))

				attachPlayerTag(newTagState, player, player.Character)
			end

			local function relayoutPlayerTags()
				for _, existingTagState in pairs(playerTags) do
					if existingTagState.Tag then
						layoutPlayerTag(existingTagState.Tag)
					end
				end
			end

			local function stopPlayerEsp()
				flag6 = false
				playerEspGeneration += 1
				espModule.DisconnectAll(playerEspConnections)
				local playerList = {}

				for k in pairs(playerTags) do
					table.insert(playerList, k)
				end

				for _, playerObj in ipairs(playerList) do
					removePlayerTag(playerObj)
				end

				if playerEspRuntime then
					playerEspRuntime:Destroy()
					playerEspRuntime = nil
				end
			end

			local function startPlayerEsp()
				if flag6 then
					return
				end
				flag6 = true
				playerEspGeneration += 1
				local espGeneration = playerEspGeneration
				playerEspRuntime = espModule.CreateRuntime()

				for _, player in ipairs(Players:GetPlayers()) do
					addPlayerTag(player)
				end

				table.insert(playerEspConnections, Players.PlayerAdded:Connect(addPlayerTag))
				table.insert(playerEspConnections, Players.PlayerRemoving:Connect(removePlayerTag))
				local currentCamera = workspace.CurrentCamera

				if currentCamera then
					table.insert(playerEspConnections, currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(relayoutPlayerTags))
				end

				task.spawn(function()
					while true do
						if flag6 and espGeneration == playerEspGeneration then
							task.wait(1)

							if not (not flag6 or espGeneration ~= playerEspGeneration) then
								for k, playerTagState in pairs(playerTags) do
									local character = k.Character
									local adornee = playerTagState.Tag and playerTagState.Tag.Billboard.Parent and playerTagState.Tag.Billboard.Adornee and playerTagState.Tag.Billboard.Adornee:IsDescendantOf(workspace)

									if character and character:IsDescendantOf(workspace) and (playerTagState.Character ~= character or not adornee) then
										attachPlayerTag(playerTagState, k, character)
									end
								end

								continue
							end
						end

						break
					end
				end)
			end

			local function syncPlayerEsp()
				if flag8 then
					return
				end

				if espModule.ReadToggle(playersToggle, flag7) then
					startPlayerEsp()
				elseif flag6 then
					stopPlayerEsp()
				end
			end

			addCleanup(function()
				flag8 = true
				stopPlayerEsp()
			end)

			playersToggle = espSection:CreateToggle({
				Name = "ESP Players",
				Default = false,
				Callback = function(playersOn)
					flag7 = playersOn == true
					espModule.SyncSoon(syncPlayerEsp)
				end,
			})

			fixNoneLabel(espSection:CreateMultiDropdown({
				Name = "ESP Player Info",
				Options = { "Name", "Username", "Avatar", "Tool" },
				Default = { "Name", "Tool" },
				SubOf = playersToggle,
				Callback = function(selectedOptions)
					local playerInfoSet = { Name = false, Username = false, Avatar = false, Tool = false }

					if type(selectedOptions) == "table" then
						for k, selectedValue in pairs(selectedOptions) do
							if type(selectedValue) == "string" and playerInfoSet[selectedValue] ~= nil then
								playerInfoSet[selectedValue] = true
							elseif type(k) == "string" and selectedValue == true and playerInfoSet[k] ~= nil then
								playerInfoSet[k] = true
							end
						end
					end

					playerInfoOptions = playerInfoSet
					relayoutPlayerTags()
				end,
			}))

			espSection:CreateSlider({
				Name = "ESP Player Size",
				Min = 50,
				Max = 200,
				Default = 75,
				Increment = 5,
				Unit = "%",
				SubOf = playersToggle,
				Callback = function(playerSizeValue)
					local num = tonumber(playerSizeValue)

					if num and playerScale ~= num / 100 then
						playerScale = math.clamp(num / 100, 0.5, 2)
						relayoutPlayerTags()
					end
				end,
			})
		end
	return { espModule = espModule }
end
