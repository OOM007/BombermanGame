local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InputServise = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- setting up camera controller and modes required
local CameraController = require(ReplicatedStorage.Scriptables.Camera.CameraController)
local FollowMode = require(ReplicatedStorage.Scriptables.Camera.Modes.FollowFromAbove)
local ExplosionEffect = require(ReplicatedStorage.Scriptables.Camera.Effects.ExplosionEffect)


-- Server events
local BombExplosion = ReplicatedStorage.Events.BombExplosion
local PlayerKilledEvent = ReplicatedStorage.Events:FindFirstChild("PlayerKilled")


-- client variables
local status = 0 -- status of the player, 0 = waiting, 1 = in game, 2 = dead

-- initiating camera
local controller = CameraController.new(player, workspace.CurrentCamera)
controller:SetMode(FollowMode)

-- starting the controller of the camera
controller:Start()

-- sends request to server to spawn the bomb
InputServise.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.B then
		game.ReplicatedStorage.Events.BombSpawn:FireServer() -- triggers the bomb spawn on server side
	end
end)

-- event sequence when bomb exploded near the player
BombExplosion.OnClientEvent:Connect(function(msg)
	if msg == "BombExploded" then
		local effect = ExplosionEffect.new(2, 1)
		
		controller:AddEffect(effect)
	end
end)

-- event sequence when player died
PlayerKilledEvent.OnClientEvent:Connect(function()
	status = 2
	controller:RestoreDefaultCamera()
end)
