-- v1.2.0 coastalhub (2025-11-26) fix button stacking
local player = game:GetService("Players").LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "CoastalHubGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 470, 0, 380)
frame.Position = UDim2.new(0.5, -235, 0.5, -190)
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
local btnYOffset = 42

local diagTexts = {
    "Diagnostic: List Usable Events",
    "Diagnostic: Basic Info",
    "Diagnostic: Backpack Items",
    "Diagnostic: Workspace Children",
    "Diagnostic: Camera Info",
    "Diagnostic: Lighting Properties",
    "Diagnostic: Service Status"
}
local diagColors = {
    Color3.fromRGB(57, 222, 143),
    Color3.fromRGB(100, 200, 255),
    Color3.fromRGB(172, 221, 90),
    Color3.fromRGB(130, 100, 255),
    Color3.fromRGB(200, 110, 180),
    Color3.fromRGB(60, 140, 220),
    Color3.fromRGB(90, 210, 210)
}
local diagButtons = {}
for i=1,#diagTexts do
    local btn = Instance.new("TextButton")
    btn.Text = diagTexts[i]
    btn.Size = UDim2.new(0, 210, 0, 36)
    btn.Position = UDim2.new(0.5, -105, 0, btnYStart + btnYOffset * (i-1))
    btn.BackgroundColor3 = diagColors[i]
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 20
    btn.TextColor3 = Color3.fromRGB(22, 22, 22)
    btn.Parent = frame
    diagButtons[i] = btn
end

local outputBox = Instance.new("TextBox")
outputBox.Size = UDim2.new(1, -24, 0, 156)
outputBox.Position = UDim2.new(0, 12, 0, btnYStart + btnYOffset * #diagButtons)
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

diagButtons[1].MouseButton1Click:Connect(function()
    local events = getUsableEvents()
    table.sort(events)
    local allEvents = table.concat(events, "\n")
    usableEventsList = allEvents
    outputBox.Text = allEvents ~= "" and allEvents or "No usable events were found."
end)
diagButtons[2].MouseButton1Click:Connect(function()
    local info = "Player: "..player.Name.."\nUserId: "..player.UserId.."\nPing: "
    local stats = game:GetService("Stats"):FindFirstChild("Network") 
    if stats then
        info = info.." "..math.floor(stats.ServerStatsItem["Data Ping"]:GetValue()).."ms"
    end
    outputBox.Text = info
end)
diagButtons[3].MouseButton1Click:Connect(function()
    local items = {}
    for _,v in ipairs(player.Backpack:GetChildren()) do
        table.insert(items, v.Name)
    end
    outputBox.Text = "Backpack Items:\n"..table.concat(items,"\n")
end)
diagButtons[4].MouseButton1Click:Connect(function()
    local children = {}
    for _,v in ipairs(game.Workspace:GetChildren()) do
        table.insert(children, v.Name.." ["..v.ClassName.."]")
    end
    outputBox.Text = "Workspace Children:\n"..table.concat(children,"\n")
end)
diagButtons[5].MouseButton1Click:Connect(function()
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
diagButtons[6].MouseButton1Click:Connect(function()
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
diagButtons[7].MouseButton1Click:Connect(function()
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
