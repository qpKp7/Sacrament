-- Sacrament Loader - OTIMIZADO PARA XENO (prioriza request/httpget, ignora HttpService quebrado)

local function HttpGet(url)
    -- Prioridade 1: request (comum em Xeno, Fluxus, Electron)
    if request then
        local success, res = pcall(request, {Url = url, Method = "GET"})
        if success and res and res.Success then
            return res.Body
        end
    end

    -- Prioridade 2: httpget (fallback comum)
    if httpget then
        local success, body = pcall(httpget, url)
        if success then
            return body
        end
    end

    -- Prioridade 3: http.request (alguns variantes usam)
    if http and http.request then
        local success, res = pcall(http.request, {Url = url, Method = "GET"})
        if success and res then
            return res.Body
        end
    end

    -- Sem fallback para HttpService (quebrado no Xeno)
    error("[Sacrament Loader] Nenhum método HTTP compatível encontrado no Xeno. Tente request/httpget.")
end

local baseUrl = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/"

local function loadModule(path)
    local url = baseUrl .. path
    local success, content = pcall(HttpGet, url)

    if not success then
        warn("[Sacrament] Falha ao baixar módulo: " .. path .. " | Erro: " .. tostring(content))
        return nil
    end

    local func, err = loadstring(content)
    if not func then
        warn("[Sacrament] Erro no loadstring do módulo " .. path .. ": " .. tostring(err))
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
        -- Debug: mostra um valor para confirmar
        print("Exemplo: AimlockKey = " .. tostring(Config.Current.AimlockKey))
    else
        warn("[Sacrament] Falhou ao carregar config_defaults.lua - verifique o raw link")
    end
end

return Sacrament
