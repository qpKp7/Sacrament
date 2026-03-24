--!strict
--[[
    SACRAMENT | Flick Adapter Backend (Core Lethality)
    Precisão Absoluta com compensação de Free-Mouse e Prediction.
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
local FLICK_PULSE_RATE = 0.05 -- Respiração rápida para sincronizar com metralhadoras

function FlickAdapter.canLoad() return true, "CFrame Override absoluto." end

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
                        
                        -- O targetPart só será entregue se o Hit Chance permitir.
                        if targetPart and targetPart:IsA("BasePart") then
                            local camera = Workspace.CurrentCamera
                            if camera then
                                -- 1. PREDIÇÃO DE MOVIMENTO
                                local finalAimPosition = targetPart.Position
                                if Predict and type(Predict.GetPosition) == "function" then
                                    local pValue = tonumber(UIState.Get(KEY_PREDICT_VAL, 0.135)) or 0.135
                                    local isAuto = UIState.Get("SilentAim_AutoPredict", false) == true or UIState.Get("SilentAim_AutoPredict", false) == "true"
                                    finalAimPosition = Predict.GetPosition(targetPart, pValue, isAuto)
                                end

                                -- 2. INVERSÃO DE MATRIZ (PRECISÃO COM MOUSE SOLTO)
                                local originalCFrame = camera.CFrame
                                local mousePos = UserInputService:GetMouseLocation()
                                local mouseRay = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
                                
                                local centerToMouseRotation = originalCFrame:ToObjectSpace(CFrame.lookAt(originalCFrame.Position, originalCFrame.Position + mouseRay.Direction))
                                local baseTargetCFrame = CFrame.lookAt(originalCFrame.Position, finalAimPosition)
                                
                                -- 3. O TIRO INVISÍVEL
                                camera.CFrame = baseTargetCFrame * centerToMouseRotation:Inverse()
                                
                                -- Aguarda a engine computar a bala
                                RunService.RenderStepped:Wait() 
                                
                                -- Restaura a câmara instantaneamente
                                camera.CFrame = originalCFrame
                            end
                        end
                    end
                    
                    -- Pausa estrutural para devolver controlo da câmara e não crashar o Roblox
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
    Telemetry.Log("LITURGY", "SilentAim", "Motor de Precisão Absoluta iniciado (CFrame Flick).")
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
