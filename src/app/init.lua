--!strict
local Import = (_G :: any).SacramentImport

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
    InputHandler.Init(adapter)
    UIManager.Init(adapter, Settings)
end

function App.Stop()
    InputHandler.Destroy()
    UIManager.Destroy()
end

return App
