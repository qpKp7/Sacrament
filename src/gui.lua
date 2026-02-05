-- Sacrament GUI - Dark Obscure Professional v0.3
-- Refinado, discreto, sem fofura - tons preto carvão + vermelho sangue

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Gui = {}
local ScreenGui = nil
local MainFrame = nil
local Checkboxes = {}
local TextBoxes = {}
local Labels = {}

local prediction = 0.135
local smoothness = 0.15

local lp = Players.LocalPlayer

local function createGui()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SacramentAimGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = lp:WaitForChild("PlayerGui")  -- PlayerGui pra compatibilidade máxima

    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 360, 0, 440)
    MainFrame.Position = UDim2.new(0.5, -180, 0.5, -220)
    MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = true  -- começa visível pra debug - depois muda pra false
    MainFrame.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = MainFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(140, 0, 0)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.65
    stroke.Parent = MainFrame

    -- Título com sombra sutil
    local titleShadow = Instance.new("TextLabel")
    titleShadow.Size = UDim2.new(1, 0, 0, 60)
    titleShadow.BackgroundTransparency = 1
    titleShadow.Text = "SACRAMENT AIMLOCK"
    titleShadow.TextColor3 = Color3.fromRGB(40, 0, 0)
    titleShadow.Font = Enum.Font.GothamBlack
    titleShadow.TextSize = 28
    titleShadow.TextXAlignment = Enum.TextXAlignment.Center
    titleShadow.Position = UDim2.new(0, 2, 0, 2)
    titleShadow.ZIndex = 0
    titleShadow.Parent = MainFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 60)
    title.BackgroundTransparency = 1
    title.Text = "SACRAMENT AIMLOCK"
    title.TextColor3 = Color3.fromRGB(200, 20, 20)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 28
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.ZIndex = 1
    title.Parent = MainFrame

    -- Divisória principal
    local mainDivider = Instance.new("Frame")
    mainDivider.Size = UDim2.new(0.92, 0, 0, 1)
    mainDivider.Position = UDim2.new(0.04, 0, 0, 60)
    mainDivider.BackgroundColor3 = Color3.fromRGB(70, 0, 0)
    mainDivider.BorderSizePixel = 0
    mainDivider.Parent = MainFrame

    -- PVP CONTROLS
    local pvpTitle = Instance.new("TextLabel")
    pvpTitle.Size = UDim2.new(0.92, 0, 0, 28)
    pvpTitle.Position = UDim2.new(0.04, 0, 0, 70)
    pvpTitle.BackgroundTransparency = 1
    pvpTitle.Text = "PVP CONTROLS"
    pvpTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    pvpTitle.Font = Enum.Font.GothamBold
    pvpTitle.TextSize = 15
    pvpTitle.TextXAlignment = Enum.TextXAlignment.Left
    pvpTitle.Parent = MainFrame

    -- Aimlock Toggle
    local aimCheck = Instance.new("TextButton")
    aimCheck.Size = UDim2.new(0, 26, 0, 26)
    aimCheck.Position = UDim2.new(0.04, 0, 0, 105)
    aimCheck.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    aimCheck.BorderSizePixel = 1
    aimCheck.BorderColor3 = Color3.fromRGB(60, 0, 0)
    aimCheck.Text = ""
    Instance.new("UICorner", aimCheck).CornerRadius = UDim.new(0, 6)
    aimCheck.Parent = MainFrame

    local aimFill = Instance.new("Frame")
    aimFill.Size = UDim2.new(0.7, 0, 0.7, 0)
    aimFill.Position = UDim2.new(0.15, 0, 0.15, 0)
    aimFill.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
    aimFill.Visible = false
    Instance.new("UICorner", aimFill).CornerRadius = UDim.new(0, 4)
    aimFill.Parent = aimCheck

    local aimText = Instance.new("TextLabel")
    aimText.Size = UDim2.new(0.5, 0, 0, 26)
    aimText.Position = UDim2.new(0.12, 0, 0, 105)
    aimText.BackgroundTransparency = 1
    aimText.Text = "Aimlock Toggle"
    aimText.TextColor3 = Color3.fromRGB(210, 210, 210)
    aimText.Font = Enum.Font.GothamSemibold
    aimText.TextSize = 14
    aimText.TextXAlignment = Enum.TextXAlignment.Left
    aimText.Parent = MainFrame

    local aimKey = Instance.new("TextLabel")
    aimKey.Size = UDim2.new(0.3, 0, 0, 26)
    aimKey.Position = UDim2.new(0.65, 0, 0, 105)
    aimKey.BackgroundTransparency = 1
    aimKey.Text = "KEY: E"
    aimKey.TextColor3 = Color3.fromRGB(140, 140, 140)
    aimKey.Font = Enum.Font.Gotham
    aimKey.TextSize = 13
    aimKey.TextXAlignment = Enum.TextXAlignment.Right
    aimKey.Parent = MainFrame

    Checkboxes["Aimlock"] = {Check = aimCheck, Fill = aimFill}

    -- Silent Aim Toggle
    local silentCheck = Instance.new("TextButton")
    silentCheck.Size = UDim2.new(0, 26, 0, 26)
    silentCheck.Position = UDim2.new(0.04, 0, 0, 138)
    silentCheck.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    silentCheck.BorderSizePixel = 1
    silentCheck.BorderColor3 = Color3.fromRGB(60, 0, 0)
    silentCheck.Text = ""
    Instance.new("UICorner", silentCheck).CornerRadius = UDim.new(0, 6)
    silentCheck.Parent = MainFrame

    local silentFill = Instance.new("Frame")
    silentFill.Size = UDim2.new(0.7, 0, 0.7, 0)
    silentFill.Position = UDim2.new(0.15, 0, 0.15, 0)
    silentFill.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
    silentFill.Visible = false
    Instance.new("UICorner", silentFill).CornerRadius = UDim.new(0, 4)
    silentFill.Parent = silentCheck

    local silentText = Instance.new("TextLabel")
    silentText.Size = UDim2.new(0.5, 0, 0, 26)
    silentText.Position = UDim2.new(0.12, 0, 0, 138)
    silentText.BackgroundTransparency = 1
    silentText.Text = "Silent Aim"
    silentText.TextColor3 = Color3.fromRGB(210, 210, 210)
    silentText.Font = Enum.Font.GothamSemibold
    silentText.TextSize = 14
    silentText.TextXAlignment = Enum.TextXAlignment.Left
    silentText.Parent = MainFrame

    local silentKey = Instance.new("TextLabel")
    silentKey.Size = UDim2.new(0.3, 0, 0, 26)
    silentKey.Position = UDim2.new(0.65, 0, 0, 138)
    silentKey.BackgroundTransparency = 1
    silentKey.Text = "KEY: Q"
    silentKey.TextColor3 = Color3.fromRGB(140, 140, 140)
    silentKey.Font = Enum.Font.Gotham
    silentKey.TextSize = 13
    silentKey.TextXAlignment = Enum.TextXAlignment.Right
    silentKey.Parent = MainFrame

    Checkboxes["SilentAim"] = {Check = silentCheck, Fill = silentFill}

    -- CONFIGS
    local configTitle = Instance.new("TextLabel")
    configTitle.Size = UDim2.new(0.92, 0, 0, 28)
    configTitle.Position = UDim2.new(0.04, 0, 0, 175)
    configTitle.BackgroundTransparency = 1
    configTitle.Text = "CONFIGS"
    configTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    configTitle.Font = Enum.Font.GothamBold
    configTitle.TextSize = 15
    configTitle.TextXAlignment = Enum.TextXAlignment.Left
    configTitle.Parent = MainFrame

    local configDivider = Instance.new("Frame")
    configDivider.Size = UDim2.new(0.92, 0, 0, 1)
    configDivider.Position = UDim2.new(0.04, 0, 0, 205)
    configDivider.BackgroundColor3 = Color3.fromRGB(70, 0, 0)
    configDivider.Parent = MainFrame

    local predLabel = Instance.new("TextLabel")
    predLabel.Size = UDim2.new(0.45, 0, 0, 22)
    predLabel.Position = UDim2.new(0.04, 0, 0, 215)
    predLabel.BackgroundTransparency = 1
    predLabel.Text = "Prediction"
    predLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    predLabel.Font = Enum.Font.Gotham
    predLabel.TextSize = 13
    predLabel.TextXAlignment = Enum.TextXAlignment.Left
    predLabel.Parent = MainFrame

    local predBox = Instance.new("TextBox")
    predBox.Size = UDim2.new(0, 120, 0, 32)
    predBox.Position = UDim2.new(0.04, 0, 0, 238)
    predBox.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    predBox.TextColor3 = Color3.fromRGB(220, 220, 220)
    predBox.Text = tostring(prediction)
    predBox.Font = Enum.Font.Gotham
    predBox.TextSize = 14
    predBox.ClearTextOnFocus = false
    Instance.new("UICorner", predBox).CornerRadius = UDim.new(0, 6)
    local predStroke = Instance.new("UIStroke", predBox)
    predStroke.Color = Color3.fromRGB(100, 0, 0)
    predStroke.Thickness = 1
    predStroke.Transparency = 0.6
    predBox.Parent = MainFrame
    TextBoxes["Prediction"] = predBox

    local smoothLabel = Instance.new("TextLabel")
    smoothLabel.Size = UDim2.new(0.45, 0, 0, 22)
    smoothLabel.Position = UDim2.new(0.51, 0, 0, 215)
    smoothLabel.BackgroundTransparency = 1
    smoothLabel.Text = "Smoothness"
    smoothLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    smoothLabel.Font = Enum.Font.Gotham
    smoothLabel.TextSize = 13
    smoothLabel.TextXAlignment = Enum.TextXAlignment.Left
    smoothLabel.Parent = MainFrame

    local smoothBox = Instance.new("TextBox")
    smoothBox.Size = UDim2.new(0, 120, 0, 32)
    smoothBox.Position = UDim2.new(0.51, 0, 0, 238)
    smoothBox.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    smoothBox.TextColor3 = Color3.fromRGB(220, 220, 220)
    smoothBox.Text = tostring(smoothness)
    smoothBox.Font = Enum.Font.Gotham
    smoothBox.TextSize = 14
    smoothBox.ClearTextOnFocus = false
    Instance.new("UICorner", smoothBox).CornerRadius = UDim.new(0, 6)
    local smoothStroke = Instance.new("UIStroke", smoothBox)
    smoothStroke.Color = Color3.fromRGB(100, 0, 0)
    smoothStroke.Thickness = 1
    smoothStroke.Transparency = 0.6
    smoothBox.Parent = MainFrame
    TextBoxes["Smoothness"] = smoothBox

    -- TARGET INFO
    local targetTitle = Instance.new("TextLabel")
    targetTitle.Size = UDim2.new(0.92, 0, 0, 28)
    targetTitle.Position = UDim2.new(0.04, 0, 0, 285)
    targetTitle.BackgroundTransparency = 1
    targetTitle.Text = "TARGET INFO"
    targetTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    targetTitle.Font = Enum.Font.GothamBold
    targetTitle.TextSize = 15
    targetTitle.TextXAlignment = Enum.TextXAlignment.Left
    targetTitle.Parent = MainFrame

    local targetDivider = Instance.new("Frame")
    targetDivider.Size = UDim2.new(0.92, 0, 0, 1)
    targetDivider.Position = UDim2.new(0.04, 0, 0, 315)
    targetDivider.BackgroundColor3 = Color3.fromRGB(70, 0, 0)
    targetDivider.Parent = MainFrame

    local targetInfo = Instance.new("TextLabel")
    targetInfo.Size = UDim2.new(0.92, 0, 0, 50)
    targetInfo.Position = UDim2.new(0.04, 0, 0, 325)
    targetInfo.BackgroundTransparency = 1
    targetInfo.Text = "Nenhum alvo selecionado"
    targetInfo.TextColor3 = Color3.fromRGB(160, 160, 160)
    targetInfo.Font = Enum.Font.GothamSemibold
    targetInfo.TextSize = 16
    targetInfo.TextXAlignment = Enum.TextXAlignment.Center
    targetInfo.TextWrapped = true
    targetInfo.Parent = MainFrame
    Labels["Target"] = targetInfo

    -- Status bar
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(0.92, 0, 0, 48)
    statusBar.Position = UDim2.new(0.04, 0, 0, 385)
    statusBar.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    Instance.new("UICorner", statusBar).CornerRadius = UDim.new(0, 8)
    statusBar.Parent = MainFrame

    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, 0, 1, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Status: OFFLINE"
    statusText.TextColor3 = Color3.fromRGB(220, 20, 20)
    statusText.Font = Enum.Font.GothamBold
    statusText.TextSize = 18
    statusText.TextXAlignment = Enum.TextXAlignment.Center
    statusText.Parent = statusBar
    Labels["Status"] = statusText

    print("[GUI Debug] GUI criada - MainFrame.Visible = true")
    return ScreenGui
end

function Gui:Init(inputModule)
    print("[GUI Debug] Init iniciado")
    local states = inputModule.States
    if not states then
        warn("[GUI] States não encontrados")
        return
    end

    ScreenGui = createGui()

    -- Começa visível pra debug - depois muda pra states.GuiVisible
    MainFrame.Visible = true
    ScreenGui.Enabled = true

    -- Atualiza visual dos toggles e status
    RunService.RenderStepped:Connect(function()
        if not MainFrame or not MainFrame.Parent then return end

        Checkboxes["Aimlock"].Fill.Visible = states.AimlockEnabled
        Checkboxes["Aimlock"].Check.BackgroundColor3 = states.AimlockEnabled and Color3.fromRGB(35, 15, 15) or Color3.fromRGB(22, 22, 28)

        Checkboxes["SilentAim"].Fill.Visible = states.SilentAimEnabled
        Checkboxes["SilentAim"].Check.BackgroundColor3 = states.SilentAimEnabled and Color3.fromRGB(35, 15, 15) or Color3.fromRGB(22, 22, 28)

        if states.AimlockEnabled or states.SilentAimEnabled then
            Labels["Status"].Text = "Status: LOCK ACTIVE"
            Labels["Status"].TextColor3 = Color3.fromRGB(40, 220, 40)
        else
            Labels["Status"].Text = "Status: OFFLINE"
            Labels["Status"].TextColor3 = Color3.fromRGB(220, 20, 20)
        end
    end)

    -- Atualiza configs
    TextBoxes["Prediction"].FocusLost:Connect(function()
        local num = tonumber(TextBoxes["Prediction"].Text)
        if num and num >= 0 and num <= 2 then
            prediction = num
        else
            TextBoxes["Prediction"].Text = tostring(prediction)
        end
    end)

    TextBoxes["Smoothness"].FocusLost:Connect(function()
        local num = tonumber(TextBoxes["Smoothness"].Text)
        if num and num >= 0 and num <= 1 then
            smoothness = num
        else
            TextBoxes["Smoothness"].Text = tostring(smoothness)
        end
    end)

    print("[GUI Debug] GUI inicializada - deve estar visível agora")
end

function Gui:Toggle(visible)
    if MainFrame then
        MainFrame.Visible = visible
        print("[GUI Debug] Toggle chamado: " .. (visible and "ON" or "OFF"))
    end
end

return Gui
