-- src/gui.lua
-- Sacrament Aim System - GUI Principal (Dark/Underground Theme)
-- Criado para visual minimalista, agressivo e discreto

local Gui = {}
Gui.__index = Gui

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)

-- Configurações visuais (ajuste aqui se precisar mudar tons)
local COLORS = {
    Background = Color3.fromRGB(8, 8, 14),          -- #08080E
    Frame = Color3.fromRGB(10, 10, 18),             -- #0A0A12
    Accent = Color3.fromRGB(200, 0, 0),             -- #C80000 vermelho sangue
    AccentDark = Color3.fromRGB(140, 0, 0),         -- preenchimento ON
    TextPrimary = Color3.fromRGB(240, 240, 245),    -- quase branco
    TextSecondary = Color3.fromRGB(160, 160, 180),  -- cinza claro
    TextMuted = Color3.fromRGB(100, 100, 120),      -- cinza escuro (keybinds)
    Stroke = Color3.fromRGB(180, 0, 0),             -- borda vermelha
    StatusOff = Color3.fromRGB(180, 0, 0),
    StatusOn = Color3.fromRGB(0, 220, 80),
}

local FONTS = {
    Title = Enum.Font.GothamBlack,
    Section = Enum.Font.GothamBold,
    Normal = Enum.Font.GothamSemibold,
    Small = Enum.Font.Gotham,
}

-- ================================================
-- Função principal de criação da GUI
-- ================================================
function Gui:Create()
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

    -- Frame principal (arrastável)
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 360, 0, 440)
    main.Position = UDim2.new(0.5, -180, 0.5, -220)
    main.BackgroundColor3 = COLORS.Frame
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = sg

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

    -- Conteúdo (padding)
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -40, 1, -90)
    content.Position = UDim2.new(0, 20, 0, 60)
    content.BackgroundTransparency = 1
    content.Parent = main

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 18)
    list.Parent = content

    -- ================================================
    -- PVP CONTROLS
    -- ================================================
    local pvpSection = self:CreateSection("PVP CONTROLS", content)
    pvpSection.LayoutOrder = 1

    self.AimlockToggle = self:CreateToggle(
        pvpSection,
        "Aimlock Toggle",
        "E",
        function(state) 
            return state.AimlockEnabled 
        end
    )

    self.SilentToggle = self:CreateToggle(
        pvpSection,
        "Silent Aim",
        "Q",
        function(state) 
            return state.SilentAimEnabled 
        end
    )

    -- ================================================
    -- CONFIGS
    -- ================================================
    local configSection = self:CreateSection("CONFIGS", content)
    configSection.LayoutOrder = 2

    local configLayout = Instance.new("UIGridLayout")
    configLayout.CellSize = UDim2.new(0.5, -8, 0, 34)
    configLayout.CellPadding = UDim2.new(0, 16, 0, 8)
    configLayout.SortOrder = Enum.SortOrder.LayoutOrder
    configLayout.Parent = configSection

    self.PredictionBox = self:CreateConfigInput(configSection, "Prediction:", "0.135")
    self.SmoothnessBox = self:CreateConfigInput(configSection, "Smoothness:", "0.15")

    -- ================================================
    -- TARGET INFO
    -- ================================================
    local targetSection = self:CreateSection("TARGET INFO", content)
    targetSection.LayoutOrder = 3

    local targetFrame = Instance.new("Frame")
    targetFrame.Size = UDim2.new(1, 0, 0, 90)
    targetFrame.BackgroundTransparency = 1
    targetFrame.Parent = targetSection

    -- Placeholder para avatar (preparado para futuro)
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Size = UDim2.new(0, 80, 0, 80)
    avatar.Position = UDim2.new(0, 0, 0.5, -40)
    avatar.BackgroundTransparency = 1
    avatar.Image = ""  -- será preenchido depois
    avatar.Visible = false  -- por enquanto invisível
    avatar.Parent = targetFrame

    local cornerAvatar = Instance.new("UICorner")
    cornerAvatar.CornerRadius = UDim.new(1, 0)
    cornerAvatar.Parent = avatar

    local targetLabel = Instance.new("TextLabel")
    targetLabel.Name = "TargetLabel"
    targetLabel.Size = UDim2.new(1, 0, 1, 0)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "Nenhum alvo"
    targetLabel.TextColor3 = COLORS.TextSecondary
    targetLabel.TextSize = 18
    targetLabel.Font = FONTS.Normal
    targetLabel.TextXAlignment = Enum.TextXAlignment.Center
    targetLabel.TextYAlignment = Enum.TextYAlignment.Center
    targetLabel.Parent = targetFrame

    self.TargetLabel = targetLabel
    self.AvatarImage = avatar

    -- ================================================
    -- STATUS BAR
    -- ================================================
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

    -- Tornar frame arrastável
    self:MakeDraggable(main)

    print("[Sacrament GUI] Interface criada com sucesso")
    return sg
end

-- ================================================
-- Helpers
-- ================================================
function Gui:CreateSection(titleText, parent)
    local section = Instance.new("Frame")
    section.BackgroundTransparency = 1
    section.Size = UDim2.new(1, 0, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.Parent = parent

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 22)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = COLORS.TextPrimary
    title.TextSize = 15
    title.Font = FONTS.Section
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = section

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0, 0, 0, 24)
    divider.BackgroundColor3 = COLORS.Accent
    divider.BackgroundTransparency = 0.4
    divider.BorderSizePixel = 0
    divider.Parent = section

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, 30)
    content.BackgroundTransparency = 1
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Parent = section

    return content
end

function Gui:CreateToggle(parent, labelText, keyText, getStateFunc)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 18, 0, 18)
    box.Position = UDim2.new(0, 0, 0.5, -9)
    box.BackgroundColor3 = COLORS.Frame
    box.BorderColor3 = COLORS.Accent
    box.BorderSizePixel = 1
    box.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(1, -4, 1, -4)
    fill.Position = UDim2.new(0, 2, 0, 2)
    fill.BackgroundColor3 = COLORS.AccentDark
    fill.BackgroundTransparency = 1
    fill.Parent = box

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = box

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 26, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = COLORS.TextSecondary
    label.TextSize = 15
    label.Font = FONTS.Normal
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local key = Instance.new("TextLabel")
    key.Size = UDim2.new(0.3, 0, 1, 0)
    key.Position = UDim2.new(0.7, 0, 0, 0)
    key.BackgroundTransparency = 1
    key.Text = "KEY: " .. keyText
    key.TextColor3 = COLORS.TextMuted
    key.TextSize = 13
    key.Font = FONTS.Small
    key.TextXAlignment = Enum.TextXAlignment.Right
    key.Parent = frame

    local toggleObj = {
        Frame = frame,
        Fill = fill,
        Update = function(enabled)
            if enabled then
                TweenService:Create(fill, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
            else
                TweenService:Create(fill, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
            end
        end
    }

    -- Hover sutil
    frame.MouseEnter:Connect(function()
        box.BorderColor3 = Color3.fromRGB(220, 40, 40)
    end)
    frame.MouseLeave:Connect(function()
        box.BorderColor3 = COLORS.Accent
    end)

    return toggleObj
end

function Gui:CreateConfigInput(parent, labelText, defaultValue)
    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = COLORS.TextSecondary
    label.TextSize = 14
    label.Font = FONTS.Normal
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.6, 0, 1, 0)
    box.Position = UDim2.new(0.4, 0, 0, 0)
    box.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    box.BorderSizePixel = 0
    box.Text = defaultValue
    box.TextColor3 = COLORS.TextPrimary
    box.TextSize = 14
    box.Font = FONTS.Normal
    box.ClearTextOnFocus = false
    box.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = box

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.Stroke
    stroke.Transparency = 0.6
    stroke.Thickness = 1
    stroke.Parent = box

    -- Atualiza valor ao perder foco
    box.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            -- Aqui você pode validar número etc
            local val = tonumber(box.Text)
            if val then
                if labelText:find("Prediction") then
                    getgenv().Sacrament_Prediction = val
                elseif labelText:find("Smoothness") then
                    getgenv().Sacrament_Smoothness = val
                end
            else
                box.Text = defaultValue
            end
        end
    end)

    return box
end

function Gui:MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement then
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
-- Atualização em tempo real
-- ================================================
function Gui:Init(statesModule)
    self.States = statesModule

    -- Cria a GUI
    self:Create()

    -- Começa oculta
    self.ScreenGui.Enabled = false

    -- Atualiza visibilidade
    local connVisibility
    connVisibility = RunService.Heartbeat:Connect(function()
        if self.States.GuiVisible ~= self.ScreenGui.Enabled then
            self.ScreenGui.Enabled = self.States.GuiVisible
            print("[Sacrament GUI] Visible → " .. tostring(self.ScreenGui.Enabled))
        end
    end)

    -- Atualiza toggles e status
    local connUpdate
    connUpdate = RunService.RenderStepped:Connect(function()
        if not self.ScreenGui.Enabled then return end

        if self.AimlockToggle then
            self.AimlockToggle.Update(self.States.AimlockEnabled)
        end

        if self.SilentToggle then
            self.SilentToggle.Update(self.States.SilentAimEnabled)
        end

        -- Status bar
        local anyActive = self.States.AimlockEnabled or self.States.SilentAimEnabled
        if anyActive then
            self.StatusText.Text = "Status: LOCK ACTIVE"
            self.StatusText.TextColor3 = COLORS.StatusOn
        else
            self.StatusText.Text = "Status: OFFLINE"
            self.StatusText.TextColor3 = COLORS.StatusOff
        end
    end)

    -- Cleanup (opcional - quando destruir)
    self.Destroy = function()
        if connVisibility then connVisibility:Disconnect() end
        if connUpdate then connUpdate:Disconnect() end
        if self.ScreenGui then self.ScreenGui:Destroy() end
    end

    print("[Sacrament GUI] Inicialização completa")
end

-- Para teste local (descomente se quiser ver a GUI ao carregar)
-- Gui:Create()
-- Gui.ScreenGui.Enabled = true

return Gui
