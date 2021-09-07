-- responsible for pulsing the dance pad
-- services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- modules
local util = ReplicatedStorage.Vendor
local class = require(util.LuaClass)
local baseSingleton = require(util.LuaClass:WaitForChild("BaseSingleton"))

--class declaration
local PadService, get, set = class("PadService", baseSingleton)

--reducers

function PadService.__initSingleton(prototype) -- class initilaization
    local self = baseSingleton.__initSingleton(PadService) -- get singleton by calling super init
    
    if RunService:IsServer() then -- define server side of the class
        self._lastTick = tick()
          
        self._thread = RunService.Heartbeat:Connect(function()
            if tick() - self._lastTick > 0.5 then
                for _, pad in pairs(workspace.Functional.DanceFloor:GetChildren()) do
                
                    pad.Color = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
                    
                end
                
                self._lastTick = tick()
            end
        
        
        end)

        
 
    end -- start defining client side of class


    return self
end



return PadService
