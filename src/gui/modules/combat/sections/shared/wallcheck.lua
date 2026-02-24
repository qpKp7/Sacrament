--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

-- Proteção de Módulo: Isolamento de dependências via pcall
local function SafeImport(path: string): any?
    local success, result = pcall(function()
        return Import(path)
    end)
    if not success then
        warn("[Sacrament] Falha ao importar dependência em WallCheck: " .. path)
        return nil
    end
    return result
end

local ToggleButton = SafeImport("gui/modules/components/togglebutton")

export type WallCheckSection = {
    Instance: Frame,
    Destroy: (self: WallCheckSection) -> ()
}

local WallCheckFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local FONT_MAIN = Enum.Font.GothamBold

function WallCheckFactory.new(layoutOrder: number): WallCheckSection
    local maid = Maid.new()

    local row = Instance.new("Frame")
    row.Name = "WallCheckRow"
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
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.BorderSizePixel = 0
    lbl.Text = "Wall Check"
    lbl.TextColor3 = COLOR_LABEL
    lbl.Font = FONT_MAIN
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local toggleCont = Instance.new("Frame")
    toggleCont.Size = UDim2.new(0, 120, 0, 32)
    toggleCont.Position = UDim2.new(1, 0, 0.5, 0)
    toggleCont.AnchorPoint = Vector2.new(1, 0.5)
    toggleCont.BackgroundTransparency = 1
    toggleCont.Parent = row

    if ToggleButton and type(ToggleButton.new) == "function" then
        local toggle = ToggleButton.new()
        toggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
        toggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        toggle.Instance.Parent = toggleCont
        maid:GiveTask(toggle)
    end

    maid:GiveTask(row)

    local self = {}
    self.Instance = row

    function self:Destroy()
        maid:Destroy()
    end

    return self :: WallCheckSection
end

return WallCheckFactory
