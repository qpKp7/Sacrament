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
local PrintScreen = SafeImport("gui/modules/misc/sections/veilofshadows/printscreen")
local RecorderScreen = SafeImport("gui/modules/misc/sections/veilofshadows/recorderscreen")

export type VeilUI = {
    Instance: Frame,
    PrintScreen: any,    -- [NOVO] Exportado
    RecorderScreen: any, -- [NOVO] Exportado
    Destroy: (self: VeilUI) -> ()
}

local VeilFactory = {}
-- [CORREÇÃO DO ÍCONE] Usando rbxthumb para carregar o Decal perfeitamente
local ICON_ID = "rbxthumb://type=Asset&id=75507316618777&w=150&h=150"

function VeilFactory.new(layoutOrder: number?): VeilUI
    local maid = Maid.new()

    local card = BentoCard.new(
        "Veil of Shadows",
        "Streamer Mode",
        "Hides GUI and visuals for screen sharing.",
        ICON_ID,
        layoutOrder or 1
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

    local printScreenInst = nil
    if PrintScreen and type(PrintScreen.new) == "function" then
        printScreenInst = PrintScreen.new(1)
        printScreenInst.Instance.Parent = container
        maid:GiveTask(printScreenInst)
        
        self.PrintScreen = printScreenInst
    end

    local recorderScreenInst = nil
    if RecorderScreen and type(RecorderScreen.new) == "function" then
        recorderScreenInst = RecorderScreen.new(2)
        recorderScreenInst.Instance.Parent = container
        maid:GiveTask(recorderScreenInst)
        
        self.RecorderScreen = recorderScreenInst
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

    -- EVENTO DO BENTOCARD PRINCIPAL (VEIL OF SHADOWS)
    if card and UIState then
        local savedMaster = UIState.Get("Misc_Veil_Master", false)
        if savedMaster and card.SetState then pcall(function() card:SetState(savedMaster, true) end) end
        maid:GiveTask(card.Toggled:Connect(function(state: boolean)
            UIState.Set("Misc_Veil_Master", state)
        end))
    end

    -- 🎯 PAINEL DE CONTROLE DE MEMÓRIA
    Orchestrator.Bind(printScreenInst,    "Misc_Veil_PrintScreen",  "Toggle")
    Orchestrator.Bind(recorderScreenInst, "Misc_Veil_OBSBypass",    "Toggle")
    -- =========================================================================

    function self:Destroy() 
        maid:Destroy() 
    end

    return self :: VeilUI
end

return VeilFactory
