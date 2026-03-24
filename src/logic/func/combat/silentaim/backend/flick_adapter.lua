--!strict
--[[
    SACRAMENT | Flick Adapter (Anti-Freecam / Camlock Contínuo)
    A câmara acompanha o alvo fluidamente. 100% de acerto sem bugar o motor de física.
]]

local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Import = (_G :: any).SacramentImport
local Telemetry = Import("logic/core/telemetry")
local UIState = Import("state/uistate")

local function SafeImport(path: string)
    local success, result = pcall(function() return Import(path) end)
    return success and result or nil
end
local Predict = SafeImport("logic/func/combat/shared/predict")

local FlickAdapter = {}
FlickAdapter._state = "unsupported"

local inputBeganConn: RBXScriptConnection? = nil
local inputEndedConn: RBXScriptConnection? = nil
local isShooting = false

local KEY_PREDICT_VAL = "SilentAim_Prediction"

function FlickAdapter.canLoad() return true, "BindToRenderStep suportado." end

function FlickAdapter.load()
    if FlickAdapter._state == "initialized" then return "initialized" end
    local Controller = Import("logic/func/combat/silentaim/main")

    inputBeganConn = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isShooting = true
            
            -- O SEGREDO ANTI-FREECAM: Não usamos loop "while". Usamos evento de renderização.
            pcall(function() RunService:UnbindFromRenderStep("Sacrament_ShootingTracker") end)
            
            RunService:BindToRenderStep("Sacrament_ShootingTracker", Enum.RenderPriority.Camera.Value + 1, function()
                if not isShooting then return end
                
                if Controller and type(Controller.GetLockedTargetPart) == "function" then
                    local targetPart = Controller.GetLockedTargetPart()
                    
                    if targetPart and targetPart:IsA("BasePart") then
                        local camera = Workspace.CurrentCamera
                        if camera then
                            -- PREDIÇÃO DE PRECISÃO (Lembrando que 0 = Sem falhas de movimento)
                            local finalAimPosition = targetPart.Position
                            if Predict and type(Predict.GetPosition) == "function" then
                                local pValue = tonumber(UIState.Get(KEY_PREDICT_VAL, 0)) or 0
                                finalAimPosition = Predict.GetPosition(targetPart, pValue)
                            end

                            -- ALINHAMENTO ABSOLUTO: A câmara olha diretamente para o alvo, garantindo o hit da arma.
                            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, finalAimPosition)
                        end
                    end
                end
            end)
        end
    end)

    inputEndedConn = UserInputService.InputEnded:Connect(function(input, gpe)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isShooting = false
            -- Solta a câmara imediatamente ao parar de atirar
            pcall(function() RunService:UnbindFromRenderStep("Sacrament_ShootingTracker") end)
        end
    end)

    FlickAdapter._state = "initialized"
    Telemetry.Log("LITURGY", "SilentAim", "Motor Anti-Freecam Ativado. Precisão contínua em rajadas.")
    return "initialized"
end

function FlickAdapter.destroy()
    if FlickAdapter._state ~= "initialized" then return end
    isShooting = false
    if inputBeganConn then inputBeganConn:Disconnect(); inputBeganConn = nil end
    if inputEndedConn then inputEndedConn:Disconnect(); inputEndedConn = nil end
    pcall(function() RunService:UnbindFromRenderStep("Sacrament_ShootingTracker") end)
    FlickAdapter._state = "destroyed"
end

return FlickAdapter
