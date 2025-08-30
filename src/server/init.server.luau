local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BombModule = require(ReplicatedStorage.Modules.BombModule)
local GridModule = require(ReplicatedStorage.Modules.GridModule)

local BombSpawnEvent = ReplicatedStorage.Events:FindFirstChild("BombSpawn")

-- making and initialising the grid and the bomb handler
local grid = GridModule.new(Vector3.new(48, 2.5, -32), Vector2.new(11, 17), 8)
local bombModule = BombModule.new(grid)

grid:InitiateGrid()
grid:SpawnField()

-- spawn handler (when player presses the button, it spawns the bomb at the location)
BombSpawnEvent.OnServerEvent:Connect(function(player)
	local playerPos = player.Character.PrimaryPart.Position
	local fieldPos = {grid.origin, grid:GetWorldPosition(grid.size)}
	
	--checks if player are in the ganmefield
	if playerPos.X >= fieldPos[1].X-1 and playerPos.X <= fieldPos[2].X+1 then
		if playerPos.Z >= fieldPos[1].Z-1 and playerPos.Z <= fieldPos[2].Z+1 then
			bombModule:SpawnBomb(playerPos, 2)
		end
	end
end)

-- bomb update loop
task.spawn(function()
	while true do
		bombModule:Update()
		task.wait(0.1)
	end
end)