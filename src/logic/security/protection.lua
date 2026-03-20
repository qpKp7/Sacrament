--!strict
--[[
    SACRAMENT | Protection Manager
    Responsável por ocultar a interface e proteger instâncias contra varreduras 
    de Anti-Cheats (ex: CoreGui, gethui, protect_gui).
--]]

local ProtectionManager = {}

local isInitialized = false
local safeContainer: Instance? = nil

-- Função interna para descobrir o local mais blindado disponível no executor
local function getSafeContainer(): Instance
    local success, result = pcall(function()
        -- 1º Nível de Segurança: gethui() (Esconde completamente a UI da árvore do jogo)
        if gethui and type(gethui) == "function" then
            return gethui()
        end
        
        -- 2º Nível de Segurança: CoreGui (O jogo não tem permissão de leitura aqui)
        local coreGui = game:GetService("CoreGui")
        if coreGui then 
            return coreGui 
        end
        
        return nil
    end)

    if success and result then
        return result
    end

    -- 3º Nível (Risco Crítico): PlayerGui. 
    -- Se chegar aqui, o executor do usuário é de baixíssima qualidade.
    warn("[SACRAMENT] ⚠️ Executor não suporta gethui/CoreGui. A UI estará vulnerável no PlayerGui!")
    local player = game:GetService("Players").LocalPlayer
    return player:WaitForChild("PlayerGui")
end

function ProtectionManager.Init(securityMaid: any)
    if isInitialized then return end
    isInitialized = true

    -- Define o "Cofre" logo que a segurança inicia
    safeContainer = getSafeContainer()
    
    securityMaid:GiveTask(function()
        isInitialized = false
    end)
end

--[[
    ProtectUI
    Recebe a ScreenGui principal do Sacrament e a blinda contra varreduras.
]]
function ProtectionManager.ProtectUI(gui: ScreenGui)
    if not isInitialized then
        warn("[SACRAMENT] ❌ ProtectionManager não foi inicializado! Chame Init primeiro.")
        return
    end

    -- Tenta blindar a GUI usando funções nativas do executor, se existirem
    pcall(function()
        if type((_G :: any).syn) == "table" and type((_G :: any).syn.protect_gui) == "function" then
            (_G :: any).syn.protect_gui(gui)
        elseif type((_G :: any).protect_gui) == "function" then
            (_G :: any).protect_gui(gui)
        end
    end)

    -- Randomiza o nome da ScreenGui para burlar checagens de nome fixo (ex: FindFirstChild("SacramentUI"))
    local randomName = ""
    for _ = 1, 16 do
        randomName = randomName .. string.char(math.random(97, 122))
    end
    gui.Name = randomName

    -- Move a interface para dentro do Cofre
    if safeContainer then
        gui.Parent = safeContainer
    end
end

return ProtectionManager
