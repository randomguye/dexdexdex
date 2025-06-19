--[[
	Script Viewer App Module
	
	A script viewer that is basically a notepad
]]

-- Common Locals
local Main,Lib,Apps,Settings -- Main Containers
local Explorer, Properties, ScriptViewer, Notebook -- Major Apps
local API,RMD,env,service,plr,create,createSimple -- Main Locals

local function initDeps(data)
	Main = data.Main
	Lib = data.Lib
	Apps = data.Apps
	Settings = data.Settings

	API = data.API
	RMD = data.RMD
	env = data.env
	service = data.service
	plr = data.plr
	create = data.create
	createSimple = data.createSimple
end

local function initAfterMain()
	Explorer = Apps.Explorer
	Properties = Apps.Properties
	ScriptViewer = Apps.ScriptViewer
	Notebook = Apps.Notebook
end

local executorName = "Unknown"
local executorVersion = "???"
if identifyexecutor then
	local name,ver = identifyexecutor()
	executorName = name
	executorVersion = ver
elseif service.RunService:IsStudio() then
	executorName = "Studio"
	executorVersion = version()
end

local function main()
	local ScriptViewer = {}

	local window,codeFrame

	ScriptViewer.ViewScript = function(scr)

		
		
		local oldtick = tick()
		
		local s,source = pcall(env.decompile or function() end,scr)
		
		if not s or not source then
			source = "-- Unable to view source.\n"
			source = source .. "-- Script Path: game."..scr:GetFullName().."\n"
			if scr:IsA("Script") and scr.RunContext == Enum.RunContext.Legacy then
				source = source .. "-- Reason: The script is likely to be running on server, or your executor does not support decompiler.\n"
			else
				source = source .. "-- Reason: Your executor does not support decompiler.\n"
			end
			source = source .. "-- Executor: "..executorName.." ("..executorVersion..")"
		else
			local decompiled = source
			-- math.floor( (tick() - oldtick) * 100) / 100
			source = "-- Script Path: game."..scr:GetFullName().."\n"
			source = source .. "-- Took "..tostring(math.floor( (tick() - oldtick) * 100) / 100).."s to decompile.\n"
			source = source .. "-- Executor: "..executorName.." ("..executorVersion..")\n\n"
			
			source = source .. decompiled
			
			oldtick = nil
			decompiled = nil
		end
		
		codeFrame:SetText(source)
		window:Show()
	end

	ScriptViewer.Init = function()
		window = Lib.Window.new()
		window:SetTitle("Notepad")
		window:Resize(500,400)
		ScriptViewer.Window = window

		codeFrame = Lib.CodeFrame.new()
		codeFrame.Frame.Position = UDim2.new(0,0,0,20)
		codeFrame.Frame.Size = UDim2.new(1,0,1,-20)
		codeFrame.Frame.Parent = window.GuiElems.Content

		local execute = Instance.new("TextButton",window.GuiElems.Content)
		execute.BackgroundTransparency = 1
		execute.Position = UDim2.new(0,0,0,0)
		execute.Size = UDim2.new(0.25,0,0,20)
		execute.Text = "Execute"
		execute.TextColor3 = Color3.new(1,1,1)

		execute.MouseButton1Click:Connect(function()
			local source = codeFrame:GetText()
			loadstring(source)()
		end)
		
		local clear = Instance.new("TextButton",window.GuiElems.Content)
		clear.BackgroundTransparency = 1
		clear.Size = UDim2.new(0.25,0,0,20)
		clear.Position = UDim2.new(0.25,0,0,0)
		clear.Text = "Clear"
		clear.TextColor3 = Color3.new(1,1,1)

		clear.MouseButton1Click:Connect(function()
			codeFrame:SetText("")
		end)
		
		local copy = Instance.new("TextButton",window.GuiElems.Content)
		copy.BackgroundTransparency = 1
		copy.Size = UDim2.new(0.25,0,0,20)
		copy.Position = UDim2.new(0.5,0,0,0)
		copy.Text = "Copy to Clipboard"
		copy.TextColor3 = Color3.new(1,1,1)

		copy.MouseButton1Click:Connect(function()
			local source = codeFrame:GetText()
			setclipboard(source)
		end)
		
		

		local save = Instance.new("TextButton",window.GuiElems.Content)
		save.BackgroundTransparency = 1
		save.Size = UDim2.new(0.25,0,0,20)
		save.Position = UDim2.new(0.75,0,0,0)
		save.Text = "Save to File"
		save.TextColor3 = Color3.new(1,1,1)

		save.MouseButton1Click:Connect(function()
			local source = codeFrame:GetText()
			local filename = "Place_"..game.PlaceId.."_Script_"..os.time()..".txt"

			writefile(filename,source)
			if movefileas then -- TODO: USE ENV
				movefileas(filename,".txt")
			end
		end)
	end

	return ScriptViewer
end

-- TODO: Remove when open source
if gethsfuncs then
	_G.moduleData = {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
else
	return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end
