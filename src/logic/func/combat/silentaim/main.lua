--!strict
local Import = (_G :: any).SacramentImport
local Registry = Import("logic/core/backend_registry")
local Telemetry = Import("logic/core/telemetry")

-- Registrando os backends disponíveis
Registry.Register("SilentAim_Unsupported", Import("logic/func/combat/silentaim/backend/unsupported"))
Registry.Register("SilentAim_Hook", Import("logic/func/combat/silentaim/backend/hook"))

local SilentAim = {}
local isInitialized = false
local activeBackendName = nil

function SilentAim.Init()
    if isInitialized then return end

    -- Roteamento Inteligente
    local canLoadHook, hookReason = Registry.CanLoad("SilentAim_Hook")
    
    if canLoadHook then
        activeBackendName = "SilentAim_Hook"
        Telemetry.Log("INFO", "SilentAim", "Capacidade detectada. Carregando backend de interceptação.")
    else
        activeBackendName = "SilentAim_Unsupported"
        Telemetry.Log("WARN", "SilentAim", "Hook negado (" .. hookReason .. "). Carregando fallback.")
    end
    
    local backend = Registry.Get(activeBackendName)
    if not backend then
        Telemetry.Log("ERROR", "SilentAim", "Backend nulo ausente do Registry.")
        return
    end

    local status = backend.load()

    if status == "initialized" or status == "unsupported" or status == "degraded" then
        isInitialized = true
        Telemetry.Log("LITURGY", "SilentAim", "Estado final da inicialização: " .. status)
    else
        Telemetry.Log("ERROR", "SilentAim", "Falha crítica no backend - módulo isolado.")
    end
end

function SilentAim.Destroy()
    if not isInitialized then return end
    
    if activeBackendName then
        local backend = Registry.Get(activeBackendName)
        if backend then backend.destroy() end
    end
    
    isInitialized = false
    Telemetry.Log("LITURGY", "SilentAim", "Backend destruído com segurança.")
end

return SilentAim
