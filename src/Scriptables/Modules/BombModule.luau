local BombModule = {}
local BombModule = {}
BombModule.__index = BombModule

type BombInfo = {
	pos: number,
	explodeAt: number,
	range: number,
	instance: Model
}

export type BombModule = {
	queue: {BombInfo},
	grid: GridModule,
	new: (grid: GridModule) -> BombModule,
	CanSpawn: (self: BombModule, position: Vector3) -> boolean,
	SpawnBomb: (self: BombModule, pos: Vector3, fuseTime: number, explosionPower: number?, player: Player?) -> Model,
	Explode: (self: BombModule, bomb: BombInfo) -> {any},
	DestroyInDirection: (self: BombModule, startPos: Vector2, dir: Vector2, range: number) -> {any},
	Update: (self: BombModule) -> (boolean, {any}),
}


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EffectControl = require(ReplicatedStorage.Scriptables.Modules.EffectControl)
local CombatModule = require(ReplicatedStorage.Scriptables.Modules.CombatModule)
local TableUtil = require(ReplicatedStorage.Scriptables.Utils.TableUtil)

local BOMB = ReplicatedStorage.Models.Bomb

local lastBombTime = {} -- for anti-spamming
local cooldown = 3


function BombModule.new(grid: GridModule) : BombModule
	local self = setmetatable ({}, BombModule)
	self.queue = {}
	self.grid = grid
	
	return self
end
 
 
function BombModule:CanSpawn(player: Player)
	local playerPos = player.Character.PrimaryPart.Position
	local fieldPos = {self.grid.origin, self.grid:GetWorldPosition(self.grid.size)}
	
	local now = tick()
	
	if lastBombTime[player] and now - lastBombTime[player] < cooldown then
		return false
	end
	
	return playerPos.X >= fieldPos[1].X-1 and playerPos.X <= fieldPos[2].X+1
		and playerPos.Z >= fieldPos[1].Z-1 and playerPos.Z <= fieldPos[2].Z+1
end


function BombModule:SpawnBomb(pos: Vector3, fuseTime:number, explosionPower:number, player: Player?) : Model
	if player then
		if not self:CanSpawn(player) then return end
		lastBombTime[player] = tick()
	end
	
	local bomb = BOMB:Clone()
	bomb.Parent = game.Workspace
	
	local bombInfo = {pos = Vector3.new(
		math.floor(pos.X/self.grid.cell + 0.5)*self.grid.cell, 2.5, math.floor(pos.Z/self.grid.cell + 0.5)*self.grid.cell),
		explodeAt = os.clock()+fuseTime,
		range = explosionPower or 1,
		instance = bomb}
	
	table.insert(self.queue, bombInfo)
	
	bomb:MoveTo(bombInfo.pos)
	
	return bomb
end


function BombModule:Explode(bomb: BombInfo) : {any}
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

function BombModule:DestroyInDirection(startPos: Vector2, dir: Vector2, range: number) : {any}
	local pos = startPos
	local coords = {}
	
	for i = 1, range do
		pos = pos + dir
		
		local state = self.grid:GetState(pos)
		
		
		if state == nil or state == 1 then
			break
		end
		
		table.insert(coords, {pos = pos, state = state})
	end
	
	return coords
	
end


function BombModule:Update(grid) : (boolean, {any})
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
