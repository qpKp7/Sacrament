--!strict
local InputHandler = require(script.Parent.input.inputhandler)
local UIManager = require(script.Parent.gui.uimanager)

export type Adapter = {
    mountGui: (gui: ScreenGui) -> (),
    connectInputBegan: (callback: (InputObject, boolean) -> ()) -> RBXScriptConnection,
    getViewportSize: () -> Vector2
}

local App = {}

function App.Start(adapter: Adapter?)
    InputHandler.Init(adapter)
    UIManager.Init(adapter)
end

function App.Stop()
    InputHandler.Destroy()
    UIManager.Destroy()
end

return App
