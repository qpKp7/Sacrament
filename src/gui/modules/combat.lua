--!strict
local TweenService = game:GetService("TweenService")

local Import = ((_G :: any).SacramentImport :: any)
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
    button: TextButton,
    stroke: UIStroke,
    tweenColor: Tween?,
    tweenRot: Tween?,
    tweenStroke: Tween?,
}

local CombatModuleFactory = {}

local COLOR_ARROW_CLOSED = Color3.fromHex("CCCCCC")
local COLOR_ARROW_OPEN = Color3.fromHex("C80000")
local COLOR_GLOW = Color3.fromHex("FF3333")

local TWEEN_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function findArrowButtonInHeader(header: Frame): TextButton?
    local controls = header:FindFirstChild("Controls")
    if not controls then
        return nil
    end

    for _, desc in ipairs(controls:GetDescendants()) do
        if desc:IsA("TextButton") then
            local t = desc.Text
            if t == "v" or t == ">" or t == "<" or t == "V" or t == "^" then
                return desc
            end
        end
    end

    return nil
end

local function replaceButton(btn: TextButton): TextButton
    local clone = btn:Clone()
    clone.Parent = btn.Parent
    btn:Destroy()
    return clone
end

local function cancelTweens(item: AccordionItem)
    if item.tweenColor then
        item.tweenColor:Cancel()
        item.tweenColor:Destroy()
        item.tweenColor = nil
    end
    if item.tweenRot then
        item.tweenRot:Cancel()
        item.tweenRot:Destroy()
        item.tweenRot = nil
    end
    if item.tweenStroke then
        item.tweenStroke:Cancel()
        item.tweenStroke:Destroy()
        item.tweenStroke = nil
    end
end

local function applyState(item: AccordionItem, isOpen: boolean, animate: boolean)
    cancelTweens(item)

    item.subFrame.Visible = isOpen

    local targetColor = if isOpen then COLOR_ARROW_OPEN else COLOR_ARROW_CLOSED
    local targetRotation = if isOpen then 90 else 0
    local targetStrokeTransparency = if isOpen then 0.7 else 1

    if not animate then
        item.button.TextColor3 = targetColor
        item.button.Rotation = targetRotation
        item.stroke.Transparency = targetStrokeTransparency
        return
    end

    item.tweenColor = TweenService:Create(item.button, TWEEN_INFO, { TextColor3 = targetColor })
    item.tweenRot = TweenService:Create(item.button, TWEEN_INFO, { Rotation = targetRotation })
    item.tweenStroke = TweenService:Create(item.stroke, TWEEN_INFO, { Transparency = targetStrokeTransparency })

    item.tweenColor:Play()
    item.tweenRot:Play()
    item.tweenStroke:Play()
end

function CombatModuleFactory.new(): CombatModule
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "CombatContainer"
    container.Size = UDim2.fromScale(1, 1)
    container.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    container.BorderSizePixel = 0
    container.ClipsDescendants = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 18)
    corner.Parent = container

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

    local function registerAccordion(header: Frame, subFrame: Frame, layoutOrder: number)
        header.LayoutOrder = layoutOrder
        header.Parent = leftPanel
        header.Visible = true

        subFrame.AutomaticSize = Enum.AutomaticSize.None
        subFrame.Size = UDim2.fromScale(1, 1)
        subFrame.Position = UDim2.fromOffset(0, 0)
        subFrame.Parent = rightPanel
        subFrame.Visible = false

        local rawBtn = findArrowButtonInHeader(header)
        if not rawBtn then
            return
        end

        local btn = replaceButton(rawBtn)
        btn.Text = ">"
        btn.TextColor3 = COLOR_ARROW_CLOSED
        btn.Rotation = 0

        local stroke = btn:FindFirstChildWhichIsA("UIStroke")
        if stroke then
            stroke:Destroy()
        end

        local glowStroke = Instance.new("UIStroke")
        glowStroke.Color = COLOR_GLOW
        glowStroke.Thickness = 1
        glowStroke.Transparency = 1
        glowStroke.Parent = btn

        local item: AccordionItem = {
            header = header,
            subFrame = subFrame,
            button = btn,
            stroke = glowStroke,
            tweenColor = nil,
            tweenRot = nil,
            tweenStroke = nil,
        }

        table.insert(items, item)

        maid:GiveTask(btn.MouseButton1Click:Connect(function()
            if openItem == item then
                openItem = nil
                applyState(item, false, true)
                return
            end

            if openItem then
                applyState(openItem, false, true)
            end

            openItem = item
            applyState(item, true, true)
        end))

        applyState(item, false, false)
    end

    local aimlock = AimlockModule.new()
    maid:GiveTask(aimlock)

    local aimHeader = aimlock.Instance:FindFirstChild("Header")
    local aimSub = aimlock.Instance:FindFirstChild("SubFrame")
    if aimHeader and aimSub and aimHeader:IsA("Frame") and aimSub:IsA("Frame") then
        registerAccordion(aimHeader, aimSub, 1)
    end

    local silentAim = SilentAimModule.new()
    maid:GiveTask(silentAim)

    local silentHeader = silentAim.Instance:FindFirstChild("Header")
    local silentSub = silentAim.Instance:FindFirstChild("SubFrame")
    if silentHeader and silentSub and silentHeader:IsA("Frame") and silentSub:IsA("Frame") then
        registerAccordion(silentHeader, silentSub, 2)
    end

    local triggerBot = TriggerBotModule.new()
    maid:GiveTask(triggerBot)

    local triggerHeader = triggerBot.Instance:FindFirstChild("Header")
    local triggerSub = triggerBot.Instance:FindFirstChild("SubFrame")
    if triggerHeader and triggerSub and triggerHeader:IsA("Frame") and triggerSub:IsA("Frame") then
        registerAccordion(triggerHeader, triggerSub, 3)
    end

    maid:GiveTask(container)

    local self = {} :: any
    self.Instance = container

    function self:Destroy()
        maid:Destroy()
    end

    return (self :: any) :: CombatModule
end

return CombatModuleFactory
