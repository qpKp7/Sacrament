--!strict
local TweenService = game:GetService("TweenService")
local Constants = require(script.Parent.Parent.Parent.config.constants)
local Colors = require(script.Parent.Parent.Parent.themes.colors)
local Maid = require(script.Parent.Parent.Parent.utils.maid)

export type TabButton = {
    Instance: TextButton,
    SetActive: (self: TabButton, isActive: boolean) -> (),
    Destroy: (self: TabButton) -> ()
}

local TabButtonModule = {}

local function playTween(instance: Instance, props: {[string]: any}, maid: any)
    local tween = TweenService:Create(instance, Constants.UI_TWEEN_INFO, props)
    maid:GiveTask(tween.Completed:Connect(function()
        tween:Destroy()
    end))
    tween:Play()
end

function TabButtonModule.new(name: string, layoutOrder: number, onClick: (string) -> ()): TabButton
    local maid = Maid.new()
    local isActiveState = false

    local btn = Instance.new("TextButton")
    btn.Name = "Button_" .. name
    btn.Size = UDim2.new(0.85, 0, 0, 38)
    btn.BackgroundColor3 = Colors.ButtonDefault
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Colors.TextDefault
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.AutoButtonColor = false
    btn.LayoutOrder = layoutOrder
    btn.Active = true

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Name = "BtnStroke"
    stroke.Thickness = 1
    stroke.Color = Colors.Divider
    stroke.Transparency = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = btn

    maid:GiveTask(btn.MouseEnter:Connect(function()
        if not isActiveState then
            playTween(btn, {BackgroundColor3 = Colors.ButtonHover}, maid)
            playTween(stroke, {Transparency = 0.5, Thickness = 1}, maid)
        end
    end))

    maid:GiveTask(btn.MouseLeave:Connect(function()
        if not isActiveState then
            playTween(btn, {BackgroundColor3 = Colors.ButtonDefault}, maid)
            playTween(stroke, {Transparency = 1}, maid)
        else
            playTween(btn, {BackgroundColor3 = Colors.ButtonActive}, maid)
        end
    end))

    maid:GiveTask(btn.MouseButton1Click:Connect(function()
        onClick(name)
    end))

    local self = {}
    
    function self:SetActive(isActive: boolean)
        isActiveState = isActive
        if isActive then
            playTween(btn, {BackgroundColor3 = Colors.ButtonActive}, maid)
            playTween(stroke, {Transparency = 0.15, Thickness = 2}, maid)
        else
            playTween(btn, {BackgroundColor3 = Colors.ButtonDefault}, maid)
            playTween(stroke, {Transparency = 1, Thickness = 1}, maid)
        end
    end

    function self:Destroy()
        maid:Destroy()
        btn:Destroy()
    end

    self.Instance = btn
    return self
end

return TabButtonModule
