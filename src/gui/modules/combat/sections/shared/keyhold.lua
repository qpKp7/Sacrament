--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")
local ToggleButton = Import("gui/modules/combat/components/togglebutton")

export type KeyHoldSection = {
    Instance: Frame,
    GetState: (self: KeyHoldSection) -> boolean,
    Destroy: (self: KeyHoldSection) -> ()
}

local KeyHoldFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local COLOR_SUB = Color3.fromRGB(150, 150, 150)
local FONT_MAIN = Enum.Font.GothamBold
local FONT_SUB = Enum.Font.Gotham

function KeyHoldFactory.new(layoutOrder: number): KeyHoldSection
    local maid = Maid.new()
    local state = false

    local row = Instance.new("Frame")
    row.Name = "KeyHoldRow"
    row.Size = UDim2.new(1, 0, 0, 45)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.LayoutOrder = layoutOrder

    local rowLayout = Instance.new("UIListLayout")
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rowLayout.Parent = row

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = row

    local textCont = Instance.new("Frame")
    textCont.Size = UDim2.new(1, -45, 1, 0)
    textCont.BackgroundTransparency = 1
    textCont.BorderSizePixel = 0
    textCont.Parent = row

    local textLayout = Instance.new("UIListLayout")
    textLayout.FillDirection = Enum.FillDirection.Vertical
    textLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    textLayout.SortOrder = Enum.SortOrder.LayoutOrder
    textLayout.Padding = UDim.new(0, 2)
    textLayout.Parent = textCont

    local lblTitle = Instance.new("TextLabel")
    lblTitle.Size = UDim2.new(1, 0, 0, 14)
    lblTitle.BackgroundTransparency = 1
    lblTitle.BorderSizePixel = 0
    lblTitle.Text = "Key Hold"
    lblTitle.TextColor3 = COLOR_LABEL
    lblTitle.Font = FONT_MAIN
    lblTitle.TextSize = 14
    lblTitle.TextXAlignment = Enum.TextXAlignment.Left
    lblTitle.Parent = textCont

    local lblSub = Instance.new("TextLabel")
    lblSub.Size = UDim2.new(1, 0, 0, 11)
    lblSub.BackgroundTransparency = 1
    lblSub.BorderSizePixel = 0
    lblSub.Text = "Only activate while holding key (no persistent lock)"
    lblSub.TextColor3 = COLOR_SUB
    lblSub.Font = FONT_SUB
    lblSub.TextSize = 11
    lblSub.TextXAlignment = Enum.TextXAlignment.Left
    lblSub.Parent = textCont

    local toggleCont = Instance.new("Frame")
    toggleCont.Size = UDim2.new(0, 40, 0, 32)
    toggleCont.BackgroundTransparency = 1
    toggleCont.Parent = row

    local toggle = ToggleButton.new()
    toggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
    toggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
    toggle.Instance.Parent = toggleCont
    maid:GiveTask(toggle)

    maid:GiveTask(toggle.Toggled:Connect(function(newState)
        state = newState
    end))

    maid:GiveTask(row)

    local self = {}
    self.Instance = row

    function self:GetState()
        return state
    end

    function self:Destroy()
        maid:Destroy()
    end

    return self
end

return KeyHoldFactory
