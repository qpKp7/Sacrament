--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local ToggleButton = SafeImport("gui/modules/components/togglebutton")
local DynamicList = SafeImport("gui/modules/components/dynamiclist")

export type GroupIdUI = {
    Instance: Frame,
    Toggle: any,      -- [NOVO] Exportado para o Orquestrador (Ligar/Desligar)
    DynamicList: any, -- [NOVO] Exportado para o Orquestrador (Salvar a lista)
    Destroy: (self: GroupIdUI) -> ()
}

local GroupIdFactory = {}

local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_BORDER = Color3.fromHex("333333")
local COLOR_TEXT = Color3.fromHex("FFFFFF")
local COLOR_SUBTEXT = Color3.fromHex("888888")
local FONT_MAIN = Enum.Font.GothamBold

function GroupIdFactory.new(layoutOrder: number?): GroupIdUI
    local maid = Maid.new()

    -- Container invisível para agrupar o Card e a Lista de forma limpa
    local container = Instance.new("Frame")
    container.Name = "GroupIdContainer"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 1

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Padding = UDim.new(0, 8) -- Espaço entre o botão e a lista
    containerLayout.Parent = container

    local toggleCard = Instance.new("Frame")
    toggleCard.Name = "GroupToggleCard"
    toggleCard.Size = UDim2.new(1, 0, 0, 55)
    toggleCard.BackgroundColor3 = COLOR_BG
    toggleCard.LayoutOrder = 1
    toggleCard.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = toggleCard
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLOR_BORDER
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = toggleCard
    
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 15)
    pad.PaddingRight = UDim.new(0, 15)
    pad.Parent = toggleCard

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 0, 16)
    title.Position = UDim2.new(0, 0, 0.5, -10)
    title.AnchorPoint = Vector2.new(0, 0.5)
    title.BackgroundTransparency = 1
    title.Text = "Group ID Check"
    title.TextColor3 = COLOR_TEXT
    title.Font = FONT_MAIN
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = toggleCard

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -50, 0, 12)
    subtitle.Position = UDim2.new(0, 0, 0.5, 8)
    subtitle.AnchorPoint = Vector2.new(0, 0.5)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Use Group ID List"
    subtitle.TextColor3 = COLOR_SUBTEXT
    subtitle.Font = FONT_MAIN
    subtitle.TextSize = 12
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = toggleCard

    local self = {} :: any
    self.Instance = container

    -- Inicia a DynamicList
    local listPanel = nil
    if DynamicList and type(DynamicList.new) == "function" then
        listPanel = DynamicList.new("Group ID List", 2)
        listPanel.Instance.Size = UDim2.new(1, 0, 0, 0)
        listPanel.Instance.Visible = false -- Inicia oculta
        listPanel.Instance.Parent = container
        maid:GiveTask(listPanel)
        
        self.DynamicList = listPanel
    end

    -- Inicia o Toggle
    local toggle = nil
    if ToggleButton and type(ToggleButton.new) == "function" then
        toggle = ToggleButton.new()
        toggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
        toggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        toggle.Instance.Parent = toggleCard
        maid:GiveTask(toggle)
        
        self.Toggle = toggle
    end

    -- Lógica de expansão e interceptação de memória
    if toggle and listPanel then
        maid:GiveTask(toggle.Toggled:Connect(function(state: boolean)
            listPanel.Instance.Visible = state
        end))
        
        -- Intercepta para abrir silenciosamente se a memória disser "true"
        local originalSetState = toggle.SetState
        toggle.SetState = function(toggleSelf, state, silent)
            if originalSetState then originalSetState(toggleSelf, state, silent) end
            listPanel.Instance.Visible = state
        end
    end

    maid:GiveTask(container)

    function self:Destroy() 
        maid:Destroy() 
    end

    return self :: GroupIdUI
end

return GroupIdFactory
