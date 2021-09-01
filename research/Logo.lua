--[[
    Pipe game will use mouse or tap input to spin a turn wheel to rise water pressure back up to 100%

    Upon completion of the game this component will self destruct and send out completion confirmation back into server and delete
    game binder off the corressponding object in world.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage:WaitForChild("Roact"))
local Otter = require(ReplicatedStorage:WaitForChild("Otter"))

local spring = Otter.spring
local motor = Otter.createSingleMotor

local Players = game:GetService("Players")
local ClientEvents = game:GetService("ReplicatedStorage"):WaitForChild("Events", 60)
local TweenService = game:GetService("TweenService")

local Events = {}
local Connections = {}

for _, event in ipairs(ClientEvents:GetChildren()) do
    ClientEvents:WaitForChild(event.Name, 5)

end

for _, event in ipairs(ClientEvents:GetChildren()) do
	Events[event.Name] = event
end

local PlayerGui = Players.LocalPlayer.PlayerGui

local GameLogo = Roact.Component:extend("Logo")

local game_handle = nil
local game_start = false

local groupMotor

local circle_spring = {
    dampingRatio = 1;
    frequency = 0.005;
}

local Logo = {}

function GameLogo:init()
    self.fade_frame = Roact.createRef()
    self.circle_image = Roact.createRef()
    self.knight_image = Roact.createRef()
    self.finger_image = Roact.createRef()
    self.text_image = Roact.createRef()
end

function GameLogo:render()
    return Roact.createElement("ScreenGui",{
        IgnoreGuiInset = true
    },{
        Background = Roact.createElement("Frame",{
            [Roact.Ref] = self.fade_frame,
            Size = UDim2.new(1,0,1,0),
           -- SizeConstraint = Enum.SizeConstraint.RelativeXX,
            Position = UDim2.new(0, 0, 0, 0),
           -- Image = "rbxassetid://5767212430",
            ZIndex = 1080,
            BorderSizePixel = 0,
            BackgroundColor = BrickColor.new("Really black"),
            Transparency = 0
        }),
        RoundCircle = Roact.createElement("ImageLabel",{
            [Roact.Ref] = self.circle_image,
            Size = UDim2.new(0.35,0,0.35,0),
            SizeConstraint = Enum.SizeConstraint.RelativeXX,
            Position = UDim2.new(0.325,0,0.1,0),
            Image = "rbxassetid://5844954118",
            ZIndex = 1011,
            BorderSizePixel = 0,
            BackgroundTransparency = 1
        }),
        Finger = Roact.createElement("ImageLabel",{
            Size = UDim2.new(0.35,0,0.35,0),
            SizeConstraint = Enum.SizeConstraint.RelativeXX,
            Position = UDim2.new(0.325,0,0.1,0),

            ZIndex = 1020,
            BorderSizePixel = 0,
            BackgroundTransparency = 1
        },{
            Image = Roact.createElement("ImageLabel",{
                [Roact.Ref] = self.finger_image,
                Position = UDim2.new(0.299,0,0.594,0),
                Image = "rbxassetid://5832925518",
                ZIndex = 1030,
                BorderSizePixel = 0,
                Image = "rbxassetid://5832925259",
                BackgroundTransparency = 1,
                Size = UDim2.new(1,0,1,0),
                Position = UDim2.new(2,0,0,0)
            })
        }),
        Knight = Roact.createElement("ImageLabel",{
            [Roact.Ref] = self.knight_image,
            Size = UDim2.new(0.2,0,0.2,0),
            SizeConstraint = Enum.SizeConstraint.RelativeXX,
            Position = UDim2.new(0.4,0,0.248,0),
            Image = "rbxassetid://5832923102",
            ZIndex = 1013,
            BorderSizePixel = 0,
            BackgroundTransparency = 1
        }),
        Shush = Roact.createElement("Frame",{
            Size = UDim2.new(0.4,0,0.1,0),
            SizeConstraint = Enum.SizeConstraint.RelativeXX,
            Position = UDim2.new(0.299,0,0.594,0),
            ZIndex = 1030,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            ClipsDescendants = true
        },{
            Image = Roact.createElement("ImageLabel",{
                [Roact.Ref] = self.text_image,
                Position = UDim2.new(0.299,0,0.594,0),
                Image = "rbxassetid://5832925518",
                ZIndex = 1030,
                BorderSizePixel = 0,
                Image = "rbxassetid://5832925518",
                BackgroundTransparency = 1,
                Size = UDim2.new(1,0,1,0),
                Position = UDim2.new(2,0,0,0)
            })
        }),
    })
end

function GameLogo:didMount()
    --self.fade_frame:getValue().Transparency = 0

    groupMotor = Otter.createGroupMotor({
        transparency = 0,
        rotation = 0,
        text_x = 2,
    })

    groupMotor:setGoal({
        transparency = Otter.spring(1),
        rotation = Otter.spring(2000,circle_spring),
        text_x = Otter.spring(0),

    })

    groupMotor:onStep(function(values)
 
        self.fade_frame:getValue().Transparency = values.transparency
        self.circle_image:getValue().Rotation = values.rotation
        self.text_image:getValue().Position = UDim2.new(values.text_x, 0, 0, 0)
        self.finger_image:getValue().Position = UDim2.new(values.text_x, 0, 0, 0)
        -- position something somewhere
    end)



end

function GameLogo:willUnmount()
    groupMotor:stop()
    --wait(2.1)
end

function Logo.Start()
    game_handle = Roact.mount(Roact.createElement(GameLogo), PlayerGui, "Logo")
end

function Logo.Stop()
    Roact.unmount(game_handle)
end


return Logo