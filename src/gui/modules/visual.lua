--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local ESP = SafeImport("gui/modules/visual/esp")

export type VisualTabUI = {
    Instance: ScrollingFrame,
    Destroy: (self: VisualTabUI) -> (),
}

local VisualTabFactory = {}

function VisualTabFactory.new(): VisualTabUI
    local maid = Maid.new()

    local container = Instance.new("ScrollingFrame")
    container.Name = "VisualTab"
    container.Size = UDim2.fromScale(1, 1)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ScrollBarThickness = 0
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 20)
    padding.PaddingBottom = UDim.new(0, 20)
    -- Padding lateral removido para respeitar o Header Core de 100% de largura
    padding.Parent = container

    if ESP and type(ESP.new) == "function" then
        local espObj = ESP.new(1)
        espObj.Instance.Parent = container
        maid:GiveTask(espObj)
    end

    maid:GiveTask(container)
    local self = {}
    self.Instance = container
    function self:Destroy() maid:Destroy() end
    return self :: VisualTabUI
end

return VisualTabFactory
