--!strict
--[[
    SACRAMENT | Camlock Adapter Backend (RenderPriority Edition)
    Fim dos tremores. Usa prioridade absoluta de renderização para esmagar o script nativo de câmara.
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

function FlickAdapter.canLoad() return true, "CFrame Override via BindToRenderStep." end

function FlickAdapter.load()
    if FlickAdapter._state == "initialized" then return "initialized" end
    local Controller = Import("logic/func/combat/silentaim/main")

    inputBeganConn = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isShooting = true
            
            -- O SEGREDO: BindToRenderStep com prioridade Camera + 1
            -- Isso garante que o nosso código rode DEPOIS do Roblox, eliminando 100% do tremor.
            RunService:BindToRenderStep("Sacrament_AbsoluteCamlock", Enum.RenderPriority.Camera.Value + 1, function()
                if not isShooting then return end
                
                if Controller and type(Controller.GetLockedTargetPart) == "function" then
                    local targetPart = Controller.GetLockedTargetPart()
                    
                    if targetPart and targetPart:IsA("BasePart") then
                        local camera = Workspace.CurrentCamera
                        if camera then
                            -- PREDIÇÃO PURA (Se 0, vai exato. Se > 0, compensa movimento)
                            local finalAimPosition = targetPart.Position
                            if Predict and type(Predict.GetPosition) == "function" then
                                local pValue = tonumber(UIState.Get(KEY_PREDICT_VAL, 0)) or 0
                                finalAimPosition = Predict.GetPosition(targetPart, pValue)
                            end

                            -- TRAVA ABSOLUTA E SUAVE
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
            -- Limpa o loop de renderização instantaneamente
            pcall(function() RunService:UnbindFromRenderStep("Sacrament_AbsoluteCamlock") end)
        end
    end)

    FlickAdapter._state = "initialized"
    Telemetry.Log("LITURGY", "SilentAim", "Absolute Camlock Ativado. Sincronização de Prioridade de Câmara injetada.")
    return "initialized"
end

function FlickAdapter.destroy()
    if FlickAdapter._state ~= "initialized" then return end
    isShooting = false
    if inputBeganConn then inputBeganConn:Disconnect(); inputBeganConn = nil end
    if inputEndedConn then inputEndedConn:Disconnect(); inputEndedConn = nil end
    pcall(function() RunService:UnbindFromRenderStep("Sacrament_AbsoluteCamlock") end)
    FlickAdapter._state = "destroyed"
end

return FlickAdapter
