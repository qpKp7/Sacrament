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

export type AimlockUI = {
    Instance: Frame,
    Destroy: (self: AimlockUI) -> ()
}

local AimlockFactory = {}

local COLOR_BG = Color3.fromRGB(14, 14, 14)
local COLOR_WHITE = Color3.fromHex("FFFFFF")
local FONT_MAIN = Enum.Font.GothamBold

function AimlockFactory.new(): AimlockUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "AimlockContainer"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundColor3 = COLOR_BG
    container.BorderSizePixel = 0
    container.AutomaticSize = Enum.AutomaticSize.Y

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.FillDirection = Enum.FillDirection.Horizontal
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Parent = container

    -- HEADER AREA (Left Side)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(0, 280, 0, 50)
    header.BackgroundColor3 = COLOR_BG
    header.BorderSizePixel = 0
    header.LayoutOrder = 1
    header.Parent = container

    local headerLayout = Instance.new("UIListLayout")
    headerLayout.FillDirection = Enum.FillDirection.Horizontal
    headerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    headerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    headerLayout.Padding = UDim.new(0, 15)
    headerLayout.Parent = header

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0, 80, 0, 30)
    title.BackgroundColor3 = COLOR_BG
    title.BorderSizePixel = 0
    title.Text = "Aimlock"
    title.TextColor3 = COLOR_WHITE
    title.Font = FONT_MAIN
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.LayoutOrder = 1
    title.Parent = header

    local glowBar = GlowBar.new()
    glowBar.Instance.LayoutOrder = 2
    glowBar.Instance.Parent = header
    maid:GiveTask(glowBar)

    local toggleBtn = ToggleButton.new()
    toggleBtn.Instance.LayoutOrder = 3
    toggleBtn.Instance.Parent = header
    maid:GiveTask(toggleBtn)

    local arrow = Arrow.new()
    arrow.Instance.LayoutOrder = 4
    arrow.Instance.Parent = header
    maid:GiveTask(arrow)

    -- SUBFRAME AREA (Right Side)
    local subFrame = Instance.new("Frame")
    subFrame.Name = "SubFrame"
    subFrame.Size = UDim2.new(1, -280, 0, 0)
    subFrame.BackgroundColor3 = COLOR_BG
    subFrame.BorderSizePixel = 0
    subFrame.AutomaticSize = Enum.AutomaticSize.Y
    subFrame.Visible = false
    subFrame.LayoutOrder = 2
    subFrame.Parent = container

    local vLine = Sidebar.createVertical()
    vLine.Instance.Position = UDim2.new(0, 0, 0, 0)
    vLine.Instance.Size = UDim2.new(0, 2, 1, 0)
    vLine.Instance.Parent = subFrame
    maid:GiveTask(vLine)

    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -2, 0, 0)
    contentArea.Position = UDim2.new(0, 2, 0, 0)
    contentArea.BackgroundColor3 = COLOR_BG
    contentArea.BorderSizePixel = 0
    contentArea.AutomaticSize = Enum.AutomaticSize.Y
    contentArea.Parent = subFrame

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 15)
    contentLayout.Parent = contentArea

    local keySec = KeybindSection.new(1)
    keySec.Instance.Parent = contentArea
    maid:GiveTask(keySec)

    local hLine = Sidebar.createHorizontal(2)
    hLine.Instance.Parent = contentArea
    maid:GiveTask(hLine)

    local predSec = PredictSection.new(3)
    predSec.Instance.Parent = contentArea
    maid:GiveTask(predSec)

    local smoothSec = SmoothnessSection.new(4)
    smoothSec.Instance.Parent = contentArea
    maid:GiveTask(smoothSec)

    -- LOGIC BINDINGS
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
