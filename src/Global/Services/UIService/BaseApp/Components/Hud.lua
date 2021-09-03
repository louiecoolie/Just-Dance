

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

--modules
local util = ReplicatedStorage.Vendor
local roactRodux = require(util:WaitForChild("Roact-Rodux"))
local roact = require(util:WaitForChild("Roact"))
--animation modules
local flipper = require(util:WaitForChild("Flipper"))
local spring = flipper.Spring


local Hud = roact.Component:extend("Hud")

--animations

local TWEEN_IN_SPRING = {
    frequency = 5,
    dampingRatio = 1
}

local function mapStateToProps(state)
    return {
        points = state.playerHandler.Profile.points;
        fame = state.playerHandler.Profile.fame;
        active = state.playerHandler.Active;
    }
end

local function mapDispatchToProps(dispatch)
    return {

    }
end

-- game methods


-- component methods



function Hud:init()
    self.visualizer = roact.createRef()
end

function Hud:render()
   
    local theme = self.props.theme;



    return roact.createElement("Frame",{
        Size = UDim2.fromScale(1,1),
        BackgroundTransparency = 1,
    },{
        points = roact.createElement("TextLabel",{
            Size = UDim2.fromScale(0.2,0.05);
            Position = UDim2.fromScale(0.4,0.1);
            BackgroundTransparency = 0;
            BackgroundColor3 = theme.background;
            Text = self.props.active and self.props.points or "Get to the Dance Floor!";
            Font = theme.font;
            TextSize = 16;
            TextColor3 = theme.text;
            ZIndex = 2;
        },{
            corner = roact.createElement("UICorner",{
                CornerRadius = UDim.new(1,0);
            });
        });
        fame =  roact.createElement("TextLabel",{
            Size = UDim2.fromScale(0.2,0.05);
            Position = UDim2.fromScale(0,0.4);
            BackgroundTransparency = 0;
            BackgroundColor3 = theme.background;
            Text = self.props.fame and ("Fame: "..self.props.fame) or "Fame: 0";
            Font = theme.font;
            TextSize = 16;
            TextColor3 = theme.text;
            ZIndex = 2;
        },{
            corner = roact.createElement("UICorner",{
                CornerRadius = UDim.new(1,0);
            });
        });


    })

end

function Hud:didMount()

end

function Hud:willUnmount()


end

return roactRodux.connect(mapStateToProps, mapDispatchToProps)(Hud)





