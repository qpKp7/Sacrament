--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local BentoCard = SafeImport("gui/modules/components/bentocard")
local FriendCheck = SafeImport("gui/modules/misc/sections/bloodpact/friendcheck")
local GroupIdCheck = SafeImport("gui/modules/misc/sections/bloodpact/groupid")
local NameCheck = SafeImport("gui/modules/misc/sections/bloodpact/namecheck")

export type BloodPactData = {
    MasterEnabled: boolean,
    FriendCheckEnabled: boolean,
    GroupCheckEnabled: boolean,
    GroupIdList: {string},
    NameCheckEnabled: boolean,
    NameList: {string}
}

export type BloodPactMasterUI = {
    Instance: Frame,
    GetData: (self: BloodPactMasterUI) -> BloodPactData,
    Destroy: (self: BloodPactMasterUI) -> ()
}

local BloodPactFactory = {}
local ICON_ID = "rbxassetid://98352735989850"

function BloodPactFactory.new(layoutOrder: number?): BloodPactMasterUI
    local maid = Maid.new()
    local masterState = false

    -- 1. Criação do Cartão Bento
    local card = BentoCard.new(
        "Blood Pact",
        "Global Team Check",
        "Forces all features to check for team.",
        ICON_ID,
        layoutOrder or 1
    )
    maid:GiveTask(card)

    maid:GiveTask(card.Toggled:Connect(function(state: boolean)
        masterState = state
    end))

    -- 2. Sub-Grid para as seções internas
    local subGrid = Instance.new("Frame")
    subGrid.Name = "BloodPactSubGrid"
    subGrid.Size = UDim2.new(1, 0, 0, 0)
    subGrid.AutomaticSize = Enum.AutomaticSize.Y
    subGrid.BackgroundTransparency = 1
    subGrid.LayoutOrder = 1
    -- Injeta no contêiner expansível do BentoCard
    subGrid.Parent = card.Container

    local gridLayout = Instance.new("UIListLayout")
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.FillDirection = Enum.FillDirection.Horizontal
    gridLayout.Wraps = true
    gridLayout.Padding = UDim.new(0, 15)
    gridLayout.Parent = subGrid

    -- 3. Instanciação das Seções de Controle
    local friendCheckInst = nil
    if FriendCheck and type(FriendCheck.new) == "function" then
        friendCheckInst = FriendCheck.new(1)
        friendCheckInst.Instance.Parent = subGrid
        maid:GiveTask(friendCheckInst)
    end

    local groupIdInst = nil
    if GroupIdCheck and type(GroupIdCheck.new) == "function" then
        groupIdInst = GroupIdCheck.new(2)
        groupIdInst.Instance.Parent = subGrid
        maid:GiveTask(groupIdInst)
    end

    local nameCheckInst = nil
    if NameCheck and type(NameCheck.new) == "function" then
        nameCheckInst = NameCheck.new(3)
        nameCheckInst.Instance.Parent = subGrid
        maid:GiveTask(nameCheckInst)
    end

    local self = {}
    self.Instance = card.Instance

    -- Interface de consumo para o Aimbot/ESP
    function self:GetData(): BloodPactData
        return {
            MasterEnabled = masterState,
            FriendCheckEnabled = friendCheckInst and friendCheckInst:GetState() or false,
            GroupCheckEnabled = groupIdInst and groupIdInst:GetState() or false,
            GroupIdList = groupIdInst and groupIdInst:GetList() or {},
            NameCheckEnabled = nameCheckInst and nameCheckInst:GetState() or false,
            NameList = nameCheckInst and nameCheckInst:GetList() or {}
        }
    end

    function self:Destroy()
        maid:Destroy()
    end

    return self :: BloodPactMasterUI
end

return BloodPactFactory
