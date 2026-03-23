--!strict
--[[
    SACRAMENT | Universal Hook Backend (The Deep-Scan Interceptor)
    Funde o Hooking Metamethod moderno com a varredura profunda em RemoteEvents.
    Imóvel. Indetectável. Absoluto.
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

local oldNamecall: any
local oldIndex: any

-- ==========================================
-- A VARREDURA PROFUNDA (SpoofTableDeep)
-- ==========================================
-- Vasculha argumentos de RemoteEvents em busca de qualquer coordenada balística
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
    return (type(hookmetamethod) == "function"), "Requer hookmetamethod nativo do executor."
end

function UniversalHook.load()
    if UniversalHook._state == "initialized" then return "initialized" end
    local Controller = Import("logic/func/combat/silentaim/main")

    local KEY_PREDICT_VAL = "SilentAim_Prediction"
    local KEY_AUTO_PREDICT = "SilentAim_AutoPredict"

    local function GetPredictedPosition(targetPart: BasePart): Vector3
        if Predict and type(Predict.GetPosition) == "function" then
            local pValue = tonumber(UIState.Get(KEY_PREDICT_VAL, 0.135)) or 0.135
            local isAuto = UIState.Get("SilentAim_AutoPredict", false) == true or UIState.Get("SilentAim_AutoPredict", false) == "true"
            return Predict.GetPosition(targetPart, pValue, isAuto)
        end
        return targetPart.Position
    end

    -- ==========================================
    -- THE NAMECALL HOOK (Rede e Física Moderna)
    -- ==========================================
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if not checkcaller() and Controller and type(Controller.GetLockedTargetPart) == "function" then
            local targetPart = Controller.GetLockedTargetPart()
            
            if targetPart and targetPart:IsA("BasePart") then
                local finalPos = GetPredictedPosition(targetPart)

                -- 1. Redirecionamento de Física Moderna (Raycast)
                if method == "Raycast" then
                    local origin = args[1]
                    local direction = args[2]
                    args[2] = (finalPos - origin).Unit * direction.Magnitude
                    return oldNamecall(self, unpack(args))
                
                -- 2. Redirecionamento de Física Legada
                elseif string.find(method, "FindPartOnRay") then
                    local ray = args[1]
                    local newDir = (finalPos - ray.Origin).Unit * ray.Direction.Magnitude
                    args[1] = Ray.new(ray.Origin, newDir)
                    return oldNamecall(self, unpack(args))

                -- 3. Redirecionamento de Dados (Deep-Scan em FireServer)
                elseif method == "FireServer" or method == "fireServer" then
                    -- Clonamos a tabela de argumentos para evitar travar threads de metatables
                    local safeArgs = table.clone(args)
                    SpoofTableDeep(safeArgs, finalPos, targetPart)
                    return oldNamecall(self, unpack(safeArgs))
                end
            end
        end

        return oldNamecall(self, ...)
    end)

    -- ==========================================
    -- THE INDEX HOOK (Legacy Mouse.Hit)
    -- ==========================================
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if not checkcaller() and typeof(self) == "Instance" and self:IsA("Mouse") and Controller and type(Controller.GetLockedTargetPart) == "function" then
            local targetPart = Controller.GetLockedTargetPart()
            
            if targetPart and targetPart:IsA("BasePart") then
                if key == "Hit" then
                    local finalPos = GetPredictedPosition(targetPart)
                    return CFrame.new(finalPos)
                elseif key == "Target" then
                    return targetPart
                end
            end
        end

        return oldIndex(self, key)
    end)

    UniversalHook._state = "initialized"
    Telemetry.Log("LITURGY", "SilentAim", "Universal Hook injetado com Deep-Scan. Compatibilidade máxima ativa.")
    return "initialized"
end

function UniversalHook.destroy()
    if UniversalHook._state ~= "initialized" then return end
    
    if type(hookmetamethod) == "function" then
        if oldNamecall then hookmetamethod(game, "__namecall", oldNamecall) end
        if oldIndex then hookmetamethod(game, "__index", oldIndex) end
    end
    
    UniversalHook._state = "destroyed"
end

return UniversalHook
