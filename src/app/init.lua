--!strict
--[[ SACRAMENT | Smart Loader (Direto da Raiz) ]]--

-- Removido o "/src/" pois suas pastas estao na raiz do repo
local BaseURL = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/"

local function smartImport(path: string): any
    -- Tenta o arquivo direto (.lua)
    local success, content = pcall(game.HttpGet, game, BaseURL .. path .. ".lua")
    
    -- Se der 404, tenta a pasta (/init.lua)
    if not success or content:find("404") then
        local successInit, contentInit = pcall(game.HttpGet, game, BaseURL .. path .. "/init.lua")
        if successInit and not contentInit:find("404") then
            content = contentInit
        else
            error("[SACRAMENT] Erro 404: Arquivo nao encontrado no GitHub -> " .. path)
        end
    end

    local func, err = loadstring(content)
    if not func then 
        error("[SACRAMENT] Erro de sintaxe no modulo (" .. path .. "): " .. tostring(err)) 
    end
    
    local successRun, module = pcall(func)
    if not successRun then
        error("[SACRAMENT] Erro ao executar modulo (" .. path .. "): " .. tostring(module))
    end
    
    return module
end

(_G :: any).SacramentImport = smartImport

-- IMPORTANTE: Verifique se esses arquivos existem nessas pastas no seu GitHub
-- Se voce moveu o uimanager para dentro de gui/, o path deve ser "gui/uimanager"
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
