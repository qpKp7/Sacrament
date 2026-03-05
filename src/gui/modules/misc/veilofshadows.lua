--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local BentoCard = SafeImport("gui/modules/components/bentocard")
local PrintScreen = SafeImport("gui/modules/misc/sections/veilofshadows/printscreen")
local RecorderScreen = SafeImport("gui/modules/misc/sections/veilofshadows/recorderscreen")

export type VeilData = {
    MasterEnabled: boolean,
    CleanPrintScreen: boolean,
    OBSBypass: boolean
}

export type VeilUI = {
    Instance: Frame,
    GetData: (self: VeilUI) -> VeilData,
    Destroy: (self: VeilUI) -> ()
}

local VeilFactory = {}
local ICON_ID = "rbxassetid://108584963373035"

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

    local container = Instance.new("Frame")
    container.Name = "RowsContainer"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundTransparency = 1
    container.Parent = card.Container

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = container

    local printScreenInst = nil
    if PrintScreen and type(PrintScreen.new) == "function" then
        printScreenInst = PrintScreen.new(1)
        printScreenInst.Instance.Parent = container
        maid:GiveTask(printScreenInst)
    end

    local recorderScreenInst = nil
    if RecorderScreen and type(RecorderScreen.new) == "function" then
        recorderScreenInst = RecorderScreen.new(2)
        recorderScreenInst.Instance.Parent = container
        maid:GiveTask(recorderScreenInst)
    end

    local self = {}
    self.Instance = card.Instance

    function self:GetData(): VeilData
        return {
            MasterEnabled = masterState,
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
