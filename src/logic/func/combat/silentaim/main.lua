src/logic/func/combat/silentaim/main.lua



--!strict

local Import = (_G :: any).SacramentImport

local Registry = Import("logic/core/backend_registry")

local Telemetry = Import("logic/core/telemetry")



local SilentAim = {}

local isInitialized = false

local activeBackendName = nil



function SilentAim.Init()

    if isInitialized then return "initialized" end



    -- Por determinação do Tribunal, usaremos o mouse_spoof como principal para FPS Legacy

    activeBackendName = "mouse_spoof"

    

    local backend = Registry.Get(activeBackendName)

    if not backend then

        Telemetry.Log("ERROR", "SilentAim", "Backend não registrado: " .. activeBackendName)

        return "failed"

    end



    local can, reason = backend.canLoad()

    if not can then

        Telemetry.Log("WARN", "SilentAim", "Backend " .. activeBackendName .. " → unsupported | Razão: " .. reason)

        return "unsupported"

    end



    local status = backend.load()

    if status == "initialized" then

        isInitialized = true

        -- Log litúrgico já é emitido dentro do load() em caso de sucesso

    else

        Telemetry.Log("WARN", "SilentAim", "Backend " .. activeBackendName .. " → " .. status)

    end



    return status

end



function SilentAim.Destroy()

    if not isInitialized then return end

    if activeBackendName then

        local backend = Registry.Get(activeBackendName)

        if backend then backend.destroy() end

    end

    isInitialized = false

end



return SilentAim
