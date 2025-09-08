local FollowFromAbove = {}
FollowFromAbove.__index = FollowFromAbove

local height = 50 -- settings

function FollowFromAbove.new(player)
	local self = setmetatable({}, FollowFromAbove)
	self.player = player
	
	return self
end

function FollowFromAbove:Enter() end -- needed for general interface

function FollowFromAbove:Exit() end

-- gets the camera CFrame and settings based on dt and current data
function FollowFromAbove:Update(dt: number, player: Player)
	local character = player.Character
	
	if not character  then
		return workspace.Camera.CFrame, {FOV = "70"}
	end
	
	local root = character:FindFirstChild("HumanoidRootPart")
	
	if not root  then
		return workspace.Camera.CFrame, {FOV = "70"}
	end
	
	local targetCFrame = CFrame.new(
		Vector3.new(root.Position.X, root.Position.Y + height, root.Position.Z),
		root.Position
	)
	
	return targetCFrame, {FOV = "70"}
end


return FollowFromAbove


-- Mode Explanation:
-- This mode sets the camera above the player to the set ampunt of studs and points it directly down, 
-- so it can be used inside the game round