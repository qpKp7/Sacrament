--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local ToggleButton = SafeImport("gui/modules/components/togglebutton")
local Slider = SafeImport("gui/modules/components/slider")

export type TrailUI = {
    Instance: Frame,
    Destroy: (self: TrailUI) -> ()
}

local TrailFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local FONT_MAIN = Enum.Font.GothamBold

function TrailFactory.new(layoutOrder: number?): TrailUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "TrailSection"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 3

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container

    -- ROW GHOST TRAIL (Padrão Grande)
    local trailRow = Instance.new("Frame")
    trailRow.Name = "GhostTrailRow"
    trailRow.Size = UDim2.new(1, 0, 0, 55)
    trailRow.BackgroundTransparency = 1
    trailRow.LayoutOrder = 1
    trailRow.Parent = container

    local trailPad = Instance.new("UIPadding")
    trailPad.PaddingLeft = UDim.new(0, 20)
    trailPad.PaddingRight = UDim.new(0, 25)
    trailPad.Parent = trailRow

    local trailLabel = Instance.new("TextLabel")
    trailLabel.Name = "Label"
    trailLabel.Size = UDim2.new(0.5, 0, 1, 0)
    trailLabel.BackgroundTransparency = 1
    trailLabel.Text = "Ghost Trail"
    trailLabel.TextColor3 = COLOR_LABEL
    trailLabel.Font = FONT_MAIN
    trailLabel.TextSize = 18
    trailLabel.TextXAlignment = Enum.TextXAlignment.Left
    trailLabel.Parent = trailRow

    local trailToggle = nil
    if ToggleButton and type(ToggleButton.new) == "function" then
        trailToggle = ToggleButton.new()
        trailToggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
        trailToggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        trailToggle.Instance.Parent = trailRow
        maid:GiveTask(trailToggle)
    end

   -- ROW DRIFT STRENGTH (Slider Decimal 0.0 a 10.0)
    local driftRow = Instance.new("Frame")
    driftRow.Name = "DriftRow"
    driftRow.Size = UDim2.new(1, 0, 0, 45) -- Altura simétrica ao Key Hold
    driftRow.BackgroundTransparency = 1
    driftRow.LayoutOrder = 2
    driftRow.Visible = false
    driftRow.Parent = container

    local driftSlider = nil
    if Slider and type(Slider.new) == "function" then
        -- Parâmetros: Título, Mín, Máx, Padrão, Incremento
        driftSlider = Slider.new("Drift Strength", 0.0, 10.0, 0.3, 0.1)
        driftSlider.Instance.AnchorPoint = Vector2.new(0, 0.5)
        driftSlider.Instance.Position = UDim2.fromScale(0, 0.5)
        driftSlider.Instance.Size = UDim2.fromScale(1, 1)
        driftSlider.Instance.Parent = driftRow
        maid:GiveTask(driftSlider)
    end

    if trailToggle then
        maid:GiveTask(trailToggle.Toggled:Connect(function(state: boolean)
            driftRow.Visible = state
        end))
    end

    maid:GiveTask(container)
    local self = {}
    self.Instance = container
    function self:Destroy() maid:Destroy() end
    return self :: TrailUI
end

return TrailFactory
