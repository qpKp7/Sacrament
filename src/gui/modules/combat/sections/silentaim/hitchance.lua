--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")
local Slider = Import("gui/modules/combat/components/slider")

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

    return self
end

return HitChanceFactory
