--!strict
--[[
    SACRAMENT | Silent Aim Mark Style
    Gerencia a indicação visual de quem é o alvo atual do Silent Aim.
--]]

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local MarkStyle = {}

-- Variáveis de controle de estado
local currentTarget: Model? = nil
local activeElements: {Instance} = {}

-- Função interna para limpar as marcações antigas da tela
local function clearMarks()
    for _, element in ipairs(activeElements) do
        if element and element.Parent then
            element:Destroy()
        end
    end
    table.clear(activeElements)
end

--[[
    Aplica o estilo visual no alvo selecionado.
    @param targetPart A parte do corpo do alvo (ex: Head, Torso)
    @param styleOption A string escolhida no menu ("Highlight", "TorsoDot", "BodyOutline", "Notify", "None")
]]
function MarkStyle.Mark(targetPart: BasePart?, styleOption: string)
    -- Se perdeu o alvo ou a opção for "None", limpa tudo e aborta
    if not targetPart or styleOption == "None" then
        clearMarks()
        currentTarget = nil
        return
    end

    local character = targetPart.Parent :: Model
    
    -- Se o alvo for EXATAMENTE o mesmo do frame anterior, não faz nada para não lagar/spammar
    if currentTarget == character then
        return 
    end

    -- Se trocou de alvo, limpa o antigo e salva o novo
    clearMarks()
    currentTarget = character

    local player = Players:GetPlayerFromCharacter(character)

    -- =========================================================================
    -- APLICAÇÃO DOS ESTILOS VISUAIS
    -- =========================================================================
    
    if styleOption == "Highlight" then
        local hl = Instance.new("Highlight")
        hl.FillColor = Color3.fromRGB(255, 50, 50) -- Vermelho
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.5
        hl.Parent = character
        table.insert(activeElements, hl)

    elseif styleOption == "BodyOutline" then
        local hl = Instance.new("Highlight")
        hl.FillTransparency = 1 -- Fundo transparente, apenas a linha
        hl.OutlineColor = Color3.fromRGB(255, 50, 50)
        hl.Parent = character
        table.insert(activeElements, hl)

    elseif styleOption == "TorsoDot" then
        local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or targetPart
        
        local bg = Instance.new("BillboardGui")
        bg.Size = UDim2.new(0, 12, 0, 12)
        bg.AlwaysOnTop = true
        
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(1, 0, 1, 0)
        dot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        dot.BorderSizePixel = 0
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0) -- Transforma o quadrado num círculo perfeito
        corner.Parent = dot
        
        dot.Parent = bg
        bg.Parent = root
        table.insert(activeElements, bg)

    elseif styleOption == "Notify" then
        if player then
            -- Puxa a foto de perfil do jogador (HeadShot)
            local userId = player.UserId
            local thumbType = Enum.ThumbnailType.HeadShot
            local thumbSize = Enum.ThumbnailSize.Size420x420
            
            task.spawn(function()
                local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
                
                -- Manda a notificação oficial do Roblox
                pcall(function()
                    StarterGui:SetCore("SendNotification", {
                        Title = "Silent Aim Target",
                        Text = player.DisplayName .. " (@" .. player.Name .. ")",
                        Icon = content,
                        Duration = 3, -- Fica na tela por 3 segundos
                    })
                end)
            end)
        end
    end
end

-- Função para ser chamada quando o usuário desligar o Silent Aim no menu
function MarkStyle.Clear()
    clearMarks()
    currentTarget = nil
end

return MarkStyle
