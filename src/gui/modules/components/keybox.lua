--!strict
--[[
    SACRAMENT | Component: Keybox
    Responsável pela captura de inputs (Teclado e Mouse) e formatação visual.
--]]

local UserInputService = game:GetService("UserInputService")
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type KeyboxUI = {
    Instance: Frame,
    KeyChanged: RBXScriptSignal,
    SetKey: (self: KeyboxUI, keyEnum: any) -> (),
    Destroy: (self: KeyboxUI) -> ()
}

local KeyboxFactory = {}

-- Constantes Visuais (Preservadas da versão original)
local COLOR_RED_DARK = Color3.fromHex("680303")
local COLOR_BOX_BG = Color3.fromHex("1A1A1A")
local COLOR_BOX_BORDER = Color3.fromHex("333333")
local FONT_MAIN = Enum.Font.GothamBold

-- Utilitário de formatação interno
local function formatKeyName(name: string): string
    local map = {
        One="1", Two="2", Three="3", Four="4", Five="5",
        Six="6", Seven="7", Eight="8", Nine="9", Zero="0",
        MouseButton1="MB1", MouseButton2="MB2", MouseButton3="MB3",
        MouseButton4="MB4", MouseButton5="MB5"
    }
    return map[name] or name
end

function KeyboxFactory.new(): KeyboxUI
    local maid = Maid.new()
    local capturingKey = false
    
    local keyChangedEvent = Instance.new("BindableEvent")
    maid:GiveTask(keyChangedEvent)

    -- Container da Box
    local inputCont = Instance.new("Frame")
    inputCont.Name = "KeyboxContainer"
    inputCont.Size = UDim2.fromOffset(120, 32)
    inputCont.BackgroundColor3 = COLOR_BOX_BG
    inputCont.BorderSizePixel = 0

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = inputCont

    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = COLOR_BOX_BORDER
    inputStroke.Thickness = 1
    inputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    inputStroke.Parent = inputCont
    
    local keyBtn = Instance.new("TextButton")
    keyBtn.Name = "InteractionButton"
    keyBtn.Size = UDim2.fromScale(1, 1)
    keyBtn.BackgroundTransparency = 1
    keyBtn.Text = "NONE"
    keyBtn.TextColor3 = COLOR_RED_DARK
    keyBtn.Font = FONT_MAIN
    keyBtn.TextSize = 16
    keyBtn.Parent = inputCont

    -- Lógica de Captura
    maid:GiveTask(keyBtn.MouseButton1Click:Connect(function()
        if capturingKey then return end
        capturingKey = true
        keyBtn.Text = "..."
        
        local connection: RBXScriptConnection
        connection = UserInputService.InputBegan:Connect(function(input)
            local inputType = input.UserInputType
            local inputKey = (inputType == Enum.UserInputType.Keyboard) and input.KeyCode or inputType

            -- Filtro para Keyboard ou Mouse Buttons
            if inputType == Enum.UserInputType.Keyboard or inputType.Name:match("MouseButton") then
                keyBtn.Text = formatKeyName(inputKey.Name)
                capturingKey = false
                connection:Disconnect()
                keyChangedEvent:Fire(inputKey)
            end
        end)
        
        maid:GiveTask(connection)
    end))

    maid:GiveTask(inputCont)

    local self = {}
    self.Instance = inputCont
    self.KeyChanged = keyChangedEvent.Event
    
    function self:SetKey(keyEnum: any)
        if keyEnum then
            keyBtn.Text = formatKeyName(keyEnum.Name)
        else
            keyBtn.Text = "NONE"
        end
    end

    function self:Destroy()
        maid:Destroy()
    end

    return self :: KeyboxUI
end

return KeyboxFactory
