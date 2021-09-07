

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

    }
end

-- game methods


-- component methods



function Button:init()
    self.visualizer = roact.createRef()
    self.hud = game.Players.LocalPlayer.PlayerGui.BaseApp.Hud.Position
    self.scorable = true;
    self.positionMap = {
        [1] = UDim2.fromScale(0.3925, 0.2);
        [2] = UDim2.fromScale(0.4475, 0.2);
        [3] = UDim2.fromScale(0.5025, 0.2);
        [4] = UDim2.fromScale(0.5575, 0.2);
    };
    self.inputMap = {
        A = 1;
        S = 2;
        W = 3;
        D = 4;
    };
    self.imageMap = {
        [1] = "rbxassetid://6952023125";
        [2] = "rbxassetid://6952020892";
        [3] = "rbxassetid://6952023839";
        [4] = "rbxassetid://6952024610";
    }
    self.danceMap = {
        [1] = "rbxassetid://7427191738";
        [2] = "rbxassetid://7427278837";
        [3] = "rbxassetid://7427282191";
        [4] = "rbxassetid://7427207859";
    }
end

function Button:render()
   
    --local theme = self.props.theme;



    return roact.createElement("ScreenGui",{
        DisplayOrder = 2;
    },{
        container = roact.createElement("Frame",{

            Size = UDim2.fromScale(1,1);
            BackgroundTransparency = 1;
        },{
            button = roact.createElement("ImageButton",{
                Size = UDim2.fromScale(0.05,0.05);
                Position = self.positionMap[self.props.position];
                Image = self.imageMap[self.props.position];
                BackgroundTransparency = 1;
                BackgroundColor3 =  Color3.fromRGB(135, 200, 142);
                SizeConstraint = Enum.SizeConstraint.RelativeXX;
                Visible = self.props.visible;
                ZIndex = 4;
                [roact.Ref] = self.visualizer;
                [roact.Event.Activated] = function(obj)
                    local position = obj.Position.Y.Scale
                    if  not(position > 0.530) and not(position < 0.4) then
                        obj.Visible = false;
                    
                        self.props.update:FireServer({
                            points = 1
                        })

                        local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                      
                        if humanoid then
                            -- need to use animation object for server access
                            local animator = humanoid:FindFirstChildOfClass("Animator")
                            local animation = Instance.new("Animation");
                            animation.AnimationId = self.danceMap[self.props.position]
                            if animator then
                                local animationTrack = animator:LoadAnimation(animation)
                                animationTrack:Play()
                           
                                self._animationTrack = animationTrack
                            end
                        end
                 
                        self.props.unmount()
                    end
                end;
            },{
                corner = roact.createElement("UICorner",{
                    CornerRadius = UDim.new(1,0);
                });
            });

        })
    })

end

function Button:didMount()

    self.thread = RunService.RenderStepped:Connect(function(dt)
        if self.scorable then
            local button = self.visualizer:getValue()
            button.ZIndex = 4;
            button.Position = UDim2.fromScale(button.Position.X.Scale,( button.Position.Y.Scale + 0.005))
            if button.Position.Y.Scale > 0.6 then
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

                self.props.update:FireServer({
                    points = -1
                })
    
                self.props.unmount()
            end
        end

    end)

    self.input = UserInputService.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.Keyboard then
            if self.inputMap[input.KeyCode.Name] then
                local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
          
                    
                if self.props.visible then
                    humanoid.WalkSpeed = 0
                end

                if self.inputMap[input.KeyCode.Name] == self.props.position then
               
                    local position = self.visualizer:getValue().Position.Y.Scale
                    if  not(position > 0.530) and not(position < 0.4) then
                        if self.scorable == true then
                            self.props.update:FireServer({
                                points = 1
                            })
                
                    

                            if humanoid then
                                -- need to use animation object for server access
                                local animator = humanoid:FindFirstChildOfClass("Animator")
                                local animation = Instance.new("Animation");
                                animation.AnimationId = self.danceMap[self.props.position]
                                if animator then
                                    local animationTrack = animator:LoadAnimation(animation)
                                    animationTrack:Play()
                            
                                    self._animationTrack = animationTrack
                                end
                            end

                    
                            self.visualizer:getValue().Visible = false
                            self.scorable = false
                            spawn(function()
                                wait(0.1)
                                self.props.unmount()
                            
                            end)
                        end
                    end
          
                end
            end

            if input.KeyCode.Name == "Space" then
 
                local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
          
                    
        
                humanoid.WalkSpeed = 16
             
            end
        end


    end)
end

function Button:willUnmount()
    pcall(self.thread.Disconnect, self.thread)
    pcall(self.input.Disconnect, self.input)
end

return roactRodux.connect(mapStateToProps, mapDispatchToProps)(Button)





