--!strict
-- SACRAMENT | Backend: Flick Adapter (Redirecionamento Degradado)
-- Mantém a arquitetura do repositório sem funções nativas exclusivas do Studio.
local Import = (_G :: any).SacramentImport
local Registry = Import("logic/core/backend_registry")
local Telemetry = Import("logic/core/telemetry")

-- Seus outros modulos (descomente e ajuste conforme a sua arvore)
-- local UIState = Import("logic/core/ui_state")
-- local Predict = Import("logic/func/combat/shared/predict") 

local FlickAdapter = {}
local isLoaded = false
local flickConnection: RBXScriptConnection? = nil

-- 1. O Contrato de Capacidade
function FlickAdapter.canLoad(): (boolean, string)
    -- O Flick usa apenas manipulação de CFrame, algo que 100% dos executores suportam.
    return true, "Manipulacao de CFrame suportada."
end

-- 2. O Rito de Inicialização
function FlickAdapter.load(): string
    if isLoaded then return "degraded" end

    -- Aqui você iniciará a conexão do seu FlickBot 
    -- (ex: conectando ao Mouse.Button1Down ou Tool.Activated)
    -- flickConnection = game:GetService("UserInputService").InputBegan:Connect(...)
    
    isLoaded = true
    Telemetry.Log("INFO", "FlickAdapter", "Backend ancorado e em modo de escuta.")
    
    -- Retorna "degraded" para o main.lua saber que não é o rito puro
    return "degraded" 
end

-- 3. O Rito de Destruição
function FlickAdapter.destroy()
    if flickConnection then
        flickConnection:Disconnect()
        flickConnection = nil
    end
    isLoaded = false
end

-- 4. O Registro Canônico (CRUCIAL PARA RESOLVER SEU ERRO)
Registry.Register("flick_adapter", FlickAdapter)

return FlickAdapter
