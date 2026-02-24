--!strict
local TweenService = game:GetService("TweenService")

local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local AimlockModule = Import("gui/modules/combat/aimlock")
local SilentAimModule = Import("gui/modules/combat/silentaim")
local TriggerBotModule = Import("gui/modules/combat/triggerbot")

export type CombatModule = {
    Instance: Frame,
    Destroy: (self: CombatModule) -> (),
}

type AccordionItem = {
    header: Frame,
    subFrame: Frame,
    controls: Instance?,
    arrowGlyph: Instance?,
    arrowHit: GuiButton?,
}

local CombatModuleFactory = {}

local COLOR_ARROW_CLOSED = Color3.fromHex("CCCCCC")
local COLOR_ARROW_OPEN = Color3.fromHex("C80000")
local TWEEN_INFO = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

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
            local t = desc.Text
            if isArrowText(t) then
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

local function playColorTween(guiObject: GuiObject, targetColor: Color3, isOpen: boolean)
    -- Glow suave utilizando TextStroke nativo para não alterar a UI tree
    local strokeColor = isOpen and COLOR_ARROW_OPEN or Color3.new(0, 0, 0)
    local strokeTransp = isOpen and 0.5 or 1

    local tween = TweenService:Create(guiObject, TWEEN_INFO, { 
        TextColor3 = targetColor,
        TextStrokeColor3 = strokeColor,
        TextStrokeTransparency = strokeTransp
    } :: any)
    tween:Play()
    
    local connection: RBXScriptConnection
    connection = tween.Completed:Connect(function()
        tween:Destroy()
        if connection then
            connection:Disconnect()
        end
    end)
end

local function setArrowVisual(glyph: Instance?, open: boolean, animate: boolean)
    if not glyph then
        return
    end

    local targetText = open and "v" or ">"
    local targetColor = open and COLOR_ARROW_OPEN or COLOR_ARROW_CLOSED

    if glyph:IsA("TextLabel") or glyph:IsA("TextButton") then
        local textObj = glyph :: TextLabel | TextButton
        textObj.Text = targetText
        
        if animate then
            playColorTween(textObj, targetColor, open)
        else
            textObj.TextColor3 = targetColor
            textObj.TextStrokeColor3 = open and COLOR_ARROW_OPEN or Color3.new(0, 0, 0)
            textObj.TextStrokeTransparency = open and 0.5 or 1
        end
    end
end

local function ensureArrowOrder(controls: Instance, arrowGlyph: Instance?)
    local function setOrder(obj: Instance?, order: number)
        if obj and obj:IsA("GuiObject") then
            obj.LayoutOrder = order
        end
    end

    local arrowRoot: Instance? = nil
    if arrowGlyph and arrowGlyph.Parent then
        arrowRoot = arrowGlyph.Parent
    end

    local toggleRoot: Instance? = nil
    for _, child in ipairs(controls:GetChildren()) do
        if child:IsA("GuiObject") then
            if arrowRoot and (child == arrowRoot or child:IsDescendantOf(arrowRoot)) then
                continue
            end
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
    if glyph:IsA("TextButton") then
        return glyph
    end
    if not glyph:IsA("GuiObject") or not glyph.Parent then
        return nil
    end

    local guiObj = glyph :: GuiObject
    local hit = Instance.new("TextButton")
    hit.Name = "ArrowHitbox"
    hit.BackgroundTransparency = 1
    hit.BorderSizePixel = 0
    hit.AutoButtonColor = false
    hit.Text = ""
    hit.ZIndex = guiObj.ZIndex + 1
    hit.AnchorPoint = guiObj.AnchorPoint
    hit.Size = guiObj.Size
    hit.Position = guiObj.Position
    hit.Parent = guiObj.Parent

    local function sync()
        hit.ZIndex = guiObj.ZIndex + 1
        hit.AnchorPoint = guiObj.AnchorPoint
        hit.Size = guiObj.Size
        hit.Position = guiObj.Position
    end

    maid:GiveTask(guiObj:GetPropertyChangedSignal("ZIndex"):Connect(sync))
    maid:GiveTask(guiObj:GetPropertyChangedSignal("AnchorPoint"):Connect(sync))
    maid:GiveTask(guiObj:GetPropertyChangedSignal("Size"):Connect(sync))
    maid:GiveTask(guiObj:GetPropertyChangedSignal("Position"):Connect(sync))

    return hit
end

function CombatModuleFactory.new(): CombatModule
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "CombatContainer"
    container.Size = UDim2.fromScale(1, 1)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ClipsDescendants = true

    local leftPanel = Instance.new("Frame")
    leftPanel.Name = "LeftPanel"
    leftPanel.Size = UDim2.new(0, 280, 1, 0)
    leftPanel.BackgroundTransparency = 1
    leftPanel.BorderSizePixel = 0
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
    rightPanel.BorderSizePixel = 0
    rightPanel.Parent = container

    local items: { AccordionItem } = {}
    local openItem: AccordionItem? = nil
    local isSyncing = false

    local function applyState(item: AccordionItem, open: boolean, animate: boolean)
        isSyncing = true
        item.subFrame.Visible = open
        setArrowVisual(item.arrowGlyph, open, animate)
        isSyncing = false
    end

    local function bindAccordion(item: AccordionItem)
        local controls = findControls(item.header)
        if not controls then
            return
        end
        item.controls = controls

        local glyph = findArrowGlyph(controls)
        item.arrowGlyph = glyph

        if glyph then
            ensureArrowOrder(controls, glyph)
            item.arrowHit = createHitboxOverGlyph(maid, glyph)
            
            -- Blindagem absoluta: Bloqueia rotações de scripts internos (evita o bug do "<")
            if glyph:IsA("GuiObject") then
                maid:GiveTask(glyph:GetPropertyChangedSignal("Rotation"):Connect(function()
                    if glyph.Rotation ~= 0 then
                        glyph.Rotation = 0
                    end
                end))
                glyph.Rotation = 0
            end
        end

        -- Orquestrador de Exclusividade: Intercepta qualquer mudança de visibilidade
        maid:GiveTask(item.subFrame:GetPropertyChangedSignal("Visible"):Connect(function()
            if isSyncing then return end
            
            local isOpen = item.subFrame.Visible
            if isOpen then
                if openItem and openItem ~= item then
                    applyState(openItem, false, true)
                end
                openItem = item
                applyState(item, true, true)
            else
                if openItem == item then
                    openItem = nil
                    applyState(item, false, true)
                end
            end
        end))

        if item.arrowHit then
            maid:GiveTask(item.arrowHit.Activated:Connect(function()
                item.subFrame.Visible = not item.subFrame.Visible
            end))
        end

        applyState(item, false, false)
    end

    local function registerAccordion(header: Frame, subFrame: Frame, layoutOrder: number)
        header.LayoutOrder = layoutOrder
        header.Parent = leftPanel
        header.Visible = true

        subFrame.Size = UDim2.fromScale(1, 1)
        subFrame.Parent = rightPanel
        subFrame.Visible = false

        local item: AccordionItem = {
            header = header,
            subFrame = subFrame,
            controls = nil,
            arrowGlyph = nil,
            arrowHit = nil,
        }
        table.insert(items, item)

        task.defer(function()
            bindAccordion(item)
        end)
    end

    local function safeLoadSection(moduleType: any, order: number)
        if typeof(moduleType) == "table" and moduleType.new then
            local success, instance = pcall(function()
                return moduleType.new()
            end)
            
            if success and instance then
                maid:GiveTask(instance)
                local header = instance.Instance:FindFirstChild("Header")
                local subFrame = instance.Instance:FindFirstChild("SubFrame")
                
                if header and subFrame then
                    registerAccordion(header :: Frame, subFrame :: Frame, order)
                end
            end
        end
    end

    safeLoadSection(AimlockModule, 1)
    safeLoadSection(SilentAimModule, 2)
    safeLoadSection(TriggerBotModule, 3)

    maid:GiveTask(container)

    local self = {}
    self.Instance = container

    function self:Destroy()
        maid:Destroy()
    end

    return self :: CombatModule
end

return CombatModuleFactory
