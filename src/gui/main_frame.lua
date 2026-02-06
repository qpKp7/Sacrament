-- src/gui/main_frame.lua - Frame principal da GUI Sacrament Aim System
-- Tema dark underground: carvão #08080E, vermelho sangue #C80000
-- Atualizado 06/02/2026 - compatível com loader flat + diagnóstico completo
-- Flat access: _G.SacramentModules["gui/components/helpers.lua"] etc.

local MainFrame = {}
local Modules = _G.SacramentModules or {}

-- Importação flat dos componentes
local Helpers = Modules["gui/components/helpers.lua"]
local Section = Modules["gui/components/section.lua"]
local Toggle = Modules["gui/components/toggle.lua"]
local InputComp = Modules["gui/components/input.lua"]
local cfg = Modules["config_defaults.lua"]
local states = Modules["input.lua"] and Modules["input.lua"].States

-- Validar dependências críticas
if not Helpers or not cfg or not states then
    warn("[MainFrame] Dependências críticas não carregadas: Helpers/cfg/states")
    return MainFrame
end

-- Elementos da GUI
MainFrame.ScreenGui = nil
MainFrame.Main = nil
MainFrame.Content = nil
MainFrame.StatusText = nil
MainFrame.Enabled = false
MainFrame.Gui = nil
MainFrame.Elements = {}

-- ================================================
-- Criação da GUI principal (dark theme completo)
-- ================================================
function MainFrame:Create()
    -- Destroi GUI anterior se existir
    if self.ScreenGui then
        self.ScreenGui:Destroy()
        print("[MainFrame] GUI anterior destruída")
    end

    -- ScreenGui principal
    local sg = Instance.new("ScreenGui")
    sg.Name = "SacramentGUI"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 9999
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Parenting robusto (CoreGui → PlayerGui fallback)
    local parentSuccess = false
    pcall(function()
        sg.Parent = game:GetService("CoreGui")
        print("[MainFrame] ✓ Parentado em CoreGui")
        parentSuccess = true
    end)

    if not parentSuccess then
        local success2, playerGui = pcall(function()
            return game.Players.LocalPlayer:WaitForChild("PlayerGui", 3)
        end)
        if success2 and playerGui then
            sg.Parent = playerGui
            print("[MainFrame] ✓ Fallback: Parentado em PlayerGui")
            parentSuccess = true
        end
    end

    if not parentSuccess then
        warn("[MainFrame] ✗ FALHA TOTAL: Nenhum parent válido encontrado!")
        return nil
    end

    self.ScreenGui = sg

    -- Frame principal (360x440 centralizado, draggable)
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.Size = UDim2.new(0, 360, 0, 440)
    main.BackgroundColor3 = cfg.Theme.Background
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.ClipsDescendants = true
    Helpers.ApplyUICorner(main, 12)
    Helpers.ApplyStroke(main, 2, cfg.Theme.Accent)
    main.Parent = sg
    self.Main = main

    -- Título "SACRAMENT AIMLOCK" (GothamBlack vermelho sangue + sombra)
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -40, 0, 60)
    title.Position = UDim2.new(0, 20, 0, 15)
    title.BackgroundTransparency = 1
    title.Text = "SACRAMENT AIMLOCK"
    title.TextColor3 = cfg.Theme.Accent
    title.TextSize = 28
    title.Font = Enum.Font.GothamBlack
    title.TextStrokeTransparency = 0.7
    title.TextStrokeColor3 = Color3.new(0, 0, 0)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = main

    -- Container de conteúdo (padding 20px)
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -40, 1, -120)
    content.Position = UDim2.new(0, 20, 0, 80)
    content.BackgroundTransparency = 1
    content.Parent = main
    self.Content = content

    -- Status bar inferior (LOCK ACTIVE verde / OFFLINE vermelho)
    local statusBar = Instance.new("Frame")
    statusBar.Name = "StatusBar"
    statusBar.Size = UDim2.new(1, -20, 0, 30)
    statusBar.Position = UDim2.new(0, 10, 1, -45)
    statusBar.BackgroundColor3 = Color3.fromHex("#1A1A1A")
    statusBar.BorderSizePixel = 0
    Helpers.ApplyUICorner(statusBar, 8)
    Helpers.ApplyStroke(statusBar, 1, cfg.Theme.Accent)
    statusBar.Parent = main

    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, 0, 1, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Status: OFFLINE"
    statusText.TextColor3 = cfg.Theme.StatusRed
    statusText.TextSize = 16
    statusText.Font = Enum.Font.GothamBold
    statusText.TextXAlignment = Enum.TextXAlignment.Center
    statusText.Parent = statusBar
    self.StatusText = statusText

    -- Updater RenderStepped (sync toggles + status)
    game:GetService("RunService").RenderStepped:Connect(function()
        if not sg.Parent then return end
        local anyActive = states.Aimlock or states.Silent
        statusText.Text = anyActive and "Status: LOCK ACTIVE" or "Status: OFFLINE"
        statusText.TextColor3 = anyActive and cfg.Theme.StatusGreen or cfg.Theme.StatusRed
    end)

    -- ================================================
    -- API compatível com Loader (Init/Toggle/Gui)
    -- ================================================
    self.Gui = sg
    self.Elements = {
        Screen = sg,
        Main = main,
        Title = title,
        Content = content,
        StatusBar = statusBar,
        StatusText = statusText
    }
    self.Enabled = false

    -- Dump de sanity completo
    print("[MainFrame Sanity Dump]")
    print("  ✓ ScreenGui: " .. tostring(sg))
    print("  ✓ Parent: " .. (sg.Parent and sg.Parent.Name or "NIL"))
    print("  ✓ MainFrame: " .. tostring(main))
    print("  ✓ Position: " .. tostring(main.Position))
    print("  ✓ Size: " .. tostring(main.Size))
    print("  ✓ AbsoluteSize: " .. tostring(main.AbsoluteSize))
    print("  ✓ DisplayOrder: " .. sg.DisplayOrder)
    print("  ✓ Draggable: " .. tostring(main.Draggable))

    print("[MainFrame] ✓ Criação completa - GUI pronta para toggle")
    return sg
end

-- ================================================
-- Inicialização (chamada pelo loader)
-- ================================================
function MainFrame:Init()
    self:Create()
    -- Começa oculta (Insert toggle ativa)
    if self.ScreenGui then
        self.ScreenGui.Enabled = false
        self.Enabled = false
        print("[MainFrame] ✓ Init OK - GUI criada e oculta (Insert para abrir)")
    end
    return self
end

-- ================================================
-- Toggle visibilidade (Insert key)
-- ================================================
function MainFrame:Toggle(forceState)
    if not self.ScreenGui then
        warn("[MainFrame] Toggle: ScreenGui nil → criando...")
        self:Create()
    end

    if forceState ~= nil then
        self.Enabled = forceState
    else
        self.Enabled = not self.Enabled
    end

    self.ScreenGui.Enabled = self.Enabled
    print("[MainFrame Toggle] Insert → Enabled = " .. tostring(self.Enabled) .. " | Parent = " .. (self.ScreenGui.Parent and self.ScreenGui.Parent.Name or "NIL"))

    return self.Enabled
end

-- ================================================
-- Getters para aimlock/silent (futuro uso)
-- ================================================
function MainFrame:GetPrediction()
    return cfg.Prediction or 0.135
end

function MainFrame:GetSmoothness()
    return cfg.Smoothness or 0.15
end

-- ================================================
-- Cleanup
-- ================================================
function MainFrame:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
        print("[MainFrame] GUI destruída")
    end
    self.ScreenGui = nil
    self.Main = nil
end

return MainFrame
