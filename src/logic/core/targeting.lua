--!strict
--[[
    SACRAMENT | Targeting Core
    Motor matemático responsável por encontrar alvos válidos, checar paredes (Raycast),
    calcular distância no monitor (FOV) e aplicar as regras do "Blood Pact".
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local Import = (_G :: any).SacramentImport
local UIState = Import("state/uistate")

local LocalPlayer = Players.LocalPlayer
local Targeting = {}

-- =========================================================================
-- FUNÇÕES DE VALIDAÇÃO (Filtros Rápidos)
-- =========================================================================

-- Checa se o jogador é válido e está vivo
function Targeting.IsAlive(player: Player): boolean
    if not player or player == LocalPlayer then return false end
    
    local character = player.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end

    return true
end

-- Checa as regras de Proteção (O "Blood Pact" que criamos no menu Misc)
function Targeting.PassesBloodPact(player: Player): boolean
    -- Se o Blood Pact estiver desligado, todo mundo é alvo (retorna true)
    local masterBP = UIState.Get("Misc_BloodPact_Master", false)
    if not masterBP then return true end

    -- 1. Friend Check
    if UIState.Get("Misc_BP_FriendCheck", false) then
        local success, isFriend = pcall(function()
            return LocalPlayer:IsFriendsWith(player.UserId)
        end)
        if success and isFriend then return false end
    end

    -- 2. Name / Whitelist Check
    if UIState.Get("Misc_BP_NameCheck", false) then
        local nameList = UIState.Get("Misc_BP_NameList", {})
        if type(nameList) == "table" then
            for _, whitelistedName in ipairs(nameList) do
                if string.lower(player.Name) == string.lower(whitelistedName) or 
                   string.lower(player.DisplayName) == string.lower(whitelistedName) then
                    return false -- Protegido!
                end
            end
        end
    end

    -- 3. Group ID Check (Da Hood Crews / Guilds)
    if UIState.Get("Misc_BP_GroupCheck", false) then
        local groupList = UIState.Get("Misc_BP_GroupList", {})
        if type(groupList) == "table" then
            for _, groupIdStr in ipairs(groupList) do
                local groupId = tonumber(groupIdStr)
                if groupId then
                    local success, isInGroup = pcall(function()
                        return player:IsInGroup(groupId)
                    end)
                    if success and isInGroup then return false end
                end
            end
        end
    end

    -- 4. Basic Team Check (Roblox Teams)
    if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        return false
    end

    return true -- Não caiu em nenhuma proteção, pode atirar!
end

-- Checa se há paredes entre a Câmera e o Alvo usando Raycast
function Targeting.IsVisible(targetPart: BasePart, origin: Vector3?): boolean
    local camera = Workspace.CurrentCamera
    if not camera then return false end

    local rayOrigin = origin or camera.CFrame.Position
    local rayDirection = targetPart.Position - rayOrigin

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    -- Ignora o jogador local e a câmera
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, camera}
    rayParams.IgnoreWater = true

    local result = Workspace:Raycast(rayOrigin, rayDirection, rayParams)

    -- Se não bateu em nada, ou se bateu em alguma parte do próprio alvo, ele está visível
    if not result or result.Instance:IsDescendantOf(targetPart.Parent) then
        return true
    end

    return false
end

-- =========================================================================
-- FUNÇÃO PRINCIPAL: ENCONTRAR O ALVO (O "Aim")
-- =========================================================================

-- Retorna a parte do corpo do inimigo que está mais próxima do cursor do mouse
function Targeting.GetClosestToCursor(fovRadius: number, useWallCheck: boolean, targetParts: {string}): BasePart?
    local camera = Workspace.CurrentCamera
    if not camera then return nil end

    local mousePos = UserInputService:GetMouseLocation()
    local closestDistance = fovRadius
    local closestPart: BasePart? = nil

    for _, player in ipairs(Players:GetPlayers()) do
        if Targeting.IsAlive(player) and Targeting.PassesBloodPact(player) then
            local character = player.Character
            
            -- Testa cada parte do corpo permitida (ex: "Head", "HumanoidRootPart")
            for _, partName in ipairs(targetParts) do
                local part = character:FindFirstChild(partName) :: BasePart
                if part then
                    -- Converte a posição 3D do alvo para posição 2D na tela
                    local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                    
                    if onScreen then
                        -- Calcula a distância matemática entre o mouse e o alvo na tela
                        local distanceOnScreen = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                        -- Se estiver dentro do FOV e for o mais próximo até agora...
                        if distanceOnScreen < closestDistance then
                            -- Checagem pesada por último (Wall Check)
                            if not useWallCheck or Targeting.IsVisible(part) then
                                closestDistance = distanceOnScreen
                                closestPart = part
                            end
                        end
                    end
                end
            end
        end
    end

    return closestPart
end

return Targeting
