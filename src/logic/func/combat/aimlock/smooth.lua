--!strict
--[[
    SACRAMENT | Aimlock Smoothness
    Calcula a suavização da câmera.
    Escala da UI:
    0.00 -> Zero suavidade (Mira gruda 100% instantaneamente).
    1.00 -> Máxima suavidade (Mira puxa de forma bem lenta e humana).
--]]

local Smooth = {}

function Smooth.Calculate(currentCFrame: CFrame, targetPosition: Vector3, smoothness: number, deltaTime: number): CFrame
    -- 1. Calcula para onde a câmera deveria olhar se estivesse grudada no alvo
    local goalCFrame = CFrame.new(currentCFrame.Position, targetPosition)

    -- Se o jogador configurou 0 (Zero Suavidade), a mira vira um ímã (Instantâneo)
    if smoothness <= 0.01 then
        return goalCFrame
    end

    -- 2. Inversão Matemática para a sua UI:
    -- Precisamos transformar o seu "Smoothness" (0 a 1) em uma "Velocidade" real.
    -- Smoothness 0.0 = Velocidade Máxima (ex: 30)
    -- Smoothness 1.0 = Velocidade Mínima (ex: 1)
    local maxSpeed = 30
    local minSpeed = 1
    
    -- Fórmula que inverte o valor: quanto maior o smoothness, menor a velocidade final.
    local currentSpeed = minSpeed + ((1 - smoothness) * (maxSpeed - minSpeed))

    -- 3. Proteção contra FPS (Independência de Quadros)
    -- Garante que quem joga a 60 FPS e quem joga a 144 FPS tenham exatamente a mesma suavidade.
    local lerpFactor = 1 - math.exp(-currentSpeed * deltaTime)
    lerpFactor = math.clamp(lerpFactor, 0.001, 1)

    -- 4. Aplica a matemática e retorna o novo ângulo da câmera
    return currentCFrame:Lerp(goalCFrame, lerpFactor)
end

return Smooth
