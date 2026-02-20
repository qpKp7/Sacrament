--!strict
local Sacrament = {}

function Sacrament:Init()
    -- Uso de os.time() garante uma semente de cache diferente a cada segundo
    local cacheBuster = tostring(os.time())
    local url = string.format("https://raw.githubusercontent.com/qpKp7/Sacrament/main/src/app/init.lua?cb=%s", cacheBuster)
    
    local success, response = pcall(function()
        return (game :: any):HttpGet(url, true)
    end)
    
    if not success or type(response) ~= "string" then
        warn("Sacrament: Falha ao carregar app/init.lua")
        return
    end
    
    local loadFn = loadstring(response)
    if type(loadFn) ~= "function" then
        warn("Sacrament: Erro de sintaxe no servidor remoto")
        return
    end
    
    local App = loadFn()
    
    -- Adapter para abstrair dependências de ambiente
    local adapter = {
        mountGui = function(gui: ScreenGui)
            local coreSuccess, CoreGui = pcall(function()
                return game:GetService("CoreGui")
            end)
            gui.Parent = (coreSuccess and CoreGui) or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        end,
        connectInputBegan = function(callback)
            return game:GetService("UserInputService").InputBegan:Connect(callback)
        end
    }
    
    if type(App) == "table" and type(App.Start) == "function" then
        App.Start(adapter)
    end
end

return Sacrament
