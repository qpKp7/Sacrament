--!strict
--[[
    SACRAMENT | Silent Aim Hit Chance
    Calcula a probabilidade do tiro ser modificado pelo Silent Aim.
    Mantém a taxa de acerto "humana" para burlar sistemas de detecção e admins.
--]]

local HitChance = {}

-- Semente aleatória para garantir que os tiros não fiquem num padrão repetitivo
math.randomseed(os.time())

--[[
    Roda o "dado" invisível para decidir se o Silent Aim vai agir neste tiro.
    
    @param chance: Valor do Slider da sua interface (0 a 100).
    @return boolean: true se o tiro deve dobrar até a cabeça, false se deve ir reto (errar).
--]]
function HitChance.Roll(chance: number): boolean
    -- Se o jogador configurou 100%, não precisamos calcular nada, acerta sempre.
    if chance >= 100 then
        return true
    end
    
    -- Se estiver zerado, o Silent Aim basicamente não funciona neste tiro.
    if chance <= 0 then
        return false
    end

    -- Sorteia um número quebrado de 0.00 até 100.00 (mais preciso que números inteiros)
    local roll = math.random() * 100

    -- Se o número sorteado for menor ou igual à chance escolhida, atira na cabeça!
    return roll <= chance
end

return HitChance
