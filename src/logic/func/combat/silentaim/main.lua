--!strict
--[[
    SACRAMENT | Silent Aim Orchestrator
    Gerencia a inicialização e o fail-over automático dos backends de interceptação.
]]

local Import = (_G :: any).SacramentImport
local Registry = Import("logic/core/backend_registry")
local Telemetry = Import("logic/core/telemetry")

local SilentAim = {}
local isInitialized = false
local activeBackendName: string? = nil

-- [O Rito de Sucessão]
-- Define a ordem de prioridade. Se o primeiro falhar, o sistema tenta o próximo.
local BACKEND_FALLBACK_CHAIN = {
    "mouse_spoof",      -- Tentativa 1: Ideal para jogos antigos baseados em Mouse.Hit
    "physical_raycast"  -- Tentativa 2: Ideal para jogos modernos e bypass em executores restritos
}

function SilentAim.Init()
    if isInitialized then return "initialized" end

    Telemetry.Log("LITURGY", "SilentAim", "Iniciando orquestração de backends...")

    -- Itera sobre a cadeia de responsabilidade
    for _, backendName in ipairs(BACKEND_FALLBACK_CHAIN) do
        local backend = Registry.Get(backendName)

        if not backend then
            Telemetry.Log("WARN", "SilentAim", "Backend ausente no registro: " .. backendName)
            continue
        end

        -- 1. Verificação Teórica: O executor diz que suporta as funções necessárias?
        local canLoad, reason = backend.canLoad()
        if not canLoad then
            Telemetry.Log("WARN", "SilentAim", string.format("Backend '%s' ignorado: %s", backendName, reason))
            continue
        end

        -- 2. Teste Prático: O rito de interceptação funcionou de verdade?
        local status = backend.load()
        if status == "initialized" then
            activeBackendName = backendName
            isInitialized = true
            
            Telemetry.Log("LITURGY", "SilentAim", string.format("Orquestração concluída. Backend ativo: [%s]", backendName))
            return "initialized"
        else
            -- Se falhou no teste de sanidade local (fail-closed), avisamos e pulamos para o próximo
            Telemetry.Log("WARN", "SilentAim", string.format("Backend '%s' falhou no teste prático. Acionando fallback...", backendName))
        end
    end

    -- Se o loop terminar e nada carregar, o ambiente é 100% hostil
    Telemetry.Log("ERROR", "SilentAim", "Falha crítica: Nenhum backend de intercepção pôde ser inicializado neste executor.")
    return "failed"
end

function SilentAim.Destroy()
    if not isInitialized or not activeBackendName then return end

    local backend = Registry.Get(activeBackendName)
    if backend and type(backend.destroy) == "function" then 
        backend.destroy() 
    end

    activeBackendName = nil
    isInitialized = false
    Telemetry.Log("LITURGY", "SilentAim", "Orquestrador desligado e hooks purgados com segurança.")
end

-- Retorna qual backend está operando (útil para debug e UI)
function SilentAim.GetActiveBackend(): string
    return activeBackendName or "None"
end

return SilentAim
