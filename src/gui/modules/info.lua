--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

if not Players.LocalPlayer then
    (Players:GetPropertyChangedSignal("LocalPlayer") :: RBXScriptSignal):Wait()
end
local localPlayer = Players.LocalPlayer

export type InfoUI = {
    Instance: Frame,
    Destroy: (self: InfoUI) -> ()
}

local InfoFactory = {}

local COLORS = {
    BG_TAB = Color3.fromRGB(14, 14, 14),
    BG_BOX = Color3.fromHex("1A1A1A"),
    BORDER = Color3.fromHex("333333"),
    TEXT_MAIN = Color3.fromRGB(255, 255, 255),
    TEXT_SUB = Color3.fromRGB(170, 170, 170),
    ACCENT_RED = Color3.fromHex("C80000"),
    BTN_BG = Color3.fromHex("222222"),
    BTN_HOVER = Color3.fromHex("2A2A2A")
}

local FONT_BOLD = Enum.Font.GothamBold

function InfoFactory.createInfoFrame(parent: Frame?): Frame
    local container = Instance.new("Frame")
    container.Name = "InfoContainer"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    if parent then container.Parent = parent end

    -- Info Box Central (Retangular e limpa)
    local infoBox = Instance.new("Frame")
    infoBox.Name = "InfoBox"
    infoBox.Size = UDim2.new(0, 380, 0, 0)
    infoBox.AutomaticSize = Enum.AutomaticSize.Y
    infoBox.AnchorPoint = Vector2.new(0.5, 0.5)
    infoBox.Position = UDim2.new(0.5, 0, 0.5, 0)
    infoBox.BackgroundColor3 = COLORS.BG_BOX
    infoBox.Parent = container

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = infoBox

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = COLORS.BORDER
    boxStroke.Thickness = 1
    boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    boxStroke.Parent = infoBox

    local boxPadding = Instance.new("UIPadding")
    boxPadding.PaddingTop = UDim.new(0, 25)
    boxPadding.PaddingBottom = UDim.new(0, 25)
    boxPadding.PaddingLeft = UDim.new(0, 20)
    boxPadding.PaddingRight = UDim.new(0, 20)
    boxPadding.Parent = infoBox

    local boxLayout = Instance.new("UIListLayout")
    boxLayout.SortOrder = Enum.SortOrder.LayoutOrder
    boxLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    boxLayout.Padding = UDim.new(0, 15)
    boxLayout.Parent = infoBox

    -- Avatar Circular
    local avatarSize = 100
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Size = UDim2.new(0, avatarSize, 0, avatarSize)
    avatar.Image = "rbxthumb://type=Avatar&id="..localPlayer.UserId.."&w=150&h=150&filters=avatar_type:3d"
    avatar.BackgroundColor3 = COLORS.BG_BOX
    avatar.LayoutOrder = 1
    avatar.Parent = infoBox

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0.5, 0)
    avatarCorner.Parent = avatar

    local avatarStroke = Instance.new("UIStroke")
    avatarStroke.Color = COLORS.ACCENT_RED
    avatarStroke.Thickness = 2
    avatarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    avatarStroke.Parent = avatar

    -- Text Stack (Informações do Jogador)
    local textStack = Instance.new("Frame")
    textStack.Name = "TextStack"
    textStack.Size = UDim2.new(1, 0, 0, 0)
    textStack.AutomaticSize = Enum.AutomaticSize.Y
    textStack.BackgroundTransparency = 1
    textStack.LayoutOrder = 2
    textStack.Parent = infoBox

    local textLayout = Instance.new("UIListLayout")
    textLayout.SortOrder = Enum.SortOrder.LayoutOrder
    textLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    textLayout.Padding = UDim.new(0, 10)
    textLayout.Parent = textStack

    local function CreateTextLabel(name: string, text: string, size: number, color: Color3, order: number, isBold: boolean?)
        local lbl = Instance.new("TextLabel")
        lbl.Name = name
        lbl.Size = UDim2.new(1, 0, 0, size + 2)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = color
        lbl.Font = isBold and FONT_BOLD or Enum.Font.GothamMedium
        lbl.TextSize = size
        lbl.LayoutOrder = order
        lbl.Parent = textStack
        return lbl
    end

    CreateTextLabel("Name", "Name: " .. localPlayer.DisplayName, 18, COLORS.TEXT_MAIN, 1, true)
    CreateTextLabel("Username", "Username: @" .. localPlayer.Name, 14, COLORS.TEXT_SUB, 2)
    CreateTextLabel("AccountAge", "Idade da Conta: " .. localPlayer.AccountAge .. " Days", 14, COLORS.TEXT_SUB, 3)
    CreateTextLabel("Status", "Status: Eternal Adept", 16, COLORS.ACCENT_RED, 4, true)
    CreateTextLabel("Cycle", "Ciclo: Lifetime", 14, COLORS.TEXT_SUB, 5)

    -- Divisor (Linha vermelha fina)
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(0.8, 0, 0, 1)
    divider.BackgroundColor3 = COLORS.ACCENT_RED
    divider.BackgroundTransparency = 0.5
    divider.LayoutOrder = 3
    divider.Parent = infoBox

    -- Footer Stack (Assinatura)
    local footerStack = Instance.new("Frame")
    footerStack.Name = "FooterStack"
    footerStack.Size = UDim2.new(1, 0, 0, 0)
    footerStack.AutomaticSize = Enum.AutomaticSize.Y
    footerStack.BackgroundTransparency = 1
    footerStack.LayoutOrder = 4
    footerStack.Parent = infoBox

    local footerLayout = Instance.new("UIListLayout")
    footerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    footerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    footerLayout.Padding = UDim.new(0, 5)
    footerLayout.Parent = footerStack

    local function CreateFooterLabel(text: string, order: number)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 14)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = COLORS.TEXT_SUB
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.LayoutOrder = order
        lbl.Parent = footerStack
    end

    CreateFooterLabel("Sacrament v1.0.0", 1)
    CreateFooterLabel("Forged by @cardstolen", 2)
    CreateFooterLabel("Invocation: March 05, 2026", 3)

    -- Discord Box (Botão inferior)
    local discordBox = Instance.new("TextButton")
    discordBox.Name = "DiscordBox"
    discordBox.Size = UDim2.new(1, 0, 0, 36)
    discordBox.BackgroundColor3 = COLORS.BTN_BG
    discordBox.Text = "Discord Sanctuary: discord.gg/bvNyfSDZxG"
    discordBox.TextColor3 = COLORS.ACCENT_RED
    discordBox.Font = FONT_BOLD
    discordBox.TextSize = 13
    discordBox.AutoButtonColor = false
    discordBox.LayoutOrder = 5
    discordBox.Parent = infoBox

    local discordCorner = Instance.new("UICorner")
    discordCorner.CornerRadius = UDim.new(0, 6)
    discordCorner.Parent = discordBox

    local discordStroke = Instance.new("UIStroke")
    discordStroke.Color = COLORS.BORDER
    discordStroke.Thickness = 1
    discordStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    discordStroke.Parent = discordBox

    return container
end

function InfoFactory.new(layoutOrder: any): InfoUI
    local maid = Maid.new()
    local frame = InfoFactory.createInfoFrame()
    maid:GiveTask(frame)

    local discordBox = frame:FindFirstChild("InfoBox") and frame.InfoBox:FindFirstChild("DiscordBox")
    
    if discordBox and discordBox:IsA("TextButton") then
        local tweenInfoHover = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local hoverOn = TweenService:Create(discordBox, tweenInfoHover, {BackgroundColor3 = COLORS.BTN_HOVER})
        local hoverOff = TweenService:Create(discordBox, tweenInfoHover, {BackgroundColor3 = COLORS.BTN_BG})
        
        maid:GiveTask(discordBox.MouseEnter:Connect(function() hoverOn:Play() end))
        maid:GiveTask(discordBox.MouseLeave:Connect(function() hoverOff:Play() end))
    end

    local self = {}
    self.Instance = frame
    
    function self:Destroy() 
        maid:Destroy() 
    end
    
    return self :: InfoUI
end

return InfoFactory
