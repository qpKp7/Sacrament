local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local BASE_URL = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/src/"

_G.SacramentModules = _G.SacramentModules or {}

local function safeHttpGet(url)
    local success, result = pcall(function()
        return HttpService:GetAsync(url, true)
    end)
    if not success then
        return false, "HttpGet falhou (pcall): " .. tostring(result)
    end
    return true, result
end

local function loadModule(path)
    local fullUrl = BASE_URL .. path
    print(string.format("[Loader DIAGNOSTIC] Tentando GET: %s", fullUrl))
    
    local httpOk, body = safeHttpGet(fullUrl)
    
    if not httpOk then
        warn(string.format("[Loader] HTTP ERROR em %s → %s", path, body))
        return nil
    end
    
    if body == nil or body == "" then
        warn(string.format("[Loader] Corpo vazio para %s", path))
        return nil
    end
    
    local len = #body
    local head = body:sub(1, math.min(120, len)):gsub("\n", " "):gsub("\r", "")
    
    print(string.format("[Loader] HTTP OK | len=%d | head=\"%s...\"", len, head))
    
    -- Detector de conteúdo inválido
    if head:find("404: Not Found") or head:find("<!DOCTYPE html") or head:find("<html") then
        warn("[Loader CRÍTICO] Conteúdo NÃO é Lua válido (provável 404 ou página HTML do GitHub). Verifique BASE_URL ou use raw link correto.")
        return nil
    end
    
    local func, compileErr = loadstring(body, "@Sacrament/" .. path)
    if not func then
        warn(string.format("[Loader] loadstring falhou em %s → %s", path, tostring(compileErr)))
        return nil
    end
    
    local successRun, module = pcall(func)
    if not successRun then
        warn(string.format("[Loader] Erro ao executar módulo %s → %s", path, tostring(module)))
        return nil
    end
    
    _G.SacramentModules[path] = module
    print(string.format("[Loader] Carregado OK: %s", path))
    return module
end

local function main()
    print("[Sacrament Loader] Modo diagnóstico ativado - " .. os.date("%H:%M:%S"))
    
    local modulesToLoad = {
        "config_defaults.lua",
        "input.lua",
        "gui/components/helpers.lua",
        "gui/components/section.lua",
        "gui/components/toggle.lua",
        "gui/components/input.lua",
        "gui/updater.lua",
        "gui/main_frame.lua",
        "gui/init.lua"
    }
    
    for _, path in ipairs(modulesToLoad) do
        loadModule(path)
    end
    
    local States = _G.SacramentModules["input.lua"]
    local Gui    = _G.SacramentModules["gui/init.lua"]
    
    print("[Loader Sanity Check]")
    print("  input.lua presente? " .. (States and "SIM" or "NÃO"))
    print("  gui/init.lua presente? " .. (Gui and "SIM" or "NÃO"))
    print("  config_defaults.lua presente? " .. (_G.SacramentModules["config_defaults.lua"] and "SIM" or "NÃO"))
    
    if not States then
        warn("[Loader] States (input.lua) NÃO carregado → pulando inicialização")
        return
    end
    
    if States.Init then
        local cfg = _G.SacramentModules["config_defaults.lua"]
        if cfg then
            States:Init(cfg)
            print("[Loader] States inicializado")
        else
            warn("[Loader] Config defaults não encontrado → States:Init pulado")
        end
    end
    
    if not Gui then
        warn("[Loader] Gui (init.lua) NÃO carregado → pulando inicialização da GUI")
        return
    end
    
    if Gui.Init then
        Gui:Init(States)
        print("[Loader] GUI inicializada")
    else
        warn("[Loader] gui/init.lua não tem método :Init")
    end
    
    -- Toggle Insert (fallback)
    local conn = UserInputService.InputBegan:Connect(function(input, gproc)
        if gproc then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            if Gui and Gui.Toggle and Gui.ScreenGui then
                Gui:Toggle(not Gui.ScreenGui.Enabled)
                print("[Fallback] GUI toggled via Insert")
            end
        end
    end)
    
    game:BindToClose(function()
        if conn then conn:Disconnect() end
    end)
end

pcall(main)
print("[Loader] Execução concluída (diagnóstico ativo)")
