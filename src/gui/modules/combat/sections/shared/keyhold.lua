--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

-- Proteção de Módulo: Isolamento de dependências via pcall (Conforme memória)
local function SafeImport(path: string): any?
    local success, result = pcall(function()
        return Import(path)
    end)
    if not success then
        warn("[Sacrament] Falha ao importar dependência em KeyHold: " .. path)
        return nil
    end
    return result
end

local ToggleButton = SafeImport("gui/modules/components/togglebutton")

export type KeyHoldSection = {
    Instance: Frame,
    GetState: (self: KeyHoldSection) -> boolean,
    Destroy: (self: KeyHoldSection) -> ()
}

local KeyHoldFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local FONT_MAIN = Enum.Font.GothamBold

function KeyHoldFactory.new(layoutOrder: number): KeyHoldSection
    local maid = Maid.new()
    local state = false

    local row = Instance.new("Frame")
    row.Name = "KeyHoldRow"
    row.Size = UDim2.new(1, 0, 0, 40)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.LayoutOrder = layoutOrder

    local rowLayout = Instance.new("UIListLayout")
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rowLayout.Parent = row

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = row

    local lblTitle = Instance.new("TextLabel")
    lblTitle.Size = UDim2.new(0.5, 0, 1, 0)
    lblTitle.BackgroundTransparency = 1
    lblTitle.BorderSizePixel = 0
    lblTitle.Text = "Key Hold"
    lblTitle.TextColor3 = COLOR_LABEL
    lblTitle.Font = FONT_MAIN
    lblTitle.TextSize = 18
    lblTitle.TextXAlignment = Enum.TextXAlignment.Left
    lblTitle.Parent = row

    local toggleCont = Instance.new("Frame")
    toggleCont.Name = "ToggleContainer"
    toggleCont.Size = UDim2.new(0, 120, 0, 32)
    toggleCont.Position = UDim2.new(1, 0, 0.5, 0)
    toggleCont.AnchorPoint = Vector2.new(1, 0.5)
    toggleCont.BackgroundTransparency = 1
    toggleCont.Parent = row

    if ToggleButton and type(ToggleButton.new) == "function" then
        local toggle = ToggleButton.new()
        toggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
        toggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        toggle.Instance.Parent = toggleCont
        maid:GiveTask(toggle)

        maid:GiveTask(toggle.Toggled:Connect(function(newState: boolean)
            state = newState
        end))
    end

    maid:GiveTask(row)

    local self = {}
    self.Instance = row

    function self:GetState()
        return state
    end

    function self:Destroy()
        maid:Destroy()
    end

    return self :: KeyHoldSection
end

return KeyHoldFactory
