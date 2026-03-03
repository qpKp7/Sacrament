--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local BentoCard = SafeImport("gui/modules/components/bentocard")
local HideVisuals = SafeImport("gui/modules/misc/sections/veilofshadows/hidevisuals")
local PanicKey = SafeImport("gui/modules/misc/sections/veilofshadows/panickey")
local PrintScreen = SafeImport("gui/modules/misc/sections/veilofshadows/printscreen")
local RecorderScreen = SafeImport("gui/modules/misc/sections/veilofshadows/recorderscreen")

export type VeilData = {
    MasterEnabled: boolean,
    HideVisualsEnabled: boolean,
    PanicKey: Enum.KeyCode?,
    CleanPrintScreen: boolean,
    OBSBypass: boolean
}

export type VeilUI = {
    Instance: Frame,
    GetData: (self: VeilUI) -> VeilData,
    Destroy: (self: VeilUI) -> ()
}

local VeilFactory = {}
local ICON_ID = "rbxassetid://139242921950134"

function VeilFactory.new(layoutOrder: number?): VeilUI
    local maid = Maid.new()
    local masterState = false

    local card = BentoCard.new(
        "Veil of Shadows",
        "Streamer Mode",
        "Hides GUI and visuals for screen sharing.",
        ICON_ID,
        layoutOrder or 1
    )
    maid:GiveTask(card)

    maid:GiveTask(card.Toggled:Connect(function(state: boolean)
        masterState = state
    end))

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

    local hideVisualsInst = nil
    if HideVisuals and type(HideVisuals.new) == "function" then
        hideVisualsInst = HideVisuals.new(1)
        hideVisualsInst.Instance.Parent = leftCol
        maid:GiveTask(hideVisualsInst)
    end

    local panicKeyInst = nil
    if PanicKey and type(PanicKey.new) == "function" then
        panicKeyInst = PanicKey.new(2)
        panicKeyInst.Instance.Parent = leftCol
        maid:GiveTask(panicKeyInst)
    end

    local printScreenInst = nil
    if PrintScreen and type(PrintScreen.new) == "function" then
        printScreenInst = PrintScreen.new(1)
        printScreenInst.Instance.Parent = rightCol
        maid:GiveTask(printScreenInst)
    end

    local recorderScreenInst = nil
    if RecorderScreen and type(RecorderScreen.new) == "function" then
        recorderScreenInst = RecorderScreen.new(2)
        recorderScreenInst.Instance.Parent = rightCol
        maid:GiveTask(recorderScreenInst)
    end

    local self = {}
    self.Instance = card.Instance

    function self:GetData(): VeilData
        return {
            MasterEnabled = masterState,
            HideVisualsEnabled = hideVisualsInst and hideVisualsInst:GetState() or false,
            PanicKey = panicKeyInst and panicKeyInst:GetKey() or nil,
            CleanPrintScreen = printScreenInst and printScreenInst:GetState() or false,
            OBSBypass = recorderScreenInst and recorderScreenInst:GetState() or false
        }
    end

    function self:Destroy() 
        maid:Destroy() 
    end

    return self :: VeilUI
end

return VeilFactory
