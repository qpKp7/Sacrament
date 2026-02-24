--!strict
local InputHandler = require(script.Parent.input.InputHandler)
local UIManager = require(script.Parent.gui.UIManager)

local App = {}

function App.Start(): ()
	InputHandler.Init()
	UIManager.Init()
end

function App.Stop(): ()
	InputHandler.Destroy()
	UIManager.Destroy()
end

return App
