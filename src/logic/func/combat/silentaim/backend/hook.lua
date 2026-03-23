--!strict
--[[
    SACRAMENT | Mathematical Redirection (Deep-Scan Edition)
    - Varredura profunda em Tabelas e Objetos Ray (Corrige Prison Life/Arsenal).
    - Redireciona a bala não importa como o jogo empacote a informação.
]]
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Import = (_G :: any).SacramentImport

local UIState   = Import("state/uistate")
local Targeting = Import("logic/core/targeting")
local Loop      = Import("logic/core/loop")
local MarkStyle = Import("logic/func/combat/silentaim/markstyle")
local Telemetry = Import("logic/core/telemetry")
local FOVLimit  = Import("logic/func/combat/silentaim/fovlimit")

local HookBackend = {}
local isInitialized = false

-- Chaves da UI
local KEY_ENABLED     = "SilentAimEnabled"
local KEY_FOV_RADIUS  = "SilentAim_FovLimit"
local KEY_MARK_STYLE  = "SilentAim_MarkStyle"
local KEY_AIM_PART    = "SilentAim_AimPart"
local KEY_WALL_CHECK  = "SilentAim_WallCheck"
local KEY_BIND        = "SilentAim_Keybind"
local KEY_HOLD        = "SilentAim_KeyHold"

local oldFireServer: any
local oldRaycast: any
local oldFindPartIgnore: any
local oldFindPart: any

local lockedCharacter: Model? = nil

local function GetCharacterAtCursor(): Model?
    local fovRadius = tonumber(UIState.Get(KEY_FOV_RADIUS, 150)) or 150
    local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
    local wallCheck = UIState.Get(KEY_WALL_CHECK, false)
    
    local targetPart = Targeting.GetClosestToCursor(fovRadius, {aimPartName, "HumanoidRootPart"}, wallCheck, false, false)
    if targetPart and targetPart.Parent then return targetPart.Parent :: Model end
    return nil
end

local function GetCalculatedTargetPosition(): (Vector3?, BasePart?)
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
        return realPart.Position, realPart
    end
    return nil, nil
end

-- =======================================================
-- VARREDURA PROFUNDA (O CORAÇÃO DO PRISON LIFE)
-- =======================================================
local function SpoofTableDeep(tbl: any, targetPos: Vector3, targetPart: BasePart)
    for k, v in pairs(tbl) do
        if type(v) == "Vector3" then
            tbl[k] = targetPos
        elseif type(v) == "CFrame" then
            tbl[k] = CFrame.new(targetPos)
        elseif typeof(v) == "Instance" and v:IsA("BasePart") and v:IsDescendantOf(Workspace) then
            tbl[k] = targetPart
        elseif typeof(v) == "Ray" then
            -- MÁGICA: Redireciona o Ray object para a cabeça do inimigo
            local newDir = (targetPos - v.Origin).Unit * v.Direction.Magnitude
            tbl[k] = Ray.new(v.Origin, newDir)
        elseif type(v) == "table" then
            -- Se for uma tabela dentro de uma tabela, vasculha também
            SpoofTableDeep(v, targetPos, targetPart)
        end
    end
end

function HookBackend.canLoad() return true, "Deep-Scan Redirector pronto." end

function HookBackend.load()
    if isInitialized then return "initialized" end
    if FOVLimit and type(FOVLimit.Init) == "function" then FOVLimit.Init() end

    HookBackend._inputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
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

    HookBackend._inputEnded = UserInputService.InputEnded:Connect(function(input, gpe)
        local bind = UIState.Get(KEY_BIND, "None")
        if bind and bind ~= "None" and input.KeyCode.Name == bind then
            if UIState.Get(KEY_HOLD, false) then lockedCharacter = nil; MarkStyle.Clear() end
        end
    end)

    Loop.BindToRender("SilentAim_Visuals", function()
        if not UIState.Get(KEY_ENABLED, false) or not lockedCharacter then MarkStyle.Clear(); return end
        local hum = lockedCharacter:FindFirstChildOfClass("Humanoid")
        if not lockedCharacter.Parent or not hum or hum.Health <= 0 then lockedCharacter = nil; MarkStyle.Clear(); return end

        local targetPart = lockedCharacter:FindFirstChild(UIState.Get(KEY_AIM_PART, "Head")) or lockedCharacter:FindFirstChild("HumanoidRootPart")
        if targetPart then MarkStyle.Mark(targetPart, UIState.Get(KEY_MARK_STYLE, "Highlight")) else MarkStyle.Clear() end
    end)

    local success, err = pcall(function()
        
        -- INTERCEPTAÇÃO DE REDE COM VARREDURA (Resolve Prison Life e Da Hood)
        local fakeEvent = Instance.new("RemoteEvent")
        oldFireServer = hookfunction(fakeEvent.FireServer, function(self, ...)
            local args = {...}
            if UIState.Get(KEY_ENABLED, false) then
                local targetPos, targetPart = GetCalculatedTargetPosition()
                if targetPos and targetPart then
                    SpoofTableDeep(args, targetPos, targetPart)
                end
            end
            return oldFireServer(self, unpack(args))
        end)

        -- INTERCEPTAÇÃO DE FÍSICA E RAYCASTS
        oldRaycast = hookfunction(Workspace.Raycast, function(self, origin, direction, params)
            if UIState.Get(KEY_ENABLED, false) then
                local targetPos, _ = GetCalculatedTargetPosition()
                if targetPos then
                    local newDir = (targetPos - origin).Unit * direction.Magnitude
                    return oldRaycast(self, origin, newDir, params)
                end
            end
            return oldRaycast(self, origin, direction, params)
        end)

        oldFindPartIgnore = hookfunction(Workspace.FindPartOnRayWithIgnoreList, function(self, ray, ignore, desc, water)
            if UIState.Get(KEY_ENABLED, false) then
                local targetPos, _ = GetCalculatedTargetPosition()
                if targetPos then
                    local newDir = (targetPos - ray.Origin).Unit * ray.Direction.Magnitude
                    return oldFindPartIgnore(self, Ray.new(ray.Origin, newDir), ignore, desc, water)
                end
            end
            return oldFindPartIgnore(self, ray, ignore, desc, water)
        end)

        oldFindPart = hookfunction(Workspace.FindPartOnRay, function(self, ray, ignore, water)
            if UIState.Get(KEY_ENABLED, false) then
                local targetPos, _ = GetCalculatedTargetPosition()
                if targetPos then
                    local newDir = (targetPos - ray.Origin).Unit * ray.Direction.Magnitude
                    return oldFindPart(self, Ray.new(ray.Origin, newDir), ignore, water)
                end
            end
            return oldFindPart(self, ray, ignore, water)
        end)

    end)

    if not success then return "failed" end

    isInitialized = true
    return "initialized"
end

function HookBackend.destroy()
    if not isInitialized then return end
    Loop.UnbindFromRender("SilentAim_Visuals")
    if HookBackend._inputBegan then HookBackend._inputBegan:Disconnect() end
    if HookBackend._inputEnded then HookBackend._inputEnded:Disconnect() end
    if FOVLimit and type(FOVLimit.Destroy) == "function" then FOVLimit.Destroy() end
    MarkStyle.Clear(); lockedCharacter = nil; isInitialized = false
end

function HookBackend.health() return isInitialized and "initialized" or "unsupported" end
function HookBackend.requirements() return {SupportsHookFunc = true} end
function HookBackend.assumptions() return "Deep-Scan em RemoteEvents e Raycasts." end

return HookBackend
