--!strict
local Predict = {}

--[[
    Calcula a posição futura do alvo usando a física do Roblox.
    @param targetPart A parte do corpo que a mira tá grudada (ex: Head)
    @param predictionValue O valor que você digita no menu (ex: 0.135, 0.157)
]]
function Predict.GetPosition(targetPart: BasePart, predictionValue: number, autoPredict: boolean): Vector3
    if not targetPart then return Vector3.zero end

    local position = targetPart.Position
    -- Usa AssemblyLinearVelocity que é a física real do motor do Roblox
    local velocity = targetPart.AssemblyLinearVelocity

    -- Se o inimigo estiver parado ou andando muito devagar, não faz prediction
    -- (Evita que a mira fique tremendo quando o cara tá parado)
    if velocity.Magnitude < 2 then
        return position
    end

    -- Fórmula Padrão da Indústria (Da Hood / Hood Modded / Rivals)
    -- Posição do Futuro = Posição Atual + (Velocidade do Inimigo * Atraso do Ping)
    local predictedPosition = position + (velocity * predictionValue)

    return predictedPosition
end

return Predict
