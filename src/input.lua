-- src/input.lua
-- Sacrament Input Module - Sistema de detecção de teclas (E/Q/Insert)
-- Detecta toggles para Aimlock, Silent Aim e GUI Visibility
-- Compatível com config_defaults.lua (binds customizáveis)

local UserInputService = game:GetService("UserInputService")

local Input = {}

-- Estados compartilhados com a GUI e outros módulos
Input.States = {
    AimlockEnabled   = false,
    SilentAimEnabled = false,
    GuiVisible       = false,
}

-- Variáveis internas
local Config = nil
local lastToggleTime = 0
local DEBOUNCE_TIME = 0.15  -- segundos para evitar spam de toggle

-- ================================================
-- Inicializa o módulo de input
-- Parâmetro: config table (de config_defaults.lua)
-- ================================================
function Input:Init(loadedConfig)
    if not loadedConfig then
        warn("[Input] Configuração não fornecida - usando defaults")
        Config = {
            AimlockKey   = Enum.KeyCode.E,
            SilentAimKey = Enum.KeyCode.Q,
            GuiToggleKey = Enum.KeyCode.Insert,
        }
    else
        -- Suporta tanto .Current quanto .Defaults
        local cfg = loadedConfig.Current or loadedConfig.Defaults or loadedConfig
        Config = {
            AimlockKey   = cfg.AimlockKey   or Enum.KeyCode.E,
            SilentAimKey = cfg.SilentAimKey or Enum.KeyCode.Q,
            GuiToggleKey = cfg.GuiToggleKey or Enum.KeyCode.Insert,
        }
    end

    -- Conexão principal de input
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end  -- ignora se estiver digitando em chat/box/etc

        local now = tick()
        if now - lastToggleTime < DEBOUNCE_TIME then return end
        lastToggleTime = now

        local key = input.KeyCode

        if key == Config.AimlockKey then
            Input.States.AimlockEnabled = not Input.States.AimlockEnabled
            print("[Input] Aimlock Toggle: " .. (Input.States.AimlockEnabled and "ON" or "OFF"))
        end

        if key == Config.SilentAimKey then
            Input.States.SilentAimEnabled = not Input.States.SilentAimEnabled
            print("[Input] Silent Aim Toggle: " .. (Input.States.SilentAimEnabled and "ON" or "OFF"))
        end

        if key == Config.GuiToggleKey then
            Input.States.GuiVisible = not Input.States.GuiVisible
            print("[Input] GUI Visibility: " .. (Input.States.GuiVisible and "ON" or "OFF"))
        end
    end)

    print("[Input] Inicializado com sucesso")
    print("  → Aimlock   : " .. tostring(Config.AimlockKey.Name))
    print("  → Silent Aim: " .. tostring(Config.SilentAimKey.Name))
    print("  → Toggle GUI: " .. tostring(Config.GuiToggleKey.Name))
end

-- Função opcional para resetar estados (útil em cleanup ou reload)
function Input:Reset()
    Input.States.AimlockEnabled   = false
    Input.States.SilentAimEnabled = false
    Input.States.GuiVisible       = false
    print("[Input] Estados resetados")
end

return Input
