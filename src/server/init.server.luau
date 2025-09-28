local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local BombModule = require(ReplicatedStorage.Scriptables.Modules.BombModule)
local GridModule = require(ReplicatedStorage.Scriptables.Modules.GridModule)
local EffectControl = require(ReplicatedStorage.Scriptables.Modules.EffectControl)
local CombatModule = require(ReplicatedStorage.Scriptables.Modules.CombatModule)
local RoundManager = require(ReplicatedStorage.Scriptables.Modules.RoundManager)

local BombSpawnEvent = ReplicatedStorage.Events:FindFirstChild("BombSpawn")
local BombExplosionEvent = ReplicatedStorage.Events:FindFirstChild("BombExplosion")
local PlayerKilledEvent = ReplicatedStorage.Events:FindFirstChild("PlayerKilled")

-- in game configs
local bombRange = 2
local bombTimer = 2
local gridSize = 8


local grid = GridModule.new(Vector3.new(48, 2, -32), Vector2.new(11, 17), gridSize)
local bomb = BombModule.new(grid)


local roundManager = RoundManager.new(grid, Vector3.new(86, 2, -86), 60)


-- testing
roundManager:StartIntermission(5)


BombSpawnEvent.OnServerEvent:Connect(function(player)
	local playerPos = player.Character.PrimaryPart.Position
	local fieldPos = {grid.origin, grid:GetWorldPosition(grid.size)}
	
	--checks if player are in the gamefield
	if playerPos.X >= fieldPos[1].X-1 and playerPos.X <= fieldPos[2].X+1 then
		if playerPos.Z >= fieldPos[1].Z-1 and playerPos.Z <= fieldPos[2].Z+1 then
			bomb:SpawnBomb(playerPos, bombTimer, bombRange) 
		end
	end
end)

-- bomb update loop
RunService.Heartbeat:Connect(function(dt)
	local exploded, infoList = bomb:Update(grid)
	
	if exploded then
		BombExplosionEvent:FireAllClients("BombExploded")
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
				PlayerKilledEvent:FireClient(player)
			end
		end
	end
end)