--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

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
    
    -- Barreira de proteção contra injeção de tabelas pelo loader dinâmico
    local actualOrder = type(layoutOrder) == "number" and layoutOrder or 1

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

    if BloodPactSection and type(BloodPactSection.new) == "function" then
        local success, bpInstance = pcall(function() return BloodPactSection.new(1) end)
        if success and bpInstance and bpInstance.Instance then
            bpInstance.Instance.Parent = gridContainer
            maid:GiveTask(bpInstance)
        end
    end

    if VeilOfShadowsSection and type(VeilOfShadowsSection.new) == "function" then
        local success, vosInstance = pcall(function() return VeilOfShadowsSection.new(2) end)
        if success and vosInstance and vosInstance.Instance then
            vosInstance.Instance.Parent = gridContainer
            maid:GiveTask(vosInstance)
        end
    end

    if ServerUtilitySection and type(ServerUtilitySection.new) == "function" then
        local success, suInstance = pcall(function() return ServerUtilitySection.new(3) end)
        if success and suInstance and suInstance.Instance then
            suInstance.Instance.Parent = gridContainer
            maid:GiveTask(suInstance)
        end
    end

    maid:GiveTask(container)
    
    local self = {}
    self.Instance = container
    
    function self:Destroy() 
        maid:Destroy() 
    end
    
    return self :: MiscUI
end

return MiscFactory
