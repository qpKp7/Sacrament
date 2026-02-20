--!strict

export type Adapter = {
	mountGui: (screenGui: ScreenGui) -> (),
	connectInputBegan: (fn: (input: InputObject, gameProcessed: boolean) -> ()) -> RBXScriptConnection,
	getViewportSize: (() -> Vector2)?,
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Loader = {}

function Loader.start(): ()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui

	if playerGui:GetAttribute("SacramentBootstrapped") == true then
		return
	end
	playerGui:SetAttribute("SacramentBootstrapped", true)

	local root = ReplicatedStorage:WaitForChild("Sacrament")

	local adapter: Adapter = {
		mountGui = function(screenGui: ScreenGui)
			screenGui.Parent = playerGui
		end,

		connectInputBegan = function(fn: (input: InputObject, gameProcessed: boolean) -> ())
			return UserInputService.InputBegan:Connect(fn)
		end,

		getViewportSize = function(): Vector2
			local cam = workspace.CurrentCamera
			if cam then
				return cam.ViewportSize
			end
			return Vector2.new(0, 0)
		end,
	}

	local App = require(root:WaitForChild("config"):WaitForChild("app"))
	;(App :: any).start(adapter)
end

return Loader
