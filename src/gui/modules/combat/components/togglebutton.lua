--!strict
local TweenService = game:GetService("TweenService")
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type ToggleButton = {
    Instance: TextButton,
    Toggled: RBXScriptSignal,
    SetState: (self: ToggleButton, state: boolean) -> (),
    Destroy: (self: ToggleButton) -> ()
}

local ToggleButtonFactory = {}

local COLOR_BG_OFF = Color3.fromHex("444444")
local COLOR_BG_ON = Color3.fromHex("960000")
local COLOR_KNOB = Color3.fromHex("FFFFFF")

function ToggleButtonFactory.new(): ToggleButton
    local maid = Maid.new()
    local isEnabled = false
    local tInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local toggledEvent = Instance.new("BindableEvent")
    maid:GiveTask(toggledEvent)

    local button = Instance.new("TextButton")
    button.Name = "ToggleButton"
    button.Size = UDim2.fromOffset(46, 24)
    button.BackgroundColor3 = COLOR_BG_OFF
    button.Text = ""
    button.AutoButtonColor = false
    button.ZIndex = 2

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.fromOffset(18, 18)
    knob.Position = UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = COLOR_KNOB
    knob.BorderSizePixel = 0
    knob.ZIndex = 3
    knob.Parent = button

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local function updateVisuals(state: boolean)
        local targetPos = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        local targetColor = state and COLOR_BG_ON or COLOR_BG_OFF
        
        local tweenPos = TweenService:Create(knob, tInfo, {Position = targetPos})
        local tweenColor = TweenService:Create(button, tInfo, {BackgroundColor3 = targetColor})
        
        tweenPos:Play()
        tweenColor:Play()
        
        maid:GiveTask(tweenPos.Completed:Connect(function() tweenPos:Destroy() end))
        maid:GiveTask(tweenColor.Completed:Connect(function() tweenColor:Destroy() end))
    end

    maid:GiveTask(button.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        updateVisuals(isEnabled)
        toggledEvent:Fire(isEnabled)
    end))

    local self = {}
    self.Instance = button
    self.Toggled = toggledEvent.Event

    function self:SetState(state: boolean)
        isEnabled = state
        updateVisuals(state)
    end

    function self:Destroy()
        maid:Destroy()
    end

    return self
end

return ToggleButtonFactory
