-- Services --

local TS = game:GetService("TweenService")

-- Assets --

local DoorPart = script.Parent.Door
local keycardScanner = script.Parent.KeycardScanner
local cardDetector = keycardScanner.CardDetectorPart

local Sounds = script.Parent:FindFirstChild("Sounds")

local doorDebounce = false

local DoorConfigurations = {
    doorOpen = false,
    doorDebounce = false,
    
    openDuration = 1.5,
    doorOpenStandby = 2,
    
    scannerCooldown = 1
}

-- Tweens --

local door_info = TweenInfo.new(DoorConfigurations.openDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local doorOpen_Tween = TS:Create(DoorPart, door_info, {CFrame = DoorPart.CFrame * CFrame.new(0, 6.4, 0)})
local doorClose_Tween = TS:Create(DoorPart, door_info, {CFrame = DoorPart.CFrame})

-- Functionality --

cardDetector.CanTouch = true

cardDetector.Touched:Connect(function(hit)
    if DoorConfigurations.doorDebounce == false then
        DoorConfigurations.doorDebounce = true
        
        if hit.Parent:IsA("Tool") and hit:GetAttribute("isKeycard") == true then
            
            local currentKeyLevel = hit:GetAttribute("currentLevel")
            local requiredKeyLevel = keycardScanner:GetAttribute("keycardLevel")
            
            if currentKeyLevel >= requiredKeyLevel then
                
                Sounds.Keycard_Granted:Play()
                task.wait(1)
                Sounds.Door_Sound:Play()
                doorOpen_Tween:Play()
                task.wait(DoorConfigurations.doorOpenStandby)
                Sounds.Door_Sound:Play()
                doorClose_Tween:Play()
                task.wait(DoorConfigurations.scannerCooldown)
                DoorConfigurations.doorDebounce = false
                
            else
                
                Sounds.Keycard_Denied:Play()
                task.wait(DoorConfigurations.scannerCooldown)
                DoorConfigurations.doorDebounce = false
                
            end
        else
            DoorConfigurations.doorDebounce = false
        end
    end
end)
