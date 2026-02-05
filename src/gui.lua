-- Sacrament GUI - Dark Professional (versão corrigida pra aparecer com certeza)

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
    
    -- Força PlayerGui pra evitar block de CoreGui no Xeno
    ScreenGui.Parent = lp:WaitForChild("PlayerGui")
    print("[GUI Debug] Parentado em PlayerGui")

    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 340, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -170, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = true  -- começa visível pra teste
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

    -- Aimlock checkbox
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

    -- CONFIGS (o resto continua igual ao que você colou, mas cortei pra não repetir tudo aqui)

    print("[GUI Debug] GUI criada e MainFrame.Visible = true")
    return ScreenGui
end

function Gui:Init(inputModule)
    print("[GUI Debug] Init chamado")
    local states = inputModule.States
    if not states then
        warn("[GUI] States não encontrados no InputModule")
        return
    end

    ScreenGui = createGui()

    -- Força visibilidade inicial pra teste
    ScreenGui.Enabled = true
    MainFrame.Visible = true

    RunService.RenderStepped:Connect(function()
        if not MainFrame or not MainFrame.Parent then return end

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

    print("[GUI Debug] GUI inicializada - deve aparecer agora")
end

return Gui
