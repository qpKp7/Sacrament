--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

-- Proteção de Módulo: Isolamento de dependências via pcall
local function SafeImport(path: string): any?
    local success, result = pcall(function()
        return Import(path)
    end)
    if not success then
        warn("[Sacrament] Falha ao importar dependência em HitChance: " .. path)
        return nil
    end
    return result
end

local Slider = SafeImport("gui/modules/components/slider")

export type HitChanceSection = {
    Instance: Frame,
    Destroy: (self: HitChanceSection) -> ()
}

local HitChanceFactory = {}

function HitChanceFactory.new(layoutOrder: number): HitChanceSection
    local maid = Maid.new()
    
    local targetInstance: Frame
    
    if Slider and type(Slider.new) == "function" then
        local slider = Slider.new("Hit Chance", 0, 100, 95, 1)
        slider.Instance.LayoutOrder = layoutOrder
        maid:GiveTask(slider)
        targetInstance = slider.Instance
    else
        -- Fallback seguro para evitar que a interface crashe se o Slider falhar
        targetInstance = Instance.new("Frame")
        targetInstance.Name = "HitChanceFallback"
        targetInstance.BackgroundTransparency = 1
        targetInstance.BorderSizePixel = 0
        targetInstance.Size = UDim2.new(1, 0, 0, 0)
        targetInstance.LayoutOrder = layoutOrder
        maid:GiveTask(targetInstance)
    end

    local self = {}
    self.Instance = targetInstance

    function self:Destroy()
        maid:Destroy()
    end

    return self :: HitChanceSection
end

return HitChanceFactory
