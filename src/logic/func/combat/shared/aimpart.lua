--!strict
--[[
    SACRAMENT | Shared AimPart Resolver
    Baseado na opção do menu (Head, Torso, Random, Closest), este módulo 
    descobre qual a parte exata do corpo do inimigo que deve ser focada.
--]]

local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local AimPart = {}

-- Utilitário interno para encontrar o Torso (Suporta R6 e R15)
local function GetTorso(character: Model): BasePart?
    return character:FindFirstChild("HumanoidRootPart") 
        or character:FindFirstChild("UpperTorso") 
        or character:FindFirstChild("Torso") :: BasePart?
end

--[[
    Resolve a parte do corpo baseada na configuração.
    
    @param character: O modelo do inimigo.
    @param option: A string que vem do Dropdown do teu Menu ("Head", "Torso", "Random", "Closest").
    @return BasePart?: A parte do corpo que deve receber o Aimlock/Tiro.
--]]
function AimPart.GetTarget(character: Model, option: string): BasePart?
    if not character then return nil end
    
    local lowerOption = string.lower(option)

    -- 1. Fixo: Head (Cabeça)
    if lowerOption == "head" then
        return character:FindFirstChild("Head") :: BasePart?
        
    -- 2. Fixo: Torso (Peito/Centro de Massa)
    elseif lowerOption == "torso" then
        return GetTorso(character)
        
    -- 3. Aleatório (Bom para disfarçar o Silent Aim)
    elseif lowerOption == "random" then
        local parts = {}
        local head = character:FindFirstChild("Head")
        local torso = GetTorso(character)
        
        if head then table.insert(parts, head) end
        if torso then table.insert(parts, torso) end
        
        if #parts > 0 then
            return parts[math.random(1, #parts)] :: BasePart
        end
        return nil

    -- 4. Closest (Calcula qual parte do corpo está fisicamente mais perto do rato na tela)
    elseif lowerOption == "closest" then
        local camera = Workspace.CurrentCamera
        if not camera then return nil end

        local mousePos = UserInputService:GetMouseLocation()
        local closestPart: BasePart? = nil
        local shortestDistance = math.huge
        
        -- Lista de partes candidatas para checar
        local candidates = {}
        local head = character:FindFirstChild("Head")
        local torso = GetTorso(character)
        local rArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightUpperArm")
        local lArm = character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftUpperArm")
        local rLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightUpperLeg")
        local lLeg = character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftUpperLeg")
        
        -- Adiciona os que existirem na lista de candidatos
        for _, part in ipairs({head, torso, rArm, lArm, rLeg, lLeg}) do
            if part then table.insert(candidates, part) end
        end

        -- Faz a matemática de qual deles está mais perto do cursor
        for _, part in ipairs(candidates) do
            local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPart = part :: BasePart
                end
            end
        end

        return closestPart
    end

    -- Fallback de segurança (Se a string for inválida, foca no Torso)
    return GetTorso(character)
end

return AimPart
