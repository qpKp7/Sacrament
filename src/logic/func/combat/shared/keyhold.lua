--!strict
--[[
    SACRAMENT | Shared KeyHold Utility
    Verifica em tempo real se a tecla de atalho está SENDO SEGURADA.
    Ideal para mecânicas "Legit" onde a função só ativa enquanto o botão está pressionado.
--]]

local UserInputService = game:GetService("UserInputService")
local KeyHold = {}

--[[
    Verifica se a tecla ou botão do rato passado está fisicamente pressionado neste exato frame.
    
    @param bind: O valor da bind que vem do teu UIState (Enum.KeyCode, Enum.UserInputType ou string).
    @return boolean: true se estiver a ser SEGURADA, false se foi solta.
--]]
function KeyHold.IsHeld(bind: any): boolean
    if not bind then return false end

    -- 1. Se a bind for um Enum (Formato nativo)
    if typeof(bind) == "EnumItem" then
        if bind.EnumType == Enum.KeyCode then
            if bind == Enum.KeyCode.Unknown then return false end
            return UserInputService:IsKeyDown(bind)
            
        elseif bind.EnumType == Enum.UserInputType then
            if bind == Enum.UserInputType.MouseButton1 then
                return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
            elseif bind == Enum.UserInputType.MouseButton2 then
                return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
            elseif bind == Enum.UserInputType.MouseButton3 then
                return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton3)
            end
        end

    -- 2. Se a UI guarda as Binds como texto ("Q", "MB2", "RightClick")
    elseif type(bind) == "string" then
        local upperBind = string.upper(bind)
        
        -- Mapeamento rápido para cliques do rato
        if upperBind == "MB2" or upperBind == "RIGHTCLICK" or upperBind == "MOUSEBUTTON2" then
            return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        elseif upperBind == "MB1" or upperBind == "LEFTCLICK" or upperBind == "MOUSEBUTTON1" then
            return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        end

        -- Mapeamento para teclado
        local success, keyCode = pcall(function()
            return Enum.KeyCode[upperBind]
        end)
        
        if success and keyCode then
            return UserInputService:IsKeyDown(keyCode)
        end
    end

    return false
end

return KeyHold
