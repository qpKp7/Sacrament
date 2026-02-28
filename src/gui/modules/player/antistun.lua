--!strict
local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function() return Import(path) end)
    if not success then return nil end
    return result
end

local ToggleButton = SafeImport("gui/modules/components/togglebutton")
local Keybind = SafeImport("gui/modules/player/sections/shared/keybind")

export type AntiStunUI = {
    Instance: Folder,
    Destroy: (self: AntiStunUI) -> ()
}

local AntiStunFactory = {}

local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local FONT_MAIN = Enum.Font.GothamBold

function AntiStunFactory.new(): AntiStunUI
    local maid = Maid.new()
    
    local folder = Instance.new("Folder")
    folder.Name = "AntiStunModule"

    -- HEADER (Esquerda)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundTransparency = 1
    header.Parent = folder

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "Anti Stun"
    title.TextColor3 = COLOR_LABEL
    title.Font = FONT_MAIN
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local controls = Instance.new("Frame")
    controls.Name = "Controls"
    controls.Size = UDim2.new(0, 100, 1, 0)
    controls.AnchorPoint = Vector2.new(1, 0.5)
    controls.Position = UDim2.new(1, 0, 0.5, 0)
    controls.BackgroundTransparency = 1
    controls.Parent = header

    local clLayout = Instance.new("UIListLayout")
    clLayout.FillDirection = Enum.FillDirection.Horizontal
    clLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    clLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    clLayout.Padding = UDim.new(0, 15)
    clLayout.SortOrder = Enum.SortOrder.LayoutOrder
    clLayout.Parent = controls

    if ToggleButton and type(ToggleButton.new) == "function" then
        local toggleObj = ToggleButton.new()
        toggleObj.Instance.LayoutOrder = 1
        toggleObj.Instance.Parent = controls
        maid:GiveTask(toggleObj)
    end

    local arrowGlyph = Instance.new("TextLabel")
    arrowGlyph.Name = "Arrow"
    arrowGlyph.Size = UDim2.fromOffset(20, 20)
    arrowGlyph.BackgroundTransparency = 1
    arrowGlyph.Text = ">"
    arrowGlyph.TextColor3 = COLOR_LABEL
    arrowGlyph.Font = FONT_MAIN
    arrowGlyph.TextSize = 18
    arrowGlyph.LayoutOrder = 2
    arrowGlyph.Parent = controls

    -- SUBFRAME (Direita)
    local subFrame = Instance.new("Frame")
    subFrame.Name = "SubFrame"
    subFrame.Size = UDim2.fromScale(1, 1)
    subFrame.BackgroundTransparency = 1
    subFrame.Visible = false
    subFrame.Parent = folder

    local subLayout = Instance.new("UIListLayout")
    subLayout.SortOrder = Enum.SortOrder.LayoutOrder
    subLayout.Padding = UDim.new(0, 15)
    subLayout.Parent = subFrame

    local subPad = Instance.new("UIPadding")
    subPad.PaddingTop = UDim.new(0, 20)
    subPad.Parent = subFrame

    if Keybind and type(Keybind.new) == "function" then
        local keyObj = Keybind.new(1)
        keyObj.Instance.Parent = subFrame
        maid:GiveTask(keyObj)
    end

    local self = {}
    self.Instance = folder

    function self:Destroy()
        maid:Destroy()
        folder:Destroy()
    end

    return self :: AntiStunUI
end

return AntiStunFactory
