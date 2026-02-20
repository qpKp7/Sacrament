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
    local url = string.format("https://raw.githubusercontent.com/qpKp7/Sacrament/main/src/app/init.lua?cb=%s", cacheBuster)
    
    local success, response = pcall(function()
        return (game :: any):HttpGet(url, true)
    end)
    
    if not success or type(response) ~= "string" then
        warn("[Sacrament] Falha ao executar HttpGet na URL fonte.")
        return
    end
    
    local loadFn = loadstring(response)
    if type(loadFn) ~= "function" then
        warn("[Sacrament] Falha ao compilar o código remoto (loadstring retornou nil ou inválido).")
        return
    end
    
    local App = loadFn()
    if type(App) ~= "table" then
        warn("[Sacrament] O módulo remoto não retornou uma tabela válida.")
        return
    end

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
            error("Método Start/start não encontrado em App.")
        end
    end)

    if not startSuccess then
        warn("[Sacrament] Erro durante a inicialização (App.start): " .. tostring(startError))
        return
    end

    _G.SacramentBooted = true
    print("[Sacrament] Inicializado com sucesso.")
end

return Sacrament
