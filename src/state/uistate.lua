--!strict
local Import = (_G :: any).SacramentImport
local Signal = Import("utils/signal")
local Constants = Import("config/constants")

-- =========================================================================
-- O COFRE DA SESSÃO (Memória Imortal)
-- =========================================================================
if type(shared._SacramentVault) ~= "table" then
    shared._SacramentVault = {
        IsVisible = true,
        ActiveTab = Constants.MODULE_NAMES and Constants.MODULE_NAMES[1] or "Combat",
        Settings = {} :: { [string]: any }
    }
end

local Vault = shared._SacramentVault

-- =========================================================================
-- UI STATE (O Gerenciador)
-- =========================================================================
local UIState = {
    -- Puxamos os valores salvos no cofre ao recarregar a UI
    IsVisible = Vault.IsVisible,
    ActiveTab = Vault.ActiveTab,
    
    -- Como Settings é uma tabela, apontamos diretamente para o cofre. 
    -- Qualquer mudança feita aqui salva na memória do executor automaticamente!
    Settings = Vault.Settings, 
    
    -- Os Sinais precisam ser recriados a cada Injeção para plugar nos botões novos
    VisibilityChanged = Signal.new() :: Signal.Signal<boolean>,
    TabChanged = Signal.new() :: Signal.Signal<string>,
    SettingChanged = Signal.new() :: Signal.Signal<string, any>
}

function UIState.ToggleVisibility()
    UIState.IsVisible = not UIState.IsVisible
    Vault.IsVisible = UIState.IsVisible -- Atualiza o Cofre Global
    UIState.VisibilityChanged:Fire(UIState.IsVisible)
end

function UIState.SetActiveTab(tabName: string)
    if UIState.ActiveTab ~= tabName then
        UIState.ActiveTab = tabName
        Vault.ActiveTab = tabName -- Atualiza o Cofre Global
        UIState.TabChanged:Fire(tabName)
    end
end

function UIState.Set(key: string, value: any)
    if UIState.Settings[key] ~= value then
        UIState.Settings[key] = value -- Salva direto no Cofre (por referência)
        UIState.SettingChanged:Fire(key, value)
    end
end

function UIState.Get(key: string, defaultValue: any?): any
    if UIState.Settings[key] == nil then
        if defaultValue ~= nil then
            UIState.Settings[key] = defaultValue
        end
    end
    return UIState.Settings[key]
end

-- Função extra de utilidade: caso você queira criar um botão de "Resetar Configurações" na UI
function UIState.FactoryReset()
    shared._SacramentVault = nil
    -- Na próxima vez que o UIState carregar, tudo volta do zero.
end

return UIState
