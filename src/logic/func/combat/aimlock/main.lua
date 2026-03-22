--!strict
local Workspace = game:GetService("Workspace")
local Import = (_G :: any).SacramentImport

local UIState   = Import("state/uistate")
local Loop      = Import("logic/core/loop")
local Targeting = Import("logic/core/targeting")

local KeyHold   = Import("logic/func/combat/shared/keyhold")
local AimPart   = Import("logic/func/combat/shared/aimpart")
local Predict   = Import("logic/func/combat/shared/predict")
local Smooth    = Import("logic/func/combat/aimlock/smooth")

local Aimlock = {}
local isInitialized = false

-- Variáveis para controlar o modo "Toggle"
local wasKeyPressed = false
local isToggledOn = false
local lockedTarget: BasePart? = nil

function Aimlock.Init()
    if isInitialized then return end
    isInitialized = true

    Loop.BindToRender("Aimlock_Main", function(deltaTime: number)
        local camera = Workspace.CurrentCamera
        if not camera then return end

        -- =====================================================================
        -- 1. LÊ AS VARIÁVEIS EXATAS DO SEU MENU (UISTATE)
        -- =====================================================================
        local isEnabled    = UIState.Get("Combat_Aimlock_Enabled", false)
        local bindKey      = UIState.Get("Combat_Aimlock_Bind", "Q")
        local isKeyHold    = UIState.Get("Combat_Aimlock_KeyHold", true) -- NOVO: Lê o botão de Hold
        
        local fovRadius    = UIState.Get("Combat_Aimlock_FOV", 100)
        local useWallCheck = UIState.Get("Combat_Aimlock_WallCheck", false)
        local useKnockCheck= UIState.Get("Combat_Aimlock_KnockCheck", true)
        local useTeamCheck = UIState.Get("Combat_Aimlock_TeamCheck", false)
        
        local aimPartOpt   = UIState.Get("Combat_Aimlock_AimPart", "Closest")
        local smoothness   = UIState.Get("Combat_Aimlock_Smoothness", 0.5)
        
        local doPredict    = UIState.Get("Combat_Aimlock_Predict", false)
        local autoPredict  = UIState.Get("Combat_Aimlock_AutoPredict", false)
        local predictValue = UIState.Get("Combat_Aimlock_PredictValue", 0.135)

        -- Se a função mestre estiver desligada no menu, solta tudo e para
        if not isEnabled then
            lockedTarget = nil
            isToggledOn = false
            return
        end

        -- =====================================================================
        -- 2. LÓGICA INTELIGENTE: HOLD VS TOGGLE
        -- =====================================================================
        local isCurrentlyPressed = KeyHold.IsHeld(bindKey)
        local isActive = false

        if isKeyHold then
            -- MODO HOLD: Só funciona enquanto estiver segurando a tecla
            isActive = isCurrentlyPressed
            if not isActive then lockedTarget = nil end
        else
            -- MODO TOGGLE: Aperta uma vez para ligar, aperta de novo para desligar
            if isCurrentlyPressed and not wasKeyPressed then
                isToggledOn = not isToggledOn
                if not isToggledOn then lockedTarget = nil end -- Limpa o alvo ao desligar
            end
            isActive = isToggledOn
        end
        wasKeyPressed = isCurrentlyPressed

        if not isActive then return end

        -- =====================================================================
        -- 3. BUSCA E TRAVA O ALVO
        -- =====================================================================
        -- Se estiver no modo Toggle e já tivermos um alvo, mantemos ele. 
        -- Se não tiver alvo (ou estiver no modo Hold), procuramos o mais próximo.
        if not lockedTarget or isKeyHold then
            lockedTarget = Targeting.GetClosestToCursor(
                fovRadius, 
                {"Head", "Torso", "HumanoidRootPart"}, 
                useWallCheck, 
                useKnockCheck, 
                useTeamCheck
            )
        end

        if not lockedTarget then return end
        
        -- =====================================================================
        -- 4. MATEMÁTICA: AIMPART, PREDICT E SMOOTH
        -- =====================================================================
        local character = lockedTarget.Parent :: Model
        local partToAim = AimPart.GetTarget(character, aimPartOpt)
        if not partToAim then return end

        local finalPosition = partToAim.Position
        if doPredict then
            finalPosition = Predict.GetPosition(partToAim, predictValue, autoPredict)
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
    isToggledOn = false
end

return Aimlock
