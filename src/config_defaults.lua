-- Sacrament - Default Configuration

local Config = {}

Config.Defaults = {
    -- Binds (use Enum.KeyCode)
    AimlockKey = Enum.KeyCode.E,
    SilentAimKey = Enum.KeyCode.Q,
    GuiToggleKey = Enum.KeyCode.Insert,

    -- Visuals
    HighlightColor = Color3.fromRGB(255, 40, 40),
    HighlightTransparency = 0.4,

    -- Aimlock
    Smoothness = 0.15,       -- 0.01 = instantâneo, 0.5+ = lento
    Prediction = 0.135,      -- fator de previsão (ajuste por ping)

    -- Silent Aim
    HitPart = "HumanoidRootPart",
    SilentPrediction = 0.135,

    -- Auto unlock
    UnlockOnDeath = true,
    UnlockOnSit = true,
}

-- Cópia editável em runtime (polyfill simples para table.clone)
local function shallowClone(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

Config.Current = shallowClone(Config.Defaults)

return Config
