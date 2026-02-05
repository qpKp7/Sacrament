-- Sacrament Loader -- 

local HttpService = game:GetService("HttpService")

local function HttpGet(url)
    if HttpService.HttpGetAsync then
        return HttpService:HttpGetAsync(url)
    elseif syn and syn.request then
        return syn.request({Url = url, Method = "GET"}).Body
    elseif request then
        return request({Url = url}).Body
    elseif httpget then
        return httpget(url)
    else
        error("[Sacrament Loader] No compatible HttpGet found.")
    end
end

local baseUrl = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/"

local function loadModule(path)
    local url = baseUrl .. path
    local success, result = pcall(HttpGet, url)
    if not success then
        warn("[Sacrament] Failed to fetch: " .. path .. " - " .. result)
        return nil
    end
    local func, err = loadstring(result)
    if not func then
        warn("[Sacrament] Loadstring error in " .. path .. ": " .. err)
        return nil
    end
    return func()
end

local Sacrament = {}

function Sacrament:Init()
    print("[Sacrament] Framework loaded - v0.1 dev")
    -- Carregar config e módulos aqui depois
    local Config = loadModule("src/config_defaults.lua")
    if Config then
        print("[Sacrament] Defaults loaded.")
    end
end

return Sacrament
