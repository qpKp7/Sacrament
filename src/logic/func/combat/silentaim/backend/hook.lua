--!strict
--[[
    SACRAMENT | Canonical Hitbox (Fixed Physics & Decals)
    1. Sem Auto-Target (Trava apenas com Bind + Cursor).
    2. Esconde o Rosto (Decals) para não aparecer rostos gigantes.
    3. Altera a física apenas 1 vez (Evita que o player trave/despedace).
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
local lockedCharacter: Model? = nil

-- Memória para podermos restaurar o inimigo ao normal depois
local originalSizes: {[BasePart]: Vector3} = {}
local originalTransparencies: {[BasePart]: number} = {}
local originalDecals: {[Decal]: number} = {}

-- Chaves sincronizadas da UI
local KEY_ENABLED     = "SilentAimEnabled"
local KEY_FOV_RADIUS  = "SilentAim_FovLimit"
local KEY_MARK_STYLE  = "SilentAim_MarkStyle"
local KEY_AIM_PART    = "SilentAim_AimPart"
local KEY_WALL_CHECK  = "SilentAim_WallCheck"
local KEY_BIND        = "SilentAim_Keybind"
local KEY_HOLD        = "SilentAim_KeyHold"

-- Restaura o Character original ao estado perfeitamente normal
local function ResetHitbox()
    for part, size in pairs(originalSizes) do
        if part and part.Parent then
            part.Size = size
            if originalTransparencies[part] then part.Transparency = originalTransparencies[part] end
            part.CanCollide = true
            part.Massless = false
        end
    end
    for decal, trans in pairs(originalDecals) do
        if decal and decal.Parent then
            decal.Transparency = trans
        end
    end
    
    table.clear(originalSizes)
    table.clear(originalTransparencies)
    table.clear(originalDecals)
end

-- Busca o alvo EXATO no momento do clique
local function GetTargetCharacterAtCursor(): Model?
    local fovRadius = tonumber(UIState.Get(KEY_FOV_RADIUS, 150)) or 150
    local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
    local wallCheck = UIState.Get(KEY_WALL_CHECK, false)
    
    local targetPart = Targeting.GetClosestToCursor(fovRadius, {aimPartName, "HumanoidRootPart"}, wallCheck, false, false)
    if targetPart and targetPart.Parent then
        return targetPart.Parent :: Model
    end
    return nil
end

function HookBackend.canLoad() return true, "Hitbox Expander suportado." end

function HookBackend.load()
    if isInitialized then return "initialized" end
    if FOVLimit and type(FOVLimit.Init) == "function" then FOVLimit.Init() end

    -- =======================================================
    -- SISTEMA DE TRAVA (SÓ FUNCIONA QUANDO APERTA A TECLA)
    -- =======================================================
    HookBackend._inputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not UIState.Get(KEY_ENABLED, false) then return end
        
        local bind = UIState.Get(KEY_BIND, "None")
        if bind and bind ~= "None" and input.KeyCode.Name == bind then
            if UIState.Get(KEY_HOLD, false) then
                lockedCharacter = GetTargetCharacterAtCursor()
            else
                -- Modo Toggle
                if lockedCharacter then
                    ResetHitbox()
                    lockedCharacter = nil
                    MarkStyle.Clear()
                else
                    lockedCharacter = GetTargetCharacterAtCursor()
                end
            end
        end
    end)

    HookBackend._inputEnded = UserInputService.InputEnded:Connect(function(input, gpe)
        local bind = UIState.Get(KEY_BIND, "None")
        if bind and bind ~= "None" and input.KeyCode.Name == bind then
            if UIState.Get(KEY_HOLD, false) then
                ResetHitbox()
                lockedCharacter = nil
                MarkStyle.Clear()
            end
        end
    end)

    -- =======================================================
    -- LOOP DE MANIPULAÇÃO (Apenas aplica no alvo travado)
    -- =======================================================
    Loop.BindToRender("SilentAim_Logic", function()
        -- Se o usuário desligar na UI ou não tiver ninguém travado
        if not UIState.Get(KEY_ENABLED, false) or not lockedCharacter then
            ResetHitbox()
            MarkStyle.Clear()
            lockedCharacter = nil
            return
        end

        local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
        
        -- Valida se o alvo ainda está no jogo e vivo
        if not lockedCharacter.Parent or not lockedCharacter:FindFirstChildOfClass("Humanoid") or lockedCharacter.Humanoid.Health <= 0 then
            ResetHitbox()
            lockedCharacter = nil
            MarkStyle.Clear()
            return
        end

        local partToEnlarge = lockedCharacter:FindFirstChild(aimPartName)
        if partToEnlarge and partToEnlarge:IsA("BasePart") then
            
            -- APENAS APLICA SE AINDA NÃO FOI APLICADO (ISSO CORRIGE O TRAVAMENTO)
            if not originalSizes[partToEnlarge] then
                originalSizes[partToEnlarge] = partToEnlarge.Size
                originalTransparencies[partToEnlarge] = partToEnlarge.Transparency
                
                -- Aumenta a Hitbox
                partToEnlarge.Size = Vector3.new(15, 15, 15) 
                partToEnlarge.Transparency = 1 
                partToEnlarge.CanCollide = false
                partToEnlarge.Massless = true -- Impede que a cabeça gigante puxe o corpo do cara pro chão

                -- Remove os rostos e acessórios colados para não flutuarem
                for _, child in ipairs(partToEnlarge:GetChildren()) do
                    if child:IsA("Decal") then
                        originalDecals[child] = child.Transparency
                        child.Transparency = 1
                    end
                end
            end

            -- Força a colisão para false a cada frame, pois o Roblox tenta reativar
            partToEnlarge.CanCollide = false 

            -- Aplica a Marcação Visual
            local markOption = UIState.Get(KEY_MARK_STYLE, "None")
            MarkStyle.Mark(partToEnlarge, markOption)
        else
            MarkStyle.Clear()
        end
    end)

    isInitialized = true
    Telemetry.Log("INFO", "SilentAim", "Hitbox Manual Fix ativado.")
    return "initialized"
end

function HookBackend.destroy()
    if not isInitialized then return end
    Loop.UnbindFromRender("SilentAim_Logic")
    
    if HookBackend._inputBegan then HookBackend._inputBegan:Disconnect() end
    if HookBackend._inputEnded then HookBackend._inputEnded:Disconnect() end
    if FOVLimit and type(FOVLimit.Destroy) == "function" then FOVLimit.Destroy() end
    
    ResetHitbox()
    MarkStyle.Clear()
    lockedCharacter = nil
    isInitialized = false
end

function HookBackend.health() return isInitialized and "initialized" or "unsupported" end
function HookBackend.requirements() return {} end
function HookBackend.assumptions() return "Manipulação segura de Hitbox com correção de Motor6D e Decals." end

return HookBackend
