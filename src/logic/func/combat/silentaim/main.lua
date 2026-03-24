--!strict
--[[
    SACRAMENT | Silent Aim Master Controller (Core Lethality)
    Foco absoluto em Targeting, Hit Chance e Hard Lock inquebrável.
]]

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Import = (_G :: any).SacramentImport
local Registry  = Import("logic/core/backend_registry")
local Telemetry = Import("logic/core/telemetry")
local UIState   = Import("state/uistate")
local Loop      = Import("logic/core/loop")
local Targeting = Import("logic/core/targeting")
local MarkStyle = Import("logic/func/combat/silentaim/markstyle")
local FOVLimit  = Import("logic/func/combat/silentaim/fovlimit")

local function SafeImport(path: string)
    local success, result = pcall(function() return Import(path) end)
    return success and result or nil
end
local KnockCheck = SafeImport("logic/func/combat/shared/knockcheck")

local SilentAim = {}
local isInitialized = false
local lockedCharacter: Model? = nil

-- Chaves de Estado da UI
local KEY_ENABLED     = "SilentAimEnabled"
local KEY_BIND        = "SilentAim_Keybind"
local KEY_HOLD        = "SilentAim_KeyHold"
local KEY_FOV_RADIUS  = "SilentAim_FovLimit"
local KEY_AIM_PART    = "SilentAim_AimPart"
local KEY_WALL_CHECK  = "SilentAim_WallCheck"
local KEY_KNOCK_CHECK = "SilentAim_KnockCheck"
local KEY_MARK_STYLE  = "SilentAim_MarkStyle"
local KEY_HIT_CHANCE  = "SilentAim_HitChance" -- Slider de 0 a 100

local function GetToggleState(key: string, default: boolean): boolean
    local val = UIState.Get(key, default)
    if val == "false" or val == 0 then return false end
    if val == "true" or val == 1 then return true end
    return val == true
end

local function IsBindMatch(input: InputObject): boolean
    local bind = UIState.Get(KEY_BIND, "None")
    if bind == "None" or bind == "" then return false end
    return input.KeyCode.Name == bind or input.UserInputType.Name == bind
end

-- ==========================================
-- AQUISIÇÃO DE ALVO
-- ==========================================
local function AcquireTarget(): Model?
    local fovRadius = tonumber(UIState.Get(KEY_FOV_RADIUS, 150)) or 150
    local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
    if aimPartName == "Random" or aimPartName == "Closest" then aimPartName = "HumanoidRootPart" end
    
    local targetPart = Targeting.GetClosestToCursor(fovRadius, {aimPartName, "HumanoidRootPart"}, GetToggleState(KEY_WALL_CHECK, false), GetToggleState(KEY_KNOCK_CHECK, false), false)
    if targetPart and targetPart.Parent then return targetPart.Parent :: Model end
    return nil
end

-- ==========================================
-- INICIALIZAÇÃO E CICLO DE VIDA
-- ==========================================
function SilentAim.Init()
    if isInitialized then return "initialized" end

    if FOVLimit and type(FOVLimit.Init) == "function" then FOVLimit.Init() end

    -- Registo exclusivo do Flick (Única via possível no seu Executor)
    pcall(function()
        if type(Registry.Register) == "function" then
            Registry.Register("flick_adapter", Import("logic/func/combat/silentaim/backend/flick_adapter"))
        end
    end)

    SilentAim._inputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not GetToggleState(KEY_ENABLED, false) then return end
        if IsBindMatch(input) then
            if GetToggleState(KEY_HOLD, false) then
                lockedCharacter = AcquireTarget()
            else
                if lockedCharacter then lockedCharacter = nil; MarkStyle.Clear() else lockedCharacter = AcquireTarget() end
            end
        end
    end)

    SilentAim._inputEnded = UserInputService.InputEnded:Connect(function(input, gpe)
        if IsBindMatch(input) and GetToggleState(KEY_HOLD, false) then
            lockedCharacter = nil; MarkStyle.Clear()
        end
    end)

    Loop.BindToRender("SilentAim_Controller", function()
        if not GetToggleState(KEY_ENABLED, false) then lockedCharacter = nil; MarkStyle.Clear(); return end
        if lockedCharacter then
            local hum = lockedCharacter:FindFirstChildOfClass("Humanoid")
            local isKnocked = GetToggleState(KEY_KNOCK_CHECK, false) and KnockCheck and KnockCheck.IsKnocked(Players:GetPlayerFromCharacter(lockedCharacter))
            local targetRoot = lockedCharacter:FindFirstChild("HumanoidRootPart") :: BasePart
            
            -- HARD LOCK: Só solta se o inimigo morrer ou cair
            if not lockedCharacter.Parent or not hum or hum.Health <= 0 or isKnocked or not targetRoot then
                lockedCharacter = nil; MarkStyle.Clear(); return
            end
            
            local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
            if aimPartName == "Random" or aimPartName == "Closest" then aimPartName = "HumanoidRootPart" end
            local markPart = lockedCharacter:FindFirstChild(aimPartName) or targetRoot
            
            if markPart then MarkStyle.Mark(markPart, UIState.Get(KEY_MARK_STYLE, "Highlight")) end
        else
            MarkStyle.Clear()
        end
    end)

    local backend = Registry.Get("flick_adapter")
    if backend and backend.canLoad() then backend.load() end

    isInitialized = true
    Telemetry.Log("LITURGY", "SilentAim", "Orquestrador Base Iniciado. Hit Chance e Absolute Aim ativados.")
    return "initialized"
end

function SilentAim.Destroy()
    if not isInitialized then return end
    if FOVLimit then FOVLimit.Destroy() end
    MarkStyle.Clear(); Loop.UnbindFromRender("SilentAim_Controller")
    if SilentAim._inputBegan then SilentAim._inputBegan:Disconnect() end
    if SilentAim._inputEnded then SilentAim._inputEnded:Disconnect() end
    local backend = Registry.Get("flick_adapter"); if backend then backend.destroy() end
    lockedCharacter = nil; isInitialized = false
end

-- ==========================================
-- EXPORTAÇÃO (COM CÁLCULO DE HIT CHANCE)
-- ==========================================
local bodyPartsList = {"Head", "UpperTorso", "LowerTorso", "RightUpperArm", "LeftUpperArm", "RightUpperLeg", "LeftUpperLeg"}

function SilentAim.GetLockedTargetPart(): BasePart?
    if not lockedCharacter or not GetToggleState(KEY_ENABLED, false) then return nil end
    local targetRoot = lockedCharacter:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return nil end

    -- MATEMÁTICA DE HIT CHANCE (0 a 100%)
    local hitChance = tonumber(UIState.Get(KEY_HIT_CHANCE, 100)) or 100
    if math.random(1, 100) > hitChance then
        -- Se falhou na probabilidade, retorna nil (A bala sairá reto, errando o alvo)
        return nil
    end

    local aimPartSetting = UIState.Get(KEY_AIM_PART, "Head")
    if aimPartSetting == "Random" then
        local validParts = {}
        for _, partName in ipairs(bodyPartsList) do
            local p = lockedCharacter:FindFirstChild(partName)
            if p and p:IsA("BasePart") then table.insert(validParts, p) end
        end
        return #validParts > 0 and validParts[math.random(1, #validParts)] or targetRoot
    end
    
    if aimPartSetting == "Closest" then
        local camera = Workspace.CurrentCamera
        local mousePos = UserInputService:GetMouseLocation()
        local closestPart, shortestDist = nil, math.huge
        for _, partName in ipairs(bodyPartsList) do
            local p = lockedCharacter:FindFirstChild(partName)
            if p and p:IsA("BasePart") then
                local screenPos, onScreen = camera:WorldToViewportPoint(p.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < shortestDist then shortestDist = dist; closestPart = p end
                end
            end
        end
        return closestPart or targetRoot
    end

    return lockedCharacter:FindFirstChild(aimPartSetting) or targetRoot
end

return SilentAim
