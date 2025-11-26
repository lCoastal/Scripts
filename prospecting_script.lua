-- v1.5.0 coastalhub (2025-11-26) eject red X, orange Eject, spacing fix
local player = game:GetService("Players").LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "CoastalHubGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local scale = 0.7
local uiWidth, uiHeight = math.floor(470 * scale), math.floor(420 * scale)
local shiftY = math.floor(80 * scale)

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, uiWidth, 0, uiHeight)
frame.Position = UDim2.new(0.5, -uiWidth // 2, 0.5, -uiHeight // 2 - shiftY)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.25
frame.BorderSizePixel = 0
frame.Parent = gui

local border = Instance.new("Frame")
border.Size = UDim2.new(1, -math.floor(8 * scale), 1, -math.floor(8 * scale))
border.Position = UDim2.new(0, math.floor(4 * scale), 0, math.floor(4 * scale))
border.BackgroundColor3 = Color3.fromRGB(255,255,255)
border.BackgroundTransparency = 0.8
border.BorderSizePixel = 0
border.Parent = frame

local inner = Instance.new("Frame")
inner.Size = UDim2.new(1, -math.floor(24 * scale), 1, -math.floor(24 * scale))
inner.Position = UDim2.new(0, math.floor(12 * scale), 0, math.floor(12 * scale))
inner.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
inner.BackgroundTransparency = 0.25
inner.BorderSizePixel = 0
inner.Parent = border

local title = Instance.new("TextLabel")
title.Text = "Coastal Hub"
title.Size = UDim2.new(1, 0, 0, math.floor(46 * scale))
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = math.floor(32 * scale)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextStrokeTransparency = 0.4
title.Parent = inner

-- CLOSE BUTTON: small white X in top right
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "✕"
closeBtn.Size = UDim2.new(0, math.floor(44 * scale), 0, math.floor(42 * scale))
closeBtn.Position = UDim2.new(1, -math.floor(44 * scale) - 6, 0, math.floor(2 * scale))
closeBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
closeBtn.BackgroundTransparency = 0.15
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = math.floor(26*scale)
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.BorderSizePixel = 0
closeBtn.Parent = inner

-- EJECT SQUARE RED X BUTTON (left of close)
local ejectRedBtn = Instance.new("TextButton")
ejectRedBtn.Text = "X"
ejectRedBtn.Size = UDim2.new(0, math.floor(46*scale), 0, math.floor(46*scale))
ejectRedBtn.Position = UDim2.new(1, -math.floor(46 * scale * 2) - 16, 0, math.floor(2 * scale))
ejectRedBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
ejectRedBtn.BackgroundTransparency = 0.15
ejectRedBtn.TextSize = math.floor(38*scale)
ejectRedBtn.Font = Enum.Font.GothamBlack
ejectRedBtn.TextColor3 = Color3.fromRGB(255,0,0)
ejectRedBtn.TextWrapped = true
ejectRedBtn.BorderSizePixel = 0
ejectRedBtn.Parent = inner

-- ORANGE "EJECT" BUTTON (left side, spaced so title does not collide)
local ejectBtn = Instance.new("TextButton")
ejectBtn.Text = "Eject"
ejectBtn.Size = UDim2.new(0, math.floor(90 * scale), 0, math.floor(38 * scale))
ejectBtn.Position = UDim2.new(0, math.floor(2 * scale), 0, math.floor(2 * scale))
ejectBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
ejectBtn.BackgroundTransparency = 0.08
ejectBtn.Font = Enum.Font.GothamBold
ejectBtn.TextSize = math.floor(20 * scale)
ejectBtn.TextColor3 = Color3.fromRGB(255,140,0) -- orange
ejectBtn.BorderSizePixel = 0
ejectBtn.Parent = inner

local restoreBtn = Instance.new("TextButton")
restoreBtn.Text = "Hub"
restoreBtn.Size = UDim2.new(0, math.floor(54 * scale), 0, math.floor(54 * scale))
restoreBtn.Position = UDim2.new(0, math.floor(8 * scale), 0.5, -math.floor(27 * scale))
restoreBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
restoreBtn.BackgroundTransparency = 0.1
restoreBtn.Font = Enum.Font.GothamBold
restoreBtn.TextSize = math.floor(20 * scale)
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
ejectRedBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
    local scriptRef = script
    if scriptRef and scriptRef.Parent then
        scriptRef:Destroy()
    end
end)

local btnYStart = math.floor(46 * scale)
local btnYOffset = math.floor(44 * scale)
local btnWidth = 0.8

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
    btn.Size = UDim2.new(btnWidth, 0, 0, math.floor(36 * scale))
    btn.Position = UDim2.new((1-btnWidth)/2, 0, 0, btnYStart + btnYOffset*(i-1))
    btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    btn.BackgroundTransparency = 0.1
    btn.Font = Enum.Font.Gotham
    btn.TextSize = math.floor(18*scale)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextWrapped = true
    btn.BorderSizePixel = 0
    btn.Parent = inner
    diagButtons[i] = btn
end

local outputAreaY = btnYStart + btnYOffset*#diagButtons
local outputFrame = Instance.new("Frame")
outputFrame.Size = UDim2.new(1, 0, 0, math.floor(112*scale))
outputFrame.Position = UDim2.new(0, 0, 0, outputAreaY)
outputFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
outputFrame.BackgroundTransparency = 0.15
outputFrame.BorderSizePixel = 0
outputFrame.Parent = inner

local outputBox = Instance.new("TextBox")
outputBox.Size = UDim2.new(1, -math.floor(34*scale), 1, -math.floor(12*scale))
outputBox.Position = UDim2.new(0, 0, 0, 0)
outputBox.BackgroundTransparency = 1
outputBox.TextSize = math.floor(14*scale)
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

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -math.floor(34*scale), 1, -math.floor(12*scale))
scrollingFrame.Position = UDim2.new(0, 0, 0, 0)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarThickness = math.floor(12*scale)
scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(255,255,255)
scrollingFrame.BorderSizePixel = 0
scrollingFrame.Visible = false
scrollingFrame.Parent = outputFrame

local scrollBar = Instance.new("Frame")
scrollBar.Size = UDim2.new(0, math.floor(12*scale), 1, -math.floor(12*scale))
scrollBar.Position = UDim2.new(1, -math.floor(20*scale), 0, math.floor(6*scale))
scrollBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
scrollBar.BackgroundTransparency = 0
scrollBar.BorderSizePixel = 0
scrollBar.Parent = outputFrame
scrollBar.Visible = false

local copyBtn = Instance.new("TextButton")
copyBtn.Text = "📋 Copy"
copyBtn.Size = UDim2.new(0, math.floor(86*scale), 0, math.floor(32*scale))
copyBtn.Position = UDim2.new(1, -math.floor(96*scale), 1, -math.floor(34*scale))
copyBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
copyBtn.BackgroundTransparency = 0.07
copyBtn.TextColor3 = Color3.fromRGB(255,255,255)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = math.floor(16*scale)
copyBtn.BorderSizePixel = 0
copyBtn.Parent = outputFrame

local function setOutput(text)
    local lines = {}
    for line in string.gmatch(text, "[^\r\n]+") do
        table.insert(lines, line)
    end

    if #lines == 0 or text == "" then
        outputBox.Text = ""
        scrollingFrame.Visible = false
        scrollBar.Visible = false
        outputBox.Visible = false
        outputFrame.Size = UDim2.new(1, 0, 0, math.floor(40*scale))
        copyBtn.Position = UDim2.new(1, -math.floor(96*scale), 0, math.floor(4*scale))
    elseif #lines <= 10 then
        outputBox.Visible = true
        outputBox.Text = table.concat(lines, "\n")
        scrollingFrame.Visible = false
        scrollBar.Visible = false
        outputFrame.Size = UDim2.new(1, 0, 0, math.floor(18*scale*math.max(#lines,1))+math.floor(32*scale))
        copyBtn.Position = UDim2.new(1, -math.floor(96*scale), 1, -math.floor(34*scale))
    else
        outputBox.Visible = false
        scrollingFrame.Visible = true
        scrollBar.Visible = true
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, math.floor(18*scale*(#lines+1)))
        for _, child in pairs(scrollingFrame:GetChildren()) do if child:IsA("TextLabel") then child:Destroy() end end
        local shown = 10
        for i=1,shown do
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1,0,0,math.floor(18*scale))
            lbl.Position = UDim2.new(0,0,0,math.floor(18*scale*(i-1)))
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = Color3.fromRGB(255,255,255)
            lbl.Font = Enum.Font.Code
            lbl.Text = lines[i]
            lbl.TextSize = math.floor(14*scale)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = scrollingFrame
        end
        local moreLbl = Instance.new("TextLabel")
        moreLbl.Size = UDim2.new(1, 0, 0, math.floor(18*scale))
        moreLbl.Position = UDim2.new(0, 0, 0, math.floor(18*scale*shown))
        moreLbl.BackgroundTransparency = 1
        moreLbl.TextColor3 = Color3.fromRGB(255,255,255)
        moreLbl.Font = Enum.Font.Code
        moreLbl.TextSize = math.floor(14*scale)
        moreLbl.TextXAlignment = Enum.TextXAlignment.Left
        moreLbl.Text = "("..#lines.." lines total, +"..(#lines-10).." hidden)"
        moreLbl.Parent = scrollingFrame
        outputFrame.Size = UDim2.new(1, 0, 0, math.floor(18*scale*(shown+2)) + math.floor(32*scale))
        copyBtn.Position = UDim2.new(1, -math.floor(96*scale), 1, -math.floor(34*scale))
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
    if outputBox.Visible then
        if setclipboard then
            setclipboard(outputBox.Text)
        end
    elseif scrollingFrame.Visible then
        local collect = {}
        for _, child in pairs(scrollingFrame:GetChildren()) do
            if child:IsA("TextLabel") then
                table.insert(collect, child.Text)
            end
        end
        if setclipboard then
            setclipboard(table.concat(collect,"\n"))
        end
    end
end)

setOutput("")
