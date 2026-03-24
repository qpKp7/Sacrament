--!strict
--[[
    SACRAMENT | Universal Hook Backend (Pure Hookfunction Edition)
    Construído estritamente para executores que possuem hookfunction, mas não hookmetamethod.
    Sem câmera piscando. As balas dobram por baixo dos panos.
]]

local Workspace = game:GetService("Workspace")
local Import = (_G :: any).SacramentImport
local Telemetry = Import("logic/core/telemetry")
local UIState = Import("state/uistate")

local function SafeImport(path: string)
    local success, result = pcall(function() return Import(path) end)
    return success and result or nil
end
local Predict = SafeImport("logic/func/combat/shared/predict")

local UniversalHook = {}
UniversalHook._state = "unsupported"

-- Guarda as funções originais do motor do Roblox
local oldRaycast: any
local oldFindPartOnRayWithIgnoreList: any
local oldFindPartOnRayWithWhitelist: any
local oldFindPartOnRay: any

function UniversalHook.canLoad()
    -- Lendo a realidade do seu executor: Requer apenas hookfunction e newcclosure
    return (type(hookfunction) == "function" and type(newcclosure) == "function"), "Requer hookfunction e newcclosure ativos."
end

function UniversalHook.load()
    if UniversalHook._state == "initialized" then return "initialized" end
    local Controller = Import("logic/func/combat/silentaim/main")

    local KEY_PREDICT_VAL = "SilentAim_Prediction"

    local function GetPredictedPosition(targetPart: BasePart): Vector3
        if Predict and type(Predict.GetPosition) == "function" then
            local pValue = tonumber(UIState.Get(KEY_PREDICT_VAL, 0)) or 0
            return Predict.GetPosition(targetPart, pValue)
        end
        return targetPart.Position
    end

    local success, err = pcall(function()
        
        -- ==========================================
        -- 1. SEQUESTRO DA FÍSICA MODERNA (RAYCAST)
        -- ==========================================
        oldRaycast = hookfunction(Workspace.Raycast, newcclosure(function(self, origin, direction, params)
            -- Se não for o próprio script a atirar e tivermos um alvo...
            if not checkcaller() and Controller and type(Controller.GetLockedTargetPart) == "function" then
                local targetPart = Controller.GetLockedTargetPart()
                if targetPart and targetPart:IsA("BasePart") then
                    
                    local finalPos = GetPredictedPosition(targetPart)
                    -- Redireciona o vetor da bala (A MÁGICA)
                    local newDir = (finalPos - origin).Unit * direction.Magnitude
                    
                    return oldRaycast(self, origin, newDir, params)
                end
            end
            return oldRaycast(self, origin, direction, params)
        end))

        -- ==========================================
        -- 2. SEQUESTRO DA FÍSICA LEGADA (FindPartOnRay)
        -- ==========================================
        oldFindPartOnRayWithIgnoreList = hookfunction(Workspace.FindPartOnRayWithIgnoreList, newcclosure(function(self, ray, ignore, desc, water)
            if not checkcaller() and Controller and type(Controller.GetLockedTargetPart) == "function" then
                local targetPart = Controller.GetLockedTargetPart()
                if targetPart and targetPart:IsA("BasePart") then
                    local finalPos = GetPredictedPosition(targetPart)
                    local newDir = (finalPos - ray.Origin).Unit * ray.Direction.Magnitude
                    return oldFindPartOnRayWithIgnoreList(self, Ray.new(ray.Origin, newDir), ignore, desc, water)
                end
            end
            return oldFindPartOnRayWithIgnoreList(self, ray, ignore, desc, water)
        end))

        oldFindPartOnRayWithWhitelist = hookfunction(Workspace.FindPartOnRayWithWhitelist, newcclosure(function(self, ray, whitelist, ignoreWater)
            if not checkcaller() and Controller and type(Controller.GetLockedTargetPart) == "function" then
                local targetPart = Controller.GetLockedTargetPart()
                if targetPart and targetPart:IsA("BasePart") then
                    local finalPos = GetPredictedPosition(targetPart)
                    local newDir = (finalPos - ray.Origin).Unit * ray.Direction.Magnitude
                    return oldFindPartOnRayWithWhitelist(self, Ray.new(ray.Origin, newDir), whitelist, ignoreWater)
                end
            end
            return oldFindPartOnRayWithWhitelist(self, ray, whitelist, ignoreWater)
        end))

        oldFindPartOnRay = hookfunction(Workspace.FindPartOnRay, newcclosure(function(self, ray, ignore, water)
            if not checkcaller() and Controller and type(Controller.GetLockedTargetPart) == "function" then
                local targetPart = Controller.GetLockedTargetPart()
                if targetPart and targetPart:IsA("BasePart") then
                    local finalPos = GetPredictedPosition(targetPart)
                    local newDir = (finalPos - ray.Origin).Unit * ray.Direction.Magnitude
                    return oldFindPartOnRay(self, Ray.new(ray.Origin, newDir), ignore, water)
                end
            end
            return oldFindPartOnRay(self, ray, ignore, water)
        end))

    end)

    if not success then
        Telemetry.Log("ERROR", "UniversalHook", "Falha na Força Bruta: " .. tostring(err))
        return "failed"
    end

    UniversalHook._state = "initialized"
    Telemetry.Log("LITURGY", "SilentAim", "Hookfunction Puros Ativados! A câmera ficará imóvel.")
    return "initialized"
end

function UniversalHook.destroy()
    if UniversalHook._state ~= "initialized" then return end
    
    -- Restaura a física ao normal
    if type(hookfunction) == "function" then
        if oldRaycast then hookfunction(Workspace.Raycast, oldRaycast) end
        if oldFindPartOnRayWithIgnoreList then hookfunction(Workspace.FindPartOnRayWithIgnoreList, oldFindPartOnRayWithIgnoreList) end
        if oldFindPartOnRayWithWhitelist then hookfunction(Workspace.FindPartOnRayWithWhitelist, oldFindPartOnRayWithWhitelist) end
        if oldFindPartOnRay then hookfunction(Workspace.FindPartOnRay, oldFindPartOnRay) end
    end
    
    UniversalHook._state = "destroyed"
end

return UniversalHook
