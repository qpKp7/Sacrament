--!strict
local Combat = {}
Combat.__index = Combat

export type CombatManager = {
    Connections: {RBXScriptConnection},
    IsActive: boolean,
    Enable: (self: CombatManager) -> (),
    Disable: (self: CombatManager) -> (),
    Destroy: (self: CombatManager) -> ()
}

local function GetModule(name: string): any?
    local success, result = pcall(function()
        -- Tentativa 1: Ambiente de Script Standard
        local currentScript = (script :: any)
        if typeof(currentScript) == "Instance" and currentScript.Parent then
            local found = currentScript.Parent:FindFirstChild(name)
            if found and found:IsA("ModuleScript") then
                return require(found)
            end
        end
        
        -- Tentativa 2: Busca Global (Executores/Loadstring)
        local registry = (getgenv and getgenv() or _G) :: any
        if registry[name] then
            return registry[name]
        end

        -- Tentativa 3: Recursao no ambiente de UI (comum para Sacrament)
        local CoreGui = game:GetService("CoreGui")
        local foundInGui = CoreGui:FindFirstChild(name, true)
        if foundInGui and foundInGui:IsA("ModuleScript") then
            return require(foundInGui)
        end
        
        error("Dependencia nao encontrada em nenhum escopo: " .. name)
    end)
    
    return if success then result else nil
end

local Aimlock = GetModule("Aimlock")
local SilentAim = GetModule("SilentAim")

-- Log de Verificacao de Integridade
do
    local missing = {}
    if not Aimlock then table.insert(missing, "Aimlock") end
    if not SilentAim then table.insert(missing, "SilentAim") end
    
    if #missing == 0 then
        print("[Combat] OK: Modulos detectados e vinculados com sucesso.")
    else
        local errorMsg = "[Combat] ERRO: Falha ao vincular (" .. table.concat(missing, ", ") .. "). Verifique se os arquivos estao no getgenv() ou no mesmo diretorio."
        warn(errorMsg)
        print(errorMsg)
    end
end

function Combat.new(): CombatManager
    local self = setmetatable({
        Connections = {},
        IsActive = false
    }, Combat)
    
    return (self :: any) :: CombatManager
end

function Combat:Enable()
    if self.IsActive then return end
    self.IsActive = true

    if Aimlock and typeof(Aimlock) == "table" and Aimlock.Enable then
        local success, err = pcall(function() Aimlock:Enable() end)
        if not success then warn("[Combat] Erro ao ativar Aimlock: " .. tostring(err)) end
    end

    if SilentAim and typeof(SilentAim) == "table" and SilentAim.Enable then
        local success, err = pcall(function() SilentAim:Enable() end)
        if not success then warn("[Combat] Erro ao ativar SilentAim: " .. tostring(err)) end
    end
end

function Combat:Disable()
    if not self.IsActive then return end
    self.IsActive = false

    if Aimlock and typeof(Aimlock) == "table" and Aimlock.Disable then
        pcall(function() Aimlock:Disable() end)
    end

    if SilentAim and typeof(SilentAim) == "table" and SilentAim.Disable then
        pcall(function() SilentAim:Disable() end)
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
