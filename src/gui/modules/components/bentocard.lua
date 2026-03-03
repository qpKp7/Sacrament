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
local Arrow = SafeImport("gui/modules/components/arrow")

export type BentoCardUI = {
    Instance: Frame,
    Container: Frame,
    Toggled: RBXScriptSignal,
    SetState: (self: BentoCardUI, state: boolean) -> (),
    Destroy: (self: BentoCardUI) -> ()
}

local BentoCardFactory = {}

local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_BORDER = Color3.fromHex("333333")
local COLOR_ACCENT = Color3.fromHex("C80000")
local COLOR_TEXT = Color3.fromHex("FFFFFF")
local COLOR_SUBTEXT = Color3.fromHex("888888")
local FONT_MAIN = Enum.Font.GothamBold
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

function BentoCardFactory.new(titleText: string, subtitleText: string, descText: string, iconId: string, layoutOrder: number?): BentoCardUI
    local maid = Maid.new()

    local card = Instance.new("Frame")
    card.Name = titleText:gsub("%s+", "") .. "Card"
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

    -- HEADER
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 80)
    header.BackgroundTransparency = 1
    header.LayoutOrder = 1
    header.Parent = card

    local headerPad = Instance.new("UIPadding")
    headerPad.PaddingLeft = UDim.new(0, 15)
    headerPad.PaddingRight = UDim.new(0, 10) -- Medida oficial de margem direita
    headerPad.Parent = header

    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.fromOffset(45, 45)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.Position = UDim2.new(0, 0, 0.5, 0)
    icon.BackgroundTransparency = 1
    icon.Image = iconId
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

    local function createLabel(text: string, size: number, color: Color3, order: number)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, size)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = color
        lbl.Font = FONT_MAIN
        lbl.TextSize = size
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.LayoutOrder = order
        lbl.Parent = textsFrame
    end

    createLabel(titleText, 18, COLOR_TEXT, 1)
    createLabel(subtitleText, 14, COLOR_TEXT, 2)
    createLabel(descText, 12, COLOR_SUBTEXT, 3)

    -- CONTROLS (Toggle + Arrow)
    local controls = Instance.new("Frame")
    controls.Name = "Controls"
    controls.Size = UDim2.new(0, 90, 0, 50)
    controls.AnchorPoint = Vector2.new(1, 0.5)
    controls.Position = UDim2.new(1, 0, 0.5, 0)
    controls.BackgroundTransparency = 1
    controls.Parent = header

    local mainToggle = nil
    if ToggleButton and type(ToggleButton.new) == "function" then
        mainToggle = ToggleButton.new()
        mainToggle.Instance.AnchorPoint = Vector2.new(0, 0.5)
        mainToggle.Instance.Position = UDim2.new(0, 0, 0.5, 0)
        mainToggle.Instance.Parent = controls
        maid:GiveTask(mainToggle)
    end

    local mainArrow = nil
    if Arrow and type(Arrow.new) == "function" then
        mainArrow = Arrow.new()
        mainArrow.Instance.AnchorPoint = Vector2.new(1, 0.5)
        mainArrow.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        mainArrow.Instance.Parent = controls
        maid:GiveTask(mainArrow)
    end

    -- CONTAINER DE CONTEÚDO EXPANSÍVEL
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, 0, 0, 0)
    contentContainer.AutomaticSize = Enum.AutomaticSize.Y
    contentContainer.BackgroundTransparency = 1
    contentContainer.ClipsDescendants = true
    contentContainer.Visible = false
    contentContainer.LayoutOrder = 2
    contentContainer.Parent = card

    local contentPad = Instance.new("UIPadding")
    contentPad.PaddingLeft = UDim.new(0, 30)
    contentPad.PaddingRight = UDim.new(0, 25)
    contentPad.PaddingBottom = UDim.new(0, 20)
    contentPad.Parent = contentContainer

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 15)
    contentLayout.Parent = contentContainer

    local divLine = Instance.new("Frame")
    divLine.Size = UDim2.new(1, 0, 0, 1)
    divLine.BackgroundColor3 = COLOR_BORDER
    divLine.BorderSizePixel = 0
    divLine.LayoutOrder = 1
    divLine.Parent = contentContainer

    local toggledEvent = Instance.new("BindableEvent")
    maid:GiveTask(toggledEvent)

    -- Toggle gerencia a cor e estado interno
    if mainToggle then
        maid:GiveTask(mainToggle.Toggled:Connect(function(state: boolean)
            local targetColor = state and COLOR_ACCENT or COLOR_BORDER
            local iconColor = state and COLOR_ACCENT or COLOR_SUBTEXT
            
            local t1 = TweenService:Create(cardStroke, TWEEN_INFO, {Color = targetColor})
            local t2 = TweenService:Create(icon, TWEEN_INFO, {ImageColor3 = iconColor})
            
            t1:Play()
            t2:Play()
            
            maid:GiveTask(t1.Completed:Connect(function() t1:Destroy() end))
            maid:GiveTask(t2.Completed:Connect(function() t2:Destroy() end))

            toggledEvent:Fire(state)
        end))
    end

    -- Arrow gerencia a expansão
    if mainArrow then
        maid:GiveTask(mainArrow.Toggled:Connect(function(state: boolean)
            contentContainer.Visible = state
        end))
    end

    maid:GiveTask(card)

    local self = {}
    self.Instance = card
    self.Container = contentContainer
    self.Toggled = toggledEvent.Event

    function self:SetState(state: boolean)
        if mainToggle then
            mainToggle:SetState(state)
        end
    end

    function self:Destroy() maid:Destroy() end
    return self :: BentoCardUI
end

return BentoCardFactory
