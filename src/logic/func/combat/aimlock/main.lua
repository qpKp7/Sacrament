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

-- Importando o Arsenal (Micro-módulos Shared)
local Targeting = Import("logic/func/combat/shared/targeting")
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

    -- Conecta-se ao nosso "Maestro" para rodar a cada frame da câmara
    Loop.BindToRender("Aimlock_Main", function(deltaTime: number)
        local camera = Workspace.CurrentCamera
        if not camera then return end

        -- =========================================================================
        -- 1. LER AS CONFIGURAÇÕES DA INTERFACE (UIState) EM TEMPO REAL
        -- =========================================================================
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

        -- =========================================================================
        -- 2. CHECAR O GATILHO (A tecla está a ser segurada?)
        -- =========================================================================
        if not isEnabled or not KeyHold.IsHeld(bindKey) then
            return -- Se não estiver a segurar, aborta instantaneamente (poupa CPU!)
        end

        -- =========================================================================
        -- 3. ENCONTRAR O ALVO (O Targeting resolve os checks pesados)
        -- =========================================================================
        -- Procuramos pelas partes genéricas apenas para descobrir quem é o jogador mais perto
        local targetBasePart = Targeting.GetClosestToCursor(
            fovRadius, 
            {"Head", "Torso", "HumanoidRootPart"}, 
            useWallCheck, 
            useKnockCheck, 
            useTeamCheck
        )

        -- Se não houver ninguém válido dentro da roda do FOV, aborta
        if not targetBasePart then return end
        
        local character = targetBasePart.Parent :: Model

        -- =========================================================================
        -- 4. DECIDIR A PARTE EXATA DO CORPO (Head, Torso, Random, Closest)
        -- =========================================================================
        local partToAim = AimPart.GetTarget(character, aimPartOpt)
        if not partToAim then return end

        -- =========================================================================
        -- 5. PREVER O FUTURO (Prediction para compensar Ping)
        -- =========================================================================
        local finalPosition = partToAim.Position
        if doPredict then
            finalPosition = Predict.GetPosition(partToAim, predictValue, autoPredict)
        end

        -- =========================================================================
        -- 6. MOVER A CÂMARA (Aplicação de Suavidade Humana)
        -- =========================================================================
        local newCFrame = Smooth.Calculate(camera.CFrame, finalPosition, smoothness, deltaTime)
        camera.CFrame = newCFrame

    end)

    warn("[SACRAMENT] 🎯 Aimlock Module carregado e plugado ao Maestro.")
end

-- Função para desligar completamente caso o utilizador dê "Unload" no script
function Aimlock.Destroy()
    if not isInitialized then return end
    Loop.UnbindFromRender("Aimlock_Main")
    isInitialized = false
end

return Aimlock
