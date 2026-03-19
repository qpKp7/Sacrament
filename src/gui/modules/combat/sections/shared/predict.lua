--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")
local ValueBox = Import("gui/modules/components/valuebox") -- Importando a fábrica!

export type PredictSection = {
    Instance: Frame,
    ValueBox: any, -- Exportado para o Orquestrador
    Destroy: (self: PredictSection) -> ()
}

local PredictFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local FONT_MAIN = Enum.Font.GothamBold

function PredictFactory.new(layoutOrder: number): PredictSection
    local maid = Maid.new()

    local row = Instance.new("Frame")
    row.Name = "PredictRow"
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
    lbl.Text = "Predict"
    lbl.TextColor3 = COLOR_LABEL
    lbl.Font = FONT_MAIN
    lbl.TextSize = 18
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    -- =========================================================
    -- NOSSO COMPONENTE MÁGICO
    -- Default: 0.135 | Min: 0 | Max: 1 | Casas Decimais: 3 | Max Caracteres: 5
    -- =========================================================
    local predictInput = ValueBox.new(0.135, 0, 1, 3, 5)
    predictInput.Instance.AnchorPoint = Vector2.new(1, 0.5)
    predictInput.Instance.Position = UDim2.new(1, 0, 0.5, 0)
    predictInput.Instance.Parent = row
    maid:GiveTask(predictInput)

    maid:GiveTask(row)

    local self = {}
    self.Instance = row
    
    -- EXPORTA A VARIÁVEL PARA O ORQUESTRADOR!
    self.ValueBox = predictInput

    function self:Destroy()
        maid:Destroy()
    end

    return self :: PredictSection
end

return PredictFactory
