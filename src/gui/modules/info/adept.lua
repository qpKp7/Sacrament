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

local COLOR_BG = Color3.fromRGB(24, 24, 24) -- Fundo levemente destacado
local COLOR_FRAME_BG = Color3.fromRGB(18, 18, 18) -- Fundo escuro para a moldura do avatar
local COLOR_TEXT_MAIN = Color3.fromRGB(255, 255, 255)
local COLOR_TEXT_SUB = Color3.fromRGB(160, 160, 160)
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
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = box

    -- Glow vermelho suave do card
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLOR_RED
    stroke.Transparency = 0.65 -- Alta transparência para efeito de glow
    stroke.Thickness = 2 -- Mais espesso para não parecer uma linha dura
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = box

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 25)
    pad.PaddingBottom = UDim.new(0, 25)
    pad.PaddingLeft = UDim.new(0, 30)
    pad.PaddingRight = UDim.new(0, 30)
    pad.Parent = box

    local boxLayout = Instance.new("UIListLayout")
    boxLayout.SortOrder = Enum.SortOrder.LayoutOrder
    boxLayout.FillDirection = Enum.FillDirection.Horizontal
    boxLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    boxLayout.Padding = UDim.new(0, 25)
    boxLayout.Parent = box

    -- 1. MOLDURA DO AVATAR (Respiro e Enquadramento)
    local frameSize = 115
    local avatarFrame = Instance.new("Frame")
    avatarFrame.Name = "AvatarFrame"
    avatarFrame.Size = UDim2.new(0, frameSize, 0, frameSize)
    avatarFrame.BackgroundColor3 = COLOR_FRAME_BG
    avatarFrame.LayoutOrder = 1
    avatarFrame.Parent = box

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = avatarFrame

    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = COLOR_RED
    frameStroke.Transparency = 0.4
    frameStroke.Thickness = 1
    frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    frameStroke.Parent = avatarFrame

    -- IMAGEM DO AVATAR (Dentro da moldura, com margem de 8px de cada lado)
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "AvatarImage"
    avatar.Size = UDim2.new(1, -16, 1, -16) -- Garante o respiro interno
    avatar.AnchorPoint = Vector2.new(0.5, 0.5)
    avatar.Position = UDim2.new(0.5, 0, 0.5, 0)
    avatar.Image = "rbxthumb://type=Avatar&id="..localPlayer.UserId.."&w=150&h=150"
    avatar.ScaleType = Enum.ScaleType.Fit -- Corpo completo sem cortes
    avatar.BackgroundTransparency = 1
    avatar.Parent = avatarFrame

    -- 2. COLUNA DE TEXTOS (Hierarquia Visual)
    local textColumn = Instance.new("Frame")
    textColumn.Name = "TextColumn"
    textColumn.Size = UDim2.new(1, -(frameSize + 25), 1, 0)
    textColumn.BackgroundTransparency = 1
    textColumn.LayoutOrder = 2
    textColumn.Parent = box

    local columnLayout = Instance.new("UIListLayout")
    columnLayout.SortOrder = Enum.SortOrder.LayoutOrder
    columnLayout.FillDirection = Enum.FillDirection.Vertical
    columnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    columnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    columnLayout.Padding = UDim.new(0, 8) -- Espaçamento limpo entre linhas
    columnLayout.Parent = textColumn

    local function createText(name: string, text: string, size: number, color: Color3, order: number, font: Enum.Font)
        local lbl = Instance.new("TextLabel")
        lbl.Name = name
        lbl.Size = UDim2.new(1, 0, 0, size + 2)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = color
        lbl.Font = font
        lbl.TextSize = size
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.LayoutOrder = order
        lbl.Parent = textColumn
    end

    -- Hierarquia visual forte: Username dominante, Status com destaque final
    createText("Username", "Username: @" .. localPlayer.Name, 18, COLOR_TEXT_MAIN, 1, FONT_BOLD)
    createText("DisplayName", "Display Name: " .. localPlayer.DisplayName, 13, COLOR_TEXT_SUB, 2, FONT_MED)
    createText("Age", "Account Age: " .. localPlayer.AccountAge .. " Days", 13, COLOR_TEXT_SUB, 3, FONT_MED)
    
    local spacer = Instance.new("Frame")
    spacer.Size = UDim2.new(1, 0, 0, 2)
    spacer.BackgroundTransparency = 1
    spacer.LayoutOrder = 4
    spacer.Parent = textColumn

    createText("Status", "Status: Eternal Adept", 15, COLOR_RED, 5, FONT_BOLD)

    maid:GiveTask(box)

    local self = {}
    self.Instance = box
    function self:Destroy() maid:Destroy() end
    return self :: AdeptUI
end

return AdeptFactory
