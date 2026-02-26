--!strict
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function()
        return Import(path)
    end)
    if not success then return nil end
    return result
end

local ToggleButton = SafeImport("gui/modules/components/togglebutton")

export type SpeedUI = {
    Instance: Frame,
    Destroy: (self: SpeedUI) -> ()
}

local SpeedFactory = {}

local COLOR_WHITE = Color3.fromHex("FFFFFF")
local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local COLOR_ACCENT = Color3.fromHex("C80000")
local COLOR_STROKE = Color3.fromHex("333333")
local FONT_MAIN = Enum.Font.GothamBold

function SpeedFactory.new(layoutOrder: number?): SpeedUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "SpeedSection"
    container.Size = UDim2.new(1, 0, 0, 0) -- Tamanho inicial 0
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 1
    container.AutomaticSize = Enum.AutomaticSize.Y -- Expande automaticamente

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container

    local toggleRow = Instance.new("Frame")
    toggleRow.Name = "FlySpeedToggleRow"
    toggleRow.Size = UDim2.new(1, 0, 0, 45)
    toggleRow.BackgroundTransparency = 1
    toggleRow.LayoutOrder = 1
    toggleRow.Parent = container

    local togglePad = Instance.new("UIPadding")
    togglePad.PaddingLeft = UDim.new(0, 20)
    togglePad.PaddingRight = UDim.new(0, 25)
    togglePad.Parent = toggleRow

    local toggleTitle = Instance.new("TextLabel")
    toggleTitle.Size = UDim2.new(0.5, 0, 1, 0)
    toggleTitle.BackgroundTransparency = 1
    toggleTitle.Text = "Fly Speed"
    toggleTitle.TextColor3 = COLOR_LABEL
    toggleTitle.Font = FONT_MAIN
    toggleTitle.TextSize = 18
    toggleTitle.TextXAlignment = Enum.TextXAlignment.Left
    toggleTitle.Parent = toggleRow

    local toggleObj = nil
    if ToggleButton and type(ToggleButton.new) == "function" then
        toggleObj = ToggleButton.new()
        toggleObj.Instance.AnchorPoint = Vector2.new(1, 0.5)
        toggleObj.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        toggleObj.Instance.Parent = toggleRow
        maid:GiveTask(toggleObj)
    end

    local sliderRow = Instance.new("Frame")
    sliderRow.Name = "FlySpeedSliderRow"
    sliderRow.Size = UDim2.new(1, 0, 0, 45)
    sliderRow.BackgroundTransparency = 1
    sliderRow.LayoutOrder = 2
    sliderRow.Visible = false
    sliderRow.Parent = container

    local sliderPad = Instance.new("UIPadding")
    sliderPad.PaddingLeft = UDim.new(0, 20)
    sliderPad.PaddingRight = UDim.new(0, 25)
    sliderPad.Parent = sliderRow

    local sliderTitle = Instance.new("TextLabel")
    sliderTitle.Size = UDim2.new(0.5, 0, 1, 0)
    sliderTitle.BackgroundTransparency = 1
    sliderTitle.Text = "Speed"
    sliderTitle.TextColor3 = COLOR_LABEL
    sliderTitle.Font = FONT_MAIN
    sliderTitle.TextSize = 18
    sliderTitle.TextXAlignment = Enum.TextXAlignment.Left
    sliderTitle.Parent = sliderRow

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(0, 130, 0, 4)
    track.AnchorPoint = Vector2.new(1, 0.5)
    track.Position = UDim2.new(1, 0, 0.5, 0)
    track.BackgroundColor3 = COLOR_STROKE
    track.AutoButtonColor = false
    track.Text = ""
    track.Parent = sliderRow

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(32 / 300, 1) -- Valor inicial 32 (de 0-300)
    fill.BackgroundColor3 = COLOR_ACCENT
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(12, 12)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(1, 0, 0.5, 0)
    knob.BackgroundColor3 = COLOR_WHITE
    knob.Parent = fill
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local isDragging = false
    maid:GiveTask(track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            local pct = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.fromScale(pct, 1)
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
            local pct = math.clamp((mousePos - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.fromScale(pct, 1)
        end
    end))

    if toggleObj then
        maid:GiveTask(toggleObj.Toggled:Connect(function(state: boolean)
            sliderRow.Visible = state
            container.Size = state and UDim2.new(1, 0, 0, 90) or UDim2.new(1, 0, 0, 45) -- Ajusta tamanho
        end))
    end

    maid:GiveTask(container)
    local self = {}
    self.Instance = container
    function self:Destroy()
        maid:Destroy()
    end
    return self :: SpeedUI
end

return SpeedFactory
