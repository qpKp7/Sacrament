--!strict
local TweenService = game:GetService("TweenService")

local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

-- Preparação para os submódulos que criaremos a seguir
local FlyModule = Import("gui/modules/player/fly")
local WalkSpeedModule = Import("gui/modules/player/walkspeed")
local AntiStunModule = Import("gui/modules/player/antistun")
local NoClipModule = Import("gui/modules/player/noclip")

export type PlayerModule = {
    Instance: Frame,
    Destroy: (self: PlayerModule) -> (),
}

type AccordionItem = {
    header: Frame,
    subFrame: Frame,
    controls: Instance?,
    arrowGlyph: Instance?,
    fakeGlyph: TextLabel?,
    fakeStroke: UIStroke?,
    arrowHit: GuiButton?,
}

local PlayerModuleFactory = {}

local COLOR_ARROW_CLOSED = Color3.fromHex("CCCCCC")
local COLOR_ARROW_OPEN = Color3.fromHex("C80000")
local COLOR_GLOW = Color3.fromHex("FF3333") 

local TWEEN_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function isArrowText(t: string): boolean
    return t == ">" or t == "v" or t == "<" or t == "V" or t == "^"
end

local function findControls(header: Frame): Instance?
    return header:FindFirstChild("Controls")
end

local function findArrowGlyph(controls: Instance): Instance?
    local best: Instance? = nil
    local bestX = -math.huge

    for _, desc in ipairs(controls:GetDescendants()) do
        if desc:IsA("TextLabel") or desc:IsA("TextButton") then
            if isArrowText(desc.Text) then
                local x = desc.AbsolutePosition.X
                if x > bestX then
                    bestX = x
                    best = desc
                end
            end
        end
    end
    return best
end

local function setArrowVisual(item: AccordionItem, open: boolean, animate: boolean)
    if not item.fakeGlyph or not item.fakeStroke then return end

    local targetRotation = open and 90 or 0
    local targetColor = open and COLOR_ARROW_OPEN or COLOR_ARROW_CLOSED
    local targetStrokeTrans = open and 0.85 or 1 

    item.fakeGlyph.Text = ">"

    if animate then
        local t1 = TweenService:Create(item.fakeGlyph, TWEEN_INFO, { 
            TextColor3 = targetColor,
            Rotation = targetRotation
        } :: any)
        local t2 = TweenService:Create(item.fakeStroke, TWEEN_INFO, { Transparency = targetStrokeTrans } :: any)
        
        t1:Play()
        t2:Play()
        
        local connection: RBXScriptConnection
        connection = t1.Completed:Connect(function()
            t1:Destroy()
            t2:Destroy()
            if connection then connection:Disconnect() end
        end)
    else
        item.fakeGlyph.TextColor3 = targetColor
        item.fakeGlyph.Rotation = targetRotation
        item.fakeStroke.Transparency = targetStrokeTrans
    end
end

local function ensureArrowOrder(controls: Instance, arrowGlyph: Instance?)
    local function setOrder(obj: Instance?, order: number)
        if obj and obj:IsA("GuiObject") then obj.LayoutOrder = order end
    end

    local arrowRoot = if arrowGlyph and arrowGlyph.Parent then arrowGlyph.Parent else nil
    local toggleRoot: Instance? = nil

    for _, child in ipairs(controls:GetChildren()) do
        if child:IsA("GuiObject") then
            if arrowRoot and (child == arrowRoot or child:IsDescendantOf(arrowRoot)) then continue end
            toggleRoot = child
            break
        end
    end

    if arrowRoot and arrowRoot:IsA("GuiObject") then
        setOrder(toggleRoot, 1)
        setOrder(arrowRoot, 2)
    end
end

local function createHitboxOverGlyph(maid: any, glyph: Instance): GuiButton?
    if glyph:IsA("TextButton") then return glyph end
    if not glyph:IsA("GuiObject") or not glyph.Parent then return nil end

    local guiObj = glyph :: GuiObject
    local hit = Instance.new("TextButton")
    hit.Name = "ArrowHitbox"
    hit.BackgroundTransparency = 1
    hit.BorderSizePixel = 0
    hit.AutoButtonColor = false
    hit.Text = ""
    hit.ZIndex = guiObj.ZIndex + 1
    hit.Parent = guiObj.Parent

    local function sync()
        hit.ZIndex = guiObj.ZIndex + 1
        hit.AnchorPoint = guiObj.AnchorPoint
        hit.Size = guiObj.Size
        hit.Position = guiObj.Position
    end

    maid:GiveTask(guiObj:GetPropertyChangedSignal("ZIndex"):Connect(sync))
    maid:GiveTask(guiObj:GetPropertyChangedSignal("Size"):Connect(sync))
    maid:GiveTask(guiObj:GetPropertyChangedSignal("Position"):Connect(sync))
    sync()

    return hit
end

function PlayerModuleFactory.new(): PlayerModule
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "PlayerContainer"
    container.Size = UDim2.fromScale(1, 1)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ClipsDescendants = true

    local leftPanel = Instance.new("Frame")
    leftPanel.Name = "LeftPanel"
    leftPanel.Size = UDim2.new(0, 280, 1, 0)
    leftPanel.BackgroundTransparency = 1
    leftPanel.Parent = container

    local leftLayout = Instance.new("UIListLayout")
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Padding = UDim.new(0, 10)
    leftLayout.Parent = leftPanel

    local rightPanel = Instance.new("Frame")
    rightPanel.Name = "RightPanel"
    rightPanel.Size = UDim2.new(1, -280, 1, 0)
    rightPanel.Position = UDim2.fromOffset(280, 0)
    rightPanel.BackgroundTransparency = 1
    rightPanel.Parent = container

    local items: { AccordionItem } = {}
    local openItem: AccordionItem? = nil
    local isSyncing = false

    local function applyState(item: AccordionItem, open: boolean, animate: boolean)
        isSyncing = true
        item.subFrame.Visible = open
        setArrowVisual(item, open, animate)
        isSyncing = false
    end

    local function bindAccordion(item: AccordionItem)
        local controls = findControls(item.header)
        if not controls then return end
        
        item.controls = controls
        local glyph = findArrowGlyph(controls)
        item.arrowGlyph = glyph

        if glyph then
            ensureArrowOrder(controls, glyph)
            item.arrowHit = createHitboxOverGlyph(maid, glyph)
            
            if glyph:IsA("TextLabel") or glyph:IsA("TextButton") then
                local textObj = glyph :: TextLabel | TextButton
                textObj.TextTransparency = 1
                textObj.TextStrokeTransparency = 1
            end

            local fake = Instance.new("TextLabel")
            fake.Name = "FakeArrowClean"
            fake.BackgroundTransparency = 1
            fake.Size = UDim2.fromScale(1, 1)
            fake.Position = UDim2.fromScale(0.5, 0.5)
            fake.AnchorPoint = Vector2.new(0.5, 0.5)
            fake.Font = Enum.Font.GothamBold
            fake.TextSize = 18
            fake.Text = ">"
            fake.Rotation = 0
            fake.TextColor3 = COLOR_ARROW_CLOSED
            fake.ZIndex = glyph.ZIndex + 1
            fake.Parent = glyph.Parent 
            
            local stroke = Instance.new("UIStroke")
            stroke.Color = COLOR_GLOW
            stroke.Thickness = 1
            stroke.Transparency = 1
            stroke.Parent = fake

            item.fakeGlyph = fake
            item.fakeStroke = stroke
            maid:GiveTask(fake)
        end

        -- Limpa botões de clique globais antigos que possam ter vindo do módulo filho
        local oldHeaderClick = item.header:FindFirstChild("HeaderClick")
        if oldHeaderClick then
            oldHeaderClick:Destroy()
        end
        local oldPlayerClick = item.header:FindFirstChild("PlayerHeaderClick")
        if oldPlayerClick then
            oldPlayerClick:Destroy()
        end

        local function toggleSubframe()
            item.subFrame.Visible = not item.subFrame.Visible
        end

        -- O evento de expandir o subframe é atrelado EXCLUSIVAMENTE à hitbox da Seta
        if item.arrowHit then
            maid:GiveTask(item.arrowHit.Activated:Connect(toggleSubframe))
        end

        maid:GiveTask(item.subFrame:GetPropertyChangedSignal("Visible"):Connect(function()
            if isSyncing then return end
            
            local isOpen = item.subFrame.Visible
            if isOpen then
                if openItem and openItem ~= item then applyState(openItem, false, true) end
                openItem = item
                applyState(item, true, true)
            elseif openItem == item then
                openItem = nil
                applyState(item, false, true)
            end
        end))

        applyState(item, false, false)
    end

    local function registerAccordion(header: Frame, subFrame: Frame, layoutOrder: number)
        header.LayoutOrder = layoutOrder
        header.Parent = leftPanel
        subFrame.Size = UDim2.fromScale(1, 1)
        subFrame.Parent = rightPanel

        local item: AccordionItem = {
            header = header, subFrame = subFrame, controls = nil,
            arrowGlyph = nil, fakeGlyph = nil, fakeStroke = nil, arrowHit = nil,
        }
        table.insert(items, item)
        task.defer(function() bindAccordion(item) end)
    end

    local function safeLoadSection(moduleType: any, order: number)
        if typeof(moduleType) == "table" and moduleType.new then
            local success, instance = pcall(function() return moduleType.new() end)
            if success and instance then
                maid:GiveTask(instance)
                local header = instance.Instance:FindFirstChild("Header")
                local subFrame = instance.Instance:FindFirstChild("SubFrame")
                if header and subFrame then registerAccordion(header :: Frame, subFrame :: Frame, order) end
            end
        end
    end

    -- Carrega os submódulos da aba Player na ordem solicitada
    safeLoadSection(FlyModule, 1)
    safeLoadSection(WalkSpeedModule, 2)
    safeLoadSection(AntiStunModule, 3)
    safeLoadSection(NoClipModule, 4)

    maid:GiveTask(container)
    local self = {}
    self.Instance = container
    function self:Destroy() maid:Destroy() end
    return self :: PlayerModule
end

-- Função obrigatória solicitada para injetar o frame direto no parent
function PlayerModuleFactory.createPlayerFrame(parent: Frame): Frame
    local playerMod = PlayerModuleFactory.new()
    playerMod.Instance.Parent = parent
    return playerMod.Instance
end

return PlayerModuleFactory
