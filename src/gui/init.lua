-- src/gui/init.lua
-- Ponto de entrada da GUI do Sacrament Aim System
-- Responsável por inicializar tudo, conectar states e expor funções úteis

local Gui = {}

-- Serviços
local RunService = game:GetService("RunService")

-- Módulos internos da GUI
local MainFrame   = require(script.Parent.main_frame)
local Updater     = require(script.Parent.updater)  -- vamos criar depois

-- Componentes reutilizáveis
local Helpers     = require(script.Parent.components.helpers)
local Section     = require(script.Parent.components.section)
local Toggle      = require(script.Parent.components.toggle)
local Input       = require(script.Parent.components.input)

-- Referências globais (para fácil acesso em outros módulos)
Gui.ScreenGui     = nil
Gui.MainFrame     = nil
Gui.States        = nil
Gui.AimlockToggle = nil
Gui.SilentToggle  = nil
Gui.PredictionBox = nil
Gui.SmoothnessBox = nil
Gui.TargetLabel   = nil
Gui.AvatarImage   = nil
Gui.StatusText    = nil

-- ================================================
-- Inicialização completa da GUI
-- ================================================
function Gui:Init(statesModule)
    if not statesModule then
        warn("[Sacrament GUI] States module não fornecido na inicialização")
        return
    end

    self.States = statesModule

    -- Cria a estrutura principal
    MainFrame:Create()
    self.ScreenGui = MainFrame.ScreenGui
    self.MainFrame = MainFrame.Main

    -- Adiciona as seções e componentes no Content
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

    -- TARGET INFO
    local targetContent = Section.Create(content, "TARGET INFO")
    local targetFrame = Instance.new("Frame")
    targetFrame.Size = UDim2.new(1, 0, 0, 90)
    targetFrame.BackgroundTransparency = 1
    targetFrame.Parent = targetContent

    -- Avatar placeholder (preparado)
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Size = UDim2.new(0, 80, 0, 80)
    avatar.Position = UDim2.new(0, 10, 0.5, -40)
    avatar.BackgroundTransparency = 1
    avatar.Image = ""
    avatar.Visible = false  -- ativar quando tiver target
    avatar.Parent = targetFrame

    Helpers.UICorner(avatar, 40)  -- círculo perfeito

    local targetLabel = Instance.new("TextLabel")
    targetLabel.Name = "TargetLabel"
    targetLabel.Size = UDim2.new(1, -100, 1, 0)
    targetLabel.Position = UDim2.new(0, 100, 0, 0)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "Nenhum alvo selecionado"
    targetLabel.TextColor3 = Helpers.COLORS.TextSecondary
    targetLabel.TextSize = 18
    targetLabel.Font = Helpers.FONTS.Normal
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.TextYAlignment = Enum.TextYAlignment.Center
    targetLabel.TextWrapped = true
    targetLabel.Parent = targetFrame

    self.TargetLabel = targetLabel
    self.AvatarImage = avatar

    -- Conecta o updater para atualizações visuais em tempo real
    Updater:Start(self)

    -- Começa oculta
    self.ScreenGui.Enabled = false

    print("[Sacrament GUI] Inicialização completa - Insert para abrir")
end

-- ================================================
-- Funções expostas para outros módulos
-- ================================================

-- Toggle visibilidade da GUI
function Gui:Toggle(visible)
    if self.ScreenGui then
        self.ScreenGui.Enabled = visible
        print("[Sacrament GUI] Visible set to: " .. tostring(visible))
    end
end

-- Atualiza info do alvo (chamado por target.lua)
function Gui:UpdateTargetInfo(playerName, thumbnailUrl, distance)
    if not self.TargetLabel then return end

    if playerName and playerName ~= "" then
        self.TargetLabel.Text = playerName .. (distance and (" (" .. distance .. ")") or "")
        if thumbnailUrl and thumbnailUrl ~= "" then
            self.AvatarImage.Image = thumbnailUrl
            self.AvatarImage.Visible = true
        end
    else
        self.TargetLabel.Text = "Nenhum alvo selecionado"
        self.AvatarImage.Visible = false
        self.AvatarImage.Image = ""
    end
end

-- Atualiza status manualmente (opcional)
function Gui:UpdateStatus(active)
    if self.StatusText then
        if active then
            self.StatusText.Text = "Status: LOCK ACTIVE"
            self.StatusText.TextColor3 = Helpers.COLORS.StatusOn
        else
            self.StatusText.Text = "Status: OFFLINE"
            self.StatusText.TextColor3 = Helpers.COLORS.StatusOff
        end
    end
end

-- Destroy tudo (cleanup)
function Gui:Destroy()
    if Updater and Updater.Stop then Updater:Stop() end
    if MainFrame and MainFrame.Destroy then MainFrame:Destroy() end
    self.ScreenGui = nil
    print("[Sacrament GUI] Destruída")
end

return Gui
