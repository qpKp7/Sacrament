--!strict
local Players = game:GetService("Players")
local UIState = require(script.Parent.Parent.state.UIState)
local Maid = require(script.Parent.Parent.utils.Maid)
local MainFrameModule = require(script.Parent.components.MainFrame)

local UIManager = {}
local uiMaid = Maid.new()

function UIManager.Init()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SacramentUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Enabled = UIState.IsVisible
    screenGui.Parent = playerGui
    uiMaid:GiveTask(screenGui)

    local mainFrame = MainFrameModule.new()
    mainFrame.Instance.Parent = screenGui
    uiMaid:GiveTask(mainFrame)

    uiMaid:GiveTask(UIState.VisibilityChanged:Connect(function(isVisible: boolean)
        screenGui.Enabled = isVisible
    end))
end

function UIManager.Destroy()
    uiMaid:DoCleaning()
end

return UIManager
