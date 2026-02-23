--!strict
--[[
    SACRAMENT GUI - Loader Estabilizado
    Corrige erros de resolução de path e garante retorno de módulo.
]]

local Sacrament = {}

local function setupImportSystem()
    local source = script.Parent -- Assume que o loader está em src/
    
    (_G :: any).SacramentImport = function(path: string)
        local parts = string.split(path, "/")
        local current: any = source
        
        for _, part in ipairs(parts) do
            if part == "" or part == "." then continue end
            
            local nextObj = current:FindFirstChild(part)
            if not nextObj then
                warn(string.format("[Sacrament] Módulo não encontrado: %s (Falha em: %s)", path, part))
                return nil
            end
            current = nextObj
        end
        
        if current:IsA("ModuleScript") then
            return require(current)
        end
        
        return current
    end
end

function Sacrament.Init()
    setupImportSystem()
    
    local Import = (_G :: any).SacramentImport
    local Maid = Import("utils/maid")
    
    -- Usamos pcall para evitar que um erro em um componente (como o TextBox) 
    -- derrube o carregamento de toda a GUI
    task.spawn(function()
        local success, result = pcall(function()
            local GuiController = Import("gui/init")
            return GuiController.new()
        end)
        
        if success then
            print("[Sacrament] Interface carregada com sucesso.")
        else
            warn("[Sacrament] Erro crítico no GuiController: " .. tostring(result))
        end
    end)
end

Sacrament.Init()

return Sacrament
