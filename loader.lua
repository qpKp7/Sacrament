-- Sacrament Loader - v0.3 flat corrigido (05/02/2026)
-- Carregamento flat sem require relativo → resolve "attempt to index nil with 'main_frame'"
-- Usa _G.SacramentModules para compartilhar todos os módulos da gui/
-- Compatível com Synapse X / Script-Ware / Fluxus / Solara / Xeno etc.

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local baseUrl = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/src/"

-- Tabela global para módulos (acesso flat sem script.Parent)
_G.SacramentModules = _G.SacramentModules or {}

local function HttpGet(url)
    local success, result = pcall(function()
        return HttpService:GetAsync(url, true)
    end)
    if success then
        return result
    else
        warn("[Loader] HttpGet falhou: " .. tostring(result))
        return nil
    end
end

local function loadModule(path)
    local url = baseUrl .. path
    local content = HttpGet(url)
    if not content or content == "" then
        warn("[Loader] Falha ao baixar ou conteúdo vazio: " .. path)
        return nil
    end

    local func, err = loadstring(content, "@Sacrament/" .. path)
    if not func then
        warn("[Loader] loadstring falhou em " .. path .. ": " .. tostring(err))
        return nil
    end

    local module = func()
    _G.SacramentModules[path] = module
    print("[Loader] Carregado com sucesso: " .. path)
    return module
end

local function main()
    print("[Sacrament Loader] Iniciando carregamento flat v0.3 - " .. os.date("%d/%m/%Y %H:%M"))

    -- Ordem crítica: dependências primeiro
    loadModule("config_defaults.lua")
    local States = loadModule("input.lua")               -- retorna tabela com .AimlockEnabled etc.

    -- Componentes da GUI (carrega na ordem de dependência)
    loadModule("gui/components/helpers.lua")
    loadModule("gui/components/section.lua")
    loadModule("gui/components/toggle.lua")
    loadModule("gui/components/input.lua")               -- componente Input (não confundir com input.lua)
    loadModule("gui/updater.lua")
    loadModule("gui/main_frame.lua")
    
    -- Por último: init.lua (depende de todos os anteriores)
    local Gui = loadModule("gui/init.lua")

    -- Inicialização
    if not States then
        warn("[Loader] CRÍTICO: input.lua (States) não carregou")
        return
    end

    if States.Init then
        States:Init(_G.SacramentModules["config_defaults.lua"])
        print("[Loader] States (input.lua) inicializado")
    end

    if not Gui then
        warn("[Loader] CRÍTICO: gui/init.lua não carregou")
        return
    end

    if Gui.Init then
        Gui:Init(States)
        print("[Loader] GUI inicializada - Insert para toggle")
    else
        warn("[Loader] gui/init.lua não tem método :Init()")
    end

    -- Garantia extra: toggle Insert caso input.lua não esteja capturando
    local guiToggleConnection
    guiToggleConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            if Gui and Gui.Toggle and Gui.ScreenGui then
                Gui:Toggle(not Gui.ScreenGui.Enabled)
            elseif States and States.GuiVisible ~= nil then
                States.GuiVisible = not States.GuiVisible
                print("[Loader fallback] States.GuiVisible toggled para " .. tostring(States.GuiVisible))
            end
        end
    end)

    -- Cleanup ao destruir (opcional, mas bom)
    game:BindToClose(function()
        if guiToggleConnection then
            guiToggleConnection:Disconnect()
        end
    end)

    print("[Sacrament Loader] Carregamento concluído com sucesso")
    print("   Comandos:")
    print("   → Insert → toggle GUI")
    print("   → E     → toggle Aimlock")
    print("   → Q     → toggle Silent Aim")
end

-- Executa
pcall(main)

-- Mensagem de debug final
if _G.SacramentModules["gui/init.lua"] then
    print("[Loader Debug] GUI module presente na tabela global")
else
    warn("[Loader Debug] GUI module NÃO encontrado na tabela global")
end
