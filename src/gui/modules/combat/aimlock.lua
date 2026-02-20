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
local COLOR_RED_GLOW = Color3.fromHex("FF3333")
local COLOR_RED_STRONG_GLOW = Color3.fromHex("FF6666")
local COLOR_TOGGLE_OFF = Color3.fromHex("444444")
local FONT_MAIN = Enum.Font.GothamBold

local function playTween(instance: Instance, tweenInfo: TweenInfo, properties: {[string]: any}, maid: any)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    maid:GiveTask(tween.Completed:Connect(function()
        tween:Destroy()
    end))
    tween:Play()
end

local function applyNumberFilter(box: TextBox, maxLen: number)
    box:GetPropertyChangedSignal("Text"):Connect(function()
        local text = box.Text
        local filtered = string.gsub(text, "[^%d%.]", "")
        local dots = 0
        filtered = string.gsub(filtered, "%.", function()
            dots = dots + 1
            return dots == 1 and "." or ""
        end)
        filtered = string.sub(filtered, 1, maxLen)
        if box.Text ~= filtered then
            box.Text = filtered
        end
    end)
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
    containerLayout.Padding = UDim.new(0, 10)
    containerLayout.Parent = container

    -- HEADER AREA (Left Side)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(0, 250, 0, 40)
    header.BackgroundColor3 = COLOR_BG
    header.BorderSizePixel = 0
    header.LayoutOrder = 1
    header.Parent = container

    local headerLayout = Instance.new("UIListLayout")
    headerLayout.FillDirection = Enum.FillDirection.Horizontal
    headerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    headerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    headerLayout.Padding = UDim.new(0, 10)
    headerLayout.Parent = header

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0, 75, 1, 0)
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
    connectorContainer.Size = UDim2.new(0, 50, 1, 0)
    connectorContainer.BackgroundColor3 = COLOR_BG
    connectorContainer.BorderSizePixel = 0
    connectorContainer.LayoutOrder = 2
    connectorContainer.Parent = header

    local connectorLine = Instance.new("Frame")
    connectorLine.Name = "Line"
    connectorLine.Size = UDim2.new(1, 0, 0, 2)
    connectorLine.Position = UDim2.new(0, 0, 0.5, -1)
    connectorLine.BackgroundColor3 = COLOR_TOGGLE_OFF
    connectorLine.BorderSizePixel = 0
    connectorLine.Parent = connectorContainer

    local connectorStroke = Instance.new("UIStroke")
    connectorStroke.Color = COLOR_RED_STRONG_GLOW
    connectorStroke.Transparency = 1
    connectorStroke.Thickness = 3
    connectorStroke.Parent = connectorLine

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

    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = COLOR_RED_STRONG_GLOW
    toggleStroke.Transparency = 1
    toggleStroke.Thickness = 2
    toggleStroke.Parent = toggleBg

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
    arrowBtn.Size = UDim2.new(0, 25, 0, 30)
    arrowBtn.BackgroundColor3 = COLOR_BG
    arrowBtn.BorderSizePixel = 0
    arrowBtn.Text = ">"
    arrowBtn.TextColor3 = COLOR_WHITE
    arrowBtn.Font = FONT_MAIN
    arrowBtn.TextSize = 18
    arrowBtn.LayoutOrder = 4
    arrowBtn.Parent = header

    local arrowStroke = Instance.new("UIStroke")
    arrowStroke.Color = COLOR_RED_GLOW
    arrowStroke.Transparency = 1
    arrowStroke.Thickness = 2
    arrowStroke.Parent = arrowBtn

    -- SUBFRAME AREA (Right Side)
    local subFrame = Instance.new("Frame")
    subFrame.Name = "SubFrame"
    subFrame.Size = UDim2.new(1, -260, 0, 0)
    subFrame.BackgroundColor3 = COLOR_BG
    subFrame.BorderSizePixel = 0
    subFrame.AutomaticSize = Enum.AutomaticSize.Y
    subFrame.Visible = false
    subFrame.LayoutOrder = 2
    subFrame.Parent = container

    local subFrameLayout = Instance.new("UIListLayout")
    subFrameLayout.FillDirection = Enum.FillDirection.Horizontal
    subFrameLayout.SortOrder = Enum.SortOrder.LayoutOrder
    subFrameLayout.Padding = UDim.new(0, 15)
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
    contentArea.Size = UDim2.new(1, -17, 0, 0)
    contentArea.BackgroundColor3 = COLOR_BG
    contentArea.BorderSizePixel = 0
    contentArea.AutomaticSize = Enum.AutomaticSize.Y
    contentArea.LayoutOrder = 2
    contentArea.Parent = subFrame

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.Parent = contentArea

    local function createRow(name: string, labelText: string, layoutOrder: number): (Frame, Frame)
        local row = Instance.new("Frame")
        row.Name = name .. "Row"
        row.Size = UDim2.new(1, 0, 0, 30)
        row.BackgroundColor3 = COLOR_BG
        row.BorderSizePixel = 0
        row.LayoutOrder = layoutOrder

        local rowLayout = Instance.new("UIListLayout")
        rowLayout.FillDirection = Enum.FillDirection.Horizontal
        rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
        rowLayout.Padding = UDim.new(0, 10)
        rowLayout.Parent = row

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 100, 1, 0)
        lbl.BackgroundColor3 = COLOR_BG
        lbl.BorderSizePixel = 0
        lbl.Text = labelText
        lbl.TextColor3 = COLOR_WHITE
        lbl.Font = FONT_MAIN
        lbl.TextSize = 14
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.LayoutOrder = 1
        lbl.Parent = row

        local inputCont = Instance.new("Frame")
        inputCont.Size = UDim2.new(0, 100, 0, 26)
        inputCont.BackgroundColor3 = COLOR_BG
        inputCont.BorderSizePixel = 0
        inputCont.LayoutOrder = 2
        inputCont.Parent = row

        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 4)
        inputCorner.Parent = inputCont

        local inputStroke = Instance.new("UIStroke")
        inputStroke.Color = COLOR_TOGGLE_OFF
        inputStroke.Transparency = 0
        inputStroke.Thickness = 1
        inputStroke.Parent = inputCont

        return row, inputCont
    end

    local keyRow, keyCont = createRow("Key", "KEY", 1)
    keyRow.Parent = contentArea
    
    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.fromScale(1, 1)
    keyBtn.BackgroundColor3 = COLOR_BG
    keyBtn.BorderSizePixel = 0
    keyBtn.Text = "[ NONE ]"
    keyBtn.TextColor3 = COLOR_WHITE
    keyBtn.Font = FONT_MAIN
    keyBtn.TextSize = 14
    keyBtn.Parent = keyCont

    local divRow = Instance.new("Frame")
    divRow.Size = UDim2.new(1, 0, 0, 1)
    divRow.BackgroundColor3 = COLOR_RED_DARK
    divRow.BorderSizePixel = 0
    divRow.LayoutOrder = 2
    divRow.Parent = contentArea

    local predRow, predCont = createRow("Predict", "Predict", 3)
    predRow.Parent = contentArea

    local predBox = Instance.new("TextBox")
    predBox.Size = UDim2.fromScale(1, 1)
    predBox.BackgroundColor3 = COLOR_BG
    predBox.BorderSizePixel = 0
    predBox.Text = "0.000"
    predBox.TextColor3 = COLOR_WHITE
    predBox.Font = FONT_MAIN
    predBox.TextSize = 14
    predBox.ClearTextOnFocus = false
    predBox.Parent = predCont
    applyNumberFilter(predBox, 5)

    local smoothRow, smoothCont = createRow("Smoothness", "Smoothness", 4)
    smoothRow.Parent = contentArea

    local smoothBox = Instance.new("TextBox")
    smoothBox.Size = UDim2.fromScale(1, 1)
    smoothBox.BackgroundColor3 = COLOR_BG
    smoothBox.BorderSizePixel = 0
    smoothBox.Text = "0.50"
    smoothBox.TextColor3 = COLOR_WHITE
    smoothBox.Font = FONT_MAIN
    smoothBox.TextSize = 14
    smoothBox.ClearTextOnFocus = false
    smoothBox.Parent = smoothCont
    applyNumberFilter(smoothBox, 4)

    -- LOGIC
    maid:GiveTask(toggleBg.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        
        local targetKnobPos = isEnabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local targetBgColor = isEnabled and COLOR_RED_GLOW or COLOR_TOGGLE_OFF
        local targetToggleStrokeTransp = isEnabled and 0.2 or 1
        
        local targetLineColor = isEnabled and COLOR_RED_GLOW or COLOR_TOGGLE_OFF
        local targetLineStrokeTransp = isEnabled and 0.1 or 1
        
        playTween(toggleKnob, tInfo, {Position = targetKnobPos}, maid)
        playTween(toggleBg, tInfo, {BackgroundColor3 = targetBgColor}, maid)
        playTween(toggleStroke, tInfo, {Transparency = targetToggleStrokeTransp}, maid)
        
        playTween(connectorLine, tInfo, {BackgroundColor3 = targetLineColor}, maid)
        playTween(connectorStroke, tInfo, {Transparency = targetLineStrokeTransp}, maid)
    end))

    maid:GiveTask(arrowBtn.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded
        subFrame.Visible = isExpanded
        
        local targetRot = isExpanded and 90 or 0
        local targetColor = isExpanded and COLOR_RED_GLOW or COLOR_WHITE
        local targetStrokeTransp = isExpanded and 0.2 or 1
        
        playTween(arrowBtn, tInfo, {Rotation = targetRot, TextColor3 = targetColor}, maid)
        playTween(arrowStroke, tInfo, {Transparency = targetStrokeTransp}, maid)
    end))

    maid:GiveTask(keyBtn.MouseButton1Click:Connect(function()
        if capturingKey then return end
        capturingKey = true
        keyBtn.Text = "[ ... ]"
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                keyBtn.Text = "[ " .. input.KeyCode.Name .. " ]"
                capturingKey = false
                connection:Disconnect()
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.MouseButton2 or
                   input.UserInputType == Enum.UserInputType.MouseButton3 or
                   input.UserInputType.Name:match("Mouse") then
                keyBtn.Text = "[ " .. input.UserInputType.Name .. " ]"
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
