--!strict
--[[
    SACRAMENT | Shared WallCheck
    Verifica se há obstáculos (paredes) entre a câmara (ou uma origem específica) e o alvo.
    Stateless: Pode ser usado em simultâneo pelo Aimlock, Silent Aim e ESP sem conflitos.
--]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local WallCheck = {}

--[[
    Verifica a visibilidade de uma parte do corpo.
    
    @param targetPart: A parte do inimigo que queremos verificar (ex: Head, Torso).
    @param origin: (Opcional) De onde o raio é disparado. Por defeito, usa a posição da Câmara.
    @param ignoreList: (Opcional) Lista de instâncias extra a ignorar no raycast (ex: partes transparentes).
    
    @return boolean: true se o alvo estiver visível, false se houver uma parede no caminho.
--]]
function WallCheck.IsVisible(targetPart: BasePart, origin: Vector3?, ignoreList: {Instance}?): boolean
    local camera = Workspace.CurrentCamera
    if not camera or not targetPart then return false end

    -- Se o módulo que chamou (ex: SilentAim) não fornecer uma origem, usamos a Câmara
    local startPos = origin or camera.CFrame.Position
    local direction = targetPart.Position - startPos

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    
    -- Ignora sempre o corpo do jogador local e a câmara para o raio não colidir connosco mesmos
    local filter = {LocalPlayer.Character, camera}
    
    -- Adiciona instâncias extra caso o Aimlock/SilentAim peçam
    if ignoreList then
        for _, inst in ipairs(ignoreList) do
            table.insert(filter, inst)
        end
    end
    
    rayParams.FilterDescendantsInstances = filter
    rayParams.IgnoreWater = true -- Ignorar água costuma ser padrão para evitar bugs de tiro

    -- Lança o raio matemático
    local result = Workspace:Raycast(startPos, direction, rayParams)

    -- Se o raio não bater em nada (chegou ao fim) OU se bateu numa parte do próprio alvo, está visível!
    if not result or (result.Instance and result.Instance:IsDescendantOf(targetPart.Parent)) then
        return true
    end

    -- Bateu numa parede ou noutro objeto
    return false
end

return WallCheck
