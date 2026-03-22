--!strict
--[[
    SACRAMENT | Canonical Hitbox Manipulation (Final Pure Fix)
    1. Manipula a peça REAL do player para garantir o dano (Da Hood).
    2. Transparency = 1 e CanCollide = false (Invisível, sem colisão física).
    3. Suporte a Target Lock (Keybind) e Auto-Target (Closest to Cursor).
]]
local Players = game:GetService("Players")
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

-- Variáveis de Estado
local lastCharacterAimingAt: Model? = nil
local lockedCharacter: Model? = nil
local originalSizes: {[BasePart]: Vector3} = {}
local originalTransparencies: {[BasePart]: number} = {}

-- Chaves sincronizadas da UI
local KEY_ENABLED     = "SilentAimEnabled"
local KEY_FOV_RADIUS  = "SilentAim_FovLimit"
local KEY_MARK_STYLE  = "SilentAim_MarkStyle"
local KEY_AIM_PART    = "SilentAim_AimPart"
local KEY_WALL_CHECK  = "SilentAim_WallCheck"
local KEY_BIND        = "SilentAim_Keybind"
local KEY_HOLD        = "SilentAim_KeyHold"

-- Restaura o Character original ao estado perfeitamente normal
local function ResetLastCharacter()
    if lastCharacterAimingAt then
        for part, size in pairs(originalSizes) do
            if part and part.Parent then
                part.Size = size
                if originalTransparencies[part] then part.Transparency = originalTransparencies[part] end
                part.CanCollide = true -- Restaura a física
            end
        end
        -- Limpa a memória para evitar memory leaks
        table.clear(originalSizes)
        table.clear(originalTransparencies)
        lastCharacterAimingAt = nil
    end
end

-- Busca o Character mais próximo do cursor respeitando o FOV e Paredes
local function GetClosestTargetCharacter(): Model?
    local fovRadius = tonumber(UIState.Get(KEY_FOV_RADIUS, 150)) or 150
    local aimPartName = UIState.Get(KEY_AIM_PART, "Head") -- Chave do slider/dropdown
    local wallCheck = UIState.Get(KEY_WALL_CHECK, false)
    
    local targetPart = Targeting.GetClosestToCursor(fovRadius, {aimPartName, "HumanoidRootPart"}, wallCheck, false, false)
    if targetPart and targetPart.Parent then
        return targetPart.Parent :: Model
    end
    return nil
end

function HookBackend.canLoad()
    return true, "Canonical Hitbox manipulada com sucesso."
end

function HookBackend.load()
    if isInitialized then return "initialized" end
    if FOVLimit and type(FOVLimit.Init) == "function" then FOVLimit.Init() end

    -- =======================================================
    -- CONTROLE DE TRAVA (TARGET LOCK) VIA BIND
    -- =======================================================
    HookBackend._inputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not UIState.Get(KEY_ENABLED, false) then return end
        
        local bind = UIState.Get(KEY_BIND, "None")
        if bind and bind ~= "None" and input.KeyCode.Name == bind then
            if UIState.Get(KEY_HOLD, false) then
                lockedCharacter = GetClosestTargetCharacter()
            else
                -- Modo Alternar (Toggle)
                if lockedCharacter then
                    lockedCharacter = nil
                else
                    lockedCharacter = GetClosestTargetCharacter()
                end
            end
        end
    end)

    HookBackend._inputEnded = UserInputService.InputEnded:Connect(function(input, gpe)
        local bind = UIState.Get(KEY_BIND, "None")
        if bind and bind ~= "None" and input.KeyCode.Name == bind then
            if UIState.Get(KEY_HOLD, false) then
                lockedCharacter = nil
            end
        end
    end)

    -- =======================================================
    -- LOOP DE MANIPULAÇÃO (60x por segundo)
    -- =======================================================
    Loop.BindToRender("SilentAim_Logic", function()
        if not UIState.Get(KEY_ENABLED, false) then
            ResetLastCharacter()
            MarkStyle.Clear()
            lockedCharacter = nil
            return
        end

        local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
        local finalTarget: Model? = nil

        -- 1. Prioridade: Alvo travado pela BIND
        if lockedCharacter and lockedCharacter.Parent and lockedCharacter:FindFirstChildOfClass("Humanoid") then
            if lockedCharacter.Humanoid.Health > 0 then
                finalTarget = lockedCharacter
            else
                lockedCharacter = nil
            end
        end

        -- 2. Secundário: Auto-Target proximo do mouse
        if not finalTarget then
            finalTarget = GetClosestTargetCharacter()
        end

        -- Se trocamos de alvo (ou perdemos o alvo)
        if finalTarget ~= lastCharacterAimingAt then
            ResetLastCharacter()
            lastCharacterAimingAt = finalTarget
        end

        if finalTarget then
            local partToEnlarge = finalTarget:FindFirstChild(aimPartName)
            if partToEnlarge and partToEnlarge:IsA("BasePart") then
                
                -- Se é a primeira vez que pegamos essa peça, salvamos o estado original
                if not originalSizes[partToEnlarge] then
                    originalSizes[partToEnlarge] = partToEnlarge.Size
                    originalTransparencies[partToEnlarge] = partToEnlarge.Transparency
                end

                -- =======================================================
                -- A MAGIA DO CONFORTO (ZERO FÍSICA E ZERO BUG VISUAL)
                -- =======================================================
                -- 1. Forçamos o tamanho gigante (para garantir o dano e curvar a bala).
                partToEnlarge.Size = Vector3.new(15, 15, 15) 
                
                -- 2. Forçamos transparência em 1 (totalmente invisível).
                partToEnlarge.Transparency = 1 
                
                -- 3. A MAIS IMPORTANTE: Desliga a colisão para você passar por dentro dele!
                partToEnlarge.CanCollide = false 
                -- =======================================================

                -- Aplica o visual da MarkStyle (Bolinha/Highlight) na peça REAL
                local markOption = UIState.Get(KEY_MARK_STYLE, "None")
                MarkStyle.Mark(partToEnlarge, markOption)
            else
                MarkStyle.Clear()
            end
        else
            MarkStyle.Clear()
        end
    end)

    isInitialized = true
    Telemetry.Log("INFO", "SilentAim", "Hitbox Pure Fix ativado.")
    return "initialized"
end

function HookBackend.destroy()
    if not isInitialized then return end
    Loop.UnbindFromRender("SilentAim_Logic")
    
    if HookBackend._inputBegan then HookBackend._inputBegan:Disconnect() end
    if HookBackend._inputEnded then HookBackend._inputEnded:Disconnect() end
    if FOVLimit and type(FOVLimit.Destroy) == "function" then FOVLimit.Destroy() end
    
    ResetLastCharacter()
    MarkStyle.Clear()
    lockedCharacter = nil
    isInitialized = false
end

function HookBackend.health() return isInitialized and "initialized" or "unsupported" end
function HookBackend.requirements() return {} end
function HookBackend.assumptions() return "Manipulação de Propriedades de Instância Nativa." end

return HookBackend
