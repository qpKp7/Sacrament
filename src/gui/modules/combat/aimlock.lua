--!strict
local TweenService = game:GetService("TweenService")
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type AimlockUI = {
    Instance: Frame,
    Destroy: (self: AimlockUI) -> ()
}

local AimlockFactory = {}

local MAIN_COLOR = Color3.fromHex("7E6262")
local GLOW_COLOR = Color3.fromHex("680303")
local BG_DARK = Color3.fromHex("1A0505")
local FONT_CURSIVE = Font.fromName("Garamond", Enum.FontWeight.Regular, Enum.FontStyle.Italic)

local function playTween(instance: Instance, tweenInfo: TweenInfo, properties: {[string]: any}, maid: any)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    maid:GiveTask(tween.Completed:Connect(function()
        tween:Destroy()
    end))
    tween:Play()
end

local function configureDecimalBox(box: TextBox, default: number, decimals: number)
    box.FocusLost:Connect(function()
        local rawText = box.Text:gsub(",", ".")
        local num = tonumber(rawText)
        if num then
            num = math.clamp(num, 0, 1)
            box.Text = string.format("%." .. tostring(decimals) .. "f", num)
        else
            box.Text = string.format("%." .. tostring(decimals) .. "f", default)
        end
    end)
end

function AimlockFactory.new(): AimlockUI
    local maid = Maid.new()
    local isEnabled = false
    local isExpanded = false
    local tInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local container = Instance.new("Frame")
    container.Name = "AimlockContainer"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Padding = UDim.new(0, 10)
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
    headerLayout.Padding = UDim.new(0, 10)
    headerLayout.Parent = header

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0, 110, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "Aimlock"
    title.TextColor3 = MAIN_COLOR
    title.FontFace = FONT_CURSIVE
    title.TextSize = 30
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.LayoutOrder = 1
    title.Parent = header

    local connectorContainer = Instance.new("Frame")
    connectorContainer.Name = "ConnectorContainer"
    connectorContainer.Size = UDim2.new(1, -210, 1, 0)
    connectorContainer.BackgroundTransparency = 1
    connectorContainer.LayoutOrder = 2
    connectorContainer.Parent = header

    local connectorLine = Instance.new("Frame")
    connectorLine.Name = "Line"
    connectorLine.Size = UDim2.new(1, 0, 0, 2)
    connectorLine.Position = UDim2.new(0, 0, 0.5, -1)
    connectorLine.BackgroundColor3 = GLOW_COLOR
    connectorLine.BorderSizePixel = 0
    connectorLine.Parent = connectorContainer

    local connectorStroke = Instance.new("UIStroke")
    connectorStroke.Color = GLOW_COLOR
    connectorStroke.Transparency = 1
    connectorStroke.Thickness = 1
    connectorStroke.Parent = connectorLine

    local toggleBg = Instance.new("TextButton")
    toggleBg.Name = "ToggleBg"
    toggleBg.Size = UDim2.new(0, 40, 0, 20)
    toggleBg.BackgroundColor3 = BG_DARK
    toggleBg.Text = ""
    toggleBg.AutoButtonColor = false
    toggleBg.LayoutOrder = 3
    toggleBg.Parent = header

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg

    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = GLOW_COLOR
    toggleStroke.Transparency = 0.8
    toggleStroke.Parent = toggleBg

    local toggleKnob = Instance.new("Frame")
    toggleKnob.Name = "Knob"
    toggleKnob.Size = UDim2.new(0, 14, 0, 14)
    toggleKnob.Position = UDim2.new(0, 3, 0.5, -7)
    toggleKnob.BackgroundColor3 = GLOW_COLOR
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
    arrowBtn.TextColor3 = MAIN_COLOR
    arrowBtn.FontFace = FONT_CURSIVE
    arrowBtn.TextSize = 28
    arrowBtn.LayoutOrder = 4
    arrowBtn.Parent = header

    local arrowStroke = Instance.new("UIStroke")
    arrowStroke.Color = GLOW_COLOR
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
    leftBorder.Position = UDim2.new(0, 5, 0, 0)
    leftBorder.BackgroundColor3 = GLOW_COLOR
    leftBorder.BorderSizePixel = 0
    leftBorder.Parent = subFrame

    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -20, 0, 0)
    contentArea.Position = UDim2.new(0, 20, 0, 0)
    contentArea.BackgroundTransparency = 1
    contentArea.AutomaticSize = Enum.AutomaticSize.Y
    contentArea.Parent = subFrame

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 8)
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
        rowLayout.Padding = UDim.new(0, 10)
        rowLayout.Parent = row

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 100, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = MAIN_COLOR
        lbl.FontFace = FONT_CURSIVE
        lbl.TextSize = 22
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.LayoutOrder = 1
        lbl.Parent = row

        local lineCont = Instance.new("Frame")
        lineCont.Size = UDim2.new(1, -190, 1, 0)
        lineCont.BackgroundTransparency = 1
        lineCont.LayoutOrder = 2
        lineCont.Parent = row

        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.new(0, 0, 0.5, 0)
        line.BackgroundColor3 = MAIN_COLOR
        line.BackgroundTransparency = 0.5
        line.BorderSizePixel = 0
        line.Parent = lineCont

        local inputCont = Instance.new("Frame")
        inputCont.Size = UDim2.new(0, 60, 0, 26)
        inputCont.BackgroundColor3 = Color3.fromHex("0F0F0F")
        inputCont.BorderSizePixel = 0
        inputCont.LayoutOrder = 3
        inputCont.Parent = row

        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 6)
        inputCorner.Parent = inputCont

        local inputStroke = Instance.new("UIStroke")
        inputStroke.Color = MAIN_COLOR
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
    keyBtn.TextColor3 = GLOW_COLOR
    keyBtn.FontFace = FONT_CURSIVE
    keyBtn.TextSize = 18
    keyBtn.Parent = keyCont

    local divRow = Instance.new("Frame")
    divRow.Size = UDim2.new(1, 0, 0, 1)
    divRow.BackgroundColor3 = GLOW_COLOR
    divRow.BackgroundTransparency = 0.4
    divRow.BorderSizePixel = 0
    divRow.LayoutOrder = 2
    divRow.Parent = contentArea

    local predRow, predCont = createRow("Predict", "Predict", 3)
    predRow.Parent = contentArea

    local predBox = Instance.new("TextBox")
    predBox.Size = UDim2.fromScale(1, 1)
    predBox.BackgroundTransparency = 1
    predBox.Text = "0.000"
    predBox.TextColor3 = MAIN_COLOR
    predBox.FontFace = FONT_CURSIVE
    predBox.TextSize = 18
    predBox.ClearTextOnFocus = false
    predBox.Parent = predCont
    configureDecimalBox(predBox, 0.000, 3)

    local smoothRow, smoothCont = createRow("Smoothness", "Smoothness", 4)
    smoothRow.Parent = contentArea

    local smoothBox = Instance.new("TextBox")
    smoothBox.Size = UDim2.fromScale(1, 1)
    smoothBox.BackgroundTransparency = 1
    smoothBox.Text = "0.50"
    smoothBox.TextColor3 = MAIN_COLOR
    smoothBox.FontFace = FONT_CURSIVE
    smoothBox.TextSize = 18
    smoothBox.ClearTextOnFocus = false
    smoothBox.Parent = smoothCont
    configureDecimalBox(smoothBox, 0.50, 2)

    -- LOGIC
    maid:GiveTask(toggleBg.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        
        local targetKnobPos = isEnabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        local targetBgColor = isEnabled and GLOW_COLOR or BG_DARK
        local targetStrokeTransp = isEnabled and 0.2 or 0.8
        local targetConnectorTransp = isEnabled and 0.2 or 1
        local targetConnectorThick = isEnabled and 3 or 1
        
        playTween(toggleKnob, tInfo, {Position = targetKnobPos}, maid)
        playTween(toggleBg, tInfo, {BackgroundColor3 = targetBgColor}, maid)
        playTween(toggleStroke, tInfo, {Transparency = targetStrokeTransp}, maid)
        playTween(connectorStroke, tInfo, {Transparency = targetConnectorTransp, Thickness = targetConnectorThick}, maid)
    end))

    maid:GiveTask(arrowBtn.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded
        subFrame.Visible = isExpanded
        
        local targetRot = isExpanded and 90 or 0
        local targetColor = isExpanded and GLOW_COLOR or MAIN_COLOR
        local targetStrokeTransp = isExpanded and 0.4 or 1
        
        playTween(arrowBtn, tInfo, {Rotation = targetRot, TextColor3 = targetColor}, maid)
        playTween(arrowStroke, tInfo, {Transparency = targetStrokeTransp}, maid)
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
