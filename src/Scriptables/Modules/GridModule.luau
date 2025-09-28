local GridModule = {}
local meta = {}
meta.__index = meta

function GridModule.new(gridOrigin:Vector3, gridSize:Vector2, cellSize:number)
	local self = {}
	setmetatable(self, meta)
	
	self.origin = gridOrigin
	self.size = gridSize
	self.cell = cellSize
	
	self.data = {}
	
	self.instances = {}
	
	return self
end


function meta:InitiateGrid()
	for x = 1, self.size.X do
		self.data[x] = {}
		
		for y = 1, self.size.Y do
			if x % 2 == 0 and y % 2 ==0 then
				self.data[x][y] = 1
			elseif math.random() < 0.5 then
				self.data[x][y] = 2
			else
				self.data[x][y] = 0
			end
		end
	end
end


function meta:GetWorldPosition(gridPos:Vector2)
	local x = self.origin.X + (gridPos.X - 1) * self.cell
	local y = self.origin.Z + (gridPos.Y - 1) * self.cell
	
	return Vector3.new(x, self.origin.Y, y)
end


function meta:GetCellPosition(worldPos:Vector3)
	local x = math.floor((worldPos.X - self.origin.X) / self.cell) + 1
	local y = math.floor((worldPos.Z - self.origin.Z) / self.cell) + 1
	
	return Vector2.new(x, y)
end


function meta:GetState(gridPos:Vector2)
	local state = nil
	if gridPos.X > 0 and gridPos.X <= self.size.X then
		state = self.data[gridPos.X][gridPos.Y]
	end
	
	return state
end


function meta:SpawnField()
	self.instances = {}
	
	for x = 1, self.size.X do
		self.instances[x] = {}
		
		for y = 1, self.size.Y do
			local cellType = self.data[x][y]
			local cellPosition = self:GetWorldPosition(Vector2.new(x, y))
			
			-- spawn wall if cell has index of 1
			if cellType == 1 then
				local wall = game.ReplicatedStorage.Models.Wall:Clone()
				wall.Position = cellPosition + Vector3.new(0, wall.Size.Y/2, 0)
				wall.Parent = workspace
				self.instances[x][y] = wall
			end
			
			-- spawn box if cell has index of 2
			if cellType == 2 then
				local box = game.ReplicatedStorage.Models.Box:Clone()
				box.Position = cellPosition +  Vector3.new(0, box.Size.Y/2, 0)
				box.Parent = workspace
				self.instances[x][y] = box
			end
		end
	end
end


function meta:ClearCell(cellPos:Vector2)
	self.data[cellPos.X][cellPos.Y] = 0
	
	local cell = self.instances[cellPos.X][cellPos.Y]
	if cell then
		self.instances[cellPos.X][cellPos.Y]:Destroy()
		self.instances[cellPos.X][cellPos.Y] = nil
	end
end

function meta:ClearAllCells()
	for x = 1, self.size.X do
		for y = 1, self.size.Y do
			self:ClearCell(Vector2.new(x, y))
		end
	end
end


function meta:__tostring()
	local lines = {}
	for row = 1, self.size.X do
		local line = {}
		for col = 1, self.size.Y do
			table.insert(line, tostring(self.data[row][col]))
		end
		table.insert(lines, table.concat(line, " "))
	end
	return table.concat(lines, "\n")
end

return GridModule



-- explanation of notation:
-- 1: wall
-- 2: box
-- 0: empty