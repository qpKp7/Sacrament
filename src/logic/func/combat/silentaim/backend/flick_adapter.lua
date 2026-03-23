--!strict
--[[
    SACRAMENT | Flick Adapter Backend (The Flash-Flick + AutoPredict)
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
local flickConnection: RBXScriptConnection? = nil

-- Chaves de Prediction da sua UI
local KEY_PREDICT_VAL = "SilentAim_Prediction"
local KEY_AUTO_PREDICT = "SilentAim_AutoPredict"

function FlickAdapter.canLoad() return true, "CFrame Override suportado." end

function FlickAdapter.load()
    if FlickAdapter._state == "initialized" then return "initialized" end
    local Controller = Import("logic/func/combat/silentaim/main")

    flickConnection = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if Controller and type(Controller.GetLockedTargetPart) == "function" then
                local targetPart = Controller.GetLockedTargetPart()
                
                if targetPart and targetPart:IsA("BasePart") then
                    local camera = Workspace.CurrentCamera
                    if not camera then return end

                    -- LÓGICA DE PREDIÇÃO COM BASE NA UI
                    local finalAimPosition = targetPart.Position
                    if Predict and type(Predict.GetPosition) == "function" then
                        local pValue = tonumber(UIState.Get(KEY_PREDICT_VAL, 0.135)) or 0.135
                        local isAuto = UIState.Get(KEY_AUTO_PREDICT, false)
                        finalAimPosition = Predict.GetPosition(targetPart, pValue, isAuto)
                    end

                    -- THE FLASH-FLICK
                    local originalCFrame = camera.CFrame
                    camera.CFrame = CFrame.new(camera.CFrame.Position, finalAimPosition)
                    
                    -- Limite de velocidade do motor
                    RunService.RenderStepped:Wait() 
                    
                    camera.CFrame = originalCFrame
                end
            end
        end
    end)

    FlickAdapter._state = "initialized"
    Telemetry.Log("LITURGY", "SilentAim", "Flash-Flick com AutoPredict sincronizado à UI.")
    return "initialized"
end

function FlickAdapter.destroy()
    if FlickAdapter._state ~= "initialized" then return end
    if flickConnection then flickConnection:Disconnect(); flickConnection = nil end
    FlickAdapter._state = "destroyed"
end

return FlickAdapter
