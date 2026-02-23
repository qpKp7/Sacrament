--!strict
local Sacrament = {}

export type Adapter = {
	mountGui: (gui: ScreenGui) -> (),
	connectInputBegan: (callback: (InputObject, boolean) -> ()) -> RBXScriptConnection,
	getViewportSize: () -> Vector2,
}

local function ensureRuntimeScriptStub(): Instance
	local existing = (_G :: any).__SacramentScriptStub
	if typeof(existing) == "Instance" then
		(_G :: any).script = existing
		return existing
	end

	local okCore, CoreGui = pcall(function()
		return game:GetService("CoreGui")
	end)

	local rootParent: Instance = if okCore and CoreGui then CoreGui else game

	local runtimeRoot = Instance.new("Folder")
	runtimeRoot.Name = "SacramentRuntime"
	runtimeRoot.Parent = rootParent

	local stub = Instance.new("Folder")
	stub.Name = "script"
	stub.Parent = runtimeRoot

	(_G :: any).__SacramentRuntimeRoot = runtimeRoot
	(_G :: any).__SacramentScriptStub = stub
	(_G :: any).script = stub

	return stub
end

local function execModuleWithTrace(path: string, chunk: () -> any): any
	local ok, result = xpcall(chunk, function(err)
		return ("[Sacrament] Erro ao executar módulo: %s\n%s"):format(path, debug.traceback(tostring(err), 2))
	end)
	if not ok then
		error(result, 0)
	end
	return result
end

function Sacrament:Init()
	if (_G :: any).SacramentBooted then
		warn("[Sacrament] Já inicializado.\nExecução abortada.")
		return
	end

	ensureRuntimeScriptStub()

	local cacheBuster = tostring(os.time())
	local baseUrl = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/src/"
	local moduleCache: { [string]: any } = {}

	(_G :: any).SacramentImport = function(path: string): any
		if moduleCache[path] ~= nil then
			return moduleCache[path]
		end

		ensureRuntimeScriptStub()

		local url = baseUrl .. path .. ".lua?cb=" .. cacheBuster
		local okGet, response = pcall(function()
			return (game :: any):HttpGet(url, true)
		end)

		if not okGet or type(response) ~= "string" then
			error("[Sacrament] Falha de rede ao carregar módulo: " .. path, 2)
		end

		local loadFn = loadstring(response)
		if type(loadFn) ~= "function" then
			error("[Sacrament] Erro de sintaxe no módulo remoto: " .. path, 2)
		end

		local result = execModuleWithTrace(path, loadFn :: any)
		moduleCache[path] = result
		return result
	end

	local Import = (_G :: any).SacramentImport
	local App = Import("app/init")

	local adapter: Adapter = {
		mountGui = function(gui: ScreenGui)
			local okCore, CoreGui = pcall(function()
				return game:GetService("CoreGui")
			end)

			if okCore and CoreGui then
				gui.Parent = CoreGui
			else
				local Players = game:GetService("Players")
				local player = Players.LocalPlayer
				if player then
					local playerGui = player:FindFirstChild("PlayerGui")
					if playerGui then
						gui.Parent = playerGui
					end
				end
			end
		end,

		connectInputBegan = function(callback: (InputObject, boolean) -> ()): RBXScriptConnection
			local UserInputService = game:GetService("UserInputService")
			return UserInputService.InputBegan:Connect(callback)
		end,

		getViewportSize = function(): Vector2
			local camera = game:GetService("Workspace").CurrentCamera
			return if camera then camera.ViewportSize else Vector2.new(1920, 1080)
		end,
	}

	local startOk, startErr = pcall(function()
		if type((App :: any).start) == "function" then
			;(App :: any).start(adapter)
		elseif type((App :: any).Start) == "function" then
			;(App :: any).Start(adapter)
		else
			error("Método Start não encontrado em App.")
		end
	end)

	if not startOk then
		warn("[Sacrament] Erro durante a inicialização: " .. tostring(startErr))
		return
	end

	(_G :: any).SacramentBooted = true
	print("[Sacrament] Inicializado com sucesso.")
end

return Sacrament
