--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")
local Players = game:GetService("Players")

if not Players.LocalPlayer then
    (Players:GetPropertyChangedSignal("LocalPlayer") :: RBXScriptSignal):Wait()
end
local localPlayer = Players.LocalPlayer

export type AdeptUI = {
    Instance: Frame,
    Destroy: (self: AdeptUI) -> ()
}

local AdeptFactory = {}

local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_BORDER = Color3.fromHex("333333")
local COLOR_TEXT = Color3.fromRGB(255, 255, 255)
local COLOR_SUBTEXT = Color3.fromRGB(170, 170, 170)
local COLOR_RED = Color3.fromHex("C80000")
local FONT_BOLD = Enum.Font.GothamBold
local FONT_MED = Enum.Font.GothamMedium

function AdeptFactory.new(layoutOrder: number): AdeptUI
    local maid = Maid.new()

    local box = Instance.new("Frame")
    box.Name = "PlayerInfoBox"
    box.BackgroundColor3 = COLOR_BG
    box.LayoutOrder = layoutOrder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = box

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLOR_BORDER
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = box

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 20)
    pad.PaddingBottom = UDim.new(0, 20)
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 20)
    pad.Parent = box

    -- Layout Horizontal da Box Principal (Avatar <-espaço-> Textos)
    local boxLayout = Instance.new("UIListLayout")
    boxLayout.SortOrder = Enum.SortOrder.LayoutOrder
    boxLayout.FillDirection = Enum.FillDirection.Horizontal
    boxLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    boxLayout.Padding = UDim.new(0, 15)
    boxLayout.Parent = box

    -- 1. Avatar (Esquerda)
    local avatarSize = 85
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Size = UDim2.new(0, avatarSize, 0, avatarSize)
    avatar.Image = "rbxthumb://type=Avatar&id="..localPlayer.UserId.."&w=150&h=150&filters=avatar_type:3d"
    avatar.BackgroundColor3 = COLOR_BG
    avatar.LayoutOrder = 1
    avatar.Parent = box

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0.5, 0)
    avatarCorner.Parent = avatar

    local avatarStroke = Instance.new("UIStroke")
    avatarStroke.Color = COLOR_RED
    avatarStroke.Thickness = 2
    avatarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    avatarStroke.Parent = avatar

    -- 2. Coluna de Textos (Direita)
    local textStack = Instance.new("Frame")
    textStack.Name = "TextStack"
    textStack.Size = UDim2.new(1, -(avatarSize + 15), 0, 0) -- Preenche o espaço restante
    textStack.AutomaticSize = Enum.AutomaticSize.Y
    textStack.BackgroundTransparency = 1
    textStack.LayoutOrder = 2
    textStack.Parent = box

    local stackLayout = Instance.new("UIListLayout")
    stackLayout.SortOrder = Enum.SortOrder.LayoutOrder
    stackLayout.FillDirection = Enum.FillDirection.Vertical
    stackLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    stackLayout.Padding = UDim.new(0, 8) -- Espaçamento vertical entre os textos
    stackLayout.Parent = textStack

    local function createText(name: string, text: string, size: number, color: Color3, order: number, font: Enum.Font)
        local lbl = Instance.new("TextLabel")
        lbl.Name = name
        lbl.Size = UDim2.new(1, 0, 0, size)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = color
        lbl.Font = font
        lbl.TextSize = size
        lbl.TextXAlignment = Enum.TextXAlignment.Left -- Alinhado rigorosamente à esquerda
        lbl.LayoutOrder = order
        lbl.Parent = textStack
    end

    createText("Username", "Username: @" .. localPlayer.Name, 14, COLOR_TEXT, 1, FONT_BOLD)
    createText("DisplayName", "Display Name: " .. localPlayer.DisplayName, 13, COLOR_SUBTEXT, 2, FONT_MED)
    createText("Age", "Account Age: " .. localPlayer.AccountAge .. " Days", 13, COLOR_SUBTEXT, 3, FONT_MED)
    createText("Status", "Status: Eternal Adept", 14, COLOR_RED, 4, FONT_BOLD)

    maid:GiveTask(box)

    local self = {}
    self.Instance = box
    function self:Destroy() maid:Destroy() end
    return self :: AdeptUI
end

return AdeptFactory
