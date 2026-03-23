--!strict
--[[
    SACRAMENT | Flick Adapter Backend (Free-Mouse & Pulse-Sync)
    Devolve o controle da câmera ao utilizador ao sincronizar o flick com o fire-rate da arma.
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

-- ==========================================
-- CALIBRAÇÃO DE CADÊNCIA (FIRE-RATE)
-- ==========================================
-- Este valor dita quanto tempo a câmera "descansa" entre um flick e outro.
-- 0.08s = ~12 flicks por segundo (Ideal para SMGs/ARs). 
-- Se a câmera ainda estiver pesada, aumente para 0.1. Se estiver a errar balas, diminua para 0.05.
local FLICK_PULSE_RATE = 0.08 

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
                                -- 1. PREDIÇÃO
                                local finalAimPosition = targetPart.Position
                                if Predict and type(Predict.GetPosition) == "function" then
                                    local pValue = tonumber(UIState.Get(KEY_PREDICT_VAL, 0.135)) or 0.135
                                    local isAuto = UIState.Get(KEY_AUTO_PREDICT, false)
                                    finalAimPosition = Predict.GetPosition(targetPart, pValue, isAuto)
                                end

                                -- 2. MATEMÁTICA DE MOUSE SOLTO
                                local originalCFrame = camera.CFrame
                                local mousePos = UserInputService:GetMouseLocation()
                                local mouseRay = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
                                local centerToMouseRotation = originalCFrame:ToObjectSpace(CFrame.lookAt(originalCFrame.Position, originalCFrame.Position + mouseRay.Direction))
                                local baseTargetCFrame = CFrame.lookAt(originalCFrame.Position, finalAimPosition)
                                
                                -- 3. O MICRO-FLICK
                                camera.CFrame = baseTargetCFrame * centerToMouseRotation:Inverse()
                                
                                -- Espera exatamente 1 frame da engine para o jogo computar o tiro
                                RunService.RenderStepped:Wait() 
                                
                                -- 4. RESTAURAÇÃO
                                camera.CFrame = originalCFrame
                            end
                        end
                    end
                    
                    -- 5. O RESPIRO DA CÂMERA (A Mágica)
                    -- Permite que você mexa o mouse normalmente entre os tiros.
                    task.wait(FLICK_PULSE_RATE)
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
    Telemetry.Log("LITURGY", "SilentAim", "Pulse-Flick ativo. Câmera destravada com compensação de cadência.")
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
