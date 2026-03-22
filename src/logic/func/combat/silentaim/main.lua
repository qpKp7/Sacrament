--!strict
--[[
    SACRAMENT | Silent Aim Main (Universal Hook)
    Intercepta as funções de disparo do Roblox (Raycast, FireServer, etc)
    e redireciona silenciosamente a bala para o alvo travado.
--]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Import = (_G :: any).SacramentImport

local UIState    = Import("state/uistate")
local Targeting  = Import("logic/core/targeting")
local AimPart    = Import("logic/func/combat/shared/aimpart")
local Predict    = Import("logic/func/combat/shared/predict")
local KnockCheck = Import("logic/func/combat/shared/knockcheck")

local HitChance  = Import("logic/func/combat/silentaim/hitchance")
local FOVLimit   = Import("logic/func/combat/silentaim/fovlimit")
local MarkStyle  = Import("logic/func/combat/silentaim/markstyle")

local SilentAim = {}
local isInitialized = false

-- Referência original do metamethod que vamos hackear
local oldNamecall: any = nil

-- Variável para guardar o alvo atual do Silent Aim
local currentSilentTarget: BasePart? = nil

--[[
    Função auxiliar que encontra o alvo válido para este exato milissegundo.
    Ela checa o FOV, KnockCheck, WallCheck, etc.
]]
local function GetValidTarget(): BasePart?
    local fovRadius = tonumber(UIState.Get("SilentAim_FOV", 150)) or 150
    local useWallCheck = UIState.Get("SilentAim_WallCheck", false)
    local useKnockCheck = UIState.Get("SilentAim_KnockCheck", false)
    local useTeamCheck = UIState.Get("SilentAim_TeamCheck", false)

    -- Busca o cara mais perto do mouse que passe nos testes
    local targetPart = Targeting.GetClosestToCursor(fovRadius, {"Head", "Torso", "HumanoidRootPart"}, useWallCheck, useKnockCheck, useTeamCheck)
    
    -- Atualiza a marcação visual (Bolinha, Highlight, etc)
    local markOption = UIState.Get("SilentAim_MarkStyle", "None")
    MarkStyle.Mark(targetPart, markOption)
    
    return targetPart
end

--=============================================================================
-- INICIALIZAÇÃO E HOOK UNIVERSAL
--=============================================================================
function SilentAim.Init()
    if isInitialized then return end
    isInitialized = true

    -- Inicia o motor visual do FOV (Círculo na tela)
    if FOVLimit and type(FOVLimit.Init) == "function" then
        FOVLimit.Init()
    end

    -- Hooking: Interceptando a comunicação do jogo
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        -- Lê se a função mestre tá ligada
        local isEnabled = UIState.Get("SilentAim_Enabled", false)

        -- Se estiver desligado ou o HitChance disser "Erra o tiro", deixa o jogo seguir normal
        if not isEnabled then
            return oldNamecall(self, unpack(args))
        end

        local chance = tonumber(UIState.Get("SilentAim_HitChance", 100)) or 100
        if not HitChance.Roll(chance) then
            return oldNamecall(self, unpack(args))
        end

        -- Tenta achar um alvo válido no FOV
        currentSilentTarget = GetValidTarget()
        if not currentSilentTarget then
            return oldNamecall(self, unpack(args))
        end

        -- Pega as configurações de AimPart e Predict
        local aimPartOpt = UIState.Get("SilentAim_AimPart", "Head")
        local predictVal = tonumber(UIState.Get("SilentAim_Predict", 0)) or 0
        
        local character = currentSilentTarget.Parent :: Model
        local finalPart = AimPart.GetTarget(character, aimPartOpt)

        if finalPart then
            local finalPos = finalPart.Position
            if predictVal > 0 then
                finalPos = Predict.GetPosition(finalPart, predictVal, false)
            end

            -- =================================================================
            -- A MÁGICA: REDIRECIONANDO A BALA (Universal)
            -- =================================================================
            
            -- Método 1: FindPartOnRay / FindPartOnRayWithIgnoreList (Jogos antigos / Da Hood)
            if method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" or method == "FindPartOnRayWithWhitelist" then
                -- O primeiro argumento (args[1]) é o Ray (Raio do tiro) original.
                local originalRay = args[1]
                
                -- Criamos um NOVO Ray saindo da mesma origem da arma, mas apontando pra cabeça do inimigo
                local newDirection = (finalPos - originalRay.Origin).Unit * (originalRay.Direction.Magnitude or 1000)
                local modifiedRay = Ray.new(originalRay.Origin, newDirection)
                
                args[1] = modifiedRay
                return oldNamecall(self, unpack(args))

            -- Método 2: Raycast Moderno (Jogos mais novos)
            elseif method == "Raycast" then
                -- args[1] é a Origem, args[2] é a Direção
                local origin = args[1]
                local originalDirection = args[2]
                
                local newDirection = (finalPos - origin).Unit * (originalDirection.Magnitude or 1000)
                args[2] = newDirection
                return oldNamecall(self, unpack(args))

            -- Método 3: FireServer (Remote Events) (Ex: Arsenal, MM2, etc)
            elseif method == "FireServer" and self.Name == "RemoteEvent" or self.Name == "Shoot" or self.Name == "Fire" then
                -- Em RemoteEvents, a coordenada do mouse costuma estar no args[1] ou args[2].
                -- Nós varremos os argumentos procurando vetores (Vector3) ou CFrames e substituímos.
                for i, v in ipairs(args) do
                    if typeof(v) == "Vector3" then
                        args[i] = finalPos
                    elseif typeof(v) == "CFrame" then
                        args[i] = CFrame.new(v.Position, finalPos)
                    end
                end
                return oldNamecall(self, unpack(args))
            end
        end

        -- Se a arma usou uma função que a gente não conhece, atira normal
        return oldNamecall(self, unpack(args))
    end))

    warn("[SACRAMENT] 🥷 Silent Aim (Universal) carregado e Hook inserido.")
end

function SilentAim.Destroy()
    if not isInitialized then return end
    
    if FOVLimit and type(FOVLimit.Destroy) == "function" then
        FOVLimit.Destroy()
    end
    
    MarkStyle.Clear()

    -- Restaura a função original do jogo (Segurança para o botão Unload)
    if oldNamecall then
        -- Restaurar hookmetamethod é mais complexo em executores básicos, 
        -- mas na maioria, o script precisa reiniciar para limpar o hook 100%.
        oldNamecall = nil 
    end
    
    isInitialized = false
end

return SilentAim
