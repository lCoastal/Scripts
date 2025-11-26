local player = game:GetService("Players").LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "CoastalHubGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 470, 0, 340)
frame.Position = UDim2.new(0.5, -235, 0.5, -170)
frame.BackgroundColor3 = Color3.fromRGB(41, 45, 62)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Text = "Coastal Hub"
title.Size = UDim2.new(1, 0, 0, 46)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 32
title.TextColor3 = Color3.fromRGB(205, 231, 244)
title.TextStrokeTransparency = 0.7
title.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Text = "✕"
closeBtn.Size = UDim2.new(0, 46, 0, 38)
closeBtn.Position = UDim2.new(1, -52, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(234, 71, 71)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 22
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Parent = frame

closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

local ejectBtn = Instance.new("TextButton")
ejectBtn.Text = "Eject"
ejectBtn.Size = UDim2.new(0, 94, 0, 38)
ejectBtn.Position = UDim2.new(1, -158, 0, 4)
ejectBtn.BackgroundColor3 = Color3.fromRGB(255, 190, 60)
ejectBtn.Font = Enum.Font.GothamBold
ejectBtn.TextSize = 20
ejectBtn.TextColor3 = Color3.fromRGB(51, 47, 54)
ejectBtn.Parent = frame

ejectBtn.MouseButton1Click:Connect(function()
	player:Kick("You have been ejected by Coastal Hub.")
end)

local diagBtn = Instance.new("TextButton")
diagBtn.Text = "Diagnostic Check"
diagBtn.Size = UDim2.new(0, 210, 0, 36)
diagBtn.Position = UDim2.new(0.5, -105, 0, 56)
diagBtn.BackgroundColor3 = Color3.fromRGB(57, 222, 143)
diagBtn.Font = Enum.Font.GothamSemibold
diagBtn.TextSize = 20
diagBtn.TextColor3 = Color3.fromRGB(22, 22, 22)
diagBtn.Parent = frame

local outputBox = Instance.new("TextBox")
outputBox.Size = UDim2.new(1, -24, 0, 156)
outputBox.Position = UDim2.new(0, 12, 0, 108)
outputBox.BackgroundColor3 = Color3.fromRGB(35, 39, 48)
outputBox.TextSize = 14
outputBox.TextColor3 = Color3.fromRGB(219, 233, 255)
outputBox.TextStrokeTransparency = 0.8
outputBox.Font = Enum.Font.Code
outputBox.TextWrapped = false
outputBox.TextXAlignment = Enum.TextXAlignment.Left
outputBox.TextYAlignment = Enum.TextYAlignment.Top
outputBox.ClearTextOnFocus = false
outputBox.MultiLine = true
outputBox.TextEditable = true
outputBox.ReadOnly = false
outputBox.Parent = frame

local copyBtn = Instance.new("TextButton")
copyBtn.Text = "Copy"
copyBtn.Size = UDim2.new(0, 98, 0, 36)
copyBtn.Position = UDim2.new(0.5, 6, 1, -44)
copyBtn.BackgroundColor3 = Color3.fromRGB(67, 151, 231)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 18
copyBtn.TextColor3 = Color3.fromRGB(240, 246, 255)
copyBtn.Parent = frame

local usableMethodsList = ""
diagBtn.MouseButton1Click:Connect(function()
	local methods = {}
	for i,v in pairs(getgc(true)) do
		if type(v) == "function" then
			local info = debug.getinfo(v)
			if info and info.name and info.name ~= "" then
				table.insert(methods, info.name)
			end
		end
	end
	table.sort(methods)
	local allMethods = table.concat(methods, "\n")
	usableMethodsList = allMethods
	outputBox.Text = allMethods ~= "" and allMethods or "No usable methods were found."
	if #allMethods > 1500 then
		outputBox.Size = UDim2.new(1, -24, 0, 220)
	else
		outputBox.Size = UDim2.new(1, -24, 0, 156)
	end
end)

copyBtn.MouseButton1Click:Connect(function()
	if setclipboard then
		setclipboard(usableMethodsList)
	end
end)
