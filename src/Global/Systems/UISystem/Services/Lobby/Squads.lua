local runService = game:GetService("RunService")
local players = game:GetService("Players")

local dss = game:GetService("DataStoreService")
local playerSquadsDS = nil -- datastore that holds all players' squad status
local activeSquadsDS = nil -- datastore that holds all existing squads' data
local squadInvitesDS = nil -- datastore that holds squad invitation requests

local httpService = game:GetService("HttpService")
local teleportService = game:GetService("TeleportService")

local repStorage = game:GetService("ReplicatedStorage")
local remotes = repStorage:WaitForChild("Remotes")


local squadService = {}
squadService.MatchMakingReady = false
squadService.IsSquadLobby = false
squadService.InitializingSquadLobby = false
squadService.InitializedSquadLobby = false
squadService.LobbySquadID = nil -- if a squad lobby server, the SquadID of the main squad
squadService.LobbySquadInviteUpdater = nil -- on ds update, check invites to see if anyone declines invitations

local services = nil

local mainLobbyPlaceId = 882690287 -- upon leaving squad, teleport back to main hub
local squadLobbyPlaceId = 2930923417 -- a squad will be teleported to a reserved server created from this place

local attritionPlaces = {
	["882690287"] = true;
	["2821011476"] = true;
	["2930907289"] = true;
	["2930922068"] = true;
	["2930923417"] = true;
	["7175796352"] = true;
}

local lobbyMap = {
--	["Squad Lobby"] = 2930923417;
	--["Main Menu"] = 882690287;
	--["Main Menu DEBUG"] = 2930922068;
	--["Game Debug"] = 2821011476;
	["2821011476"] = true;
	["882690287"] = true;
	["7175796352"] = true;
}

local squads = {}

local inSquadCreation = {} -- dictionary of players currently creating squads

local playerInviteEvents = {}

local function debugLogClient(client, msg)
	remotes.LogClient:FireClient(client, msg)
end

local function displayDebugSquad(squadData)
	print("DISPLAYING CURRENT SQUAD DATA:")
	print("	ID:", squadData.GUID)
	print("	Leader:", squadData.Leader)
	print("	Size:", squadData.Size)
	print("	Invite:")
	for i, v in pairs(squadData.Invited) do
		print("		", i, v)
	end
	print("	Members:")
	for i, v in pairs(squadData.Members) do
		print("		", v[1], v[2])
	end
end

local function isPlayerContributor(client)
	local contribStatus = game.ServerScriptService.PatchVotingService.GetContributorStatus:Invoke(client)
	for i, v in pairs(contribStatus) do
		if v > 0 then
			return true
		end
	end
	return false
end			

local function datastoreOnUpdate(ds, key, callback) -- since the other one doesn't seem to work, lets just pool it manually
	local polling = true
	local connection = {}
	function connection:Disconnect()
		polling = false
		connection = nil
	end
	spawn(function()
		local previous = nil
		while polling do
			wait(5)
			local data = ds:GetAsync(key)
			if data then
				local tojson = httpService:JSONEncode(data) 
				if previous ~= tojson then
					previous = tojson
					callback(data)
				end
			end
		end
	end)
	
	return connection
end

local function getSquadFromMember(mem)

	for guid, squad in pairs(squads) do

		for i = 1, #squad.Members do
	
			if squad.Members[i][2] == mem.UserId then
			
				return squad
			end
		end
	end
	return nil
	--local userLocationData = playerSquadsDS:GetAsync(mem.UserId)
	
	--local squadID = userLocationData.SquadId

	--local squadData = nil


	--squadData = activeSquadsDS:GetAsync(squadID)
	--return squadData
end

local function updatePlayerLocationDataAsync(player, squad)
	-- update the player's user squads entry so friends can find them
	local userID = tostring(player.UserId)
	if squad then

		local friendsCanJoin = (squad.LeaderId == player.UserId and (squad.AllowFriendJoins) or (squad.AllowMemberInvites and squad.AllowFriendJoins))
		local newEntry = {SquadId = squad.GUID, FriendsJoinEnabled = friendsCanJoin}
		playerSquadsDS:SetAsync(userID, newEntry)

	
	else
		playerSquadsDS:RemoveAsync(userID)
	end
end

local function addMemberToSquad(squad, player)

	if getSquadFromMember(player) then
		return true -- already in squad
	end
	
	-- determine if player should be in squad
	local allowed = false
	if squad.Size == 0 then
		-- first member, allow
		allowed = true
	else
		-- determine if invited, if so then allow
		if squad.Invited[tostring(player.UserId)] then
			squad.Invited[tostring(player.UserId)] = nil
			allowed = true
		else
			-- determine if friend
			if squad.AllowFriendJoins then
				if squad.AllowMemberInvites then
					-- check all members
					for i = 1, #squad.Members do
						if player:IsFriendsWith(squad.Members[i][2]) then
							allowed = true
							break
						end
					end
				else
					-- only check leader
					if player:IsFriendsWith(squad.LeaderId) then
						allowed = true
					end
				end
			end
		end
	end
		
	if not allowed then
		return false
	end

	if squad.Size < 5 then
		squad.Size = squad.Size+1
		table.insert(squad.Members, {player.Name, player.UserId})

		for i = 1, #squad.Members do
			local plr = players:GetPlayerByUserId(squad.Members[i][2])
			print("firing from inside squad")
			remotes.RequestSquadInvite:FireClient(plr, squad)
		end
		spawn(function()
			updatePlayerLocationDataAsync(player, squad)
		end)
		return true
	else
		return false -- squad is full, cannot add more players
	end
end

local function createNewSquad(leader, data)
	local squad = {}
	local guid = httpService:GenerateGUID(false)
	squads[guid] = squad -- do this first because possible yield when getting reserved server, and if tags allowed
	
	squad.GUID = guid
	squad.SquadId = guid
	squad.Leader = leader.Name
	squad.LeaderId = leader.UserId
	squad.Members = {} -- list of {name, userId}
	squad.Invited = {} -- dictionary of invited userIds
	squad.Size = 0 -- take into account inviteds
	squad.AllowMemberInvites = data.AllowMemberInvites
	squad.AllowFriendJoins = data.AllowFriendJoins
	squad.Tag = (isPlayerContributor(leader)) and data.SquadTag
	
	
	squad.LastUpdateType = "External" -- External or Internal, If internal, it came from the squad's lobby server, if that's the case, ignore OnUpdate requests
	
	local success = addMemberToSquad(squad, leader)
	if not success then
		print("couldn't add leader to squad for some reason")
		return nil
	end
	

--	local reservedServerID, reservedServerPrivateID = nil
	--	local passed, errorReason = pcall(function()
	--	reservedServerID, reservedServerPrivateID = teleportService:ReserveServer(game.PlaceId)
	--end)
	--if passed then
		--squad.ReservedLobby = {ReservedID = reservedServerID, PrivateServerID = reservedServerPrivateID}
		remotes.RequestSquadInvite:FireClient(leader, squads[guid]) --send squad information to leader
	--else
		--print("reserve server failed:", errorReason)
	--	return nil
--	end

	
	return squad
end

local function leaveSquad(squad, mem)
	-- make player leave squad, and teleport back to main lobby
	if squad then
	
		remotes.RequestSquadInvite:FireClient(mem, nil)
		local index = 0
		for i = 1, #squad.Members do
			if squad.Members[i][2] == mem.UserId then
				index = i
				break
			end
		end
		if index > 0 then
			table.remove(squad.Members, index)
			squad.Size = squad.Size - 1
			
			spawn(function()
				updatePlayerLocationDataAsync(mem, nil) -- update rich presence to not be in a squad
			end)
			
			if #squad.Members > 0 then
				if mem.UserId == squad.LeaderId then
					squad.Leader = squad.Members[1][1]
					squad.LeaderId = squad.Members[1][2] --if leader has left designate new leader
				end

				for i=1, #squad.Members do -- update everyone else in squad
					
					local plr = game.Players:GetPlayerByUserId(squad.Members[i][2])
				
					remotes.RequestSquadInvite:FireClient(plr, squad)
				end
	
			else
				-- squad disbanded, remove from list, and Active Squads datastore
				squads[squad.GUID] = nil
				spawn(function()
					activeSquadsDS:RemoveAsync(squad.GUID)
				end)
			end
			
		
			
		end
	end
end

local function teleportGroupToReservedServer(placeId, accessCode, group, tpData)
	local passed, errorReason = false, nil
	local sentServerJobID = nil
	
	while not passed do
		passed, errorReason = pcall(function()
			sentServerJobID = teleportService:TeleportToPrivateServer(placeId, accessCode, group, nil, tpData, nil)
		end)
		
		if not passed then
			print("Teleport Error:", errorReason)
			-- try again in 5 seconds
			wait(5)
		end
	end
end

local function sendToSquadLobby(squad)
	-- send created squad to a squad lobby
	wait(5)
	
	-- save squad to activesquads datastore
	activeSquadsDS:SetAsync(squad.GUID, squad)
	
	-- when done, teleport
	local group = {}
	for i = 1, #squad.Members do
		local player = game.Players:GetPlayerByUserId(squad.Members[i][2])
		table.insert(group, player)
	end
	
	-- teleport
	teleportGroupToReservedServer(squadLobbyPlaceId, squad.ReservedLobby["ReservedID"], group, {SquadID = squad.GUID, LeaderID = squad.LeaderId})
	
	-- remove squad from list
	squads[squad.GUID] = nil
end

local function promptPlayerWithInvite(player, inviteData)
	print("sending invite")
	-- fire client with information related to invite, and wait for accept/decline
	-- first check to see if squad is still active
	print("invite is sent")
	print(inviteData)
	for k, v in pairs(inviteData) do
		print(k,v)
	end
	local squadData = activeSquadsDS:GetAsync(inviteData.SquadId)
	if squadData then
		local inviter = inviteData.Inviter
		local stillActive = false
		for i = 1, #squadData.Members do
			if squadData.Members[i][1] == inviter then
				stillActive = true
				break
			end
		end
		
		if stillActive then
			-- alert client with invite
			print("sending to client")
			local accepted = remotes.PromptSquadInvite:InvokeClient(player, inviteData)
				
			if accepted then
				print("invite accepted")
				local group = {player}
				local tpData = {SquadID = squadData.GUID, LeaderID = squadData.LeaderId}
				
				spawn(function()
					-- update rich presence
					addMemberToSquad(squads[squadData.SquadId], player)
					updatePlayerLocationDataAsync(player, squadData)

					local squad = squads[squadData.SquadId]

				
					
				end)
				
				--teleportGroupToReservedServer(squadLobbyPlaceId, squadData.ReservedLobby["ReservedID"], group, tpData)
			else
				print("invite declined")
				-- remove invite from squad invites, and update datastore
				-- setting to false rather than nil implies this value exists, but was declined, and allows for squad lobby to handle it.
				activeSquadsDS:UpdateAsync(squadData.GUID, function(old)
					old.Invited[tostring(player.UserId)] = false
					return old
				end)
			end
			
		end
	end
end

local function invitePlayerToSquad(userID, squad, inviter)
	if squad.Size < 5 then
		squad.Invited[tostring(userID)] = true
		
		-- determine how to invite
		local invited = game.Players:GetPlayerByUserId(userID)
		local inviteData = {SquadId = squad.GUID, Inviter = inviter}
		if invited then
			-- invite by directly prompting them
			spawn(function()
				promptPlayerWithInvite(invited, inviteData)
			end)
		else
			-- invite by sending invitation upon joining the game, or over datastore (and they receive OnUpdate)
			squadInvitesDS:UpdateAsync(tostring(userID), function(old)
				return inviteData
			end)
		end
	end
end

local function sanitizeTagText(plr, text)
	-- make into a valid clantag
	local numbers = {["1"]=true,["2"]=true,["3"]=true,["4"]=true,["5"]=true,["6"]=true,["7"]=true,["8"]=true,["9"]=true,["0"]=true} -- to filter out non alphanumerical chars, do a string upper then lower comparison, and ignore these numbers

	-- first check for non-alphanumeric chars
	local formattedString = text
	local index = 1
	local length = string.len(text)
	while index < length do
		-- check if uppertext[1] == lowertext[1]
		-- if so then check if it's a number
		-- if not then don't increment index, and remove that char from the string
		
		local upperText = string.upper(text)
		local lowerText = string.lower(upperText)
		
		local upperi = string.sub(upperText, index, index)
		local loweri = string.sub(lowerText, index, index)
		local increment = true
		if upperi == loweri then
			if not numbers[upperi] then
				increment = false
				length = length-1
				if index == 1 then
					-- ignore pretext, just go after
					if index == length then
						-- they just sent a string of bad chars, return false
						return nil
					end
					text = string.sub(text, 2)
				elseif index == length then
					-- ignore posttext, just go up to index
					text = string.sub(text, 1, index-1)
				else
					-- somewhere in the middle
					local preText, postText = string.sub(text, 1, index-1), string.sub(text, index+1)
					text = preText..postText
				end
			end
		end
		
		if increment then
			index = index+1
		end
	end
		
	if string.len(text) > 5 then
		text = string.sub(text, 1, 5)
	end
	
	text = string.upper(text)
	
	-- now check chat filter
	local filtered = game:GetService("Chat"):FilterStringForBroadcast(text, plr)
	if string.find(filtered, "#") then
		return nil
	end
	
	return filtered
end

function squadService:SaveSquad(squad)
	squad.LastUpdateType = "Internal"
	activeSquadsDS:UpdateAsync(squad.GUID, function(old)
		return squad
	end)
end

function squadService:InviteFriendToSquad(player, friendID) -- pass both name and id, so we don't have to do more lookups
	if player and friendID then
		local squad = getSquadFromMember(player)
		displayDebugSquad(squad)
		if squad and squad.Size < 4 then
			local inviteAllowed = (squad.LeaderId == player.UserId) or (squad.AllowMemberInvites == true)
			if player:IsFriendsWith(friendID) and inviteAllowed then
				-- first check if player isn't already in the squad, or already invited
				print("friend verified")
				if not squad.Invited[tostring(friendID)] then
					print("friend not invited")
					local friendPlayer = game.Players:GetPlayerByUserId(friendID)
					if friendPlayer then
						-- already in server
						print("got player id")
						local friendSquad = getSquadFromMember(friendPlayer)

						if friendSquad then
							displayDebugSquad(friendSquad)
						end

						print(friendSquad, squad)
						if friendSquad ~= squad then
							print("friend is not in a squad")
							-- allow invite

							invitePlayerToSquad(friendID, squad, player.Name)
						end
					else
						-- allow invite
						-- will check if they're playing attrition before checking if they're online or not
						-- if on roblox website, send an invite via social service
						invitePlayerToSquad(friendID, squad, player.Name)
					end
				end
			end
		end
	end
end

function squadService:GetFriendsOnline(player, friendsList, filter)
	-- get a list of players friends, show their online status as "In Attrition", "Website"
	local rawFriendsData = friendsList
	local sendFriendsList = {}
	for i = 1, #rawFriendsData do
		local friend = rawFriendsData[i]
		local squadId
		local location = friend.LastLocation == "Website" and "Roblox Website" or (attritionPlaces[tostring(friend.PlaceId)] and "Attrition: In-game" or "Playing Another Game")
		if location == "Attrition: In-game" then
			-- specify if in a private/public squad, or if ingame
			-- grab rich presence
			local place = friend.PlaceId
		--	if place == lobbyMap["Squad Lobby"] then
				-- determine if public or private to player
				local richPresence = playerSquadsDS:GetAsync(tostring(friend.VisitorId))
				if richPresence then
					if richPresence.FriendsJoinEnabled then
						location = "Attrition: In Open Squad"
						squadId = richPresence.SquadId
					else
						location = "Attrition: In Private Squad"
					end
				else
			--elseif place == lobbyMap["Main Menu"] or place == lobbyMap["Main Menu DEBUG"] then
					if lobbyMap[tostring(friend.PlaceId)] then
						location = "Attrition: In Main Menu"
					else
						location = "Attrition: In-game"
					end
				end
			--end
		end
		
		local data = {
			Name = friend.UserName;
			UserId = friend.VisitorId;
			Location = location;
			SquadId = squadId
		}
		
		--if not filter[location] then
			sendFriendsList[#sendFriendsList+1] = data
		--end
	end
	
	return sendFriendsList
end

function squadService:GetSquadFromMember(client)
	return getSquadFromMember(client)
end

function squadService:CreateSquadFromData(data)
	-- This is a squad lobby server, and dat is the incoming data from a central lobby
	if data.GUID and data.Leader then
		squads[data.GUID] = data
	end
end

function squadService:PlayerRequestedCreateSquad(client, creationData)
	-- player in this server started squad creation
	if not getSquadFromMember(client) then
		-- allow squad
		local squad = createNewSquad(client, creationData)
		if squad then
			activeSquadsDS:SetAsync(squad.GUID, squad)
			--sendToSquadLobby(squad)
			return true
		end
	end
	return false
end

function squadService:InitializeSquadLobby(member) -- This Lobby is a squad lobby server, get squad ID from user's "rich presence"
	-- initialize self so that we are connected to the squad
	self.InitializingSquadLobby = true
	
	local userID = tostring(member.UserId)
	local userLocationData = playerSquadsDS:GetAsync(userID)
	
	local squadID = userLocationData.SquadId
	local privateServerID = userLocationData.SquadLobby["PrivateServerID"]
	
	local squadData = nil
	local correctServer = (privateServerID == game.PrivateServerId)
	

	squadData = activeSquadsDS:GetAsync(squadID)
	if squadData then
		-- we got data, now initialize
		squadService:CreateSquadFromData(squadData)
	else
		print("Active Squad doesn't exist, handle this exception")
		-- probably send back to main lobby and clear rich presence
		--self.InitializingSquadLobby = false
		--return
	end

	
	self.LobbySquadID = squadID
	self.LobbySquadInviteUpdater = datastoreOnUpdate(activeSquadsDS, squadID, function(data) --activeSquadsDS:OnUpdate(squadID, function(data)
		-- this could either be a really good or really bad way to handle invites
		-- depends on how frequent this function can be called without datastores crapping out.
		if data.LastUpdateType == "External" then
			if data.Invited then
				for invitedUserId, status in pairs(data.Invited) do
					if status == false then
						if squadData.Invited[invitedUserId] == true then
							-- player declined invite
							squadData.Invited[invitedUserId] = nil
							squadData.Size = squadData.Size - 1
						end
					end
				end
			end
			
			spawn(function()
				squadData.LastUpdateType = "Internal"
				activeSquadsDS:UpdateAsync(squadID, function(old)
					return squadData
				end)
				
				displayDebugSquad(squadData)
			end)
		end
	end)
	
	self.MatchMakingReady = true -- ready for matchmaking
	self.InitializedSquadLobby = true
	self.InitializingSquadLobby = false
end


function squadService:Init(m)
	services = m

	
	local passed, errorReason = pcall(function()
		playerSquadsDS = dss:GetDataStore("Attrition_User_Squads") -- used for getting users' states
		-- Key will be UserId, Value will be {SquadLobby = ReservedServerID; SquadID = squadGUID, FriendJoinEnabled = true/false}
		
		activeSquadsDS = dss:GetDataStore("Attrition_Active_Squads")
		-- Key will be squadId, value will be squad data, delete when squad disbanded (when last member leaves, or when game server receives squad)
	
		squadInvitesDS = dss:GetDataStore("Attrition_Squad_Invites")
		-- Key will be UserId, value will be the most recent squad you've been invited to, and the person who invited you 
		-- {SquadId = squadId, Inviter = string PlayerName}
	end)
	
	if not passed then
		print("Datastores Offline: ", errorReason)
	end
	
	remotes.RequestSquadLeave.OnServerEvent:connect(function(client)
		local squad = getSquadFromMember(client)
		if squad then
			leaveSquad(squad, client)
		end
	end)
	
	remotes.RequestSquadInvite.OnServerEvent:connect(function(client, friendId)

		self:InviteFriendToSquad(client, friendId) 


	end)
	
	remotes.RequestJoinFriend.OnServerEvent:connect(function(client, friendId, squadJoin)
		-- first check if friends, then where friend is, if in game, just send to friend's server, if in open squad, send to squad place
		if client and friendId then

			if client:IsFriendsWith(friendId) then

				if squadJoin then
					local friendSquad = squads[squadJoin]
					addMemberToSquad(friendSquad, client)
					return
				end
				
				local success, err, placeId, instanceId = teleportService:GetPlayerPlaceInstanceAsync(friendId)
				if placeId then
			
					-- need to check now if this place is a Custom Server
					local customServerData = services["Matchmaking"]:GetReservedServerFromJobId(instanceId)
					if not customServerData then
						-- join normal server
						teleportService:TeleportToPlaceInstance(tostring(placeId), instanceId, client, "", {JoiningFriend = friendId}, nil)
					else
						-- join custom server
						local accessCode = customServerData.AccessCode
						teleportService:TeleportToPrivateServer(tostring(placeId), accessCode, {client}, "", {JoiningFriend = friendId}, nil)
					end
					
				end
			end
		end
	end)
	
	remotes.GetSquadState.OnServerInvoke = function(client)
	



		return (self:GetSquadFromMember(client)) -- lets avoid sending squad data for now
		--return squadData
	end
	
	remotes.GetFriendsOnline.OnServerInvoke = function(client, friendsList, filter)
		return self:GetFriendsOnline(client, friendsList, filter)
	end
	
	remotes.RequestSquadCreation.OnServerInvoke = function(client, state, data)
	
		-- determine if allowed to make a squad
		-- first check if not in a squad, then if the player is in a state that would prevent them from making a squad (teleporting to a squad lobby, matchmaking, already making a squad, etc.)
		if not self:GetSquadFromMember(client) then
			-- we'll do those other checks later though
			if state == "GetAllowed" then
				if not inSquadCreation[client.Name] then
					inSquadCreation[client.Name] = true
					return true
				end
			elseif state == "CreateSquad" then
				if inSquadCreation[client.Name] and data then
					local success = self:PlayerRequestedCreateSquad(client, data)
					inSquadCreation[client.Name] = false
					return success
				end
				return false
			elseif state == "Cancel" then
				if inSquadCreation[client.Name] then
					inSquadCreation[client.Name] = false
					return true
				end
				return false
			elseif state == "CanShowTag" then
				-- return true for now
				-- check if owns a contributor tier
				
				local isContributor = isPlayerContributor(client)
		
				
				
				return isContributor
			elseif state == "BuyTag" then
					--prompt purchase of bronze contributor
					local mps = game:GetService("MarketplaceService") --get this set elsewhere
					mps:PromptProductPurchase(client, 309772155)

					return
			elseif state == "ValidateTag" then
				if type(data) == "string" then
					local sanitizedText = sanitizeTagText(client, data)
					if sanitizedText then
						return sanitizedText
					end
				end
			elseif state == "GetSquad" then
				return self:GetSquadFromMember(client)
			end
		end	
	end
	
	game.Players.PlayerAdded:Connect(function(player)
	--	debugLogClient(player,"you joined, congrats")
	--	spawn(function()
	--		wait(5)
	--		debugLogClient(player,"sending debug mssg")
	--	end)

		local function OnInviteReceived(data)
			print("invite check")
			
			if data then
				spawn(function()
					squadInvitesDS:RemoveAsync(tostring(player.UserId))
				end)
				
				local squad = getSquadFromMember(player)
	
				
				spawn(function()
					promptPlayerWithInvite(player, data)
				end)
			end
		end
		

		local updateSignal = datastoreOnUpdate(squadInvitesDS, tostring(player.UserId), OnInviteReceived) --squadInvitesDS:OnUpdate(tostring(player.UserId), OnInviteReceived)

		
		
	--	local added = false
		--if self.InitializedSquadLobby then
			-- handle adding player to squad
		--	added = addMemberToSquad(squads[self.LobbySquadID], player)
	--	elseif not self.InitializingSquadLobby then
			-- initialize squad lobby
		--	self:InitializeSquadLobby(player)
		--	added = addMemberToSquad(squads[self.LobbySquadID], player)
	--	else
	--		-- lobby is being initialized, wait until completed
			-- then add to squad
		--	while not self.InitializedSquadLobby do
		--		wait(.5)
		--	end
		--	added = addMemberToSquad(squads[self.LobbySquadID], player)
		--end

		
	end)
	
	game.Players.PlayerRemoving:Connect(function(player)
		if playerInviteEvents[player.Name] then
			playerInviteEvents[player.Name]:Disconnect()
			playerInviteEvents[player.Name] = nil
		end
		
	
		-- if player is leaving, and is not matchmaking, then remove from squad
		local squad = getSquadFromMember(player)
		if squad  then
			-- player left squad
			leaveSquad(squad, player)
		end
	
	end)
end

return squadService
