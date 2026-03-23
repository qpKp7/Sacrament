--!strict
--[[
    SACRAMENT | Mouse Spoof Backend (The Legacy Fix)
    Intercepta chamadas nativas de Mouse.Hit e Mouse.Target.
    Obedece estritamente ao Backend Contract.
]]
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Import = (_G :: any).SacramentImport

local UIState   = Import("state/uistate")
local Targeting = Import("logic/core/targeting")
local Loop      = Import("logic/core/loop")
local MarkStyle = Import("logic/func/combat/silentaim/markstyle")
local Telemetry = Import("logic/core/telemetry")
local FOVLimit  = Import("logic/func/combat/silentaim/fovlimit")

local MouseSpoof = {}
MouseSpoof._state = "unsupported"

-- Chaves sincronizadas da UI
local KEY_ENABLED     = "SilentAimEnabled"
local KEY_FOV_RADIUS  = "SilentAim_FovLimit"
local KEY_MARK_STYLE  = "SilentAim_MarkStyle"
local KEY_AIM_PART    = "SilentAim_AimPart"
local KEY_WALL_CHECK  = "SilentAim_WallCheck"
local KEY_BIND        = "SilentAim_Keybind"
local KEY_HOLD        = "SilentAim_KeyHold"

local lockedCharacter: Model? = nil
local oldIndex: any

-- Busca rigorosa do Target
local function GetCharacterAtCursor(): Model?
    local fovRadius = tonumber(UIState.Get(KEY_FOV_RADIUS, 150)) or 150
    local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
    local wallCheck = UIState.Get(KEY_WALL_CHECK, false)
    
    local targetPart = Targeting.GetClosestToCursor(fovRadius, {aimPartName, "HumanoidRootPart"}, wallCheck, false, false)
    if targetPart and targetPart.Parent then return targetPart.Parent :: Model end
    return nil
end

-- Valida se o tiro deve dobrar (Dentro do FOV e Vivo)
local function GetSpoofData(): (CFrame?, BasePart?)
    if not lockedCharacter or not lockedCharacter.Parent then return nil, nil end
    local hum = lockedCharacter:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return nil, nil end

    local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
    local realPart = lockedCharacter:FindFirstChild(aimPartName) or lockedCharacter:FindFirstChild("HumanoidRootPart")
    if not realPart or not realPart:IsA("BasePart") then return nil, nil end

    local camera = Workspace.CurrentCamera
    if not camera then return nil, nil end
    local screenPos, onScreen = camera:WorldToViewportPoint(realPart.Position)
    if not onScreen then return nil, nil end 

    local mousePos = UserInputService:GetMouseLocation()
    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
    local fovRadius = tonumber(UIState.Get(KEY_FOV_RADIUS, 150)) or 150

    if dist <= fovRadius then
        return realPart.CFrame, realPart
    end
    return nil, nil
end

-- ==========================================
-- CONTRATO DO BACKEND
-- ==========================================
function MouseSpoof.canLoad()
    local success, result = pcall(function()
        local mouse = Players.LocalPlayer:GetMouse()
        local mt = getrawmetatable(mouse)
        return (mt ~= nil and type(mt.__index) == "function")
    end)
    
    if success and result then
        return true, "Mouse metatable acessível"
    end
    return false, "O executor não consegue acessar a metatable do Mouse"
end

function MouseSpoof._testSpoofLocally()
    local success, err = pcall(function()
        local mouse = Players.LocalPlayer:GetMouse()
        local mt = getrawmetatable(mouse)
        setreadonly(mt, false)
        local testOld = mt.__index
        setreadonly(mt, true)
    end)
    return success
end

function MouseSpoof.load()
    if MouseSpoof._state == "initialized" then return "initialized" end

    -- Teste local de segurança antes de marcar initialized (Fail-Closed)
    if not MouseSpoof._testSpoofLocally() then
        MouseSpoof._state = "unsupported"
        Telemetry.Log("LITURGY", "SilentAim", "Backend mouse_spoof → unsupported | Razão: Falha no teste local de setreadonly.")
        return "unsupported"
    end

    if FOVLimit and type(FOVLimit.Init) == "function" then FOVLimit.Init() end

    -- TRAVA (KEYBIND)
    MouseSpoof._inputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not UIState.Get(KEY_ENABLED, false) then return end
        local bind = UIState.Get(KEY_BIND, "None")
        if bind and bind ~= "None" and input.KeyCode.Name == bind then
            if UIState.Get(KEY_HOLD, false) then
                lockedCharacter = GetCharacterAtCursor()
            else
                if lockedCharacter then lockedCharacter = nil; MarkStyle.Clear() else lockedCharacter = GetCharacterAtCursor() end
            end
        end
    end)

    MouseSpoof._inputEnded = UserInputService.InputEnded:Connect(function(input, gpe)
        local bind = UIState.Get(KEY_BIND, "None")
        if bind and bind ~= "None" and input.KeyCode.Name == bind then
            if UIState.Get(KEY_HOLD, false) then lockedCharacter = nil; MarkStyle.Clear() end
        end
    end)

    -- VISUALS (HIGHLIGHT)
    Loop.BindToRender("SilentAim_Visuals", function()
        if not UIState.Get(KEY_ENABLED, false) or not lockedCharacter then MarkStyle.Clear(); return end
        local hum = lockedCharacter:FindFirstChildOfClass("Humanoid")
        if not lockedCharacter.Parent or not hum or hum.Health <= 0 then lockedCharacter = nil; MarkStyle.Clear(); return end

        local targetPart = lockedCharacter:FindFirstChild(UIState.Get(KEY_AIM_PART, "Head")) or lockedCharacter:FindFirstChild("HumanoidRootPart")
        if targetPart then MarkStyle.Mark(targetPart, UIState.Get(KEY_MARK_STYLE, "Highlight")) else MarkStyle.Clear() end
    end)

    -- A MÁGICA DE SPOOF DO MOUSE
    local mouse = Players.LocalPlayer:GetMouse()
    local mt = getrawmetatable(mouse)
    setreadonly(mt, false)
    oldIndex = mt.__index

    mt.__index = newcclosure(function(t, k)
        if UIState.Get(KEY_ENABLED, false) and (k == "Hit" or k == "Target") then
            local spoofCFrame, spoofPart = GetSpoofData()
            if spoofCFrame and spoofPart then
                if k == "Hit" then return spoofCFrame end
                if k == "Target" then return spoofPart end
            end
        end
        return oldIndex(t, k)
    end)

    setreadonly(mt, true)

    MouseSpoof._state = "initialized"
    Telemetry.Log("LITURGY", "SilentAim", "Backend mouse_spoof → initialized | Pipeline Mouse.Hit spoofado")
    return "initialized"
end

function MouseSpoof.destroy()
    if MouseSpoof._state ~= "initialized" then return end
    Loop.UnbindFromRender("SilentAim_Visuals")
    if MouseSpoof._inputBegan then MouseSpoof._inputBegan:Disconnect() end
    if MouseSpoof._inputEnded then MouseSpoof._inputEnded:Disconnect() end
    if FOVLimit and type(FOVLimit.Destroy) == "function" then FOVLimit.Destroy() end
    
    -- Restaura o Mouse
    local success = pcall(function()
        local mouse = Players.LocalPlayer:GetMouse()
        local mt = getrawmetatable(mouse)
        setreadonly(mt, false)
        mt.__index = oldIndex
        setreadonly(mt, true)
    end)

    MarkStyle.Clear()
    lockedCharacter = nil
    MouseSpoof._state = "destroyed"
    Telemetry.Log("LITURGY", "SilentAim", "Backend mouse_spoof → destroyed | Limpeza segura concluída")
end

function MouseSpoof.health() return MouseSpoof._state or "unsupported" end
function MouseSpoof.requirements() return { "getrawmetatable", "setreadonly" } end
function MouseSpoof.assumptions() return "Pipeline baseado em Mouse.Hit / Mouse.Target (jogos legacy)" end

return MouseSpoof
