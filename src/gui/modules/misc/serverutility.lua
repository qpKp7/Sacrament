--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local UIState = SafeImport("state/uistate") -- [NOVO] O Cofre de Memória

local BentoCard = SafeImport("gui/modules/components/bentocard")
local Rejoin = SafeImport("gui/modules/misc/sections/serverutility/rejoin")
local ServerHop = SafeImport("gui/modules/misc/sections/serverutility/serverhop")
local InstantRejoin = SafeImport("gui/modules/misc/sections/serverutility/instantrejoin")

export type ServerUtilityUI = {
    Instance: Frame,
    Rejoin: any,        -- [NOVO] Exportado para conectar a lógica de Teleport
    ServerHop: any,     -- [NOVO] Exportado para conectar a lógica de Teleport
    InstantRejoin: any, -- [NOVO] Exportado para o Orquestrador
    Destroy: (self: ServerUtilityUI) -> ()
}

local ServerUtilityFactory = {}

-- [CORREÇÃO DO ÍCONE] Usando rbxthumb para forçar o carregamento mesmo se for um Decal ID
local ICON_ID = "rbxthumb://type=Asset&id=111933292722916&w=150&h=150"

function ServerUtilityFactory.new(layoutOrder: any): ServerUtilityUI
    local maid = Maid.new()
    
    -- Barreira de proteção contra injeção de tabelas pelo loader dinâmico
    local actualOrder = type(layoutOrder) == "number" and layoutOrder or 2

    local card = BentoCard.new(
        "Server Utility",
        "Session Control",
        "Manage your current server connection.",
        ICON_ID,
        actualOrder
    )
    maid:GiveTask(card)

    local container = Instance.new("Frame")
    container.Name = "RowsContainer"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundTransparency = 1
    container.Parent = card.Container

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 10)
    pad.Parent = container

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = container

    local self = {} :: any
    self.Instance = card.Instance

    local rejoinInst = nil
    if Rejoin and type(Rejoin.new) == "function" then
        rejoinInst = Rejoin.new(1)
        rejoinInst.Instance.Parent = container
        maid:GiveTask(rejoinInst)
        
        self.Rejoin = rejoinInst
    end

    local serverHopInst = nil
    if ServerHop and type(ServerHop.new) == "function" then
        serverHopInst = ServerHop.new(2)
        serverHopInst.Instance.Parent = container
        maid:GiveTask(serverHopInst)
        
        self.ServerHop = serverHopInst
    end

    local instantRejoinInst = nil
    if InstantRejoin and type(InstantRejoin.new) == "function" then
        instantRejoinInst = InstantRejoin.new(3)
        instantRejoinInst.Instance.Parent = container
        maid:GiveTask(instantRejoinInst)
        
        self.InstantRejoin = instantRejoinInst
    end

    -- =========================================================================
    -- 👑 ORQUESTRADOR DE ESTADOS
    -- =========================================================================
    local Orchestrator = {}
    
    function Orchestrator.Bind(section: any, stateKey: string, componentType: string)
        if not section or not UIState then return end
        local savedValue = UIState.Get(stateKey)
        
        if componentType == "Toggle" then
            local component = section.Toggle or section.ToggleButton or section
            if component then
                if savedValue ~= nil and component.SetState then pcall(function() component:SetState(savedValue, true) end) end
                if component.Toggled then maid:GiveTask(component.Toggled:Connect(function(val: boolean) UIState.Set(stateKey, val) end)) end
            end
        end
    end

    -- EVENTO DO BENTOCARD PRINCIPAL (SERVER UTILITY)
    if card and UIState then
        local savedMaster = UIState.Get("Misc_ServerUtility_Master", false)
        if savedMaster and card.SetState then pcall(function() card:SetState(savedMaster, true) end) end
        maid:GiveTask(card.Toggled:Connect(function(state: boolean)
            UIState.Set("Misc_ServerUtility_Master", state)
        end))
    end

    -- 🎯 PAINEL DE CONTROLE DE MEMÓRIA (Rejoin e Hop são ações, então não salvam estado)
    Orchestrator.Bind(instantRejoinInst, "Misc_ServerUtility_InstantRejoin", "Toggle")
    -- =========================================================================

    function self:Destroy() 
        maid:Destroy() 
    end

    return self :: ServerUtilityUI
end

return ServerUtilityFactory
