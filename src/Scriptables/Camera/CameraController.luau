local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = game:GetService("Workspace").CurrentCamera

local CameraController = {}
CameraController.__index = CameraController

function CameraController.new(player: Player, camera: Camera)
	local self = setmetatable({}, CameraController)
	self.player = player
	self.camera = camera
	self.mode = nil
	self.effects = {}
	self.IsActive = false
	
	return self
end

function CameraController:SetMode(modeModule)
	if self.mode then
		pcall(function() self.mode:Exit() end)
	end
	
	local ok, modeOrErr = pcall(function()
		return modeModule.new(self.player)
	end)
	
	if ok and modeOrErr then
		self.mode = modeOrErr
		self.mode:Enter(self.player)
	else
		warn("[CamerraController] failed to load mode:", modeOrErr)
		self:RestoreDefaultCamera() 
	end
end

function CameraController:AddEffect(effect: Enum)
	table.insert(self.effects, effect)
end

function CameraController:Update(dt: number) 
	if not self.mode then return end
	
	local camera = self.camera
	
	local ok, camCFrame, CamSettings = pcall(function()
		return self.mode:Update(dt, self.player) 
	end)
	
	if not ok then
		warn("[CameraController] mode error, restoring default camera:", camCFrame)
		self:RestoreDefaultCamera()
		return
	end
	
	-- effects
	for _, effect in self.effects  do
		
		local ok, c, p = pcall(function()
			return effect:Apply(camCFrame, CamSettings, dt)
		end)
		
		if ok then
			camCFrame, CamSettings = c, p -- setting camCFrmae and CamSettings with values returned from error handling function
			if effect:IsFinished() then
				table.remove(self.effects, table.find(self.effects, effect))
			end
		else
			warn("[CamerraController] failed to apply effect:", c)
			table.remove(self.effects, table.find(self.effects, effect))
		end
	end
	
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = camCFrame
	camera.FieldOfView = CamSettings.FOV or camera.FieldOfView
end

function CameraController:RestoreDefaultCamera()
	RunService:UnbindFromRenderStep("CustomCamera")
	Camera.CameraType = Enum.CameraType.Custom
	self.mode = nil
	self.IsActive = false
end

function CameraController:Start()
	self.IsActive = true
	RunService:BindToRenderStep("CustomCamera", Enum.RenderPriority.Camera.Value, function(dt)
		self:Update(dt)
	end)
end

return CameraController