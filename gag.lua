-- Grow a Garden Game Script
-- A collapsible UI for displaying player currencies and purchasable items

local player = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")

-- Create main ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "GrowAGardenGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- UI scaling configuration
local scale = 0.8
local mainWidth, mainHeight = math.floor(400 * scale), math.floor(500 * scale)
local toggleButtonSize = math.floor(60 * scale)

-- Create toggle button (starts visible, main frame starts hidden)
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, toggleButtonSize, 0, toggleButtonSize)
toggleButton.Position = UDim2.new(0, math.floor(20 * scale), 0.5, -toggleButtonSize // 2)
toggleButton.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
toggleButton.BorderSizePixel = 2
toggleButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Text = "🌱"
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
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Parent = gui

-- Add rounded corners to main frame
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, math.floor(50 * scale))
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

-- Title text
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -100, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🌱 Grow a Garden"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = math.floor(24 * scale)
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Close button
local closeButton = Instance.new("TextButton")
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

-- Content area
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -math.floor(60 * scale))
contentFrame.Position = UDim2.new(0, 10, 0, math.floor(55 * scale))
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Currency display section
local currencyFrame = Instance.new("Frame")
currencyFrame.Size = UDim2.new(1, 0, 0, math.floor(80 * scale))
currencyFrame.Position = UDim2.new(0, 0, 0, 0)
currencyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
currencyFrame.BackgroundTransparency = 0.3
currencyFrame.BorderSizePixel = 1
currencyFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
currencyFrame.Parent = contentFrame

local currencyCorner = Instance.new("UICorner")
currencyCorner.CornerRadius = UDim.new(0, 8)
currencyCorner.Parent = currencyFrame

-- Tokens display
local tokensLabel = Instance.new("TextLabel")
tokensLabel.Size = UDim2.new(1, -20, 0, math.floor(30 * scale))
tokensLabel.Position = UDim2.new(0, 10, 0, math.floor(10 * scale))
tokensLabel.BackgroundTransparency = 1
tokensLabel.Text = "💰 Tokens: 0"
tokensLabel.Font = Enum.Font.GothamBold
tokensLabel.TextSize = math.floor(18 * scale)
tokensLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
tokensLabel.TextXAlignment = Enum.TextXAlignment.Left
tokensLabel.Parent = currencyFrame

-- Sheckles display
local shecklesLabel = Instance.new("TextLabel")
shecklesLabel.Size = UDim2.new(1, -20, 0, math.floor(30 * scale))
shecklesLabel.Position = UDim2.new(0, 10, 0, math.floor(42 * scale))
shecklesLabel.BackgroundTransparency = 1
shecklesLabel.Text = "💎 Sheckles: 0"
shecklesLabel.Font = Enum.Font.GothamBold
shecklesLabel.TextSize = math.floor(18 * scale)
shecklesLabel.TextColor3 = Color3.fromRGB(135, 206, 250)
shecklesLabel.TextXAlignment = Enum.TextXAlignment.Left
shecklesLabel.Parent = currencyFrame

-- Shop section header
local shopHeader = Instance.new("TextLabel")
shopHeader.Size = UDim2.new(1, 0, 0, math.floor(35 * scale))
shopHeader.Position = UDim2.new(0, 0, 0, math.floor(90 * scale))
shopHeader.BackgroundTransparency = 1
shopHeader.Text = "🛒 Purchasable Items"
shopHeader.Font = Enum.Font.GothamBold
shopHeader.TextSize = math.floor(20 * scale)
shopHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
shopHeader.TextXAlignment = Enum.TextXAlignment.Left
shopHeader.Parent = contentFrame

-- Scrolling frame for shop items
local shopScrollFrame = Instance.new("ScrollingFrame")
shopScrollFrame.Size = UDim2.new(1, 0, 1, -math.floor(130 * scale))
shopScrollFrame.Position = UDim2.new(0, 0, 0, math.floor(130 * scale))
shopScrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
shopScrollFrame.BackgroundTransparency = 0.3
shopScrollFrame.BorderSizePixel = 1
shopScrollFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
shopScrollFrame.ScrollBarThickness = 8
shopScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(34, 139, 34)
shopScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
shopScrollFrame.Parent = contentFrame

local shopCorner = Instance.new("UICorner")
shopCorner.CornerRadius = UDim.new(0, 8)
shopCorner.Parent = shopScrollFrame

-- UI list layout for shop items
local shopLayout = Instance.new("UIListLayout")
shopLayout.SortOrder = Enum.SortOrder.LayoutOrder
shopLayout.Padding = UDim.new(0, 5)
shopLayout.Parent = shopScrollFrame

-- Sample shop items data (would normally be fetched from game)
local shopItems = {
	{name = "Watering Can", cost = 50, emoji = "🚿", description = "Basic watering tool"},
	{name = "Fertilizer", cost = 100, emoji = "💩", description = "Makes plants grow faster"},
	{name = "Seed Pack (Common)", cost = 25, emoji = "🌱", description = "Pack of common seeds"},
	{name = "Seed Pack (Rare)", cost = 150, emoji = "🌿", description = "Pack of rare seeds"},
	{name = "Garden Gnome", cost = 200, emoji = "🧙", description = "Decorative gnome"},
	{name = "Sprinkler System", cost = 500, emoji = "💦", description = "Auto-waters plants"},
	{name = "Greenhouse", cost = 1000, emoji = "🏠", description = "Protected growing area"},
	{name = "Compost Bin", cost = 300, emoji = "🗑️", description = "Creates fertilizer"},
	{name = "Garden Tools Set", cost = 250, emoji = "🔧", description = "Complete tool set"},
	{name = "Flower Seeds", cost = 75, emoji = "🌸", description = "Beautiful flowers"},
	{name = "Vegetable Seeds", cost = 60, emoji = "🥕", description = "Edible vegetables"},
	{name = "Tree Sapling", cost = 400, emoji = "🌳", description = "Grows into a tree"},
}

-- Function to create a shop item entry
local function createShopItem(itemData, index)
	local itemFrame = Instance.new("Frame")
	itemFrame.Name = "Item_" .. index
	itemFrame.Size = UDim2.new(1, -10, 0, math.floor(60 * scale))
	itemFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	itemFrame.BorderSizePixel = 0
	itemFrame.LayoutOrder = index
	itemFrame.Parent = shopScrollFrame
	
	local itemCorner = Instance.new("UICorner")
	itemCorner.CornerRadius = UDim.new(0, 6)
	itemCorner.Parent = itemFrame
	
	-- Item emoji/icon
	local itemIcon = Instance.new("TextLabel")
	itemIcon.Size = UDim2.new(0, math.floor(50 * scale), 1, 0)
	itemIcon.Position = UDim2.new(0, 5, 0, 0)
	itemIcon.BackgroundTransparency = 1
	itemIcon.Text = itemData.emoji
	itemIcon.Font = Enum.Font.GothamBold
	itemIcon.TextSize = math.floor(28 * scale)
	itemIcon.Parent = itemFrame
	
	-- Item name
	local itemName = Instance.new("TextLabel")
	itemName.Size = UDim2.new(1, -math.floor(130 * scale), 0, math.floor(25 * scale))
	itemName.Position = UDim2.new(0, math.floor(55 * scale), 0, 5)
	itemName.BackgroundTransparency = 1
	itemName.Text = itemData.name
	itemName.Font = Enum.Font.GothamBold
	itemName.TextSize = math.floor(14 * scale)
	itemName.TextColor3 = Color3.fromRGB(255, 255, 255)
	itemName.TextXAlignment = Enum.TextXAlignment.Left
	itemName.Parent = itemFrame
	
	-- Item description
	local itemDesc = Instance.new("TextLabel")
	itemDesc.Size = UDim2.new(1, -math.floor(130 * scale), 0, math.floor(20 * scale))
	itemDesc.Position = UDim2.new(0, math.floor(55 * scale), 0, 28)
	itemDesc.BackgroundTransparency = 1
	itemDesc.Text = itemData.description
	itemDesc.Font = Enum.Font.Gotham
	itemDesc.TextSize = math.floor(11 * scale)
	itemDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
	itemDesc.TextXAlignment = Enum.TextXAlignment.Left
	itemDesc.Parent = itemFrame
	
	-- Cost label
	local costLabel = Instance.new("TextLabel")
	costLabel.Size = UDim2.new(0, math.floor(70 * scale), 0, math.floor(25 * scale))
	costLabel.Position = UDim2.new(1, -math.floor(75 * scale), 0, 5)
	costLabel.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
	costLabel.BorderSizePixel = 0
	costLabel.Text = itemData.cost .. " 💰"
	costLabel.Font = Enum.Font.GothamBold
	costLabel.TextSize = math.floor(12 * scale)
	costLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	costLabel.Parent = itemFrame
	
	local costCorner = Instance.new("UICorner")
	costCorner.CornerRadius = UDim.new(0, 4)
	costCorner.Parent = costLabel
	
	-- Buy button
	local buyButton = Instance.new("TextButton")
	buyButton.Size = UDim2.new(0, math.floor(70 * scale), 0, math.floor(25 * scale))
	buyButton.Position = UDim2.new(1, -math.floor(75 * scale), 0, 32)
	buyButton.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
	buyButton.BorderSizePixel = 0
	buyButton.Text = "Buy"
	buyButton.Font = Enum.Font.GothamBold
	buyButton.TextSize = math.floor(12 * scale)
	buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	buyButton.Parent = itemFrame
	
	local buyCorner = Instance.new("UICorner")
	buyCorner.CornerRadius = UDim.new(0, 4)
	buyCorner.Parent = buyButton
	
	-- Buy button hover effect
	buyButton.MouseEnter:Connect(function()
		buyButton.BackgroundColor3 = Color3.fromRGB(44, 169, 44)
	end)
	
	buyButton.MouseLeave:Connect(function()
		buyButton.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
	end)
	
	-- Buy button click handler
	buyButton.MouseButton1Click:Connect(function()
		-- Placeholder for purchase logic
		print("Attempting to purchase: " .. itemData.name .. " for " .. itemData.cost .. " tokens")
		-- Here you would implement actual purchase logic:
		-- 1. Check if player has enough tokens
		-- 2. Deduct tokens and add item
		-- 3. Update UI
	end)
end

-- Populate shop with items
for i, item in ipairs(shopItems) do
	createShopItem(item, i)
end

-- Update canvas size for scrolling
local itemHeight = math.floor(60 * scale)
local itemSpacing = 5
local totalHeight = (#shopItems * itemHeight) + ((#shopItems - 1) * itemSpacing) + 10
shopScrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)

-- Function to fetch and update player currencies
local function updateCurrencies()
	-- Try to find currency values from player's leaderstats or other sources
	local tokens = 0
	local sheckles = 0
	
	-- Check leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local tokensValue = leaderstats:FindFirstChild("Tokens")
		if tokensValue and tokensValue:IsA("IntValue") then
			tokens = tokensValue.Value
		end
		
		local shecklesValue = leaderstats:FindFirstChild("Sheckles")
		if shecklesValue and shecklesValue:IsA("IntValue") then
			sheckles = shecklesValue.Value
		end
	end
	
	-- Update UI labels
	tokensLabel.Text = "💰 Tokens: " .. tostring(tokens)
	shecklesLabel.Text = "💎 Sheckles: " .. tostring(sheckles)
end

-- Function to handle UI opening with smooth animation
local function openUI()
	mainFrame.Visible = true
	mainFrame.Size = UDim2.new(0, 0, 0, 0)
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	
	local openTween = TweenService:Create(
		mainFrame,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Size = UDim2.new(0, mainWidth, 0, mainHeight),
			Position = UDim2.new(0.5, -mainWidth // 2, 0.5, -mainHeight // 2)
		}
	)
	openTween:Play()
	
	-- Hide toggle button with fade
	local toggleFade = TweenService:Create(
		toggleButton,
		TweenInfo.new(0.2, Enum.EasingStyle.Linear),
		{BackgroundTransparency = 1, TextTransparency = 1}
	)
	toggleFade:Play()
	toggleFade.Completed:Connect(function()
		toggleButton.Visible = false
	end)
	
	-- Update currencies when opening
	updateCurrencies()
end

-- Function to handle UI closing with smooth animation
local function closeUI()
	local closeTween = TweenService:Create(
		mainFrame,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
		{
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}
	)
	closeTween:Play()
	closeTween.Completed:Connect(function()
		mainFrame.Visible = false
	end)
	
	-- Show toggle button with fade
	toggleButton.Visible = true
	toggleButton.BackgroundTransparency = 1
	toggleButton.TextTransparency = 1
	
	local toggleFade = TweenService:Create(
		toggleButton,
		TweenInfo.new(0.2, Enum.EasingStyle.Linear),
		{BackgroundTransparency = 0, TextTransparency = 0}
	)
	toggleFade:Play()
end

-- Connect toggle button to open UI
toggleButton.MouseButton1Click:Connect(function()
	openUI()
end)

-- Connect close button to close UI
closeButton.MouseButton1Click:Connect(function()
	closeUI()
end)

-- Add hover effect to toggle button
toggleButton.MouseEnter:Connect(function()
	local hoverTween = TweenService:Create(
		toggleButton,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = UDim2.new(0, toggleButtonSize * 1.1, 0, toggleButtonSize * 1.1)}
	)
	hoverTween:Play()
end)

toggleButton.MouseLeave:Connect(function()
	local leaveTween = TweenService:Create(
		toggleButton,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = UDim2.new(0, toggleButtonSize, 0, toggleButtonSize)}
	)
	leaveTween:Play()
end)

-- Monitor for currency changes if using leaderstats
local leaderstats = player:FindFirstChild("leaderstats")
if leaderstats then
	-- Watch for Tokens changes
	local tokensValue = leaderstats:FindFirstChild("Tokens")
	if tokensValue and tokensValue:IsA("IntValue") then
		tokensValue.Changed:Connect(function()
			if mainFrame.Visible then
				updateCurrencies()
			end
		end)
	end
	
	-- Watch for Sheckles changes
	local shecklesValue = leaderstats:FindFirstChild("Sheckles")
	if shecklesValue and shecklesValue:IsA("IntValue") then
		shecklesValue.Changed:Connect(function()
			if mainFrame.Visible then
				updateCurrencies()
			end
		end)
	end
end

-- Initialize UI in closed state (as required)
mainFrame.Visible = false
toggleButton.Visible = true

print("Grow a Garden UI loaded successfully!")
