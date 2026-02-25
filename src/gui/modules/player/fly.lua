--!strict
local TweenService = game:GetService("TweenService")

local Import = (_G :: any).SacramentImport
local Maid = Import("utils/maid")

local function SafeImport(path: string): any?
    local success, result = pcall(function()
        return Import(path)
    end)
    if not success then
        warn("[Sacrament] Falha ao importar dependência em Fly: " .. path)
        return nil
    end
    return result
end

local ToggleButton = SafeImport("gui/modules/components/togglebutton")
local Arrow = SafeImport("gui/modules/components/arrow")
local GlowBar = SafeImport("gui/modules/components/glowbar")
local Sidebar = SafeImport("gui/modules/components/sidebar")
local Slider = SafeImport("gui/modules/components/slider")

local KeybindSection = SafeImport("gui/modules/player/sections/shared/keybind")
local KeyHoldSection = SafeImport("gui/modules/player/sections/shared/keyhold")
local AnimationsSection = SafeImport("gui/modules/player/sections/fly/animations")

export type FlyUI = {
    Instance: Frame,
    Destroy: (self: FlyUI) -> ()
}

local FlyFactory = {}

local COLOR_WHITE = Color3.fromHex("B4B4B4")
local COLOR_LABEL = Color3.fromRGB(200, 200, 200)
local COLOR_BG = Color3.fromHex("1A1A1A")
local COLOR_STROKE = Color3.fromHex("333333")
local COLOR_TEXT_WHITE = Color3.fromHex("FFFFFF")
local FONT_MAIN = Enum.Font.GothamBold

local function createVelocityRow(maid: any, layoutOrder: number): Frame
    local row = Instance.new("Frame")
    row.Name = "VelocityRow"
    row.Size = UDim2.new(1, 0, 0, 45)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 25)
    pad.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Velocity"
    lbl.TextColor3 = COLOR_LABEL
    lbl.Font = FONT_MAIN
    lbl.TextSize = 18
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local inputBg = Instance.new("Frame")
    inputBg.Size = UDim2.new(0, 60, 0, 24)
    inputBg.Position = UDim2.new(1, 0, 0.5, 0)
    inputBg.AnchorPoint = Vector2.new(1, 0.5)
    inputBg.BackgroundColor3 = COLOR_BG
    inputBg.Parent = row

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = inputBg

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLOR_STROKE
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = inputBg

    local input = Instance.new("TextBox")
    input.Size = UDim2.fromScale(1, 1)
    input.BackgroundTransparency = 1
    input.Text = "32.00"
    input.PlaceholderText = "32.00"
    input.TextColor3 = COLOR_TEXT_WHITE
    input.Font = FONT_MAIN
    input.TextSize = 14
    input.Parent = inputBg

    maid:GiveTask(input:GetPropertyChangedSignal("Text"):Connect(function()
        local text = input.Text:gsub("[^%d%.]", "")
        local parts = string.split(text, ".")
        if #parts > 2 then
            text = parts[1] .. "." .. table.concat(parts, "", 2)
        end
        if input.Text ~= text then
            input.Text = text
        end
    end))

    maid:GiveTask(input.FocusLost:Connect(function()
        local num = tonumber(input.Text)
        if not num then
            input.Text = "32.00"
            return
        end
        num = math.clamp(num, 0, 100)
        input.Text = string.format("%.2f", num)
    end))

    return row
end

function FlyFactory.new(layoutOrder: number?): FlyUI
    local maid = Maid.new()

    local container = Instance.new("Frame")
    container.Name = "FlyContainer"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1 
    container.BorderSizePixel = 0
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.LayoutOrder = layoutOrder or 1

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.FillDirection = Enum.FillDirection.Vertical
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Parent = container

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundTransparency = 1
    header.BorderSizePixel = 0
    header.LayoutOrder = 1
    header.ClipsDescendants = true
    header.Parent = container

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.fromOffset(0, 50)
    title.AutomaticSize = Enum.AutomaticSize.X
    title.Position = UDim2.fromOffset(20, 0)
    title.BackgroundTransparency = 1
    title.Text = "Fly"
    title.TextColor3 = COLOR_WHITE
    title.Font = FONT_MAIN
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local controls = Instance.new("Frame")
    controls.Name = "Controls"
    controls.Size = UDim2.fromOffset(0, 50)
    controls.AutomaticSize = Enum.AutomaticSize.X
    controls.Position = UDim2.fromScale(1, 0)
    controls.AnchorPoint = Vector2.new(1, 0)
    controls.BackgroundTransparency = 1
    controls.Parent = header

    local ctrlLayout = Instance.new("UIListLayout")
    ctrlLayout.FillDirection = Enum.FillDirection.Horizontal
    ctrlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ctrlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ctrlLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ctrlLayout.Padding = UDim.new(0, 15)
    ctrlLayout.Parent = controls

    local ctrlPadding = Instance.new("UIPadding")
    ctrlPadding.PaddingRight = UDim.new(0, 20)
    ctrlPadding.Parent = controls
    
    local toggleBtn = nil
    if ToggleButton and type(ToggleButton.new) == "function" then
        toggleBtn = ToggleButton.new()
        toggleBtn.Instance.LayoutOrder = 1
        toggleBtn.Instance.Parent = controls
        maid:GiveTask(toggleBtn)
    end

    local arrow = nil
    if Arrow and type(Arrow.new) == "function" then
        arrow = Arrow.new()
        arrow.Instance.LayoutOrder = 2
        arrow.Instance.Parent = controls
        maid:GiveTask(arrow)
    end

    local glowWrapper = Instance.new("Frame")
    glowWrapper.Name = "GlowWrapper"
    glowWrapper.AnchorPoint = Vector2.new(0, 0.5)
    glowWrapper.BackgroundTransparency = 1
    glowWrapper.Parent = header

    local glowBar = nil
    if GlowBar and type(GlowBar.new) == "function" then
        glowBar = GlowBar.new()
        glowBar.Instance.AnchorPoint = Vector2.new(0.5, 0.5)
        glowBar.Instance.Position = UDim2.fromScale(0.5, 0.5)
        glowBar.Instance.AutomaticSize = Enum.AutomaticSize.None
        glowBar.Instance.Size = UDim2.fromScale(1, 1)
        glowBar.Instance.Parent = glowWrapper

        local c1 = glowBar.Instance:FindFirstChildWhichIsA("UISizeConstraint", true)
        if c1 then c1:Destroy() end
        local c2 = glowBar.Instance:FindFirstChildWhichIsA("UIAspectRatioConstraint", true)
        if c2 then c2:Destroy() end
        maid:GiveTask(glowBar)
    end

    local function updateGlowBar()
        if header.AbsoluteSize.X == 0 then return end
        local titleRightAbsolute = title.AbsolutePosition.X + title.AbsoluteSize.X
        local controlsLeftAbsolute = controls.AbsolutePosition.X
        local startX = (titleRightAbsolute - header.AbsolutePosition.X) + 5
        local endX = (controlsLeftAbsolute - header.AbsolutePosition.X) - 5
        local width = math.max(0, endX - startX)
        glowWrapper.Position = UDim2.new(0, startX, 0.5, 0)
        glowWrapper.Size = UDim2.fromOffset(width, 32)
    end

    maid:GiveTask(title:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGlowBar))
    maid:GiveTask(title:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateGlowBar))
    maid:GiveTask(controls:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGlowBar))
    maid:GiveTask(controls:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateGlowBar))
    maid:GiveTask(header:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGlowBar))
    maid:GiveTask(header:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateGlowBar))
    
    task.defer(updateGlowBar)

    local subFrame = Instance.new("Frame")
    subFrame.Name = "SubFrame"
    subFrame.Size = UDim2.new(1, 0, 0, 0)
    subFrame.AutomaticSize = Enum.AutomaticSize.Y
    subFrame.BackgroundTransparency = 1
    subFrame.BorderSizePixel = 0
    subFrame.Visible = false
    subFrame.LayoutOrder = 2
    subFrame.Parent = container

    if Sidebar and type(Sidebar.createVertical) == "function" then
        local vLine = Sidebar.createVertical()
        vLine.Instance.Size = UDim2.new(0, 2, 1, 0)
        vLine.Instance.Position = UDim2.fromScale(0, 0)
        vLine.Instance.Parent = subFrame
        maid:GiveTask(vLine)
    end

    local rightContent = Instance.new("Frame")
    rightContent.Name = "RightContent"
    rightContent.Size = UDim2.new(1, -2, 0, 0)
    rightContent.Position = UDim2.fromOffset(2, 0)
    rightContent.AutomaticSize = Enum.AutomaticSize.Y
    rightContent.BackgroundTransparency = 1
    rightContent.BorderSizePixel = 0
    rightContent.Parent = subFrame

    local rightLayout = Instance.new("UIListLayout")
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Parent = rightContent

    local inputsPadding = Instance.new("UIPadding")
    inputsPadding.PaddingTop = UDim.new(0, 15)
    inputsPadding.PaddingBottom = UDim.new(0, 20)
    inputsPadding.Parent = rightContent

    -- 1. KEY Bind
    if KeybindSection and type(KeybindSection.new) == "function" then
        local keybind = KeybindSection.new(1)
        keybind.Instance.Parent = rightContent
        maid:GiveTask(keybind)
    end

    -- 2. Key Hold Toggle
    if KeyHoldSection and type(KeyHoldSection.new) == "function" then
        local keyhold = KeyHoldSection.new(2)
        keyhold.Instance.Parent = rightContent
        maid:GiveTask(keyhold)
    end

    -- 3. Fly Speed Toggle
    local flySpeedToggleRow = Instance.new("Frame")
    flySpeedToggleRow.Name = "FlySpeedToggleRow"
    flySpeedToggleRow.Size = UDim2.new(1, 0, 0, 45)
    flySpeedToggleRow.BackgroundTransparency = 1
    flySpeedToggleRow.LayoutOrder = 3
    flySpeedToggleRow.Parent = rightContent

    local fstPad = Instance.new("UIPadding")
    fstPad.PaddingLeft = UDim.new(0, 20)
    fstPad.PaddingRight = UDim.new(0, 25)
    fstPad.Parent = flySpeedToggleRow

    local fstTitle = Instance.new("TextLabel")
    fstTitle.Size = UDim2.new(0.5, 0, 1, 0)
    fstTitle.BackgroundTransparency = 1
    fstTitle.Text = "Fly Speed"
    fstTitle.TextColor3 = COLOR_LABEL
    fstTitle.Font = FONT_MAIN
    fstTitle.TextSize = 18
    fstTitle.TextXAlignment = Enum.TextXAlignment.Left
    fstTitle.Parent = flySpeedToggleRow

    local fstToggle = nil
    if ToggleButton and type(ToggleButton.new) == "function" then
        fstToggle = ToggleButton.new()
        fstToggle.Instance.AnchorPoint = Vector2.new(1, 0.5)
        fstToggle.Instance.Position = UDim2.new(1, 0, 0.5, 0)
        fstToggle.Instance.Parent = flySpeedToggleRow
        maid:GiveTask(fstToggle)
    end

    -- 4. Fly Speed Slider (Condicional)
    local flySpeedSlider = nil
    if Slider and type(Slider.new) == "function" then
        flySpeedSlider = Slider.new("Speed", 0, 200, 60, 0)
        flySpeedSlider.Instance.LayoutOrder = 4
        flySpeedSlider.Instance.Visible = false 
        flySpeedSlider.Instance.Parent = rightContent
        maid:GiveTask(flySpeedSlider)
    end

    if fstToggle and flySpeedSlider then
        maid:GiveTask(fstToggle.Toggled:Connect(function(state: boolean)
            flySpeedSlider.Instance.Visible = state
        end))
    end

    -- 5. Velocity Box
    local velocityRow = createVelocityRow(maid, 5)
    velocityRow.Parent = rightContent

    -- 6. Animation Dropdown
    if AnimationsSection and type(AnimationsSection.new) == "function" then
        local anims = AnimationsSection.new(6)
        anims.Instance.Parent = rightContent
        maid:GiveTask(anims)
    end

    -- GlowBar Sync Principal
    if toggleBtn and glowBar then
        maid:GiveTask(toggleBtn.Toggled:Connect(function(state: boolean)
            glowBar:SetState(state)
        end))
    end

    maid:GiveTask(container)
    
    local self = {}
    self.Instance = container

    function self:Destroy()
        maid:Destroy()
    end

    return self :: FlyUI
end

return FlyFactory
