--!strict
--[[
    SACRAMENT | Silent Aim Master Controller (Híbrido Legit/Global)
    Gerencia Visuais, Inputs e Validação de FOV Dinâmica (Liga/Desliga).
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

-- Chaves de Estado da UI
local KEY_ENABLED     = "SilentAimEnabled"
local KEY_BIND        = "SilentAim_Keybind"
local KEY_HOLD        = "SilentAim_KeyHold"
local KEY_USE_FOV     = "SilentAim_UseFov"   -- Toggle: Ligar/Desligar restrição de FOV
local KEY_FOV_RADIUS  = "SilentAim_FovLimit"
local KEY_AIM_PART    = "SilentAim_AimPart"
local KEY_WALL_CHECK  = "SilentAim_WallCheck"
local KEY_KNOCK_CHECK = "SilentAim_KnockCheck"
local KEY_MARK_STYLE  = "SilentAim_MarkStyle"

-- ==========================================
-- RITO DE ARMAMENTO (PRE-REGISTRATION)
-- ==========================================
local function PreRegisterBackends()
    pcall(function()
        if type(Registry.Register) == "function" then
            Registry.Register("flick_adapter", Import("logic/func/combat/silentaim/backend/flick_adapter"))
            Registry.Register("mouse_spoof", Import("logic/func/combat/silentaim/backend/mouse_spoof"))
            Registry.Register("physical_raycast", Import("logic/func/combat/silentaim/backend/physical_raycast"))
        end
    end)
end
PreRegisterBackends()

-- ==========================================
-- LÓGICA DE TARGETING (AQUISIÇÃO INICIAL)
-- ==========================================
local function AcquireTarget(): Model?
    -- Se o FOV estiver desligado, o raio de busca é INFINITO (math.huge)
    local useFov = UIState.Get(KEY_USE_FOV, true)
    local fovRadius = useFov and (tonumber(UIState.Get(KEY_FOV_RADIUS, 150)) or 150) or math.huge
    
    local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
    if aimPartName == "Random" or aimPartName == "Closest" then aimPartName = "HumanoidRootPart" end
    
    local wallCheck = UIState.Get(KEY_WALL_CHECK, false)
    local knockCheck = UIState.Get(KEY_KNOCK_CHECK, false)
    
    local targetPart = Targeting.GetClosestToCursor(fovRadius, {aimPartName, "HumanoidRootPart"}, wallCheck, knockCheck, false)
    if targetPart and targetPart.Parent then return targetPart.Parent :: Model end
    return nil
end

-- ==========================================
-- CICLO DE VIDA PRINCIPAL
-- ==========================================
function SilentAim.Init()
    if isInitialized then return "initialized" end

    if FOVLimit and type(FOVLimit.Init) == "function" then FOVLimit.Init() end

    SilentAim._inputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not UIState.Get(KEY_ENABLED, false) then return end
        
        local bind = UIState.Get(KEY_BIND, "None")
        if bind and bind ~= "None" and input.KeyCode.Name == bind then
            if UIState.Get(KEY_HOLD, false) then
                lockedCharacter = AcquireTarget()
            else
                if lockedCharacter then 
                    lockedCharacter = nil; MarkStyle.Clear()
                else 
                    lockedCharacter = AcquireTarget()
                end
            end
        end
    end)

    SilentAim._inputEnded = UserInputService.InputEnded:Connect(function(input, gpe)
        local bind = UIState.Get(KEY_BIND, "None")
        if bind and bind ~= "None" and input.KeyCode.Name == bind then
            if UIState.Get(KEY_HOLD, false) then
                lockedCharacter = nil; MarkStyle.Clear()
            end
        end
    end)

    -- Loop de Validação Contínua (60 FPS)
    Loop.BindToRender("SilentAim_Controller", function()
        if not UIState.Get(KEY_ENABLED, false) then 
            lockedCharacter = nil; MarkStyle.Clear(); return 
        end

        if lockedCharacter then
            local hum = lockedCharacter:FindFirstChildOfClass("Humanoid")
            local isKnocked = UIState.Get(KEY_KNOCK_CHECK, false) and KnockCheck and KnockCheck.IsKnocked(Players:GetPlayerFromCharacter(lockedCharacter))
            local targetRoot = lockedCharacter:FindFirstChild("HumanoidRootPart") :: BasePart
            
            if not lockedCharacter.Parent or not hum or hum.Health <= 0 or isKnocked or not targetRoot then
                lockedCharacter = nil; MarkStyle.Clear(); return
            end

            -- VALIDAÇÃO DINÂMICA (FOV ON vs FOV OFF)
            local useFov = UIState.Get(KEY_USE_FOV, true)
            if useFov then
                local camera = Workspace.CurrentCamera
                if camera then
                    local screenPos, onScreen = camera:WorldToViewportPoint(targetRoot.Position)
                    local fovRadius = tonumber(UIState.Get(KEY_FOV_RADIUS, 150)) or 150
                    local mousePos = UserInputService:GetMouseLocation()
                    
                    -- Quebra a trava APENAS se o sistema de FOV estiver ativado e o alvo sair da área
                    if not onScreen or (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude > fovRadius then
                        lockedCharacter = nil
                        MarkStyle.Clear()
                        return
                    end
                end
            end

            local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
            if aimPartName == "Random" or aimPartName == "Closest" then aimPartName = "HumanoidRootPart" end
            local markPart = lockedCharacter:FindFirstChild(aimPartName) or targetRoot
            
            if markPart then MarkStyle.Mark(markPart, UIState.Get(KEY_MARK_STYLE, "Highlight")) end
        else
            MarkStyle.Clear()
        end
    end)

    local BACKEND_CHAIN = { "flick_adapter", "mouse_spoof", "physical_raycast" }
    for _, backendName in ipairs(BACKEND_CHAIN) do
        local backend = Registry.Get(backendName)
        if backend and backend.canLoad() then
            if backend.load() == "initialized" then
                activeBackendName = backendName
                break
            end
        end
    end

    isInitialized = true
    Telemetry.Log("LITURGY", "SilentAim", "Controlador Híbrido Iniciado. Backend: " .. (activeBackendName or "Nenhum"))
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

    lockedCharacter = nil
    activeBackendName = nil
    isInitialized = false
end

-- ==========================================
-- EXPORTAÇÃO DE ALVO PARA O MOTOR DE TIRO
-- ==========================================
local bodyPartsList = {"Head", "UpperTorso", "LowerTorso", "RightUpperArm", "LeftUpperArm", "RightUpperLeg", "LeftUpperLeg"}

function SilentAim.GetLockedTargetPart(): BasePart?
    if not lockedCharacter or not UIState.Get(KEY_ENABLED, false) then return nil end
    
    local aimPartSetting = UIState.Get(KEY_AIM_PART, "Head")
    
    if aimPartSetting == "Random" then
        local validParts = {}
        for _, partName in ipairs(bodyPartsList) do
            local p = lockedCharacter:FindFirstChild(partName)
            if p and p:IsA("BasePart") then table.insert(validParts, p) end
        end
        if #validParts > 0 then return validParts[math.random(1, #validParts)] end
        return lockedCharacter:FindFirstChild("HumanoidRootPart")
    end
    
    if aimPartSetting == "Closest" then
        local camera = Workspace.CurrentCamera
        local mousePos = UserInputService:GetMouseLocation()
        local closestPart = nil
        local shortestDist = math.huge
        
        for _, partName in ipairs(bodyPartsList) do
            local p = lockedCharacter:FindFirstChild(partName)
            if p and p:IsA("BasePart") then
                local screenPos, onScreen = camera:WorldToViewportPoint(p.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestPart = p
                    end
                end
            end
        end
        return closestPart or lockedCharacter:FindFirstChild("HumanoidRootPart")
    end

    return lockedCharacter:FindFirstChild(aimPartSetting) or lockedCharacter:FindFirstChild("HumanoidRootPart")
end

return SilentAim
