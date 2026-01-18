-- Remote Events Scanner with GUI

local player = game: GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Create main ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "RemoteScanner"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- UI scaling configuration
local scale = 0.8
local mainWidth, mainHeight = math.floor(400 * scale), math.floor(500 * scale)
local toggleButtonSize = math.floor(60 * scale)

-- Create toggle button (starts visible, main frame starts hidden)
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton. Size = UDim2.new(0, toggleButtonSize, 0, toggleButtonSize)
toggleButton.Position = UDim2.new(0, math.floor(20 * scale), 0.5, -toggleButtonSize // 2)
toggleButton.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
toggleButton.BorderSizePixel = 2
toggleButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Text = "🔍"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = math.floor(32 * scale)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Parent = gui

-- Add rounded corners to toggle button
local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

-- Create main frame (starts hidden)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, mainWidth, 0, mainHeight)
mainFrame.Position = UDim2.new(0.5, -mainWidth // 2, 0.5, -mainHeight // 2)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(34, 139, 34)
mainFrame. Visible = false
mainFrame.Active = true
mainFrame.Parent = gui

-- Add rounded corners to main frame
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim. new(0, 10)
mainCorner.Parent = mainFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, math.floor(50 * scale))
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim. new(0, 10)
titleCorner.Parent = titleBar

-- Title text
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -100, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔍 Remote Scanner"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = math.floor(24 * scale)
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Close button
local closeButton = Instance. new("TextButton")
closeButton.Size = UDim2.new(0, math.floor(40 * scale), 0, math.floor(40 * scale))
closeButton.Position = UDim2.new(1, -math.floor(45 * scale), 0, math.floor(5 * scale))
closeButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
closeButton.BorderSizePixel = 0
closeButton.Text = "✕"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = math.floor(20 * scale)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Eject button (X button that removes the script)
local ejectButton = Instance.new("TextButton")
ejectButton.Size = UDim2.new(0, math.floor(40 * scale), 0, math.floor(40 * scale))
ejectButton.Position = UDim2.new(1, -math.floor(90 * scale), 0, math.floor(5 * scale))
ejectButton.BackgroundColor3 = Color3.fromRGB(255, 69, 0)
ejectButton.BorderSizePixel = 0
ejectButton.Text = "⏏"
ejectButton.Font = Enum.Font.GothamBold
ejectButton.TextSize = math.floor(20 * scale)
ejectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ejectButton.Parent = titleBar

local ejectCorner = Instance.new("UICorner")
ejectCorner.CornerRadius = UDim.new(0, 8)
ejectCorner.Parent = ejectButton

-- Content area
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -math.floor(110 * scale))
contentFrame.Position = UDim2.new(0, 10, 0, math.floor(55 * scale))
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Scrolling frame for remotes
local remoteScrollFrame = Instance.new("ScrollingFrame")
remoteScrollFrame.Size = UDim2.new(1, 0, 1, 0)
remoteScrollFrame.Position = UDim2.new(0, 0, 0, 0)
remoteScrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
remoteScrollFrame.BackgroundTransparency = 0.3
remoteScrollFrame.BorderSizePixel = 1
remoteScrollFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
remoteScrollFrame.ScrollBarThickness = 8
remoteScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(34, 139, 34)
remoteScrollFrame. CanvasSize = UDim2.new(0, 0, 0, 0)
remoteScrollFrame.Parent = contentFrame

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim. new(0, 8)
scrollCorner.Parent = remoteScrollFrame

-- UI list layout for remotes
local remoteLayout = Instance.new("UIListLayout")
remoteLayout.SortOrder = Enum.SortOrder.LayoutOrder
remoteLayout.Padding = UDim.new(0, 5)
remoteLayout.Parent = remoteScrollFrame

-- Bottom button frame
local buttonFrame = Instance.new("Frame")
buttonFrame.Size = UDim2.new(1, -20, 0, math.floor(45 * scale))
buttonFrame.Position = UDim2.new(0, 10, 1, -math.floor(50 * scale))
buttonFrame.BackgroundTransparency = 1
buttonFrame.Parent = mainFrame

-- Scan button
local scanButton = Instance. new("TextButton")
scanButton.Size = UDim2.new(0.48, 0, 1, 0)
scanButton.Position = UDim2.new(0, 0, 0, 0)
scanButton.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
scanButton.BorderSizePixel = 0
scanButton.Text = "🔍 Scan Remotes"
scanButton.Font = Enum.Font.GothamBold
scanButton.TextSize = math.floor(16 * scale)
scanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
scanButton.Parent = buttonFrame

local scanCorner = Instance.new("UICorner")
scanCorner.CornerRadius = UDim.new(0, 6)
scanCorner.Parent = scanButton

-- Copy to clipboard button
local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(0.48, 0, 1, 0)
copyButton.Position = UDim2.new(0.52, 0, 0, 0)
copyButton.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
copyButton.BorderSizePixel = 0
copyButton.Text = "📋 Copy to Clipboard"
copyButton. Font = Enum.Font.GothamBold
copyButton. TextSize = math.floor(16 * scale)
copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
copyButton.Parent = buttonFrame

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim. new(0, 6)
copyCorner.Parent = copyButton

-- Remote data storage
local remotes = {}

-- Function to create a remote entry in the list
local function createRemoteEntry(remoteData, index)
	local entryFrame = Instance.new("Frame")
	entryFrame.Name = "Remote_" .. index
	entryFrame.Size = UDim2.new(1, -10, 0, math.floor(70 * scale))
	entryFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	entryFrame.BorderSizePixel = 0
	entryFrame. LayoutOrder = index
	entryFrame.Parent = remoteScrollFrame
	
	local entryCorner = Instance.new("UICorner")
	entryCorner.CornerRadius = UDim.new(0, 6)
	entryCorner.Parent = entryFrame
	
	-- Type label
	local typeLabel = Instance.new("TextLabel")
	typeLabel.Size = UDim2.new(0, math.floor(120 * scale), 0, math.floor(20 * scale))
	typeLabel.Position = UDim2.new(0, 10, 0, 5)
	typeLabel.BackgroundColor3 = remoteData.Type == "RemoteEvent" and Color3.fromRGB(34, 139, 34) or Color3.fromRGB(30, 144, 255)
	typeLabel.BorderSizePixel = 0
	typeLabel.Text = remoteData.Type
	typeLabel. Font = Enum.Font.GothamBold
	typeLabel.TextSize = math.floor(11 * scale)
	typeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	typeLabel.Parent = entryFrame
	
	local typeCorner = Instance.new("UICorner")
	typeCorner.CornerRadius = UDim.new(0, 4)
	typeCorner.Parent = typeLabel
	
	-- Name label
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -20, 0, math.floor(20 * scale))
	nameLabel.Position = UDim2.new(0, 10, 0, 28)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = "📡 " .. remoteData.Name
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = math.floor(13 * scale)
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel. Text*

