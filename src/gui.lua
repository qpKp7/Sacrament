-- Sacrament - GUI Module (dark theme status display) - v0.1 corrigido

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Gui = {}
local ScreenGui = nil
local Frame = nil
local Labels = {}

local function createGui()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local coreGui = game:GetService("CoreGui")
    
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SacramentStatus"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Enabled = false  -- Começa desabilitada, toggle depois
    
    -- Tenta CoreGui primeiro (mais resistente), fallback PlayerGui
    local parentSuccess = pcall(function()
        ScreenGui.Parent = coreGui
    end)
    
    if not parentSuccess then
        warn("[GUI] CoreGui parent falhou, usando PlayerGui")
        ScreenGui.Parent = playerGui
    end
    
    Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 220, 0, 140)
    Frame.Position = UDim2.new(0.5, -110, 0.5, -70)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = Frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 60)
    stroke.Thickness = 1
    stroke.Parent = Frame
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "Sacrament v0.1"
    title.TextColor3 = Color3.fromRGB(220, 220, 220)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = Frame
    
    -- Labels de status
    local yOffset = 40
    for _, name in ipairs({"Aimlock", "Silent Aim"}) do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 25)
        label.Position = UDim2.new(0, 10, 0, yOffset)
        label.BackgroundTransparency = 1
        label.Text = name .. ": OFF"
        label.TextColor3 = Color3.fromRGB(180, 180, 180)
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = Frame
        
        Labels[name] = label
        yOffset = yOffset + 30
    end
    
    print("[GUI] ScreenGui criada e parentada")
    return ScreenGui
end

function Gui:Init(inputModule)
    local states = inputModule.States
    if not states then
        warn("[GUI] States não encontrados no InputModule")
        return
    end
    
    ScreenGui = createGui()
    
    -- Sincroniza Enabled inicial (começa false, toggle via Insert)
    ScreenGui.Enabled = states.GuiVisible
    
    local oldGuiVisible = states.GuiVisible
    
    -- ÚNICO RenderStepped: atualiza labels + visibility quando muda
    RunService.RenderStepped:Connect(function()
        if not ScreenGui or not Frame or not Frame.Parent then 
            warn("[GUI Debug] Frame ou ScreenGui destruído?")
            return 
        end
        
        -- Atualiza labels
        Labels["Aimlock"].Text = "Aimlock: " .. (states.AimlockEnabled and "ON" or "OFF")
        Labels["Aimlock"].TextColor3 = states.AimlockEnabled and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
        
        Labels["Silent Aim"].Text = "Silent Aim: " .. (states.SilentAimEnabled and "ON" or "OFF")
        Labels["Silent Aim"].TextColor3 = states.SilentAimEnabled and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
        
        -- Sincroniza visibility (só quando muda)
        if states.GuiVisible ~= oldGuiVisible then
            ScreenGui.Enabled = states.GuiVisible
            oldGuiVisible = states.GuiVisible
            print("[GUI Debug] Visibility atualizada para: " .. (states.GuiVisible and "ON" or "OFF"))
        end
    end)
    
    print("[GUI] Inicializado - visibility inicial: " .. (states.GuiVisible and "ON" or "OFF"))
end

function Gui:Toggle(visible)
    if ScreenGui then
        ScreenGui.Enabled = visible
        print("[GUI] Toggle manual chamado: " .. (visible and "ON" or "OFF"))
    end
end

return Gui
