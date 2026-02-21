--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")
local ToggleButton = Import("gui/modules/combat/components/togglebutton")

export type KnockCheckSection = {
    Instance: Frame,
    Destroy: (self: KnockCheckSection) -> ()
}

local KnockCheckFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local COLOR_DESC = Color3.fromRGB(130, 130, 130)
local FONT_MAIN = Enum.Font.GothamBold
local FONT_DESC = Enum.Font.Gotham

function KnockCheckFactory.new(layoutOrder: number): KnockCheckSection
    local maid = Maid.new()

    local row = Instance.new("Frame")
    row.Name = "KnockCheckRow"
    row.Size = UDim2.new(1, 0, 0, 45)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.LayoutOrder = layoutOrder

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 20)
    pad.Parent = row

    local textCont = Instance.new("Frame")
    textCont.Size = UDim2.new(0.7, 0, 1, 0)
    textCont.BackgroundTransparency = 1
    textCont.Parent = row

    local textLayout = Instance.new("UIListLayout")
    textLayout.FillDirection = Enum.FillDirection.Vertical
    textLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    textLayout.SortOrder = Enum.SortOrder.LayoutOrder
    textLayout.Padding = UDim.new(0, 2)
    textLayout.Parent = textCont

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.BorderSizePixel = 0
    lbl.Text = "Knock Check"
    lbl.TextColor3 = COLOR_LABEL
    lbl.Font = FONT_MAIN
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = 1
    lbl.Parent = textCont

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, 0, 0, 12)
    desc.BackgroundTransparency = 1
    desc.BorderSizePixel = 0
    desc.Text = "Ignore knocked down players"
    desc.TextColor3 = COLOR_DESC
    desc.Font = FONT_DESC
    desc.TextSize = 11
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.LayoutOrder = 2
    desc.Parent = textCont

    local toggle = ToggleButton.new()
    toggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
    toggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
    toggle.Instance.Parent = row
    maid:GiveTask(toggle)

    maid:GiveTask(row)

    local self = {}
    self.Instance = row

    function self:Destroy()
        maid:Destroy()
    end

    return self
end

return KnockCheckFactory
