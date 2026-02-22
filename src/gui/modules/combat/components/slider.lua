--!strict
local UserInputService = game:GetService("UserInputService")
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type Slider = {
    Instance: Frame,
    SetValue: (self: Slider, value: number) -> (),
    OnValueChanged: RBXScriptSignal,
    Destroy: (self: Slider) -> ()
}

local SliderFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local COLOR_VALUE = Color3.fromRGB(255, 255, 255)
local FONT_MAIN = Enum.Font.GothamBold

function SliderFactory.new(title: string, min: number, max: number, default: number): Slider
    local maid = Maid.new()
    local valueChanged = Instance.new("BindableEvent")
    
    local isDragging = false
    local currentValue = math.clamp(math.round(default), min, max)

    local container = Instance.new("Frame")
    container.Name = title .. "Slider"
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundTransparency = 1
    container.Active = true -- Essencial para detectar cliques/drag

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = container

    local infoFrame = Instance.new("Frame")
    infoFrame.Size = UDim2.new(1, 0, 0, 20)
    infoFrame.BackgroundTransparency = 1
    infoFrame.Parent = container

    local lblTitle = Instance.new("TextLabel")
    lblTitle.Size = UDim2.new(0.5, 0, 1, 0)
    lblTitle.BackgroundTransparency = 1
    lblTitle.Text = title
    lblTitle.TextColor3 = COLOR_LABEL
    lblTitle.Font = FONT_MAIN
    lblTitle.TextSize = 14
    lblTitle.TextXAlignment = Enum.TextXAlignment.Left
    lblTitle.Parent = infoFrame

    local lblValue = Instance.new("TextLabel")
    lblValue.Size = UDim2.new(0.5, 0, 1, 0)
    lblValue.Position = UDim2.fromScale(0.5, 0)
    lblValue.BackgroundTransparency = 1
    lblValue.Text = tostring(currentValue)
    lblValue.TextColor3 = COLOR_VALUE
    lblValue.Font = FONT_MAIN
    lblValue.TextSize = 14
    lblValue.TextXAlignment = Enum.TextXAlignment.Right
    lblValue.Parent = infoFrame

    local rail = Instance.new("Frame")
    rail.Name = "Rail"
    rail.Size = UDim2.new(1, 0, 0, 4)
    rail.Position = UDim2.new(0, 0, 1, -5)
    rail.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    rail.BorderSizePixel = 0
    rail.Parent = container

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.fromScale((currentValue - min) / (max - min), 1)
    fill.BackgroundColor3 = Color3.fromHex("C80000")
    fill.BorderSizePixel = 0
    fill.Parent = rail

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.fromOffset(10, 10)
    knob.Position = UDim2.new(1, 0, 0.5, 0)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Parent = fill
    
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function updateValue(input: InputObject)
        local railAbsoluteSize = rail.AbsoluteSize.X
        local railAbsolutePos = rail.AbsolutePosition.X
        local mousePos = input.Position.X
        
        local percent = math.clamp((mousePos - railAbsolutePos) / railAbsoluteSize, 0, 1)
        local rawValue = min + (percent * (max - min))
        local snappedValue = math.round(rawValue)
        
        if snappedValue ~= currentValue then
            currentValue = snappedValue
            lblValue.Text = tostring(currentValue)
            fill.Size = UDim2.fromScale((currentValue - min) / (max - min), 1)
            valueChanged:Fire(currentValue)
        end
    end

    maid:GiveTask(container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            updateValue(input)
        end
    end))

    maid:GiveTask(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end))

    maid:GiveTask(UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValue(input)
        end
    end))

    maid:GiveTask(container)

    local self = {}
    self.Instance = container
    self.OnValueChanged = valueChanged.Event

    function self:SetValue(value: number)
        currentValue = math.clamp(math.round(value), min, max)
        lblValue.Text = tostring(currentValue)
        fill.Size = UDim2.fromScale((currentValue - min) / (max - min), 1)
    end

    function self:Destroy()
        maid:Destroy()
    end

    return self
end

return SliderFactory
