
-- Services

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")

local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

local RunService = game:GetService("RunService")

-- Events

local settingsEvent = RS:FindFirstChild("Remotes").RemoteEvent

-- Global Variables

local Player = Players.LocalPlayer
local PlayerName = Player.Name

local Char = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Char:FindFirstChildOfClass("Humanoid")

-- Modules

local SprintingConfigurations = require(Char:FindFirstChild("Modules").Sprinting)
local DashingConfigurations = require(Char:FindFirstChild("Modules").Dashing)

local playerSettings = {}

if Char then
    playerSettings = {
        Stamina = 100, -- Stamina is a global value for  all movesets.

        Running = SprintingConfigurations.runPresets({}),
        Dashing = DashingConfigurations.runPresets({})
    }
end

local dashDirections = {
    [Enum.KeyCode.W] = "W",
    [Enum.KeyCode.A] = "A",
    [Enum.KeyCode.S] = "S",
    [Enum.KeyCode.D] = "D"
}

-- UI

local MainUI = Player.PlayerGui.MainUI
local StaminaBar = MainUI.Stamina.Stamina_Bar

-- UI Tweens

local tween_info = TweenInfo.new(.3)
local dashed_tween_info = TweenInfo.new(.5)

--[[
    
    add_StaminaBar = TS:Create(StaminaBar, tween_info, {
        Size = UDim2.new(playerSettings.Stamina / 99.992, 0, 0.8, 0),
        BackgroundColor3 = Color3.fromRGB(108, 221, 255)
    })
    
    sub_StaminaBar = TS:Create(StaminaBar, tween_info, {
        Size = UDim2.new(playerSettings.Stamina / 99.992, 0, 0.8, 0),
        BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    })
    
]]--

-- Functions

local add_StaminaBar
local sub_StaminaBar

-- UIS Connections

UIS.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if Humanoid.MoveDirection.Magnitude < 0.1 then return end
    
    if i.KeyCode == Enum.KeyCode.LeftShift then
        playerSettings.Running:is_Sprinting(true)
    end
    
    if i.KeyCode == Enum.KeyCode.E and playerSettings.Dashing.inCooldown == false and playerSettings.Dashing.isTired == false then
        
        playerSettings.Stamina -= playerSettings.Dashing.staminaDrain
        
        for enum, key in dashDirections do
            
            if UIS.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
                playerSettings.Running:is_Sprinting(false)
                playerSettings.Dashing:is_Dashing(true, "W")
                return
            end
            
            if UIS:IsKeyDown(enum) then
                playerSettings.Running:is_Sprinting(false)
                playerSettings.Dashing:is_Dashing(true, key)
                break
            end
        end
    end
    
end)

UIS.InputEnded:Connect(function(i, gpe)
    if gpe then return end

    if i.KeyCode == Enum.KeyCode.LeftShift then
        playerSettings.Running:is_Sprinting(false)
    end
end)

-- RunService (Stamina System)

task.wait()

RunService.Heartbeat:Connect(function(dT)
    if not Player then return end
    if not playerSettings then return end
    
    if playerSettings.Running.runningState == true and Humanoid.MoveDirection.Magnitude > 0.1 then
        
        if playerSettings.Stamina > 0 then
            playerSettings.Stamina -= dT * playerSettings.Running.staminaDrain
            
            sub_StaminaBar = TS:Create(StaminaBar, tween_info, {
                Size = UDim2.new(playerSettings.Stamina / 99.992, 0, 0.8, 0),
                BackgroundColor3 = Color3.fromRGB(255, 85, 85)
            }):Play()
            
        else
            playerSettings.Running:is_Sprinting(false)
            playerSettings.Running.isTired = true
        end
    end
    
    if playerSettings.Dashing.dashingState == true then
        
        sub_StaminaBar = TS:Create(StaminaBar, dashed_tween_info, {
            Size = UDim2.new(playerSettings.Stamina / 99.992, 0, 0.8, 0),
            BackgroundColor3 = Color3.fromRGB(255, 85, 85)
        }):Play()
        
    elseif playerSettings.Stamina <= 35 then
        
        playerSettings.Dashing:is_Dashing(false)
        playerSettings.Dashing.isTired = true
        
    end
    
    if playerSettings.Running.runningState == false and playerSettings.Dashing.dashingState == false then
        if playerSettings.Stamina < 100 then
            playerSettings.Stamina += dT * 20
            
            task.wait(0.2)
            add_StaminaBar = TS:Create(StaminaBar, tween_info, {
                Size = UDim2.new(playerSettings.Stamina / 101, 0, 0.8, 0),
                BackgroundColor3 = Color3.fromRGB(108, 221, 255)
            }):Play()

            if playerSettings.Stamina > 100 then
                playerSettings.Stamina = 100 -- Conversion (via it rounding off)
            end

            if playerSettings.Stamina > playerSettings.Running.staminaDelay then
                playerSettings.Running.isTired = false
            end

            if playerSettings.Stamina > playerSettings.Dashing.staminaDelay then
                playerSettings.Dashing.isTired = false
            end
        end
    end
end)
