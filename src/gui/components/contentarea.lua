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

function ContentAreaModule.new(settings: any): ContentArea
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

    -- O Cache e o Ticket de Prevenção de Condição de Corrida
    local tabCache = {} 
    local currentRequestedTab = ""

    local function loadTabContent(tabName: string)
        local lowerName = string.lower(tabName)
        currentRequestedTab = lowerName -- Atualiza o "Ticket" atual

        -- MATA A SOBREPOSIÇÃO: Força todas as abas carregadas a ficarem invisíveis imediatamente
        for name, inst in pairs(tabCache) do
            inst.Visible = false
        end

        -- Se a aba já foi carregada antes (Está no Cache), apenas exibe ela instantaneamente!
        if tabCache[lowerName] then
            tabCache[lowerName].Visible = true
            return
        end

        -- Se a aba NÃO existe no Cache, nós carregamos ela pela primeira e única vez.
        local modulePath = "gui/modules/" .. lowerName
        local success, result = pcall(function()
            return Import(modulePath)
        end)
        
        if success and type(result) == "table" and type(result.new) == "function" then
            local successCreate, moduleInstance = pcall(function()
                return result.new(settings)
            end)

            if successCreate and moduleInstance and moduleInstance.Instance then
                moduleInstance.Instance.Parent = content
                maid:GiveTask(moduleInstance)
                
                -- Salva no Cache para acesso futuro
                tabCache[lowerName] = moduleInstance.Instance
                
                -- O CHEQUE DE SEGURANÇA:
                -- Se eu terminei de carregar, mas o usuário já clicou em outra aba enquanto eu carregava, eu fico invisível!
                if currentRequestedTab == lowerName then
                    moduleInstance.Instance.Visible = true
                else
                    moduleInstance.Instance.Visible = false
                end
            else
                warn(string.format("[Sacrament] Erro ao instanciar módulo %s", tabName))
            end
        else
            warn(string.format("[Sacrament] Módulo não encontrado ou erro de sintaxe (%s)", tabName))
        end
    end

    maid:GiveTask(UIState.TabChanged:Connect(loadTabContent))
    loadTabContent(UIState.ActiveTab)

    local self = {}
    self.Instance = content

    function self:Destroy()
        tabCache = {}
        maid:Destroy()
        content:Destroy()
    end

    return self
end

return ContentAreaModule
