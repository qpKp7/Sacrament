-- Sacrament Loader - versão simplificada usando game:HttpGet (testado no Xeno)

local function HttpGet(url)
    print("[Loader Debug] Tentando game:HttpGet: " .. url)
    local success, content = pcall(game.HttpGet, game, url, true)
    if success then
        print("[Loader Debug] Sucesso - conteúdo length: " .. #content)
        return content
    else
        warn("[Loader Debug] game:HttpGet falhou: " .. tostring(content))
        return nil
    end
end

local baseUrl = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/"

local function loadModule(path)
    local url = baseUrl .. path
    local content = HttpGet(url)
    
    if not content then
        warn("[Sacrament] Fetch falhou para: " .. path)
        return nil
    end
    
    local func, err = loadstring(content)
    if not func then
        warn("[Sacrament] Loadstring falhou para " .. path .. ": " .. tostring(err))
        return nil
    end
    
    print("[Loader Debug] " .. path .. " carregado e compilado OK")
    return func()
end

local Sacrament = {}

function Sacrament:Init()
    print("[Sacrament] Framework iniciado - v0.1 dev")
    
    local Config = loadModule("src/config_defaults.lua")
    if Config then
        print("[Sacrament] Config carregada OK")
        print("Debug: AimlockKey = " .. tostring(Config.Current.AimlockKey.Name))
    else
        warn("[Sacrament] Config falhou - verifique nome do arquivo")
    end
    
    local InputModule = loadModule("src/input.lua")
    if InputModule and Config then
        InputModule:Init(Config)
        print("[Sacrament] Input carregado OK")
    else
        warn("[Sacrament] Input falhou - verifique se src/input.lua existe")
    end
end

return Sacrament
