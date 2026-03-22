--!strict
--[[
    SACRAMENT | Backend Registry
    Ponto único de registro e recuperação de backends.
]]
local Registry = {}
local backends: {[string]: any} = {}

function Registry.Register(backendName: string, contractTable: any)
    backends[backendName] = contractTable
end

function Registry.Get(backendName: string): any?
    return backends[backendName]
end

function Registry.CanLoad(backendName: string): (boolean, string)
    local backend = backends[backendName]
    if not backend then 
        return false, "Backend não registrado: " .. backendName 
    end
    return backend.canLoad()
end

return Registry
