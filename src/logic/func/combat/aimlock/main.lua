--!strict
--[[
    SACRAMENT | Aimlock Main
    O coração do Aimlock. Une a Interface (UIState) com a Matemática (Shared & Smooth)
    para controlar a câmara de forma perfeita, otimizada e humana.
--]]

local Workspace = game:GetService("Workspace")
local Import = (_G :: any).SacramentImport

-- Importando os nossos Sistemas Core e Estado
local UIState   = Import("state/uistate")
local Loop      = Import("logic/core/loop")

-- [CORRIGIDO] Puxando o Targeting da pasta Core (conforme a sua estrutura atual)
local Targeting = Import("logic/core/targeting")

-- Importando os outros Micro-módulos Shared
local KeyHold   = Import("logic/func/combat/shared/keyhold")
local AimPart   = Import("logic/func/combat/shared/aimpart")
local Predict   = Import("logic/func/combat/shared/predict")

-- Importando a Matemática específica do Aimlock
local Smooth    = Import("logic/func/combat/aimlock/smooth")

local Aimlock = {}
local isInitialized = false

function Aimlock.Init()
    if isInitialized then return end
    isInitialized = true

    -- Conecta-se ao nosso "Maestro" para rodar a cada frame
    Loop.BindToRender("Aimlock_Main", function(deltaTime: number)
        local camera = Workspace.CurrentCamera
        if not camera then return end

        -- 1. LER AS CONFIGURAÇÕES DA INTERFACE
        local isEnabled    = UIState.Get("Combat_Aimlock_Enabled", false)
        local bindKey      = UIState.Get("Combat_Aimlock_Bind", "MB2")
        
        local fovRadius    = UIState.Get("Combat_Aimlock_FOV", 100)
        local useWallCheck = UIState.Get("Combat_Aimlock_WallCheck", false)
        local useKnockCheck= UIState.Get("Combat_Aimlock_KnockCheck", true)
        local useTeamCheck = UIState.Get("Combat_Aimlock_TeamCheck", true)
        
        local aimPartOpt   = UIState.Get("Combat_Aimlock_AimPart", "Closest")
        local smoothness   = UIState.Get("Combat_Aimlock_Smoothness", 0.5)
        
        local doPredict    = UIState.Get("Combat_Aimlock_Predict", false)
        local autoPredict  = UIState.Get("Combat_Aimlock_AutoPredict", false)
        local predictValue = UIState.Get("Combat_Aimlock_PredictValue", 0.135)

        -- 2. CHECAR O GATILHO (O botão está pressionado?)
        if not isEnabled or not KeyHold.IsHeld(bindKey) then
            return 
        end

        -- 3. ENCONTRAR O ALVO (O Targeting resolve os checks pesados)
        local targetBasePart = Targeting.GetClosestToCursor(
            fovRadius, 
            {"Head", "Torso", "HumanoidRootPart"}, 
            useWallCheck, 
            useKnockCheck, 
            useTeamCheck
        )

        if not targetBasePart then return end
        
        local character = targetBasePart.Parent :: Model

        -- 4. DECIDIR A PARTE EXATA DO CORPO (Head, Torso, Random, Closest)
        local partToAim = AimPart.GetTarget(character, aimPartOpt)
        if not partToAim then return end

        -- 5. PREVER O FUTURO (Prediction para compensar Ping)
        local finalPosition = partToAim.Position
        if doPredict then
            finalPosition = Predict.GetPosition(partToAim, predictValue, autoPredict)
        end

        -- 6. MOVER A CÂMARA COM SUAVIDADE
        local newCFrame = Smooth.Calculate(camera.CFrame, finalPosition, smoothness, deltaTime)
        camera.CFrame = newCFrame

    end)

    warn("[SACRAMENT] 🎯 Aimlock Module carregado e plugado ao Maestro.")
end

function Aimlock.Destroy()
    if not isInitialized then return end
    Loop.UnbindFromRender("Aimlock_Main")
    isInitialized = false
end

return Aimlock
