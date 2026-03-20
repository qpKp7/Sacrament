--!strict
--[[
    SACRAMENT | Spoofing Manager
    Fornece uma API simples para falsificar propriedades de instâncias.
    Depende do HooksManager (__index) para interceptar as leituras do jogo.
--]]

local Import = (_G :: any).SacramentImport
local Hooks = Import("logic/security/hooks")

local SpoofingManager = {}
local isInitialized = false

-- Onde guardamos as mentiras: spoofCache[Instancia][Propriedade] = ValorFalso
local spoofCache = {}

function SpoofingManager.Init(securityMaid: any)
    if isInitialized then return end
    isInitialized = true

    -- Conecta-se ao nosso Despachante Central (HooksManager)
    if Hooks and type(Hooks.AddIndexListener) == "function" then
        Hooks.AddIndexListener(function(instance: Instance, index: any)
            -- O jogo está tentando ler algo. Vamos checar se temos uma mentira preparada para isso:
            if spoofCache[instance] and spoofCache[instance][index] ~= nil then
                -- Retorna 'true' (sim, queremos sobrescrever) e o 'valor falso'
                return true, spoofCache[instance][index]
            end
            
            -- Retorna 'false' (não queremos sobrescrever, deixe o jogo ler o valor real)
            return false, nil
        end)
    else
        warn("[SACRAMENT] ⚠️ SpoofingManager não conseguiu encontrar o HooksManager.")
    end

    -- Limpeza de memória caso o usuário descarregue o script
    securityMaid:GiveTask(function()
        spoofCache = {}
        isInitialized = false
    end)
end

--[[
    Spoof
    Aplica um disfarce a uma propriedade de uma instância específica.
    Ex: Spoof(Humanoid, "WalkSpeed", 16)
]]
function SpoofingManager.Spoof(instance: Instance, property: string, fakeValue: any)
    if not spoofCache[instance] then
        spoofCache[instance] = {}
    end
    spoofCache[instance][property] = fakeValue
end

--[[
    Unspoof
    Remove o disfarce, permitindo que o jogo leia o valor real novamente.
]]
function SpoofingManager.Unspoof(instance: Instance, property: string)
    if spoofCache[instance] then
        spoofCache[instance][property] = nil
        
        -- Se não houver mais nada sendo falsificado nessa instância, limpamos a tabela
        if next(spoofCache[instance]) == nil then
            spoofCache[instance] = nil
        end
    end
end

return SpoofingManager
