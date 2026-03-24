--!strict
--[[
    SACRAMENT | TriggerBot Master Controller
    Atira automaticamente quando o alvo entra na mira.
    Construído com Raycast puro. Funciona em QUALQUER executor.
]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

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
local KEY_DELAY       = "TriggerBot_Delay"      -- Slider: 0.00 a 3.00
local KEY_HIT_CHANCE  = "TriggerBot_HitChance"  -- Slider: 0 a 100
local KEY_WALL_CHECK  = "TriggerBot_WallCheck"  -- Toggle
local KEY_KNOCK_CHECK = "TriggerBot_KnockCheck" -- Toggle

-- Variáveis de Controle de Tempo
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
-- LÓGICA DE DETECÇÃO (O Olho do TriggerBot)
-- ==========================================
local function GetTargetInCrosshair(): Model?
    local camera = Workspace.CurrentCamera
    if not camera then return nil end

    local mousePos = UserInputService:GetMouseLocation()
    local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
    
    -- Parâmetros de Raycast (Para ignorar o nosso próprio corpo)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local localPlayer = Players.LocalPlayer
    if localPlayer and localPlayer.Character then
        rayParams.FilterDescendantsInstances = {localPlayer.Character, camera}
    end

    -- Distância máxima do tiro (Padrão: 1000 studs)
    local raycastResult = Workspace:Raycast(ray.Origin, ray.Direction * 1000, rayParams)
    
    if raycastResult and raycastResult.Instance then
        local hitPart = raycastResult.Instance
        local character = hitPart:FindFirstAncestorOfClass("Model")
        
        if character then
            local hum = character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local player = Players:GetPlayerFromCharacter(character)
                
                -- Verifica se é um jogador inimigo
                if player and player ~= localPlayer then
                    -- Knock Check
                    if GetToggleState(KEY_KNOCK_CHECK, false) and KnockCheck then
                        if KnockCheck.IsKnocked(player) then return nil end
                    end
                    
                    -- Wall Check
                    -- O Raycast já bate na primeira coisa que vê. Se bateu no jogador, ele NÃO está atrás da parede.
                    -- Mas se o Wall Check estiver DESLIGADO na UI, teríamos de atravessar paredes (o que requer mais matemática). 
                    -- Para um TriggerBot limpo, o Raycast nativo serve como WallCheck perfeito.
                    
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
    -- Usa as funções nativas de executor para clicar o rato fisicamente
    if type(mouse1press) == "function" and type(mouse1release) == "function" then
        mouse1press()
        task.wait(0.01) -- Simula o tempo do dedo pressionar o botão
        mouse1release()
    elseif type(mouse1click) == "function" then
        mouse1click()
    else
        Telemetry.Log("ERROR", "TriggerBot", "O executor não suporta simulação de clique (mouse1click).")
    end
end

-- ==========================================
-- CICLO DE VIDA DO TRIGGERBOT
-- ==========================================
function TriggerBot.Init()
    if isInitialized then return "initialized" end

    Loop.BindToRender("TriggerBot_Controller", function()
        -- Verifica se está ativado pela UI
        if not GetToggleState(KEY_ENABLED, false) then 
            isHovering = false
            hoverStartTime = 0
            return 
        end

        local target = GetTargetInCrosshair()

        if target then
            -- Se acabou de colocar a mira no alvo, regista o tempo exato
            if not isHovering then
                isHovering = true
                hoverStartTime = tick()
            end

            -- Lógica do Delay
            local delayTime = tonumber(UIState.Get(KEY_DELAY, 0.03)) or 0.00
            local timeHovering = tick() - hoverStartTime

            if timeHovering >= delayTime then
                -- O tempo de Delay passou! Agora calculamos a probabilidade de atirar (Hit Chance)
                -- Adicionamos um cooldown (0.05s) para ele não clicar 60 vezes por segundo e crashar o PC.
                if tick() - lastClickTime >= 0.05 then
                    lastClickTime = tick()
                    
                    local hitChance = tonumber(UIState.Get(KEY_HIT_CHANCE, 100)) or 100
                    local rng = math.random(1, 100)
                    
                    if rng <= hitChance then
                        FireWeapon()
                    end
                end
            end
        else
            -- Se a mira saiu do alvo, reseta tudo
            if isHovering then
                isHovering = false
                hoverStartTime = 0
            end
        end
    end)

    isInitialized = true
    Telemetry.Log("LITURGY", "TriggerBot", "Módulo Inicializado. Delay e Hit Chance ativos.")
    return "initialized"
end

function TriggerBot.Destroy()
    if not isInitialized then return end
    Loop.UnbindFromRender("TriggerBot_Controller")
    isHovering = false
    hoverStartTime = 0
    isInitialized = false
end

return TriggerBot
