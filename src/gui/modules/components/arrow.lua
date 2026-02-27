--!strict
local TweenService = game:GetService("TweenService")

local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type ArrowUI = {
    Instance: Frame,
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
    
    -- Contêiner estrutural fixo de 30px (salva o UIListLayout sem esticar a hitbox)
    local container = Instance.new("Frame")
    container.Name = "ArrowContainer"
    container.Size = UDim2.new(0, 30, 1, 0)
    container.BackgroundTransparency = 1
    
    -- Botão real da seta com hitbox fisicamente cravada em 24x24 pixels
    local btn = Instance.new("TextButton")
    btn.Name = "ArrowButton"
    btn.Size = UDim2.fromOffset(24, 24)
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.Position = UDim2.fromScale(0.5, 0.5)
    btn.BackgroundTransparency = 1
    btn.Text = ">"
    btn.TextColor3 = COLOR_IDLE
    btn.Font = FONT_MAIN
    btn.TextSize = 16
    btn.AutoButtonColor = false
    btn.Parent = container
    
    local toggledEvent = Instance.new("BindableEvent")
    maid:GiveTask(toggledEvent)
    
    local self = {}
    self.Instance = container
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
    
    -- Apenas cliques cirúrgicos dentro dos 24x24 pixels disparam o evento
    maid:GiveTask(btn.MouseButton1Click:Connect(function()
        self:SetState(not self.State)
        toggledEvent:Fire(self.State)
    end))
    
    function self:Destroy()
        maid:Destroy()
    end
    
    maid:GiveTask(container)
    
    return self :: ArrowUI
end

return ArrowFactory
