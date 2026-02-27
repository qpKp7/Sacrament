--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type AimPartSection = {
    Instance: Frame,
    Destroy: (self: AimPartSection) -> ()
}

local AimPartFactory = {}

local COLOR_WHITE = Color3.fromHex("FFFFFF")
local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local COLOR_ACCENT = Color3.fromHex("C80000")
local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_STROKE = Color3.fromHex("333333")
local FONT_MAIN = Enum.Font.GothamBold

function AimPartFactory.new(layoutOrder: number): AimPartSection
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "AimPartSection"
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 1
    container.AutomaticSize = Enum.AutomaticSize.Y

    local headerRow = Instance.new("Frame")
    headerRow.Size = UDim2.new(1, 0, 0, 45)
    headerRow.BackgroundTransparency = 1
    headerRow.Parent = container

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = headerRow

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "Aim Part"
    title.TextColor3 = COLOR_LABEL
    title.Font = FONT_MAIN
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = headerRow

    local btnBg = Instance.new("TextButton")
    btnBg.Size = UDim2.new(0, 130, 0, 32)
    btnBg.AnchorPoint = Vector2.new(1, 0.5)
    btnBg.Position = UDim2.new(1, 0, 0.5, 0)
    btnBg.BackgroundColor3 = COLOR_BG
    btnBg.Text = ""
    btnBg.AutoButtonColor = false
    btnBg.Parent = headerRow

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btnBg

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLOR_STROKE
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = btnBg

    local valText = Instance.new("TextLabel")
    valText.Size = UDim2.new(1, -30, 1, 0)
    valText.Position = UDim2.fromOffset(10, 0)
    valText.BackgroundTransparency = 1
    valText.Text = "Head"
    valText.TextColor3 = COLOR_WHITE
    valText.Font = FONT_MAIN
    valText.TextSize = 14
    valText.TextXAlignment = Enum.TextXAlignment.Left
    valText.Parent = btnBg

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -25, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = ">"
    arrow.TextColor3 = COLOR_WHITE
    arrow.Font = FONT_MAIN
    arrow.TextSize = 14
    arrow.Parent = btnBg

    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(1, 0, 0, 0)
    listFrame.Position = UDim2.new(0, 0, 0, 45)
    listFrame.BackgroundTransparency = 1
    listFrame.Visible = false
    listFrame.AutomaticSize = Enum.AutomaticSize.Y
    listFrame.Parent = container

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = listFrame

    local listPad = Instance.new("UIPadding")
    listPad.PaddingTop = UDim.new(0, 5)
    listPad.PaddingRight = UDim.new(0, 25)
    listPad.Parent = listFrame

    local options = {"Head", "Torso", "Random", "Closest"}

    local isOpen = false
    maid:GiveTask(btnBg.Activated:Connect(function()
        isOpen = not isOpen
        listFrame.Visible = isOpen
        stroke.Color = isOpen and COLOR_ACCENT or COLOR_STROKE
    end))

    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(0, 130, 0, 28)
        optBtn.BackgroundColor3 = COLOR_BG
        optBtn.Text = opt
        optBtn.TextColor3 = (i == 1) and COLOR_ACCENT or COLOR_LABEL
        optBtn.Font = FONT_MAIN
        optBtn.TextSize = 14
        optBtn.LayoutOrder = i
        optBtn.Parent = listFrame

        local optCorner = Instance.new("UICorner")
        optCorner.CornerRadius = UDim.new(0, 4)
        optCorner.Parent = optBtn

        maid:GiveTask(optBtn.Activated:Connect(function()
            valText.Text = opt
            isOpen = false
            listFrame.Visible = false
            stroke.Color = COLOR_STROKE
            
            for _, child in ipairs(listFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child.TextColor3 = (child.Text == opt) and COLOR_ACCENT or COLOR_LABEL
                end
            end
        end))
    end

    maid:GiveTask(container)
    local self = {}
    self.Instance = container
    function self:Destroy()
        maid:Destroy()
    end
    return self :: AimPartSection
end

return AimPartFactory
