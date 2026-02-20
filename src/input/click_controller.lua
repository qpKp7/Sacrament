--!strict

local TweenService = game:GetService("TweenService")

local UIState = require(script.Parent.Parent.state.ui_state)
local Tokens = require(script.Parent.Parent.themes.tokens)

export type TabId = UIState.TabId
export type State = UIState.State

export type Store = {
	getState: (self: Store) -> State,
	subscribe: (self: Store, listener: (state: State) -> ()) -> RBXScriptConnection,
	setActiveTab: (self: Store, tabId: TabId) -> (),
}

export type ButtonsByTab = { [TabId]: TextButton }

local ClickController = {}

local function tween(obj: Instance, goal: { [string]: any })
	return TweenService:Create(obj, Tokens.Motion.ButtonTweenInfo, goal)
end

local function getStroke(btn: TextButton): UIStroke?
	local stroke = btn:FindFirstChild("BtnStroke")
	if stroke and stroke:IsA("UIStroke") then
		return stroke
	end
	return nil
end

local function applyDefault(btn: TextButton)
	local stroke = getStroke(btn)
	tween(btn, { BackgroundColor3 = Tokens.Colors.SidebarButtonBg }):Play()
	if stroke then
		tween(stroke, { Transparency = 1, Thickness = 1 }):Play()
	end
end

local function applyHover(btn: TextButton)
	local stroke = getStroke(btn)
	tween(btn, { BackgroundColor3 = Tokens.Colors.SidebarButtonBgHover }):Play()
	if stroke then
		tween(stroke, { Transparency = 0.5, Thickness = 1 }):Play()
	end
end

local function applyActive(btn: TextButton)
	local stroke = getStroke(btn)
	tween(btn, { BackgroundColor3 = Tokens.Colors.SidebarButtonBgActive }):Play()
	if stroke then
		tween(stroke, { Transparency = 0.15, Thickness = 2 }):Play()
	end
end

local function repaint(buttonsByTab: ButtonsByTab, activeTabId: TabId)
	for tabId, btn in pairs(buttonsByTab) do
		if tabId == activeTabId then
			applyActive(btn)
		else
			applyDefault(btn)
		end
	end
end

function ClickController.start(store: Store, buttonsByTab: ButtonsByTab)
	local activeTabId: TabId = store:getState().activeTabId
	repaint(buttonsByTab, activeTabId)

	for tabId, btn in pairs(buttonsByTab) do
		btn.MouseEnter:Connect(function()
			applyHover(btn)
			if activeTabId == tabId then
				applyHover(btn)
				applyActive(btn)
			end
			if activeTabId ~= tabId then
				applyHover(btn)
			end
		end)

		btn.MouseLeave:Connect(function()
			if activeTabId == tabId then
				applyActive(btn)
			else
				applyDefault(btn)
			end
		end)

		btn.MouseButton1Click:Connect(function()
			store:setActiveTab(tabId)
		end)
	end

	return store:subscribe(function(state: State)
		if state.activeTabId == activeTabId then
			return
		end
		activeTabId = state.activeTabId
		repaint(buttonsByTab, activeTabId)
	end)
end

return ClickController
