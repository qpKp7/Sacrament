--!strict
--[[
    SACRAMENT | Hooks Manager
    Centraliza a interceptação de Metamethods (__namecall, __index, __newindex).
    Evita conflitos entre múltiplos módulos tentando hookar a mesma coisa.
--]]

local HooksManager = {}

-- Tipos de funções para os nossos ouvintes
type NamecallListener = (instance: Instance, method: string, ...any) -> (boolean, any)
type IndexListener = (instance: Instance, index: any) -> (boolean, any)
type NewIndexListener = (instance: Instance, index: any, value: any) -> (boolean)

-- Tabelas que vão guardar quem está "escutando" as interceptações
local namecallListeners: {NamecallListener} = {}
local indexListeners: {IndexListener} = {}
local newIndexListeners: {NewIndexListener} = {}

-- Variáveis para guardar as funções originais do Roblox
local oldNamecall: any
local oldIndex: any
local oldNewIndex: any

local isHooked = false

--[[
    Init
    Faz o hook global. Requer o ambiente de executor (hookmetamethod, newcclosure, etc.)
]]
function HooksManager.Init(securityMaid: any)
    if isHooked then return end
    
    -- Verifica se o executor suporta hookmetamethod (obrigatório para scripts de alto nível)
    if not hookmetamethod or not getnamecallmethod or not newcclosure then
        warn("[SACRAMENT] ⚠️ Executor não suporta hookmetamethod. Segurança comprometida!")
        return
    end

    isHooked = true

    -- 1. Hook de __namecall (Intercepta chamadas como workspace:FindPartOnRay, remotes:FireServer, etc)
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        
        -- Passa a chamada por todos os módulos que estão escutando (Ex: Silent Aim, Anti-Ban)
        for _, listener in ipairs(namecallListeners) do
            local shouldOverride, returnValue = listener(self, method, ...)
            if shouldOverride then
                return returnValue -- Se o módulo disser "Eu cuido disso", cancelamos a original!
            end
        end

        return oldNamecall(self, ...)
    end))

    -- 2. Hook de __index (Intercepta quando o jogo tenta LER uma propriedade, ex: Player.Character)
    oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, index)
        if not checkcaller() then -- Apenas altera o que o JOGO lê, não o que o NOSSO script lê
            for _, listener in ipairs(indexListeners) do
                local shouldOverride, returnValue = listener(self, index)
                if shouldOverride then
                    return returnValue
                end
            end
        end
        return oldIndex(self, index)
    end))

    -- 3. Hook de __newindex (Intercepta quando o jogo tenta ESCREVER uma propriedade, ex: Humanoid.WalkSpeed = 16)
    oldNewIndex = hookmetamethod(game, "__newindex", newcclosure(function(self, index, value)
        if not checkcaller() then
            for _, listener in ipairs(newIndexListeners) do
                local shouldOverride = listener(self, index, value)
                if shouldOverride then
                    return -- Bloqueia a escrita original!
                end
            end
        end
        return oldNewIndex(self, index, value)
    end))

    -- Quando o script fechar (Unload), nós apenas limpamos as listas. 
    -- O hook continuará existindo, mas sem listeners, ele rodará 100% o código original (seguro e sem crash)
    securityMaid:GiveTask(function()
        namecallListeners = {}
        indexListeners = {}
        newIndexListeners = {}
        warn("[SACRAMENT] Hooks desativados (Listeners limpos).")
    end)
end

-- =========================================================================
-- API PUBLICA PARA OS OUTROS MÓDULOS (Combat, Spoofing, etc)
-- =========================================================================

-- Adiciona um observador de Namecall (Ideal para Silent Aim)
function HooksManager.AddNamecallListener(listener: NamecallListener)
    table.insert(namecallListeners, listener)
end

-- Adiciona um observador de Index (Ideal para Spoofing de WalkSpeed/JumpPower)
function HooksManager.AddIndexListener(listener: IndexListener)
    table.insert(indexListeners, listener)
end

-- Adiciona um observador de NewIndex (Impede o jogo de forçar câmera, fov, etc)
function HooksManager.AddNewIndexListener(listener: NewIndexListener)
    table.insert(newIndexListeners, listener)
end

return HooksManager
