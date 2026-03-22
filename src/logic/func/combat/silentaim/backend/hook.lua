--!strict
--[[
    SACRAMENT | Metamethod Backend (Universal)
    O código real do Silent Aim. Só é carregado se o executor suportar.
--]]

local Workspace = game:GetService("Workspace")
local Import = (_G :: any).SacramentImport

local UIState   = Import("state/uistate")
local Targeting = Import("logic/core/targeting")
local AimPart   = Import("logic/func/combat/shared/aimpart")
local Predict   = Import("logic/func/combat/shared/predict")
local HitChance = Import("logic/func/combat/silentaim/hitchance")
local FOVLimit  = Import("logic/func/combat/silentaim/fovlimit")
local MarkStyle = Import("logic/func/combat/silentaim/markstyle")

local HookBackend = {}
local oldNamecall: any = nil
local currentSilentTarget: BasePart? = nil

local function GetValidTarget(): BasePart?
    local fovRadius = tonumber(UIState.Get("SilentAim_FOV", 150)) or 150
    local target = Targeting.GetClosestToCursor(fovRadius, {"Head", "Torso", "HumanoidRootPart"}, false, false, false)
    local markOption = UIState.Get("SilentAim_MarkStyle", "None")
    MarkStyle.Mark(target, markOption)
    return target
end

function HookBackend.Init()
    if FOVLimit and type(FOVLimit.Init) == "function" then
        FOVLimit.Init()
    end

    -- Hooking Seguro (Sabemos que hookmetamethod existe porque o adaptador já validou)
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if not UIState.Get("SilentAim_Enabled", false) then return oldNamecall(self, unpack(args)) end
        
        local chance = tonumber(UIState.Get("SilentAim_HitChance", 100)) or 100
        if not HitChance.Roll(chance) then return oldNamecall(self, unpack(args)) end

        currentSilentTarget = GetValidTarget()
        if not currentSilentTarget then return oldNamecall(self, unpack(args)) end

        local finalPart = AimPart.GetTarget(currentSilentTarget.Parent :: Model, UIState.Get("SilentAim_AimPart", "Head"))
        if finalPart then
            local finalPos = Predict.GetPosition(finalPart, tonumber(UIState.Get("SilentAim_Predict", 0)) or 0, false)

            if method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" then
                args[1] = Ray.new(args[1].Origin, (finalPos - args[1].Origin).Unit * (args[1].Direction.Magnitude or 1000))
                return oldNamecall(self, unpack(args))
            elseif method == "Raycast" then
                args[2] = (finalPos - args[1]).Unit * (args[2].Magnitude or 1000)
                return oldNamecall(self, unpack(args))
            elseif method == "FireServer" and (self.Name == "RemoteEvent" or self.Name == "Shoot") then
                for i, v in ipairs(args) do
                    if typeof(v) == "Vector3" then args[i] = finalPos end
                end
                return oldNamecall(self, unpack(args))
            end
        end
        return oldNamecall(self, unpack(args))
    end))

    warn("[SACRAMENT] 🥷 Silent Aim Universal injetado com sucesso!")
end

function HookBackend.Destroy()
    if FOVLimit and type(FOVLimit.Destroy) == "function" then FOVLimit.Destroy() end
    MarkStyle.Clear()
    if oldNamecall then oldNamecall = nil end
end

return HookBackend
