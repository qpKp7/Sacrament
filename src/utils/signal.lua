--!strict
export type Connection = {
    Disconnect: (self: Connection) -> ()
}

export type Signal<T...> = {
    Connect: (self: Signal<T...>, callback: (T...) -> ()) -> Connection,
    Fire: (self: Signal<T...>, T...) -> (),
    Destroy: (self: Signal<T...>) -> ()
}

local Connection = {}
Connection.__index = Connection

function Connection.new(signal: any, callback: (...any) -> ()): Connection
    local self = setmetatable({}, Connection)
    self._signal = signal
    self._callback = callback
    self._connected = true
    return self
end

function Connection:Disconnect()
    if not self._connected then return end
    self._connected = false
    
    for i, conn in ipairs(self._signal._connections) do
        if conn == self then
            table.remove(self._signal._connections, i)
            break
        end
    end
end

local Signal = {}
Signal.__index = Signal

function Signal.new<T...>(): Signal<T...>
    local self = setmetatable({}, Signal)
    self._connections = {}
    return (self :: any) :: Signal<T...>
end

function Signal:Connect(callback: (...any) -> ()): Connection
    local connection = Connection.new(self, callback)
    table.insert(self._connections, connection)
    return connection
end

function Signal:Fire(...)
    for _, connection in ipairs(self._connections) do
        if connection._connected then
            task.spawn(connection._callback, ...)
        end
    end
end

function Signal:Destroy()
    for _, connection in ipairs(self._connections) do
        connection._connected = false
    end
    table.clear(self._connections)
end

return Signal
