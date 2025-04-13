local TweenService = game:GetService("TweenService") -- Get Tween Service

local Model = script.Parent
local Door = Model.Door
local Prompt = Model.Top.Attachment.ProximityPrompt

local tweeninfo = TweenInfo.new(
	1.5,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.InOut,
	0,
	false,
	0
)

local DoorGoalOpen = {}
local DoorGoalClose = {}
DoorGoalOpen.CFrame = Door.CFrame * CFrame.new(Door.Size.X, 0, 0) -- The CFrame [X, Y, Z]
DoorGoalClose.CFrame = Door.CFrame
local DoorTweenOpen = TweenService:Create(Door, tweeninfo, DoorGoalOpen) -- Creating Tween Service [Parent, Custom Info, Goal Created]
local DoorTweenClose = TweenService:Create(Door, tweeninfo, DoorGoalClose) -- Creating Tween Service [Parent, Custom Info, Goal Created]

local sound = script.Parent.DoorSound

Prompt.Triggered:Connect(function() -- Prompt
	if Prompt.ActionText == "Close" then
		DoorTweenClose:Play()
		sound:Play()
		Prompt.Enabled = false
		wait(1.5)
		Prompt.Enabled = true
		Prompt.ActionText = "Open"
	else
		DoorTweenOpen:Play()
		sound:Play()
		Prompt.ActionText = "Close"
		Prompt.Enabled = false
		wait(1.5)
		Prompt.Enabled = true
	end
end)
