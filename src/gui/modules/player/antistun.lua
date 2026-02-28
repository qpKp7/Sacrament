--!strict
local TweenService = game:GetService("TweenService")
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local ToggleButton = SafeImport("gui/modules/components/togglebutton")
local Keybind = SafeImport("gui/modules/player/sections/shared/keybind")

export type AntiStunUI = {
    Instance: Frame,
    Destroy: (self: AntiStunUI) -> ()
}

local AntiStunFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local FONT_MAIN = Enum.Font.GothamBold

function AntiStunFactory.new(layoutOrder: number?): AntiStunUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "AntiStunSection"
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 1
    container.ClipsDescendants = true

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container

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

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "Anti Stun"
    title.TextColor3 = COLOR_LABEL
    title.Font = FONT_MAIN
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = mainRow

    local controlsList = Instance.new("Frame")
    controlsList.Size = UDim2.new(0, 100, 1, 0)
    controlsList.AnchorPoint = Vector2.new(1, 0.5)
    controlsList.Position = UDim2.new(1, 0, 0.5, 0)
    controlsList.BackgroundTransparency = 1
    controlsList.Parent = mainRow

    local clLayout = Instance.new("UIListLayout")
    clLayout.FillDirection = Enum.FillDirection.Horizontal
    clLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    clLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    clLayout.Padding = UDim.new(0, 10)
    clLayout.SortOrder = Enum.SortOrder.LayoutOrder
    clLayout.Parent = controlsList

    local arrowBtn = Instance.new("TextButton")
    arrowBtn.Name = "Arrow"
    arrowBtn.Size = UDim2.fromOffset(20, 20)
    arrowBtn.BackgroundTransparency = 1
    arrowBtn.Text = ">"
    arrowBtn.TextColor3 = COLOR_LABEL
    arrowBtn.Font = FONT_MAIN
    arrowBtn.TextSize = 18
    arrowBtn.LayoutOrder = 2
    arrowBtn.Parent = controlsList

    if ToggleButton and type(ToggleButton.new) == "function" then
        local toggleObj = ToggleButton.new()
        toggleObj.Instance.LayoutOrder = 1
        toggleObj.Instance.Parent = controlsList
        maid:GiveTask(toggleObj)
    end

    -- CONTEÚDO EXPANSÍVEL
    local expandFrame = Instance.new("Frame")
    expandFrame.Name = "ExpandableContent"
    expandFrame.Size = UDim2.new(1, 0, 0, 55)
    expandFrame.BackgroundTransparency = 1
    expandFrame.LayoutOrder = 2
    expandFrame.Visible = false
    expandFrame.Parent = container

    local expandLayout = Instance.new("UIListLayout")
    expandLayout.SortOrder = Enum.SortOrder.LayoutOrder
    expandLayout.Parent = expandFrame

    if Keybind and type(Keybind.new) == "function" then
        local keyObj = Keybind.new(1)
        keyObj.Instance.Parent = expandFrame
        maid:GiveTask(keyObj)
    end

    -- ANIMAÇÃO DA SETA E EXPANSÃO
    local isExpanded = false
    local tInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    maid:GiveTask(arrowBtn.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded
        if isExpanded then expandFrame.Visible = true end
        
        local targetRot = isExpanded and 90 or 0
        local targetSize = isExpanded and UDim2.new(1, 0, 0, 100) or UDim2.new(1, 0, 0, 45)
        
        TweenService:Create(arrowBtn, tInfo, {Rotation = targetRot}):Play()
        local sizeTween = TweenService:Create(container, tInfo, {Size = targetSize})
        sizeTween:Play()
        
        if not isExpanded then
            maid:GiveTask(sizeTween.Completed:Connect(function()
                if not isExpanded then expandFrame.Visible = false end
            end))
        end
    end))

    maid:GiveTask(container)
    local self = {}
    self.Instance = container
    function self:Destroy()
        maid:Destroy()
    end
    return self :: AntiStunUI
end

return AntiStunFactory
