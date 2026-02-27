--!strict
local TweenService = game:GetService("TweenService")

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

local KeybindSection = SafeImport("gui/modules/player/sections/shared/keybind")
local KeyHoldSection = SafeImport("gui/modules/player/sections/shared/keyhold")
local SpeedSection = SafeImport("gui/modules/player/sections/shared/speed")
local AnimationsSection = SafeImport("gui/modules/player/sections/fly/animations")

export type FlyUI = {
	Instance: Frame,
	Destroy: (self: FlyUI) -> (),
}

local FlyFactory = {}

local COLOR_WHITE = Color3.fromHex("B4B4B4")
local FONT_MAIN = Enum.Font.GothamBold

local function findGuiButton(root: Instance): GuiButton?
	if root:IsA("GuiButton") then
		return root :: GuiButton
	end
	local found = root:FindFirstChildWhichIsA("GuiButton", true)
	if found and found:IsA("GuiButton") then
		return found :: GuiButton
	end
	return nil
end

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
	glowWrapper.Active = false
	glowWrapper.Selectable = false
	glowWrapper.Parent = header

	local glowBar = nil
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
			gObj.Selectable = false
		end

		local c1 = glowBar.Instance:FindFirstChildWhichIsA("UISizeConstraint", true)
		if c1 then
			c1:Destroy()
		end
		local c2 = glowBar.Instance:FindFirstChildWhichIsA("UIAspectRatioConstraint", true)
		if c2 then
			c2:Destroy()
		end
		maid:GiveTask(glowBar)
	end

	local function updateGlowBar()
		if header.AbsoluteSize.X == 0 then
			return
		end
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
	subFrame.Size = UDim2.new(1, 0, 0, 0)
	subFrame.AutomaticSize = Enum.AutomaticSize.Y
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
	rightContent.Size = UDim2.new(1, -2, 0, 0)
	rightContent.AutomaticSize = Enum.AutomaticSize.Y
	rightContent.Position = UDim2.fromOffset(2, 0)
	rightContent.BackgroundTransparency = 1
	rightContent.BorderSizePixel = 0
	rightContent.Parent = subFrame

	local rightLayout = Instance.new("UIListLayout")
	rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
	rightLayout.Parent = rightContent

	local function safeLoadSection(moduleType: any, order: number, parentInstance: Instance)
		if type(moduleType) == "table" and type(moduleType.new) == "function" then
			local success, instance = pcall(function()
				return moduleType.new(order)
			end)
			if success and instance and instance.Instance then
				instance.Instance.Parent = parentInstance
				maid:GiveTask(instance)
			end
		end
	end

	safeLoadSection(KeybindSection, 1, rightContent)

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

	safeLoadSection(KeyHoldSection, 1, inputsScroll)
	safeLoadSection(SpeedSection, 2, inputsScroll)
	safeLoadSection(AnimationsSection, 3, inputsScroll)

	if toggleBtn and glowBar then
		local toggledSignal = (toggleBtn :: any).Toggled
		if toggledSignal and typeof(toggledSignal) == "RBXScriptSignal" then
			maid:GiveTask(toggledSignal:Connect(function(state: boolean)
				(glowBar :: any):SetState(state)
			end))
		end
	end

	local isExpanded = false

	if arrow then
		local arrowButton = findGuiButton((arrow :: any).Instance)
		if arrowButton then
			maid:GiveTask(arrowButton.MouseButton1Click:Connect(function()
				isExpanded = not isExpanded
				subFrame.Visible = isExpanded
				if type((arrow :: any).SetState) == "function" then
					(arrow :: any):SetState(isExpanded)
				end
			end))
		else
			local root = (arrow :: any).Instance
			if typeof(root) == "Instance" and root:IsA("GuiObject") then
				local arrowFallback = Instance.new("TextButton")
				arrowFallback.Name = "ArrowHitbox"
				arrowFallback.Size = UDim2.fromScale(1, 1)
				arrowFallback.Position = UDim2.fromScale(0, 0)
				arrowFallback.BackgroundTransparency = 1
				arrowFallback.Text = ""
				arrowFallback.AutoButtonColor = false
				arrowFallback.Parent = root

				maid:GiveTask(arrowFallback.MouseButton1Click:Connect(function()
					isExpanded = not isExpanded
					subFrame.Visible = isExpanded
					if type((arrow :: any).SetState) == "function" then
						(arrow :: any):SetState(isExpanded)
					end
				end))
			end
		end
	end

	maid:GiveTask(container)
	local self = {}
	self.Instance = container
	function self:Destroy()
		maid:Destroy()
	end
	return self :: FlyUI
end

return FlyFactory
