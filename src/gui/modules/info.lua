--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local PlayerCard = SafeImport("gui/modules/components/playercard")
local ScriptCard = SafeImport("gui/modules/components/scriptcard")

export type InfoUI = {
    Instance: Frame,
    Destroy: (self: InfoUI) -> ()
}

local InfoFactory = {}

function InfoFactory.new(layoutOrder: any): InfoUI
    local maid = Maid.new()
    local actualOrder = type(layoutOrder) == "number" and layoutOrder or 1

    local container = Instance.new("Frame")
    container.Name = "InfoContainer"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.LayoutOrder = actualOrder

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 20)
    pad.PaddingBottom = UDim.new(0, 20)
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 20)
    pad.Parent = container

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 15)
    layout.Parent = container

    if PlayerCard and type(PlayerCard.new) == "function" then
        local success, playerInst = pcall(function() return PlayerCard.new(1) end)
        if success and playerInst and playerInst.Instance then
            playerInst.Instance.Size = UDim2.new(0.55, -7, 1, 0)
            playerInst.Instance.Parent = container
            maid:GiveTask(playerInst)
        end
    end

    if ScriptCard and type(ScriptCard.new) == "function" then
        local success, scriptInst = pcall(function() return ScriptCard.new(2) end)
        if success and scriptInst and scriptInst.Instance then
            scriptInst.Instance.Size = UDim2.new(0.45, -8, 1, 0)
            scriptInst.Instance.Parent = container
            maid:GiveTask(scriptInst)
        end
    end

    maid:GiveTask(container)

    local self = {}
    self.Instance = container
    function self:Destroy() maid:Destroy() end
    return self :: InfoUI
end

return InfoFactory
