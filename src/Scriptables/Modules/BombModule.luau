local BombModule = {}
local meta = {}
meta.__index = meta

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EffectControl = require(ReplicatedStorage.Scriptables.Modules.EffectControl)
local CombatModule = require(ReplicatedStorage.Scriptables.Modules.CombatModule)
local TableUtil = require(ReplicatedStorage.Scriptables.Utils.TableUtil)

local BOMB = ReplicatedStorage.Models.Bomb

function BombModule.new(grid)
	local self = setmetatable ({}, meta)
	self.queue = {}
	self.grid = grid
	
	return self
end

function meta:SpawnBomb(pos:Vector3, fuseTime:number, explosionPower:number)
	local bomb = BOMB:Clone()
	bomb.Parent = game.Workspace
	
	-- bomb's information
	local bombInfo = {pos = Vector3.new(
		math.floor(pos.X/self.grid.cell + 0.5)*self.grid.cell, 2.5, math.floor(pos.Z/self.grid.cell + 0.5)*self.grid.cell),
		explodeAt = os.clock()+fuseTime,
		range = explosionPower or 1,
		instance = bomb}
	
	table.insert(self.queue, bombInfo)
	
	bomb:MoveTo(bombInfo.pos)
	
	return bomb
end

function meta:Explode(bomb: table)
	if bomb and bomb.instance.PrimaryPart then
		local ExplodedCells = {}
		
		bomb.instance:Destroy()
		
		local gridPos = self.grid:GetCellPosition(bomb.pos)
		
		table.insert(ExplodedCells, {pos = gridPos, state = 0})
		
		TableUtil.InsertTableInTable(ExplodedCells, self:DestroyInDirection(gridPos, Vector2.new(1, 0), bomb.range))
		TableUtil.InsertTableInTable(ExplodedCells, self:DestroyInDirection(gridPos, Vector2.new(0, 1), bomb.range))
		TableUtil.InsertTableInTable(ExplodedCells, self:DestroyInDirection(gridPos, Vector2.new(-1, 0), bomb.range))
		TableUtil.InsertTableInTable(ExplodedCells, self:DestroyInDirection(gridPos, Vector2.new(0, -1), bomb.range))
		
		return ExplodedCells
	end
end

function meta:DestroyInDirection(startPos: Vector2, dir: Vector2, range: number)
	local pos = startPos
	local coords = {} -- coordinates of destroyed cells
	
	for i = 1, range do
		pos = pos + dir
		
		local state = self.grid:GetState(pos)
		
		-- if the position is out of bounds or it is a wall, break
		if state == nil or state == 1 then
			break
		end
		
		table.insert(coords, {pos = pos, state = state})
	end
	
	return coords
	
end

function meta:Update(grid)
	local now = os.clock()
	local explosions = {}
	local exploded = false
	
	for i=#self.queue, 1, -1 do
		local bomb = self.queue[i]
		if now >= bomb.explodeAt then
			explosions = self:Explode(bomb)
			exploded = true
			table.remove(self.queue, i)
		end
	end
	
	return exploded, explosions
end

return BombModule
