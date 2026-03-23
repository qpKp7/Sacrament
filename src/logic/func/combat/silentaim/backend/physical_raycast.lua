--!strict
--[[
    SACRAMENT | Physical Raycast Backend (Omni-Interceptor)
    Intercepta a física moderna (Raycast) e toda a família legada (FindPartOnRay).
]]

local Workspace = game:GetService("Workspace")
local Import = (_G :: any).SacramentImport
local Telemetry = Import("logic/core/telemetry")

local PhysicalRaycast = {}
PhysicalRaycast._state = "unsupported"

-- Ponteiros para as funções originais do motor
local oldRaycast: any
local oldFindPartOnRayWithIgnoreList: any
local oldFindPartOnRayWithWhitelist: any
local oldFindPartOnRay: any

-- ==========================================
-- MOTOR MATEMÁTICO DE REDIRECIONAMENTO
-- ==========================================
local function GetRedirectedDirection(origin: Vector3, originalDirection: Vector3): Vector3
    local Controller = Import("logic/func/combat/silentaim/main")
    
    if Controller and type(Controller.GetLockedTargetPart) == "function" then
        local targetPart = Controller.GetLockedTargetPart()
        
        -- Se temos um alvo válido, recalculamos o vetor mantendo a magnitude (alcance) da arma original
        if targetPart and targetPart:IsA("BasePart") then
            return (targetPart.Position - origin).Unit * originalDirection.Magnitude
        end
    end
    
    -- Se não houver alvo travado, devolve o tiro natural
    return originalDirection
end

-- ==========================================
-- RITOS DE INTERCEPTAÇÃO (HOOKS)
-- ==========================================

-- 1. Física Moderna
local function HookedRaycast(self: WorldRoot, origin: Vector3, direction: Vector3, params: RaycastParams?): RaycastResult?
    local newDirection = GetRedirectedDirection(origin, direction)
    local result = oldRaycast(self, origin, newDirection, params)
    return result
end

-- 2. Física Legada (Muito comum em frameworks de FPS clássicos)
local function HookedFindPartOnRayWithIgnoreList(self: WorldRoot, ray: Ray, ignoreDescendantsTable: {Instance}?, terrainCellsAreCubes: boolean?, ignoreWater: boolean?): (BasePart?, Vector3, Vector3, Material)
    local newDirection = GetRedirectedDirection(ray.Origin, ray.Direction)
    local spoofedRay = Ray.new(ray.Origin, newDirection)
    return oldFindPartOnRayWithIgnoreList(self, spoofedRay, ignoreDescendantsTable, terrainCellsAreCubes, ignoreWater)
end

-- 3. Física Legada (Whitelist)
local function HookedFindPartOnRayWithWhitelist(self: WorldRoot, ray: Ray, whitelistDescendantsTable: {Instance}, ignoreWater: boolean?): (BasePart?, Vector3, Vector3, Material)
    local newDirection = GetRedirectedDirection(ray.Origin, ray.Direction)
    local spoofedRay = Ray.new(ray.Origin, newDirection)
    return oldFindPartOnRayWithWhitelist(self, spoofedRay, whitelistDescendantsTable, ignoreWater)
end

-- 4. Física Legada (Simples)
local function HookedFindPartOnRay(self: WorldRoot, ray: Ray, ignoreDescendantsInstance: Instance?, terrainCellsAreCubes: boolean?, ignoreWater: boolean?): (BasePart?, Vector3, Vector3, Material)
    local newDirection = GetRedirectedDirection(ray.Origin, ray.Direction)
    local spoofedRay = Ray.new(ray.Origin, newDirection)
    return oldFindPartOnRay(self, spoofedRay, ignoreDescendantsInstance, terrainCellsAreCubes, ignoreWater)
end

-- ==========================================
-- CONTRATO DO BACKEND
-- ==========================================
function PhysicalRaycast.canLoad()
    return (type(hookfunction) == "function"), "Requer suporte nativo a hookfunction."
end

function PhysicalRaycast.load()
    if PhysicalRaycast._state == "initialized" then return "initialized" end
    
    -- Aplica os grampos em todas as vias possíveis de disparo
    oldRaycast = hookfunction(Workspace.Raycast, newcclosure(HookedRaycast))
    oldFindPartOnRayWithIgnoreList = hookfunction(Workspace.FindPartOnRayWithIgnoreList, newcclosure(HookedFindPartOnRayWithIgnoreList))
    oldFindPartOnRayWithWhitelist = hookfunction(Workspace.FindPartOnRayWithWhitelist, newcclosure(HookedFindPartOnRayWithWhitelist))
    oldFindPartOnRay = hookfunction(Workspace.FindPartOnRay, newcclosure(HookedFindPartOnRay))
    
    PhysicalRaycast._state = "initialized"
    Telemetry.Log("LITURGY", "Raycast", "Omni-Interceptor instalado. Todas as vias físicas foram grampeadas.")
    return "initialized"
end

function PhysicalRaycast.destroy()
    if PhysicalRaycast._state ~= "initialized" then return end
    
    -- Restauração segura para evitar Memory Leaks ou Crash
    if type(hookfunction) == "function" then
        if oldRaycast then hookfunction(Workspace.Raycast, oldRaycast) end
        if oldFindPartOnRayWithIgnoreList then hookfunction(Workspace.FindPartOnRayWithIgnoreList, oldFindPartOnRayWithIgnoreList) end
        if oldFindPartOnRayWithWhitelist then hookfunction(Workspace.FindPartOnRayWithWhitelist, oldFindPartOnRayWithWhitelist) end
        if oldFindPartOnRay then hookfunction(Workspace.FindPartOnRay, oldFindPartOnRay) end
    end
    
    PhysicalRaycast._state = "destroyed"
end

return PhysicalRaycast
