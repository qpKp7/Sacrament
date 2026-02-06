-- src/gui/components/toggle.lua
-- Cria toggle custom (checkbox) com visual underground: quadrado borda vermelha, fill vermelho escuro ON
-- Inclui hover sutil e keybind ao lado

local Toggle = {}

local Helpers = require(script.Parent.helpers)
local TweenService = game:GetService("TweenService")

-- Tween info para preenchimento suave (rápido e discreto)
local TWEEN_INFO = TweenInfo.new(
    0.14, 
    Enum.EasingStyle.Linear, 
    Enum.EasingDirection.Out
)

-- ================================================
-- Cria um toggle completo
-- Parâmetros:
--   parent: Frame onde colocar (geralmente o Content de uma Section)
--   labelText: string - texto principal (ex: "Aimlock Toggle")
--   keyText: string - tecla (ex: "E")
--   getStateFunc: function - callback que retorna boolean atual (ex: function() return states.AimlockEnabled end)
-- Retorna: table com .Frame e .Fill (para update se necessário), e método .Update(enabled)
-- ================================================
function Toggle.Create(parent, labelText, keyText, getStateFunc)
    local toggleObj = {}

    local frame = Instance.new("Frame")
    frame.Name = labelText:gsub(" ", "") .. "Toggle"
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    toggleObj.Frame = frame

    -- Checkbox quadrado
    local box = Instance.new("Frame")
    box.Name = "Box"
    box.Size = UDim2.new(0, 18, 0, 18)
    box.Position = UDim2.new(0, 0, 0.5, -9)
    box.BackgroundColor3 = Helpers.COLORS.Frame
    box.BorderColor3 = Helpers.COLORS.Accent
    box.BorderSizePixel = 1
    box.Parent = frame

    Helpers.UICorner(box, 4)

    -- Fill vermelho quando ON
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(1, -4, 1, -4)
    fill.Position = UDim2.new(0, 2, 0, 2)
    fill.BackgroundColor3 = Helpers.COLORS.AccentDark
    fill.BackgroundTransparency = 1  -- começa OFF
    fill.BorderSizePixel = 0
    fill.Parent = box

    Helpers.UICorner(fill, 3)

    toggleObj.Fill = fill

    -- Label texto
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 140, 1, 0)
    label.Position = UDim2.new(0, 26, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Helpers.COLORS.TextSecondary
    label.TextSize = 15
    label.Font = Helpers.FONTS.Normal
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = frame

    -- Keybind à direita
    local keyLabel = Instance.new("TextLabel")
    keyLabel.Size = UDim2.new(0.3, 0, 1, 0)
    keyLabel.Position = UDim2.new(0.7, 0, 0, 0)
    keyLabel.BackgroundTransparency = 1
    keyLabel.Text = "KEY: " .. keyText
    keyLabel.TextColor3 = Helpers.COLORS.TextMuted
    keyLabel.TextSize = 13
    keyLabel.Font = Helpers.FONTS.Small
    keyLabel.TextXAlignment = Enum.TextXAlignment.Right
    keyLabel.Parent = frame

    -- Hover sutil na borda do checkbox
    Helpers.AddHoverEffect(frame, box)

    -- Função para atualizar visual (chamada pelo updater)
    function toggleObj:Update(enabled)
        local targetTransparency = enabled and 0 or 1
        TweenService:Create(
            fill,
            TWEEN_INFO,
            {BackgroundTransparency = targetTransparency}
        ):Play()
    end

    -- Atualização inicial (para sincronizar ao criar)
    if getStateFunc then
        toggleObj:Update(getStateFunc())
    end

    return toggleObj
end

return Toggle
