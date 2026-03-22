--!strict
--[[
    SACRAMENT | Silent Aim Main (Orchestrator)
    Detecta as capacidades do executor e carrega o backend correto,
    evitando crashes ("attempt to call a nil value") no carregamento do projeto.
--]]

local Import = (_G :: any).SacramentImport
local Capability = Import("logic/func/combat/silentaim/capability")

local SilentAim = {}
local isInitialized = false
local activeBackend: any = nil

function SilentAim.Init()
    if isInitialized then return end

    -- 1. Verifica as capacidades físicas do executor ANTES de qualquer coisa
    local env = Capability.Get()

    -- 2. Roteamento Inteligente (A mágica da arquitetura)
    if env.SupportsHookMetaMethod then
        -- O executor aguenta! Carrega o script pesado.
        activeBackend = Import("logic/func/combat/silentaim/backend/hook")
    else
        -- O executor não aguenta (Ex: Xeno). Carrega o fallback de segurança.
        activeBackend = Import("logic/func/combat/silentaim/backend/disabled")
    end

    -- 3. Inicializa o backend escolhido com segurança
    if activeBackend and type(activeBackend.Init) == "function" then
        activeBackend.Init()
    end

    isInitialized = true
end

function SilentAim.Destroy()
    if not isInitialized then return end

    if activeBackend and type(activeBackend.Destroy) == "function" then
        activeBackend.Destroy()
    end
    
    activeBackend = nil
    isInitialized = false
end

return SilentAim
