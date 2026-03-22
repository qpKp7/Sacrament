--!strict
--[[
    SACRAMENT | Mathematical Redirection (True Silent Aim)
    - Sem Hitbox falsa. Usa interceptação de Vetores na Rede.
    - Exclusivo por BIND (Sem auto-target).
    - Disparo só redireciona se o ALVO TRAVADO estiver DENTRO DO FOV.
    - Padrão MarkStyle corrigido para Highlight.
]]
local Workspace = game:GetService("Workspace")
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

-- Chaves sincronizadas da UI
local KEY_ENABLED     = "SilentAimEnabled"
local KEY_FOV_RADIUS  = "SilentAim_FovLimit"
local KEY_MARK_STYLE  = "SilentAim_MarkStyle"
local KEY_AIM_PART    = "SilentAim_AimPart"
local KEY_WALL_CHECK  = "SilentAim_WallCheck"
local KEY_BIND        = "SilentAim_Keybind"
local KEY_HOLD        = "SilentAim_KeyHold"

local oldFireServer: any
local oldRaycast: any

-- Memória do alvo travado
local lockedCharacter: Model? = nil

-- Busca o Character apenas no milissegundo em que você aperta a Bind
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

-- =======================================================
-- A CONDIÇÃO DE DISPARO (A MÁGICA DO FOV)
-- =======================================================
local function GetValidLockedPartForShooting(): BasePart?
    -- Se não tem ninguém travado, não atira dobrado
    if not lockedCharacter or not lockedCharacter.Parent then return nil end
    
    local hum = lockedCharacter:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return nil end

    local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
    local realPart = lockedCharacter:FindFirstChild(aimPartName) or lockedCharacter:FindFirstChild("HumanoidRootPart")
    
    if not realPart or not realPart:IsA("BasePart") then return nil end

    -- Pega a câmera para calcular se o cara travado está DENTRO do Círculo na tela
    local camera = Workspace.CurrentCamera
    if not camera then return nil end

    local screenPos, onScreen = camera:WorldToViewportPoint(realPart.Position)
    if not onScreen then return nil end -- Se o cara não tá nem na sua tela, atira normal

    local mousePos = UserInputService:GetMouseLocation()
    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
    local fovRadius = tonumber(UIState.Get(KEY_FOV_RADIUS, 150)) or 150

    -- SE O CARA ESTIVER DENTRO DO CÍRCULO BRANCO, RETORNA A PEÇA PARA A BALA ACERTAR
    if dist <= fovRadius then
        return realPart
    end

    -- Se ele estiver travado, mas você mirou muito longe (fora do FOV), atira normal
    return nil
end

function HookBackend.canLoad() return true, "Mathematical Redirector suportado." end

function HookBackend.load()
    if isInitialized then return "initialized" end
    if FOVLimit and type(FOVLimit.Init) == "function" then FOVLimit.Init() end

    -- =======================================================
    -- SISTEMA DE TRAVA (BIND)
    -- =======================================================
    HookBackend._inputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not UIState.Get(KEY_ENABLED, false) then return end
        
        local bind = UIState.Get(KEY_BIND, "None")
        if bind and bind ~= "None" and input.KeyCode.Name == bind then
            if UIState.Get(KEY_HOLD, false) then
                lockedCharacter = GetCharacterAtCursor()
            else
                if lockedCharacter then
                    lockedCharacter = nil
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
                lockedCharacter = nil
                MarkStyle.Clear()
            end
        end
    end)

    -- =======================================================
    -- RENDERIZAÇÃO VISUAL (Bolinha/Highlight)
    -- =======================================================
    Loop.BindToRender("SilentAim_Visuals", function()
        if not UIState.Get(KEY_ENABLED, false) or not lockedCharacter then
            MarkStyle.Clear()
            return
        end
        
        local hum = lockedCharacter:FindFirstChildOfClass("Humanoid")
        if not lockedCharacter.Parent or not hum or hum.Health <= 0 then
            lockedCharacter = nil
            MarkStyle.Clear()
            return
        end

        local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
        local targetPart = lockedCharacter:FindFirstChild(aimPartName) or lockedCharacter:FindFirstChild("HumanoidRootPart")
        
        if targetPart then
            -- [CORRIGIDO] Padrão setado para "Highlight" direto!
            MarkStyle.Mark(targetPart, UIState.Get(KEY_MARK_STYLE, "Highlight"))
        else
            MarkStyle.Clear()
        end
    end)

    -- =======================================================
    -- A MATEMÁTICA DO TIRO (INTERCEPTAÇÃO DA ARMA)
    -- =======================================================
    local success, err = pcall(function()
        
        -- Da Hood / Jogos com RemoteEvent
        local fakeEvent = Instance.new("RemoteEvent")
        oldFireServer = hookfunction(fakeEvent.FireServer, function(self, ...)
            local args = {...}
            
            if UIState.Get(KEY_ENABLED, false) then
                local target = GetValidLockedPartForShooting()
                if target then
                    -- Se a arma mandou um Vector3 pro servidor, troca pra cabeça do inimigo
                    for i, value in pairs(args) do
                        if typeof(value) == "Vector3" then
                            args[i] = target.Position
                        elseif typeof(value) == "CFrame" then
                            args[i] = target.CFrame
                        end
                    end
                end
            end
            return oldFireServer(self, unpack(args))
        end)

        -- Jogos Modernos / Raycast
        oldRaycast = hookfunction(Workspace.Raycast, function(self, origin, direction, params)
            if UIState.Get(KEY_ENABLED, false) then
                local target = GetValidLockedPartForShooting()
                if target then
                    local newDirection = (target.Position - origin).Unit * direction.Magnitude
                    return oldRaycast(self, origin, newDirection, params)
                end
            end
            return oldRaycast(self, origin, direction, params)
        end)

    end)

    if not success then
        Telemetry.Log("ERROR", "SilentAim", "Falha ao interceptar pacotes: " .. tostring(err))
        return "failed"
    end

    isInitialized = true
    Telemetry.Log("INFO", "SilentAim", "Target Lock Matemático Ativado.")
    return "initialized"
end

function HookBackend.destroy()
    if not isInitialized then return end
    Loop.UnbindFromRender("SilentAim_Visuals")
    
    if HookBackend._inputBegan then HookBackend._inputBegan:Disconnect() end
    if HookBackend._inputEnded then HookBackend._inputEnded:Disconnect() end
    if FOVLimit and type(FOVLimit.Destroy) == "function" then FOVLimit.Destroy() end
    
    MarkStyle.Clear()
    lockedCharacter = nil
    isInitialized = false
end

function HookBackend.health() return isInitialized and "initialized" or "unsupported" end
function HookBackend.requirements() return {SupportsHookFunc = true} end
function HookBackend.assumptions() return "Matemática de interceptação com FOV Dinâmico." end

return HookBackend
