local dss = game:GetService("DataStoreService")
local ServerStorage = game:GetService("ServerStorage")
local ServerShared = ServerStorage:WaitForChild("ServerShared")
local ServerReporter = require(ServerShared:WaitForChild("Modules"):WaitForChild("SharedServerReporter"))

local vipServersDS = nil
local officialServersDS = nil
local reservedServersDS = nil
local bannedPlayersDS = nil
local version = "_Pre_Alpha_3"

local teleportService = game:GetService("TeleportService")
local repStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

local messagingService = game:GetService("MessagingService")
local serverTopic = "AttritionServerReports_6"

local remotes = repStorage:WaitForChild("Remotes")

local customServerModule = require(script:WaitForChild("CustomServers"))

-- debug
local debugMode = "VIPLobby"
local debugEnabled = false
local studioVIPId = "studioDebug_2" -- for the studio hosted debug vip server
if runService:IsStudio() then
	debugEnabled = true
	print("debug enabled", debugMode)
end

local services = nil
local matchmakingService = {}

local nonVetted = {} -- players who have just joined and their status has not been checked yet
local softBannedPlayers = {} -- list of players in this server who have been softbanned, to use with matchmaking

local stagingServers = {} -- server ids that have been reserved, but not yet reported.
local activeServers = {} -- dictionary of active servers

local matchmakingPools = { -- different catagories of places
	Normal = {
		-- not final in any way
		Classic = 7177124134;--2930907289; (replace this one on launch<<<) --2930813746; --882690287;	-- each gamemode is a separate place instance
	};
	Premium = {
		Classic = 3594798603;
	};
	Softban = {
		Classic = 3594795652;
	};
	Development = {
		Classic = 2821011476;
	}
}


local playersInMatchMaking = nil -- table of players who are currently in matchmaking

local creatingVIPServer = false
local linkedVIPServer = nil

local function isVIPServer()
	local vipDebugEnabled = (debugEnabled and debugMode == "VIPLobby")
	if vipDebugEnabled then
		return true
	end
	if not (game.PrivateServerId == "") and (game.PrivateServerOwnerId > 0) then
		return true
	end
	return false
end

local function getMatchMakingPool(party)
	-- go through party and make sure each are vetted and not softbanned
	local partyOK = true
	
	for i = 1, #party do
		local uid = tostring(party[i][2])
		if nonVetted[uid] or softBannedPlayers[uid] then
			partyOK = false
			break
		end
	end
	
	if partyOK then
		return matchmakingPools["Normal"], "Normal"
	else
		return matchmakingPools["Softban"], "Softban"
	end
end

local function getPoolFromId(placeId)
	for name, pool in pairs(matchmakingPools) do
		for typeName, id in pairs(pool) do
			if placeId == id then
				return name
			end
		end
	end
end

local function createNewServerEntry(serverDat) 

	-- create a new server entry from the data given
	local id = serverDat.ServerInfo -- should make this a GUID sent by other server

	activeServers[id] = serverDat
	
	-- create a function that checks to see if a server is timing out, if it does, don't display it
	spawn(function()
		while (activeServers[id] == serverDat) do
			wait(20)
			local timeSince = (tick()-serverDat.LastUpdate)--%3600
			--if timeSince > 3500 then
			--	timeSince = timeSince-3500
			--end
			--print("checking health of", id, ":", timeSince)
			if timeSince > 10 then
				if serverDat.Healthy == true then
					serverDat.Healthy = false
				else
					-- server hasn't been received for over 4 possible intervals, probably dead
					activeServers[id] = nil
					break
				end
			end
		end
	end)
end

local function onServerUpdateReceived(received)

	local data = received.Data
	local timeSent = received.Sent
	
	if data then
		data.LastUpdate = tick()
		data.Healthy = true
		
		-- add server to list
		local currentServerData = activeServers[data.ServerInfo]
		if not currentServerData then
			-- create new entry
			for id, accessCode in pairs(stagingServers) do	-- check to see if new server is a previous staging server
				if data.AccessCode == accessCode then
					activeServers[id] = nil
					stagingServers[id] = nil
					break
				end
			end
			createNewServerEntry(data)
		else
			if data.GameEnded then
				-- end the game
				activeServers[data.ServerInfo] = nil
		
			else
				-- update entry with new data
				for key, value in pairs(data) do
					if key == "PlayerCount" then
						currentServerData[key].Current = value.Current
						currentServerData[key].Max = value.Max
					else
						if value ~= currentServerData[key] then
							currentServerData[key] = value
						end
					end
				end
			end

		end
	end
end

local function getServersForClientWithFilter(client, filter)
	local list = {}
	
	local activeServerTable = activeServers
	for i, v in pairs(activeServerTable) do
		
	
	end



	if runService:IsStudio() then
		activeServerTable = {}
		-- can't really get server, so just create a fake list
	
		for i = 1, 25 do
			local report = {}
			local id = i
			local players = math.random(0, 50)
			
			report.ServerInfo = "Official Server ID: "..id
			report.PlayerCount = {Current = players, Max = 50}
			report.Gamemode = "Build and Battle"
			report.Map = "Procedural Hills"
			report.Timer = math.random(1, 3600)
			report.Status = true
			report.Description = "Official public server for attrition. Standard maps, gamemodes, and parameters."
			
			report.PlaceId = 2930907289
			report.Healthy = true
			report.LastUpdate = tick()
			
			activeServerTable[tostring(id)] = report
		end
	end

	if not filter then
		filter = {
			SearchDevBranch = false;
			IncludeSlowServers = true;
			IncludeSoftban = false;
			CustomFilter = true;
			FullFilter = false;
			PreferredMap = "Any";
		}
	end
	print("filter checked")
	-- check if in a squad
	-- if in squad, if any members are softbanned, only show softban servers
	local squad = services["Squads"]:GetSquadFromMember(client)
	local softbanned = false
	local partyList = nil
	if squad then
		partyList = squad.Members
	else
		partyList = {{client.Name, client.UserId}}
	end
	
	local pool, poolName = getMatchMakingPool(partyList)
	if poolName == "Softban" then
		print("softbanned")
		softbanned = true
	end
	
	for serverId, serverData in pairs(activeServerTable) do

		-- only grab healthy servers, unless client insists
		--print(serverData.Healthy)
		local includable = true
		
		local serverSettings = serverData.Settings
		--print("server settings?", serverSettings)
		local isPrivate = serverSettings and (serverSettings.Public == false) or false
		
		--if serverSettings then
			--print("is public?", serverSettings.Public)
		--end
		
		if softbanned then
			if getPoolFromId(serverData.PlaceId) ~= "Softban" then
				includable = false
			end
		else
			if getPoolFromId(serverData.PlaceId) == "Softban" then
		
				if not filter["IncludeSoftban"] then
					includable = false
				end
			end
		end
		
		local isDevBranch = getPoolFromId(serverData.PlaceId) == "Development"
		if not filter["SearchDevBranch"] then
			if isDevBranch then
				includable = false

			end
		else
			if not isDevBranch then
				includable = false
	
			end
		end
		
		if isPrivate then

			if serverSettings.FriendsCanJoin == true then
				local owner = serverData.OwnerID
		
				if owner then
					-- i don't want to have any async here, it would make the fetch even slower
					--if not client:IsFriendsWith(owner) then this 
						includable = false
					--end
				end
			else
				includable = false
			end
		end
		
		if includable and (serverData.Healthy or filter["IncludeSlowServers"]) then
			-- determine if meets filter
			
			-- turn this into a tree later for O(log(n)) searches
			
			local preferredMap = filter["PreferredMap"]
			local preferredMode = filter["PreferredMode"]
			local mapOk = preferredMap and (serverData.Map == preferredMap) or (preferredMap == "Any")-- or true
			local modeOk = preferredMode and (serverData.Gamemode == preferredMode) or (preferredMode == "Any")
			
			local includeFullServers = filter["FullFilter"]
			local includeEmptyServers = filter["EmptyFilter"]

			local playersOk

			if not filter["Population"] then -- search for client prop, if not use default behavior for playerOk
				local tooManyPlayers = (not includeFullServers) and (serverData.PlayerCount.Current >= serverData.PlayerCount.Max) or false
				local tooFewPlayers = (not includeEmptyServers) and (serverData.PlayerCount.Current <= 0) or false
				playersOk = not (tooFewPlayers or tooManyPlayers)
			else -- client passed population prop, search as desired.
				local justRightPlayers  --could be one long ternary statement but I want readability lol
				if ((filter["Population"] == "Small")  and (serverData.PlayerCount.Current >= 0) and (serverData.PlayerCount.Current <= 10)) then
					justRightPlayers = true
				elseif (filter["Population"] == "Medium")  and (serverData.PlayerCount.Current >= 10) then
					justRightPlayers = true
				elseif (filter["Population"] == "Large")  and (serverData.PlayerCount.Current >= 25) then
					justRightPlayers = true
				else
					justRightPlayers = false
				end

				playersOk = justRightPlayers
			end
		
			
			-- custom servers are VIP servers that can be made public to everyone
			--local serverTypeOk = (not filter["CustomFilter"]) and serverData.Type ~= "CustomServer" or true
			local serverTypeOk
			if filter["CustomFilter"] == "Custom" then
				serverTypeOk = (serverData.Type == "CustomServer")
			elseif filter["CustomFilter"] == "Official" then
				serverTypeOk = (serverData.Type == "OfficialServer")
			elseif filter["CustomFilter"] == "Any" then
				serverTypeOk = true
			end
			

		
			if mapOk and playersOk and serverTypeOk and modeOk then
				table.insert(list, serverData)
			end
		end
	end
	
	return list
end

local function teleportGroupToServer(client, squad, selectedGame, serverData, serverID)	
	local members = nil
	if squad then
		members = {}
		for i = 1, #squad.Members do
			table.insert(members, game.Players:GetPlayerByUserId(squad.Members[i][2]))
		end
	else
		members = {client}
	end
	
	local teleportData = {SquadId = squad and squad.GUID}
	
	if not serverData then -- send to a random server
		-- everything is set up, now alert each member that they are being teleported
		for i = 1, #members do
			playersInMatchMaking[members[i]] = true
			remotes.RequestMatchmaking:FireClient(members[i], "JoiningServer")
		end
		
		if squad then
			services["Squads"]:SaveSquad(squad) -- save squad before sending it over
		end
		
		local jobID = nil
		local passed, erReason = pcall(function()
			jobID = teleportService:TeleportPartyAsync(selectedGame, members, teleportData, nil)
		end)
		
		if not passed then
			print("Teleport failed:", erReason)
		end
		
		for i = 1, #members do
			if not passed then
				-- alert each member that the teleport failed
				remotes.RequestMatchmaking:FireClient(members[i], "TeleportFailed")
			end
			playersInMatchMaking[members[i]] = nil -- allows them to try again
		end
	else
		-- send to a specific server
		if serverData.PlayerCount.Current + #members <= serverData.PlayerCount.Max then
			-- able to send everyone
			for i = 1, #members do
				playersInMatchMaking[members[i]] = true
				remotes.RequestMatchmaking:FireClient(members[i], "JoiningServer")
			end
		
			if squad then
				services["Squads"]:SaveSquad(squad) -- save squad before sending it over
			end
			
			for i = 1, #members do
				spawn(function()
					local passed, erReason = pcall(function()
						teleportService:TeleportToPlaceInstance(selectedGame, serverID, members[i], "", teleportData, nil)
					end)
					if not passed then
						-- alert each member that the teleport failed
						remotes.RequestMatchmaking:FireClient(members[i], "TeleportFailed")
					end
					playersInMatchMaking[members[i]] = nil -- allows them to try again
				end)
			end
		else
			-- alert that server's full
			remotes.RequestMatchmaking:FireClient(client, "ServerFull")
		end
	end
end

local function teleportGroupToVIPServer(client, squad, selectedGame, accessCode)
	local members = nil

	if squad then
		members = {}
		for i = 1, #squad.Members do

			table.insert(members, game.Players:GetPlayerByUserId(squad.Members[i][2]))
		end
	else
		members = {client}
	end
	
	local teleportData = {SquadId = squad and squad.GUID}
	for i = 1, #members do
		playersInMatchMaking[members[i]] = true
		remotes.RequestMatchmaking:FireClient(members[i], "JoiningVIPServer")
	end
	
	if squad then
		services["Squads"]:SaveSquad(squad) -- save squad before sending it over
	end
	
	local jobID = nil
	local passed, erReason = pcall(function()
		 jobID = teleportService:TeleportToPrivateServer(selectedGame, accessCode, members, "", teleportData, nil)
	end)
	
	if not passed then
		print("Teleport failed:", erReason)
	end
	
	for i = 1, #members do
		if not passed then
			-- alert each member that the teleport failed
			remotes.RequestMatchmaking:FireClient(members[i], "TeleportFailed")
		end
		playersInMatchMaking[members[i]] = nil -- allows them to try again
	end
end

local function sendToCustomServer(client, squad, placeID)
	-- fetch our vip server id, then try to get the reserved server, if reserved server doesn't exist, then create one
	if vipServersDS and isVIPServer() then
		if creatingVIPServer then
			repeat
				wait(1)
			until not creatingVIPServer
		end
		
		local vipServerId = game.PrivateServerId
		
		if not linkedVIPServer then
			local data
			if debugEnabled and debugMode == "VIPLobby" then
				data = vipServersDS:GetAsync(studioVIPId)

			else
				data = vipServersDS:GetAsync(vipServerId)
			end
			linkedVIPServer = data and data.ReservedServerAccessCode
			if data then
				print("VIP Server exists", linkedVIPServer)
			end
		end
		
		local linkedReservedServer = linkedVIPServer
		if not linkedReservedServer then
			-- create one
			local ownerID = game.PrivateServerOwnerId
			local ownerName = game.Players:GetNameFromUserIdAsync(ownerID)
			
			creatingVIPServer = true
			local newServerData = customServerModule:GetCustomServerData(vipServerId)
			
			-- reserve server
			local reservedAccessCode, reservedServerID  = teleportService:ReserveServer(placeID)
			newServerData.ReservedServerAccessCode = reservedAccessCode
			newServerData.ReservedServerPrivateID = reservedServerID
			
			linkedVIPServer = reservedAccessCode
			linkedReservedServer = reservedAccessCode
			
			print("VIP Server didn't exist, created new", linkedVIPServer)
			
			spawn(function()
				vipServersDS:UpdateAsync(vipServerId, function(old)
					-- set to newServerData
					return newServerData
				end)
				reservedServersDS:UpdateAsync(reservedServerID, function(old)
					-- set to newServerData
					return newServerData
				end)
			end)
		end
		
		if linkedReservedServer then
			-- join it
			teleportGroupToVIPServer(client, squad, placeID, linkedReservedServer)
		end
	end
end

local function createNewOfficialServer(placeID)
	-- reserve server
	local reservedAccessCode, reservedServerID  = teleportService:ReserveServer(placeID)
	
	-- add to server pool so we dont end up making 50 servers at once
	local stagingReport = {
		ServerInfo = "(Just Starting) Official Server: "..reservedServerID;
		PlaceId = placeID;
		JobId = nil;
		PlayerCount = {Current = 0, Max = 50};
		Gamemode = "Intermission";
		Map = "Intermission";
		Timer = 0;
		Status = false;
		GameEnded = false;
		Description = "Official public server for attrition. Standard maps, gamemodes, and parameters.";
		AccessCode = reservedAccessCode;
		LastUpdate = tick();
		Healthy = true;
	}

	createNewServerEntry(stagingReport)
	stagingServers[stagingReport.ServerInfo] = reservedAccessCode

	-- upload ID to datastore
	spawn(function()
		officialServersDS:UpdateAsync(reservedServerID, function(old)
			-- set to newServerData
			return {ReservedServerAccessCode = reservedAccessCode}
		end)
	end)
	
	return reservedAccessCode
end

local function initiateJoin(client, squad, selectedGame, possibleServers)
	print("found possible servers")
	local serverData = possibleServers[math.random(1, #possibleServers)]
	print("server type", serverData.Type)
	local accessCode = serverData.AccessCode
	if accessCode then
		-- increment player count by group size
		serverData.PlayerCount["Current"] += (squad and #squad or 1)

		print("Teleporting to new official server, or custom server")
		wait(1)
		print("access code acquired, teleport")
		teleportGroupToVIPServer(client, squad, selectedGame, accessCode)
	else
		if serverData.Type == "OfficialServer" then -- old server to be phased out
			
			local serverID = serverData.JobId
			if serverID then
				-- server exists, check to see if we can send player there.
				print("Teleporting to old server")
				wait(1)
				teleportGroupToServer(client, squad, selectedGame, serverData, serverID)
			else
				remotes.RequestMatchmaking:FireClient(client, "ServerInactive")
			end
		else
			remotes.RequestMatchmaking:FireClient(client, "LockedServer")
		end
	end
end

local function quickMatch(client, squad, selectedGame, filter, count)

	
	if getPoolFromId(selectedGame) == "Development" then
		filter["SearchDevBranch"] = true
	end
	
	local possibleServers = getServersForClientWithFilter(client, filter)
	if #possibleServers > 0 and count <= 5 then --check count to make sure we aren't performing extra scans
		initiateJoin(client, squad, selectedGame, possibleServers)
	else
		if count < 7 then
			print("no server found with filter, retry")
			filter["Population"] = "Large" -- just do a population check starting from large
			local serverScan0 = getServersForClientWithFilter(client, filter)
			if #serverScan0 > 0 then -- found large population hit
				initiateJoin(client, squad, selectedGame, serverScan0)
			else --search down to medium
				filter["Population"] = "Medium"
				local serverScan1 = getServersForClientWithFilter(client, filter)
				if #serverScan1 > 0 then -- found medium size hit 
					initiateJoin(client, squad, selectedGame, serverScan1)
				else -- reduce to small
					filter["Population"] = "Small"
					local serverScan2 = getServersForClientWithFilter(client, filter)
					if #serverScan2 > 0 then -- found small hitSection
						initiateJoin(client, squad, selectedGame, serverScan2)
					else
						remotes.RequestMatchmaking:FireClient(client, "Retry", count) -- retry the large-small sort
					end
				end
			end
			
		elseif count == 7 then
			print("exhausted retrys, perform default search")
			if filter["CustomFilter"] == "Custom" then
				remotes.RequestMatchmaking:FireClient(client, "Reconfigure");
			else
				remotes.RequestMatchmaking:FireClient(client, "Default");
				local findServersWithDefault = getServersForClientWithFilter(client)
				if #findServersWithDefault > 0 then
					initiateJoin(client, squad, selectedGame, findServersWithDefault)
				else
					print("exhausted default, create new offiicial")
					remotes.RequestMatchmaking:FireClient(client, "New");
					print("Start a brand new official server")
					-- start a new server
					---- teleportGroupToServer(client, squad, selectedGame)
					local serverAccessCode = createNewOfficialServer(selectedGame)
					teleportGroupToVIPServer(client, squad, selectedGame, serverAccessCode)
				end
			end

		end

	end
end

function matchmakingService:GetReservedServerFromJobId(jobId)
	for i, v in pairs(activeServers) do
		--print("Equal?: ", v.JobId, jobId, v.JobId == jobId)
		if v.JobId == jobId and v.AccessCode then
			return v
		end
	end
	return nil
end

function matchmakingService:Init(m)
	services = m
	
	customServerModule:Init()
	
	playersInMatchMaking = {}
	
	-- if we are in a vip server, we don't have a server browser, and thus don't need to do this.
	if not (isVIPServer() or runService:IsStudio()) then
		local serverSubscription = nil
		local passed, errorMsg = pcall(function()
			officialServersDS = dss:GetDataStore("Attrition_Official_Servers"..version)
			--for i = 0, 3 do
				--messagingService:SubscribeAsync(serverTopic.."_"..i, onServerUpdateReceived)
			--end
			ServerReporter:SubscribeSafe(onServerUpdateReceived)
	
		end)
		if not passed then
			print(errorMsg)
		end
	elseif isVIPServer() then
		local passed, errorReason = pcall(function()
			vipServersDS = dss:GetDataStore("Attrition_VIP_Servers"..version)
			reservedServersDS = dss:GetDataStore("Attrition_Custom_Servers"..version)
		end)
	end
	
	local passed, errorReason = pcall(function()
		bannedPlayersDS = dss:GetDataStore("Bans")
	end)
	
	game.Players.PlayerAdded:Connect(function(plr)
		
		local uid = tostring(plr.UserId)
		
		--[[if uid == "324616" then
			print("ban garnold")
			softBannedPlayers[uid] = true
			return
		end]]
		
		-- get account age (if less than a week or so put in softban category)
		if plr.AccountAge < 10 then -- eventually include less than a certain amount of attrition gameplay time
			softBannedPlayers[uid] = true
			return
		end
		
		-- mark as non-vetted
		nonVetted[uid] = true
		
		-- get ban status
		if bannedPlayersDS then
			local isBanned = bannedPlayersDS:GetAsync(uid)
			if isBanned then
				if os.time() < isBanned.BanTimestamp+isBanned.BanDuration then
					softBannedPlayers[uid] = true
					nonVetted[uid] = nil
					return
				end
			end
		end
		
		nonVetted[uid] = nil
	end)
	
	remotes.GetServerList.OnServerInvoke = function(client, filter)
		if filter then
			print(filter, " was acquired")
			-- do checks to make sure client is a good boy
			-- go through servers and return info to client
			return getServersForClientWithFilter(client, filter)
		end
	end
	
	remotes.RequestMatchmaking.OnServerEvent:connect(function(client, request, data, filter, count)
		-- client sent a matchmaking request
		
		--if not services["Squads"].MatchMakingReady then -- seems to consider a variable set only by 1 client
			-- server isn't ready yet, don't do anything
			--remotes.RequestMatchmaking:FireClient(client, "NotReady")
			--return
		--end
			
		-- check if in a squad
		-- if in squad, only allow leader to do matchmaking
		local squad = services["Squads"]:GetSquadFromMember(client)
	
		if squad then
			if squad.LeaderId ~= client.UserId then
				remotes.RequestMatchmaking:FireClient(client, "NotLeader")
				return
			end
			--squad.Matchmaking = true
		end
		
		local partyList = squad and squad.Members or {{client.Name, client.UserId}}
		-- do a check to make sure party's been vetted
		for i = 1, #partyList do
			local uid = tostring(partyList[i][2])
			if nonVetted[uid] then
				remotes.RequestMatchmaking:FireClient(client, "NonVetted")
				return
			end
		end
		
		if isVIPServer() then
			-- send to vip server
			local pool = getMatchMakingPool(partyList)-- if in a squad, all members join the pool of the leader (might want to send a squad to a softban though if one member is banned)
			local selectedGame = pool["Classic"]
			
			-- make sure custom server data exists, if not, if this is the owner, prompt them to set up the server, otherwise, tell them
			-- that they have to wait for owner to set it up (maybe just have a default server, idk)
			local savedVIPServer
			if debugEnabled and debugMode == "VIPLobby" then
				savedVIPServer = customServerModule:GetCustomServerData(vipServersDS, (studioVIPId))
			else
				savedVIPServer = customServerModule:GetCustomServerData(vipServersDS, (game.PrivateServerId or studioVIPId))
			end
			if not savedVIPServer then
				if client.UserId == game.PrivateServerOwnerId then
					print("vip server settings do not exist, prompt owner to create new")
					-- fire a remote event that triggers server creation
					--remotes.PromptVIPSettings:FireClient(client, savedVIPServer)
				end
				return false
			end
				
			sendToCustomServer(client, squad, selectedGame)
			return
		end
		
		if request == "QuickMatch" then -- ignore filters and just teleport them to the game
			if not playersInMatchMaking[client] then
				local pool = getMatchMakingPool(partyList) -- if in a squad, all members join the pool of the leader (might want to send a squad to a softban though if one member is banned)
				local selectedGame = pool["Classic"]
				quickMatch(client, squad, selectedGame, filter, count)
			end
		elseif request == "DevBranch" then
			if not playersInMatchMaking[client] then
				local pool = getMatchMakingPool(partyList)
				if pool == matchmakingPools["Normal"] then
					pool = matchmakingPools["Development"]
				end
				local selectedGame = pool["Classic"]
				
				quickMatch(client, squad, selectedGame, filter, count)
			end
		elseif request == "JoinServer" then
			print("received join request")
			local serverData = activeServers[data.ServerID]
			if serverData then
				print("we got data bois")
				local pool = getMatchMakingPool(partyList)
				local selectedGame = pool["Classic"]
				
				local accessCode = serverData.AccessCode
				print(accessCode, "we got code")
				if accessCode then
					print("Teleporting to new official server, or custom server")
					wait(1)
					teleportGroupToVIPServer(client, squad, selectedGame, accessCode)
				else
					if serverData.Type == "OfficialServer" then -- old server to be phased out
						
						local serverID = serverData.JobId
						if serverID then
							-- server exists, check to see if we can send player there.
							print("Teleporting to old server")
							wait(1)
							teleportGroupToServer(client, squad, selectedGame, serverData, serverID)
						else
							remotes.RequestMatchmaking:FireClient(client, "ServerInactive")
						end
					else
						remotes.RequestMatchmaking:FireClient(client, "LockedServer")
					end
				end
			else
				remotes.RequestMatchmaking:FireClient(client, "ServerInactive")
			end
		end
	end)
		
	remotes.RequestVIPSettings.OnServerInvoke = function(client, request, params)
		local isdebug = (debugEnabled and debugMode == "VIPLobby")
		if isVIPServer() or isdebug then
			-- check to see if this is the owner
			if client.UserId == game.PrivateServerOwnerId or isdebug then 
				local vipServerId = isdebug and studioVIPId or game.PrivateServerId
				if request == "GetServerSettings" then
					print("owner requested vip settings")
					-- get vip server settings and return to 
					print(vipServersDS, vipServerId, client.UserId, "server vip data")
					local savedVIPServer = customServerModule:GetCustomServerData(vipServersDS, vipServerId, client.UserId)
	
					return true, savedVIPServer
				elseif request == "SettingsUpdate" then
					local updateData = params
					-- call update function
					-- check to make sure what client sent is ok
					--print("owner requested change to settings")
					if params then
						--print("valid parameters")
						
						customServerModule:SetCustomServerDataAsync(vipServersDS, reservedServersDS, vipServerId, updateData)
						return true
					end
				end
			else
				local vipServerId = isdebug and studioVIPId or game.PrivateServerId
				local data = vipServersDS:GetAsync(vipServerId)
				return false, data
			end
		end
		return false
	end
end

return matchmakingService
