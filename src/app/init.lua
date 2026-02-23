--!strict
--[[
    SACRAMENT GUI - Loader/Entry Point
    Desenvolvido para máxima precisão técnica e performance (2026).
]]

local Sacrament = {}

-- Configuração do sistema de importação global (SacramentImport)
-- Permite que módulos se comuniquem sem caminhos fixos (Relative Path)
local function setupImportSystem()
    local source = script.Parent
    
    (_G :: any).SacramentImport = function(path: string)
        local parts = string.split(path, "/")
        local current: any = source
        
        for _, part in ipairs(parts) do
            current = current:FindFirstChild(part)
            if not current then
                warn("[Sacrament] Erro ao importar: " .. path)
                return nil
            end
        end
        
        if current:IsA("ModuleScript") then
            return require(current)
        end
        return current
    end
end

-- Inicialização do Sistema
function Sacrament.Init()
    setupImportSystem()
    
    local Import = (_G :: any).SacramentImport
    local Maid = Import("utils/maid")
    local GuiController = Import("gui/init")
    
    -- Criar a interface principal
    local mainMaid = Maid.new()
    
    task.spawn(function()
        local success, err = pcall(function()
            local menu = GuiController.new()
            mainMaid:GiveTask(menu)
            
            print("[Sacrament] Inicializado com sucesso.")
        end)
        
        if not success then
            warn("[Sacrament] Falha na inicialização crítica: " .. tostring(err))
        end
    end)
end

-- Execução imediata
Sacrament.Init()

return Sacrament
