-- Sacrament Loader - versão final para Xeno (usa game:HttpGet como principal, fallback request/httpget)

local HttpService = game:GetService("HttpService")

local function HttpGet(url)
    print("[Loader Debug] Tentando baixar: " .. url)
    
    -- Prioridade 1: game:HttpGet (testado e funcionando no seu Xeno)
    local success, content = pcall(game.HttpGet, game, url, true)
    if success then
        print("[Loader Debug] game:HttpGet OK - length: " .. #content)
        return content
    else
        warn("[Loader Debug] game:HttpGet falhou: " .. tostring(content))
    end
    
    -- Prioridade 2: request (se disponível)
    if request then
        local success, res = pcall(request, {Url = url, Method = "GET"})
        if success and res and res.Success then
            print("[Loader Debug] request OK")
            return res.Body
        else
            warn("[Loader Debug] request falhou: " .. tostring(res and res.StatusMessage or "nil"))
        end
    end
    
    -- Prioridade 3: httpget
    if httpget then
        local success, body = pcall(httpget, url)
        if success then
            print("[Loader Debug] httpget OK")
            return body
        else
            warn("[Loader Debug] httpget falhou: " .. tostring(body))
        end
    end
    
    error("[Sacrament Loader] Nenhum método HTTP funcionou.")
end

local baseUrl = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/"

local function loadModule(path)
    local url = baseUrl .. path
    local content = HttpGet(url)  -- já printa debug dentro
    
    if not content then
        warn("[Sacrament] Fetch falhou para: " .. path)
        return nil
    end
    
    local func, err = loadstring(content)
    if not func then
        warn("[Sacrament] Loadstring falhou para " .. path .. ": " .. tostring(err))
        return nil
    end
    
    print("[Loader Debug] " .. path .. " compilado OK")
    return func()
end

local Sacrament = {}

function Sacrament:Init()
    print("[Sacrament] Framework iniciado no Xeno - v0.1 dev")
    
    local Config = loadModule("src/config_defaults.lua")
    if Config then
        print("[Sacrament] Config carregada OK")
        print("Debug AimlockKey: " .. tostring(Config.Current.AimlockKey and Config.Current.AimlockKey.Name))
    else
        warn("[Sacrament] Config falhou")
    end
    
    local InputModule = loadModule("src/input.lua")
    if InputModule and Config then
        InputModule:Init(Config)
        print("[Sacrament] Input inicializado OK")
    else
        warn("[Sacrament] Input falhou - verifique arquivo")
    end
end

return Sacrament
