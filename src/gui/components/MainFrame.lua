--!strict
local UserInputService = game:GetService("UserInputService")
local Constants = require(script.Parent.Parent.Parent.config.Constants)
local Colors = require(script.Parent.Parent.Parent.themes.Colors)
local Maid = require(script.Parent.Parent.Parent.utils.Maid)
local SidebarModule = require(script.Parent.Sidebar)
local ContentAreaModule = require(script.Parent.ContentArea)

export type MainFrame = {
    Instance: Frame,
    Destroy: (self: MainFrame) -> ()
}

local MainFrameModule = {}

function MainFrameModule.new(): MainFrame
    local maid = Maid.new()

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.fromScale(0.38, 0.42)
    mainFrame.Position = UDim2.fromScale(0.31, 0.29)
    mainFrame.BackgroundTransparency = 1
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = false

    local sidebar = SidebarModule.new()
    sidebar.Instance.Parent = mainFrame
    maid:GiveTask(sidebar)

    local verticalDivider = Instance.new("Frame")
    verticalDivider.Name = "VerticalDivider"
    verticalDivider.Size = UDim2.new(0, 2, 1, 0)
    verticalDivider.Position = UDim2.new(Constants.SIDEBAR_WIDTH, 0, 0, 0)
    verticalDivider.BackgroundColor3 = Colors.Divider
    verticalDivider.BorderSizePixel = 0
    verticalDivider.Active = false
    verticalDivider.Parent = mainFrame

    local contentArea = ContentAreaModule.new()
    contentArea.Instance.Parent = mainFrame
    maid:GiveTask(contentArea)

    local dragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()

    maid:GiveTask(UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
        if gameProcessed then return end
        local parentGui = mainFrame.Parent :: ScreenGui
        if not parentGui or not parentGui.Enabled then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local mPos = input.Position
            local absPos = mainFrame.AbsolutePosition
            local absSize = mainFrame.AbsoluteSize
            
            if mPos.X >= absPos.X and mPos.X <= absPos.X + absSize.X and
               mPos.Y >= absPos.Y and mPos.Y <= absPos.Y + absSize.Y then
                dragging = true
                dragStart = Vector2.new(mPos.X, mPos.Y)
                startPos = mainFrame.Position
            end
        end
    end))

    maid:GiveTask(UserInputService.InputChanged:Connect(function(input: InputObject)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end))

    maid:GiveTask(UserInputService.InputEnded:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    local self = {}
    self.Instance = mainFrame

    function self:Destroy()
        maid:Destroy()
        mainFrame:Destroy()
    end

    return self
end

return MainFrameModule
