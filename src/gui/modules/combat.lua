--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")
local AimlockModule = Import("gui/modules/combat/aimlock")
local SilentAimModule = Import("gui/modules/combat/silentaim")

export type CombatModule = {
    Instance: Frame,
    Destroy: (self: CombatModule) -> ()
}

local CombatModuleFactory = {}

function CombatModuleFactory.new(): CombatModule
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "CombatContainer"
    container.Size = UDim2.fromScale(1, 1)
    container.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    container.BorderSizePixel = 0
    container.ClipsDescendants = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 18)
    corner.Parent = container

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

    local rightPanel = Instance.new("Frame")
    rightPanel.Name = "RightPanel"
    rightPanel.Size = UDim2.new(1, -280, 1, 0)
    rightPanel.Position = UDim2.fromOffset(280, 0)
    rightPanel.BackgroundTransparency = 1
    rightPanel.BorderSizePixel = 0
    rightPanel.Parent = container

    local openSubframe: Frame? = nil
    local openHeader: Frame? = nil

    local function updateArrowText(header: Frame, text: string)
        local controls = header:FindFirstChild("Controls")
        if controls then
            for _, desc in ipairs(controls:GetDescendants()) do
                if desc:IsA("TextButton") and (desc.Text == "v" or desc.Text == ">" or desc.Text == "V") then
                    desc.Text = text
                    break
                end
            end
        end
    end

    local function setupMutex(header: Frame, subFrame: Frame)
        maid:GiveTask(subFrame:GetPropertyChangedSignal("Visible"):Connect(function()
            if subFrame.Visible then
                if openSubframe and openSubframe ~= subFrame then
                    local prevSub = openSubframe
                    local prevHeader = openHeader
                    
                    prevSub.Visible = false
                    if prevHeader then
                        updateArrowText(prevHeader, ">")
                    end
                end
                
                openSubframe = subFrame
                openHeader = header
                updateArrowText(header, "v")
            else
                if openSubframe == subFrame then
                    openSubframe = nil
                    openHeader = nil
                    updateArrowText(header, ">")
                end
            end
        end))
    end

    local aimlock = AimlockModule.new()
    maid:GiveTask(aimlock)
    
    local aimHeader = aimlock.Instance:FindFirstChild("Header")
    local aimSub = aimlock.Instance:FindFirstChild("SubFrame")
    if aimHeader and aimSub then
        aimHeader.LayoutOrder = 1
        aimHeader.Parent = leftPanel
        
        aimSub.AutomaticSize = Enum.AutomaticSize.None
        aimSub.Size = UDim2.fromScale(1, 1)
        aimSub.Position = UDim2.fromOffset(0, 0)
        aimSub.Parent = rightPanel
        
        setupMutex(aimHeader :: Frame, aimSub :: Frame)
    end

    local silentAim = SilentAimModule.new()
    maid:GiveTask(silentAim)

    local silentHeader = silentAim.Instance:FindFirstChild("Header")
    local silentSub = silentAim.Instance:FindFirstChild("SubFrame")
    if silentHeader and silentSub then
        silentHeader.LayoutOrder = 2
        silentHeader.Parent = leftPanel
        
        silentSub.AutomaticSize = Enum.AutomaticSize.None
        silentSub.Size = UDim2.fromScale(1, 1)
        silentSub.Position = UDim2.fromOffset(0, 0)
        silentSub.Parent = rightPanel
        
        setupMutex(silentHeader :: Frame, silentSub :: Frame)
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
