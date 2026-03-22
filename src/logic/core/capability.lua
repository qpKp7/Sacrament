--!strict
local Capability = {}

function Capability.Get()
    return {
        SupportsHookMeta = (type(hookmetamethod) == "function"),
        SupportsRawMeta  = (type(getrawmetatable) == "function"),
        SupportsDrawing  = (type(Drawing) == "table"),
        SupportsMouseRel = (type(mousemoverel) == "function") -- Essencial para o novo Magnet Aim
    }
end

return Capability
