--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local ToggleButton = SafeImport("gui/modules/components/togglebutton")

export type FriendCheckUI = {
    Instance: Frame,
    Toggle: any, -- [NOVO] Exportado para o Orquestrador!
    Destroy: (self: FriendCheckUI) -> ()
}

local FriendCheckFactory = {}

local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_BORDER = Color3.fromHex("333333")
local COLOR_TEXT = Color3.fromHex("FFFFFF")
local COLOR_SUBTEXT = Color3.fromHex("888888")
local FONT_MAIN = Enum.Font.GothamBold

function FriendCheckFactory.new(layoutOrder: number?): FriendCheckUI
    local maid = Maid.new()

    local card = Instance.new("Frame")
    card.Name = "FriendCheckCard"
    card.Size = UDim2.new(0.5, -7.5, 0, 55)
    card.BackgroundColor3 = COLOR_BG
    card.LayoutOrder = layoutOrder or 1

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLOR_BORDER
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = card

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 15)
    pad.PaddingRight = UDim.new(0, 15)
    pad.Parent = card

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 0, 16)
    title.Position = UDim2.new(0, 0, 0.5, -10)
    title.AnchorPoint = Vector2.new(0, 0.5)
    title.BackgroundTransparency = 1
    title.Text = "Friend Check"
    title.TextColor3 = COLOR_TEXT
    title.Font = FONT_MAIN
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -50, 0, 12)
    subtitle.Position = UDim2.new(0, 0, 0.5, 8)
    subtitle.AnchorPoint = Vector2.new(0, 0.5)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Use Roblox Friends List"
    subtitle.TextColor3 = COLOR_SUBTEXT
    subtitle.Font = FONT_MAIN
    subtitle.TextSize = 12
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = card

    local self = {} :: any
    self.Instance = card

    if ToggleButton and type(ToggleButton.new) == "function" then
        local toggle = ToggleButton.new()
        toggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
        toggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        toggle.Instance.Parent = card
        maid:GiveTask(toggle)
        
        -- [O SEGREDO] Chave para a memória!
        self.Toggle = toggle
    end

    maid:GiveTask(card)

    function self:Destroy()
        maid:Destroy()
    end

    return self :: FriendCheckUI
end

return FriendCheckFactory
