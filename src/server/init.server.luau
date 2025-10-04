local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local BombModule = require(ReplicatedStorage.Scriptables.Modules.BombModule)
local GridModule = require(ReplicatedStorage.Scriptables.Modules.GridModule)
local EffectControl = require(ReplicatedStorage.Scriptables.Modules.EffectControl)
local CombatModule = require(ReplicatedStorage.Scriptables.Modules.CombatModule)
local RoundManager = require(ReplicatedStorage.Scriptables.Modules.RoundManager)

local Networker = require(ReplicatedStorage.Scriptables.Packages.Networker)

local BombSpawnEvent = ReplicatedStorage.Events:FindFirstChild("BombSpawn")
local BombExplosionEvent = ReplicatedStorage.Events:FindFirstChild("BombExplosion")
local PlayerKilledEvent = ReplicatedStorage.Events:FindFirstChild("PlayerKilled")

-- in game configs
local bombRange = 2
local bombTimer = 2
local gridSize = 8
local cooldown = 3


local grid = GridModule.new(Vector3.new(48, 2, -32), Vector2.new(11, 17), gridSize)
local bomb = BombModule.new(grid)


local roundManager = RoundManager.new(grid, Vector3.new(86, 2, -86), 30)


local lastBombTime = {}

Networker.OnServer("BombSpawn", function(player)
	local playerPos = player.Character.PrimaryPart.Position
	
	if roundManager.state ~= "RoundActive" then
		return
	end
	
	local fieldPos = {grid.origin, grid:GetWorldPosition(grid.size)}
	
	bomb:SpawnBomb(playerPos, bombTimer, bombRange, player)

end)

Networker.OnServer("StartGame", function()
	roundManager:StartIntermission(5)
end)


-- bomb update loop
RunService.Heartbeat:Connect(function(dt)
	local exploded, infoList = bomb:Update(grid)
	
	if exploded then
		Networker.FireAllClients("BombExplosion")
	end
	
	for _, info in ipairs(infoList) do
		if info.pos then
			local worldPos = grid:GetWorldPosition(info.pos)
			
			if info.state == 2 then
				grid:ClearCell(info.pos)
			end
			
			EffectControl.explosion(worldPos)
			local killed = CombatModule:ApplyExplosionDamage(worldPos, gridSize)
			
			for _, player in pairs(killed) do
				roundManager:MarkAlive(player, false)
				Networker.FireClient(player, "PlayerKilled")
			end
		end
	end
end)
