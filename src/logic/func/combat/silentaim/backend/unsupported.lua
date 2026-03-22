--!strict
--[[
    SACRAMENT | Unsupported Backend (Null Object)
    Declara explicitly "unsupported". Nunca tenta nada, nunca crasha.
]]
local Import = (_G :: any).SacramentImport
local Telemetry = Import("logic/core/telemetry")

local UnsupportedBackend = {}

function UnsupportedBackend.canLoad()
    return true, "Fallback garantido sempre pode ser carregado."
end

function UnsupportedBackend.load()
    Telemetry.Log("LITURGY", "SilentAim", "Pipeline incompatível. Modo Unsupported ativo.")
    return "unsupported"
end

function UnsupportedBackend.destroy()
    -- Null pattern
end

function UnsupportedBackend.health()
    return "unsupported"
end

function UnsupportedBackend.requirements()
    return {}
end

function UnsupportedBackend.assumptions()
    return "Nenhuma capacidade de rede ou memória assumida."
end

return UnsupportedBackend
