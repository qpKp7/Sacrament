--!strict
--[[
    SACRAMENT | Mathematical Redirection Backend (True Silent Aim)
    Abandona a Hitbox. Intercepta os pacotes de rede e Raios (Raycasts)
    e redireciona matematicamente para o alvo dentro do FOV.
]]
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Import = (_G :: any).SacramentImport

local UIState   = Import("state/uistate")
local Targeting = Import("logic/core/targeting")
local Loop      = Import("logic/core/loop")
local MarkStyle = Import("logic/func/combat/silentaim/markstyle")
local Telemetry = Import("logic/core/telemetry")
local FOVLimit  = Import("logic/func/combat/silentaim/fovlimit")

local HookBackend = {}
local isInitialized = false

-- Chaves sincronizadas da sua UI
local KEY_ENABLED     = "SilentAimEnabled"
local KEY_FOV_RADIUS  = "SilentAim_FovLimit"
local KEY_MARK_STYLE  = "SilentAim_MarkStyle"
local KEY_AIM_PART    = "SilentAim_AimPart"
local KEY_WALL_CHECK  = "SilentAim_WallCheck"

local oldFireServer: any
local oldRaycast: any

-- Pega APENAS quem estiver mais perto do mouse, respeitando FOV e Parede
local function GetTargetPart(): BasePart?
    local fovRadius = tonumber(UIState.Get(KEY_FOV_RADIUS, 150)) or 150
    local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
    local wallCheck = UIState.Get(KEY_WALL_CHECK, false)
    
    return Targeting.GetClosestToCursor(fovRadius, {aimPartName, "HumanoidRootPart"}, wallCheck, false, false)
end

function HookBackend.canLoad() return true, "Mathematical Redirector pronto." end

function HookBackend.load()
    if isInitialized then return "initialized" end
    if FOVLimit and type(FOVLimit.Init) == "function" then FOVLimit.Init() end

    -- 1. LOOP VISUAL (Apenas para a Bolinha/Highlight ficar no alvo)
    Loop.BindToRender("SilentAim_Visuals", function()
        if not UIState.Get(KEY_ENABLED, false) then
            MarkStyle.Clear()
            return
        end
        local target = GetTargetPart()
        if target then
            MarkStyle.Mark(target, UIState.Get(KEY_MARK_STYLE, "None"))
        else
            MarkStyle.Clear()
        end
    end)

    -- 2. A MAGIA MATEMÁTICA (Interceptação de Rede e Física)
    local success, err = pcall(function()
        
        -- Hook de RemoteEvent (Intercepta o tiro do Da Hood e afins)
        local fakeEvent = Instance.new("RemoteEvent")
        oldFireServer = hookfunction(fakeEvent.FireServer, function(self, ...)
            local args = {...}
            
            if UIState.Get(KEY_ENABLED, false) then
                local target = GetTargetPart()
                if target then
                    -- Vasculha o que o jogo está mandando pro servidor e troca pela posição do inimigo
                    for i, value in pairs(args) do
                        if typeof(value) == "Vector3" then
                            args[i] = target.Position
                        elseif typeof(value) == "CFrame" then
                            args[i] = target.CFrame
                        end
                    end
                end
            end
            return oldFireServer(self, unpack(args))
        end)

        -- Hook de Raycast (Para jogos mais modernos)
        oldRaycast = hookfunction(Workspace.Raycast, function(self, origin, direction, params)
            if UIState.Get(KEY_ENABLED, false) then
                local target = GetTargetPart()
                if target then
                    -- Calcula a nova direção da bala para ir reto na cabeça do alvo
                    local newDirection = (target.Position - origin).Unit * direction.Magnitude
                    return oldRaycast(self, origin, newDirection, params)
                end
            end
            return oldRaycast(self, origin, direction, params)
        end)

    end)

    if not success then
        Telemetry.Log("ERROR", "SilentAim", "Falha ao interceptar pacotes: " .. tostring(err))
        return "failed"
    end

    isInitialized = true
    Telemetry.Log("INFO", "SilentAim", "Redireção Matemática Ativada com Sucesso.")
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
function HookBackend.assumptions() return "Uso de Redireção de Vetores em RemoteEvents e Raycasts." end

return HookBackend
