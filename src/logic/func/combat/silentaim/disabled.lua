--!strict
--[[
    SACRAMENT | Disabled Backend (Fallback)
    Carregado automaticamente quando o executor não suporta o Silent Aim.
--]]

local DisabledBackend = {}

function DisabledBackend.Init()
    warn("[SACRAMENT] 🛡️ Fallback ativado: O executor não suporta hookmetamethod. Silent Aim desativado com segurança.")
end

function DisabledBackend.Destroy()
    -- Não há nada para limpar aqui
end

return DisabledBackend
