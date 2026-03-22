--!strict
--[[
    SACRAMENT | Silent Aim FOV Limit
    Verifica se a posição 3D do inimigo está dentro do raio bidimensional (2D) 
    do mouse na tela do jogador.
--]]

local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local FOVLimit = {}

--[[
    Converte a posição do inimigo e checa a distância até o ponteiro do mouse.
    
    @param targetPosition A posição 3D no mapa (ex: Cabeça do inimigo)
    @param fovRadius O tamanho do círculo configurado na UI (ex: 150)
    @return boolean true se estiver dentro do círculo, false se estiver fora.
]]
function FOVLimit.IsInFOV(targetPosition: Vector3, fovRadius: number): boolean
    local camera = Workspace.CurrentCamera
    if not camera then return false end

    -- 1. Converte o 3D (Mundo) para 2D (Sua Tela)
    local screenPosition, onScreen = camera:WorldToViewportPoint(targetPosition)
    
    -- Se o inimigo estiver nas suas costas (fora da tela), ignora instantaneamente
    if not onScreen then return false end

    -- 2. Pega a coordenada exata do seu Mouse na tela
    local mouseLocation = UserInputService:GetMouseLocation()
    local target2D = Vector2.new(screenPosition.X, screenPosition.Y)

    -- 3. Calcula a distância matemática entre o Mouse e o Inimigo
    local distance = (mouseLocation - target2D).Magnitude

    -- 4. Retorna verdadeiro se a distância for menor que o limite do FOV
    return distance <= fovRadius
end

return FOVLimit
