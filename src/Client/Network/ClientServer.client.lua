-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage");


-- systems
local UIService = require(ReplicatedStorage.Services.UIService)()
local ChartService = require(ReplicatedStorage.Services.ChartService)()


ChartService:LoadApp(game.Players.LocalPlayer.PlayerGui)
 