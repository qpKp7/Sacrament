--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local BentoCard = SafeImport("gui/modules/components/bentocard")
local Rejoin = SafeImport("gui/modules/misc/sections/serverutility/rejoin")
local ServerHop = SafeImport("gui/modules/misc/sections/serverutility/serverhop")
local InstantRejoin = SafeImport("gui/modules/misc/sections/serverutility/instantrejoin")

export type ServerUtilityData = {
    MasterEnabled: boolean,
    InstantRejoinEnabled: boolean
}

export type ServerUtilityUI = {
    Instance: Frame,
    GetData: (self: ServerUtilityUI) -> ServerUtilityData,
    Destroy: (self: ServerUtilityUI) -> ()
}

local ServerUtilityFactory = {}
local ICON_ID = "rbxassetid://111933292722916"

function ServerUtilityFactory.new(layoutOrder: number?): ServerUtilityUI
    local maid = Maid.new()
    local masterState = false

    local card = BentoCard.new(
        "Server Utility",
        "Session Control",
        "Manage your current server connection.",
        ICON_ID,
        layoutOrder or 2
    )
    maid:GiveTask(card)

    maid:GiveTask(card.Toggled:Connect(function(state: boolean)
        masterState = state
    end))

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

    local rejoinInst = nil
    if Rejoin and type(Rejoin.new) == "function" then
        rejoinInst = Rejoin.new(1)
        rejoinInst.Instance.Parent = container
        maid:GiveTask(rejoinInst)
        
        maid:GiveTask(rejoinInst.Clicked:Connect(function()
            if not masterState then return end
            -- Lógica de TeleportService (Rejoin) será acoplada pelo controlador principal
        end))
    end

    local serverHopInst = nil
    if ServerHop and type(ServerHop.new) == "function" then
        serverHopInst = ServerHop.new(2)
        serverHopInst.Instance.Parent = container
        maid:GiveTask(serverHopInst)
        
        maid:GiveTask(serverHopInst.Clicked:Connect(function()
            if not masterState then return end
            -- Lógica de TeleportService + HttpService (Hop) será acoplada pelo controlador principal
        end))
    end

    local instantRejoinInst = nil
    if InstantRejoin and type(InstantRejoin.new) == "function" then
        instantRejoinInst = InstantRejoin.new(3)
        instantRejoinInst.Instance.Parent = container
        maid:GiveTask(instantRejoinInst)
    end

    local self = {}
    self.Instance = card.Instance

    function self:GetData(): ServerUtilityData
        return {
            MasterEnabled = masterState,
            InstantRejoinEnabled = instantRejoinInst and instantRejoinInst:GetState() or false
        }
    end

    function self:Destroy() 
        maid:Destroy() 
    end

    return self :: ServerUtilityUI
end

return ServerUtilityFactory
