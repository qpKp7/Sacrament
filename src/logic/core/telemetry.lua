--!strict
--[[
    SACRAMENT | Telemetry System
    Garante que todo log siga o mesmo idioma doutrinário.
]]
local Telemetry = {}

function Telemetry.Log(level: string, system: string, message: string)
    local prefix = "[SACRAMENT | " .. system .. "]"
    if level == "INFO" then
        print(prefix .. " ℹ️ " .. message)
    elseif level == "WARN" then
        warn(prefix .. " ⚠️ " .. message)
    elseif level == "ERROR" then
        warn(prefix .. " ❌ " .. message)
    elseif level == "LITURGY" then
        warn(prefix .. " 🛡️ " .. message)
    end
end

return Telemetry
