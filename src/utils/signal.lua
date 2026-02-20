--!strict

local Signal = {}
Signal.__index = Signal

export type Connection = {
	Disconnect: (self: Connection) -> (),
	Connected: boolean,
}

export type Signal<T...> = typeof(setmetatable({} :: any, Signal)) & {
	Connect: (self: Signal<T...>, fn: (T...) -> ()) -> Connection,
	Once: (self: Signal<T...>, fn: (T...) -> ()) -> Connection,
	Fire: (self: Signal<T...>, ...T...) -> (),
	Destroy: (self: Signal<T...>) -> (),
}

type Handler<T...> = {
	fn: (T...) -> (),
	once: boolean,
	connected: boolean,
}

type SignalImpl<T...> = Signal<T...> & {
	_handlers: { Handler<T...> },
	_destroyed: boolean,
}

local function newConnection(disconnectFn: () -> ()): Connection
	local conn = { Connected = true } :: any
	function conn:Disconnect()
		if not self.Connected then
			return
		end
		self.Connected = false
		disconnectFn()
	end
	return conn :: Connection
end

function Signal.new<T...>(): Signal<T...>
	local self = setmetatable({}, Signal) :: SignalImpl<T...>
	self._handlers = {}
	self._destroyed = false
	return self
end

function Signal:Connect<T...>(fn: (T...) -> ()): Connection
	local selfImpl = self :: SignalImpl<T...>
	if selfImpl._destroyed then
		error("Signal is destroyed", 2)
	end

	local handler: Handler<T...> = { fn = fn, once = false, connected = true }
	table.insert(selfImpl._handlers, handler)

	return newConnection(function()
		handler.connected = false
	end)
end

function Signal:Once<T...>(fn: (T...) -> ()): Connection
	local selfImpl = self :: SignalImpl<T...>
	if selfImpl._destroyed then
		error("Signal is destroyed", 2)
	end

	local handler: Handler<T...> = { fn = fn, once = true, connected = true }
	table.insert(selfImpl._handlers, handler)

	return newConnection(function()
		handler.connected = false
	end)
end

function Signal:Fire<T...>(...: T...)
	local selfImpl = self :: SignalImpl<T...>
	if selfImpl._destroyed then
		return
	end

	local handlers = selfImpl._handlers
	for i = 1, #handlers do
		local h = handlers[i]
		if h and h.connected then
			h.fn(...)
			if h.once then
				h.connected = false
			end
		end
	end
end

function Signal:Destroy()
	local selfImpl = self :: SignalImpl<any>
	if selfImpl._destroyed then
		return
	end
	selfImpl._destroyed = true
	table.clear(selfImpl._handlers)
end

return Signal
