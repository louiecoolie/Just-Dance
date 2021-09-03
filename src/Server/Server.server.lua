-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage");

--networker
local Binding = Instance.new("BindableEvent", ReplicatedStorage.Events) -- this will be used between services.
Binding.Name = "Binding"

-- systems
local UIService = require(ReplicatedStorage.Services.UIService)()
local ChartService = require(ReplicatedStorage.Services.ChartService)()
local MarketService = require(ServerStorage.Services.MarketService)()


