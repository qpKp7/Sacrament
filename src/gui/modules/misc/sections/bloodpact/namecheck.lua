--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local ToggleButton = SafeImport("gui/modules/components/togglebutton")
local DynamicList = SafeImport("gui/modules/components/dynamiclist")

export type NameCheckUI = {
    ToggleInstance: Frame,
    ListInstance: Frame?,
    Toggled: RBXScriptSignal,
    ListChanged: RBXScriptSignal,
    GetState: (self: NameCheckUI) -> boolean,
    GetList: (self: NameCheckUI) -> {string},
    Destroy: (self: NameCheckUI) -> ()
}

local NameCheckFactory = {}

local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_BORDER = Color3.fromHex("333333")
local COLOR_TEXT = Color3.fromHex("FFFFFF")
local COLOR_SUBTEXT = Color3.fromHex("888888")
local FONT_MAIN = Enum.Font.GothamBold

function NameCheckFactory.new(layoutOrder: number?): NameCheckUI
    local maid = Maid.new()
    local currentState = false

    local toggleCard = Instance.new("Frame")
    toggleCard.Name = "NameToggleCard"
    toggleCard.Size = UDim2.new(1, 0, 0, 55)
    toggleCard.BackgroundColor3 = COLOR_BG
    toggleCard.LayoutOrder = layoutOrder or 1

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = toggleCard
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLOR_BORDER
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = toggleCard
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 15)
    pad.PaddingRight = UDim.new(0, 15)
    pad.Parent = toggleCard

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 0, 16)
    title.Position = UDim2.new(0, 0, 0.5, -10)
    title.AnchorPoint = Vector2.new(0, 0.5)
    title.BackgroundTransparency = 1
    title.Text = "User Name Check"
    title.TextColor3 = COLOR_TEXT
    title.Font = FONT_MAIN
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = toggleCard

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -50, 0, 12)
    subtitle.Position = UDim2.new(0, 0, 0.5, 8)
    subtitle.AnchorPoint = Vector2.new(0, 0.5)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Use User Name List"
    subtitle.TextColor3 = COLOR_SUBTEXT
    subtitle.Font = FONT_MAIN
    subtitle.TextSize = 12
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = toggleCard

    local toggledEvent = Instance.new("BindableEvent")
    maid:GiveTask(toggledEvent)

    local listPanel = nil
    if DynamicList and type(DynamicList.new) == "function" then
        listPanel = DynamicList.new("User Name List", layoutOrder)
        listPanel.Instance.Size = UDim2.new(1, 0, 0, 0)
        listPanel.Instance.Visible = false -- Inicia oculta
        maid:GiveTask(listPanel)
    end

    if ToggleButton and type(ToggleButton.new) == "function" then
        local toggle = ToggleButton.new()
        toggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
        toggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        toggle.Instance.Parent = toggleCard
        
        maid:GiveTask(toggle.Toggled:Connect(function(state: boolean)
            currentState = state
            if listPanel then
                listPanel.Instance.Visible = state
            end
            toggledEvent:Fire(state)
        end))
        maid:GiveTask(toggle)
    end

    maid:GiveTask(toggleCard)

    local self = {}
    self.ToggleInstance = toggleCard
    self.ListInstance = listPanel and listPanel.Instance or nil
    self.Toggled = toggledEvent.Event
    self.ListChanged = listPanel and listPanel.ListChanged or Instance.new("BindableEvent").Event

    function self:GetState() return currentState end
    function self:GetList() return listPanel and listPanel:GetValues() or {} end
    function self:Destroy() maid:Destroy() end

    return self :: NameCheckUI
end

return NameCheckFactory
