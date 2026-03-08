--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")
local TweenService = game:GetService("TweenService")

export type ScriptCardUI = {
    Instance: Frame,
    Destroy: (self: ScriptCardUI) -> ()
}

local ScriptCardFactory = {}

local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_BORDER = Color3.fromHex("333333")
local COLOR_TEXT = Color3.fromRGB(255, 255, 255)
local COLOR_SUBTEXT = Color3.fromRGB(170, 170, 170)
local COLOR_RED = Color3.fromHex("C80000")
local COLOR_BTN = Color3.fromHex("222222")
local COLOR_HOVER = Color3.fromHex("2A2A2A")
local FONT_BOLD = Enum.Font.GothamBold
local FONT_MED = Enum.Font.GothamMedium

function ScriptCardFactory.new(layoutOrder: number): ScriptCardUI
    local maid = Maid.new()

    local box = Instance.new("Frame")
    box.Name = "ScriptInfoBox"
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

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 12)
    layout.Parent = box

    local function createText(name: string, text: string, size: number, color: Color3, order: number, font: Enum.Font)
        local lbl = Instance.new("TextLabel")
        lbl.Name = name
        lbl.Size = UDim2.new(1, 0, 0, size + 2)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = color
        lbl.Font = font
        lbl.TextSize = size
        lbl.TextXAlignment = Enum.TextXAlignment.Center
        lbl.LayoutOrder = order
        lbl.Parent = box
    end

    createText("Title", "Sacrament", 18, COLOR_TEXT, 1, FONT_BOLD)
    createText("Version", "Version: v1.0.0", 13, COLOR_SUBTEXT, 2, FONT_MED)
    createText("Author", "Forged By: @cardstolen", 13, COLOR_SUBTEXT, 3, FONT_MED)

    -- Spacer transparente para empurrar o botão para baixo
    local spacer = Instance.new("Frame")
    spacer.Name = "Spacer"
    spacer.Size = UDim2.new(1, 0, 0, 15)
    spacer.BackgroundTransparency = 1
    spacer.LayoutOrder = 4
    spacer.Parent = box

    local discordBtn = Instance.new("TextButton")
    discordBtn.Name = "DiscordBtn"
    discordBtn.Size = UDim2.new(1, 0, 0, 36)
    discordBtn.BackgroundColor3 = COLOR_BTN
    discordBtn.Text = "Discord Sanctuary\ndiscord.gg/bvNyfSDZxG"
    discordBtn.TextColor3 = COLOR_RED
    discordBtn.Font = FONT_BOLD
    discordBtn.TextSize = 11
    discordBtn.AutoButtonColor = false
    discordBtn.LayoutOrder = 5
    discordBtn.Parent = box

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = discordBtn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = COLOR_BORDER
    btnStroke.Thickness = 1
    btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    btnStroke.Parent = discordBtn

    local tweenInfoHover = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local hoverOn = TweenService:Create(discordBtn, tweenInfoHover, {BackgroundColor3 = COLOR_HOVER})
    local hoverOff = TweenService:Create(discordBtn, tweenInfoHover, {BackgroundColor3 = COLOR_BTN})

    maid:GiveTask(discordBtn.MouseEnter:Connect(function() hoverOn:Play() end))
    maid:GiveTask(discordBtn.MouseLeave:Connect(function() hoverOff:Play() end))

    maid:GiveTask(box)

    local self = {}
    self.Instance = box
    function self:Destroy() maid:Destroy() end
    return self :: ScriptCardUI
end

return ScriptCardFactory
