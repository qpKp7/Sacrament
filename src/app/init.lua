local tickTime = tostring(math.floor(tick()))
local initUrl = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/src/app/init.lua?t=" .. tickTime

local success, code = pcall(game.HttpGet, game, initUrl, true)
if not success then return warn("Falha no HttpGet do init.lua") end

local fn, compileErr = loadstring(code, "@init.lua")
if not fn then return warn("Falha de compilação no init.lua: " .. tostring(compileErr)) end

local App = fn()

local adapter = {
    mountGui = function(gui) 
        gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") 
    end,
    connectInputBegan = function(callback) 
        game:GetService("UserInputService").InputBegan:Connect(callback) 
    end,
    getViewportSize = function() 
        return workspace.CurrentCamera.ViewportSize 
    end
}

local startSuccess, startErr = pcall(function()
    App.start(adapter)
end)

if not startSuccess then
    warn("Erro ao rodar App.start(): " .. tostring(startErr))
else
    print("App.start() executado com sucesso.")
end
