--!strict

local UIState = require(script.Parent.Parent.state.ui_state)

export type State = UIState.State

export type Store = {
	getState: (self: Store) -> State,
	setOpen: (self: Store, isOpen: boolean) -> (),
}

export type Adapter = {
	connectInputBegan: (fn: (input: InputObject, gameProcessed: boolean) -> ()) -> RBXScriptConnection,
}

export type Config = {
	ToggleKey: Enum.KeyCode,
}

local ToggleController = {}

function ToggleController.start(adapter: Adapter, store: Store, config: Config): RBXScriptConnection
	return adapter.connectInputBegan(function(input: InputObject, gameProcessed: boolean)
		if gameProcessed then
			return
		end

		if input.KeyCode ~= config.ToggleKey then
			return
		end

		local state = store:getState()
		store:setOpen(not state.isOpen)
	end)
end

return ToggleController
