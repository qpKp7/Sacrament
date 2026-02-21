--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type SmoothnessSection = {
    Instance: Frame,
    Destroy: (self: SmoothnessSection) -> ()
}

local SmoothnessFactory = {}

local COLOR_WHITE = Color3.fromHex("FFFFFF")
local COLOR_BOX_BG = Color3.fromHex("1A1A1A")
local COLOR_BOX_BORDER = Color3.fromHex("333333")
local FONT_MAIN = Enum.Font.GothamBold

local function enforceDecimalBox(box: TextBox, default: string, decimals: number, maxLen: number)
    box:GetPropertyChangedSignal("Text"):Connect(function()
        local text = box.Text
        local clean = string.gsub(text, "[^%d%.]", "")
        local dots = 0
        
        clean = string.gsub(clean, "%.", function()
            dots = dots + 1
            return dots == 1 and "." or ""
        end)
        
        if #clean > maxLen then
            clean = string.sub(clean, 1, maxLen)
        end
        
        if box.Text ~= clean then
            box.Text = clean
        end
    end)
    
    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if not num then
            box.Text = default
            return
        end
        
        num = math.clamp(num, 0, 1)
        box.Text = string.format("%." .. tostring(decimals) .. "f", num)
    end)
end

function SmoothnessFactory.new(layoutOrder: number): SmoothnessSection
    local maid = Maid.new()

    local row = Instance.new("Frame")
    row.Name = "SmoothnessRow"
    row.Size = UDim2.new(1, 0, 0, 40)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.LayoutOrder = layoutOrder

    local rowLayout = Instance.new("UIListLayout")
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rowLayout.Parent = row

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 20)
    pad.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.BorderSizePixel = 0
    lbl.Text = "Smoothness"
    lbl.TextColor3 = COLOR_WHITE
    lbl.Font = FONT_MAIN
    lbl.TextSize = 16
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local inputCont = Instance.new("Frame")
    inputCont.Size = UDim2.new(0, 120, 0, 32)
    inputCont.Position = UDim2.new(1, 0, 0.5, 0)
    inputCont.AnchorPoint = Vector2.new(1, 0.5)
    inputCont.BackgroundColor3 = COLOR_BOX_BG
    inputCont.BorderSizePixel = 0
    inputCont.Parent = row

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = inputCont

    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = COLOR_BOX_BORDER
    inputStroke.Thickness = 1
    inputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    inputStroke.Parent = inputCont

    local smoothBox = Instance.new("TextBox")
    smoothBox.Size = UDim2.fromScale(1, 1)
    smoothBox.BackgroundColor3 = COLOR_BOX_BG
    smoothBox.BackgroundTransparency = 1
    smoothBox.BorderSizePixel = 0
    smoothBox.Text = "0.50"
    smoothBox.TextColor3 = COLOR_WHITE
    smoothBox.Font = FONT_MAIN
    smoothBox.TextSize = 16
    smoothBox.ClearTextOnFocus = false
    smoothBox.Parent = inputCont
    enforceDecimalBox(smoothBox, "0.50", 2, 4)

    maid:GiveTask(row)

    local self = {}
    self.Instance = row

    function self:Destroy()
        maid:Destroy()
    end

    return self
end

return SmoothnessFactory
