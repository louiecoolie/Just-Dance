
-- responsible for general ui of the game


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

-- modules
local util = ReplicatedStorage.Vendor
local rodux = require(util:WaitForChild("Rodux"))
local roactRodux = require(util:WaitForChild("Roact-Rodux"))
local roact = require(util:WaitForChild("Roact"))
local class = require(util.LuaClass)
local baseSingleton = require(util.LuaClass:WaitForChild("BaseSingleton"))





--class declaration
local UIService, get, set = class("UIService", baseSingleton)

--reducers
local server = require(script.Server)
local client = require(script.Client)
local baseApp = script.BaseApp


function UIService.__initSingleton(prototype) -- class initilaization
    local self = baseSingleton.__initSingleton(UIService) -- get singleton by calling super init

    if  RunService:IsServer() then -- define server side of the class
        local result, response = pcall(DataStoreService.GetDataStore, DataStoreService, "DanceDS")
        self._datastore = result and response or false

        self._updateServer = Instance.new("RemoteEvent", script) -- receives updates external to the service
        self._dispatchClient = Instance.new("RemoteEvent", script) -- dispatches updates internal to the service.
        self._updateServer.Name = "updateServer"
        self._dispatchClient.Name = "dispatchClient"



        self._playerStores = {}
        self._serverStore = rodux.Store.new(server, {}, {
            --rodux.thunkMiddleware
        })

 
        self._updateServer.OnServerEvent:Connect(function(player, data)
       
            if data.points then
                local state = self._serverStore:getState() -- pull state 
     
                local points = state.Server.Profiles[player.Name].points -- get clients points from state.

                points += data.points

                if points < 0 then
                    points = 0   -- ensure we do not have negative points
                end

                self._serverStore:dispatch({
                    type = "Points";
                    key = player.Name;
                    value = points;
                })

                self._dispatchClient:FireClient(player, {
                    type = "Points",
                    value = points
                })

            end
        end)

        game.Players.PlayerAdded:Connect(function(player)
            local success, store = pcall(function()
                return  self._datastore:GetAsync(player.UserId)
            end)

            if success and store then

                self._serverStore:dispatch({
                    type = "Profile";
                    key = player.Name;
                    data = store;
                })

                self._dispatchClient:FireClient(player, {
                    type = "Profile";
                    data = store;
                })
            else
           
                self._serverStore:dispatch({
                    type = "Profile";
                    key = player.Name;
                    data = {
                        points = 0;
                        fame = 0;
                    };
                })
                self._dispatchClient:FireClient(player, {
                    type = "Profile";
                    data = {
                        points = 0;
                        fame = 0;
                    };
                })
            end
        
        
        end)
        
        game.Players.PlayerRemoving:Connect(function(player)
            local state = self._serverStore:getState() 
            local success, errorMessage = pcall(function()
                self._datastore:SetAsync(player.UserId, state.Server.Profiles[player.Name])
            end)
        
        end)

        ReplicatedStorage.Events:WaitForChild("Binding").Event:Connect(function(type)

            if type == "reset" then
                
                local state = self._serverStore:getState() 

                for player, data in pairs(state.Server.Profiles) do
                    self._serverStore:dispatch({
                        type = "Fame";
                        key = player;
           
                    })
    
                    self._dispatchClient:FireClient(game.Players[player], {
                        type = "Fame";
        
                    })
                end

            end
        
        end)
    else -- start defining client side of class
        self._initialized = false
        self._uiHandle = ""; -- set it to an empty string for now
        self._dispatchClient = script:WaitForChild("dispatchClient")
        self._activate = false;

        self._clientStore = rodux.Store.new(client, {}, {rodux.thunkMiddleware})
        self._clientApp = roact.createElement(roactRodux.StoreProvider, {
            store = self._clientStore
        }, {
            LoadoutApp = roact.createElement(require(script.BaseApp),{
            })
        })


        self._dispatchClient.OnClientEvent:Connect(function(data)
        
            self._clientStore:dispatch(data)
        
        end)

        self._coreLoop = RunService.RenderStepped:Connect(function(dt) 
            if game.Players.LocalPlayer.Character then
                local distance = (workspace.Functional.Dance.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distance > 29 then
                    if self._activate == true then
                        self._activate = false
                
                        self._clientStore:dispatch({
                            type = "Toggle";
                            value = self._activate
                        })
                    end
                elseif distance < 29 then
                    if self._activate == false then
                        self._activate = true
                        
                        self._clientStore:dispatch({
                            type = "Toggle";
                            value = self._activate
                        })
                    end
                end
            end
        end)

        self._initialized = true

    end

    return self
end



-- server methods

function UIService:DispatchToClient(player, dispatch)
    self._remoteEvent:FireClient(player, dispatch)

end

function UIService:ToggleUI(player, toggle)
    self._toggleEvent:FireClient(player, toggle)

end

-- client methods


function UIService:LoadApp(playerGui)
 
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

function UIService:Unmount()
    roact.unmount(self._uiHandle)
    self._uiHandle = nil

end

return UIService
