--!strict
--[[
    SACRAMENT | Capability Detector Global
    A única fonte de verdade sobre o que o executor suporta.
]]
local Capability = {}

function Capability.Get()
    return {
        SupportsHookMeta = (type(hookmetamethod) == "function"),
        SupportsHookFunc = (type(hookfunction) == "function"),
        SupportsRawMeta  = (type(getrawmetatable) == "function"),
        SupportsDrawing  = (type(Drawing) == "table" and type(Drawing.new) == "function")
    }
end

-- Retorna o estado de saúde explícito baseado nas dependências
function Capability.GetHealth(requirements: {[string]: boolean}): string
    local caps = Capability.Get()
    for req, needed in pairs(requirements) do
        if needed and not caps[req] then
            return "unavailable"
        end
    end
    return "supported"
end

return Capability
