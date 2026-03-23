--!strict
--[[
    SACRAMENT | Flick Adapter Backend (The Micro-Pulse Flick)
    Suporte nativo a armas semi-automáticas e automáticas (Hold M1).
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
local flickConnectionBegan: RBXScriptConnection? = nil
local flickConnectionEnded: RBXScriptConnection? = nil
local isShooting = false

-- Chaves de Prediction da sua UI
local KEY_PREDICT_VAL = "SilentAim_Prediction"
local KEY_AUTO_PREDICT = "SilentAim_AutoPredict"

function FlickAdapter.canLoad() return true, "CFrame Override suportado." end

function FlickAdapter.load()
    if FlickAdapter._state == "initialized" then return "initialized" end
    local Controller = Import("logic/func/combat/silentaim/main")

    flickConnectionBegan = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        
        -- Detecta o início do disparo (Clique ou Segurar)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isShooting = true
            
            -- Cria o Micro-Pulse Loop assíncrono para armas automáticas
            task.spawn(function()
                while isShooting do
                    if Controller and type(Controller.GetLockedTargetPart) == "function" then
                        local targetPart = Controller.GetLockedTargetPart()
                        
                        if targetPart and targetPart:IsA("BasePart") then
                            local camera = Workspace.CurrentCamera
                            if camera then
                                -- PREDIÇÃO BALÍSTICA
                                local finalAimPosition = targetPart.Position
                                if Predict and type(Predict.GetPosition) == "function" then
                                    local pValue = tonumber(UIState.Get(KEY_PREDICT_VAL, 0.135)) or 0.135
                                    local isAuto = UIState.Get(KEY_AUTO_PREDICT, false)
                                    finalAimPosition = Predict.GetPosition(targetPart, pValue, isAuto)
                                end

                                -- O MICRO-FLICK
                                local originalCFrame = camera.CFrame
                                camera.CFrame = CFrame.new(camera.CFrame.Position, finalAimPosition)
                                
                                -- Yield 1: Mantém o Flick apenas pelo milissegundo em que o tiro sai
                                RunService.RenderStepped:Wait() 
                                
                                -- Restauração
                                camera.CFrame = originalCFrame
                            end
                        end
                    end
                    -- Yield 2: Devolve a câmera ao estado puro para o motor descansar antes do próximo tiro
                    RunService.Heartbeat:Wait()
                end
            end)
        end
    end)

    flickConnectionEnded = UserInputService.InputEnded:Connect(function(input, gpe)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isShooting = false -- Quebra o loop quando soltar o dedo
        end
    end)

    FlickAdapter._state = "initialized"
    Telemetry.Log("LITURGY", "SilentAim", "Flash-Flick Micro-Pulse (Suporte Auto-Fire) ativo.")
    return "initialized"
end

function FlickAdapter.destroy()
    if FlickAdapter._state ~= "initialized" then return end
    isShooting = false
    if flickConnectionBegan then flickConnectionBegan:Disconnect(); flickConnectionBegan = nil end
    if flickConnectionEnded then flickConnectionEnded:Disconnect(); flickConnectionEnded = nil end
    FlickAdapter._state = "destroyed"
end

return FlickAdapter
