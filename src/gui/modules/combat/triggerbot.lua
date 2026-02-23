--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local ToggleButton = Import("gui/modules/combat/components/togglebutton")
local Arrow = Import("gui/modules/combat/components/arrow")
local GlowBar = Import("gui/modules/combat/components/glowbar")
local Sidebar = Import("gui/modules/combat/components/sidebar")
local Slider = Import("gui/modules/combat/components/sliderbar")
local KeybindSection = Import("gui/modules/combat/sections/shared/keybind")

export type TriggerBotUI = {
    Instance: Frame,
    Destroy: (self: TriggerBotUI) -> ()
}

local TriggerBotFactory = {}

local COLOR_WHITE = Color3.fromHex("B4B4B4")
local COLOR_SUBTEXT = Color3.fromHex("828282")
local FONT_MAIN = Enum.Font.GothamBold
local FONT_SUB = Enum.Font.Gotham

function TriggerBotFactory.new(): TriggerBotUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "TriggerBotContainer"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1 
    container.BorderSizePixel = 0
    container.AutomaticSize = Enum.AutomaticSize.Y

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.FillDirection = Enum.FillDirection.Vertical
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Parent = container

    -- HEADER
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(0, 280, 0, 50)
    header.BackgroundTransparency = 1
    header.BorderSizePixel = 0
    header.LayoutOrder = 1
    header.ClipsDescendants = true
    header.Parent = container

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.fromOffset(0, 50)
    title.AutomaticSize = Enum.AutomaticSize.X
    title.Position = UDim2.fromOffset(20, 0)
    title.BackgroundTransparency = 1
    title.Text = "Trigger Bot"
    title.TextColor3 = COLOR_WHITE
    title.Font = FONT_MAIN
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local controls = Instance.new("Frame")
    controls.Name = "Controls"
    controls.Size = UDim2.fromOffset(0, 50)
    controls.AutomaticSize = Enum.AutomaticSize.X
    controls.Position = UDim2.fromScale(1, 0)
    controls.AnchorPoint = Vector2.new(1, 0)
    controls.BackgroundTransparency = 1
    controls.Parent = header

    local ctrlLayout = Instance.new("UIListLayout")
    ctrlLayout.FillDirection = Enum.FillDirection.Horizontal
    ctrlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ctrlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ctrlLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ctrlLayout.Padding = UDim.new(0, 15)
    ctrlLayout.Parent = controls

    local ctrlPadding = Instance.new("UIPadding")
    ctrlPadding.PaddingRight = UDim.new(0, 20)
    ctrlPadding.Parent = controls

    local toggleBtn = ToggleButton.new()
    toggleBtn.Instance.LayoutOrder = 1
    toggleBtn.Instance.Parent = controls
    maid:GiveTask(toggleBtn)

    local arrow = Arrow.new()
    arrow.Instance.LayoutOrder = 2
    arrow.Instance.Parent = controls
    maid:GiveTask(arrow)

    local glowWrapper = Instance.new("Frame")
    glowWrapper.Name = "GlowWrapper"
    glowWrapper.AnchorPoint = Vector2.new(0, 0.5)
    glowWrapper.BackgroundTransparency = 1
    glowWrapper.Parent = header

    local glowBar = GlowBar.new()
    glowBar.Instance.AnchorPoint = Vector2.new(0.5, 0.5)
    glowBar.Instance.Position = UDim2.fromScale(0.5, 0.5)
    glowBar.Instance.AutomaticSize = Enum.AutomaticSize.None
    glowBar.Instance.Size = UDim2.fromScale(1, 1)
    glowBar.Instance.Parent = glowWrapper

    do
        local c1 = glowBar.Instance:FindFirstChildWhichIsA("UISizeConstraint", true)
        if c1 then c1:Destroy() end
        local c2 = glowBar.Instance:FindFirstChildWhichIsA("UIAspectRatioConstraint", true)
        if c2 then c2:Destroy() end
    end
    maid:GiveTask(glowBar)

    local function updateGlowBar()
        if header.AbsoluteSize.X == 0 then return end

        local titleRightAbsolute = title.AbsolutePosition.X + title.AbsoluteSize.X
        local controlsLeftAbsolute = controls.AbsolutePosition.X

        local startX = (titleRightAbsolute - header.AbsolutePosition.X) + 5
        local endX = (controlsLeftAbsolute - header.AbsolutePosition.X) - 5

        local width = math.max(0, endX - startX)

        glowWrapper.Position = UDim2.new(0, startX, 0.5, 0)
        glowWrapper.Size = UDim2.fromOffset(width, 32)
    end

    maid:GiveTask(title:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGlowBar))
    maid:GiveTask(title:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateGlowBar))
    maid:GiveTask(controls:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGlowBar))
    maid:GiveTask(controls:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateGlowBar))
    maid:GiveTask(header:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGlowBar))
    maid:GiveTask(header:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateGlowBar))
    
    task.defer(updateGlowBar)

    -- SUBFRAME
    local subFrame = Instance.new("Frame")
    subFrame.Name = "SubFrame"
    subFrame.Size = UDim2.new(1, 0, 0, 260)
    subFrame.BackgroundTransparency = 1
    subFrame.BorderSizePixel = 0
    subFrame.Visible = false
    subFrame.LayoutOrder = 2
    subFrame.Parent = container

    local vLine = Sidebar.createVertical()
    vLine.Instance.Size = UDim2.new(0, 2, 1, 0)
    vLine.Instance.Position = UDim2.fromScale(0, 0)
    vLine.Instance.Parent = subFrame
    maid:GiveTask(vLine)

    local rightContent = Instance.new("Frame")
    rightContent.Name = "RightContent"
    rightContent.Size = UDim2.new(1, -2, 1, 0)
    rightContent.Position = UDim2.fromOffset(2, 0)
    rightContent.BackgroundTransparency = 1
    rightContent.BorderSizePixel = 0
    rightContent.Parent = subFrame

    local rightLayout = Instance.new("UIListLayout")
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Parent = rightContent

    -- 1. KEYBIND
    local keySec = KeybindSection.new(1)
    keySec.Instance.Parent = rightContent
    maid:GiveTask(keySec)

    local hLine = Sidebar.createHorizontal(2)
    hLine.Instance.Parent = rightContent
    maid:GiveTask(hLine)

    local inputsScroll = Instance.new("ScrollingFrame")
    inputsScroll.Name = "InputsScroll"
    inputsScroll.Size = UDim2.new(1, 0, 1, -57)
    inputsScroll.BackgroundTransparency = 1
    inputsScroll.BorderSizePixel = 0
    inputsScroll.ScrollBarThickness = 0
    inputsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    inputsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    inputsScroll.LayoutOrder = 3
    inputsScroll.Parent = rightContent

    local inputsLayout = Instance.new("UIListLayout")
    inputsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    inputsLayout.Padding = UDim.new(0, 15)
    inputsLayout.Parent = inputsScroll

    local inputsPadding = Instance.new("UIPadding")
    inputsPadding.PaddingTop = UDim.new(0, 20)
    inputsPadding.PaddingBottom = UDim.new(0, 20)
    inputsPadding.PaddingRight = UDim.new(0, 25)
    inputsPadding.Parent = inputsScroll

    -- 2. DELAY
    local delayRow = Instance.new("Frame")
    delayRow.Name = "DelayRow"
    delayRow.Size = UDim2.new(1, 0, 0, 35)
    delayRow.BackgroundTransparency = 1
    delayRow.LayoutOrder = 1
    delayRow.Parent = inputsScroll

    local delayLbl = Instance.new("TextLabel")
    delayLbl.Text = "Delay"
    delayLbl.TextColor3 = COLOR_WHITE
    delayLbl.Font = FONT_MAIN
    delayLbl.TextSize = 14
    delayLbl.TextXAlignment = Enum.TextXAlignment.Left
    delayLbl.Size = UDim2.new(0.5, 0, 1, 0)
    delayLbl.BackgroundTransparency = 1
    delayLbl.Parent = delayRow

    local delayBox = Instance.new("TextBox")
    delayBox.Size = UDim2.fromOffset(60, 26)
    delayBox.Position = UDim2.new(1, 0, 0.5, 0)
    delayBox.AnchorPoint = Vector2.new(1, 0.5)
    delayBox.BackgroundColor3 = Color3.fromHex("1A1A1A")
    delayBox.TextColor3 = COLOR_WHITE
    delayBox.Font = FONT_MAIN
    delayBox.TextSize = 13
    delayBox.Text = "0.030"
    delayBox.PlaceholderText = "0.000"
    delayBox.Parent = delayRow

    local delayCorner = Instance.new("UICorner")
    delayCorner.CornerRadius = UDim.new(0, 4)
    delayCorner.Parent = delayBox

    local delayStroke = Instance.new("UIStroke")
    delayStroke.Color = Color3.fromHex("333333")
    delayStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    delayStroke.Parent = delayBox

    maid:GiveTask(delayBox.FocusLost:Connect(function()
        local num = tonumber(delayBox.Text)
        if num then
            num = math.clamp(num, 0, 0.300)
            delayBox.Text = string.format("%.3f", num)
        else
            delayBox.Text = "0.030"
        end
    end))

    -- 3. HIT CHANCE
    local hitChanceSlider = Slider.new("Hit Chance", 0, 100, 95)
    hitChanceSlider.Instance.LayoutOrder = 2
    hitChanceSlider.Instance.Parent = inputsScroll
    maid:GiveTask(hitChanceSlider)

    -- 4. WALL CHECK
    local wallRow = Instance.new("Frame")
    wallRow.Name = "WallCheckRow"
    wallRow.Size = UDim2.new(1, 0, 0, 45)
    wallRow.BackgroundTransparency = 1
    wallRow.LayoutOrder = 3
    wallRow.Parent = inputsScroll

    local wallLbl = Instance.new("TextLabel")
    wallLbl.Size = UDim2.new(1, -60, 0, 20)
    wallLbl.Text = "Wall Check"
    wallLbl.TextColor3 = COLOR_WHITE
    wallLbl.Font = FONT_MAIN
    wallLbl.TextSize = 14
    wallLbl.TextXAlignment = Enum.TextXAlignment.Left
    wallLbl.BackgroundTransparency = 1
    wallLbl.Parent = wallRow

    local wallSub = Instance.new("TextLabel")
    wallSub.Size = UDim2.new(1, -60, 0, 25)
    wallSub.Position = UDim2.new(0, 0, 0, 20)
    wallSub.Text = "Only trigger if no obstacle between crosshair and player (clean raycast)"
    wallSub.TextColor3 = COLOR_SUBTEXT
    wallSub.Font = FONT_SUB
    wallSub.TextSize = 11
    wallSub.TextWrapped = true
    wallSub.TextXAlignment = Enum.TextXAlignment.Left
    wallSub.TextYAlignment = Enum.TextYAlignment.Top
    wallSub.BackgroundTransparency = 1
    wallSub.Parent = wallRow

    local wallToggle = ToggleButton.new()
    wallToggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
    wallToggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
    wallToggle.Instance.Parent = wallRow
    maid:GiveTask(wallToggle)

    -- 5. KNOCK CHECK
    local knockRow = Instance.new("Frame")
    knockRow.Name = "KnockCheckRow"
    knockRow.Size = UDim2.new(1, 0, 0, 45)
    knockRow.BackgroundTransparency = 1
    knockRow.LayoutOrder = 4
    knockRow.Parent = inputsScroll

    local knockLbl = Instance.new("TextLabel")
    knockLbl.Size = UDim2.new(1, -60, 0, 20)
    knockLbl.Text = "Knock Check"
    knockLbl.TextColor3 = COLOR_WHITE
    knockLbl.Font = FONT_MAIN
    knockLbl.TextSize = 14
    knockLbl.TextXAlignment = Enum.TextXAlignment.Left
    knockLbl.BackgroundTransparency = 1
    knockLbl.Parent = knockRow

    local knockSub = Instance.new("TextLabel")
    knockSub.Size = UDim2.new(1, -60, 0, 25)
    knockSub.Position = UDim2.new(0, 0, 0, 20)
    knockSub.Text = "Ignore knocked down players"
    knockSub.TextColor3 = COLOR_SUBTEXT
    knockSub.Font = FONT_SUB
    knockSub.TextSize = 11
    knockSub.TextWrapped = true
    knockSub.TextXAlignment = Enum.TextXAlignment.Left
    knockSub.TextYAlignment = Enum.TextYAlignment.Top
    knockSub.BackgroundTransparency = 1
    knockSub.Parent = knockRow

    local knockToggle = ToggleButton.new()
    knockToggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
    knockToggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
    knockToggle.Instance.Parent = knockRow
    maid:GiveTask(knockToggle)

    maid:GiveTask(toggleBtn.Toggled:Connect(function(state)
        glowBar:SetState(state)
    end))

    maid:GiveTask(container)
    
    local self = {}
    self.Instance = container

    function self:Destroy()
        maid:Destroy()
    end

    return self
end

return TriggerBotFactory
