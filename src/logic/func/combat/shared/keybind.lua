--!strict
--[[
    SACRAMENT | Shared Keybind Utility
    Normaliza a verificação de inputs, permitindo que módulos como Aimlock 
    e Silent Aim verifiquem facilmente se uma tecla (Teclado) ou botão (Rato) está pressionado.
--]]

local UserInputService = game:GetService("UserInputService")
local Keybind = {}

--[[
    Verifica se a tecla ou botão do rato passado está fisicamente pressionado.
    
    @param bind: O valor da bind que vem do teu UIState (pode ser Enum.KeyCode, Enum.UserInputType ou string).
    @return boolean: true se estiver a ser pressionado, false caso contrário.
--]]
function Keybind.IsPressed(bind: any): boolean
    if not bind then return false end

    -- 1. Se a bind for um Enum (O formato mais correto)
    if typeof(bind) == "EnumItem" then
        
        -- É uma tecla do teclado? (Ex: Enum.KeyCode.Q, Enum.KeyCode.E)
        if bind.EnumType == Enum.KeyCode then
            -- Evita bug de verificar a tecla Unknown
            if bind == Enum.KeyCode.Unknown then return false end
            return UserInputService:IsKeyDown(bind)
            
        -- É um botão do rato? (Ex: Enum.UserInputType.MouseButton2)
        elseif bind.EnumType == Enum.UserInputType then
            if bind == Enum.UserInputType.MouseButton1 then
                return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
            elseif bind == Enum.UserInputType.MouseButton2 then
                return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
            elseif bind == Enum.UserInputType.MouseButton3 then
                return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton3)
            end
        end

    -- 2. Se a tua UI guarda as Binds como texto ("Q", "MB2", "RightClick")
    elseif type(bind) == "string" then
        local upperBind = string.upper(bind)
        
        -- Tratamento para Rato em formato de texto
        if upperBind == "MB2" or upperBind == "RIGHTCLICK" or upperBind == "MOUSEBUTTON2" then
            return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        elseif upperBind == "MB1" or upperBind == "LEFTCLICK" or upperBind == "MOUSEBUTTON1" then
            return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        end

        -- Tratamento para Teclado em formato de texto
        local success, keyCode = pcall(function()
            return Enum.KeyCode[upperBind]
        end)
        
        if success and keyCode then
            return UserInputService:IsKeyDown(keyCode)
        end
    end

    return false
end

return Keybind
