--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local Slider = SafeImport("gui/modules/components/slider")

export type SpeedSectionUI = {
    Instance: Frame,
    Destroy: (self: SpeedSectionUI) -> ()
}

local SpeedFactory = {}

function SpeedFactory.new(layoutOrder: number?): SpeedSectionUI
    local maid = Maid.new()

    -- Container mantido fixo em 55px de altura para dar respiro visual ao slider
    local container = Instance.new("Frame")
    container.Name = "SpeedSection"
    container.Size = UDim2.new(1, 0, 0, 55)
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 2

    if Slider and type(Slider.new) == "function" then
        local speedSlider = Slider.new("Speed", 0, 300, 32, 1)
        
        -- Centralizado perfeitamente no Y, aproveitando a margem X nativa do slider.lua
        speedSlider.Instance.AnchorPoint = Vector2.new(0, 0.5)
        speedSlider.Instance.Position = UDim2.fromScale(0, 0.5)
        speedSlider.Instance.Size = UDim2.fromScale(1, 1)
        speedSlider.Instance.Parent = container
        
        maid:GiveTask(speedSlider)
    end

    maid:GiveTask(container)
    local self = {}
    self.Instance = container
    function self:Destroy() maid:Destroy() end
    return self :: SpeedSectionUI
end

return SpeedFactory
