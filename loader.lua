-- Sacrament Loader - versão corrigida para Xeno (prioriza request/httpget)

local function HttpGet(url)
    -- Prioridade 1: request (Xeno usa isso)
    if request then
        local success, res = pcall(request, {Url = url, Method = "GET"})
        if success and res and res.Success then
            return res.Body
        else
            warn("[Loader Debug] request falhou: " .. tostring(res and res.StatusMessage or "nil"))
        end
    end
    
    -- Prioridade 2: httpget
    if httpget then
        local success, body = pcall(httpget, url)
        if success then
            return body
        else
            warn("[Loader Debug] httpget falhou: " .. tostring(body))
        end
    end
    
    -- Sem mais fallbacks - Xeno não precisa de HttpService
    error("[Sacrament Loader] Nenhum método HTTP compatível encontrado no Xeno.")
end

local baseUrl = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/"

local function loadModule(path)
    local url = baseUrl .. path
    print("[Loader Debug] Tentando carregar: " .. url)
    
    local success, content = pcall(HttpGet, url)
    
    if not success then
        warn("[Sacrament] Falha ao baixar módulo: " .. path .. " | Erro: " .. tostring(content))
        return nil
    end
    
    local func, err = loadstring(content)
    if not func then
        warn("[Sacrament] Erro no loadstring de " .. path .. ": " .. tostring(err))
        return nil
    end
    
    print("[Loader Debug] " .. path .. " carregado com sucesso")
    return func()
end

local Sacrament = {}

function Sacrament:Init()
    print("[Sacrament] Framework carregado no Xeno - v0.1 dev")
    
    -- Carrega config
    local Config = loadModule("src/config_defaults.lua")
    if Config then
        print("[Sacrament] Config carregada OK")
        print("Debug: AimlockKey = " .. tostring(Config.Current.AimlockKey and Config.Current.AimlockKey.Name))
    else
        warn("[Sacrament] Config falhou - verifique src/config_defaults.lua")
    end
    
    -- Carrega input
    local InputModule = loadModule("src/input.lua")
    if InputModule and Config then
        InputModule:Init(Config)
        print("[Sacrament] Input carregado e inicializado")
    else
        warn("[Sacrament] Input falhou - verifique src/input.lua ou config")
    end
end

return Sacrament
