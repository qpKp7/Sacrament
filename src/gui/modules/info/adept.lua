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
    pad.Parent = box

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 12)
    layout.Parent = box

    local avatarSize = 90
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

    local function createText(name: string, text: string, size: number, color: Color3, order: number, font: Enum.Font)
        local lbl = Instance.new("TextLabel")
        lbl.Name = name
        lbl.Size = UDim2.new(1, -20, 0, size + 4)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = color
        lbl.Font = font
        lbl.TextSize = size
        lbl.LayoutOrder = order
        lbl.Parent = box
    end

    createText("Name", "Name: " .. localPlayer.DisplayName, 16, COLOR_TEXT, 2, FONT_BOLD)
    createText("User", "Username: @" .. localPlayer.Name, 13, COLOR_SUBTEXT, 3, FONT_MED)
    createText("Age", "Idade da Conta: " .. localPlayer.AccountAge .. " Days", 13, COLOR_SUBTEXT, 4, FONT_MED)
    createText("Status", "Status: Eternal Adept", 15, COLOR_RED, 5, FONT_BOLD)
    createText("Cycle", "Ciclo: Lifetime", 13, COLOR_SUBTEXT, 6, FONT_MED)

    maid:GiveTask(box)

    local self = {}
    self.Instance = box
    function self:Destroy() maid:Destroy() end
    return self :: AdeptUI
end

return AdeptFactory
