local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local dss = game:GetService("DataStoreService")

local version = "_Pre_Alpha_3"
local StarterGui = nil

local isServer = RunService:IsServer()

local localPlayer = nil
if not isServer then
    localPlayer = Players.LocalPlayer

    StarterGui = game:GetService("StarterGui")
end

-- external stuff
local remotes -- defined later
local gameShared = ReplicatedStorage:WaitForChild("GameShared")
local sharedLib = gameShared:WaitForChild("SharedLib")
local sharedSystems = gameShared:WaitForChild("SharedSystems")
local util = gameShared:WaitForChild("Util")
local luaClass = sharedLib:WaitForChild("LuaClass")


--modules 
local rodux = require(util:WaitForChild("Rodux"))
local roactRodux = require(util:WaitForChild("Roact-Rodux"))
local roact = require(util:WaitForChild("Roact"))
local class = require(luaClass)
local baseSingleton = require(luaClass:WaitForChild("BaseSingleton"))


-- lobby services
local serverModules -- defined later 

-- mapping data



local function isVIPServer()

    if game.PlaceId == 7175796352 then -- if lobby place then
        if not (game.PrivateServerId == "") and (game.PrivateServerOwnerId > 0) then
            return true
        end
        return false
    else
        local vipServersDS, reservedServersDS, serverData;
        local passed, errorReason = pcall(function()
            vipServersDS = dss:GetDataStore("Attrition_VIP_Servers"..version)
            reservedServersDS = dss:GetDataStore("Attrition_Custom_Servers"..version)

            serverData = reservedServersDS:GetAsync(game.PrivateServerId) 
        end)
     
        if serverData then
            for i, v in pairs(serverData) do
                print(i, v, "vip")
            end
            return true, serverData
        end

        return false
        
    end
end 


--class declaration
local LobbyService, get, set = class("LobbyService", baseSingleton)

--reducers
local server = require(script.Server)
local client = require(script.Client)
local baseApp = script.BaseApp

--rules 
local gameRules = require(script.GameRules)

function LobbyService.__initSingleton(prototype) -- class initilaization
    local self = baseSingleton.__initSingleton(LobbyService) -- get singleton by calling super init

    if isServer then -- define server side of the class

        if game.PlaceId == 7175796352 then -- if we are in the lobby then
            serverModules = script.Services.Lobby:GetChildren()
            remotes = ReplicatedStorage:WaitForChild("Remotes", 2)
        else -- we are definetly in game
    
            serverModules = script.Services.Ingame:GetChildren()
            local folder = Instance.new("Folder", ReplicatedStorage); -- create a new events folder because these do not exist in game and are required at a minimum
            local function createEvent(name, type, parent)
                if type == "event" then
                    local event = Instance.new("RemoteEvent", parent)
                    event.Name = name;
                elseif type == "function" then
                    local func = Instance.new("RemoteFunction", parent)
                    func.Name = name;
                end
            end

            createEvent("RequestMatchmaking", "event", folder)
            createEvent("RequestVIPSettings", "function", folder)

            folder.Name = "Remotes"
      
        end



        self._remoteEvent = Instance.new("RemoteEvent", script)
        self._toggleEvent = Instance.new("RemoteEvent", script)
        self._purchaseVerification = Instance.new("RemoteEvent", script)
        self._init = Instance.new("RemoteFunction", script) 
        self._purchaseVerification.Name = "PurchaseVerification"
        self._init.Name = "Init"
        self._toggleEvent.Name = "ToggleEvent"
        self._playerStores = {}
        self._serverStore = rodux.Store.new(server, {}, {rodux.thunkMiddleware})

        self._purchaseVerification.OnServerEvent:Connect(function(plr)
            local contribStatus

            if game.PlaceId == 7175796352 then -- if lobby place then
                contribStatus = game.ServerScriptService.PatchVotingService.GetContributorStatus:Invoke(plr)
    
            else -- else in game so patchvoting in a different spot. should of been a shared tbh if on both places
                contribStatus = game.ServerScriptService.Services.PatchVotingService.GetContributorStatus:Invoke(plr)
       
            end

            if contribStatus then
                for i, v in pairs(contribStatus) do
                    if v > 0 then
                        self._remoteEvent:FireClient(plr, {
                            type = "TagPurchased";
                            value = true
                        })
                    end
                end
            end

        end)

        self._init.OnServerInvoke = (function(plr)


            local vipStatus, serverData = isVIPServer()
            print(vipStatus, "this is the real vip status")
            
            if vipStatus then

                if serverData then
                    self._remoteEvent:FireClient(plr, {
                        type = "GetVIPSetting";
                        isOwner = (serverData.OwnerID == plr.UserId);
                        customSettings = serverData;
                    })

                    print("We have server data")
                end
           
                if game.PlaceId == 7175796352 then -- if lobby then set vip lobby
                    print("vip lobby")
                    self._remoteEvent:FireClient(plr, {
                        type = "ToggleLobby";
                        toggleTo = "VIP";
                    })
                    self._remoteEvent:FireClient(plr, {
                        type = "ServerType";
                        value = "VIP";
                    })
                else-- we be in game, so give it the vip in game version
                    print("vip server")
                    self._remoteEvent:FireClient(plr, {
                        type = "ToggleLobby";
                        toggleTo = "DEPLOY";
                    })
                    self._remoteEvent:FireClient(plr, {
                        type = "ServerType";
                        value = "VIPServer";
                    })
                end
            else
                if not(game.PlaceId == 7175796352) then -- if not vip but also not lobby 
                    print("regular server")
                    self._remoteEvent:FireClient(plr, {
                        type = "ToggleLobby";
                        toggleTo = "DEPLOY";
                    })
                    self._remoteEvent:FireClient(plr, {
                        type = "ServerType";
                        value = "Server";
                    })
                end
            end

            return true
            
        end)

        self._serverModules = {}

        for i = 1, #serverModules do -- require server modules
            self._serverModules[serverModules[i].Name] = require(serverModules[i])
        end
        
        for i, v in pairs(self._serverModules) do -- initialize them with a list of the other modules
            v:Init(self._serverModules)
        end
    else -- start defining client side of class
        self._initialized = false
        self._uiHandle = ""; -- set it to an empty string I guess
        self._remoteEvent = script:WaitForChild("RemoteEvent")
        self._toggleEvent = script:WaitForChild("ToggleEvent")
        self._init = script:WaitForChild("Init")
        self._purchaseVerification = script:WaitForChild("PurchaseVerification")
        self._clientStore = rodux.Store.new(client, {}, {rodux.thunkMiddleware})
        self._clientApp = roact.createElement(roactRodux.StoreProvider, {
            store = self._clientStore
        }, {
            LoadoutApp = roact.createElement(require(script.BaseApp),{
            })
        })

        remotes = ReplicatedStorage:WaitForChild("Remotes", 2)

        self._remoteEvent.OnClientEvent:Connect(function(passedDispatch)
            self._clientStore:dispatch(passedDispatch)
        end)

        self._toggleEvent.OnClientEvent:Connect(function(toggle)
     
            if toggle then
                self._uiHandle = roact.mount(self._clientApp, game.Players.LocalPlayer.PlayerGui, "LobbyApp")
            else
                if self._uiHandle then
                    roact.unmount(self._uiHandle)
                end
                game.Players.LocalPlayer.PlayerGui.HudApp.Enabled = true
            end
        end)

        if game.PlaceId == 7175796352 then -- if lobby then give initial dispatches
    
            self._clientStore:dispatch(function(store)
                local state = store:getState()
                local servers = remotes.GetServerList:InvokeServer(state.playerHandler.Filter)
        
                store:dispatch({
                    type = "SetServers";
                    servers = servers;
                })

            end)

            self._clientStore:dispatch(function(store)
        
                local canTag = remotes.RequestSquadCreation:InvokeServer("CanShowTag")
    
                store:dispatch({
                    type = "SetServers";
                    value = canTag;
                })
            
            end)

            self._clientStore:dispatch(function(store)
        
                local getSquad = remotes.GetSquadState:InvokeServer()
    
                store:dispatch({
                    type = "GetSquad";
                    squad = getSquad;
                })
            
            end)

            
            remotes.RequestSquadInvite.OnClientEvent:Connect(function(squad)
    

                self._clientStore:dispatch(function(store)
        
        
                    store:dispatch({
                        type = "GetSquad";
                        squad = squad;
                    })

                
                end)
            
            end)

            

        else -- we are not in lobby
           print("in game")

        end


        local ready = self._init:InvokeServer()

        local state = self._clientStore:getState()
        
        if state.playerHandler.ServerType == "VIP" or state.playerHandler.ServerType == "VIPServer" then
                    --local success, error = pcall(remotes.RequestVIPSettings.InvokeServer, remotes.RequestVIPSettings, "GetServerSettings") debug
            local canCustomize, customServerData = remotes.RequestVIPSettings:InvokeServer("GetServerSettings") --check for server owner/private server
            print("we are in vip land")
            if customServerData then --should replace this to check if isVIPServer instead of can customize or those who can't customize will just get defaults
      
                self._clientStore:dispatch({
                    type = "GetVIPSetting";
                    isOwner = canCustomize;
                    customSettings = customServerData;
                })

         
                if not customServerData.GameRules.RuleSet.BaseVehicleCaps then
                    self._clientStore:dispatch({
                        type = "SetRuleSetting";
                        setting = "BaseVehicleCaps";
                        value = {
                            LandLightArmor = 10; -- jeeps
                            LandArtillery = 4; --  rocket artillery
                            LandHeavyArmor = 8; -- tanks, apc
                            AirHelicopterTransport = 6; -- light and transport helis
                            AirHelicopterCombat = 3; -- attack helis
                            AirJet = 2; -- jets
                            AirFighter = 2;
                        };
                    })
                end
                
                if not customServerData.GameRules.RuleSet.VehiclePointCostMultipliers then
                    self._clientStore:dispatch({
                        type = "SetRuleSetting";
                        setting = "VehiclePointCostMultipliers";
                        value  = {
                            LandLightArmor = 1; -- jeeps
                            LandArtillery = 1; --  rocket artillery
                            LandHeavyArmor = 1; -- tanks, apc
                            AirHelicopterTransport = 1; -- light and transport helis
                            AirHelicopterCombat = 1; -- attack helis
                            AirJet = 1; -- jets
                            AirFighter = 1;
                        };
                    })
                end
    
                if not customServerData.GameRules.RuleSet.WorldSettings then
                    self._clientStore:dispatch({
                        type = "SetRuleSetting";
                        setting = "WorldSettings";
                        value  = {
                            Gravity = 1;
                            Trees = true;
                        };
                    })
                end
    
        
    
                self._clientStore:dispatch({
                    type = "GameRules";
                    value = gameRules;
                })


            end
            
        end

        self._purchaseVerification:FireServer()
        -- this is a shared dispatch between places
        self._clientStore:dispatch(function(store)
                local loadout = require(sharedSystems:WaitForChild("Loadout"))            
                store:dispatch({
                type = "GetLoadout";
                loadout = loadout;
            })
        end)
    

        self._initialized = true
    end

    return self
end

get.Store = function(self)
    if isServer then
        return self._serverStore
    else
        return self._clientStore
    end
end

-- server methods

function LobbyService:DispatchToClient(player, dispatch)
    self._remoteEvent:FireClient(player, dispatch)

end

function LobbyService:ToggleUI(player, toggle)
    self._toggleEvent:FireClient(player, toggle)

end

-- client methods


function LobbyService:LoadApp(playerGui)
 
        if self._initialized then
    
            self._uiHandle = roact.mount(self._clientApp, playerGui, "LobbyApp")
        else
            spawn(function()
                while not(self._initialized) do
                    wait()
                end
                
                self._uiHandle = roact.mount(self._clientApp, playerGui, "LobbyApp")
            end)
        end
           
   


end

function LobbyService:Unmount()
    roact.unmount(self._uiHandle)
    self._uiHandle = nil

end

return LobbyService
