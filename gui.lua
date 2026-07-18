--// Smile Mod Menu GUI v4.0 | CLEAN — No Button Connections
--// Pure Instance.new | Backend handles all logic
--// Compatible with functions.lua (finxion.txt backend)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// ============================================
--// GLOBAL G TABLE (CRITICAL)
--// ============================================
getgenv().G = getgenv().G or {}
local G = getgenv().G

-- Destroy old GUI if re-executing
if G.screenGui and G.screenGui.Parent then
    pcall(function() G.screenGui:Destroy() end)
end
for k, v in pairs(G) do
    if typeof(v) == "Instance" then
        pcall(function() v:Destroy() end)
    end
    G[k] = nil
end

--// ============================================
--// THEME
--// ============================================
local COL = {
    bg = Color3.fromRGB(18, 18, 24),
    surface = Color3.fromRGB(28, 28, 38),
    surfaceHover = Color3.fromRGB(38, 38, 52),
    accent = Color3.fromRGB(0, 170, 255),
    text = Color3.fromRGB(235, 235, 240),
    textDim = Color3.fromRGB(140, 140, 155),
    border = Color3.fromRGB(40, 40, 55),
    toggleOff = Color3.fromRGB(40, 40, 40),
    toggleOn = Color3.fromRGB(0, 180, 0),
    red = Color3.fromRGB(255, 65, 65),
    green = Color3.fromRGB(65, 255, 100)
}

local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = parent
    return c
end

local function stroke(parent, col, thick)
    local s = Instance.new("UIStroke")
    s.Color = col or COL.border
    s.Thickness = thick or 1
    s.Parent = parent
    return s
end

local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

--// ============================================
--// 1. SCREEN GUI & MAIN FRAME
--// ============================================
G.screenGui = Instance.new("ScreenGui")
G.screenGui.Name = "SmileModMenu"
G.screenGui.ResetOnSpawn = false
G.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
G.screenGui.Parent = PlayerGui

G.frame = Instance.new("Frame")
G.frame.Name = "MainFrame"
G.frame.Size = UDim2.new(0, 640, 0, 440)
G.frame.Position = UDim2.new(0.5, -320, 0.5, -220)
G.frame.BackgroundColor3 = COL.bg
G.frame.BorderSizePixel = 0
G.frame.Active = true
G.frame.Parent = G.screenGui
corner(G.frame, 12)
stroke(G.frame)

G.titleLabel = Instance.new("TextLabel")
G.titleLabel.Name = "TitleBar"
G.titleLabel.Size = UDim2.new(1, 0, 0, 36)
G.titleLabel.BackgroundColor3 = COL.surface
G.titleLabel.BorderSizePixel = 0
G.titleLabel.Text = "  Smile Mod Menu"
G.titleLabel.TextColor3 = COL.text
G.titleLabel.TextSize = 15
G.titleLabel.Font = Enum.Font.GothamBold
G.titleLabel.TextXAlignment = Enum.TextXAlignment.Left
G.titleLabel.Parent = G.frame
corner(G.titleLabel, 12)

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 8)
titleFix.Position = UDim2.new(0, 0, 1, -8)
titleFix.BackgroundColor3 = COL.surface
titleFix.BorderSizePixel = 0
titleFix.Parent = G.titleLabel

makeDraggable(G.frame, G.titleLabel)

G.minimizedCircle = Instance.new("TextButton")
G.minimizedCircle.Name = "MinimizeBtn"
G.minimizedCircle.Size = UDim2.new(0, 24, 0, 24)
G.minimizedCircle.Position = UDim2.new(1, -34, 0, 6)
G.minimizedCircle.BackgroundColor3 = COL.red
G.minimizedCircle.Text = "−"
G.minimizedCircle.TextColor3 = COL.text
G.minimizedCircle.TextSize = 14
G.minimizedCircle.Font = Enum.Font.GothamBold
G.minimizedCircle.Parent = G.titleLabel
corner(G.minimizedCircle, 12)

local minimized = false
G.minimizedCircle.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        G.frame:TweenSize(UDim2.new(0, 640, 0, 36), "Out", "Quad", 0.25, true)
        G.minimizedCircle.Text = "+"
        G.minimizedCircle.BackgroundColor3 = COL.green
    else
        G.frame:TweenSize(UDim2.new(0, 640, 0, 440), "Out", "Quad", 0.25, true)
        G.minimizedCircle.Text = "−"
        G.minimizedCircle.BackgroundColor3 = COL.red
    end
end)

--// ============================================
--// TAB SYSTEM
--// ============================================
local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(1, -20, 0, 32)
tabBar.Position = UDim2.new(0, 10, 0, 42)
tabBar.BackgroundTransparency = 1
tabBar.Parent = G.frame

local tabList = Instance.new("UIListLayout")
tabList.FillDirection = Enum.FillDirection.Horizontal
tabList.SortOrder = Enum.SortOrder.LayoutOrder
tabList.Padding = UDim.new(0, 6)
tabList.Parent = tabBar

local tabs = {}
local activeTab = nil

local function createTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "TabBtn"
    btn.Size = UDim2.new(0, 90, 1, 0)
    btn.BackgroundColor3 = COL.surface
    btn.Text = name
    btn.TextColor3 = COL.textDim
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamSemibold
    btn.LayoutOrder = order
    btn.Parent = tabBar
    corner(btn, 6)

    local content = Instance.new("ScrollingFrame")
    content.Name = name .. "Content"
    content.Size = UDim2.new(1, -20, 1, -88)
    content.Position = UDim2.new(0, 10, 0, 78)
    content.BackgroundColor3 = COL.surface
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = COL.accent
    content.Visible = false
    content.Parent = G.frame
    corner(content, 8)

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 8)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = content

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.Parent = content

    tabs[name] = {button = btn, content = content}

    btn.MouseButton1Click:Connect(function()
        for n, t in pairs(tabs) do
            t.content.Visible = (n == name)
            t.button.TextColor3 = (n == name) and COL.accent or COL.textDim
            t.button.BackgroundColor3 = (n == name) and COL.surfaceHover or COL.surface
        end
        activeTab = name
    end)

    return content
end

local aimTab = createTab("Aimbot", 1)
local visTab = createTab("Visuals", 2)
local playTab = createTab("Player", 3)
local hitTab = createTab("Hitboxes", 4)
local miscTab = createTab("Misc", 5)
local cfgTab = createTab("Configs", 6)

tabs["Aimbot"].content.Visible = true
tabs["Aimbot"].button.TextColor3 = COL.accent
tabs["Aimbot"].button.BackgroundColor3 = COL.surfaceHover

--// ============================================
--// UI BUILDERS
--// ============================================
local function createToggle(parent, text, gKey, order)
    local row = Instance.new("Frame")
    row.Name = gKey .. "Row"
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = COL.text
    lbl.TextSize = 13
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Name = gKey
    btn.Size = UDim2.new(0, 90, 0, 24)
    btn.Position = UDim2.new(1, -90, 0.5, -12)
    btn.BackgroundColor3 = COL.toggleOff
    btn.Text = text .. ": OFF"
    btn.TextColor3 = COL.text
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.Parent = row
    corner(btn, 4)

    G[gKey] = btn
    return btn
end

local function createSliderRow(parent, labelText, gFrameKey, gBtnKey, gInputKey, min, max, default, order)
    local row = Instance.new("Frame")
    row.Name = gFrameKey .. "Row"
    row.Size = UDim2.new(1, 0, 0, 52)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.35, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = COL.text
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = gFrameKey
    sliderFrame.Size = UDim2.new(0.45, 0, 0, 8)
    sliderFrame.Position = UDim2.new(0, 0, 0, 28)
    sliderFrame.BackgroundColor3 = COL.toggleOff
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = row
    corner(sliderFrame, 4)

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = COL.accent
    fill.BorderSizePixel = 0
    fill.Parent = sliderFrame
    corner(fill, 4)

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Name = gBtnKey
    sliderBtn.Size = UDim2.new(0, 16, 0, 16)
    sliderBtn.Position = UDim2.new((default-min)/(max-min), -8, 0.5, -8)
    sliderBtn.BackgroundColor3 = COL.text
    sliderBtn.Text = ""
    sliderBtn.Parent = sliderFrame
    corner(sliderBtn, 8)

    local input = Instance.new("TextBox")
    input.Name = gInputKey
    input.Size = UDim2.new(0, 55, 0, 24)
    input.Position = UDim2.new(1, -60, 0, 0)
    input.BackgroundColor3 = COL.bg
    input.TextColor3 = COL.text
    input.TextSize = 12
    input.Font = Enum.Font.Gotham
    input.PlaceholderText = tostring(default)
    input.Text = tostring(default)
    input.Parent = row
    corner(input, 4)
    stroke(input)

    G[gFrameKey] = sliderFrame
    G[gBtnKey] = sliderBtn
    G[gInputKey] = input

    local dragging = false
    local range = max - min

    local function setValue(val)
        val = math.clamp(val, min, max)
        local pct = (val - min) / range
        sliderBtn.Position = UDim2.new(pct, -8, 0.5, -8)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        input.Text = tostring(math.floor(val * 100) / 100)
        return val
    end

    sliderBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local absPos = sliderFrame.AbsolutePosition.X
            local absSize = sliderFrame.AbsoluteSize.X
            local mouseX = inp.Position.X
            local pct = math.clamp((mouseX - absPos) / absSize, 0, 1)
            setValue(min + (pct * range))
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    input.FocusLost:Connect(function()
        local num = tonumber(input.Text)
        if num then setValue(num) end
    end)

    return row
end

--// ============================================
--// 2. AIMBOT TAB
--// ============================================
createToggle(aimTab, "AIM", "aimButton", 1)
createToggle(aimTab, "FOV Circle", "fovCircleButton", 2)
createToggle(aimTab, "WallCheck", "wallButton", 3)
createToggle(aimTab, "Team Check", "teamCheckButton", 4)
createToggle(aimTab, "Silent Aim", "silentAimButton", 5)
createToggle(aimTab, "Smooth", "smoothToggleButton", 6)
createSliderRow(aimTab, "FOV", "aimFOVSliderFrame", "aimFOVSliderButton", "aimFOVInput", 30, 200, 100, 7)
createSliderRow(aimTab, "Smoothness", "smoothSliderFrame", "smoothSliderButton", "smoothInput", 0.01, 1, 0.15, 8)

G.aimSettingsFrame = Instance.new("Frame")
G.aimSettingsFrame.Name = "AimSettings"
G.aimSettingsFrame.Size = UDim2.new(1, 0, 0, 90)
G.aimSettingsFrame.BackgroundColor3 = COL.bg
G.aimSettingsFrame.LayoutOrder = 9
G.aimSettingsFrame.Parent = aimTab
corner(G.aimSettingsFrame, 8)
stroke(G.aimSettingsFrame)

G.aimSettingsTitle = Instance.new("TextLabel")
G.aimSettingsTitle.Name = "Title"
G.aimSettingsTitle.Size = UDim2.new(1, -10, 0, 22)
G.aimSettingsTitle.Position = UDim2.new(0, 5, 0, 4)
G.aimSettingsTitle.BackgroundTransparency = 1
G.aimSettingsTitle.Text = "Advanced Aim Settings"
G.aimSettingsTitle.TextColor3 = COL.accent
G.aimSettingsTitle.TextSize = 12
G.aimSettingsTitle.Font = Enum.Font.GothamBold
G.aimSettingsTitle.Parent = G.aimSettingsFrame

makeDraggable(G.aimSettingsFrame, G.aimSettingsTitle)

G.aimValCheckFrame = Instance.new("Frame")
G.aimValCheckFrame.Name = "AimValCheck"
G.aimValCheckFrame.Size = UDim2.new(1, 0, 0, 110)
G.aimValCheckFrame.BackgroundColor3 = COL.bg
G.aimValCheckFrame.LayoutOrder = 10
G.aimValCheckFrame.Parent = aimTab
corner(G.aimValCheckFrame, 8)
stroke(G.aimValCheckFrame)

G.aimValCheckTitle = Instance.new("TextLabel")
G.aimValCheckTitle.Name = "Title"
G.aimValCheckTitle.Size = UDim2.new(1, -10, 0, 20)
G.aimValCheckTitle.Position = UDim2.new(0, 5, 0, 3)
G.aimValCheckTitle.BackgroundTransparency = 1
G.aimValCheckTitle.Text = "Aim ValCheck"
G.aimValCheckTitle.TextColor3 = COL.accent
G.aimValCheckTitle.TextSize = 11
G.aimValCheckTitle.Font = Enum.Font.GothamBold
G.aimValCheckTitle.Parent = G.aimValCheckFrame

makeDraggable(G.aimValCheckFrame, G.aimValCheckTitle)

G.aimValCheckScroll = Instance.new("ScrollingFrame")
G.aimValCheckScroll.Name = "Scroll"
G.aimValCheckScroll.Size = UDim2.new(1, -10, 1, -32)
G.aimValCheckScroll.Position = UDim2.new(0, 5, 0, 27)
G.aimValCheckScroll.BackgroundTransparency = 1
G.aimValCheckScroll.ScrollBarThickness = 3
G.aimValCheckScroll.Parent = G.aimValCheckFrame

G.aimValCheckButton = Instance.new("TextButton")
G.aimValCheckButton.Name = "ValCheckBtn"
G.aimValCheckButton.Size = UDim2.new(0, 85, 0, 24)
G.aimValCheckButton.Position = UDim2.new(0, 5, 0, 3)
G.aimValCheckButton.BackgroundColor3 = COL.surfaceHover
G.aimValCheckButton.Text = "ValCheck"
G.aimValCheckButton.TextColor3 = COL.text
G.aimValCheckButton.TextSize = 10
G.aimValCheckButton.Font = Enum.Font.GothamSemibold
G.aimValCheckButton.Parent = G.aimValCheckFrame
corner(G.aimValCheckButton, 4)

G.aimValCheckBtn = Instance.new("TextButton")
G.aimValCheckBtn.Name = "CheckBtn"
G.aimValCheckBtn.Size = UDim2.new(0, 85, 0, 24)
G.aimValCheckBtn.Position = UDim2.new(0, 95, 0, 3)
G.aimValCheckBtn.BackgroundColor3 = COL.surfaceHover
G.aimValCheckBtn.Text = "Check"
G.aimValCheckBtn.TextColor3 = COL.text
G.aimValCheckBtn.TextSize = 10
G.aimValCheckBtn.Font = Enum.Font.GothamSemibold
G.aimValCheckBtn.Parent = G.aimValCheckFrame
corner(G.aimValCheckBtn, 4)

--// ============================================
--// 3. VISUALS TAB
--// ============================================
createToggle(visTab, "ESP", "espButton", 1)
createToggle(visTab, "Charms", "charmsButton", 2)

local espToggleFrame = Instance.new("Frame")
espToggleFrame.Size = UDim2.new(1, 0, 0, 160)
espToggleFrame.BackgroundTransparency = 1
espToggleFrame.LayoutOrder = 3
espToggleFrame.Parent = visTab

createToggle(espToggleFrame, "Tracer", "espTracerBtn", 1)
createToggle(espToggleFrame, "Box", "espBoxBtn", 2)
createToggle(espToggleFrame, "Name", "espNameBtn", 3)
createToggle(espToggleFrame, "Health", "espHealthBtn", 4)
createToggle(espToggleFrame, "Distance", "espDistBtn", 5)

G.espColorPickerFrame = Instance.new("Frame")
G.espColorPickerFrame.Name = "ESPColorPicker"
G.espColorPickerFrame.Size = UDim2.new(1, 0, 0, 120)
G.espColorPickerFrame.BackgroundColor3 = COL.bg
G.espColorPickerFrame.LayoutOrder = 4
G.espColorPickerFrame.Parent = visTab
corner(G.espColorPickerFrame, 8)
stroke(G.espColorPickerFrame)

G.espColorPickerTitle = Instance.new("TextLabel")
G.espColorPickerTitle.Name = "Title"
G.espColorPickerTitle.Size = UDim2.new(1, -10, 0, 20)
G.espColorPickerTitle.Position = UDim2.new(0, 5, 0, 3)
G.espColorPickerTitle.BackgroundTransparency = 1
G.espColorPickerTitle.Text = "ESP Color (R/G/B)"
G.espColorPickerTitle.TextColor3 = COL.accent
G.espColorPickerTitle.TextSize = 11
G.espColorPickerTitle.Font = Enum.Font.GothamBold
G.espColorPickerTitle.Parent = G.espColorPickerFrame

makeDraggable(G.espColorPickerFrame, G.espColorPickerTitle)

local function makeColorSlider(parent, y, color, gFrameKey, gHandleKey)
    local frame = Instance.new("Frame")
    frame.Name = gFrameKey
    frame.Size = UDim2.new(1, -70, 0, 8)
    frame.Position = UDim2.new(0, 5, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    corner(frame, 4)

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new(Color3.new(0,0,0), color)
    grad.Parent = frame

    local handle = Instance.new("TextButton")
    handle.Name = gHandleKey
    handle.Size = UDim2.new(0, 14, 0, 14)
    handle.Position = UDim2.new(0.5, -7, 0.5, -7)
    handle.BackgroundColor3 = COL.text
    handle.Text = ""
    handle.Parent = frame
    corner(handle, 7)

    G[gFrameKey] = frame
    G[gHandleKey] = handle

    local dragging = false
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local pct = math.clamp((i.Position.X - frame.AbsolutePosition.X) / frame.AbsoluteSize.X, 0, 1)
            handle.Position = UDim2.new(pct, -7, 0.5, -7)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return frame, handle
end

makeColorSlider(G.espColorPickerFrame, 26, Color3.fromRGB(255,0,0), "espRSlider", "espRHandle")
makeColorSlider(G.espColorPickerFrame, 46, Color3.fromRGB(0,255,0), "espGSlider", "espGHandle")
makeColorSlider(G.espColorPickerFrame, 66, Color3.fromRGB(0,0,255), "espBSlider", "espBHandle")

G.espColorPreview = Instance.new("Frame")
G.espColorPreview.Name = "Preview"
G.espColorPreview.Size = UDim2.new(0, 42, 0, 42)
G.espColorPreview.Position = UDim2.new(1, -52, 0, 22)
G.espColorPreview.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
G.espColorPreview.Parent = G.espColorPickerFrame
corner(G.espColorPreview, 6)
stroke(G.espColorPreview)

G.espVisColorBtn = Instance.new("TextButton")
G.espVisColorBtn.Name = "VisColor"
G.espVisColorBtn.Size = UDim2.new(0, 80, 0, 24)
G.espVisColorBtn.Position = UDim2.new(0, 5, 0, 88)
G.espVisColorBtn.BackgroundColor3 = COL.surfaceHover
G.espVisColorBtn.Text = "Visible"
G.espVisColorBtn.TextColor3 = COL.text
G.espVisColorBtn.TextSize = 10
G.espVisColorBtn.Font = Enum.Font.GothamSemibold
G.espVisColorBtn.Parent = G.espColorPickerFrame
corner(G.espVisColorBtn, 4)

G.espUnvisColorBtn = Instance.new("TextButton")
G.espUnvisColorBtn.Name = "UnvisColor"
G.espUnvisColorBtn.Size = UDim2.new(0, 80, 0, 24)
G.espUnvisColorBtn.Position = UDim2.new(0, 90, 0, 88)
G.espUnvisColorBtn.BackgroundColor3 = COL.surfaceHover
G.espUnvisColorBtn.Text = "Hidden"
G.espUnvisColorBtn.TextColor3 = COL.text
G.espUnvisColorBtn.TextSize = 10
G.espUnvisColorBtn.Font = Enum.Font.GothamSemibold
G.espUnvisColorBtn.Parent = G.espColorPickerFrame
corner(G.espUnvisColorBtn, 4)

G.charmsSettingsFrame = Instance.new("Frame")
G.charmsSettingsFrame.Name = "CharmsSettings"
G.charmsSettingsFrame.Size = UDim2.new(1, 0, 0, 150)
G.charmsSettingsFrame.BackgroundColor3 = COL.bg
G.charmsSettingsFrame.LayoutOrder = 5
G.charmsSettingsFrame.Parent = visTab
corner(G.charmsSettingsFrame, 8)
stroke(G.charmsSettingsFrame)

G.charmsSettingsTitle = Instance.new("TextLabel")
G.charmsSettingsTitle.Name = "Title"
G.charmsSettingsTitle.Size = UDim2.new(1, -10, 0, 20)
G.charmsSettingsTitle.Position = UDim2.new(0, 5, 0, 3)
G.charmsSettingsTitle.BackgroundTransparency = 1
G.charmsSettingsTitle.Text = "Charms Settings"
G.charmsSettingsTitle.TextColor3 = COL.accent
G.charmsSettingsTitle.TextSize = 11
G.charmsSettingsTitle.Font = Enum.Font.GothamBold
G.charmsSettingsTitle.Parent = G.charmsSettingsFrame

makeDraggable(G.charmsSettingsFrame, G.charmsSettingsTitle)

createToggle(G.charmsSettingsFrame, "Visible", "charmsVisBtn", 2)
createToggle(G.charmsSettingsFrame, "Hidden", "charmsUnvisBtn", 3)
createToggle(G.charmsSettingsFrame, "NPC ESP", "charmsNpcBtn", 4)
createToggle(G.charmsSettingsFrame, "Object ESP", "charmsObjBtn", 5)

G.charmsColorPickerFrame = Instance.new("Frame")
G.charmsColorPickerFrame.Name = "CharmsColorPicker"
G.charmsColorPickerFrame.Size = UDim2.new(1, -10, 0, 70)
G.charmsColorPickerFrame.Position = UDim2.new(0, 5, 0, 78)
G.charmsColorPickerFrame.BackgroundColor3 = COL.surface
G.charmsColorPickerFrame.Parent = G.charmsSettingsFrame
corner(G.charmsColorPickerFrame, 4)

G.charmsColorPickerTitle = Instance.new("TextLabel")
G.charmsColorPickerTitle.Name = "Title"
G.charmsColorPickerTitle.Size = UDim2.new(1, -10, 0, 18)
G.charmsColorPickerTitle.Position = UDim2.new(0, 5, 0, 2)
G.charmsColorPickerTitle.BackgroundTransparency = 1
G.charmsColorPickerTitle.Text = "Charms Color"
G.charmsColorPickerTitle.TextColor3 = COL.accent
G.charmsColorPickerTitle.TextSize = 10
G.charmsColorPickerTitle.Font = Enum.Font.GothamBold
G.charmsColorPickerTitle.Parent = G.charmsColorPickerFrame

makeDraggable(G.charmsColorPickerFrame, G.charmsColorPickerTitle)

local function makeCharmsSlider(y, col, gKey)
    local frame = Instance.new("Frame")
    frame.Name = gKey
    frame.Size = UDim2.new(1, -60, 0, 6)
    frame.Position = UDim2.new(0, 5, 0, y)
    frame.BackgroundColor3 = col
    frame.BorderSizePixel = 0
    frame.Parent = G.charmsColorPickerFrame
    corner(frame, 3)

    local handle = Instance.new("TextButton")
    handle.Size = UDim2.new(0, 12, 0, 12)
    handle.Position = UDim2.new(0.5, -6, 0.5, -6)
    handle.BackgroundColor3 = COL.text
    handle.Text = ""
    handle.Parent = frame
    corner(handle, 6)

    G[gKey] = frame
    local handleName = gKey:gsub("Slider", "Handle")
    G[handleName] = handle

    local dragging = false
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local pct = math.clamp((i.Position.X - frame.AbsolutePosition.X) / frame.AbsoluteSize.X, 0, 1)
            handle.Position = UDim2.new(pct, -6, 0.5, -6)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

makeCharmsSlider(22, Color3.fromRGB(80,40,40), "charmsRSlider")
makeCharmsSlider(36, Color3.fromRGB(40,80,40), "charmsGSlider")
makeCharmsSlider(50, Color3.fromRGB(40,40,80), "charmsBSlider")

G.charmsColorPreview = Instance.new("Frame")
G.charmsColorPreview.Name = "Preview"
G.charmsColorPreview.Size = UDim2.new(0, 38, 0, 38)
G.charmsColorPreview.Position = UDim2.new(1, -48, 0, 8)
G.charmsColorPreview.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
G.charmsColorPreview.Parent = G.charmsColorPickerFrame
corner(G.charmsColorPreview, 4)
stroke(G.charmsColorPreview)

G.espSettingsFrame = Instance.new("Frame")
G.espSettingsFrame.Name = "ESPSettings"
G.espSettingsFrame.Size = UDim2.new(1, 0, 0, 70)
G.espSettingsFrame.BackgroundColor3 = COL.bg
G.espSettingsFrame.LayoutOrder = 6
G.espSettingsFrame.Parent = visTab
corner(G.espSettingsFrame, 8)
stroke(G.espSettingsFrame)

G.espSettingsTitle = Instance.new("TextLabel")
G.espSettingsTitle.Name = "Title"
G.espSettingsTitle.Size = UDim2.new(1, -10, 0, 20)
G.espSettingsTitle.Position = UDim2.new(0, 5, 0, 3)
G.espSettingsTitle.BackgroundTransparency = 1
G.espSettingsTitle.Text = "ESP Settings"
G.espSettingsTitle.TextColor3 = COL.accent
G.espSettingsTitle.TextSize = 11
G.espSettingsTitle.Font = Enum.Font.GothamBold
G.espSettingsTitle.Parent = G.espSettingsFrame

makeDraggable(G.espSettingsFrame, G.espSettingsTitle)

G.espTeamCheckBtn = Instance.new("TextButton")
G.espTeamCheckBtn.Name = "TeamCheck"
G.espTeamCheckBtn.Size = UDim2.new(0, 110, 0, 26)
G.espTeamCheckBtn.Position = UDim2.new(0, 5, 0, 28)
G.espTeamCheckBtn.BackgroundColor3 = COL.toggleOff
G.espTeamCheckBtn.Text = "Team Check: OFF"
G.espTeamCheckBtn.TextColor3 = COL.text
G.espTeamCheckBtn.TextSize = 11
G.espTeamCheckBtn.Font = Enum.Font.GothamSemibold
G.espTeamCheckBtn.Parent = G.espSettingsFrame
corner(G.espTeamCheckBtn, 4)

G.espValCheckFrame = Instance.new("Frame")
G.espValCheckFrame.Name = "ESPValCheck"
G.espValCheckFrame.Size = UDim2.new(1, 0, 0, 90)
G.espValCheckFrame.BackgroundColor3 = COL.bg
G.espValCheckFrame.LayoutOrder = 7
G.espValCheckFrame.Parent = visTab
corner(G.espValCheckFrame, 8)
stroke(G.espValCheckFrame)

G.espValCheckTitle = Instance.new("TextLabel")
G.espValCheckTitle.Name = "Title"
G.espValCheckTitle.Size = UDim2.new(1, -10, 0, 20)
G.espValCheckTitle.Position = UDim2.new(0, 5, 0, 3)
G.espValCheckTitle.BackgroundTransparency = 1
G.espValCheckTitle.Text = "ESP ValCheck"
G.espValCheckTitle.TextColor3 = COL.accent
G.espValCheckTitle.TextSize = 11
G.espValCheckTitle.Font = Enum.Font.GothamBold
G.espValCheckTitle.Parent = G.espValCheckFrame

makeDraggable(G.espValCheckFrame, G.espValCheckTitle)

G.espValCheckScroll = Instance.new("ScrollingFrame")
G.espValCheckScroll.Name = "Scroll"
G.espValCheckScroll.Size = UDim2.new(1, -10, 1, -28)
G.espValCheckScroll.Position = UDim2.new(0, 5, 0, 23)
G.espValCheckScroll.BackgroundTransparency = 1
G.espValCheckScroll.ScrollBarThickness = 3
G.espValCheckScroll.Parent = G.espValCheckFrame

G.espValCheckBtn = Instance.new("TextButton")
G.espValCheckBtn.Name = "ValCheckBtn"
G.espValCheckBtn.Size = UDim2.new(0, 85, 0, 20)
G.espValCheckBtn.Position = UDim2.new(0, 5, 0, 2)
G.espValCheckBtn.BackgroundColor3 = COL.surfaceHover
G.espValCheckBtn.Text = "ValCheck"
G.espValCheckBtn.TextColor3 = COL.text
G.espValCheckBtn.TextSize = 10
G.espValCheckBtn.Font = Enum.Font.GothamSemibold
G.espValCheckBtn.Parent = G.espValCheckFrame
corner(G.espValCheckBtn, 4)

--// ============================================
--// 4. PLAYER TAB
--// ============================================
createToggle(playTab, "Speed", "speedButton", 1)
createSliderRow(playTab, "Speed", "sliderFrame", "sliderButton", "speedInput", 16, 400, 16, 2)
createToggle(playTab, "FOV", "fovButton", 3)
createSliderRow(playTab, "FOV", "fovSliderFrame", "fovSliderButton", "fovInput", 30, 120, 70, 4)
createToggle(playTab, "Fly", "flyButton", 5)
createToggle(playTab, "Noclip", "noclipButton", 6)
createToggle(playTab, "BunnyHop", "bunnyHopButton", 7)
createToggle(playTab, "Infinite Jump", "infiniteJumpButton", 8)

local flyRow = Instance.new("Frame")
flyRow.Size = UDim2.new(1, 0, 0, 32)
flyRow.BackgroundTransparency = 1
flyRow.LayoutOrder = 9
flyRow.Parent = playTab

local flyLbl = Instance.new("TextLabel")
flyLbl.Size = UDim2.new(0.5, 0, 1, 0)
flyLbl.BackgroundTransparency = 1
flyLbl.Text = "Fly Speed"
flyLbl.TextColor3 = COL.text
flyLbl.TextSize = 12
flyLbl.Font = Enum.Font.Gotham
flyLbl.TextXAlignment = Enum.TextXAlignment.Left
flyLbl.Parent = flyRow

G.flyInput = Instance.new("TextBox")
G.flyInput.Name = "FlySpeedInput"
G.flyInput.Size = UDim2.new(0, 65, 0, 26)
G.flyInput.Position = UDim2.new(1, -65, 0.5, -13)
G.flyInput.BackgroundColor3 = COL.bg
G.flyInput.TextColor3 = COL.text
G.flyInput.TextSize = 12
G.flyInput.Font = Enum.Font.Gotham
G.flyInput.PlaceholderText = "50"
G.flyInput.Text = "50"
G.flyInput.Parent = flyRow
corner(G.flyInput, 4)
stroke(G.flyInput)

--// ============================================
--// 5. HITBOXES TAB
--// ============================================
createToggle(hitTab, "Hitbox", "hitboxButton", 1)

local hitSizeRow = Instance.new("Frame")
hitSizeRow.Size = UDim2.new(1, 0, 0, 32)
hitSizeRow.BackgroundTransparency = 1
hitSizeRow.LayoutOrder = 2
hitSizeRow.Parent = hitTab

local hitSizeLbl = Instance.new("TextLabel")
hitSizeLbl.Size = UDim2.new(0.5, 0, 1, 0)
hitSizeLbl.BackgroundTransparency = 1
hitSizeLbl.Text = "Hitbox Size"
hitSizeLbl.TextColor3 = COL.text
hitSizeLbl.TextSize = 12
hitSizeLbl.Font = Enum.Font.Gotham
hitSizeLbl.TextXAlignment = Enum.TextXAlignment.Left
hitSizeLbl.Parent = hitSizeRow

G.hitboxSizeInput = Instance.new("TextBox")
G.hitboxSizeInput.Name = "HitboxSize"
G.hitboxSizeInput.Size = UDim2.new(0, 65, 0, 26)
G.hitboxSizeInput.Position = UDim2.new(1, -65, 0.5, -13)
G.hitboxSizeInput.BackgroundColor3 = COL.bg
G.hitboxSizeInput.TextColor3 = COL.text
G.hitboxSizeInput.TextSize = 12
G.hitboxSizeInput.Font = Enum.Font.Gotham
G.hitboxSizeInput.PlaceholderText = "10"
G.hitboxSizeInput.Text = "10"
G.hitboxSizeInput.Parent = hitSizeRow
corner(G.hitboxSizeInput, 4)
stroke(G.hitboxSizeInput)

createToggle(hitTab, "Head", "hitboxHeadButton", 3)
createToggle(hitTab, "Torso", "hitboxTorsoButton", 4)
createToggle(hitTab, "Arms", "hitboxArmsButton", 5)
createToggle(hitTab, "Legs", "hitboxLegsButton", 6)

G.hitboxSettingsFrame = Instance.new("Frame")
G.hitboxSettingsFrame.Name = "HitboxSettings"
G.hitboxSettingsFrame.Size = UDim2.new(1, 0, 0, 90)
G.hitboxSettingsFrame.BackgroundColor3 = COL.bg
G.hitboxSettingsFrame.LayoutOrder = 7
G.hitboxSettingsFrame.Parent = hitTab
corner(G.hitboxSettingsFrame, 8)
stroke(G.hitboxSettingsFrame)

G.hitboxSettingsTitle = Instance.new("TextLabel")
G.hitboxSettingsTitle.Name = "Title"
G.hitboxSettingsTitle.Size = UDim2.new(1, -10, 0, 22)
G.hitboxSettingsTitle.Position = UDim2.new(0, 5, 0, 4)
G.hitboxSettingsTitle.BackgroundTransparency = 1
G.hitboxSettingsTitle.Text = "Hitbox Settings"
G.hitboxSettingsTitle.TextColor3 = COL.accent
G.hitboxSettingsTitle.TextSize = 12
G.hitboxSettingsTitle.Font = Enum.Font.GothamBold
G.hitboxSettingsTitle.Parent = G.hitboxSettingsFrame

makeDraggable(G.hitboxSettingsFrame, G.hitboxSettingsTitle)

--// ============================================
--// 6. MISC TAB
--// ============================================
createToggle(miscTab, "Fullbright", "fullbrightButton", 1)
createToggle(miscTab, "Anti-AFK", "antiAfkButton", 2)
createToggle(miscTab, "FPS Boost", "fpsBoostButton", 3)
createToggle(miscTab, "PC Trigger", "pcTriggerButton", 4)
createToggle(miscTab, "Mobile Trigger", "mobileTriggerButton", 5)
createToggle(miscTab, "Val Check", "valCheckButton", 6)
createToggle(miscTab, "Trigger WallCheck", "triggerWallCheckButton", 7)
createToggle(miscTab, "Trigger TeamCheck", "triggerTeamCheckButton", 8)
createToggle(miscTab, "Chaos Mode", "chaosModeButton", 9)
createToggle(miscTab, "Sky Changer", "skyButton", 10)

G.teleportFrame = Instance.new("Frame")
G.teleportFrame.Name = "TeleportFrame"
G.teleportFrame.Size = UDim2.new(1, 0, 0, 130)
G.teleportFrame.BackgroundColor3 = COL.bg
G.teleportFrame.LayoutOrder = 11
G.teleportFrame.Parent = miscTab
corner(G.teleportFrame, 8)
stroke(G.teleportFrame)

G.teleportTitle = Instance.new("TextLabel")
G.teleportTitle.Name = "Title"
G.teleportTitle.Size = UDim2.new(1, -10, 0, 20)
G.teleportTitle.Position = UDim2.new(0, 5, 0, 3)
G.teleportTitle.BackgroundTransparency = 1
G.teleportTitle.Text = "Teleport Locations"
G.teleportTitle.TextColor3 = COL.accent
G.teleportTitle.TextSize = 11
G.teleportTitle.Font = Enum.Font.GothamBold
G.teleportTitle.Parent = G.teleportFrame

makeDraggable(G.teleportFrame, G.teleportTitle)

G.teleportScroll = Instance.new("ScrollingFrame")
G.teleportScroll.Name = "Scroll"
G.teleportScroll.Size = UDim2.new(1, -10, 1, -26)
G.teleportScroll.Position = UDim2.new(0, 5, 0, 22)
G.teleportScroll.BackgroundTransparency = 1
G.teleportScroll.ScrollBarThickness = 3
G.teleportScroll.Parent = G.teleportFrame

G.playerSelectFrame = Instance.new("Frame")
G.playerSelectFrame.Name = "PlayerSelect"
G.playerSelectFrame.Size = UDim2.new(1, 0, 0, 130)
G.playerSelectFrame.BackgroundColor3 = COL.bg
G.playerSelectFrame.LayoutOrder = 12
G.playerSelectFrame.Parent = miscTab
corner(G.playerSelectFrame, 8)
stroke(G.playerSelectFrame)

G.playerSelectTitle = Instance.new("TextLabel")
G.playerSelectTitle.Name = "Title"
G.playerSelectTitle.Size = UDim2.new(1, -10, 0, 20)
G.playerSelectTitle.Position = UDim2.new(0, 5, 0, 3)
G.playerSelectTitle.BackgroundTransparency = 1
G.playerSelectTitle.Text = "Select Player"
G.playerSelectTitle.TextColor3 = COL.accent
G.playerSelectTitle.TextSize = 11
G.playerSelectTitle.Font = Enum.Font.GothamBold
G.playerSelectTitle.Parent = G.playerSelectFrame

makeDraggable(G.playerSelectFrame, G.playerSelectTitle)

G.playerSelectScroll = Instance.new("ScrollingFrame")
G.playerSelectScroll.Name = "Scroll"
G.playerSelectScroll.Size = UDim2.new(1, -10, 1, -26)
G.playerSelectScroll.Position = UDim2.new(0, 5, 0, 22)
G.playerSelectScroll.BackgroundTransparency = 1
G.playerSelectScroll.ScrollBarThickness = 3
G.playerSelectScroll.Parent = G.playerSelectFrame

--// ============================================
--// 7. CONFIGS TAB
--// ============================================
G.configFrame = Instance.new("Frame")
G.configFrame.Name = "ConfigPanel"
G.configFrame.Size = UDim2.new(1, 0, 0, 300)
G.configFrame.BackgroundColor3 = COL.bg
G.configFrame.LayoutOrder = 1
G.configFrame.Parent = cfgTab
corner(G.configFrame, 8)
stroke(G.configFrame)
G.configFrame.Visible = false

G.configTitle = Instance.new("TextLabel")
G.configTitle.Name = "Title"
G.configTitle.Size = UDim2.new(1, -10, 0, 24)
G.configTitle.Position = UDim2.new(0, 5, 0, 4)
G.configTitle.BackgroundTransparency = 1
G.configTitle.Text = "Configuration Manager"
G.configTitle.TextColor3 = COL.accent
G.configTitle.TextSize = 13
G.configTitle.Font = Enum.Font.GothamBold
G.configTitle.Parent = G.configFrame

makeDraggable(G.configFrame, G.configTitle)

G.configButton = Instance.new("TextButton")
G.configButton.Name = "OpenConfig"
G.configButton.Size = UDim2.new(0, 130, 0, 28)
G.configButton.Position = UDim2.new(0, 5, 0, 30)
G.configButton.BackgroundColor3 = COL.surfaceHover
G.configButton.Text = "Open Menu"
G.configButton.TextColor3 = COL.text
G.configButton.TextSize = 11
G.configButton.Font = Enum.Font.GothamSemibold
G.configButton.Parent = G.configFrame
corner(G.configButton, 4)

G.configBackButton = Instance.new("TextButton")
G.configBackButton.Name = "Back"
G.configBackButton.Size = UDim2.new(0, 90, 0, 24)
G.configBackButton.Position = UDim2.new(0, 140, 0, 32)
G.configBackButton.BackgroundColor3 = COL.surfaceHover
G.configBackButton.Text = "Back"
G.configBackButton.TextColor3 = COL.text
G.configBackButton.TextSize = 10
G.configBackButton.Font = Enum.Font.GothamSemibold
G.configBackButton.Parent = G.configFrame
corner(G.configBackButton, 4)

G.configScroll = Instance.new("ScrollingFrame")
G.configScroll.Name = "ConfigList"
G.configScroll.Size = UDim2.new(1, -10, 0, 110)
G.configScroll.Position = UDim2.new(0, 5, 0, 64)
G.configScroll.BackgroundColor3 = COL.surface
G.configScroll.ScrollBarThickness = 3
G.configScroll.Parent = G.configFrame
corner(G.configScroll, 4)

G.configNameInput = Instance.new("TextBox")
G.configNameInput.Name = "ConfigName"
G.configNameInput.Size = UDim2.new(1, -10, 0, 28)
G.configNameInput.Position = UDim2.new(0, 5, 0, 180)
G.configNameInput.BackgroundColor3 = COL.surface
G.configNameInput.TextColor3 = COL.text
G.configNameInput.PlaceholderText = "Config name..."
G.configNameInput.Text = ""
G.configNameInput.TextSize = 12
G.configNameInput.Font = Enum.Font.Gotham
G.configNameInput.Parent = G.configFrame
corner(G.configNameInput, 4)
stroke(G.configNameInput)

local cfgBtnRow = Instance.new("Frame")
cfgBtnRow.Size = UDim2.new(1, -10, 0, 30)
cfgBtnRow.Position = UDim2.new(0, 5, 0, 214)
cfgBtnRow.BackgroundTransparency = 1
cfgBtnRow.Parent = G.configFrame

G.saveConfigButton = Instance.new("TextButton")
G.saveConfigButton.Name = "Save"
G.saveConfigButton.Size = UDim2.new(0.32, -4, 1, 0)
G.saveConfigButton.BackgroundColor3 = COL.green
G.saveConfigButton.Text = "Save"
G.saveConfigButton.TextColor3 = COL.text
G.saveConfigButton.TextSize = 11
G.saveConfigButton.Font = Enum.Font.GothamBold
G.saveConfigButton.Parent = cfgBtnRow
corner(G.saveConfigButton, 4)

G.loadConfigButton = Instance.new("TextButton")
G.loadConfigButton.Name = "Load"
G.loadConfigButton.Size = UDim2.new(0.32, -4, 1, 0)
G.loadConfigButton.Position = UDim2.new(0.34, 0, 0, 0)
G.loadConfigButton.BackgroundColor3 = COL.accent
G.loadConfigButton.Text = "Load"
G.loadConfigButton.TextColor3 = COL.text
G.loadConfigButton.TextSize = 11
G.loadConfigButton.Font = Enum.Font.GothamBold
G.loadConfigButton.Parent = cfgBtnRow
corner(G.loadConfigButton, 4)

G.deleteConfigButton = Instance.new("TextButton")
G.deleteConfigButton.Name = "Delete"
G.deleteConfigButton.Size = UDim2.new(0.32, -4, 1, 0)
G.deleteConfigButton.Position = UDim2.new(0.68, 0, 0, 0)
G.deleteConfigButton.BackgroundColor3 = COL.red
G.deleteConfigButton.Text = "Delete"
G.deleteConfigButton.TextColor3 = COL.text
G.deleteConfigButton.TextSize = 11
G.deleteConfigButton.Font = Enum.Font.GothamBold
G.deleteConfigButton.Parent = cfgBtnRow
corner(G.deleteConfigButton, 4)

--// ============================================
--// 8. MOBILE GUI
--// ============================================
G.mobileGui = Instance.new("Frame")
G.mobileGui.Name = "MobileControls"
G.mobileGui.Size = UDim2.new(0, 200, 0, 160)
G.mobileGui.Position = UDim2.new(0, 20, 1, -180)
G.mobileGui.BackgroundColor3 = COL.bg
G.mobileGui.BackgroundTransparency = 0.2
G.mobileGui.Visible = false
G.mobileGui.Parent = G.screenGui
corner(G.mobileGui, 12)
stroke(G.mobileGui)

makeDraggable(G.mobileGui)

local mobTitle = Instance.new("TextLabel")
mobTitle.Size = UDim2.new(1, 0, 0, 22)
mobTitle.BackgroundTransparency = 1
mobTitle.Text = "Mobile"
mobTitle.TextColor3 = COL.text
mobTitle.TextSize = 12
mobTitle.Font = Enum.Font.GothamBold
mobTitle.Parent = G.mobileGui

local function mobBtn(name, pos, size)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = size or UDim2.new(0, 52, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = COL.surfaceHover
    btn.Text = name:gsub("mobile", ""):gsub("Btn", "")
    btn.TextColor3 = COL.text
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.Parent = G.mobileGui
    corner(btn, 6)
    return btn
end

G.mobileWBtn = mobBtn("mobileWBtn", UDim2.new(0.5, -26, 0, 24))
G.mobileSBtn = mobBtn("mobileSBtn", UDim2.new(0.5, -26, 0, 68))
G.mobileABtn = mobBtn("mobileABtn", UDim2.new(0, 8, 0, 46))
G.mobileDBtn = mobBtn("mobileDBtn", UDim2.new(1, -60, 0, 46))
G.mobileSpaceBtn = mobBtn("mobileSpaceBtn", UDim2.new(0.5, -26, 0, 112), UDim2.new(0, 52, 0, 32))
G.mobileWABtn = mobBtn("mobileWABtn", UDim2.new(0, 8, 0, 24), UDim2.new(0, 40, 0, 40))
G.mobileWDBtn = mobBtn("mobileWDBtn", UDim2.new(1, -48, 0, 24), UDim2.new(0, 40, 0, 40))

if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    G.mobileGui.Visible = true
end

--// ============================================
--// VERIFICATION
--// ============================================
local required = {
    "screenGui","frame","titleLabel","minimizedCircle",
    "aimButton","fovCircleButton","wallButton","teamCheckButton","silentAimButton","smoothToggleButton",
    "aimFOVSliderFrame","aimFOVSliderButton","aimFOVInput",
    "smoothSliderFrame","smoothSliderButton","smoothInput",
    "aimSettingsFrame","aimSettingsTitle","aimValCheckFrame","aimValCheckTitle","aimValCheckScroll","aimValCheckButton","aimValCheckBtn",
    "espButton","charmsButton","espTracerBtn","espBoxBtn","espNameBtn","espHealthBtn","espDistBtn",
    "espColorPickerFrame","espColorPickerTitle","espRSlider","espGSlider","espBSlider","espRHandle","espGHandle","espBHandle","espColorPreview",
    "espVisColorBtn","espUnvisColorBtn",
    "charmsSettingsFrame","charmsSettingsTitle","charmsVisBtn","charmsUnvisBtn","charmsNpcBtn","charmsObjBtn",
    "charmsColorPickerFrame","charmsColorPickerTitle","charmsRSlider","charmsGSlider","charmsBSlider","charmsRHandle","charmsGHandle","charmsBHandle","charmsColorPreview",
    "espSettingsFrame","espSettingsTitle","espValCheckFrame","espValCheckTitle","espValCheckScroll","espTeamCheckBtn","espValCheckBtn",
    "speedButton","fovButton","flyButton","noclipButton","bunnyHopButton","infiniteJumpButton",
    "sliderFrame","sliderButton","speedInput","fovSliderFrame","fovSliderButton","fovInput","flyInput",
    "hitboxButton","hitboxSizeInput","hitboxHeadButton","hitboxTorsoButton","hitboxArmsButton","hitboxLegsButton","hitboxSettingsFrame","hitboxSettingsTitle",
    "fullbrightButton","antiAfkButton","fpsBoostButton","pcTriggerButton","mobileTriggerButton",
    "valCheckButton","triggerWallCheckButton","triggerTeamCheckButton","chaosModeButton","skyButton",
    "teleportFrame","teleportTitle","teleportScroll","playerSelectFrame","playerSelectScroll","playerSelectTitle",
    "configFrame","configTitle","configButton","configBackButton","configScroll","configNameInput",
    "saveConfigButton","loadConfigButton","deleteConfigButton",
    "mobileGui","mobileWBtn","mobileABtn","mobileSBtn","mobileDBtn","mobileSpaceBtn","mobileWABtn","mobileWDBtn"
}

print("[Smile GUI] Verifying G table...")
local missing = {}
for _, key in ipairs(required) do
    if G[key] == nil then
        table.insert(missing, key)
    end
end

if #missing > 0 then
    warn("[Smile GUI] MISSING: " .. table.concat(missing, ", "))
else
    print("[Smile GUI] All G elements verified ✓")
    print("[Smile GUI] Ready for backend. Load functions.lua next.")
end
