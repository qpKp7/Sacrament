-- Sacrament - Input Module (detecta teclas e toggles)

local UserInputService = game:GetService("UserInputService")

local Input = {}

Input.States = {
    AimlockEnabled = false,
    SilentAimEnabled = false,
    GuiVisible = false,
}

local Config = nil

function Input:Init(loadedConfig)
    Config = loadedConfig.Current or loadedConfig.Defaults

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end  -- ignora se for chat/UI do Roblox

        local key = input.KeyCode

        if key == Config.AimlockKey then
            Input.States.AimlockEnabled = not Input.States.AimlockEnabled
            print("[Input] Aimlock toggled: " .. (Input.States.AimlockEnabled and "ON" or "OFF"))
        end

        if key == Config.SilentAimKey then
            Input.States.SilentAimEnabled = not Input.States.SilentAimEnabled
            print("[Input] Silent Aim toggled: " .. (Input.States.SilentAimEnabled and "ON" or "OFF"))
        end

        if key == Config.GuiToggleKey then
            Input.States.GuiVisible = not Input.States.GuiVisible
            print("[Input] GUI toggled: " .. (Input.States.GuiVisible and "ON" or "OFF"))
        end
    end)

    print("[Input] Inicializado - teclas: E (Aimlock), Q (Silent Aim), Insert (GUI toggle)")
end

return Input
