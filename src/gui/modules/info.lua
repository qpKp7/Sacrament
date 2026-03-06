--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type InfoUI = {
    Instance: Frame,
    Destroy: (self: InfoUI) -> ()
}

local InfoFactory = {}

local COLOR_BG = Color3.fromRGB(14, 14, 14)
local COLOR_ALTAR = Color3.fromRGB(20, 20, 20)
local COLOR_RED = Color3.fromHex("C80000")
local COLOR_TEXT = Color3.fromRGB(255, 255, 255)
local COLOR_SUBTEXT = Color3.fromRGB(150, 150, 150)
local FONT_MAIN = Enum.Font.GothamBold

-- Cria um gradiente simulado para o Altar (centro claro, bordas escuras)
local function CreateRadialGradient(parent: GuiObject)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(0.5, Color3.new(0.8, 0.8, 0.8)),
        ColorSequenceKeypoint.new(1, Color3.new(0.4, 0.4, 0.4))
    })
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.8, 0.3),
        NumberSequenceKeypoint.new(1, 0.7)
    })
    gradient.Rotation = 90
    gradient.Parent = parent
end

function InfoFactory.createInfoFrame(parent: Frame): Frame
    local container = Instance.new("Frame")
    container.Name = "InfoContainer"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundColor3 = COLOR_BG
    container.BorderSizePixel = 0
    if parent then
        container.Parent = parent
    end

    -- Altar Central
    local altar = Instance.new("Frame")
    altar.Name = "Altar"
    altar.Size = UDim2.new(0, 400, 0, 500)
    altar.AnchorPoint = Vector2.new(0.5, 0.5)
    altar.Position = UDim2.new(0.5, 0, 0.5, 0)
    altar.BackgroundColor3 = COLOR_ALTAR
    altar.Parent = container

    local altarCorner = Instance.new("UICorner")
    altarCorner.CornerRadius = UDim.new(0, 12)
    altarCorner.Parent = altar

    local altarStroke = Instance.new("UIStroke")
    altarStroke.Color = COLOR_RED
    altarStroke.Thickness = 1
    altarStroke.Transparency = 0.6
    altarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    altarStroke.Parent = altar

    CreateRadialGradient(altar)

    local altarPadding = Instance.new("UIPadding")
    altarPadding.PaddingTop = UDim.new(0, 30)
    altarPadding.PaddingBottom = UDim.new(0, 30)
    altarPadding.PaddingLeft = UDim.new(0, 20)
    altarPadding.PaddingRight = UDim.new(0, 20)
    altarPadding.Parent = altar

    local altarLayout = Instance.new("UIListLayout")
    altarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    altarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    altarLayout.Padding = UDim.new(0, 15)
    altarLayout.Parent = altar

    -- Avatar
    local avatarSize = 120
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Size = UDim2.new(0, avatarSize, 0, avatarSize)
    -- Placeholder ID (pode ser substituído dinamicamente depois)
    avatar.Image = "rbxthumb://type=Avatar&id=1&w=150&h=150" 
    avatar.BackgroundColor3 = COLOR_BG
    avatar.LayoutOrder = 1
    avatar.Parent = altar

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0.5, 0)
    avatarCorner.Parent = avatar

    local avatarStroke = Instance.new("UIStroke")
    avatarStroke.Color = COLOR_RED
    avatarStroke.Thickness = 2
    avatarStroke.Transparency = 0.4
    avatarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    avatarStroke.Parent = avatar

    -- Função auxiliar de texto
    local function CreateText(name: string, text: string, size: number, color: Color3, order: number): TextLabel
        local lbl = Instance.new("TextLabel")
        lbl.Name = name
        lbl.Size = UDim2.new(1, 0, 0, size + 4)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = color
        lbl.Font = FONT_MAIN
        lbl.TextSize = size
        lbl.LayoutOrder = order
        lbl.Parent = altar
        return lbl
    end

    -- Informações Principais
    CreateText("Name", "Name: juniorplay828", 18, COLOR_TEXT, 2)
    CreateText("Username", "Username: @Lokcsz", 14, COLOR_SUBTEXT, 3)
    CreateText("AccountAge", "Idade da Conta: 2098 Days", 14, COLOR_SUBTEXT, 4)
    CreateText("Status", "Status: Eternal Adept", 16, COLOR_RED, 5)
    CreateText("Cycle", "Ciclo: Lifetime", 14, COLOR_SUBTEXT, 6)

    -- Divisor (Runas/Linha Vermelha)
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(0.8, 0, 0, 1)
    divider.BackgroundColor3 = COLOR_RED
    divider.BackgroundTransparency = 0.5
    divider.LayoutOrder = 7
    divider.Parent = altar

    -- Rodapé Sacrament
    local footerContainer = Instance.new("Frame")
    footerContainer.Name = "Footer"
    footerContainer.Size = UDim2.new(1, 0, 0, 60)
    footerContainer.BackgroundTransparency = 1
    footerContainer.LayoutOrder = 8
    footerContainer.Parent = altar

    local footerLayout = Instance.new("UIListLayout")
    footerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    footerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    footerLayout.Padding = UDim.new(0, 5)
    footerLayout.Parent = footerContainer

    local lblSacrament = Instance.new("TextLabel")
    lblSacrament.Size = UDim2.new(1, 0, 0, 14)
    lblSacrament.BackgroundTransparency = 1
    lblSacrament.Text = "Sacrament v1.0.0"
    lblSacrament.TextColor3 = COLOR_TEXT
    lblSacrament.Font = FONT_MAIN
    lblSacrament.TextSize = 12
    lblSacrament.LayoutOrder = 1
    lblSacrament.Parent = footerContainer

    local lblForged = Instance.new("TextLabel")
    lblForged.Size = UDim2.new(1, 0, 0, 14)
    lblForged.BackgroundTransparency = 1
    lblForged.Text = "Forged by @cardstolen"
    lblForged.TextColor3 = COLOR_SUBTEXT
    lblForged.Font = FONT_MAIN
    lblForged.TextSize = 12
    lblForged.LayoutOrder = 2
    lblForged.Parent = footerContainer

    local lblDate = Instance.new("TextLabel")
    lblDate.Size = UDim2.new(1, 0, 0, 14)
    lblDate.BackgroundTransparency = 1
    lblDate.Text = "Invocation: March 05, 2026"
    lblDate.TextColor3 = COLOR_SUBTEXT
    lblDate.Font = FONT_MAIN
    lblDate.TextSize = 12
    lblDate.LayoutOrder = 3
    lblDate.Parent = footerContainer

    -- Botão Discord
    local discordBtn = Instance.new("TextButton")
    discordBtn.Name = "DiscordBtn"
    discordBtn.Size = UDim2.new(1, 0, 0, 20)
    discordBtn.BackgroundTransparency = 1
    discordBtn.Text = "Discord Sanctuary: discord.gg/bvNyfSDZxG"
    discordBtn.TextColor3 = COLOR_RED
    discordBtn.Font = FONT_MAIN
    discordBtn.TextSize = 12
    discordBtn.LayoutOrder = 9
    discordBtn.Parent = altar

    return container
end

-- Wrapper caso o loader utilize .new()
function InfoFactory.new(layoutOrder: any): InfoUI
    local maid = Maid.new()
    local frame = InfoFactory.createInfoFrame(nil :: any)
    maid:GiveTask(frame)

    local self = {}
    self.Instance = frame
    function self:Destroy() maid:Destroy() end
    return self :: InfoUI
end

return InfoFactory
