--!strict
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Combat = {}
Combat.__index = Combat

export type CombatManager = typeof(setmetatable({}, Combat))

local function SafeRequire(moduleName: string): (boolean, any)
    local moduleScript = script.Parent:FindFirstChild(moduleName) :: ModuleScript?
    if not moduleScript then
        return false, moduleName .. " (ModuleScript) nao encontrado no diretorio atual."
    end
    
    return pcall(function()
        return require(moduleScript)
    end)
end

local isAimlockLoaded, aimlockModule = SafeRequire("Aimlock")
local isSilentAimLoaded, silentAimModule = SafeRequire("SilentAim")

if isAimlockLoaded and isSilentAimLoaded then
    print("[Combat] OK: Modulos de combate (Aimlock, SilentAim) inicializados com sucesso e sem erros.")
else
    local errorMessage = "[Combat] ERRO DE INICIALIZACAO: "
    if not isAimlockLoaded then
        errorMessage ..= "Falha no Aimlock -> " .. tostring(aimlockModule) .. " | "
    end
    if not isSilentAimLoaded then
        errorMessage ..= "Falha no SilentAim -> " .. tostring(silentAimModule)
    end
    print(errorMessage)
end

function Combat.new(): CombatManager
    local self = setmetatable({}, Combat)
    
    self.Connections = {} :: {RBXScriptConnection}
    self.IsActive = false
    
    return self
end

function Combat:Enable()
    if self.IsActive then 
        return 
    end
    
    self.IsActive = true

    if isAimlockLoaded and type(aimlockModule) == "table" and type(aimlockModule.Enable) == "function" then
        aimlockModule:Enable()
    end

    if isSilentAimLoaded and type(silentAimModule) == "table" and type(silentAimModule.Enable) == "function" then
        silentAimModule:Enable()
    end
end

function Combat:Disable()
    if not self.IsActive then 
        return 
    end
    
    self.IsActive = false

    if isAimlockLoaded and type(aimlockModule) == "table" and type(aimlockModule.Disable) == "function" then
        aimlockModule:Disable()
    end

    if isSilentAimLoaded and type(silentAimModule) == "table" and type(silentAimModule.Disable) == "function" then
        silentAimModule:Disable()
    end

    for _, connection in self.Connections do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    
    table.clear(self.Connections)
end

function Combat:Destroy()
    self:Disable()
    setmetatable(self :: any, nil)
end

return Combat
