--!strict
--[[
    SACRAMENT | Backend Contract
    Interface abstrata que todo backend DEVE implementar.
]]
export type Contract = {
    canLoad: () -> (boolean, string),
    load: () -> string, -- Retorna: initialized, degraded, unsupported, failed
    destroy: () -> (),
    health: () -> string,
    requirements: () -> {[string]: boolean},
    assumptions: () -> string
}

return {}
