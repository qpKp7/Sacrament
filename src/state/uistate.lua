--!strict
local Signal = require(script.Parent.Parent.utils.Signal)
local Constants = require(script.Parent.Parent.config.Constants)

local UIState = {
    IsVisible = false,
    ActiveTab = Constants.MODULE_NAMES[1],
    
    VisibilityChanged = Signal.new() :: Signal.Signal<boolean>,
    TabChanged = Signal.new() :: Signal.Signal<string>
}

function UIState.ToggleVisibility()
    UIState.IsVisible = not UIState.IsVisible
    UIState.VisibilityChanged:Fire(UIState.IsVisible)
end

function UIState.SetActiveTab(tabName: string)
    if UIState.ActiveTab ~= tabName then
        UIState.ActiveTab = tabName
        UIState.TabChanged:Fire(tabName)
    end
end

return UIState
