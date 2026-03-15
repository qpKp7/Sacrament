--!strict
local Import = (_G :: any).SacramentImport
local Signal = Import("utils/signal")
local Constants = Import("config/constants")
local HttpService = game:GetService("HttpService")

local FILE_NAME = "Sacrament_Settings.json"

local UIState = {
    IsVisible = true,
    ActiveTab = Constants.MODULE_NAMES and Constants.MODULE_NAMES[1] or "Combat",
    Settings = {} :: { [string]: any },
    
    VisibilityChanged = Signal.new() :: Signal.Signal<boolean>,
    TabChanged = Signal.new() :: Signal.Signal<string>,
    SettingChanged = Signal.new() :: Signal.Signal<string, any>
}

-- Função interna para salvar no disco
local function SaveToDisk()
    if writefile then
        local success, content = pcall(function()
            return HttpService:JSONEncode(UIState.Settings)
        end)
        if success then
            writefile(FILE_NAME, content)
        end
    end
end

-- Função interna para carregar do disco
local function LoadFromDisk()
    if isfile and isfile(FILE_NAME) then
        local success, content = pcall(function()
            return readfile(FILE_NAME)
        end)
        if success then
            local decodeSuccess, decoded = pcall(function()
                return HttpService:JSONDecode(content)
            end)
            if decodeSuccess then
                UIState.Settings = decoded
            end
        end
    end
end

-- Inicia carregando o que já existe
LoadFromDisk()

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
        SaveToDisk() -- Salva automaticamente a cada mudança
    end
end

function UIState.Get(key: string, defaultValue: any?): any
    -- Se não existe no arquivo carregado, usa o default e salva
    if UIState.Settings[key] == nil then
        if defaultValue ~= nil then
            UIState.Settings[key] = defaultValue
            SaveToDisk()
        end
    end
    return UIState.Settings[key]
end

return UIState
