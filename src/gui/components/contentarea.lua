--!strict
local Import = (_G :: any).SacramentImport
local Constants = Import("config/constants")
local Colors = Import("themes/colors")
local UIState = Import("state/uistate")
local Maid = Import("utils/maid")

export type ContentArea = {
    Instance: Frame,
    Destroy: (self: ContentArea) -> ()
}

local ContentAreaModule = {}

function ContentAreaModule.new(): ContentArea
    local maid = Maid.new()

    local content = Instance.new("Frame")
    content.Name = "ContentRounded"
    content.Size = UDim2.new(1 - Constants.SIDEBAR_WIDTH, -2, 1, 0)
    content.Position = UDim2.new(Constants.SIDEBAR_WIDTH, 2, 0, 0)
    content.BackgroundColor3 = Colors.ContentBackground
    content.BorderSizePixel = 0
    content.Active = false

    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 18)
    contentCorner.Parent = content

    local leftStraightEdge = Instance.new("Frame")
    leftStraightEdge.Name = "LeftStraightEdge"
    leftStraightEdge.Size = UDim2.new(0, 18, 1, 0)
    leftStraightEdge.Position = UDim2.new(0, 0, 0, 0)
    leftStraightEdge.BackgroundColor3 = Colors.ContentBackground
    leftStraightEdge.BorderSizePixel = 0
    leftStraightEdge.Active = false
    leftStraightEdge.Parent = content

    local currentModuleMaid = Maid.new()
    maid:GiveTask(currentModuleMaid)

    local function loadTabContent(tabName: string)
        currentModuleMaid:DoCleaning()
        
        local modulePath = "gui/modules/" .. string.lower(tabName)
        local success, result = pcall(function()
            return Import(modulePath)
        end)
        
        if success and type(result) == "table" and type(result.new) == "function" then
            local successCreate, moduleInstance = pcall(function()
                return result.new()
            end)

            if successCreate and moduleInstance and moduleInstance.Instance then
                moduleInstance.Instance.Parent = content
                currentModuleMaid:GiveTask(moduleInstance)
            else
                warn(string.format("[Sacrament] Erro ao instanciar módulo %s: %s", tabName, tostring(moduleInstance)))
            end
        else
            warn(string.format("[Sacrament] Módulo não encontrado ou erro de sintaxe (%s): %s", tabName, tostring(result)))
        end
    end

    maid:GiveTask(UIState.TabChanged:Connect(loadTabContent))
    loadTabContent(UIState.ActiveTab)

    local self = {}
    self.Instance = content

    function self:Destroy()
        maid:Destroy()
        content:Destroy()
    end

    return self
end

return ContentAreaModule
