--!strict

local UIState = require(script.Parent.Parent.state.ui_state)

export type TabId = UIState.TabId
export type TabsById = { [TabId]: Frame }

export type Store = {
	getState: (self: Store) -> UIState.State,
	subscribe: (self: Store, listener: (state: UIState.State) -> ()) -> RBXScriptConnection,
}

local TabRouter = {}

local function apply(tabsById: TabsById, activeTabId: TabId)
	for tabId, frame in pairs(tabsById) do
		frame.Visible = (tabId == activeTabId)
	end
end

function TabRouter.start(store: Store, tabsById: TabsById): RBXScriptConnection
	apply(tabsById, store:getState().activeTabId)

	return store:subscribe(function(state: UIState.State)
		apply(tabsById, state.activeTabId)
	end)
end

return TabRouter
