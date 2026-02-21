--!strict
local TweenService = game:GetService("TweenService")
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type GlowBar = {
    Instance: Frame,
    SetState: (self: GlowBar, state: boolean) -> (),
    Destroy: (self: GlowBar) -> ()
}

local GlowBarFactory = {}

local COLOR_OFF = Color3.fromHex("444444")
local COLOR_ON = Color3.fromHex("FF3333")

function GlowBarFactory.new(): GlowBar
    local maid = Maid.new()
    local tInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local container = Instance.new("Frame")
    container.Name = "GlowBarContainer"
    container.Size = UDim2.fromOffset(60, 30) -- Comprimento reduzido de 90 para 60 para economizar espaço
    container.BackgroundTransparency = 1

    local line = Instance.new("Frame")
    line.Name = "Line"
    line.Size = UDim2.new(1, -10, 0, 2) -- Reduzido o padding interno da linha
    line.Position = UDim2.fromScale(0.5, 0.5)
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BackgroundColor3 = COLOR_OFF
    line.BorderSizePixel = 0
    line.Parent = container

    local self = {}
    self.Instance = container

    function self:SetState(state: boolean)
        local targetColor = state and COLOR_ON or COLOR_OFF
        local tween = TweenService:Create(line, tInfo, {BackgroundColor3 = targetColor})
        tween:Play()
        maid:GiveTask(tween.Completed:Connect(function() tween:Destroy() end))
    end

    function self:Destroy()
        maid:Destroy()
    end

    return self
end

return GlowBarFactory
