-- Roblox Prospecting Diagnostic Script
-- Features: Diagnostic checker, Eject button, Popup UI menu

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Diagnostic Data Storage
local diagnosticData = {
    gameObjects = {},
    tools = {},
    remoteEvents = {},
    remoteFunctions = {},
    localScripts = {},
    modules = {},
    workspace = {},
    replicatedStorage = {}
}

-- Function to scan and diagnose game elements
local function runDiagnostics()
    print("=== Starting Diagnostic Scan ===")
    
    -- Clear previous data
    diagnosticData = {
        gameObjects = {},
        tools = {},
        remoteEvents = {},
        remoteFunctions = {},
        localScripts = {},
        modules = {},
        workspace = {},
        replicatedStorage = {}
    }
    
    -- Scan Workspace
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        table.insert(diagnosticData.workspace, {
            Name = obj.Name,
            ClassName = obj.ClassName,
            Path = obj:GetFullName()
        })
        
        if obj:IsA("Tool") then
            table.insert(diagnosticData.tools, obj:GetFullName())
        end
    end
    
    -- Scan ReplicatedStorage
    if game:GetService("ReplicatedStorage") then
        for _, obj in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            table.insert(diagnosticData.replicatedStorage, {
                Name = obj.Name,
                ClassName = obj.ClassName,
                Path = obj:GetFullName()
            })
            
            if obj:IsA("RemoteEvent") then
                table.insert(diagnosticData.remoteEvents, obj:GetFullName())
            elseif obj:IsA("RemoteFunction") then
                table.insert(diagnosticData.remoteFunctions, obj:GetFullName())
            elseif obj:IsA("ModuleScript") then
                table.insert(diagnosticData.modules, obj:GetFullName())
            end
        end
    end
    
    -- Scan Player's Backpack and Character
    if player.Character then
        for _, obj in pairs(player.Character:GetDescendants()) do
            table.insert(diagnosticData.gameObjects, {
                Name = obj.Name,
                ClassName = obj.ClassName,
                Path = obj:GetFullName()
            })
        end
    end
    
    if player.Backpack then
        for _, obj in pairs(player.Backpack:GetChildren()) do
            if obj:IsA("Tool") then
                table.insert(diagnosticData.tools, obj:GetFullName())
            end
        end
    end
    
    -- Scan PlayerGui
    for _, obj in pairs(playerGui:GetDescendants()) do
        if obj:IsA("LocalScript") then
            table.insert(diagnosticData.localScripts, obj:GetFullName())
        end
    end
    
    print("=== Diagnostic Scan Complete ===")
    print("Workspace Objects: " .. #diagnosticData.workspace)
    print("ReplicatedStorage Objects: " .. #diagnosticData.replicatedStorage)
    print("Tools Found: " .. #diagnosticData.tools)
    print("Remote Events: " .. #diagnosticData.remoteEvents)
    print("Remote Functions: " .. #diagnosticData.remoteFunctions)
    print("Modules: " .. #diagnosticData.modules)
    
    return diagnosticData
end

-- Create Main UI
local function createUI()
    -- Check if UI already exists
    if playerGui:FindFirstChild("ProspectingDiagnosticUI") then
        playerGui.ProspectingDiagnosticUI:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ProspectingDiagnosticUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Toggle Button (Square to open menu)
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 50, 0, 50)
    toggleButton.Position = UDim2.new(0, 10, 0.5, -25)
    toggleButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    toggleButton.BorderSizePixel = 2
    toggleButton.BorderColor3 = Color3.fromRGB(30, 60, 90)
    toggleButton.Text = "📊"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.TextSize = 24
    toggleButton.Parent = screenGui
    
    -- Make it draggable
    local dragging = false
    local dragInput, mousePos, framePos
    
    toggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = toggleButton.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    toggleButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            toggleButton.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Main Menu Frame (hidden by default)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Prospecting Diagnostic Tool"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 18
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton
    
    -- Eject Button
    local ejectButton = Instance.new("TextButton")
    ejectButton.Name = "EjectButton"
    ejectButton.Size = UDim2.new(0, 60, 0, 30)
    ejectButton.Position = UDim2.new(1, -100, 0, 5)
    ejectButton.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
    ejectButton.Text = "EJECT"
    ejectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ejectButton.Font = Enum.Font.SourceSansBold
    ejectButton.TextSize = 14
    ejectButton.Parent = titleBar
    
    local ejectCorner = Instance.new("UICorner")
    ejectCorner.CornerRadius = UDim.new(0, 4)
    ejectCorner.Parent = ejectButton
    
    -- Content Frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -60)
    contentFrame.Position = UDim2.new(0, 10, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- Scan Button
    local scanButton = Instance.new("TextButton")
    scanButton.Name = "ScanButton"
    scanButton.Size = UDim2.new(0, 200, 0, 40)
    scanButton.Position = UDim2.new(0.5, -100, 0, 10)
    scanButton.BackgroundColor3 = Color3.fromRGB(70, 180, 130)
    scanButton.Text = "🔍 Run Diagnostic Scan"
    scanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    scanButton.Font = Enum.Font.SourceSansBold
    scanButton.TextSize = 16
    scanButton.Parent = contentFrame
    
    local scanCorner = Instance.new("UICorner")
    scanCorner.CornerRadius = UDim.new(0, 6)
    scanCorner.Parent = scanButton
    
    -- Results ScrollingFrame
    local resultsFrame = Instance.new("ScrollingFrame")
    resultsFrame.Name = "ResultsFrame"
    resultsFrame.Size = UDim2.new(1, 0, 1, -70)
    resultsFrame.Position = UDim2.new(0, 0, 0, 60)
    resultsFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    resultsFrame.BorderSizePixel = 0
    resultsFrame.ScrollBarThickness = 8
    resultsFrame.Parent = contentFrame
    
    local resultsCorner = Instance.new("UICorner")
    resultsCorner.CornerRadius = UDim.new(0, 6)
    resultsCorner.Parent = resultsFrame
    
    local resultsLayout = Instance.new("UIListLayout")
    resultsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    resultsLayout.Padding = UDim.new(0, 5)
    resultsLayout.Parent = resultsFrame
    
    -- Function to display results
    local function displayResults(data)
        -- Clear previous results
        for _, child in pairs(resultsFrame:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") then
                child:Destroy()
            end
        end
        
        local yOffset = 0
        
        -- Helper function to create category
        local function createCategory(title, items)
            local categoryLabel = Instance.new("TextLabel")
            categoryLabel.Size = UDim2.new(1, -10, 0, 25)
            categoryLabel.Position = UDim2.new(0, 5, 0, yOffset)
            categoryLabel.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
            categoryLabel.Text = title .. " (" .. #items .. ")"
            categoryLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            categoryLabel.Font = Enum.Font.SourceSansBold
            categoryLabel.TextSize = 14
            categoryLabel.TextXAlignment = Enum.TextXAlignment.Left
            categoryLabel.TextXOffset = 10
            categoryLabel.Parent = resultsFrame
            
            local catCorner = Instance.new("UICorner")
            catCorner.CornerRadius = UDim.new(0, 4)
            catCorner.Parent = categoryLabel
            
            yOffset = yOffset + 30
            
            for i, item in ipairs(items) do
                if i <= 50 then -- Limit display to first 50 items per category
                    local itemLabel = Instance.new("TextLabel")
                    itemLabel.Size = UDim2.new(1, -20, 0, 20)
                    itemLabel.Position = UDim2.new(0, 10, 0, yOffset)
                    itemLabel.BackgroundTransparency = 1
                    itemLabel.Text = "  • " .. (type(item) == "table" and (item.Name .. " [" .. item.ClassName .. "]") or tostring(item))
                    itemLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                    itemLabel.Font = Enum.Font.SourceSans
                    itemLabel.TextSize = 12
                    itemLabel.TextXAlignment = Enum.TextXAlignment.Left
                    itemLabel.TextTruncate = Enum.TextTruncate.AtEnd
                    itemLabel.Parent = resultsFrame
                    
                    yOffset = yOffset + 22
                end
            end
            
            if #items > 50 then
                local moreLabel = Instance.new("TextLabel")
                moreLabel.Size = UDim2.new(1, -20, 0, 20)
                moreLabel.Position = UDim2.new(0, 10, 0, yOffset)
                moreLabel.BackgroundTransparency = 1
                moreLabel.Text = "  ... and " .. (#items - 50) .. " more"
                moreLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
                moreLabel.Font = Enum.Font.SourceSansItalic
                moreLabel.TextSize = 12
                moreLabel.TextXAlignment = Enum.TextXAlignment.Left
                moreLabel.Parent = resultsFrame
                
                yOffset = yOffset + 25
            end
            
            yOffset = yOffset + 5
        end
        
        -- Display all categories
        createCategory("🔧 Tools", data.tools)
        createCategory("📡 Remote Events", data.remoteEvents)
        createCategory("📞 Remote Functions", data.remoteFunctions)
        createCategory("📦 Module Scripts", data.modules)
        createCategory("🌍 Workspace Objects", data.workspace)
        createCategory("💾 ReplicatedStorage Objects", data.replicatedStorage)
        
        resultsFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    end
    
    -- Button Events
    toggleButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)
    
    ejectButton.MouseButton1Click:Connect(function()
        print("=== EJECTING SCRIPT ===")
        screenGui:Destroy()
        print("Script UI removed successfully")
    end)
    
    scanButton.MouseButton1Click:Connect(function()
        scanButton.Text = "⏳ Scanning..."
        scanButton.BackgroundColor3 = Color3.fromRGB(180, 140, 70)
        
        task.wait(0.1)
        local results = runDiagnostics()
        displayResults(results)
        
        scanButton.Text = "✓ Scan Complete!"
        scanButton.BackgroundColor3 = Color3.fromRGB(70, 180, 130)
        
        task.wait(2)
        scanButton.Text = "🔍 Run Diagnostic Scan"
    end)
    
    screenGui.Parent = playerGui
    print("Prospecting Diagnostic UI loaded successfully!")
    print("Click the square button on the left to open the menu")
end

-- Initialize
print("=== Prospecting Diagnostic Script Loaded ===")
print("Initializing UI...")
createUI()
print("Ready! Click the square button to get started.")