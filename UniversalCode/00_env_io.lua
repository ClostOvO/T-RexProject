-- T-RexProject/UniversalCode/00_env_io.lua
-- Shared environment shims, Roblox services, path/folder helpers, asset loader, and singleton lifecycle.

local TRex = {}
TRex.GameId = "Game01"
TRex.Version = "1.0.0"

local function getService(name)
	return game:GetService(name)
end

TRex.Services = {
	Players = getService("Players"),
	ReplicatedStorage = getService("ReplicatedStorage"),
	RunService = getService("RunService"),
	TweenService = getService("TweenService"),
	UserInputService = getService("UserInputService"),
	CollectionService = getService("CollectionService"),
	Lighting = getService("Lighting"),
	SoundService = getService("SoundService"),
	HttpService = getService("HttpService"),
	TeleportService = getService("TeleportService"),
	GuiService = getService("GuiService"),
	StarterGui = getService("StarterGui"),
	Workspace = getService("Workspace"),
	CoreGui = getService("CoreGui"),
}

TRex.LocalPlayer = TRex.Services.Players.LocalPlayer or TRex.Services.Players.PlayerAdded:Wait()

function TRex.resolveGlobalFunc(name)
	local okGenv, genv = pcall(function()
		return type(getgenv) == "function" and getgenv() or nil
	end)
	if okGenv and type(genv) == "table" and type(genv[name]) == "function" then
		return genv[name]
	end
	if type(_G) == "table" and type(_G[name]) == "function" then
		return _G[name]
	end
	return nil
end

TRex.GlobalEnv = (type(getgenv) == "function" and getgenv()) or _G

function TRex.normalizePath(relPath)
	if type(relPath) ~= "string" then
		return ""
	end
	local p = relPath:gsub("\\", "/")
	p = p:gsub("^%./", "")
	p = p:gsub("/+", "/")
	return p
end

function TRex.ensureFolderChain(relFolder)
	local isfolderFn = TRex.resolveGlobalFunc("isfolder")
	local makefolderFn = TRex.resolveGlobalFunc("makefolder")
	if not isfolderFn or not makefolderFn then
		return false
	end
	local norm = TRex.normalizePath(relFolder)
	if norm == "" then
		return false
	end
	local current = ""
	for segment in norm:gmatch("[^/]+") do
		current = (current == "") and segment or (current .. "/" .. segment)
		local okCheck, exists = pcall(isfolderFn, current)
		if not okCheck or not exists then
			local okMake = pcall(makefolderFn, current)
			if not okMake then
				return false
			end
		end
	end
	return true
end

function TRex.hasFileIO()
	return TRex.resolveGlobalFunc("isfile") ~= nil
		and TRex.resolveGlobalFunc("readfile") ~= nil
		and TRex.resolveGlobalFunc("writefile") ~= nil
		and TRex.resolveGlobalFunc("isfolder") ~= nil
		and TRex.resolveGlobalFunc("makefolder") ~= nil
end

function TRex.safeReadFile(relPath)
	local isfileFn = TRex.resolveGlobalFunc("isfile")
	local readfileFn = TRex.resolveGlobalFunc("readfile")
	if not isfileFn or not readfileFn then
		return nil
	end
	local p = TRex.normalizePath(relPath)
	local okExists, exists = pcall(isfileFn, p)
	if not okExists or not exists then
		return nil
	end
	local okRead, content = pcall(readfileFn, p)
	if okRead and type(content) == "string" then
		return content
	end
	return nil
end

function TRex.safeWriteFile(relPath, content)
	local writefileFn = TRex.resolveGlobalFunc("writefile")
	if not writefileFn then
		return false
	end
	local p = TRex.normalizePath(relPath)
	local parentFolder = p:match("^(.*)/[^/]+$")
	if parentFolder and parentFolder ~= "" then
		TRex.ensureFolderChain(parentFolder)
	end
	local ok = pcall(writefileFn, p, tostring(content))
	return ok
end

function TRex.loadTRexLogoAsset()
	local isfileFn = TRex.resolveGlobalFunc("isfile")
	local getcustomassetFn = TRex.resolveGlobalFunc("getcustomasset") or TRex.resolveGlobalFunc("getsynasset")
	if not isfileFn or not getcustomassetFn then
		return nil
	end
	local logoPath = TRex.normalizePath("T-RexProject/Assets/T-RexLogo.png")
	local okExists, exists = pcall(isfileFn, logoPath)
	if not okExists or not exists then
		return nil
	end
	local okAsset, assetId = pcall(getcustomassetFn, logoPath)
	if okAsset and type(assetId) == "string" and assetId ~= "" then
		return assetId
	end
	return nil
end

function TRex.cloneTable(tbl)
	if type(tbl) ~= "table" then
		return tbl
	end
	local copy = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			copy[k] = TRex.cloneTable(v)
		else
			copy[k] = v
		end
	end
	return copy
end

function TRex.safeEnumFont(fontName, fallback)
	local ok, res = pcall(function()
		return Enum.Font[fontName]
	end)
	if ok and res then
		return res
	end
	return fallback or Enum.Font.GothamMedium
end

function TRex.safeKeyCode(keyName)
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

function TRex.isTextBoxFocused()
	local ok, focused = pcall(TRex.Services.UserInputService.GetFocusedTextBox, TRex.Services.UserInputService)
	return ok and focused ~= nil
end

-- Lifecycle & Singleton Cleanup
TRex.IsRunning = true
TRex.ActiveConnections = {}
TRex.CleanupHooks = {}
TRex.ReportFailure = nil

function TRex.runPreviousCleanup(gameId)
	local key = "__TRexCleanup_" .. tostring(gameId or TRex.GameId)
	if type(TRex.GlobalEnv[key]) == "function" then
		pcall(TRex.GlobalEnv[key])
	end
	if type(TRex.GlobalEnv.__ThaiCleanHubCleanup) == "function" then
		pcall(TRex.GlobalEnv.__ThaiCleanHubCleanup)
	end
end

function TRex.registerCleanupHook(fn)
	if type(fn) == "function" then
		table.insert(TRex.CleanupHooks, fn)
	end
end

function TRex.connectSignal(sig, fn)
	if not sig then
		return nil
	end
	local okConn, conn = pcall(function()
		return sig:Connect(function(...)
			if not TRex.IsRunning then
				return
			end
			local ok, err = pcall(fn, ...)
			if not ok and TRex.ReportFailure then
				TRex.ReportFailure("Signal", err)
			end
		end)
	end)
	if not okConn or not conn then
		return nil
	end
	table.insert(TRex.ActiveConnections, conn)
	if #TRex.ActiveConnections % 64 == 0 then
		for i = #TRex.ActiveConnections, 1, -1 do
			if not TRex.ActiveConnections[i].Connected then
				table.remove(TRex.ActiveConnections, i)
			end
		end
	end
	return conn
end

function TRex.bindClick(button, callback)
	local downPos = nil
	local function trigger()
		if not TRex.IsRunning then
			return
		end
		local ok, err = pcall(callback)
		if not ok and TRex.ReportFailure then
			TRex.ReportFailure("UI", err)
		end
	end
	if button:IsA("GuiButton") then
		TRex.connectSignal(button.Activated, trigger)
	else
		TRex.connectSignal(button.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				downPos = input.Position
			end
		end)
		TRex.connectSignal(button.InputEnded, function(input)
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

function TRex.mountScreenGui(gui)
	local gethuiFn = TRex.resolveGlobalFunc("gethui")
	if gethuiFn then
		pcall(function()
			local hui = gethuiFn()
			local old = hui and hui:FindFirstChild(gui.Name)
			if old then
				old:Destroy()
			end
		end)
	end
	pcall(function()
		local old = TRex.Services.CoreGui:FindFirstChild(gui.Name)
		if old then
			old:Destroy()
		end
	end)
	local pGui = TRex.LocalPlayer:FindFirstChildOfClass("PlayerGui") or TRex.LocalPlayer:WaitForChild("PlayerGui", 10)
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
	if gethuiFn then
		local ok, hui = pcall(gethuiFn)
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

function TRex.cleanup()
	if not TRex.IsRunning then
		return
	end
	TRex.IsRunning = false
	for i = #TRex.CleanupHooks, 1, -1 do
		pcall(TRex.CleanupHooks[i])
	end
	table.clear(TRex.CleanupHooks)
	for _, conn in ipairs(TRex.ActiveConnections) do
		pcall(function()
			conn:Disconnect()
		end)
	end
	table.clear(TRex.ActiveConnections)
	TRex.GlobalEnv["__TRexCleanup_" .. tostring(TRex.GameId)] = nil
	TRex.GlobalEnv["__TRex" .. tostring(TRex.GameId) .. "API"] = nil
end
