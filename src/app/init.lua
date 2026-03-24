--!strict
--[[
    SACRAMENT | TriggerBot Master Controller
    Lê o alvo exato sob a mira. Sistema de Bind blindado (Suporta MouseButton2 nativamente).
]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local Import = (_G :: any).SacramentImport
local Telemetry = Import("logic/core/telemetry")
local UIState   = Import("state/uistate")
local Loop      = Import("logic/core/loop")

local function SafeImport(path: string)
    local success, result = pcall(function() return Import(path) end)
    return success and result or nil
end
local KnockCheck = SafeImport("logic/func/combat/shared/knockcheck")

local TriggerBot = {}
local isInitialized = false

-- Chaves de Estado da UI
local KEY_ENABLED     = "TriggerBotEnabled"
local KEY_BIND        = "TriggerBot_Keybind"
local KEY_DELAY       = "TriggerBot_Delay"
local KEY_HIT_CHANCE  = "TriggerBot_HitChance"
local KEY_KNOCK_CHECK = "TriggerBot_KnockCheck"

-- Variáveis de Controle
local isTriggerBotActive = false 
local hoverStartTime = 0
local lastClickTime = 0
local isHovering = false

local function GetToggleState(key: string, default: boolean): boolean
    local val = UIState.Get(key, default)
    if val == "false" or val == 0 then return false end
    if val == "true" or val == 1 then return true end
    return val == true
end

-- ==========================================
-- NOTIFICAÇÃO VISUAL (Pop-up do Roblox)
-- ==========================================
local function SendNotification(message: string)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "SACRAMENT",
            Text = message,
            Duration = 2, 
            Icon = "rbxassetid://6023426923" 
        })
    end)
end

-- ==========================================
-- LÓGICA DE DETECÇÃO (Pixel-Perfect)
-- ==========================================
local function GetTargetInCrosshair(): Model?
    local localPlayer = Players.LocalPlayer
    if not localPlayer then return nil end

    -- Mouse.Target é 100% preciso, ignorando a barra invisível da UI.
    local mouse = localPlayer:GetMouse()
    local targetPart = mouse.Target

    if targetPart then
        local character = targetPart:FindFirstAncestorOfClass("Model")
        
        if character then
            local hum = character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local player = Players:GetPlayerFromCharacter(character)
                
                if player and player ~= localPlayer then
                    if GetToggleState(KEY_KNOCK_CHECK, false) and KnockCheck then
                        if KnockCheck.IsKnocked(player) then return nil end
                    end
                    return character
                end
            end
        end
    end
    return nil
end

-- ==========================================
-- O GATILHO (Simulação de Clique)
-- ==========================================
local function FireWeapon()
    if type(mouse1press) == "function" and type(mouse1release) == "function" then
        mouse1press()
        task.wait(0.01)
        mouse1release()
    elseif type(mouse1click) == "function" then
        mouse1click()
    else
        Telemetry.Log("ERROR", "TriggerBot", "Executor não suporta simulação de clique.")
    end
end

-- ==========================================
-- CICLO DE VIDA DO TRIGGERBOT
-- ==========================================
function TriggerBot.Init()
    if isInitialized then return "initialized" end

    -- 1. SISTEMA DE KEYBIND BLINDADO (Aceita MouseButton2 perfeitamente)
    TriggerBot._inputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
        -- Ignora apenas se for o chat (Teclado) com GPE. Permite cliques do Rato sempre.
        if gpe and not string.find(input.UserInputType.Name, "MouseButton") then return end
        
        local bind = tostring(UIState.Get(KEY_BIND, "None"))
        if bind == "None" or bind == "" then return end

        -- Verifica se a tecla/botão apertado é igual ao da UI
        if input.KeyCode.Name == bind or input.UserInputType.Name == bind then
            isTriggerBotActive = not isTriggerBotActive
            
            -- Sincroniza com a UI e mostra a notificação visual
            UIState.Set(KEY_ENABLED, isTriggerBotActive)
            if isTriggerBotActive then
                SendNotification("Triggerbot ON")
            else
                SendNotification("Triggerbot OFF")
            end
        end
    end)

    isTriggerBotActive = GetToggleState(KEY_ENABLED, false)

    -- 2. LOOP DE DETECÇÃO E DISPARO
    Loop.BindToRender("TriggerBot_Controller", function()
        if not isTriggerBotActive then 
            isHovering = false
            hoverStartTime = 0
            return 
        end

        local target = GetTargetInCrosshair()

        if target then
            if not isHovering then
                isHovering = true
                hoverStartTime = tick()
            end

            local delayTime = tonumber(UIState.Get(KEY_DELAY, 0.00)) or 0.00
            local timeHovering = tick() - hoverStartTime

            if timeHovering >= delayTime then
                -- Limite de cadência (Evita crashar o executor com cliques infinitos)
                if tick() - lastClickTime >= 0.05 then
                    lastClickTime = tick()
                    
                    local hitChance = tonumber(UIState.Get(KEY_HIT_CHANCE, 100)) or 100
                    if math.random(1, 100) <= hitChance then
                        FireWeapon()
                    end
                end
            end
        else
            if isHovering then
                isHovering = false
                hoverStartTime = 0
            end
        end
    end)

    isInitialized = true
    Telemetry.Log("LITURGY", "TriggerBot", "Módulo Iniciado com sucesso.")
    return "initialized"
end

function TriggerBot.Destroy()
    if not isInitialized then return end
    Loop.UnbindFromRender("TriggerBot_Controller")
    if TriggerBot._inputBegan then TriggerBot._inputBegan:Disconnect() end
    isHovering = false
    hoverStartTime = 0
    isTriggerBotActive = false
    isInitialized = false
end

return TriggerBot
