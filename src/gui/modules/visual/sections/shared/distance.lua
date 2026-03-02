--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local Slider = SafeImport("gui/modules/components/slider")

export type DistanceUI = {
    Instance: Frame,
    Destroy: (self: DistanceUI) -> ()
}

local DistanceFactory = {}

function DistanceFactory.new(layoutOrder: number?): DistanceUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "DistanceSection"
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 1

    if Slider and type(Slider.new) == "function" then
        local distanceSlider = Slider.new("Max Distance", 0, 3000, 1500, 50)
        distanceSlider.Instance.AnchorPoint = Vector2.new(0, 0.5)
        distanceSlider.Instance.Position = UDim2.fromScale(0, 0.5)
        distanceSlider.Instance.Size = UDim2.fromScale(1, 1)
        distanceSlider.Instance.Parent = container
        maid:GiveTask(distanceSlider)
    end

    maid:GiveTask(container)
    local self = {}
    self.Instance = container
    function self:Destroy() maid:Destroy() end
    return self :: DistanceUI
end

return DistanceFactory
