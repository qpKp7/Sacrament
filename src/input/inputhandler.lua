--!strict
local UserInputService = game:GetService("UserInputService")
local UIState = require(script.Parent.Parent.state.UIState)
local Constants = require(script.Parent.Parent.config.Constants)
local Maid = require(script.Parent.Parent.utils.Maid)

local InputHandler = {}
local handlerMaid = Maid.new()

function InputHandler.Init()
    handlerMaid:GiveTask(UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
        if not gameProcessed and input.KeyCode == Constants.TOGGLE_KEY then
            UIState.ToggleVisibility()
        end
    end))
end

function InputHandler.Destroy()
    handlerMaid:DoCleaning()
end

return InputHandler
