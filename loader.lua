--!strict
local Sacrament = {}

export type Adapter = {
    mountGui: (gui: ScreenGui) -> (),
    connectInputBegan: (callback: (InputObject, boolean) -> ()) -> RBXScriptConnection,
    getViewportSize: () -> Vector2
}

function Sacrament:Init()
    if _G.SacramentBooted then
        warn("[Sacrament] Já inicializado. Execução abortada.")
        return
    end

    local cacheBuster = tostring(os.time())
    local baseUrl = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/src/"
    local moduleCache = {}

    -- LISTA DAS PASTAS (Corta requisições HTTP perdidas pela raiz)
    local FolderModules = {
        ["gui/modules/combat"] = true,
        ["gui/modules/player"] = true,
        ["gui/modules/visual"] = true,
        ["gui/modules/misc"] = true,
        ["gui/modules/info"] = true,
        ["gui/modules/components"] = true -- Adicionado suporte para componentes
    }

    (_G :: any).SacramentImport = function(path: string): any
        if moduleCache[path] then
            return moduleCache[path]
        end

        -- LÓGICA DE PATH CORRETA: Pasta usa /init.lua, arquivo usa .lua
        local isFolder = FolderModules[path]
        local fullPath = isFolder and (path .. "/init.lua") or (path .. ".lua")
        
        local url = baseUrl .. fullPath .. "?cb=" .. cacheBuster
        local success, response = pcall(function()
            return (game :: any):HttpGet(url, true)
        end)

        -- Checa se o GitHub retornou 404
        if not success or type(response) ~= "string" or response:find("404: Not Found") then
            error("[Sacrament] Falha de rede ou Arquivo Morto: " .. fullPath)
        end

        local loadFn, syntaxErr = loadstring(response, fullPath)
        if type(loadFn) ~= "function" then
            error(string.format("[Sacrament] Erro de sintaxe em %s:\n%s", fullPath, tostring(syntaxErr)))
        end

        local result = loadFn()
        moduleCache[path] = result
        return result
    end

    local Import = (_G :: any).SacramentImport
    local App = Import("app/init")

    local adapter: Adapter = {
        mountGui = function(gui: ScreenGui)
            local coreSuccess, CoreGui = pcall(function()
                return game:GetService("CoreGui")
            end)
            
            if coreSuccess and CoreGui then
                gui.Parent = CoreGui
            else
                local Players = game:GetService("Players")
                local player = Players.LocalPlayer
                if player then
                    local playerGui = player:FindFirstChild("PlayerGui")
                    if playerGui then
                        gui.Parent = playerGui
                    end
                end
            end
        end,
        connectInputBegan = function(callback: (InputObject, boolean) -> ()): RBXScriptConnection
            local UserInputService = game:GetService("UserInputService")
            return UserInputService.InputBegan:Connect(callback)
        end,
        getViewportSize = function(): Vector2
            local camera = game:GetService("Workspace").CurrentCamera
            return camera and camera.ViewportSize or Vector2.new(1920, 1080)
        end
    }

    local startSuccess, startError = pcall(function()
        if type(App.start) == "function" then
            App.start(adapter)
        elseif type(App.Start) == "function" then
            App.Start(adapter)
        else
            error("Método Start não encontrado em App.")
        end
    end)

    if not startSuccess then
        warn("[Sacrament] Erro durante a inicialização: " .. tostring(startError))
        return
    end

    _G.SacramentBooted = true
    print("[Sacrament] Inicializado com sucesso.")
end

return Sacrament
