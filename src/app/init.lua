--!strict
--[[ SACRAMENT | Smart Loader ]]--

-- Substitua pelo seu link raw exato
local BaseURL = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/src/"

local function smartImport(path: string): any
    -- Tenta o arquivo direto (.lua)
    local success, content = pcall(game.HttpGet, game, BaseURL .. path .. ".lua")
    
    -- Se der 404, tenta a pasta (/init.lua)
    if not success or content:find("404") then
        local successInit, contentInit = pcall(game.HttpGet, game, BaseURL .. path .. "/init.lua")
        if successInit and not contentInit:find("404") then
            content = contentInit
        else
            error("[SACRAMENT] Erro: Path nao encontrado -> " .. path)
        end
    end

    local func = loadstring(content)
    if not func then 
        error("[SACRAMENT] Erro de sintaxe no modulo: " .. path) 
    end
    
    return func()
end

(_G :: any).SacramentImport = smartImport

-- Carrega os pilares
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
