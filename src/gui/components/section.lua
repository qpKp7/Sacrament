-- src/gui/components/section.lua
-- Cria seções padronizadas da GUI (título + divider vermelho + container de conteúdo)
-- Usado para PVP CONTROLS, CONFIGS, TARGET INFO, etc.

local Section = {}

local Helpers = require(script.Parent.helpers)

-- ================================================
-- Cria uma seção completa
-- Parâmetros:
--   parent: Frame onde a seção será colocada (geralmente MainFrame.Content)
--   titleText: string - nome da seção (ex: "PVP CONTROLS")
-- Retorna: o Frame "Content" interno (para adicionar toggles/inputs)
-- ================================================
function Section.Create(parent, titleText)
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Name = titleText:gsub(" ", "") .. "Section"
    sectionFrame.BackgroundTransparency = 1
    sectionFrame.Size = UDim2.new(1, 0, 0, 0)
    sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
    sectionFrame.Parent = parent

    -- Título da seção
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "SectionTitle"
    titleLabel.Size = UDim2.new(1, 0, 0, 22)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = titleText
    titleLabel.TextColor3 = Helpers.COLORS.TextPrimary
    titleLabel.TextSize = 15
    titleLabel.Font = Helpers.FONTS.Section
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.Parent = sectionFrame

    -- Linha divisória vermelha sutil
    Helpers.Divider(sectionFrame, 24)

    -- Container para os elementos da seção (toggles, inputs, etc.)
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, 0, 0, 0)
    contentFrame.Position = UDim2.new(0, 0, 0, 30)
    contentFrame.BackgroundTransparency = 1
    contentFrame.AutomaticSize = Enum.AutomaticSize.Y
    contentFrame.Parent = sectionFrame

    -- Layout vertical com espaçamento entre itens
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 10)  -- espaçamento entre toggles/inputs
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    listLayout.Parent = contentFrame

    -- Padding lateral sutil (para não colar na borda)
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 4)
    padding.PaddingRight = UDim.new(0, 4)
    padding.Parent = contentFrame

    return contentFrame  -- retorne isso para adicionar toggles/inputs dentro
end

return Section
