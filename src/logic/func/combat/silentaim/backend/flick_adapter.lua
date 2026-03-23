--!strict
--[[
    SACRAMENT | Flick Adapter Backend (Free-Mouse & Pulse-Sync)
    A única solução para executores em Modo Degradado (Sem Hooks).
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

-- Define a cadência (tempo que a câmara volta ao seu controlo entre os tiros)
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
                        -- Aqui é a chave: Se estiver fora do FOV, Controller retorna 'nil' e o tiro sai normal.
                        local targetPart = Controller.GetLockedTargetPart()
                        
                        if targetPart and targetPart:IsA("BasePart") then
                            local camera = Workspace.CurrentCamera
                            if camera then
                                -- PREDIÇÃO
                                local finalAimPosition = targetPart.Position
                                if Predict and type(Predict.GetPosition) == "function" then
                                    local pValue = tonumber(UIState.Get(KEY_PREDICT_VAL, 0.135)) or 0.135
                                    local isAuto = UIState.Get("SilentAim_AutoPredict", false) == true or UIState.Get("SilentAim_AutoPredict", false) == "true"
                                    finalAimPosition = Predict.GetPosition(targetPart, pValue, isAuto)
                                end

                                -- MATEMÁTICA DE MOUSE SOLTO
                                local originalCFrame = camera.CFrame
                                local mousePos = UserInputService:GetMouseLocation()
                                local mouseRay = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
                                local centerToMouseRotation = originalCFrame:ToObjectSpace(CFrame.lookAt(originalCFrame.Position, originalCFrame.Position + mouseRay.Direction))
                                local baseTargetCFrame = CFrame.lookAt(originalCFrame.Position, finalAimPosition)
                                
                                -- O MICRO-FLICK
                                camera.CFrame = baseTargetCFrame * centerToMouseRotation:Inverse()
                                
                                -- Yield de 1 Frame
                                RunService.RenderStepped:Wait() 
                                
                                -- RESTAURAÇÃO
                                camera.CFrame = originalCFrame
                            end
                        end
                    end
                    
                    -- Pausa para dar controlo de rato ao jogador entre os tiros
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
    Telemetry.Log("LITURGY", "SilentAim", "Flick-Adapter acoplado com sucesso. Restrição FOV Dinâmica ativa.")
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
