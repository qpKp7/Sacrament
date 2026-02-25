--!strict
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type SpeedUI = {
    Instance: Frame,
    Value: number,
    OnChanged: RBXScriptSignal,
    Destroy: (self: SpeedUI) -> ()
}

local SpeedFactory = {}

local COLOR_WHITE = Color3.fromHex("FFFFFF")
local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local COLOR_ACCENT = Color3.fromHex("C80000")
local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_STROKE = Color3.fromHex("333333")
local FONT_MAIN = Enum.Font.GothamBold

function SpeedFactory.new(titleText: string, minVal: number, maxVal: number, defaultVal: number, layoutOrder: number?): SpeedUI
    local maid = Maid.new()
    local self = {}
    self.Value = defaultVal

    local changedEvent = Instance.new("BindableEvent")
    maid:GiveTask(changedEvent)
    self.OnChanged = changedEvent.Event

    local container = Instance.new("Frame")
    container.Name = titleText:gsub(" ", "") .. "Section"
    container.Size = UDim2.new(1, 0, 0, 65)
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 1

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = container

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0.5, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = COLOR_LABEL
    title.Font = FONT_MAIN
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = container

    local inputBg = Instance.new("Frame")
    inputBg.Name = "ValueBg"
    inputBg.Size = UDim2.new(0, 60, 0, 24)
    inputBg.Position = UDim2.new(1, 0, 0, 8)
    inputBg.AnchorPoint = Vector2.new(1, 0)
    inputBg.BackgroundColor3 = COLOR_BG
    inputBg.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = inputBg

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLOR_STROKE
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = inputBg

    local input = Instance.new("TextBox")
    input.Name = "ValueInput"
    input.Size = UDim2.fromScale(1, 1)
    input.BackgroundTransparency = 1
    input.Text = tostring(defaultVal)
    input.TextColor3 = COLOR_WHITE
    input.Font = FONT_MAIN
    input.TextSize = 14
    input.Parent = inputBg

    local track = Instance.new("TextButton")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0, 4)
    track.Position = UDim2.new(0, 0, 1, -15)
    track.BackgroundColor3 = COLOR_STROKE
    track.AutoButtonColor = false
    track.Text = ""
    track.Parent = container

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.fromScale(0.5, 1)
    fill.BackgroundColor3 = COLOR_ACCENT
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.fromOffset(12, 12)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(1, 0, 0.5, 0)
    knob.BackgroundColor3 = COLOR_WHITE
    knob.Parent = fill

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local function updateSliderVisuals(val: number)
        local pct = math.clamp((val - minVal) / (maxVal - minVal), 0, 1)
        fill.Size = UDim2.fromScale(pct, 1)
        input.Text = string.format("%d", val)
    end

    local function setValue(val: number)
        val = math.clamp(val, minVal, maxVal)
        val = math.round(val)
        if self.Value ~= val then
            self.Value = val
            changedEvent:Fire(val)
        end
        updateSliderVisuals(val)
    end

    local isDragging = false

    maid:GiveTask(track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            local ap = track.AbsolutePosition.X
            local as = track.AbsoluteSize.X
            local pct = math.clamp((inp.Position.X - ap) / as, 0, 1)
            setValue(minVal + pct * (maxVal - minVal))
        end
    end))

    maid:GiveTask(UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end))

    maid:GiveTask(RunService.RenderStepped:Connect(function()
        if isDragging then
            local mousePos = UserInputService:GetMouseLocation().X
            local ap = track.AbsolutePosition.X
            local as = track.AbsoluteSize.X
            local pct = math.clamp((mousePos - ap) / as, 0, 1)
            setValue(minVal + pct * (maxVal - minVal))
        end
    end))

    maid:GiveTask(input.FocusLost:Connect(function()
        local num = tonumber(input.Text)
        if num then
            setValue(num)
        else
            setValue(self.Value)
        end
    end))

    setValue(defaultVal)
    maid:GiveTask(container)
    self.Instance = container

    function self:Destroy()
        maid:Destroy()
    end

    return self :: SpeedUI
end

return SpeedFactory
