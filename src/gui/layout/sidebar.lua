--!strict

local UIState = require(script.Parent.Parent.Parent.state.ui_state)

type TabId = UIState.TabId

export type Tokens = {
	Colors: {
		SidebarBg: Color3,
		SidebarButtonBg: Color3,
		Divider: Color3,
		ButtonText: Color3,
	},
	Layout: {
		SidebarWidthScale: number,
		LogoHeightScale: number,
		HorizontalDividerHeightPx: number,

		ModulesPaddingTopPx: number,
		ModulesGapPx: number,

		ButtonWidthScale: number,
		ButtonHeightPx: number,

		ButtonCornerRadiusPx: number,
	},
	Typography: {
		ButtonFont: Enum.Font,
		ButtonTextSize: number,
	},
}

local Sidebar = {}

export type SidebarRefs = {
	frame: Frame,
	buttonsByTab: { [TabId]: TextButton },
}

function Sidebar.create(tokens: Tokens, groupId: number, tabOrder: { TabId }): SidebarRefs
	local frame = Instance.new("Frame")
	frame.Name = "Sidebar"
	frame.Size = UDim2.new(tokens.Layout.SidebarWidthScale, 0, 1, 0)
	frame.BackgroundColor3 = tokens.Colors.SidebarBg
	frame.BorderSizePixel = 0
	frame.Active = false

	local logoContainer = Instance.new("Frame")
	logoContainer.Name = "LogoContainer"
	logoContainer.Size = UDim2.new(1, 0, tokens.Layout.LogoHeightScale, 0)
	logoContainer.BackgroundTransparency = 1
	logoContainer.BorderSizePixel = 0
	logoContainer.Active = false
	logoContainer.Parent = frame

	local logo = Instance.new("ImageLabel")
	logo.Name = "Logo"
	logo.Size = UDim2.new(1, 0, 1, 0)
	logo.BackgroundTransparency = 1
	logo.Image = ("rbxthumb://type=GroupIcon&id=%d&w=420&h=420"):format(groupId)
	logo.ScaleType = Enum.ScaleType.Fit
	logo.Active = false
	logo.Parent = logoContainer

	local horizontalDivider = Instance.new("Frame")
	horizontalDivider.Name = "HorizontalDivider"
	horizontalDivider.Size = UDim2.new(1, 0, 0, tokens.Layout.HorizontalDividerHeightPx)
	horizontalDivider.Position = UDim2.new(0, 0, tokens.Layout.LogoHeightScale, 0)
	horizontalDivider.BackgroundColor3 = tokens.Colors.Divider
	horizontalDivider.BorderSizePixel = 0
	horizontalDivider.Active = false
	horizontalDivider.Parent = frame

	local modulesContainer = Instance.new("Frame")
	modulesContainer.Name = "ModulesContainer"
	modulesContainer.Size = UDim2.new(1, 0, 1 - tokens.Layout.LogoHeightScale, -tokens.Layout.HorizontalDividerHeightPx)
	modulesContainer.Position = UDim2.new(0, 0, tokens.Layout.LogoHeightScale, tokens.Layout.HorizontalDividerHeightPx)
	modulesContainer.BackgroundColor3 = tokens.Colors.SidebarBg
	modulesContainer.BorderSizePixel = 0
	modulesContainer.ClipsDescendants = true
	modulesContainer.Active = false
	modulesContainer.Parent = frame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, tokens.Layout.ModulesGapPx)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = modulesContainer

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, tokens.Layout.ModulesPaddingTopPx)
	padding.Parent = modulesContainer

	local buttonsByTab: { [TabId]: TextButton } = {}

	for i, tabId in ipairs(tabOrder) do
		local btn = Instance.new("TextButton")
		btn.Name = "Button_" .. tabId
		btn.Size = UDim2.new(tokens.Layout.ButtonWidthScale, 0, 0, tokens.Layout.ButtonHeightPx)
		btn.BackgroundColor3 = tokens.Colors.SidebarButtonBg
		btn.BorderSizePixel = 0
		btn.Text = tabId
		btn.TextColor3 = tokens.Colors.ButtonText
		btn.Font = tokens.Typography.ButtonFont
		btn.TextSize = tokens.Typography.ButtonTextSize
		btn.AutoButtonColor = false
		btn.LayoutOrder = i
		btn.Active = true
		btn.Parent = modulesContainer

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, tokens.Layout.ButtonCornerRadiusPx)
		corner.Parent = btn

		local stroke = Instance.new("UIStroke")
		stroke.Name = "BtnStroke"
		stroke.Thickness = 1
		stroke.Color = tokens.Colors.Divider
		stroke.Transparency = 1
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = btn

		buttonsByTab[tabId] = btn
	end

	return {
		frame = frame,
		buttonsByTab = buttonsByTab,
	}
end

return Sidebar
