--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type SmoothSection = {
    Instance: Frame,
    Destroy: (self: SmoothSection) -> ()
}

local SmoothFactory = {}

local COLOR_TEXT = Color3.fromHex("B4B4B4")
local COLOR_BOX_BG = Color3.fromRGB(20, 20, 20)
local COLOR_BOX_STROKE = Color3.fromRGB(35, 35, 35)
local FONT_MAIN = Enum.Font.GothamBold

function SmoothFactory.new(layoutOrder: number): SmoothSection
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "SmoothContainer"
    container.Size = UDim2.new(1, 0, 0, 32)
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.fromOffset(20, 0)
    title.BackgroundTransparency = 1
    title.Text = "Smooth"
    title.TextColor3 = COLOR_TEXT
    title.Font = FONT_MAIN
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = container

    local valueBox = Instance.new("Frame")
    valueBox.Name = "ValueBox"
    valueBox.AnchorPoint = Vector2.new(1, 0.5)
    valueBox.Position = UDim2.new(1, 0, 0.5, 0)
    valueBox.Size = UDim2.fromOffset(90, 28)
    valueBox.BackgroundColor3 = COLOR_BOX_BG
    valueBox.BorderSizePixel = 0
    valueBox.Parent = container

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = valueBox

    local boxStroke = Instance.new("UIStroke")
    boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    boxStroke.Color = COLOR_BOX_STROKE
    boxStroke.Thickness = 1
    boxStroke.Parent = valueBox

    local input = Instance.new("TextBox")
    input.Name = "Input"
    input.Size = UDim2.fromScale(1, 1)
    input.BackgroundTransparency = 1
    input.Text = "1"
    input.TextColor3 = Color3.new(1, 1, 1)
    input.Font = FONT_MAIN
    input.TextSize = 13
    input.ClearTextOnFocus = false
    input.Parent = valueBox

    maid:GiveTask(container)
    
    local self = {}
    self.Instance = container

    function self:Destroy()
        maid:Destroy()
    end

    return self
end

return SmoothFactory
