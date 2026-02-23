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
local TWEEN_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

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

local function setArrowVisual(glyph: Instance?, open: boolean, animate: boolean)
	if not glyph then
		return
	end

	local targetText = if open then "v" else ">"
	local targetColor = if open then COLOR_ARROW_OPEN else COLOR_ARROW_CLOSED

	if glyph:IsA("TextLabel") then
		glyph.Text = targetText
		if animate then
			TweenService:Create(glyph, TWEEN_INFO, { TextColor3 = targetColor }):Play()
		else
			glyph.TextColor3 = targetColor
		end
	elseif glyph:IsA("TextButton") then
		glyph.Text = targetText
		if animate then
			TweenService:Create(glyph, TWEEN_INFO, { TextColor3 = targetColor }):Play()
		else
			glyph.TextColor3 = targetColor
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
	if arrowGlyph then
		if arrowGlyph.Parent then
			arrowRoot = arrowGlyph.Parent
		end
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
	if not glyph:IsA("GuiObject") then
		return nil
	end
	if not glyph.Parent then
		return nil
	end

	local hit = Instance.new("TextButton")
	hit.Name = "ArrowHitbox"
	hit.BackgroundTransparency = 1
	hit.BorderSizePixel = 0
	hit.AutoButtonColor = false
	hit.Text = ""
	hit.ZIndex = glyph.ZIndex + 1
	hit.AnchorPoint = glyph.AnchorPoint
	hit.Size = glyph.Size
	hit.Position = glyph.Position
	hit.Parent = glyph.Parent

	local function sync()
		hit.ZIndex = glyph.ZIndex + 1
		hit.AnchorPoint = glyph.AnchorPoint
		hit.Size = glyph.Size
		hit.Position = glyph.Position
	end

	maid:GiveTask(glyph:GetPropertyChangedSignal("ZIndex"):Connect(sync))
	maid:GiveTask(glyph:GetPropertyChangedSignal("AnchorPoint"):Connect(sync))
	maid:GiveTask(glyph:GetPropertyChangedSignal("Size"):Connect(sync))
	maid:GiveTask(glyph:GetPropertyChangedSignal("Position"):Connect(sync))

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

	local function applyState(item: AccordionItem, open: boolean, animate: boolean)
		item.subFrame.Visible = open
		setArrowVisual(item.arrowGlyph, open, animate)
	end

	local function toggleItem(item: AccordionItem)
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
		end

		if item.arrowHit then
			maid:GiveTask(item.arrowHit.Activated:Connect(function()
				toggleItem(item)
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

	local aimlock = AimlockModule.new()
	maid:GiveTask(aimlock)
	local aHeader = aimlock.Instance:FindFirstChild("Header")
	local aSub = aimlock.Instance:FindFirstChild("SubFrame")
	if aHeader and aSub then
		registerAccordion(aHeader :: Frame, aSub :: Frame, 1)
	end

	local silentAim = SilentAimModule.new()
	maid:GiveTask(silentAim)
	local sHeader = silentAim.Instance:FindFirstChild("Header")
	local sSub = silentAim.Instance:FindFirstChild("SubFrame")
	if sHeader and sSub then
		registerAccordion(sHeader :: Frame, sSub :: Frame, 2)
	end

	local triggerBot = TriggerBotModule.new()
	maid:GiveTask(triggerBot)
	local tHeader = triggerBot.Instance:FindFirstChild("Header")
	local tSub = triggerBot.Instance:FindFirstChild("SubFrame")
	if tHeader and tSub then
		registerAccordion(tHeader :: Frame, tSub :: Frame, 3)
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
