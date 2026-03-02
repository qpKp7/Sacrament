--!strict
local TweenService = game:GetService("TweenService")
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local ToggleButton = SafeImport("gui/modules/components/togglebutton")

export type BloodPactUI = {
    Instance: Frame,
    Destroy: (self: BloodPactUI) -> ()
}

local BloodPactFactory = {}

local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_BORDER = Color3.fromHex("333333")
local COLOR_ACCENT = Color3.fromHex("C80000")
local COLOR_TEXT = Color3.fromHex("FFFFFF")
local COLOR_SUBTEXT = Color3.fromHex("888888")
local FONT_MAIN = Enum.Font.GothamBold
local ICON_ID = "rbxassetid://98352735989850"
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

function BloodPactFactory.new(layoutOrder: number?): BloodPactUI
    local maid = Maid.new()

    -- Cartão Bento Box principal (Lida com AutomaticSize para expandir)
    local card = Instance.new("Frame")
    card.Name = "BloodPactCard"
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = COLOR_BG
    card.LayoutOrder = layoutOrder or 1

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 6)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = COLOR_BORDER
    cardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    cardStroke.Parent = card

    local cardLayout = Instance.new("UIListLayout")
    cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cardLayout.Parent = card

    -- CABEÇALHO DO CARTÃO
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 80)
    header.BackgroundTransparency = 1
    header.LayoutOrder = 1
    header.Parent = card

    local headerPad = Instance.new("UIPadding")
    headerPad.PaddingLeft = UDim.new(0, 15)
    headerPad.PaddingRight = UDim.new(0, 20)
    headerPad.Parent = header

    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.fromOffset(45, 45)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.Position = UDim2.new(0, 0, 0.5, 0)
    icon.BackgroundTransparency = 1
    icon.Image = ICON_ID
    icon.ImageColor3 = COLOR_SUBTEXT
    icon.Parent = header

    local textsFrame = Instance.new("Frame")
    textsFrame.Name = "Texts"
    textsFrame.Size = UDim2.new(1, -120, 1, 0)
    textsFrame.Position = UDim2.fromOffset(60, 0)
    textsFrame.BackgroundTransparency = 1
    textsFrame.Parent = header

    local textsLayout = Instance.new("UIListLayout")
    textsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    textsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    textsLayout.Padding = UDim.new(0, 4)
    textsLayout.Parent = textsFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 18)
    title.BackgroundTransparency = 1
    title.Text = "Blood Pact"
    title.TextColor3 = COLOR_TEXT
    title.Font = FONT_MAIN
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.LayoutOrder = 1
    title.Parent = textsFrame

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 14)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Global Team Check"
    subtitle.TextColor3 = COLOR_TEXT
    subtitle.Font = FONT_MAIN
    subtitle.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.LayoutOrder = 2
    subtitle.Parent = textsFrame

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, 0, 0, 12)
    desc.BackgroundTransparency = 1
    desc.Text = "Forces all features to check for team."
    desc.TextColor3 = COLOR_SUBTEXT
    desc.Font = FONT_MAIN
    desc.TextSize = 12
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.LayoutOrder = 3
    desc.Parent = textsFrame

    local mainToggle = nil
    if ToggleButton and type(ToggleButton.new) == "function" then
        mainToggle = ToggleButton.new()
        mainToggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
        mainToggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        mainToggle.Instance.Parent = header
        maid:GiveTask(mainToggle)
    end

    -- CONTÊINER EXPANSÍVEL DE OPÇÕES
    local optionsContainer = Instance.new("Frame")
    optionsContainer.Name = "OptionsContainer"
    optionsContainer.Size = UDim2.new(1, 0, 0, 0)
    optionsContainer.AutomaticSize = Enum.AutomaticSize.Y
    optionsContainer.BackgroundTransparency = 1
    optionsContainer.ClipsDescendants = true
    optionsContainer.Visible = false
    optionsContainer.LayoutOrder = 2
    optionsContainer.Parent = card

    local optionsPad = Instance.new("UIPadding")
    optionsPad.PaddingLeft = UDim.new(0, 15)
    optionsPad.PaddingRight = UDim.new(0, 15)
    optionsPad.PaddingBottom = UDim.new(0, 20)
    optionsPad.Parent = optionsContainer

    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsLayout.Padding = UDim.new(0, 15)
    optionsLayout.Parent = optionsContainer

    -- Linha divisória
    local divLine = Instance.new("Frame")
    divLine.Size = UDim2.new(1, 0, 0, 1)
    divLine.BackgroundColor3 = COLOR_BORDER
    divLine.BorderSizePixel = 0
    divLine.LayoutOrder = 1
    divLine.Parent = optionsContainer

    -- Grid Interno para as Listas Dinâmicas
    local dynamicListsFrame = Instance.new("Frame")
    dynamicListsFrame.Name = "DynamicLists"
    dynamicListsFrame.Size = UDim2.new(1, 0, 0, 0)
    dynamicListsFrame.AutomaticSize = Enum.AutomaticSize.Y
    dynamicListsFrame.BackgroundTransparency = 1
    dynamicListsFrame.LayoutOrder = 2
    dynamicListsFrame.Parent = optionsContainer

    local dynamicLayout = Instance.new("UIListLayout")
    dynamicLayout.FillDirection = Enum.FillDirection.Horizontal
    dynamicLayout.SortOrder = Enum.SortOrder.LayoutOrder
    dynamicLayout.Padding = UDim.new(0, 15)
    dynamicLayout.Parent = dynamicListsFrame

    -- FÁBRICA DE LISTAS
    local function createListPanel(titleText: string, layoutOrder: number)
        local panel = Instance.new("Frame")
        panel.Size = UDim2.new(0.5, -7.5, 0, 0)
        panel.AutomaticSize = Enum.AutomaticSize.Y
        panel.BackgroundTransparency = 1
        panel.LayoutOrder = layoutOrder
        panel.Parent = dynamicListsFrame

        local pLayout = Instance.new("UIListLayout")
        pLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pLayout.Padding = UDim.new(0, 5)
        pLayout.Parent = panel

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

        local itemsContainer = Instance.new("Frame")
        itemsContainer.Size = UDim2.new(1, 0, 0, 0)
        itemsContainer.AutomaticSize = Enum.AutomaticSize.Y
        itemsContainer.BackgroundTransparency = 1
        itemsContainer.LayoutOrder = 2
        itemsContainer.Parent = panel

        local iLayout = Instance.new("UIListLayout")
        iLayout.SortOrder = Enum.SortOrder.LayoutOrder
        iLayout.Padding = UDim.new(0, 5)
        iLayout.Parent = itemsContainer

        local itemCount = 0

        -- Fábrica de Itens (+)
        maid:GiveTask(pAddBtn.Activated:Connect(function()
            itemCount += 1
            local rowMaid = Maid.new()
            
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 32)
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

            rowMaid:GiveTask(remBtn.Activated:Connect(function()
                rowMaid:Destroy()
                row:Destroy()
            end))

            maid:GiveTask(rowMaid)
        end))
    end

    createListPanel("Group ID List", 1)
    createListPanel("User Name List", 2)

    -- ANIMAÇÃO DE ESTADO
    if mainToggle then
        maid:GiveTask(mainToggle.Toggled:Connect(function(state: boolean)
            optionsContainer.Visible = state
            
            local targetColor = state and COLOR_ACCENT or COLOR_BORDER
            local iconColor = state and COLOR_ACCENT or COLOR_SUBTEXT
            
            local t1 = TweenService:Create(cardStroke, TWEEN_INFO, {Color = targetColor})
            local t2 = TweenService:Create(icon, TWEEN_INFO, {ImageColor3 = iconColor})
            
            t1:Play()
            t2:Play()
            
            maid:GiveTask(t1.Completed:Connect(function() t1:Destroy() end))
            maid:GiveTask(t2.Completed:Connect(function() t2:Destroy() end))
        end))
    end

    maid:GiveTask(card)
    local self = {}
    self.Instance = card
    function self:Destroy() maid:Destroy() end
    return self :: BloodPactUI
end

return BloodPactFactory
