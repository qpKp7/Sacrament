-- Sacrament - Input Module (UserInputService + fallback para teclas)

local UserInputService = game:GetService("UserInputService")

local Input = {}

-- Estado dos toggles (pode ser acessado de outros módulos)
Input.States = {
    AimlockEnabled = false,
    SilentAimEnabled = false,
    GuiVisible = false,
}

-- Referência ao config (carregado pelo loader)
local Config = nil

-- Função para inicializar (chamada pelo loader depois de carregar config)
function Input:Init(loadedConfig)
    Config = loadedConfig.Current or loadedConfig.Defaults
    
    -- Conecta aos binds do config
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end  -- ignora se for chat/UI do Roblox
        
        if input.KeyCode == Config.AimlockKey then
            Input.States.AimlockEnabled = not Input.States.AimlockEnabled
            print("[Sacrament Input] Aimlock toggled: " .. tostring(Input.States.AimlockEnabled))
        end
        
        if input.KeyCode == Config.SilentAimKey then
            Input.States.SilentAimEnabled = not Input.States.SilentAimEnabled
            print("[Sacrament Input] Silent Aim toggled: " .. tostring(Input.States.SilentAimEnabled))
        end
        
        if input.KeyCode == Config.GuiToggleKey then
            Input.States.GuiVisible = not Input.States.GuiVisible
            print("[Sacrament Input] GUI toggled: " .. tostring(Input.States.GuiVisible))
            -- Depois vamos mostrar/esconder a GUI aqui
        end
    end)
    
    print("[Sacrament Input] Input system inicializado.")
    print("Binds atuais: Aimlock = " .. tostring(Config.AimlockKey.Name) .. 
          " | Silent = " .. tostring(Config.SilentAimKey.Name) .. 
          " | GUI = " .. tostring(Config.GuiToggleKey.Name))
end

-- Exporta para global (opcional, útil para debug)
if getgenv then
    getgenv().SacramentInput = Input
end

return Input
