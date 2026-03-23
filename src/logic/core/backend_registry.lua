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

-- ====================================================================
-- REGISTROS OFICIAIS DA DOUTRINA
-- ====================================================================
local Import = (_G :: any).SacramentImport

Registry.Register("unsupported", Import("logic/func/combat/silentaim/backend/unsupported"))
Registry.Register("mouse_spoof", Import("logic/func/combat/silentaim/backend/mouse_spoof"))
-- Registry.Register("physical_raycast", Import("logic/func/combat/silentaim/backend/physical_raycast"))

return Registry
