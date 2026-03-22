--!strict
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Import = (_G :: any).SacramentImport

local UIState   = Import("state/uistate")
local Loop      = Import("logic/core/loop")
local Targeting = Import("logic/core/targeting")

local KeyHold   = Import("logic/func/combat/shared/keyhold")
local AimPart   = Import("logic/func/combat/shared/aimpart")
local Predict   = Import("logic/func/combat/shared/predict")
local Smooth    = Import("logic/func/combat/aimlock/smooth")
local KnockCheck= Import("logic/func/combat/shared/knockcheck")

local Aimlock = {}
local isInitialized = false

-- Variáveis de controle de Estado
local wasKeyPressed = false
local lockedTarget: BasePart? = nil

function Aimlock.Init()
    if isInitialized then return end
    isInitialized = true

    Loop.BindToRender("Aimlock_Main", function(deltaTime: number)
        local camera = Workspace.CurrentCamera
        if not camera then return end

        local isEnabled = UIState.Get("AimlockEnabled", false)
        if not isEnabled then
            lockedTarget = nil
            wasKeyPressed = false
            return
        end

        local bindKey      = UIState.Get("Aimlock_Keybind", "Q")
        local isKeyHold    = UIState.Get("Aimlock_KeyHold", false)
        
        local useWallCheck = UIState.Get("Aimlock_WallCheck", false)
        local useKnockCheck= UIState.Get("Aimlock_KnockCheck", false) 
        local aimPartOpt   = UIState.Get("Aimlock_AimPart", "Closest")  
        
        local smoothness   = tonumber(UIState.Get("Aimlock_Smooth", 0.5)) or 0.5
        local predictValue = tonumber(UIState.Get("Aimlock_Predict", 0)) or 0
        local fovRadius    = 5000 
        local useTeamCheck = false 

        -- =====================================================================
        -- 1. DETECÇÃO DE CLIQUE PERFEITA (EDGE DETECTION)
        -- =====================================================================
        local isCurrentlyPressed = KeyHold.IsHeld(bindKey)
        local justPressed = isCurrentlyPressed and not wasKeyPressed
        local justReleased = not isCurrentlyPressed and wasKeyPressed
        wasKeyPressed = isCurrentlyPressed -- Salva para o próximo frame

        -- =====================================================================
        -- 2. LÓGICA DE TRAVA (HOLD VS TOGGLE)
        -- =====================================================================
        if isKeyHold then
            -- MODO HOLD: Só funciona enquanto segura
            if justPressed then
                lockedTarget = Targeting.GetClosestToCursor(fovRadius, {"Head", "Torso", "HumanoidRootPart"}, useWallCheck, useKnockCheck, useTeamCheck)
            elseif justReleased then
                lockedTarget = nil
            end
        else
            -- MODO TOGGLE: Aperta pra travar, aperta de novo pra soltar
            if justPressed then
                if lockedTarget then
                    lockedTarget = nil -- Desliga a trava
                else
                    -- Procura o alvo APENAS quando clica (nunca muda de alvo sozinho)
                    lockedTarget = Targeting.GetClosestToCursor(fovRadius, {"Head", "Torso", "HumanoidRootPart"}, useWallCheck, useKnockCheck, useTeamCheck)
                end
            end
        end

        if not lockedTarget then return end

        -- =====================================================================
        -- 3. VERIFICAÇÃO DE VALIDADE (Solta a mira se o cara morrer/cair)
        -- =====================================================================
        local character = lockedTarget.Parent :: Model
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if not humanoid or humanoid.Health <= 0 then
            lockedTarget = nil
            return
        end

        -- Se KnockCheck estiver ligado, solta a mira na hora que ele deitar
        if useKnockCheck and KnockCheck then
            local playerTarget = Players:GetPlayerFromCharacter(character)
            if playerTarget and KnockCheck.IsKnocked(playerTarget) then
                lockedTarget = nil
                return
            end
        end

        -- =====================================================================
        -- 4. MATEMÁTICA E CÂMERA
        -- =====================================================================
        local partToAim = AimPart.GetTarget(character, aimPartOpt)
        if not partToAim then return end

        local finalPosition = partToAim.Position
        if predictValue > 0 then
            finalPosition = Predict.GetPosition(partToAim, predictValue, false)
        end

        local newCFrame = Smooth.Calculate(camera.CFrame, finalPosition, smoothness, deltaTime)
        camera.CFrame = newCFrame
    end)
end

function Aimlock.Destroy()
    if not isInitialized then return end
    Loop.UnbindFromRender("Aimlock_Main")
    isInitialized = false
    lockedTarget = nil
    wasKeyPressed = false
end

return Aimlock
