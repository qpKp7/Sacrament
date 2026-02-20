--!strict
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type AimlockUI = {
    Instance: Frame,
    Destroy: (self: AimlockUI) -> ()
}

local AimlockFactory = {}

local COLOR_BG = Color3.fromRGB(14, 14, 14)
local COLOR_WHITE = Color3.fromHex("FFFFFF")
local COLOR_RED_DARK = Color3.fromHex("680303")
local COLOR_RED_LIGHT = Color3.fromHex("FF3333")
local COLOR_TOGGLE_OFF = Color3.fromHex("444444")
local COLOR_ARROW_CLOSED = Color3.fromHex("CCCCCC")
local COLOR_BOX_BG = Color3.fromHex("1A1A1A")
local COLOR_BOX_BORDER = Color3.fromHex("333333")
local FONT_MAIN = Enum.Font.GothamBold

local function playTween(instance: Instance, tweenInfo: TweenInfo, properties: {[string]: any}, maid: any)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    maid:GiveTask(tween.Completed:Connect(function()
        tween:Destroy()
    end))
    tween:Play()
end

local function enforceDecimalBox(box: TextBox, default: string, decimals: number, maxLen: number)
    box:GetPropertyChangedSignal("Text"):Connect(function()
        local text = box.Text
        local clean = string.gsub(text, "[^%d%.]", "")
        local dots = 0
        
        clean = string.gsub(clean, "%.", function()
            dots = dots + 1
            return dots == 1 and "." or ""
        end)
        
        if #clean > maxLen then
            clean = string.sub(clean, 1, maxLen)
        end
        
        if box.Text ~= clean then
            box.Text = clean
        end
    end)
    
    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if not num then
            box.Text = default
            return
        end
        
        num = math.clamp(num, 0, 1)
        box.Text = string.format("%." .. tostring(decimals) .. "f", num)
    end)
end

local function formatKeyName(name: string): string
    local map = {
        One="1", Two="2", Three="3", Four="4", Five="5",
        Six="6", Seven="7", Eight="8", Nine="9", Zero="0",
        MouseButton1="MB1", MouseButton2="MB2", MouseButton3="MB3",
        MouseButton4="MB4", MouseButton5="MB5"
    }
    return map[name] or name
end

function AimlockFactory.new(): AimlockUI
    local maid = Maid.new()
    local isEnabled = false
    local isExpanded = false
    local capturingKey = false
    local tInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local container = Instance.new("Frame")
    container.Name = "AimlockContainer"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundColor3 = COLOR_BG
    container.BorderSizePixel = 0
    container.AutomaticSize = Enum.AutomaticSize.Y

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.FillDirection = Enum.FillDirection.Horizontal
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Parent = container

    -- HEADER AREA (Left Side)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(0, 260, 0, 45)
    header.BackgroundColor3 = COLOR_BG
    header.BorderSizePixel = 0
    header.LayoutOrder = 1
    header.Parent = container

    local headerLayout = Instance.new("UIListLayout")
    headerLayout.FillDirection = Enum.FillDirection.Horizontal
    headerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    headerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    headerLayout.Padding = UDim.new(0, 8)
    headerLayout.Parent = header

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0, 75, 0, 30)
    title.BackgroundColor3 = COLOR_BG
    title.BorderSizePixel = 0
    title.Text = "Aimlock"
    title.TextColor3 = COLOR_WHITE
    title.Font = FONT_MAIN
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.LayoutOrder = 1
    title.Parent = header

    local connectorContainer = Instance.new("Frame")
    connectorContainer.Name = "ConnectorContainer"
    connectorContainer.Size = UDim2.new(0, 85, 0, 30)
    connectorContainer.BackgroundColor3 = COLOR_BG
    connectorContainer.BorderSizePixel = 0
    connectorContainer.LayoutOrder = 2
    connectorContainer.Parent = header

    local connectorLine = Instance.new("Frame")
    connectorLine.Name = "Line"
    connectorLine.Size = UDim2.new(1, -16, 0, 2)
    connectorLine.Position = UDim2.new(0, 8, 0.5, -1)
    connectorLine.BackgroundColor3 = COLOR_TOGGLE_OFF
    connectorLine.BorderSizePixel = 0
    connectorLine.Parent = connectorContainer

    local toggleBg = Instance.new("TextButton")
    toggleBg.Name = "ToggleBg"
    toggleBg.Size = UDim2.new(0, 42, 0, 22)
    toggleBg.BackgroundColor3 = COLOR_TOGGLE_OFF
    toggleBg.Text = ""
    toggleBg.AutoButtonColor = false
    toggleBg.LayoutOrder = 3
    toggleBg.Parent = header

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg

    local toggleKnob = Instance.new("Frame")
    toggleKnob.Name = "Knob"
    toggleKnob.Size = UDim2.new(0, 16, 0, 16)
    toggleKnob.Position = UDim2.new(0, 3, 0.5, -8)
    toggleKnob.BackgroundColor3 = COLOR_WHITE
    toggleKnob.BorderSizePixel = 0
    toggleKnob.Parent = toggleBg

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = toggleKnob

    local arrowBtn = Instance.new("TextButton")
    arrowBtn.Name = "ArrowBtn"
    arrowBtn.Size = UDim2.new(0, 32, 0, 32)
    arrowBtn.BackgroundColor3 = COLOR_BG
    arrowBtn.BorderSizePixel = 0
    arrowBtn.Text = ">"
    arrowBtn.TextColor3 = COLOR_ARROW_CLOSED
    arrowBtn.Font = FONT_MAIN
    arrowBtn.TextSize = 22
    arrowBtn.LayoutOrder = 4
    arrowBtn.Parent = header

    -- SUBFRAME AREA (Right Side)
    local subFrame = Instance.new("Frame")
    subFrame.Name = "SubFrame"
    subFrame.Size = UDim2.new(1, -270, 0, 0)
    subFrame.BackgroundColor3 = COLOR_BG
    subFrame.BorderSizePixel = 0
    subFrame.AutomaticSize = Enum.AutomaticSize.Y
    subFrame.Visible = false
    subFrame.LayoutOrder = 2
    subFrame.Parent = container

    local subFrameLayout = Instance.new("UIListLayout")
    subFrameLayout.FillDirection = Enum.FillDirection.Horizontal
    subFrameLayout.SortOrder = Enum.SortOrder.LayoutOrder
    subFrameLayout.Parent = subFrame

    local verticalSeparator = Instance.new("Frame")
    verticalSeparator.Name = "VerticalSeparator"
    verticalSeparator.Size = UDim2.new(0, 2, 1, 0)
    verticalSeparator.BackgroundColor3 = COLOR_RED_DARK
    verticalSeparator.BorderSizePixel = 0
    verticalSeparator.LayoutOrder = 1
    verticalSeparator.Parent = subFrame

    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -2, 0, 0)
    contentArea.BackgroundColor3 = COLOR_BG
    contentArea.BorderSizePixel = 0
    contentArea.AutomaticSize = Enum.AutomaticSize.Y
    contentArea.LayoutOrder = 2
    contentArea.Parent = subFrame

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.Parent = contentArea
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 8)
    contentPadding.PaddingBottom = UDim.new(0, 8)
    contentPadding.Parent = contentArea

    local function createRow(name: string, labelText: string, layoutOrder: number): (Frame, Frame)
        local row = Instance.new("Frame")
        row.Name = name .. "Row"
        row.Size = UDim2.new(1, 0, 0, 34)
        row.BackgroundColor3 = COLOR_BG
        row.BorderSizePixel = 0
        row.LayoutOrder = layoutOrder

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.5, 0, 1, 0)
        lbl.Position = UDim2.new(0, 15, 0, 0)
        lbl.BackgroundColor3 = COLOR_BG
        lbl.BorderSizePixel = 0
        lbl.Text = labelText
        lbl.TextColor3 = COLOR_WHITE
        lbl.Font = FONT_MAIN
        lbl.TextSize = 14
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local inputCont = Instance.new("Frame")
        inputCont.Size = UDim2.new(0, 90, 0, 28)
        inputCont.Position = UDim2.new(1, -15, 0.5, 0)
        inputCont.AnchorPoint = Vector2.new(1, 0.5)
        inputCont.BackgroundColor3 = COLOR_BOX_BG
        inputCont.BorderSizePixel = 0
        inputCont.Parent = row

        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 6)
        inputCorner.Parent = inputCont

        local inputStroke = Instance.new("UIStroke")
        inputStroke.Color = COLOR_BOX_BORDER
        inputStroke.Thickness = 1
        inputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        inputStroke.Parent = inputCont

        return row, inputCont
    end

    local keyRow, keyCont = createRow("Key", "KEY", 1)
    keyRow.Parent = contentArea
    
    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.fromScale(1, 1)
    keyBtn.BackgroundColor3 = COLOR_BOX_BG
    keyBtn.BackgroundTransparency = 1
    keyBtn.BorderSizePixel = 0
    keyBtn.Text = "NONE"
    keyBtn.TextColor3 = COLOR_RED_DARK
    keyBtn.Font = FONT_MAIN
    keyBtn.TextSize = 14
    keyBtn.Parent = keyCont

    local divRow = Instance.new("Frame")
    divRow.Name = "HorizontalDivider"
    divRow.Size = UDim2.new(1, 0, 0, 2)
    divRow.BackgroundColor3 = COLOR_RED_DARK
    divRow.BorderSizePixel = 0
    divRow.LayoutOrder = 2
    divRow.Parent = contentArea

    local predRow, predCont = createRow("Predict", "Predict", 3)
    predRow.Parent = contentArea

    local predBox = Instance.new("TextBox")
    predBox.Size = UDim2.fromScale(1, 1)
    predBox.BackgroundColor3 = COLOR_BOX_BG
    predBox.BackgroundTransparency = 1
    predBox.BorderSizePixel = 0
    predBox.Text = "0.000"
    predBox.TextColor3 = COLOR_WHITE
    predBox.Font = FONT_MAIN
    predBox.TextSize = 14
    predBox.ClearTextOnFocus = false
    predBox.Parent = predCont
    enforceDecimalBox(predBox, "0.000", 3, 5)

    local smoothRow, smoothCont = createRow("Smoothness", "Smoothness", 4)
    smoothRow.Parent = contentArea

    local smoothBox = Instance.new("TextBox")
    smoothBox.Size = UDim2.fromScale(1, 1)
    smoothBox.BackgroundColor3 = COLOR_BOX_BG
    smoothBox.BackgroundTransparency = 1
    smoothBox.BorderSizePixel = 0
    smoothBox.Text = "0.500"
    smoothBox.TextColor3 = COLOR_WHITE
    smoothBox.Font = FONT_MAIN
    smoothBox.TextSize = 14
    smoothBox.ClearTextOnFocus = false
    smoothBox.Parent = smoothCont
    enforceDecimalBox(smoothBox, "0.500", 3, 5)

    -- LOGIC
    maid:GiveTask(toggleBg.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        
        local targetKnobPos = isEnabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local targetBgColor = isEnabled and COLOR_RED_LIGHT or COLOR_TOGGLE_OFF
        local targetLineColor = isEnabled and COLOR_RED_LIGHT or COLOR_TOGGLE_OFF
        
        playTween(toggleKnob, tInfo, {Position = targetKnobPos}, maid)
        playTween(toggleBg, tInfo, {BackgroundColor3 = targetBgColor}, maid)
        playTween(connectorLine, tInfo, {BackgroundColor3 = targetLineColor}, maid)
    end))

    maid:GiveTask(arrowBtn.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded
        subFrame.Visible = isExpanded
        
        local targetRot = isExpanded and 90 or 0
        local targetColor = isExpanded and COLOR_RED_LIGHT or COLOR_ARROW_CLOSED
        
        playTween(arrowBtn, tInfo, {Rotation = targetRot, TextColor3 = targetColor}, maid)
    end))

    maid:GiveTask(keyBtn.MouseButton1Click:Connect(function()
        if capturingKey then return end
        capturingKey = true
        keyBtn.Text = "..."
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                keyBtn.Text = formatKeyName(input.KeyCode.Name)
                capturingKey = false
                connection:Disconnect()
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.MouseButton2 or
                   input.UserInputType == Enum.UserInputType.MouseButton3 or
                   input.UserInputType.Name:match("Mouse") then
                keyBtn.Text = formatKeyName(input.UserInputType.Name)
                capturingKey = false
                connection:Disconnect()
            end
        end)
        
        maid:GiveTask(connection)
    end))

    maid:GiveTask(container)

    local self = {}
    self.Instance = container

    function self:Destroy()
        maid:Destroy()
    end

    return self
end

return AimlockFactory
