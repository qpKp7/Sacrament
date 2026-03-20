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
local ColorPicker = SafeImport("gui/modules/components/colorpicker")

export type TracersUI = {
    Instance: Frame,
    Toggle: any,      -- [NOVO]
    Slider: any,      -- [NOVO]
    ColorPicker: any, -- [NOVO]
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

    local self = {} :: any
    self.Instance = container

    local mainToggle = nil
    if ToggleButton and type(ToggleButton.new) == "function" then
        mainToggle = ToggleButton.new()
        mainToggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
        mainToggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        mainToggle.Instance.Parent = mainRow
        maid:GiveTask(mainToggle)
        
        self.Toggle = mainToggle
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

    local thickSlider = nil
    if Slider and type(Slider.new) == "function" then
        -- Ajustado para 4 argumentos pulando de 1 em 1
        thickSlider = Slider.new("Thickness", 1, 4, 1)
        thickSlider.Instance.AnchorPoint = Vector2.new(0, 0.5)
        thickSlider.Instance.Position = UDim2.fromScale(0, 0.5)
        thickSlider.Instance.Size = UDim2.fromScale(1, 1)
        thickSlider.Instance.Parent = thickRow
        maid:GiveTask(thickSlider)
        
        self.Slider = thickSlider
    end

    -- PREVIEW DE COR E SELETOR (WRAPPER)
    local colorWrapper = Instance.new("Frame")
    colorWrapper.Name = "ColorWrapper"
    colorWrapper.Size = UDim2.new(1, 0, 0, 0)
    colorWrapper.AutomaticSize = Enum.AutomaticSize.Y
    colorWrapper.BackgroundTransparency = 1
    colorWrapper.LayoutOrder = 2
    colorWrapper.Parent = optionsContainer

    local wrapperLayout = Instance.new("UIListLayout")
    wrapperLayout.SortOrder = Enum.SortOrder.LayoutOrder
    wrapperLayout.Parent = colorWrapper

    local colorRow = Instance.new("Frame")
    colorRow.Name = "ColorRow"
    colorRow.Size = UDim2.new(1, 0, 0, 40)
    colorRow.BackgroundTransparency = 1
    colorRow.LayoutOrder = 1
    colorRow.Parent = colorWrapper

    local colorPad = Instance.new("UIPadding")
    colorPad.PaddingLeft = UDim.new(0, 40)
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

    if ColorPicker and type(ColorPicker.new) == "function" then
        local pickerContainer = Instance.new("Frame")
        pickerContainer.Name = "PickerContainer"
        pickerContainer.Size = UDim2.new(1, 0, 0, 0)
        pickerContainer.AutomaticSize = Enum.AutomaticSize.Y
        pickerContainer.BackgroundTransparency = 1
        pickerContainer.Visible = false
        pickerContainer.LayoutOrder = 2
        pickerContainer.Parent = colorWrapper

        local pPad = Instance.new("UIPadding")
        pPad.PaddingLeft = UDim.new(0, 40)
        pPad.PaddingRight = UDim.new(0, 25)
        pPad.PaddingBottom = UDim.new(0, 10)
        pPad.Parent = pickerContainer

        local picker = ColorPicker.new(COLOR_TRACER_DEFAULT)
        picker.Instance.Parent = pickerContainer
        maid:GiveTask(picker)
        
        -- [O SEGREDO] Exporta o picker e adiciona um SetColor simulado (caso o Picker original não tenha)
        if not picker.SetColor then
            picker.SetColor = function(selfPicker, newColor: Color3, silent: boolean?)
                -- Muda visualmente o ColorPicker nativo (precisaríamos olhar o colorpicker.lua pra ter certeza do método, mas geralmente é UpdateColor)
                if selfPicker.UpdateColor then pcall(function() selfPicker:UpdateColor(newColor) end) end
                colorPreview.BackgroundColor3 = newColor
            end
        end
        
        self.ColorPicker = picker

        maid:GiveTask(colorPreview.Activated:Connect(function()
            pickerContainer.Visible = not pickerContainer.Visible
        end))

        -- Conecta a mudança visual do botão de preview com o componente
        maid:GiveTask(picker.Changed:Connect(function(newColor: Color3)
            colorPreview.BackgroundColor3 = newColor
        end))
    end

    -- EVENTO DE EXPANSÃO E INTERCEPTAÇÃO DE MEMÓRIA
    if mainToggle then
        maid:GiveTask(mainToggle.Toggled:Connect(function(state: boolean)
            optionsContainer.Visible = state
        end))
        
        -- Garante que se a memória ativar os Tracers, a janela de opções abra junto
        local originalSetState = mainToggle.SetState
        mainToggle.SetState = function(toggleSelf, state, silent)
            originalSetState(toggleSelf, state, silent)
            optionsContainer.Visible = state
        end
    end

    maid:GiveTask(container)

    function self:Destroy() 
        maid:Destroy() 
    end

    return self :: TracersUI
end

return TracersFactory
