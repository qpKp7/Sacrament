--!strict
local TweenService = game:GetService("TweenService")
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type DynamicListUI = {
    Instance: Frame,
    ListChanged: RBXScriptSignal,
    GetValues: (self: DynamicListUI) -> {string},
    Destroy: (self: DynamicListUI) -> ()
}

local DynamicListFactory = {}

local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_BORDER = Color3.fromHex("333333")
local COLOR_ACCENT = Color3.fromHex("C80000")
local COLOR_TEXT = Color3.fromHex("FFFFFF")
local COLOR_SUBTEXT = Color3.fromHex("888888")
local FONT_MAIN = Enum.Font.GothamBold

function DynamicListFactory.new(titleText: string, layoutOrder: number?): DynamicListUI
    local maid = Maid.new()
    local valuesList: {string} = {}

    local panel = Instance.new("Frame")
    panel.Name = "DynamicListPanel"
    panel.Size = UDim2.new(0.5, -7.5, 0, 0)
    panel.AutomaticSize = Enum.AutomaticSize.Y
    panel.BackgroundTransparency = 1
    panel.LayoutOrder = layoutOrder or 1

    local pLayout = Instance.new("UIListLayout")
    pLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pLayout.Padding = UDim.new(0, 5)
    pLayout.Parent = panel

    -- CABEÇALHO
    local pHeader = Instance.new("Frame")
    pHeader.Size = UDim2.new(1, 0, 0, 30)
    pHeader.BackgroundTransparency = 1
    pHeader.LayoutOrder = 1
    pHeader.Parent = panel

    local pTitle = Instance.new("TextLabel")
    pTitle.Size = UDim2.new(1, -30, 1, 0)
    pTitle.BackgroundTransparency = 1
    pTitle.Text = titleText
    pTitle.TextColor3 = COLOR_TEXT
    pTitle.Font = FONT_MAIN
    pTitle.TextSize = 14
    pTitle.TextXAlignment = Enum.TextXAlignment.Left
    pTitle.Parent = pHeader

    local pAddBtn = Instance.new("TextButton")
    pAddBtn.Size = UDim2.fromOffset(24, 24)
    pAddBtn.AnchorPoint = Vector2.new(1, 0.5)
    pAddBtn.Position = UDim2.new(1, 0, 0.5, 0)
    pAddBtn.BackgroundColor3 = COLOR_BG
    pAddBtn.Text = "+"
    pAddBtn.TextColor3 = COLOR_SUBTEXT
    pAddBtn.Font = FONT_MAIN
    pAddBtn.TextSize = 16
    pAddBtn.AutoButtonColor = false
    pAddBtn.Parent = pHeader

    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(0, 4)
    pCorner.Parent = pAddBtn
    
    local pStroke = Instance.new("UIStroke")
    pStroke.Color = COLOR_BORDER
    pStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    pStroke.Parent = pAddBtn

    -- LISTA COM SCROLL (Cresce de 0px até 140px, depois rola)
    local itemsContainer = Instance.new("ScrollingFrame")
    itemsContainer.Name = "ItemsContainer"
    itemsContainer.Size = UDim2.new(1, 0, 0, 0)
    itemsContainer.AutomaticSize = Enum.AutomaticSize.Y
    itemsContainer.BackgroundTransparency = 1
    itemsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    itemsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    itemsContainer.ScrollBarThickness = 2
    itemsContainer.ScrollBarImageColor3 = COLOR_BORDER
    itemsContainer.BorderSizePixel = 0
    itemsContainer.LayoutOrder = 2
    itemsContainer.Parent = panel

    local sizeConstraint = Instance.new("UISizeConstraint")
    sizeConstraint.MaxSize = Vector2.new(math.huge, 140)
    sizeConstraint.Parent = itemsContainer

    local iLayout = Instance.new("UIListLayout")
    iLayout.SortOrder = Enum.SortOrder.LayoutOrder
    iLayout.Padding = UDim.new(0, 5)
    iLayout.Parent = itemsContainer

    local listChangedEvent = Instance.new("BindableEvent")
    maid:GiveTask(listChangedEvent)

    local itemCount = 0
    local inputsTracker = {}

    local function emitChange()
        local currentValues = {}
        for _, box in pairs(inputsTracker) do
            if box and box.Text ~= "" then
                table.insert(currentValues, box.Text)
            end
        end
        valuesList = currentValues
        listChangedEvent:Fire(valuesList)
    end

    maid:GiveTask(pAddBtn.Activated:Connect(function()
        itemCount += 1
        local rowMaid = Maid.new()
        
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -8, 0, 32)
        row.BackgroundTransparency = 1
        row.LayoutOrder = itemCount
        row.Parent = itemsContainer

        local remBtn = Instance.new("TextButton")
        remBtn.Size = UDim2.fromOffset(20, 20)
        remBtn.AnchorPoint = Vector2.new(0, 0.5)
        remBtn.Position = UDim2.new(0, 0, 0.5, 0)
        remBtn.BackgroundTransparency = 1
        remBtn.Text = "-"
        remBtn.TextColor3 = COLOR_ACCENT
        remBtn.Font = FONT_MAIN
        remBtn.TextSize = 20
        remBtn.Parent = row

        local thumb = Instance.new("ImageLabel")
        thumb.Size = UDim2.fromOffset(24, 24)
        thumb.AnchorPoint = Vector2.new(0, 0.5)
        thumb.Position = UDim2.new(0, 25, 0.5, 0)
        thumb.BackgroundColor3 = COLOR_BORDER
        thumb.BorderSizePixel = 0
        thumb.Parent = row
        local tCorner = Instance.new("UICorner")
        tCorner.CornerRadius = UDim.new(0, 4)
        tCorner.Parent = thumb

        local input = Instance.new("TextBox")
        input.Size = UDim2.new(1, -60, 1, 0)
        input.Position = UDim2.new(0, 60, 0, 0)
        input.BackgroundColor3 = COLOR_BG
        input.Text = ""
        input.PlaceholderText = "ID/Name..."
        input.TextColor3 = COLOR_TEXT
        input.Font = FONT_MAIN
        input.TextSize = 14
        input.ClearTextOnFocus = false
        input.Parent = row

        local iBoxCorner = Instance.new("UICorner")
        iBoxCorner.CornerRadius = UDim.new(0, 4)
        iBoxCorner.Parent = input
        local iBoxStroke = Instance.new("UIStroke")
        iBoxStroke.Color = COLOR_BORDER
        iBoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        iBoxStroke.Parent = input

        inputsTracker[itemCount] = input

        rowMaid:GiveTask(input:GetPropertyChangedSignal("Text"):Connect(emitChange))

        rowMaid:GiveTask(remBtn.Activated:Connect(function()
            inputsTracker[itemCount] = nil
            rowMaid:Destroy()
            row:Destroy()
            emitChange()
        end))

        maid:GiveTask(rowMaid)
        maid:GiveTask(row)
    end))

    maid:GiveTask(panel)

    local self = {}
    self.Instance = panel
    self.ListChanged = listChangedEvent.Event

    function self:GetValues()
        return valuesList
    end

    function self:Destroy() maid:Destroy() end
    return self :: DynamicListUI
end

return DynamicListFactory
