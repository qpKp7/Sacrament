--!strict
--[[
    SACRAMENT | Misc Orchestrator (init)
    Responsável por utilitários, proteções e funções de servidor em layout Grid.
--]]

local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

-- Função de importação segura para evitar quebra do script caso um arquivo GitHub falhe
local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then 
        warn("[SACRAMENT] Falha ao importar modulo misc: " .. path)
        return nil 
    end
    return result
end

-- Sub-módulos (Caminhos atualizados para a nova estrutura de pastas)
local BloodPactSection = SafeImport("gui/modules/misc/bloodpact")
local VeilOfShadowsSection = SafeImport("gui/modules/misc/veilofshadows")
local ServerUtilitySection = SafeImport("gui/modules/misc/serverutility")

export type MiscUI = {
    Instance: ScrollingFrame,
    Destroy: (self: MiscUI) -> ()
}

local MiscFactory = {}

function MiscFactory.new(layoutOrder: any): MiscUI
    local maid = Maid.new()
    
    -- Normalização do LayoutOrder para evitar erros de tipagem dinâmica
    local actualOrder = type(layoutOrder) == "number" and layoutOrder or 1

    -- Container Principal (Scrolling)
    local container = Instance.new("ScrollingFrame")
    container.Name = "MiscContainer"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.ScrollBarThickness = 2
    container.ScrollBarImageColor3 = Color3.fromHex("333333")
    container.BorderSizePixel = 0
    container.LayoutOrder = actualOrder

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Padding = UDim.new(0, 15)
    containerLayout.Parent = container

    local containerPad = Instance.new("UIPadding")
    containerPad.PaddingTop = UDim.new(0, 20)
    containerPad.PaddingLeft = UDim.new(0, 20)
    containerPad.PaddingRight = UDim.new(0, 20)
    containerPad.PaddingBottom = UDim.new(0, 20)
    containerPad.Parent = container

    -- GRID DE RITUAIS (BENTO BOX)
    -- Este frame organiza os sub-módulos horizontalmente com quebra automática (wrap)
    local gridContainer = Instance.new("Frame")
    gridContainer.Name = "GridContainer"
    gridContainer.Size = UDim2.new(1, 0, 0, 0)
    gridContainer.AutomaticSize = Enum.AutomaticSize.Y
    gridContainer.BackgroundTransparency = 1
    gridContainer.LayoutOrder = 1
    gridContainer.Parent = container

    local gridLayout = Instance.new("UIListLayout")
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.FillDirection = Enum.FillDirection.Horizontal
    gridLayout.Wraps = true
    gridLayout.Padding = UDim.new(0, 15)
    gridLayout.Parent = gridContainer

    --[[ CARREGAMENTO DINÂMICO DOS COMPONENTES ]]--

    local function loadSection(module: any, order: number)
        if module and type(module.new) == "function" then
            local success, sectionInstance = pcall(function() return module.new(order) end)
            if success and sectionInstance and sectionInstance.Instance then
                sectionInstance.Instance.Parent = gridContainer
                maid:GiveTask(sectionInstance)
            end
        end
    end

    -- Ordem de exibição no Grid
    loadSection(BloodPactSection, 1)
    loadSection(VeilOfShadowsSection, 2)
    loadSection(ServerUtilitySection, 3)

    -- Registro de destruição
    maid:GiveTask(container)
    
    local self = {}
    self.Instance = container
    
    function self:Destroy() 
        maid:Destroy() 
    end
    
    return self :: MiscUI
end

return MiscFactory
