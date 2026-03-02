--!strict
local TweenService = game:GetService("TweenService")
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type ActionButtonUI = {
    Instance: TextButton,
    Activated: RBXScriptSignal,
    Destroy: (self: ActionButtonUI) -> ()
}

local ActionButtonFactory = {}

local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_BORDER = Color3.fromHex("333333")
local COLOR_ACCENT = Color3.fromHex("C80000")
local COLOR_TEXT = Color3.fromHex("FFFFFF")
local FONT_MAIN = Enum.Font.GothamBold
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

function ActionButtonFactory.new(text: string, layoutOrder: number?): ActionButtonUI
    local maid = Maid.new()

    local btn = Instance.new("TextButton")
    btn.Name = "ActionButton"
    btn.Size = UDim2.new(0.5, -7, 1, 0)
    btn.BackgroundColor3 = COLOR_BG
    btn.Text = text
    btn.TextColor3 = COLOR_TEXT
    btn.Font = FONT_MAIN
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.LayoutOrder = layoutOrder or 1

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLOR_BORDER
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = btn

    maid:GiveTask(btn.MouseEnter:Connect(function()
        local tween = TweenService:Create(stroke, TWEEN_INFO, {Color = COLOR_ACCENT})
        tween:Play()
        maid:GiveTask(tween.Completed:Connect(function() tween:Destroy() end))
    end))

    maid:GiveTask(btn.MouseLeave:Connect(function()
        local tween = TweenService:Create(stroke, TWEEN_INFO, {Color = COLOR_BORDER})
        tween:Play()
        maid:GiveTask(tween.Completed:Connect(function() tween:Destroy() end))
    end))

    local activatedEvent = Instance.new("BindableEvent")
    maid:GiveTask(activatedEvent)
    maid:GiveTask(btn.Activated:Connect(function()
        activatedEvent:Fire()
    end))

    maid:GiveTask(btn)

    local self = {}
    self.Instance = btn
    self.Activated = activatedEvent.Event
    function self:Destroy() maid:Destroy() end
    return self :: ActionButtonUI
end

return ActionButtonFactory
