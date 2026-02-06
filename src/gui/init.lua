-- gui/init.lua - Ponto de entrada da GUI Sacrament (flat, sem requires relativos)
-- Atualizado 06/02/2026 - com diagnóstico de visibilidade + force show para teste

local Gui = {}

local RunService = game:GetService("RunService")

-- Importação flat dos módulos (injetados pelo loader)
local Modules = _G.SacramentModules or {}
local MainFrame   = Modules["gui/main_frame.lua"]
local Helpers     = Modules["gui/components/helpers.lua"]
local Section     = Modules["gui/components/section.lua"]
local Toggle      = Modules["gui/components/toggle.lua"]
local InputComp   = Modules["gui/components/input.lua"]
local Updater     = Modules["gui/updater.lua"] or {Start = function() end}  -- fallback se opcional

if not MainFrame or not Helpers or not Section or not Toggle or not InputComp then
    warn("[GUI] Módulos críticos da GUI não foram carregados pelo loader")
    return Gui
end

-- Referências
Gui.ScreenGui     = nil
Gui.MainFrame     = nil
Gui.StatusText    = nil
Gui.States        = nil

-- ================================================
-- Inicialização da GUI
-- ================================================
function Gui:Init(statesModule)
    if not statesModule then
        warn("[GUI] States module não fornecido")
        return
    end

    self.States = statesModule

    -- Cria a estrutura principal via main_frame
    MainFrame:Create()
    self.ScreenGui = MainFrame.ScreenGui
    self.MainFrame = MainFrame.Main

    if not self.ScreenGui or not self.MainFrame then
        warn("[GUI] ScreenGui ou MainFrame não criados")
        return
    end

    local content = MainFrame.Content or Instance.new("Frame", self.MainFrame)
    content.Size = UDim2.new(1, -20, 1, -80)
    content.Position = UDim2.new(0, 10, 0, 70)
    content.BackgroundTransparency = 1

    -- PVP CONTROLS
    local pvpSection = Section.Create(content, "PVP CONTROLS")
    pvpSection.Position = UDim2.new(0, 0, 0, 0)

    Toggle.Create(
        pvpSection,
        "Aimlock Toggle",
        "E",
        function() return self.States.States.Aimlock end
    )

    Toggle.Create(
        pvpSection,
        "Silent Aim",
        "Q",
        function() return self.States.States.Silent end
    )

    -- CONFIGS
    local configSection = Section.Create(content, "CONFIGS")
    configSection.Position = UDim2.new(0, 0, 0, 120)

    InputComp.Create(configSection, "Prediction:", "0.135")
    InputComp.Create(configSection, "Smoothness:", "0.15")

    -- TARGET INFO (placeholder)
    local targetSection = Section.Create(content, "TARGET INFO")
    targetSection.Position = UDim2.new(0, 0, 0, 240)

    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(1, -20, 0, 30)
    targetLabel.Position = UDim2.new(0, 10, 0, 10)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "Nenhum alvo selecionado"
    targetLabel.TextColor3 = Color3.fromHex("#888888")
    targetLabel.TextSize = 14
    targetLabel.Font = Enum.Font.GothamSemibold
    targetLabel.Parent = targetSection

    -- Status bar (já criado no main_frame, mas referenciamos aqui)
    self.StatusText = MainFrame.StatusText

    -- Inicia updater (RenderStepped para sync visual)
    if Updater and Updater.Start then
        Updater:Start(self)
    end

    -- Começa oculta, mas FORÇA visível para teste diagnóstico
    self.ScreenGui.Enabled = true
    self.ScreenGui.DisplayOrder = 9999
    self.ScreenGui.IgnoreGuiInset = true
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    print("[GUI] Inicialização completa")

    -- Dump de diagnóstico completo
    print("[GUI Sanity Dump]")
    print("  ScreenGui.Parent: " .. (self.ScreenGui.Parent and self.ScreenGui.Parent.Name or "NIL"))
    print("  ScreenGui.Enabled: " .. tostring(self.ScreenGui.Enabled))
    print("  DisplayOrder: " .. tostring(self.ScreenGui.DisplayOrder))
    print("  IgnoreGuiInset: " .. tostring(self.ScreenGui.IgnoreGuiInset))
    if self.MainFrame then
        print("  MainFrame.Position: " .. tostring(self.MainFrame.Position))
        print("  MainFrame.AnchorPoint: " .. tostring(self.MainFrame.AnchorPoint))
        print("  MainFrame.AbsoluteSize: " .. tostring(self.MainFrame.AbsoluteSize))
        print("  MainFrame.AbsolutePosition: " .. tostring(self.MainFrame.AbsolutePosition))
    else
        warn("  MainFrame não encontrado")
    end

    print("[GUI] FORÇADA VISÍVEL para diagnóstico - se não aparecer, veja Parent e Executor")
end

-- ================================================
-- Toggle da GUI
-- ================================================
function Gui:Toggle()
    if not self.ScreenGui then
        warn("[GUI Toggle] ScreenGui não existe")
        return
    end

    self.ScreenGui.Enabled = not self.ScreenGui.Enabled
    print("[GUI Toggle] Insert pressionado → Enabled agora = " .. tostring(self.ScreenGui.Enabled))

    if self.MainFrame then
        print("  Posição atual: " .. tostring(self.MainFrame.AbsolutePosition))
        print("  Tamanho atual: " .. tostring(self.MainFrame.AbsoluteSize))
    end
end

-- ================================================
-- Cleanup (opcional)
-- ================================================
function Gui:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
        print("[GUI] Destruída")
    end
end

return Gui
