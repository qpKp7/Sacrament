--!strict
local Sacrament = {}

export type Adapter = {
    mountGui: (gui: ScreenGui) -> (),
    connectInputBegan: (callback: (InputObject, boolean) -> ()) -> RBXScriptConnection,
    getViewportSize: () -> Vector2
}

function Sacrament:Init()
    local cacheBuster = tostring(math.floor(os.clock() * 1000))
    local url = string.format("https://raw.githubusercontent.com/qpKp7/Sacrament/main/src/app/init.lua?cb=%s", cacheBuster)
    
    local success, response = pcall(function()
        return (game :: any):HttpGet(url, true)
    end)
    
    if not success or type(response) ~= "string" then
        return
    end
    
    local loadFn = loadstring(response)
    if type(loadFn) ~= "function" then
        return
    end
    
    local App = loadFn()
    
    local adapter: Adapter = {
        mountGui = function(gui: ScreenGui)
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            if player then
                local playerGui = player:FindFirstChild("PlayerGui")
                if playerGui then
                    gui.Parent = playerGui
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
    
    if type(App) == "table" then
        if type(App.start) == "function" then
            App.start(adapter)
        elseif type(App.Start) == "function" then
            App.Start(adapter)
        end
    end
end

return Sacrament
