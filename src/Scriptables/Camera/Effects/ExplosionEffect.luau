local ExplosionEffect = {}
ExplosionEffect.__index = ExplosionEffect

function ExplosionEffect.new(intensity, duration)
	local self = setmetatable({}, ExplosionEffect)
	
	self.intensity = intensity
	self.duration = duration
	self.time = 0
	
	return self
end


function ExplosionEffect:Apply(cFrame, settings, dt)
	self.time += dt
	
	if self.time >= self.duration then
		return cFrame, settings
	end
	
	local offset = Vector3.new(
		math.random() * self.intensity,
		math.random() * self.intensity,
		math.random() * self.intensity
	)
	
	return cFrame * CFrame.new(offset), settings
	
end

function ExplosionEffect:IsFinished ()
	return self.time > self.duration
end


return ExplosionEffect


-- Effect Explanation: 
-- This effect should be used to indicate player that the bomb has exploded nearby