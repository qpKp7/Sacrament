--!strict
--[[
    SACRAMENT | Shared Targeting
    Função matemática utilitária para achar o alvo mais próximo do cursor.
    Pode ser usada simultaneamente pelo Aimlock, Silent Aim e TriggerBot.
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local Import = (_G :: any).SacramentImport
local LocalPlayer = Players.LocalPlayer

-- Importa os micro-checks que ficarão na pasta shared
local function SafeImport(path: string)
    local success, result = pcall(function() return Import(path) end)
    return success and result or nil
end

local TeamCheck  = SafeImport("logic/func/combat/shared/teamcheck")
local WallCheck  = SafeImport("logic/func/combat/shared/wallcheck")
local KnockCheck = SafeImport("logic/func/combat/shared/knockcheck")

local Targeting = {}

-- Checagem básica de integridade (Está vivo e tem as partes do corpo?)
local function IsAliveAndValid(player: Player): boolean
    if not player or player == LocalPlayer then return false end
    
    local character = player.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end

    return true
end

--[[
    GetClosestToCursor
    @param fovRadius: Tamanho do círculo na tela (em pixels).
    @param targetParts: Tabela com as partes que podem ser focadas (ex: {"Head", "Torso"}).
    @param useWallCheck: Booleano para exigir que o alvo esteja visível.
    @param useKnockCheck: Booleano para ignorar jogadores nocauteados.
    @param useTeamCheck: Booleano para ignorar amigos/mesmo time (Blood Pact).
    
    @return BasePart? (A parte do corpo mais próxima, ou nil se não achar ninguém)
--]]
function Targeting.GetClosestToCursor(
    fovRadius: number, 
    targetParts: {string}, 
    useWallCheck: boolean, 
    useKnockCheck: boolean,
    useTeamCheck: boolean
): BasePart?

    local camera = Workspace.CurrentCamera
    if not camera then return nil end

    local mousePos = UserInputService:GetMouseLocation()
    local closestDistance = fovRadius
    local closestPart: BasePart? = nil

    for _, player in ipairs(Players:GetPlayers()) do
        if IsAliveAndValid(player) then
            
            -- Filtro 1: Blood Pact (Amigos/Time)
            if useTeamCheck and TeamCheck and TeamCheck.IsProtected(player) then
                continue
            end

            -- Filtro 2: Knocked (Nocauteado)
            if useKnockCheck and KnockCheck and KnockCheck.IsKnocked(player) then
                continue
            end

            local character = player.Character
            
            -- Itera sobre as partes permitidas (Ex: Primeiro checa a Cabeça, depois o Torso)
            for _, partName in ipairs(targetParts) do
                local part = character:FindFirstChild(partName) :: BasePart
                if part then
                    local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                    
                    if onScreen then
                        local distanceOnScreen = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                        if distanceOnScreen < closestDistance then
                            -- Filtro 3: Raycast (Parede) - Fazemos por último para poupar processamento
                            if not useWallCheck or (WallCheck and WallCheck.IsVisible(part)) then
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
