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
    -- Tenta localizar o modulo no ambiente atual (Parent do script ou arvore de jogo)
    local success, result = pcall(function()
        local currentScript = (script :: any)
        if currentScript and currentScript.Parent then
            local found = currentScript.Parent:FindFirstChild(name)
            if found and found:IsA("ModuleScript") then
                return require(found)
            end
        end
        
        -- Fallback: Busca global se o script estiver orfao (comum em loadstring)
        return (getgenv() :: any)[name] or (_G :: any)[name]
    end)
    
    return if success then result else nil
end

local Aimlock = GetModule("Aimlock")
local SilentAim = GetModule("SilentAim")

-- Log de Verificacao de Dependencias
do
    local status = {}
    if Aimlock then table.insert(status, "Aimlock: OK") else table.insert(status, "Aimlock: MISSING/ERROR") end
    if SilentAim then table.insert(status, "SilentAim: OK") else table.insert(status, "SilentAim: MISSING/ERROR") end
    
    if Aimlock and SilentAim then
        print("[Combat] OK: Sistema de combate inicializado com sucesso.")
    else
        warn("[Combat] ERRO CRITICO: Verifique se os arquivos estao no mesmo diretorio ou no ambiente global.")
        print("[Combat] Status Detalhado: " .. table.concat(status, " | "))
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
        Aimlock:Enable()
    end

    if SilentAim and typeof(SilentAim) == "table" and SilentAim.Enable then
        SilentAim:Enable()
    end
end

function Combat:Disable()
    if not self.IsActive then return end
    self.IsActive = false

    if Aimlock and typeof(Aimlock) == "table" and Aimlock.Disable then
        Aimlock:Disable()
    end

    if SilentAim and typeof(SilentAim) == "table" and SilentAim.Disable then
        SilentAim:Disable()
    end

    for _, connection in self.Connections do
        connection:Disconnect()
    end
    table.clear(self.Connections)
end

function Combat:Destroy()
    self:Disable()
    setmetatable(self :: any, nil)
end

return Combat
