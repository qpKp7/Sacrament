--!strict
local TweenService = game:GetService("TweenService")
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")
local AimlockModule = Import("gui/modules/combat/aimlock")
local SilentAimModule = Import("gui/modules/combat/silentaim")

export type CombatModule = {
    Instance: Frame,
    Destroy: (self: CombatModule) -> ()
}

local CombatModuleFactory = {}

local COLOR_ARROW_CLOSED = Color3.fromHex("B4B4B4")
local COLOR_ARROW_OPEN = Color3.fromHex("680303")

function CombatModuleFactory.new(): CombatModule
    local maid = Maid.new()

    -- Container principal estático (não-arrastável)
    local container = Instance.new("Frame")
    container.Name = "CombatContainer"
    container.Size = UDim2.fromScale(1, 1)
    container.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    container.BorderSizePixel = 0
    container.ClipsDescendants = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 18)
    corner.Parent = container

    -- Painel Esquerdo: Área fixa para os headers (toggles) empilhados
    local leftPanel = Instance.new("Frame")
    leftPanel.Name = "LeftPanel"
    leftPanel.Size = UDim2.new(0, 280, 1, 0)
    leftPanel.BackgroundTransparency = 1
    leftPanel.BorderSizePixel = 0
    leftPanel.Parent = container

    local leftLayout = Instance.new("UIListLayout")
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Padding = UDim.new(0, 0)
    leftLayout.Parent = leftPanel

    -- Painel Direito: Área fixa para os subframes (renderizam a partir do topo)
    local rightPanel = Instance.new("Frame")
    rightPanel.Name = "RightPanel"
    rightPanel.Size = UDim2.new(1, -280, 1, 0)
    rightPanel.Position = UDim2.fromOffset(280, 0)
    rightPanel.BackgroundTransparency = 1
    rightPanel.BorderSizePixel = 0
    rightPanel.Parent = container

    local openSubframe: Frame? = nil
    local openHeader: Frame? = nil

    local function updateArrowState(header: Frame, isOpen: boolean)
        local controls = header:FindFirstChild("Controls")
        if controls then
            for _, desc in ipairs(controls:GetDescendants()) do
                -- Captura o botão da seta independente do estado atual ou bugado ("<")
                if desc:IsA("TextButton") and (desc.Text == "v" or desc.Text == ">" or desc.Text == "<" or desc.Text == "V" or desc.Text == "^") then
                    local targetText = isOpen and "v" or ">"
                    local targetColor = isOpen and COLOR_ARROW_OPEN or COLOR_ARROW_CLOSED
                    
                    desc.Text = targetText
                    
                    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local tween = TweenService:Create(desc, tweenInfo, {TextColor3 = targetColor})
                    tween:Play()
                    
                    local conn: RBXScriptConnection
                    conn = tween.Completed:Connect(function()
                        conn:Disconnect()
                        tween:Destroy()
                    end)
                    break
                end
            end
        end
    end

    local function setupMutex(header: Frame, subFrame: Frame)
        maid:GiveTask(subFrame:GetPropertyChangedSignal("Visible"):Connect(function()
            -- task.defer sobrescreve instantaneamente qualquer texto incorreto setado pelo componente interno (como "<")
            task.defer(function()
                if subFrame.Visible then
                    if openSubframe and openSubframe ~= subFrame then
                        local prevSub = openSubframe
                        local prevHeader = openHeader
                        
                        prevSub.Visible = false
                        if prevHeader then
                            updateArrowState(prevHeader, false)
                        end
                    end
                    
                    openSubframe = subFrame
                    openHeader = header
                    updateArrowState(header, true)
                else
                    if openSubframe == subFrame then
                        openSubframe = nil
                        openHeader = nil
                    end
                    updateArrowState(header, false)
                end
            end)
        end))
    end

    -- Extração e Montagem do Aimlock
    local aimlock = AimlockModule.new()
    maid:GiveTask(aimlock)
    
    local aimHeader = aimlock.Instance:FindFirstChild("Header")
    if aimHeader then
        aimHeader.LayoutOrder = 1
        aimHeader.Parent = leftPanel
    end
    
    local aimSub = aimlock.Instance:FindFirstChild("SubFrame")
    if aimSub then
        aimSub.AutomaticSize = Enum.AutomaticSize.None
        aimSub.Size = UDim2.fromScale(1, 1)
        aimSub.Position = UDim2.fromOffset(0, 0)
        aimSub.Parent = rightPanel
    end
    
    if aimHeader and aimSub then
        setupMutex(aimHeader :: Frame, aimSub :: Frame)
        task.defer(function() updateArrowState(aimHeader :: Frame, false) end)
    end

    -- Extração e Montagem do Silent Aim
    local silentAim = SilentAimModule.new()
    maid:GiveTask(silentAim)

    local silentHeader = silentAim.Instance:FindFirstChild("Header")
    if silentHeader then
        silentHeader.LayoutOrder = 2
        silentHeader.Parent = leftPanel
    end
    
    local silentSub = silentAim.Instance:FindFirstChild("SubFrame")
    if silentSub then
        silentSub.AutomaticSize = Enum.AutomaticSize.None
        silentSub.Size = UDim2.fromScale(1, 1)
        silentSub.Position = UDim2.fromOffset(0, 0)
        silentSub.Parent = rightPanel
    end
    
    if silentHeader and silentSub then
        setupMutex(silentHeader :: Frame, silentSub :: Frame)
        task.defer(function() updateArrowState(silentHeader :: Frame, false) end)
    end

    maid:GiveTask(container)

    local self = {}
    self.Instance = container

    function self:Destroy()
        maid:Destroy()
    end

    return self
end

return CombatModuleFactory
