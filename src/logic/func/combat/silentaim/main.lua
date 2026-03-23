--!strict
--[[
    SACRAMENT | Silent Aim Master Controller
    Gerencia FOV, Binds, Target Locking e delega a interceptação aos backends.
]]

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Import = (_G :: any).SacramentImport
local Registry  = Import("logic/core/backend_registry")
local Telemetry = Import("logic/core/telemetry")
local UIState   = Import("state/uistate")
local Loop      = Import("logic/core/loop")
local Targeting = Import("logic/core/targeting")
local MarkStyle = Import("logic/func/combat/silentaim/markstyle")
local FOVLimit  = Import("logic/func/combat/silentaim/fovlimit")

-- Import seguro de validações
local function SafeImport(path: string)
    local success, result = pcall(function() return Import(path) end)
    return success and result or nil
end
local KnockCheck = SafeImport("logic/func/combat/shared/knockcheck")

local SilentAim = {}
local isInitialized = false
local activeBackendName: string? = nil
local lockedCharacter: Model? = nil

-- Chaves da UI
local KEY_ENABLED     = "SilentAimEnabled"
local KEY_BIND        = "SilentAim_Keybind"
local KEY_HOLD        = "SilentAim_KeyHold"
local KEY_FOV_RADIUS  = "SilentAim_FovLimit"
local KEY_AIM_PART    = "SilentAim_AimPart"
local KEY_WALL_CHECK  = "SilentAim_WallCheck"
local KEY_KNOCK_CHECK = "SilentAim_KnockCheck"
local KEY_MARK_STYLE  = "SilentAim_MarkStyle"

-- ==========================================
-- RITO DE ARMAMENTO (PRE-REGISTRATION)
-- ==========================================
local function PreRegisterBackends()
    pcall(function()
        if type(Registry.Register) == "function" then
            Registry.Register("mouse_spoof", Import("logic/func/combat/silentaim/backend/mouse_spoof"))
            Registry.Register("physical_raycast", Import("logic/func/combat/silentaim/backend/physical_raycast"))
        end
    end)
end
PreRegisterBackends()

-- ==========================================
-- LÓGICA DE TARGETING (AQUISIÇÃO)
-- ==========================================
local function AcquireTarget(): Model?
    local fovRadius = tonumber(UIState.Get(KEY_FOV_RADIUS, 150)) or 150
    local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
    local wallCheck = UIState.Get(KEY_WALL_CHECK, false)
    local knockCheck = UIState.Get(KEY_KNOCK_CHECK, false)
    
    local targetPart = Targeting.GetClosestToCursor(fovRadius, {aimPartName, "HumanoidRootPart"}, wallCheck, knockCheck, false)
    if targetPart and targetPart.Parent then return targetPart.Parent :: Model end
    return nil
end

-- ==========================================
-- CICLO DE VIDA PRINCIPAL
-- ==========================================
function SilentAim.Init()
    if isInitialized then return "initialized" end

    -- 1. Inicia os Visuais (FOV) independente do backend
    if FOVLimit and type(FOVLimit.Init) == "function" then 
        FOVLimit.Init() 
    end

    -- 2. Sistema de Inputs (Toggle / Hold)
    SilentAim._inputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not UIState.Get(KEY_ENABLED, false) then return end
        
        local bind = UIState.Get(KEY_BIND, "None")
        if bind and bind ~= "None" and input.KeyCode.Name == bind then
            if UIState.Get(KEY_HOLD, false) then
                lockedCharacter = AcquireTarget() -- Segurou a tecla: Trava
            else
                if lockedCharacter then 
                    lockedCharacter = nil
                    MarkStyle.Clear()
                else 
                    lockedCharacter = AcquireTarget() -- Toggle: Alterna
                end
            end
        end
    end)

    SilentAim._inputEnded = UserInputService.InputEnded:Connect(function(input, gpe)
        local bind = UIState.Get(KEY_BIND, "None")
        if bind and bind ~= "None" and input.KeyCode.Name == bind then
            if UIState.Get(KEY_HOLD, false) then
                lockedCharacter = nil -- Soltou a tecla (Hold Mode): Destrava
                MarkStyle.Clear()
            end
        end
    end)

    -- 3. Loop de Validação Contínua (60 FPS)
    Loop.BindToRender("SilentAim_Controller", function()
        if not UIState.Get(KEY_ENABLED, false) then 
            lockedCharacter = nil
            MarkStyle.Clear()
            return 
        end

        if lockedCharacter then
            local hum = lockedCharacter:FindFirstChildOfClass("Humanoid")
            local isKnocked = UIState.Get(KEY_KNOCK_CHECK, false) and KnockCheck and KnockCheck.IsKnocked(Players:GetPlayerFromCharacter(lockedCharacter))
            
            -- Se o alvo morrer, desconectar, ou cair (KnockCheck), perde a trava automaticamente
            if not lockedCharacter.Parent or not hum or hum.Health <= 0 or isKnocked then
                lockedCharacter = nil
                MarkStyle.Clear()
                return
            end

            -- Mantém o MarkStyle atualizado no alvo
            local targetPart = lockedCharacter:FindFirstChild(UIState.Get(KEY_AIM_PART, "Head")) or lockedCharacter:FindFirstChild("HumanoidRootPart")
            if targetPart then MarkStyle.Mark(targetPart, UIState.Get(KEY_MARK_STYLE, "Highlight")) end
        else
            MarkStyle.Clear()
        end
    end)

    -- 4. Inicia o Motor de Interceptação (Backend)
    local BACKEND_CHAIN = { "mouse_spoof", "physical_raycast" }
    for _, backendName in ipairs(BACKEND_CHAIN) do
        local backend = Registry.Get(backendName)
        if backend and backend.canLoad() then
            if backend.load() == "initialized" then
                activeBackendName = backendName
                break
            end
        end
    end

    isInitialized = true
    Telemetry.Log("LITURGY", "SilentAim", "Controlador Iniciado. FOV e Binds ativos. Backend: " .. (activeBackendName or "Nenhum"))
    return "initialized"
end

function SilentAim.Destroy()
    if not isInitialized then return end

    if FOVLimit then FOVLimit.Destroy() end
    MarkStyle.Clear()
    Loop.UnbindFromRender("SilentAim_Controller")
    
    if SilentAim._inputBegan then SilentAim._inputBegan:Disconnect() end
    if SilentAim._inputEnded then SilentAim._inputEnded:Disconnect() end

    if activeBackendName then
        local backend = Registry.Get(activeBackendName)
        if backend then backend.destroy() end
    end

    lockedCharacter = nil
    activeBackendName = nil
    isInitialized = false
end

-- ==========================================
-- EXPORTAÇÃO PARA OS BACKENDS (A Mágica)
-- ==========================================
-- Os backends chamam essa função na hora do tiro para saber para onde dobrar a bala.
function SilentAim.GetLockedTargetPart(): BasePart?
    if not lockedCharacter or not UIState.Get(KEY_ENABLED, false) then return nil end
    local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
    return lockedCharacter:FindFirstChild(aimPartName) or lockedCharacter:FindFirstChild("HumanoidRootPart")
end

return SilentAim
