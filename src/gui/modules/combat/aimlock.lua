--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then warn("[Sacrament] Falha ao importar: " .. path) return nil end
    return result
end

local UIState = SafeImport("state/uistate")

local ToggleButton = SafeImport("gui/modules/components/togglebutton")
local Arrow = SafeImport("gui/modules/components/arrow")
local GlowBar = SafeImport("gui/modules/components/glowbar")
local Sidebar = SafeImport("gui/modules/components/sidebar")

local KeybindSection = SafeImport("gui/modules/combat/sections/shared/keybind")
local AimPartSection = SafeImport("gui/modules/combat/sections/shared/aimpart")
local PredictSection = SafeImport("gui/modules/combat/sections/shared/predict")
local SmoothSection = SafeImport("gui/modules/combat/sections/aimlock/smooth")
local KeyHoldSection = SafeImport("gui/modules/combat/sections/shared/keyhold")
local WallCheckSection = SafeImport("gui/modules/combat/sections/shared/wallcheck")
local KnockCheckSection = SafeImport("gui/modules/combat/sections/shared/knockcheck")

export type AimlockUI = { Instance: Frame, Destroy: (self: AimlockUI) -> () }
local AimlockFactory = {}

local COLOR_WHITE = Color3.fromHex("B4B4B4")
local FONT_MAIN = Enum.Font.GothamBold

-- =========================================================================
-- CONSTRUTOR DA UI
-- =========================================================================
function AimlockFactory.new(): AimlockUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "AimlockContainer"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1 
    container.AutomaticSize = Enum.AutomaticSize.Y

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.FillDirection = Enum.FillDirection.Vertical
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Parent = container

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(0, 280, 0, 50)
    header.BackgroundTransparency = 1
    header.LayoutOrder = 1
    header.ClipsDescendants = true
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

    -- Puxa o estado apenas do botão de Ligar/Desligar (Toggle Principal)
    local isEnabled = UIState and UIState.Get("AimlockEnabled", false) or false

    local toggleBtn
    if ToggleButton and type(ToggleButton.new) == "function" then
        toggleBtn = ToggleButton.new()
        toggleBtn.Instance.AnchorPoint = Vector2.new(0, 0.5)
        toggleBtn.Instance.Position = UDim2.new(0, 0, 0.5, 0)
        if toggleBtn.SetState then pcall(function() toggleBtn:SetState(isEnabled, true) end) end
        toggleBtn.Instance.Parent = controls
        maid:GiveTask(toggleBtn)
    end

    -- ARROW MODO SILENT AIM (Sem interferência)
    local arrow
    if Arrow and type(Arrow.new) == "function" then
        arrow = Arrow.new()
        arrow.Instance.AnchorPoint = Vector2.new(1, 0.5)
        arrow.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        arrow.Instance.Parent = controls
        maid:GiveTask(arrow)
    end

    local glowWrapper = Instance.new("Frame")
    glowWrapper.Name = "GlowWrapper"
    glowWrapper.AnchorPoint = Vector2.new(0, 0.5)
    glowWrapper.BackgroundTransparency = 1
    glowWrapper.Parent = header

    local glowBar
    if GlowBar and type(GlowBar.new) == "function" then
        glowBar = GlowBar.new()
        glowBar.Instance.AnchorPoint = Vector2.new(0.5, 0.5)
        glowBar.Instance.Position = UDim2.fromScale(0.5, 0.5)
        glowBar.Instance.Size = UDim2.fromScale(1, 1)
        if glowBar.SetState then glowBar:SetState(isEnabled) end
        glowBar.Instance.Parent = glowWrapper
        maid:GiveTask(glowBar)
    end

    local function updateGlowBar()
        if header.AbsoluteSize.X == 0 then return end
        local titleRight = title.AbsolutePosition.X + title.AbsoluteSize.X
        local controlsLeft = controls.AbsolutePosition.X
        local startX = (titleRight - header.AbsolutePosition.X) + 5
        local width = math.max(0, (controlsLeft - header.AbsolutePosition.X) - 5 - startX)
        glowWrapper.Position = UDim2.new(0, startX, 0.5, 0)
        glowWrapper.Size = UDim2.fromOffset(width, 32)
    end
    maid:GiveTask(title:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGlowBar))
    maid:GiveTask(header:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGlowBar))
    task.defer(updateGlowBar)

    -- SUBFRAME (Nasce fechado, gerenciado externamente)
    local subFrame = Instance.new("Frame")
    subFrame.Name = "SubFrame"
    subFrame.Size = UDim2.new(1, 0, 0, 320)
    subFrame.BackgroundTransparency = 1
    subFrame.BorderSizePixel = 0
    subFrame.Visible = false 
    subFrame.LayoutOrder = 2
    subFrame.Parent = container

    if Sidebar and type(Sidebar.createVertical) == "function" then
        local vLine = Sidebar.createVertical()
        vLine.Instance.Size = UDim2.new(0, 2, 1, 0)
        vLine.Instance.Parent = subFrame
        maid:GiveTask(vLine)
    end

    local rightContent = Instance.new("Frame")
    rightContent.Name = "RightContent"
    rightContent.Size = UDim2.new(1, -2, 1, 0)
    rightContent.Position = UDim2.fromOffset(2, 0)
    rightContent.BackgroundTransparency = 1
    rightContent.Parent = subFrame

    local rightLayout = Instance.new("UIListLayout")
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Parent = rightContent

    -- Função de Carregamento modificada para nos DEVOLVER o componente (Para o Orquestrador ler)
    local function loadSec(moduleType: any, order: number, parentInstance: Instance)
        if typeof(moduleType) == "table" and moduleType.new then
            local success, instance = pcall(function() return moduleType.new(order) end)
            if success and instance then
                instance.Instance.Parent = parentInstance
                maid:GiveTask(instance)
                return instance -- Agora a gente tem acesso ao componente!
            end
        end
        return nil
    end

    -- CARREGAMENTO DAS SEÇÕES (Apenas monta o visual)
    local secKeybind = loadSec(KeybindSection, 1, rightContent)

    if Sidebar and type(Sidebar.createHorizontal) == "function" then
        local hLine = Sidebar.createHorizontal(2)
        hLine.Instance.Parent = rightContent
        maid:GiveTask(hLine)
    end

    local inputsScroll = Instance.new("ScrollingFrame")
    inputsScroll.Name = "InputsScroll"
    inputsScroll.Size = UDim2.new(1, 0, 1, -57)
    inputsScroll.BackgroundTransparency = 1
    inputsScroll.BorderSizePixel = 0
    inputsScroll.ScrollBarThickness = 0
    inputsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    inputsScroll.LayoutOrder = 3
    inputsScroll.Parent = rightContent

    local inputsLayout = Instance.new("UIListLayout")
    inputsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    inputsLayout.Padding = UDim.new(0, 15)
    inputsLayout.Parent = inputsScroll

    local inputsPadding = Instance.new("UIPadding")
    inputsPadding.PaddingTop = UDim.new(0, 15)
    inputsPadding.PaddingBottom = UDim.new(0, 20)
    inputsPadding.Parent = inputsScroll

    local secKeyHold   = loadSec(KeyHoldSection,   1, inputsScroll)
    local secPredict   = loadSec(PredictSection,   2, inputsScroll)
    local secSmooth    = loadSec(SmoothSection,    3, inputsScroll)
    local secAimPart   = loadSec(AimPartSection,   4, inputsScroll)
    local secWallCheck = loadSec(WallCheckSection, 5, inputsScroll)
    local secKnockCheck= loadSec(KnockCheckSection,6, inputsScroll)

    -- EVENTO PRINCIPAL
    if toggleBtn and UIState then
        maid:GiveTask(toggleBtn.Toggled:Connect(function(state: boolean)
            if glowBar then glowBar:SetState(state) end
            UIState.Set("AimlockEnabled", state)
        end))
    end

    -- =========================================================================
    -- 👑 ORQUESTRADOR DE ESTADOS (CLIENT SYNC) - CONTRATO ESTRITO
    -- =========================================================================
    local Orchestrator = {}
    
    function Orchestrator.Bind(section: any, stateKey: string, componentType: string)
        if not section or not UIState then return end
        
        local savedValue = UIState.Get(stateKey)
        
        if componentType == "TextBox" or componentType == "ValueBox" then
            -- Exige que a seção exporte o componente real (ex: self.ValueBox = meuComponenteBox)
            local component = section.ValueBox or section.TextBox
            if component then
                -- 1. Restaura silenciosamente
                if savedValue ~= nil and component.SetValue then
                    pcall(function() component:SetValue(savedValue, true) end) -- true = silent
                end
                -- 2. Ouve a fonte da verdade já sanitizada
                if component.OnValueChanged then
                    maid:GiveTask(component.OnValueChanged:Connect(function(finalValue)
                        UIState.Set(stateKey, finalValue)
                    end))
                end
            else
                warn("[Orquestrador] Falha: " .. stateKey .. " nao exporta 'self.ValueBox' ou 'self.TextBox'.")
            end
            
        elseif componentType == "Toggle" then
            local component = section.Toggle or section.ToggleButton
            if component then
                if savedValue ~= nil and component.SetState then
                    pcall(function() component:SetState(savedValue, true) end) -- true = silent
                end
                if component.Toggled then
                    maid:GiveTask(component.Toggled:Connect(function(val: boolean)
                        UIState.Set(stateKey, val)
                    end))
                end
            else
                warn("[Orquestrador] Falha: " .. stateKey .. " nao exporta 'self.Toggle'.")
            end
            
        elseif componentType == "Dropdown" then
            local component = section.Dropdown
            if component then
                if savedValue ~= nil and component.SetSelected then
                    pcall(function() component:SetSelected(savedValue, true) end) -- true = silent
                end
                if component.OnSelectionChanged then
                    maid:GiveTask(component.OnSelectionChanged:Connect(function(val: string)
                        UIState.Set(stateKey, val)
                    end))
                end
            else
                warn("[Orquestrador] Falha: " .. stateKey .. " nao exporta 'self.Dropdown'.")
            end

        elseif componentType == "Keybind" then
            local component = section.Keybox or section.KeyBind or section
            if component then
                -- Keybind mantida conforme regra obrigatória 8
                if savedValue and type(savedValue) == "string" and component.SetKey then
                    pcall(function() component:SetKey(Enum.KeyCode[savedValue], true) end)
                end
                if component.KeyChanged then
                    maid:GiveTask(component.KeyChanged:Connect(function(k: Enum.KeyCode?)
                        UIState.Set(stateKey, k and k.Name or nil)
                    end))
                end
            end
        end
    end

    -- 🎯 PAINEL DE CONTROLE DE MEMÓRIA
    Orchestrator.Bind(secKeybind,   "Aimlock_Keybind",   "Keybind")
    Orchestrator.Bind(secKeyHold,   "Aimlock_KeyHold",   "Toggle")
    Orchestrator.Bind(secPredict,   "Aimlock_Predict",   "TextBox")
    Orchestrator.Bind(secSmooth,    "Aimlock_Smooth",    "TextBox")
    Orchestrator.Bind(secAimPart,   "Aimlock_AimPart",   "Dropdown")
    Orchestrator.Bind(secWallCheck, "Aimlock_WallCheck", "Toggle")
    Orchestrator.Bind(secKnockCheck,"Aimlock_KnockCheck","Toggle")
    -- =========================================================================

    maid:GiveTask(container)
    local self = {}
    self.Instance = container
    function self:Destroy() maid:Destroy() end
    return self :: AimlockUI
end

return AimlockFactory
