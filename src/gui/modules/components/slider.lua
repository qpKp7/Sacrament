--!strict
local UserInputService = game:GetService("UserInputService")
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type Slider = {
    Instance: Frame,
    SetValue: (self: Slider, value: number, silent: boolean?) -> (),
    GetValue: (self: Slider) -> number,
    OnValueChanged: RBXScriptSignal,
    Destroy: (self: Slider) -> ()
}

local SliderFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local COLOR_VALUE = Color3.fromRGB(255, 255, 255)
local FONT_MAIN = Enum.Font.GothamBold

function SliderFactory.new(title: string, min: number, max: number, default: number): Slider
    local maid = Maid.new()
    local valueChanged = Instance.new("BindableEvent")
    maid:GiveTask(valueChanged)
    
    local isDragging = false
    -- O math.round garante que o valor sempre seja inteiro (pula de 1 em 1)
    local currentValue = math.clamp(math.round(default), min, max)

    local container = Instance.new("Frame")
    container.Name = title .. "Slider"
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundTransparency = 1
    container.Active = true

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = container

    local infoFrame = Instance.new("Frame")
    infoFrame.Size = UDim2.new(1, 0, 0, 20)
    infoFrame.BackgroundTransparency = 1
    infoFrame.Parent = container

    local lblTitle = Instance.new("TextLabel")
    lblTitle.Size = UDim2.new(0.5, 0, 1, 0)
    lblTitle.BackgroundTransparency = 1
    lblTitle.Text = title
    lblTitle.TextColor3 = COLOR_LABEL
    lblTitle.Font = FONT_MAIN
    lblTitle.TextSize = 14
    lblTitle.TextXAlignment = Enum.TextXAlignment.Left
    lblTitle.Parent = infoFrame

    local lblValue = Instance.new("TextLabel")
    lblValue.Size = UDim2.new(0.5, 0, 1, 0)
    lblValue.Position = UDim2.fromScale(0.5, 0)
    lblValue.BackgroundTransparency = 1
    lblValue.Text = tostring(currentValue)
    lblValue.TextColor3 = COLOR_VALUE
    lblValue.Font = FONT_MAIN
    lblValue.TextSize = 14
    lblValue.TextXAlignment = Enum.TextXAlignment.Right
    lblValue.Parent = infoFrame

    local rail = Instance.new("Frame")
    rail.Name = "Rail"
    rail.Size = UDim2.new(1, 0, 0, 4)
    rail.Position = UDim2.new(0, 0, 1, -5)
    rail.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    rail.BorderSizePixel = 0
    rail.Parent = container

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.fromScale((currentValue - min) / (max - min), 1)
    fill.BackgroundColor3 = Color3.fromHex("C80000")
    fill.BorderSizePixel = 0
    fill.Parent = rail

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.fromOffset(10, 10)
    knob.Position = UDim2.new(1, 0, 0.5, 0)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Parent = fill
    
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local self = {} :: any
    self.Instance = container
    self.OnValueChanged = valueChanged.Event

    -- =========================================================
    -- O CONTRATO OBRIGATÓRIO (Para o Orquestrador ler e escrever)
    -- =========================================================
    function self:SetValue(value: number, silent: boolean?)
        -- Força o número a ser inteiro e dentro do limite
        local num = math.clamp(math.round(tonumber(value) or default), min, max)
        
        if num ~= currentValue or silent then
            currentValue = num
            lblValue.Text = tostring(currentValue)
            
            -- Evita divisão por zero se max == min
            local percent = (max > min) and ((currentValue - min) / (max - min)) or 0
            fill.Size = UDim2.fromScale(percent, 1)

            -- Se for o Orquestrador que estiver setando, não avisa ele de volta
            if not silent then
                valueChanged:Fire(currentValue)
            end
        end
    end

    function self:GetValue(): number
        return currentValue
    end

    -- =========================================================
    -- LÓGICA DO MOUSE
    -- =========================================================
    local function processMouseInput(input: InputObject)
        local railAbsoluteSize = rail.AbsoluteSize.X
        local railAbsolutePos = rail.AbsolutePosition.X
        local mousePos = input.Position.X
        
        -- Garante que o slider não quebre se for zero
        if railAbsoluteSize <= 0 then return end
        
        local percent = math.clamp((mousePos - railAbsolutePos) / railAbsoluteSize, 0, 1)
        local rawValue = min + (percent * (max - min))
        
        -- Chama o SetValue, forçando o envio para o Orquestrador (silent = false)
        self:SetValue(rawValue, false)
    end

    maid:GiveTask(container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            processMouseInput(input)
        end
    end))

    maid:GiveTask(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end))

    maid:GiveTask(UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            processMouseInput(input)
        end
    end))

    maid:GiveTask(container)

    function self:Destroy()
        maid:Destroy()
    end

    return self :: Slider
end

return SliderFactory
