--!strict
local Workspace = game:GetService("Workspace")
local Import = (_G :: any).SacramentImport

local Loop      = Import("logic/core/loop")
local Targeting = Import("logic/core/targeting")
local KeyHold   = Import("logic/func/combat/shared/keyhold")
local AimPart   = Import("logic/func/combat/shared/aimpart")
local Smooth    = Import("logic/func/combat/aimlock/smooth")

local Aimlock = {}
local isInitialized = false

function Aimlock.Init()
    if isInitialized then return end
    isInitialized = true

    Loop.BindToRender("Aimlock_Main", function(deltaTime: number)
        local camera = Workspace.CurrentCamera
        if not camera then return end

        -- =========================================================
        -- VALORES FORÇADOS (IGNORANDO O MENU PARA TESTE)
        -- =========================================================
        local isEnabled    = true       -- FORÇADO: Ligado
        local bindKey      = "Q"        -- FORÇADO: Tecla Q
        local fovRadius    = 5000       -- FORÇADO: Pega a tela inteira
        local useWallCheck = false      -- FORÇADO: Desligado
        local useKnockCheck= false      -- FORÇADO: Desligado
        local useTeamCheck = false      -- FORÇADO: Desligado
        local aimPartOpt   = "Torso"    -- FORÇADO: Foca no peito
        local smoothness   = 0.5        -- FORÇADO: Suavidade média
        
        -- Checa se você está segurando o 'Q'
        if not KeyHold.IsHeld(bindKey) then
            return 
        end

        -- Busca o Alvo
        local targetBasePart = Targeting.GetClosestToCursor(
            fovRadius, 
            {"Torso", "HumanoidRootPart", "UpperTorso"}, 
            useWallCheck, 
            useKnockCheck, 
            useTeamCheck
        )

        if not targetBasePart then return end
        
        -- Puxa a câmera
        local newCFrame = Smooth.Calculate(camera.CFrame, targetBasePart.Position, smoothness, deltaTime)
        camera.CFrame = newCFrame

    end)

    warn("[SACRAMENT] 🎯 Aimlock (MODO DE TESTE FORÇADO) carregado.")
end

function Aimlock.Destroy()
    if not isInitialized then return end
    Loop.UnbindFromRender("Aimlock_Main")
    isInitialized = false
end

return Aimlock
