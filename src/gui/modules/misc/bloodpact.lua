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
local FriendCheck = SafeImport("gui/modules/misc/sections/bloodpact/friendcheck")
local GroupIdCheck = SafeImport("gui/modules/misc/sections/bloodpact/groupid")
local NameCheck = SafeImport("gui/modules/misc/sections/bloodpact/namecheck")

export type BloodPactMasterUI = {
    Instance: Frame,
    Destroy: (self: BloodPactMasterUI) -> ()
}

local BloodPactFactory = {}
local ICON_ID = "rbxassetid://119374823365207"

function BloodPactFactory.new(layoutOrder: number?): BloodPactMasterUI
    local maid = Maid.new()

    local card = BentoCard.new(
        "Blood Pact",
        "Global Team Check",
        "Forces all features to check for team.",
        ICON_ID,
        layoutOrder or 1
    )
    maid:GiveTask(card)

    -- Contêiner vertical simplificado (substituindo o antigo split Left/Right)
    local columnsContainer = Instance.new("Frame")
    columnsContainer.Name = "ColumnsContainer"
    columnsContainer.Size = UDim2.new(1, 0, 0, 0)
    columnsContainer.AutomaticSize = Enum.AutomaticSize.Y
    columnsContainer.BackgroundTransparency = 1
    columnsContainer.LayoutOrder = 1
    columnsContainer.Parent = card.Container

    local colsLayout = Instance.new("UIListLayout")
    colsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    colsLayout.FillDirection = Enum.FillDirection.Vertical
    colsLayout.Padding = UDim.new(0, 10)
    colsLayout.Parent = columnsContainer

    local friendCheckInst = nil
    if FriendCheck and type(FriendCheck.new) == "function" then
        friendCheckInst = FriendCheck.new(1)
        friendCheckInst.Instance.Size = UDim2.new(1, 0, 0, 55)
        friendCheckInst.Instance.Parent = columnsContainer
        maid:GiveTask(friendCheckInst)
    end

    local groupIdInst = nil
    if GroupIdCheck and type(GroupIdCheck.new) == "function" then
        groupIdInst = GroupIdCheck.new(2)
        groupIdInst.Instance.Parent = columnsContainer
        maid:GiveTask(groupIdInst)
    end

    local nameCheckInst = nil
    if NameCheck and type(NameCheck.new) == "function" then
        nameCheckInst = NameCheck.new(3)
        nameCheckInst.Instance.Parent = columnsContainer
        maid:GiveTask(nameCheckInst)
    end

    -- =========================================================================
    -- 👑 ORQUESTRADOR DE ESTADOS (AGORA COMPATÍVEL COM DYNAMIC LIST)
    -- =========================================================================
    local Orchestrator = {}
    
    function Orchestrator.Bind(section: any, stateKey: string, componentType: string)
        if not section or not UIState then return end
        local savedValue = UIState.Get(stateKey)
        
        if componentType == "Toggle" then
            -- Suporta tanto o ToggleButton comum quanto o BentoCard
            local component = section.Toggle or section.ToggleButton or section
            if component then
                if savedValue ~= nil and component.SetState then pcall(function() component:SetState(savedValue, true) end) end
                if component.Toggled then maid:GiveTask(component.Toggled:Connect(function(val: boolean) UIState.Set(stateKey, val) end)) end
            end

        -- 👉 NOVA MAGIA: Listas Dinâmicas (Arrays)
        elseif componentType == "DynamicList" then
            local component = section.DynamicList
            if component then
                if savedValue and type(savedValue) == "table" and component.SetValues then 
                    pcall(function() component:SetValues(savedValue, true) end) 
                end
                if component.ListChanged then 
                    maid:GiveTask(component.ListChanged:Connect(function(newList: {string}) 
                        UIState.Set(stateKey, newList) 
                    end)) 
                end
            end
        end
    end

    -- EVENTO DO BENTOCARD PRINCIPAL (BLOOD PACT)
    if card and UIState then
        local savedMaster = UIState.Get("Misc_BloodPact_Master", false)
        if savedMaster and card.SetState then pcall(function() card:SetState(savedMaster, true) end) end
        maid:GiveTask(card.Toggled:Connect(function(state: boolean)
            UIState.Set("Misc_BloodPact_Master", state)
        end))
    end

    -- 🎯 PAINEL DE CONTROLE DE MEMÓRIA DO BLOOD PACT
    Orchestrator.Bind(friendCheckInst, "Misc_BP_FriendCheck",  "Toggle")
    
    Orchestrator.Bind(groupIdInst,     "Misc_BP_GroupCheck",   "Toggle")
    Orchestrator.Bind(groupIdInst,     "Misc_BP_GroupList",    "DynamicList")
    
    Orchestrator.Bind(nameCheckInst,   "Misc_BP_NameCheck",    "Toggle")
    Orchestrator.Bind(nameCheckInst,   "Misc_BP_NameList",     "DynamicList")
    -- =========================================================================

    local self = {}
    self.Instance = card.Instance

    function self:Destroy()
        maid:Destroy()
    end

    return self :: BloodPactMasterUI
end

return BloodPactFactory
