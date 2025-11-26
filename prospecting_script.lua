-- v1.3.0 coastalhub (2025-11-26) advanced UI overhaul
local player = game:GetService("Players").LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "CoastalHubGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 470, 0, 420)
frame.Position = UDim2.new(0.5, -235, 0.5, -210)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.25
frame.BorderSizePixel = 0
frame.Parent = gui

local border = Instance.new("Frame")
border.Size = UDim2.new(1, -8, 1, -8)
border.Position = UDim2.new(0, 4, 0, 4)
border.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
border.BackgroundTransparency = 0.8
border.BorderSizePixel = 0
border.Parent = frame

local inner = Instance.new("Frame")
inner.Size = UDim2.new(1, -24, 1, -24)
inner.Position = UDim2.new(0, 12, 0, 12)
inner.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
inner.BackgroundTransparency = 0.25
inner.BorderSizePixel = 0
inner.Parent = border

local title = Instance.new("TextLabel")
title.Text = "Coastal Hub"
title.Size = UDim2.new(1, 0, 0, 46)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 32
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextStrokeTransparency = 0.4
title.Parent = inner

local closeBtn = Instance.new("TextButton")
closeBtn.Text = "✕"
closeBtn.Size = UDim2.new(0, 46, 0, 38)
closeBtn.Position = UDim2.new(1, -52, 0, 7)
closeBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
closeBtn.BackgroundTransparency = 0.15
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 22
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.BorderSizePixel = 0
closeBtn.Parent = inner

local ejectBtn = Instance.new("TextButton")
ejectBtn.Text = "Eject"
ejectBtn.Size = UDim2.new(0, 94, 0, 38)
ejectBtn.Position = UDim2.new(1, -158, 0, 7)
ejectBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ejectBtn.BackgroundTransparency = 0.08
ejectBtn.Font = Enum.Font.GothamBold
ejectBtn.TextSize = 20
ejectBtn.TextColor3 = Color3.fromRGB(255,255,255)
ejectBtn.BorderSizePixel = 0
ejectBtn.Parent = inner

local restoreBtn = Instance.new("TextButton")
restoreBtn.Text = "Hub"
restoreBtn.Size = UDim2.new(0, 54, 0, 54)
restoreBtn.Position = UDim2.new(0, 8, 0.5, -27)
restoreBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
restoreBtn.BackgroundTransparency = 0.1
restoreBtn.Font = Enum.Font.GothamBold
restoreBtn.TextSize = 20
restoreBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
restoreBtn.BorderSizePixel = 0
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

local btnYStart = 46
local btnYOffset = 44

local diagTexts = {
    "List Usable Events",
    "Basic Info",
    "Backpack Items",
    "Workspace Children",
    "Camera Info",
    "Lighting Properties",
    "Service Status"
}
local diagButtons = {}
for i=1,#diagTexts do
    local btn = Instance.new("TextButton")
    btn.Text = diagTexts[i]
    btn.Size = UDim2.new(0.98, 0, 0, 36)
    btn.Position = UDim2.new(0.01, 0, 0, btnYStart + btnYOffset*(i-1))
    btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    btn.BackgroundTransparency = 0.1
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 18
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextWrapped = true
    btn.BorderSizePixel = 0
    btn.Parent = inner
    diagButtons[i] = btn
end

local outputFrame = Instance.new("Frame")
outputFrame.Size = UDim2.new(1, 0, 0, 162)
outputFrame.Position = UDim2.new(0, 0, 0, btnYStart + btnYOffset*#diagButtons)
outputFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
outputFrame.BackgroundTransparency = 0.1
outputFrame.BorderSizePixel = 0
outputFrame.Parent = inner

local outputBox = Instance.new("TextBox")
outputBox.Size = UDim2.new(1, -34, 1, -6)
outputBox.Position = UDim2.new(0, 0, 0, 0)
outputBox.BackgroundTransparency = 1
outputBox.TextSize = 14
outputBox.TextColor3 = Color3.fromRGB(255,255,255)
outputBox.Font = Enum.Font.Code
outputBox.TextWrapped = false
outputBox.TextXAlignment = Enum.TextXAlignment.Left
outputBox.TextYAlignment = Enum.TextYAlignment.Top
outputBox.ClearTextOnFocus = false
outputBox.MultiLine = true
outputBox.TextEditable = false
outputBox.ReadOnly = true
outputBox.Parent = outputFrame

local scrollBar = Instance.new("Frame")
scrollBar.Size = UDim2.new(0, 12, 1, -12)
scrollBar.Position = UDim2.new(1, -20, 0, 6)
scrollBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
scrollBar.BackgroundTransparency = 0.7
scrollBar.BorderSizePixel = 0
scrollBar.Parent = outputFrame
scrollBar.Visible = false

local copyBtn = Instance.new("TextButton")
copyBtn.Text = "📋 Copy"
copyBtn.Size = UDim2.new(0, 86, 0, 32)
copyBtn.Position = UDim2.new(1, -96, 1, -34)
copyBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
copyBtn.BackgroundTransparency = 0.07
copyBtn.TextColor3 = Color3.fromRGB(255,255,255)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 16
copyBtn.BorderSizePixel = 0
copyBtn.Parent = outputFrame

local function setOutput(text)
    local lines = {}
    for line in string.gmatch(text, "[^\r\n]+") do
        table.insert(lines, line)
    end

    if #lines == 0 or text == "" then
        outputBox.Text = ""
        copyBtn.Visible = true
        outputBox.Visible = false
        scrollBar.Visible = false
        outputFrame.Size = UDim2.new(1, 0, 0, 40)
        copyBtn.Position = UDim2.new(1, -96, 0, 4)
    else
        outputBox.Visible = true
        local shown = math.min(#lines, 10)
        local displayLines = {}
        for i=1,shown do
            table.insert(displayLines, lines[i])
        end
        local more = #lines > 10 and "\n(" .. tostring(#lines) .. " lines total, +" .. tostring(#lines-10) .. " more lines not shown)" or ""
        outputBox.Text = table.concat(displayLines, "\n")..more
        outputBox.Size = UDim2.new(1, -34, 0, 18*math.max(shown,1)+10)
        outputFrame.Size = UDim2.new(1, 0, 0, math.max(44,outputBox.Size.Y.Offset+36))
        copyBtn.Visible = true
        copyBtn.Position = UDim2.new(1, -96, 1, -34)
        scrollBar.Visible = (#lines > 10)
        scrollBar.Size = UDim2.new(0, 12, 0, math.max(44,outputBox.Size.Y.Offset+36)-12)
    end
end

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
    setOutput(allEvents ~= "" and allEvents or "")
end)
diagButtons[2].MouseButton1Click:Connect(function()
    local info = "Player: "..player.Name.."\nUserId: "..player.UserId.."\nPing: "
    local stats = game:GetService("Stats"):FindFirstChild("Network") 
    if stats then
        info = info.." "..math.floor(stats.ServerStatsItem["Data Ping"]:GetValue()).."ms"
    end
    setOutput(info)
end)
diagButtons[3].MouseButton1Click:Connect(function()
    local items = {}
    for _,v in ipairs(player.Backpack:GetChildren()) do
        table.insert(items, v.Name)
    end
    setOutput("Backpack Items:\n"..table.concat(items,"\n"))
end)
diagButtons[4].MouseButton1Click:Connect(function()
    local children = {}
    for _,v in ipairs(game.Workspace:GetChildren()) do
        table.insert(children, v.Name.." ["..v.ClassName.."]")
    end
    setOutput("Workspace Children:\n"..table.concat(children,"\n"))
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
    setOutput("Camera Info:\n"..table.concat(camInfo,"\n"))
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
    setOutput("Lighting Properties:\n"..table.concat(items,"\n"))
end)
diagButtons[7].MouseButton1Click:Connect(function()
    local services = {}
    for _, service in ipairs(game:GetChildren()) do
        table.insert(services, service.ClassName.." ("..service.Name..")")
    end
    setOutput("Services:\n"..table.concat(services,"\n"))
end)

copyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(outputBox.Text)
    end
end)

setOutput("")
