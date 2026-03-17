--!strict
--[[ SACRAMENT | Root Loader ]]--
local BaseURL = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/"

local function smartImport(path: string): any
    -- Tenta carregar o arquivo (ex: gui/uimanager.lua ou combat/init.lua)
    local url = BaseURL .. path .. ".lua"
    local success, content = pcall(game.HttpGet, game, url)
    
    -- Se não achar .lua, tenta como pasta /init.lua
    if not success or content:find("404") then
        content = game:HttpGet(BaseURL .. path .. "/init.lua")
    end

    local func = loadstring(content)
    if not func then error("[SACRAMENT] Erro no path: " .. path) end
    return func()
end

(_G :: any).SacramentImport = smartImport

-- IMPORTANTE: Verifique se esses nomes de pastas estao certos no seu GitHub
local InputHandler = smartImport("input/inputhandler")
local UIManager    = smartImport("gui/uimanager") -- Se estiver na raiz, use apenas "uimanager"
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
