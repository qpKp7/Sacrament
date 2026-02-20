--!strict

export type Tokens = {
	Colors: {
		ContentBg: Color3,
		Divider: Color3,
	},
	Layout: {
		SidebarWidthScale: number,
		VerticalDividerWidthPx: number,

		ContentCornerRadiusPx: number,
		LeftStraightEdgeWidthPx: number,
	},
}

local ContentRoot = {}

export type ContentRefs = {
	root: Frame,
	verticalDivider: Frame,
	content: Frame,
}

function ContentRoot.create(tokens: Tokens): ContentRefs
	local verticalDivider = Instance.new("Frame")
	verticalDivider.Name = "VerticalDivider"
	verticalDivider.Size = UDim2.new(0, tokens.Layout.VerticalDividerWidthPx, 1, 0)
	verticalDivider.Position = UDim2.new(tokens.Layout.SidebarWidthScale, 0, 0, 0)
	verticalDivider.BackgroundColor3 = tokens.Colors.Divider
	verticalDivider.BorderSizePixel = 0
	verticalDivider.Active = false

	local root = Instance.new("Frame")
	root.Name = "ContentRoot"
	root.Size = UDim2.new(1 - tokens.Layout.SidebarWidthScale, -tokens.Layout.VerticalDividerWidthPx, 1, 0)
	root.Position = UDim2.new(tokens.Layout.SidebarWidthScale, tokens.Layout.VerticalDividerWidthPx, 0, 0)
	root.BackgroundTransparency = 1
	root.BorderSizePixel = 0
	root.Active = false

	local content = Instance.new("Frame")
	content.Name = "ContentRounded"
	content.Size = UDim2.new(1, 0, 1, 0)
	content.Position = UDim2.new(0, 0, 0, 0)
	content.BackgroundColor3 = tokens.Colors.ContentBg
	content.BorderSizePixel = 0
	content.Active = false
	content.Parent = root

	local contentCorner = Instance.new("UICorner")
	contentCorner.CornerRadius = UDim.new(0, tokens.Layout.ContentCornerRadiusPx)
	contentCorner.Parent = content

	local leftStraightEdge = Instance.new("Frame")
	leftStraightEdge.Name = "LeftStraightEdge"
	leftStraightEdge.Size = UDim2.new(0, tokens.Layout.LeftStraightEdgeWidthPx, 1, 0)
	leftStraightEdge.Position = UDim2.new(0, 0, 0, 0)
	leftStraightEdge.BackgroundColor3 = tokens.Colors.ContentBg
	leftStraightEdge.BorderSizePixel = 0
	leftStraightEdge.Active = false
	leftStraightEdge.Parent = content

	return {
		root = root,
		verticalDivider = verticalDivider,
		content = content,
	}
end

return ContentRoot
