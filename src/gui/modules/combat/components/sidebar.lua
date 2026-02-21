--!strict
local Import = (_G :: any).SacramentImport

export type Sidebar = {
    Instance: Frame,
    Destroy: (self: Sidebar) -> ()
}

local SidebarFactory = {}

local SIDEBAR_COLOR = Color3.fromHex("FF3333")

function SidebarFactory.createVertical(): Sidebar
    local line = Instance.new("Frame")
    line.Name = "VerticalSeparator"
    line.Size = UDim2.new(0, 2, 1, 0)
    line.Position = UDim2.fromScale(0, 0)
    line.BackgroundColor3 = SIDEBAR_COLOR
    line.BorderSizePixel = 0
    line.ZIndex = 2

    return {
        Instance = line,
        Destroy = function()
            line:Destroy()
        end
    }
end

function SidebarFactory.createHorizontal(order: number): Sidebar
    local line = Instance.new("Frame")
    line.Name = "HorizontalSeparator"
    line.Size = UDim2.new(1, 0, 0, 2)
    line.BackgroundColor3 = SIDEBAR_COLOR
    line.BorderSizePixel = 0
    line.LayoutOrder = order
    line.ZIndex = 2

    return {
        Instance = line,
        Destroy = function()
            line:Destroy()
        end
    }
end

return SidebarFactory
