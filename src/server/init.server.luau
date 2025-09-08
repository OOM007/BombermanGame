local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- requiring Modules
local BombModule = require(ReplicatedStorage.Scriptables.Modules.BombModule)
local GridModule = require(ReplicatedStorage.Scriptables.Modules.GridModule)
local EffectControl = require(ReplicatedStorage.Scriptables.Modules.EffectControl)
local CombatModule = require(ReplicatedStorage.Scriptables.Modules.CombatModule)

-- RemoteEvents
local BombSpawnEvent = ReplicatedStorage.Events:FindFirstChild("BombSpawn")
local BombExplosionEvent = ReplicatedStorage.Events:FindFirstChild("BombExplosion")
local PlayerKilledEvent = ReplicatedStorage.Events:FindFirstChild("PlayerKilled")

-- in game configs
local bombRange = 2
local bombTimer = 2
local gridSize = 8

-- making and initialising the grid and the bomb handler
local grid = GridModule.new(Vector3.new(48, 2, -32), Vector2.new(11, 17), gridSize)
local bomb = BombModule.new(grid)

-- Initialising the grid and spawning the field
grid:InitiateGrid()
grid:SpawnField()

-- spawn handler (when player presses the button, it spawns the bomb at the location)
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

-- bomb update loop (updates the bomb queue every frame)
RunService.Heartbeat:Connect(function(dt)
	local exploded, infoList = bomb:Update(grid)
	
	if exploded then
		BombExplosionEvent:FireAllClients("BombExploded") -- firing clients for explosion effect
	end
	
	for _, info in ipairs(infoList) do
		if info.pos then
			local worldPos = grid:GetWorldPosition(info.pos)
			
			if info.state == 2 then
				grid:ClearCell(info.pos) -- clearing destroyed cells
			end
			
			EffectControl.explosion(worldPos) -- applying effects om the affected cells
			local killed = CombatModule:ApplyExplosionDamage(worldPos, gridSize) -- applying explosion damage and getting affected players
			
			for _, player in pairs(killed) do
				PlayerKilledEvent:FireClient(player) -- firing clients for changing their state
			end
		end
	end
end)
