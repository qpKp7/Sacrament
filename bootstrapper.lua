--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ROOT_NAME = "SacramentGui"

local Bootstrapper = {}

function Bootstrapper.start()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local root = ReplicatedStorage:WaitForChild(ROOT_NAME)

	local Store = require(root.state.store)
	local UiState = require(root.state.ui_state)
	local TabIds = require(root.navigation.tab_ids)

	local BuildGui = require(root.gui.build_gui)
	local TabRouter = require(root.navigation.tab_router)

	local ToggleController = require(root.input.toggle_controller)
	local DragController = require(root.input.drag_controller)
	local ClickController = require(root.input.click_controller)

	local store = Store.new(UiState.initial(TabIds.Default))

	local refs = BuildGui.create()
	refs.ScreenGui.Parent = playerGui

	TabRouter.bind(store, refs.Tabs, refs.TabButtons)
	ToggleController.bind(store, refs.ScreenGui)
	DragController.bind(refs.DragHandle, refs.MainFrame)
	ClickController.bindTabs(refs.TabButtons, function(tabId: string)
		store:setState({ activeTab = tabId })
	end)

	return refs
end

return Bootstrapper
