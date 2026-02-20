--!strict

export type Tokens = {
	Layout: {
		MainSize: UDim2,
		MainPosition: UDim2,
	},
}

local MainWindow = {}

export type MainWindowRefs = {
	mainFrame: Frame,
	dragHandle: Frame,
}

function MainWindow.create(tokens: Tokens): MainWindowRefs
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = tokens.Layout.MainSize
	mainFrame.Position = tokens.Layout.MainPosition
	mainFrame.BackgroundTransparency = 1
	mainFrame.BorderSizePixel = 0
	mainFrame.Active = false

	local dragHandle = Instance.new("Frame")
	dragHandle.Name = "DragHandle"
	dragHandle.Size = UDim2.new(1, 0, 0, 34)
	dragHandle.Position = UDim2.new(0, 0, 0, 0)
	dragHandle.BackgroundTransparency = 1
	dragHandle.BorderSizePixel = 0
	dragHandle.Active = false
	dragHandle.ZIndex = 10
	dragHandle.Parent = mainFrame

	return {
		mainFrame = mainFrame,
		dragHandle = dragHandle,
	}
end

return MainWindow
