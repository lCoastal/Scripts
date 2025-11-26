-- v1.7.0 coastalhub (2025-11-26) button feedback green "Done!" text
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
local bottomAreaHeight = math.floor(112*scale)
local outputFrame = Instance.new("Frame")
outputFrame.Size = UDim2.new(1, 0, 0, bottomAreaHeight)
outputFrame.Position = UDim2.new(0, 0, 0, outputAreaY)
outputFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
outputFrame.BackgroundTransparency = 0.15
outputFrame.BorderSizePixel = 0
outputFrame.Parent = inner

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -math.floor(24*scale), 1, -math.floor(44*scale))
scrollingFrame.Position = UDim2.new(0, math.floor(12*scale), 0, math.floor(10*scale))
scrollingFrame.BackgroundTransparency = 0.1
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.ScrollBarThickness = math.floor(12*scale)
scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(255,255,255)
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarImageTransparency = 0
scrollingFrame.Parent = outputFrame

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

-- Feedback "Done!" text
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
feedbackLbl.ZIndex = 100 -- Always top!
feedbackLbl.Visible = false
feedbackLbl.Parent = outputFrame

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
    local lines = {}
    for line in string.gmatch(text, "[^\r\n]+") do
        table.insert(lines, line)
    end
    for _, child in pairs(scrollingFrame:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    if #lines == 0 or text == "" then
        scrollingFrame.CanvasSize = UDim2.new(0,0,0,0)
    else
        local visibleLines = #lines > 10 and 10 or #lines
        for i=1,visibleLines do
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
        if #lines > 10 then
            local moreLbl = Instance.new("TextLabel")
            moreLbl.Size = UDim2.new(1, 0, 0, math.floor(18*scale))
            moreLbl.Position = UDim2.new(0, 0, 0, math.floor(18*scale*11))
            moreLbl.BackgroundTransparency = 1
            moreLbl.TextColor3 = Color3.fromRGB(255,255,255)
            moreLbl.Font = Enum.Font.Code
            moreLbl.TextSize = math.floor(14*scale)
            moreLbl.TextXAlignment = Enum.TextXAlignment.Left
            moreLbl.Text = "("..#lines.." lines total, +"..(#lines-10).." hidden)"
            moreLbl.Parent = scrollingFrame
            scrollingFrame.CanvasSize = UDim2.new(0,0,0,math.floor(18*scale*12))
        else
            scrollingFrame.CanvasSize = UDim2.new(0,0,0,math.floor(18*scale*visibleLines))
        end
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
    local info = "Player: "..player.Name.."\nUserId: "..player.UserId.."\nPing: "
    local stats = game:GetService("Stats"):FindFirstChild("Network") 
    if stats then
        info = info.." "..math.floor(stats.ServerStatsItem["Data Ping"]:GetValue()).."ms"
    end
    setOutput(info)
    buttonFeedback("Done!")
end)
diagButtons[3].MouseButton1Click:Connect(function()
    local items = {}
    for _,v in ipairs(player.Backpack:GetChildren()) do
        table.insert(items, v.Name)
    end
    setOutput("Backpack Items:\n"..table.concat(items,"\n"))
    buttonFeedback("Done!")
end)
diagButtons[4].MouseButton1Click:Connect(function()
    local children = {}
    for _,v in ipairs(game.Workspace:GetChildren()) do
        table.insert(children, v.Name.." ["..v.ClassName.."]")
    end
    setOutput("Workspace Children:\n"..table.concat(children,"\n"))
    buttonFeedback("Done!")
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
    buttonFeedback("Done!")
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
    buttonFeedback("Done!")
end)
diagButtons[7].MouseButton1Click:Connect(function()
    local services = {}
    for _, service in ipairs(game:GetChildren()) do
        table.insert(services, service.ClassName.." ("..service.Name..")")
    end
    setOutput("Services:\n"..table.concat(services,"\n"))
    buttonFeedback("Done!")
end)

copyBtn.MouseButton1Click:Connect(function()
    local collect = {}
    for _, child in pairs(scrollingFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            table.insert(collect, child.Text)
        end
    end
    if setclipboard then
        setclipboard(table.concat(collect,"\n"))
        buttonFeedback("Copied!")
    end
end)

setOutput("")
