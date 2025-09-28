local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InputServise = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local CameraController = require(ReplicatedStorage.Scriptables.Camera.CameraController)
local FollowMode = require(ReplicatedStorage.Scriptables.Camera.Modes.FollowFromAbove)
local ExplosionEffect = require(ReplicatedStorage.Scriptables.Camera.Effects.ExplosionEffect)


local BombExplosion = ReplicatedStorage.Events.BombExplosion
local RoundEvent = ReplicatedStorage.Events.RoundEvent
local PlayerKilledEvent = ReplicatedStorage.Events:FindFirstChild("PlayerKilled")


-- client variables
local status = 0 -- status of the player, 0 = waiting, 1 = in game, 2 = dead

local controller = CameraController.new(player, workspace.CurrentCamera)


InputServise.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.B then
		game.ReplicatedStorage.Events.BombSpawn:FireServer()
	end
end)

BombExplosion.OnClientEvent:Connect(function(msg)
	if msg == "BombExploded" then
		local effect = ExplosionEffect.new(2, 1)
		
		controller:AddEffect(effect)
	end
end)

RoundEvent.OnClientEvent:Connect(function(msg, data)
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

PlayerKilledEvent.OnClientEvent:Connect(function()
	controller:RestoreDefaultCamera()
end)
