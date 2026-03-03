--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local Keybox = SafeImport("gui/modules/components/keybox")

export type PanicKeyUI = {
    Instance: Frame,
    KeyChanged: RBXScriptSignal,
    GetKey: (self: PanicKeyUI) -> Enum.KeyCode?,
    Destroy: (self: PanicKeyUI) -> ()
}

local PanicKeyFactory = {}

local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_BORDER = Color3.fromHex("333333")
local COLOR_TEXT = Color3.fromHex("FFFFFF")
local COLOR_SUBTEXT = Color3.fromHex("888888")
local FONT_MAIN = Enum.Font.GothamBold

function PanicKeyFactory.new(layoutOrder: number?): PanicKeyUI
    local maid = Maid.new()
    local currentKey = Enum.KeyCode.End

    local row = Instance.new("Frame")
    row.Name = "PanicKeyRow"
    row.Size = UDim2.new(1, 0, 0, 55)
    row.BackgroundColor3 = COLOR_BG
    row.LayoutOrder = layoutOrder or 1

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = row
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLOR_BORDER
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = row
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 50)
    pad.Parent = row

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 0, 16)
    title.Position = UDim2.new(0, 0, 0.5, -10)
    title.AnchorPoint = Vector2.new(0, 0.5)
    title.BackgroundTransparency = 1
    title.Text = "Panic Key"
    title.TextColor3 = COLOR_TEXT
    title.Font = FONT_MAIN
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = row

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(0.5, 0, 0, 12)
    subtitle.Position = UDim2.new(0, 0, 0.5, 10)
    subtitle.AnchorPoint = Vector2.new(0, 0.5)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Instantly hides Sacrament menu"
    subtitle.TextColor3 = COLOR_SUBTEXT
    subtitle.Font = FONT_MAIN
    subtitle.TextSize = 12
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = row

    local keyChangedEvent = Instance.new("BindableEvent")
    maid:GiveTask(keyChangedEvent)

    if Keybox and type(Keybox.new) == "function" then
        local kbox = Keybox.new(currentKey)
        kbox.Instance.AnchorPoint = Vector2.new(1, 0.5)
        kbox.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        kbox.Instance.Parent = row
        maid:GiveTask(kbox.KeyChanged:Connect(function(key: Enum.KeyCode?)
            currentKey = key :: any
            keyChangedEvent:Fire(key)
        end))
        maid:GiveTask(kbox)
    end

    maid:GiveTask(row)

    local self = {}
    self.Instance = row
    self.KeyChanged = keyChangedEvent.Event
    function self:GetKey() return currentKey end
    function self:Destroy() maid:Destroy() end
    return self :: PanicKeyUI
end

return PanicKeyFactory
