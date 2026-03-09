--!strict
local Import = (_G :: any).SacramentImport
local Signal = Import("utils/signal")
local Constants = Import("config/constants")

local UIState = {
    IsVisible = true,
    ActiveTab = Constants.MODULE_NAMES and Constants.MODULE_NAMES[1] or "Combat",
    
    Settings = {} :: { [string]: any },
    
    VisibilityChanged = Signal.new() :: Signal.Signal<boolean>,
    TabChanged = Signal.new() :: Signal.Signal<string>,
    SettingChanged = Signal.new() :: Signal.Signal<string, any>
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

function UIState.Set(key: string, value: any)
    if UIState.Settings[key] ~= value then
        UIState.Settings[key] = value
        UIState.SettingChanged:Fire(key, value)
    end
end

function UIState.Get(key: string, defaultValue: any?): any
    if UIState.Settings[key] == nil and defaultValue ~= nil then
        UIState.Settings[key] = defaultValue
    end
    return UIState.Settings[key]
end

return UIState
