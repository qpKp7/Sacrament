--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function tryStart()
	local bootstrapperModule = ReplicatedStorage:FindFirstChild("SacramentGui_Bootstrapper")
	if bootstrapperModule and bootstrapperModule:IsA("ModuleScript") then
		local bootstrapper = require(bootstrapperModule)
		if type(bootstrapper) == "table" and type(bootstrapper.start) == "function" then
			bootstrapper.start()
			return true
		end
	end

	local root = ReplicatedStorage:FindFirstChild("SacramentGui")
	if root and root:IsA("Folder") then
		local candidate = root:FindFirstChild("bootstrapper")
		if candidate and candidate:IsA("ModuleScript") then
			local bootstrapper = require(candidate)
			if type(bootstrapper) == "table" and type(bootstrapper.start) == "function" then
				bootstrapper.start()
				return true
			end
		end
	end

	return false
end

tryStart()
