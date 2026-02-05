-- Sacrament GUI - Dark Professional (alinhado com sua foto preferida)

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

local function createGui()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SacramentAimGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")

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
    stroke.Transparency = 0.4
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

    -- Aimlock
    local aimCheck = Instance.new("TextButton")
    aimCheck.Size = UDim2.new(0, 30, 0, 30)
    aimCheck.Position = UDim2.new(0.05, 0, 0, 95)
    aimCheck.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    aimCheck.Text = ""
    Instance.new("UICorner", aimCheck).CornerRadius = UDim.new(0, 8)
    aimCheck.Parent = MainFrame

    local aimFill = Instance.new("Frame")
    aimFill.Size = UDim2.new(0.6, 0, 0.6, 0)
    aimFill.Position = UDim2.new(0.2, 0, 0.2, 0)
    aimFill.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    aimFill.Visible = false
    Instance.new("UICorner", aimFill).CornerRadius = UDim.new(0, 6)
    aimFill.Parent = aimCheck

    local aimLabel = Instance.new("TextLabel")
    aimLabel.Size = UDim2.new(0.5, 0, 0, 30)
    aimLabel.Position = UDim2.new(0.15, 0, 0, 95)
    aimLabel.BackgroundTransparency = 1
    aimLabel.Text = "Aimlock Toggle (E)"
    aimLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    aimLabel.Font = Enum.Font.Gotham
    aimLabel.TextSize = 15
    aimLabel.TextXAlignment = Enum.TextXAlignment.Left
    aimLabel.Parent = MainFrame

    Checkboxes["Aimlock"] = {Check = aimCheck, Fill = aimFill}

    -- Silent Aim
    local silentCheck = Instance.new("TextButton")
    silentCheck.Size = UDim2.new(0, 30, 0, 30)
    silentCheck.Position = UDim2.new(0.05, 0, 0, 135)
    silentCheck.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    silentCheck.Text = ""
    Instance.new("UICorner", silentCheck).CornerRadius = UDim.new(0, 8)
    silentCheck.Parent = MainFrame

    local silentFill = Instance.new("Frame")
    silentFill.Size = UDim2.new(0.6, 0, 0.6, 0)
    silentFill.Position = UDim2.new(0.2, 0, 0.2, 0)
    silentFill.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    silentFill.Visible = false
    Instance.new("UICorner", silentFill).CornerRadius = UDim.new(0, 6)
    silentFill.Parent = silentCheck

    local silentLabel = Instance.new("TextLabel")
    silentLabel.Size = UDim2.new(0.5, 0, 0, 30)
    silentLabel.Position = UDim2.new(0.15, 0, 0, 135)
    silentLabel.BackgroundTransparency = 1
    silentLabel.Text = "Silent Aim (Q)"
    silentLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    silentLabel.Font = Enum.Font.Gotham
    silentLabel.TextSize = 15
    silentLabel.TextXAlignment = Enum.TextXAlignment.Left
    silentLabel.Parent = MainFrame

    Checkboxes["SilentAim"] = {Check = silentCheck, Fill = silentFill}

    -- CONFIGS
    local configTitle = Instance.new("TextLabel")
    configTitle.Size = UDim2.new(0.9, 0, 0, 25)
    configTitle.Position = UDim2.new(0.05, 0, 0, 175)
    configTitle.BackgroundTransparency = 1
    configTitle.Text = "CONFIGS"
    configTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
    configTitle.Font = Enum.Font.GothamBold
    configTitle.TextSize = 16
    configTitle.TextXAlignment = Enum.TextXAlignment.Left
    configTitle.Parent = MainFrame

    local configDivider = Instance.new("Frame")
    configDivider.Size = UDim2.new(0.9, 0, 0, 1)
    configDivider.Position = UDim2.new(0.05, 0, 0, 205)
    configDivider.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    configDivider.Parent = MainFrame

    local predLabel = Instance.new("TextLabel")
    predLabel.Size = UDim2.new(0.4, 0, 0, 20)
    predLabel.Position = UDim2.new(0.05, 0, 0, 215)
    predLabel.BackgroundTransparency = 1
    predLabel.Text = "Prediction:"
    predLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    predLabel.Font = Enum.Font.Gotham
    predLabel.TextSize = 14
    predLabel.Parent = MainFrame

    local predBox = Instance.new("TextBox")
    predBox.Size = UDim2.new(0, 110, 0, 32)
    predBox.Position = UDim2.new(0.05, 0, 0, 235)
    predBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    predBox.TextColor3 = Color3.fromRGB(220, 220, 220)
    predBox.Text = tostring(prediction)
    predBox.Font = Enum.Font.Gotham
    predBox.TextSize = 15
    Instance.new("UICorner", predBox).CornerRadius = UDim.new(0, 6)
    predBox.Parent = MainFrame
    TextBoxes["Prediction"] = predBox

    local smoothLabel = Instance.new("TextLabel")
    smoothLabel.Size = UDim2.new(0.4, 0, 0, 20)
    smoothLabel.Position = UDim2.new(0.55, 0, 0, 215)
    smoothLabel.BackgroundTransparency = 1
    smoothLabel.Text = "Smoothness:"
    smoothLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    smoothLabel.Font = Enum.Font.Gotham
    smoothLabel.TextSize = 14
    smoothLabel.Parent = MainFrame

    local smoothBox = Instance.new("TextBox")
    smoothBox.Size = UDim2.new(0, 110, 0, 32)
    smoothBox.Position = UDim2.new(0.55, 0, 0, 235)
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
    targetTitle.Position = UDim2.new(0.05, 0, 0, 280)
    targetTitle.BackgroundTransparency = 1
    targetTitle.Text = "TARGET INFO"
    targetTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
    targetTitle.Font = Enum.Font.GothamBold
    targetTitle.TextSize = 16
    targetTitle.TextXAlignment = Enum.TextXAlignment.Left
    targetTitle.Parent = MainFrame

    local targetDivider = Instance.new("Frame")
    targetDivider.Size = UDim2.new(0.9, 0, 0, 1)
    targetDivider.Position = UDim2.new(0.05, 0, 0, 310)
    targetDivider.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    targetDivider.Parent = MainFrame

    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(0.9, 0, 0, 40)
    targetLabel.Position = UDim2.new(0.05, 0, 0, 320)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "Nenhum alvo"
    targetLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    targetLabel.Font = Enum.Font.GothamBold
    targetLabel.TextSize = 18
    targetLabel.TextXAlignment = Enum.TextXAlignment.Center
    targetLabel.Parent = MainFrame
    Labels["Target"] = targetLabel

    -- Status
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0.9, 0, 0, 45)
    status.Position = UDim2.new(0.05, 0, 0, 370)
    status.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    status.Text = "Status: OFFLINE"
    status.TextColor3 = Color3.fromRGB(220, 20, 20)
    status.Font = Enum.Font.GothamBold
    status.TextSize = 18
    status.TextXAlignment = Enum.TextXAlignment.Center
    Instance.new("UICorner", status).CornerRadius = UDim.new(0, 10)
    status.Parent = MainFrame
    Labels["Status"] = status

    return ScreenGui
end

function Gui:Init(inputModule)
    local states = inputModule.States
    if not states then return end

    ScreenGui = createGui()
    ScreenGui.Enabled = states.GuiVisible

    RunService.RenderStepped:Connect(function()
        Checkboxes["Aimlock"].Fill.Visible = states.AimlockEnabled
        Checkboxes["Aimlock"].Check.BackgroundColor3 = states.AimlockEnabled and Color3.fromRGB(40, 20, 20) or Color3.fromRGB(30, 30, 35)

        Checkboxes["SilentAim"].Fill.Visible = states.SilentAimEnabled
        Checkboxes["SilentAim"].Check.BackgroundColor3 = states.SilentAimEnabled and Color3.fromRGB(40, 20, 20) or Color3.fromRGB(30, 30, 35)

        if states.AimlockEnabled or states.SilentAimEnabled then
            Labels["Status"].Text = "Status: ONLINE"
            Labels["Status"].TextColor3 = Color3.fromRGB(0, 220, 0)
            Labels["Status"].BackgroundColor3 = Color3.fromRGB(15, 35, 15)
        else
            Labels["Status"].Text = "Status: OFFLINE"
            Labels["Status"].TextColor3 = Color3.fromRGB(220, 20, 20)
            Labels["Status"].BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        end
    end)

    TextBoxes["Prediction"].FocusLost:Connect(function()
        local num = tonumber(TextBoxes["Prediction"].Text)
        if num then prediction = num end
    end)

    TextBoxes["Smoothness"].FocusLost:Connect(function()
        local num = tonumber(TextBoxes["Smoothness"].Text)
        if num then smoothness = num end
    end)

    local oldVisible = states.GuiVisible
    RunService.RenderStepped:Connect(function()
        if states.GuiVisible ~= oldVisible then
            ScreenGui.Enabled = states.GuiVisible
            oldVisible = states.GuiVisible
        end
    end)
end

return Gui
