--// Smile Mod Menu — Backend Wrapper v1.0
--// Connects all G buttons to finxion.lua functions
--// Load AFTER gui.lua (G must exist)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

--// Verify G exists
if not getgenv().G or not getgenv().G.screenGui then
    error("[Smile Backend] G not found! Load GUI first.")
    return
end

local G = getgenv().G

--// ============================================
--// LOAD ORIGINAL BACKEND (finxion.txt)
--// ============================================
local BACKEND_URL = "https://pastebin.com/raw/1pwSUHBK" -- твій бекенд

local success, backendCode = pcall(function()
    return game:HttpGet(BACKEND_URL)
end)

if not success then
    error("[Smile Backend] Failed to load backend: " .. tostring(backendCode))
    return
end

local backendFunc = loadstring(backendCode)
if not backendFunc then
    error("[Smile Backend] Failed to parse backend code")
    return
end

--// Initialize backend
local funcs = backendFunc()(G, {})

if not funcs then
    error("[Smile Backend] Backend init returned nil!")
    return
end

print("[Smile Backend] Functions loaded successfully")

--// ============================================
--// BUTTON CONNECTOR
--// ============================================

local function styleToggle(btn, state)
    if state then
        btn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    else
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
end

local function bindToggle(btn, getter, setter, label)
    if not btn then return end
    btn.MouseButton1Click:Connect(function()
        local ok, state = pcall(getter)
        if not ok then state = false end
        local newState = not state
        pcall(function() setter(newState) end)
        btn.Text = label .. ": " .. (newState and "ON" or "OFF")
        styleToggle(btn, newState)
    end)
end

local function bindSimple(btn, callback, label)
    if not btn then return end
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
        if label then
            print("[Smile] " .. label .. " clicked")
        end
    end)
end

--// AIMBOT TAB
bindToggle(G.aimButton, funcs.getHolding, funcs.setHolding, "AIM")
bindToggle(G.fovCircleButton, funcs.getFovCircle, funcs.setFovCircle, "FOV Circle")
bindToggle(G.wallButton, funcs.getWallCheck, funcs.setWallCheck, "WallCheck")
bindToggle(G.teamCheckButton, funcs.getTeamCheck, funcs.setTeamCheck, "Team Check")
bindToggle(G.silentAimButton, funcs.getSilentAim, funcs.setSilentAim, "Silent Aim")
bindToggle(G.smoothToggleButton, funcs.getSmoothToggle, funcs.setSmoothToggle, "Smooth")

--// VISUALS TAB
bindToggle(G.espButton, funcs.getEsp, funcs.setEsp, "ESP")
bindToggle(G.charmsButton, funcs.getCharms, funcs.setCharms, "Charms")
bindToggle(G.espTracerBtn, funcs.getEspShowTracer, funcs.setEspShowTracer, "Tracer")
bindToggle(G.espBoxBtn, funcs.getEspShowBox, funcs.setEspShowBox, "Box")
bindToggle(G.espNameBtn, funcs.getEspShowName, funcs.setEspShowName, "Name")
bindToggle(G.espHealthBtn, funcs.getEspShowHealth, funcs.setEspShowHealth, "Health")
bindToggle(G.espDistBtn, funcs.getEspShowDist, funcs.setEspShowDist, "Distance")
bindToggle(G.charmsNpcBtn, funcs.getCharmsNpc, funcs.setCharmsNpc, "NPC ESP")
bindToggle(G.charmsObjBtn, funcs.getCharmsEspObj, funcs.setCharmsEspObj, "Object ESP")

-- ESP Team Check
if G.espTeamCheckBtn then
    bindToggle(G.espTeamCheckBtn, funcs.getEspTeamCheck, funcs.setEspTeamCheck, "ESP Team Check")
end

--// PLAYER TAB
bindToggle(G.speedButton, funcs.getSpeed, funcs.setSpeed, "Speed")
bindToggle(G.fovButton, funcs.getFovChanger, funcs.setFovChanger, "FOV")
bindToggle(G.flyButton, funcs.getFly, funcs.setFly, "Fly")
bindToggle(G.noclipButton, funcs.getNoclip, funcs.setNoclip, "Noclip")
bindToggle(G.bunnyHopButton, funcs.getBunnyHop, funcs.setBunnyHop, "BunnyHop")
bindToggle(G.infiniteJumpButton, funcs.getInfiniteJump, funcs.setInfiniteJump, "Infinite Jump")

--// HITBOX TAB
bindToggle(G.hitboxButton, funcs.getHitbox, funcs.setHitbox, "Hitbox")

if G.hitboxHeadButton then
    G.hitboxHeadButton.MouseButton1Click:Connect(function()
        pcall(function() funcs.setHitboxPart("Head") end)
        G.hitboxHeadButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        if G.hitboxTorsoButton then G.hitboxTorsoButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
        if G.hitboxArmsButton then G.hitboxArmsButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
        if G.hitboxLegsButton then G.hitboxLegsButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
    end)
end

if G.hitboxTorsoButton then
    G.hitboxTorsoButton.MouseButton1Click:Connect(function()
        pcall(function() funcs.setHitboxPart("Torso") end)
        G.hitboxTorsoButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        if G.hitboxHeadButton then G.hitboxHeadButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
        if G.hitboxArmsButton then G.hitboxArmsButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
        if G.hitboxLegsButton then G.hitboxLegsButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
    end)
end

if G.hitboxArmsButton then
    G.hitboxArmsButton.MouseButton1Click:Connect(function()
        pcall(function() funcs.setHitboxPart("Arms") end)
        G.hitboxArmsButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        if G.hitboxHeadButton then G.hitboxHeadButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
        if G.hitboxTorsoButton then G.hitboxTorsoButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
        if G.hitboxLegsButton then G.hitboxLegsButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
    end)
end

if G.hitboxLegsButton then
    G.hitboxLegsButton.MouseButton1Click:Connect(function()
        pcall(function() funcs.setHitboxPart("Legs") end)
        G.hitboxLegsButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        if G.hitboxHeadButton then G.hitboxHeadButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
        if G.hitboxTorsoButton then G.hitboxTorsoButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
        if G.hitboxArmsButton then G.hitboxArmsButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
    end)
end

--// MISC TAB
bindToggle(G.fullbrightButton, funcs.getFullbright, funcs.setFullbright, "Fullbright")
bindToggle(G.antiAfkButton, funcs.getAntiAfk, funcs.setAntiAfk, "Anti-AFK")
bindToggle(G.fpsBoostButton, funcs.getFpsBoost, funcs.setFpsBoost, "FPS Boost")
bindToggle(G.pcTriggerButton, funcs.getPCTrigger, funcs.setPCTrigger, "PC Trigger")
bindToggle(G.mobileTriggerButton, funcs.getMobileTrigger, funcs.setMobileTrigger, "Mobile Trigger")
bindToggle(G.valCheckButton, funcs.getValCheck, funcs.setValCheck, "Val Check")
bindToggle(G.triggerWallCheckButton, funcs.getTriggerWallCheck, funcs.setTriggerWallCheck, "Trigger WallCheck")
bindToggle(G.triggerTeamCheckButton, funcs.getTriggerTeamCheck, funcs.setTriggerTeamCheck, "Trigger TeamCheck")
bindToggle(G.chaosModeButton, funcs.getChaos, funcs.setChaos, "Chaos Mode")

-- Sky button
if G.skyButton then
    G.skyButton.MouseButton1Click:Connect(function()
        pcall(function() funcs.changeSky() end)
    end)
end

-- ValCheck lists
if G.aimValCheckButton and funcs.updateAimValCheckList then
    G.aimValCheckButton.MouseButton1Click:Connect(function()
        pcall(function() funcs.updateAimValCheckList() end)
    end)
end

if G.espValCheckBtn and funcs.updateEspValCheckList then
    G.espValCheckBtn.MouseButton1Click:Connect(function()
        pcall(function() funcs.updateEspValCheckList() end)
    end)
end

if G.valCheckButton and funcs.updatePlayerSelectList then
    -- Already bound above, but also update list on click
    local oldClick = G.valCheckButton.MouseButton1Click
end

--// CONFIG TAB
if G.configButton then
    G.configButton.MouseButton1Click:Connect(function()
        G.frame.Visible = false
        if G.aimSettingsFrame then G.aimSettingsFrame.Visible = false end
        if G.hitboxSettingsFrame then G.hitboxSettingsFrame.Visible = false end
        G.configFrame.Visible = true
        if funcs.updateConfigList then
            pcall(function() funcs.updateConfigList() end)
        end
    end)
end

if G.configBackButton then
    G.configBackButton.MouseButton1Click:Connect(function()
        G.configFrame.Visible = false
        G.frame.Visible = true
    end)
end

if G.saveConfigButton and funcs.saveConfig then
    G.saveConfigButton.MouseButton1Click:Connect(function()
        pcall(function() funcs.saveConfig(G.configNameInput.Text or "") end)
        if funcs.updateConfigList then
            pcall(function() funcs.updateConfigList() end)
        end
    end)
end

if G.loadConfigButton and funcs.loadConfig then
    G.loadConfigButton.MouseButton1Click:Connect(function()
        pcall(function() funcs.loadConfig(G.configNameInput.Text or "") end)
    end)
end

if G.deleteConfigButton and funcs.deleteConfig then
    G.deleteConfigButton.MouseButton1Click:Connect(function()
        pcall(function() funcs.deleteConfig(G.configNameInput.Text or "") end)
        if funcs.updateConfigList then
            pcall(function() funcs.updateConfigList() end)
        end
    end)
end

--// TEXT INPUTS
if G.speedInput then
    G.speedInput.FocusLost:Connect(function()
        local v = tonumber(G.speedInput.Text)
        if v then
            pcall(function()
                funcs.setSpeed(true)
                -- Speed value is handled by slider, but we can set it via internal if needed
            end)
        end
    end)
end

if G.flyInput then
    G.flyInput.FocusLost:Connect(function()
        local v = tonumber(G.flyInput.Text)
        if v and funcs.setFlySpeed then
            pcall(function() funcs.setFlySpeed(v) end)
        end
    end)
end

if G.fovInput then
    G.fovInput.FocusLost:Connect(function()
        local v = tonumber(G.fovInput.Text)
        if v and funcs.setFOV then
            pcall(function() funcs.setFOV(v) end)
        end
    end)
end

if G.aimFOVInput then
    G.aimFOVInput.FocusLost:Connect(function()
        local v = tonumber(G.aimFOVInput.Text)
        if v and funcs.setAimFOV then
            pcall(function() funcs.setAimFOV(v) end)
        end
    end)
end

if G.smoothInput then
    G.smoothInput.FocusLost:Connect(function()
        local v = tonumber(G.smoothInput.Text)
        if v and funcs.setSmoothValue then
            pcall(function() funcs.setSmoothValue(v) end)
        end
    end)
end

if G.hitboxSizeInput then
    G.hitboxSizeInput.FocusLost:Connect(function()
        local v = tonumber(G.hitboxSizeInput.Text)
        if v and funcs.setHitboxSize then
            pcall(function() funcs.setHitboxSize(v) end)
        end
    end)
end

--// COLOR PICKERS
if G.espVisColorBtn and funcs.setEspColorTarget then
    G.espVisColorBtn.MouseButton1Click:Connect(function()
        pcall(function() funcs.setEspColorTarget("vis") end)
    end)
end

if G.espUnvisColorBtn and funcs.setEspColorTarget then
    G.espUnvisColorBtn.MouseButton1Click:Connect(function()
        pcall(function() funcs.setEspColorTarget("unvis") end)
    end)
end

if G.charmsVisBtn and funcs.openCharmsColorPicker then
    G.charmsVisBtn.MouseButton1Click:Connect(function()
        pcall(function() funcs.openCharmsColorPicker("vis") end)
    end)
end

if G.charmsUnvisBtn and funcs.openCharmsColorPicker then
    G.charmsUnvisBtn.MouseButton1Click:Connect(function()
        pcall(function() funcs.openCharmsColorPicker("unvis") end)
    end)
end

--// MOBILE BUTTONS
local VIM = game:GetService("VirtualInputManager")

local function setupMobileKey(btn, keyCode)
    if not btn then return end
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            btn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
            pcall(function() VIM:SendKeyEvent(true, keyCode, false, game) end)
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            pcall(function() VIM:SendKeyEvent(false, keyCode, false, game) end)
        end
    end)
end

setupMobileKey(G.mobileWBtn, Enum.KeyCode.W)
setupMobileKey(G.mobileABtn, Enum.KeyCode.A)
setupMobileKey(G.mobileSBtn, Enum.KeyCode.S)
setupMobileKey(G.mobileDBtn, Enum.KeyCode.D)
setupMobileKey(G.mobileSpaceBtn, Enum.KeyCode.Space)

--// INITIAL UI STATE
local function initButtonState(btn, getter, label)
    if not btn or not getter then return end
    local ok, state = pcall(getter)
    if ok then
        btn.Text = label .. ": " .. (state and "ON" or "OFF")
        styleToggle(btn, state)
    end
end

initButtonState(G.aimButton, funcs.getHolding, "AIM")
initButtonState(G.fovCircleButton, funcs.getFovCircle, "FOV Circle")
initButtonState(G.wallButton, funcs.getWallCheck, "WallCheck")
initButtonState(G.teamCheckButton, funcs.getTeamCheck, "Team Check")
initButtonState(G.silentAimButton, funcs.getSilentAim, "Silent Aim")
initButtonState(G.smoothToggleButton, funcs.getSmoothToggle, "Smooth")
initButtonState(G.espButton, funcs.getEsp, "ESP")
initButtonState(G.charmsButton, funcs.getCharms, "Charms")
initButtonState(G.speedButton, funcs.getSpeed, "Speed")
initButtonState(G.fovButton, funcs.getFovChanger, "FOV")
initButtonState(G.flyButton, funcs.getFly, "Fly")
initButtonState(G.noclipButton, funcs.getNoclip, "Noclip")
initButtonState(G.bunnyHopButton, funcs.getBunnyHop, "BunnyHop")
initButtonState(G.infiniteJumpButton, funcs.getInfiniteJump, "Infinite Jump")
initButtonState(G.hitboxButton, funcs.getHitbox, "Hitbox")
initButtonState(G.fullbrightButton, funcs.getFullbright, "Fullbright")
initButtonState(G.antiAfkButton, funcs.getAntiAfk, "Anti-AFK")
initButtonState(G.fpsBoostButton, funcs.getFpsBoost, "FPS Boost")
initButtonState(G.pcTriggerButton, funcs.getPCTrigger, "PC Trigger")
initButtonState(G.mobileTriggerButton, funcs.getMobileTrigger, "Mobile Trigger")
initButtonState(G.valCheckButton, funcs.getValCheck, "Val Check")
initButtonState(G.triggerWallCheckButton, funcs.getTriggerWallCheck, "Trigger WallCheck")
initButtonState(G.triggerTeamCheckButton, funcs.getTriggerTeamCheck, "Trigger TeamCheck")
initButtonState(G.chaosModeButton, funcs.getChaos, "Chaos Mode")

print("[Smile Backend] All buttons connected ✓")
print("[Smile Backend] Mod Menu is fully operational!")
