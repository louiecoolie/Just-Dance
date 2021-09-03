

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


local Button = roact.Component:extend("Button")

--animations

local TWEEN_IN_SPRING = {
    frequency = 5,
    dampingRatio = 1
}

local function mapStateToProps(state)
    return {

        appTheme = state.playerHandler.Theme.Current; 
        visible = state.playerHandler.Active;
    }
end

local function mapDispatchToProps(dispatch)
    return {
        score = function(type)
            dispatch({
                type = "Result";
                value = type;
            })
            
        end;
    }
end

-- game methods


-- component methods



function Button:init()
    self.visualizer = roact.createRef()
    self.hud = game.Players.LocalPlayer.PlayerGui.BaseApp.Hud.Position
end

function Button:render()
   
    --local theme = self.props.theme;



    return roact.createElement("ScreenGui",{

        },{
            roact.createElement("ImageButton",{
            Size = UDim2.fromScale(0.05,0.05);
            Position = UDim2.fromScale(0.475, 0.2);

            BackgroundColor3 =  Color3.fromRGB(135, 200, 142);
            SizeConstraint = Enum.SizeConstraint.RelativeXX;
            Visible = self.props.visible;
            ZIndex = 4;
            [roact.Ref] = self.visualizer;
            [roact.Event.Activated] = function(obj)
                obj.Visible = false;
                self.props.update:FireServer({
                    points = 1
                })

                self.props.score("hit")
                self.props.unmount()

            end;
        },{
            corner = roact.createElement("UICorner",{
                CornerRadius = UDim.new(1,0);
            });
        })
    })

end

function Button:didMount()

    self.thread = RunService.RenderStepped:Connect(function(dt)
        local button = self.visualizer:getValue()

        button.Position = UDim2.fromScale(button.Position.X.Scale,( button.Position.Y.Scale + 0.005))
        if button.Position.Y.Scale > 0.6 then
  
            self.props.update:FireServer({
                points = -1
            })
            self.props.score("miss")
            self.props.unmount()
        end


    end)
end

function Button:willUnmount()
    pcall(self.thread.Disconnect, self.thread)

end

return roactRodux.connect(mapStateToProps, mapDispatchToProps)(Button)





