--!strict
--[[
    SACRAMENT | Silent Aim Orchestrator
    Gerencia a inicialização, o registro prévio e o fail-over automático dos backends.
]]

local Import = (_G :: any).SacramentImport
local Registry = Import("logic/core/backend_registry")
local Telemetry = Import("logic/core/telemetry")

-- ==========================================
-- RITO DE ARMAMENTO (PRE-REGISTRATION)
-- ==========================================
-- Garante que os arquivos existam na memória e sejam mapeados no Cartógrafo 
-- ANTES do Orquestrador tentar inicializá-los.
local function PreRegisterBackends()
    local success, err = pcall(function()
        local mouse_spoof = Import("logic/func/combat/silentaim/backend/mouse_spoof")
        local physical_raycast = Import("logic/func/combat/silentaim/backend/physical_raycast")
        
        -- Mapeia no registro usando a função apropriada do seu backend_registry.lua
        if type(Registry.Register) == "function" then
            Registry.Register("mouse_spoof", mouse_spoof)
            Registry.Register("physical_raycast", physical_raycast)
        end
    end)

    if not success then
        Telemetry.Log("ERROR", "SilentAim", "Falha crítica no Rito de Armamento (Import): " .. tostring(err))
    end
end

-- Executa o registro imediatamente ao ler este arquivo
PreRegisterBackends()

-- ==========================================
-- ORQUESTRADOR
-- ==========================================
local SilentAim = {}
local isInitialized = false
local activeBackendName: string? = nil

-- Define a ordem de prioridade. Se a porta da frente trancar, tenta a dos fundos.
local BACKEND_FALLBACK_CHAIN = {
    "mouse_spoof",      -- Tentativa 1: Jogos legacy baseados em Mouse.Hit
    "physical_raycast"  -- Tentativa 2: Jogos modernos e bypass em executores restritos (Xeno)
}

function SilentAim.Init()
    if isInitialized then return "initialized" end

    Telemetry.Log("LITURGY", "SilentAim", "Iniciando orquestração de backends...")

    -- Itera sobre a cadeia de responsabilidade
    for _, backendName in ipairs(BACKEND_FALLBACK_CHAIN) do
        local backend = Registry.Get(backendName) -- O Cartógrafo agora terá a resposta!

        if not backend then
            Telemetry.Log("WARN", "SilentAim", "Backend ausente no registro: " .. backendName)
            continue
        end

        -- 1. Verificação Teórica: O executor suporta as funções necessárias?
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
            -- Se falhou no teste de sanidade local, avisa e pula para o próximo
            Telemetry.Log("WARN", "SilentAim", string.format("Backend '%s' falhou no teste prático. Acionando fallback...", backendName))
        end
    end

    -- Se o loop terminar e nada carregar, o ambiente é 100% hostil
    Telemetry.Log("ERROR", "SilentAim", "Falha crítica: Nenhum backend de intercepção pôde ser inicializado neste executor. Verifique o capability.lua.")
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

-- Retorna qual backend está operando (útil para debug na UI)
function SilentAim.GetActiveBackend(): string
    return activeBackendName or "None"
end

return SilentAim
