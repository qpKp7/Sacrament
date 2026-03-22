--!strict
--[[
    SACRAMENT | Shared Prediction
    Calcula a posição futura do alvo baseada na sua velocidade e no ping do jogador.
    Essencial para acertar tiros com precisão perfeita mesmo com lag alto.
--]]

local Stats = game:GetService("Stats")
local Predict = {}

--[[
    Obtém o ping atual do jogador em milissegundos.
]]
local function GetRealPing(): number
    local success, ping = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    -- Se der erro ao ler o ping, retorna um valor médio (70ms)
    return success and ping or 70
end

--[[
    Calcula o ponto exato onde a mira deve focar ou o tiro deve ir.
    
    @param targetPart: A parte do corpo do inimigo (ex: Head, Torso).
    @param predictionValue: O valor manual do UI (ex: 0.135). Se AutoPredict estiver ligado, isto é ignorado.
    @param autoPredict: Booleano que define se o script deve calcular o delay sozinho usando o Ping.
    
    @return Vector3: A coordenada 3D do "futuro" do alvo.
--]]
function Predict.GetPosition(targetPart: BasePart, predictionValue: number, autoPredict: boolean): Vector3
    if not targetPart then return Vector3.zero end

    local position = targetPart.Position
    local velocity = targetPart.AssemblyLinearVelocity

    -- Se o cara estiver parado, não tem o que prever, atira direto nele.
    if velocity.Magnitude < 1 then
        return position
    end

    local finalPredictionFactor = predictionValue

    if autoPredict then
        -- A Mágica do Auto-Predict:
        -- Transforma o ping (ex: 120ms) em segundos (0.12) e adiciona 
        -- uma constante de compensação do motor do Roblox.
        local currentPing = GetRealPing()
        finalPredictionFactor = (currentPing / 1000) + 0.015
    end

    -- Calcula a posição futura: Posição Atual + (Velocidade * Atraso)
    local predictedPosition = position + (velocity * finalPredictionFactor)

    return predictedPosition
end

return Predict
