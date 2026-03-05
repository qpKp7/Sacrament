--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type RejoinUI = {
    Instance: Frame,
    Clicked: RBXScriptSignal,
    Destroy: (self: RejoinUI) -> ()
}

local RejoinFactory = {}

local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_BORDER = Color3.fromHex("333333")
local COLOR_TEXT = Color3.fromHex("FFFFFF")
local COLOR_SUBTEXT = Color3.fromHex("888888")
local COLOR_BTN = Color3.fromHex("2A2A2A")
local FONT_MAIN = Enum.Font.GothamBold

function RejoinFactory.new(layoutOrder: number?): RejoinUI
    local maid = Maid.new()

    local row = Instance.new("Frame")
    row.Name = "RejoinRow"
    row.Size = UDim2.new(1, 0, 0, 55)
    row.BackgroundColor3 = COLOR_BG
    row.BackgroundTransparency = 0
    row.LayoutOrder = layoutOrder or 1

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = row

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLOR_BORDER
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = row

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 50)
    pad.Parent = row

    local textContainer = Instance.new("Frame")
    textContainer.Name = "TextContainer"
    textContainer.Size = UDim2.new(0.6, 0, 1, 0)
    textContainer.BackgroundTransparency = 1
    textContainer.Parent = row

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 16)
    title.Position = UDim2.new(0, 0, 0.5, -9)
    title.AnchorPoint = Vector2.new(0, 0.5)
    title.BackgroundTransparency = 1
    title.Text = "Rejoin Server"
    title.TextColor3 = COLOR_TEXT
    title.Font = FONT_MAIN
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = textContainer

    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, 0, 0, 12)
    subtitle.Position = UDim2.new(0, 0, 0.5, 9)
    subtitle.AnchorPoint = Vector2.new(0, 0.5)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Reconnects to the current JobId"
    subtitle.TextColor3 = COLOR_SUBTEXT
    subtitle.Font = FONT_MAIN
    subtitle.TextSize = 12
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = textContainer

    local clickedEvent = Instance.new("BindableEvent")
    maid:GiveTask(clickedEvent)

    local button = Instance.new("TextButton")
    button.Name = "ActionBtn"
    button.Size = UDim2.new(0, 80, 0, 30)
    button.AnchorPoint = Vector2.new(1, 0.5)
    button.Position = UDim2.new(1, 0, 0.5, 0)
    button.BackgroundColor3 = COLOR_BTN
    button.Text = "Execute"
    button.TextColor3 = COLOR_TEXT
    button.Font = FONT_MAIN
    button.TextSize = 14
    button.AutoButtonColor = true
    button.Parent = row

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = COLOR_BORDER
    btnStroke.Thickness = 1
    btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    btnStroke.Parent = button

    maid:GiveTask(button.MouseButton1Click:Connect(function()
        clickedEvent:Fire()
    end))

    maid:GiveTask(row)

    local self = {}
    self.Instance = row
    self.Clicked = clickedEvent.Event
    
    function self:Destroy() maid:Destroy() end
    
    return self :: RejoinUI
end

return RejoinFactory
