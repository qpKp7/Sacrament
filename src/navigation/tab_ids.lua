--!strict

local UIState = require(script.Parent.Parent.state.ui_state)

export type TabId = UIState.TabId

local TabIds = {}

TabIds.Order = { "COMBAT", "PLAYER", "VISUAL", "MISC", "INFO" } :: { TabId }

return TabIds
