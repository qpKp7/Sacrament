--!strict
--[[
    SACRAMENT | Anchored Ghost Hitbox (The Absolute Fix)
    - Cria peça nova (sem rosto/decals).
    - Anchored = true (zero quebra de física ou joints).
    - Trava EXCLUSIVA via Keybind.
]]
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

-- Referências Restritas
local lockedCharacter: Model? = nil
local ghostHitbox: Part? = nil

-- Chaves sincronizadas da UI
local KEY_ENABLED     = "SilentAimEnabled"
local KEY_FOV_RADIUS  = "SilentAim_FovLimit"
local KEY_MARK_STYLE  = "SilentAim_MarkStyle"
local KEY_AIM_PART    = "SilentAim_AimPart"
local KEY_WALL_CHECK  = "SilentAim_WallCheck"
local KEY_BIND        = "SilentAim_Keybind"
local KEY_HOLD        = "SilentAim_KeyHold"

-- Destrói completamente o fantasma
local function CleanGhost()
    if ghostHitbox then
        ghostHitbox:Destroy()
        ghostHitbox = nil
    end
end

-- Busca rigorosa: Apenas procura quem está no cursor AGORA
local function GetCharacterAtCursor(): Model?
    local fovRadius = tonumber(UIState.Get(KEY_FOV_RADIUS, 150)) or 150
    local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
    local wallCheck = UIState.Get(KEY_WALL_CHECK, false)
    
    local targetPart = Targeting.GetClosestToCursor(fovRadius, {aimPartName, "HumanoidRootPart"}, wallCheck, false, false)
    if targetPart and targetPart.Parent then
        return targetPart.Parent :: Model
    end
    return nil
end

function HookBackend.canLoad()
    return true, "Anchored Ghost Hitbox pronta."
end

function HookBackend.load()
    if isInitialized then return "initialized" end
    if FOVLimit and type(FOVLimit.Init) == "function" then FOVLimit.Init() end

    -- =======================================================
    -- SISTEMA DE TRAVA: LEI ABSOLUTA DA KEYBIND
    -- =======================================================
    HookBackend._inputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not UIState.Get(KEY_ENABLED, false) then return end
        
        local bind = UIState.Get(KEY_BIND, "None")
        if bind and bind ~= "None" and input.KeyCode.Name == bind then
            if UIState.Get(KEY_HOLD, false) then
                -- Modo Hold: Só procura e trava quando aperta
                lockedCharacter = GetCharacterAtCursor()
            else
                -- Modo Toggle: Destrava se tiver alguém, ou trava se tiver vazio
                if lockedCharacter then
                    lockedCharacter = nil
                    CleanGhost()
                    MarkStyle.Clear()
                else
                    lockedCharacter = GetCharacterAtCursor()
                end
            end
        end
    end)

    HookBackend._inputEnded = UserInputService.InputEnded:Connect(function(input, gpe)
        local bind = UIState.Get(KEY_BIND, "None")
        if bind and bind ~= "None" and input.KeyCode.Name == bind then
            if UIState.Get(KEY_HOLD, false) then
                -- Modo Hold: Limpa tudo ao soltar o dedo
                lockedCharacter = nil
                CleanGhost()
                MarkStyle.Clear()
            end
        end
    end)

    -- =======================================================
    -- LOOP: O MOTOR DO FANTASMA
    -- =======================================================
    Loop.BindToRender("SilentAim_Logic", function()
        -- Se desligou o Silent Aim ou se NÃO TEM NINGUÉM TRAVADO
        if not UIState.Get(KEY_ENABLED, false) or not lockedCharacter then
            CleanGhost()
            MarkStyle.Clear()
            return
        end

        local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
        local hum = lockedCharacter:FindFirstChildOfClass("Humanoid")
        local realPart = lockedCharacter:FindFirstChild(aimPartName) or lockedCharacter:FindFirstChild("HumanoidRootPart")

        -- Se o alvo desconectar, morrer ou a peça sumir, aborta.
        if not lockedCharacter.Parent or not hum or hum.Health <= 0 or not realPart then
            lockedCharacter = nil
            CleanGhost()
            MarkStyle.Clear()
            return
        end

        -- Criação do Cubo Novo (Isolado da física do Inimigo)
        if not ghostHitbox or ghostHitbox.Parent ~= lockedCharacter or ghostHitbox.Name ~= aimPartName then
            CleanGhost()
            
            ghostHitbox = Instance.new("Part")
            ghostHitbox.Name = realPart.Name -- Pega o nome "Head" ou "Torso"
            ghostHitbox.Size = Vector3.new(15, 15, 15)
            ghostHitbox.Transparency = 1 -- Invisível
            ghostHitbox.CanCollide = false -- Sem colisão com o mapa ou jogadores
            ghostHitbox.Anchored = true -- MAGIA: O cubo fica congelado no espaço
            ghostHitbox.Parent = lockedCharacter -- Engana o Da Hood
        end

        -- Atualiza a posição do cubo para acompanhar a cabeça real
        if ghostHitbox and realPart then
            ghostHitbox.CFrame = realPart.CFrame
        end

        -- Mantém o highlight apenas na peça real
        MarkStyle.Mark(realPart, UIState.Get(KEY_MARK_STYLE, "None"))
    end)

    isInitialized = true
    Telemetry.Log("INFO", "SilentAim", "Hitbox Fantasma Desvinculada iniciada.")
    return "initialized"
end

function HookBackend.destroy()
    if not isInitialized then return end
    Loop.UnbindFromRender("SilentAim_Logic")
    
    if HookBackend._inputBegan then HookBackend._inputBegan:Disconnect() end
    if HookBackend._inputEnded then HookBackend._inputEnded:Disconnect() end
    if FOVLimit and type(FOVLimit.Destroy) == "function" then FOVLimit.Destroy() end
    
    CleanGhost()
    MarkStyle.Clear()
    lockedCharacter = nil
    isInitialized = false
end

function HookBackend.health() return isInitialized and "initialized" or "unsupported" end
function HookBackend.requirements() return {} end
function HookBackend.assumptions() return "Manipulação desacoplada com Hitbox Anchored." end

return HookBackend
