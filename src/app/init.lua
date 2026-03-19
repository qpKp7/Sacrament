--!strict
--[[ 
    SACRAMENT | Strict Loader V3 (Resilient Router) 
    Sem adivinhações. Máxima estabilidade de rede.
--]]

local BaseURL = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/src/"

-- Registro explícito de quais caminhos são pastas (init.lua)
-- Isso corta as requisições HTTP pela metade.
local FolderModules = {
    ["gui/modules/combat"] = true,
    ["gui/modules/player"] = true,
    ["gui/modules/visual"] = true,
    ["gui/modules/misc"] = true,
    ["gui/modules/info"] = true
}

local function StrictImport(path: string): any
    -- Monta o caminho exato de primeira
    local isFolder = FolderModules[path]
    local fullPath = isFolder and (path .. "/init.lua") or (path .. ".lua")
    local url = BaseURL .. fullPath

    local content = nil
    local success = false

    -- Sistema de Retry (Proteção contra Rate Limit do GitHub)
    for attempt = 1, 3 do
        success, content = pcall(game.HttpGet, game, url)
        if success and content and not content:find("404: Not Found") then
            break -- Download perfeito
        end
        task.wait(0.15) -- Respira e tenta de novo
    end

    if not success or not content or content:find("404: Not Found") then
        error(string.format("[SACRAMENT FATAL] Arquivo morto ou GitHub bloqueou: %s", fullPath))
    end

    -- Compilação com injeção de Path (Para mostrar a linha exata se houver erro)
    local func, err = loadstring(content, fullPath)
    if not func then 
        error(string.format("[SACRAMENT SYNTAX] Erro no arquivo %s:\n%s", fullPath, tostring(err))) 
    end
    
    return func()
end

(_G :: any).SacramentImport = StrictImport

-- Carregamento do Núcleo
warn("[SACRAMENT] Sincronizando arquivos do repositorio...")
local InputHandler = StrictImport("input/inputhandler")
local UIManager    = StrictImport("gui/uimanager")
local Settings     = StrictImport("logic/settings")

local App = {}

function App.Start(adapter: any)
    InputHandler.Init(adapter)
    UIManager.Init(adapter, Settings)
    warn("[SACRAMENT] GUI injetada com sucesso.")
end

function App.Stop()
    InputHandler.Destroy()
    UIManager.Destroy()
end

return App
