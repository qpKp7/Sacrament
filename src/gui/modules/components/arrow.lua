--!strict
local TweenService = game:GetService("TweenService")
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type Arrow = {
    Instance: Frame,
    Toggled: RBXScriptSignal,
    SetState: (self: Arrow, expanded: boolean) -> (),
    Destroy: (self: Arrow) -> ()
}

local ArrowFactory = {}

local COLOR_CLOSED = Color3.fromHex("CCCCCC")
local COLOR_OPEN = Color3.fromHex("C80000")
local FONT_MAIN = Enum.Font.GothamBold

function ArrowFactory.new(): Arrow
    local maid = Maid.new()
    local expanded = false
    local tInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local toggledEvent = Instance.new("BindableEvent")
    maid:GiveTask(toggledEvent)

    local container = Instance.new("Frame")
    container.Name = "ArrowContainer"
    container.Size = UDim2.fromOffset(20, 50)
    container.BackgroundTransparency = 1

    local button = Instance.new("TextButton")
    button.Name = "ArrowBtn"
    button.Size = UDim2.fromOffset(30, 30)
    button.Position = UDim2.fromScale(0.5, 0.5)
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    button.BackgroundTransparency = 1
    button.Text = ">"
    button.Rotation = 0
    button.TextColor3 = COLOR_CLOSED
    button.Font = FONT_MAIN
    button.TextSize = 18
    button.ZIndex = 2
    button.Parent = container

    local currentTween: Tween? = nil

    local function updateVisuals(isExpanded: boolean)
        if currentTween then
            currentTween:Cancel()
            currentTween:Destroy()
            currentTween = nil
        end

        local targetRot = isExpanded and 90 or 0
        local targetColor = isExpanded and COLOR_OPEN or COLOR_CLOSED
        
        local tween = TweenService:Create(button, tInfo, {
            Rotation = targetRot,
            TextColor3 = targetColor
        })
        
        currentTween = tween
        tween:Play()
        
        local connection: RBXScriptConnection
        connection = tween.Completed:Connect(function()
            if connection then
                connection:Disconnect()
            end
            if currentTween == tween then
                currentTween = nil
            end
            tween:Destroy()
        end)
    end

    maid:GiveTask(button.MouseButton1Click:Connect(function()
        expanded = not expanded
        updateVisuals(expanded)
        toggledEvent:Fire(expanded)
    end))

    local self = {}
    self.Instance = container
    self.Toggled = toggledEvent.Event

    function self:SetState(state: boolean)
        expanded = state
        updateVisuals(state)
    end

    function self:Destroy()
        if currentTween then
            currentTween:Cancel()
            currentTween:Destroy()
        end
        maid:Destroy()
    end

    return self
end

return ArrowFactory
