--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")
local ValueBox = Import("gui/modules/components/valuebox") -- Puxamos a nossa fábrica de inputs!

export type SmoothSection = {
    Instance: Frame,
    ValueBox: any, -- Adicionamos no contrato para o Orquestrador achar
    Destroy: (self: SmoothSection) -> ()
}

local SmoothFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local FONT_MAIN = Enum.Font.GothamBold

function SmoothFactory.new(layoutOrder: number): SmoothSection
    local maid = Maid.new()

    local row = Instance.new("Frame")
    row.Name = "SmoothRow"
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
    lbl.Name = "Label"
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.BorderSizePixel = 0
    lbl.Text = "Smooth"
    lbl.TextColor3 = COLOR_LABEL
    lbl.Font = FONT_MAIN
    lbl.TextSize = 18
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    -- =========================================================
    -- NOSSO COMPONENTE MÁGICO
    -- Default: 0.50 | Min: 0 | Max: 1 | Casas Decimais: 2 | Max Caracteres: 4
    -- =========================================================
    local smoothInput = ValueBox.new(0.50, 0, 1, 2, 4)
    smoothInput.Instance.AnchorPoint = Vector2.new(1, 0.5)
    smoothInput.Instance.Position = UDim2.new(1, 0, 0.5, 0)
    smoothInput.Instance.Parent = row
    maid:GiveTask(smoothInput)

    maid:GiveTask(row)

    local self = {}
    self.Instance = row
    
    -- EXPORTA A VARIÁVEL PARA O ORQUESTRADOR GRUDAR A MEMÓRIA!
    self.ValueBox = smoothInput

    function self:Destroy()
        maid:Destroy()
    end

    return self :: SmoothSection
end

return SmoothFactory
