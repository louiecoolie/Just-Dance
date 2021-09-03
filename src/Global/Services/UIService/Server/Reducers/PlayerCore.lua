local ReplicatedStorage = game:GetService("ReplicatedStorage")

--modules
local util = ReplicatedStorage.Vendor
local rodux = require(util:WaitForChild("Rodux"))

local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

return rodux.createReducer({
    Profiles = {};
},{
    Points = function(state, action)
        local newState = copy(state)
        

        newState.Profiles[action.key].points = action.value
        
        return newState
    end,
    Fame = function(state, action)

        local newState = copy(state)

        print(state)

        if not(newState.Profiles[action.key].fame) then
            newState.Profiles[action.key].fame = 0
        end
        
        newState.Profiles[action.key].fame = newState.Profiles[action.key].fame + newState.Profiles[action.key].points
        newState.Profiles[action.key].points = 0;

        return newState
    end,
    Profile = function(state, action)
        local newState = copy(state) 

        newState.Profiles[action.key] = action.data
        
        return newState
    end,

    

})
