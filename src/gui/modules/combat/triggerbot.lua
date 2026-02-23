--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local ToggleButton = Import("gui/modules/combat/components/togglebutton")
local Arrow = Import("gui/modules/combat/components/arrow")
local GlowBar = Import("gui/modules/combat/components/glowbar")
local Sidebar = Import("gui/modules/combat/components/sidebar")
local KeybindSection = Import("gui/modules/combat/sections/shared/keybind")

export type TriggerBotUI = {
    Instance: Frame,
    Destroy: (self: TriggerBotUI) -> ()
}

local TriggerBotFactory = {}

local COLOR_WHITE = Color3.fromHex("B4B4B4")
local FONT_MAIN = Enum.Font.GothamBold

function TriggerBotFactory.new(): TriggerBotUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "TriggerBotContainer"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1 
    container.AutomaticSize = Enum.AutomaticSize.Y

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundTransparency = 1
    header.Parent = container

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.fromOffset(0, 50)
    title.AutomaticSize = Enum.AutomaticSize.X
    title.Position = UDim2.fromOffset(20, 0)
    title.BackgroundTransparency = 1
    title.Text = "Trigger Bot"
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
    glowBar.Instance.Size = UDim2.fromScale(1, 1)
    glowBar.Instance.Parent = glowWrapper
    maid:GiveTask(glowBar)

    local function updateGlowBar()
        if header.AbsoluteSize.X == 0 then return end
        local startX = (title.AbsolutePosition.X + title.AbsoluteSize.X - header.AbsolutePosition.X) + 5
        local endX = (controls.AbsolutePosition.X - header.AbsolutePosition.X) - 5
        local width = math.max(0, endX - startX)
        glowWrapper.Position = UDim2.new(0, startX, 0.5, 0)
        glowWrapper.Size = UDim2.fromOffset(width, 32)
    end

    maid:GiveTask(title:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGlowBar))
    maid:GiveTask(controls:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateGlowBar))
    task.defer(updateGlowBar)

    local subFrame = Instance.new("Frame")
    subFrame.Name = "SubFrame"
    subFrame.Size = UDim2.new(1, 0, 0, 100)
    subFrame.BackgroundTransparency = 1
    subFrame.Parent = container

    local vLine = Sidebar.createVertical()
    vLine.Instance.Parent = subFrame
    maid:GiveTask(vLine)

    local rightContent = Instance.new("Frame")
    rightContent.Name = "RightContent"
    rightContent.Size = UDim2.new(1, -2, 1, 0)
    rightContent.Position = UDim2.fromOffset(2, 0)
    rightContent.BackgroundTransparency = 1
    rightContent.Parent = subFrame
    
    local rightLayout = Instance.new("UIListLayout")
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Parent = rightContent

    local keySec = KeybindSection.new(1)
    keySec.Instance.Parent = rightContent
    maid:GiveTask(keySec)

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

return TriggerBotFactory
