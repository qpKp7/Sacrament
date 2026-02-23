--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local ToggleButton = Import("gui/modules/combat/components/togglebutton")
local Arrow = Import("gui/modules/combat/components/arrow")
local GlowBar = Import("gui/modules/combat/components/glowbar")
local Sidebar = Import("gui/modules/combat/components/sidebar")

local KeybindSection = Import("gui/modules/combat/sections/shared/keybind")
local KeyHoldSection = Import("gui/modules/combat/sections/shared/keyhold")
local PredictSection = Import("gui/modules/combat/sections/shared/predict")
local HitChanceSection = Import("gui/modules/combat/sections/silentaim/hitchance")
local MarkStyleSection = Import("gui/modules/combat/sections/silentaim/markstyle")
local FovLimitSection = Import("gui/modules/combat/sections/silentaim/fovlimit")
local AimPartSection = Import("gui/modules/combat/sections/shared/aimpart")
local WallCheckSection = Import("gui/modules/combat/sections/shared/wallcheck")
local KnockCheckSection = Import("gui/modules/combat/sections/shared/knockcheck")

export type SilentAimUI = {
    Instance: Frame,
    Destroy: (self: SilentAimUI) -> ()
}

local SilentAimFactory = {}

local COLOR_WHITE = Color3.fromHex("B4B4B4")
local FONT_MAIN = Enum.Font.GothamBold

function SilentAimFactory.new(): SilentAimUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "SilentAimContainer"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1 
    container.BorderSizePixel = 0
    container.AutomaticSize = Enum.AutomaticSize.Y

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.FillDirection = Enum.FillDirection.Horizontal
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Parent = container

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(0, 280, 0, 50)
    header.BackgroundTransparency = 1
    header.BorderSizePixel = 0
    header.LayoutOrder = 1
    header.ClipsDescendants = true
    header.Parent = container

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.fromOffset(0, 50)
    title.AutomaticSize = Enum.AutomaticSize.X
    title.Position = UDim2.fromOffset(20, 0)
    title.BackgroundTransparency = 1
    title.Text = "Silent Aim"
    title.TextColor3 = COLOR_WHITE
    title.Font = FONT_MAIN
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local controls = Instance.new("Frame")
    controls.Name = "Controls"
    controls.Size = UDim2.fromOffset(0, 50)
    controls.AutomaticSize = Enum.AutomaticSize.X
    controls.Position = UDim2.fromScale(1, 0)
    controls.AnchorPoint = Vector2.new(1, 0)
    controls.BackgroundTransparency = 1
    controls.Parent = header

    local ctrlLayout = Instance.new("UIListLayout")
    ctrlLayout.FillDirection = Enum.FillDirection.Horizontal
    ctrlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ctrlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ctrlLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ctrlLayout.Padding = UDim.new(0, 15)
    ctrlLayout.Parent = controls

    local ctrlPadding = Instance.new("UIPadding")
    ctrlPadding.PaddingRight = UDim.new(0, 20)
    ctrlPadding.Parent = controls

    local toggleBtn = ToggleButton.new()
    toggleBtn.Instance.LayoutOrder = 1
    toggleBtn.Instance.Parent = controls
    maid:GiveTask(toggleBtn)

    local arrow = Arrow.new()
    arrow.Instance.LayoutOrder = 2
    arrow.Instance.Parent = controls
    maid:GiveTask(arrow)

    local glowWrapper = Instance.new("Frame")
    glowWrapper.Name = "GlowWrapper"
    glowWrapper.AnchorPoint = Vector2.new(0, 0.5)
    glowWrapper.BackgroundTransparency = 1
    glowWrapper.Parent = header

    local glowBar = GlowBar.new()
    glowBar.Instance.AnchorPoint = Vector2.new(0.5, 0.5)
    glowBar.Instance.Position = UDim2.fromScale(0.5, 0.5)
    glowBar.Instance.AutomaticSize = Enum.AutomaticSize.None
    glowBar.Instance.Size = UDim2.fromScale(1, 1)
    glowBar.Instance.Parent = glowWrapper

    do
        local c1 = glowBar.Instance:FindFirstChildWhichIsA("UISizeConstraint", true)
        if c1 then c1:Destroy() end
        local c2 = glowBar.Instance:FindFirstChildWhichIsA("UIAspectRatioConstraint", true)
        if c2 then c2:Destroy() end
    end
    maid:GiveTask(glowBar)

    local function updateGlowBar()
        if header.AbsoluteSize.X == 0 then return end

        local titleRightAbsolute = title.AbsolutePosition.X + title.AbsoluteSize.X
        local controlsLeftAbsolute = controls.AbsolutePosition.X

        local startX = (titleRightAbsolute - header.AbsolutePosition.X) + 5
        local endX = (controlsLeftAbsolute - header.AbsolutePosition.X) - 5

        local width = math.max(0, endX - startX)

        glowWrapper.Position = UDim2.new(0, startX, 0.5, 0)
        glowWrapper.Size = UDim2.fromOffset(width, 32)
    end

    maid:GiveTask(title:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGlowBar))
    maid:GiveTask(title:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateGlowBar))
    maid:GiveTask(controls:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGlowBar))
    maid:GiveTask(controls:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateGlowBar))
    maid:GiveTask(header:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGlowBar))
    maid:GiveTask(header:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateGlowBar))
    
    task.spawn(function()
        for _ = 1, 10 do
            updateGlowBar()
            task.wait(0.05)
        end
    end)

    local subFrame = Instance.new("Frame")
    subFrame.Name = "SubFrame"
    subFrame.Size = UDim2.fromScale(1, 1)
    subFrame.BackgroundTransparency = 1
    subFrame.BorderSizePixel = 0
    subFrame.Visible = false
    subFrame.LayoutOrder = 2
    subFrame.Parent = container

    local vLine = Sidebar.createVertical()
    vLine.Instance.Size = UDim2.new(0, 2, 1, 0)
    vLine.Instance.Position = UDim2.fromScale(0, 0)
    vLine.Instance.Parent = subFrame
    maid:GiveTask(vLine)

    local rightContent = Instance.new("Frame")
    rightContent.Name = "RightContent"
    rightContent.Size = UDim2.new(1, -2, 1, 0)
    rightContent.Position = UDim2.fromOffset(2, 0)
    rightContent.BackgroundTransparency = 1
    rightContent.BorderSizePixel = 0
    rightContent.Parent = subFrame

    local rightLayout = Instance.new("UIListLayout")
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Parent = rightContent

    local keySec = KeybindSection.new(1)
    keySec.Instance.Parent = rightContent
    maid:GiveTask(keySec)

    local hLine = Sidebar.createHorizontal(2)
    hLine.Instance.Parent = rightContent
    maid:GiveTask(hLine)

    local inputsScroll = Instance.new("ScrollingFrame")
    inputsScroll.Name = "InputsScroll"
    inputsScroll.Size = UDim2.new(1, 0, 1, -57)
    inputsScroll.BackgroundTransparency = 1
    inputsScroll.BorderSizePixel = 0
    inputsScroll.ScrollBarThickness = 0
    inputsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    inputsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    inputsScroll.LayoutOrder = 3
    inputsScroll.Parent = rightContent

    local inputsLayout = Instance.new("UIListLayout")
    inputsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    inputsLayout.Padding = UDim.new(0, 15)
    inputsLayout.Parent = inputsScroll

    local inputsPadding = Instance.new("UIPadding")
    inputsPadding.PaddingTop = UDim.new(0, 20)
    inputsPadding.PaddingBottom = UDim.new(0, 20)
    inputsPadding.PaddingRight = UDim.new(0, 25)
    inputsPadding.Parent = inputsScroll

    local keyHoldSec = KeyHoldSection.new(1)
    keyHoldSec.Instance.Parent = inputsScroll
    maid:GiveTask(keyHoldSec)

    local predSec = PredictSection.new(2)
    predSec.Instance.Parent = inputsScroll
    maid:GiveTask(predSec)

    local hitChanceSec = HitChanceSection.new(3)
    hitChanceSec.Instance.Parent = inputsScroll
    maid:GiveTask(hitChanceSec)

    local markStyleSec = MarkStyleSection.new(4)
    markStyleSec.Instance.Parent = inputsScroll
    maid:GiveTask(markStyleSec)

    local fovLimitSec = FovLimitSection.new(5)
    fovLimitSec.Instance.Parent = inputsScroll
    maid:GiveTask(fovLimitSec)

    local aimPartSec = AimPartSection.new(6)
    aimPartSec.Instance.Parent = inputsScroll
    maid:GiveTask(aimPartSec)

    local wallCheckSec = WallCheckSection.new(7)
    wallCheckSec.Instance.Parent = inputsScroll
    maid:GiveTask(wallCheckSec)

    local knockCheckSec = KnockCheckSection.new(8)
    knockCheckSec.Instance.Parent = inputsScroll
    maid:GiveTask(knockCheckSec)

    maid:GiveTask(toggleBtn.Toggled:Connect(function(state)
        glowBar:SetState(state)
    end))

    maid:GiveTask(container)
    
    local self = {}
    self.Instance = container

    function self:Destroy()
        maid:Destroy()
    end

    return self
end

return SilentAimFactory
