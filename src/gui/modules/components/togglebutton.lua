--!strict
local TweenService = game:GetService("TweenService")
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type ToggleButton = {
    Instance: TextButton,
    Toggled: RBXScriptSignal,
    SetState: (self: ToggleButton, state: boolean, instant: boolean?) -> (),
    Destroy: (self: ToggleButton) -> (),
}

local ToggleButtonFactory = {}

local COLOR_BG_OFF = Color3.fromHex("444444")
local COLOR_BG_ON = Color3.fromHex("960000")
local COLOR_KNOB = Color3.fromHex("FFFFFF")

function ToggleButtonFactory.new(initialState: boolean?): ToggleButton
    local maid = Maid.new()
    local isEnabled = if initialState ~= nil then initialState else false
    local tInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local toggledEvent = Instance.new("BindableEvent")
    maid:GiveTask(toggledEvent)

    local button = Instance.new("TextButton")
    button.Name = "ToggleButton"
    button.Size = UDim2.fromOffset(46, 24)
    button.BackgroundColor3 = isEnabled and COLOR_BG_ON or COLOR_BG_OFF
    button.Text = ""
    button.AutoButtonColor = false
    button.ZIndex = 2

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.fromOffset(18, 18)
    knob.Position = isEnabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = COLOR_KNOB
    knob.BorderSizePixel = 0
    knob.ZIndex = 3
    knob.Parent = button

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    -- Função de atualização visual com suporte a modo instantâneo
    local function updateVisuals(state: boolean, instant: boolean?)
        local targetPos = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        local targetColor = state and COLOR_BG_ON or COLOR_BG_OFF

        if instant then
            knob.Position = targetPos
            button.BackgroundColor3 = targetColor
        else
            local tweenPos = TweenService:Create(knob, tInfo, { Position = targetPos })
            local tweenColor = TweenService:Create(button, tInfo, { BackgroundColor3 = targetColor })
            
            tweenPos:Play()
            tweenColor:Play()

            maid:GiveTask(tweenPos.Completed:Connect(function() tweenPos:Destroy() end))
            maid:GiveTask(tweenColor.Completed:Connect(function() tweenColor:Destroy() end))
        end
    end

    -- Evento de clique do usuário (sempre animado)
    maid:GiveTask(button.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        updateVisuals(isEnabled, false)
        toggledEvent:Fire(isEnabled)
    end))

    local self = {}
    self.Instance = button
    self.Toggled = toggledEvent.Event

    -- Método para alterar o estado via código (suporta modo silencioso para o Loader)
    function self:SetState(state: boolean, instant: boolean?)
        isEnabled = state
        updateVisuals(state, instant)
    end

    function self:Destroy()
        maid:Destroy()
    end

    return self :: ToggleButton
end

return ToggleButtonFactory
