--!strict
-- SACRAMENT | Combat Core: Silent Aim (Adaptive Manager)
-- Ambiente: Roblox Studio / Aim BOT Research
local Import = (_G :: any).SacramentImport
local Registry = Import("logic/core/backend_registry")
local Telemetry = Import("logic/core/telemetry")

local SilentAim = {}
local isInitialized: boolean = false
local activeBackendName: string? = nil

-- A Hierarquia dos Ritos (Do mais puro ao mais bruto)
-- O sistema tentará carregar na ordem definida aqui.
local BACKEND_PRIORITY = {
    "mouse_spoof",    -- Nível 1: Metatable Hook (True Silent)
    "flick_adapter"   -- Nível 2: Degraded Redirection (Camera Flick)
}

function SilentAim.Init(): string
    if isInitialized then return "initialized" end

    Telemetry.Log("INFO", "SilentAim", "Iniciando varredura de adaptadores de combate...")

    for _, backendName in ipairs(BACKEND_PRIORITY) do
        local backend = Registry.Get(backendName)
        
        if not backend then
            Telemetry.Log("WARN", "SilentAim", "Backend ausente no registro: " .. backendName)
            continue -- Pula para o próximo da lista
        end

        local canLoad, reason = backend.canLoad()
        if canLoad then
            local status = backend.load()
            
            if status == "initialized" or status == "degraded" then
                activeBackendName = backendName
                isInitialized = true
                
                -- Log Litúrgico de Sucesso
                local rank = (backendName == "mouse_spoof") and "Rito Puro" or "Rito Degradado"
                Telemetry.Log("SUCCESS", "SilentAim", "Ancorado com sucesso via " .. backendName .. " (" .. rank .. ")")
                
                return status
            else
                Telemetry.Log("ERROR", "SilentAim", "Falha crítica ao carregar " .. backendName .. " → " .. status)
            end
        else
            Telemetry.Log("INFO", "SilentAim", "Ignorando " .. backendName .. " → " .. reason)
        end
    end

    -- Se o loop terminar e nada carregar, o limite absoluto foi atingido.
    Telemetry.Log("WARN", "SilentAim", "Nenhum adaptador suportado. O módulo transitará para unsupported permanente.")
    return "unsupported"
end

function SilentAim.Destroy()
    if not isInitialized then return end
    
    if activeBackendName then
        local backend = Registry.Get(activeBackendName)
        if backend and backend.destroy then 
            backend.destroy() 
            Telemetry.Log("INFO", "SilentAim", "Adaptador " .. activeBackendName .. " desativado.")
        end
    end
    
    activeBackendName = nil
    isInitialized = false
end

return SilentAim
