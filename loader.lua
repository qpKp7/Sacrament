-- Sacrament Universal Loader v3.3 - OFFLINE + Diagnóstico GUI Completo (06/02/2026)
-- Single-file, bundle embutido, sem dependência de HttpGet

_G.SacramentModules = _G.SacramentModules or {}
_G.SacramentLoadedOrder = _G.SacramentLoadedOrder or {}

-- =============================================================================
-- Módulos críticos (sem eles = erro fatal)
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
-- BUNDLE completo (com correções de parenting, centralização e diagnóstico)
-- =============================================================================
local BUNDLE = {
["config_defaults.lua"] = [[
local M = {}
M.Prediction = 0.135
M.Smoothness = 0.15
M.Keys = { Aimlock = Enum.KeyCode.E, Silent = Enum.KeyCode.Q, GUI = Enum.KeyCode.Insert }
M.Theme = {
    Background = Color3.fromHex("#08080E"),
    Panel = Color3.fromHex("#0A0A12"),
    Accent = Color3.fromHex("#C80000"),
    TextBright = Color3.fromHex("#E0E0E0"),
    TextDim = Color3.fromHex("#888888"),
    StatusGreen = Color3.fromRGB(0, 255, 100),
    StatusRed = Color3.fromRGB(200, 0, 0)
}
return M
]],

["input.lua"] = [[
local UserInputService = game:GetService("UserInputService")
local M = {}
M.States = { Aimlock = false, Silent = false }

function M.Init()
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        local key = input.KeyCode
        if key == Enum.KeyCode.E then
            M.States.Aimlock = not M.States.Aimlock
            print("[Input] Aimlock:", M.States.Aimlock and "ON" or "OFF")
        elseif key == Enum.KeyCode.Q then
            M.States.Silent = not M.States.Silent
            print("[Input] Silent Aim:", M.States.Silent and "ON" or "OFF")
        end
    end)
end
return M
]],

["gui/components/helpers.lua"] = [[
local Helpers = {}
function Helpers.ApplyUICorner(obj, r) local c = Instance.new("UICorner", obj) c.CornerRadius = UDim.new(0, r or 8) end
function Helpers.ApplyStroke(obj, t, c) local s = Instance.new("UIStroke", obj) s.Thickness = t or 1 s.Color = c or Color3.fromHex("#C80000") s.Transparency = 0.6 end
return Helpers
]],

["gui/components/section.lua"] = [[
local Section = {}
function Section.Create(parent, title)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1,0,0,50)
    f.BackgroundTransparency = 1
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Color3.fromHex("#FFFFFF")
    lbl.TextSize = 16
    lbl.Font = Enum.Font.GothamBold
    return f
end
return Section
]],

["gui/components/toggle.lua"] = [[
local Toggle = {}
function Toggle.Create(parent, label, key, getStateFn)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1,0,0,30)
    f.BackgroundTransparency = 1
    local cb = Instance.new("Frame", f)
    cb.Size = UDim2.new(0,20,0,20)
    cb.Position = UDim2.new(0,10,0.5,-10)
    cb.BackgroundColor3 = Color3.fromHex("#1A1A1A")
    local fill = Instance.new("Frame", cb)
    fill.Size = UDim2.new(1,-4,1,-4)
    fill.Position = UDim2.new(0,2,0,2)
    fill.BackgroundColor3 = Color3.fromHex("#C80000")
    fill.BackgroundTransparency = 1
    game:GetService("RunService").RenderStepped:Connect(function()
        fill.BackgroundTransparency = getStateFn() and 0 or 1
    end)
    local txt = Instance.new("TextLabel", f)
    txt.Size = UDim2.new(1,-50,1,0)
    txt.Position = UDim2.new(0,40,0,0)
    txt.BackgroundTransparency = 1
    txt.Text = label .. " (" .. key .. ")"
    txt.TextColor3 = Color3.fromHex("#E0E0E0")
    txt.TextSize = 14
    return f
end
return Toggle
]],

["gui/components/input.lua"] = [[
local Input = {}
function Input.Create(parent, label, default)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(0.48,0,0,40)
    f.BackgroundTransparency = 1
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1,0,0,20)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromHex("#AAAAAA")
    local box = Instance.new("TextBox", f)
    box.Size = UDim2.new(1,0,0,20)
    box.Position = UDim2.new(0,0,0,20)
    box.BackgroundColor3 = Color3.fromHex("#0F0F0F")
    box.TextColor3 = Color3.fromHex("#FFFFFF")
    box.Text = default
    box.PlaceholderText = default
    return f
end
return Input
]],

["gui/main_frame.lua"] = [[
local Helpers = _G.SacramentModules["gui/components/helpers.lua"]
local Section = _G.SacramentModules["gui/components/section.lua"]
local Toggle = _G.SacramentModules["gui/components/toggle.lua"]
local InputComp = _G.SacramentModules["gui/components/input.lua"]
local cfg = _G.SacramentModules["config_defaults.lua"]
local states = _G.SacramentModules["input.lua"].States

local M = {}
M.ScreenGui = nil
M.Main = nil
M.Enabled = false

function M:Create()
    if self.ScreenGui then self.ScreenGui:Destroy() print("[GUI] GUI antiga destruída") end

    local sg = Instance.new("ScreenGui")
    sg.Name = "SacramentGUI"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 9999
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local parented = false
    pcall(function()
        sg.Parent = game:GetService("CoreGui")
        print("[GUI] Parentado em CoreGui")
        parented = true
    end)
    if not parented then
        pcall(function()
            sg.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
            print("[GUI] Fallback: Parentado em PlayerGui")
            parented = true
        end)
    end
    if not parented then warn("[GUI] FALHA: Nenhum parent válido") end

    self.ScreenGui = sg

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.Size = UDim2.new(0, 360, 0, 440)
    main.BackgroundColor3 = cfg.Theme.Background
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    Helpers.ApplyUICorner(main, 12)
    Helpers.ApplyStroke(main, 1.5)
    main.Parent = sg
    self.Main = main

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1,0,0,60)
    title.BackgroundTransparency = 1
    title.Text = "SACRAMENT AIMLOCK"
    title.TextColor3 = cfg.Theme.Accent
    title.TextSize = 28
    title.Font = Enum.Font.GothamBlack
    title.TextStrokeTransparency = 0.7

    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1,-20,1,-80)
    content.Position = UDim2.new(0,10,0,70)
    content.BackgroundTransparency = 1

    Section.Create(content, "PVP CONTROLS")
    Toggle.Create(content, "Aimlock Toggle", "E", function() return states.Aimlock end)
    Toggle.Create(content, "Silent Aim", "Q", function() return states.Silent end)
    InputComp.Create(content, "Prediction", "0.135")
    InputComp.Create(content, "Smoothness", "0.15")

    local status = Instance.new("TextLabel", main)
    status.Size = UDim2.new(1,0,0,30)
    status.Position = UDim2.new(0,0,1,-30)
    status.BackgroundTransparency = 1
    status.Text = "Status: OFFLINE"
    status.TextColor3 = cfg.Theme.Accent
    status.TextSize = 16
    status.Font = Enum.Font.GothamBold
    self.StatusText = status

    game:GetService("RunService").RenderStepped:Connect(function()
        local anyOn = states.Aimlock or states.Silent
        status.Text = anyOn and "LOCK ACTIVE" or "OFFLINE"
        status.TextColor3 = anyOn and cfg.Theme.StatusGreen or cfg.Theme.StatusRed
    end)

    print("[GUI Sanity Dump]")
    print("  Parent: " .. (sg.Parent and sg.Parent.Name or "NIL"))
    print("  Enabled: " .. tostring(sg.Enabled))
    print("  DisplayOrder: " .. sg.DisplayOrder)
    print("  Main Position: " .. tostring(main.Position))
    print("  Main Size: " .. tostring(main.Size))
    if main.AbsolutePosition then print("  AbsolutePos: " .. tostring(main.AbsolutePosition)) end

    return sg
end

function M:Toggle()
    if not self.ScreenGui then self:Create() end
    self.Enabled = not self.Enabled
    self.ScreenGui.Enabled = self.Enabled
    print("[GUI Toggle] Enabled agora = " .. tostring(self.Enabled))
end

function M:Init()
    self:Create()
    self.ScreenGui.Enabled = true
    self.ScreenGui.DisplayOrder = 9999
    print("[GUI Init] FORÇADA VISÍVEL + DisplayOrder 9999 para diagnóstico")
end

return M
]],

["gui/updater.lua"] = [[return { Start = function() end } -- opcional]]
}

-- =============================================================================
-- Funções de carregamento
-- =============================================================================
local function normalize(p)
    return p:gsub("\\", "/"):gsub("^src/", "")
end

local function load_bundle()
    local loaded = 0
    local missing = {}

    for _, path in ipairs(ALL_MODULES) do
        local code = BUNDLE[normalize(path)] or BUNDLE[path]
        if not code then
            if table.find(CRITICAL_MODULES, path) then
                table.insert(missing, path)
            end
            continue
        end
        local fn, err = loadstring(code, "@" .. path)
        if not fn then continue end
        local ok, res = pcall(fn)
        if not ok then continue end
        _G.SacramentModules[path] = res
        loaded = loaded + 1
    end

    -- Alias essencial
    _G.SacramentModules["gui/init.lua"] = _G.SacramentModules["gui/main_frame.lua"]

    if #missing > 0 then
        warn("[Loader] CRÍTICOS faltando: " .. table.concat(missing, ", "))
        return false
    end

    print("[Loader] OFFLINE: " .. loaded .. "/" .. #ALL_MODULES .. " carregados")
    return true
end

-- =============================================================================
-- Execução principal
-- =============================================================================
print("[Loader] Iniciando v3.3...")

load_bundle()

local input = _G.SacramentModules["input.lua"]
if input and input.Init then
    pcall(input.Init)
    print("[Loader] Input inicializado")
end

local gui = _G.SacramentModules["gui/init.lua"] or _G.SacramentModules["gui/main_frame.lua"]
if gui and gui.Init then
    pcall(gui.Init)
    print("[Loader] GUI Init chamado")
end

-- Força GUI visível pós-init (diagnóstico)
if gui and gui.ScreenGui then
    gui.ScreenGui.Enabled = true
    gui.ScreenGui.DisplayOrder = 9999
    print("[Loader] FORCED GUI visible pós-init para debug")
end

-- Conexão Insert (anti-duplicata)
if _G.__SacramentInsertConn then
    _G.__SacramentInsertConn:Disconnect()
end

_G.__SacramentInsertConn = game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        print("[Loader] Insert detectado → chamando Toggle()")
        if gui and gui.Toggle then
            pcall(gui.Toggle)
        end
    end
end)

print("[Loader] Pronto. Aperte Insert para toggle.")
print("Veja o [GUI Sanity Dump] no console para diagnosticar visibilidade.")
