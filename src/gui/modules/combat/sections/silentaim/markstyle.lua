--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type MarkStyleSection = {
    Instance: Frame,
    Destroy: (self: MarkStyleSection) -> ()
}

local MarkStyleFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local COLOR_WHITE = Color3.fromHex("FFFFFF")
local COLOR_BOX_BG = Color3.fromHex("1A1A1A")
local COLOR_BOX_BORDER = Color3.fromHex("333333")
local COLOR_HOVER = Color3.fromHex("222222")
local FONT_MAIN = Enum.Font.GothamBold

function MarkStyleFactory.new(layoutOrder: number): MarkStyleSection
    local maid = Maid.new()
    local isDropdownOpen = false
    local options = {"Highlight", "TorsoDot", "BodyOutline", "Notify", "None"}

    local row = Instance.new("Frame")
    row.Name = "MarkStyleRow"
    row.Size = UDim2.new(1, 0, 0, 40)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.LayoutOrder = layoutOrder
    row.ZIndex = 10 - layoutOrder 

    local rowLayout = Instance.new("UIListLayout")
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rowLayout.Parent = row

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.BorderSizePixel = 0
    lbl.Text = "Mark Style"
    lbl.TextColor3 = COLOR_LABEL
    lbl.Font = FONT_MAIN
    lbl.TextSize = 18
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local dropdownCont = Instance.new("Frame")
    dropdownCont.Size = UDim2.new(0, 120, 0, 32)
    dropdownCont.Position = UDim2.new(1, 0, 0.5, 0)
    dropdownCont.AnchorPoint = Vector2.new(1, 0.5)
    dropdownCont.BackgroundColor3 = COLOR_BOX_BG
    dropdownCont.BorderSizePixel = 0
    dropdownCont.ZIndex = row.ZIndex
    dropdownCont.Parent = row

    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 6)
    dropdownCorner.Parent = dropdownCont

    local dropdownStroke = Instance.new("UIStroke")
    dropdownStroke.Color = COLOR_BOX_BORDER
    dropdownStroke.Thickness = 1
    dropdownStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    dropdownStroke.Parent = dropdownCont

    local mainBtn = Instance.new("TextButton")
    mainBtn.Size = UDim2.fromScale(1, 1)
    mainBtn.BackgroundColor3 = COLOR_BOX_BG
    mainBtn.BackgroundTransparency = 1
    mainBtn.BorderSizePixel = 0
    mainBtn.Text = options[1]
    mainBtn.TextColor3 = COLOR_WHITE
    mainBtn.Font = FONT_MAIN
    mainBtn.TextSize = 14
    mainBtn.ZIndex = row.ZIndex + 1
    mainBtn.Parent = dropdownCont

    local listCont = Instance.new("Frame")
    listCont.Name = "OptionsList"
    listCont.Size = UDim2.new(1, 0, 0, 0)
    listCont.Position = UDim2.new(0, 0, 1, 4)
    listCont.BackgroundColor3 = COLOR_BOX_BG
    listCont.BorderSizePixel = 0
    listCont.AutomaticSize = Enum.AutomaticSize.Y
    listCont.Visible = false
    listCont.ZIndex = row.ZIndex + 2
    listCont.Parent = dropdownCont

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 6)
    listCorner.Parent = listCont

    local listStroke = Instance.new("UIStroke")
    listStroke.Color = COLOR_BOX_BORDER
    listStroke.Thickness = 1
    listStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    listStroke.Parent = listCont

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listCont

    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 32)
        optBtn.BackgroundColor3 = COLOR_BOX_BG
        optBtn.BackgroundTransparency = 1
        optBtn.BorderSizePixel = 0
        optBtn.Text = opt
        optBtn.TextColor3 = COLOR_WHITE
        optBtn.Font = FONT_MAIN
        optBtn.TextSize = 14
        optBtn.LayoutOrder = i
        optBtn.ZIndex = listCont.ZIndex + 1
        optBtn.Parent = listCont

        maid:GiveTask(optBtn.MouseEnter:Connect(function()
            optBtn.BackgroundTransparency = 0
            optBtn.BackgroundColor3 = COLOR_HOVER
        end))

        maid:GiveTask(optBtn.MouseLeave:Connect(function()
            optBtn.BackgroundTransparency = 1
        end))

        maid:GiveTask(optBtn.MouseButton1Click:Connect(function()
            mainBtn.Text = opt
            isDropdownOpen = false
            listCont.Visible = false
        end))
    end

    maid:GiveTask(mainBtn.MouseButton1Click:Connect(function()
        isDropdownOpen = not isDropdownOpen
        listCont.Visible = isDropdownOpen
    end))

    maid:GiveTask(row)

    local self = {}
    self.Instance = row

    function self:Destroy()
        maid:Destroy()
    end

    return self :: MarkStyleSection
end

return MarkStyleFactory
