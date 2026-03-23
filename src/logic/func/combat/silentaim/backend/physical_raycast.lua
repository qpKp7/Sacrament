--!strict
--[[
    SACRAMENT | Physical Raycast Backend (The Vector Interceptor)
    Interceptação cirúrgica com suporte total a Targeting Lifecycle, Keybinds e UI State.
]]

local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Import = (_G :: any).SacramentImport

local UIState   = Import("state/uistate")
local Targeting = Import("logic/core/targeting")
local Telemetry = Import("logic/core/telemetry")
local MarkStyle = Import("logic/func/combat/silentaim/markstyle")
local FOVLimit  = Import("logic/func/combat/silentaim/fovlimit")
local Loop      = Import("logic/core/loop")
local KnockCheck = Import("logic/func/combat/shared/knockcheck")

local PhysicalRaycast = {}
PhysicalRaycast._state = "unsupported"

-- Chaves de Estado (Sincronizadas com a sua UI)
local KEY_ENABLED    = "SilentAimEnabled"
local KEY_BIND       = "SilentAim_Keybind"
local KEY_HOLD       = "SilentAim_KeyHold"
local KEY_FOV_RADIUS = "SilentAim_FovLimit"
local KEY_SHOW_FOV   = "SilentAim_ShowFov"
local KEY_AIM_PART   = "SilentAim_AimPart"
local KEY_WALL_CHECK = "SilentAim_WallCheck"
local KEY_KNOCK_CHECK= "SilentAim_KnockCheck"
local KEY_MARK_STYLE = "SilentAim_MarkStyle"

local oldRaycast: any
local lockedCharacter: Model? = nil

-- ==========================================
-- LÓGICA DE TARGETING (AQUISIÇÃO DE ALVO)
-- ==========================================
local function AcquireTarget(): Model?
    local fovRadius = tonumber(UIState.Get(KEY_FOV_RADIUS, 150)) or 150
    local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
    local wallCheck = UIState.Get(KEY_WALL_CHECK, false)
    local knockCheck = UIState.Get(KEY_KNOCK_CHECK, false)
    
    -- Utiliza a matemática do Vidente para achar o alvo dentro do círculo
    local targetPart = Targeting.GetClosestToCursor(
        fovRadius, 
        {aimPartName, "HumanoidRootPart"}, 
        wallCheck, 
        knockCheck, 
        false -- teamCheck pode ser adicionado aqui se necessário
    )
    
    if targetPart and targetPart.Parent then 
        return targetPart.Parent :: Model 
    end
    return nil
end

-- ==========================================
-- INTERCEPTAÇÃO FÍSICA (THE SURGICAL HOOK)
-- ==========================================
local function HookedRaycast(self: WorldRoot, origin: Vector3, direction: Vector3, params: RaycastParams?): RaycastResult?
    -- Se temos um alvo travado e o sistema está ativo
    if UIState.Get(KEY_ENABLED, false) and lockedCharacter then
        
        local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
        local targetPart = lockedCharacter:FindFirstChild(aimPartName) or lockedCharacter:FindFirstChild("HumanoidRootPart")
        
        if targetPart and targetPart:IsA("BasePart") then
            -- Matemática de Precisão Absoluta: Dobra a bala em direção ao alvo mantendo o alcance original da arma
            local targetPos = targetPart.Position
            local redirectedDirection = (targetPos - origin).Unit * direction.Magnitude
            
            local spoofedResult = oldRaycast(self, origin, redirectedDirection, params)
            if spoofedResult and spoofedResult.Instance then
                return spoofedResult
            end
        end
    end
    
    -- Fluxo natural se não houver alvo
    return oldRaycast(self, origin, direction, params)
end

-- ==========================================
-- CONTRATO DO BACKEND
-- ==========================================
function PhysicalRaycast.canLoad()
    return (type(hookfunction) == "function"), "Requer suporte nativo a hookfunction."
end

function PhysicalRaycast.load()
    if PhysicalRaycast._state == "initialized" then return "initialized" end

    -- Inicializa o Círculo de FOV
    if FOVLimit and type(FOVLimit.Init) == "function" then FOVLimit.Init() end

    -- GESTÃO DE INPUT (BIND / HOLD / TOGGLE)
    PhysicalRaycast._inputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not UIState.Get(KEY_ENABLED, false) then return end
        
        local bind = UIState.Get(KEY_BIND, "None")
        if bind and bind ~= "None" and input.KeyCode.Name == bind then
            if UIState.Get(KEY_HOLD, false) then
                -- Modo HOLD: Trava o alvo ao segurar a tecla
                lockedCharacter = AcquireTarget()
            else
                -- Modo TOGGLE: Alterna o alvo ao pressionar a tecla
                if lockedCharacter then 
                    lockedCharacter = nil
                    MarkStyle.Clear()
                else 
                    lockedCharacter = AcquireTarget() 
                end
            end
        end
    end)

    PhysicalRaycast._inputEnded = UserInputService.InputEnded:Connect(function(input, gpe)
        local bind = UIState.Get(KEY_BIND, "None")
        if bind and bind ~= "None" and input.KeyCode.Name == bind then
            if UIState.Get(KEY_HOLD, false) then
                -- Modo HOLD: Soltou a tecla, destrava o alvo
                lockedCharacter = nil
                MarkStyle.Clear()
            end
        end
    end)

    -- GESTÃO VISUAL E VALIDAÇÃO CONTÍNUA (60 FPS)
    Loop.BindToRender("SilentAim_Visuals", function()
        if not UIState.Get(KEY_ENABLED, false) then 
            MarkStyle.Clear()
            lockedCharacter = nil
            return 
        end

        -- Se houver um alvo travado, precisamos checar se ele continua válido (vivo e não nocauteado)
        if lockedCharacter then
            local hum = lockedCharacter:FindFirstChildOfClass("Humanoid")
            local isKnocked = UIState.Get(KEY_KNOCK_CHECK, false) and KnockCheck and KnockCheck.IsKnocked(Players:GetPlayerFromCharacter(lockedCharacter))
            
            if not lockedCharacter.Parent or not hum or hum.Health <= 0 or isKnocked then
                lockedCharacter = nil
                MarkStyle.Clear()
                return
            end

            -- Aplica o Highlight/MarkStyle no alvo atual
            local targetPart = lockedCharacter:FindFirstChild(UIState.Get(KEY_AIM_PART, "Head")) or lockedCharacter:FindFirstChild("HumanoidRootPart")
            if targetPart then 
                MarkStyle.Mark(targetPart, UIState.Get(KEY_MARK_STYLE, "Highlight")) 
            else 
                MarkStyle.Clear() 
            end
        else
            MarkStyle.Clear()
        end
    end)

    -- Aplica o Hook no motor de física
    oldRaycast = hookfunction(Workspace.Raycast, newcclosure(HookedRaycast))

    PhysicalRaycast._state = "initialized"
    Telemetry.Log("LITURGY", "SilentAim", "Backend physical_raycast → initialized | Lifecycle completo ativado")
    return "initialized"
end

function PhysicalRaycast.destroy()
    if PhysicalRaycast._state ~= "initialized" then return end
    
    -- Limpeza Cirúrgica (Prevenção de Leaks)
    Loop.UnbindFromRender("SilentAim_Visuals")
    if PhysicalRaycast._inputBegan then PhysicalRaycast._inputBegan:Disconnect() end
    if PhysicalRaycast._inputEnded then PhysicalRaycast._inputEnded:Disconnect() end
    if FOVLimit and type(FOVLimit.Destroy) == "function" then FOVLimit.Destroy() end
    
    MarkStyle.Clear()
    lockedCharacter = nil
    
    if type(hookfunction) == "function" and oldRaycast then
        hookfunction(Workspace.Raycast, oldRaycast)
    end
    
    PhysicalRaycast._state = "destroyed"
    Telemetry.Log("LITURGY", "SilentAim", "Backend physical_raycast → destroyed | Hooks e Binds purgados")
end

function PhysicalRaycast.health() return PhysicalRaycast._state or "unsupported" end
function PhysicalRaycast.requirements() return { "hookfunction", "newcclosure" } end

return PhysicalRaycast
