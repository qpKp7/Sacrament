--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local ToggleButton = SafeImport("gui/modules/components/togglebutton")

export type TrailUI = {
    Instance: Frame,
    Destroy: (self: TrailUI) -> ()
}

local TrailFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local COLOR_BOX_BG = Color3.fromHex("1A1A1A")
local COLOR_BOX_BORDER = Color3.fromHex("333333")
local FONT_MAIN = Enum.Font.GothamBold

function TrailFactory.new(layoutOrder: number?): TrailUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "TrailSection"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 1

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 15)
    layout.Parent = container

    local trailRow = Instance.new("Frame")
    trailRow.Name = "GhostTrailRow"
    trailRow.Size = UDim2.new(1, 0, 0, 24)
    trailRow.BackgroundTransparency = 1
    trailRow.LayoutOrder = 1
    trailRow.Parent = container

    local trailLabel = Instance.new("TextLabel")
    trailLabel.Name = "Label"
    trailLabel.Size = UDim2.new(0.5, 0, 1, 0)
    trailLabel.Position = UDim2.fromOffset(20, 0) -- Margem esquerda de 20px cravada
    trailLabel.BackgroundTransparency = 1
    trailLabel.Text = "Ghost Trail"
    trailLabel.TextColor3 = COLOR_LABEL
    trailLabel.Font = FONT_MAIN
    trailLabel.TextSize = 14
    trailLabel.TextXAlignment = Enum.TextXAlignment.Left
    trailLabel.Parent = trailRow

    local toggleWrapper = Instance.new("Frame")
    toggleWrapper.Name = "ToggleWrapper"
    toggleWrapper.Size = UDim2.new(0, 40, 1, 0)
    toggleWrapper.AnchorPoint = Vector2.new(1, 0.5)
    toggleWrapper.Position = UDim2.new(1, -25, 0.5, 0) -- Margem direita de 25px cravada
    toggleWrapper.BackgroundTransparency = 1
    toggleWrapper.Parent = trailRow

    local trailToggle = nil
    if ToggleButton and type(ToggleButton.new) == "function" then
        trailToggle = ToggleButton.new()
        trailToggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
        trailToggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        trailToggle.Instance.Parent = toggleWrapper
        maid:GiveTask(trailToggle)
    end

    local driftRow = Instance.new("Frame")
    driftRow.Name = "DriftRow"
    driftRow.Size = UDim2.new(1, 0, 0, 24)
    driftRow.BackgroundTransparency = 1
    driftRow.LayoutOrder = 2
    driftRow.Visible = false
    driftRow.Parent = container

    local driftLabel = Instance.new("TextLabel")
    driftLabel.Name = "Label"
    driftLabel.Size = UDim2.new(0.5, 0, 1, 0)
    driftLabel.Position = UDim2.fromOffset(20, 0) -- Margem esquerda de 20px cravada
    driftLabel.BackgroundTransparency = 1
    driftLabel.Text = "Drift Strength"
    driftLabel.TextColor3 = COLOR_LABEL
    driftLabel.Font = FONT_MAIN
    driftLabel.TextSize = 14
    driftLabel.TextXAlignment = Enum.TextXAlignment.Left
    driftLabel.Parent = driftRow

    local inputCont = Instance.new("Frame")
    inputCont.Name = "InputWrapper"
    inputCont.Size = UDim2.new(0, 50, 1, 0)
    inputCont.AnchorPoint = Vector2.new(1, 0.5)
    inputCont.Position = UDim2.new(1, -25, 0.5, 0) -- Margem direita de 25px cravada
    inputCont.BackgroundColor3 = COLOR_BOX_BG
    inputCont.Parent = driftRow

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = inputCont

    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = COLOR_BOX_BORDER
    inputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    inputStroke.Parent = inputCont

    local driftInput = Instance.new("TextBox")
    driftInput.Size = UDim2.fromScale(1, 1)
    driftInput.BackgroundTransparency = 1
    driftInput.Text = "0.5"
    driftInput.TextColor3 = COLOR_LABEL
    driftInput.Font = FONT_MAIN
    driftInput.TextSize = 12
    driftInput.Parent = inputCont

    if trailToggle then
        maid:GiveTask(trailToggle.Toggled:Connect(function(state: boolean)
            driftRow.Visible = state
        end))
    end

    maid:GiveTask(driftInput:GetPropertyChangedSignal("Text"):Connect(function()
        local text = driftInput.Text
        local filtered = text:gsub("[^%d%.]", "")
        
        local _, dotCount = filtered:gsub("%.", "%.")
        if dotCount > 1 then
            filtered = text:sub(1, text:len() - 1)
        end

        if filtered:len() > 3 then
            filtered = filtered:sub(1, 3)
        end

        local num = tonumber(filtered)
        if num and num > 1.0 then
            filtered = "1.0"
        end

        if driftInput.Text ~= filtered then
            driftInput.Text = filtered
        end
    end))

    maid:GiveTask(driftInput.FocusLost:Connect(function()
        local num = tonumber(driftInput.Text)
        if not num then
            driftInput.Text = "0.5"
        elseif num < 0 then
            driftInput.Text = "0.0"
        elseif num > 1.0 then
            driftInput.Text = "1.0"
        end
    end))

    maid:GiveTask(container)
    local self = {}
    self.Instance = container
    function self:Destroy() maid:Destroy() end
    return self :: TrailUI
end

return TrailFactory
