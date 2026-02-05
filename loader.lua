-- Sacrament Loader --

local function HttpGet(url)
    if request then
        local success, res = pcall(request, {Url = url, Method = "GET"})
        if success and res and res.Success then
            return res.Body
        end
    end
    
    if httpget then
        local success, body = pcall(httpget, url)
        if success then
            return body
        end
    end
    
    if http and http.request then
        local success, res = pcall(http.request, {Url = url, Method = "GET"})
        if success and res then
            return res.Body
        end
    end
    
    error("[Sacrament Loader] Nenhum método HTTP compatível no Xeno.")
end

local baseUrl = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/"

local function loadModule(path)
    local url = baseUrl .. path
    local success, content = pcall(HttpGet, url)
    
    if not success then
        warn("[Sacrament] Falha ao baixar: " .. path .. " | Erro: " .. tostring(content))
        return nil
    end
    
    local func, err = loadstring(content)
    if not func then
        warn("[Sacrament] Erro loadstring: " .. path .. " | " .. tostring(err))
        return nil
    end
    
    return func()
end

local Sacrament = {}

function Sacrament:Init()
    print("[Sacrament] Framework carregado no Xeno - v0.1 dev")
    
    local Config = loadModule("src/config_defaults.lua")
    if Config then
        print("[Sacrament] Config padrão carregada com sucesso.")
        print("Exemplo: AimlockKey = " .. tostring(Config.Current.AimlockKey.Name))
    else
        warn("[Sacrament] Falhou ao carregar config_defaults.lua")
    end
    
    local InputModule = loadModule("src/input.lua")
    if InputModule then
        InputModule:Init(Config)
        print("[Sacrament] Input module carregado.")
    else
        warn("[Sacrament] Falhou ao carregar input.lua")
    end
end

return Sacrament
