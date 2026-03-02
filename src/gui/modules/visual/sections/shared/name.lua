--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local ToggleButton = SafeImport("gui/modules/components/togglebutton")
local Checkbox = SafeImport("gui/modules/components/checkbox")

export type NameUI = {
    Instance: Frame,
    Destroy: (self: NameUI) -> ()
}

local NameFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local FONT_MAIN = Enum.Font.GothamBold

function NameFactory.new(layoutOrder: number?): NameUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "NameSection"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 1

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Parent = container

    -- LINHA PRINCIPAL
    local mainRow = Instance.new("Frame")
    mainRow.Name = "MainRow"
    mainRow.Size = UDim2.new(1, 0, 0, 45)
    mainRow.BackgroundTransparency = 1
    mainRow.LayoutOrder = 1
    mainRow.Parent = container

    local mainPad = Instance.new("UIPadding")
    mainPad.PaddingLeft = UDim.new(0, 20)
    mainPad.PaddingRight = UDim.new(0, 25)
    mainPad.Parent = mainRow

    local mainLabel = Instance.new("TextLabel")
    mainLabel.Name = "Label"
    mainLabel.Size = UDim2.new(0.5, 0, 1, 0)
    mainLabel.BackgroundTransparency = 1
    mainLabel.Text = "Name"
    mainLabel.TextColor3 = COLOR_LABEL
    mainLabel.Font = FONT_MAIN
    mainLabel.TextSize = 18
    mainLabel.TextXAlignment = Enum.TextXAlignment.Left
    mainLabel.Parent = mainRow

    local mainToggle = nil
    if ToggleButton and type(ToggleButton.new) == "function" then
        mainToggle = ToggleButton.new()
        mainToggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
        mainToggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        mainToggle.Instance.Parent = mainRow
        maid:GiveTask(mainToggle)
    end

    -- CONTÊINER DE SUB-OPÇÕES
    local optionsContainer = Instance.new("Frame")
    optionsContainer.Name = "OptionsContainer"
    optionsContainer.Size = UDim2.new(1, 0, 0, 0)
    optionsContainer.AutomaticSize = Enum.AutomaticSize.Y
    optionsContainer.BackgroundTransparency = 1
    optionsContainer.Visible = false
    optionsContainer.LayoutOrder = 2
    optionsContainer.Parent = container

    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsLayout.Parent = optionsContainer

    local function createCheckRow(name: string, order: number): (Frame, any)
        local row = Instance.new("Frame")
        row.Name = name:gsub("%s+", "") .. "Row"
        row.Size = UDim2.new(1, 0, 0, 30)
        row.BackgroundTransparency = 1
        row.LayoutOrder = order
        row.Parent = optionsContainer

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 40)
        pad.PaddingRight = UDim.new(0, 25)
        pad.Parent = row

        local lbl = Instance.new("TextLabel")
        lbl.Name = "Label"
        lbl.Size = UDim2.new(0.5, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = name
        lbl.TextColor3 = COLOR_LABEL
        lbl.Font = FONT_MAIN
        lbl.TextSize = 14
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local check = nil
        if Checkbox and type(Checkbox.new) == "function" then
            check = Checkbox.new(false)
            check.Instance.AnchorPoint = Vector2.new(1, 0.5)
            check.Instance.Position = UDim2.new(1, 0, 0.5, 0)
            check.Instance.Parent = row
            maid:GiveTask(check)
        end

        return row, check
    end

    local userRow, userCheck = createCheckRow("User Name", 1)
    local displayRow, displayCheck = createCheckRow("Display Name", 2)

    -- LÓGICA RADIO BUTTON MUTUAMENTE EXCLUSIVA
    if userCheck and displayCheck then
        userCheck:SetState(true)

        local isUpdating = false

        maid:GiveTask(userCheck.Toggled:Connect(function(state: boolean)
            if isUpdating then return end
            isUpdating = true

            if state == true then
                displayCheck:SetState(false)
            else
                if displayCheck:GetState() == false then
                    userCheck:SetState(true)
                end
            end

            isUpdating = false
        end))

        maid:GiveTask(displayCheck.Toggled:Connect(function(state: boolean)
            if isUpdating then return end
            isUpdating = true

            if state == true then
                userCheck:SetState(false)
            else
                if userCheck:GetState() == false then
                    displayCheck:SetState(true)
                end
            end

            isUpdating = false
        end))
    end

    if mainToggle then
        maid:GiveTask(mainToggle.Toggled:Connect(function(state: boolean)
            optionsContainer.Visible = state
        end))
    end

    maid:GiveTask(container)
    local self = {}
    self.Instance = container
    function self:Destroy() maid:Destroy() end
    return self :: NameUI
end

return NameFactory
