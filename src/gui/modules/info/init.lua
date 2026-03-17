--!strict
--[[
    SACRAMENT | Info Orchestrator (init)
    Responsável pela exibição de créditos, informações do desenvolvedor e status do sistema.
--]]

local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

-- Função de importação segura
local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then 
        warn("[SACRAMENT] Falha ao importar modulo info: " .. path)
        return nil 
    end
    return result
end

-- Sub-módulos (Paths atualizados para a nova estrutura de pastas)
local AdeptSection = SafeImport("gui/modules/info/adept")
local ScriptInfoSection = SafeImport("gui/modules/info/scriptinfo")

export type InfoUI = {
    Instance: Frame,
    Destroy: (self: InfoUI) -> ()
}

local InfoFactory = {}

function InfoFactory.new(layoutOrder: any): InfoUI
    local maid = Maid.new()
    
    -- Normalização de LayoutOrder
    local actualOrder = type(layoutOrder) == "number" and layoutOrder or 1

    -- Container Raiz da Aba
    local container = Instance.new("Frame")
    container.Name = "InfoContainer"
    container.Size = UDim2.fromScale(1, 1)
    container.BackgroundTransparency = 1
    container.LayoutOrder = actualOrder

    -- Wrapper Central (Mantendo a largura de 480px para foco visual)
    local wrapper = Instance.new("Frame")
    wrapper.Name = "VerticalWrapper"
    wrapper.Size = UDim2.new(0, 480, 1, 0)
    wrapper.AnchorPoint = Vector2.new(0.5, 0.5)
    wrapper.Position = UDim2.fromScale(0.5, 0.5)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = container

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 25)
    layout.Parent = wrapper

    --[[ CARREGAMENTO DINÂMICO ]]--

    -- Seção Adept (Créditos/Avatar)
    if AdeptSection and type(AdeptSection.new) == "function" then
        local success, adeptInst = pcall(function() return AdeptSection.new(1) end)
        if success and adeptInst and adeptInst.Instance then
            -- Altura expandida para respiro elegante (165px)
            adeptInst.Instance.Size = UDim2.new(1, 0, 0, 165)
            adeptInst.Instance.Parent = wrapper
            maid:GiveTask(adeptInst)
        end
    end

    -- Seção Script Info (Versão/Status)
    if ScriptInfoSection and type(ScriptInfoSection.new) == "function" then
        local success, scriptInst = pcall(function() return ScriptInfoSection.new(2) end)
        if success and scriptInst and scriptInst.Instance then
            scriptInst.Instance.Size = UDim2.new(1, 0, 0, 170)
            scriptInst.Instance.Parent = wrapper
            maid:GiveTask(scriptInst)
        end
    end

    maid:GiveTask(container)

    local self = {}
    self.Instance = container
    
    function self:Destroy() 
        maid:Destroy() 
    end
    
    return self :: InfoUI
end

return InfoFactory
