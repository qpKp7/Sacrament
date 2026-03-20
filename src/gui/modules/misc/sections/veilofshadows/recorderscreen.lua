--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local ToggleButton = SafeImport("gui/modules/components/togglebutton")

export type RecorderScreenUI = {
    Instance: Frame,
    Toggle: any, -- [NOVO] Exportado para o Orquestrador injetar a memória
    Destroy: (self: RecorderScreenUI) -> ()
}

local RecorderScreenFactory = {}

local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_BORDER = Color3.fromHex("333333")
local COLOR_TEXT = Color3.fromHex("FFFFFF")
local COLOR_SUBTEXT = Color3.fromHex("888888")
local FONT_MAIN = Enum.Font.GothamBold

function RecorderScreenFactory.new(layoutOrder: number?): RecorderScreenUI
    local maid = Maid.new()

    local row = Instance.new("Frame")
    row.Name = "RecorderScreenRow"
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
    title.Text = "OBS / Stream Bypass"
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
    subtitle.Text = "Attempts to hide UI from recording software"
    subtitle.TextColor3 = COLOR_SUBTEXT
    subtitle.Font = FONT_MAIN
    subtitle.TextSize = 12
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = row

    local self = {} :: any
    self.Instance = row

    if ToggleButton and type(ToggleButton.new) == "function" then
        local toggle = ToggleButton.new()
        toggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
        toggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        toggle.Instance.Parent = row
        maid:GiveTask(toggle)
        
        -- [O SEGREDO] Expondo o Toggle para o Orquestrador
        self.Toggle = toggle
    end

    maid:GiveTask(row)

    function self:Destroy() 
        maid:Destroy() 
    end
    
    return self :: RecorderScreenUI
end

return RecorderScreenFactory
