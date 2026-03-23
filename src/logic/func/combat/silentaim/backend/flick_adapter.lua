--!strict
--[[
    SACRAMENT | Flick Adapter Backend (The Flash-Flick)
    Redirecionamento mecânico na velocidade da luz (1 frame exato).
    Sem loops. Sem grudar a tela. O tiro sai, a câmera volta.
]]

local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Import = (_G :: any).SacramentImport
local Telemetry = Import("logic/core/telemetry")

local FlickAdapter = {}
FlickAdapter._state = "unsupported"
local flickConnection: RBXScriptConnection? = nil

-- ==========================================
-- CONTRATO DO BACKEND
-- ==========================================
function FlickAdapter.canLoad()
    return true, "Manipulação de CFrame é universal e não detectável por anti-hooks."
end

function FlickAdapter.load()
    if FlickAdapter._state == "initialized" then return "initialized" end

    local Controller = Import("logic/func/combat/silentaim/main")

    -- Dispara EXATAMENTE na fração de segundo em que você clica
    flickConnection = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if Controller and type(Controller.GetLockedTargetPart) == "function" then
                local targetPart = Controller.GetLockedTargetPart()
                
                -- Se temos o alvo travado no FOV
                if targetPart and targetPart:IsA("BasePart") then
                    local camera = Workspace.CurrentCamera
                    if not camera then return end

                    -- 1. Snapshot: Salva para onde você estava olhando
                    local originalCFrame = camera.CFrame
                    
                    -- 2. Flash-Flick: Aponta o centro da câmera para o AimPart (Ex: Cabeça)
                    camera.CFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
                    
                    -- 3. Yield de Renderização (Velocidade da Luz)
                    -- O motor do jogo processa o tiro neste exato milissegundo.
                    RunService.RenderStepped:Wait()
                    
                    -- 4. Restauração Imediata: Devolve o controle para você
                    camera.CFrame = originalCFrame
                end
            end
        end
    end)

    FlickAdapter._state = "initialized"
    Telemetry.Log("LITURGY", "SilentAim", "Backend flick_adapter → initialized | Flash-Flick (No-Lock) ativo.")
    return "initialized"
end

function FlickAdapter.destroy()
    if FlickAdapter._state ~= "initialized" then return end
    
    if flickConnection then 
        flickConnection:Disconnect() 
        flickConnection = nil 
    end
    
    FlickAdapter._state = "destroyed"
end

return FlickAdapter
