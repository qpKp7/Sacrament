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

local COLOR_WHITE = Color3.fromHex("FFFFFF")
local COLOR_RED_DARK = Color3.fromHex("680303")
local COLOR_RED_GLOW = Color3.fromHex("FF3333")
local COLOR_BG_DARK = Color3.fromHex("111111")
local COLOR_BG_INPUT = Color3.fromHex("0A0A0A")

local FONT_ITALIC = Font.fromName("Garamond", Enum.FontWeight.Regular, Enum.FontStyle.Italic)
local FONT_REGULAR = Font.fromName("Gotham", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

local function playTween(instance: Instance, tweenInfo: TweenInfo, properties: {[string]: any}, maid: any)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    maid:GiveTask(tween.Completed:Connect(function()
        tween:Destroy()
    end))
    tween:Play()
end

local function formatDecimalValue(text: string): string
    local clean = string.gsub(text, "[^%d%.]", "")
    local parts = string.split(clean, ".")
    if #parts > 2 then
        clean = parts[1] .. "." .. table.concat(parts, "", 2)
    end
    
    clean = string.sub(clean, 1, 5)
    
    local num = tonumber(clean)
    if not num then return "0.000" end
    
    num = math.clamp(num, 0, 1)
    return string.format("%.3f", num)
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
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Padding = UDim.new(0, 5)
    containerLayout.Parent = container

    -- HEADER
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    header.LayoutOrder = 1
    header.Parent = container

    local headerLayout = Instance.new("UIListLayout")
    headerLayout.FillDirection = Enum.FillDirection.Horizontal
    headerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    headerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    headerLayout.Padding = UDim.new(0, 15)
    headerLayout.Parent = header

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0, 90, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "Aimlock"
    title.TextColor3 = COLOR_WHITE
    title.FontFace = FONT_ITALIC
    title.TextSize = 28
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.LayoutOrder = 1
    title.Parent = header

    local connectorContainer = Instance.new("Frame")
    connectorContainer.Name = "ConnectorContainer"
    connectorContainer.Size = UDim2.new(0.5, -30, 1, 0)
    connectorContainer.BackgroundTransparency = 1
    connectorContainer.LayoutOrder = 2
    connectorContainer.Parent = header

    local connectorLine = Instance.new("Frame")
    connectorLine.Name = "Line"
    connectorLine.Size = UDim2.new(1, 0, 0, 2)
    connectorLine.Position = UDim2.new(0, 0, 0.5, -1)
    connectorLine.BackgroundColor3 = COLOR_RED_DARK
    connectorLine.BorderSizePixel = 0
    connectorLine.Parent = connectorContainer

    local connectorStroke = Instance.new("UIStroke")
    connectorStroke.Color = Color3.fromHex("FF6666")
    connectorStroke.Transparency = 1
    connectorStroke.Thickness = 1
    connectorStroke.Parent = connectorLine

    local toggleBg = Instance.new("TextButton")
    toggleBg.Name = "ToggleBg"
    toggleBg.Size = UDim2.new(0, 42, 0, 22)
    toggleBg.BackgroundColor3 = COLOR_BG_DARK
    toggleBg.Text = ""
    toggleBg.AutoButtonColor = false
    toggleBg.LayoutOrder = 3
    toggleBg.Parent = header

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg

    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = COLOR_RED_DARK
    toggleStroke.Transparency = 0.5
    toggleStroke.Parent = toggleBg

    local toggleKnob = Instance.new("Frame")
    toggleKnob.Name = "Knob"
    toggleKnob.Size = UDim2.new(0, 16, 0, 16)
    toggleKnob.Position = UDim2.new(0, 3, 0.5, -8)
    toggleKnob.BackgroundColor3 = COLOR_RED_DARK
    toggleKnob.BorderSizePixel = 0
    toggleKnob.Parent = toggleBg

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = toggleKnob

    local arrowBtn = Instance.new("TextButton")
    arrowBtn.Name = "ArrowBtn"
    arrowBtn.Size = UDim2.new(0, 30, 0, 30)
    arrowBtn.BackgroundTransparency = 1
    arrowBtn.Text = ">"
    arrowBtn.TextColor3 = COLOR_WHITE
    arrowBtn.FontFace = FONT_REGULAR
    arrowBtn.TextSize = 24
    arrowBtn.LayoutOrder = 4
    arrowBtn.Parent = header

    local arrowStroke = Instance.new("UIStroke")
    arrowStroke.Color = COLOR_RED_GLOW
    arrowStroke.Transparency = 1
    arrowStroke.Thickness = 2
    arrowStroke.Parent = arrowBtn

    -- SUBFRAME
    local subFrame = Instance.new("Frame")
    subFrame.Name = "SubFrame"
    subFrame.Size = UDim2.new(1, 0, 0, 0)
    subFrame.BackgroundTransparency = 1
    subFrame.AutomaticSize = Enum.AutomaticSize.Y
    subFrame.Visible = false
    subFrame.LayoutOrder = 2
    subFrame.Parent = container

    local leftBorder = Instance.new("Frame")
    leftBorder.Name = "LeftBorder"
    leftBorder.Size = UDim2.new(0, 2, 1, 0)
    leftBorder.Position = UDim2.new(0, 15, 0, 0)
    leftBorder.BackgroundColor3 = COLOR_RED_DARK
    leftBorder.BorderSizePixel = 0
    leftBorder.Parent = subFrame

    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -30, 0, 0)
    contentArea.Position = UDim2.new(0, 30, 0, 0)
    contentArea.BackgroundTransparency = 1
    contentArea.AutomaticSize = Enum.AutomaticSize.Y
    contentArea.Parent = subFrame

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.Parent = contentArea

    local function createRow(name: string, labelText: string, layoutOrder: number): (Frame, Frame)
        local row = Instance.new("Frame")
        row.Name = name .. "Row"
        row.Size = UDim2.new(1, 0, 0, 30)
        row.BackgroundTransparency = 1
        row.LayoutOrder = layoutOrder

        local rowLayout = Instance.new("UIListLayout")
        rowLayout.FillDirection = Enum.FillDirection.Horizontal
        rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
        rowLayout.Padding = UDim.new(0, 15)
        rowLayout.Parent = row

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 90, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = COLOR_WHITE
        lbl.FontFace = FONT_ITALIC
        lbl.TextSize = 20
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.LayoutOrder = 1
        lbl.Parent = row

        local lineCont = Instance.new("Frame")
        lineCont.Size = UDim2.new(1, -195, 1, 0)
        lineCont.BackgroundTransparency = 1
        lineCont.LayoutOrder = 2
        lineCont.Parent = row

        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.new(0, 0, 0.5, 0)
        line.BackgroundColor3 = COLOR_RED_DARK
        line.BackgroundTransparency = 0.5
        line.BorderSizePixel = 0
        line.Parent = lineCont

        local inputCont = Instance.new("Frame")
        inputCont.Size = UDim2.new(0, 75, 0, 26)
        inputCont.BackgroundColor3 = COLOR_BG_INPUT
        inputCont.BorderSizePixel = 0
        inputCont.LayoutOrder = 3
        inputCont.Parent = row

        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 6)
        inputCorner.Parent = inputCont

        local inputStroke = Instance.new("UIStroke")
        inputStroke.Color = COLOR_RED_DARK
        inputStroke.Transparency = 0.6
        inputStroke.Parent = inputCont

        return row, inputCont
    end

    local keyRow, keyCont = createRow("Key", "KEY", 1)
    keyRow.Parent = contentArea
    
    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.fromScale(1, 1)
    keyBtn.BackgroundTransparency = 1
    keyBtn.Text = "[ NONE ]"
    keyBtn.TextColor3 = COLOR_RED_DARK
    keyBtn.FontFace = FONT_ITALIC
    keyBtn.TextSize = 16
    keyBtn.Parent = keyCont

    local divRow = Instance.new("Frame")
    divRow.Size = UDim2.new(1, 0, 0, 1)
    divRow.BackgroundColor3 = COLOR_RED_DARK
    divRow.BackgroundTransparency = 0.6
    divRow.BorderSizePixel = 0
    divRow.LayoutOrder = 2
    divRow.Parent = contentArea

    local predRow, predCont = createRow("Predict", "Predict", 3)
    predRow.Parent = contentArea

    local predBox = Instance.new("TextBox")
    predBox.Size = UDim2.fromScale(1, 1)
    predBox.BackgroundTransparency = 1
    predBox.Text = "0.000"
    predBox.TextColor3 = COLOR_WHITE
    predBox.FontFace = FONT_ITALIC
    predBox.TextSize = 16
    predBox.ClearTextOnFocus = false
    predBox.Parent = predCont
    
    maid:GiveTask(predBox.FocusLost:Connect(function()
        predBox.Text = formatDecimalValue(predBox.Text)
    end))

    local smoothRow, smoothCont = createRow("Smoothness", "Smoothness", 4)
    smoothRow.Parent = contentArea

    local smoothBox = Instance.new("TextBox")
    smoothBox.Size = UDim2.fromScale(1, 1)
    smoothBox.BackgroundTransparency = 1
    smoothBox.Text = "0.500"
    smoothBox.TextColor3 = COLOR_WHITE
    smoothBox.FontFace = FONT_ITALIC
    smoothBox.TextSize = 16
    smoothBox.ClearTextOnFocus = false
    smoothBox.Parent = smoothCont

    maid:GiveTask(smoothBox.FocusLost:Connect(function()
        smoothBox.Text = formatDecimalValue(smoothBox.Text)
    end))

    -- LOGIC
    maid:GiveTask(toggleBg.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        
        local targetKnobPos = isEnabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local targetKnobColor = isEnabled and COLOR_WHITE or COLOR_RED_DARK
        local targetBgColor = isEnabled and COLOR_RED_GLOW or COLOR_BG_DARK
        local targetStrokeTransp = isEnabled and 0.2 or 0.8
        
        local targetLineColor = isEnabled and COLOR_RED_GLOW or COLOR_RED_DARK
        local targetLineStrokeTransp = isEnabled and 0.1 or 1
        local targetLineStrokeThick = isEnabled and 3 or 1
        
        playTween(toggleKnob, tInfo, {Position = targetKnobPos, BackgroundColor3 = targetKnobColor}, maid)
        playTween(toggleBg, tInfo, {BackgroundColor3 = targetBgColor}, maid)
        playTween(toggleStroke, tInfo, {Transparency = targetStrokeTransp}, maid)
        
        playTween(connectorLine, tInfo, {BackgroundColor3 = targetLineColor}, maid)
        playTween(connectorStroke, tInfo, {Transparency = targetLineStrokeTransp, Thickness = targetLineStrokeThick}, maid)
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
        keyBtn.TextColor3 = COLOR_WHITE
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                keyBtn.Text = "[ " .. input.KeyCode.Name .. " ]"
                keyBtn.TextColor3 = COLOR_RED_DARK
                capturingKey = false
                connection:Disconnect()
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.MouseButton2 or
                   input.UserInputType == Enum.UserInputType.MouseButton3 or
                   input.UserInputType.Name:match("Mouse") then
                keyBtn.Text = "[ " .. input.UserInputType.Name .. " ]"
                keyBtn.TextColor3 = COLOR_RED_DARK
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
