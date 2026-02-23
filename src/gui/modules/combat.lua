--!strict
local TweenService = game:GetService("TweenService")

local root = script.Parent.Parent.Parent
local Maid = require(root.utils.Maid)

local AimlockModule = require(script.Parent.combat.aimlock)
local SilentAimModule = require(script.Parent.combat.silentaim)
local TriggerBotModule = require(script.Parent.combat.triggerbot)

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
    if not controls then return nil end

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

local function applyState(item: AccordionItem, isOpen: boolean, animate: boolean)
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

    TweenService:Create(item.button, TWEEN_INFO, { TextColor3 = targetColor }):Play()
    TweenService:Create(item.button, TWEEN_INFO, { Rotation = targetRotation }):Play()
    TweenService:Create(item.stroke, TWEEN_INFO, { Transparency = targetStrokeTransparency }):Play()
end

function CombatModuleFactory.new(): CombatModule
    local maid = Maid.new()
    print("[Sacrament] Initializing Combat Module...")

    local container = Instance.new("Frame")
    container.Name = "CombatContainer"
    container.Size = UDim2.fromScale(1, 1)
    container.BackgroundTransparency = 1
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

    local function registerAccordion(header: Frame, subFrame: Frame, layoutOrder: number)
        header.LayoutOrder = layoutOrder
        header.Parent = leftPanel
        header.Visible = true

        subFrame.Size = UDim2.fromScale(1, 1)
        subFrame.Parent = rightPanel
        subFrame.Visible = false

        local rawBtn = findArrowButtonInHeader(header)
        if not rawBtn then return end

        local btn = replaceButton(rawBtn)
        local glowStroke = Instance.new("UIStroke")
        glowStroke.Color = COLOR_GLOW
        glowStroke.Transparency = 1
        glowStroke.Parent = btn

        local item: AccordionItem = {
            header = header, subFrame = subFrame, button = btn, stroke = glowStroke
        }
        table.insert(items, item)

        maid:GiveTask(btn.MouseButton1Click:Connect(function()
            if openItem == item then
                openItem = nil
                applyState(item, false, true)
            else
                if openItem then applyState(openItem, false, true) end
                openItem = item
                applyState(item, true, true)
            end
        end))
        
        applyState(item, false, false)
    end

    -- Aimlock
    local aimlock = AimlockModule.new()
    maid:GiveTask(aimlock)
    local aHeader = aimlock.Instance:FindFirstChild("Header")
    local aSub = aimlock.Instance:FindFirstChild("SubFrame")
    if aHeader and aSub then
        registerAccordion(aHeader :: Frame, aSub :: Frame, 1)
    end

    -- Silent Aim
    local silentAim = SilentAimModule.new()
    maid:GiveTask(silentAim)
    local sHeader = silentAim.Instance:FindFirstChild("Header")
    local sSub = silentAim.Instance:FindFirstChild("SubFrame")
    if sHeader and sSub then
        registerAccordion(sHeader :: Frame, sSub :: Frame, 2)
    end

    -- TriggerBot
    local triggerBot = TriggerBotModule.new()
    maid:GiveTask(triggerBot)
    local tHeader = triggerBot.Instance:FindFirstChild("Header")
    local tSub = triggerBot.Instance:FindFirstChild("SubFrame")
    if tHeader and tSub then
        registerAccordion(tHeader :: Frame, tSub :: Frame, 3)
    else
        warn("[Sacrament] TriggerBot components missing! Check Header/SubFrame naming.")
    end

    maid:GiveTask(container)
    
    local self = {}
    self.Instance = container

    function self:Destroy()
        maid:Destroy()
    end

    return self :: CombatModule
end

return CombatModuleFactory
