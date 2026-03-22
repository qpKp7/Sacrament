--!strict
local Import = (_G :: any).SacramentImport
local Capability = Import("logic/core/capability")
local Telemetry = Import("logic/core/telemetry")

local SecurityManager = {}
local isInitialized = false

function SecurityManager.Init()
    if isInitialized then return end
    
    local health = Capability.GetHealth({SupportsHookMeta = true, SupportsRawMeta = true})
    
    if health == "unavailable" then
        Telemetry.Log("LITURGY", "Security", "Modo degradado ativo. O executor não suporta Hooks nativos.")
        isInitialized = true
        return
    end

    Telemetry.Log("INFO", "Security", "Escudo inicializado com capacidade total.")
    isInitialized = true
end

function SecurityManager.Destroy()
    if not isInitialized then return end
    isInitialized = false
    Telemetry.Log("LITURGY", "Security", "Destruído com segurança.")
end

return SecurityManager
