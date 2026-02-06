-- Sacrament Universal Loader v3.1 - OFFLINE robusto (2026-02-06)
-- Single-file, detecta bloqueio de HTTP, fallback para bundle embutido
-- Repository: https://github.com/qpKp7/Sacrament

_G.SacramentModules = _G.SacramentModules or {}
_G.SacramentLoadedOrder = _G.SacramentLoadedOrder or {}

local HttpService = game:GetService("HttpService")  -- pode ser nil em alguns exploits

-- =============================================================================
-- Listas de módulos
-- =============================================================================
local CRITICAL_MODULES = {
    "config_defaults.lua",
    "input.lua",
    "gui/main_frame.lua",
    "gui/components/helpers.lua",
    "gui/components/section.lua",
    "gui/components/toggle.lua",
    "gui/components/input.lua"
}

local OPTIONAL_MODULES = {
    "gui/updater.lua"
}

local ALL_MODULES = {}
for _, v in ipairs(CRITICAL_MODULES) do table.insert(ALL_MODULES, v) end
for _, v in ipairs(OPTIONAL_MODULES) do table.insert(ALL_MODULES, v) end

-- =============================================================================
-- BUNDLE embutido (atualizado com correções no main_frame)
-- =============================================================================
local BUNDLE = {
["config_defaults.lua"] = [[
-- config_defaults.lua
local M = {}
M.Prediction = 0.135
M.Smoothness = 0.15
M.Keys = {
    Aimlock = Enum.KeyCode.E,
    Silent = Enum.KeyCode.Q,
    GUI = Enum.KeyCode.Insert
}
M.Theme = {
    Background = Color3.fromHex("08080E"),
    Panel = Color3.fromHex("0A0A12"),
    Accent = Color3.fromHex("C80000"),
    TextBright = Color3.fromHex("E0E0E0"),
    TextDim = Color3.fromHex("888888"),
    Stroke = Color3.fromRGB(200,0,0)
}
return M
]],

["input.lua"] = [[
-- input.lua
local UserInputService = game:GetService("UserInputService")
local M = {}
M.States = { Aimlock = false, Silent = false }

local cfg = _G.SacramentModules["config_defaults.lua"] or {Keys = {Aimlock = Enum.KeyCode.E, Silent = Enum.KeyCode.Q}}

function M.Init()
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        local key = input.KeyCode
        if key == cfg.Keys.Aimlock then
            M.States.Aimlock = not M.States.Aimlock
            print("[Sacrament] Aimlock:", M.States.Aimlock and "ON" or "OFF")
        elseif key == cfg.Keys.Silent then
            M.States.Silent = not M.States.Silent
            print("[Sacrament] Silent Aim:", M.States.Silent and "ON" or "OFF")
        end
    end)
end
return M
]],

["gui/components/helpers.lua"] = [[
-- gui/components/helpers.lua (mantido igual ao anterior)
local Helpers = {}
function Helpers.Create(name, class)
    local obj = Instance.new(class)
    obj.Name = name
    return obj
end
function Helpers.MakeTextLabel(text, size, color, font, alignment)
    local l = Instance.new("TextLabel")
    l.Size = size or UDim2.new(1,0,0,20)
    l.BackgroundTransparency = 1
    l.Text = text or ""
    l.TextColor3 = color or Color3.fromHex("E0E0E0")
    l.TextSize = 14
    l.Font = font or Enum.Font.GothamSemibold
    l.TextXAlignment = alignment or Enum.TextXAlignment.Left
    return l
end
function Helpers.ApplyUICorner(frame, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = frame
end
function Helpers.ApplyStroke(frame, thickness, color)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness or 1
    s.Color = color or Color3.fromHex("C80000")
    s.Transparency = 0.6
    s.Parent = frame
end
return Helpers
]],

["gui/components/section.lua"] = [[
-- gui/components/section.lua (mantido)
local Helpers = _G.SacramentModules["gui/components/helpers.lua"]
local Section = {}
function Section.Create(titleText)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 92)
    frame.BackgroundTransparency = 1
    local title = Helpers.MakeTextLabel(titleText, UDim2.new(1,0,0,22), nil, Enum.Font.GothamBold)
    title.Position = UDim2.new(0,8,0,6)
    title.Parent = frame
    return {Frame = frame}
end
return Section
]],

["gui/components/toggle.lua"] = [[
-- gui/components/toggle.lua (mantido, simplificado)
local Helpers = _G.SacramentModules["gui/components/helpers.lua"]
local Toggle = {}
function Toggle.Create(opts)
    opts = opts or {}
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,28)
    container.BackgroundTransparency = 1
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-40,1,0)
    label.BackgroundTransparency = 1
    label.Text = opts.Label or "Toggle"
    label.TextColor3 = Color3.fromHex("E0E0E0")
    label.TextSize = 14
    label.Font = Enum.Font.GothamSemibold
    label.Parent = container
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0,20,0,20)
    box.Position = UDim2.new(1,-26,0.5,-10)
    box.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Helpers.ApplyUICorner(box, 6)
    Helpers.ApplyStroke(box, 1.2)
    box.Parent = container
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0,0,0,0)
    fill.Position = UDim2.new(0.1,0,0.1,0)
    fill.BackgroundColor3 = Color3.fromHex("C80000")
    Helpers.ApplyUICorner(fill, 4)
    fill.Parent = box
    local state = opts.Initial or false
    local function update()
        fill:TweenSize(state and UDim2.new(0.8,0,0.8,0) or UDim2.new(), "Out", "Quad", 0.15, true)
    end
    update()
    box.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            update()
            if opts.OnToggle then opts.OnToggle(state) end
        end
    end)
    return {Container = container, Set = function(_,v) state=v update() end}
end
return Toggle
]],

["gui/components/input.lua"] = [[
-- gui/components/input.lua (mantido)
local Helpers = _G.SacramentModules["gui/components/helpers.lua"]
local Input = {}
function Input.Create(opts)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.48,0,0,40)
    container.BackgroundTransparency = 1
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,18)
    label.BackgroundTransparency = 1
    label.Text = opts.Label or "Input"
    label.TextColor3 = Color3.fromHex("AAAAAA")
    label.TextSize = 13
    label.Parent = container
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1,0,0,22)
    box.Position = UDim2.new(0,0,0,18)
    box.BackgroundColor3 = Color3.fromRGB(15,15,15)
    box.TextColor3 = Color3.fromHex("FFFFFF")
    box.PlaceholderText = opts.Placeholder or ""
    box.Text = tostring(opts.Initial or "")
    Helpers.ApplyUICorner(box, 6)
    Helpers.ApplyStroke(box, 1)
    box.Parent = container
    return {Container = container, Get = function() return box.Text end}
end
return Input
]],

["gui/main_frame.lua"] = [[
-- gui/main_frame.lua (CORRIGIDO: parentagem, alias Init/Toggle)
local Helpers = _G.SacramentModules["gui/components/helpers.lua"]
local Section = _G.SacramentModules["gui/components/section.lua"]
local Toggle = _G.SacramentModules["gui/components/toggle.lua"]
local InputComp = _G.SacramentModules["gui/components/input.lua"]
local cfg = _G.SacramentModules["config_defaults.lua"]
local states = _G.SacramentModules["input.lua"].States

local M = {}
M.Gui = nil
M.Enabled = false

function M.Create()
    if M.Gui then return M end

    local screen = Instance.new("ScreenGui")
    screen.Name = "SacramentGUI"
    screen.ResetOnSpawn = false
    screen.IgnoreGuiInset = true

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0,360,0,440)
    main.Position = UDim2.new(0.5,-180,0.5,-220)
    main.BackgroundColor3 = cfg.Theme.Background
    main.Active = true
    main.Draggable = true
    Helpers.ApplyUICorner(main, 12)
    Helpers.ApplyStroke(main, 1.5)
    main.Parent = screen

    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-20,0,50)
    title.Position = UDim2.new(0,10,0,10)
    title.BackgroundTransparency = 1
    title.Text = "SACRAMENT AIMLOCK"
    title.TextColor3 = cfg.Theme.Accent
    title.TextSize = 24
    title.Font = Enum.Font.GothamBlack
    title.Parent = main

    -- Conteúdo (simplificado para teste)
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1,-20,1,-80)
    content.Position = UDim2.new(0,10,0,60)
    content.BackgroundTransparency = 1
    content.Parent = main

    -- PVP CONTROLS
    local pvp = Section.Create("PVP CONTROLS")
    pvp.Frame.Parent = content
    pvp.Frame.Position = UDim2.new(0,0,0,0)

    Toggle.Create({Label = "Aimlock Toggle", Initial = states.Aimlock, OnToggle = function(v) states.Aimlock = v end}).Container.Parent = pvp.Frame
    Toggle.Create({Label = "Silent Aim", Initial = states.Silent, OnToggle = function(v) states.Silent = v end}).Container.Parent = pvp.Frame

    -- Status
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1,-20,0,30)
    status.Position = UDim2.new(0,10,1,-40)
    status.BackgroundTransparency = 1
    status.Text = "Status: OFFLINE"
    status.TextColor3 = cfg.Theme.Accent
    status.TextSize = 16
    status.Font = Enum.Font.GothamBold
    status.Parent = main

    M.Gui = screen
    M.StatusText = status

    game:GetService("RunService").RenderStepped:Connect(function()
        local any = states.Aimlock or states.Silent
        status.Text = any and "Status: LOCK ACTIVE" or "Status: OFFLINE"
        status.TextColor3 = any and Color3.fromRGB(0,255,80) or cfg.Theme.Accent
    end)

    return M
end

function M.Toggle()
    if not M.Gui then M.Create() end
    M.Enabled = not M.Enabled
    M.Gui.Enabled = M.Enabled
    print("[Sacrament] GUI:", M.Enabled and "ON" or "OFF")
end

function M.Init()
    M.Create()
    local success = pcall(function()
        M.Gui.Parent = game:GetService("CoreGui")
    end)
    if not success then
        pcall(function()
            M.Gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        end)
    end
    M.Gui.Enabled = false
    return M
end

return M
]],

["gui/updater.lua"] = [[return {} -- opcional por enquanto]]
}

-- =============================================================================
-- Funções auxiliares
-- =============================================================================
local function normalize_path(p)
    p = p:gsub("\\", "/"):gsub("^src/", ""):gsub("^/", "")
    return p
end

local function http_is_blocked()
    if not HttpService then return true end
    local ok = pcall(function()
        HttpService:GetAsync("https://httpbin.org/status/200")
    end)
    return not ok
end

local function load_bundle()
    local loaded = 0
    local missing_critical = {}

    for _, path in ipairs(ALL_MODULES) do
        local norm = normalize_path(path)
        local code = BUNDLE[norm] or BUNDLE[path]
        if not code then
            if table.find(CRITICAL_MODULES, path) then
                table.insert(missing_critical, path)
            end
            continue
        end
        local fn, err = loadstring(code, "@Sacrament/"..path)
        if not fn then
            print("[Sacrament] loadstring falhou:", path, err)
            continue
        end
        local ok, res = pcall(fn)
        if not ok then
            print("[Sacrament] execução falhou:", path, res)
            continue
        end
        _G.SacramentModules[path] = res
        table.insert(_G.SacramentLoadedOrder, path)
        loaded = loaded + 1
    end

    -- Alias importante
    if _G.SacramentModules["gui/main_frame.lua"] then
        _G.SacramentModules["gui/init.lua"] = _G.SacramentModules["gui/main_frame.lua"]
    end

    if #missing_critical > 0 then
        warn("[Sacrament] Módulos CRÍTICOS faltando: " .. table.concat(missing_critical, ", "))
        return false, missing_critical
    end

    print("[Sacrament] OFFLINE: carregados " .. loaded .. "/" .. #ALL_MODULES)
    return true
end

-- =============================================================================
-- Execução principal
-- =============================================================================
print("[Sacrament Loader] Iniciando...")

local success, reason = false, "desconhecido"

if not http_is_blocked() then
    print("[Sacrament] Tentando modo ONLINE...")
    -- Aqui poderia tentar carregar via Http, mas como está bloqueado na maioria, pulamos direto pro bundle
    -- (você pode reativar se quiser testar em executor que permita)
end

print("[Sacrament] Usando modo OFFLINE (bundle embutido)")
success, reason = load_bundle()

if not success then
    error("[Sacrament] Falha crítica: módulos essenciais ausentes. " .. tostring(reason))
end

-- =============================================================================
-- Inicialização
-- =============================================================================
local input = _G.SacramentModules["input.lua"]
if input and input.Init then
    pcall(input.Init)
    print("[Sacrament] Input inicializado")
end

local gui = _G.SacramentModules["gui/init.lua"] or _G.SacramentModules["gui/main_frame.lua"]
if gui and gui.Init then
    pcall(gui.Init)
    print("[Sacrament] GUI inicializada")
end

-- Conexão Insert (anti-duplicata)
if _G.__Sacrament_InsertConn then
    _G.__Sacrament_InsertConn:Disconnect()
end

_G.__Sacrament_InsertConn = game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        if gui and gui.Toggle then
            pcall(gui.Toggle)
        end
    end
end)

print("[Sacrament] Loader concluído. Aperte Insert para abrir GUI.")
print("E = Aimlock toggle | Q = Silent Aim toggle")
