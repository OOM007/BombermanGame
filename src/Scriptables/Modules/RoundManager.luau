local RoundManager = {}
RoundManager.__index = RoundManager

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Networker = require(ReplicatedStorage.Scriptables.Packages.Networker)


local function resetPlayers(self)
	for _, player in pairs(Players:GetPlayers()) do
		if not player.Character or not player.Character.PrimaryPart then
			continue
		end

		player.Character.PrimaryPart.CFrame = CFrame.new(
			self.spawnLocation.X + math.random(-5, 5), self.spawnLocation.Y, self.spawnLocation.Z + math.random(-5, 5))

		local humanoid = player.Character:FindFirstChild("Humanoid")	
		if humanoid then
			humanoid.Health = 100
		end
	end
end


local function findFreeCell(start: Vector2, grid: GridModule)
	local queue = {start}
	local visited = {}
	local directions = {
		Vector2.new(1, 0), Vector2.new(-1, 0),
		Vector2.new(0, 1), Vector2.new(0, -1)
	}
	
	visited[start] = true
	
	while #queue > 0 do
		local current = table.remove(queue, 1)
		local state = grid:GetState(current)
		
		if state == 0 then
			return current
		end
		
		for _, dir in pairs(directions) do
			local nx, ny = current.X + dir.X, current.Y + dir.Y
			
			if nx <= 0 or nx > grid.size.X or ny <= 0 or ny > grid.size.Y then
				continue
			end
			
			local key = Vector2.new(nx, ny)
			
			if not visited[key] then
				visited[key] = true
				table.insert(queue, key)
			end
		end
	end
	
	return start
end

local function getSpawnPositions(self)
	local corners = {
		Vector2.new(1, 1), Vector2.new(self.grid.size.X, 1),
		Vector2.new(1, self.grid.size.Y), Vector2.new(self.grid.size)
	}
	
	local spawnPoints = {}
	
	for i = 1, #Players:GetPlayers() do
		local pos = findFreeCell(corners[i], self.grid)
		table.insert(spawnPoints, self.grid:GetWorldPosition(pos))
	end
	
	return spawnPoints
end


local function spawnPlayers(self)
	local spawnPoints = getSpawnPositions(self)
	
	for i, player in pairs(Players:GetPlayers()) do
		if player.Character and player.Character.PrimaryPart then
			player.Character.PrimaryPart.CFrame = CFrame.new(spawnPoints[i])
		end
	end
end




function RoundManager.new(grid: GridModule, spawningLocation: Vector3, roundLength: number)
	if not grid then
		error("RoundManager requires GridModule instance to be operational")
	end
	
	local self = setmetatable({}, RoundManager)
	self.grid = grid
	self.state = "Idle"
	self.roundLength = roundLength or 60
	self.AlivePlayers = {} 
	
	self.spawnLocation = spawningLocation or Vector3.new(0, 0, 0)
	
	return self
end


function RoundManager:MarkAlive(player, alive: boolean)
	self.AlivePlayers[player.UserId] = alive
end

function RoundManager:IsAlive(player)
	return self.AlivePlayers[player.UserId]
end

function RoundManager:ResetAlivePlayers()
	self.AlivePlayers = {}
	for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
		self.AlivePlayers[plr.UserId] = true
	end
end



function RoundManager:CheckWinCondition()
	local aliveCount = 0
	for _, alive in pairs(self.AlivePlayers) do
		if alive then aliveCount += 1 end
	end

	return aliveCount <= 1
end


function RoundManager:StartIntermission(t: number)
	self.state = "Intermission"
	
	for t = t, 1, -1 do
		print("intermission: "..t)
		Networker.FireAllClients("RoundEvent", "Intermission", t)
		task.wait(1)
	end
	
	self:StartRound(self.roundLength)
end


function RoundManager:StartRound(t:number)
	local t = t or 10
	self.state = "RoundActive"
	
	if #self.grid.data >= 1 then
		self.grid:ClearAllCells()
	end
	
	self.grid:InitiateGrid()
	self.grid:SpawnField()
	
	self:ResetAlivePlayers()
	spawnPlayers(self)
	
	Networker.FireAllClients("RoundEvent", "RoundStart")
	
	local roundTime = t
	local accumulator = 0
	local connction
		
	connction = RunService.Heartbeat:Connect(function(dt)
		if self.state ~= "RoundActive" then
			connction:Disconnect()
			return
		end
		
		roundTime -= dt
		accumulator += dt
		
		if accumulator >= 1 then
			Networker.FireAllClients("RoundTimer", math.ceil(roundTime))
			accumulator = 0
		end
		
		if roundTime <= 0 or self:CheckWinCondition() then
			connction:Disconnect()
			self:EndRound()
		end
		
	end)
	
end

function RoundManager:EndRound()
	self.state = "RoundEnd"
	Networker.FireAllClients("RoundEvent", "RoundEnd")
	
	
	resetPlayers(self)
	
	
	print("Round ended")
end

return RoundManager



--States:
-- Idle
-- Intermission
-- RoundActive
-- RoundEnd


-- Messeges that may be thrown:
-- RoundEnd
-- RoundStart
-- Intermission (t)
-- RoundTimer (t)