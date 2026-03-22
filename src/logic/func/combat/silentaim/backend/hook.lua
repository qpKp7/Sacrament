--!strict
--[[
    SACRAMENT | Ghost Hitbox Backend (Elite Version)
    Cria uma hitbox invisível separada para não deformar o personagem original.
    Inclui sistema de trava (Target Lock) e WallCheck corrigido.
]]
local Players = game:GetService("Players")
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

-- Referências de Controle
local lockedCharacter: Model? = nil
local currentGhost: Part? = nil

-- Sincronizando Chaves da UI
local KEY_ENABLED     = "SilentAimEnabled"
local KEY_FOV_RADIUS  = "SilentAim_FovLimit"
local KEY_MARK_STYLE  = "SilentAim_MarkStyle"
local KEY_AIM_PART    = "SilentAim_AimPart"
local KEY_WALL_CHECK  = "SilentAim_WallCheck"
local KEY_BIND        = "SilentAim_Keybind"
local KEY_HOLD        = "SilentAim_KeyHold"

-- Limpa a Ghost Hitbox do mapa
local function CleanGhost()
    if currentGhost then
        currentGhost:Destroy()
        currentGhost = nil
    end
end

-- Cria a Hitbox Invisível "colada" no inimigo
local function CreateGhostHitbox(character: Model, partName: string)
    CleanGhost()
    
    local realPart = character:FindFirstChild(partName) or character:FindFirstChild("HumanoidRootPart")
    if not realPart or not realPart:IsA("BasePart") then return end

    -- Cria o "fantasma" que vai receber as balas
    local ghost = Instance.new("Part")
    ghost.Name = realPart.Name -- O jogo vai achar que acertou a "Head" ou "Torso" real
    ghost.Size = Vector3.new(15, 15, 15) -- Hitbox Gigante
    ghost.Transparency = 1 -- 100% Invisível
    ghost.CanCollide = false
    ghost.Massless = true
    ghost.Anchored = false
    
    -- Posiciona e solda no inimigo (sem deformar o original)
    ghost.CFrame = realPart.CFrame
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = ghost
    weld.Part1 = realPart
    weld.Parent = ghost
    
    -- Coloca dentro do Character inimigo para o script da arma registrar o dano
    ghost.Parent = character
    currentGhost = ghost
end

-- Pega o Character mais próximo do cursor respeitando o WallCheck
local function GetClosestCharacter(): Model?
    local fovRadius = tonumber(UIState.Get(KEY_FOV_RADIUS, 150)) or 150
    local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
    local wallCheck = UIState.Get(KEY_WALL_CHECK, false)
    
    local targetPart = Targeting.GetClosestToCursor(fovRadius, {aimPartName, "HumanoidRootPart"}, wallCheck, false, false)
    if targetPart then
        return targetPart.Parent :: Model
    end
    return nil
end

function HookBackend.canLoad()
    return true, "Ghost Hitbox suportada."
end

function HookBackend.load()
    if isInitialized then return "initialized" end
    if FOVLimit and type(FOVLimit.Init) == "function" then FOVLimit.Init() end

    -- =======================================================
    -- SISTEMA DE TARGET LOCK (Trava de Mira)
    -- =======================================================
    HookBackend._inputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not UIState.Get(KEY_ENABLED, false) then return end
        
        local bind = UIState.Get(KEY_BIND, "None")
        if bind and bind ~= "None" and input.KeyCode.Name == bind then
            local isHold = UIState.Get(KEY_HOLD, false)
            
            if isHold then
                lockedCharacter = GetClosestCharacter()
            else
                if lockedCharacter then
                    lockedCharacter = nil
                    CleanGhost()
                else
                    lockedCharacter = GetClosestCharacter()
                end
            end
        end
    end)

    HookBackend._inputEnded = UserInputService.InputEnded:Connect(function(input, gpe)
        local bind = UIState.Get(KEY_BIND, "None")
        if bind and bind ~= "None" and input.KeyCode.Name == bind then
            if UIState.Get(KEY_HOLD, false) then
                lockedCharacter = nil
                CleanGhost()
            end
        end
    end)

    -- =======================================================
    -- LOOP PRINCIPAL (60x por segundo)
    -- =======================================================
    Loop.BindToRender("SilentAim_Logic", function()
        if not UIState.Get(KEY_ENABLED, false) then
            CleanGhost()
            MarkStyle.Clear()
            lockedCharacter = nil
            return
        end

        local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
        local targetChar = lockedCharacter

        -- Valida se o alvo travado ainda está vivo
        if targetChar then
            local hum = targetChar:FindFirstChildOfClass("Humanoid")
            if not targetChar.Parent or not hum or hum.Health <= 0 then
                lockedCharacter = nil
                targetChar = nil
            end
        end

        -- Se não tiver alvo travado, pega o mais próximo
        if not targetChar then
            targetChar = GetClosestCharacter()
        end

        if targetChar then
            -- Se for um inimigo novo ou a AimPart mudou, recria a hitbox fantasma
            if not currentGhost or currentGhost.Parent ~= targetChar or currentGhost.Name ~= aimPartName then
                CreateGhostHitbox(targetChar, aimPartName)
            end
            
            -- Atualiza o MarkStyle (Highlight) na peça real
            local partToMark = targetChar:FindFirstChild(aimPartName) or targetChar:FindFirstChild("HumanoidRootPart")
            if partToMark then
                MarkStyle.Mark(partToMark, UIState.Get(KEY_MARK_STYLE, "None"))
            end
        else
            CleanGhost()
            MarkStyle.Clear()
        end
    end)

    isInitialized = true
    Telemetry.Log("INFO", "SilentAim", "Ghost Hitbox com Target Lock ativado.")
    return "initialized"
end

function HookBackend.destroy()
    if not isInitialized then return end
    Loop.UnbindFromRender("SilentAim_Logic")
    if HookBackend._inputBegan then HookBackend._inputBegan:Disconnect() end
    if HookBackend._inputEnded then HookBackend._inputEnded:Disconnect() end
    if FOVLimit and type(FOVLimit.Destroy) == "function" then FOVLimit.Destroy() end
    CleanGhost()
    MarkStyle.Clear()
    lockedCharacter = nil
    isInitialized = false
end

function HookBackend.health() return isInitialized and "initialized" or "unsupported" end
function HookBackend.requirements() return {} end
function HookBackend.assumptions() return "O jogo registra Hit em peças falsas anexadas ao Character." end

return HookBackend
