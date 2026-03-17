--!strict
--[[
    SACRAMENT | UI Manager
    Responsável por instanciar a ScreenGui e montar a MainFrame no ambiente correto.
--]]

local Import = (_G :: any).SacramentImport
local UIState = Import("state/uistate")
local Maid = Import("utils/maid")

-- O SmartImport cuidará se o mainframe estiver em gui/ ou gui/components/
local MainFrameModule = Import("gui/mainframe") 

local UIManager = {}
local uiMaid = Maid.new()

--[[
    UIManager.Init
    Monta a interface completa. 
    @param adapter: Opcional - Permite injetar a GUI no CoreGui (Executores)
    @param settings: Tabela de configurações iniciais
--]]
function UIManager.Init(adapter: any?, settings: any)
    -- Segurança: Limpa qualquer resíduo antes de iniciar
    UIManager.Destroy()

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SacramentUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    
    -- Inicializa com o estado salvo na persistência (Matando bug de visibilidade)
    screenGui.Enabled = if UIState.IsVisible ~= nil then UIState.IsVisible else true
    
    -- Tag de identificação para o Script de Limpeza (Essential para Hot-Reload)
    local tag = Instance.new("BoolValue")
    tag.Name = "Sacrament_Tag"
    tag.Parent = screenGui
    
    uiMaid:GiveTask(screenGui)

    -- Instancia a moldura principal (MainFrame)
    local mainFrame = MainFrameModule.new(settings)
    mainFrame.Instance.Parent = screenGui
    uiMaid:GiveTask(mainFrame)

    -- Lógica de Injeção (Adapter ou PlayerGui)
    if adapter and adapter.mountGui then
        adapter.mountGui(screenGui)
    else
        local player = game:GetService("Players").LocalPlayer
        if player then
            -- Deferimos para garantir que o ambiente do player está pronto
            task.defer(function()
                screenGui.Parent = player:WaitForChild("PlayerGui")
            end)
        end
    end

    -- Sincronização de Visibilidade (Event-Driven)
    if UIState.VisibilityChanged then
        uiMaid:GiveTask(UIState.VisibilityChanged:Connect(function(isVisible: boolean)
            screenGui.Enabled = isVisible
        end))
    end
    
    warn("[SACRAMENT] UI Manager inicializado com sucesso.")
end

--[[
    UIManager.Destroy
    Limpa todas as instâncias e desconecta eventos da UI.
--]]
function UIManager.Destroy()
    uiMaid:DoCleaning()
end

return UIManager
