--!strict

local Tokens = {}

Tokens.Colors = {
	SidebarBg = Color3.fromRGB(6, 6, 6),
	SidebarButtonBg = Color3.fromRGB(12, 12, 12),
	SidebarButtonBgHover = Color3.fromRGB(20, 20, 20),
	SidebarButtonBgActive = Color3.fromRGB(18, 18, 18),

	ContentBg = Color3.fromRGB(14, 14, 14),

	Divider = Color3.fromRGB(150, 0, 0),

	ButtonText = Color3.fromRGB(180, 180, 180),
}

Tokens.Layout = {
	MainSize = UDim2.fromScale(0.38, 0.42),
	MainPosition = UDim2.fromScale(0.31, 0.29),

	SidebarWidthScale = 0.24,

	LogoHeightScale = 0.38,
	HorizontalDividerHeightPx = 2,

	ModulesPaddingTopPx = 10,
	ModulesGapPx = 8,

	ButtonWidthScale = 0.85,
	ButtonHeightPx = 38,

	VerticalDividerWidthPx = 2,

	ContentCornerRadiusPx = 18,
	ButtonCornerRadiusPx = 8,

	LeftStraightEdgeWidthPx = 18,
}

Tokens.Typography = {
	ButtonFont = Enum.Font.GothamBold,
	ButtonTextSize = 11,
}

Tokens.Motion = {
	ButtonTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
}

return Tokens
