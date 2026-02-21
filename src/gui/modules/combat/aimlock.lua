--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local ToggleButton = Import("gui/modules/combat/components/togglebutton")
local Arrow = Import("gui/modules/combat/components/arrow")
local GlowBar = Import("gui/modules/combat/components/glowbar")
local Sidebar = Import("gui/modules/combat/components/sidebar")

local KeybindSection = Import("gui/modules/combat/sections/keybind")
local PredictSection = Import("gui/modules/combat/sections/predict")
local SmoothnessSection = Import("gui/modules/combat/sections/smoothness")
local AimPartSection = Import("gui/modules/combat/sections/aimpart")
local WallCheckSection = Import("gui/modules/combat/sections/wallcheck")
local KnockCheckSection = Import("gui/modules/combat/sections/knockcheck")

export type AimlockUI = {
    Instance: Frame,
    Destroy: (self: AimlockUI) -> ()
}

local AimlockFactory = {}

local COLOR_WHITE = Color3.fromHex("FFFFFF")
local FONT_MAIN = Enum.Font.GothamBold

function AimlockFactory.new(): AimlockUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "AimlockContainer"
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
    header.Parent = container

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.fromOffset(70, 50)
    title.Position = UDim2.fromOffset(20, 0)
    title.BackgroundTransparency = 1
    title.Text = "Aimlock"
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
    glowWrapper.Size = UDim2.fromOffset(65, 50)
    glowWrapper.Position = UDim2.fromOffset(105, 0)
    glowWrapper.BackgroundTransparency = 1
    glowWrapper.Parent = header

    local glowBar = GlowBar.new()
    glowBar.Instance.Position = UDim2.fromScale(0.5, 0.5)
    glowBar.Instance.AnchorPoint = Vector2.new(0.5, 0.5)
    glowBar.Instance.Parent = glowWrapper
    maid:GiveTask(glowBar)

    local subFrame = Instance.new("Frame")
    subFrame.Name = "SubFrame"
    subFrame.Size = UDim2.new(1, -280, 0, 0)
    subFrame.BackgroundTransparency = 1
    subFrame.BorderSizePixel = 0
    subFrame.AutomaticSize = Enum.AutomaticSize.Y
    subFrame.Visible = false
    subFrame.LayoutOrder = 2
    subFrame.Parent = container

    local vLine = Sidebar.createVertical()
    vLine.Instance.Parent = subFrame
    maid:GiveTask(vLine)

    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -2, 0, 0)
    contentArea.Position = UDim2.fromOffset(2, 0)
    contentArea.BackgroundTransparency = 1
    contentArea.AutomaticSize = Enum.AutomaticSize.Y
    contentArea.Parent = subFrame

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 0)
    contentLayout.Parent = contentArea

    local keySec = KeybindSection.new(1)
    keySec.Instance.Parent = contentArea
    maid:GiveTask(keySec)

    local hLine = Sidebar.createHorizontal(2)
    hLine.Instance.Parent = contentArea
    maid:GiveTask(hLine)

    local inputsContainer = Instance.new("Frame")
    inputsContainer.Name = "InputsContainer"
    inputsContainer.Size = UDim2.new(1, 0, 0, 0)
    inputsContainer.BackgroundTransparency = 1
    inputsContainer.AutomaticSize = Enum.AutomaticSize.Y
    inputsContainer.LayoutOrder = 3
    inputsContainer.Parent = contentArea

    local inputsLayout = Instance.new("UIListLayout")
    inputsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    inputsLayout.Padding = UDim.new(0, 10)
    inputsLayout.Parent = inputsContainer

    local inputsPadding = Instance.new("UIPadding")
    inputsPadding.PaddingTop = UDim.new(0, 15)
    inputsPadding.PaddingBottom = UDim.new(0, 15)
    inputsPadding.PaddingRight = UDim.new(0, 25)
    inputsPadding.Parent = inputsContainer

    local predSec = PredictSection.new(1)
    predSec.Instance.Parent = inputsContainer
    maid:GiveTask(predSec)

    local smoothSec = SmoothnessSection.new(2)
    smoothSec.Instance.Parent = inputsContainer
    maid:GiveTask(smoothSec)

    local aimPartSec = AimPartSection.new(3)
    aimPartSec.Instance.Parent = inputsContainer
    maid:GiveTask(aimPartSec)

    local wallCheckSec = WallCheckSection.new(4)
    wallCheckSec.Instance.Parent = inputsContainer
    maid:GiveTask(wallCheckSec)

    local knockCheckSec = KnockCheckSection.new(5)
    knockCheckSec.Instance.Parent = inputsContainer
    maid:GiveTask(knockCheckSec)

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

return AimlockFactory
