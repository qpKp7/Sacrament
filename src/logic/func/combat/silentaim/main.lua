--!strict
local Import = (_G :: any).SacramentImport
local Registry = Import("logic/core/backend_registry")
local Telemetry = Import("logic/core/telemetry")

-- Registrando o backend nulo (futuramente você registra o hook.lua aqui também)
Registry.Register("SilentAim_Unsupported", Import("logic/func/combat/silentaim/backend/unsupported"))

local SilentAim = {}
local isInitialized = false
local activeBackendName = nil

function SilentAim.Init()
    if isInitialized then return end

    -- Por enquanto, forçamos o Unsupported para garantir que o boot está limpo.
    -- Quando criarmos o contrato do Hook, faremos a checagem via Registry.CanLoad()
    activeBackendName = "SilentAim_Unsupported"
    
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
