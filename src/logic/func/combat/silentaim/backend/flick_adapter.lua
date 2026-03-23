--!strict
--[[
    SACRAMENT | Flick Adapter Backend (Free-Mouse & Prediction)
    Calcula a deflexão vetorial para precisão absoluta com mouse solto (Sem Shift-Lock).
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

local KEY_PREDICT_VAL = "SilentAim_Prediction"
local KEY_AUTO_PREDICT = "SilentAim_AutoPredict"

function FlickAdapter.canLoad() return true, "CFrame Override suportado." end

function FlickAdapter.load()
    if FlickAdapter._state == "initialized" then return "initialized" end
    local Controller = Import("logic/func/combat/silentaim/main")

    flickConnectionBegan = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isShooting = true
            
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

                                -- MATEMÁTICA DE MOUSE SOLTO (FREE MOUSE)
                                local originalCFrame = camera.CFrame
                                local mousePos = UserInputService:GetMouseLocation()
                                local mouseRay = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
                                
                                -- Calcula a distância angular entre o centro da tela e onde o seu mouse está
                                local centerToMouseRotation = originalCFrame:ToObjectSpace(CFrame.lookAt(originalCFrame.Position, originalCFrame.Position + mouseRay.Direction))
                                
                                -- Aponta a câmera para o alvo predito e "subtrai" o offset do cursor
                                local baseTargetCFrame = CFrame.lookAt(originalCFrame.Position, finalAimPosition)
                                
                                -- O MICRO-FLICK COM COMPENSAÇÃO DE CURSOR
                                camera.CFrame = baseTargetCFrame * centerToMouseRotation:Inverse()
                                
                                -- Dispara a bala
                                RunService.RenderStepped:Wait() 
                                
                                -- Devolve a câmera
                                camera.CFrame = originalCFrame
                            end
                        end
                    end
                    RunService.Heartbeat:Wait()
                end
            end)
        end
    end)

    flickConnectionEnded = UserInputService.InputEnded:Connect(function(input, gpe)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isShooting = false
        end
    end)

    FlickAdapter._state = "initialized"
    Telemetry.Log("LITURGY", "SilentAim", "Engine de Free-Mouse e Prediction acoplada.")
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
