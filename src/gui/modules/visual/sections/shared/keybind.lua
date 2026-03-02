--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type KeybindUI = {
    Instance: Frame,
    Destroy: (self: KeybindUI) -> ()
}

local KeybindFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local COLOR_BOX_BG = Color3.fromHex("1A1A1A")
local COLOR_BOX_BORDER = Color3.fromHex("333333")
local FONT_MAIN = Enum.Font.GothamBold

function KeybindFactory.new(layoutOrder: number?): KeybindUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "KeybindSection"
    container.Size = UDim2.new(1, 0, 0, 55) -- Padrão Row Grande
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 1

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 50)
    pad.Parent = container

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "Keybind"
    title.TextColor3 = COLOR_LABEL
    title.Font = FONT_MAIN
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = container

    local keyBox = Instance.new("TextButton")
    keyBox.Name = "KeyBox"
    keyBox.Size = UDim2.fromOffset(120, 32)
    keyBox.AnchorPoint = Vector2.new(1, 0.5)
    keyBox.Position = UDim2.fromScale(1, 0.5)
    keyBox.BackgroundColor3 = COLOR_BOX_BG
    keyBox.Text = "None"
    keyBox.TextColor3 = COLOR_LABEL
    keyBox.Font = FONT_MAIN
    keyBox.TextSize = 14
    keyBox.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = keyBox

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLOR_BOX_BORDER
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = keyBox

    maid:GiveTask(container)
    local self = {}
    self.Instance = container
    function self:Destroy() maid:Destroy() end
    return self :: KeybindUI
end

return KeybindFactory
