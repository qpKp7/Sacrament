--!strict
local Import = (_G :: any).SacramentImport

local SecurityManager = Import("logic/security/manager") 
local InputHandler = Import("input/inputhandler")
local UIManager = Import("gui/uimanager")
local Settings = Import("logic/settings")

-- Importando os Motores de Combate
local LoopManager = Import("logic/core/loop")
local Aimlock = Import("logic/func/combat/aimlock/main")
local SilentAim = Import("logic/func/combat/silentaim/main") -- [NOVO] O Silent Aim chegou!

export type Adapter = {
    mountGui: (gui: ScreenGui) -> (),
    connectInputBegan: (callback: (InputObject, boolean) -> ()) -> RBXScriptConnection,
    getViewportSize: () -> Vector2
}

local App = {}

function App.Start(adapter: Adapter)
    -- 1. Liga a Segurança
    if SecurityManager and type(SecurityManager.Init) == "function" then
        SecurityManager.Init()
    end

    -- 2. Inicializa UI e Inputs
    InputHandler.Init(adapter)
    UIManager.Init(adapter, Settings)

    -- 3. Liga o Motor e as Funções
    if LoopManager and type(LoopManager.Init) == "function" then
        LoopManager.Init()
    end
    if Aimlock and type(Aimlock.Init) == "function" then
        Aimlock.Init()
    end
    
    -- [NOVO] LIGA O SILENT AIM
    if SilentAim and type(SilentAim.Init) == "function" then
        SilentAim.Init()
    end
end

function App.Stop()
    -- Desliga as funções primeiro
    if SilentAim and type(SilentAim.Destroy) == "function" then
        SilentAim.Destroy()
    end
    if Aimlock and type(Aimlock.Destroy) == "function" then
        Aimlock.Destroy()
    end
    if LoopManager and type(LoopManager.Destroy) == "function" then
        LoopManager.Destroy()
    end

    InputHandler.Destroy()
    UIManager.Destroy()
    
    if SecurityManager and type(SecurityManager.Destroy) == "function" then
        SecurityManager.Destroy()
    end
end

return App
