local TS = game:GetService("TweenService")

local LocalPlayer = game.Players.LocalPlayer
local Humanoid = LocalPlayer.Character.Humanoid
local oldHealth = Humanoid.Health

local UI = LocalPlayer.PlayerGui.MainUI
local Health_Status = UI.Health.Health_Bar

local health_info = TweenInfo.new(.4)
local health_color_info = TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

Humanoid.HealthChanged:Connect(function()
    local health_tween = TS:Create(Health_Status, health_info, {Size = UDim2.new(Humanoid.Health / 100, -4, 1, -3)}):Play()
    
    if oldHealth > Humanoid.Health then
        local dmged_Tween = TS:Create(Health_Status, health_info, {BackgroundColor3 = Color3.fromRGB(170, 61, 61)}):Play()
        task.wait(.3)
        local ogcolor_Tween = TS:Create(Health_Status, health_info, {BackgroundColor3 = Color3.fromRGB(133, 255, 131)}):Play()
    else
        local regen_Tween = TS:Create(Health_Status, health_info, {BackgroundColor3 = Color3.fromRGB(105, 255, 64)}):Play()
        task.wait(.3)
        local ogcolor_Tween = TS:Create(Health_Status, health_info, {BackgroundColor3 = Color3.fromRGB(133, 255, 131)}):Play()
    end
    
    oldHealth = Humanoid.Health
    
    if Humanoid.Health <= 0 then
        local no_health_tween = TS:Create(Health_Status, health_info, {Size = UDim2.new(Humanoid.Health / 100, 0, 1, -3)}):Play()
        Health_Status.Text = ""
    else
        Health_Status.Text = math.round(Humanoid.Health).." | 100"
    end
end)
