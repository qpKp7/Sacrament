--!strict
--[[
    SACRAMENT | Loop Manager
    O "Maestro" do script. Centraliza os eventos do RunService para otimizar 
    a performance (FPS) e garantir a ordem correta de execução.
--]]

local RunService = game:GetService("RunService")
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local LoopManager = {}
local loopMaid = Maid.new()

-- Usamos dicionários para que seja super rápido adicionar e remover tarefas (O(1))
local renderCallbacks: { [string]: (number) -> () } = {}
local heartbeatCallbacks: { [string]: (number) -> () } = {}

local isInitialized = false

function LoopManager.Init()
    if isInitialized then return end
    isInitialized = true

    -- 📸 LOOP DE RENDERIZAÇÃO (Roda a cada frame ANTES da tela ser desenhada)
    -- Ideal para: Câmera (Aimlock), Desenhos na tela (ESP, FOV).
    loopMaid:GiveTask(RunService.RenderStepped:Connect(function(deltaTime: number)
        for id, callback in pairs(renderCallbacks) do
            -- Chamada direta para máxima performance (144+ FPS)
            callback(deltaTime)
        end
    end))

    -- 🏃‍♂️ LOOP DE FÍSICA (Roda após a física do jogo ser calculada)
    -- Ideal para: Movimentação (WalkSpeed, Fly, Noclip).
    loopMaid:GiveTask(RunService.Heartbeat:Connect(function(deltaTime: number)
        for id, callback in pairs(heartbeatCallbacks) do
            callback(deltaTime)
        end
    end))

    warn("[SACRAMENT] ⚙️ Loop Manager inicializado.")
end

-- =========================================================================
-- API PUBLICA (Como os outros módulos vão se conectar ao Maestro)
-- =========================================================================

-- Conecta uma função ao RenderStepped
function LoopManager.BindToRender(id: string, callback: (number) -> ())
    renderCallbacks[id] = callback
end

-- Desconecta uma função do RenderStepped (Use quando o usuário desligar a função no Menu)
function LoopManager.UnbindFromRender(id: string)
    renderCallbacks[id] = nil
end

-- Conecta uma função ao Heartbeat
function LoopManager.BindToHeartbeat(id: string, callback: (number) -> ())
    heartbeatCallbacks[id] = callback
end

-- Desconecta uma função do Heartbeat
function LoopManager.UnbindFromHeartbeat(id: string)
    heartbeatCallbacks[id] = nil
end

-- =========================================================================

function LoopManager.Destroy()
    if not isInitialized then return end
    
    loopMaid:DoCleaning()
    table.clear(renderCallbacks)
    table.clear(heartbeatCallbacks)
    isInitialized = false
    
    warn("[SACRAMENT] ⚙️ Loop Manager finalizado.")
end

return LoopManager
