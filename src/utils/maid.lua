--!strict
export type Maid = {
    GiveTask: (self: Maid, task: any) -> number,
    DoCleaning: (self: Maid) -> (),
    Destroy: (self: Maid) -> ()
}

local Maid = {}
Maid.__index = Maid

function Maid.new(): Maid
    local self = setmetatable({}, Maid)
    self._tasks = {}
    return (self :: any) :: Maid
end

function Maid:GiveTask(task: any): number
    if not task then
        error("Task cannot be false or nil", 2)
    end
    
    local taskId = #self._tasks + 1
    self._tasks[taskId] = task
    return taskId
end

function Maid:DoCleaning()
    local tasks = self._tasks
    self._tasks = {}

    for _, task in pairs(tasks) do
        if type(task) == "function" then
            task()
        elseif typeof(task) == "RBXScriptConnection" then
            task:Disconnect()
        elseif type(task) == "table" and type(task.Destroy) == "function" then
            task:Destroy()
        elseif type(task) == "table" and type(task.Disconnect) == "function" then
            task:Disconnect()
        elseif typeof(task) == "Instance" then
            task:Destroy()
        end
    end
end

function Maid:Destroy()
    self:DoCleaning()
end

return Maid
