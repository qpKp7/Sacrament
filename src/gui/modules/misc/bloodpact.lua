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

    -- Contêiner Divisor de Colunas (Esquerda: Toggles / Direita: Listas)
    local columnsContainer = Instance.new("Frame")
    columnsContainer.Name = "ColumnsContainer"
    columnsContainer.Size = UDim2.new(1, 0, 0, 0)
    columnsContainer.AutomaticSize = Enum.AutomaticSize.Y
    columnsContainer.BackgroundTransparency = 1
    columnsContainer.LayoutOrder = 1
    columnsContainer.Parent = card.Container

    local colsLayout = Instance.new("UIListLayout")
    colsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    colsLayout.FillDirection = Enum.FillDirection.Horizontal
    colsLayout.Padding = UDim.new(0, 15)
    colsLayout.Parent = columnsContainer

    -- Coluna Esquerda
    local leftCol = Instance.new("Frame")
    leftCol.Name = "LeftColumn"
    leftCol.Size = UDim2.new(0.5, -7.5, 0, 0)
    leftCol.AutomaticSize = Enum.AutomaticSize.Y
    leftCol.BackgroundTransparency = 1
    leftCol.LayoutOrder = 1
    leftCol.Parent = columnsContainer

    local leftLayout = Instance.new("UIListLayout")
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Padding = UDim.new(0, 10)
    leftLayout.Parent = leftCol

    -- Coluna Direita
    local rightCol = Instance.new("Frame")
    rightCol.Name = "RightColumn"
    rightCol.Size = UDim2.new(0.5, -7.5, 0, 0)
    rightCol.AutomaticSize = Enum.AutomaticSize.Y
    rightCol.BackgroundTransparency = 1
    rightCol.LayoutOrder = 2
    rightCol.Parent = columnsContainer

    local rightLayout = Instance.new("UIListLayout")
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Padding = UDim.new(0, 10)
    rightLayout.Parent = rightCol

    -- Instanciação e Distribuição
    local friendCheckInst = nil
    if FriendCheck and type(FriendCheck.new) == "function" then
        friendCheckInst = FriendCheck.new(1)
        friendCheckInst.Instance.Size = UDim2.new(1, 0, 0, 55)
        friendCheckInst.Instance.Parent = leftCol
        maid:GiveTask(friendCheckInst)
    end

    local groupIdInst = nil
    if GroupIdCheck and type(GroupIdCheck.new) == "function" then
        groupIdInst = GroupIdCheck.new(2)
        groupIdInst.ToggleInstance.Parent = leftCol
        if groupIdInst.ListInstance then
            groupIdInst.ListInstance.Parent = rightCol
        end
        maid:GiveTask(groupIdInst)
    end

    local nameCheckInst = nil
    if NameCheck and type(NameCheck.new) == "function" then
        nameCheckInst = NameCheck.new(3)
        nameCheckInst.ToggleInstance.Parent = leftCol
        if nameCheckInst.ListInstance then
            nameCheckInst.ListInstance.Parent = rightCol
        end
        maid:GiveTask(nameCheckInst)
    end

    local self = {}
    self.Instance = card.Instance

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
