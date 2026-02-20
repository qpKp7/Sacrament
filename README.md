# Sacrament

## Quick Start

```lua
local url = "[https://raw.githubusercontent.com/qpKp7/Sacrament/main/loader.lua?cb=](https://raw.githubusercontent.com/qpKp7/Sacrament/main/loader.lua?cb=)" .. tostring(os.time())
local success, response = pcall(function() return game:HttpGet(url, true) end)
if success and type(response) == "string" then
    local loader = loadstring(response)
    if type(loader) == "function" then
        loader():Init()
    end
end
