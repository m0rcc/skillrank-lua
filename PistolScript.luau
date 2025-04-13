-- (LOCAL SCRIPT)
-- Services

local RF = game:GetService("ReplicatedFirst")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")

-- Modules

local Modules = script.Parent.Modules
local BulletClientRender = require(Modules.createBullet)

-- Events

local Events = script.Parent.Events
local weaponTrigger = Events.WeaponTrigger

-- Important

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:FindFirstChild("Humanoid")
local Animator = Humanoid:FindFirstChildOfClass("Animator")

local Mouse = game.Players.LocalPlayer:GetMouse()
local Camera = game.Workspace.CurrentCamera

-- Assets 

local Gun = script.Parent.Parent
local Bullet_Hole = Gun.Bullet_Hole

local Assets = RF:FindFirstChild("Assets")

local Animations = {
    Animator:LoadAnimation(Assets.Animations.Gun_Hold)
}

local Sounds = {
    Assets.Sounds.Pistol_Equipped, Assets.Sounds.Pistol_Shoot,
    Assets.Sounds.Pistol_Reload
}

-- ui

local UI = Player.PlayerGui.Experimental.AmmoUI
local Frame = UI.Frame
local AmmoDisplay = Frame.AmmoDisplay

-- Conditions / Int

local FireRate = 0.4
local prev = 0

local Ammo = 8
local is_Reloading = false
local is_Equipped = false

-- Functions

local function canShoot()
    local curr = tick()
    if curr - prev >= FireRate then
        return true
    else
        return false
    end
end

Gun.Equipped:Connect(function()
    
    Sounds[1]:Play()
    Animations[1]:Play()
    Mouse.Icon = "http://www.roblox.com/asset/?id=4540204883"
    
    Frame.Visible = true
    
    if is_Reloading then
        AmmoDisplay.Text = "... | 8"
    else
        AmmoDisplay.Text = Ammo.." | 8"
    end
    
    is_Equipped = true
    
    UIS.InputBegan:Connect(function(i, gpe)
        if gpe then return end
        
        if i.KeyCode == Enum.KeyCode.R and Ammo < 8 and is_Equipped == true and is_Reloading == false then
            is_Reloading = true
            
            AmmoDisplay.Text = "... | 8"
            Sounds[3]:Play()

            task.wait(3)

            Ammo = 8
            AmmoDisplay.Text = Ammo.." | 8"
            
            is_Reloading = false
        end
    end)
    
    Gun.Activated:Connect(function()
        
        if canShoot() then
            if Ammo == 0 and is_Reloading == false then
                is_Reloading = true
                
                AmmoDisplay.Text = "... | 8"
                Sounds[3]:Play()
                
                task.wait(3)
                
                Ammo = 8
                AmmoDisplay.Text = Ammo.." | 8"
                is_Reloading = false
                
            elseif Ammo > 0 and is_Reloading == false then
                prev = tick()

                Sounds[2]:Play()
                Ammo -= 1
                AmmoDisplay.Text = Ammo.." | 8"

                BulletClientRender.new(Bullet_Hole.Position, Mouse.Hit.Position, Player.Name, true)
                weaponTrigger:FireServer(Bullet_Hole.Position, Mouse.Hit.Position, Player.Name)
            end
        end
    end)
end)

Gun.Unequipped:Connect(function()
    
    Mouse.Icon = ""
    Animations[1]:Stop()
    
    is_Equipped = false
    Frame.Visible = false
    
end)

-- RS

RS.RenderStepped:Connect(function(dT)
    
    local char = game:GetService("Players").LocalPlayer.Character
    local r_shoulder = char:FindFirstChild("Right Shoulder", true)
    local l_shoulder = char:FindFirstChild("Left Shoulder", true)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    local hrp_tween = nil
    
    if is_Equipped then
        
        local X = Mouse.Hit.Position.X
        local Y = Mouse.Hit.Position.Y
        local Z = Mouse.Hit.Position.Z
        
        -- HumanoidRootPart
        
        local hrp_Y = hrp.Position.Y
        local hrp_t_info = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local hrp_CFrame = CFrame.lookAt(hrp.Position, Vector3.new(X, hrp_Y, Z))
        
        local hrp_tween = TS:Create(hrp, hrp_t_info, {CFrame = hrp_CFrame}):Play()
        
        
        hrp.CFrame = hrp_CFrame
        
        -- Arms
        
        local mouse_pitch_offset = hrp.CFrame:PointToObjectSpace(Mouse.Hit.Position)
        local mouse_pitch_angle = math.atan2(mouse_pitch_offset.Y, -mouse_pitch_offset.Z)

        r_shoulder.C0 = CFrame.new(r_shoulder.C0.X, r_shoulder.C0.Y, 0) * CFrame.Angles(mouse_pitch_angle / 1.3, math.pi / 2, 0)
        l_shoulder.C0 = CFrame.new(l_shoulder.C0.X, l_shoulder.C0.Y, 0) * CFrame.Angles(0, -(math.pi / 2), -mouse_pitch_angle / 1.3)
        
    else
        r_shoulder.C0 = CFrame.new(r_shoulder.C0.X, r_shoulder.C0.Y, 0) * CFrame.Angles(0, math.pi / 2, 0)
        l_shoulder.C0 = CFrame.new(l_shoulder.C0.X, l_shoulder.C0.Y, 0) * CFrame.Angles(0, -(math.pi / 2), 0)
          
        if hrp_tween then
            hrp_tween:Stop()
        end
        
    end
end)

-- (SERVER SCRIPT: ServerWeaponHandler)
-- Modules

local Modules = script.Parent.Modules
local createRay = require(Modules.createRay)
local Bullet = require(Modules.createBullet)

-- Events

local Events = script.Parent.Events
local WeaponTrigger = Events.WeaponTrigger

-- Values

local bullet_Range = 500

WeaponTrigger.OnServerEvent:Connect(function(player, origin, target, plrName, custom)
    Bullet.new(origin, target, plrName, false)
    
    local rayDetected = createRay.new(player, origin, target, bullet_Range)
    if not rayDetected then
        return
    end
    
    if rayDetected.Instance.Parent:IsA("Model") then
        local char = rayDetected.Instance.Parent
        local humanoid = rayDetected.Instance.Parent:FindFirstChild("Humanoid")
        
        if humanoid then
            if rayDetected.Instance.Name == "Head" then
                humanoid:TakeDamage(25)
            else
                humanoid:TakeDamage(15)
            end
        end
    end
end)

-- (SERVER SCRIPT: createRay)

local createRay = {}

function createRay.new(player, origin, targetPos, range)
    
    local direction = (targetPos - origin).Unit * range
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {player.Character, game.Workspace.Baseplate}
    raycastParams.IgnoreWater = true
    
    local raycast = game.Workspace:Raycast(origin, direction, raycastParams)
    if raycast then
        return raycast
    else
        return nil
    end
end

return createRay

-- (SERVER SCRIPT: createTracer)
-- Services

local TS = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local createBullet = {}
createBullet.__index = createBullet

function createBullet.new(origin, target, player, is_client, custom)
    local self = setmetatable({}, createBullet)
    
    local distance = (target - origin).Magnitude
    
    self.default_config = {
        Color = ColorSequence.new(Color3.fromRGB(255, 247, 130)),

        TextureSpeed = 0,
        TextureLength = 10,

        Transparency = NumberSequence.new(0),
        ZOffset = 0,
        LightEmission = 5,

        FaceCamera = true,
        Width0 = 0.2,
        Width1 = 0.2
    }
    
    local bulletPart = Instance.new("Part", game.Workspace.Bullets)
    bulletPart.Name = "Bullet - "..player
    bulletPart.Anchored = true
    bulletPart.CanCollide = false
    bulletPart.Transparency = 1
    bulletPart.Size = Vector3.new(0.05, 0.05, 0.05)
    
    bulletPart.CFrame = CFrame.lookAt(origin, target)
    
    local Att0 = Instance.new("Attachment", bulletPart)
    local Att1 = Instance.new("Attachment", bulletPart)
    
    Att0.Position = Vector3.new(0, 0, 0)
    Att1.Position = Vector3.new(0, 0, -distance)
    
    local tracer = Instance.new("Beam", bulletPart)
    tracer.Attachment0 = Att0
    tracer.Attachment1 = Att1
    
    for property, val in pairs(self.default_config) do
        tracer[property] = val
    end
    
    if custom then
        for property, val in pairs(custom) do
            tracer[property] = val
        end
    end
    
    task.spawn(function()
        task.wait()
        
        local t_info = TweenInfo.new(0.05 * (distance / 25), Enum.EasingStyle.Linear)
        local tween = TS:Create(Att0, t_info, {Position = Att1.Position})
        
        tween:Play()
        
        if is_client then
            Debris:AddItem(bulletPart, 0.05)
        elseif not is_client then
            Debris:AddItem(bulletPart, 3)
            tween.Completed:Wait()

            bulletPart:Destroy()
        end
    end)
end


return createBullet

