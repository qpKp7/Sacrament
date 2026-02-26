--!strict
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function()
        return Import(path)
    end)
    if not success then
        warn("[Sacrament] Falha ao importar dependência em Fly: " .. path)
        return nil
    end
    return result
end

local ToggleButton = SafeImport("gui/modules/components/togglebutton")
local Arrow = SafeImport("gui/modules/components/arrow")
local GlowBar = SafeImport("gui/modules/components/glowbar")
local Sidebar = SafeImport("gui/modules/components/sidebar")

export type FlyUI = {
    Instance: Frame,
    Destroy: (self: FlyUI) -> ()
}

local FlyFactory = {}

local COLOR_WHITE = Color3.fromHex("B4B4B4")
local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_STROKE = Color3.fromHex("333333")
local COLOR_TEXT_WHITE = Color3.fromHex("FFFFFF")
local COLOR_ACCENT = Color3.fromHex("C80000")
local FONT_MAIN = Enum.Font.GothamBold

function FlyFactory.new(layoutOrder: number?): FlyUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "FlyContainer"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1 
    container.BorderSizePixel = 0
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.LayoutOrder = layoutOrder or 1

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
    title.Text = "Fly"
    title.TextColor3 = COLOR_WHITE
    title.Font = FONT_MAIN
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local controls = Instance.new("Frame")
    controls.Name = "Controls"
    controls.Size = UDim2.fromOffset(0, 50)
    controls.AutomaticSize = Enum.AutomaticSize.X
    controls.Position = UDim2.fromScale(1, 0)
    controls.AnchorPoint = Vector2.new(1, 0)
    controls.BackgroundTransparency = 1
    controls.Parent = header

    local ctrlLayout = Instance.new("UIListLayout")
    ctrlLayout.FillDirection = Enum.FillDirection.Horizontal
    ctrlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ctrlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ctrlLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ctrlLayout.Padding = UDim.new(0, 15)
    ctrlLayout.Parent = controls

    local ctrlPadding = Instance.new("UIPadding")
    ctrlPadding.PaddingRight = UDim.new(0, 20)
    ctrlPadding.Parent = controls
    
    local toggleBtn = nil
    if ToggleButton and type(ToggleButton.new) == "function" then
        toggleBtn = ToggleButton.new()
        toggleBtn.Instance.LayoutOrder = 1
        toggleBtn.Instance.Parent = controls
        maid:GiveTask(toggleBtn)
    end

    local arrow = nil
    if Arrow and type(Arrow.new) == "function" then
        arrow = Arrow.new()
        arrow.Instance.LayoutOrder = 2
        arrow.Instance.Parent = controls
        maid:GiveTask(arrow)
    end

    local glowWrapper = Instance.new("Frame")
    glowWrapper.Name = "GlowWrapper"
    glowWrapper.AnchorPoint = Vector2.new(0, 0.5)
    glowWrapper.BackgroundTransparency = 1
    glowWrapper.Parent = header

    local glowBar = nil
    if GlowBar and type(GlowBar.new) == "function" then
        glowBar = GlowBar.new()
        glowBar.Instance.AnchorPoint = Vector2.new(0.5, 0.5)
        glowBar.Instance.Position = UDim2.fromScale(0.5, 0.5)
        glowBar.Instance.AutomaticSize = Enum.AutomaticSize.None
        glowBar.Instance.Size = UDim2.fromScale(1, 1)
        glowBar.Instance.Parent = glowWrapper

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
    subFrame.Size = UDim2.new(1, 0, 0, 300)
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

    -- 1. Cabecalho Fixo: Keybind + Linha Horizontal
    local keybindRow = Instance.new("Frame")
    keybindRow.Size = UDim2.new(1, 0, 0, 45)
    keybindRow.BackgroundTransparency = 1
    keybindRow.LayoutOrder = 1
    keybindRow.Parent = rightContent

    local kbPad = Instance.new("UIPadding")
    kbPad.PaddingLeft = UDim.new(0, 20)
    kbPad.PaddingRight = UDim.new(0, 25)
    kbPad.Parent = keybindRow

    local kbTitle = Instance.new("TextLabel")
    kbTitle.Size = UDim2.new(0.5, 0, 1, 0)
    kbTitle.BackgroundTransparency = 1
    kbTitle.Text = "KEY"
    kbTitle.TextColor3 = COLOR_LABEL
    kbTitle.Font = FONT_MAIN
    kbTitle.TextSize = 18
    kbTitle.TextXAlignment = Enum.TextXAlignment.Left
    kbTitle.Parent = keybindRow

    -- Correção 2: Valuebox KEY com tamanho proporcional (130x32) e texto NONE vermelho sangue
    local kbBtnBg = Instance.new("Frame")
    kbBtnBg.Size = UDim2.new(0, 130, 0, 32) 
    kbBtnBg.AnchorPoint = Vector2.new(1, 0.5)
    kbBtnBg.Position = UDim2.new(1, 0, 0.5, 0)
    kbBtnBg.BackgroundColor3 = COLOR_BG
    kbBtnBg.Parent = keybindRow

    local kbCorner = Instance.new("UICorner")
    kbCorner.CornerRadius = UDim.new(0, 4)
    kbCorner.Parent = kbBtnBg

    local kbStroke = Instance.new("UIStroke")
    kbStroke.Color = COLOR_STROKE
    kbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    kbStroke.Parent = kbBtnBg

    local kbBtn = Instance.new("TextButton")
    kbBtn.Size = UDim2.fromScale(1, 1)
    kbBtn.BackgroundTransparency = 1
    kbBtn.Text = "NONE"
    kbBtn.TextColor3 = COLOR_ACCENT 
    kbBtn.Font = FONT_MAIN
    kbBtn.TextSize = 14
    kbBtn.Parent = kbBtnBg

    local isListening = false
    local currentKey: Enum.KeyCode? = nil
    maid:GiveTask(kbBtn.Activated:Connect(function()
        if isListening then return end
        isListening = true
        kbBtn.Text = "...?"
        kbBtn.TextColor3 = COLOR_ACCENT
        kbStroke.Color = COLOR_ACCENT
    end))
    maid:GiveTask(UserInputService.InputBegan:Connect(function(input)
        if not isListening then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
                currentKey = nil
                kbBtn.Text = "NONE"
                kbBtn.TextColor3 = COLOR_ACCENT
            else
                currentKey = input.KeyCode
                kbBtn.Text = currentKey.Name:upper()
                kbBtn.TextColor3 = COLOR_TEXT_WHITE
            end
            isListening = false
            kbStroke.Color = COLOR_STROKE
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
            isListening = false
            kbStroke.Color = COLOR_STROKE
            kbBtn.Text = currentKey and currentKey.Name:upper() or "NONE"
            kbBtn.TextColor3 = currentKey and COLOR_TEXT_WHITE or COLOR_ACCENT
        end
    end))

    if Sidebar and type(Sidebar.createHorizontal) == "function" then
        local hLine = Sidebar.createHorizontal(2)
        hLine.Instance.Parent = rightContent
        maid:GiveTask(hLine)
    end

    -- 2. Area Rolável (InputsScroll)
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
    inputsPadding.PaddingRight = UDim.new(0, 25)
    inputsPadding.Parent = inputsScroll

    -- Correção 1: Key Hold alinhado à direita de forma simétrica
    local keyHoldRow = Instance.new("Frame")
    keyHoldRow.Size = UDim2.new(1, 0, 0, 45)
    keyHoldRow.BackgroundTransparency = 1
    keyHoldRow.LayoutOrder = 1
    keyHoldRow.Parent = inputsScroll

    local khPad = Instance.new("UIPadding")
    khPad.PaddingLeft = UDim.new(0, 20)
    khPad.Parent = keyHoldRow

    local khTitle = Instance.new("TextLabel")
    khTitle.Size = UDim2.new(0.5, 0, 1, 0)
    khTitle.BackgroundTransparency = 1
    khTitle.Text = "Key Hold"
    khTitle.TextColor3 = COLOR_LABEL
    khTitle.Font = FONT_MAIN
    khTitle.TextSize = 18
    khTitle.TextXAlignment = Enum.TextXAlignment.Left
    khTitle.Parent = keyHoldRow

    if ToggleButton and type(ToggleButton.new) == "function" then
        local khToggle = ToggleButton.new()
        khToggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
        khToggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        khToggle.Instance.Parent = keyHoldRow
        maid:GiveTask(khToggle)
    end

    -- 2.2 Fly Speed Toggle
    local flySpeedToggleRow = Instance.new("Frame")
    flySpeedToggleRow.Name = "FlySpeedToggleRow"
    flySpeedToggleRow.Size = UDim2.new(1, 0, 0, 45)
    flySpeedToggleRow.BackgroundTransparency = 1
    flySpeedToggleRow.LayoutOrder = 2
    flySpeedToggleRow.Parent = inputsScroll

    local fstPad = Instance.new("UIPadding")
    fstPad.PaddingLeft = UDim.new(0, 20)
    fstPad.Parent = flySpeedToggleRow

    local fstTitle = Instance.new("TextLabel")
    fstTitle.Size = UDim2.new(0.5, 0, 1, 0)
    fstTitle.BackgroundTransparency = 1
    fstTitle.Text = "Fly Speed"
    fstTitle.TextColor3 = COLOR_LABEL
    fstTitle.Font = FONT_MAIN
    fstTitle.TextSize = 18
    fstTitle.TextXAlignment = Enum.TextXAlignment.Left
    fstTitle.Parent = flySpeedToggleRow

    local fstToggle = nil
    if ToggleButton and type(ToggleButton.new) == "function" then
        fstToggle = ToggleButton.new()
        fstToggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
        fstToggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        fstToggle.Instance.Parent = flySpeedToggleRow
        maid:GiveTask(fstToggle)
    end

    -- 2.3 Fly Speed Slider (0 a 300, sem value box)
    local flySpeedSliderRow = Instance.new("Frame")
    flySpeedSliderRow.Name = "FlySpeedSliderRow"
    flySpeedSliderRow.Size = UDim2.new(1, 0, 0, 45)
    flySpeedSliderRow.BackgroundTransparency = 1
    flySpeedSliderRow.LayoutOrder = 3
    flySpeedSliderRow.Visible = false
    flySpeedSliderRow.Parent = inputsScroll

    local fssPad = Instance.new("UIPadding")
    fssPad.PaddingLeft = UDim.new(0, 20)
    fssPad.Parent = flySpeedSliderRow

    local fssTitle = Instance.new("TextLabel")
    fssTitle.Size = UDim2.new(0.5, 0, 1, 0)
    fssTitle.BackgroundTransparency = 1
    fssTitle.Text = "Speed"
    fssTitle.TextColor3 = COLOR_LABEL
    fssTitle.Font = FONT_MAIN
    fssTitle.TextSize = 18
    fssTitle.TextXAlignment = Enum.TextXAlignment.Left
    fssTitle.Parent = flySpeedSliderRow

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(0, 120, 0, 4)
    track.AnchorPoint = Vector2.new(1, 0.5)
    track.Position = UDim2.new(1, 0, 0.5, 0)
    track.BackgroundColor3 = COLOR_STROKE
    track.AutoButtonColor = false
    track.Text = ""
    track.Parent = flySpeedSliderRow

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(32 / 300, 1)
    fill.BackgroundColor3 = COLOR_ACCENT
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(12, 12)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(1, 0, 0.5, 0)
    knob.BackgroundColor3 = COLOR_TEXT_WHITE
    knob.Parent = fill
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local isDragging = false
    maid:GiveTask(track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            local pct = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.fromScale(pct, 1)
        end
    end))

    maid:GiveTask(UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end))

    maid:GiveTask(RunService.RenderStepped:Connect(function()
        if isDragging then
            local mousePos = UserInputService:GetMouseLocation().X
            local pct = math.clamp((mousePos - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.fromScale(pct, 1)
        end
    end))

    if fstToggle then
        maid:GiveTask(fstToggle.Toggled:Connect(function(state: boolean)
            flySpeedSliderRow.Visible = state
        end))
    end

    -- Correção 3: Dropdown Animation alinhado com o padrão COMBAT
    local animContainer = Instance.new("Frame")
    animContainer.Name = "AnimationContainer"
    animContainer.Size = UDim2.new(1, 0, 0, 45)
    animContainer.BackgroundTransparency = 1
    animContainer.AutomaticSize = Enum.AutomaticSize.Y
    animContainer.LayoutOrder = 4
    animContainer.Parent = inputsScroll

    local animHeaderRow = Instance.new("Frame")
    animHeaderRow.Size = UDim2.new(1, 0, 0, 45)
    animHeaderRow.BackgroundTransparency = 1
    animHeaderRow.Parent = animContainer

    local animPad = Instance.new("UIPadding")
    animPad.PaddingLeft = UDim.new(0, 20)
    animPad.Parent = animHeaderRow

    local animTitle = Instance.new("TextLabel")
    animTitle.Size = UDim2.new(0.5, 0, 1, 0)
    animTitle.BackgroundTransparency = 1
    animTitle.Text = "Animation"
    animTitle.TextColor3 = COLOR_LABEL
    animTitle.Font = FONT_MAIN
    animTitle.TextSize = 18
    animTitle.TextXAlignment = Enum.TextXAlignment.Left
    animTitle.Parent = animHeaderRow

    local animBtn = Instance.new("TextButton")
    animBtn.Size = UDim2.new(0, 130, 0, 32)
    animBtn.AnchorPoint = Vector2.new(1, 0.5)
    animBtn.Position = UDim2.new(1, 0, 0.5, 0)
    animBtn.BackgroundColor3 = COLOR_BG
    animBtn.Text = ""
    animBtn.AutoButtonColor = false
    animBtn.Parent = animHeaderRow

    local animCorner = Instance.new("UICorner")
    animCorner.CornerRadius = UDim.new(0, 6) 
    animCorner.Parent = animBtn

    local animStroke = Instance.new("UIStroke")
    animStroke.Color = COLOR_STROKE
    animStroke.Thickness = 1
    animStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    animStroke.Parent = animBtn

    local animText = Instance.new("TextLabel")
    animText.Size = UDim2.new(1, -30, 1, 0)
    animText.Position = UDim2.fromOffset(10, 0)
    animText.BackgroundTransparency = 1
    animText.Text = "None"
    animText.TextColor3 = COLOR_TEXT_WHITE
    animText.Font = FONT_MAIN
    animText.TextSize = 14
    animText.TextXAlignment = Enum.TextXAlignment.Left
    animText.Parent = animBtn

    local animArrow = Instance.new("TextLabel")
    animArrow.Size = UDim2.new(0, 20, 1, 0)
    animArrow.Position = UDim2.new(1, -25, 0, 0)
    animArrow.BackgroundTransparency = 1
    animArrow.Text = ">"
    animArrow.TextColor3 = COLOR_TEXT_WHITE
    animArrow.Font = FONT_MAIN
    animArrow.TextSize = 14
    animArrow.Parent = animBtn

    local animList = Instance.new("Frame")
    animList.Size = UDim2.new(1, 0, 0, 0)
    animList.BackgroundTransparency = 1
    animList.Visible = false
    animList.AutomaticSize = Enum.AutomaticSize.Y
    animList.Parent = animContainer

    local animListLayout = Instance.new("UIListLayout")
    animListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    animListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    animListLayout.Padding = UDim.new(0, 5)
    animListLayout.Parent = animList

    local animListPad = Instance.new("UIPadding")
    animListPad.PaddingTop = UDim.new(0, 5)
    animListPad.Parent = animList

    local options = {
        {name = "None", id = ""},
        {name = "Vampire", id = "rbxassetid://1113743239"},
        {name = "Ninja", id = "rbxassetid://754639239"},
        {name = "Mage", id = "rbxassetid://658833139"},
        {name = "Toy", id = "rbxassetid://973773170"}
    }

    local isAnimOpen = false
    maid:GiveTask(animBtn.Activated:Connect(function()
        isAnimOpen = not isAnimOpen
        animList.Visible = isAnimOpen
        animStroke.Color = isAnimOpen and COLOR_ACCENT or COLOR_STROKE
    end))

    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(0, 130, 0, 28)
        optBtn.BackgroundColor3 = COLOR_BG
        optBtn.Text = opt.name
        optBtn.TextColor3 = (i == 1) and COLOR_ACCENT or COLOR_LABEL
        optBtn.Font = FONT_MAIN
        optBtn.TextSize = 14
        optBtn.LayoutOrder = i
        optBtn.Parent = animList

        local optCorner = Instance.new("UICorner")
        optCorner.CornerRadius = UDim.new(0, 4)
        optCorner.Parent = optBtn

        maid:GiveTask(optBtn.Activated:Connect(function()
            animText.Text = opt.name
            isAnimOpen = false
            animList.Visible = false
            animStroke.Color = COLOR_STROKE
            
            for _, child in ipairs(animList:GetChildren()) do
                if child:IsA("TextButton") then
                    child.TextColor3 = (child.Text == opt.name) and COLOR_ACCENT or COLOR_LABEL
                end
            end
        end))
    end

    if toggleBtn and glowBar then
        maid:GiveTask(toggleBtn.Toggled:Connect(function(state: boolean)
            glowBar:SetState(state)
        end))
    end

    local isExpanded = false
    
    -- Correção 4: Hitboxes separadas para evitar conflito (Toggle Fly x Expandir Subframe)
    local arrowHitbox = Instance.new("TextButton")
    arrowHitbox.Name = "ArrowHitbox"
    arrowHitbox.Size = UDim2.new(0, 50, 1, 0)
    arrowHitbox.AnchorPoint = Vector2.new(1, 0)
    arrowHitbox.Position = UDim2.fromScale(1, 0)
    arrowHitbox.BackgroundTransparency = 1
    arrowHitbox.Text = ""
    arrowHitbox.ZIndex = 10 
    arrowHitbox.Parent = header

    maid:GiveTask(arrowHitbox.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded
        subFrame.Visible = isExpanded
        if arrow and type(arrow.SetState) == "function" then
            arrow:SetState(isExpanded)
        end
    end))

    local headerHitbox = Instance.new("TextButton")
    headerHitbox.Name = "HeaderToggleClick"
    headerHitbox.Size = UDim2.new(1, -50, 1, 0) 
    headerHitbox.Position = UDim2.fromScale(0, 0)
    headerHitbox.BackgroundTransparency = 1
    headerHitbox.Text = ""
    headerHitbox.ZIndex = 1 
    headerHitbox.Parent = header

    maid:GiveTask(headerHitbox.MouseButton1Click:Connect(function()
        if toggleBtn then
            pcall(function()
                if type(toggleBtn.Toggle) == "function" then
                    toggleBtn:Toggle()
                elseif type(toggleBtn.SetState) == "function" and toggleBtn.State ~= nil then
                    toggleBtn:SetState(not toggleBtn.State)
                end
            end)
        end
    end))

    maid:GiveTask(container)
    
    local self = {}
    self.Instance = container

    function self:Destroy()
        maid:Destroy()
    end

    return self :: FlyUI
end

return FlyFactory
