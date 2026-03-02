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

export type TracersUI = {
    Instance: Frame,
    Destroy: (self: TracersUI) -> ()
}

local TracersFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local COLOR_BOX_BORDER = Color3.fromHex("333333")
local COLOR_TRACER_DEFAULT = Color3.fromHex("C80000")
local FONT_MAIN = Enum.Font.GothamBold

function TracersFactory.new(layoutOrder: number?): TracersUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "TracersSection"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 1

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Parent = container

    -- LINHA PRINCIPAL (TOGGLE)
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
    mainLabel.Text = "Tracers"
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

    -- CONTÊINER DE SUB-OPÇÕES
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

    -- SLIDER DE ESPESSURA (THICKNESS)
    local thickRow = Instance.new("Frame")
    thickRow.Name = "ThicknessRow"
    thickRow.Size = UDim2.new(1, 0, 0, 45)
    thickRow.BackgroundTransparency = 1
    thickRow.LayoutOrder = 1
    thickRow.Parent = optionsContainer

    if Slider and type(Slider.new) == "function" then
        -- Parâmetros: Título, Mín, Máx, Padrão, Incremento
        local thickSlider = Slider.new("Thickness", 1, 4, 1, 1)
        thickSlider.Instance.AnchorPoint = Vector2.new(0, 0.5)
        thickSlider.Instance.Position = UDim2.fromScale(0, 0.5)
        thickSlider.Instance.Size = UDim2.fromScale(1, 1)
        thickSlider.Instance.Parent = thickRow
        maid:GiveTask(thickSlider)
    end

    -- PREVIEW DE COR
    local colorRow = Instance.new("Frame")
    colorRow.Name = "ColorRow"
    colorRow.Size = UDim2.new(1, 0, 0, 40)
    colorRow.BackgroundTransparency = 1
    colorRow.LayoutOrder = 2
    colorRow.Parent = optionsContainer

    local colorPad = Instance.new("UIPadding")
    colorPad.PaddingLeft = UDim.new(0, 40) -- Recuo visual de sub-opção
    colorPad.PaddingRight = UDim.new(0, 25)
    colorPad.Parent = colorRow

    local colorLabel = Instance.new("TextLabel")
    colorLabel.Name = "Label"
    colorLabel.Size = UDim2.new(0.5, 0, 1, 0)
    colorLabel.BackgroundTransparency = 1
    colorLabel.Text = "Color"
    colorLabel.TextColor3 = COLOR_LABEL
    colorLabel.Font = FONT_MAIN
    colorLabel.TextSize = 16
    colorLabel.TextXAlignment = Enum.TextXAlignment.Left
    colorLabel.Parent = colorRow

    local colorPreview = Instance.new("TextButton")
    colorPreview.Name = "ColorPreview"
    colorPreview.Size = UDim2.fromOffset(40, 20)
    colorPreview.AnchorPoint = Vector2.new(1, 0.5)
    colorPreview.Position = UDim2.new(1, 0, 0.5, 0)
    colorPreview.BackgroundColor3 = COLOR_TRACER_DEFAULT
    colorPreview.Text = ""
    colorPreview.AutoButtonColor = false
    colorPreview.Parent = colorRow

    local colorCorner = Instance.new("UICorner")
    colorCorner.CornerRadius = UDim.new(0, 4)
    colorCorner.Parent = colorPreview

    local colorStroke = Instance.new("UIStroke")
    colorStroke.Color = COLOR_BOX_BORDER
    colorStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    colorStroke.Parent = colorPreview

    -- EVENTO DE EXPANSÃO
    if mainToggle then
        maid:GiveTask(mainToggle.Toggled:Connect(function(state: boolean)
            optionsContainer.Visible = state
        end))
    end

    maid:GiveTask(container)
    local self = {}
    self.Instance = container
    function self:Destroy() maid:Destroy() end
    return self :: TracersUI
end

return TracersFactory
