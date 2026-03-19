--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local Dropdown = {}
Dropdown.__index = Dropdown

local COLOR_WHITE = Color3.fromHex("FFFFFF")
local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local COLOR_ACCENT = Color3.fromHex("C80000")
local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_STROKE = Color3.fromHex("333333")
local FONT_MAIN = Enum.Font.GothamBold

export type Dropdown = {
    Instance: Frame,
    CurrentValue: string,
    SetSelected: (self: Dropdown, value: string, silent: boolean?) -> (),
    GetSelected: (self: Dropdown) -> string,
    Destroy: (self: Dropdown) -> (),
    OnSelectionChanged: RBXScriptSignal
}

function Dropdown.new(options: {string}, defaultValue: string): Dropdown
    local self = setmetatable({}, Dropdown) :: any
    self.Maid = Maid.new()
    
    local bindable = Instance.new("BindableEvent")
    self.OnSelectionChanged = bindable.Event
    self.OnSelectionChangedBindable = bindable
    self.Maid:GiveTask(bindable)

    self.CurrentValue = defaultValue
    self.DefaultValue = defaultValue
    self.Options = options

    -- =========================================================
    -- ESTRUTURA VISUAL INTELIGENTE (Wrapper)
    -- =========================================================
    local wrapper = Instance.new("Frame")
    wrapper.Name = "DropdownWrapper"
    wrapper.Size = UDim2.new(0, 130, 0, 0)
    wrapper.BackgroundTransparency = 1
    wrapper.AutomaticSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = wrapper

    -- O BOTÃO PRINCIPAL
    local btnBg = Instance.new("TextButton")
    btnBg.Size = UDim2.new(1, 0, 0, 32)
    btnBg.BackgroundColor3 = COLOR_BG
    btnBg.Text = ""
    btnBg.AutoButtonColor = false
    btnBg.LayoutOrder = 1
    btnBg.Parent = wrapper

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btnBg

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLOR_STROKE
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = btnBg

    local valText = Instance.new("TextLabel")
    valText.Size = UDim2.new(1, -30, 1, 0)
    valText.Position = UDim2.fromOffset(10, 0)
    valText.BackgroundTransparency = 1
    valText.Text = defaultValue
    valText.TextColor3 = COLOR_WHITE
    valText.Font = FONT_MAIN
    valText.TextSize = 14
    valText.TextXAlignment = Enum.TextXAlignment.Left
    valText.Parent = btnBg

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -25, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = ">"
    arrow.TextColor3 = COLOR_WHITE
    arrow.Font = FONT_MAIN
    arrow.TextSize = 14
    arrow.Parent = btnBg

    -- A LISTA DROPDOWN
    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(1, 0, 0, 0)
    listFrame.BackgroundTransparency = 1
    listFrame.Visible = false
    listFrame.AutomaticSize = Enum.AutomaticSize.Y
    listFrame.LayoutOrder = 2
    listFrame.Parent = wrapper

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = listFrame

    self.Instance = wrapper

    -- =========================================================
    -- CONTRATO DO ORQUESTRADOR: SetSelected
    -- =========================================================
    function self:SetSelected(value: string, silent: boolean?)
        -- Validação de segurança
        local valid = false
        for _, opt in ipairs(self.Options) do
            if opt == value then valid = true; break end
        end
        if not valid then value = self.DefaultValue end

        self.CurrentValue = value
        valText.Text = value

        -- Atualiza as cores da lista
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child.TextColor3 = (child.Text == value) and COLOR_ACCENT or COLOR_LABEL
            end
        end

        if not silent then
            self.OnSelectionChangedBindable:Fire(self.CurrentValue)
        end
    end

    function self:GetSelected(): string
        return self.CurrentValue
    end

    -- =========================================================
    -- LÓGICA DE INTERAÇÃO E CLIQUES
    -- =========================================================
    local isOpen = false
    self.Maid:GiveTask(btnBg.Activated:Connect(function()
        isOpen = not isOpen
        listFrame.Visible = isOpen
        stroke.Color = isOpen and COLOR_ACCENT or COLOR_STROKE
    end))

    -- Gera as opções dinamicamente
    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 28)
        optBtn.BackgroundColor3 = COLOR_BG
        optBtn.Text = opt
        optBtn.TextColor3 = (opt == defaultValue) and COLOR_ACCENT or COLOR_LABEL
        optBtn.Font = FONT_MAIN
        optBtn.TextSize = 14
        optBtn.LayoutOrder = i
        optBtn.Parent = listFrame

        local optCorner = Instance.new("UICorner")
        optCorner.CornerRadius = UDim.new(0, 4)
        optCorner.Parent = optBtn

        self.Maid:GiveTask(optBtn.Activated:Connect(function()
            isOpen = false
            listFrame.Visible = false
            stroke.Color = COLOR_STROKE
            
            -- Chama o SetState Oficial e não-silencioso
            self:SetSelected(opt, false) 
        end))
    end

    function self:Destroy()
        self.Maid:Destroy()
    end

    return self
end

return Dropdown
