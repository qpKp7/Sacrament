--!strict
local UserInputService = game:GetService("UserInputService")
local UIState = require(script.Parent.Parent.state.uistate)
local Constants = require(script.Parent.Parent.config.constants)
local Maid = require(script.Parent.Parent.utils.maid)

local InputHandler = {}
local handlerMaid = Maid.new()

function InputHandler.Init(adapter: any?)
    if adapter and adapter.connectInputBegan then
        handlerMaid:GiveTask(adapter.connectInputBegan(function(input: InputObject, gameProcessed: boolean)
            if not gameProcessed and input.KeyCode == Constants.TOGGLE_KEY then
                UIState.ToggleVisibility()
            end
        end))
    else
        handlerMaid:GiveTask(UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
            if not gameProcessed and input.KeyCode == Constants.TOGGLE_KEY then
                UIState.ToggleVisibility()
            end
        end))
    end
end

function InputHandler.Destroy()
    handlerMaid:DoCleaning()
end

return InputHandler
