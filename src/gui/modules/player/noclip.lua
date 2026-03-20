--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local UIState = SafeImport("state/uistate") -- [NOVO] O Cofre de Memória

local ToggleButton = SafeImport("gui/modules/components/togglebutton")
local Arrow = SafeImport("gui/modules/components/arrow")
local GlowBar = SafeImport("gui/modules/components/glowbar")
local Sidebar = SafeImport("gui/modules/components/sidebar")

local KeybindSection = SafeImport("gui/modules/player/sections/shared/keybind")
local KeyHoldSection = SafeImport("gui/modules/player/sections/shared/keyhold")

export type NoclipUI = {
    Instance: Frame,
    Destroy: (self: NoclipUI) -> (),
}

local NoclipFactory = {}

local COLOR_WHITE = Color3.fromHex("B4B4B4")
local FONT_MAIN = Enum.Font.GothamBold

function NoclipFactory.new(layoutOrder: number?): NoclipUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "NoclipContainer"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1 
    container.BorderSizePixel = 0
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.LayoutOrder = layoutOrder or 4

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
    title.Text = "Noclip"
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
    
    -- Puxa o estado do botão principal
    local isEnabled = UIState and UIState.Get("NoclipEnabled", false) or false

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
        if gObj:IsA("GuiObject") then gObj.Active = false end

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
    subFrame.Size = UDim2.new(1, 0, 0, 420)
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

    -- [MODIFICADO] Retorna a instância para o Orquestrador ler
    local function loadSec(moduleType: any, order: number, parentInstance: Instance)
        if type(moduleType) == "table" and type(moduleType.new) == "function" then
            local success, instance = pcall(function() return moduleType.new(order) end)
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

    local secKeyHold = loadSec(KeyHoldSection, 1, inputsScroll)

    -- EVENTO DO TOGGLE PRINCIPAL DO NOCLIP
    if toggleBtn and UIState then
        maid:GiveTask(toggleBtn.Toggled:Connect(function(state: boolean)
            if glowBar then glowBar:SetState(state) end
            UIState.Set("NoclipEnabled", state)
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
        elseif componentType == "Dropdown" then
            local component = section.Dropdown
            if component then
                if savedValue ~= nil and component.SetSelected then pcall(function() component:SetSelected(savedValue, true) end) end
                if component.OnSelectionChanged then maid:GiveTask(component.OnSelectionChanged:Connect(function(val: string) UIState.Set(stateKey, val) end)) end
            end
        elseif componentType == "Slider" then
            local component = section.Slider
            if component then
                if savedValue ~= nil and component.SetValue then pcall(function() component:SetValue(savedValue, true) end) end
                if component.OnValueChanged then maid:GiveTask(component.OnValueChanged:Connect(function(val: number) UIState.Set(stateKey, val) end)) end
            end
        elseif componentType == "Keybind" then
            local component = section.Keybox or section.KeyBind or section
            if component then
                if savedValue and type(savedValue) == "string" and component.SetKey then pcall(function() component:SetKey(Enum.KeyCode[savedValue], true) end) end
                if component.KeyChanged then maid:GiveTask(component.KeyChanged:Connect(function(k: Enum.KeyCode?) UIState.Set(stateKey, k and k.Name or nil) end)) end
            end
        end
    end

    -- 🎯 PAINEL DE CONTROLE DE MEMÓRIA DO NOCLIP
    Orchestrator.Bind(secKeybind, "Noclip_Keybind", "Keybind")
    Orchestrator.Bind(secKeyHold, "Noclip_KeyHold", "Toggle")
    -- =========================================================================

    maid:GiveTask(container)
    local self = {}
    self.Instance = container
    function self:Destroy() maid:Destroy() end
    return self :: NoclipUI
end

return NoclipFactory
