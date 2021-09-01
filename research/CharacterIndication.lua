
local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Roact = require(ReplicatedStorage:WaitForChild("Roact"))
local Otter = require(ReplicatedStorage:WaitForChild("Otter"))
local Events
local Modules


local PlayerGui = Players.LocalPlayer.PlayerGui

local Interface = Roact.Component:extend("CharacterStatus")

local componentHandle
local tickValue = 1
local connections = {}

local circle_spring = {
    dampingRatio = 0.01;
    frequency = 0.0005;
}


function Interface:init()
    self.tickCount, self.updateTickCount = Roact.createBinding()
end

function Interface:render()
    return Roact.createElement("ScreenGui", {
        IgnoreGuiInset = true
    },{
        Container = Roact.createElement("Frame",{
            Size = UDim2.new(0.1,0,0.1,0),
            Position = UDim2.new(0.1, 0, 0.1,0)
        },{
            Text = Roact.createElement("TextLabel",{
                Size = UDim2.new(1,0,1,0),
                Position = UDim2.new(0,0,0,0),
                Text = self.tickCount
            })
        })
    })
end

function Interface:didMount()
    connections[#connections+1] = game:GetService("RunService").Heartbeat:Connect(function()

        self.updateTickCount(tickValue)
    
    end)


end

function Interface:willUnmount()
  --  self.background:getValue():Destroy()
  --  self.title:getValue():Destroy()

end


function module.init(modules, events)
    print("Launching Interface")
    Modules = modules
    Events = events

    componentHandle = Roact.mount(Roact.createElement(Interface), PlayerGui, "Character Indication")
end

function module.update(value)
    tickValue = value
end

function module.stop()
    print("Stopping Interface")
    if componentHandle then  

        componentHandle = nil
    end

    for k, v in pairs(connections) do
        if v then
            v:Disconnect()
        end
    end

end




return module