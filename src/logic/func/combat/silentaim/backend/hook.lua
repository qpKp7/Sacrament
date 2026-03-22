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
local Loop      = Import("logic/core/loop") -- [NOVO] Precisamos do Loop para os visuais

local HookBackend = {}
local isInitialized = false

local oldRaycast: any
local oldFindPartIgnore: any

-- Função limpa para buscar o alvo sem poluir com desenhos
local function GetTargetForShoot(): BasePart?
    local fovRadius = tonumber(UIState.Get("SilentAim_FOV", 150)) or 150
    return Targeting.GetClosestToCursor(fovRadius, {"Head", "Torso", "HumanoidRootPart"}, false, false, false)
end

function HookBackend.canLoad()
    local caps = Capability.Get()
    if caps.SupportsHookFunc then return true, "hookfunction suportado." end
    return false, "O executor não suporta hookfunction."
end

function HookBackend.load()
    if isInitialized then return "initialized" end

    -- Inicializa a lógica do FOV Limit
    if FOVLimit and type(FOVLimit.Init) == "function" then FOVLimit.Init() end

    -- =========================================================
    -- [NOVO] LOOP VISUAL: Roda 60x por segundo para desenhar a UI
    -- =========================================================
    Loop.BindToRender("SilentAim_Visuals", function()
        if not UIState.Get("SilentAim_Enabled", false) then
            MarkStyle.Clear()
            return
        end
        
        -- Desenha a bolinha/highlight no alvo mais próximo constantemente
        local target = GetTargetForShoot()
        if target then
            local markOption = UIState.Get("SilentAim_MarkStyle", "None")
            MarkStyle.Mark(target, markOption)
        else
            MarkStyle.Clear()
        end
    end)

    -- =========================================================
    -- HOOKS DE INTERCEPTAÇÃO (O TIRO REAL)
    -- =========================================================
    local success, err = pcall(function()
        
        -- Hook 1: Raycast Moderno
        oldRaycast = hookfunction(Workspace.Raycast, function(self, origin, direction, params)
            if not UIState.Get("SilentAim_Enabled", false) then return oldRaycast(self, origin, direction, params) end
            if not HitChance.Roll(tonumber(UIState.Get("SilentAim_HitChance", 100)) or 100) then return oldRaycast(self, origin, direction, params) end

            local target = GetTargetForShoot()
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

        -- Hook 2: Raycast Antigo (Da Hood, etc)
        oldFindPartIgnore = hookfunction(Workspace.FindPartOnRayWithIgnoreList, function(self, ray, ignore, desc, water)
            if not UIState.Get("SilentAim_Enabled", false) then return oldFindPartIgnore(self, ray, ignore, desc, water) end
            if not HitChance.Roll(tonumber(UIState.Get("SilentAim_HitChance", 100)) or 100) then return oldFindPartIgnore(self, ray, ignore, desc, water) end

            local target = GetTargetForShoot()
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

function HookBackend.destroy()
    if not isInitialized then return end
    Loop.UnbindFromRender("SilentAim_Visuals")
    if FOVLimit and type(FOVLimit.Destroy) == "function" then FOVLimit.Destroy() end
    MarkStyle.Clear()
    isInitialized = false
end

function HookBackend.health() return isInitialized and "initialized" or "unsupported" end
function HookBackend.requirements() return {SupportsHookFunc = true} end
function HookBackend.assumptions() return "O jogo valida disparo via Workspace:Raycast ou FindPartOnRay." end

return HookBackend
