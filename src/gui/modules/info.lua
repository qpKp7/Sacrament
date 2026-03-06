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
local FONT_MEDIUM = Enum.Font.GothamMedium

function InfoFactory.createInfoFrame(parent: Frame?): Frame
    local container = Instance.new("Frame")
    container.Name = "InfoContainer"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    if parent then container.Parent = parent end

    -- WRAPPER HORIZONTAL (Controla o espaçamento das duas boxes)
    local wrapper = Instance.new("Frame")
    wrapper.Name = "WrapperHorizontal"
    wrapper.Size = UDim2.new(0, 620, 0, 320) -- Dimensão fixa respirável
    wrapper.AnchorPoint = Vector2.new(0.5, 0.5)
    wrapper.Position = UDim2.new(0.5, 0, 0.5, 0)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = container

    local wrapperLayout = Instance.new("UIListLayout")
    wrapperLayout.SortOrder = Enum.SortOrder.LayoutOrder
    wrapperLayout.FillDirection = Enum.FillDirection.Horizontal
    wrapperLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    wrapperLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    wrapperLayout.Padding = UDim.new(0, 20) -- Espaçamento entre as boxes
    wrapperLayout.Parent = wrapper

    -- ==========================================
    -- 1. PLAYER INFO BOX (55% Width)
    -- ==========================================
    local playerBox = Instance.new("Frame")
    playerBox.Name = "PlayerInfoBox"
    playerBox.Size = UDim2.new(0.55, -10, 1, 0)
    playerBox.BackgroundColor3 = COLORS.BG_BOX
    playerBox.LayoutOrder = 1
    playerBox.Parent = wrapper

    local pBoxCorner = Instance.new("UICorner")
    pBoxCorner.CornerRadius = UDim.new(0, 6)
    pBoxCorner.Parent = playerBox

    local pBoxStroke = Instance.new("UIStroke")
    pBoxStroke.Color = COLORS.BORDER
    pBoxStroke.Thickness = 1
    pBoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    pBoxStroke.Parent = playerBox

    local pBoxPad = Instance.new("UIPadding")
    pBoxPad.PaddingTop = UDim.new(0, 25)
    pBoxPad.PaddingBottom = UDim.new(0, 25)
    pBoxPad.Parent = playerBox

    local pBoxLayout = Instance.new("UIListLayout")
    pBoxLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pBoxLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    pBoxLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    pBoxLayout.Padding = UDim.new(0, 12)
    pBoxLayout.Parent = playerBox

    -- Avatar Circular
    local avatarSize = 90
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Size = UDim2.new(0, avatarSize, 0, avatarSize)
    avatar.Image = "rbxthumb://type=Avatar&id="..localPlayer.UserId.."&w=150&h=150&filters=avatar_type:3d"
    avatar.BackgroundColor3 = COLORS.BG_BOX
    avatar.LayoutOrder = 1
    avatar.Parent = playerBox

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0.5, 0)
    avatarCorner.Parent = avatar

    local avatarStroke = Instance.new("UIStroke")
    avatarStroke.Color = COLORS.ACCENT_RED
    avatarStroke.Thickness = 2
    avatarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    avatarStroke.Parent = avatar

    local function CreateTextLabel(parentBox: Instance, text: string, size: number, color: Color3, order: number, isBold: boolean?): TextLabel
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -20, 0, size + 4)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = color
        lbl.Font = isBold and FONT_BOLD or FONT_MEDIUM
        lbl.TextSize = size
        lbl.LayoutOrder = order
        lbl.Parent = parentBox
        return lbl
    end

    CreateTextLabel(playerBox, "Name: " .. localPlayer.DisplayName, 16, COLORS.TEXT_MAIN, 2, true)
    CreateTextLabel(playerBox, "Username: @" .. localPlayer.Name, 13, COLORS.TEXT_SUB, 3)
    CreateTextLabel(playerBox, "Idade da Conta: " .. localPlayer.AccountAge .. " Days", 13, COLORS.TEXT_SUB, 4)
    CreateTextLabel(playerBox, "Status: Eternal Adept", 15, COLORS.ACCENT_RED, 5, true)
    CreateTextLabel(playerBox, "Ciclo: Lifetime", 13, COLORS.TEXT_SUB, 6)

    -- ==========================================
    -- 2. SCRIPT INFO BOX (45% Width)
    -- ==========================================
    local scriptBox = Instance.new("Frame")
    scriptBox.Name = "ScriptInfoBox"
    scriptBox.Size = UDim2.new(0.45, -10, 1, 0)
    scriptBox.BackgroundColor3 = COLORS.BG_BOX
    scriptBox.LayoutOrder = 2
    scriptBox.Parent = wrapper

    local sBoxCorner = Instance.new("UICorner")
    sBoxCorner.CornerRadius = UDim.new(0, 6)
    sBoxCorner.Parent = scriptBox

    local sBoxStroke = Instance.new("UIStroke")
    sBoxStroke.Color = COLORS.BORDER
    sBoxStroke.Thickness = 1
    sBoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    sBoxStroke.Parent = scriptBox

    local sBoxPad = Instance.new("UIPadding")
    sBoxPad.PaddingTop = UDim.new(0, 25)
    sBoxPad.PaddingBottom = UDim.new(0, 25)
    sBoxPad.PaddingLeft = UDim.new(0, 15)
    sBoxPad.PaddingRight = UDim.new(0, 15)
    sBoxPad.Parent = scriptBox

    local sBoxLayout = Instance.new("UIListLayout")
    sBoxLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sBoxLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sBoxLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    sBoxLayout.Padding = UDim.new(0, 14)
    sBoxLayout.Parent = scriptBox

    CreateTextLabel(scriptBox, "Sacrament v1.0.0", 14, COLORS.TEXT_MAIN, 1, true)
    CreateTextLabel(scriptBox, "Forged by @cardstolen", 13, COLORS.TEXT_SUB, 2)
    CreateTextLabel(scriptBox, "Invocation: March 05, 2026", 13, COLORS.TEXT_SUB, 3)

    -- Divisor Vermelho Fino
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(0.8, 0, 0, 1)
    divider.BackgroundColor3 = COLORS.ACCENT_RED
    divider.BackgroundTransparency = 0.5
    divider.LayoutOrder = 4
    divider.Parent = scriptBox

    -- Botão Discord (Sub-box estilizada)
    local discordBox = Instance.new("TextButton")
    discordBox.Name = "DiscordBox"
    discordBox.Size = UDim2.new(1, 0, 0, 36)
    discordBox.BackgroundColor3 = COLORS.BTN_BG
    discordBox.Text = "Discord Sanctuary\ndiscord.gg/bvNyfSDZxG"
    discordBox.TextColor3 = COLORS.ACCENT_RED
    discordBox.Font = FONT_BOLD
    discordBox.TextSize = 11
    discordBox.AutoButtonColor = false
    discordBox.LayoutOrder = 5
    discordBox.Parent = scriptBox

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

    -- Bind do Hover Effect do Botão Discord
    local wrapper = frame:FindFirstChild("WrapperHorizontal")
    local scriptBox = wrapper and wrapper:FindFirstChild("ScriptInfoBox")
    local discordBox = scriptBox and scriptBox:FindFirstChild("DiscordBox")
    
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
