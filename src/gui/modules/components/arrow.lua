--!strict
local TweenService = game:GetService("TweenService")

local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type ArrowUI = {
    Instance: TextButton,
    Toggled: RBXScriptSignal,
    State: boolean,
    SetState: (self: ArrowUI, state: boolean) -> (),
    Destroy: (self: ArrowUI) -> ()
}

local ArrowFactory = {}

local COLOR_IDLE = Color3.fromHex("B4B4B4")
local COLOR_ACTIVE = Color3.fromHex("C80000")
local FONT_MAIN = Enum.Font.GothamBold
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function ArrowFactory.new(): ArrowUI
    local maid = Maid.new()
    
    -- Hitbox minúscula e exata: 20x20 pixels. Sem Scale (1, 0), sem frames invisíveis.
    local btn = Instance.new("TextButton")
    btn.Name = "ArrowButton"
    btn.Size = UDim2.fromOffset(20, 20)
    btn.BackgroundTransparency = 1
    btn.Text = ">"
    btn.TextColor3 = COLOR_IDLE
    btn.Font = FONT_MAIN
    btn.TextSize = 16
    btn.AutoButtonColor = false
    
    local toggledEvent = Instance.new("BindableEvent")
    maid:GiveTask(toggledEvent)
    
    local self = {}
    self.Instance = btn
    self.State = false
    self.Toggled = toggledEvent.Event
    
    local function animate()
        TweenService:Create(btn, TWEEN_INFO, {
            Rotation = self.State and 90 or 0,
            TextColor3 = self.State and COLOR_ACTIVE or COLOR_IDLE
        }):Play()
    end
    
    function self:SetState(state: boolean)
        if self.State == state then return end
        self.State = state
        animate()
    end
    
    maid:GiveTask(btn.MouseButton1Click:Connect(function()
        self:SetState(not self.State)
        toggledEvent:Fire(self.State)
    end))
    
    function self:Destroy()
        maid:Destroy()
    end
    
    maid:GiveTask(btn)
    
    return self :: ArrowUI
end

return ArrowFactory
