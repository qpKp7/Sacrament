--!strict
local Import = (_G :: any).SacramentImport

local SecurityManager = Import("logic/security/manager") -- Importando o Escudo
local InputHandler = Import("input/inputhandler")
local UIManager = Import("gui/uimanager")
local Settings = Import("logic/settings")

-- Importando os Motores de Combate
local LoopManager = Import("logic/core/loop")
local Aimlock = Import("logic/func/combat/aimlock/main")
local SilentAim = Import("logic/func/combat/silentaim/main") -- [NOVO] O Orquestrador do Silent Aim

export type Adapter = {
    mountGui: (gui: ScreenGui) -> (),
    connectInputBegan: (callback: (InputObject, boolean) -> ()) -> RBXScriptConnection,
    getViewportSize: () -> Vector2
}

local App = {}

function App.Start(adapter: Adapter)
    -- 1. LIGA O ESCUDO PRIMEIRO (Garante que a UI já nasça protegida e os Hooks fiquem prontos)
    if SecurityManager and type(SecurityManager.Init) == "function" then
        SecurityManager.Init()
    end

    -- 2. Inicializa os inputs e a interface visual
    InputHandler.Init(adapter)
    UIManager.Init(adapter, Settings)

    -- 3. LIGA O MOTOR DO JOGO E OS MÓDULOS DE COMBATE (A mágica acontece aqui!)
    if LoopManager and type(LoopManager.Init) == "function" then
        LoopManager.Init()
    end
    if Aimlock and type(Aimlock.Init) == "function" then
        Aimlock.Init()
    end
    
    -- [NOVO] Inicia o Silent Aim. Ele vai ler o Executor e decidir sozinho se carrega o Hook ou o Fallback!
    if SilentAim and type(SilentAim.Init) == "function" then
        SilentAim.Init()
    end
end

function App.Stop()
    -- 1. Desliga primeiro os Módulos de Combate e o Loop (Sempre de trás pra frente)
    if SilentAim and type(SilentAim.Destroy) == "function" then
        SilentAim.Destroy()
    end
    if Aimlock and type(Aimlock.Destroy) == "function" then
        Aimlock.Destroy()
    end
    if LoopManager and type(LoopManager.Destroy) == "function" then
        LoopManager.Destroy()
    end

    -- 2. Desliga a interface e os inputs
    InputHandler.Destroy()
    UIManager.Destroy()
    
    -- 3. DESLIGA O ESCUDO E LIMPA OS HOOKS
    if SecurityManager and type(SecurityManager.Destroy) == "function" then
        SecurityManager.Destroy()
    end
end

return App
