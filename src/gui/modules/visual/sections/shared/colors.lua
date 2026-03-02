--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local ToggleButton = SafeImport("gui/modules/components/togglebutton")
local ColorPicker = SafeImport("gui/modules/components/colorpicker")

export type ColorsUI = {
    Instance: Frame,
    Destroy: (self: ColorsUI) -> ()
}

local ColorsFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local COLOR_BOX_BORDER = Color3.fromHex("333333")
local FONT_MAIN = Enum.Font.GothamBold

function ColorsFactory.new(layoutOrder: number?): ColorsUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "ColorsSection"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 1

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Parent = container

    local mainRow = Instance.new("Frame")
    mainRow.Name = "MainRow"
    mainRow.Size = UDim2.new(1, 0, 0, 45)
    mainRow.BackgroundTransparency = 1
    mainRow.LayoutOrder = 1
    mainRow.Parent = container

    local mainPad = Instance.new("UIPadding")
    mainPad.PaddingLeft = UDim.new(0, 20)
    mainPad.PaddingRight = UDim.new(0, 25)
    mainPad.Parent = mainRow

    local mainLabel = Instance.new("TextLabel")
    mainLabel.Name = "Label"
    mainLabel.Size = UDim2.new(0.5, 0, 1, 0)
    mainLabel.BackgroundTransparency = 1
    mainLabel.Text = "Custom Colors"
    mainLabel.TextColor3 = COLOR_LABEL
    mainLabel.Font = FONT_MAIN
    mainLabel.TextSize = 18
    mainLabel.TextXAlignment = Enum.TextXAlignment.Left
    mainLabel.Parent = mainRow

    local mainToggle = nil
    if ToggleButton and type(ToggleButton.new) == "function" then
        mainToggle = ToggleButton.new()
        mainToggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
        mainToggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        mainToggle.Instance.Parent = mainRow
        maid:GiveTask(mainToggle)
    end

    local optionsContainer = Instance.new("Frame")
    optionsContainer.Name = "OptionsContainer"
    optionsContainer.Size = UDim2.new(1, 0, 0, 0)
    optionsContainer.AutomaticSize = Enum.AutomaticSize.Y
    optionsContainer.BackgroundTransparency = 1
    optionsContainer.Visible = false
    optionsContainer.LayoutOrder = 2
    optionsContainer.Parent = container

    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsLayout.Parent = optionsContainer

    local function createColorRow(name: string, defaultColor: Color3, order: number): Frame
        local wrapper = Instance.new("Frame")
        wrapper.Name = name:gsub("%s+", "") .. "Wrapper"
        wrapper.Size = UDim2.new(1, 0, 0, 0)
        wrapper.AutomaticSize = Enum.AutomaticSize.Y
        wrapper.BackgroundTransparency = 1
        wrapper.LayoutOrder = order
        wrapper.Parent = optionsContainer

        local wrapperLayout = Instance.new("UIListLayout")
        wrapperLayout.SortOrder = Enum.SortOrder.LayoutOrder
        wrapperLayout.Parent = wrapper

        local row = Instance.new("Frame")
        row.Name = "Row"
        row.Size = UDim2.new(1, 0, 0, 40)
        row.BackgroundTransparency = 1
        row.LayoutOrder = 1
        row.Parent = wrapper

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 40)
        pad.PaddingRight = UDim.new(0, 25)
        pad.Parent = row

        local lbl = Instance.new("TextLabel")
        lbl.Name = "Label"
        lbl.Size = UDim2.new(0.5, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = name
        lbl.TextColor3 = COLOR_LABEL
        lbl.Font = FONT_MAIN
        lbl.TextSize = 16
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local colorPreview = Instance.new("TextButton")
        colorPreview.Name = "ColorPreview"
        colorPreview.Size = UDim2.fromOffset(40, 20)
        colorPreview.AnchorPoint = Vector2.new(1, 0.5)
        colorPreview.Position = UDim2.new(1, 0, 0.5, 0)
        colorPreview.BackgroundColor3 = defaultColor
        colorPreview.Text = ""
        colorPreview.AutoButtonColor = false
        colorPreview.Parent = row

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = colorPreview

        local stroke = Instance.new("UIStroke")
        stroke.Color = COLOR_BOX_BORDER
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = colorPreview

        if ColorPicker and type(ColorPicker.new) == "function" then
            local pickerContainer = Instance.new("Frame")
            pickerContainer.Name = "PickerContainer"
            pickerContainer.Size = UDim2.new(1, 0, 0, 0)
            pickerContainer.AutomaticSize = Enum.AutomaticSize.Y
            pickerContainer.BackgroundTransparency = 1
            pickerContainer.Visible = false
            pickerContainer.LayoutOrder = 2
            pickerContainer.Parent = wrapper

            local pPad = Instance.new("UIPadding")
            pPad.PaddingLeft = UDim.new(0, 40)
            pPad.PaddingRight = UDim.new(0, 25)
            pPad.PaddingBottom = UDim.new(0, 10)
            pPad.Parent = pickerContainer

            local picker = ColorPicker.new(defaultColor)
            picker.Instance.Parent = pickerContainer
            maid:GiveTask(picker)

            maid:GiveTask(colorPreview.Activated:Connect(function()
                pickerContainer.Visible = not pickerContainer.Visible
            end))

            maid:GiveTask(picker.Changed:Connect(function(newColor: Color3)
                colorPreview.BackgroundColor3 = newColor
            end))
        end

        return wrapper
    end

    createColorRow("Enemy Color", Color3.fromHex("C80000"), 1)
    createColorRow("Team Color", Color3.fromHex("4A90E2"), 2)

    if mainToggle then
        maid:GiveTask(mainToggle.Toggled:Connect(function(state: boolean)
            optionsContainer.Visible = state
        end))
    end

    maid:GiveTask(container)
    local self = {}
    self.Instance = container
    function self:Destroy() maid:Destroy() end
    return self :: ColorsUI
end

return ColorsFactory
