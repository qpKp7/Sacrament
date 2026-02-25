--!strict
local TweenService = game:GetService("TweenService")

local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type AnimationUI = {
    Instance: Frame,
    Value: string,
    OnChanged: RBXScriptSignal,
    Destroy: (self: AnimationUI) -> ()
}

local AnimationFactory = {}

local COLOR_WHITE = Color3.fromHex("FFFFFF")
local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local COLOR_ACCENT = Color3.fromHex("C80000")
local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_STROKE = Color3.fromHex("333333")
local FONT_MAIN = Enum.Font.GothamBold

local OPTIONS = {
    { name = "None", id = "" },
    { name = "Vampire", id = "rbxassetid://1113743239" },
    { name = "Ninja", id = "rbxassetid://754639239" },
    { name = "Mage", id = "rbxassetid://658833139" },
    { name = "Toy", id = "rbxassetid://973773170" }
}

function AnimationFactory.new(layoutOrder: number?): AnimationUI
    local maid = Maid.new()
    local self = {}
    self.Value = OPTIONS[1].id
    
    local changedEvent = Instance.new("BindableEvent")
    maid:GiveTask(changedEvent)
    self.OnChanged = changedEvent.Event
    
    local container = Instance.new("Frame")
    container.Name = "AnimationSection"
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 1
    container.ClipsDescendants = true
    container.AutomaticSize = Enum.AutomaticSize.Y
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundTransparency = 1
    header.LayoutOrder = 1
    header.Parent = container

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "Animation"
    title.TextColor3 = COLOR_LABEL
    title.Font = FONT_MAIN
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local selectorBtn = Instance.new("TextButton")
    selectorBtn.Size = UDim2.new(0, 130, 0, 28)
    selectorBtn.AnchorPoint = Vector2.new(1, 0.5)
    selectorBtn.Position = UDim2.new(1, 0, 0.5, 0)
    selectorBtn.BackgroundColor3 = COLOR_BG
    selectorBtn.Text = ""
    selectorBtn.AutoButtonColor = false
    selectorBtn.Parent = header
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = selectorBtn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLOR_STROKE
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = selectorBtn
    
    local selectorText = Instance.new("TextLabel")
    selectorText.Size = UDim2.new(1, -25, 1, 0)
    selectorText.Position = UDim2.fromOffset(10, 0)
    selectorText.BackgroundTransparency = 1
    selectorText.Text = OPTIONS[1].name
    selectorText.TextColor3 = COLOR_WHITE
    selectorText.Font = FONT_MAIN
    selectorText.TextSize = 14
    selectorText.TextXAlignment = Enum.TextXAlignment.Left
    selectorText.Parent = selectorBtn
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -25, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = ">"
    arrow.TextColor3 = COLOR_WHITE
    arrow.Font = FONT_MAIN
    arrow.TextSize = 14
    arrow.Rotation = 0
    arrow.Parent = selectorBtn
    
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Name = "OptionsFrame"
    optionsFrame.Size = UDim2.new(1, 0, 0, 0)
    optionsFrame.BackgroundTransparency = 1
    optionsFrame.Visible = false
    optionsFrame.LayoutOrder = 2
    optionsFrame.AutomaticSize = Enum.AutomaticSize.Y
    optionsFrame.Parent = container
    
    local optLayout = Instance.new("UIListLayout")
    optLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optLayout.Parent = optionsFrame
    
    local optPad = Instance.new("UIPadding")
    optPad.PaddingLeft = UDim.new(1, -155)
    optPad.PaddingRight = UDim.new(0, 25)
    optPad.PaddingBottom = UDim.new(0, 10)
    optPad.Parent = optionsFrame
    
    local isOpen = false
    local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    local function toggleDropdown()
        isOpen = not isOpen
        optionsFrame.Visible = isOpen
        
        TweenService:Create(arrow, TWEEN_INFO, {
            Rotation = isOpen and 90 or 0,
            TextColor3 = isOpen and COLOR_ACCENT or COLOR_WHITE
        }):Play()
        
        TweenService:Create(stroke, TWEEN_INFO, {
            Color = isOpen and COLOR_ACCENT or COLOR_STROKE
        }):Play()
    end
    
    maid:GiveTask(selectorBtn.Activated:Connect(toggleDropdown))
    
    for i, opt in ipairs(OPTIONS) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 28)
        optBtn.BackgroundColor3 = COLOR_BG
        optBtn.BackgroundTransparency = 1
        optBtn.Text = " " .. opt.name
        optBtn.TextColor3 = (i == 1) and COLOR_ACCENT or COLOR_LABEL
        optBtn.Font = FONT_MAIN
        optBtn.TextSize = 14
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.LayoutOrder = i
        optBtn.Parent = optionsFrame
        
        maid:GiveTask(optBtn.MouseEnter:Connect(function()
            optBtn.BackgroundTransparency = 0
            optBtn.TextColor3 = COLOR_WHITE
        end))
        
        maid:GiveTask(optBtn.MouseLeave:Connect(function()
            optBtn.BackgroundTransparency = 1
            optBtn.TextColor3 = (self.Value == opt.id) and COLOR_ACCENT or COLOR_LABEL
        end))
        
        maid:GiveTask(optBtn.Activated:Connect(function()
            self.Value = opt.id
            selectorText.Text = opt.name
            changedEvent:Fire(opt.id, opt.name)
            
            for _, child in ipairs(optionsFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child.TextColor3 = (child.Text == " " .. opt.name) and COLOR_ACCENT or COLOR_LABEL
                end
            end
            
            toggleDropdown()
        end))
    end
    
    maid:GiveTask(container)
    self.Instance = container
    
    function self:Destroy()
        maid:Destroy()
    end
    
    return self :: AnimationUI
end

return AnimationFactory
