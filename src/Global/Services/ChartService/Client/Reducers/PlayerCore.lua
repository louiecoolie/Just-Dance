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
    Theme = {
        Current = "darkTheme"
    };
    Active = false;
},{
    Toggle = function(state, action)
        local newState = copy(state)
        

        newState.Active = action.value
        
        return newState
    end,

    

})
