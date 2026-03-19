--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")
local Dropdown = Import("gui/modules/components/dropdown") -- Importa a fábrica universal!

export type MarkStyleSection = {
    Instance: Frame,
    Dropdown: any, -- Exportado para o Orquestrador ler a memória
    Destroy: (self: MarkStyleSection) -> ()
}

local MarkStyleFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local FONT_MAIN = Enum.Font.GothamBold

function MarkStyleFactory.new(layoutOrder: number): MarkStyleSection
    local maid = Maid.new()

    local row = Instance.new("Frame")
    row.Name = "MarkStyleRow"
    row.Size = UDim2.new(1, 0, 0, 45)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder or 1
    row.AutomaticSize = Enum.AutomaticSize.Y
    
    -- [TRUQUE DE ENGENHARIA] ZIndex para a lista abrir por cima de tudo
    row.ZIndex = 50 - (layoutOrder or 1)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = row

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 0, 45)
    title.BackgroundTransparency = 1
    title.Text = "Mark Style"
    title.TextColor3 = COLOR_LABEL
    title.Font = FONT_MAIN
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = row

    -- =========================================================
    -- INSTANCIA O DROPDOWN COMPONENTE
    -- =========================================================
    local optionsList = {"Highlight", "TorsoDot", "BodyOutline", "Notify", "None"}
    local markStyleDrop = Dropdown.new(optionsList, "Highlight")
    
    markStyleDrop.Instance.AnchorPoint = Vector2.new(1, 0)
    markStyleDrop.Instance.Position = UDim2.new(1, 0, 0, 6.5) -- Centraliza os 32px nos 45px
    markStyleDrop.Instance.Parent = row
    maid:GiveTask(markStyleDrop)

    maid:GiveTask(row)

    local self = {}
    self.Instance = row
    
    -- [O SEGREDO] Entregando o Dropdown para o Orquestrador injetar a memória
    self.Dropdown = markStyleDrop 

    function self:Destroy()
        maid:Destroy()
    end

    return self :: MarkStyleSection
end

return MarkStyleFactory
