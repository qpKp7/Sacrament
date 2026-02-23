--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local ToggleButton = Import("gui/modules/combat/components/togglebutton")
local Arrow = Import("gui/modules/combat/components/arrow")
local GlowBar = Import("gui/modules/combat/components/glowbar")
local Sidebar = Import("gui/modules/combat/components/sidebar")
local Slider = Import("gui/modules/combat/components/slider")

local KeybindSection = Import("gui/modules/combat/sections/shared/keybind")

export type TriggerBotUI = {
    Instance: Frame,
    Destroy: (self: TriggerBotUI) -> ()
}

local TriggerBotFactory = {}

local COLOR_WHITE = Color3.fromHex("B4B4B4")
local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local FONT_MAIN = Enum.Font.GothamBold

local function createToggleRow(maid: typeof(Maid.new()), title: string, layoutOrder: number): Frame
    local row = Instance.new("Frame")
    row.Name = title:gsub(" ", "") .. "Row"
    row.Size = UDim2.new(1, 0, 0, 45)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = COLOR_LABEL
    lbl.Font = FONT_MAIN
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local toggle = ToggleButton.new()
    toggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
    toggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
    toggle.Instance.Parent = row
    maid:GiveTask(toggle)

    return row
end

local function createDelayRow(maid: typeof(Maid.new()), layoutOrder: number): Frame
    local row = Instance.new("Frame")
    row.Name = "DelayRow"
    row.Size = UDim2.new(1, 0, 0, 45)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Delay"
    lbl.TextColor3 = COLOR_LABEL
    lbl.Font = FONT_MAIN
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local inputBg = Instance.new("Frame")
    inputBg.Size = UDim2.new(0, 60, 0, 24)
    inputBg.Position = UDim2.new(1, 0, 0.5, 0)
    inputBg.AnchorPoint = Vector2.new(1, 0.5)
    inputBg.BackgroundColor3 = Color3.fromHex("1A1A1A")
    inputBg.Parent = row

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = inputBg

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromHex("333333")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = inputBg

    local input = Instance.new("TextBox")
    input.Size = UDim2.fromScale(1, 1)
    input.BackgroundTransparency = 1
    input.Text = "0.03"
    input.PlaceholderText = "0.03"
    input.TextColor3 = Color3.fromHex("FFFFFF")
    input.Font = FONT_MAIN
    input.TextSize = 14
    input.Parent = inputBg

    maid:GiveTask(input:GetPropertyChangedSignal("Text"):Connect(function()
        local text = input.Text:gsub("[^%d%.]", "")
        if #text > 4 then text = string.sub(text, 1, 4) end
        if input.Text ~= text then
            input.Text = text
        end
    end))

    maid:GiveTask(input.FocusLost:Connect(function()
        local num = tonumber(input.Text)
        if not num then
            input.Text = "0.03"
            return
        end
        num = math.clamp(num, 0, 3)
        input.Text = string.format("%.2f", num)
    end))

    return row
end

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

    local subFrame = Instance.new("Frame")
    subFrame.Name = "SubFrame"
    subFrame.Size = UDim2.new(1, 0, 0, 250)
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

    local delayRow = createDelayRow(maid, 1)
    delayRow.Parent = inputsScroll

    local hitChanceSlider = Slider.new("Hit Chance", 0, 100, 95)
    hitChanceSlider.Instance.LayoutOrder = 2
    hitChanceSlider.Instance.Parent = inputsScroll
    maid:GiveTask(hitChanceSlider)

    local wallCheckRow = createToggleRow(maid, "Wall Check", 3)
    wallCheckRow.Parent = inputsScroll

    local knockCheckRow = createToggleRow(maid, "Knock Check", 4)
    knockCheckRow.Parent = inputsScroll

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
