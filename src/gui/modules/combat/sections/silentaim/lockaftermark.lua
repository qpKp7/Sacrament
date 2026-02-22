--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")
local ToggleButton = Import("gui/modules/combat/components/togglebutton")

export type LockAfterMarkSection = {
    Instance: Frame,
    Destroy: (self: LockAfterMarkSection) -> ()
}

local LockAfterMarkFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local FONT_MAIN = Enum.Font.GothamBold

function LockAfterMarkFactory.new(layoutOrder: number): LockAfterMarkSection
    local maid = Maid.new()

    local row = Instance.new("Frame")
    row.Name = "LockAfterMarkRow"
    row.Size = UDim2.new(1, 0, 0, 40)
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

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -45, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.BorderSizePixel = 0
    lbl.Text = "Keep silent aim after marking until new target or disable"
    lbl.TextColor3 = COLOR_LABEL
    lbl.Font = FONT_MAIN
    lbl.TextSize = 11
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local toggleCont = Instance.new("Frame")
    toggleCont.Size = UDim2.new(0, 40, 0, 32)
    toggleCont.BackgroundTransparency = 1
    toggleCont.Parent = row

    local toggle = ToggleButton.new()
    toggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
    toggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
    toggle.Instance.Parent = toggleCont
    maid:GiveTask(toggle)

    maid:GiveTask(row)

    local self = {}
    self.Instance = row

    function self:Destroy()
        maid:Destroy()
    end

    return self
end

return LockAfterMarkFactory
