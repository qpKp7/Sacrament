--!strict
--[[
    SACRAMENT | Raw Input Tracker (Anti-Freecam & Auto-Fire 100%)
    Usa simulação nativa de rato para evitar detecção e conflitos de câmara.
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

function FlickAdapter.canLoad() return true, "Raw Input Tracker suportado." end

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
                                local finalAimPosition = targetPart.Position
                                if Predict and type(Predict.GetPosition) == "function" then
                                    local pValue = tonumber(UIState.Get(KEY_PREDICT_VAL, 0)) or 0
                                    finalAimPosition = Predict.GetPosition(targetPart, pValue)
                                end

                                -- A MÁGICA ANTI-FREECAM: Simula o arrastar do rato real.
                                if type(mousemoverel) == "function" then
                                    local screenPos, onScreen = camera:WorldToViewportPoint(finalAimPosition)
                                    if onScreen then
                                        local mouseLocation = UserInputService:GetMouseLocation()
                                        local moveX = (screenPos.X - mouseLocation.X)
                                        local moveY = (screenPos.Y - mouseLocation.Y)
                                        
                                        -- Arrasta o rato suavemente para o alvo
                                        mousemoverel(moveX, moveY)
                                    end
                                else
                                    -- Fallback seguro para CFrame caso o executor não tenha mousemoverel
                                    camera.CFrame = CFrame.new(camera.CFrame.Position, finalAimPosition)
                                end
                            end
                        end
                    end
                    -- Sincroniza perfeitamente com a física do jogo (fim do bug do Freecam)
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
    Telemetry.Log("LITURGY", "SilentAim", "Raw Input Tracker ativado. 100% de Letalidade.")
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
