--!strict
local App = {}
App.__index = App

export type AppConfig = {
    Name: string,
    Version: string,
    Debug: boolean
}

export type SacramentApp = {
    Config: AppConfig,
    Modules: { [string]: any },
    IsInitialized: boolean,
    Start: (self: SacramentApp) -> (),
    InitModules: (self: SacramentApp) -> ()
}

local function GetSourcePath(): Instance?
    local success, result = pcall(function()
        return script.Parent
    end)
    return if success then result else nil
end

function App.new(config: AppConfig): SacramentApp
    local self = setmetatable({
        Config = config,
        Modules = {},
        IsInitialized = false
    }, App)
    
    return (self :: any) :: SacramentApp
end

function App:InitModules()
    local source = GetSourcePath()
    if not source then return end
    
    local moduleFolder = source:FindFirstChild("modules")
    if not moduleFolder then return end
    
    for _, moduleScript in moduleFolder:GetChildren() do
        if moduleScript:IsA("ModuleScript") then
            local success, result = pcall(function()
                return require(moduleScript)
            end)
            
            if success then
                self.Modules[moduleScript.Name] = result
            end
        end
    end
end

function App:Start()
    if self.IsInitialized then return end
    
    self:InitModules()
    
    -- Inicializacao de Sistemas Core
    if self.Modules["Combat"] and self.Modules["Combat"].new then
        local combatManager = self.Modules["Combat"].new()
        self.Modules["CombatInstance"] = combatManager
    end
    
    -- Inicializacao de Interface
    local uiFolder = if GetSourcePath() then GetSourcePath():FindFirstChild("ui") else nil
    if uiFolder then
        local interface = uiFolder:FindFirstChild("Interface")
        if interface and interface:IsA("ModuleScript") then
            local mainUI = require(interface)
            if typeof(mainUI) == "table" and mainUI.Init then
                mainUI:Init(self)
            end
        end
    end

    self.IsInitialized = true
    print("[Sacrament] App started successfully. Version: " .. self.Config.Version)
end

return {
    Create = function(config: AppConfig)
        return App.new(config)
    end
}
