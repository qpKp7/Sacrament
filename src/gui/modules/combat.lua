--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")
local AimlockModule = Import("gui/modules/combat/aimlock")

export type CombatModule = {
    Instance: ScrollingFrame,
    Destroy: (self: CombatModule) -> ()
}

local CombatModuleFactory = {}

function CombatModuleFactory.new(): CombatModule
    local maid = Maid.new()

    local container = Instance.new("ScrollingFrame")
    container.Name = "CombatContainer"
    container.Size = UDim2.fromScale(1, 1)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ScrollBarThickness = 2
    container.ScrollBarImageColor3 = Color3.fromHex("680303")
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 15)
    padding.PaddingBottom = UDim.new(0, 15)
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.Parent = container

    local aimlock = AimlockModule.new()
    aimlock.Instance.LayoutOrder = 1
    aimlock.Instance.Parent = container
    maid:GiveTask(aimlock)

    maid:GiveTask(container)

    local self = {}
    self.Instance = container

    function self:Destroy()
        maid:Destroy()
    end

    return self
end

return CombatModuleFactory
