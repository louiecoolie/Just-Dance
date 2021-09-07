

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
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
        visible = state.playerHandler.Active;
        dancing = state.playerHandler.Dance;
    }
end

local function mapDispatchToProps(dispatch)
    return {
        danceToggle = function(toggle)
            dispatch({
                type = "ToggleDance";
                value = toggle;
            })


        end
    }
end

-- game methods


-- component methods



function Hud:init()
    self.visualizer = roact.createRef()
    self.deactivatedMap = {
        A = "rbxassetid://6961097413";
        S = "rbxassetid://6961098686";
        W = "rbxassetid://6961098212";
        D = "rbxassetid://7427421504";
    }
    self.imageMap = {
        A = "rbxassetid://6952023125";
        S = "rbxassetid://6952020892";
        W = "rbxassetid://6952023839";
        D = "rbxassetid://6952024610";
    }
    self.arrowMap = {
        A = roact.createRef();
        S = roact.createRef();
        W = roact.createRef();
        D = roact.createRef();

    }
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
        help1 = roact.createElement("TextLabel",{
            Font = theme.font;
           -- TextColor3 = theme.text;
            TextSize = 16;
            Visible = self.props.visible;
            Position = UDim2.fromScale(0.7,0.4);
            Size = UDim2.fromScale(0.2,0.1);
            BackgroundTransparency = 1;
            Text = "Use WASD to Dance or Press on the Arrows!";
        });
        breakButton = roact.createElement("TextButton", {
            Size = UDim2.fromScale(0.1,0.1);
            Position = UDim2.fromScale(0.7,0.2);
            BackgroundColor3 = theme.background;
            Text = self.props.dancing and "Dancing: Enabled" or "Dancing: Disabled";
            Visible = self.props.visible;
            TextSize = 16;
            TextColor3 = theme.text;
            Font = theme.font;
            ZIndex = 2;
            [roact.Event.Activated] = function(obj)
                self.props.danceToggle(not(self.props.dancing))


            end
        },{
            corner = roact.createElement("UICorner",{
                CornerRadius = UDim.new(1,0);
            });
        });
        help2 = roact.createElement("TextLabel",{
            Font = theme.font;
           -- TextColor3 = theme.text;
            TextSize = 16;
            Visible = self.props.visible;
            Position = UDim2.fromScale(0.7,0.5);
            Size = UDim2.fromScale(0.2,0.1);
            BackgroundTransparency = 1;
            Text = "Jump to start or stop dancing!!";
        });
        a = roact.createElement("ImageLabel",{
            Size = UDim2.fromScale(0.05,0.05);
            Position = UDim2.fromScale(0.3925, 0.525);
            BackgroundTransparency = 0.5;
            Image = self.deactivatedMap["A"];
            BackgroundColor3 = Color3.fromRGB(244, 244, 244),
            Visible = self.props.visible;
            ZIndex = 1;
            SizeConstraint = Enum.SizeConstraint.RelativeXX;
            [roact.Ref] = self.arrowMap["A"]
        },{
            corner = roact.createElement("UICorner",{
                CornerRadius = UDim.new(1,0);
            });
        });
        s = roact.createElement("ImageLabel",{
            Size = UDim2.fromScale(0.05,0.05);
            Position = UDim2.fromScale(0.4475, 0.525);
            BackgroundTransparency = 0.5;
            Image = self.deactivatedMap["S"];
            BackgroundColor3 = Color3.fromRGB(244, 244, 244),
            Visible = self.props.visible;
            ZIndex = 1;
            SizeConstraint = Enum.SizeConstraint.RelativeXX;
            [roact.Ref] = self.arrowMap["S"]
        },{
            corner = roact.createElement("UICorner",{
                CornerRadius = UDim.new(1,0);
            });
        });
        w = roact.createElement("ImageLabel",{
            Size = UDim2.fromScale(0.05,0.05);
            Position = UDim2.fromScale(.5025,.525);
            BackgroundTransparency = 0.5;
            Image = self.deactivatedMap["W"];
        
            BackgroundColor3 = Color3.fromRGB(244, 244, 244),
            Visible = self.props.visible;
            ZIndex = 1;
            SizeConstraint = Enum.SizeConstraint.RelativeXX;
            [roact.Ref] = self.arrowMap["W"]
        },{
            corner = roact.createElement("UICorner",{
                CornerRadius = UDim.new(1,0);
            });
        });
        d = roact.createElement("ImageLabel",{
            Size = UDim2.fromScale(0.05,0.05);
            Position = UDim2.fromScale(0.5575, 0.525);
            BackgroundTransparency = 0.5;
            Image = self.deactivatedMap["D"];
         
            BackgroundColor3 = Color3.fromRGB(244, 244, 244),
            Visible = self.props.visible;
            ZIndex = 1;
            SizeConstraint = Enum.SizeConstraint.RelativeXX;
            [roact.Ref] = self.arrowMap["D"]
        },{
            corner = roact.createElement("UICorner",{
                CornerRadius = UDim.new(1,0);
            });
        });
    })

end

function Hud:didMount()
    self.connection = RunService.Heartbeat:Connect(function()
        if game:GetService("SoundService"):FindFirstChild("Sound").isPlaying then
            local sound =  game:GetService("SoundService"):FindFirstChild("Sound")
            self.visualizer:getValue().Size = UDim2.fromScale(1+(sound.PlaybackLoudness/500), 1+(sound.PlaybackLoudness/500))
   
        end
    
    end)

    self.inputBegin = UserInputService.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.Keyboard then

                    
            if self.props.dancing then
                if self.props.visible then
                    local gotNote = false
                    

                    for _, item in pairs(game.Players.LocalPlayer.PlayerGui:GetChildren()) do
                        if item.name == "button" then
                            local position = item.container.button.Position.Y.Scale
                            if  not(position > 0.530) and not(position < 0.46) then
                        
                                gotNote = true
                            end
                        end
                    end

                    if gotNote == false then
  
                    
                        self.props.update:FireServer({
                            points = -1
                        })
                        local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            
                        if humanoid then
                            -- need to use animation object for server access
                            local animator = humanoid:FindFirstChildOfClass("Animator")
                            local animation = Instance.new("Animation");
                            animation.AnimationId = "rbxassetid://7428299815"
                            if animator then
                                local animationTrack = animator:LoadAnimation(animation)
                                animationTrack:Play()
                        
                                self._animationTrack = animationTrack
                            end
                        end
                    end
                end
            end

            if self.imageMap[input.KeyCode.Name] then
                


                if self.arrowMap[input.KeyCode.Name] and self.arrowMap[input.KeyCode.Name]:getValue() then
                    self.arrowMap[input.KeyCode.Name]:getValue().Image = self.imageMap[input.KeyCode.Name]

                end
            end
        end


    end)

    self.inputDisconnect = UserInputService.InputEnded:Connect(function(input)
      
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if self.deactivatedMap[input.KeyCode.Name] then
          
                if self.arrowMap[input.KeyCode.Name] and self.arrowMap[input.KeyCode.Name]:getValue() then
                    self.arrowMap[input.KeyCode.Name]:getValue().Image = self.deactivatedMap[input.KeyCode.Name]
                end
            end
        end


    end)


end

function Hud:willUnmount()
    pcall(self.thread.Disconnect, self.thread)
    pcall(self.inputBegin.Disconnect, self.inputBegin)
    pcall(self.inputDisconnect.Disconnect, self.inputDisconnect)


end

return roactRodux.connect(mapStateToProps, mapDispatchToProps)(Hud)





