--!strict
--[[
    SACRAMENT | Silent Aim FOV Limit (Math & Visuals)
    Faz a checagem matemática da distância e desenha o círculo visual na tela 
    usando a Drawing API nativa do executor.
--]]

local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Import = (_G :: any).SacramentImport

local UIState = Import("state/uistate")
local Loop    = Import("logic/core/loop")

local FOVLimit = {}
local isInitialized = false

-- Variável que vai guardar o nosso círculo de exploit
local fovCircle: any = nil 

--=============================================================================
-- 1. MOTOR VISUAL DO CÍRCULO
--=============================================================================
function FOVLimit.Init()
    if isInitialized then return end
    isInitialized = true

    -- Cria o círculo usando a API de Drawing (se o executor suportar)
    if Drawing then
        fovCircle = Drawing.new("Circle")
        fovCircle.Color = Color3.fromRGB(255, 50, 50) -- Vermelho vibrante
        fovCircle.Thickness = 1.2
        fovCircle.Filled = false
        fovCircle.NumSides = 64 -- Deixa o círculo bem liso (anti-aliasing)
        fovCircle.Visible = false
    else
        warn("[SACRAMENT] Seu executor não suporta a Drawing API para o FOV!")
    end

    -- Conecta no nosso Maestro para atualizar a posição do círculo a cada frame
    Loop.BindToRender("SilentAim_FOVCircle", function()
        if not fovCircle then return end

        -- Lê as configurações do Menu do Silent Aim
        local isSilentAimOn = UIState.Get("SilentAim_Enabled", false)
        local showFOV       = UIState.Get("SilentAim_ShowFOV", false)
        local fovRadius     = tonumber(UIState.Get("SilentAim_FOV", 150)) or 150

        -- Se a função mestre ou o botão "Show FOV" estiverem desligados, esconde o círculo
        if not isSilentAimOn or not showFOV then
            fovCircle.Visible = false
            return
        end

        -- Se estiver ligado, faz o círculo seguir o mouse e atualiza o tamanho (Slider)
        local mouseLocation = UserInputService:GetMouseLocation()
        fovCircle.Visible = true
        fovCircle.Radius = fovRadius
        fovCircle.Position = mouseLocation
    end)
end

function FOVLimit.Destroy()
    if not isInitialized then return end
    Loop.UnbindFromRender("SilentAim_FOVCircle")
    
    if fovCircle then
        fovCircle:Remove() -- Apaga da memória
        fovCircle = nil
    end
    isInitialized = false
end

--=============================================================================
-- 2. MATEMÁTICA DE CHECAGEM (Para o main.lua usar)
--=============================================================================
--[[
    Checa se a cabeça do inimigo está dentro do círculo vermelho do mouse.
]]
function FOVLimit.IsInFOV(targetPosition: Vector3, fovRadius: number): boolean
    local camera = Workspace.CurrentCamera
    if not camera then return false end

    local screenPosition, onScreen = camera:WorldToViewportPoint(targetPosition)
    if not onScreen then return false end

    local mouseLocation = UserInputService:GetMouseLocation()
    local target2D = Vector2.new(screenPosition.X, screenPosition.Y)

    local distance = (mouseLocation - target2D).Magnitude

    return distance <= fovRadius
end

return FOVLimit
