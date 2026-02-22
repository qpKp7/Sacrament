--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local ToggleButton = Import("gui/modules/combat/components/togglebutton")
local Arrow = Import("gui/modules/combat/components/arrow")
local GlowBar = Import("gui/modules/combat/components/glowbar")
local Sidebar = Import("gui/modules/combat/components/sidebar")

local KeybindSection = Import("gui/modules/combat/sections/shared/keybind")
local PredictSection = Import("gui/modules/combat/sections/shared/predict")
local HitChanceSection = Import("gui/modules/combat/sections/silentaim/hitchance")
local FovLimitSection = Import("gui/modules/combat/sections/silentaim/fovlimit")
local AimPartSection = Import("gui/modules/combat/sections/shared/aimpart")
local MarkStyleSection = Import("gui/modules/combat/sections/silentaim/markstyle")
local WallCheckSection = Import("gui/modules/combat/sections/shared/wallcheck")
local KnockCheckSection = Import("gui/modules/combat/sections/shared/knockcheck")
local LockAfterMarkSection = Import("gui/modules/combat/sections/silentaim/lockaftermark")

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

    --------------------------------------------------
    -- HEADER
    --------------------------------------------------

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(0, 280, 0, 50)
    header.BackgroundTransparency = 1
    header.LayoutOrder = 1
    header.Parent = container

    local title = Instance.new("TextLabel")
    title.Size = UDim2.fromOffset(85, 50)
    title.Position = UDim2.fromOffset(20, 0)
    title.BackgroundTransparency = 1
    title.Text = "Silent Aim"
    title.TextColor3 = COLOR_WHITE
    title.Font = FONT_MAIN
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local controls = Instance.new("Frame")
    controls.Name = "Controls"
    controls.Size = UDim2.fromOffset(105, 50)
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

    local toggleBtn = ToggleButton.new()
    toggleBtn.Instance.Parent = controls
    maid:GiveTask(toggleBtn)

    local arrow = Arrow.new()
    arrow.Instance.Parent = controls
    maid:GiveTask(arrow)

    local glowBar = GlowBar.new()
    glowBar.Instance.Parent = header
    maid:GiveTask(glowBar)

    --------------------------------------------------
    -- SUBFRAME
    --------------------------------------------------

    local subFrame = Instance.new("Frame")
    subFrame.Name = "SubFrame"
    subFrame.Size = UDim2.new(1, -280, 0, 350)
    subFrame.BackgroundTransparency = 1
    subFrame.BorderSizePixel = 0
    subFrame.Visible = false
    subFrame.LayoutOrder = 2
    subFrame.Parent = container

    local vLine = Sidebar.createVertical()
    vLine.Instance.Parent = subFrame
    maid:GiveTask(vLine)

    --------------------------------------------------
    -- FIXED TOP
    --------------------------------------------------

    local fixedTop = Instance.new("Frame")
    fixedTop.Name = "FixedTop"
    fixedTop.Size = UDim2.new(1, -2, 0, 0)
    fixedTop.Position = UDim2.fromOffset(2, 0)
    fixedTop.BackgroundTransparency = 1
    fixedTop.AutomaticSize = Enum.AutomaticSize.Y
    fixedTop.Parent = subFrame

    local fixedLayout = Instance.new("UIListLayout")
    fixedLayout.Parent = fixedTop

    local keySec = KeybindSection.new(1)
    keySec.Instance.Parent = fixedTop
    maid:GiveTask(keySec)

    local hLine = Sidebar.createHorizontal(2)
    hLine.Instance.Parent = fixedTop
    maid:GiveTask(hLine)

    --------------------------------------------------
    -- SCROLL AREA (ONLY INPUTS)
    --------------------------------------------------

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "ScrollArea"
    scroll.Position = UDim2.new(0, 2, 0, 0)
    scroll.Size = UDim2.new(1, -2, 1, -fixedTop.AbsoluteSize.Y)
    scroll.CanvasSize = UDim2.fromOffset(0, 0)
    scroll.ScrollBarThickness = 0
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.Parent = subFrame

    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.Padding = UDim.new(0, 15)
    scrollLayout.Parent = scroll

    local scrollPadding = Instance.new("UIPadding")
    scrollPadding.PaddingTop = UDim.new(0, 20)
    scrollPadding.PaddingBottom = UDim.new(0, 20)
    scrollPadding.PaddingRight = UDim.new(0, 25)
    scrollPadding.Parent = scroll

    local function updateCanvas()
        scroll.CanvasSize = UDim2.fromOffset(0, scrollLayout.AbsoluteContentSize.Y)
    end

    scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

    local sections = {
        PredictSection.new(1),
        HitChanceSection.new(2),
        FovLimitSection.new(3),
        AimPartSection.new(4),
        MarkStyleSection.new(5),
        WallCheckSection.new(6),
        KnockCheckSection.new(7),
        LockAfterMarkSection.new(8),
    }

    for _, section in ipairs(sections) do
        section.Instance.Parent = scroll
        maid:GiveTask(section)
    end

    maid:GiveTask(toggleBtn.Toggled:Connect(function(state)
        glowBar:SetState(state)
    end))

    maid:GiveTask(arrow.Toggled:Connect(function(isExpanded)
        subFrame.Visible = isExpanded
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
