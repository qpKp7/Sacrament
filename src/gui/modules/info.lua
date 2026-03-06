--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

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
    BG_ALTAR = Color3.fromRGB(18, 18, 18),
    TEXT_MAIN = Color3.fromRGB(255, 255, 255),
    TEXT_SUB = Color3.fromRGB(170, 170, 170),
    ACCENT_RED = Color3.fromHex("C80000"),
    BTN_HOVER = Color3.fromRGB(40, 40, 40),
    BTN_DEFAULT = Color3.fromRGB(30, 30, 30)
}

local FONT_BOLD = Enum.Font.GothamBold

function InfoFactory.createInfoFrame(parent: Frame?): Frame
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "InfoContainer"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    if parent then container.Parent = parent end

    local altarSize = UDim2.new(0, 420, 0, 580)
    local altar = Instance.new("Frame")
    altar.Name = "Altar"
    altar.Size = altarSize
    altar.AnchorPoint = Vector2.new(0.5, 0.5)
    altar.Position = UDim2.new(0.5, 0, 0.5, 0)
    altar.BackgroundColor3 = COLORS.BG_ALTAR
    altar.Parent = container

    local altarCorner = Instance.new("UICorner")
    altarCorner.CornerRadius = UDim.new(0.5, 0)
    altarCorner.Parent = altar

    local altarStroke = Instance.new("UIStroke")
    altarStroke.Color = COLORS.ACCENT_RED
    altarStroke.Thickness = 1
    altarStroke.Transparency = 0.6
    altarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    altarStroke.Parent = altar

    local altarPadding = Instance.new("UIPadding")
    altarPadding.PaddingTop = UDim.new(0, 30)
    altarPadding.PaddingBottom = UDim.new(0, 30)
    altarPadding.PaddingLeft = UDim.new(0, 25)
    altarPadding.PaddingRight = UDim.new(0, 25)
    altarPadding.Parent = altar

    local altarLayout = Instance.new("UIListLayout")
    altarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    altarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    altarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    altarLayout.Padding = UDim.new(0, 18)
    altarLayout.Parent = altar

    local tweenInfoPulse = TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local tweenPulse = TweenService:Create(altarStroke, tweenInfoPulse, {Transparency = 0.9})
    tweenPulse:Play()
    maid:GiveTask(tweenPulse)

    local avatarSize = 140
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Size = UDim2.new(0, avatarSize, 0, avatarSize)
    avatar.Image = "rbxthumb://type=Avatar&id="..localPlayer.UserId.."&w=420&h=420&filters=avatar_type:3d"
    avatar.BackgroundColor3 = COLORS.BG_ALTAR
    avatar.LayoutOrder = 1
    avatar.Parent = altar

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0.5, 0)
    avatarCorner.Parent = avatar

    local avatarStroke = Instance.new("UIStroke")
    avatarStroke.Color = COLORS.ACCENT_RED
    avatarStroke.Thickness = 2
    avatarStroke.Transparency = 0.4
    avatarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    avatarStroke.Parent = avatar

    local textStack = Instance.new("Frame")
    textStack.Name = "TextStack"
    textStack.Size = UDim2.new(1, 0, 0, 0)
    textStack.AutomaticSize = Enum.AutomaticSize.Y
    textStack.BackgroundTransparency = 1
    textStack.LayoutOrder = 2
    textStack.Parent = altar

    local textLayout = Instance.new("UIListLayout")
    textLayout.SortOrder = Enum.SortOrder.LayoutOrder
    textLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    textLayout.Padding = UDim.new(0, 12)
    textLayout.Parent = textStack

    local function CreateTextLabel(name: string, text: string, size: number, color: Color3, order: number)
        local lbl = Instance.new("TextLabel")
        lbl.Name = name
        lbl.Size = UDim2.new(1, 0, 0, size + 2)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = color
        lbl.Font = FONT_BOLD
        lbl.TextSize = size
        lbl.TextWrapped = true
        lbl.LayoutOrder = order
        lbl.Parent = textStack
        return lbl
    end

    CreateTextLabel("Name", "Name: " .. localPlayer.DisplayName, 20, COLORS.TEXT_MAIN, 1)
    CreateTextLabel("Username", "Username: @" .. localPlayer.Name, 16, COLORS.TEXT_SUB, 2)
    CreateTextLabel("AccountAge", "Idade da Conta: " .. localPlayer.AccountAge .. " Days", 16, COLORS.TEXT_SUB, 3)

    CreateTextLabel("Status", "Status: Eternal Adept", 18, COLORS.ACCENT_RED, 4)
    CreateTextLabel("Cycle", "Ciclo: Lifetime", 16, COLORS.TEXT_SUB, 5)

    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(0.8, 0, 0, 1)
    divider.BackgroundColor3 = COLORS.ACCENT_RED
    divider.BackgroundTransparency = 0.6
    divider.LayoutOrder = 3
    divider.Parent = altar

    local sacramentFooter = Instance.new("Frame")
    sacramentFooter.Name = "SacramentFooter"
    sacramentFooter.Size = UDim2.new(1, 0, 0, 0)
    sacramentFooter.AutomaticSize = Enum.AutomaticSize.Y
    sacramentFooter.BackgroundTransparency = 1
    sacramentFooter.LayoutOrder = 4
    sacramentFooter.Parent = altar

    local sacramentLayout = Instance.new("UIListLayout")
    sacramentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sacramentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sacramentLayout.Padding = UDim.new(0, 6)
    sacramentLayout.Parent = sacramentFooter

    local function CreateSacramentLabel(text: string, order: number)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 14)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = COLORS.TEXT_SUB
        lbl.Font = FONT_BOLD
        lbl.TextSize = 12
        lbl.LayoutOrder = order
        lbl.Parent = sacramentFooter
    end

    CreateSacramentLabel("Sacrament v1.0.0", 1)
    CreateSacramentLabel("Forged by @cardstolen", 2)
    CreateSacramentLabel("Invocation: March 05, 2026", 3)

    local discordSize = UDim2.new(1, 0, 0, 32)
    local discordBtn = Instance.new("TextButton")
    discordBtn.Name = "DiscordBtn"
    discordBtn.Size = discordSize
    discordBtn.BackgroundColor3 = COLORS.BTN_DEFAULT
    discordBtn.Text = "Discord Sanctuary: discord.gg/bvNyfSDZxG"
    discordBtn.TextColor3 = COLORS.ACCENT_RED
    discordBtn.Font = FONT_BOLD
    discordBtn.TextSize = 12
    discordBtn.AutoButtonColor = false
    discordBtn.LayoutOrder = 5
    discordBtn.Parent = altar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = discordBtn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = COLORS.ACCENT_RED
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.8
    btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    btnStroke.Parent = discordBtn

    local tweenInfoHover = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    
    local tweenHoverOn = TweenService:Create(discordBtn, tweenInfoHover, {BackgroundColor3 = COLORS.BTN_HOVER})
    local tweenHoverOff = TweenService:Create(discordBtn, tweenInfoHover, {BackgroundColor3 = COLORS.BTN_DEFAULT})

    maid:GiveTask(discordBtn.MouseEnter:Connect(function()
        tweenHoverOn:Play()
    end))

    maid:GiveTask(discordBtn.MouseLeave:Connect(function()
        tweenHoverOff:Play()
    end))

    maid:GiveTask(discordBtn.MouseButton1Click:Connect(function()
        discordBtn.TextTransparency = 0.5
        task.wait(0.1)
        discordBtn.TextTransparency = 0
    end))

    maid:GiveTask(container)
    
    return container
end

function InfoFactory.new(layoutOrder: any): InfoUI
    local maid = Maid.new()
    local frame = InfoFactory.createInfoFrame()
    maid:GiveTask(frame)

    local self = {}
    self.Instance = frame
    
    function self:Destroy() 
        maid:Destroy() 
    end
    
    return self :: InfoUI
end

return InfoFactory
