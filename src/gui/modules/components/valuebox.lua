--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local ValueBox = {}
ValueBox.__index = ValueBox

local COLOR_WHITE = Color3.fromHex("FFFFFF")
local COLOR_BOX_BG = Color3.fromHex("1A1A1A")
local COLOR_BOX_BORDER = Color3.fromHex("333333")
local FONT_MAIN = Enum.Font.GothamBold

export type ValueBox = {
    Instance: Frame,
    TextBox: TextBox,
    CurrentValue: number,
    SetValue: (self: ValueBox, value: number, silent: boolean?) -> (),
    GetValue: (self: ValueBox) -> number,
    Destroy: (self: ValueBox) -> (),
    OnValueChanged: RBXScriptSignal
}

--[[
    @param defaultValue: Valor inicial padrão
    @param min: Limite mínimo do clamp
    @param max: Limite máximo do clamp
    @param decimals: Quantidade de casas decimais (0 para números inteiros)
    @param maxLen: Limite máximo de caracteres que podem ser digitados
]]
function ValueBox.new(defaultValue: number, min: number, max: number, decimals: number, maxLen: number): ValueBox
    local self = setmetatable({}, ValueBox) :: any
    self.Maid = Maid.new()
    
    -- Evento para o Orquestrador escutar
    local bindable = Instance.new("BindableEvent")
    self.OnValueChanged = bindable.Event
    self.OnValueChangedBindable = bindable
    self.Maid:GiveTask(bindable)

    self.CurrentValue = defaultValue
    self.DefaultValue = defaultValue
    self.Min = min
    self.Max = max
    self.Decimals = decimals

    -- =========================================================
    -- VISUAL (Baseado na sua estrutura do Smooth)
    -- =========================================================
    local inputCont = Instance.new("Frame")
    inputCont.Name = "ValueBoxContainer"
    inputCont.Size = UDim2.new(0, 120, 0, 32)
    inputCont.BackgroundColor3 = COLOR_BOX_BG
    inputCont.BorderSizePixel = 0

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = inputCont

    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = COLOR_BOX_BORDER
    inputStroke.Thickness = 1
    inputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    inputStroke.Parent = inputCont

    local textBox = Instance.new("TextBox")
    textBox.Name = "Input"
    textBox.Size = UDim2.fromScale(1, 1)
    textBox.BackgroundColor3 = COLOR_BOX_BG
    textBox.BackgroundTransparency = 1
    textBox.BorderSizePixel = 0
    textBox.TextColor3 = COLOR_WHITE
    textBox.Font = FONT_MAIN
    textBox.TextSize = 16
    textBox.ClearTextOnFocus = false
    textBox.Parent = inputCont
    
    self.Instance = inputCont
    self.TextBox = textBox

    -- Força a formatação inicial visual
    self.TextBox.Text = string.format("%." .. tostring(self.Decimals) .. "f", self.CurrentValue)

    -- =========================================================
    -- 1. FILTRO EM TEMPO REAL (Não dispara save, apenas limpa digitação)
    -- =========================================================
    self.Maid:GiveTask(textBox:GetPropertyChangedSignal("Text"):Connect(function()
        local text = textBox.Text
        local clean = string.gsub(text, "[^%d%.]", "")
        local dots = 0
        
        clean = string.gsub(clean, "%.", function()
            dots = dots + 1
            return dots == 1 and "." or ""
        end)
        
        if #clean > maxLen then
            clean = string.sub(clean, 1, maxLen)
        end
        
        if textBox.Text ~= clean then
            textBox.Text = clean
        end
    end))
    
    -- =========================================================
    -- 2. FONTE DA VERDADE (Quando o usuário aperta Enter/Clica fora)
    -- =========================================================
    self.Maid:GiveTask(textBox.FocusLost:Connect(function()
        local num = tonumber(textBox.Text)
        
        -- Se o usuário deletou tudo e deu enter, volta para o valor atual seguro
        if not num then
            num = self.CurrentValue 
        end
        
        -- Atualiza a UI e dispara o save para o Orquestrador (silent = false)
        self:SetValue(num, false)
    end))

    return self
end

-- =========================================================
-- O CONTRATO OBRIGATÓRIO (Para o Orquestrador ler e escrever)
-- =========================================================
function ValueBox:SetValue(value: number, silent: boolean?)
    local num = tonumber(value)
    if not num then num = self.DefaultValue end
    
    -- Força os limites matemáticos
    num = math.clamp(num, self.Min, self.Max)
    
    -- Garante que o número fique exatamente como será exibido na tela
    local formatStr = "%." .. tostring(self.Decimals) .. "f"
    local formattedText = string.format(formatStr, num)
    local finalNumber = tonumber(formattedText) or num
    
    self.CurrentValue = finalNumber
    self.TextBox.Text = formattedText

    -- Se silent for true (Orquestrador injetando memória inicial), não dispara save.
    -- Se for false (Usuário acabou de digitar no FocusLost), dispara o save!
    if not silent then
        self.OnValueChangedBindable:Fire(self.CurrentValue)
    end
end

function ValueBox:GetValue(): number
    return self.CurrentValue
end

function ValueBox:Destroy()
    self.Maid:Destroy()
end

return ValueBox
