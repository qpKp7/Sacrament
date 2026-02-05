-- Sacrament - GUI Module (dark theme aprimorado, arrastável) - v0.2

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Gui = {}
local ScreenGui = nil
local Frame = nil
local Labels = {}
local Dragging = false
local DragStart = nil
local StartPos = nil

local function createGui()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local coreGui = game:GetService("CoreGui")
    
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SacramentStatus"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Enabled = false
    
    -- Parent: CoreGui preferencial, fallback PlayerGui
    local parentSuccess = pcall(function()
        ScreenGui.Parent = coreGui
    end)
    if not parentSuccess then
        warn("[GUI] CoreGui falhou, usando PlayerGui")
        ScreenGui.Parent = playerGui
    end
    
    Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 260, 0, 220)  -- maior pra mais espaço
    Frame.Position = UDim2.new(0.5, -130, 0.4, -110)  -- um pouco mais alto
    Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = ScreenGui
    
    -- Gradiente fundo sutil
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 12))
    }
    gradient.Rotation = 90
    gradient.Parent = Frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = Frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(50, 50, 50)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.4
    stroke.Parent = Frame
    
    -- Shadow (simulada com outro frame)
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 12, 1, 12)
    shadow.Position = UDim2.new(0, -6, 0, -6)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.7
    shadow.ZIndex = -1
    shadow.Parent = Frame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 12)
    shadowCorner.Parent = shadow
    
    -- Título bar (arrastável)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = Frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "Sacrament v0.2"
    title.TextColor3 = Color3.fromRGB(200, 200, 255)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = titleBar
    
    -- Botão Close (X)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -34, 0, 3)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        if ScreenGui then ScreenGui.Enabled = false end
    end)
    
    -- Conteúdo principal
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, -36)
    contentFrame.Position = UDim2.new(0, 0, 0, 36)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = Frame
    
    local yOffset = 10
    for _, name in ipairs({"Aimlock", "Silent Aim"}) do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 28)
        label.Position = UDim2.new(0, 10, 0, yOffset)
        label.BackgroundTransparency = 1
        label.Text = name .. ": OFF"
        label.TextColor3 = Color3.fromRGB(180, 180, 180)
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 15
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = contentFrame
        
        Labels[name] = label
        yOffset = yOffset + 32
    end
    
    -- Status extra: Target Name + Distância
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(1, -20, 0, 28)
    targetLabel.Position = UDim2.new(0, 10, 0, yOffset)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "Target: Nenhum"
    targetLabel.TextColor3 = Color3.fromRGB(120, 220, 255)
    targetLabel.Font = Enum.Font.Gotham
    targetLabel.TextSize = 14
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.Parent = contentFrame
    Labels["Target"] = targetLabel
    
    yOffset = yOffset + 32
    
    -- FPS simples (opcional, pra debug)
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(1, -20, 0, 20)
    fpsLabel.Position = UDim2.new(0, 10, 1, -30)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: --"
    fpsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    fpsLabel.Font = Enum.Font.Gotham
    fpsLabel.TextSize = 12
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    fpsLabel.Parent = contentFrame
    Labels["FPS"] = fpsLabel
    
    print("[GUI] Janela aprimorada criada")
    return ScreenGui
end

-- Função de drag
local function startDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = Frame.Position
    end
end

local function updateDrag(input)
    if Dragging then
        local delta = input.Position - DragStart
        Frame.Position = UDim2.new(
            StartPos.X.Scale,
            StartPos.X.Offset + delta.X,
            StartPos.Y.Scale,
            StartPos.Y.Offset + delta.Y
        )
    end
end

local function stopDrag(input)
    Dragging = false
end

function Gui:Init(inputModule)
    local states = inputModule.States
    if not states then
        warn("[GUI] States não encontrados")
        return
    end
    
    ScreenGui = createGui()
    ScreenGui.Enabled = states.GuiVisible
    
    -- Drag no title bar
    local titleBar = Frame:FindFirstChildWhichIsA("Frame")  -- o titleBar
    if titleBar then
        titleBar.InputBegan:Connect(startDrag)
        titleBar.InputChanged:Connect(updateDrag)
        titleBar.InputEnded:Connect(stopDrag)
        
        -- Suporte touch/mobile
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                updateDrag(input)
            end
        end)
    end
    
    local oldGuiVisible = states.GuiVisible
    
    RunService.RenderStepped:Connect(function(delta)
        if not ScreenGui or not Frame or not Frame.Parent then return end
        
        -- Atualiza toggles
        Labels["Aimlock"].Text = "Aimlock: " .. (states.AimlockEnabled and "ON" or "OFF")
        Labels["Aimlock"].TextColor3 = states.AimlockEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 80, 80)
        
        Labels["Silent Aim"].Text = "Silent Aim: " .. (states.SilentAimEnabled and "ON" or "OFF")
        Labels["Silent Aim"].TextColor3 = states.SilentAimEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 80, 80)
        
        -- FPS
        local fps = math.floor(1 / delta + 0.5)
        Labels["FPS"].Text = "FPS: " .. fps
        
        -- Visibility sync
        if states.GuiVisible ~= oldGuiVisible then
            ScreenGui.Enabled = states.GuiVisible
            oldGuiVisible = states.GuiVisible
            print("[GUI] Visibility: " .. (states.GuiVisible and "ON" or "OFF"))
        end
    end)
    
    print("[GUI] Inicializado - arrastável + aprimorada")
end

function Gui:Toggle(visible)
    if ScreenGui then
        ScreenGui.Enabled = visible
    end
end

return Gui
