-- Sacrament GUI - Dark Professional Edition (baseado no exemplo SafadinhaPvP)
-- Discreto, obscuro, alinhado - sem fofura

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Gui = {}
local ScreenGui = nil
local MainFrame = nil
local Labels = {}
local Checkboxes = {}
local TextBoxes = {}

local lp = Players.LocalPlayer

-- Variáveis de config (serão atualizadas pelos TextBox)
local prediction = 0.135
local smoothness = 0.15

local function createGui()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SacramentAimGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")  -- tenta CoreGui pra resistência

    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 340, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -170, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = MainFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(180, 0, 0)
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = MainFrame

    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = "SACRAMENT AIMLOCK"
    title.TextColor3 = Color3.fromRGB(220, 20, 20)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 24
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = MainFrame

    -- Divisória
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(0.9, 0, 0, 1)
    divider.Position = UDim2.new(0.05, 0, 0, 55)
    divider.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    divider.BorderSizePixel = 0
    divider.Parent = MainFrame

    -- PVP CONTROLS
    local pvpTitle = Instance.new("TextLabel")
    pvpTitle.Size = UDim2.new(0.9, 0, 0, 25)
    pvpTitle.Position = UDim2.new(0.05, 0, 0, 65)
    pvpTitle.BackgroundTransparency = 1
    pvpTitle.Text = "PVP CONTROLS"
    pvpTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
    pvpTitle.Font = Enum.Font.GothamBold
    pvpTitle.TextSize = 16
    pvpTitle.TextXAlignment = Enum.TextXAlignment.Left
    pvpTitle.Parent = MainFrame

    -- Aimlock toggle
    local aimCheck = Instance.new("TextButton")
    aimCheck.Size = UDim2.new(0, 22, 0, 22)
    aimCheck.Position = UDim2.new(0.05, 0, 0, 95)
    aimCheck.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    aimCheck.Text = ""
    Instance.new("UICorner", aimCheck).CornerRadius = UDim.new(0, 6)
    aimCheck.Parent = MainFrame

    local aimFill = Instance.new("Frame")
    aimFill.Size = UDim2.new(0.7, 0, 0.7, 0)
    aimFill.Position = UDim2.new(0.15, 0, 0.15, 0)
    aimFill.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    aimFill.Visible = false
    Instance.new("UICorner", aimFill).CornerRadius = UDim.new(0, 4)
    aimFill.Parent = aimCheck

    local aimLabel = Instance.new("TextLabel")
    aimLabel.Size = UDim2.new(0.8, 0, 0, 22)
    aimLabel.Position = UDim2.new(0.15, 0, 0, 95)
    aimLabel.BackgroundTransparency = 1
    aimLabel.Text = "Aimlock Toggle"
    aimLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    aimLabel.Font = Enum.Font.Gotham
    aimLabel.TextSize = 15
    aimLabel.TextXAlignment = Enum.TextXAlignment.Left
    aimLabel.Parent = MainFrame

    local aimKey = Instance.new("TextLabel")
    aimKey.Size = UDim2.new(0.3, 0, 0, 22)
    aimKey.Position = UDim2.new(0.65, 0, 0, 95)
    aimKey.BackgroundTransparency = 1
    aimKey.Text = "KEY: E"
    aimKey.TextColor3 = Color3.fromRGB(180, 180, 180)
    aimKey.Font = Enum.Font.Gotham
    aimKey.TextSize = 14
    aimKey.TextXAlignment = Enum.TextXAlignment.Right
    aimKey.Parent = MainFrame

    Checkboxes["Aimlock"] = {Check = aimCheck, Fill = aimFill, Label = aimLabel, KeyLabel = aimKey}

    -- Silent Aim toggle
    local silentCheck = Instance.new("TextButton")
    silentCheck.Size = UDim2.new(0, 22, 0, 22)
    silentCheck.Position = UDim2.new(0.05, 0, 0, 125)
    silentCheck.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    silentCheck.Text = ""
    Instance.new("UICorner", silentCheck).CornerRadius = UDim.new(0, 6)
    silentCheck.Parent = MainFrame

    local silentFill = Instance.new("Frame")
    silentFill.Size = UDim2.new(0.7, 0, 0.7, 0)
    silentFill.Position = UDim2.new(0.15, 0, 0.15, 0)
    silentFill.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    silentFill.Visible = false
    Instance.new("UICorner", silentFill).CornerRadius = UDim.new(0, 4)
    silentFill.Parent = silentCheck

    local silentLabel = Instance.new("TextLabel")
    silentLabel.Size = UDim2.new(0.8, 0, 0, 22)
    silentLabel.Position = UDim2.new(0.15, 0, 0, 125)
    silentLabel.BackgroundTransparency = 1
    silentLabel.Text = "Silent Aim"
    silentLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    silentLabel.Font = Enum.Font.Gotham
    silentLabel.TextSize = 15
    silentLabel.TextXAlignment = Enum.TextXAlignment.Left
    silentLabel.Parent = MainFrame

    local silentKey = Instance.new("TextLabel")
    silentKey.Size = UDim2.new(0.3, 0, 0, 22)
    silentKey.Position = UDim2.new(0.65, 0, 0, 125)
    silentKey.BackgroundTransparency = 1
    silentKey.Text = "KEY: Q"
    silentKey.TextColor3 = Color3.fromRGB(180, 180, 180)
    silentKey.Font = Enum.Font.Gotham
    silentKey.TextSize = 14
    silentKey.TextXAlignment = Enum.TextXAlignment.Right
    silentKey.Parent = MainFrame

    Checkboxes["SilentAim"] = {Check = silentCheck, Fill = silentFill, Label = silentLabel, KeyLabel = silentKey}

    -- CONFIGS
    local configTitle = Instance.new("TextLabel")
    configTitle.Size = UDim2.new(0.9, 0, 0, 25)
    configTitle.Position = UDim2.new(0.05, 0, 0, 160)
    configTitle.BackgroundTransparency = 1
    configTitle.Text = "CONFIGS"
    configTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
    configTitle.Font = Enum.Font.GothamBold
    configTitle.TextSize = 16
    configTitle.TextXAlignment = Enum.TextXAlignment.Left
    configTitle.Parent = MainFrame

    -- Prediction
    local predLabel = Instance.new("TextLabel")
    predLabel.Size = UDim2.new(0.45, 0, 0, 20)
    predLabel.Position = UDim2.new(0.05, 0, 0, 190)
    predLabel.BackgroundTransparency = 1
    predLabel.Text = "Prediction:"
    predLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    predLabel.Font = Enum.Font.Gotham
    predLabel.TextSize = 14
    predLabel.Parent = MainFrame

    local predBox = Instance.new("TextBox")
    predBox.Size = UDim2.new(0, 110, 0, 28)
    predBox.Position = UDim2.new(0.05, 0, 0, 210)
    predBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    predBox.TextColor3 = Color3.fromRGB(220, 220, 220)
    predBox.Text = tostring(prediction)
    predBox.Font = Enum.Font.Gotham
    predBox.TextSize = 15
    Instance.new("UICorner", predBox).CornerRadius = UDim.new(0, 6)
    predBox.Parent = MainFrame

    TextBoxes["Prediction"] = predBox

    -- Smoothness
    local smoothLabel = Instance.new("TextLabel")
    smoothLabel.Size = UDim2.new(0.45, 0, 0, 20)
    smoothLabel.Position = UDim2.new(0.5, 0, 0, 190)
    smoothLabel.BackgroundTransparency = 1
    smoothLabel.Text = "Smoothness:"
    smoothLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    smoothLabel.Font = Enum.Font.Gotham
    smoothLabel.TextSize = 14
    smoothLabel.Parent = MainFrame

    local smoothBox = Instance.new("TextBox")
    smoothBox.Size = UDim2.new(0, 110, 0, 28)
    smoothBox.Position = UDim2.new(0.5, 0, 0, 210)
    smoothBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    smoothBox.TextColor3 = Color3.fromRGB(220, 220, 220)
    smoothBox.Text = tostring(smoothness)
    smoothBox.Font = Enum.Font.Gotham
    smoothBox.TextSize = 15
    Instance.new("UICorner", smoothBox).CornerRadius = UDim.new(0, 6)
    smoothBox.Parent = MainFrame

    TextBoxes["Smoothness"] = smoothBox

    -- TARGET INFO
    local targetTitle = Instance.new("TextLabel")
    targetTitle.Size = UDim2.new(0.9, 0, 0, 25)
    targetTitle.Position = UDim2.new(0.05, 0, 0, 250)
    targetTitle.BackgroundTransparency = 1
    targetTitle.Text = "TARGET INFO"
    targetTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
    targetTitle.Font = Enum.Font.GothamBold
    targetTitle.TextSize = 16
    targetTitle.TextXAlignment = Enum.TextXAlignment.Left
    targetTitle.Parent = MainFrame

    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(0.9, 0, 0, 30)
    targetLabel.Position = UDim2.new(0.05, 0, 0, 280)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "Nenhum alvo"
    targetLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    targetLabel.Font = Enum.Font.GothamBold
    targetLabel.TextSize = 18
    targetLabel.TextXAlignment = Enum.TextXAlignment.Center
    targetLabel.Parent = MainFrame
    Labels["Target"] = targetLabel

    -- Status bar
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0.9, 0, 0, 40)
    status.Position = UDim2.new(0.05, 0, 0, 340)
    status.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    status.Text = "Status: OFFLINE"
    status.TextColor3 = Color3.fromRGB(220, 20, 20)
    status.Font = Enum.Font.GothamBold
    status.TextSize = 18
    status.TextXAlignment = Enum.TextXAlignment.Center
    Instance.new("UICorner", status).CornerRadius = UDim.new(0, 10)
    status.Parent = MainFrame
    Labels["Status"] = status

    print("[GUI] Dark professional criada")
    return ScreenGui
end

function Gui:Init(inputModule)
    local states = inputModule.States
    if not states then
        warn("[GUI] States não encontrados")
        return
    end

    ScreenGui = createGui()
    ScreenGui.Enabled = states.GuiVisible  -- começa false, toggle via Insert

    -- Atualiza visual dos toggles e status via poll
    RunService.RenderStepped:Connect(function()
        if not MainFrame or not MainFrame.Parent then return end

        -- Aimlock
        Checkboxes["Aimlock"].Fill.Visible = states.AimlockEnabled
        Checkboxes["Aimlock"].Check.BackgroundColor3 = states.AimlockEnabled and Color3.fromRGB(40, 20, 20) or Color3.fromRGB(30, 30, 35)

        -- Silent Aim
        Checkboxes["SilentAim"].Fill.Visible = states.SilentAimEnabled
        Checkboxes["SilentAim"].Check.BackgroundColor3 = states.SilentAimEnabled and Color3.fromRGB(40, 20, 20) or Color3.fromRGB(30, 30, 35)

        -- Status (placeholder - atualize quando tiver target real)
        if states.AimlockEnabled or states.SilentAimEnabled then
            Labels["Status"].Text = "Status: ONLINE"
            Labels["Status"].TextColor3 = Color3.fromRGB(0, 220, 0)
            Labels["Status"].BackgroundColor3 = Color3.fromRGB(15, 35, 15)
        else
            Labels["Status"].Text = "Status: OFFLINE"
            Labels["Status"].TextColor3 = Color3.fromRGB(220, 20, 20)
            Labels["Status"].BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        end

        -- Target placeholder
        Labels["Target"].Text = "Nenhum alvo"  -- atualize depois com target real
    end)

    -- Atualiza configs dos TextBox
    TextBoxes["Prediction"].FocusLost:Connect(function()
        local num = tonumber(TextBoxes["Prediction"].Text)
        if num and num >= 0 and num <= 1 then
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

    -- Sync visibility
    local oldVisible = states.GuiVisible
    RunService.RenderStepped:Connect(function()
        if states.GuiVisible ~= oldVisible then
            ScreenGui.Enabled = states.GuiVisible
            oldVisible = states.GuiVisible
        end
    end)

    print("[GUI] Inicializado - dark professional mode")
end

return Gui
