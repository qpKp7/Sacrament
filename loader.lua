-- Sacrament Loader --

local HttpService = game:GetService("HttpService")

local function HttpGet(url)
    -- Prioridade alta para Xeno/Fluxus/Electron (request ou httpget)
    if request then
        local res = request({Url = url, Method = "GET"})
        return res.Body
    end
    
    if httpget then
        return httpget(url)
    end
    
    -- Fallback http.request
    if http and http.request then
        local res = http.request({Url = url, Method = "GET"})
        return res.Body
    end
    
    -- Último fallback: HttpService (se disponível em algum executor)
    if HttpService.HttpGetAsync then
        return HttpService:HttpGetAsync(url)
    end
    
    -- Se nada funcionar
    error("[Sacrament Loader] Nenhum método HttpGet compatível no Xeno/executor. Verifique se request/httpget está disponível.")
end

local baseUrl = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/"

local function loadModule(path)
    local url = baseUrl .. path
    local success, content = pcall(HttpGet, url)
    
    if not success then
        warn("[Sacrament] Falha ao baixar: " .. path .. " - " .. tostring(content))
        return nil
    end
    
    local func, err = loadstring(content)
    if not func then
        warn("[Sacrament] Erro loadstring em " .. path .. ": " .. tostring(err))
        return nil
    end
    
    return func()
end

local Sacrament = {}

function Sacrament:Init()
    print("[Sacrament] Framework carregado no Xeno - v0.1 dev")
    
    local Config = loadModule("src/config_defaults.lua")
    if Config then
        print("[Sacrament] Config padrão carregada.")
        -- Debug rápido: mostra um valor
        print("AimlockKey default: " .. tostring(Config.Current.AimlockKey))
    else
        warn("[Sacrament] Falhou ao carregar config_defaults.lua")
    end
end

return Sacrament
