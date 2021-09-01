local teleportService = game:GetService("TeleportService")
local runService = game:GetService("RunService")

local repStorage = game:GetService("ReplicatedStorage")
local gameRulesModule = require(repStorage:WaitForChild("GameRules"))

local vipServerPlace = 7177124134--2930907289 change back at launch

-- make a debug vip server so studio can work
local debugServerData = {}

local customServerModule = {}
local cachedVIPServers = {}

local function deepCopy(tab)
	local copy = {}
	for i, v in pairs(tab) do
		if type(v) == "table" or type(v) == "userdata" then
			copy[i] = deepCopy(v)
		else
			copy[i] = v
		end
	end
	return copy
end


local defaultGameMode = "gamemode_bnb"
local defaultMap = "Procedural Hils"

local function getDefaultRules(gameMode)
	local rulesPreset = gameRulesModule[gameMode]
	if rulesPreset then
		local copy = deepCopy(rulesPreset)
		return copy
	end
end

local function generateNewVIPSettings(ownerID)
	-- basically generate the basic data, and the server
	-- generate a new set of data from default settings
	local serverData = {}
	serverData.GameRules = {
		GameMode = defaultGameMode;
		RuleSet = getDefaultRules(defaultGameMode).Rules
	}
	
	local ownerName = game.Players:GetNameFromUserIdAsync(ownerID)
	local serverInfo = ownerName.."'s Custom Attrition Server"
	local serverDesc = "This server is a Custom Server hosted by "..ownerName..". You can make your own Custom Server by purchasing a VIP server off of Roblox, and then joining it. You will then be able to customize the server to your liking, including what map, what teams, timer, how many reinforcements, who can join, and more."
	
	serverData.OwnerID = ownerID
	serverData.ServerInfo = serverInfo
	serverData.ServerDescription = serverDesc
	serverData.ServerIcon = "rbxassetid://924320031"
	serverData.Settings = {
		Public = false;
		FriendsCanJoin = true;
		BoughtPublicHost = false; -- player has to pay to have a server appear in server browser.
	}

	-- create vip server
	if not runService:IsStudio() then
		local reservedAccessCode, reservedServerID  = teleportService:ReserveServer(vipServerPlace)
		serverData.ReservedServerAccessCode = reservedAccessCode
		serverData.ReservedServerPrivateID = reservedServerID
	else
		local studioAccessCode = "pdKJ51p2jURgENLH2df9ouX9JWdEOkhGsg_JzSQMP2qZGLKuAAAAAAA2" --"Fmpo5TPo-L3T09bIf5lze9SZgxu2q1xNsefn61J3ZDGZGLKuAAAAAA2" -- i fetched this from a live game via just calling reserved server, should work
		local studioServerID = "6725fde5-3a44-4648-b20f-c9cd240c3f6a"--"1b8399d4-abb6-4d5c-b1e7-e7eb52776431"
		
		serverData.ReservedServerAccessCode = studioAccessCode
		serverData.ReservedServerPrivateID = studioServerID
	end
	
	return serverData
end

function customServerModule:GetCustomServerData(vipDs, vipServerId, ownerID)
	--print("getting data for serverID:", vipServerId)
	print(vipDs, vipServerId, ownerID, "was sent to get data vip")
	local savedData = cachedVIPServers[vipServerId] or vipDs:GetAsync(vipServerId)
	print(savedData, cachedVIPServers)
	
	if not savedData then
		--print("this vip server id has no saved data")
		-- create new
		savedData = generateNewVIPSettings(ownerID)
		vipDs:SetAsync(vipServerId, savedData)

	end
	cachedVIPServers[vipServerId] = savedData
	


	return savedData
end

function customServerModule:SetCustomServerDataAsync(vipDs, rsDS, vipServerId, parameters)
	print("this is being updated")
	print(vipServerId, " id was sent here")
	local savedData = cachedVIPServers[vipServerId] or vipDs:GetAsync(vipServerId)
	
	if not savedData then
		savedData = generateNewVIPSettings(vipServerPlace)
	end
	
	-- set basic info
	savedData.OwnerID = parameters.OwnerID or savedData.OwnerID
	savedData.ServerInfo = parameters.ServerInfo or savedData.ServerInfo 
	savedData.ServerDescription = parameters.ServerDescription or savedData.ServerDescription 
	savedData.ServerIcon = parameters.ServerIcon or savedData.ServerIcon
	
	if parameters.Settings then
		-- this won't be sent via client
		savedData.Settings.BoughtPublicHost = parameters.Settings.BoughtPublicHost or savedData.Settings.BoughtPublicHost 
		
		-- this will though
		local didSetPublic = (parameters.Settings.Public == true)
		if didSetPublic then
			if savedData.Settings.BoughtPublicHost then
				--print("client made server public")
				savedData.Settings.Public = true
			else
				savedData.Settings.Public = false
			end
		else
			--print("client made server private")
			savedData.Settings.Public = false
		end
	end
	
	savedData.Settings.FriendsCanJoin = true -- cant really set this yet, but keep true
	
	-- set gamerules
	savedData.GameRules.GameMode = parameters.GameRules.GameMode or savedData.GameRules.GameMode
	for ruleName, val in pairs(parameters.GameRules.RuleSet) do
		savedData.GameRules.RuleSet[ruleName] = val
	end
	
	-- upload reserved server changes to datastores
	local reservedServer = savedData.ReservedServerPrivateID
	print(reservedServer)
	
	vipDs:UpdateAsync(vipServerId, function(old)
		-- set to newServerData
		return savedData
	end)
	rsDS:UpdateAsync(reservedServer, function(old)
		-- set to newServerData
		return savedData
	end)

	cachedVIPServers[vipServerId] = savedData
	return savedData
end

function customServerModule:Init()

	repStorage.Remotes.RequestFilterCheck.OnServerInvoke = function(client, str)
		if str then
			local chat = game:GetService("Chat")
			local result chat:FilterStringAsync(str, client, client)
			if result == str then
				return nil
			else 
				return result
			end
		end
	end
	
	local checkForPurchase = game.ServerScriptService.PatchVotingService.GetPurchasedServerHosting
	repStorage.Remotes.RequestCustomServerInfo.OnServerInvoke = function(client, request)
		if request == "CanHostServer" then
			local vipServerId = runService:IsStudio() and "studioDebug_2" or game.PrivateServerId
			local ownerID = runService:IsStudio() and 324616 or game.PrivateServerOwnerId
			if ownerID == client.UserId then
				local serverData = cachedVIPServers[vipServerId]
				if serverData then
					--print("user is allowed to check")
					if serverData.Settings.BoughtPublicHost or checkForPurchase:Invoke(client) then
						serverData.Settings.BoughtPublicHost = true
						--print(client.Name, "is allowed to host the server")
						return true
					else
						-- prompt purchase
						game.MarketplaceService:PromptProductPurchase(client, 541536383)
						return false
					end
				end
			end
		end
	end

end

return customServerModule
