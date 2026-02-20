--!strict
local TweenService = game:GetService("TweenService")
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")
local Colors = Import("themes/colors")

export type AimlockUI = {
    Instance: Frame,
    Destroy: (self: AimlockUI) -> ()
}

local AimlockFactory = {}

function AimlockFactory.new(): AimlockUI
    local maid = Maid.new()
    local isEnabled = false

    local container = Instance.new("Frame")
    container.Name = "AimlockContainer"
    container.Size = UDim2.new(1, 0, 0, 42)
    container.BackgroundColor3 = Colors.ButtonDefault
    container.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container

    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Divider
    stroke.Transparency = 0.8
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = container

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Aimlock"
    title.TextColor3 = Colors.TextDefault
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = container

    local toggleBg = Instance.new("TextButton")
    toggleBg.Name = "ToggleBg"
    toggleBg.Size = UDim2.new(0, 40, 0, 20)
    toggleBg.Position = UDim2.new(1, -55, 0.5, -10)
    toggleBg.BackgroundColor3 = Color3.fromHex("1A0505")
    toggleBg.Text = ""
    toggleBg.AutoButtonColor = false
    toggleBg.Parent = container

    local toggleBgCorner = Instance.new("UICorner")
    toggleBgCorner.CornerRadius = UDim.new(1, 0)
    toggleBgCorner.Parent = toggleBg

    local toggleBgStroke = Instance.new("UIStroke")
    toggleBgStroke.Color = Colors.Divider
    toggleBgStroke.Transparency = 0.5
    toggleBgStroke.Parent = toggleBg

    local toggleKnob = Instance.new("Frame")
    toggleKnob.Name = "Knob"
    toggleKnob.Size = UDim2.new(0, 14, 0, 14)
    toggleKnob.Position = UDim2.new(0, 3, 0.5, -7)
    toggleKnob.BackgroundColor3 = Colors.TextDefault
    toggleKnob.BorderSizePixel = 0
    toggleKnob.Parent = toggleBg

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = toggleKnob

    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    maid:GiveTask(toggleBg.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        
        local targetKnobPos = isEnabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        local targetBgColor = isEnabled and Color3.fromHex("3D0000") or Color3.fromHex("1A0505")
        
        local knobTween = TweenService:Create(toggleKnob, tweenInfo, {Position = targetKnobPos})
        local bgTween = TweenService:Create(toggleBg, tweenInfo, {BackgroundColor3 = targetBgColor})
        
        maid:GiveTask(knobTween.Completed:Connect(function() knobTween:Destroy() end))
        maid:GiveTask(bgTween.Completed:Connect(function() bgTween:Destroy() end))
        
        knobTween:Play()
        bgTween:Play()
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
