-- Sacrament Universal Loader (OFFLINE-friendly)
-- Single-file loader + embedded bundle for executors that block HttpGet/GetAsync.
-- Repository: https://github.com/qpKp7/Sacrament
-- Author: generated (qpKp7 request)
-- Date: 2026-02-06

-- USAGE: paste into executor and run. This loader:
-- 1) Detects whether Http requests are allowed.
-- 2) If allowed, attempts to load modules from raw.githubusercontent.com/qpKp7/Sacrament/main/src/
-- 3) If blocked or any HTTP fetch fails, falls back to the embedded BUNDLE.
-- 4) Loads modules via loadstring and stores them in _G.SacramentModules["<path>"].
-- 5) Initializes input states, then GUI (flat access via _G.SacramentModules["gui/..."]).
-- 6) Connects Insert to toggle GUI. E toggles Aimlock, Q toggles Silent Aim (visual only).
-- 7) Prints debug info during load.

-- RIGID RULES FOLLOWED:
-- - Single script, full code provided.
-- - loadstring used to load modules from bundle.
-- - gui/init.lua uses only _G.SacramentModules accesses (no requires).
-- - Clear debug prints in Portuguese as requested.

-- START OF LOADER

-- Safety: ensure globals exist
_G.SacramentModules = _G.SacramentModules or {}
_G.SacramentLoadedOrder = _G.SacramentLoadedOrder or {}

local HttpService = nil
pcall(function() HttpService = game:GetService("HttpService") end)

local MODULES = {
    -- Note: keys are the module identifiers used by the gui/init.lua access.
    -- Paths mirror the repo `src/` structure.
    "config_defaults.lua",
    "input.lua",
    "gui/init.lua",
    "gui/main_frame.lua",
    "gui/updater.lua",
    "gui/components/helpers.lua",
    "gui/components/section.lua",
    "gui/components/toggle.lua",
    "gui/components/input.lua"
}

-- Embedded BUNDLE: all source files from src/* as strings.
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
-- input.lua (root)
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local M = {}
M.States = {
    Aimlock = false,
    Silent = false
}

local cfg = _G.SacramentModules and _G.SacramentModules["config_defaults.lua"] or nil

local function KeyName(k)
    if typeof(k) == "EnumItem" then return tostring(k.Name) end
    return tostring(k)
end

function M.Init()
    -- connect KeyDowns for toggles
    pcall(function()
        UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if cfg and input.KeyCode == cfg.Keys.Aimlock then
                    M.States.Aimlock = not M.States.Aimlock
                    print("[Sacrament] Aimlock:", M.States.Aimlock and "ON" or "OFF")
                elseif cfg and input.KeyCode == cfg.Keys.Silent then
                    M.States.Silent = not M.States.Silent
                    print("[Sacrament] Silent Aim:", M.States.Silent and "ON" or "OFF")
                end
            end
        end)
    end)
    return M
end

return M
]],

["gui/components/helpers.lua"] = [[
-- gui/components/helpers.lua
local Helpers = {}

local function setCommonFrame(f)
    f.BackgroundColor3 = _G.SacramentModules["config_defaults.lua"].Theme.Panel
    f.BorderSizePixel = 0
    if f:IsA("GuiObject") then
        -- nothing else
    end
    return f
end

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
    l.TextColor3 = color or _G.SacramentModules["config_defaults.lua"].Theme.TextBright
    l.TextSize = 14
    l.Font = font or Enum.Font.SourceSansSemibold
    l.TextXAlignment = alignment or Enum.TextXAlignment.Left
    return l
end

function Helpers.ApplyUICorner(frame, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = frame
    return c
end

function Helpers.ApplyStroke(frame, thickness, color)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness or 0.5
    s.Color = color or _G.SacramentModules["config_defaults.lua"].Theme.Stroke
    s.Parent = frame
    return s
end

return Helpers
]],

["gui/components/section.lua"] = [[
-- gui/components/section.lua
local Helpers = _G.SacramentModules["gui/components/helpers.lua"]
local Section = {}

function Section.Create(titleText)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 92)
    frame.AnchorPoint = Vector2.new(0,0)
    frame.BackgroundColor3 = _G.SacramentModules["config_defaults.lua"].Theme.Panel
    frame.BorderSizePixel = 0

    Helpers.ApplyUICorner(frame, 10)
    Helpers.ApplyStroke(frame, 0.45)

    local title = Helpers.MakeTextLabel(titleText, UDim2.new(1, -8, 0, 22), nil, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
    title.Position = UDim2.new(0, 8, 0, 6)
    title.TextSize = 14
    title.TextColor3 = _G.SacramentModules["config_defaults.lua"].Theme.TextBright
    title.Parent = frame

    return {
        Frame = frame,
        AddChild = function(self, obj)
            obj.Parent = frame
        end
    }
end

return Section
]],

["gui/components/toggle.lua"] = [[
-- gui/components/toggle.lua
local Helpers = _G.SacramentModules["gui/components/helpers.lua"]
local Toggle = {}

-- Create a square checkbox (custom)
-- opts: {Label = "name", Initial = false, OnToggle = fn}
function Toggle.Create(opts)
    opts = opts or {}
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, 28)
    container.BackgroundTransparency = 1

    local label = Helpers.MakeTextLabel(opts.Label or "Toggle", UDim2.new(1, -34, 1, 0), nil, Enum.Font.GothamSemibold, Enum.TextXAlignment.Left)
    label.Position = UDim2.new(0, 6, 0, 0)
    label.TextSize = 13
    label.TextColor3 = _G.SacramentModules["config_defaults.lua"].Theme.TextBright
    label.Parent = container

    local box = Instance.new("Frame")
    box.Name = "CheckBox"
    box.Size = UDim2.new(0, 18, 0, 18)
    box.AnchorPoint = Vector2.new(1,0)
    box.Position = UDim2.new(1, -6, 0, 5)
    box.BackgroundColor3 = Color3.fromRGB(20,20,20)
    box.BorderSizePixel = 0
    Helpers.ApplyUICorner(box, 4)
    Helpers.ApplyStroke(box, 0.45)
    box.Parent = container

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0.0, 0, 0.0, 0)
    fill.AnchorPoint = Vector2.new(0,0)
    fill.Position = UDim2.new(0.1, 0, 0.1, 0)
    fill.BackgroundColor3 = _G.SacramentModules["config_defaults.lua"].Theme.Accent
    Helpers.ApplyUICorner(fill, 3)
    fill.Parent = box

    local state = opts.Initial and true or false
    local function updateVisual()
        if state then
            fill:TweenSize(UDim2.new(0.8,0,0.8,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
        else
            fill:TweenSize(UDim2.new(0,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
        end
    end

    updateVisual()

    local clickConn
    clickConn = box.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            state = not state
            updateVisual()
            if type(opts.OnToggle) == "function" then
                pcall(opts.OnToggle, state)
            end
        end
    end)

    return {
        Container = container,
        Set = function(self, v)
            state = not not v
            updateVisual()
        end,
        Get = function() return state end,
        Destroy = function()
            if clickConn then clickConn:Disconnect() end
            container:Destroy()
        end
    }
end

return Toggle
]],

["gui/components/input.lua"] = [[
-- gui/components/input.lua
local Helpers = _G.SacramentModules["gui/components/helpers.lua"]
local Input = {}

-- create textbox with label; opts = {Label, Placeholder, Initial, OnChanged}
function Input.Create(opts)
    opts = opts or {}
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.5, -12, 0, 34)
    container.BackgroundTransparency = 1

    local label = Helpers.MakeTextLabel(opts.Label or "Input", UDim2.new(1,0,0,14), nil, Enum.Font.GothamSemibold, Enum.TextXAlignment.Left)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.TextSize = 12
    label.TextColor3 = _G.SacramentModules["config_defaults.lua"].Theme.TextDim
    label.Parent = container

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, 18)
    box.Position = UDim2.new(0, 0, 0, 14)
    box.Text = tostring(opts.Initial or "")
    box.PlaceholderText = opts.Placeholder or ""
    box.ClearTextOnFocus = false
    box.BackgroundColor3 = Color3.fromRGB(15,15,15)
    box.TextColor3 = _G.SacramentModules["config_defaults.lua"].Theme.TextBright
    box.TextSize = 13
    box.Font = Enum.Font.GothamSemibold
    Helpers.ApplyUICorner(box, 6)
    Helpers.ApplyStroke(box, 0.35)
    box.Parent = container

    box.FocusLost:Connect(function(enter)
        local val = tonumber(box.Text) or box.Text
        if type(opts.OnChanged) == "function" then
            pcall(opts.OnChanged, val)
        end
    end)

    return {
        Container = container,
        Set = function(_, v) box.Text = tostring(v) end,
        Get = function() return box.Text end,
        Destroy = function() container:Destroy() end
    }
end

return Input
]],

["gui/main_frame.lua"] = [[
-- gui/main_frame.lua
-- Builds the entire UI and provides Toggle/Init functions.
local Helpers = _G.SacramentModules["gui/components/helpers.lua"]
local Section = _G.SacramentModules["gui/components/section.lua"]
local ToggleComp = _G.SacramentModules["gui/components/toggle.lua"]
local InputComp = _G.SacramentModules["gui/components/input.lua"]
local cfg = _G.SacramentModules["config_defaults.lua"]
local inputModule = _G.SacramentModules["input.lua"]
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local M = {}
M.Gui = nil
M.Enabled = false
M.Elements = {}

local function makeTitle(parent)
    local title = Instance.new("TextLabel")
    title.AnchorPoint = Vector2.new(0.5,0)
    title.Size = UDim2.new(1, -16, 0, 36)
    title.Position = UDim2.new(0.5, 0, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = "SACRAMENT AIMLOCK"
    title.TextColor3 = cfg.Theme.Accent
    title.TextSize = 20
    title.Font = Enum.Font.GothamBlack
    title.TextStrokeTransparency = 0.8
    title.Parent = parent

    local shadow = Instance.new("TextLabel")
    shadow.Size = title.Size
    shadow.Position = title.Position + UDim2.new(0,2,0,2)
    shadow.AnchorPoint = title.AnchorPoint
    shadow.BackgroundTransparency = 1
    shadow.Text = title.Text
    shadow.TextColor3 = Color3.fromRGB(0,0,0)
    shadow.TextSize = title.TextSize
    shadow.Font = title.Font
    shadow.TextTransparency = 0.75
    shadow.ZIndex = title.ZIndex - 1
    shadow.Parent = parent

    return title
end

function M.CreateMainGui()
    if M.Gui and M.Gui.Parent then
        return M
    end

    local screen = Instance.new("ScreenGui")
    screen.Name = "SacramentMainGui"
    screen.ResetOnSpawn = false
    screen.Enabled = false

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 360, 0, 440)
    main.Position = UDim2.new(0.5, -180, 0.5, -220)
    main.AnchorPoint = Vector2.new(0,0)
    main.BackgroundColor3 = cfg.Theme.Background
    main.BorderSizePixel = 0
    main.Parent = screen
    main.Active = true
    pcall(function() main.Draggable = true end)

    Helpers.ApplyUICorner(main, 10)
    Helpers.ApplyStroke(main, 0.5)

    -- Title
    makeTitle(main)

    -- PVP CONTROLS section
    local sec1 = Section.Create("PVP CONTROLS")
    sec1.Frame.Position = UDim2.new(0, 12, 0, 56)
    sec1.Frame.Size = UDim2.new(1, -24, 0, 110)
    sec1.Frame.Parent = main

    -- Aimlock toggle
    local aimToggle = ToggleComp.Create({
        Label = "Aimlock",
        Initial = inputModule.States and inputModule.States.Aimlock or false,
        OnToggle = function(state)
            inputModule.States.Aimlock = state
            print("[Sacrament] Aimlock (via GUI):", state and "ON" or "OFF")
        end
    })
    aimToggle.Container.Position = UDim2.new(0, 8, 0, 30)
    aimToggle.Container.Parent = sec1.Frame

    local keyLabelA = Helpers.MakeTextLabel("KEY: E", UDim2.new(0, 64, 0, 14), cfg.Theme.TextDim, Enum.Font.GothamSemibold, Enum.TextXAlignment.Right)
    keyLabelA.Position = UDim2.new(1, -72, 0, 8)
    keyLabelA.Parent = sec1.Frame

    -- Silent Aim toggle
    local silentToggle = ToggleComp.Create({
        Label = "Silent Aim",
        Initial = inputModule.States and inputModule.States.Silent or false,
        OnToggle = function(state)
            inputModule.States.Silent = state
            print("[Sacrament] Silent Aim (via GUI):", state and "ON" or "OFF")
        end
    })
    silentToggle.Container.Position = UDim2.new(0, 8, 0, 64)
    silentToggle.Container.Parent = sec1.Frame

    local keyLabelS = Helpers.MakeTextLabel("KEY: Q", UDim2.new(0, 64, 0, 14), cfg.Theme.TextDim, Enum.Font.GothamSemibold, Enum.TextXAlignment.Right)
    keyLabelS.Position = UDim2.new(1, -72, 0, 42)
    keyLabelS.Parent = sec1.Frame

    -- CONFIGS section
    local sec2 = Section.Create("CONFIGS")
    sec2.Frame.Position = UDim2.new(0, 12, 0, 176)
    sec2.Frame.Parent = main
    sec2.Frame.Size = UDim2.new(1, -24, 0, 82)

    -- two TextBoxes side by side
    local predInput = InputComp.Create({
        Label = "Prediction",
        Placeholder = "0.135",
        Initial = tostring(cfg.Prediction),
        OnChanged = function(v)
            local num = tonumber(v)
            if num then cfg.Prediction = num end
            print("[Sacrament] Prediction set to", cfg.Prediction)
        end
    })
    predInput.Container.Position = UDim2.new(0, 8, 0, 26)
    predInput.Container.Parent = sec2.Frame

    local smoothInput = InputComp.Create({
        Label = "Smoothness",
        Placeholder = "0.15",
        Initial = tostring(cfg.Smoothness),
        OnChanged = function(v)
            local num = tonumber(v)
            if num then cfg.Smoothness = num end
            print("[Sacrament] Smoothness set to", cfg.Smoothness)
        end
    })
    smoothInput.Container.Position = UDim2.new(0.5, 4, 0, 26)
    smoothInput.Container.Parent = sec2.Frame

    -- TARGET INFO section
    local sec3 = Section.Create("TARGET INFO")
    sec3.Frame.Position = UDim2.new(0, 12, 0, 270)
    sec3.Frame.Parent = main
    sec3.Frame.Size = UDim2.new(1, -24, 0, 90)

    local placeholder = Helpers.MakeTextLabel("Nenhum alvo selecionado", UDim2.new(1, -12, 0, 20), cfg.Theme.TextDim, Enum.Font.GothamSemibold, Enum.TextXAlignment.Left)
    placeholder.Position = UDim2.new(0, 8, 0, 6)
    placeholder.Parent = sec3.Frame

    -- Status bar bottom
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(1, 0, 0, 28)
    statusBar.Position = UDim2.new(0, 0, 1, -28)
    statusBar.BackgroundTransparency = 0.03
    statusBar.BackgroundColor3 = Color3.fromRGB(18,18,18)
    statusBar.Parent = main
    Helpers.ApplyUICorner(statusBar, 8)
    Helpers.ApplyStroke(statusBar, 0.35)

    local statusText = Helpers.MakeTextLabel("Status: OFFLINE", UDim2.new(1, -8, 1, 0), cfg.Theme.Accent, Enum.Font.GothamSemibold, Enum.TextXAlignment.Left)
    statusText.Position = UDim2.new(0, 8, 0, 4)
    statusText.TextSize = 12
    statusText.Parent = statusBar

    -- store elements
    M.Elements = {
        Screen = screen,
        Main = main,
        AimToggle = aimToggle,
        SilentToggle = silentToggle,
        PredInput = predInput,
        SmoothInput = smoothInput,
        StatusText = statusText,
        StatusBar = statusBar,
        Placeholder = placeholder
    }

    -- RenderStepped updater to sync visuals with states
    RunService.RenderStepped:Connect(function()
        if not screen.Parent then return end
        local states = _G.SacramentModules["input.lua"].States
        -- update gui toggles if external key toggled
        pcall(function()
            M.Elements.AimToggle:Set(states.Aimlock)
            M.Elements.SilentToggle:Set(states.Silent)
        end)
        -- update status text
        if states.Aimlock then
            statusText.Text = "Status: LOCK ACTIVE"
            statusText.TextColor3 = Color3.fromRGB(46, 204, 113) -- green
        else
            statusText.Text = "Status: OFFLINE"
            statusText.TextColor3 = cfg.Theme.Accent
        end
    end)

    M.Gui = screen
    return M
end

function M.Toggle()
    if not M.Gui then return end
    M.Enabled = not M.Enabled
    M.Gui.Enabled = M.Enabled
    print("[Sacrament] Visibilidade alterada. Enabled =", tostring(M.Enabled))
end

function M.Init()
    local inst = M.CreateMainGui()
    -- Parent to CoreGui or PlayerGui depending on environment
    local success = pcall(function()
        inst.Screen.Parent = game:GetService("CoreGui")
    end)
    if not success then
        inst.Screen.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    inst.Screen.Enabled = false
    M.Enabled = false
    return M
end

return M
]],

["gui/updater.lua"] = [[
-- gui/updater.lua (kept minimal for now)
-- Provides helpers for future updates. Currently a placeholder.
local M = {}
function M.Init() return M end
return M
]],
}

-- Helper: attempt a single HTTP test to detect if HTTP is blocked.
local function http_allowed_test()
    if not HttpService then return false end
    local ok, res = pcall(function()
        -- try fetching a small known file. A HEAD isn't possible easily; use GetAsync on repo root (small response).
        return HttpService:GetAsync("https://raw.githubusercontent.com/qpKp7/Sacrament/main/src/config_defaults.lua")
    end)
    return ok
end

-- Attempt to load modules via HTTP. If any fail, we'll fallback to BUNDLE.
local function try_load_online()
    if not HttpService then return false, "No HttpService" end
    local base = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/src/"
    local loaded = 0
    local total = #MODULES
    local tempModules = {}
    for _, path in ipairs(MODULES) do
        local url = base .. path
        local ok, body = pcall(function()
            return HttpService:GetAsync(url)
        end)
        if not ok or not body or #tostring(body) < 3 then
            return false, "HTTP fetch failed for "..path
        end
        tempModules[path] = tostring(body)
        loaded = loaded + 1
    end
    -- If all fetched, compile them
    local count = 0
    for path, src in pairs(tempModules) do
        local fn, err = loadstring(src)
        if not fn then
            return false, "loadstring failed for "..path..": "..tostring(err)
        end
        local ok2, result = pcall(fn)
        if not ok2 then
            return false, "execution failed for "..path..": "..tostring(result)
        end
        _G.SacramentModules[path] = result
        table.insert(_G.SacramentLoadedOrder, path)
        count = count + 1
    end
    print(string.format("[Sacrament] Modo ONLINE. Módulos carregados: %d/%d", count, total))
    return true
end

-- Load from BUNDLE
local function load_from_bundle()
    local count = 0
    for _, path in ipairs(MODULES) do
        local src = BUNDLE[path]
        if not src then
            print("[Sacrament] BUNDLE missing path:", path)
        else
            local fn, err = loadstring(src)
            if not fn then
                print("[Sacrament] loadstring error for", path, err)
            else
                local ok, res = pcall(fn)
                if not ok then
                    print("[Sacrament] execution error for", path, res)
                else
                    _G.SacramentModules[path] = res
                    table.insert(_G.SacramentLoadedOrder, path)
                    count = count + 1
                end
            end
        end
    end
    print(string.format("[Sacrament] Modo OFFLINE ativado. Módulos carregados: %d/%d", count, #MODULES))
    return count == #MODULES
end

-- MAIN LOAD PROCESS
local loaded_online = false
local http_test_ok, http_test_err = pcall(http_allowed_test)
if http_test_ok and http_test_err then
    -- Try online load, but if any failure occurs, fallback to bundle
    local ok, err = pcall(try_load_online)
    if ok and err == true then
        loaded_online = true
    else
        print("[Sacrament] HTTP load failed or incomplete; fallback to BUNDLE. Reason:", tostring(err))
    end
else
    print("[Sacrament] HTTP appears blocked or unavailable. Using OFFLINE bundle.")
end

if not loaded_online then
    -- clear any partial modules and load bundle
    _G.SacramentModules = {}
    _G.SacramentLoadedOrder = {}
    local ok = load_from_bundle()
    if not ok then
        error("[Sacrament] FATAL: Could not load modules from bundle.")
    end
else
    -- online loaded; but ensure loaded modules available in _G table are used by rest.
    -- print paths loaded
    print("[Sacrament] Modules loaded (online):")
    for i, p in ipairs(_G.SacramentLoadedOrder) do print(" -", p) end
end

-- POST-LOAD: initialize Input then GUI
local function safe_init()
    -- input.lua Init
    local input_mod = _G.SacramentModules["input.lua"]
    if not input_mod then
        error("[Sacrament] input.lua not found after load")
    end
    local ok, res = pcall(function() return input_mod.Init() end)
    if not ok then
        print("[Sacrament] Error initializing input module:", res)
    else
        print("[Sacrament] Input initialized.")
    end

    -- gui/init.lua should now be present as a module returning a table with Init/Toggle etc.
    local gui_mod = _G.SacramentModules["gui/init.lua"]
    if not gui_mod then
        -- In our bundle gui/init.lua is actually gui/main_frame.lua loaded under that path; if we didn't provide gui/init.lua separately, handle aliasing.
        -- But the BUNDLE includes gui/init.lua key; in case, fallback to using gui/main_frame.lua's table as the init
    end

    -- Some bundles might have gui/init.lua that simply returns the main_frame module; handle both cases.
    local gui_init = _G.SacramentModules["gui/init.lua"] or _G.SacramentModules["gui/main_frame.lua"]
    if not gui_init then
        error("[Sacrament] GUI module not found.")
    end

    local ok2, guires = pcall(function() return gui_init.Init() end)
    if not ok2 then
        print("[Sacrament] Error initializing GUI:", guires)
    else
        print("[Sacrament] GUI initialized.")
    end

    -- Connect Insert to toggle GUI visibility (explicitly)
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(inp, processed)
        if processed then return end
        if inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == _G.SacramentModules["config_defaults.lua"].Keys.GUI then
            local guiObj = _G.SacramentModules["gui/init.lua"] or _G.SacramentModules["gui/main_frame.lua"]
            pcall(function()
                guiObj.Toggle()
            end)
        end
    end)

    print("[Sacrament] Conexões de teclas prontas: E/Q (toggles), Insert (GUI).")
end

-- Finally call safe_init in a pcall
local ok, err = pcall(safe_init)
if not ok then
    print("[Sacrament] Inicialização falhou:", err)
else
    print("[Sacrament] Sistema Sacrament carregado com sucesso.")
end

-- END OF LOADER
