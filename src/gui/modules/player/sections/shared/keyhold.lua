--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

-- Proteção de Módulo: Isolamento de dependências via pcall
local function SafeImport(path: string): any?
    local success, result = pcall(function()
        return Import(path)
    end)
    if not success then
        warn("[Sacrament] Falha ao importar dependência em Key Hold: " .. path)
        return nil
    end
    return result
end

local ToggleButton = SafeImport("gui/modules/components/togglebutton")

export type KeyHoldUI = {
    Instance: Frame,
    Toggled: RBXScriptSignal,
    Destroy: (self: KeyHoldUI) -> ()
}

local KeyHoldFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local FONT_MAIN = Enum.Font.GothamBold

function KeyHoldFactory.new(layoutOrder: number?): KeyHoldUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "KeyHoldSection"
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 1

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = container

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "Key Hold"
    title.TextColor3 = COLOR_LABEL
    title.Font = FONT_MAIN
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = container

    local toggledEvent = Instance.new("BindableEvent")
    maid:GiveTask(toggledEvent)

    if ToggleButton and type(ToggleButton.new) == "function" then
        local toggle = ToggleButton.new()
        toggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
        toggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        toggle.Instance.Parent = container
        maid:GiveTask(toggle)

        maid:GiveTask(toggle.Toggled:Connect(function(state: boolean)
            toggledEvent:Fire(state)
        end))
    end

    maid:GiveTask(container)

    local self = {}
    self.Instance = container
    self.Toggled = toggledEvent.Event

    function self:Destroy()
        maid:Destroy()
    end

    return self :: KeyHoldUI
end

return KeyHoldFactory
