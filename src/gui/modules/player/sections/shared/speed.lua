--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

-- Proteção de Módulo: Isolamento de dependências via pcall
local function SafeImport(path: string): any?
    local success, result = pcall(function()
        return Import(path)
    end)
    if not success then
        warn("[Sacrament] Falha ao importar dependência em Speed Section: " .. path)
        return nil
    end
    return result
end

local ToggleButton = SafeImport("gui/modules/components/togglebutton")

export type SpeedUI = {
    Instance: Frame,
    Toggled: RBXScriptSignal,
    ValueChanged: RBXScriptSignal,
    Destroy: (self: SpeedUI) -> ()
}

local SpeedFactory = {}

local COLOR_WHITE = Color3.fromHex("FFFFFF")
local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_STROKE = Color3.fromHex("333333")
local FONT_MAIN = Enum.Font.GothamBold

local function createToggleRow(maid: any, titleText: string, layoutOrder: number)
    local row = Instance.new("Frame")
    row.Name = titleText:gsub(" ", "") .. "ToggleRow"
    row.Size = UDim2.new(1, 0, 0, 45)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = row

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = COLOR_LABEL
    title.Font = FONT_MAIN
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = row

    local toggle = nil
    if ToggleButton and type(ToggleButton.new) == "function" then
        toggle = ToggleButton.new()
        toggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
        toggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        toggle.Instance.Parent = row
        maid:GiveTask(toggle)
    end

    return row, toggle
end

local function createValueRow(maid: any, titleText: string, defaultVal: number, layoutOrder: number)
    local row = Instance.new("Frame")
    row.Name = titleText:gsub(" ", "") .. "ValueRow"
    row.Size = UDim2.new(1, 0, 0, 45)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = row

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = COLOR_LABEL
    title.Font = FONT_MAIN
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = row

    local inputBg = Instance.new("Frame")
    inputBg.Size = UDim2.new(0, 60, 0, 24)
    inputBg.Position = UDim2.new(1, 0, 0.5, 0)
    inputBg.AnchorPoint = Vector2.new(1, 0.5)
    inputBg.BackgroundColor3 = COLOR_BG
    inputBg.Parent = row

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = inputBg

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLOR_STROKE
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = inputBg

    local input = Instance.new("TextBox")
    input.Size = UDim2.fromScale(1, 1)
    input.BackgroundTransparency = 1
    input.Text = tostring(defaultVal)
    input.PlaceholderText = tostring(defaultVal)
    input.TextColor3 = COLOR_WHITE
    input.Font = FONT_MAIN
    input.TextSize = 14
    input.Parent = inputBg

    local changedEvent = Instance.new("BindableEvent")
    maid:GiveTask(changedEvent)

    maid:GiveTask(input:GetPropertyChangedSignal("Text"):Connect(function()
        -- Remove tudo que não for número
        local text = input.Text:gsub("%D", "")
        -- Limita a 3 caracteres (0 até 999)
        if #text > 3 then 
            text = string.sub(text, 1, 3) 
        end
        
        if input.Text ~= text then
            input.Text = text
        end
    end))

    maid:GiveTask(input.FocusLost:Connect(function()
        local num = tonumber(input.Text)
        if not num then
            input.Text = tostring(defaultVal)
            changedEvent:Fire(defaultVal)
            return
        end
        
        -- Garante que valores vazios ou apenas com zeros não quebrem o formato
        input.Text = tostring(num)
        changedEvent:Fire(num)
    end))

    return row, input, changedEvent
end

function SpeedFactory.new(toggleTitle: string, valueTitle: string, defaultVal: number, layoutOrder: number?): SpeedUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = toggleTitle:gsub(" ", "") .. "Section"
    container.Size = UDim2.new(1, 0, 0, 90) -- Espaço para duas linhas de 45
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 1

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container

    local toggleRow, toggleObj = createToggleRow(maid, toggleTitle, 1)
    toggleRow.Parent = container

    local valueRow, valueInput, valueChangedEvent = createValueRow(maid, valueTitle, defaultVal, 2)
    valueRow.Parent = container

    local toggledEvent = Instance.new("BindableEvent")
    maid:GiveTask(toggledEvent)

    if toggleObj then
        maid:GiveTask(toggleObj.Toggled:Connect(function(state: boolean)
            toggledEvent:Fire(state)
        end))
    end

    maid:GiveTask(container)

    local self = {}
    self.Instance = container
    self.Toggled = toggledEvent.Event
    self.ValueChanged = valueChangedEvent.Event

    function self:Destroy()
        maid:Destroy()
    end

    return self :: SpeedUI
end

return SpeedFactory
