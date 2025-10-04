local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InputServise = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local CameraController = require(ReplicatedStorage.Scriptables.Camera.CameraController)
local FollowMode = require(ReplicatedStorage.Scriptables.Camera.Modes.FollowFromAbove)
local ExplosionEffect = require(ReplicatedStorage.Scriptables.Camera.Effects.ExplosionEffect)

local Networker = require(ReplicatedStorage.Scriptables.Packages.Networker)


local controller = CameraController.new(player, workspace.CurrentCamera)


InputServise.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.B then
		Networker.FireServer("BombSpawn")
	end
end)


Networker.OnClient("RoundEvent", function(msg)
	if msg == "Intermission" then
		print("Intermission on "..player.Name.."'s client")
	end

	if msg == "RoundStart" then
		controller:SetMode(FollowMode)
		controller:Start()
	end

	if msg == "RoundEnd" then
		if controller.IsActive then
			controller:RestoreDefaultCamera()
		end
	end
end)


Networker.OnClient("PlayerKilled", function()
	if controller.IsActive then
		controller:RestoreDefaultCamera()
	end
end)

Networker.OnClient("BombExplosion", function()
	local effect = ExplosionEffect.new(2, 1)
	controller:AddEffect(effect)
end)
