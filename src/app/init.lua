--!strict
local Import = (_G :: any).SacramentImport

local SecurityManager = Import("logic/security/manager") -- Importando o Escudo
local InputHandler = Import("input/inputhandler")
local UIManager = Import("gui/uimanager")
local Settings = Import("logic/settings")

-- [NOVO] Importando o Maestro e o Aimlock
local LoopManager = Import("logic/core/loop")
local Aimlock = Import("logic/func/combat/aimlock/main")

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

    -- 3. LIGA O MOTOR DO JOGO E O AIMLOCK (A mágica acontece aqui!)
    if LoopManager and type(LoopManager.Init) == "function" then
        LoopManager.Init()
    end
    if Aimlock and type(Aimlock.Init) == "function" then
        Aimlock.Init()
    end
end

function App.Stop()
    -- 1. Desliga primeiro os Módulos de Combate e o Loop
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
