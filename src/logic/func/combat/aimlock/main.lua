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

local wasKeyPressed = false
local isToggledOn = false
local lockedTarget: BasePart? = nil

local lastDebugTime = 0

function Aimlock.Init()
    if isInitialized then return end
    isInitialized = true

    warn("[SACRAMENT] 🎯 Aimlock (Modo Diagnostico) Iniciado!")

    Loop.BindToRender("Aimlock_Main", function(deltaTime: number)
        local camera = Workspace.CurrentCamera
        if not camera then return end

        local isEnabled    = UIState.Get("AimlockEnabled", false)
        local bindKey      = UIState.Get("Aimlock_Keybind", "Q")
        local isKeyHold    = UIState.Get("Aimlock_KeyHold", true)
        
        local useWallCheck = UIState.Get("Aimlock_WallCheck", false)
        local useKnockCheck= UIState.Get("Aimlock_KnockCheck", false) 
        local aimPartOpt   = UIState.Get("Aimlock_AimPart", "Torso")  
        
        local smoothness   = tonumber(UIState.Get("Aimlock_Smooth", 0.5)) or 0.5
        local fovRadius    = 5000 
        local useTeamCheck = false 

        local isCurrentlyPressed = KeyHold.IsHeld(bindKey)
        
        -- Aqui mora o Raio-X!
        if isCurrentlyPressed and (tick() - lastDebugTime > 1) then
            lastDebugTime = tick()
            print("--- RAIO X DO AIMLOCK ---")
            print("1. Tecla lida pelo UIState: ", tostring(bindKey))
            print("2. Botao Principal Ligado?: ", tostring(isEnabled))
            print("3. Modo KeyHold Ligado?: ", tostring(isKeyHold))
            print("4. WallCheck Ligado?: ", tostring(useWallCheck))
            print("-------------------------")
        end

        if not isEnabled then
            lockedTarget = nil
            isToggledOn = false
            return
        end

        local isActive = false
        if isKeyHold then
            isActive = isCurrentlyPressed
            if not isActive then lockedTarget = nil end
        else
            if isCurrentlyPressed and not wasKeyPressed then
                isToggledOn = not isToggledOn
                if not isToggledOn then lockedTarget = nil end
            end
            isActive = isToggledOn
        end
        wasKeyPressed = isCurrentlyPressed

        if not isActive then return end

        if not lockedTarget or isKeyHold then
            lockedTarget = Targeting.GetClosestToCursor(
                fovRadius, 
                {"Torso", "HumanoidRootPart"}, 
                useWallCheck, 
                useKnockCheck, 
                useTeamCheck
            )
        end

        if not lockedTarget then return end
        
        local character = lockedTarget.Parent :: Model
        local partToAim = AimPart.GetTarget(character, aimPartOpt)
        if not partToAim then return end

        local newCFrame = Smooth.Calculate(camera.CFrame, partToAim.Position, smoothness, deltaTime)
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
