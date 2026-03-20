--!strict
local Import = (_G :: any).SacramentImport

local SecurityManager = Import("logic/security/manager") -- [NOVO] Importando o Escudo
local InputHandler = Import("input/inputhandler")
local UIManager = Import("gui/uimanager")
local Settings = Import("logic/settings")

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
end

function App.Stop()
    -- 1. Desliga a interface e os inputs
    InputHandler.Destroy()
    UIManager.Destroy()
    
    -- 2. DESLIGA O ESCUDO E LIMPA OS HOOKS
    -- (Garante que o jogo volte 100% ao normal se você clicar no botão de "Unload" do seu executor)
    if SecurityManager and type(SecurityManager.Destroy) == "function" then
        SecurityManager.Destroy()
    end
end

return App
