--!strict
--[[
    SACRAMENT | Universal FPS Redirection (True Silent Aim)
    - Suporte a 90% dos FPS: Arsenal, Da Hood, Prison Life, Phantom Forces, etc.
    - Intercepta 5 camadas de física e rede nativas do Roblox.
    - Inclui Prediction (Predição de Movimento) e HitChance.
    - Exclusivo por BIND + Verificação rígida de FOV.
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
local Predict   = Import("logic/func/combat/shared/predict") -- [NOVO] Essencial para FPS
local HitChance = Import("logic/func/combat/silentaim/hitchance") -- [NOVO] Essencial para disfarce

local HookBackend = {}
local isInitialized = false

-- Chaves sincronizadas da UI
local KEY_ENABLED     = "SilentAimEnabled"
local KEY_FOV_RADIUS  = "SilentAim_FovLimit"
local KEY_MARK_STYLE  = "SilentAim_MarkStyle"
local KEY_AIM_PART    = "SilentAim_AimPart"
local KEY_WALL_CHECK  = "SilentAim_WallCheck"
local KEY_BIND        = "SilentAim_Keybind"
local KEY_HOLD        = "SilentAim_KeyHold"
local KEY_PREDICT     = "SilentAim_Predict"
local KEY_HITCHANCE   = "SilentAim_HitChance"

-- Variáveis dos Hooks Universais
local oldRaycast: any
local oldFindPartIgnore: any
local oldFindPartWhite: any
local oldFindPart: any
local oldFireServer: any

-- Memória do alvo travado
local lockedCharacter: Model? = nil

-- Busca o Character no momento em que aperta a Bind
local function GetCharacterAtCursor(): Model?
    local fovRadius = tonumber(UIState.Get(KEY_FOV_RADIUS, 150)) or 150
    local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
    local wallCheck = UIState.Get(KEY_WALL_CHECK, false)
    
    local targetPart = Targeting.GetClosestToCursor(fovRadius, {aimPartName, "HumanoidRootPart"}, wallCheck, false, false)
    if targetPart and targetPart.Parent then
        return targetPart.Parent :: Model
    end
    return nil
end

-- Condição de disparo: Valida FOV, Vida, Trava e aplica Prediction
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
        -- Aplica o HitChance (se falhar, retorna nil para atirar normal e disfarçar)
        local chance = tonumber(UIState.Get(KEY_HITCHANCE, 100)) or 100
        if HitChance and type(HitChance.Roll) == "function" and not HitChance.Roll(chance) then
            return nil, nil
        end

        -- Aplica a Predição (Prediction) para FPS rápidos
        local predValue = tonumber(UIState.Get(KEY_PREDICT, 0)) or 0
        local finalPosition = realPart.Position
        if Predict and type(Predict.GetPosition) == "function" and predValue > 0 then
            finalPosition = Predict.GetPosition(realPart, predValue, false)
        end

        return finalPosition, realPart
    end

    return nil, nil
end

function HookBackend.canLoad() return true, "Universal FPS Redirector suportado." end

function HookBackend.load()
    if isInitialized then return "initialized" end
    if FOVLimit and type(FOVLimit.Init) == "function" then FOVLimit.Init() end

    -- =======================================================
    -- SISTEMA DE TRAVA (BIND)
    -- =======================================================
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

    -- =======================================================
    -- RENDERIZAÇÃO VISUAL (HIGHLIGHT)
    -- =======================================================
    Loop.BindToRender("SilentAim_Visuals", function()
        if not UIState.Get(KEY_ENABLED, false) or not lockedCharacter then MarkStyle.Clear(); return end
        
        local hum = lockedCharacter:FindFirstChildOfClass("Humanoid")
        if not lockedCharacter.Parent or not hum or hum.Health <= 0 then
            lockedCharacter = nil
            MarkStyle.Clear()
            return
        end

        local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
        local targetPart = lockedCharacter:FindFirstChild(aimPartName) or lockedCharacter:FindFirstChild("HumanoidRootPart")
        
        if targetPart then
            MarkStyle.Mark(targetPart, UIState.Get(KEY_MARK_STYLE, "Highlight"))
        else
            MarkStyle.Clear()
        end
    end)

    -- =======================================================
    -- O NÚCLEO UNIVERSAL (5 CAMADAS DE INTERCEPTAÇÃO)
    -- =======================================================
    local success, err = pcall(function()
        
        -- 1. Raycast Moderno (Arsenal, Frontlines, Phantom Forces, etc)
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

        -- 2. Legacy: FindPartOnRayWithIgnoreList (Da Hood, Prison Life, etc)
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

        -- 3. Legacy: FindPartOnRayWithWhitelist (Alguns FPS baseados em zumbis/PVE)
        oldFindPartWhite = hookfunction(Workspace.FindPartOnRayWithWhitelist, function(self, ray, whitelist, ignore)
            if UIState.Get(KEY_ENABLED, false) then
                local targetPos, _ = GetCalculatedTargetPosition()
                if targetPos then
                    local newDir = (targetPos - ray.Origin).Unit * ray.Direction.Magnitude
                    return oldFindPartWhite(self, Ray.new(ray.Origin, newDir), whitelist, ignore)
                end
            end
            return oldFindPartWhite(self, ray, whitelist, ignore)
        end)

        -- 4. Legacy: FindPartOnRay (Jogos antigos em geral)
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

        -- 5. Interceptação de Rede / RemoteEvent (Da Hood, Hood Modded, etc)
        local fakeEvent = Instance.new("RemoteEvent")
        oldFireServer = hookfunction(fakeEvent.FireServer, function(self, ...)
            local args = {...}
            if UIState.Get(KEY_ENABLED, false) then
                local targetPos, targetPart = GetCalculatedTargetPosition()
                if targetPos and targetPart then
                    for i, v in pairs(args) do
                        if typeof(v) == "Vector3" then 
                            args[i] = targetPos
                        elseif typeof(v) == "CFrame" then 
                            args[i] = CFrame.new(targetPos)
                        elseif typeof(v) == "Instance" and v:IsA("BasePart") and v:IsDescendantOf(Workspace) then
                            args[i] = targetPart
                        end
                    end
                end
            end
            return oldFireServer(self, unpack(args))
        end)

    end)

    if not success then
        Telemetry.Log("ERROR", "SilentAim", "Falha nos ganchos universais: " .. tostring(err))
        return "failed"
    end

    isInitialized = true
    Telemetry.Log("INFO", "SilentAim", "Arsenal Universal (5 Camadas) Ativado.")
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
function HookBackend.assumptions() return "Intercepta 4 tipos de Raycast e manipula RemoteEvents." end

return HookBackend
