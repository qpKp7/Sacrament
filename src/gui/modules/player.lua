--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

-- Preparação para os submódulos da aba Player
local FlyModule = Import("gui/modules/player/fly")
local WalkSpeedModule = Import("gui/modules/player/walkspeed")
local AntiStunModule = Import("gui/modules/player/antistun")
local NoClipModule = Import("gui/modules/player/noclip")

export type PlayerModule = {
    Instance: ScrollingFrame,
    Destroy: (self: PlayerModule) -> (),
}

local PlayerModuleFactory = {}

function PlayerModuleFactory.new(): PlayerModule
    local maid = Maid.new()

    -- O container agora rola a tela automaticamente caso os módulos expandidos passem do limite da tela
    local container = Instance.new("ScrollingFrame")
    container.Name = "PlayerContainer"
    container.Size = UDim2.fromScale(1, 1)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ScrollBarThickness = 0
    container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.ClipsDescendants = true

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10) -- Espaçamento vertical entre os módulos
    layout.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = container

    local function safeLoadSection(moduleType: any, order: number)
        if typeof(moduleType) == "table" and moduleType.new then
            local success, instance = pcall(function() return moduleType.new(order) end)
            if success and instance and instance.Instance then
                maid:GiveTask(instance)
                instance.Instance.LayoutOrder = order
                instance.Instance.Parent = container
            else
                warn(string.format("[Sacrament] Falha ao carregar o submódulo na ordem %d", order))
            end
        end
    end

    -- Carrega os submódulos da aba Player na ordem solicitada
    safeLoadSection(FlyModule, 1)
    safeLoadSection(WalkSpeedModule, 2)
    safeLoadSection(AntiStunModule, 3)
    safeLoadSection(NoClipModule, 4)

    maid:GiveTask(container)
    
    local self = {}
    self.Instance = container
    
    function self:Destroy() 
        maid:Destroy() 
    end
    
    return self :: PlayerModule
end

-- Função obrigatória solicitada para injetar o frame direto no parent
function PlayerModuleFactory.createPlayerFrame(parent: Frame): Frame
    local playerMod = PlayerModuleFactory.new()
    playerMod.Instance.Parent = parent
    return (playerMod.Instance :: any) :: Frame
end

return PlayerModuleFactory
