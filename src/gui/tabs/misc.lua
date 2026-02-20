--!strict

export type Tokens = any

local MiscTab = {}

function MiscTab.create(_: Tokens): Frame
	local frame = Instance.new("Frame")
	frame.Name = "Tab_MISC"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.Position = UDim2.new(0, 0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Active = false
	return frame
end

return MiscTab
