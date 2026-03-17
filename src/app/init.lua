--!strict
--[[ SACRAMENT | Main Root Loader ]]--

local BaseURL = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/"

-- Função de importação robusta
local function smartImport(path: string): any
    -- Tenta o arquivo .lua direto (ex: utils/maid.lua)
    local success, content = pcall(game.HttpGet, game, BaseURL .. path .. ".lua")
    
    -- Se falhar (404), tenta como pasta (ex: combat/init.lua)
    if not success or content:find("404") then
        local successInit, contentInit = pcall(game.HttpGet, game, BaseURL .. path .. "/init.lua")
        if successInit and not contentInit:find("404") then
            content = contentInit
        else
            error("[SACRAMENT] Erro 404: Arquivo nao encontrado -> " .. path)
        end
    end

    local func, err = loadstring(content)
    if not func then error("[SACRAMENT] Erro de sintaxe em " .. path .. ": " .. tostring(err)) end
    
    local successRun, module = pcall(func)
    if not successRun then error("[SACRAMENT] Erro ao rodar " .. path .. ": " .. tostring(module)) end
    
    return module
end

(_G :: any).SacramentImport = smartImport

-- Carrega os módulos base (Ajuste os caminhos se necessário)
-- Ex: Se o uimanager estiver dentro da pasta gui, use "gui/uimanager"
local InputHandler = smartImport("input/inputhandler")
local UIManager    = smartImport("gui/uimanager")
local Settings     = smartImport("logic/settings")

local App = {}

function App.Start(adapter: any)
    InputHandler.Init(adapter)
    UIManager.Init(adapter, Settings)
end

function App.Stop()
    InputHandler.Destroy()
    UIManager.Destroy()
end

return App
