--!strict
--[[ SACRAMENT | Root System Loader ]]--
local BaseURL = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/"

local function smartImport(path: string): any
    -- Tenta o arquivo direto (ex: input/inputhandler.lua)
    local url = BaseURL .. path .. ".lua"
    local success, content = pcall(game.HttpGet, game, url)
    
    -- Se não achar o arquivo, tenta a pasta (ex: combat/init.lua)
    if not success or content:find("404") then
        content = game:HttpGet(BaseURL .. path .. "/init.lua")
    end

    local func = loadstring(content)
    if not func then 
        error("[SACRAMENT] Erro critico de sintaxe ou path: " .. path) 
    end
    
    return func()
end

-- Disponibiliza para os sub-módulos
(_G :: any).SacramentImport = smartImport

-- Inicialização dos Pilares (Ajuste os nomes conforme suas pastas)
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
