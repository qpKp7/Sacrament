--!strict
local Sacrament = {}

function Sacrament:Init(adapter: any?)
    local cacheBuster = tostring(math.floor(os.clock() * 1000))
    local url = string.format("https://raw.githubusercontent.com/qpKp7/Sacrament/main/src/app/init.lua?cb=%s", cacheBuster)
    
    local success, response = pcall(function()
        return (game :: any):HttpGet(url, true)
    end)
    
    if not success or type(response) ~= "string" then
        return
    end
    
    local loadFn = loadstring(response)
    if type(loadFn) ~= "function" then
        return
    end
    
    local App = loadFn()
    
    if type(App) == "table" then
        if type(App.start) == "function" then
            App.start(adapter)
        elseif type(App.Start) == "function" then
            App.Start(adapter)
        end
    end
end

return Sacrament
