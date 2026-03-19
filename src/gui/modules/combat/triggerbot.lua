--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function()
        return Import(path)
    end)
    if not success then
        warn("[Sacrament] Falha ao importar dependência em TriggerBot: " .. path)
        return nil
    end
    return result
end

local UIState = SafeImport("state/uistate") -- [NOVO] O Cofre de Memória

local ToggleButton = SafeImport("gui/modules/components/togglebutton")
local Arrow = SafeImport("gui/modules/components/arrow")
local GlowBar = SafeImport("gui/modules/components/glowbar")
local Sidebar = SafeImport("gui/modules/components/sidebar")
local Slider = SafeImport("gui/modules/components/slider")
local ValueBox = SafeImport("gui/modules/components/valuebox") -- [NOVO] Para o Delay

local KeybindSection = SafeImport("gui/modules/combat/sections/shared/keybind")

export type TriggerBotUI = {
    Instance: Frame,
    Destroy: (self: TriggerBotUI) -> ()
}

local TriggerBotFactory = {}

local COLOR_WHITE = Color3.fromHex("B4B4B4")
local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local FONT_MAIN = Enum.Font.GothamBold

-- [MODIFICADO] Agora devolve a tabela pro Orquestrador ler
local function createToggleRow(maid: any, title: string, layoutOrder: number)
    local row = Instance.new("Frame")
    row.Name = title:gsub(" ", "") .. "Row"
    row.Size = UDim2.new(1, 0, 0, 45)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = COLOR_LABEL
    lbl.Font = FONT_MAIN
    lbl.TextSize = 18
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local toggle = nil
    if ToggleButton and type(ToggleButton.new) == "function" then
        toggle = ToggleButton.new()
        toggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
        toggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        toggle.Instance.Parent = row
        maid:GiveTask(toggle)
    end

    -- Entregando a chave pro Orquestrador!
    return { Instance = row, Toggle = toggle } 
end

-- [MODIFICADO] Usando o ValueBox no Delay para blindar a memória
local function createDelayRow(maid: any, layoutOrder: number)
    local row = Instance.new("Frame")
    row.Name = "DelayRow"
    row.Size = UDim2.new(1, 0, 0, 45)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Delay"
    lbl.TextColor3 = COLOR_LABEL
    lbl.Font = FONT_MAIN
    lbl.TextSize = 18
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local delayBox = nil
    if ValueBox then
        -- Default: 0.03 | Min: 0 | Max: 3 | Decimais: 2 | Limite char: 4
        delayBox = ValueBox.new(0.03, 0, 3, 2, 4)
        delayBox.Instance.AnchorPoint = Vector2.new(1, 0.5)
        delayBox.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        delayBox.Instance.Parent = row
        maid:GiveTask(delayBox)
    end

    return { Instance = row, ValueBox = delayBox }
end

function TriggerBotFactory.new(): TriggerBotUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "TriggerBotContainer"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1 
    container.BorderSizePixel = 0
    container.AutomaticSize = Enum.AutomaticSize.Y

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.FillDirection = Enum.FillDirection.Vertical
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Parent = container

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(0, 280, 0, 50)
    header.BackgroundTransparency = 1
    header.BorderSizePixel = 0
    header.LayoutOrder = 1
    header.ClipsDescendants = true
    header.Parent = container

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.fromOffset(0, 50)
    title.AutomaticSize = Enum.AutomaticSize.X
    title.Position = UDim2.fromOffset(20, 0)
    title.BackgroundTransparency = 1
    title.Text = "Trigger Bot"
    title.TextColor3 = COLOR_WHITE
    title.Font = FONT_MAIN
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Active = false
    title.Parent = header

    local controls = Instance.new("Frame")
    controls.Name = "Controls"
    controls.Size = UDim2.fromOffset(90, 50)
    controls.AnchorPoint = Vector2.new(1, 0)
    controls.Position = UDim2.new(1, -10, 0, 0)
    controls.BackgroundTransparency = 1
    controls.Active = false
    controls.Parent = header
    
    local isEnabled = UIState and UIState.Get("TriggerBotEnabled", false) or false

    local toggleBtn = nil
    if ToggleButton and type(ToggleButton.new) == "function" then
        toggleBtn = ToggleButton.new()
        toggleBtn.Instance.AnchorPoint = Vector2.new(0, 0.5)
        toggleBtn.Instance.Position = UDim2.new(0, 0, 0.5, 0)
        if toggleBtn.SetState then pcall(function() toggleBtn:SetState(isEnabled, true) end) end
        toggleBtn.Instance.Parent = controls
        maid:GiveTask(toggleBtn)
    end

    local arrow = nil
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
    glowWrapper.Active = false
    glowWrapper.Parent = header

    local glowBar = nil
    if GlowBar and type(GlowBar.new) == "function" then
        glowBar = GlowBar.new()
        glowBar.Instance.AnchorPoint = Vector2.new(0.5, 0.5)
        glowBar.Instance.Position = UDim2.fromScale(0.5, 0.5)
        glowBar.Instance.AutomaticSize = Enum.AutomaticSize.None
        glowBar.Instance.Size = UDim2.fromScale(1, 1)
        if glowBar.SetState then glowBar:SetState(isEnabled) end
        glowBar.Instance.Parent = glowWrapper

        local gObj = glowBar.Instance
        if gObj:IsA("GuiObject") then
            gObj.Active = false
        end

        local c1 = glowBar.Instance:FindFirstChildWhichIsA("UISizeConstraint", true)
        if c1 then c1:Destroy() end
        local c2 = glowBar.Instance:FindFirstChildWhichIsA("UIAspectRatioConstraint", true)
        if c2 then c2:Destroy() end
        maid:GiveTask(glowBar)
    end

    local function updateGlowBar()
        if header.AbsoluteSize.X == 0 then return end
        local titleRightAbsolute = title.AbsolutePosition.X + title.AbsoluteSize.X
        local controlsLeftAbsolute = controls.AbsolutePosition.X
        local startX = (titleRightAbsolute - header.AbsolutePosition.X) + 5
        local endX = (controlsLeftAbsolute - header.AbsolutePosition.X) - 5
        local width = math.max(0, endX - startX)
        glowWrapper.Position = UDim2.new(0, startX, 0.5, 0)
        glowWrapper.Size = UDim2.fromOffset(width, 32)
    end

    maid:GiveTask(title:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGlowBar))
    maid:GiveTask(title:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateGlowBar))
    maid:GiveTask(controls:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGlowBar))
    maid:GiveTask(controls:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateGlowBar))
    maid:GiveTask(header:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGlowBar))
    maid:GiveTask(header:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateGlowBar))
    task.defer(updateGlowBar)

    local subFrame = Instance.new("Frame")
    subFrame.Name = "SubFrame"
    subFrame.Size = UDim2.new(1, 0, 0, 250)
    subFrame.BackgroundTransparency = 1
    subFrame.BorderSizePixel = 0
    subFrame.Visible = false
    subFrame.LayoutOrder = 2
    subFrame.Parent = container

    if Sidebar and type(Sidebar.createVertical) == "function" then
        local vLine = Sidebar.createVertical()
        vLine.Instance.Size = UDim2.new(0, 2, 1, 0)
        vLine.Instance.Position = UDim2.fromScale(0, 0)
        vLine.Instance.Parent = subFrame
        maid:GiveTask(vLine)
    end

    local rightContent = Instance.new("Frame")
    rightContent.Name = "RightContent"
    rightContent.Size = UDim2.new(1, -2, 1, 0)
    rightContent.Position = UDim2.fromOffset(2, 0)
    rightContent.BackgroundTransparency = 1
    rightContent.BorderSizePixel = 0
    rightContent.Parent = subFrame

    local rightLayout = Instance.new("UIListLayout")
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Parent = rightContent

    local function loadSec(moduleType: any, order: number, parentInstance: Instance)
        if type(moduleType) == "table" and type(moduleType.new) == "function" then
            local success, instance = pcall(function()
                return moduleType.new(order)
            end)
            if success and instance and instance.Instance then
                instance.Instance.Parent = parentInstance
                maid:GiveTask(instance)
                return instance
            end
        end
        return nil
    end

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
    inputsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    inputsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    inputsScroll.LayoutOrder = 3
    inputsScroll.Parent = rightContent

    local inputsLayout = Instance.new("UIListLayout")
    inputsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    inputsLayout.Padding = UDim.new(0, 15)
    inputsLayout.Parent = inputsScroll

    local inputsPadding = Instance.new("UIPadding")
    inputsPadding.PaddingTop = UDim.new(0, 20)
    inputsPadding.PaddingBottom = UDim.new(0, 20)
    inputsPadding.Parent = inputsScroll

    -- CARREGANDO AS LINHAS COM MEMÓRIA
    local secDelay = createDelayRow(maid, 1)
    secDelay.Instance.Parent = inputsScroll

    local secHitChance = { Instance = nil, Slider = nil }
    if Slider and type(Slider.new) == "function" then
        local hitChanceSlider = Slider.new("Hit Chance", 0, 100, 95)
        hitChanceSlider.Instance.LayoutOrder = 2
        hitChanceSlider.Instance.Parent = inputsScroll
        maid:GiveTask(hitChanceSlider)
        secHitChance.Instance = hitChanceSlider.Instance
        secHitChance.Slider = hitChanceSlider
    end

    local secWallCheck = createToggleRow(maid, "Wall Check", 3)
    secWallCheck.Instance.Parent = inputsScroll

    local secKnockCheck = createToggleRow(maid, "Knock Check", 4)
    secKnockCheck.Instance.Parent = inputsScroll

    if toggleBtn and glowBar then
        maid:GiveTask(toggleBtn.Toggled:Connect(function(state: boolean)
            if glowBar then glowBar:SetState(state) end
            if UIState then UIState.Set("TriggerBotEnabled", state) end
        end))
    end

    -- =========================================================================
    -- 👑 ORQUESTRADOR DE ESTADOS
    -- =========================================================================
    local Orchestrator = {}
    
    function Orchestrator.Bind(section: any, stateKey: string, componentType: string)
        if not section or not UIState then return end
        local savedValue = UIState.Get(stateKey)
        
        if componentType == "TextBox" or componentType == "ValueBox" then
            local component = section.ValueBox or section.TextBox
            if component then
                if savedValue ~= nil and component.SetValue then pcall(function() component:SetValue(savedValue, true) end) end
                if component.OnValueChanged then maid:GiveTask(component.OnValueChanged:Connect(function(val) UIState.Set(stateKey, val) end)) end
            end
        elseif componentType == "Toggle" then
            local component = section.Toggle or section.ToggleButton
            if component then
                if savedValue ~= nil and component.SetState then pcall(function() component:SetState(savedValue, true) end) end
                if component.Toggled then maid:GiveTask(component.Toggled:Connect(function(val: boolean) UIState.Set(stateKey, val) end)) end
            end
        elseif componentType == "Slider" then
            local component = section.Slider
            if component then
                if savedValue ~= nil and component.SetValue then pcall(function() component:SetValue(savedValue, true) end) end
                if component.OnValueChanged then maid:GiveTask(component.OnValueChanged:Connect(function(val) UIState.Set(stateKey, val) end)) end
            end
        elseif componentType == "Keybind" then
            local component = section.Keybox or section.KeyBind or section
            if component then
                if savedValue and type(savedValue) == "string" and component.SetKey then pcall(function() component:SetKey(Enum.KeyCode[savedValue], true) end) end
                if component.KeyChanged then maid:GiveTask(component.KeyChanged:Connect(function(k: Enum.KeyCode?) UIState.Set(stateKey, k and k.Name or nil) end)) end
            end
        end
    end

    -- 🎯 PAINEL DE CONTROLE DE MEMÓRIA DO TRIGGERBOT
    Orchestrator.Bind(secKeybind,    "TriggerBot_Keybind",    "Keybind")
    Orchestrator.Bind(secDelay,      "TriggerBot_Delay",      "ValueBox")
    Orchestrator.Bind(secHitChance,  "TriggerBot_HitChance",  "Slider")
    Orchestrator.Bind(secWallCheck,  "TriggerBot_WallCheck",  "Toggle")
    Orchestrator.Bind(secKnockCheck, "TriggerBot_KnockCheck", "Toggle")
    -- =========================================================================

    maid:GiveTask(container)
    
    local self = {}
    self.Instance = container

    function self:Destroy()
        maid:Destroy()
    end

    return self :: TriggerBotUI
end

return TriggerBotFactory
