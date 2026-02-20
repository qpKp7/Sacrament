--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type InfoModule = {
    Instance: Frame,
    Destroy: (self: InfoModule) -> ()
}

local InfoModuleFactory = {}

local function createTextLabel(name: string, text: string, size: number, fontFace: Font, hexColorNoHash: string): TextLabel
    local lbl = Instance.new("TextLabel")
    lbl.Name = name
    lbl.Size = UDim2.new(1, 0, 0, size + 15)
    lbl.BackgroundTransparency = 1
    lbl.RichText = true
    lbl.Text = text
    lbl.TextColor3 = Color3.fromHex(hexColorNoHash)
    lbl.FontFace = fontFace
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
    container.BackgroundColor3 = Color3.fromHex("0B0A0A")
    container.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 18)
    corner.Parent = container

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("2E1111")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("0B0A0A"))
    })
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 0.4)
    })
    gradient.Rotation = 90
    gradient.Parent = container

    local mainLayout = Instance.new("Frame")
    mainLayout.Name = "MainLayout"
    mainLayout.Size = UDim2.fromScale(1, 1)
    mainLayout.BackgroundTransparency = 1
    mainLayout.Parent = container

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = mainLayout

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 15)
    padding.Parent = mainLayout

    local mainColorHex = "7E6262"
    local highlightColorHex = "680303"
    local footerColorHex = "3D0000"
    local highlightRich = "#" .. highlightColorHex

    local mainFont = Font.fromName("Garamond", Enum.FontWeight.Regular, Enum.FontStyle.Italic)
    local footerFont = Font.fromName("GrenzeGotisch", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

    local lines = {
        "This exploit was forged to rise above all players.",
        string.format("Those who use <font color=\"%s\">Sacrament</font> are not more cheaters, they are <font color=\"%s\">gods</font>.", highlightRich, highlightRich),
        "This cult bears no responsibility for the unholy power unleashed by this tool."
    }

    for i, txt in ipairs(lines) do
        local lbl = createTextLabel("Line"..i, txt, 20, mainFont, mainColorHex)
        lbl.LayoutOrder = i
        lbl.Parent = mainLayout
    end

    local spacer = Instance.new("Frame")
    spacer.Size = UDim2.new(1, 0, 0, 25)
    spacer.BackgroundTransparency = 1
    spacer.LayoutOrder = 4
    spacer.Parent = mainLayout

    local invokeText = string.format("You do not inject Sacrament,\nYou <font color=\"%s\">invoke</font> it.", highlightRich)
    local invokeLbl = createTextLabel("Invoke", invokeText, 26, mainFont, mainColorHex)
    invokeLbl.LayoutOrder = 5
    invokeLbl.Parent = mainLayout

    local footerContainer = Instance.new("Frame")
    footerContainer.Name = "FooterContainer"
    footerContainer.Size = UDim2.new(1, 0, 0, 60)
    footerContainer.Position = UDim2.new(0, 0, 1, -70)
    footerContainer.BackgroundTransparency = 1
    footerContainer.Parent = container

    local footer = createTextLabel("Footer", "Created by @cardstolen", 32, footerFont, footerColorHex)
    footer.Size = UDim2.fromScale(1, 1)
    footer.Parent = footerContainer

    maid:GiveTask(container)

    local self = {}
    self.Instance = container

    function self:Destroy()
        maid:Destroy()
    end

    return self
end

return InfoModuleFactory
