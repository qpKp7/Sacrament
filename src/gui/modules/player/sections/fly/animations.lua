--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")
local Dropdown = Import("gui/modules/components/dropdown") -- A mágica do componente

export type AnimationsUI = {
    Instance: Frame,
    Dropdown: any, -- [NOVO] Exportado para o Orquestrador ler a memória!
    Destroy: (self: AnimationsUI) -> ()
}

local AnimationsFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local FONT_MAIN = Enum.Font.GothamBold

function AnimationsFactory.new(layoutOrder: number?): AnimationsUI
    local maid = Maid.new()

    local row = Instance.new("Frame")
    row.Name = "AnimationsRow"
    row.Size = UDim2.new(1, 0, 0, 45)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder or 1
    row.AutomaticSize = Enum.AutomaticSize.Y
    
    -- [TRUQUE DE ENGENHARIA] ZIndex para o Dropdown abrir por cima de outras coisas
    row.ZIndex = 50 - (layoutOrder or 1)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = row

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 0, 45)
    title.BackgroundTransparency = 1
    title.Text = "Animation"
    title.TextColor3 = COLOR_LABEL
    title.Font = FONT_MAIN
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = row

    -- =========================================================
    -- INSTANCIA O DROPDOWN COMPONENTE
    -- =========================================================
    -- Nota: O nosso componente Dropdown salva o texto (nome). Se o seu script de
    -- Fly precisar do ID da animação depois, você só precisa pegar esse nome salvo
    -- ("Vampire", "Ninja") e procurar o ID dele na sua tabela lá no script de Fly.
    local optionsList = {"None", "Vampire", "Ninja", "Mage", "Toy"}
    local animDrop = Dropdown.new(optionsList, "None")
    
    animDrop.Instance.AnchorPoint = Vector2.new(1, 0)
    animDrop.Instance.Position = UDim2.new(1, 0, 0, 6.5) -- Centraliza na linha de 45px
    animDrop.Instance.Parent = row
    maid:GiveTask(animDrop)

    maid:GiveTask(row)

    local self = {}
    self.Instance = row
    
    -- [O SEGREDO] Entregando o Dropdown para o Orquestrador injetar a memória
    self.Dropdown = animDrop

    function self:Destroy()
        maid:Destroy()
    end

    return self :: AnimationsUI
end

return AnimationsFactory
