--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")
local Dropdown = Import("gui/modules/components/dropdown") -- A mágica do componente

export type StyleUI = {
    Instance: Frame,
    Dropdown: any, -- [NOVO] Exportado para o Orquestrador
    Destroy: (self: StyleUI) -> ()
}

local StyleFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local FONT_MAIN = Enum.Font.GothamBold

function StyleFactory.new(layoutOrder: number?): StyleUI
    local maid = Maid.new()

    local row = Instance.new("Frame")
    row.Name = "StyleRow"
    row.Size = UDim2.new(1, 0, 0, 45)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder or 1
    row.AutomaticSize = Enum.AutomaticSize.Y
    
    -- ZIndex para garantir que o menu dropdown fique por cima dos botões de baixo
    row.ZIndex = 50 - (layoutOrder or 1)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = row

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 0, 45)
    title.BackgroundTransparency = 1
    title.Text = "Draw Style"
    title.TextColor3 = COLOR_LABEL
    title.Font = FONT_MAIN
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = row

    -- =========================================================
    -- INSTANCIA O DROPDOWN COMPONENTE
    -- =========================================================
    local optionsList = {"Highlight", "Outline", "Box", "Chams"}
    local styleDrop = Dropdown.new(optionsList, "Highlight")
    
    styleDrop.Instance.AnchorPoint = Vector2.new(1, 0)
    styleDrop.Instance.Position = UDim2.new(1, 0, 0, 6.5)
    styleDrop.Instance.Parent = row
    maid:GiveTask(styleDrop)

    maid:GiveTask(row)

    local self = {}
    self.Instance = row
    
    -- [O SEGREDO] Entregando a chave pro Orquestrador ler a memória!
    self.Dropdown = styleDrop

    function self:Destroy()
        maid:Destroy()
    end

    return self :: StyleUI
end

return StyleFactory
