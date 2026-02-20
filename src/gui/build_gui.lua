--!strict

local UIState = require(script.Parent.Parent.state.ui_state)
local Tokens = require(script.Parent.Parent.themes.tokens)

local TabIds = require(script.Parent.Parent.navigation.tab_ids)

local MainWindow = require(script.Parent.layout.main_window)
local Sidebar = require(script.Parent.layout.sidebar)
local ContentRoot = require(script.Parent.layout.content_root)

local CombatTab = require(script.Parent.tabs.combat)
local PlayerTab = require(script.Parent.tabs.player)
local VisualTab = require(script.Parent.tabs.visual)
local MiscTab = require(script.Parent.tabs.misc)
local InfoTab = require(script.Parent.tabs.info)

type TabId = UIState.TabId

export type Config = {
	GroupId: number,
	GuiName: string,
}

export type UIRefs = {
	screenGui: ScreenGui,
	mainFrame: Frame,
	dragHandle: Frame,

	sidebar: Frame,
	contentRoot: Frame,

	buttonsByTab: { [TabId]: TextButton },
	tabsById: { [TabId]: Frame },
}

local BuildGui = {}

function BuildGui.build(config: Config): UIRefs
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = config.GuiName
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true

	local mainWindow = MainWindow.create(Tokens)
	mainWindow.mainFrame.Parent = screenGui

	local sidebar = Sidebar.create(Tokens, config.GroupId, TabIds.Order)
	sidebar.frame.Parent = mainWindow.mainFrame

	local content = ContentRoot.create(Tokens)
	content.verticalDivider.Parent = mainWindow.mainFrame
	content.root.Parent = mainWindow.mainFrame

	local tabsById: { [TabId]: Frame } = {}

	local combatFrame = CombatTab.create(Tokens)
	combatFrame.Parent = content.root
	combatFrame.Visible = false
	tabsById["COMBAT"] = combatFrame

	local playerFrame = PlayerTab.create(Tokens)
	playerFrame.Parent = content.root
	playerFrame.Visible = false
	tabsById["PLAYER"] = playerFrame

	local visualFrame = VisualTab.create(Tokens)
	visualFrame.Parent = content.root
	visualFrame.Visible = false
	tabsById["VISUAL"] = visualFrame

	local miscFrame = MiscTab.create(Tokens)
	miscFrame.Parent = content.root
	miscFrame.Visible = false
	tabsById["MISC"] = miscFrame

	local infoFrame = InfoTab.create(Tokens)
	infoFrame.Parent = content.root
	infoFrame.Visible = false
	tabsById["INFO"] = infoFrame

	return {
		screenGui = screenGui,
		mainFrame = mainWindow.mainFrame,
		dragHandle = mainWindow.dragHandle,

		sidebar = sidebar.frame,
		contentRoot = content.root,

		buttonsByTab = sidebar.buttonsByTab,
		tabsById = tabsById,
	}
end

return BuildGui
