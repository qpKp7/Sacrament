--!strict
--[[ SACRAMENT | Loader Principal (Localizado em src/app/init.lua) ]]--

-- BaseURL apontando exatamente para a pasta src/ do seu repositório
local BaseURL = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/src/"

local function smartImport(path: string): any
    -- 1. Tenta carregar o arquivo direto .lua
    local url = BaseURL .. path .. ".lua"
    local success, content = pcall(game.HttpGet, game, url)
    
    -- 2. Se falhar (404), tenta o padrão de pasta /init.lua
    if not success or content:find("404") then
        local initUrl = BaseURL .. path .. "/init.lua"
        local successInit, contentInit = pcall(game.HttpGet, game, initUrl)
        
        if successInit and not contentInit:find("404") then
            content = contentInit
        else
            error("[SACRAMENT] Nao foi possivel encontrar o modulo: " .. path)
        end
    end

    local func, err = loadstring(content)
    if not func then error("[SACRAMENT] Erro de sintaxe em " .. path .. ": " .. tostring(err)) end
    
    return func()
end

-- Define o importador global para todos os outros arquivos usarem
(_G :: any).SacramentImport = smartImport

-- Carrega os pilares do sistema (Caminhos relativos à pasta src/)
local InputHandler = smartImport("input/inputhandler")
local UIManager    = smartImport("gui/uimanager")
local Settings     = smartImport("logic/settings")

local App = {}

function App.Start(adapter: any)
    warn("[SACRAMENT] Iniciando...")
    InputHandler.Init(adapter)
    UIManager.Init(adapter, Settings)
    warn("[SACRAMENT] Sistema Online.")
end

function App.Stop()
    InputHandler.Destroy()
    UIManager.Destroy()
end

return App
