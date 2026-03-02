--!strict
local TweenService = game:GetService("TweenService")
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type CheckboxUI = {
    Instance: Frame,
    Toggled: RBXScriptSignal,
    SetState: (self: CheckboxUI, state: boolean, animate: boolean?) -> (),
    Destroy: (self: CheckboxUI) -> ()
}

local CheckboxFactory = {}

local COLOR_BOX_BG = Color3.fromHex("1A1A1A")
local COLOR_BOX_BORDER = Color3.fromHex("333333")
local COLOR_FILL = Color3.fromHex("C80000")
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function CheckboxFactory.new(defaultState: boolean?): CheckboxUI
    local maid = Maid.new()
    local isToggled = defaultState or false

    local container = Instance.new("Frame")
    container.Name = "CheckboxContainer"
    container.Size = UDim2.fromOffset(20, 20)
    container.BackgroundColor3 = COLOR_BOX_BG
    container.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = container

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLOR_BOX_BORDER
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = container

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.AnchorPoint = Vector2.new(0.5, 0.5)
    fill.Position = UDim2.fromScale(0.5, 0.5)
    fill.BackgroundColor3 = COLOR_FILL
    fill.BorderSizePixel = 0
    fill.Parent = container

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill

    local hitBtn = Instance.new("TextButton")
    hitBtn.Name = "Hitbox"
    hitBtn.Size = UDim2.fromScale(1, 1)
    hitBtn.BackgroundTransparency = 1
    hitBtn.Text = ""
    hitBtn.Parent = container

    local toggledEvent = Instance.new("BindableEvent")
    maid:GiveTask(toggledEvent)

    local self = {}
    self.Instance = container
    self.Toggled = toggledEvent.Event

    function self:SetState(state: boolean, animate: boolean?)
        isToggled = state
        
        local targetSize = state and UDim2.new(1, -8, 1, -8) or UDim2.fromScale(0, 0)
        local targetTrans = state and 0 or 1

        if animate ~= false then
            local t = TweenService:Create(fill, TWEEN_INFO, {
                Size = targetSize,
                BackgroundTransparency = targetTrans
            } :: any)
            t:Play()
            
            local conn: RBXScriptConnection
            conn = t.Completed:Connect(function()
                t:Destroy()
                if conn then conn:Disconnect() end
            end)
        else
            fill.Size = targetSize
            fill.BackgroundTransparency = targetTrans
        end
    end

    maid:GiveTask(hitBtn.Activated:Connect(function()
        self:SetState(not isToggled, true)
        toggledEvent:Fire(isToggled)
    end))

    self:SetState(isToggled, false)

    maid:GiveTask(container)
    function self:Destroy()
        maid:Destroy()
    end

    return self :: CheckboxUI
end

return CheckboxFactory
