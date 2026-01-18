-- Remote Events Scanner with GUI

local player = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Create main ScreenGui
local gui = Instance. new("ScreenGui")
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
toggleCorner.CornerRadius = UDim. new(0, 8)
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
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize =*

