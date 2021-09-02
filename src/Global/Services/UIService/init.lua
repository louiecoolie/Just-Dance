
-- responsible for general ui unrelated to the game


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- modules
local util = ReplicatedStorage.Vendor
local rodux = require(util:WaitForChild("Rodux"))
local roactRodux = require(util:WaitForChild("Roact-Rodux"))
local roact = require(util:WaitForChild("Roact"))
local class = require(util.LuaClass)
local baseSingleton = require(util.LuaClass:WaitForChild("BaseSingleton"))


-- lobby services



--class declaration
local UIService, get, set = class("UIService", baseSingleton)

--reducers
local server = require(script.Server)
local client = require(script.Client)
local baseApp = script.BaseApp


function UIService.__initSingleton(prototype) -- class initilaization
    local self = baseSingleton.__initSingleton(UIService) -- get singleton by calling super init

    if  RunService:IsServer() then -- define server side of the class




        self._remoteEvent = Instance.new("RemoteEvent", script)
        self._toggleEvent = Instance.new("RemoteEvent", script)
        self._purchaseVerification = Instance.new("RemoteEvent", script)
        self._init = Instance.new("RemoteFunction", script) 
        self._purchaseVerification.Name = "PurchaseVerification"
        self._init.Name = "Init"
        self._toggleEvent.Name = "ToggleEvent"
        self._playerStores = {}
        self._serverStore = rodux.Store.new(server, {}, {rodux.thunkMiddleware})

 
    else -- start defining client side of class
        self._initialized = false
        self._uiHandle = ""; -- set it to an empty string for now
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
