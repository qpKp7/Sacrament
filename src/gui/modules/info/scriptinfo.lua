--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")
local TweenService = game:GetService("TweenService")

export type ScriptInfoUI = {
    Instance: Frame,
    Destroy: (self: ScriptInfoUI) -> ()
}

local ScriptInfoFactory = {}

local COLOR_BG = Color3.fromRGB(22, 22, 22)
local COLOR_BORDER = Color3.fromRGB(45, 45, 45)
local COLOR_TEXT = Color3.fromRGB(255, 255, 255)
local COLOR_SUBTEXT = Color3.fromRGB(170, 170, 170)
local COLOR_RED = Color3.fromHex("C80000")
local COLOR_BTN = Color3.fromRGB(30, 30, 30)
local COLOR_HOVER = Color3.fromRGB(40, 40, 40)
local FONT_BOLD = Enum.Font.GothamBold
local FONT_MED = Enum.Font.GothamMedium

function ScriptInfoFactory.new(layoutOrder: number): ScriptInfoUI
    local maid = Maid.new()

    local box = Instance.new("Frame")
    box.Name = "ScriptInfoBox"
    box.BackgroundColor3 = COLOR_BG
    box.LayoutOrder = layoutOrder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = box

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLOR_BORDER
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = box

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 20)
    pad.PaddingBottom = UDim.new(0, 20)
    pad.PaddingLeft = UDim.new(0, 25)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = box

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 8)
    layout.Parent = box

    local function createText(name: string, text: string, size: number, color: Color3, order: number, font: Enum.Font)
        local lbl = Instance.new("TextLabel")
        lbl.Name = name
        lbl.Size = UDim2.new(1, 0, 0, size + 4)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = color
        lbl.Font = font
        lbl.TextSize = size
        lbl.TextXAlignment = Enum.TextXAlignment.Center
        lbl.LayoutOrder = order
        lbl.Parent = box
    end

    createText("Title", "Sacrament", 20, COLOR_TEXT, 1, FONT_BOLD)
    
    local spacer1 = Instance.new("Frame")
    spacer1.Size = UDim2.new(1, 0, 0, 4)
    spacer1.BackgroundTransparency = 1
    spacer1.LayoutOrder = 2
    spacer1.Parent = box

    createText("Version", "Version: v1.0.0", 14, COLOR_SUBTEXT, 3, FONT_MED)
    createText("Author", "Forged By: @cardstolen", 14, COLOR_SUBTEXT, 4, FONT_MED)

    -- Spacer flexível para empurrar o botão para a base
    local spacer2 = Instance.new("Frame")
    spacer2.Size = UDim2.new(1, 0, 1, -110)
    spacer2.BackgroundTransparency = 1
    spacer2.LayoutOrder = 5
    spacer2.Parent = box

    local discordBtn = Instance.new("TextButton")
    discordBtn.Name = "DiscordBtn"
    discordBtn.Size = UDim2.new(1, 0, 0, 36)
    discordBtn.BackgroundColor3 = COLOR_BTN
    discordBtn.Text = "Discord Sanctuary"
    discordBtn.TextColor3 = COLOR_RED
    discordBtn.Font = FONT_BOLD
    discordBtn.TextSize = 13
    discordBtn.AutoButtonColor = false
    discordBtn.LayoutOrder = 6
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
    return self :: ScriptInfoUI
end

return ScriptInfoFactory
