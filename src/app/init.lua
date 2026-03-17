--!strict
--[[
    SACRAMENT | Main Entry Point (Bootstrap)
    Responsável pela inicialização do ecossistema, gerenciamento de caminhos
    e ciclo de vida do script no executor.
--]]

local BaseURL = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/src/"

-- =========================================================================
-- SISTEMA DE IMPORTAÇÃO INTELIGENTE (RESOLVE O ERRO 404)
-- =========================================================================
local function smartImport(path: string): any
    -- 1. Tenta o caminho direto (ex: logic/settings.lua)
    local url = BaseURL .. path .. ".lua"
    local success, content = pcall(game.HttpGet, game, url)
    
    -- 2. Se falhar ou retornar 404 do GitHub, tenta o padrão de pacote (init.lua)
    if not success or content:find("404: Not Found") or content:find("Project not found") then
        local initUrl = BaseURL .. path .. "/init.lua"
        local successInit, contentInit = pcall(game.HttpGet, game, initUrl)
        
        if successInit and not (contentInit:find("404: Not Found")) then
            content = contentInit
        else
            error(string.format("[SACRAMENT] Falha fatal ao importar módulo remoto.\nCaminho: %s\nVerifique se o arquivo existe no GitHub.", path))
        end
    end

    -- 3. Compilação do código recebido
    local func, syntaxError = loadstring(content)
    if not func then
        error(string.format("[SACRAMENT] Erro de Sintaxe no módulo '%s':\n%s", path, tostring(syntaxError)))
    end

    -- 4. Execução e retorno do módulo
    local execSuccess, module = pcall(func)
    if not execSuccess then
        error(string.format("[SACRAMENT] Erro de Execução ao carregar '%s':\n%s", path, tostring(module)))
    end

    return module
end

-- Disponibiliza o Import para todo o sistema via shared (Global seguro)
(_G :: any).SacramentImport = smartImport
local Import = smartImport

-- =========================================================================
-- CARREGAMENTO DO NÚCLEO
-- =========================================================================
local InputHandler = Import("input/inputhandler")
local UIManager    = Import("gui/uimanager")
local Settings      = Import("logic/settings")

export type Adapter = {
    mountGui: (gui: ScreenGui) -> (),
    connectInputBegan: (callback: (InputObject, boolean) -> ()) -> RBXScriptConnection,
    getViewportSize: () -> Vector2
}

local App = {}

--[[
    App.Start
    Ponto de ignição do sistema Sacrament.
--]]
function App.Start(adapter: Adapter)
    warn("[SACRAMENT] Iniciando Sistema...")
    
    -- Inicializa a Lógica de Input
    InputHandler.Init(adapter)
    
    -- Inicializa a Interface Gráfica com as configurações injetadas
    UIManager.Init(adapter, Settings)
    
    warn("[SACRAMENT] Sistema carregado com sucesso!")
end

--[[
    App.Stop
    Cleanup completo para permitir re-execução (Hot Reload) sem bugs.
--]]
function App.Stop()
    warn("[SACRAMENT] Encerrando processos...")
    InputHandler.Destroy()
    UIManager.Destroy()
end

return App
