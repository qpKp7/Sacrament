--!strict

local UIState = require(script.Parent.ui_state)

export type TabId = UIState.TabId
export type State = UIState.State

export type Listener = (state: State) -> ()

export type Store = {
	getState: (self: Store) -> State,
	subscribe: (self: Store, listener: Listener) -> RBXScriptConnection,

	setOpen: (self: Store, isOpen: boolean) -> (),
	setActiveTab: (self: Store, tabId: TabId) -> (),

	destroy: (self: Store) -> (),
}

type StoreImpl = Store & {
	_state: State,
	_changed: BindableEvent,
}

local StoreModule = {}
StoreModule.__index = StoreModule

local function cloneState(s: State): State
	return {
		isOpen = s.isOpen,
		activeTabId = s.activeTabId,
	}
end

function StoreModule.new(initial: State?): Store
	local self = setmetatable({}, StoreModule) :: StoreImpl
	self._state = if initial ~= nil then cloneState(initial) else UIState.create()
	self._changed = Instance.new("BindableEvent")
	return self
end

function StoreModule:getState(): State
	return self._state
end

function StoreModule:subscribe(listener: Listener): RBXScriptConnection
	return (self :: StoreImpl)._changed.Event:Connect(listener)
end

function StoreModule:_commit(nextState: State)
	local impl = self :: StoreImpl
	impl._state = nextState
	impl._changed:Fire(nextState)
end

function StoreModule:setOpen(isOpen: boolean)
	local impl = self :: StoreImpl
	if impl._state.isOpen == isOpen then
		return
	end

	local nextState = cloneState(impl._state)
	nextState.isOpen = isOpen
	self:_commit(nextState)
end

function StoreModule:setActiveTab(tabId: TabId)
	local impl = self :: StoreImpl
	if impl._state.activeTabId == tabId then
		return
	end

	local nextState = cloneState(impl._state)
	nextState.activeTabId = tabId
	self:_commit(nextState)
end

function StoreModule:destroy()
	local impl = self :: StoreImpl
	impl._changed:Destroy()
end

return StoreModule
