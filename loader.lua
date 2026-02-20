--!strict
-- Arquivo: loader.lua (Root do repositório)

-- 1. Sistema de Lock Global (Previne Loops e Execuções Duplas)
local env = getfenv()
local globalEnv = env.getgenv and env.getgenv() or _G

if globalEnv.SacramentBooted then
    warn("[Sacrament] Carregamento bloqueado: O script já está rodando nesta sessão.")
    return { Init = function() end } -- Retorna um dummy para evitar erros de nil value
end
globalEnv.SacramentBooted = true

local AppLoader = {}

function AppLoader:Init()
    print("[Sacrament] Iniciando bootloader remoto...")
    
    -- Cache buster
    local tickTime = tostring(math.floor(tick()))
    local url = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/src/app/init.lua?t=" .. tickTime

    local success, result = pcall(game.HttpGet, game, url, true)
    
    if not success then
        warn("[Sacrament] Falha de rede no HttpGet: " .. tostring(result))
        globalEnv.SacramentBooted = false -- Libera o lock para tentar de novo
        return
    end

    local fn, compileErr = loadstring(result, "@Sacrament_Init")
    if type(fn) ~= "function" then
        warn("[Sacrament] Erro de compilação no init.lua: " .. tostring(compileErr))
        globalEnv.SacramentBooted = false
        return
    end

    local App = fn()
    if type(App) ~= "table" or type(App.start) ~= "function" then
        warn("[Sacrament] init.lua não retornou a tabela App com o método .start()")
        globalEnv.SacramentBooted = false
        return
    end
    
    -- 2. Adapter Simplificado e Robusto
    local adapter = {
        mountGui = function(gui)
            local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
            
            -- Remove a versão antiga se existir (Hot-Reloading seguro)
            local oldGui = playerGui:FindFirstChild(gui.Name)
            if oldGui then oldGui:Destroy() end
            
            gui.Parent = playerGui
        end,
        
        connectInputBegan = function(callback)
            return game:GetService("UserInputService").InputBegan:Connect(callback)
        end
    }

    -- 3. Inicia o App
    local startSuccess, startErr = pcall(function()
        App.start(adapter)
    end)

    if not startSuccess then
        warn("[Sacrament] Erro crítico ao montar a GUI: " .. tostring(startErr))
        globalEnv.SacramentBooted = false
    else
        print("[Sacrament] GUI carregada e montada com sucesso!")
    end
end

return AppLoader
