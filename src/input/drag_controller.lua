--!strict

local UserInputService = game:GetService("UserInputService")

local UIState = require(script.Parent.Parent.state.ui_state)

export type State = UIState.State

export type Store = {
	getState: (self: Store) -> State,
	subscribe: (self: Store, listener: (state: State) -> ()) -> RBXScriptConnection,
}

export type Adapter = {
	connectInputBegan: (fn: (input: InputObject, gameProcessed: boolean) -> ()) -> RBXScriptConnection,
}

local DragController = {}

local function isWithin(gui: GuiObject, pos: Vector2): boolean
	local ap = gui.AbsolutePosition
	local as = gui.AbsoluteSize
	return pos.X >= ap.X and pos.X <= ap.X + as.X and pos.Y >= ap.Y and pos.Y <= ap.Y + as.Y
end

function DragController.start(adapter: Adapter, store: Store, dragHandle: Frame, mainFrame: Frame)
	local dragging = false
	local dragStart = Vector2.new(0, 0)
	local startPos = mainFrame.Position
	local currentActiveTab = store:getState().activeTabId

	local beganConn = adapter.connectInputBegan(function(input: InputObject, gameProcessed: boolean)
		if gameProcessed then
			return
		end

		if not store:getState().isOpen then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local pos = input.Position
		if not isWithin(dragHandle, pos) then
			return
		end

		dragging = true
		dragStart = pos
		startPos = mainFrame.Position
	end)

	local changedConn = UserInputService.InputChanged:Connect(function(input: InputObject)
		if not dragging then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end)

	local endedConn = UserInputService.InputEnded:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	local storeConn = store:subscribe(function(state: State)
		if not state.isOpen then
			dragging = false
		end
		currentActiveTab = state.activeTabId
	end)

	return {
		beganConn = beganConn,
		changedConn = changedConn,
		endedConn = endedConn,
		storeConn = storeConn,
	}
end

return DragController
