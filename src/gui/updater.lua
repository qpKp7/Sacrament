-- src/gui/updater.lua
-- Gerencia atualizações em tempo real da GUI (toggles visuais + status bar)
-- Usa RenderStepped/Heartbeat para responsividade sem lag perceptível

local Updater = {}

local RunService = game:GetService("RunService")

-- Referências (serão setadas no :Start)
local guiModule = nil
local states = nil
local connections = {}

-- Tween info rápida para transições suaves no checkbox
local TWEEN_INFO = TweenInfo.new(
    0.15,                       -- tempo curto para feel imediato
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.Out
)

-- ================================================
-- Inicia as atualizações dinâmicas
-- ================================================
function Updater:Start(gui)
    if not gui or not gui.States then
        warn("[Sacrament Updater] GUI ou States não fornecidos")
        return
    end

    guiModule = gui
    states = gui.States

    -- Limpa conexões antigas se houver
    self:Stop()

    -- Conexão principal: atualiza toggles e status a cada frame (só se GUI visível)
    local connUpdate = RunService.RenderStepped:Connect(function()
        if not gui.ScreenGui or not gui.ScreenGui.Enabled then
            return
        end

        -- Atualiza visual dos toggles
        if gui.AimlockToggle and gui.AimlockToggle.Fill then
            local enabled = states.AimlockEnabled
            local targetTrans = enabled and 0 or 1
            if math.abs(gui.AimlockToggle.Fill.BackgroundTransparency - targetTrans) > 0.01 then
                game:GetService("TweenService"):Create(
                    gui.AimlockToggle.Fill,
                    TWEEN_INFO,
                    {BackgroundTransparency = targetTrans}
                ):Play()
            end
        end

        if gui.SilentToggle and gui.SilentToggle.Fill then
            local enabled = states.SilentAimEnabled
            local targetTrans = enabled and 0 or 1
            if math.abs(gui.SilentToggle.Fill.BackgroundTransparency - targetTrans) > 0.01 then
                game:GetService("TweenService"):Create(
                    gui.SilentToggle.Fill,
                    TWEEN_INFO,
                    {BackgroundTransparency = targetTrans}
                ):Play()
            end
        end

        -- Atualiza status bar
        local anyActive = states.AimlockEnabled or states.SilentAimEnabled
        if gui.StatusText then
            if anyActive then
                if gui.StatusText.Text ~= "Status: LOCK ACTIVE" then
                    gui.StatusText.Text = "Status: LOCK ACTIVE"
                    gui.StatusText.TextColor3 = require(script.Parent.components.helpers).COLORS.StatusOn
                end
            else
                if gui.StatusText.Text ~= "Status: OFFLINE" then
                    gui.StatusText.Text = "Status: OFFLINE"
                    gui.StatusText.TextColor3 = require(script.Parent.components.helpers).COLORS.StatusOff
                end
            end
        end
    end)

    table.insert(connections, connUpdate)

    -- Conexão opcional mais leve (Heartbeat) para coisas menos frequentes, se precisar depois
    -- Exemplo: checar se states mudaram de forma externa (não necessário agora)

    print("[Sacrament Updater] Atualizações em tempo real iniciadas")
end

-- ================================================
-- Para todas as conexões (cleanup)
-- ================================================
function Updater:Stop()
    for _, conn in ipairs(connections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    connections = {}
    print("[Sacrament Updater] Atualizações paradas")
end

return Updater
