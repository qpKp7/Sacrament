--!strict
local UserInputService = game:GetService("UserInputService")
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

export type KeyboxUI = {
    Instance: TextButton,
    KeyChanged: RBXScriptSignal,
    GetKey: (self: KeyboxUI) -> Enum.KeyCode?,
    SetKey: (self: KeyboxUI, keyEnum: Enum.KeyCode?) -> (),
    Destroy: (self: KeyboxUI) -> ()
}

local KeyboxFactory = {}

local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_BORDER = Color3.fromHex("333333")
local COLOR_TEXT = Color3.fromHex("FFFFFF")
local COLOR_ACCENT = Color3.fromHex("C80000")
local FONT_MAIN = Enum.Font.GothamBold

function KeyboxFactory.new(defaultKey: Enum.KeyCode?): KeyboxUI
    local maid = Maid.new()
    local currentKey = defaultKey
    local isListening = false

    local btn = Instance.new("TextButton")
    btn.Name = "Keybox"
    btn.Size = UDim2.fromOffset(120, 32)
    btn.BackgroundColor3 = COLOR_BG
    btn.Text = currentKey and currentKey.Name or "None"
    btn.TextColor3 = COLOR_TEXT
    btn.Font = FONT_MAIN
    btn.TextSize = 16
    btn.AutoButtonColor = false

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLOR_BORDER
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = btn

    local keyChangedEvent = Instance.new("BindableEvent")
    maid:GiveTask(keyChangedEvent)

    maid:GiveTask(btn.Activated:Connect(function()
        if isListening then return end
        isListening = true
        btn.Text = "..."
        stroke.Color = COLOR_ACCENT
    end))

    maid:GiveTask(UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
        if not isListening then return end
        
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.Escape then
                currentKey = nil
                btn.Text = "None"
            else
                currentKey = input.KeyCode
                btn.Text = currentKey.Name
            end
            
            stroke.Color = COLOR_BORDER
            isListening = false
            keyChangedEvent:Fire(currentKey)
        end
    end))

    maid:GiveTask(btn)

    local self = {}
    self.Instance = btn
    self.KeyChanged = keyChangedEvent.Event
    
    function self:GetKey() 
        return currentKey 
    end

    -- Método injetado para suportar carregamento de memória silencioso
    function self:SetKey(keyEnum: Enum.KeyCode?)
        currentKey = keyEnum
        if keyEnum then
            btn.Text = keyEnum.Name
        else
            btn.Text = "None"
        end
    end
    
    function self:Destroy() 
        maid:Destroy() 
    end

    return self :: KeyboxUI
end

return KeyboxFactory
