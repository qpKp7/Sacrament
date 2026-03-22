--!strict
--[[
    SACRAMENT | Hitbox Expander Backend
    Com WallCheck, AimPart específico e Sistema de Target Lock (Keybind)
]]
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Import = (_G :: any).SacramentImport

local UIState   = Import("state/uistate")
local Targeting = Import("logic/core/targeting")
local Loop      = Import("logic/core/loop")
local MarkStyle = Import("logic/func/combat/silentaim/markstyle")
local Telemetry = Import("logic/core/telemetry")
local FOVLimit  = Import("logic/func/combat/silentaim/fovlimit")

local HookBackend = {}
local isInitialized = false

-- Memória da Hitbox
local lastTarget: BasePart? = nil
local originalSizes: {[BasePart]: Vector3} = {}
local originalTransparencies: {[BasePart]: number} = {}

-- Memória do Target Lock
local lockedTarget: BasePart? = nil
local isHolding = false
local inputBeganConn: RBXScriptConnection? = nil
local inputEndedConn: RBXScriptConnection? = nil

-- Sincronizando Chaves da UI
local KEY_ENABLED     = "SilentAimEnabled"
local KEY_FOV_RADIUS  = "SilentAim_FovLimit"
local KEY_MARK_STYLE  = "SilentAim_MarkStyle"
local KEY_AIM_PART    = "SilentAim_AimPart"
local KEY_WALL_CHECK  = "SilentAim_WallCheck"
local KEY_BIND        = "SilentAim_Keybind"
local KEY_HOLD        = "SilentAim_KeyHold"

local function ResetLastTarget()
    if lastTarget then
        if originalSizes[lastTarget] then lastTarget.Size = originalSizes[lastTarget] end
        if originalTransparencies[lastTarget] then lastTarget.Transparency = originalTransparencies[lastTarget] end
        lastTarget.CanCollide = true
        
        originalSizes[lastTarget] = nil
        originalTransparencies[lastTarget] = nil
        lastTarget = nil
    end
end

-- Busca o alvo respeitando WallCheck e a parte do corpo (Head/Torso)
local function GetClosestTarget(): BasePart?
    local fovRadius = tonumber(UIState.Get(KEY_FOV_RADIUS, 150)) or 150
    local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
    local wallCheck = UIState.Get(KEY_WALL_CHECK, false)
    
    local target = Targeting.GetClosestToCursor(fovRadius, {aimPartName, "HumanoidRootPart"}, wallCheck, false, false)
    
    if target and target.Parent then
        -- Garante que vamos expandir a parte exata que você escolheu na UI
        return target.Parent:FindFirstChild(aimPartName) or target.Parent:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

function HookBackend.canLoad()
    return true, "Hitbox Expander é compatível com todos os executores."
end

function HookBackend.load()
    if isInitialized then return "initialized" end

    if FOVLimit and type(FOVLimit.Init) == "function" then FOVLimit.Init() end

    -- =======================================================
    -- SISTEMA DE TARGET LOCK (A Trava da Keybind)
    -- =======================================================
    inputBeganConn = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not UIState.Get(KEY_ENABLED, false) then return end

        local bind = UIState.Get(KEY_BIND, "None")
        if bind and bind ~= "None" and input.KeyCode.Name == bind then
            if UIState.Get(KEY_HOLD, false) then
                isHolding = true
                lockedTarget = GetClosestTarget()
            else
                -- Modo Toggle: Clica para travar, clica para soltar
                if lockedTarget then
                    lockedTarget = nil
                else
                    lockedTarget = GetClosestTarget()
                end
            end
        end
    end)

    inputEndedConn = UserInputService.InputEnded:Connect(function(input, gpe)
        local bind = UIState.Get(KEY_BIND, "None")
        if bind and bind ~= "None" and input.KeyCode.Name == bind then
            if UIState.Get(KEY_HOLD, false) then
                isHolding = false
                lockedTarget = nil
            end
        end
    end)

    -- =======================================================
    -- LOOP PRINCIPAL DE COMBATE (60x por segundo)
    -- =======================================================
    Loop.BindToRender("SilentAim_Hitbox", function()
        if not UIState.Get(KEY_ENABLED, false) then
            ResetLastTarget()
            MarkStyle.Clear()
            lockedTarget = nil
            return
        end

        local currentTarget: BasePart? = nil

        -- Se você tiver alguém "Trancado" na mira, foca nele
        if lockedTarget and lockedTarget.Parent then
            local hum = lockedTarget.Parent:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                currentTarget = lockedTarget
            else
                lockedTarget = nil -- Solta o alvo se ele morrer
            end
        end

        -- Se não tem ninguém trancado, pega o mais próximo
        if not currentTarget then
            currentTarget = GetClosestTarget()
        end

        -- Se mudou de alvo, restaura o corpo do alvo anterior ao normal
        if currentTarget ~= lastTarget then
            ResetLastTarget()
            lastTarget = currentTarget
        end

        -- Aplica a Expansão no alvo atual
        if currentTarget then
            if not originalSizes[currentTarget] then
                originalSizes[currentTarget] = currentTarget.Size
                originalTransparencies[currentTarget] = currentTarget.Transparency
            end

            -- HITBOX GIGANTE E 100% INVISÍVEL
            currentTarget.Size = Vector3.new(15, 15, 15)
            currentTarget.Transparency = 1 
            currentTarget.CanCollide = false

            -- Atualiza o visual
            local markOption = UIState.Get(KEY_MARK_STYLE, "None")
            MarkStyle.Mark(currentTarget, markOption)
        else
            MarkStyle.Clear()
        end
    end)

    isInitialized = true
    Telemetry.Log("INFO", "SilentAim", "Hitbox Expander com Target Lock ativado.")
    return "initialized"
end

function HookBackend.destroy()
    if not isInitialized then return end
    Loop.UnbindFromRender("SilentAim_Hitbox")
    if inputBeganConn then inputBeganConn:Disconnect() end
    if inputEndedConn then inputEndedConn:Disconnect() end
    if FOVLimit and type(FOVLimit.Destroy) == "function" then FOVLimit.Destroy() end
    ResetLastTarget()
    MarkStyle.Clear()
    lockedTarget = nil
    isInitialized = false
end

function HookBackend.health() return isInitialized and "initialized" or "unsupported" end
function HookBackend.requirements() return {} end
function HookBackend.assumptions() return "O jogo aceita modificação de propriedades de BasePart." end

return HookBackend
