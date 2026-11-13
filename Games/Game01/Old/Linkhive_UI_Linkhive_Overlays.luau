return function(ctx)
	ctx = ctx or {}
	local ui = ctx.ui
	if not (ui and ui.C) then return {} end

	local C = ui.C
	local gui = ctx.gui
	local corner = ui.corner
	local label = ui.label
	local liveGrad = ui.liveGrad
	local addLivingStroke = ui.addLivingStroke
	local TweenService = (ctx.services and ctx.services.TweenService) or game:GetService("TweenService")
	local Airflow = ctx.airflow

	local function notify(title, text, dur)
		pcall(function()
			if Airflow and Airflow.Notify then
				Airflow:Notify({
					Title = tostring(title or ""),
					Content = tostring(text or ""),
					Icon = "info",
					Type = "Info",
					Duration = tonumber(dur) or 4,
				})
			end
		end)
	end

	local bannerToken = 0
	local function banner(text, dur)
		pcall(function()
			bannerToken = bannerToken + 1
			local mine = bannerToken
			local old = gui:FindFirstChild("LinkhiveBanner")
			if old then old:Destroy() end
			local f = Instance.new("TextLabel", gui)
			f.Name = "LinkhiveBanner"
			f.AnchorPoint = Vector2.new(0.5, 0)
			f.Position = UDim2.new(0.5, 0, 0, 42)
			f.Size = UDim2.new(0, 0, 0, 24); f.AutomaticSize = Enum.AutomaticSize.X
			f.BackgroundColor3 = C.BG; f.BackgroundTransparency = 0.2
			f.BorderSizePixel = 0; f.ZIndex = 920
			f.Text = tostring(text or ""); f.Font = Enum.Font.GothamBold; f.TextSize = 10
			f.TextColor3 = C.TEXT
			local pad = Instance.new("UIPadding", f)
			pad.PaddingLeft = UDim.new(0, 12); pad.PaddingRight = UDim.new(0, 12)
			corner(f, 12); addLivingStroke(f, 1.2)
			local sc = Instance.new("UIScale", f); sc.Scale = 0.85
			TweenService:Create(sc, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
			task.delay(tonumber(dur) or 5, function()
				if bannerToken == mine and f.Parent then
					TweenService:Create(f, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
					task.delay(0.3, function() pcall(function() f:Destroy() end) end)
				end
			end)
		end)
	end

	local riskToken = 0
	local function riskBadge(title, text, dur)
		pcall(function()
			riskToken = riskToken + 1
			local mine = riskToken
			local old = gui:FindFirstChild("LinkhiveRisk")
			if old then old:Destroy() end
			local f = Instance.new("Frame", gui)
			f.Name = "LinkhiveRisk"
			f.AnchorPoint = Vector2.new(0.5, 0.5); f.Position = UDim2.new(0.5, 0, 0.5, 0)
			f.Size = UDim2.new(0, 300, 0, 92)
			f.BackgroundColor3 = C.BG; f.BackgroundTransparency = 0.15
			f.BorderSizePixel = 0; f.ZIndex = 930
			corner(f, 14)
			local st = Instance.new("UIStroke", f)
			st.Color = C.RED; st.Thickness = 2.5; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			local t = label(f, tostring(title or ""), UDim2.new(1, -20, 0, 18), C.RED, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
			t.Position = UDim2.new(0, 10, 0, 8); t.TextSize = 12; t.ZIndex = 931
			local d = label(f, tostring(text or ""), UDim2.new(1, -24, 0, 56), C.SILVER, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
			d.Position = UDim2.new(0, 12, 0, 28); d.TextSize = 10; d.TextWrapped = true
			d.TextYAlignment = Enum.TextYAlignment.Top; d.ZIndex = 931
			local sc = Instance.new("UIScale", f); sc.Scale = 0.85
			TweenService:Create(sc, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
			local endAt = os.clock() + (tonumber(dur) or 10)
			task.spawn(function()
				local dim = false
				while riskToken == mine and f.Parent and os.clock() < endAt do
					dim = not dim
					TweenService:Create(st, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {Transparency = dim and 0.85 or 0}):Play()
					task.wait(0.3)
				end
				if riskToken == mine and f.Parent then
					TweenService:Create(f, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
					TweenService:Create(st, TweenInfo.new(0.3), {Transparency = 1}):Play()
					TweenService:Create(t, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
					TweenService:Create(d, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
					task.wait(0.35)
					pcall(function() f:Destroy() end)
				end
			end)
		end)
	end

	local function splash(lines)
		pcall(function()
			lines = lines or {}
			local rowH = 17
			local hh = 54 + #lines * rowH
			local f = Instance.new("Frame", gui)
			f.Name = "LinkhiveSplash"
			f.AnchorPoint = Vector2.new(0.5, 0.5)
			f.Position = UDim2.new(0.5, 0, 0.5, 0)
			f.Size = UDim2.new(0, 258, 0, hh)
			f.BackgroundColor3 = C.BG; f.BorderSizePixel = 0; f.ZIndex = 950
			corner(f, 10); addLivingStroke(f, 1.5)
			local bad = 0
			for _, ln in ipairs(lines) do if ln.Ok == false then bad = bad + 1 end end
			local t = label(f, "Linkhive", UDim2.new(1, -24, 0, 22), C.TEXT, Enum.Font.GothamBold)
			t.Position = UDim2.new(0, 14, 0, 8); t.TextSize = 15; t.ZIndex = 951; liveGrad(t)
			local sub = label(f, bad == 0 and "Everything loaded" or (bad .. " problem" .. (bad > 1 and "s" or "") .. " found"),
				UDim2.new(1, -24, 0, 12), bad == 0 and C.GREEN or C.MOON2, Enum.Font.GothamMedium)
			sub.Position = UDim2.new(0, 14, 0, 30); sub.TextSize = 9.5; sub.ZIndex = 951
			for i, ln in ipairs(lines) do
				local y = 50 + (i - 1) * rowH
				local dot = Instance.new("Frame", f)
				dot.Size = UDim2.new(0, 7, 0, 7); dot.Position = UDim2.new(0, 16, 0, y + 5)
				dot.BackgroundColor3 = ln.Ok and C.GREEN or C.RED; dot.BorderSizePixel = 0; dot.ZIndex = 951
				corner(dot, 4)
				local tx = label(f, ln.Text, UDim2.new(1, -40, 0, rowH), ln.Ok and C.SILVER or C.GOLD, Enum.Font.GothamMedium)
				tx.Position = UDim2.new(0, 30, 0, y); tx.TextSize = 9.5; tx.ZIndex = 951
				tx.TextTruncate = Enum.TextTruncate.AtEnd
			end
			task.delay(bad == 0 and 3.5 or 7, function()
				if f.Parent then pcall(function() f:Destroy() end) end
			end)
		end)
	end

	return { Notify = notify, Banner = banner, RiskBadge = riskBadge, Splash = splash }
end
