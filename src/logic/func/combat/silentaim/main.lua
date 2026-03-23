--!strict
--[[
    SACRAMENT | Silent Aim Master Controller (Perfect Legit & Hard Lock)
    Mantém o alvo travado infinitamente, mas só curva os tiros se ele estiver dentro do FOV.
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
local activeBackendName: string? = nil
local lockedCharacter: Model? = nil

local KEY_ENABLED     = "SilentAimEnabled"
local KEY_BIND        = "SilentAim_Keybind"
local KEY_HOLD        = "SilentAim_KeyHold"
local KEY_USE_FOV     = "SilentAim_UseFov"
local KEY_FOV_RADIUS  = "SilentAim_FovLimit"
local KEY_AIM_PART    = "SilentAim_AimPart"
local KEY_WALL_CHECK  = "SilentAim_WallCheck"
local KEY_KNOCK_CHECK = "SilentAim_KnockCheck"
local KEY_MARK_STYLE  = "SilentAim_MarkStyle"

-- ==========================================
-- ANALISADOR ESTRITO
-- ==========================================
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
-- RITO DE ARMAMENTO
-- ==========================================
local function PreRegisterBackends()
    pcall(function()
        if type(Registry.Register) == "function" then
            -- Note que agora usamos o universal_hook como arma principal
            Registry.Register("universal_hook", Import("logic/func/combat/silentaim/backend/universal_hook"))
        end
    end)
end
PreRegisterBackends()

-- ==========================================
-- AQUISIÇÃO E CICLO DE VIDA (HARD LOCK)
-- ==========================================
local function AcquireTarget(): Model?
    local useFov = GetToggleState(KEY_USE_FOV, true)
    local fovRadius = useFov and (tonumber(UIState.Get(KEY_FOV_RADIUS, 150)) or 150) or math.huge
    local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
    if aimPartName == "Random" or aimPartName == "Closest" then aimPartName = "HumanoidRootPart" end
    
    local targetPart = Targeting.GetClosestToCursor(fovRadius, {aimPartName, "HumanoidRootPart"}, GetToggleState(KEY_WALL_CHECK, false), GetToggleState(KEY_KNOCK_CHECK, false), false)
    if targetPart and targetPart.Parent then return targetPart.Parent :: Model end
    return nil
end

function SilentAim.Init()
    if isInitialized then return "initialized" end
    if FOVLimit and type(FOVLimit.Init) == "function" then FOVLimit.Init() end

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

    -- Carrega a nova joia da coroa: O Hook Universal
    local backend = Registry.Get("universal_hook")
    if backend and backend.canLoad() and backend.load() == "initialized" then
        activeBackendName = "universal_hook"
    else
        Telemetry.Log("ERROR", "SilentAim", "O executor não suporta metatables modernas.")
    end

    isInitialized = true
    return "initialized"
end

function SilentAim.Destroy()
    if not isInitialized then return end
    if FOVLimit then FOVLimit.Destroy() end
    MarkStyle.Clear()
    Loop.UnbindFromRender("SilentAim_Controller")
    if SilentAim._inputBegan then SilentAim._inputBegan:Disconnect() end
    if SilentAim._inputEnded then SilentAim._inputEnded:Disconnect() end
    if activeBackendName then
        local backend = Registry.Get(activeBackendName)
        if backend then backend.destroy() end
    end
    lockedCharacter = nil; activeBackendName = nil; isInitialized = false
end

-- ==========================================
-- A LÓGICA DE GATILHO (BALAS SÓ DOBRAM DENTRO DO FOV)
-- ==========================================
local bodyPartsList = {"Head", "UpperTorso", "LowerTorso", "RightUpperArm", "LeftUpperArm", "RightUpperLeg", "LeftUpperLeg"}

function SilentAim.GetLockedTargetPart(): BasePart?
    if not lockedCharacter or not GetToggleState(KEY_ENABLED, false) then return nil end
    local targetRoot = lockedCharacter:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return nil end

    -- VALIDAÇÃO DA LENTE: Se o alvo estiver fora do FOV, os tiros vão retos (Retorna nil para o backend)
    if GetToggleState(KEY_USE_FOV, true) then
        local camera = Workspace.CurrentCamera
        if camera then
            local screenPos, onScreen = camera:WorldToViewportPoint(targetRoot.Position)
            local fovRadius = tonumber(UIState.Get(KEY_FOV_RADIUS, 150)) or 150
            local mousePos = UserInputService:GetMouseLocation()
            
            if not onScreen or (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude > fovRadius then
                -- O alvo está travado (highlight ligado), mas você não está a apontar a arma para perto dele.
                return nil 
            end
        end
    end

    -- Se ele estiver dentro do FOV, escolhemos com precisão matemática a parte do corpo
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
