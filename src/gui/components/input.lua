-- src/gui/components/input.lua
-- Cria campos de input (TextBox) para configs como Prediction e Smoothness
-- Com label, fundo escuro, stroke vermelho sutil, arredondado e FocusLost para salvar valor

local Input = {}

local Helpers = require(script.Parent.helpers)

-- ================================================
-- Cria um input completo (label + TextBox)
-- Parâmetros:
--   parent: Frame onde colocar (geralmente Content de uma Section)
--   labelText: string - texto do label (ex: "Prediction:")
--   defaultValue: string - valor inicial (ex: "0.135")
--   configKey: string - chave para salvar (ex: "Prediction" → getgenv().Sacrament_Prediction)
-- Retorna: o TextBox criado (para referência se precisar)
-- ================================================
function Input.Create(parent, labelText, defaultValue, configKey)
    local frame = Instance.new("Frame")
    frame.Name = labelText:gsub(":", "") .. "Input"
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    -- Label à esquerda
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Helpers.COLORS.TextSecondary
    label.TextSize = 14
    label.Font = Helpers.FONTS.Normal
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = frame

    -- TextBox à direita
    local box = Instance.new("TextBox")
    box.Name = "Box"
    box.Size = UDim2.new(0.6, 0, 1, 0)
    box.Position = UDim2.new(0.4, 0, 0, 0)
    box.BackgroundColor3 = Helpers.COLORS.InputBg
    box.BorderSizePixel = 0
    box.Text = defaultValue
    box.TextColor3 = Helpers.COLORS.TextPrimary
    box.TextSize = 14
    box.Font = Helpers.FONTS.Normal
    box.ClearTextOnFocus = false
    box.TextXAlignment = Enum.TextXAlignment.Center
    box.Parent = frame

    Helpers.UICorner(box, 6)
    Helpers.UIStroke(box, 0.6, 1)  -- stroke vermelho sutil

    -- Hover na borda do TextBox
    Helpers.AddHoverEffect(box, box:FindFirstChildOfClass("UIStroke"))

    -- Salvar valor ao perder foco (ou Enter)
    local lastValidValue = defaultValue

    box.FocusLost:Connect(function(enterPressed)
        local inputText = box.Text
        local numValue = tonumber(inputText)

        if numValue then
            -- Valor válido → salva
            lastValidValue = inputText

            -- Salva em variável global (ajuste conforme sua estrutura de config)
            if configKey == "Prediction" then
                getgenv().Sacrament_Prediction = numValue
                print("[Sacrament Config] Prediction atualizado para: " .. numValue)
            elseif configKey == "Smoothness" then
                getgenv().Sacrament_Smoothness = numValue
                print("[Sacrament Config] Smoothness atualizado para: " .. numValue)
            end
            -- Aqui você pode adicionar mais chaves no futuro (FOV, etc.)

        else
            -- Inválido → restaura último valor válido
            box.Text = lastValidValue
            warn("[Sacrament Config] Valor inválido para " .. labelText .. ": " .. inputText)
        end
    end)

    -- Valor inicial
    box.Text = defaultValue

    return box
end

return Input
