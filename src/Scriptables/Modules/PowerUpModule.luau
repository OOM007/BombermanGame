local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PowerUpModule = {}

function PowerUpModule.Spawn(grid, pos: Vector2)
    if math.random() < 0.2 then
        local choice = math.random(1, #game.ReplicatedStorage.Models.PowerUps:GetChildren())
        local model = game.ReplicatedStorage.Models.PowerUps:GetChildren()[choice]:Clone()

        model.Position = grid:GetWorldPosition(pos)
        model.Parent = game.Workspace
    end
end

return PowerUpModule

-- not used yet