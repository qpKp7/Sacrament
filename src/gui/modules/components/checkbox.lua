--!strict
local TweenService = game:GetService("TweenService")
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type CheckboxUI = {
    Instance: TextButton,
    Toggled: RBXScriptSignal,
    SetState: (self: CheckboxUI, state: boolean) -> (),
    GetState: (self: CheckboxUI) -> boolean,
    Destroy: (self: CheckboxUI) -> ()
}

local CheckboxFactory = {}

local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_BORDER = Color3.fromHex("333333")
local COLOR_BORDER_HOVER = Color3.fromHex("555555")
local COLOR_ACTIVE = Color3.fromHex("C80000")
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

function CheckboxFactory.new(defaultState: boolean?): CheckboxUI
    local maid = Maid.new()
    local isChecked = defaultState or false

    local button = Instance.new("TextButton")
    button.Name = "Checkbox"
    button.Size = UDim2.fromOffset(20, 20)
    button.BackgroundColor3 = COLOR_BG
    button.Text = ""
    button.AutoButtonColor = false

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLOR_BORDER
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = button

    local innerMark = Instance.new("Frame")
    innerMark.Name = "Mark"
    innerMark.AnchorPoint = Vector2.new(0.5, 0.5)
    innerMark.Position = UDim2.fromScale(0.5, 0.5)
    innerMark.BackgroundColor3 = COLOR_ACTIVE
    innerMark.BorderSizePixel = 0
    innerMark.Size = isChecked and UDim2.fromOffset(12, 12) or UDim2.fromOffset(0, 0)
    innerMark.Parent = button

    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(0, 2)
    innerCorner.Parent = innerMark

    local toggledEvent = Instance.new("BindableEvent")
    maid:GiveTask(toggledEvent)

    local function updateVisuals()
        local targetSize = isChecked and UDim2.fromOffset(12, 12) or UDim2.fromOffset(0, 0)
        local tween = TweenService:Create(innerMark, TWEEN_INFO, {Size = targetSize})
        tween:Play()
        
        maid:GiveTask(tween.Completed:Connect(function()
            tween:Destroy()
        end))
    end

    maid:GiveTask(button.MouseEnter:Connect(function()
        local tween = TweenService:Create(stroke, TWEEN_INFO, {Color = COLOR_BORDER_HOVER})
        tween:Play()
        maid:GiveTask(tween.Completed:Connect(function() tween:Destroy() end))
    end))

    maid:GiveTask(button.MouseLeave:Connect(function()
        local tween = TweenService:Create(stroke, TWEEN_INFO, {Color = COLOR_BORDER})
        tween:Play()
        maid:GiveTask(tween.Completed:Connect(function() tween:Destroy() end))
    end))

    maid:GiveTask(button.Activated:Connect(function()
        isChecked = not isChecked
        updateVisuals()
        toggledEvent:Fire(isChecked)
    end))

    maid:GiveTask(button)
    
    local self = {}
    self.Instance = button
    self.Toggled = toggledEvent.Event

    function self:SetState(state: boolean)
        if isChecked == state then return end
        isChecked = state
        updateVisuals()
        toggledEvent:Fire(isChecked)
    end

    function self:GetState()
        return isChecked
    end

    function self:Destroy()
        maid:Destroy()
    end

    return self :: CheckboxUI
end

return CheckboxFactory
