local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- external stuff
local gameShared = ReplicatedStorage:WaitForChild("GameShared")
local util = gameShared:WaitForChild("Util")

--modules
local rodux = require(util:WaitForChild("Rodux"))

return rodux.combineReducers({
    playerHandler = require(script.Reducers.PlayerCore)
})