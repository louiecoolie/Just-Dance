local module = {}

local Events



function module.taunt()
 
    Events.request_action:FireServer("taunt")

end

function module.toy()

    Events.request_action:FireServer("toy")
end

function module.special()

    Events.request_action:FireServer("special")
end


function module.init(events)
    Events = events
end

return module