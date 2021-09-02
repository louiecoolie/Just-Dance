-- chart service will be responsible for loading and syncing charts to players

-- services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- modules
local util = ReplicatedStorage.Vendor

--modules 
local rodux = require(util:WaitForChild("Rodux"))
local roactRodux = require(util:WaitForChild("Roact-Rodux"))
local roact = require(util:WaitForChild("Roact"))
local class = require(util.LuaClass)
local baseSingleton = require(util.LuaClass:WaitForChild("BaseSingleton"))


-- lobby services



--class declaration
local ChartService, get, set = class("ChartService", baseSingleton)

--reducers
local server = require(script.Server)
local client = require(script.Client)
local baseApp = script.BaseApp


function ChartService.__initSingleton(prototype) -- class initilaization
    local self = baseSingleton.__initSingleton(ChartService) -- get singleton by calling super init

    if RunService:IsServer() then -- define server side of the class


        self._syncClient = Instance.new("RemoteEvent", script)
        self._startClient = Instance.new("RemoteEvent", script)
        self._syncClient.Name = "syncClient"
        self._startClient.Name = "startClient"
        

        self._playerStores = {}
        self._serverStore = rodux.Store.new(server, {}, {rodux.thunkMiddleware})


        -- chart container
        self._charts = {} -- define an empty table for charts 
        for _, chartData in pairs(script.Charts:GetChildren()) do -- get the charts
            local data = require(chartData)
            self._charts[#self._charts+1] = {
                name = data.name;
                chart = data.chart;
                length = data.length;
                id = data.id;
            }-- store the chart data for later usage
        end


        -- audio object
        self._currentSound = Instance.new("Sound") -- init audio object that will play first song
        self._currentIndex = 0; -- will be used to index the currently indexed chart, may or may not be needed
        self._currentSound.Parent = game:GetService("SoundService")
        
    
        -- game logic variables
        self._intermission = 2
        self._elapsed = 0;
        self._songTick = nil;
        self._songElapsed = 0;
        self._chartTick = 0;
        
        self._coreLoop = RunService.Heartbeat:Connect(function(dt) -- core logic loop for the chart service initialized here.

            if not(self._currentSound.Playing) then
                if self._elapsed < self._intermission then --if not in intermission then.
                    self._elapsed += dt
                else --start a new song
                        
                    if self._currentSound then -- clean up previous sound devise.
                        self._currentSound:Destroy()
                    end

                    
                    self._chartTick = 0 -- reset the chart tick

                    self._currentSound = Instance.new("Sound") -- this will play the current song and be cleaned up on the next song.
                    self._currentSound.Parent = game:GetService("SoundService")
            
                    print("starting song")

                    self._currentIndex = self._charts[math.random(1,#self._charts)] -- get a random chart
            
                    self._currentSound.SoundId = self._currentIndex.id; -- set the id of the new sound object

                    self._currentSound:Play() -- start playing the song

                    self._elapsed = 0 -- reset timer for next song
                    self._songElapsed = tick()

                    self._stepNote = true

                    self._startClient:FireAllClients(true, self._currentIndex)
                    self._currentSound.Ended:Connect(function()
                    
                        self._startClient:FireAllClients(false)
                    end)
                end
            else
                -- get the time in seconds for each position of the track
                if self._currentSound.isLoaded then -- make sure the audio is loaded to get pretty TimeLength
                    if self._stepNote then
                        
                        self._songTick = self._currentSound.TimeLength / self._currentIndex.length 
                        self._stepNote = false
                        self._lastStep = dt
                        
                        self._syncClient:FireAllClients(self._songTick, self._chartTick)
                        coroutine.wrap(function()
                            while self._lastStep > self._songTick do
                                self._lastStep -= self._songTick
                                                    
                                
                                if (tick()-self._songElapsed) >= self._songTick then
                    
                                    self._chartTick += 1;
                                    if self._currentIndex.chart[self._chartTick] then
                                     --   print("found note at", self._chartTick)
                                        self._songElapsed = tick()
                                    end
                                    
                                end

                                if self._lastStep  < self._songTick then
                            
                                    self._stepNote = true
                                end
                            end
                        end)()
                    end


                end
            end
        
        end)

 
    else -- start defining client side of class
        self._initialized = false
        self._uiHandle = ""; -- set it to an empty string for now

        self._clientStore = rodux.Store.new(client, {}, {rodux.thunkMiddleware})
        self._clientApp = roact.createElement(roactRodux.StoreProvider, {
            store = self._clientStore
        }, {
            App = roact.createElement(require(script.BaseApp),{
            })
        })
        self._syncClient = script.syncClient
        self._startClient = script.startClient
        -- chart container
        self._charts = {} -- define an empty table for charts 
        for _, chartData in pairs(script.Charts:GetChildren()) do -- get the charts
            local data = require(chartData)
            self._charts[#self._charts+1] = {
                name = data.name;
                chart = data.chart;
                length = data.length;
                id = data.id;
            }-- store the chart data for later usage
        end


  
    
        -- game logic variables
        self._intermission = 2
        self._elapsed = 0;
        self._songTick = nil;
        self._songElapsed = 0;
        self._chartTick = 0;
        self._songPlaying = false;

        self._syncClient.OnClientEvent:Connect(function(songTick, chartTick)
        
            self._songTick = songTick
            self._chartTick = chartTick

        end)

        self._startClient.OnClientEvent:Connect(function(condition, index)
            print("received start from server")
            self._songPlaying = condition
            self._stepNote = condition
            self._songElapsed = tick()

            if index then
         
                self._currentIndex = index;
            end
        
        end)
        
        self._coreLoop = RunService.Heartbeat:Connect(function(dt) -- core logic loop for the chart service initialized here for client

            if self._songPlaying then
                if self._stepNote then
                
                    if self._songTick then
                  
                        self._stepNote = false
                        self._lastStep = dt
                       -- print(self._songTick)
                        coroutine.wrap(function()
                            while self._lastStep > self._songTick do
                                self._lastStep -= self._songTick
                                --print(self._lastStep)
                                                            
                                
                                if (tick()-self._songElapsed) >= self._songTick then
                                  
                                    self._chartTick += 1;
                                    --print(self._chartTick)
                                    --print(self._currentIndex.chart[self._chartTick])
                                    if self._currentIndex.chart[tostring(self._chartTick)] then
                                        print("found note at client", self._chartTick)
                                        self._songElapsed = tick()
                                    end
                                    
                                end

                                if self._lastStep  < self._songTick then
                            
                                    self._stepNote = true
                                end
                            end
                        end)()
                    end
                end
            else
                self._stepNote = true
                self._songTick = nil
            end
        
        end)


        self._initialized = true
    end

    return self
end



-- server methods

function ChartService:DispatchToClient(player, dispatch)
    self._remoteEvent:FireClient(player, dispatch)

end

function ChartService:ToggleUI(player, toggle)
    self._toggleEvent:FireClient(player, toggle)

end

-- client methods


function ChartService:LoadApp(playerGui)
 
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

function ChartService:Unmount()
    roact.unmount(self._uiHandle)
    self._uiHandle = nil

end

return ChartService
