--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local ToggleButton = SafeImport("gui/modules/components/togglebutton")
local Slider = SafeImport("gui/modules/components/slider")

export type TrailUI = {
    Instance: Frame,
    Toggle: any, -- [NOVO] Exportado para a memória do Ghost Trail
    Slider: any, -- [NOVO] Exportado para a memória do Drift Strength
    Destroy: (self: TrailUI) -> ()
}

local TrailFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local FONT_MAIN = Enum.Font.GothamBold

function TrailFactory.new(layoutOrder: number?): TrailUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "TrailSection"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 3

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container

    -- ROW GHOST TRAIL (Padrão Grande)
    local trailRow = Instance.new("Frame")
    trailRow.Name = "GhostTrailRow"
    trailRow.Size = UDim2.new(1, 0, 0, 55)
    trailRow.BackgroundTransparency = 1
    trailRow.LayoutOrder = 1
    trailRow.Parent = container

    local trailPad = Instance.new("UIPadding")
    trailPad.PaddingLeft = UDim.new(0, 20)
    trailPad.PaddingRight = UDim.new(0, 25)
    trailPad.Parent = trailRow

    local trailLabel = Instance.new("TextLabel")
    trailLabel.Name = "Label"
    trailLabel.Size = UDim2.new(0.5, 0, 1, 0)
    trailLabel.BackgroundTransparency = 1
    trailLabel.Text = "Ghost Trail"
    trailLabel.TextColor3 = COLOR_LABEL
    trailLabel.Font = FONT_MAIN
    trailLabel.TextSize = 18
    trailLabel.TextXAlignment = Enum.TextXAlignment.Left
    trailLabel.Parent = trailRow

    local self = {} :: any
    self.Instance = container

    -- 1. Cria e exporta o Toggle
    local trailToggle = nil
    if ToggleButton and type(ToggleButton.new) == "function" then
        trailToggle = ToggleButton.new()
        trailToggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
        trailToggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        trailToggle.Instance.Parent = trailRow
        maid:GiveTask(trailToggle)
        
        self.Toggle = trailToggle
    end

   -- ROW DRIFT STRENGTH
    local driftRow = Instance.new("Frame")
    driftRow.Name = "DriftRow"
    driftRow.Size = UDim2.new(1, 0, 0, 45)
    driftRow.BackgroundTransparency = 1
    driftRow.LayoutOrder = 2
    driftRow.Visible = false
    driftRow.Parent = container

    -- 2. Cria e exporta o Slider (Ajustado para 4 argumentos, pulando de 1 em 1)
    local driftSlider = nil
    if Slider and type(Slider.new) == "function" then
        driftSlider = Slider.new("Drift Strength", 0, 10, 0)
        driftSlider.Instance.AnchorPoint = Vector2.new(0, 0.5)
        driftSlider.Instance.Position = UDim2.fromScale(0, 0.5)
        driftSlider.Instance.Size = UDim2.fromScale(1, 1)
        driftSlider.Instance.Parent = driftRow
        maid:GiveTask(driftSlider)
        
        self.Slider = driftSlider
    end

    -- 3. Lógica de visibilidade dinâmica com interceptação de memória
    if self.Toggle and self.Slider then
        -- Evento de clique do usuário
        maid:GiveTask(self.Toggle.Toggled:Connect(function(state: boolean)
            driftRow.Visible = state
        end))
        
        -- Intercepta o carregamento silencioso do Orquestrador
        local originalSetState = self.Toggle.SetState
        self.Toggle.SetState = function(toggleSelf, state, silent)
            originalSetState(toggleSelf, state, silent)
            driftRow.Visible = state
        end
    end

    maid:GiveTask(container)

    function self:Destroy() 
        maid:Destroy() 
    end

    return self :: TrailUI
end

return TrailFactory
