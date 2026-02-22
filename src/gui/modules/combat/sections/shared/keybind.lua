--!strict
local UserInputService = game:GetService("UserInputService")
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type KeybindSection = {
    Instance: Frame,
    Destroy: (self: KeybindSection) -> ()
}

local KeybindFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local COLOR_WHITE = Color3.fromHex("FFFFFF")
local COLOR_RED_DARK = Color3.fromHex("680303")
local COLOR_BOX_BG = Color3.fromHex("1A1A1A")
local COLOR_BOX_BORDER = Color3.fromHex("333333")
local FONT_MAIN = Enum.Font.GothamBold

local function formatKeyName(name: string): string
    local map = {
        One="1", Two="2", Three="3", Four="4", Five="5",
        Six="6", Seven="7", Eight="8", Nine="9", Zero="0",
        MouseButton1="MB1", MouseButton2="MB2", MouseButton3="MB3",
        MouseButton4="MB4", MouseButton5="MB5"
    }
    return map[name] or name
end

function KeybindFactory.new(layoutOrder: number): KeybindSection
    local maid = Maid.new()
    local capturingKey = false

    local row = Instance.new("Frame")
    row.Name = "KeyRow"
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
    pad.PaddingRight = UDim.new(0, 50)
    pad.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.BorderSizePixel = 0
    lbl.Text = "KEY"
    lbl.TextColor3 = COLOR_LABEL
    lbl.Font = FONT_MAIN
    lbl.TextSize = 14
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
    
    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.fromScale(1, 1)
    keyBtn.BackgroundColor3 = COLOR_BOX_BG
    keyBtn.BackgroundTransparency = 1
    keyBtn.BorderSizePixel = 0
    keyBtn.Text = "NONE"
    keyBtn.TextColor3 = COLOR_RED_DARK
    keyBtn.Font = FONT_MAIN
    keyBtn.TextSize = 16
    keyBtn.Parent = inputCont

    maid:GiveTask(keyBtn.MouseButton1Click:Connect(function()
        if capturingKey then return end
        capturingKey = true
        keyBtn.Text = "..."
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                keyBtn.Text = formatKeyName(input.KeyCode.Name)
                capturingKey = false
                connection:Disconnect()
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.MouseButton2 or
                   input.UserInputType == Enum.UserInputType.MouseButton3 or
                   input.UserInputType.Name:match("Mouse") then
                keyBtn.Text = formatKeyName(input.UserInputType.Name)
                capturingKey = false
                connection:Disconnect()
            end
        end)
        
        maid:GiveTask(connection)
    end))

    maid:GiveTask(row)

    local self = {}
    self.Instance = row

    function self:Destroy()
        maid:Destroy()
    end

    return self
end

return KeybindFactory
