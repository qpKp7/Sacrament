-- Sacrament Loader - v0.3 dev - GUI modular dark theme
-- Otimizado para Xeno, Solara, Fluxus, Electron etc.
-- Carrega via raw GitHub - estrutura atual: src/gui/init.lua como entry point

local function HttpGet(url)
    print("[Loader Debug] Tentando game:HttpGet → " .. url)
    local success, result = pcall(function()
        return game:HttpGet(url, true)
    end)
    if success then
        print("[Loader Debug] Sucesso - tamanho: " .. #result .. " bytes")
        return result
    else
        warn("[Loader Debug] HttpGet falhou: " .. tostring(result))
        return nil
    end
end

local baseUrl = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/"
local function loadModule(path)
    local url = baseUrl .. path
    local content = HttpGet(url)
    if not content then
        warn("[Loader] Falha ao baixar módulo: " .. path)
        return nil
    end

    local func, err = loadstring(content, "@" .. path)
    if not func then
        warn("[Loader] loadstring falhou em " .. path .. ": " .. tostring(err))
        return nil
    end

    local success, module = pcall(func)
    if not success then
        warn("[Loader] Execução do módulo falhou em " .. path .. ": " .. tostring(module))
        return nil
    end

    print("[Loader Debug] " .. path .. " carregado com sucesso")
    return module
end

local Sacrament = {}
function Sacrament:Init()
    print("[Sacrament Loader] Iniciando v0.3 dev - GUI modular dark/underground")

    -- 1. Configuração base
    local Config = loadModule("src/config_defaults.lua")
    if not Config then
        warn("[Sacrament] Falha crítica: config_defaults.lua não carregado")
        return
    end
    print("[Sacrament] Configuração base OK")

    -- 2. Sistema de input (teclas E/Q/Insert + states)
    local InputModule = loadModule("src/input.lua")
    if not InputModule then
        warn("[Sacrament] Falha crítica: input.lua não carregado")
        return
    end
    local inputSuccess, inputErr = pcall(InputModule.Init, InputModule, Config)
    if not inputSuccess then
        warn("[Sacrament] Falha ao inicializar InputModule: " .. tostring(inputErr))
        return
    end
    print("[Sacrament] Input system inicializado (E/Q/Insert)")

    -- 3. Nova GUI modular (src/gui/init.lua)
    local GuiModule = loadModule("src/gui/init.lua")
    if not GuiModule then
        warn("[Sacrament] Falha crítica: src/gui/init.lua não carregado")
        return
    end

    -- Passa os states do input (assumindo que input.lua expõe .States)
    local states = InputModule.States or {}
    local guiSuccess, guiErr = pcall(GuiModule.Init, GuiModule, states)
    if not guiSuccess then
        warn("[Sacrament] Falha ao inicializar GUI: " .. tostring(guiErr))
        return
    end
    print("[Sacrament] GUI modular dark carregada com sucesso (SACRAMENT AIMLOCK)")

    -- Mensagem final de sucesso
    print("──────────────────────────────────────────────")
    print("  Sacrament Aim System v0.3 dev - Pronto!")
    print("──────────────────────────────────────────────")
    print(" → Insert       → Toggle GUI")
    print(" → E            → Aimlock Toggle")
    print(" → Q            → Silent Aim Toggle")
    print(" → Arraste a janela para mover")
    print(" → Edite Prediction/Smoothness nos campos")
    print("──────────────────────────────────────────────")
    print("[Sacrament] Inicialização completa - teste em jogo PVP")
end

-- Auto-init (opcional - comente se quiser chamar manualmente)
Sacrament:Init()

return Sacrament
