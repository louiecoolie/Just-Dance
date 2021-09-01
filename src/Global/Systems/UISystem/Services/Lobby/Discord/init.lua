local runService = game:GetService("RunService")

local dss = game:GetService("DataStoreService")
local playerLinksDS = nil -- datastore that holds all players' squad status

local http = game:GetService("HttpService")
local repStorage = game:GetService("ReplicatedStorage")
local remotes = repStorage:WaitForChild("Remotes")

local discordRequestsModule = require(script:WaitForChild("DiscordRequestHandler"))
local discordLinkService = {}

local services = nil

-- WebVars
local cachedPlayerVerCodes = {}

local token = "NjczOTg1OTE3NDI5NjEyNTU0.Xjoo8Q.xmMbW9Mdq4FlmYEqBkY3AnYq6Rw"

local baseURL = "https://discordapp.com/api/"

local botDiscordId = "673985917429612554"
local attritionDiscordId = "341255866994917376"
local verificationChannelId = "674702955181768745"

-- roles
local verifiedDiscordRole = "674698152850358274"
local platinumRole = "674698139923644436"
local goldRole = "674698145908654131"
local silverRole = "674698148609785876"
local bronzeRole = "674698150879166464"

local headers = {
	["Authorization"] = "Bot "..token;
	["Content-Type"] = "application/json";
}
-- end


local function isPlayerContributor(client)
	local contribStatus = game.ServerScriptService.PatchVotingService.GetContributorStatus:Invoke(client)
	return contribStatus
end

local function deleteMessages(channelId, listOfMsgs) -- delete a user's message after bot verifies
	if #listOfMsgs > 1 then
		local channelURL = baseURL.."channels/"..channelId.."/messages/bulk-delete"
		local data = {messages = listOfMsgs}
		local dataJson = http:JSONEncode()
		local passed, deletionData = discordRequestsModule:Request(channelURL, "POST", headers, data, 5)
	else
		local msgURL = baseURL.."channels/"..channelId.."/messages/"..listOfMsgs[1]
		local passed, deletionData = discordRequestsModule:Request(msgURL, "DELETE", headers, nil, 5)
	end
end

local function assignDiscordRole(userid, roleid)
	local assignRoleURL = baseURL.."/guilds/"..attritionDiscordId.."/members/"..userid.."/roles/"..roleid
	local passed, response = discordRequestsModule:Request(assignRoleURL, "PUT", headers, nil, 5)
end

local function processVerification(client, discordUserData) -- dm user when process completed, and assign role
	
	-- log the link in datastores
	playerLinksDS:SetAsync(tostring(client.UserId), discordUserData.id)
	
	
	-- assign verified role
	assignDiscordRole(discordUserData.id, verifiedDiscordRole)
	
	-- check for contributions, and assign corresponding roles
	local contribs = isPlayerContributor(client)
	if contribs["Platinum"] > 0 then
		assignDiscordRole(discordUserData.id, platinumRole)
	end
	if contribs["Gold"] > 0 then
		assignDiscordRole(discordUserData.id, goldRole)
	end
	if contribs["Silver"] > 0 then
		assignDiscordRole(discordUserData.id, silverRole)
	end
	if contribs["Bronze"] > 0 then
		assignDiscordRole(discordUserData.id, bronzeRole)
	end
	
	-- send DM for confirmation
	local dmCreationURL = baseURL.."/users/@me/channels"
	
	local creationData = {recipient_id = discordUserData.id}
	--local dataJson = http:JSONEncode(creationData)
	
	local passedDMCreate, dmChannelData = discordRequestsModule:Request(dmCreationURL, "POST", headers, creationData, 5)
	--local dmChannelJson= http:PostAsync(dmCreationURL, dataJson, Enum.HttpContentType.ApplicationJson, false, headers)
	--local dmChannelData = http:JSONDecode(dmChannelJson)
	
	-- message the user in the channel
	local dmMessage = "Thank you for linking your Roblox account '"..client.Name.."' with your Discord account! This will sync data from Attrition to the Official Attrition Discord Server involving your account. You will receive a 'Verified' role for Discord, perks for your character in Attrition, and if you are a Contributor, a role in Discord to represent it!"
	
	local dmChannelURL = baseURL.."/channels/"..dmChannelData.id.."/messages"
	local msgData = {content = dmMessage}
	local msgJson = http:JSONEncode(msgData)
	
	local passedDMSend, dmMessageData = discordRequestsModule:Request(dmChannelURL, "POST", headers, msgData, 5)
end

local function checkChannelForCode(client, channelId, code)
	local channelURL = baseURL.."channels/"..channelId.."/messages"
	
	local passed, channelMessages = discordRequestsModule:Request(channelURL, "GET", headers, nil, 5)
	--local channelMessageDataJSON = http:GetAsync(channelURL, false, headers)
	--local channelMessages = http:JSONDecode(channelMessageDataJSON)
	
	local replyMessage = ""
	local linkedUser = nil
	local linkedUserName = nil
	local pruneMessages = {}
	
	-- go through messages, find mentions of bot's ID
	for i = 1, #channelMessages do
		local valid = false
		local msg = channelMessages[i]
		if msg.mentions and msg.mentions[1] then
			if msg.mentions[1].id == botDiscordId then
				-- check for code
				valid = true
				
				local msgContent = msg.content
				local mentionString = "<@!"..botDiscordId..">"
				local msgBegin = string.len(mentionString)+1
				local codeReply = string.sub(msgContent, msgBegin)
				
				if string.find(codeReply, code) then
					linkedUser = msg.author.id
					linkedUserName = msg.author.username.." #"..msg.author.discriminator
					pruneMessages[#pruneMessages+1] = msg.id -- prune message to provide feedback
				end
			end
		end
		if not valid then
			-- add to prune
			local index = #pruneMessages+1
			pruneMessages[index] = msg.id
		end
	end
	
	if linkedUser then
		print("We have a match!")
		print("you are:", linkedUserName)
		processVerification(client, {username = linkedUserName, id = linkedUser})
		
		replyMessage = "Verification suceeded! We linked your Roblox account '"..client.Name.."' with your Discord account '"..linkedUserName.."'. If this is wrong, please retry the process."
	else
		replyMessage = "The verification code was not found in the #attrition-link-verification channel. Please make sure you have the right channel and try again."
	end
	
	if #pruneMessages > 0 then
		print("deleting prune marked messages")
		pcall(function() -- might error if multiple requests try to delete the same message
			deleteMessages(channelId, pruneMessages)
		end)
	end
	
	return replyMessage
end

local function generateCode(guid)
	local codeLength = 5
	local formatted = table.concat(string.split(guid, "-"), "")
	local code = ""
	for i = 1, 5 do
		local index = tonumber("0x"..string.sub(formatted, i, i))+6
		code = code..string.sub(formatted, index, index)
	end
	return code
end

function discordLinkService:Init(m)
	services = m
	
	local passed, errorReason = pcall(function()
		playerLinksDS = dss:GetDataStore("Attrition_Discord_Ids") -- used for getting users' states
		-- Key will be UserId, Value will be {SquadLobby = ReservedServerID; SquadID = squadGUID, FriendJoinEnabled = true/false}
	end)
	
	if not passed then
		print("Datastores Offline: ", errorReason)
	end
	
	remotes.GetDiscordState.OnServerInvoke = function(client, state, currentStep)
		if state == "Next" then
			if currentStep == 2 then
				-- generate the code
				local code = generateCode(http:GenerateGUID(false))
				cachedPlayerVerCodes[client] = code
				return "@Attrition-Link "..code
			elseif currentStep == 3 then
				-- check discord for code
				-- return status of link
				local code = cachedPlayerVerCodes[client]
				if code then
					local message = checkChannelForCode(client, verificationChannelId, code)
					return message
				else
					return "An error occurred - Code was never requested, please try again."
				end
			end
		end
	end
end

return discordLinkService
