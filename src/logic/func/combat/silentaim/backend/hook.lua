--!strict
--[[
    SACRAMENT | Manual Fake Hitbox Backend (Elite Version)
    1. Cria uma Hitbox Fantasma ancorada (Não despedaça o player).
    2. Mantém a peça original intocada (Não remove a cabeça do alvo).
    3. Foco EXCLUSIVO via Keybind (Não marca quem passa pelo mouse).
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

-- Referências de Controle Estrito
local lockedCharacter: Model? = nil
local fakeHitbox: Part? = nil

-- Chaves da UI sincronizadas
local KEY_ENABLED     = "SilentAimEnabled"
local KEY_FOV_RADIUS  = "SilentAim_FovLimit"
local KEY_MARK_STYLE  = "SilentAim_MarkStyle"
local KEY_AIM_PART    = "SilentAim_AimPart"
local KEY_WALL_CHECK  = "SilentAim_WallCheck"
local KEY_BIND        = "SilentAim_Keybind"
local KEY_HOLD        = "SilentAim_KeyHold"

-- Destrói a Hitbox Fantasma do mapa
local function CleanFakeHitbox()
    if fakeHitbox then
        fakeHitbox:Destroy()
        fakeHitbox = nil
    end
end

-- Busca o Character mais próximo do cursor, respeitando a Parede
local function GetClosestCharacter(): Model?
    local fovRadius = tonumber(UIState.Get(KEY_FOV_RADIUS, 150)) or 150
    local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
    local wallCheck = UIState.Get(KEY_WALL_CHECK, false)
    
    -- Busca a peça e já avalia o WallCheck por dentro da função canônica
    local targetPart = Targeting.GetClosestToCursor(fovRadius, {aimPartName, "HumanoidRootPart"}, wallCheck, false, false)
    if targetPart and targetPart.Parent then
        return targetPart.Parent :: Model
    end
    return nil
end

function HookBackend.canLoad()
    return true, "Manual Fake Hitbox carregada com sucesso."
end

function HookBackend.load()
    if isInitialized then return "initialized" end
    if FOVLimit and type(FOVLimit.Init) == "function" then FOVLimit.Init() end

    -- =======================================================
    -- CONTROLE DE TRAVA (Apenas funciona com a BIND)
    -- =======================================================
    HookBackend._inputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not UIState.Get(KEY_ENABLED, false) then return end
        
        local bind = UIState.Get(KEY_BIND, "None")
        if bind and bind ~= "None" and input.KeyCode.Name == bind then
            local isHold = UIState.Get(KEY_HOLD, false)
            
            if isHold then
                -- Modo Segurar: Trava no cara ao apertar
                lockedCharacter = GetClosestCharacter()
            else
                -- Modo Alternar (Toggle): Trava ou destrava
                if lockedCharacter then
                    lockedCharacter = nil
                    CleanFakeHitbox()
                    MarkStyle.Clear()
                else
                    lockedCharacter = GetClosestCharacter()
                end
            end
        end
    end)

    HookBackend._inputEnded = UserInputService.InputEnded:Connect(function(input, gpe)
        local bind = UIState.Get(KEY_BIND, "None")
        if bind and bind ~= "None" and input.KeyCode.Name == bind then
            if UIState.Get(KEY_HOLD, false) then
                -- Modo Segurar: Solta o alvo ao soltar a tecla
                lockedCharacter = nil
                CleanFakeHitbox()
                MarkStyle.Clear()
            end
        end
    end)

    -- =======================================================
    -- RENDERIZAÇÃO DA HITBOX FANTASMA (60x por segundo)
    -- =======================================================
    Loop.BindToRender("SilentAim_Logic", function()
        -- Se o usuário desligar na UI, força a limpeza total
        if not UIState.Get(KEY_ENABLED, false) then
            lockedCharacter = nil
            CleanFakeHitbox()
            MarkStyle.Clear()
            return
        end

        -- Se não tiver ninguém travado pela Keybind, não faz absolutamente nada
        if not lockedCharacter then
            CleanFakeHitbox()
            MarkStyle.Clear()
            return
        end

        local hum = lockedCharacter:FindFirstChildOfClass("Humanoid")
        local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
        local realPart = lockedCharacter:FindFirstChild(aimPartName) or lockedCharacter:FindFirstChild("HumanoidRootPart")

        -- Se o alvo travado morrer, sair do jogo ou for deletado, solta a trava
        if not lockedCharacter.Parent or not hum or hum.Health <= 0 or not realPart then
            lockedCharacter = nil
            CleanFakeHitbox()
            MarkStyle.Clear()
            return
        end

        -- Cria ou atualiza o Fantasma se for um alvo/AimPart nova
        if not fakeHitbox or fakeHitbox.Parent ~= lockedCharacter or fakeHitbox.Name ~= aimPartName then
            CleanFakeHitbox()
            
            fakeHitbox = Instance.new("Part")
            fakeHitbox.Name = realPart.Name -- Engana o script da arma
            fakeHitbox.Size = Vector3.new(15, 15, 15) -- Hitbox invisível gigante
            fakeHitbox.Transparency = 1 -- 100% Invisível
            fakeHitbox.CanCollide = false
            fakeHitbox.Anchored = true -- EVITA DESPEDAÇAR O PLAYER
            fakeHitbox.Massless = true
            fakeHitbox.Parent = lockedCharacter
        end

        -- Move o fantasma para a posição exata da peça real a cada frame
        if fakeHitbox and realPart then
            fakeHitbox.CFrame = realPart.CFrame
        end

        -- Marca visualmente apenas a peça original
        MarkStyle.Mark(realPart, UIState.Get(KEY_MARK_STYLE, "None"))
    end)

    isInitialized = true
    Telemetry.Log("INFO", "SilentAim", "Hitbox Fantasma com Trava Manual ativada.")
    return "initialized"
end

function HookBackend.destroy()
    if not isInitialized then return end
    Loop.UnbindFromRender("SilentAim_Logic")
    
    if HookBackend._inputBegan then HookBackend._inputBegan:Disconnect() end
    if HookBackend._inputEnded then HookBackend._inputEnded:Disconnect() end
    if FOVLimit and type(FOVLimit.Destroy) == "function" then FOVLimit.Destroy() end
    
    CleanFakeHitbox()
    MarkStyle.Clear()
    lockedCharacter = nil
    isInitialized = false
end

function HookBackend.health() return isInitialized and "initialized" or "unsupported" end
function HookBackend.requirements() return {} end
function HookBackend.assumptions() return "Criação de Peças Ancoradas." end

return HookBackend
