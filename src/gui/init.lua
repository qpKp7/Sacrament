-- src/gui/init.lua
-- Ponto de entrada principal da GUI Sacrament Aim System
-- Inicializa tudo, conecta states e expõe funções para o resto do projeto

local Gui = {}

local RunService = game:GetService("RunService")

-- Módulos da GUI
local MainFrame   = require(script.Parent.main_frame)
local Updater     = require(script.Parent.updater)

-- Componentes
local Helpers     = require(script.Parent.components.helpers)
local Section     = require(script.Parent.components.section)
local Toggle      = require(script.Parent.components.toggle)
local Input       = require(script.Parent.components.input)

-- Referências expostas
Gui.ScreenGui     = nil
Gui.States        = nil

Gui.AimlockToggle = nil
Gui.SilentToggle  = nil
Gui.PredictionBox = nil
Gui.SmoothnessBox = nil

Gui.NameLabel     = nil
Gui.InfoLabel     = nil
Gui.AvatarImage   = nil
Gui.StatusText    = nil

-- ================================================
-- Inicializa a GUI completa
-- ================================================
function Gui:Init(statesModule)
    if not statesModule then
        warn("[Sacrament GUI] States module não foi passado na inicialização")
        return
    end

    self.States = statesModule

    -- Cria a estrutura principal
    MainFrame:Create()
    self.ScreenGui = MainFrame.ScreenGui

    -- Adiciona seções e componentes
    local content = MainFrame.Content

    -- PVP CONTROLS
    local pvpContent = Section.Create(content, "PVP CONTROLS")
    self.AimlockToggle = Toggle.Create(
        pvpContent,
        "Aimlock Toggle",
        "E",
        function() return self.States.AimlockEnabled end
    )
    self.SilentToggle = Toggle.Create(
        pvpContent,
        "Silent Aim",
        "Q",
        function() return self.States.SilentAimEnabled end
    )

    -- CONFIGS
    local configContent = Section.Create(content, "CONFIGS")
    self.PredictionBox = Input.Create(configContent, "Prediction:", "0.135", "Prediction")
    self.SmoothnessBox = Input.Create(configContent, "Smoothness:", "0.15", "Smoothness")

    -- TARGET INFO (melhorado: avatar + nome + info)
    local targetContent = Section.Create(content, "TARGET INFO")

    local targetFrame = Instance.new("Frame")
    targetFrame.Size = UDim2.new(1, 0, 0, 100)
    targetFrame.BackgroundTransparency = 1
    targetFrame.Parent = targetContent

    -- Avatar circular
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Size = UDim2.new(0, 80, 0, 80)
    avatar.Position = UDim2.new(0, 10, 0, 10)
    avatar.BackgroundTransparency = 1
    avatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    avatar.Visible = false
    avatar.Parent = targetFrame
    Helpers.UICorner(avatar, 40)

    -- Nome do alvo
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, -110, 0, 30)
    nameLabel.Position = UDim2.new(0, 100, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Nenhum alvo selecionado"
    nameLabel.TextColor3 = Helpers.COLORS.TextPrimary
    nameLabel.TextSize = 18
    nameLabel.Font = Helpers.FONTS.Normal
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextWrapped = true
    nameLabel.Parent = targetFrame

    -- Info (distância / health)
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "InfoLabel"
    infoLabel.Size = UDim2.new(1, -110, 0, 20)
    infoLabel.Position = UDim2.new(0, 100, 0, 45)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = ""
    infoLabel.TextColor3 = Helpers.COLORS.TextSecondary
    infoLabel.TextSize = 14
    infoLabel.Font = Helpers.FONTS.Small
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Parent = targetFrame

    self.NameLabel   = nameLabel
    self.InfoLabel   = infoLabel
    self.AvatarImage = avatar

    -- Inicia o updater para visual dinâmico
    Updater:Start(self)

    -- Começa oculta
    self.ScreenGui.Enabled = false

    print("[Sacrament GUI] Inicialização completa - use Insert para abrir")
end

-- ================================================
-- Funções expostas
-- ================================================

function Gui:Toggle(visible)
    if self.ScreenGui then
        self.ScreenGui.Enabled = visible
        print("[Sacrament GUI] Visibilidade alterada para: " .. tostring(visible))
    end
end

-- Atualiza TARGET INFO (chamado pelo target.lua)
function Gui:UpdateTargetInfo(playerName, thumbnailUrl, distanceStr, healthStr)
    if not self.NameLabel then return end

    if playerName and playerName ~= "" then
        self.NameLabel.Text = playerName
        local infoText = ""
        if distanceStr then infoText = infoText .. distanceStr end
        if healthStr then infoText = infoText .. (distanceStr and " | " or "") .. "HP: " .. healthStr end
        self.InfoLabel.Text = infoText

        if thumbnailUrl and thumbnailUrl ~= "" then
            self.AvatarImage.Image = thumbnailUrl
            self.AvatarImage.Visible = true
        end
    else
        self.NameLabel.Text = "Nenhum alvo selecionado"
        self.InfoLabel.Text = ""
        self.AvatarImage.Visible = false
        self.AvatarImage.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    end
end

-- Getters para configs (usado no aimlock)
function Gui:GetPrediction()
    if self.PredictionBox and self.PredictionBox.Text then
        local val = tonumber(self.PredictionBox.Text)
        return val and val or 0.135
    end
    return 0.135
end

function Gui:GetSmoothness()
    if self.SmoothnessBox and self.SmoothnessBox.Text then
        local val = tonumber(self.SmoothnessBox.Text)
        return val and val or 0.15
    end
    return 0.15
end

-- Cleanup
function Gui:Destroy()
    if Updater and Updater.Stop then Updater:Stop() end
    if MainFrame and MainFrame.Destroy then MainFrame:Destroy() end
    self.ScreenGui = nil
    print("[Sacrament GUI] Destruída completamente")
end

return Gui
