--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local ToggleButton = SafeImport("gui/modules/components/togglebutton")

export type TargetUI = {
    Instance: Frame,
    Destroy: (self: TargetUI) -> ()
}

local TargetFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local COLOR_WHITE = Color3.fromHex("FFFFFF")
local COLOR_BOX_BG = Color3.fromHex("1A1A1A")
local COLOR_BOX_BORDER = Color3.fromHex("333333")
local COLOR_ACCENT = Color3.fromHex("C80000")
local FONT_MAIN = Enum.Font.GothamBold

function TargetFactory.new(layoutOrder: number?): TargetUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "TargetSection"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 1

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Parent = container

    -- LINHA PRINCIPAL (TOGGLE)
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
    mainLabel.Text = "Target Mode"
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

    -- INPUT DE NOME
    local inputRow = Instance.new("Frame")
    inputRow.Name = "InputRow"
    inputRow.Size = UDim2.new(1, 0, 0, 40)
    inputRow.BackgroundTransparency = 1
    inputRow.LayoutOrder = 1
    inputRow.Parent = optionsContainer

    local inputPad = Instance.new("UIPadding")
    inputPad.PaddingLeft = UDim.new(0, 40)
    inputPad.PaddingRight = UDim.new(0, 25)
    inputPad.Parent = inputRow

    local inputLabel = Instance.new("TextLabel")
    inputLabel.Name = "Label"
    inputLabel.Size = UDim2.new(0.5, 0, 1, 0)
    inputLabel.BackgroundTransparency = 1
    inputLabel.Text = "Target Name"
    inputLabel.TextColor3 = COLOR_LABEL
    inputLabel.Font = FONT_MAIN
    inputLabel.TextSize = 16
    inputLabel.TextXAlignment = Enum.TextXAlignment.Left
    inputLabel.Parent = inputRow

    local nameInput = Instance.new("TextBox")
    nameInput.Name = "InputBox"
    nameInput.Size = UDim2.fromOffset(130, 28)
    nameInput.AnchorPoint = Vector2.new(1, 0.5)
    nameInput.Position = UDim2.new(1, 0, 0.5, 0)
    nameInput.BackgroundColor3 = COLOR_BOX_BG
    nameInput.Text = ""
    nameInput.PlaceholderText = "Username..."
    nameInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    nameInput.TextColor3 = COLOR_WHITE
    nameInput.Font = FONT_MAIN
    nameInput.TextSize = 14
    nameInput.ClearTextOnFocus = false
    nameInput.Parent = inputRow

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = nameInput

    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = COLOR_BOX_BORDER
    inputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    inputStroke.Parent = nameInput

    -- CARTÃO DE INFORMAÇÕES DO ALVO
    local infoRow = Instance.new("Frame")
    infoRow.Name = "InfoRow"
    infoRow.Size = UDim2.new(1, 0, 0, 90)
    infoRow.BackgroundTransparency = 1
    infoRow.LayoutOrder = 2
    infoRow.Parent = optionsContainer

    local infoPad = Instance.new("UIPadding")
    infoPad.PaddingLeft = UDim.new(0, 40)
    infoPad.PaddingRight = UDim.new(0, 25)
    infoPad.PaddingTop = UDim.new(0, 5)
    infoPad.PaddingBottom = UDim.new(0, 5)
    infoPad.Parent = infoRow

    local card = Instance.new("Frame")
    card.Name = "Card"
    card.Size = UDim2.fromScale(1, 1)
    card.BackgroundColor3 = COLOR_BOX_BG
    card.Parent = infoRow

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 6)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = COLOR_BOX_BORDER
    cardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    cardStroke.Parent = card

    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Name = "Avatar"
    avatarImg.Size = UDim2.fromOffset(60, 60)
    avatarImg.Position = UDim2.fromOffset(10, 10)
    avatarImg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    avatarImg.BorderSizePixel = 0
    avatarImg.Image = "" -- Placeholder
    avatarImg.Parent = card

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0, 6)
    avatarCorner.Parent = avatarImg

    local nickLabel = Instance.new("TextLabel")
    nickLabel.Name = "Nick"
    nickLabel.Size = UDim2.new(1, -90, 0, 30)
    nickLabel.Position = UDim2.fromOffset(80, 10)
    nickLabel.BackgroundTransparency = 1
    nickLabel.Text = "No Target"
    nickLabel.TextColor3 = COLOR_WHITE
    nickLabel.Font = FONT_MAIN
    nickLabel.TextSize = 16
    nickLabel.TextXAlignment = Enum.TextXAlignment.Left
    nickLabel.Parent = card

    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "Distance"
    distLabel.Size = UDim2.new(1, -90, 0, 20)
    distLabel.Position = UDim2.fromOffset(80, 45)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "[ 0m ]"
    distLabel.TextColor3 = COLOR_ACCENT
    distLabel.Font = FONT_MAIN
    distLabel.TextSize = 14
    distLabel.TextXAlignment = Enum.TextXAlignment.Left
    distLabel.Parent = card

    -- EVENTO DE EXPANSÃO
    if mainToggle then
        maid:GiveTask(mainToggle.Toggled:Connect(function(state: boolean)
            optionsContainer.Visible = state
        end))
    end

    maid:GiveTask(container)
    local self = {}
    self.Instance = container
    function self:Destroy() maid:Destroy() end
    return self :: TargetUI
end

return TargetFactory
