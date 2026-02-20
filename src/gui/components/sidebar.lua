--!strict
local Constants = require(script.Parent.Parent.Parent.config.constants)
local Colors = require(script.Parent.Parent.Parent.themes.colors)
local UIState = require(script.Parent.Parent.Parent.state.uistate)
local Maid = require(script.Parent.Parent.Parent.utils.maid)
local TabButtonModule = require(script.Parent.tabbutton)

export type Sidebar = {
    Instance: Frame,
    Destroy: (self: Sidebar) -> ()
}

local SidebarModule = {}

function SidebarModule.new(): Sidebar
    local maid = Maid.new()
    local buttons: {[string]: any} = {}

    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(Constants.SIDEBAR_WIDTH, 0, 1, 0)
    sidebar.BackgroundColor3 = Colors.SidebarBackground
    sidebar.BorderSizePixel = 0
    sidebar.Active = false

    local logoContainer = Instance.new("Frame")
    logoContainer.Name = "LogoContainer"
    logoContainer.Size = UDim2.new(1, 0, 0.38, 0)
    logoContainer.BackgroundTransparency = 1
    logoContainer.BorderSizePixel = 0
    logoContainer.Active = false
    logoContainer.Parent = sidebar

    local logo = Instance.new("ImageLabel")
    logo.Name = "Logo"
    logo.Size = UDim2.new(1, 0, 1, 0)
    logo.BackgroundTransparency = 1
    logo.Image = "rbxthumb://type=GroupIcon&id=" .. Constants.GROUP_ID .. "&w=420&h=420"
    logo.ScaleType = Enum.ScaleType.Fit
    logo.Active = false
    logo.Parent = logoContainer

    local horizontalDivider = Instance.new("Frame")
    horizontalDivider.Name = "HorizontalDivider"
    horizontalDivider.Size = UDim2.new(1, 0, 0, 2)
    horizontalDivider.Position = UDim2.new(0, 0, 0.38, 0)
    horizontalDivider.BackgroundColor3 = Colors.Divider
    horizontalDivider.BorderSizePixel = 0
    horizontalDivider.Active = false
    horizontalDivider.Parent = sidebar

    local modulesContainer = Instance.new("Frame")
    modulesContainer.Name = "ModulesContainer"
    modulesContainer.Size = UDim2.new(1, 0, 0.62, -2)
    modulesContainer.Position = UDim2.new(0, 0, 0.38, 2)
    modulesContainer.BackgroundColor3 = Colors.SidebarBackground
    modulesContainer.BorderSizePixel = 0
    modulesContainer.ClipsDescendants = true
    modulesContainer.Active = false
    modulesContainer.Parent = sidebar

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = modulesContainer

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.Parent = modulesContainer

    local function handleTabClick(tabName: string)
        UIState.SetActiveTab(tabName)
    end

    for i, name in ipairs(Constants.MODULE_NAMES) do
        local tabBtn = TabButtonModule.new(name, i, handleTabClick)
        tabBtn.Instance.Parent = modulesContainer
        maid:GiveTask(tabBtn)
        buttons[name] = tabBtn
    end

    maid:GiveTask(UIState.TabChanged:Connect(function(activeTab: string)
        for name, btn in pairs(buttons) do
            btn:SetActive(name == activeTab)
        end
    end))

    if buttons[UIState.ActiveTab] then
        buttons[UIState.ActiveTab]:SetActive(true)
    end

    local self = {}
    self.Instance = sidebar

    function self:Destroy()
        maid:Destroy()
        sidebar:Destroy()
    end

    return self
end

return SidebarModule
