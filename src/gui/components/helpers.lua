-- src/gui/components/helpers.lua
-- Definições visuais globais e funções auxiliares para a GUI Sacrament
-- Use isso em todos os componentes para manter consistência no tema dark/underground

local Helpers = {}

-- Cores principais (baseado no tema carvão + vermelho sangue sutil)
Helpers.COLORS = {
    -- Fundos
    Background      = Color3.fromRGB(8,   8,   14),     -- #08080E - carvão profundo
    Frame           = Color3.fromRGB(10,  10,  18),     -- #0A0A12 - frame principal
    Darker          = Color3.fromRGB(14,  14,  22),     -- status bar / hover fundo
    InputBg         = Color3.fromRGB(24,  24,  30),     -- TextBox fundo
    
    -- Accents / Vermelho sangue
    Accent          = Color3.fromRGB(200, 0,   0),      -- #C80000 título e bordas
    AccentDark      = Color3.fromRGB(140, 0,   0),      -- preenchimento toggle ON
    AccentHover     = Color3.fromRGB(220, 40,  40),     -- hover borda
    
    -- Textos
    TextPrimary     = Color3.fromRGB(240, 240, 245),    -- texto principal / quase branco
    TextSecondary   = Color3.fromRGB(160, 160, 180),    -- labels secundários
    TextMuted       = Color3.fromRGB(100, 100, 120),    -- keybinds e muted
    
    -- Status
    StatusOff       = Color3.fromRGB(180, 0,   0),      -- OFFLINE
    StatusOn        = Color3.fromRGB(0,   220, 80),     -- LOCK ACTIVE / verde discreto
}

-- Fontes (Gotham family - padrão underground/profissional)
Helpers.FONTS = {
    Title       = Enum.Font.GothamBlack,
    Section     = Enum.Font.GothamBold,
    Normal      = Enum.Font.GothamSemibold,
    Small       = Enum.Font.Gotham,
    Code        = Enum.Font.Code,  -- opcional para keybinds ou logs
}

-- ================================================
-- Funções auxiliares rápidas para UI
-- ================================================

-- Cria UICorner com raio padrão 6-10
function Helpers.UICorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

-- Cria UIStroke vermelho sutil (usado em frames, TextBox, toggles)
function Helpers.UIStroke(parent, transparency, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Helpers.COLORS.Accent
    stroke.Transparency = transparency or 0.55
    stroke.Thickness = thickness or 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

-- Cria um divider fino vermelho (usado entre seções)
function Helpers.Divider(parent, yOffset)
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0, 0, 0, yOffset or 24)
    divider.BackgroundColor3 = Helpers.COLORS.Accent
    divider.BackgroundTransparency = 0.4
    divider.BorderSizePixel = 0
    divider.Parent = parent
    return divider
end

-- Função para criar hover simples (borda mais clara no mouse enter)
function Helpers.AddHoverEffect(frame, borderObj)
    if not borderObj then return end
    
    frame.MouseEnter:Connect(function()
        borderObj.Color = Helpers.COLORS.AccentHover
    end)
    
    frame.MouseLeave:Connect(function()
        borderObj.Color = Helpers.COLORS.Accent
    end)
end

return Helpers
