-- src/gui/main_frame.lua
-- Responsável pela criação da estrutura principal da GUI (ScreenGui + Main Frame + Status Bar)

local MainFrame = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)

-- Cores e fontes centralizadas (pode vir de helpers depois)
local COLORS = {
    Background = Color3.fromRGB(8, 8, 14),          -- #08080E
    Frame = Color3.fromRGB(10, 10, 18),             -- #0A0A12
    Accent = Color3.fromRGB(200, 0, 0),             -- #C80000
    AccentDark = Color3.fromRGB(140, 0, 0),
    Stroke = Color3.fromRGB(180, 0, 0),
    TextPrimary = Color3.fromRGB(240, 240, 245),
    TextSecondary = Color3.fromRGB(160, 160, 180),
    TextMuted = Color3.fromRGB(100, 100, 120),
    StatusOff = Color3.fromRGB(180, 0, 0),
    StatusOn = Color3.fromRGB(0, 220, 80),
}

local FONTS = {
    Title = Enum.Font.GothamBlack,
    Section = Enum.Font.GothamBold,
    Normal = Enum.Font.GothamSemibold,
    Small = Enum.Font.Gotham,
}

-- Referências que serão expostas
MainFrame.ScreenGui = nil
MainFrame.Main = nil
MainFrame.Content = nil
MainFrame.StatusText = nil
MainFrame.TargetLabel = nil
MainFrame.AvatarImage = nil
MainFrame.AimlockToggle = nil
MainFrame.SilentToggle = nil
MainFrame.PredictionBox = nil
MainFrame.SmoothnessBox = nil

-- ================================================
-- Criação da GUI principal
-- ================================================
function MainFrame:Create()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end

    local sg = Instance.new("ScreenGui")
    sg.Name = "SacramentAim"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999
    sg.Parent = PlayerGui
    self.ScreenGui = sg

    -- Frame principal
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 360, 0, 440)
    main.Position = UDim2.new(0.5, -180, 0.5, -220)
    main.BackgroundColor3 = COLORS.Frame
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = sg
    self.Main = main

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = main

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.Stroke
    stroke.Transparency = 0.55
    stroke.Thickness = 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = main

    -- Título
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = "SACRAMENT AIMLOCK"
    title.TextColor3 = COLORS.Accent
    title.TextSize = 26
    title.Font = FONTS.Title
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.TextYAlignment = Enum.TextYAlignment.Center
    title.Parent = main

    -- Container de conteúdo (onde vão as seções)
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -40, 1, -90)
    content.Position = UDim2.new(0, 20, 0, 60)
    content.BackgroundTransparency = 1
    content.Parent = main
    self.Content = content

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 18)
    list.Parent = content

    -- Barra de status (fundo fixo)
    local statusBar = Instance.new("Frame")
    statusBar.Name = "StatusBar"
    statusBar.Size = UDim2.new(1, 0, 0, 36)
    statusBar.Position = UDim2.new(0, 0, 1, -36)
    statusBar.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
    statusBar.BorderSizePixel = 0
    statusBar.Parent = main

    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 10)
    statusCorner.Parent = statusBar

    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, -20, 1, 0)
    statusText.Position = UDim2.new(0, 10, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Status: OFFLINE"
    statusText.TextColor3 = COLORS.StatusOff
    statusText.TextSize = 15
    statusText.Font = FONTS.Section
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusBar
    self.StatusText = statusText

    -- Tornar arrastável
    self:MakeDraggable(main)

    print("[Sacrament MainFrame] Estrutura principal criada")
    return sg
end

-- ================================================
-- Função auxiliar: tornar frame arrastável
-- ================================================
function MainFrame:MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ================================================
-- Cleanup (chamar quando destruir a GUI)
-- ================================================
function MainFrame:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
        self.ScreenGui = nil
    end
    print("[Sacrament MainFrame] Destruído")
end

return MainFrame
