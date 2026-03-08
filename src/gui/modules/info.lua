--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local AdeptSection = SafeImport("gui/modules/info/adept")
local ScriptInfoSection = SafeImport("gui/modules/info/scriptinfo")

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

    -- Wrapper central para segurar as duas boxes lado a lado com tamanho fixo e premium
    local wrapper = Instance.new("Frame")
    wrapper.Name = "HorizontalWrapper"
    wrapper.Size = UDim2.new(0, 680, 0, 160)
    wrapper.AnchorPoint = Vector2.new(0.5, 0.5)
    wrapper.Position = UDim2.new(0.5, 0, 0.5, 0)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = container

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 20)
    layout.Parent = wrapper

    if AdeptSection and type(AdeptSection.new) == "function" then
        local success, adeptInst = pcall(function() return AdeptSection.new(1) end)
        if success and adeptInst and adeptInst.Instance then
            adeptInst.Instance.Size = UDim2.new(0.55, -10, 1, 0)
            adeptInst.Instance.Parent = wrapper
            maid:GiveTask(adeptInst)
        end
    end

    if ScriptInfoSection and type(ScriptInfoSection.new) == "function" then
        local success, scriptInst = pcall(function() return ScriptInfoSection.new(2) end)
        if success and scriptInst and scriptInst.Instance then
            scriptInst.Instance.Size = UDim2.new(0.45, -10, 1, 0)
            scriptInst.Instance.Parent = wrapper
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
