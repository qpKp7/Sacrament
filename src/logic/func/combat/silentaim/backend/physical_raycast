--!strict
--[[
    SACRAMENT | Physical Raycast Backend (The Vector Interceptor)
    Intercepta chamadas nativas de Workspace:Raycast.
    Redireciona o vetor direcional com precisão matemática absoluta para garantir um RaycastResult legítimo.
]]

local Workspace = game:GetService("Workspace")
local Import = (_G :: any).SacramentImport

local UIState   = Import("state/uistate")
local Targeting = Import("logic/core/targeting")
local Telemetry = Import("logic/core/telemetry")
local MarkStyle = Import("logic/func/combat/silentaim/markstyle")
local Loop      = Import("logic/core/loop")

local PhysicalRaycast = {}
PhysicalRaycast._state = "unsupported"

-- Chaves de Estado partilhadas (UI Contract)
local KEY_ENABLED    = "SilentAimEnabled"
local KEY_FOV_RADIUS = "SilentAim_FovLimit"
local KEY_AIM_PART   = "SilentAim_AimPart"
local KEY_WALL_CHECK = "SilentAim_WallCheck"
local KEY_MARK_STYLE = "SilentAim_MarkStyle"

local oldRaycast: any
local currentTarget: BasePart? = nil

-- Função Interna: Aquisição Contínua do Alvo
local function UpdateTarget()
    if not UIState.Get(KEY_ENABLED, false) then 
        currentTarget = nil
        return 
    end

    local fovRadius = tonumber(UIState.Get(KEY_FOV_RADIUS, 150)) or 150
    local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
    local wallCheck = UIState.Get(KEY_WALL_CHECK, false)
    
    currentTarget = Targeting.GetClosestToCursor(fovRadius, {aimPartName, "HumanoidRootPart"}, wallCheck, false, false)
end

-- ==========================================
-- RITO DE INTERCEÇÃO (THE SURGICAL HOOK)
-- ==========================================
local function HookedRaycast(self: WorldRoot, origin: Vector3, direction: Vector3, params: RaycastParams?): RaycastResult?
    -- Se o sistema estiver ativo e tivermos um alvo validado
    if UIState.Get(KEY_ENABLED, false) and currentTarget then
        
        -- PRECISÃO ABSOLUTA: 
        -- Calculamos a diferença entre a posição do alvo e a origem do tiro.
        -- Normalizamos o vetor (.Unit) e multiplicamos pela magnitude do tiro original 
        -- para preservar o alcance máximo da arma estipulado pelo programador do jogo.
        local targetPosition = currentTarget.Position
        local redirectedDirection = (targetPosition - origin).Unit * direction.Magnitude
        
        -- Chamamos a função nativa com a direção falsificada. 
        -- O motor C++ do Roblox trata do resto, devolvendo um RaycastResult imaculado.
        local spoofedResult = oldRaycast(self, origin, redirectedDirection, params)
        
        if spoofedResult and spoofedResult.Instance then
            return spoofedResult
        end
    end
    
    -- Se não houver alvo ou o Silent Aim estiver desligado, o fluxo segue normalmente.
    return oldRaycast(self, origin, direction, params)
end

-- ==========================================
-- CONTRATO DO BACKEND
-- ==========================================
function PhysicalRaycast.canLoad()
    local success, _ = pcall(function()
        return type(hookfunction) == "function" and type(newcclosure) == "function"
    end)
    
    if success then
        return true, "Suporte a hookfunction detectado (Compatível com Xeno/Executores Modernos)"
    end
    return false, "O executor carece de funções de manipulação de memória (hookfunction)"
end

function PhysicalRaycast.load()
    if PhysicalRaycast._state == "initialized" then return "initialized" end

    -- Regista o ciclo visual e de aquisição de alvos em sincronia com o motor (60 FPS)
    Loop.BindToRender("SilentAim_RaycastLogic", function()
        UpdateTarget()
        
        if currentTarget then
            MarkStyle.Mark(currentTarget, UIState.Get(KEY_MARK_STYLE, "Highlight"))
        else
            MarkStyle.Clear()
        end
    end)

    -- Aplica o Hook na metatable C do Workspace de forma silenciosa
    oldRaycast = hookfunction(Workspace.Raycast, newcclosure(HookedRaycast))

    PhysicalRaycast._state = "initialized"
    Telemetry.Log("LITURGY", "SilentAim", "Backend physical_raycast → initialized | Workspace:Raycast interceptado com sucesso")
    return "initialized"
end

function PhysicalRaycast.destroy()
    if PhysicalRaycast._state ~= "initialized" then return end
    
    Loop.UnbindFromRender("SilentAim_RaycastLogic")
    MarkStyle.Clear()
    currentTarget = nil
    
    -- Restaura a função original para evitar memory leaks caso o Sacrament seja descarregado
    if type(hookfunction) == "function" and oldRaycast then
        hookfunction(Workspace.Raycast, oldRaycast)
    end
    
    PhysicalRaycast._state = "destroyed"
    Telemetry.Log("LITURGY", "SilentAim", "Backend physical_raycast → destroyed | Hooks de física purgados")
end

function PhysicalRaycast.health() return PhysicalRaycast._state or "unsupported" end
function PhysicalRaycast.requirements() return { "hookfunction", "newcclosure" } end
function PhysicalRaycast.assumptions() return "Interceptação de vetor físico direta. Requer armas baseadas em Workspace:Raycast." end

return PhysicalRaycast
