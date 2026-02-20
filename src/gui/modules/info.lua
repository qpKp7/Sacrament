--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type InfoModule = {
    Instance: Frame,
    Destroy: (self: InfoModule) -> ()
}

local InfoModuleFactory = {}

local function createTextLabel(name: string, text: string, size: number, font: Enum.Font, color: string): TextLabel
    local lbl = Instance.new("TextLabel")
    lbl.Name = name
    lbl.Size = UDim2.new(0.9, 0, 0, size + 10)
    lbl.BackgroundTransparency = 1
    lbl.RichText = true
    lbl.Text = text
    lbl.TextColor3 = Color3.fromHex(color)
    lbl.Font = font
    lbl.TextSize = size
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    return lbl
end

function InfoModuleFactory.new(): InfoModule
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "InfoContainer"
    container.Size = UDim2.fromScale(1, 1)
    container.BackgroundColor3 = Color3.fromHex("#0B0A0A")
    container.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = container

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("#2E1111")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("#0B0A0A"))
    })
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 0.4)
    })
    gradient.Rotation = 90
    gradient.Parent = container

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 10)
    layout.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 20)
    padding.PaddingBottom = UDim.new(0, 20)
    padding.PaddingLeft = UDim.new(0, 20)
    padding.PaddingRight = UDim.new(0, 20)
    padding.Parent = container

    local mainColor = "#7E6262"
    local highlightColor = "#680303"
    local footerColor = "#2C0000"

    local line1 = createTextLabel("Line1", "This exploit was forged to rise above all players.", 20, Enum.Font.Garamond, mainColor)
    line1.LayoutOrder = 1
    line1.Parent = container

    local line2Text = string.format("Those who use <font color=\"%s\">Sacrament</font> are not mere cheaters – they are <font color=\"%s\">gods</font>.", highlightColor, highlightColor)
    local line2 = createTextLabel("Line2", line2Text, 20, Enum.Font.Garamond, mainColor)
    line2.LayoutOrder = 2
    line2.Parent = container

    local line3 = createTextLabel("Line3", "This cult bears no responsibility for the unholy power unleashed by this tool.", 20, Enum.Font.Garamond, mainColor)
    line3.LayoutOrder = 3
    line3.Parent = container

    local spacer1 = Instance.new("Frame")
    spacer1.Name = "Spacer1"
    spacer1.Size = UDim2.new(1, 0, 0, 15)
    spacer1.BackgroundTransparency = 1
    spacer1.LayoutOrder = 4
    spacer1.Parent = container

    local invokeText = string.format("* You do not inject Sacrament,\n* You <font color=\"%s\">invoke</font> it.", highlightColor)
    local centralBlock = createTextLabel("CentralBlock", invokeText, 24, Enum.Font.Garamond, mainColor)
    centralBlock.Size = UDim2.new(0.9, 0, 0, 60)
    centralBlock.LayoutOrder = 5
    centralBlock.Parent = container

    local spacer2 = Instance.new("Frame")
    spacer2.Name = "Spacer2"
    spacer2.Size = UDim2.new(1, 0, 0, 30)
    spacer2.BackgroundTransparency = 1
    spacer2.LayoutOrder = 6
    spacer2.Parent = container

    local footer = createTextLabel("Footer", "Created by cardstolen", 16, Enum.Font.Fantasy, footerColor)
    footer.LayoutOrder = 7
    footer.Parent = container

    maid:GiveTask(container)

    local self = {}
    self.Instance = container

    function self:Destroy()
        maid:Destroy()
    end

    return self
end

return InfoModuleFactory
