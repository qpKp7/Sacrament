--!strict
--[[
    SACRAMENT | Async Micro-Flick Adapter
    Garante 100% de letalidade em rajadas automáticas sem causar o bug de Freecam.
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

function FlickAdapter.canLoad() return true, "Async Flick Override suportado." end

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
                                -- 1. Guarda o estado natural da câmara para não bugar o movimento do boneco
                                local originalCFrame = camera.CFrame
                                local currentPosition = originalCFrame.Position
                                
                                -- 2. Calcula a matemática do alvo
                                local finalAimPosition = targetPart.Position
                                if Predict and type(Predict.GetPosition) == "function" then
                                    local pValue = tonumber(UIState.Get(KEY_PREDICT_VAL, 0)) or 0
                                    finalAimPosition = Predict.GetPosition(targetPart, pValue)
                                end

                                -- 3. O MICRO-FLICK: Vira apenas o ângulo, mantendo a posição física intacta
                                camera.CFrame = CFrame.new(currentPosition, finalAimPosition)
                                
                                -- 4. Congela por exato 1 frame para o servidor do jogo registar a bala no AimPart
                                RunService.RenderStepped:Wait() 
                                
                                -- 5. Devolve a câmara ao utilizador instantaneamente
                                camera.CFrame = originalCFrame
                            end
                        end
                    end
                    
                    -- A SALVAÇÃO DO FREECAM: 
                    -- Esta micro-pausa permite que o motor do Roblox calcule os passos e a física do boneco.
                    task.wait(0.015)
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
    Telemetry.Log("LITURGY", "SilentAim", "Async Micro-Flick Injetado. Letalidade Auto-Fire sem Freecam.")
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
