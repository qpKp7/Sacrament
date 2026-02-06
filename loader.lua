local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local BASE_URL = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/src/"

_G.SacramentModules = _G.SacramentModules or {}

local function loadModule(path)
    local success, content = pcall(HttpService.GetAsync, HttpService, BASE_URL .. path, true)
    if not success or not content then
        warn("[Sacrament Loader] Falha ao carregar: " .. path)
        return nil
    end

    local func, err = loadstring(content, "@Sacrament/" .. path)
    if not func then
        warn("[Sacrament Loader] loadstring falhou em " .. path .. " → " .. tostring(err))
        return nil
    end

    local module = func()
    _G.SacramentModules[path] = module
    return module
end

local function main()
    local modulesToLoad = {
        "config_defaults.lua",
        "input.lua",
        "gui/components/helpers.lua",
        "gui/components/section.lua",
        "gui/components/toggle.lua",
        "gui/components/input.lua",
        "gui/updater.lua",
        "gui/main_frame.lua",
        "gui/init.lua"
    }

    for _, path in ipairs(modulesToLoad) do
        loadModule(path)
    end

    local States = _G.SacramentModules["input.lua"]
    local Gui    = _G.SacramentModules["gui/init.lua"]

    if not States or not Gui then
        warn("[Sacrament Loader] Falha crítica: States ou Gui não carregados")
        return
    end

    if States.Init then
        States:Init(_G.SacramentModules["config_defaults.lua"])
    end

    if Gui.Init then
        Gui:Init(States)
    end

    -- Toggle da GUI via Insert
    local connection
    connection = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            if Gui and Gui.Toggle and Gui.ScreenGui then
                Gui:Toggle(not Gui.ScreenGui.Enabled)
            end
        end
    end)

    game:BindToClose(function()
        if connection then connection:Disconnect() end
    end)
end

pcall(main)
