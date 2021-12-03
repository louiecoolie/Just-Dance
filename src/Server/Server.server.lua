--[[
    This script is responsible for initializing the server side services for the game.
    This game is a rythme dancing game.
]]--


-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage");

--networker
local Binding = Instance.new("BindableEvent", ReplicatedStorage.Events) -- this will be used between services.
Binding.Name = "Binding"

-- systems
local UIService = require(ReplicatedStorage.Services.UIService)() -- responsible for player ui
local ChartService = require(ReplicatedStorage.Services.ChartService)() -- responsible for generating dance charts
local MarketService = require(ServerStorage.Services.MarketService)() -- placed in to consider for monetization
local PadService = require(ReplicatedStorage.Services.PadService)() -- responsible for coloring the dance pad/floor


