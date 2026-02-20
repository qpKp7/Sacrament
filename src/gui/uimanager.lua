--!strict
local Import = (_G :: any).SacramentImport
local UIState = Import("state/uistate")
local Maid = Import("utils/maid")
local MainFrameModule = Import("gui/components/mainframe")

local UIManager = {}
local uiMaid = Maid.new()

function UIManager.Init(adapter: any?)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SacramentUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Enabled = UIState.IsVisible
    uiMaid:GiveTask(screenGui)

    local mainFrame = MainFrameModule.new()
    mainFrame.Instance.Parent = screenGui
    uiMaid:GiveTask(mainFrame)

    if adapter and adapter.mountGui then
        adapter.mountGui(screenGui)
    else
        local player = game:GetService("Players").LocalPlayer
        if player then
            screenGui.Parent = player:WaitForChild("PlayerGui")
        end
    end

    uiMaid:GiveTask(UIState.VisibilityChanged:Connect(function(isVisible: boolean)
        screenGui.Enabled = isVisible
    end))
end

function UIManager.Destroy()
    uiMaid:DoCleaning()
end

return UIManager
