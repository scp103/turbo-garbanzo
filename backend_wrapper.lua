--// Smile Mod Menu — Backend Wrapper v2.0
--// Connects all G buttons to finxion.lua functions
--// Load AFTER gui.lua (G must exist)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

--// Verify G exists
if not getgenv().G or not getgenv().G.screenGui then
    error("[Smile Backend] G not found! Load GUI first.")
    return
end

local G = getgenv().G

--// ============================================
--// LOAD ORIGINAL BACKEND (funxion.lua from GitHub)
--// ============================================
-- ЗАМІНИ ЦЕЙ URL НА СВІЙ (raw GitHub або Pastebin raw)
local BACKEND_URL = "https://raw.githubusercontent.com/scp103/turbo-garbanzo/main/funxion.lua"

print("[Smile Backend] Loading from: " .. BACKEND_URL)

local success, backendCode = pcall(function()
    return game:HttpGet(BACKEND_URL, true)
end)

if not success then
    warn("[Smile Backend] HttpGet failed: " .. tostring(backendCode))
    return
end

-- Debug: show first 100 chars to verify it's Lua, not HTML
print("[Smile Backend] First 100 chars: " .. string.sub(backendCode, 1, 100))

if string.sub(backendCode, 1, 1) == "<" then
    warn("[Smile Backend] ERROR: Got HTML instead of Lua code! Check the URL.")
    warn("[Smile Backend] Make sure you're using RAW github URL (raw.githubusercontent.com)")
    return
end

local backendFunc, compileErr = loadstring(backendCode, "funxion.lua")
if not backendFunc then
    warn("[Smile Backend] Failed to parse: " .. tostring(compileErr))
    return
end

print("[Smile Backend] Code parsed successfully")

--// Initialize backend — call init(G, {})
local initOk, initResult = pcall(function()
    return backendFunc()
end)

if not initOk then
    warn("[Smile Backend] init() error: " .. tostring(initResult))
    return
end

if type(initResult) ~= "function" then
    warn("[Smile Backend] Expected init() to return a function, got: " .. type(initResult))
    return
end

print("[Smile Backend] init() function returned, calling with G...")

local funcsOk, funcs = pcall(function()
    return initResult(G, {})
end)

if not funcsOk then
    warn("[Smile Backend] init(G,{}) error: " .. tostring(funcs))
    return
end

if type(funcs) ~= "table" then
    warn("[Smile Backend] Expected table of functions, got: " .. type(funcs))
    return
end

print("[Smile Backend] Functions loaded successfully ✓")

--// ============================================
--// BUTTON CONNECTOR
--// ============================================

local function styleToggle(btn, state)
    if not btn then return end
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

--// AIMBOT
bindToggle(G.aimButton, funcs.getHolding, funcs.setHolding, "AIM")
bindToggle(G.fovCircleButton, funcs.getFovCircle, funcs.setFovCircle, "FOV Circle")
bindToggle(G.wallButton, funcs.getWallCheck, funcs.setWallCheck, "WallCheck")
bindToggle(G.teamCheckButton, funcs.getTeamCheck, funcs.setTeamCheck, "Team Check")
bindToggle(G.silentAimButton, funcs.getSilentAim, funcs.setSilentAim, "Silent Aim")
bindToggle(G.smoothToggleButton, funcs.getSmoothToggle, funcs.setSmoothToggle, "Smooth")

--// VISUALS
bindToggle(G.espButton, funcs.getEsp, funcs.setEsp, "ESP")
bindToggle(G.charmsButton, funcs.getCharms, funcs.setCharms, "Charms")
bindToggle(G.espTracerBtn, funcs.getEspShowTracer, funcs.setEspShowTracer, "Tracer")
bindToggle(G.espBoxBtn, funcs.getEspShowBox, funcs.setEspShowBox, "Box")
bindToggle(G.espNameBtn, funcs.getEspShowName, funcs.setEspShowName, "Name")
bindToggle(G.espHealthBtn, funcs.getEspShowHealth, funcs.setEspShowHealth, "Health")
bindToggle(G.espDistBtn, funcs.getEspShowDist, funcs.setEspShowDist, "Distance")
bindToggle(G.charmsNpcBtn, funcs.getCharmsNpc, funcs.setCharmsNpc, "NPC ESP")
bindToggle(G.charmsObjBtn, funcs.getCharmsEspObj, funcs.setCharmsEspObj, "Object ESP")

if G.espTeamCheckBtn then
    bindToggle(G.espTeamCheckBtn, funcs.getEspTeamCheck, funcs.setEspTeamCheck, "Team Check")
end

--// PLAYER
bindToggle(G.speedButton, funcs.getSpeed, funcs.setSpeed, "Speed")
bindToggle(G.fovButton, funcs.getFovChanger, funcs.setFovChanger, "FOV")
bindToggle(G.flyButton, funcs.getFly, funcs.setFly, "Fly")
bindToggle(G.noclipButton, funcs.getNoclip, funcs.setNoclip, "Noclip")
bindToggle(G.bunnyHopButton, funcs.getBunnyHop, funcs.setBunnyHop, "BunnyHop")
bindToggle(G.infiniteJumpButton, funcs.getInfiniteJump, funcs.setInfiniteJump, "Infinite Jump")

--// HITBOX
bindToggle(G.hitboxButton, funcs.getHitbox, funcs.setHitbox, "Hitbox")

local function setHitboxPart(part)
    pcall(function() funcs.setHitboxPart(part) end)
    local buttons = {G.hitboxHeadButton, G.hitboxTorsoButton, G.hitboxArmsButton, G.hitboxLegsButton}
    for _, btn in ipairs(buttons) do
        if btn then btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
    end
    if part == "Head" and G.hitboxHeadButton then G.hitboxHeadButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    elseif part == "Torso" and G.hitboxTorsoButton then G.hitboxTorsoButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    elseif part == "Arms" and G.hitboxArmsButton then G.hitboxArmsButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    elseif part == "Legs" and G.hitboxLegsButton then G.hitboxLegsButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) end
end

if G.hitboxHeadButton then G.hitboxHeadButton.MouseButton1Click:Connect(function() setHitboxPart("Head") end) end
if G.hitboxTorsoButton then G.hitboxTorsoButton.MouseButton1Click:Connect(function() setHitboxPart("Torso") end) end
if G.hitboxArmsButton then G.hitboxArmsButton.MouseButton1Click:Connect(function() setHitboxPart("Arms") end) end
if G.hitboxLegsButton then G.hitboxLegsButton.MouseButton1Click:Connect(function() setHitboxPart("Legs") end) end

--// MISC
bindToggle(G.fullbrightButton, funcs.getFullbright, funcs.setFullbright, "Fullbright")
bindToggle(G.antiAfkButton, funcs.getAntiAfk, funcs.setAntiAfk, "Anti-AFK")
bindToggle(G.fpsBoostButton, funcs.getFpsBoost, funcs.setFpsBoost, "FPS Boost")
bindToggle(G.pcTriggerButton, funcs.getPCTrigger, funcs.setPCTrigger, "PC Trigger")
bindToggle(G.mobileTriggerButton, funcs.getMobileTrigger, funcs.setMobileTrigger, "Mobile Trigger")
bindToggle(G.valCheckButton, funcs.getValCheck, funcs.setValCheck, "Val Check")
bindToggle(G.triggerWallCheckButton, funcs.getTriggerWallCheck, funcs.setTriggerWallCheck, "WallCheck")
bindToggle(G.triggerTeamCheckButton, funcs.getTriggerTeamCheck, funcs.setTriggerTeamCheck, "TeamCheck")
bindToggle(G.chaosModeButton, funcs.getChaos, funcs.setChaos, "Chaos Mode")

if G.skyButton then
    G.skyButton.MouseButton1Click:Connect(function()
        pcall(function() funcs.changeSky() end)
    end)
end

--// VALCHECK
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
    G.valCheckButton.MouseButton1Click:Connect(function()
        pcall(function() funcs.updatePlayerSelectList() end)
    end)
end

--// CONFIG
if G.configButton then
    G.configButton.MouseButton1Click:Connect(function()
        G.frame.Visible = false
        if G.aimSettingsFrame then G.aimSettingsFrame.Visible = false end
        if G.hitboxSettingsFrame then G.hitboxSettingsFrame.Visible = false end
        G.configFrame.Visible = true
        if funcs.updateConfigList then pcall(function() funcs.updateConfigList() end) end
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
        if funcs.updateConfigList then pcall(function() funcs.updateConfigList() end) end
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
        if funcs.updateConfigList then pcall(function() funcs.updateConfigList() end) end
    end)
end

--// TEXT INPUTS
if G.flyInput then
    G.flyInput.FocusLost:Connect(function()
        local v = tonumber(G.flyInput.Text)
        if v and funcs.setFlySpeed then pcall(function() funcs.setFlySpeed(v) end) end
    end)
end

if G.fovInput then
    G.fovInput.FocusLost:Connect(function()
        local v = tonumber(G.fovInput.Text)
        if v and funcs.setFOV then pcall(function() funcs.setFOV(v) end) end
    end)
end

if G.aimFOVInput then
    G.aimFOVInput.FocusLost:Connect(function()
        local v = tonumber(G.aimFOVInput.Text)
        if v and funcs.setAimFOV then pcall(function() funcs.setAimFOV(v) end) end
    end)
end

if G.smoothInput then
    G.smoothInput.FocusLost:Connect(function()
        local v = tonumber(G.smoothInput.Text)
        if v and funcs.setSmoothValue then pcall(function() funcs.setSmoothValue(v) end) end
    end)
end

if G.hitboxSizeInput then
    G.hitboxSizeInput.FocusLost:Connect(function()
        local v = tonumber(G.hitboxSizeInput.Text)
        if v and funcs.setHitboxSize then pcall(function() funcs.setHitboxSize(v) end) end
    end)
end

--// COLOR PICKERS
if G.espVisColorBtn and funcs.setEspColorTarget then
    G.espVisColorBtn.MouseButton1Click:Connect(function() pcall(function() funcs.setEspColorTarget("vis") end) end)
end
if G.espUnvisColorBtn and funcs.setEspColorTarget then
    G.espUnvisColorBtn.MouseButton1Click:Connect(function() pcall(function() funcs.setEspColorTarget("unvis") end) end)
end
if G.charmsVisBtn and funcs.openCharmsColorPicker then
    G.charmsVisBtn.MouseButton1Click:Connect(function() pcall(function() funcs.openCharmsColorPicker("vis") end) end)
end
if G.charmsUnvisBtn and funcs.openCharmsColorPicker then
    G.charmsUnvisBtn.MouseButton1Click:Connect(function() pcall(function() funcs.openCharmsColorPicker("unvis") end) end)
end

--// MOBILE
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

--// INIT STATE
local function initBtn(btn, getter, label)
    if not btn or not getter then return end
    local ok, state = pcall(getter)
    if ok then
        btn.Text = label .. ": " .. (state and "ON" or "OFF")
        styleToggle(btn, state)
    end
end

initBtn(G.aimButton, funcs.getHolding, "AIM")
initBtn(G.fovCircleButton, funcs.getFovCircle, "FOV Circle")
initBtn(G.wallButton, funcs.getWallCheck, "WallCheck")
initBtn(G.teamCheckButton, funcs.getTeamCheck, "Team Check")
initBtn(G.silentAimButton, funcs.getSilentAim, "Silent Aim")
initBtn(G.smoothToggleButton, funcs.getSmoothToggle, "Smooth")
initBtn(G.espButton, funcs.getEsp, "ESP")
initBtn(G.charmsButton, funcs.getCharms, "Charms")
initBtn(G.speedButton, funcs.getSpeed, "Speed")
initBtn(G.fovButton, funcs.getFovChanger, "FOV")
initBtn(G.flyButton, funcs.getFly, "Fly")
initBtn(G.noclipButton, funcs.getNoclip, "Noclip")
initBtn(G.bunnyHopButton, funcs.getBunnyHop, "BunnyHop")
initBtn(G.infiniteJumpButton, funcs.getInfiniteJump, "Infinite Jump")
initBtn(G.hitboxButton, funcs.getHitbox, "Hitbox")
initBtn(G.fullbrightButton, funcs.getFullbright, "Fullbright")
initBtn(G.antiAfkButton, funcs.getAntiAfk, "Anti-AFK")
initBtn(G.fpsBoostButton, funcs.getFpsBoost, "FPS Boost")
initBtn(G.pcTriggerButton, funcs.getPCTrigger, "PC Trigger")
initBtn(G.mobileTriggerButton, funcs.getMobileTrigger, "Mobile Trigger")
initBtn(G.valCheckButton, funcs.getValCheck, "Val Check")
initBtn(G.triggerWallCheckButton, funcs.getTriggerWallCheck, "WallCheck")
initBtn(G.triggerTeamCheckButton, funcs.getTriggerTeamCheck, "TeamCheck")
initBtn(G.chaosModeButton, funcs.getChaos, "Chaos Mode")

print("[Smile Backend] All buttons connected ✓")
print("[Smile Backend] Mod Menu fully operational!")
