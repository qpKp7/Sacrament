-- Sacrament Loader - versão simplificada usando game:HttpGet (testado no Xeno)
-- Atualizado para carregar GUI após Input

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
    
    local func, err = loadstring(content, "@" .. path)  -- nomeia pra debug melhor
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
    
    -- Carrega Config primeiro
    local Config = loadModule("src/config_defaults.lua")
    if Config then
        print("[Sacrament] Config carregada OK")
        print("Debug: AimlockKey = " .. tostring(Config.Current.AimlockKey.Name))
    else
        warn("[Sacrament] Config falhou - verifique nome do arquivo")
        return  -- para aqui se config falhar
    end
    
    -- Carrega Input
    local InputModule = loadModule("src/input.lua")
    if InputModule then
        InputModule:Init(Config)
        print("[Sacrament] Input carregado e inicializado OK")
    else
        warn("[Sacrament] Input falhou - verifique src/input.lua")
        return
    end
    
    -- Carrega GUI (depois do Input, pois depende dos States)
    local GuiModule = loadModule("src/gui.lua")
    if GuiModule then
        GuiModule:Init(InputModule)
        print("[Sacrament] GUI carregada e inicializada OK")
    else
        warn("[Sacrament] GUI falhou - verifique src/gui.lua")
    end
    
    print("[Sacrament] Init completa - pressione Insert para GUI, E/Q para toggles")
end

return Sacrament
