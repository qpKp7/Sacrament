-- src/gui/init.lua
-- Ponto de entrada da GUI Sacrament Aim System
-- Versão flat: sem require(script.Parent), usa módulos pré-carregados via _G.SacramentModules

local Gui = {}

local RunService = game:GetService("RunService")

-- ================================================
-- Importação FLAT dos módulos (injetados pelo loader)
-- ================================================
local Modules = _G.SacramentModules or {}
local MainFrame   = Modules["gui/main_frame"]
local Updater     = Modules["gui/updater"]

local Helpers     = Modules["gui/components/helpers"]
local Section     = Modules["gui/components/section"]
local Toggle      = Modules["gui/components/toggle"]
local InputComp   = Modules["gui/components/input"]  -- renomeado para evitar conflito com input.lua

if not MainFrame or not Updater or not Helpers or not Section or not Toggle or not InputComp then
    warn("[Sacrament GUI] Módulos da GUI não foram injetados corretamente pelo loader")
    return Gui  -- sai cedo para não crashar tudo
end

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

    if not self.ScreenGui then
        warn("[Sacrament GUI] ScreenGui não foi criada pelo MainFrame")
        return
    end

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
    self.PredictionBox = InputComp.Create(configContent, "Prediction:", "0.135", "Prediction")
    self.SmoothnessBox = InputComp.Create(configContent, "Smoothness:", "0.15", "Smoothness")

    -- TARGET INFO (placeholder por enquanto)
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

    -- Inicia o updater para visual dinâmico (RenderStepped)
    Updater:Start(self)

    -- Começa oculta
    self.ScreenGui.Enabled = false
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.IgnoreGuiInset = true

    print("[Sacrament GUI] Inicialização completa - use Insert para abrir")
end

-- ================================================
-- Funções expostas
-- ================================================

function Gui:Toggle(visible)
    if self.ScreenGui then
        self.ScreenGui.Enabled = visible
        print("[Sacrament GUI] Visibilidade alterada para: " .. tostring(visible))
    else
        warn("[Sacrament GUI] Tentou toggle mas ScreenGui é nil")
    end
end

-- Atualiza TARGET INFO (futuro target.lua chama isso)
function Gui:UpdateTargetInfo(playerName, thumbnailUrl, distanceStr, healthStr)
    if not self.NameLabel then return end

    if playerName and playerName ~= "" then
        self.NameLabel.Text = playerName
        local infoText = distanceStr or ""
        if healthStr then
            infoText = infoText .. (distanceStr and " | " or "") .. "HP: " .. healthStr
        end
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

-- Getters para configs (aimlock/silent vão usar)
function Gui:GetPrediction()
    if self.PredictionBox and self.PredictionBox.TextBox then
        local val = tonumber(self.PredictionBox.TextBox.Text)
        return val or 0.135
    end
    return 0.135
end

function Gui:GetSmoothness()
    if self.SmoothnessBox and self.SmoothnessBox.TextBox then
        local val = tonumber(self.SmoothnessBox.TextBox.Text)
        return val or 0.15
    end
    return 0.15
end

-- Cleanup (opcional)
function Gui:Destroy()
    if Updater and Updater.Stop then Updater:Stop() end
    if MainFrame and MainFrame.Destroy then MainFrame:Destroy() end
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    print("[Sacrament GUI] Destruída")
end

return Gui
