

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
        appTheme = state.playerHandler.Theme.Current; 
        visible = state.playerHandler.Active
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
        Size = UDim2.fromScale(1,1);
        BackgroundTransparency = 1;
    },{ 
        mainCircle = roact.createElement("Frame",{
            Size = UDim2.fromScale(0.2,0.2);
            Position = UDim2.fromScale(0.4,0.4);
            BackgroundTransparency = 0.8;
            BackgroundColor3 = theme.background;
            SizeConstraint = Enum.SizeConstraint.RelativeXX;
            Visible = self.props.visible;
            ZIndex = 2;
        },{
            corner = roact.createElement("UICorner",{
                CornerRadius = UDim.new(1,0);
            });
            layout = roact.createElement("UIListLayout",{
                FillDirection = 0;
                HorizontalAlignment = 0;
                VerticalAlignment = 0;
            });
            subCircle = roact.createElement("Frame",{
                Size = UDim2.fromScale(1,1);
                BackgroundTransparency = 0.9;
                BackgroundColor3 = theme.section;
                SizeConstraint = Enum.SizeConstraint.RelativeXX;
                [roact.Ref] = self.visualizer
            },{
                corner = roact.createElement("UICorner",{
                    CornerRadius = UDim.new(1,0);
                });
            });

        });
        targetCircle = roact.createElement("Frame",{
            Size = UDim2.fromScale(0.05,0.05);
            Position = UDim2.fromScale(.475,.525);
            BackgroundTransparency = 0.2;
            BackgroundColor3 = theme.section;
            Visible = self.props.visible;
            ZIndex = 1;
            SizeConstraint = Enum.SizeConstraint.RelativeXX;
        },{
            corner = roact.createElement("UICorner",{
                CornerRadius = UDim.new(1,0);
            });
        })
    })

end

function Hud:didMount()
    self.connection = RunService.Heartbeat:Connect(function()
        if game:GetService("SoundService"):FindFirstChild("Sound").isPlaying then
            local sound =  game:GetService("SoundService"):FindFirstChild("Sound")
            self.visualizer:getValue().Size = UDim2.fromScale(1+(sound.PlaybackLoudness/500), 1+(sound.PlaybackLoudness/500))
   
        end
    
    end)
end

function Hud:willUnmount()


end

return roactRodux.connect(mapStateToProps, mapDispatchToProps)(Hud)





