--!strict
--[[
    SACRAMENT | Security Manager
    Responsável por inicializar e gerenciar todas as camadas de anti-detect.
--]]

local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

-- Importamos os submódulos de segurança (que vamos criar em seguida)
local Protection = SafeImport("logic/security/protection")
local Hooks      = SafeImport("logic/security/hooks")
local Spoofing   = SafeImport("logic/security/spoofing")

local SecurityManager = {}
local securityMaid = Maid.new()
local isInitialized = false

--[[
    Inicializa o Escudo.
    Deve ser chamado no main.lua ANTES dos módulos de Combat e Visual.
]]
function SecurityManager.Init()
    if isInitialized then return end
    isInitialized = true

    -- 1. Proteção de Instâncias (Esconde a UI no CoreGui/gethui, protege contra FindFirstChild)
    if Protection and type(Protection.Init) == "function" then
        Protection.Init(securityMaid)
    end

    -- 2. Interceptação de Metamethods (__namecall, __index, __newindex)
    if Hooks and type(Hooks.Init) == "function" then
        Hooks.Init(securityMaid)
    end

    -- 3. Spoofing de Valores (Engana o servidor enviando WalkSpeed 16, etc.)
    if Spoofing and type(Spoofing.Init) == "function" then
        Spoofing.Init(securityMaid)
    end

    warn("[SACRAMENT] 🛡️ Security Manager inicializado. Escudo ATIVADO.")
end

--[[
    Desliga as proteções e limpa a memória (Útil para o botão de "Unload" do script)
]]
function SecurityManager.Destroy()
    if not isInitialized then return end
    
    securityMaid:DoCleaning()
    isInitialized = false
    
    warn("[SACRAMENT] ⚠️ Security Manager finalizado. Escudo DESATIVADO.")
end

return SecurityManager
