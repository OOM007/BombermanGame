local Networker = {}

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local folder = ReplicatedStorage:FindFirstChild("Events")

if not folder and RunService:IsServer() then
	local newFolder = Instance.new("Folder")
	newFolder.Parent = ReplicatedStorage
	newFolder.Name = "Events"

	folder = newFolder
else
	folder = ReplicatedStorage:WaitForChild("Events")
end

local function WaitForEvent(folder, name)
	local event
	
	while not event do
		event = folder:FindFirstChild(name)
		task.wait()
	end
	
	return event
end


local function getEvent(name)
	local event = folder:FindFirstChild(name)
	
	if RunService:IsServer() then
		if not event then
			event = Instance.new("RemoteEvent")
			event.Parent = folder
			event.Name = name
		end
	else
		event = WaitForEvent(folder, name)
	end
	
	return event :: RemoteEvent
end


function Networker.OnServer(eventName, callback)
	local event = getEvent(eventName)
	event.OnServerEvent:Connect(callback)
end

function Networker.FireClient(player, eventName, ...)
	local event = getEvent(eventName)
	event:FireClient(player, ...)
end

function Networker.FireAllClients(eventName, ...)
	local event = getEvent(eventName)
	event:FireAllClients(...)
end



function Networker.OnClient(eventName, callback)
	task.spawn(function()
		local event = getEvent(eventName)
		event.OnClientEvent:Connect(callback)
	end)
end


function Networker.FireServer(eventName, ...)
	local event = getEvent(eventName)
	event:FireServer(...)
end

return Networker
