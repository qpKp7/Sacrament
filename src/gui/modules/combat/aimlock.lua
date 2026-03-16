--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function()
        return Import(path)
    end)
    if not success then
        warn("[Sacrament] Falha ao importar: " .. path)
        return nil
    end
    return result
end

-- Importação do Cérebro de Estado
local UIState = SafeImport("state/uistate")

local ToggleButton = SafeImport("gui/modules/components/togglebutton")
local Arrow = SafeImport("gui/modules/components/arrow")
local GlowBar = SafeImport("gui/modules/components/glowbar")
local Sidebar = SafeImport("gui/modules/components/sidebar")

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

-- =========================================================================
-- MÁQUINA DE BINDING UNIVERSAL
-- =========================================================================
local function UniversalStateBinder(sectionTable: any, stateKey: string, state: any, maid: any)
    if not state or not sectionTable then return end
    
    local root = sectionTable.Instance
    if not root then return end

    -- [TOGGLE BUTTON / KEYHOLD]
    if sectionTable.Toggled and sectionTable.SetState then
        local savedVal = state.Get(stateKey, false)
        sectionTable:SetState(savedVal, true)
        
        maid:GiveTask(sectionTable.Toggled:Connect(function(val: boolean)
            state.Set(stateKey, val)
        end))
        return
    end

    -- [SLIDER EXTERNO]
    if sectionTable.OnValueChanged and sectionTable.SetValue then
        local savedVal = state.Get(stateKey)
        if savedVal ~= nil then
            sectionTable:SetValue(savedVal)
        end
        
        maid:GiveTask(sectionTable.OnValueChanged:Connect(function(val: number)
            state.Set(stateKey, val)
        end))
        return
    end

    -- [KEYBOX EXTERNO / KEYBIND]
    if sectionTable.KeyChanged and sectionTable.SetKey then
        local savedKeyName = state.Get(stateKey)
        
        if savedKeyName and type(savedKeyName) == "string" then
            local success, enumItem = pcall(function() return Enum.KeyCode[savedKeyName] end)
            if success then
                sectionTable:SetKey(enumItem)
            end
        end

        maid:GiveTask(sectionTable.KeyChanged:Connect(function(keyEnum: Enum.KeyCode?)
            state.Set(stateKey, keyEnum and keyEnum.Name or nil)
        end))
        return
    end

    -- [VALUEBOX / TEXTBOX INTERNO] (Ex: SmoothBox)
    local box = root:FindFirstChildWhichIsA("TextBox", true)
    if box then
        local savedText = state.Get(stateKey, box.Text)
        box.Text = savedText
        
        maid:GiveTask(box.FocusLost:Connect(function()
            task.defer(function()
                state.Set(stateKey, box.Text)
            end)
        end))
    end

    -- [DROPDOWN INTERNO] (Ex: Aim Part)
    local displayLabel = nil
    for _, child in ipairs(root:GetDescendants()) do
        if child:IsA("TextLabel") and child.Parent and child.Parent:IsA("TextButton") then
            if child.Name ~= "Label" and child.Text ~= ">" then
                displayLabel = child
                break
            end
        end
    end

    if displayLabel then
        local savedDropdown = state.Get(stateKey, displayLabel.Text)
        displayLabel.Text = savedDropdown
        
        maid:GiveTask(displayLabel:GetPropertyChangedSignal("Text"):Connect(function()
            state.Set(stateKey, displayLabel.Text)
        end))
    end
end

function AimlockFactory.new(): AimlockUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "AimlockContainer"
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
    title.Text = "Aimlock"
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

    -- Pega os estados guardados em memória volátil
    local isEnabled = UIState and UIState.Get("AimlockEnabled", false) or false
    local isExpanded = UIState and UIState.Get("AimlockExpanded", false) or false

    local toggleBtn
    if ToggleButton and type(ToggleButton.new) == "function" then
        toggleBtn = ToggleButton.new()
        toggleBtn.Instance.AnchorPoint = Vector2.new(0, 0.5)
        toggleBtn.Instance.Position = UDim2.new(0, 0, 0.5, 0)
        -- NÃO aplica o SetState aqui, vamos fazê-lo pós-montagem
        toggleBtn.Instance.Parent = controls
        maid:GiveTask(toggleBtn)
    end

    local arrow
    if Arrow and type(Arrow.new) == "function" then
        arrow = Arrow.new()
        arrow.Instance.AnchorPoint = Vector2.new(1, 0.5)
        arrow.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        -- NÃO aplica o SetState aqui, vamos fazê-lo pós-montagem
        arrow.Instance.Parent = controls
        maid:GiveTask(arrow)
    end

    local glowWrapper = Instance.new("Frame")
    glowWrapper.Name = "GlowWrapper"
    glowWrapper.AnchorPoint = Vector2.new(0, 0.5)
    glowWrapper.BackgroundTransparency = 1
    glowWrapper.Active = false
    glowWrapper.Parent = header

    local glowBar
    if GlowBar and type(GlowBar.new) == "function" then
        glowBar = GlowBar.new()
        glowBar.Instance.AnchorPoint = Vector2.new(0.5, 0.5)
        glowBar.Instance.Position = UDim2.fromScale(0.5, 0.5)
        glowBar.Instance.AutomaticSize = Enum.AutomaticSize.None
        glowBar.Instance.Size = UDim2.fromScale(1, 1)
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
    maid:GiveTask(header:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGlowBar))
    task.defer(updateGlowBar)

    local subFrame = Instance.new("Frame")
    subFrame.Name = "SubFrame"
    subFrame.Size = UDim2.new(1, 0, 0, 320)
    subFrame.BackgroundTransparency = 1
    subFrame.BorderSizePixel = 0
    -- BUG RESOLVIDO: O SubFrame nasce sempre invisível para forçar o recalculo do AutomaticSize!
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

    local function safeLoadSection(moduleType: any, sectionID: string, order: number, parentInstance: Instance, state: any)
        if typeof(moduleType) == "table" and moduleType.new then
            local success, instance = pcall(function()
                return moduleType.new(order, state) 
            end)
            if success and instance then
                instance.Instance.Parent = parentInstance
                
                UniversalStateBinder(instance, "Aimlock_" .. sectionID, state, maid)
                
                maid:GiveTask(instance)
            end
        end
    end

    safeLoadSection(KeybindSection, "Keybind", 1, rightContent, UIState)

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

    safeLoadSection(KeyHoldSection, "KeyHold", 1, inputsScroll, UIState)
    safeLoadSection(PredictSection, "Predict", 2, inputsScroll, UIState)
    safeLoadSection(SmoothSection, "Smooth", 3, inputsScroll, UIState)
    safeLoadSection(AimPartSection, "AimPart", 4, inputsScroll, UIState)
    safeLoadSection(WallCheckSection, "WallCheck", 5, inputsScroll, UIState)
    safeLoadSection(KnockCheckSection, "Knock", 6, inputsScroll, UIState)

    -- EVENTOS E INICIALIZAÇÃO PÓS-MONTAGEM (O Segredo para a Seta e o Toggle)
    task.defer(function()
        if toggleBtn and toggleBtn.SetState then 
            toggleBtn:SetState(isEnabled, true) 
        end
        if glowBar and glowBar.SetState then 
            glowBar:SetState(isEnabled) 
        end
        
        if arrow and arrow.SetState then 
            arrow:SetState(isExpanded, true) 
            subFrame.Visible = isExpanded -- Só muda a visibilidade quando tudo já está renderizado!
        end
    end)

    if toggleBtn and UIState then
        maid:GiveTask(toggleBtn.Toggled:Connect(function(state: boolean)
            if glowBar then glowBar:SetState(state) end
            UIState.Set("AimlockEnabled", state)
        end))
    end

    if arrow and UIState then
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
