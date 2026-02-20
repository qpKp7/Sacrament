--!strict

-- Darkcode Runtime Loader v5.0
-- Carrega dinamicamente o módulo principal via rede (raw GitHub)
-- Expõe Sacrament com :Init() para compatibilidade com README
-- 100% teórico / offline-test friendly

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

export type Adapter = {
	mountGui: (gui: ScreenGui) -> (),
	connectInputBegan: (callback: (input: InputObject, gameProcessed: boolean) -> ()) -> RBXScriptConnection,
	getViewportSize: () -> Vector2,
	-- extensível no futuro: getMouse, getCamera, etc.
}

local REMOTE_INIT_URL = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/src/app/init.lua"

local Sacrament = {}
Sacrament.__index = Sacrament

local function createMinimalAdapter(): Adapter
	local player = Players.LocalPlayer
	local playerGui: PlayerGui = player:WaitForChild("PlayerGui") :: PlayerGui

	return {
		mountGui = function(gui: ScreenGui)
			gui.Parent = playerGui
			-- futuro: ResetOnSpawn = false, etc. se desejado
		end,

		connectInputBegan = function(callback)
			return UserInputService.InputBegan:Connect(callback)
		end,

		getViewportSize = function(): Vector2
			local cam = workspace.CurrentCamera
			return if cam then cam.ViewportSize else Vector2.zero
		end,
	}
end

function Sacrament.new()
	local self = setmetatable({}, Sacrament)
	self._booted = false
	self._initModule = nil
	return self
end

function Sacrament:Init()
	if self._booted then
		warn("[Sacrament] Já inicializado. Chamada ignorada.")
		return
	end

	self._booted = true

	local success, result = pcall(function()
		local code = game:HttpGet(REMOTE_INIT_URL, true)
		local fn, err = loadstring(code, "Sacrament@init.lua")
		if not fn then
			error("Falha ao compilar init.lua remoto: " .. tostring(err))
		end
		self._initModule = fn() -- executa e obtém o módulo exportado
	end)

	if not success then
		warn("[Sacrament] Falha crítica no bootstrap remoto:\n" .. tostring(result))
		-- fallback opcional: carregar versão local estática se existir
		return
	end

	if typeof(self._initModule) ~= "table" or typeof(self._initModule.start) ~= "function" then
		error("[Sacrament] Módulo remoto não exportou tabela com método .start(adapter)")
	end

	local adapter = createMinimalAdapter()
	self._initModule.start(adapter)

	print("[Sacrament] Bootstrap remoto concluído com sucesso.")
end

-- API de compatibilidade com README
return Sacrament.new()
