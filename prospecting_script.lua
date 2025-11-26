-- v1.1.0 coastalhub (2025-11-26) hub restore, multi-diagnostics
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

local ejectBtn = Instance.new("TextButton")
ejectBtn.Text = "Eject"
ejectBtn.Size = UDim2.new(0, 94, 0, 38)
ejectBtn.Position = UDim2.new(1, -158, 0, 4)
ejectBtn.BackgroundColor3 = Color3.fromRGB(255, 190, 60)
ejectBtn.Font = Enum.Font.GothamBold
ejectBtn.TextSize = 20
ejectBtn.TextColor3 = Color3.fromRGB(51, 47, 54)
ejectBtn.Parent = frame

local restoreBtn = Instance.new("TextButton")
restoreBtn.Text = "Hub"
restoreBtn.Size = UDim2.new(0, 54, 0, 54)
restoreBtn.Position = UDim2.new(0, 8, 0.5, -27)
restoreBtn.BackgroundColor3 = Color3.fromRGB(41, 45, 62)
restoreBtn.Font = Enum.Font.GothamBold
restoreBtn.TextSize = 20
restoreBtn.TextColor3 = Color3.fromRGB(205, 231, 244)
restoreBtn.Visible = false
restoreBtn.Parent = gui

closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    restoreBtn.Visible = true
end)

restoreBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    restoreBtn.Visible = false
end)

ejectBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
    local scriptRef = script
    if scriptRef and scriptRef.Parent then
        scriptRef:Destroy()
    end
end)

local btnYStart = 56
local btnYOffset = 40

local diagBtn = Instance.new("TextButton")
diagBtn.Text = "Diagnostic: List Usable Events"
diagBtn.Size = UDim2.new(0, 210, 0, 36)
diagBtn.Position = UDim2.new(0.5, -105, 0, btnYStart)
diagBtn.BackgroundColor3 = Color3.fromRGB(57, 222, 143)
diagBtn.Font = Enum.Font.GothamSemibold
diagBtn.TextSize = 20
diagBtn.TextColor3 = Color3.fromRGB(22, 22, 22)
diagBtn.Parent = frame

local diagBtn2 = Instance.new("TextButton")
diagBtn2.Text = "Diagnostic: Basic Info"
diagBtn2.Size = UDim2.new(0, 210, 0, 36)
diagBtn2.Position = UDim2.new(0.5, -105, 0, btnYStart + btnYOffset)
diagBtn2.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
diagBtn2.Font = Enum.Font.GothamSemibold
diagBtn2.TextSize = 20
diagBtn2.TextColor3 = Color3.fromRGB(22, 22, 22)
diagBtn2.Parent = frame

local diagBtn3 = Instance.new("TextButton")
diagBtn3.Text = "Diagnostic: Backpack Items"
diagBtn3.Size = UDim2.new(0, 210, 0, 36)
diagBtn3.Position = UDim2.new(0.5, -105, 0, btnYStart + btnYOffset*2)
diagBtn3.BackgroundColor3 = Color3.fromRGB(172, 221, 90)
diagBtn3.Font = Enum.Font.GothamSemibold
diagBtn3.TextSize = 20
diagBtn3.TextColor3 = Color3.fromRGB(22, 22, 22)
diagBtn3.Parent = frame

local diagBtn4 = Instance.new("TextButton")
diagBtn4.Text = "Diagnostic: Workspace Children"
diagBtn4.Size = UDim2.new(0, 210, 0, 36)
diagBtn4.Position = UDim2.new(0.5, -105, 0, btnYStart + btnYOffset*3)
diagBtn4.BackgroundColor3 = Color3.fromRGB(130, 100, 255)
diagBtn4.Font = Enum.Font.GothamSemibold
diagBtn4.TextSize = 20
diagBtn4.TextColor3 = Color3.fromRGB(22, 22, 22)
diagBtn4.Parent = frame

local diagBtn5 = Instance.new("TextButton")
diagBtn5.Text = "Diagnostic: Camera Info"
diagBtn5.Size = UDim2.new(0, 210, 0, 36)
diagBtn5.Position = UDim2.new(0.5, -105, 0, btnYStart + btnYOffset*4)
diagBtn5.BackgroundColor3 = Color3.fromRGB(200, 110, 180)
diagBtn5.Font = Enum.Font.GothamSemibold
diagBtn5.TextSize = 20
diagBtn5.TextColor3 = Color3.fromRGB(22, 22, 22)
diagBtn5.Parent = frame

local diagBtn6 = Instance.new("TextButton")
diagBtn6.Text = "Diagnostic: Lighting Properties"
diagBtn6.Size = UDim2.new(0, 210, 0, 36)
diagBtn6.Position = UDim2.new(0.5, -105, 0, btnYStart + btnYOffset*5)
diagBtn6.BackgroundColor3 = Color3.fromRGB(60, 140, 220)
diagBtn6.Font = Enum.Font.GothamSemibold
diagBtn6.TextSize = 20
diagBtn6.TextColor3 = Color3.fromRGB(22, 22, 22)
diagBtn6.Parent = frame

local diagBtn7 = Instance.new("TextButton")
diagBtn7.Text = "Diagnostic: Service Status"
diagBtn7.Size = UDim2.new(0, 210, 0, 36)
diagBtn7.Position = UDim2.new(0.5, -105, 0, btnYStart + btnYOffset*6)
diagBtn7.BackgroundColor3 = Color3.fromRGB(90, 210, 210)
diagBtn7.Font = Enum.Font.GothamSemibold
diagBtn7.TextSize = 20
diagBtn7.TextColor3 = Color3.fromRGB(22, 22, 22)
diagBtn7.Parent = frame

local outputBox = Instance.new("TextBox")
outputBox.Size = UDim2.new(1, -24, 0, 156)
outputBox.Position = UDim2.new(0, 12, 0, btnYStart + btnYOffset*7)
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

local usableEventsList = ""

local function getUsableEvents()
    local result = {}
    local function scan(obj, path)
        for _, child in ipairs(obj:GetChildren()) do
            local cpath = (path ~= "" and path .. "/" or "") .. child.Name
            for _, prop in ipairs({"Touched", "Changed", "ChildAdded", "ChildRemoved", "DescendantAdded", "DescendantRemoving"}) do
                local s = child[prop]
                if typeof(s) == "RBXScriptSignal" then
                    table.insert(result, cpath .. ":" .. prop)
                end
            end
            scan(child, cpath)
        end
    end
    scan(game, "")
    return result
end

diagBtn.MouseButton1Click:Connect(function()
    local events = getUsableEvents()
    table.sort(events)
    local allEvents = table.concat(events, "\n")
    usableEventsList = allEvents
    outputBox.Text = allEvents ~= "" and allEvents or "No usable events were found."
end)

diagBtn2.MouseButton1Click:Connect(function()
    local info = "Player: "..player.Name.."\nUserId: "..player.UserId.."\nPing: "
    local stats = game:GetService("Stats"):FindFirstChild("Network") 
    if stats then
        info = info.." "..math.floor(stats.ServerStatsItem["Data Ping"]:GetValue()).."ms"
    end
    outputBox.Text = info
end)

diagBtn3.MouseButton1Click:Connect(function()
    local items = {}
    for _,v in ipairs(player.Backpack:GetChildren()) do
        table.insert(items, v.Name)
    end
    outputBox.Text = "Backpack Items:\n"..table.concat(items,"\n")
end)

diagBtn4.MouseButton1Click:Connect(function()
    local children = {}
    for _,v in ipairs(game.Workspace:GetChildren()) do
        table.insert(children, v.Name.." ["..v.ClassName.."]")
    end
    outputBox.Text = "Workspace Children:\n"..table.concat(children,"\n")
end)

diagBtn5.MouseButton1Click:Connect(function()
    local cam = workspace.CurrentCamera
    local camInfo = {
        "Camera Type: "..tostring(cam.CameraType),
        "CFrame: "..tostring(cam.CFrame),
        "FieldOfView: "..tostring(cam.FieldOfView),
        "Focus: "..tostring(cam.Focus),
        "ViewportSize: "..tostring(cam.ViewportSize)
    }
    outputBox.Text = "Camera Info:\n"..table.concat(camInfo,"\n")
end)

diagBtn6.MouseButton1Click:Connect(function()
    local lighting = game:GetService("Lighting")
    local items = {}
    for _,prop in ipairs({"Ambient","Brightness","ColorShift_Bottom","ColorShift_Top","ClockTime","FogColor","FogEnd","FogStart","OutdoorAmbient","ShadowSoftness"}) do
        local ok, value = pcall(function() return lighting[prop] end)
        if ok then
            table.insert(items, prop..": "..tostring(value))
        end
    end
    outputBox.Text = "Lighting Properties:\n"..table.concat(items,"\n")
end)

diagBtn7.MouseButton1Click:Connect(function()
    local services = {}
    for _, service in ipairs(game:GetChildren()) do
        table.insert(services, service.ClassName.." ("..service.Name..")")
    end
    outputBox.Text = "Services:\n"..table.concat(services,"\n")
end)

copyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(outputBox.Text)
    end
end)
