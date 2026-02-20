--!strict

local Tokens = require(script.Parent.Parent.themes.tokens)

export type Props = {
	name: string,
	layoutOrder: number,
}

local TabButton = {}

function TabButton.create(props: Props): TextButton
	local btn = Instance.new("TextButton")
	btn.Name = "Button_" .. props.name
	btn.Size = UDim2.new(Tokens.Layout.ButtonWidthScale, 0, 0, Tokens.Layout.ButtonHeightPx)
	btn.BackgroundColor3 = Tokens.Colors.SidebarButtonBg
	btn.BorderSizePixel = 0
	btn.Text = props.name
	btn.TextColor3 = Tokens.Colors.ButtonText
	btn.Font = Tokens.Typography.ButtonFont
	btn.TextSize = Tokens.Typography.ButtonTextSize
	btn.AutoButtonColor = false
	btn.LayoutOrder = props.layoutOrder
	btn.Active = true

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, Tokens.Layout.ButtonCornerRadiusPx)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Name = "BtnStroke"
	stroke.Thickness = 1
	stroke.Color = Tokens.Colors.Divider
	stroke.Transparency = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = btn

	return btn
end

return TabButton
