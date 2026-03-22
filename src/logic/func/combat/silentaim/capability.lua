--!strict
--[[
    SACRAMENT | Capability Detector
    Verifica as funções que o executor atual suporta de forma segura.
--]]

local Capability = {}

function Capability.Get()
    return {
        SupportsHookMetaMethod = (type(hookmetamethod) == "function"),
        SupportsHookFunction   = (type(hookfunction) == "function"),
        SupportsGetRawMeta     = (type(getrawmetatable) == "function"),
        SupportsDrawing        = (type(Drawing) == "table" and type(Drawing.new) == "function")
    }
end

return Capability
