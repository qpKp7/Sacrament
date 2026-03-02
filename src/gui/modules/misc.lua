--!strict
local Players = game:GetService("Players")
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local BloodPactSection = SafeImport("gui/modules/misc/bloodpact")

export type MiscUI = {
    Instance: Frame,
    Destroy: (self: MiscUI) -> ()
}

local MiscFactory = {}

local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_BORDER = Color3.fromHex("333333")
local COLOR_ACCENT = Color3.fromHex("C80000")
local COLOR_TEXT = Color3.fromHex("FFFFFF")
local COLOR_SUBTEXT = Color3.fromHex("888888")
local FONT_MAIN = Enum.Font.GothamBold

function MiscFactory.new(layoutOrder: number?): MiscUI
    local maid = Maid.new()
    local localPlayer = Players.LocalPlayer

    local container = Instance.new("Frame")
    container.Name = "MiscContainer"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.LayoutOrder = layoutOrder or 1

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Padding = UDim.new(0, 15)
    containerLayout.Parent = container

    local containerPad = Instance.new("UIPadding")
    containerPad.PaddingTop = UDim.new(0, 20)
    containerPad.PaddingLeft = UDim.new(0, 20)
    containerPad.PaddingRight = UDim.new(0, 20)
    containerPad.PaddingBottom = UDim.new(0, 20)
    containerPad.Parent = container

    -- 1. CARTÃO DO ADEPTO (TOP)
    local adeptCard = Instance.new("Frame")
    adeptCard.Name = "AdeptCard"
    adeptCard.Size = UDim2.new(1, 0, 0, 80)
    adeptCard.BackgroundColor3 = COLOR_BG
    adeptCard.LayoutOrder = 1
    adeptCard.Parent = container

    local adeptCorner = Instance.new("UICorner")
    adeptCorner.CornerRadius = UDim.new(0, 6)
    adeptCorner.Parent = adeptCard

    local adeptStroke = Instance.new("UIStroke")
    adeptStroke.Color = COLOR_BORDER
    adeptStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    adeptStroke.Parent = adeptCard

    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Name = "Avatar"
    avatarImg.Size = UDim2.fromOffset(60, 60)
    avatarImg.AnchorPoint = Vector2.new(0, 0.5)
    avatarImg.Position = UDim2.new(0, 10, 0.5, 0)
    avatarImg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    avatarImg.BorderSizePixel = 0
    avatarImg.Parent = adeptCard

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0, 6)
    avatarCorner.Parent = avatarImg

    local avatarStroke = Instance.new("UIStroke")
    avatarStroke.Color = COLOR_ACCENT
    avatarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    avatarStroke.Parent = avatarImg

    -- Carregar avatar real do LocalPlayer
    task.spawn(function()
        if localPlayer then
            local thumbType = Enum.ThumbnailType.HeadShot
            local thumbSize = Enum.ThumbnailSize.Size150x150
            local content, isReady = Players:GetUserThumbnailAsync(localPlayer.UserId, thumbType, thumbSize)
            if isReady then
                avatarImg.Image = content
            end
        end
    end)

    local adeptLabels = Instance.new("Frame")
    adeptLabels.Name = "Labels"
    adeptLabels.Size = UDim2.new(1, -90, 1, 0)
    adeptLabels.Position = UDim2.fromOffset(85, 0)
    adeptLabels.BackgroundTransparency = 1
    adeptLabels.Parent = adeptCard

    local adeptLayout = Instance.new("UIListLayout")
    adeptLayout.SortOrder = Enum.SortOrder.LayoutOrder
    adeptLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    adeptLayout.Padding = UDim.new(0, 4)
    adeptLayout.Parent = adeptLabels

    local function createLabel(text: string, color: Color3, order: number)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 16)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = color
        lbl.Font = FONT_MAIN
        lbl.TextSize = 16
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.LayoutOrder = order
        lbl.Parent = adeptLabels
    end

    local playerName = localPlayer and localPlayer.Name or "Unknown"
    createLabel("Adept: " .. playerName, COLOR_TEXT, 1)
    createLabel("Covenant: Lifetime", COLOR_ACCENT, 2)
    createLabel("Version: V1.0.0", COLOR_SUBTEXT, 3)

    -- 2. GRID DE RITUAIS (BENTO BOX)
    local gridContainer = Instance.new("Frame")
    gridContainer.Name = "GridContainer"
    gridContainer.Size = UDim2.new(1, 0, 0, 0)
    gridContainer.AutomaticSize = Enum.AutomaticSize.Y
    gridContainer.BackgroundTransparency = 1
    gridContainer.LayoutOrder = 2
    gridContainer.Parent = container

    local gridLayout = Instance.new("UIListLayout")
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.FillDirection = Enum.FillDirection.Horizontal
    gridLayout.Wraps = true
    gridLayout.Padding = UDim.new(0, 15)
    gridLayout.Parent = gridContainer

    -- Inserir Blood Pact Cartão Dinâmico
    if BloodPactSection and type(BloodPactSection.new) == "function" then
        local success, bpInstance = pcall(function() return BloodPactSection.new(1) end)
        if success and bpInstance and bpInstance.Instance then
            bpInstance.Instance.Parent = gridContainer
            maid:GiveTask(bpInstance)
        end
    end

    -- 3. BOTÕES DE CONFIG (RODAPÉ)
    local configContainer = Instance.new("Frame")
    configContainer.Name = "ConfigContainer"
    configContainer.Size = UDim2.new(1, 0, 0, 45)
    configContainer.BackgroundTransparency = 1
    configContainer.LayoutOrder = 3
    configContainer.Parent = container

    local configLayout = Instance.new("UIListLayout")
    configLayout.SortOrder = Enum.SortOrder.LayoutOrder
    configLayout.FillDirection = Enum.FillDirection.Horizontal
    configLayout.HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween
    configLayout.Parent = configContainer

    local function createBtn(text: string, order: number)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.5, -7, 1, 0)
        btn.BackgroundColor3 = COLOR_BG
        btn.Text = text
        btn.TextColor3 = COLOR_TEXT
        btn.Font = FONT_MAIN
        btn.TextSize = 14
        btn.AutoButtonColor = false
        btn.LayoutOrder = order
        btn.Parent = configContainer

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn

        local stroke = Instance.new("UIStroke")
        stroke.Color = COLOR_BORDER
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = btn
        
        -- Eventos visuais básicos para o botão
        maid:GiveTask(btn.MouseEnter:Connect(function() stroke.Color = COLOR_ACCENT end))
        maid:GiveTask(btn.MouseLeave:Connect(function() stroke.Color = COLOR_BORDER end))

        return btn
    end

    local saveBtn = createBtn("SAVE CONFIG", 1)
    local loadBtn = createBtn("LOAD CONFIG", 2)

    maid:GiveTask(container)
    local self = {}
    self.Instance = container
    function self:Destroy() maid:Destroy() end
    return self :: MiscUI
end

return MiscFactory
