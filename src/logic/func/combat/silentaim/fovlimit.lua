--!strict
--[[
    SACRAMENT | FOV Limit Visuals
    Desenha o círculo perfeitamente sincronizado com as chaves da sua UI.
]]
local UserInputService = game:GetService("UserInputService")
local Import = (_G :: any).SacramentImport
local UIState = Import("state/uistate")
local Loop = Import("logic/core/loop")

local FOVLimit = {}
local circle: any = nil

function FOVLimit.Init()
    if circle then return end
    
    local success, err = pcall(function()
        circle = Drawing.new("Circle")
        circle.Color = Color3.fromRGB(255, 255, 255)
        circle.Thickness = 1.5
        circle.Filled = false
        circle.Transparency = 1
    end)

    if not success then return end

    Loop.BindToRender("SilentAim_FOV_Draw", function()
        if not circle then return end
        
        -- Lê exatamente os nomes que você colocou no silentaim.lua
        local isSilentEnabled = UIState.Get("SilentAimEnabled", false)
        local isFovVisible = UIState.Get("SilentAim_ShowFov", false)
        
        if isSilentEnabled and isFovVisible then
            circle.Visible = true
            circle.Radius = tonumber(UIState.Get("SilentAim_FovLimit", 150)) or 150
            local mousePos = UserInputService:GetMouseLocation()
            circle.Position = mousePos
        else
            circle.Visible = false
        end
    end)
end

function FOVLimit.Destroy()
    Loop.UnbindFromRender("SilentAim_FOV_Draw")
    if circle then
        pcall(function() circle:Remove() end)
        circle = nil
    end
end

return FOVLimit
