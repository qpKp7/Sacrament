--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sacrament = ReplicatedStorage:WaitForChild("Sacrament")
local Maid = require(Sacrament.src.utils.maid)
local Components = Sacrament.src.gui.components
local ToggleButton = require(Components.togglebutton)

local Aimlock = {}
Aimlock.__index = Aimlock

function Aimlock.new(parent: GuiObject)
    local self = setmetatable({}, Aimlock)
    self._maid = Maid.new()

    self.Header = self._maid:GiveTask(Instance.new("Frame"))
    self.Header.Name = "AimlockHeader"
    self.Header.Size = UDim2.new(1, 0, 0, 30)
    self.Header.BackgroundTransparency = 1
    self.Header.Parent = parent

    self.Title = self._maid:GiveTask(Instance.new("TextLabel"))
    self.Title.Name = "Title"
    self.Title.Text = "Aimlock"
    self.Title.Font = Enum.Font.GothamBold
    self.Title.TextSize = 14
    self.Title.TextColor3 = Color3.fromRGB(210, 210, 210)
    self.Title.BackgroundTransparency = 1
    self.Title.Position = UDim2.new(0, 0, 0, 0)
    self.Title.Size = UDim2.new(0, 0, 1, 0)
    self.Title.AutomaticSize = Enum.AutomaticSize.X
    self.Title.Parent = self.Header

    self.Controls = self._maid:GiveTask(Instance.new("Frame"))
    self.Controls.Name = "Controls"
    self.Controls.AnchorPoint = Vector2.new(1, 0.5)
    self.Controls.Position = UDim2.new(1, 0, 0.5, 0)
    self.Controls.Size = UDim2.new(0, 60, 1, 0)
    self.Controls.BackgroundTransparency = 1
    self.Controls.Parent = self.Header

    local controlsLayout = self._maid:GiveTask(Instance.new("UIListLayout"))
    controlsLayout.FillDirection = Enum.FillDirection.Horizontal
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    controlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    controlsLayout.Padding = UDim.new(0, 15)
    controlsLayout.Parent = self.Controls

    self.Toggle = self._maid:GiveTask(ToggleButton.new({
        Parent = self.Controls
    }))
    
    if self.Toggle.Instance then
        self.Toggle.Instance.LayoutOrder = 1
    end

    self.Arrow = self._maid:GiveTask(Instance.new("TextLabel"))
    self.Arrow.Name = "Arrow"
    self.Arrow.Text = "v"
    self.Arrow.TextColor3 = Color3.fromRGB(220, 30, 30)
    self.Arrow.Font = Enum.Font.GothamBold
    self.Arrow.TextSize = 12
    self.Arrow.BackgroundTransparency = 1
    self.Arrow.Size = UDim2.new(0, 10, 1, 0)
    self.Arrow.LayoutOrder = 2
    self.Arrow.Parent = self.Controls

    self.GlowBar = self._maid:GiveTask(Instance.new("Frame"))
    self.GlowBar.Name = "GlowBar"
    self.GlowBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    self.GlowBar.BorderSizePixel = 0
    self.GlowBar.AnchorPoint = Vector2.new(0, 0.5)
    self.GlowBar.Parent = self.Header

    local function updateLayout()
        if not self.Header.Parent then return end
        if not self.Toggle.Instance then return end

        local headerX = self.Header.AbsolutePosition.X
        local titleEnd = self.Title.AbsolutePosition.X + self.Title.AbsoluteSize.X
        local toggleStart = self.Toggle.Instance.AbsolutePosition.X

        local startX = (titleEnd + 5) - headerX
        local endX = (toggleStart - 5) - headerX
        local width = endX - startX

        if width > 0 then
            self.GlowBar.Visible = true
            self.GlowBar.Position = UDim2.new(0, startX, 0.5, 0)
            self.GlowBar.Size = UDim2.new(0, width, 0, 1)
        else
            self.GlowBar.Visible = false
            self.GlowBar.Size = UDim2.new(0, 0, 0, 1)
        end
    end

    self._maid:GiveTask(self.Title:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateLayout))
    self._maid:GiveTask(self.Title:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLayout))
    self._maid:GiveTask(self.Toggle.Instance:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateLayout))
    self._maid:GiveTask(self.Header:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateLayout))
    self._maid:GiveTask(self.Header:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLayout))

    task.defer(updateLayout)
    
    for i = 1, 5 do
        task.delay(i * 0.05, updateLayout)
    end

    return self
end

function Aimlock:Destroy()
    self._maid:Destroy()
end

return Aimlock
