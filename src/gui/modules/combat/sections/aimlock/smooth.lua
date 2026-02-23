--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local ToggleButton = Import("gui/modules/combat/components/togglebutton")

export type SmoothSection = {
    Instance: Frame,
    Destroy: (self: SmoothSection) -> ()
}

local SmoothFactory = {}

local COLOR_WHITE = Color3.fromHex("B4B4B4")
local FONT_MAIN = Enum.Font.GothamBold

function SmoothFactory.new(layoutOrder: number): SmoothSection
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "SmoothContainer"
    container.Size = UDim2.new(1, 0, 0, 32)
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -80, 1, 0) 
    title.Position = UDim2.fromOffset(20, 0)
    title.BackgroundTransparency = 1
    title.Text = "Smooth"
    title.TextColor3 = COLOR_WHITE
    title.Font = FONT_MAIN
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = container

    local toggleBtn = ToggleButton.new()
    toggleBtn.Instance.AnchorPoint = Vector2.new(1, 0.5)
    toggleBtn.Instance.Position = UDim2.new(1, 0, 0.5, 0)
    toggleBtn.Instance.Parent = container
    maid:GiveTask(toggleBtn)

    maid:GiveTask(container)
    
    local self = {}
    self.Instance = container

    function self:Destroy()
        maid:Destroy()
    end

    return self
end

return SmoothFactory
