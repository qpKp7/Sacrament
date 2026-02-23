--!strict
local root = script.Parent.Parent.Parent.Parent.Parent.Parent
local Maid = require(root.utils.Maid)
local Slider = require(root.gui.modules.components.Slider)

export type HitChanceSection = {
    Instance: Frame,
    Destroy: (self: HitChanceSection) -> ()
}

local HitChanceFactory = {}

function HitChanceFactory.new(layoutOrder: number): HitChanceSection
    local maid = Maid.new()
    
    local slider = Slider.new("Hit Chance", 0, 100, 95, 1)
    slider.Instance.LayoutOrder = layoutOrder
    maid:GiveTask(slider)

    local self = {}
    self.Instance = slider.Instance

    function self:Destroy()
        maid:Destroy()
    end

    return self :: HitChanceSection
end

return HitChanceFactory
