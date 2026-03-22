--!strict
--[[
    SACRAMENT | Shared KnockCheck
    Verifica se o alvo está nocauteado (Knocked/Downed) ou morto.
    Essencial para evitar que a mira grude em jogadores que já estão no chão.
--]]

local KnockCheck = {}

-- Nomes comuns de variáveis usadas por jogos (Da Hood, etc.) para definir o estado de nocaute
local KNOCK_INDICATORS = {"K.O", "KO", "Knocked", "Downed", "IsKnocked"}

--[[
    Verifica se o jogador está fora de combate (morto ou nocauteado).
    
    @param player: O jogador alvo.
    @return boolean: true se estiver nocauteado/morto, false se estiver de pé e pronto para apanhar.
--]]
function KnockCheck.IsKnocked(player: Player): boolean
    if not player then return true end
    
    local character = player.Character
    if not character then return true end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return true end

    -- 1. Verificação básica de vida (Se já morreu, ignora)
    if humanoid.Health <= 0 then return true end
    if humanoid:GetState() == Enum.HumanoidStateType.Dead then return true end

    -- 2. Verificação Universal do Roblox (Muitos jogos usam PlatformStand para deitar o boneco)
    -- Só consideramos se a vida também estiver baixa, para não confundir com outras mecânicas.
    -- (Opcional, mas ajuda em jogos sem BodyEffects)
    -- if humanoid.PlatformStand and humanoid.Health < 15 then return true end

    -- 3. Verificação Específica de Jogos (A magia negra para Da Hood & afins)
    -- A maioria dos jogos guarda estas "tags" diretamente no Character ou numa pasta BodyEffects
    local bodyEffects = character:FindFirstChild("BodyEffects")

    for _, indicatorName in ipairs(KNOCK_INDICATORS) do
        -- Procura diretamente no corpo do jogador
        local val = character:FindFirstChild(indicatorName)
        if val and val:IsA("BoolValue") and val.Value == true then
            return true
        end
        
        -- Procura na pasta BodyEffects (Padrão Da Hood)
        if bodyEffects then
            local beVal = bodyEffects:FindFirstChild(indicatorName)
            if beVal and beVal:IsA("BoolValue") and beVal.Value == true then
                return true
            end
        end
    end

    -- Se passou por tudo isto e não ativou nada, o tipo está vivo e de pé!
    return false
end

return KnockCheck
