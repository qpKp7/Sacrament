--!strict
local Import = (_G :: any).SacramentImport
local Constants = Import("config/constants")
local Colors = Import("themes/colors")

export type ContentArea = {
    Instance: Frame,
    Destroy: (self: ContentArea) -> ()
}

local ContentAreaModule = {}

function ContentAreaModule.new(): ContentArea
    local content = Instance.new("Frame")
    content.Name = "ContentRounded"
    content.Size = UDim2.new(1 - Constants.SIDEBAR_WIDTH, -2, 1, 0)
    content.Position = UDim2.new(Constants.SIDEBAR_WIDTH, 2, 0, 0)
    content.BackgroundColor3 = Colors.ContentBackground
    content.BorderSizePixel = 0
    content.Active = false

    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 18)
    contentCorner.Parent = content

    local leftStraightEdge = Instance.new("Frame")
    leftStraightEdge.Name = "LeftStraightEdge"
    leftStraightEdge.Size = UDim2.new(0, 18, 1, 0)
    leftStraightEdge.Position = UDim2.new(0, 0, 0, 0)
    leftStraightEdge.BackgroundColor3 = Colors.ContentBackground
    leftStraightEdge.BorderSizePixel = 0
    leftStraightEdge.Active = false
    leftStraightEdge.Parent = content

    local self = {}
    self.Instance = content

    function self:Destroy()
        content:Destroy()
    end

    return self
end

return ContentAreaModule
