--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type PredictSection = {
    Instance: Frame,
    Destroy: (self: PredictSection) -> ()
}

local PredictFactory = {}

local COLOR_BG = Color3.fromRGB(14, 14, 14)
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

function PredictFactory.new(layoutOrder: number): PredictSection
    local maid = Maid.new()

    local row = Instance.new("Frame")
    row.Name = "PredictRow"
    row.Size = UDim2.new(1, 0, 0, 40)
    row.BackgroundColor3 = COLOR_BG
    row.BorderSizePixel = 0
    row.LayoutOrder = layoutOrder

    local rowLayout = Instance.new("UIListLayout")
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rowLayout.Padding = UDim.new(0, 10)
    rowLayout.Parent = row

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.BackgroundColor3 = COLOR_BG
    lbl.BorderSizePixel = 0
    lbl.Text = "Predict"
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

    local predBox = Instance.new("TextBox")
    predBox.Size = UDim2.fromScale(1, 1)
    predBox.BackgroundColor3 = COLOR_BOX_BG
    predBox.BackgroundTransparency = 1
    predBox.BorderSizePixel = 0
    predBox.Text = "0.000"
    predBox.TextColor3 = COLOR_WHITE
    predBox.Font = FONT_MAIN
    predBox.TextSize = 16
    predBox.ClearTextOnFocus = false
    predBox.Parent = inputCont
    enforceDecimalBox(predBox, "0.000", 3, 5)

    maid:GiveTask(row)

    local self = {}
    self.Instance = row

    function self:Destroy()
        maid:Destroy()
    end

    return self
end

return PredictFactory
