local Import = _G.SacramentImport

local InputHandler = Import("input/inputhandler")
local UIManager = Import("gui/uimanager")
local Settings = Import("logic/settings")

local App = {}

function App.Start(adapter)
    -- Inicia os módulos repassando as funções do executor
    InputHandler.Init(adapter)
    UIManager.Init(adapter, Settings)
end

function App.Stop()
    -- Garante que tudo seja destruído ao desligar o script
    InputHandler.Destroy()
    UIManager.Destroy()
end

return App
