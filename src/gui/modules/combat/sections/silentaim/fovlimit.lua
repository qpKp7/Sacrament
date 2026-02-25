--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

-- Proteção de Módulo: Isolamento de dependências via pcall
local function SafeImport(path: string): any?
    local success, result = pcall(function()
        return Import(path)
    end)
    if not success then
        warn("[Sacrament] Falha ao importar dependência em FovLimit: " .. path)
        return nil
    end
    return result
end

local Slider = SafeImport("gui/modules/components/slider")
local ToggleButton = SafeImport("gui/modules/components/togglebutton")

export type FovLimitSection = {
    Instance: Frame,
    Destroy: (self: FovLimitSection) -> ()
}

local FovLimitFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local FONT_MAIN = Enum.Font.GothamBold

function FovLimitFactory.new(layoutOrder: number): FovLimitSection
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "FovLimitContainer"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.LayoutOrder = layoutOrder
    container.AutomaticSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = container

    if Slider and type(Slider.new) == "function" then
        local slider = Slider.new("FOV Limit", 0, 500, 150, 1)
        slider.Instance.LayoutOrder = 1
        slider.Instance.Parent = container
        maid:GiveTask(slider)
    end

    local toggleRow = Instance.new("Frame")
    toggleRow.Name = "ShowFovRow"
    toggleRow.Size = UDim2.new(1, 0, 0, 40)
    toggleRow.BackgroundTransparency = 1
    toggleRow.BorderSizePixel = 0
    toggleRow.LayoutOrder = 2
    toggleRow.Parent = container

    local toggleLayout = Instance.new("UIListLayout")
    toggleLayout.FillDirection = Enum.FillDirection.Horizontal
    toggleLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    toggleLayout.SortOrder = Enum.SortOrder.LayoutOrder
    toggleLayout.Parent = toggleRow

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = toggleRow

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.BorderSizePixel = 0
    lbl.Text = "Show FOV Circle"
    lbl.TextColor3 = COLOR_LABEL
    lbl.Font = FONT_MAIN
    lbl.TextSize = 18
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = toggleRow

    local toggleCont = Instance.new("Frame")
    toggleCont.Size = UDim2.new(0, 120, 0, 32)
    toggleCont.Position = UDim2.new(1, 0, 0.5, 0)
    toggleCont.AnchorPoint = Vector2.new(1, 0.5)
    toggleCont.BackgroundTransparency = 1
    toggleCont.Parent = toggleRow

    if ToggleButton and type(ToggleButton.new) == "function" then
        local toggle = ToggleButton.new()
        toggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
        toggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        toggle.Instance.Parent = toggleCont
        maid:GiveTask(toggle)
    end

    maid:GiveTask(container)

    local self = {}
    self.Instance = container

    function self:Destroy()
        maid:Destroy()
    end

    return self :: FovLimitSection
end

return FovLimitFactory
