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
    Toggle: any,      -- [NOVO] Exportado para o Toggle principal
    ColorPicker: any, -- [NOVO] Exportado para salvar a cor
    Destroy: (self: ColorsUI) -> ()
}

local ColorsFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
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

    -- LINHA PRINCIPAL E ÚNICA (TOGGLE)
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

    -- COLOR PICKER EMBUTIDO (Visível apenas se Toggle == true)
    local pickerContainer = Instance.new("Frame")
    pickerContainer.Name = "PickerContainer"
    pickerContainer.Size = UDim2.new(1, 0, 0, 0)
    pickerContainer.AutomaticSize = Enum.AutomaticSize.Y
    pickerContainer.BackgroundTransparency = 1
    pickerContainer.Visible = false
    pickerContainer.LayoutOrder = 2
    pickerContainer.Parent = container

    local pPad = Instance.new("UIPadding")
    pPad.PaddingLeft = UDim.new(0, 20)
    pPad.PaddingRight = UDim.new(0, 25)
    pPad.PaddingBottom = UDim.new(0, 10)
    pPad.Parent = pickerContainer

    if ColorPicker and type(ColorPicker.new) == "function" then
        local picker = ColorPicker.new(Color3.fromHex("C80000"))
        picker.Instance.Parent = pickerContainer
        maid:GiveTask(picker)
        
        self.ColorPicker = picker
    end

    -- LÓGICA DE EXPANSÃO + INTERCEPTAÇÃO DE MEMÓRIA
    if mainToggle then
        maid:GiveTask(mainToggle.Toggled:Connect(function(state: boolean)
            pickerContainer.Visible = state
        end))
        
        local originalSetState = mainToggle.SetState
        mainToggle.SetState = function(toggleSelf, state, silent)
            if originalSetState then originalSetState(toggleSelf, state, silent) end
            pickerContainer.Visible = state
        end
    end

    maid:GiveTask(container)

    function self:Destroy() 
        maid:Destroy() 
    end

    return self :: ColorsUI
end

return ColorsFactory
