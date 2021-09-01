--[[
	
	API:
	 Discord:Post(postData)
	
	Resources:
	 https://support.discordapp.com/hc/en-us/articles/228383668-Intro-to-Webhooks
	 https://discordapp.com/developers/docs/resources/webhook#execute-webhook
	
	Example:
	 Discord:Post({
	 	username = player.Name,
		avatar_url = game.Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size180x180),
		embeds = {{
			title = "Feedback from "..player.Name,
			color = 178007,
			description = "This is what I thought about your game...",
		}},
	 })
	
	Colors:
	 Green = 178007
	 Red = 14820122
	 Grey = 2895667
	
	Proxy:
	 Because Discord blocked webhooks coming from Roblox because we didn't respect the rate limits (this module does), 
	 you have to use a proxy until they lift that ban. 
	
	 Osyris has a free one available, you can find it here: https://devforum.roblox.com/t/roblox-discord-webhook-proxy-server/98825
--]]

--Services
local runService = game:GetService("RunService")
local heartbeat = runService.Heartbeat

local HTTP = game:GetService("HttpService")

--Module
local Discord = {
	BlockedUntil = 0	
}

--Functions
function Discord:Request(url, method, headers, body, autoretryCount)
	
	--Validatae
	if (tick() < Discord.BlockedUntil) then
		
		local timeLeft = Discord.BlockedUntil-tick()
		if autoretryCount > 0 then
			warn("Discord: You are posting too many messages to discord! Autoretry in:", timeLeft.." seconds")
			repeat
				heartbeat:wait()
			until tick() > (Discord.BlockedUntil + math.random()) -- add a bit of random leeway
			Discord:Request(url, method, headers, body, autoretryCount-1)
		else
			return false, Discord.BlockedUntil
		end
		
	end

	--Variables
	local data = {
		Url = url,	
		Method = method,
		Headers = headers,
	}
	
	if not (method == "GET" or method == "HEAD") then
		data.Body = body and HTTP:JSONEncode(body) or ""
	end
	
	--Post
	local res = HTTP:RequestAsync(data)
	local resBody = res.Body and res.Body ~= "" and HTTP:JSONDecode(res.Body) or {}
	
	--Rate Limiting
	if res.StatusCode == 429 then 
		--Block
		Discord.BlockedUntil = tick() + (resBody["retry_after"] / 1000)		
		--Warn
		warn("Discord: You have been rate limited until " .. Discord.BlockedUntil)
		
		local timeLeft = Discord.BlockedUntil-tick()
		if autoretryCount > 0 then
			warn("Autoretry in:", timeLeft.." seconds")
			repeat
				heartbeat:wait()
			until tick() > (Discord.BlockedUntil + math.random()) -- add a bit of random leeway
			Discord:Request(url, method, headers, body, autoretryCount-1)
		else
			return false, Discord.BlockedUntil
		end
	end

	return true, resBody
end

return Discord