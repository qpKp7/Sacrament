--!strict

local Maid = {}
Maid.__index = Maid

export type Task =
	RBXScriptConnection
	| Instance
	| (() -> ())
	| { Destroy: (self: any) -> () }
	| { Disconnect: (self: any) -> () }

export type Maid = typeof(setmetatable({} :: any, Maid)) & {
	Give: (self: Maid, task: Task) -> Task,
	GiveKey: (self: Maid, key: any, task: Task) -> Task,
	Cleanup: (self: Maid) -> (),
	Destroy: (self: Maid) -> (),
}

type MaidImpl = Maid & {
	_tasks: { [any]: Task },
	_order: { any },
}

local function doTask(task: Task)
	local t = typeof(task)
	if t == "RBXScriptConnection" then
		(task :: RBXScriptConnection):Disconnect()
		return
	end
	if t == "Instance" then
		(task :: Instance):Destroy()
		return
	end
	if t == "function" then
		(task :: () -> ())()
		return
	end

	if (task :: any).Disconnect then
		(task :: any):Disconnect()
		return
	end
	if (task :: any).Destroy then
		(task :: any):Destroy()
		return
	end
end

function Maid.new(): Maid
	local self = setmetatable({}, Maid) :: MaidImpl
	self._tasks = {}
	self._order = {}
	return self
end

function Maid:Give(task: Task): Task
	local key = #((self :: MaidImpl)._order) + 1
	return self:GiveKey(key, task)
end

function Maid:GiveKey(key: any, task: Task): Task
	local selfImpl = self :: MaidImpl

	if selfImpl._tasks[key] ~= nil then
		doTask(selfImpl._tasks[key])
	end

	selfImpl._tasks[key] = task
	table.insert(selfImpl._order, key)

	return task
end

function Maid:Cleanup()
	local selfImpl = self :: MaidImpl
	for _, key in ipairs(selfImpl._order) do
		local task = selfImpl._tasks[key]
		if task ~= nil then
			doTask(task)
			selfImpl._tasks[key] = nil
		end
	end
	table.clear(selfImpl._order)
end

function Maid:Destroy()
	self:Cleanup()
end

return Maid
