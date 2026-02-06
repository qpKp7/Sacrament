-- src/input.lua
-- Sacrament Input Module - Sistema de detecção de teclas (E/Q)
-- Detecta toggles apenas para Aimlock e Silent Aim
-- Toggle da GUI agora gerenciado no loader ou gui/init.lua

local UserInputService = game:GetService("UserInputService")

local Input = {}

-- Estados compartilhados (GUI Visible removido daqui)
Input.States = {
    AimlockEnabled   = false,
    SilentAimEnabled = false,
    -- GuiVisible removido - agora controlado pela GUI diretamente
}

-- Variáveis internas
local Config = nil
local lastToggleTime = 0
local DEBOUNCE_TIME = 0.15  -- segundos para evitar spam

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
            -- GuiToggleKey removido daqui
        }
    else
        local cfg = loadedConfig.Current or loadedConfig.Defaults or loadedConfig
        Config = {
            AimlockKey   = cfg.AimlockKey   or Enum.KeyCode.E,
            SilentAimKey = cfg.SilentAimKey or Enum.KeyCode.Q,
        }
    end

    -- Conexão principal de input (só E e Q agora)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

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
    end)

    print("[Input] Inicializado com sucesso")
    print("  → Aimlock   : " .. tostring(Config.AimlockKey.Name))
    print("  → Silent Aim: " .. tostring(Config.SilentAimKey.Name))
    -- print de GuiToggleKey removido
end

-- Função opcional para resetar estados
function Input:Reset()
    Input.States.AimlockEnabled   = false
    Input.States.SilentAimEnabled = false
    print("[Input] Estados resetados")
end

return Input
