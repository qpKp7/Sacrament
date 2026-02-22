--!strict
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type Slider = {
    Instance: Frame,
    Value: number,
    Changed: RBXScriptSignal,
    Destroy: (self: Slider) -> ()
}

local SliderFactory = {}

local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_FILL = Color3.fromHex("960000")
local COLOR_TEXT = Color3.fromHex("FFFFFF")
local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local FONT_MAIN = Enum.Font.GothamBold

function SliderFactory.new(name: string, min: number, max: number, default: number, step: number): Slider
    local maid = Maid.new()
    local bindable = Instance.new("BindableEvent")
    maid:GiveTask(bindable)

    local row = Instance.new("Frame")
    row.Name = name .. "SliderRow"
    row.Size = UDim2.new(1, 0, 0, 50)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = row

    local label = Instance.new("TextLabel")
    label.Name = "Title"
    label.Size = UDim2.new(0.5, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = COLOR_LABEL
    label.Font = FONT_MAIN
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local valLabel = Instance.new("TextLabel")
    valLabel.Name = "Value"
    valLabel.Size = UDim2.new(0.5, 0, 0, 20)
    valLabel.Position = UDim2.fromScale(0.5, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(default)
    valLabel.TextColor3 = COLOR_TEXT
    valLabel.Font = FONT_MAIN
    valLabel.TextSize = 14
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = row

    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 1, -15)
    track.BackgroundColor3 = COLOR_BG
    track.BorderSizePixel = 0
    track.Parent = row

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.fromScale((default - min) / (max - min), 1)
    fill.BackgroundColor3 = COLOR_FILL
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.fromOffset(12, 12)
    knob.Position = UDim2.new(1, 0, 0.5, 0)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.BackgroundColor3 = COLOR_TEXT
    knob.BorderSizePixel = 0
    knob.Parent = fill

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local btn = Instance.new("TextButton")
    btn.Name = "InputCapture"
    btn.Size = UDim2.new(1, 0, 0, 24)
    btn.Position = UDim2.new(0, 0, 0.5, 0)
    btn.AnchorPoint = Vector2.new(0, 0.5)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = track

    local isDragging = false
    local currentValue = default

    local function updateSlider(input: InputObject)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local rawValue = min + (max - min) * pos
        local steppedValue = math.floor(rawValue / step + 0.5) * step
        steppedValue = math.clamp(steppedValue, min, max)

        if currentValue ~= steppedValue then
            currentValue = steppedValue
            valLabel.Text = tostring(currentValue)
            
            local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(fill, tweenInfo, {Size = UDim2.fromScale((currentValue - min) / (max - min), 1)})
            tween:Play()
            
            local conn: RBXScriptConnection
            conn = tween.Completed:Connect(function()
                conn:Disconnect()
                tween:Destroy()
            end)
            
            bindable:Fire(currentValue)
        end
    end

    maid:GiveTask(btn.InputBegan:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            updateSlider(input)
        end
    end))

    maid:GiveTask(UserInputService.InputEnded:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end))

    maid:GiveTask(UserInputService.InputChanged:Connect(function(input: InputObject)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end))

    maid:GiveTask(row)

    local self = {}
    self.Instance = row
    self.Value = currentValue
    self.Changed = bindable.Event

    function self:Destroy()
        maid:Destroy()
    end

    return self
end

return SliderFactory
