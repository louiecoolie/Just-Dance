local teleportService = game:GetService("TeleportService")
local runService = game:GetService("RunService")

local repStorage = game:GetService("ReplicatedStorage")
local gameRulesModule

local vipServerPlace = 7177124134--2930907289 change back at launch

-- make a debug vip server so studio can work
local debugServerData = {}

local customServerModule = {}
local cachedVIPServers = {}






function customServerModule:GetCustomServerData(vipDs, vipServerId, ownerID)
	--print("getting data for serverID:", vipServerId)
	--print(vipDs, vipServerId, ownerID, "was sent to get data vip")
	local savedData = cachedVIPServers[vipServerId] or vipDs:GetAsync(vipServerId)
	--print(savedData, cachedVIPServers)
	-- shouldn't need to generate new data.
	cachedVIPServers[vipServerId] = savedData
	
	return savedData
end

function customServerModule:SetCustomServerDataAsync(vipDs, rsDS, vipServerId, parameters)

		-- upload reserved server changes to datastores
		local reservedServer = parameters.ReservedServerPrivateID
		--print(reservedServer)
		
		vipDs:UpdateAsync(vipServerId, function(old)
			-- set to newServerData
			return parameters
		end)
		rsDS:UpdateAsync(reservedServer, function(old)
			-- set to newServerData
			return parameters
		end)

		local data = rsDS:GetAsync(reservedServer)
		for i, v in pairs(data) do
			print(i, v, "issues")
		end
		
		cachedVIPServers[vipServerId] = parameters
		return parameters

end

function customServerModule:Init()


end

return customServerModule
