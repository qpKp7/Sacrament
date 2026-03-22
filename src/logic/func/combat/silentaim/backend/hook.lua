--!strict
--[[
    SACRAMENT | Hook Backend (Xeno Compatible)
    Redireciona os tiros usando hookfunction no Workspace.
]]
local Workspace = game:GetService("Workspace")
local Import = (_G :: any).SacramentImport

local UIState   = Import("state/uistate")
local Targeting = Import("logic/core/targeting")
local AimPart   = Import("logic/func/combat/shared/aimpart")
local Predict   = Import("logic/func/combat/shared/predict")
local HitChance = Import("logic/func/combat/silentaim/hitchance")
local FOVLimit  = Import("logic/func/combat/silentaim/fovlimit")
local MarkStyle = Import("logic/func/combat/silentaim/markstyle")
local Telemetry = Import("logic/core/telemetry")
local Capability= Import("logic/core/capability")

local HookBackend = {}
local isInitialized = false

local oldRaycast: any
local oldFindPartIgnore: any

local function GetValidTarget(): BasePart?
    local fovRadius = tonumber(UIState.Get("SilentAim_FOV", 150)) or 150
    local target = Targeting.GetClosestToCursor(fovRadius, {"Head", "Torso", "HumanoidRootPart"}, false, false, false)
    MarkStyle.Mark(target, UIState.Get("SilentAim_MarkStyle", "None"))
    return target
end

-- 1. O Contrato: Ele pode ser carregado?
function HookBackend.canLoad()
    local caps = Capability.Get()
    if caps.SupportsHookFunc then
        return true, "hookfunction suportado."
    end
    return false, "O executor não suporta hookfunction."
end

-- 2. O Contrato: Inicializa a máquina
function HookBackend.load()
    if isInitialized then return "initialized" end

    -- Liga o FOV visual
    if FOVLimit and type(FOVLimit.Init) == "function" then
        FOVLimit.Init()
    end

    local success, err = pcall(function()
        oldRaycast = hookfunction(Workspace.Raycast, function(self, origin, direction, params)
            if not UIState.Get("SilentAim_Enabled", false) then return oldRaycast(self, origin, direction, params) end
            if not HitChance.Roll(tonumber(UIState.Get("SilentAim_HitChance", 100)) or 100) then return oldRaycast(self, origin, direction, params) end

            local target = GetValidTarget()
            if target then
                local finalPart = AimPart.GetTarget(target.Parent :: Model, UIState.Get("SilentAim_AimPart", "Head"))
                if finalPart then
                    local finalPos = Predict.GetPosition(finalPart, tonumber(UIState.Get("SilentAim_Predict", 0)) or 0, false)
                    local newDirection = (finalPos - origin).Unit * direction.Magnitude
                    return oldRaycast(self, origin, newDirection, params)
                end
            end
            return oldRaycast(self, origin, direction, params)
        end)

        oldFindPartIgnore = hookfunction(Workspace.FindPartOnRayWithIgnoreList, function(self, ray, ignore, desc, water)
            if not UIState.Get("SilentAim_Enabled", false) then return oldFindPartIgnore(self, ray, ignore, desc, water) end
            local target = GetValidTarget()
            if target then
                local finalPart = AimPart.GetTarget(target.Parent :: Model, UIState.Get("SilentAim_AimPart", "Head"))
                if finalPart then
                    local finalPos = Predict.GetPosition(finalPart, tonumber(UIState.Get("SilentAim_Predict", 0)) or 0, false)
                    local newDirection = (finalPos - ray.Origin).Unit * ray.Direction.Magnitude
                    return oldFindPartIgnore(self, Ray.new(ray.Origin, newDirection), ignore, desc, water)
                end
            end
            return oldFindPartIgnore(self, ray, ignore, desc, water)
        end)
    end)

    if not success then
        Telemetry.Log("ERROR", "SilentAim", "Falha ao injetar hookfunction: " .. tostring(err))
        return "failed"
    end

    isInitialized = true
    Telemetry.Log("INFO", "SilentAim", "Interceptação de disparo ativada com sucesso (HookFunction).")
    return "initialized"
end

-- 3. O Contrato: Limpeza
function HookBackend.destroy()
    if not isInitialized then return end
    if FOVLimit and type(FOVLimit.Destroy) == "function" then FOVLimit.Destroy() end
    MarkStyle.Clear()
    isInitialized = false
end

-- 4. O Contrato: Status
function HookBackend.health()
    return isInitialized and "initialized" or "unsupported"
end

function HookBackend.requirements()
    return {SupportsHookFunc = true}
end

function HookBackend.assumptions()
    return "O jogo valida disparo via Workspace:Raycast ou FindPartOnRay."
end

return HookBackend
