--!strict
--[[
    SACRAMENT | Hitbox Expander Backend (Xeno / Da Hood)
    Substitui a interceptação de raio por uma expansão física dinâmica.
]]
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Import = (_G :: any).SacramentImport

local UIState   = Import("state/uistate")
local Targeting = Import("logic/core/targeting")
local Loop      = Import("logic/core/loop")
local MarkStyle = Import("logic/func/combat/silentaim/markstyle")
local Telemetry = Import("logic/core/telemetry")
local Capability= Import("logic/core/capability")
local FOVLimit  = Import("logic/func/combat/silentaim/fovlimit")

local HookBackend = {}
local isInitialized = false

-- Variáveis de Controle da Hitbox
local lastTarget: BasePart? = nil
local originalSizes: {[BasePart]: Vector3} = {}
local originalTransparencies: {[BasePart]: number} = {}

-- Sincronizando com as chaves exatas do seu silentaim.lua (UI)
local KEY_ENABLED     = "SilentAimEnabled"
local KEY_FOV_RADIUS  = "SilentAim_FovLimit"
local KEY_MARK_STYLE  = "SilentAim_MarkStyle"
local KEY_AIM_PART    = "SilentAim_AimPart"

local function GetTargetPart(): BasePart?
    local fovRadius = tonumber(UIState.Get(KEY_FOV_RADIUS, 150)) or 150
    local aimPartName = UIState.Get(KEY_AIM_PART, "Head")
    return Targeting.GetClosestToCursor(fovRadius, {aimPartName, "Torso", "HumanoidRootPart"}, false, false, false)
end

-- Restaura a parte do corpo do inimigo ao normal
local function ResetLastTarget()
    if lastTarget then
        if originalSizes[lastTarget] then lastTarget.Size = originalSizes[lastTarget] end
        if originalTransparencies[lastTarget] then lastTarget.Transparency = originalTransparencies[lastTarget] end
        lastTarget.CanCollide = true
        
        -- Limpa a memória
        originalSizes[lastTarget] = nil
        originalTransparencies[lastTarget] = nil
        lastTarget = nil
    end
end

-- 1. O Contrato: Ele pode ser carregado?
function HookBackend.canLoad()
    -- Como é um Hitbox Expander, ele roda em qualquer executor!
    return true, "Hitbox Expander é compatível com todos os executores."
end

-- 2. O Contrato: Inicializa a máquina
function HookBackend.load()
    if isInitialized then return "initialized" end

    -- Inicializa o visual do FOV
    if FOVLimit and type(FOVLimit.Init) == "function" then FOVLimit.Init() end

    -- Loop de Combate (Roda 60x por segundo)
    Loop.BindToRender("SilentAim_Hitbox", function()
        
        -- Se o usuário desligar na UI, nós limpamos tudo
        if not UIState.Get(KEY_ENABLED, false) then
            ResetLastTarget()
            MarkStyle.Clear()
            return
        end

        local target = GetTargetPart()

        -- Se o alvo mudou (ou perdemos ele), reseta o antigo
        if target ~= lastTarget then
            ResetLastTarget()
            lastTarget = target
        end

        if target then
            -- Se for a primeira vez que pegamos esse alvo, salvamos o tamanho real dele
            if not originalSizes[target] then
                originalSizes[target] = target.Size
                originalTransparencies[target] = target.Transparency
            end

            -- EXPANSÃO DE HITBOX (O SEGREDO DO XENO)
            -- Aumentamos a cabeça/peito do cara para 15x15 studs.
            target.Size = Vector3.new(15, 15, 15)
            target.Transparency = 1     -- Deixa invisível para não assustar o usuário
            target.CanCollide = false   -- Impede de bugar a física do jogo

            -- Marca o cara visualmente (Bolinha ou Highlight)
            local markOption = UIState.Get(KEY_MARK_STYLE, "None")
            MarkStyle.Mark(target, markOption)
        else
            MarkStyle.Clear()
        end
    end)

    isInitialized = true
    Telemetry.Log("INFO", "SilentAim", "Hitbox Expander Dinâmico ativado.")
    return "initialized"
end

-- 3. O Contrato: Limpeza
function HookBackend.destroy()
    if not isInitialized then return end
    Loop.UnbindFromRender("SilentAim_Hitbox")
    if FOVLimit and type(FOVLimit.Destroy) == "function" then FOVLimit.Destroy() end
    ResetLastTarget()
    MarkStyle.Clear()
    isInitialized = false
end

-- 4. O Contrato: Status
function HookBackend.health() return isInitialized and "initialized" or "unsupported" end
function HookBackend.requirements() return {} end -- Sem requisitos especiais
function HookBackend.assumptions() return "O jogo aceita modificação de propriedades de BasePart em LocalScripts." end

return HookBackend
