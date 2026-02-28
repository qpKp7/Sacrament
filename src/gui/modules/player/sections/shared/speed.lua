--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function()
        return Import(path)
    end)
    if not success then return nil end
    return result
end

local ToggleButton = SafeImport("gui/modules/components/togglebutton")
local Slider = SafeImport("gui/modules/components/slider")

export type SpeedUI = {
    Instance: Frame,
    Destroy: (self: SpeedUI) -> ()
}

local SpeedFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local FONT_MAIN = Enum.Font.GothamBold

function SpeedFactory.new(layoutOrder: number?): SpeedUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "SpeedSection"
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 1
    container.AutomaticSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container

    local toggleRow = Instance.new("Frame")
    toggleRow.Name = "FlySpeedToggleRow"
    toggleRow.Size = UDim2.new(1, 0, 0, 45)
    toggleRow.BackgroundTransparency = 1
    toggleRow.LayoutOrder = 1
    toggleRow.Parent = container

    local togglePad = Instance.new("UIPadding")
    togglePad.PaddingLeft = UDim.new(0, 20)
    togglePad.PaddingRight = UDim.new(0, 25)
    togglePad.Parent = toggleRow

    local toggleTitle = Instance.new("TextLabel")
    toggleTitle.Size = UDim2.new(0.5, 0, 1, 0)
    toggleTitle.BackgroundTransparency = 1
    toggleTitle.Text = "Fly Speed"
    toggleTitle.TextColor3 = COLOR_LABEL
    toggleTitle.Font = FONT_MAIN
    toggleTitle.TextSize = 18
    toggleTitle.TextXAlignment = Enum.TextXAlignment.Left
    toggleTitle.Parent = toggleRow

    local toggleObj = nil
    if ToggleButton and type(ToggleButton.new) == "function" then
        toggleObj = ToggleButton.new()
        toggleObj.Instance.AnchorPoint = Vector2.new(1, 0.5)
        toggleObj.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        toggleObj.Instance.Parent = toggleRow
        maid:GiveTask(toggleObj)
    end

    local speedSlider = nil
    if Slider and type(Slider.new) == "function" then
        -- Instanciando o componente Slider oficial (Título, Min, Max, Default, Step)
        speedSlider = Slider.new("Speed", 0, 300, 32, 1)
        speedSlider.Instance.LayoutOrder = 2
        speedSlider.Instance.Visible = false
        speedSlider.Instance.Parent = container
        maid:GiveTask(speedSlider)
    end

    if toggleObj then
        maid:GiveTask(toggleObj.Toggled:Connect(function(state: boolean)
            if speedSlider then
                speedSlider.Instance.Visible = state
            end
            container.Size = state and UDim2.new(1, 0, 0, 90) or UDim2.new(1, 0, 0, 45)
        end))
    end

    maid:GiveTask(container)
    local self = {}
    self.Instance = container
    function self:Destroy()
        maid:Destroy()
    end
    return self :: SpeedUI
end

return SpeedFactory
