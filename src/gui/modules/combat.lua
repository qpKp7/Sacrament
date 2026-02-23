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
	button: GuiButton?,
	glyph: TextLabel?,
}

local CombatModuleFactory = {}

local COLOR_ARROW_CLOSED = Color3.fromHex("CCCCCC")
local COLOR_ARROW_OPEN = Color3.fromHex("C80000")
local TWEEN_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function getControls(header: Frame): Instance?
	return header:FindFirstChild("Controls")
end

local function findRightmostButton(controls: Instance): GuiButton?
	local best: GuiButton? = nil
	local bestX = -math.huge

	for _, desc in ipairs(controls:GetDescendants()) do
		if desc:IsA("GuiButton") then
			local x = desc.AbsolutePosition.X
			if x > bestX then
				bestX = x
				best = desc
			end
		end
	end

	return best
end

local function findArrowGlyph(controls: Instance): TextLabel?
	local best: TextLabel? = nil
	local bestX = -math.huge

	for _, desc in ipairs(controls:GetDescendants()) do
		if desc:IsA("TextLabel") then
			local t = desc.Text
			if t == ">" or t == "v" or t == "<" or t == "V" or t == "^" then
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

local function applyState(item: AccordionItem, isOpen: boolean, animate: boolean)
	item.subFrame.Visible = isOpen

	local targetColor = if isOpen then COLOR_ARROW_OPEN else COLOR_ARROW_CLOSED
	local targetText = if isOpen then "v" else ">"

	if item.glyph then
		item.glyph.Text = targetText
		if animate then
			TweenService:Create(item.glyph, TWEEN_INFO, { TextColor3 = targetColor }):Play()
		else
			item.glyph.TextColor3 = targetColor
		end
	elseif item.button and item.button:IsA("TextButton") then
		(item.button :: TextButton).Text = targetText
		if animate then
			TweenService:Create(item.button, TWEEN_INFO, { TextColor3 = targetColor }):Play()
		else
			(item.button :: TextButton).TextColor3 = targetColor
		end
	end
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

	local function bindArrow(item: AccordionItem)
		local controls = getControls(item.header)
		if not controls then
			return
		end

		local btn = findRightmostButton(controls)
		local glyph = findArrowGlyph(controls)

		item.button = btn
		item.glyph = glyph

		applyState(item, false, false)

		if btn then
			maid:GiveTask(btn.Activated:Connect(function()
				toggleItem(item)
			end))
		end
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
			button = nil,
			glyph = nil,
		}
		table.insert(items, item)

		task.defer(function()
			bindArrow(item)
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
