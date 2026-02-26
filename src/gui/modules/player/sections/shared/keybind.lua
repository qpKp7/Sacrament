--!strict
local UserInputService = game:GetService("UserInputService")

local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type KeybindUI = {
    Instance: Frame,
    Destroy: (self: KeybindUI) -> ()
}

local KeybindFactory = {}

local COLOR_WHITE = Color3.fromHex("FFFFFF")
local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local COLOR_ACCENT = Color3.fromHex("C80000")
local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_STROKE = Color3.fromHex("333333")
local FONT_MAIN = Enum.Font.GothamBold

function KeybindFactory.new(layoutOrder: number?): KeybindUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "KeybindSection"
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 1

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = container

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "KEY"
    title.TextColor3 = COLOR_LABEL
    title.Font = FONT_MAIN
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = container

    local btnBg = Instance.new("Frame")
    btnBg.Name = "ButtonBg"
    btnBg.Size = UDim2.new(0, 130, 0, 32)
    btnBg.AnchorPoint = Vector2.new(1, 0.5)
    btnBg.Position = UDim2.new(1, 0, 0.5, 0)
    btnBg.BackgroundColor3 = COLOR_BG
    btnBg.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btnBg

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLOR_STROKE
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = btnBg

    local bindBtn = Instance.new("TextButton")
    bindBtn.Name = "BindButton"
    bindBtn.Size = UDim2.fromScale(1, 1)
    bindBtn.BackgroundTransparency = 1
    bindBtn.Text = "NONE"
    bindBtn.TextColor3 = COLOR_ACCENT
    bindBtn.Font = FONT_MAIN
    bindBtn.TextSize = 14
    bindBtn.Parent = btnBg

    local isListening = false
    local currentKey: Enum.KeyCode? = nil

    local function updateVisual()
        if isListening then
            bindBtn.Text = "...?"
            bindBtn.TextColor3 = COLOR_ACCENT
            stroke.Color = COLOR_ACCENT
        else
            stroke.Color = COLOR_STROKE
            if currentKey then
                bindBtn.Text = currentKey.Name:upper()
                bindBtn.TextColor3 = COLOR_WHITE
            else
                bindBtn.Text = "NONE"
                bindBtn.TextColor3 = COLOR_ACCENT
            end
        end
    end

    maid:GiveTask(bindBtn.Activated:Connect(function()
        if isListening then return end
        isListening = true
        updateVisual()
    end))

    maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not isListening then return end
        
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
                currentKey = nil
            else
                currentKey = input.KeyCode
            end
            isListening = false
            updateVisual()
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
            isListening = false
            updateVisual()
        end
    end))

    maid:GiveTask(container)

    local self = {}
    self.Instance = container

    function self:Destroy()
        maid:Destroy()
    end

    return self :: KeybindUI
end

return KeybindFactory
