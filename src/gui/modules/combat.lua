--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")
local AimlockModule = Import("gui/modules/combat/aimlock")
local SilentAimModule = Import("gui/modules/combat/silentaim")

export type CombatModule = {
    Instance: Frame,
    Destroy: (self: CombatModule) -> ()
}

local CombatModuleFactory = {}

function CombatModuleFactory.new(): CombatModule
    local maid = Maid.new()

    -- Container principal estático (não-arrastável)
    local container = Instance.new("Frame")
    container.Name = "CombatContainer"
    container.Size = UDim2.fromScale(1, 1)
    container.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    container.BorderSizePixel = 0
    container.ClipsDescendants = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 18)
    corner.Parent = container

    -- Painel Esquerdo: Área fixa para os headers (toggles) empilhados
    local leftPanel = Instance.new("Frame")
    leftPanel.Name = "LeftPanel"
    leftPanel.Size = UDim2.new(0, 280, 1, 0)
    leftPanel.BackgroundTransparency = 1
    leftPanel.BorderSizePixel = 0
    leftPanel.Parent = container

    local leftLayout = Instance.new("UIListLayout")
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Padding = UDim.new(0, 0)
    leftLayout.Parent = leftPanel

    -- Painel Direito: Área fixa para os subframes (renderizam a partir do topo)
    local rightPanel = Instance.new("Frame")
    rightPanel.Name = "RightPanel"
    rightPanel.Size = UDim2.new(1, -280, 1, 0)
    rightPanel.Position = UDim2.fromOffset(280, 0)
    rightPanel.BackgroundTransparency = 1
    rightPanel.BorderSizePixel = 0
    rightPanel.Parent = container

    -- Extração e Montagem do Aimlock
    local aimlock = AimlockModule.new()
    maid:GiveTask(aimlock)
    
    local aimHeader = aimlock.Instance:FindFirstChild("Header")
    if aimHeader then
        aimHeader.LayoutOrder = 1
        aimHeader.Parent = leftPanel
    end
    
    local aimSub = aimlock.Instance:FindFirstChild("SubFrame")
    if aimSub then
        aimSub.AutomaticSize = Enum.AutomaticSize.None
        aimSub.Size = UDim2.fromScale(1, 1)
        aimSub.Position = UDim2.fromOffset(0, 0)
        aimSub.Parent = rightPanel
    end

    -- Extração e Montagem do Silent Aim
    local silentAim = SilentAimModule.new()
    maid:GiveTask(silentAim)

    local silentHeader = silentAim.Instance:FindFirstChild("Header")
    if silentHeader then
        silentHeader.LayoutOrder = 2
        silentHeader.Parent = leftPanel
    end
    
    local silentSub = silentAim.Instance:FindFirstChild("SubFrame")
    if silentSub then
        silentSub.AutomaticSize = Enum.AutomaticSize.None
        silentSub.Size = UDim2.fromScale(1, 1)
        silentSub.Position = UDim2.fromOffset(0, 0)
        silentSub.Parent = rightPanel
    end

    maid:GiveTask(container)

    local self = {}
    self.Instance = container

    function self:Destroy()
        maid:Destroy()
    end

    return self
end

return CombatModuleFactory
