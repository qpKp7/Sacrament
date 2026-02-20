--!strict

export type Adapter = {
	mountGui: (gui: ScreenGui) -> (),
	connectInputBegan: (callback: (input: InputObject, gameProcessed: boolean) -> ()) -> RBXScriptConnection,
	getViewportSize: (() -> Vector2)?,
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Loader = {}

local booted = false

local function createAdapter(): Adapter
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui

	return {
		mountGui = function(gui: ScreenGui)
			gui.Parent = playerGui
		end,

		connectInputBegan = function(callback)
			return UserInputService.InputBegan:Connect(callback)
		end,

		getViewportSize = function(): Vector2
			local cam = workspace.CurrentCamera
			if cam then
				return cam.ViewportSize
			end
			return Vector2.new(0, 0)
		end,
	}
end

function Loader:Init()
	if booted then
		return
	end
	booted = true

	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui

	if playerGui:GetAttribute("SacramentBootstrapped") == true then
		return
	end
	playerGui:SetAttribute("SacramentBootstrapped", true)

	local root = ReplicatedStorage:WaitForChild("Sacrament")
	local app = require(root:WaitForChild("config"):WaitForChild("app"))
	(app :: any).start(createAdapter())
end

return Loader
