--!strict
--[[
    SACRAMENT | Flick Adapter Backend (The Hyper-Flick)
    Garante o redirecionamento mecânico mais rápido possível pelo motor (1 Frame).
    Suporta armas automáticas (Hold M1).
]]

local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local Import = (_G :: any).SacramentImport
local Telemetry = Import("logic/core/telemetry")

local FlickAdapter = {}
FlickAdapter._state = "unsupported"

local isShooting = false
local flickConnectionBegan: RBXScriptConnection? = nil
local flickConnectionEnded: RBXScriptConnection? = nil

-- ==========================================
-- CONTRATO DO BACKEND
-- ==========================================
function FlickAdapter.canLoad()
    return true, "Manipulação de CFrame é universal."
end

function FlickAdapter.load()
    if FlickAdapter._state == "initialized" then return "initialized" end

    local Controller = Import("logic/func/combat/silentaim/main")

    -- Detecta quando começa a atirar
    flickConnectionBegan = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isShooting = true
            
            -- Cria uma thread assíncrona para não travar o jogo
            task.spawn(function()
                while isShooting do
                    if Controller and type(Controller.GetLockedTargetPart) == "function" then
                        local targetPart = Controller.GetLockedTargetPart()
                        
                        if targetPart and targetPart:IsA("BasePart") then
                            local camera = Workspace.CurrentCamera
                            if camera then
                                -- 1. Salva a posição exata da câmera
                                local originalCFrame = camera.CFrame
                                
                                -- 2. O HYPER-FLICK: Vira para a cabeça do alvo
                                camera.CFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
                                
                                -- 3. Yield de 1 Tick (O limite absoluto de velocidade do Luau)
                                task.wait() 
                                
                                -- 4. Restaura a câmera. O olho humano percebe apenas uma vibração.
                                camera.CFrame = originalCFrame
                            end
                        end
                    end
                    -- Pequeno respiro mecânico para a tela voltar ao normal entre os tiros
                    task.wait() 
                end
            end)
        end
    end)

    -- Detecta quando para de atirar
    flickConnectionEnded = UserInputService.InputEnded:Connect(function(input, gpe)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isShooting = false
        end
    end)

    FlickAdapter._state = "initialized"
    Telemetry.Log("LITURGY", "SilentAim", "Backend flick_adapter → initialized | Hyper-Flick (Auto-Fire) ativo.")
    return "initialized"
end

function FlickAdapter.destroy()
    if FlickAdapter._state ~= "initialized" then return end
    
    isShooting = false
    if flickConnectionBegan then flickConnectionBegan:Disconnect(); flickConnectionBegan = nil end
    if flickConnectionEnded then flickConnectionEnded:Disconnect(); flickConnectionEnded = nil end
    
    FlickAdapter._state = "destroyed"
    Telemetry.Log("LITURGY", "SilentAim", "Backend flick_adapter → destroyed | Eventos purgados.")
end

return FlickAdapter
