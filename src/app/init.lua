--!strict
--[[ SACRAMENT | Main Loader ]]--

-- O link precisa terminar com /src/ para achar as subpastas
local BaseURL = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/src/"

local function smartImport(path: string): any
    -- 1. Tenta o arquivo direto (.lua)
    local success, content = pcall(game.HttpGet, game, BaseURL .. path .. ".lua")
    
    -- 2. Se der 404, tenta a pasta (/init.lua)
    if not success or content:find("404") then
        local successInit, contentInit = pcall(game.HttpGet, game, BaseURL .. path .. "/init.lua")
        if successInit and not contentInit:find("404") then
            content = contentInit
        else
            error("[SACRAMENT] Path nao encontrado: " .. path)
        end
    end

    local func = loadstring(content)
    if not func then error("[SACRAMENT] Erro de sintaxe: " .. path) end
    
    return func()
end

(_G :: any).SacramentImport = smartImport

-- IMPORTANTE: Garanta que esses arquivos existam dentro de /src/ no seu GitHub
local InputHandler = smartImport("input/inputhandler")
local UIManager    = smartImport("gui/uimanager")
local Settings     = smartImport("logic/settings")

local App = {}
function App.Start(adapter)
    InputHandler.Init(adapter)
    UIManager.Init(adapter, Settings)
end
function App.Stop()
    InputHandler.Destroy()
    UIManager.Destroy()
end
return App
