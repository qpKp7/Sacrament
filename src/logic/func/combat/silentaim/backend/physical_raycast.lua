--!strict
--[[
    SACRAMENT | Physical Raycast Backend (Pure Interceptor)
    Apenas intercepta a física e pergunta ao main.lua para onde atirar.
]]

local Workspace = game:GetService("Workspace")
local Import = (_G :: any).SacramentImport
local Telemetry = Import("logic/core/telemetry")

local PhysicalRaycast = {}
PhysicalRaycast._state = "unsupported"
local oldRaycast: any

local function HookedRaycast(self: WorldRoot, origin: Vector3, direction: Vector3, params: RaycastParams?): RaycastResult?
    -- Carregamento Lazy (evita dependência circular no Luau)
    local Controller = Import("logic/func/combat/silentaim/main")
    
    if Controller and type(Controller.GetLockedTargetPart) == "function" then
        local targetPart = Controller.GetLockedTargetPart()
        
        -- Se o main.lua disser que temos um alvo travado, dobramos a bala
        if targetPart and targetPart:IsA("BasePart") then
            local targetPos = targetPart.Position
            local redirectedDirection = (targetPos - origin).Unit * direction.Magnitude
            
            local spoofedResult = oldRaycast(self, origin, redirectedDirection, params)
            if spoofedResult and spoofedResult.Instance then
                return spoofedResult
            end
        end
    end
    
    -- Tiro normal
    return oldRaycast(self, origin, direction, params)
end

function PhysicalRaycast.canLoad()
    return (type(hookfunction) == "function"), "Requer hookfunction."
end

function PhysicalRaycast.load()
    if PhysicalRaycast._state == "initialized" then return "initialized" end
    
    oldRaycast = hookfunction(Workspace.Raycast, newcclosure(HookedRaycast))
    
    PhysicalRaycast._state = "initialized"
    Telemetry.Log("LITURGY", "Raycast", "Hook nativo instalado com sucesso.")
    return "initialized"
end

function PhysicalRaycast.destroy()
    if PhysicalRaycast._state ~= "initialized" then return end
    if type(hookfunction) == "function" and oldRaycast then
        hookfunction(Workspace.Raycast, oldRaycast)
    end
    PhysicalRaycast._state = "destroyed"
end

return PhysicalRaycast
