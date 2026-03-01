--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local ToggleButton = SafeImport("gui/modules/components/togglebutton")
local Slider = SafeImport("gui/modules/components/slider")

export type SpeedSectionUI = {
    Instance: Frame,
    Destroy: (self: SpeedSectionUI) -> ()
}

local SpeedFactory = {}

local COLOR_LABEL = Color3.fromHex("B4B4B4")
local FONT_MAIN = Enum.Font.GothamBold

function SpeedFactory.new(layoutOrder: number?): SpeedSectionUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "SpeedSection"
    container.Size = UDim2.new(1, 0, 0, 45)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 2

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container

    local toggleRow = Instance.new("Frame")
    toggleRow.Name = "ToggleRow"
    toggleRow.Size = UDim2.new(1, 0, 0, 45)
    toggleRow.BackgroundTransparency = 1
    toggleRow.LayoutOrder = 1
    toggleRow.Parent = container

    local togglePad = Instance.new("UIPadding")
    togglePad.PaddingLeft = UDim.new(0, 20)
    togglePad.PaddingRight = UDim.new(0, 25)
    togglePad.Parent = toggleRow

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0.5, 0, 1, 0)
    titleLabel.Position = UDim2.fromScale(0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Walk Speed"
    titleLabel.TextColor3 = COLOR_LABEL
    titleLabel.Font = FONT_MAIN
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = toggleRow

    local speedToggle = nil
    if ToggleButton and type(ToggleButton.new) == "function" then
        speedToggle = ToggleButton.new()
        speedToggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
        speedToggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        speedToggle.Instance.Parent = toggleRow
        maid:GiveTask(speedToggle)
    end

    local sliderRow = Instance.new("Frame")
    sliderRow.Name = "SliderRow"
    sliderRow.Size = UDim2.new(1, 0, 0, 45)
    sliderRow.BackgroundTransparency = 1
    sliderRow.Visible = false
    sliderRow.LayoutOrder = 2
    sliderRow.Parent = container

    local sliderPad = Instance.new("UIPadding")
    sliderPad.PaddingLeft = UDim.new(0, 20)
    sliderPad.PaddingRight = UDim.new(0, 25)
    sliderPad.Parent = sliderRow

    local speedSlider = nil
    if Slider and type(Slider.new) == "function" then
        speedSlider = Slider.new("Speed", 16, 300, 16, 1)
        speedSlider.Instance.AnchorPoint = Vector2.new(0, 0.5)
        speedSlider.Instance.Position = UDim2.new(0, 0, 0.5, 0)
        speedSlider.Instance.Parent = sliderRow
        maid:GiveTask(speedSlider)
    end

    if speedToggle then
        maid:GiveTask(speedToggle.Toggled:Connect(function(state: boolean)
            sliderRow.Visible = state
        end))
    end

    maid:GiveTask(container)
    local self = {}
    self.Instance = container
    function self:Destroy() maid:Destroy() end
    return self :: SpeedSectionUI
end

return SpeedFactory
