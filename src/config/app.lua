--!strict

local UIState = require(script.Parent.Parent.state.ui_state)
local StoreModule = require(script.Parent.Parent.state.store)
local Maid = require(script.Parent.Parent.utils.maid)

local BuildGui = require(script.Parent.Parent.gui.build_gui) :: any
local TabRouter = require(script.Parent.Parent.navigation.tab_router) :: any
local ToggleController = require(script.Parent.Parent.input.toggle_controller) :: any
local DragController = require(script.Parent.Parent.input.drag_controller) :: any
local ClickController = require(script.Parent.Parent.input.click_controller) :: any

export type TabId = UIState.TabId
export type State = UIState.State

export type Adapter = {
	mountGui: (screenGui: ScreenGui) -> (),
	connectInputBegan: (fn: (input: InputObject, gameProcessed: boolean) -> ()) -> RBXScriptConnection,
	getViewportSize: (() -> Vector2)?,
}

export type Config = {
	GroupId: number,
	ToggleKey: Enum.KeyCode,
	DefaultTab: TabId,
	GuiName: string,
}

local App = {}

App.Config = {
	GroupId = 869981416,
	ToggleKey = Enum.KeyCode.RightAlt,
	DefaultTab = "COMBAT" :: TabId,
	GuiName = "SacramentUI",
} :: Config

local started = false
local appMaid: any = nil

function App.start(adapter: Adapter)
	if started then
		return
	end
	started = true

	local maid = Maid.new()
	appMaid = maid

	local initialState = UIState.create({
		isOpen = true,
		activeTabId = App.Config.DefaultTab,
	})

	local store = (StoreModule :: any).new(initialState)

	local ui = BuildGui.build(App.Config)

	adapter.mountGui(ui.screenGui)

	ui.screenGui.Enabled = store:getState().isOpen
	maid:Give(store:subscribe(function(state: State)
		ui.screenGui.Enabled = state.isOpen
	end))

	TabRouter.start(store, ui.tabsById)

	ToggleController.start(adapter, store, App.Config)
	DragController.start(adapter, store, ui.dragHandle, ui.mainFrame)
	ClickController.start(store, ui.buttonsByTab)

	maid:Give(function()
		store:destroy()
	end)
end

return App
