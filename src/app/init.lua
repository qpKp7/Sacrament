--!strict
local Import = (_G :: any).SacramentImport
local InputHandler = Import("input/inputhandler")
local UIManager = Import("gui/uimanager")

local App = {}

function App.Start(adapter: any?)
    InputHandler.Init(adapter)
    UIManager.Init(adapter)
end

function App.Stop()
    InputHandler.Destroy()
    UIManager.Destroy()
end

return App
