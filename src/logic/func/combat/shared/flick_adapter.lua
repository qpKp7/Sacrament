--!strict
-- SACRAMENT | Flick Adapter (Degraded Redirection)
-- Ambiente: Roblox Studio / Aim BOT Research
-- Objetivo: Forçar CFrame de 1 Frame e gerar assinatura angular para o Anti-Cheat.

local FlickAdapter = {}

-- Dependências do Framework
local Predict = require(script.Parent.predict)
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Cofre de Estado Interno do Adaptador
type FlickState = {
    IsFlicking: boolean,
    OriginalCFrame: CFrame?,
    TargetCFrame: CFrame?,
    FrameCount: number
}

local State: FlickState = {
    IsFlicking = false,
    OriginalCFrame = nil,
    TargetCFrame = nil,
    FrameCount = 0
}

--[[
    Calcula a Matriz de Transformação exata para o ponto predito.
    @param targetPart A hitbox do inimigo (ex: Head)
    @param prediction O valor de predição (Tabela de Ping ou Math)
]]
function FlickAdapter.CalculateMatrix(targetPart: BasePart, prediction: number): CFrame?
    if not targetPart then return nil end
    
    -- Chama o módulo de predição que refinamos anteriormente
    local predictedPosition = Predict.GetPosition(targetPart, prediction, true)
    
    -- Retorna a matriz olhando para o futuro
    return CFrame.lookAt(Camera.CFrame.Position, predictedPosition)
end

--[[
    O Rito de Execução: Inicia a Anomalia de 1 Frame.
    Deve ser chamado exatamente no milissegundo em que o Input de disparo ocorre.
]]
function FlickAdapter.Engage(targetPart: BasePart, prediction: number)
    if State.IsFlicking then return end -- Previne sobreposição de flicks
    
    local newCFrame = FlickAdapter.CalculateMatrix(targetPart, prediction)
    if not newCFrame then return end
    
    -- 1. Salva a realidade (Estado Original)
    State.OriginalCFrame = Camera.CFrame
    State.TargetCFrame = newCFrame
    State.IsFlicking = true
    State.FrameCount = 0
    
    -- 2. Dobra a realidade (Aplica o Flick)
    Camera.CFrame = newCFrame
end

--[[
    O Rito de Restauração: Devolve a câmera ao jogador.
    Rodar via RenderStepped garante que a restauração ocorra antes da próxima renderização visual.
]]
local function RestoreCycle()
    if not State.IsFlicking or not State.OriginalCFrame then return end
    
    -- Conta quantos frames se passaram desde o Engage
    State.FrameCount += 1
    
    -- No exato frame seguinte (Frame 1), devolve a câmera
    if State.FrameCount >= 1 then
        Camera.CFrame = State.OriginalCFrame
        
        -- Limpa o estado (Fail-Closed)
        State.IsFlicking = false
        State.OriginalCFrame = nil
        State.TargetCFrame = nil
        State.FrameCount = 0
    end
end

-- Conecta a restauração ao motor de renderização do jogo
RunService.RenderStepped:Connect(RestoreCycle)

return FlickAdapter
