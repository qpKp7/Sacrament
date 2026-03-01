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

    -- Container principal com altura dinâmica (55px + Slider)
    local container = Instance.new("Frame")
    container.Name = "SpeedSection"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 2

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container

    -- Linha Principal (Toggle)
    local toggleRow = Instance.new("Frame")
    toggleRow.Name = "ToggleRow"
    toggleRow.Size = UDim2.new(1, 0, 0, 55) -- Altura exata de 55px
    toggleRow.BackgroundTransparency = 1
    toggleRow.LayoutOrder = 1
    toggleRow.Parent = container

    local togglePad = Instance.new("UIPadding")
    togglePad.PaddingLeft = UDim.new(0, 20)
    togglePad.PaddingRight = UDim.new(0, 50)
    togglePad.Parent = toggleRow

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0.5, 0, 1, 0) -- Sem scale total para não encavalar
    titleLabel.Position = UDim2.fromScale(0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Fly Speed"
    titleLabel.TextColor3 = COLOR_LABEL
    titleLabel.Font = FONT_MAIN
    titleLabel.TextSize = 20 -- Tipografia padronizada em 20
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = toggleRow

    local toggleWrapper = Instance.new("Frame")
    toggleWrapper.Name = "ToggleWrapper"
    toggleWrapper.Size = UDim2.new(0, 40, 1, 0)
    toggleWrapper.AnchorPoint = Vector2.new(1, 0.5)
    toggleWrapper.Position = UDim2.fromScale(1, 0.5) -- O UIPadding cuida do recuo real de 50px
    toggleWrapper.BackgroundTransparency = 1
    toggleWrapper.Parent = toggleRow

    local speedToggle = nil
    if ToggleButton and type(ToggleButton.new) == "function" then
        speedToggle = ToggleButton.new()
        speedToggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
        speedToggle.Instance.Position = UDim2.fromScale(1, 0.5)
        speedToggle.Instance.Parent = toggleWrapper
        maid:GiveTask(speedToggle)
    end

    -- Linha Secundária (Slider)
    local sliderRow = Instance.new("Frame")
    sliderRow.Name = "SliderRow"
    sliderRow.Size = UDim2.new(1, 0, 0, 40) -- Altura base para abrigar o slider
    sliderRow.AutomaticSize = Enum.AutomaticSize.Y -- Permite expandir se o slider precisar de mais
    sliderRow.BackgroundTransparency = 1
    sliderRow.Visible = false
    sliderRow.LayoutOrder = 2
    sliderRow.Parent = container

    local sliderPad = Instance.new("UIPadding")
    sliderPad.PaddingLeft = UDim.new(0, 20)
    sliderPad.PaddingRight = UDim.new(0, 50)
    sliderPad.Parent = sliderRow

    local speedSlider = nil
    if Slider and type(Slider.new) == "function" then
        -- Slider.new(title, min, max, default, step)
        speedSlider = Slider.new("Speed", 0, 300, 32, 1)
        speedSlider.Instance.AnchorPoint = Vector2.new(0, 0.5)
        speedSlider.Instance.Position = UDim2.fromScale(0, 0.5)
        -- O componente Slider internamente vai respeitar o invólucro (sliderRow + UIPadding)
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
    function self:Destroy()
        maid:Destroy()
    end
    return self :: SpeedSectionUI
end

return SpeedFactory
