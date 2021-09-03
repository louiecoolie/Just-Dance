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
    Profile = {
        points = 0;
        fame = 0;
    };
    Theme = {
        Current = "darkTheme"
    };
    Active = false;
},{
    Points = function(state, action)
        local newState = copy(state)
        
      
        newState.Profile.points = action.value
        
        return newState
    end,
    Fame = function(state, action)

        local newState = copy(state)

        print("got dispatch")
        if not(newState.Profile.fame) then
            newState.Profile.fame = 0
        end
        newState.Profile.fame = newState.Profile.fame + newState.Profile.points
        newState.Profile.points = 0;

        return newState
    end,
    Profile = function(state, action)
        local newState = copy(state) 

        newState.Profile = action.data
        
        return newState
    end,
    Toggle = function(state, action)
        print(action)
        local newState = copy(state)
        

        newState.Active = action.value
        
        return newState
    end,


    

})
