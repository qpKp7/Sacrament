--!strict

local App = {}

export type Adapter = {
    mountGui: (gui: ScreenGui) -> (),
    connectInputBegan: (cb: (InputObject, boolean) -> ()) -> RBXScriptConnection,
    getViewportSize: () -> Vector2,
}

function App.start(adapter: Adapter)
    print("App starting with remote adapter!")
    -- Aqui vai sua lógica real de UI, state, navigation, etc.
    -- Exemplo mínimo:
    local gui = Instance.new("ScreenGui")
    gui.Name = "SacramentRoot"
    adapter.mountGui(gui)

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0.5, 0, 0.5, 0)
    frame.Position = UDim2.new(0.25, 0, 0.25, 0)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)

    adapter.connectInputBegan(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Q then
            print("Q pressed!")
        end
    end)
end

return App
