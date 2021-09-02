-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage");


-- systems
local UIService = require(ReplicatedStorage.Services.UIService)()
local ChartService = require(ReplicatedStorage.Services.ChartService)()
local MarketService = require(ServerStorage.Services.MarketService)()
