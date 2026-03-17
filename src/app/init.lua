--!strict
--[[ SACRAMENT | Main Loader ]]--
local BaseURL = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/src/"

local function smartImport(path: string): any
    -- Tenta carregar o arquivo .lua direto
    local success, content = pcall(game.HttpGet, game, BaseURL .. path .. ".lua")
    
    -- Se der erro ou for 404, tenta a pasta /init.lua
    if not success or content:find("404") then
        local successInit, contentInit = pcall(game.HttpGet, game, BaseURL .. path .. "/init.lua")
        if successInit and not contentInit:find("404") then
            content = contentInit
        else
            error("[SACRAMENT] Erro: Nao achou " .. path .. " no GitHub.")
        end
    end

    local func = loadstring(content)
    if not func then error("[SACRAMENT] Erro de sintaxe: " .. path) end
    
    local ok, res = pcall(func)
    if not ok then error("[SACRAMENT] Erro ao rodar: " .. path .. " | " .. tostring(res)) end
    return res
end

(_G :: any).SacramentImport = smartImport

-- Carrega os pilares (Verifique se esses nomes de pastas estao minusculos no seu GitHub)
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
