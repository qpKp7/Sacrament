--!strict
--[[
    SACRAMENT | Combat: Aimlock Module
    Gerencia a interface de Aimlock, vinculando componentes visuais ao estado global.
--]]

local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then 
        warn("[SACRAMENT] Erro crítico ao carregar sub-módulo: " .. path) 
        return nil 
    end
    return result
end

-- Camada de Estado
local UIState = SafeImport("state/uistate")

-- Camada de Componentes (Paths atualizados)
local ToggleButton = SafeImport("gui/modules/components/togglebutton")
local Arrow = SafeImport("gui/modules/components/arrow")
local GlowBar = SafeImport("gui/modules/components/glowbar")
local Sidebar = SafeImport("gui/modules/components/sidebar")

-- Seções Internas
local KeybindSection = SafeImport("gui/modules/combat/sections/shared/keybind")
local KeyHoldSection = SafeImport("gui/modules/combat/sections/shared/keyhold")
local PredictSection = SafeImport("gui/modules/combat/sections/shared/predict")
local SmoothSection = SafeImport("gui/modules/combat/sections/aimlock/smooth")
local AimPartSection = SafeImport("gui/modules/combat/sections/shared/aimpart")
local WallCheckSection = SafeImport("gui/modules/combat/sections/shared/wallcheck")
local KnockCheckSection = SafeImport("gui/modules/combat/sections/shared/knockcheck")

export type AimlockUI = { 
    Instance: Frame, 
    Destroy: (self: AimlockUI) -> () 
}

local AimlockFactory = {}

local COLOR_WHITE = Color3.fromHex("B4B4B4")
local FONT_MAIN = Enum.Font.GothamBold

--[[ 
    MÁQUINA DE BINDING UNIVERSAL (V6 - INTEGRADA COM KEYBOX)
    Esta função garante que qualquer mudança na UI salve no Estado, e vice-versa.
]]
local function UniversalStateBinder(sectionTable: any, stateKey: string, state: any, maid: any)
    if not state or not sectionTable then return end
    local root = sectionTable.Instance
    if not root then return end

    -- [CASO 1: TOGGLES / CHECKBOXES]
    if sectionTable.Toggled and sectionTable.SetState then
        local savedVal = state.Get(stateKey, false)
        sectionTable:SetState(savedVal, true)
        maid:GiveTask(sectionTable.Toggled:Connect(function(val: boolean)
            state.Set(stateKey, val)
        end))
        return
    end

    -- [CASO 2: SLIDERS]
    if sectionTable.OnValueChanged and sectionTable.SetValue then
        local savedVal = state.Get(stateKey)
        if savedVal ~= nil then sectionTable:SetValue(savedVal) end
        maid:GiveTask(sectionTable.OnValueChanged:Connect(function(val: number)
            state.Set(stateKey, val)
        end))
        return
    end

    -- [CASO 3: KEYBINDS (Integrado com o novo Keybox Component)]
    if sectionTable.KeyChanged and sectionTable.SetKey then
        local savedKeyName = state.Get(stateKey)
        if savedKeyName and type(savedKeyName) == "string" then
            -- Converte string do state de volta para Enum
            pcall(function() 
                local isMouse = savedKeyName:match("MouseButton")
                local enumType = isMouse and Enum.UserInputType or Enum.KeyCode
                sectionTable:SetKey(enumType[savedKeyName]) 
            end)
        end
        maid:GiveTask(sectionTable.KeyChanged:Connect(function(keyEnum: any)
            state.Set(stateKey, keyEnum and keyEnum.Name or nil)
        end))
        return
    end

    -- [CASO 4: DROPDOWNS / TEXTBOXES]
    -- (Mantido conforme lógica original do projeto)
end

function AimlockFactory.new(): AimlockUI
    local maid = Maid.new()

    -- Recuperação imediata de Estado para evitar Desync visual
    local isEnabled = UIState and UIState.Get("AimlockEnabled", false) or false
    local isExpanded = UIState and UIState.Get("AimlockExpanded", false) or false

    -- Container Principal
    local container = Instance.new("Frame")
    container.Name = "AimlockContainer"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1 
    container.AutomaticSize = Enum.AutomaticSize.Y

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Parent = container

    -- HEADER
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundTransparency = 1
    header.LayoutOrder = 1
    header.Parent = container

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.fromOffset(0, 50)
    title.AutomaticSize = Enum.AutomaticSize.X
    title.Position = UDim2.fromOffset(20, 0)
    title.BackgroundTransparency = 1
    title.Text = "Aimlock"
    title.TextColor3 = COLOR_WHITE
    title.Font = FONT_MAIN
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local controls = Instance.new("Frame")
    controls.Name = "Controls"
    controls.Size = UDim2.fromOffset(90, 50)
    controls.AnchorPoint = Vector2.new(1, 0)
    controls.Position = UDim2.new(1, -10, 0, 0)
    controls.BackgroundTransparency = 1
    controls.Parent = header

    -- COMPONENTES DO HEADER
    local toggleBtn, arrow, glowBar

    if ToggleButton then
        toggleBtn = ToggleButton.new()
        toggleBtn.Instance.AnchorPoint = Vector2.new(0, 0.5)
        toggleBtn.Instance.Position = UDim2.fromScale(0, 0.5)
        if toggleBtn.SetState then toggleBtn:SetState(isEnabled, true) end
        toggleBtn.Instance.Parent = controls
        maid:GiveTask(toggleBtn)
    end

    if Arrow then
        arrow = Arrow.new()
        arrow.Instance.AnchorPoint = Vector2.new(1, 0.5)
        arrow.Instance.Position = UDim2.fromScale(1, 0.5)
        if arrow.SetState then arrow:SetState(isExpanded, true) end
        arrow.Instance.Parent = controls
        maid:GiveTask(arrow)
    end

    -- GLOW BAR (Visual Feedback)
    local glowWrapper = Instance.new("Frame")
    glowWrapper.Name = "GlowWrapper"
    glowWrapper.AnchorPoint = Vector2.new(0, 0.5)
    glowWrapper.BackgroundTransparency = 1
    glowWrapper.Parent = header

    if GlowBar then
        glowBar = GlowBar.new()
        glowBar.Instance.Size = UDim2.fromScale(1, 1)
        if glowBar.SetState then glowBar:SetState(isEnabled) end
        glowBar.Instance.Parent = glowWrapper
        maid:GiveTask(glowBar)
    end

    -- Lógica de Posicionamento do Glow (Dinâmica)
    local function updateGlowBar()
        if header.AbsoluteSize.X == 0 then return end
        local startX = title.AbsolutePosition.X + title.AbsoluteSize.X + 10
        local endX = controls.AbsolutePosition.X - 10
        local width = math.max(0, endX - startX)
        glowWrapper.Position = UDim2.new(0, startX - header.AbsolutePosition.X, 0.5, 0)
        glowWrapper.Size = UDim2.fromOffset(width, 2)
    end
    maid:GiveTask(header:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGlowBar))
    task.defer(updateGlowBar)

    -- SUBFRAME (Conteúdo Expansível)
    local subFrame = Instance.new("Frame")
    subFrame.Name = "SubFrame"
    subFrame.Size = UDim2.new(1, 0, 0, 320)
    subFrame.BackgroundTransparency = 1
    subFrame.Visible = isExpanded -- SINCRONIA TOTAL
    subFrame.LayoutOrder = 2
    subFrame.Parent = container

    if Sidebar then
        local vLine = Sidebar.createVertical()
        vLine.Instance.Parent = subFrame
        maid:GiveTask(vLine)
    end

    local rightContent = Instance.new("Frame")
    rightContent.Name = "RightContent"
    rightContent.Size = UDim2.new(1, -5, 1, 0)
    rightContent.Position = UDim2.fromOffset(5, 0)
    rightContent.BackgroundTransparency = 1
    rightContent.Parent = subFrame

    local rightLayout = Instance.new("UIListLayout")
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Parent = rightContent

    --[[ CARREGAMENTO DE SEÇÕES COM BINDING AUTOMÁTICO ]]--

    local function safeLoadSection(module: any, sectionID: string, order: number, parent: Instance)
        if module and type(module.new) == "function" then
            local success, inst = pcall(function() return module.new(order) end)
            if success and inst then
                inst.Instance.Parent = parent
                UniversalStateBinder(inst, "Aimlock_" .. sectionID, UIState, maid)
                maid:GiveTask(inst)
            end
        end
    end

    -- Seção de Keybind (Fixa no topo)
    safeLoadSection(KeybindSection, "MainKey", 1, rightContent)

    if Sidebar then
        local hLine = Sidebar.createHorizontal(2)
        hLine.Instance.Parent = rightContent
        maid:GiveTask(hLine)
    end

    -- Área de Scroll para as demais opções
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "OptionsScroll"
    scroll.Size = UDim2.new(1, 0, 1, -60)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 0
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.LayoutOrder = 3
    scroll.Parent = rightContent

    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.Padding = UDim.new(0, 10)
    scrollLayout.Parent = scroll

    local scrollPad = Instance.new("UIPadding")
    scrollPad.PaddingTop = UDim.new(0, 10)
    scrollPad.PaddingLeft = UDim.new(0, 20)
    scrollPad.Parent = scroll

    -- Carregamento das opções granulares
    safeLoadSection(KeyHoldSection, "Mode", 1, scroll)
    safeLoadSection(PredictSection, "Prediction", 2, scroll)
    safeLoadSection(SmoothSection, "Smoothness", 3, scroll)
    safeLoadSection(AimPartSection, "TargetPart", 4, scroll)
    safeLoadSection(WallCheckSection, "WallCheck", 5, scroll)
    safeLoadSection(KnockCheckSection, "KnockCheck", 6, scroll)

    -- CONEXÕES DE CONTROLE
    if toggleBtn then
        maid:GiveTask(toggleBtn.Toggled:Connect(function(state: boolean)
            if glowBar then glowBar:SetState(state) end
            UIState.Set("AimlockEnabled", state)
        end))
    end

    if arrow then
        maid:GiveTask(arrow.Toggled:Connect(function(state: boolean)
            subFrame.Visible = state
            UIState.Set("AimlockExpanded", state)
        end))
    end

    maid:GiveTask(container)
    local self = {}
    self.Instance = container
    function self:Destroy() maid:Destroy() end
    return self :: AimlockUI
end

return AimlockFactory
