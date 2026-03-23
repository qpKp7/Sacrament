--!strict
--[[
    SACRAMENT | Motor Balístico Preditivo
    Calcula o deslocamento futuro do alvo. Suporta Auto-Prediction adaptativo.
]]
local Players = game:GetService("Players")
local Predict = {}

function Predict.GetPosition(targetPart: BasePart, predictionValue: number, autoPredict: boolean): Vector3
    if not targetPart then return Vector3.zero end

    local position = targetPart.Position
    local velocity = targetPart.AssemblyLinearVelocity

    -- Prevenção de micro-tremores em alvos parados
    if velocity.Magnitude < 2 then
        return position
    end

    local finalPrediction = predictionValue

    if autoPredict then
        local pingMs = 50 -- Valor padrão seguro
        local localPlayer = Players.LocalPlayer
        
        if localPlayer then
            local success, pingSeconds = pcall(function() return localPlayer:GetNetworkPing() end)
            if success and pingSeconds > 0 then
                pingMs = pingSeconds * 1000
            else
                -- Fallback para jogos legacy
                local stats = game:GetService("Stats")
                local netStats = stats:FindFirstChild("Network")
                if netStats then
                    local serverStats = netStats:FindFirstChild("ServerStatsItem")
                    if serverStats then
                        local pingStr = serverStats:FindFirstChild("Data Ping") :: StringValue
                        if pingStr and pingStr.Value then
                            pingMs = tonumber(string.match(pingStr.Value, "%d+")) or 50
                        end
                    end
                end
            end
        end

        -- Matriz Clássica de Atraso de Engine (Extremamente calibrada para Da Hood / FPS)
        if pingMs < 40 then finalPrediction = 0.1256
        elseif pingMs < 50 then finalPrediction = 0.1225
        elseif pingMs < 60 then finalPrediction = 0.1229
        elseif pingMs < 70 then finalPrediction = 0.131
        elseif pingMs < 80 then finalPrediction = 0.134
        elseif pingMs < 90 then finalPrediction = 0.136
        elseif pingMs < 105 then finalPrediction = 0.138
        elseif pingMs < 110 then finalPrediction = 0.146
        elseif pingMs < 125 then finalPrediction = 0.149
        elseif pingMs < 130 then finalPrediction = 0.151
        else finalPrediction = 0.165
        end
    end

    -- Posição do Futuro = Posição Atual + (Velocidade * Tempo de Viagem Ajustado)
    return position + (velocity * finalPrediction)
end

return Predict
