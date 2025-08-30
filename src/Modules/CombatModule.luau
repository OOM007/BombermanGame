local CombatModule = {}

function CombatModule:ApplyExplosionDamage(pos: Vector3, radius: number)
	for _, player in pairs(game.Players:GetPlayers()) do
		local character = player.Character
		local PrimPart = character.PrimaryPart
		local Humanoid = character:FindFirstChild("Humanoid")

		if PrimPart and Humanoid then
			if (PrimPart.Position - pos).Magnitude < radius then
				Humanoid.Health = 0
			end
		end
	end
end

return CombatModule
