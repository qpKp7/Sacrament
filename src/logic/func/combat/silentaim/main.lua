--!strict
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Import = (_G :: any).SacramentImport

local UIState    = Import("state/uistate")
local Targeting  = Import("logic/core/targeting")
local AimPart    = Import("logic/func/combat/shared/aimpart")
local Predict    = Import("logic/func/combat/shared/predict")

local HitChance  = Import("logic/func/combat/silentaim/hitchance")
local FOVLimit   = Import("logic/func/combat/silentaim/fovlimit")
local MarkStyle  = Import("logic/func/combat/silentaim/markstyle")

local SilentAim = {}
local isInitialized = false
local oldNamecall: any = nil
local currentSilentTarget: BasePart? = nil

local function GetValidTarget(): BasePart?
    local fovRadius = tonumber(UIState.Get("SilentAim_FOV", 150)) or 150
    local useWallCheck = UIState.Get("SilentAim_WallCheck", false)
    local useKnockCheck = UIState.Get("SilentAim_KnockCheck", false)
    local useTeamCheck = UIState.Get("SilentAim_TeamCheck", false)

    local targetPart = Targeting.GetClosestToCursor(fovRadius, {"Head", "Torso", "HumanoidRootPart"}, useWallCheck, useKnockCheck, useTeamCheck)
    
    local markOption = UIState.Get("SilentAim_MarkStyle", "None")
    MarkStyle.Mark(targetPart, markOption)
    
    return targetPart
end

function SilentAim.Init()
    if isInitialized then return end
    isInitialized = true

    if FOVLimit and type(FOVLimit.Init) == "function" then
        FOVLimit.Init()
    end

    warn("[SACRAMENT] ⏳ Forçando a inicialização do Silent Aim Universal...")

    -- FORÇANDO O HOOK METAMETHOD (Ignorando os avisos do executor)
    local success, err = pcall(function()
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            local isEnabled = UIState.Get("SilentAim_Enabled", false)
            if not isEnabled then return oldNamecall(self, unpack(args)) end

            local chance = tonumber(UIState.Get("SilentAim_HitChance", 100)) or 100
            if not HitChance.Roll(chance) then return oldNamecall(self, unpack(args)) end

            currentSilentTarget = GetValidTarget()
            if not currentSilentTarget then return oldNamecall(self, unpack(args)) end

            local aimPartOpt = UIState.Get("SilentAim_AimPart", "Head")
            local predictVal = tonumber(UIState.Get("SilentAim_Predict", 0)) or 0
            
            local character = currentSilentTarget.Parent :: Model
            local finalPart = AimPart.GetTarget(character, aimPartOpt)

            if finalPart then
                local finalPos = finalPart.Position
                if predictVal > 0 then finalPos = Predict.GetPosition(finalPart, predictVal, false) end

                if method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" or method == "FindPartOnRayWithWhitelist" then
                    local originalRay = args[1]
                    local newDirection = (finalPos - originalRay.Origin).Unit * (originalRay.Direction.Magnitude or 1000)
                    args[1] = Ray.new(originalRay.Origin, newDirection)
                    return oldNamecall(self, unpack(args))

                elseif method == "Raycast" then
                    local origin = args[1]
                    local originalDirection = args[2]
                    args[2] = (finalPos - origin).Unit * (originalDirection.Magnitude or 1000)
                    return oldNamecall(self, unpack(args))

                elseif method == "FireServer" and (self.Name == "RemoteEvent" or self.Name == "Shoot" or self.Name == "Fire") then
                    for i, v in ipairs(args) do
                        if typeof(v) == "Vector3" then args[i] = finalPos
                        elseif typeof(v) == "CFrame" then args[i] = CFrame.new(v.Position, finalPos) end
                    end
                    return oldNamecall(self, unpack(args))
                end
            end
            return oldNamecall(self, unpack(args))
        end))
    end)

    if success then
        warn("[SACRAMENT] 🥷 Silent Aim carregado com sucesso! As balas devem dobrar agora.")
    else
        warn("[SACRAMENT] ❌ ERRO DO EXECUTOR: Ele tentou usar o hookmetamethod e crashou. Motivo técnico: " .. tostring(err))
    end
end

function SilentAim.Destroy()
    if not isInitialized then return end
    if FOVLimit and type(FOVLimit.Destroy) == "function" then FOVLimit.Destroy() end
    MarkStyle.Clear()
    if oldNamecall then oldNamecall = nil end
    isInitialized = false
end

return SilentAim
