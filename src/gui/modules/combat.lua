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

local COLOR_ARROW_CLOSED = Color3.fromHex("CCCCCC")
local COLOR_ARROW_OPEN = Color3.fromHex("C80000")
local COLOR_GLOW = Color3.fromHex("FF3333")

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

    local function setupArrowAndMutex(header: Frame, subFrame: Frame)
        local arrowBtn: TextButton? = nil
        local controls = header:FindFirstChild("Controls")
        
        if controls then
            for _, desc in ipairs(controls:GetDescendants()) do
                if desc:IsA("TextButton") and (desc.Text == "v" or desc.Text == ">" or desc.Text == "<" or desc.Text == "V" or desc.Text == "^") then
                    arrowBtn = desc:Clone() :: TextButton
                    arrowBtn.Parent = desc.Parent
                    desc:Destroy()
                    break
                end
            end
        end

        if arrowBtn then
            local btn = arrowBtn :: TextButton
            btn.Text = ">"
            btn.TextColor3 = COLOR_ARROW_CLOSED

            local glowStroke = Instance.new("UIStroke")
            glowStroke.Color = COLOR_GLOW
            glowStroke.Thickness = 1.5
            glowStroke.Transparency = 1
            glowStroke.Parent = btn

            maid:GiveTask(btn.MouseButton1Click:Connect(function()
                subFrame.Visible = not subFrame.Visible
            end))

            maid:GiveTask(subFrame:GetPropertyChangedSignal("Visible"):Connect(function()
                local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                
                if subFrame.Visible then
                    if openSubframe and openSubframe ~= subFrame then
                        openSubframe.Visible = false
                    end
                    openSubframe = subFrame
                    
                    btn.Text = "v"
                    local tweenBtn = TweenService:Create(btn, tweenInfo, {TextColor3 = COLOR_ARROW_OPEN})
                    local tweenStroke = TweenService:Create(glowStroke, tweenInfo, {Transparency = 0.4})
                    
                    tweenBtn:Play()
                    tweenStroke:Play()
                    
                    local conn: RBXScriptConnection
                    conn = tweenBtn.Completed:Connect(function()
                        conn:Disconnect()
                        tweenBtn:Destroy()
                        tweenStroke:Destroy()
                    end)
                else
                    if openSubframe == subFrame then
                        openSubframe = nil
                    end
                    
                    btn.Text = ">"
                    local tweenBtn = TweenService:Create(btn, tweenInfo, {TextColor3 = COLOR_ARROW_CLOSED})
                    local tweenStroke = TweenService:Create(glowStroke, tweenInfo, {Transparency = 1})
                    
                    tweenBtn:Play()
                    tweenStroke:Play()
                    
                    local conn: RBXScriptConnection
                    conn = tweenBtn.Completed:Connect(function()
                        conn:Disconnect()
                        tweenBtn:Destroy()
                        tweenStroke:Destroy()
                    end)
                end
            end))
        end
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
        
        setupArrowAndMutex(aimHeader :: Frame, aimSub :: Frame)
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
        
        setupArrowAndMutex(silentHeader :: Frame, silentSub :: Frame)
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
