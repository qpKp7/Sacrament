--!strict

local UIState = {}

export type TabId = "COMBAT" | "PLAYER" | "VISUAL" | "MISC" | "INFO"

export type State = {
	isOpen: boolean,
	activeTabId: TabId,
}

export type Init = {
	isOpen: boolean?,
	activeTabId: TabId?,
}

function UIState.create(init: Init?): State
	local cfg = init or {}
	return {
		isOpen = if cfg.isOpen ~= nil then cfg.isOpen else true,
		activeTabId = if cfg.activeTabId ~= nil then cfg.activeTabId else "COMBAT",
	}
end

return UIState
