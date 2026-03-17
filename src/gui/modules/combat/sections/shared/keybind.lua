--!strict
--[[
    SACRAMENT | Section: Keybind Row
    Exibe a linha "KEY" e utiliza o componente Keybox centralizado.
--]]

local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

-- Importando o novo componente
local KeyboxComponent = Import("gui/modules/components/keybox")

export type KeybindSection = {
    Instance: Frame,
    KeyChanged: RBXScriptSignal,
    SetKey: (self: KeybindSection, keyEnum: any) -> (),
    Destroy: (self: KeybindSection) -> ()
}

local KeybindFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local FONT_MAIN = Enum.Font.GothamBold

function KeybindFactory.new(layoutOrder: number): KeybindSection
    local maid = Maid.new()
    
    -- Container da Linha
    local row = Instance.new("Frame")
    row.Name = "KeyRow"
    row.Size = UDim2.new(1, 0, 0, 55)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder

    local rowLayout = Instance.new("UIListLayout")
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rowLayout.Parent = row

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 50)
    pad.Parent = row

    -- Label "KEY"
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "KEY"
    lbl.TextColor3 = COLOR_LABEL
    lbl.Font = FONT_MAIN
    lbl.TextSize = 20
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    -- Instanciação do Componente Centralizado
    local keybox = KeyboxComponent.new()
    keybox.Instance.AnchorPoint = Vector2.new(1, 0.5)
    keybox.Instance.Position = UDim2.new(1, 0, 0.5, 0)
    keybox.Instance.Parent = row
    maid:GiveTask(keybox)

    maid:GiveTask(row)

    local self = {}
    self.Instance = row
    self.KeyChanged = keybox.KeyChanged -- Repassa o sinal do componente
    
    function self:SetKey(keyEnum: any)
        keybox:SetKey(keyEnum)
    end

    function self:Destroy()
        maid:Destroy()
    end

    return self :: KeybindSection
end

return KeybindFactory
