local debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EffectControl = {}

function EffectControl.explosion(pos)
	local model = ReplicatedStorage.Models.Explosion:Clone()
	model.Parent = game.Workspace
	model.Position = pos
	
	local goal = {
		Size = Vector3.new(4, 4, 4)
	}
	
	local info = TweenInfo.new(1) -- time for animation
	local tween = TweenService:Create(model, info, goal)
	
	tween:Play()
	
	debris:AddItem(model, 2)
	
end


return EffectControl