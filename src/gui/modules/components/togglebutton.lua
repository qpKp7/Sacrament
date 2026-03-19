--!strict
local TweenService = game:GetService("TweenService")
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type ToggleButton = {
    Instance: TextButton,
    Toggled: RBXScriptSignal,
    GetValue: (self: ToggleButton) -> boolean,
    SetState: (self: ToggleButton, state: boolean, silent: boolean?) -> (),
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

    local self = {} :: any
    self.Instance = button
    self.Toggled = toggledEvent.Event

    -- =========================================================
    -- CONTRATO OBRIGATÓRIO: SetState Unificado
    -- =========================================================
    function self:SetState(state: boolean, silent: boolean?)
        isEnabled = state
        
        local targetPos = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        local targetColor = state and COLOR_BG_ON or COLOR_BG_OFF

        if silent then
            -- Se for o Orquestrador injetando a memória, muda instantaneamente e sem gritar
            knob.Position = targetPos
            button.BackgroundColor3 = targetColor
        else
            -- Se for o usuário interagindo, anima e grita pro Orquestrador salvar
            local tweenPos = TweenService:Create(knob, tInfo, { Position = targetPos })
            local tweenColor = TweenService:Create(button, tInfo, { BackgroundColor3 = targetColor })
            
            tweenPos:Play()
            tweenColor:Play()

            -- Limpeza limpa sem atrapalhar a thread
            task.delay(0.25, function()
                tweenPos:Destroy()
                tweenColor:Destroy()
            end)

            toggledEvent:Fire(isEnabled)
        end
    end

    function self:GetValue()
        return isEnabled
    end

    -- O clique do usuário agora chama o Contrato dizendo: "Muda aí, e não é silencioso!"
    maid:GiveTask(button.MouseButton1Click:Connect(function()
        self:SetState(not isEnabled, false)
    end))

    function self:Destroy()
        maid:Destroy()
    end

    return self :: ToggleButton
end

return ToggleButtonFactory
