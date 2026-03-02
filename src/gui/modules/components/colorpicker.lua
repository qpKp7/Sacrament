--!strict
local UserInputService = game:GetService("UserInputService")
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type ColorPickerUI = {
    Instance: Frame,
    Changed: RBXScriptSignal,
    SetColor: (self: ColorPickerUI, color: Color3) -> (),
    Destroy: (self: ColorPickerUI) -> ()
}

local ColorPickerFactory = {}

local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_BORDER = Color3.fromHex("333333")
local COLOR_TEXT = Color3.fromHex("B4B4B4")
local FONT_MAIN = Enum.Font.GothamBold

local HUE_COLORS = ColorSequence.new({
    ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.500, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 0, 0))
})

local function round(num: number): number
    return math.floor(num + 0.5)
end

function ColorPickerFactory.new(defaultColor: Color3?): ColorPickerUI
    local maid = Maid.new()
    local currentColor = defaultColor or Color3.fromRGB(200, 0, 0)
    local h, s, v = currentColor:ToHSV()

    local container = Instance.new("Frame")
    container.Name = "ColorPickerContainer"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundColor3 = COLOR_BG
    container.BorderSizePixel = 0
    container.ClipsDescendants = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = container

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLOR_BORDER
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = container

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = container

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.Parent = container

    -- SV Canvas (Branco à esquerda, Cor à direita, Preto no fundo)
    local svCanvas = Instance.new("TextButton")
    svCanvas.Name = "SVCanvas"
    svCanvas.Size = UDim2.new(1, 0, 0, 120)
    svCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    svCanvas.AutoButtonColor = false
    svCanvas.Text = ""
    svCanvas.LayoutOrder = 1
    svCanvas.Parent = container

    local svCorner = Instance.new("UICorner")
    svCorner.CornerRadius = UDim.new(0, 4)
    svCorner.Parent = svCanvas

    -- Camada 1: Branco para Transparente (Esquerda para Direita)
    local whiteGradient = Instance.new("UIGradient")
    whiteGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
    whiteGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    whiteGradient.Parent = svCanvas

    -- Camada 2: Overlay Preto (Cima Transparente para Baixo Preto)
    local blackOverlay = Instance.new("Frame")
    blackOverlay.Size = UDim2.fromScale(1, 1)
    blackOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
    blackOverlay.BorderSizePixel = 0
    blackOverlay.Parent = svCanvas

    local blackCorner = Instance.new("UICorner")
    blackCorner.CornerRadius = UDim.new(0, 4)
    blackCorner.Parent = blackOverlay

    local blackGradient = Instance.new("UIGradient")
    blackGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
    blackGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    })
    blackGradient.Rotation = 90
    blackGradient.Parent = blackOverlay

    local svKnob = Instance.new("Frame")
    svKnob.Name = "Knob"
    svKnob.Size = UDim2.fromOffset(12, 12)
    svKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    svKnob.BackgroundColor3 = currentColor
    svKnob.Parent = svCanvas

    local svKnobCorner = Instance.new("UICorner")
    svKnobCorner.CornerRadius = UDim.new(1, 0)
    svKnobCorner.Parent = svKnob

    local svKnobStroke = Instance.new("UIStroke")
    svKnobStroke.Color = Color3.new(1, 1, 1) -- Borda branca para contraste
    svKnobStroke.Thickness = 1
    svKnobStroke.Parent = svKnob

    -- Hue Slider
    local hueCanvas = Instance.new("TextButton")
    hueCanvas.Name = "HueCanvas"
    hueCanvas.Size = UDim2.new(1, 0, 0, 12)
    hueCanvas.BackgroundColor3 = Color3.new(1, 1, 1)
    hueCanvas.AutoButtonColor = false
    hueCanvas.Text = ""
    hueCanvas.LayoutOrder = 2
    hueCanvas.Parent = container

    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(0, 6)
    hueCorner.Parent = hueCanvas

    local hueGradient = Instance.new("UIGradient")
    hueGradient.Color = HUE_COLORS
    hueGradient.Parent = hueCanvas

    local hueKnob = Instance.new("Frame")
    hueKnob.Name = "Knob"
    hueKnob.Size = UDim2.fromOffset(16, 16)
    hueKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    hueKnob.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    hueKnob.Parent = hueCanvas

    local hueKnobCorner = Instance.new("UICorner")
    hueKnobCorner.CornerRadius = UDim.new(1, 0)
    hueKnobCorner.Parent = hueKnob

    local hueKnobStroke = Instance.new("UIStroke")
    hueKnobStroke.Color = Color3.new(0, 0, 0)
    hueKnobStroke.Thickness = 1
    hueKnobStroke.Parent = hueKnob

    -- Inputs (HEX & RGB)
    local inputsFrame = Instance.new("Frame")
    inputsFrame.Name = "Inputs"
    inputsFrame.Size = UDim2.new(1, 0, 0, 28)
    inputsFrame.BackgroundTransparency = 1
    inputsFrame.LayoutOrder = 3
    inputsFrame.Parent = container

    local inputLayout = Instance.new("UIListLayout")
    inputLayout.FillDirection = Enum.FillDirection.Horizontal
    inputLayout.SortOrder = Enum.SortOrder.LayoutOrder
    inputLayout.Padding = UDim.new(0, 10)
    inputLayout.Parent = inputsFrame

    local function createInput(name: string, widthScale: number, order: number): TextBox
        local box = Instance.new("TextBox")
        box.Name = name
        box.Size = UDim2.new(widthScale, (widthScale == 1 and 0 or -5), 1, 0)
        box.BackgroundColor3 = COLOR_BG
        box.TextColor3 = COLOR_TEXT
        box.Font = FONT_MAIN
        box.TextSize = 12
        box.ClearTextOnFocus = false
        box.LayoutOrder = order
        box.Parent = inputsFrame

        local boxCorner = Instance.new("UICorner")
        boxCorner.CornerRadius = UDim.new(0, 4)
        boxCorner.Parent = box

        local boxStroke = Instance.new("UIStroke")
        boxStroke.Color = COLOR_BORDER
        boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        boxStroke.Parent = box

        return box
    end

    local hexInput = createInput("HexInput", 0.4, 1)
    local rgbInput = createInput("RGBInput", 0.6, 2)

    local changedEvent = Instance.new("BindableEvent")
    maid:GiveTask(changedEvent)

    local isUpdatingInternal = false

    local function updateVisuals()
        svCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        svKnob.Position = UDim2.fromScale(s, 1 - v)
        svKnob.BackgroundColor3 = currentColor
        hueKnob.Position = UDim2.fromScale(1 - h, 0.5)
        hueKnob.BackgroundColor3 = Color3.fromHSV(h, 1, 1)

        if not isUpdatingInternal then
            hexInput.Text = "#" .. currentColor:ToHex():upper()
            rgbInput.Text = string.format("%d, %d, %d", round(currentColor.R * 255), round(currentColor.G * 255), round(currentColor.B * 255))
        end
    end

    local function setColorInternal(newH: number, newS: number, newV: number)
        h = math.clamp(newH, 0, 1)
        s = math.clamp(newS, 0, 1)
        v = math.clamp(newV, 0, 1)
        currentColor = Color3.fromHSV(h, s, v)
        updateVisuals()
        changedEvent:Fire(currentColor)
    end

    local function bindDrag(canvas: TextButton, isHue: boolean)
        local dragging = false
        maid:GiveTask(canvas.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                local pos = input.Position
                local absPos = canvas.AbsolutePosition
                local absSize = canvas.AbsoluteSize
                if isHue then
                    local newH = 1 - math.clamp((pos.X - absPos.X) / absSize.X, 0, 1)
                    setColorInternal(newH, s, v)
                else
                    local newS = math.clamp((pos.X - absPos.X) / absSize.X, 0, 1)
                    local newV = 1 - math.clamp((pos.Y - absPos.Y) / absSize.Y, 0, 1)
                    setColorInternal(h, newS, newV)
                end
            end
        end))

        maid:GiveTask(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))

        maid:GiveTask(UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local pos = input.Position
                local absPos = canvas.AbsolutePosition
                local absSize = canvas.AbsoluteSize

                if isHue then
                    local newH = 1 - math.clamp((pos.X - absPos.X) / absSize.X, 0, 1)
                    setColorInternal(newH, s, v)
                else
                    local newS = math.clamp((pos.X - absPos.X) / absSize.X, 0, 1)
                    local newV = 1 - math.clamp((pos.Y - absPos.Y) / absSize.Y, 0, 1)
                    setColorInternal(h, newS, newV)
                end
            end
        end))
    end

    bindDrag(svCanvas, false)
    bindDrag(hueCanvas, true)

    -- Filtros Rigorosos de Texto (Tempo Real)
    maid:GiveTask(hexInput:GetPropertyChangedSignal("Text"):Connect(function()
        if isUpdatingInternal then return end
        isUpdatingInternal = true
        local cleaned = hexInput.Text:upper():gsub("[^%dA-F]", "")
        cleaned = string.sub(cleaned, 1, 6)
        hexInput.Text = "#" .. cleaned
        isUpdatingInternal = false
    end))

    maid:GiveTask(rgbInput:GetPropertyChangedSignal("Text"):Connect(function()
        if isUpdatingInternal then return end
        isUpdatingInternal = true
        local cleaned = rgbInput.Text:gsub("[^%d, ]", "")
        cleaned = string.sub(cleaned, 1, 13) -- Máximo de caracteres para "255, 255, 255"
        rgbInput.Text = cleaned
        isUpdatingInternal = false
    end))

    -- Atualização Matemática Pós-Edição
    maid:GiveTask(hexInput.FocusLost:Connect(function()
        isUpdatingInternal = true
        local txt = hexInput.Text:gsub("#", "")
        if #txt == 6 then
            local success, c = pcall(function() return Color3.fromHex(txt) end)
            if success and c then
                local newH, newS, newV = c:ToHSV()
                setColorInternal(newH, newS, newV)
            end
        end
        isUpdatingInternal = false
        updateVisuals()
    end))

    maid:GiveTask(rgbInput.FocusLost:Connect(function()
        isUpdatingInternal = true
        local r, g, b = rgbInput.Text:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
        if r and g and b then
            local nr, ng, nb = tonumber(r), tonumber(g), tonumber(b)
            if nr and ng and nb then
                local c = Color3.fromRGB(math.clamp(nr, 0, 255), math.clamp(ng, 0, 255), math.clamp(nb, 0, 255))
                local newH, newS, newV = c:ToHSV()
                setColorInternal(newH, newS, newV)
            end
        end
        isUpdatingInternal = false
        updateVisuals()
    end))

    updateVisuals()

    maid:GiveTask(container)
    local self = {}
    self.Instance = container
    self.Changed = changedEvent.Event

    function self:SetColor(color: Color3)
        local newH, newS, newV = color:ToHSV()
        setColorInternal(newH, newS, newV)
    end

    function self:Destroy()
        maid:Destroy()
    end

    return self :: ColorPickerUI
end

return ColorPickerFactory
