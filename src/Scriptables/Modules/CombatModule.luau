local CombatModule = {}

function CombatModule:ApplyExplosionDamage(pos: Vector3, radius: number)
	local killedPlayers = {}
	
	local cell = Vector2.new( -- position of the blast cube in the grid of radius n
		math.floor(pos.X/radius+0.5),
		math.floor(pos.Z/radius+0.5)
	)

	for _, player in pairs(game.Players:GetPlayers()) do
		local Character = player.Character
		local Humanoid = Character:FindFirstChild("Humanoid")
		local PrimaryPart = Character.PrimaryPart

		if Humanoid and PrimaryPart then
			local playerGridPos = Vector2.new(
				math.floor(PrimaryPart.Position.X/radius+0.5),
				math.floor(PrimaryPart.Position.Z/radius+0.5)
			)
			
			if playerGridPos.X == cell.X and playerGridPos.Y == cell.Y then
				table.insert(killedPlayers, player)
				Humanoid.Health = 0
			end
		end

	end
	
	return killedPlayers
end

return CombatModule