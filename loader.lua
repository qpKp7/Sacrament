-- Sacrament Loader - v0.2 dev - otimizado para Xeno/Solara/Fluxus
-- Carrega apenas a nova GUI dark (sem duplicatas)

local function HttpGet(url)
    print("[Loader Debug] Tentando game:HttpGet → " .. url)
    local success, content = pcall(game.HttpGet, game, url, true)
    if success then
        print("[Loader Debug] Sucesso - length: " .. #content)
        return content
    else
        warn("[Loader Debug] HttpGet falhou: " .. tostring(content))
        return nil
    end
end

local baseUrl = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/"

local function loadModule(path)
    local url = baseUrl .. path
    local content = HttpGet(url)
    if not content then
        warn("[Loader] Falha ao baixar: " .. path)
        return nil
    end

    local func, err = loadstring(content, "@" .. path)
    if not func then
        warn("[Loader] loadstring falhou em " .. path .. ": " .. tostring(err))
        return nil
    end

    print("[Loader Debug] " .. path .. " carregado OK")
    return func()
end

local Sacrament = {}

function Sacrament:Init()
    print("[Sacrament] Iniciando v0.2 dev - nova GUI dark")

    -- 1. Configuração base
    local Config = loadModule("src/config_defaults.lua")
    if not Config then
        warn("[Sacrament] Config falhou - abortando")
        return
    end
    print("[Sacrament] Config OK")

    -- 2. Sistema de input (teclas E/Q/Insert)
    local InputModule = loadModule("src/input.lua")
    if not InputModule then
        warn("[Sacrament] Input falhou - abortando")
        return
    end
    InputModule:Init(Config)
    print("[Sacrament] Input inicializado")

    -- 3. GUI nova (a grande dark com título vermelho, PVP CONTROLS, etc.)
    local GuiModule = loadModule("src/gui.lua")
    if not GuiModule then
        warn("[Sacrament] GUI falhou - verifique src/gui.lua")
        return
    end
    GuiModule:Init(InputModule)
    print("[Sacrament] Nova GUI dark carregada (SACRAMENT AIMLOCK)")

    -- Mensagem final de sucesso
    print("[Sacrament] Init completa")
    print("   → Insert = toggle GUI")
    print("   → E = Aimlock toggle")
    print("   → Q = Silent Aim toggle")
end

return Sacrament
