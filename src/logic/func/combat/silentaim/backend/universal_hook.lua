--!strict
--[[
    SACRAMENT | Universal Hook Backend (Force-Hook Edition)
    Ignora bloqueios de __namecall e sequestra as funções diretamente via hookfunction.
    Compatível com Prison Life, Da Hood, Arsenal e frameworks modernos.
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

local oldRaycast: any
local oldFindPartIgnore: any
local oldFindPart: any
local oldFireServer: any

-- ==========================================
-- A VARREDURA PROFUNDA (Deep-Scan)
-- ==========================================
local function SpoofTableDeep(tbl: any, targetPos: Vector3, targetPart: BasePart)
    for k, v in pairs(tbl) do
        if type(v) == "Vector3" then
            tbl[k] = targetPos
        elseif type(v) == "CFrame" then
            tbl[k] = CFrame.new(targetPos)
        elseif typeof(v) == "Instance" and v:IsA("BasePart") and v:IsDescendantOf(Workspace) then
            tbl[k] = targetPart
        elseif typeof(v) == "Ray" then
            local newDir = (targetPos - v.Origin).Unit * v.Direction.Magnitude
            tbl[k] = Ray.new(v.Origin, newDir)
        elseif type(v) == "table" then
            SpoofTableDeep(v, targetPos, targetPart)
        end
    end
end

function UniversalHook.canLoad()
    return (type(hookfunction) == "function"), "Requer hookfunction nativo."
end

function UniversalHook.load()
    if UniversalHook._state == "initialized" then return "initialized" end
    local Controller = Import("logic/func/combat/silentaim/main")

    local KEY_PREDICT_VAL = "SilentAim_Prediction"

    local function GetPredictedPosition(targetPart: BasePart): Vector3
        if Predict and type(Predict.GetPosition) == "function" then
            local pValue = tonumber(UIState.Get(KEY_PREDICT_VAL, 0.135)) or 0.135
            local isAuto = UIState.Get("SilentAim_AutoPredict", false) == true or UIState.Get("SilentAim_AutoPredict", false) == "true"
            return Predict.GetPosition(targetPart, pValue, isAuto)
        end
        return targetPart.Position
    end

    local success, err = pcall(function()
        
        -- 1. SEQUESTRO DE REDE (FIRESERVER)
        local dummyEvent = Instance.new("RemoteEvent")
        oldFireServer = hookfunction(dummyEvent.FireServer, newcclosure(function(self, ...)
            local args = {...}
            if Controller and type(Controller.GetLockedTargetPart) == "function" then
                local targetPart = Controller.GetLockedTargetPart()
                if targetPart and targetPart:IsA("BasePart") then
                    local finalPos = GetPredictedPosition(targetPart)
                    local safeArgs = table.clone(args)
                    SpoofTableDeep(safeArgs, finalPos, targetPart)
                    return oldFireServer(self, unpack(safeArgs))
                end
            end
            return oldFireServer(self, ...)
        end))

        -- 2. SEQUESTRO DE FÍSICA MODERNA
        oldRaycast = hookfunction(Workspace.Raycast, newcclosure(function(self, origin, direction, params)
            if Controller and type(Controller.GetLockedTargetPart) == "function" then
                local targetPart = Controller.GetLockedTargetPart()
                if targetPart and targetPart:IsA("BasePart") then
                    local finalPos = GetPredictedPosition(targetPart)
                    local newDir = (finalPos - origin).Unit * direction.Magnitude
                    return oldRaycast(self, origin, newDir, params)
                end
            end
            return oldRaycast(self, origin, direction, params)
        end))

        -- 3. SEQUESTRO DE FÍSICA LEGADA
        oldFindPartIgnore = hookfunction(Workspace.FindPartOnRayWithIgnoreList, newcclosure(function(self, ray, ignore, desc, water)
            if Controller and type(Controller.GetLockedTargetPart) == "function" then
                local targetPart = Controller.GetLockedTargetPart()
                if targetPart and targetPart:IsA("BasePart") then
                    local finalPos = GetPredictedPosition(targetPart)
                    local newDir = (finalPos - ray.Origin).Unit * ray.Direction.Magnitude
                    return oldFindPartIgnore(self, Ray.new(ray.Origin, newDir), ignore, desc, water)
                end
            end
            return oldFindPartIgnore(self, ray, ignore, desc, water)
        end))

        oldFindPart = hookfunction(Workspace.FindPartOnRay, newcclosure(function(self, ray, ignore, water)
            if Controller and type(Controller.GetLockedTargetPart) == "function" then
                local targetPart = Controller.GetLockedTargetPart()
                if targetPart and targetPart:IsA("BasePart") then
                    local finalPos = GetPredictedPosition(targetPart)
                    local newDir = (finalPos - ray.Origin).Unit * ray.Direction.Magnitude
                    return oldFindPart(self, Ray.new(ray.Origin, newDir), ignore, water)
                end
            end
            return oldFindPart(self, ray, ignore, water)
        end))

    end)

    if not success then
        Telemetry.Log("ERROR", "UniversalHook", "Falha ao aplicar hooks: " .. tostring(err))
        return "failed"
    end

    UniversalHook._state = "initialized"
    Telemetry.Log("LITURGY", "SilentAim", "Universal Hook injetado via Força Bruta (hookfunction).")
    return "initialized"
end

function UniversalHook.destroy()
    if UniversalHook._state ~= "initialized" then return end
    if type(hookfunction) == "function" then
        if oldFireServer then hookfunction(Instance.new("RemoteEvent").FireServer, oldFireServer) end
        if oldRaycast then hookfunction(Workspace.Raycast, oldRaycast) end
        if oldFindPartIgnore then hookfunction(Workspace.FindPartOnRayWithIgnoreList, oldFindPartIgnore) end
        if oldFindPart then hookfunction(Workspace.FindPartOnRay, oldFindPart) end
    end
    UniversalHook._state = "destroyed"
end

return UniversalHook
