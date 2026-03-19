--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")
local Dropdown = Import("gui/modules/components/dropdown") -- Importa a nossa fábrica!

export type AimPartSection = {
    Instance: Frame,
    Dropdown: any, -- Exportado para o Orquestrador ler a memória!
    Destroy: (self: AimPartSection) -> ()
}

local AimPartFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local FONT_MAIN = Enum.Font.GothamBold

function AimPartFactory.new(layoutOrder: number): AimPartSection
    local maid = Maid.new()

    local row = Instance.new("Frame")
    row.Name = "AimPartRow"
    row.Size = UDim2.new(1, 0, 0, 45)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder or 1
    row.AutomaticSize = Enum.AutomaticSize.Y
    
    -- [TRUQUE DE ENGENHARIA] Força a linha a renderizar acima das outras
    -- Isso garante que a lista Dropdown cubra os botões de baixo sem sumir!
    row.ZIndex = 50 - (layoutOrder or 1)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = row

    -- Título fixo no topo da linha
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 0, 45) 
    title.BackgroundTransparency = 1
    title.Text = "Aim Part"
    title.TextColor3 = COLOR_LABEL
    title.Font = FONT_MAIN
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = row

    -- =========================================================
    -- INSTANCIA O DROPDOWN COMPONENTE
    -- =========================================================
    local optionsList = {"Head", "Torso", "Random", "Closest"}
    local aimPartDrop = Dropdown.new(optionsList, "Head")
    
    aimPartDrop.Instance.AnchorPoint = Vector2.new(1, 0)
    aimPartDrop.Instance.Position = UDim2.new(1, 0, 0, 6.5) -- Centraliza os 32px nos 45px da linha
    aimPartDrop.Instance.Parent = row
    maid:GiveTask(aimPartDrop)

    maid:GiveTask(row)

    local self = {}
    self.Instance = row
    
    -- [O SEGREDO] Entregando o Dropdown para o Orquestrador injetar a memória
    self.Dropdown = aimPartDrop 

    function self:Destroy()
        maid:Destroy()
    end

    return self :: AimPartSection
end

return AimPartFactory
