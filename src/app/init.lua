--!strict
-- Arquivo: src/app/init.lua

local App = {}

function App.start(adapter)
    -- 1. Cria a Root GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SacramentRoot"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true

    -- 2. Cria o Frame Cinza de Teste
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.fromOffset(300, 200)
    mainFrame.Position = UDim2.fromScale(0.5, 0.5)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.fromScale(1, 1)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "Sacrament V5.0\n\nAperte [Q] para testar"
    textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 16
    textLabel.Parent = mainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    -- 3. Monta a GUI usando o Adapter
    adapter.mountGui(screenGui)

    -- 4. Conecta os Inputs
    adapter.connectInputBegan(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Q then
            print("[Sacrament] Input detectado: A tecla Q foi pressionada!")
        end
    end)
end

return App
