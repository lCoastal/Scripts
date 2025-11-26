-- v1.9.0 coastalhub (2025-11-26) intelligent scroll/copy all, summary line hidden, image1 reference

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
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255,255,255)
frame.Active = true
frame.Draggable = false
frame.Parent = gui

local dragging, dragInput, dragStart, startPos

local titleBarHeight = math.floor(46 * scale)
local function makeDraggable(target, dragFrame)
    target.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = dragFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    target.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            dragFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local inner = Instance.new("Frame")
inner.Size = UDim2.new(1, 0, 1, 0)
inner.Position = UDim2.new(0, 0, 0, 0)
inner.BackgroundTransparency = 1
inner.BorderSizePixel = 0
inner.Parent = frame

local title = Instance.new("TextLabel")
title.Text = "Coastal Hub"
title.Size = UDim2.new(1, 0, 0, titleBarHeight)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = math.floor(32 * scale)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextStrokeTransparency = 0.4
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = inner
makeDraggable(title, frame)

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

local ejectBtn = Instance.new("TextButton")
ejectBtn.Text = "Eject"
ejectBtn.Size = UDim2.new(0, math.floor(90 * scale), 0, math.floor(38 * scale))
ejectBtn.Position = UDim2.new(0, math.floor(2 * scale), 0, math.floor(2 * scale))
ejectBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
ejectBtn.BackgroundTransparency = 0.08
ejectBtn.Font = Enum.Font.GothamBold
ejectBtn.TextSize = math.floor(20 * scale)
ejectBtn.TextColor3 = Color3.fromRGB(255,140,0)
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

-- Ping Toggle Area
local pingArea = Instance.new("Frame")
pingArea.Size = UDim2.new(1, 0, 0, math.floor(30 * scale))
pingArea.Position = UDim2.new(0, 0, 0, math.floor(48 * scale))
pingArea.BackgroundTransparency = 1
pingArea.Parent = inner

local pingToggle = Instance.new("TextButton")
pingToggle.Size = UDim2.new(0, math.floor(80 * scale), 1, 0)
pingToggle.Position = UDim2.new(0, math.floor(10 * scale), 0, 0)
pingToggle.BackgroundColor3 = Color3.fromRGB(0,0,0)
pingToggle.BackgroundTransparency = 0.1
pingToggle.Text = "Ping: OFF"
pingToggle.Font = Enum.Font.GothamBold
pingToggle.TextSize = math.floor(18 * scale)
pingToggle.TextColor3 = Color3.fromRGB(255,255,255)
pingToggle.BorderSizePixel = 0
pingToggle.Parent = pingArea

local pingValueLbl = Instance.new("TextLabel")
pingValueLbl.Size = UDim2.new(0, math.floor(120 * scale), 1, 0)
pingValueLbl.Position = UDim2.new(0, math.floor(100 * scale), 0, 0)
pingValueLbl.BackgroundTransparency = 1
pingValueLbl.Font = Enum.Font.GothamBold
pingValueLbl.TextSize = math.floor(18 * scale)
pingValueLbl.TextColor3 = Color3.fromRGB(80,255,80)
pingValueLbl.Text = ""
pingValueLbl.Parent = pingArea

local showPing = false
local pingConnection
local function updatePing()
    if showPing then
        local stats = game:GetService("Stats"):FindFirstChild("Network")
        local pingVal = "?"
        if stats and stats:FindFirstChild("ServerStatsItem") and stats.ServerStatsItem:FindFirstChild("Data Ping") then
            pingVal = math.floor(stats.ServerStatsItem["Data Ping"]:GetValue())
        end
        pingValueLbl.Text = "✔ Ping: "..tostring(pingVal).."ms"
    else
        pingValueLbl.Text = ""
    end
end
pingToggle.MouseButton1Click:Connect(function()
    showPing = not showPing
    pingToggle.Text = showPing and "Ping: ON" or "Ping: OFF"
    updatePing()
    if showPing and not pingConnection then
        pingConnection = game:GetService("RunService").Heartbeat:Connect(function()
            updatePing()
        end)
    elseif not showPing and pingConnection then
        pingConnection:Disconnect()
        pingConnection = nil
    end
end)

local btnYOffset = math.floor(44 * scale)
local btnWidth = 0.8
local diagTexts = {
    "List Usable Events",
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
    btn.Position = UDim2.new((1-btnWidth)/2, 0, 0, math.floor(80*scale) + btnYOffset*(i-1))
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

local outputAreaY = math.floor(80*scale) + btnYOffset*#diagButtons
local bottomAreaHeight = math.floor(112*scale)
local outputFrame = Instance.new("Frame")
outputFrame.Size = UDim2.new(1, 0, 0, bottomAreaHeight)
outputFrame.Position = UDim2.new(0, 0, 0, outputAreaY)
outputFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
outputFrame.BackgroundTransparency = 0.15
outputFrame.BorderSizePixel = 0
outputFrame.Parent = inner

local outputBox = Instance.new("TextBox")
outputBox.Size = UDim2.new(1, -math.floor(24*scale), 1, -math.floor(44*scale))
outputBox.Position = UDim2.new(0, math.floor(12*scale), 0, math.floor(10*scale))
outputBox.BackgroundTransparency = 0.1
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

local lines_total_label = Instance.new("TextLabel")
lines_total_label.Size = UDim2.new(1, -math.floor(24*scale), 0, math.floor(18*scale))
lines_total_label.Position = UDim2.new(0, math.floor(12*scale), 1, -math.floor(34*scale))
lines_total_label.BackgroundTransparency = 1
lines_total_label.Font = Enum.Font.Code
lines_total_label.TextSize = math.floor(14*scale)
lines_total_label.TextColor3 = Color3.fromRGB(210,210,210)
lines_total_label.Text = ""
lines_total_label.Visible = false
lines_total_label.Parent = outputFrame

outputBox.ClearTextOnFocus = false
outputBox.MultiLine = true
outputBox.TextEditable = false
outputBox.ReadOnly = true

local copyBtn = Instance.new("TextButton")
copyBtn.Text = "📋 Copy"
copyBtn.Size = UDim2.new(0, math.floor(86*scale), 0, math.floor(32*scale))
copyBtn.Position = UDim2.new(1, -math.floor(100*scale), 1, -math.floor(38*scale))
copyBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
copyBtn.BackgroundTransparency = 0.15
copyBtn.TextColor3 = Color3.fromRGB(255,255,255)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = math.floor(16*scale)
copyBtn.BorderSizePixel = 0
copyBtn.Parent = outputFrame

local feedbackLbl = Instance.new("TextLabel")
feedbackLbl.Text = ""
feedbackLbl.Size = UDim2.new(0, math.floor(160*scale),0, math.floor(32*scale))
feedbackLbl.Position = UDim2.new(0.5, -math.floor(80*scale), 1, -math.floor(40*scale))
feedbackLbl.BackgroundTransparency = 1
feedbackLbl.TextColor3 = Color3.fromRGB(37,220,30)
feedbackLbl.Font = Enum.Font.GothamBlack
feedbackLbl.TextSize = math.floor(22*scale)
feedbackLbl.TextStrokeTransparency = 0.7
feedbackLbl.TextXAlignment = Enum.TextXAlignment.Center
feedbackLbl.ZIndex = 100
feedbackLbl.Visible = false
feedbackLbl.Parent = outputFrame

local currentOutputText = ""
local function buttonFeedback(msg)
    feedbackLbl.Text = msg or "Done!"
    feedbackLbl.Visible = true
    feedbackLbl.BackgroundTransparency = 1
    feedbackLbl.TextTransparency = 0
    feedbackLbl.TextStrokeTransparency = 0.7
    local fade = game:GetService("TweenService"):Create(feedbackLbl,TweenInfo.new(1),{TextTransparency=0.5})
    fade:Play()
    task.delay(1,function()
        feedbackLbl.Visible = false
        feedbackLbl.TextTransparency = 0
    end)
end

local function setOutput(text)
    currentOutputText = text or ""
    local lines = {}
    for line in string.gmatch(currentOutputText, "[^\r\n]+") do
        table.insert(lines, line)
    end
    outputBox.Text = currentOutputText
    outputBox.CursorPosition = 1

    -- Show summary line only if there are more than 20 lines, and only when not fully expanded
    if #lines > 20 then
        lines_total_label.Text = "("..#lines.." lines total)"
        lines_total_label.Visible = true
    else
        lines_total_label.Text = ""
        lines_total_label.Visible = false
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
    buttonFeedback("Done!")
end)
diagButtons[2].MouseButton1Click:Connect(function()
    local items = {}
    for _,v in ipairs(player.Backpack:GetChildren()) do
        table.insert(items, v.Name)
    end
    setOutput("Backpack Items:\n"..table.concat(items,"\n"))
    buttonFeedback("Done!")
end)
diagButtons[3].MouseButton1Click:Connect(function()
    local children = {}
    for _,v in ipairs(game.Workspace:GetChildren()) do
        table.insert(children, v.Name.." ["..v.ClassName.."]")
    end
    setOutput("Workspace Children:\n"..table.concat(children,"\n"))
    buttonFeedback("Done!")
end)
diagButtons[4].MouseButton1Click:Connect(function()
    local cam = workspace.CurrentCamera
    local camInfo = {
        "Camera Type: "..tostring(cam.CameraType),
        "CFrame: "..tostring(cam.CFrame),
        "FieldOfView: "..tostring(cam.FieldOfView),
        "Focus: "..tostring(cam.Focus),
        "ViewportSize: "..tostring(cam.ViewportSize)
    }
    setOutput("Camera Info:\n"..table.concat(camInfo,"\n"))
    buttonFeedback("Done!")
end)
diagButtons[5].MouseButton1Click:Connect(function()
    local lighting = game:GetService("Lighting")
    local items = {}
    for _,prop in ipairs({"Ambient","Brightness","ColorShift_Bottom","ColorShift_Top","ClockTime","FogColor","FogEnd","FogStart","OutdoorAmbient","ShadowSoftness"}) do
        local ok, value = pcall(function() return lighting[prop] end)
        if ok then
            table.insert(items, prop..": "..tostring(value))
        end
    end
    setOutput("Lighting Properties:\n"..table.concat(items,"\n"))
    buttonFeedback("Done!")
end)
diagButtons[6].MouseButton1Click:Connect(function()
    local services = {}
    for _, service in ipairs(game:GetChildren()) do
        table.insert(services, service.ClassName.." ("..service.Name..")")
    end
    setOutput("Services:\n"..table.concat(services,"\n"))
    buttonFeedback("Done!")
end)

copyBtn.MouseButton1Click:Connect(function()
    local textToCopy = currentOutputText
    -- Remove summary line from copy
    textToCopy = string.gsub(textToCopy, "\n?%(%d+ lines total.-%)$", "")
    if setclipboard then
        setclipboard(textToCopy)
        buttonFeedback("Copied!")
    end
    -- On copy, show ALL lines and remove the lines summary label
    outputBox.Text = textToCopy
    lines_total_label.Visible = false
end)

setOutput("")
