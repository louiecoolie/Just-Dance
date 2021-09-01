local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local Players = game:GetService("Players")

-- external stuff
local gameShared = ReplicatedStorage:WaitForChild("GameShared")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local util = gameShared:WaitForChild("Util")



--modules
local roactRodux = require(util:WaitForChild("Roact-Rodux"))
local roact = require(util:WaitForChild("Roact"))

--animation modules
local flipper = require(util:WaitForChild("Flipper"))
local roactFlipper = require(util:WaitForChild("Roact-Flipper"))
local spring = flipper.Spring


local Social = roact.Component:extend("Social")

local TWEEN_IN_SPRING = {
    frequency = 5,
    dampingRatio = 1
}


-- rodux methods

local function mapStateToProps(state)
    return {
        inSquad = state.playerHandler.SquadActive;
        tagEnabled = state.playerHandler.TagEnabled;
        open = state.playerHandler.Lobby.currentOpen;
        currentSquad = state.playerHandler.CurrentSquad;
        playSettings = state.playerHandler.PlaySetting;
        loadout = state.playerHandler.Loadout;
        squadSettings = state.playerHandler.SquadSetting;
    }
end

local function mapDispatchToProps(dispatch)
    return {
        cameraToggle = function(fov, position, specular, exposure, camType, lighting)
     
            dispatch({
                type = "ToggleCamera";
                fov = fov;
                position = position;
                specular = specular;
                exposure = exposure;
                camType = camType;
                lighting = lighting;

            })
        end;
        lobbyToggle = function(toggleTo)
            dispatch({
                type = "ToggleLobby";
                toggleTo = toggleTo;
            })
            
        end;
        squadUpdate = function(setting, value)

            dispatch({
                type = "SetSquad",
                setting = setting;
                value = value;
            })
        
    


        end;
        squadGet = function()
            dispatch(function(store)
           
                local getSquad = remotes.GetSquadState:InvokeServer()
            
                store:dispatch({
                    type = "GetSquad";
                    squad = getSquad;
                })
            
            end)
        end;
    }
end


local function createFilterElement(theme, order, setting, value, binding)

    if type(value) == "string" then
        return roact.createElement("Frame",{
            Size = UDim2.fromScale(.95,0.2);
            BackgroundTransparency = 1;
            LayoutOrder = order;
            BorderSizePixel = 0;
        },{
            text = roact.createElement("TextLabel",{
                Size = UDim2.fromScale(0.5,1);
                BackgroundTransparency = 1;
                TextScaled = true;
                TextColor3 = theme.text;
                Font = theme.font;
                Text = setting;
            });
            button = roact.createElement("TextButton",{
                Size = UDim2.fromScale(0.5,1);
                Position = UDim2.fromScale(0.5,0);
                BackgroundTransparency = 1;
                TextScaled = true;
                TextColor3 = theme.text;
                Font = theme.font;
                Text = value;
                [roact.Event.Activated] = binding;
            })
        })
    elseif type(value) == "boolean" then
        if value then
            return roact.createElement("Frame",{
                Size = UDim2.fromScale(.95,0.2);
                BackgroundTransparency = 1;
                LayoutOrder = order;
                BorderSizePixel = 0;
            },{
                text = roact.createElement("TextLabel",{
                    Size = UDim2.fromScale(0.5,1);
                    TextScaled = true;
                    BackgroundTransparency = 1;
                    TextColor3 = theme.text;
                    Font = theme.font;
                    Text = setting;
                });
                frame = roact.createElement("Frame",{
                    Size = UDim2.fromScale(0.5,1);
                    Position = UDim2.fromScale(0.5,0);
                    
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                },{
                    button = roact.createElement("TextButton",{
                        Size = UDim2.fromScale(0.5,0.5);
                        Position = UDim2.fromScale(0.25,0.25);
                        BackgroundColor3 = theme.text;
                        TextColor3 = theme.text;
                        SizeConstraint = Enum.SizeConstraint.RelativeYY;
                        TextScaled = true;
                        Text = "";
                        Font = theme.font;
                        [roact.Event.Activated] = binding;
                    })
                })
            })
        else
            return roact.createElement("Frame",{
                Size = UDim2.fromScale(.95,0.2);
                BackgroundTransparency = 1;
                LayoutOrder = order;
                BorderSizePixel = 0;
            },{
                text = roact.createElement("TextLabel",{
                    Size = UDim2.fromScale(0.5,1);
                    TextScaled = true;
                    BackgroundTransparency = 1;
                    TextColor3 = theme.text;
                    Font = theme.font;
                    Text = setting;
                });
                frame = roact.createElement("Frame",{
                    Size = UDim2.fromScale(0.5,1);
                    Position = UDim2.fromScale(0.5,0);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                },{
                    button = roact.createElement("TextButton",{
                        Size = UDim2.fromScale(0.5,0.5);
                        Position = UDim2.fromScale(0.25,0.25);
                        SizeConstraint = Enum.SizeConstraint.RelativeYY;
                        BackgroundColor3 = theme.section;
                        TextColor3 = theme.text;
                        TextScaled = true;

                        Text = "";
                        Font = theme.font;
                        [roact.Event.Activated] = binding;
                    })
                })
            })
        end

    end


end

local function createFilterOptions(self, theme)

    return roact.createElement("Frame",{
        Size = UDim2.fromScale(1,1);
        BorderSizePixel = 0;
        BackgroundColor3 = theme.section;
        BackgroundTransparency = 1;
    },{
        container = roact.createElement("Frame",{
            Size = UDim2.fromScale(1,1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        },{
            uilist = roact.createElement("UIListLayout",{
                SortOrder = Enum.SortOrder.LayoutOrder;
                Padding = UDim.new(0.02,0);
            });
            setting = roact.createElement("TextLabel",{
                Text = "Squad Settings: ";
                TextSize = 16;
                TextColor3 = theme.text;
                Font = theme.font;
                BackgroundTransparency = 1;
                LayoutOrder = 1;
                Size = UDim2.fromScale(1,0.2);
                BorderSizePixel = 0;
            });
            memberInvite = createFilterElement(theme, 2, "Members can Invite: ", self.props.squadSettings.AllowMemberInvites, 
            function()
                self.props.squadUpdate("AllowMemberInvites", not(self.props.squadSettings.AllowMemberInvites))
            end);
            friendInvite = createFilterElement(theme, 3, "Friends can join: ", self.props.squadSettings.AllowFriendJoins, 
            function()
                self.props.squadUpdate("AllowFriendJoins", not(self.props.squadSettings.AllowFriendJoins))
            end);
        })
    })
end

local function createSquadTag(self, theme)
    if self.props.tagEnabled then
        return roact.createElement("Frame",{
            Size = UDim2.fromScale(1,0.2);
            BackgroundTransparency = 1;
        },{
            label = roact.createElement("TextLabel",{
                TextColor3 = theme.text;
                Size = UDim2.fromScale(0.5,1);
                BackgroundTransparency = 1;
                Text = "Squad Tag";
                Font = theme.font;
                TextSize = 16;
            });
            entry = roact.createElement("TextBox",{
                Size = UDim2.fromScale(0.4,1);
                Position = UDim2.fromScale(0.5,0);
                Text = self.props.squadSettings.SquadTag or "";
                BackgroundColor3 = theme.option;
                BackgroundTransparency = 0.5;
                TextColor3 = theme.text;
                Font = theme.font;
                [roact.Event.FocusLost] = function(obj, enterPressed)
                
                    spawn(function()
                    local response = remotes.RequestSquadCreation:InvokeServer("ValidateTag", obj.text)
					if response then -- if tag good dispatch to client state
                 
                        self.props.squadUpdate("SquadTag", obj.Text)
						--validatedTag = true
						--validatedText = response
					else -- else tell client they did a no no
						--validatedText = ""
						obj.Text = "- invalid -"
					end
                end)
                end,
            })
        })
    else
        return roact.createElement("Frame",{
            Size = UDim2.fromScale(1,0.2);
            BackgroundTransparency = 1;
        },{
            label = roact.createElement("TextLabel",{
                TextColor3 = theme.text;
                Size = UDim2.fromScale(0.5,1);
                BackgroundTransparency = 1;
                Text = "Squad Tag";
                Font = theme.font;
                TextSize = 16;
            });
            entry = roact.createElement("TextButton",{
                Size = UDim2.fromScale(0.4,1);
                Position = UDim2.fromScale(0.5,0);
                Text = "Purchase here";
                TextSize = 16;
                BackgroundColor3 = theme.option;
                BackgroundTransparency = 0.5;
                TextColor3 = theme.text;
                Font = theme.font;
                [roact.Event.Activated] = function()
                    spawn(function()
                        remotes.RequestSquadCreation:InvokeServer("BuyTag") -- could make a rmeote event but reusing remote function
                    end)
                end,
            })
        })
    end

end



local function createButton(open, theme, Name, Position, Size, Dispatch)
    if open == Name then
        return roact.createElement("TextButton",{
            Text = Name;
            Font = Enum.Font.GothamBlack;
            BackgroundTransparency = 0;
            BackgroundColor3 = theme.text;
            TextSize = 24;
            TextColor3 = theme.background;
            BorderSizePixel = 0;
            Size = Size;
            Position = Position;
            [roact.Event.Activated] = Dispatch;
        })
    else
        return roact.createElement("TextButton",{
            Text = Name;
            Font = Enum.Font.GothamBlack;
            BackgroundTransparency = 1;
            TextSize = 24;
            TextColor3 = theme.text;
            Size = Size;
            Position = Position;
            [roact.Event.Activated] = Dispatch;
        })

    end

end

-- build component



function friendLabel(self, theme, name, desc, id, squadId)

    if desc == "Attrition: In Main Menu" then
        if self.props.currentSquad then
            return roact.createElement("Frame",{
                Size = UDim2.fromScale(1,0.1);
                BackgroundColor3 = theme.text;
                BackgroundTransparency = 0.3;
                BorderSizePixel = 0;
            },{
                description = roact.createElement("TextLabel",{
                    BackgroundTransparency = 1;
                    Size = UDim2.fromScale(0.4,0.5);
                    Position = UDim2.fromScale(0.3,0.5);
                    Text = desc;
                    TextScaled = true;
                    Font = Enum.Font.GothamBlack;
                    TextColor3 = theme.background
                });
                buttonInvite = roact.createElement("TextButton",{
                    BackgroundTransparency = 0;
                    Size = UDim2.fromScale(0.2,0.45);
                    BackgroundColor3 = Color3.fromRGB(0,200,0);
                    Position = UDim2.fromScale(0.75,0.45);
                    Text = "Invite";
                    TextSize = 15;
                    Font = Enum.Font.GothamBlack;
                    TextColor3 = theme.text;
                    [roact.Event.Activated] = function(obj)
                        if (self.props.currentSquad.Leader == game.Players.LocalPlayer.Name) or self.props.currentSquad.AllowMemberInvites then
                            remotes.RequestSquadInvite:FireServer(self.state.friendsId[name])
                            spawn(function()
                                obj.Text = "Invite sent!"
                                wait(1)
                                obj.Text = "Sent"

                            end)
      
                        end

                    end;
                },{
                    corner = roact.createElement("UICorner")
                });
                name = roact.createElement("TextLabel",{
                    BackgroundTransparency = 1;
                    Size = UDim2.fromScale(0.7,0.5);
                    Position = UDim2.fromScale(0.3,0);
                    Text = name;
                    TextSize = 20;
                    Font = Enum.Font.GothamBlack;
                    TextColor3 = theme.background
                });
                pfp = roact.createElement("ImageLabel",{
                    Size = UDim2.fromScale(0.3,1);
                    ScaleType = Enum.ScaleType.Fit;
                    Image = self.state.friendsPfp[name];
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                });
                border = roact.createElement("Frame",{
                    Size = UDim2.fromScale(1,0.01);
                    Position = UDim2.fromScale(0,0.99);
                    BorderSizePixel = 0;
                    BackgroundColor3 = theme.background;
                })
            })
        else
            return roact.createElement("Frame",{
                Size = UDim2.fromScale(1,0.1);
                BackgroundColor3 = theme.text;
                BackgroundTransparency = 0.3;
                BorderSizePixel = 0;
            },{
                description = roact.createElement("TextLabel",{
                    BackgroundTransparency = 1;
                    Size = UDim2.fromScale(0.4,0.5);
                    Position = UDim2.fromScale(0.3,0.5);
                    Text = desc;
                    TextScaled = true;
                    Font = Enum.Font.GothamBlack;
                    TextColor3 = theme.background
                });
                name = roact.createElement("TextLabel",{
                    BackgroundTransparency = 1;
                    Size = UDim2.fromScale(0.7,0.5);
                    Position = UDim2.fromScale(0.3,0);
                    Text = name;
                    TextSize = 20;
                    Font = Enum.Font.GothamBlack;
                    TextColor3 = theme.background
                });
                pfp = roact.createElement("ImageLabel",{
                    Size = UDim2.fromScale(0.3,1);
                    ScaleType = Enum.ScaleType.Fit;
                    Image = self.state.friendsPfp[name];
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                });
                border = roact.createElement("Frame",{
                    Size = UDim2.fromScale(1,0.01);
                    Position = UDim2.fromScale(0,0.99);
                    BorderSizePixel = 0;
                    BackgroundColor3 = theme.background;
                })
            })
        end
    elseif (desc == "Attrition: In-game") or (desc == "Attrition: In Open Squad") then
        return roact.createElement("Frame",{
            Size = UDim2.fromScale(1,0.1);
            BackgroundColor3 = theme.text;
            BackgroundTransparency = 0.3;
            BorderSizePixel = 0;
        },{
            description = roact.createElement("TextLabel",{
                BackgroundTransparency = 1;
                Size = UDim2.fromScale(0.4,0.5);
                Position = UDim2.fromScale(0.3,0.5);
                Text = desc;
                TextScaled = true;
                Font = Enum.Font.GothamBlack;
                TextColor3 = theme.background
            });
            buttonInvite = roact.createElement("TextButton",{
                BackgroundTransparency = 0;
                Size = UDim2.fromScale(0.2,0.45);
                BackgroundColor3 = Color3.fromRGB(0,200,0);
                Position = UDim2.fromScale(0.75,0.45);
                Text = "Join";
                TextSize = 15;
                Font = Enum.Font.GothamBlack;
                TextColor3 = theme.text;
                [roact.Event.Activated] = function(obj)
                    if (desc == "Attrition: In-game") then
                        remotes.RequestJoinFriend:FireServer(self.state.friendsId[name])
            
                        obj.Text = "Joining!"
                    elseif (desc == "Attrition: In Open Squad") then
                        spawn(function()
                            obj.Text = "Joining squad!"
                            remotes.RequestJoinFriend:FireServer(id, squadId)
                            wait(.01)
                            obj.Text = "Join"
                        
                        end)
                    end

                end;
            },{
                corner = roact.createElement("UICorner")
            });
            name = roact.createElement("TextLabel",{
                BackgroundTransparency = 1;
                Size = UDim2.fromScale(0.7,0.5);
                Position = UDim2.fromScale(0.3,0);
                Text = name;
                TextSize = 20;
                Font = Enum.Font.GothamBlack;
                TextColor3 = theme.background
            });
            pfp = roact.createElement("ImageLabel",{
                Size = UDim2.fromScale(0.3,1);
                ScaleType = Enum.ScaleType.Fit;
                Image = self.state.friendsPfp[name];
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
            });
            border = roact.createElement("Frame",{
                Size = UDim2.fromScale(1,0.01);
                Position = UDim2.fromScale(0,0.99);
                BorderSizePixel = 0;
                BackgroundColor3 = theme.background;
            })
        })
    else
        return roact.createElement("Frame",{
            Size = UDim2.fromScale(1,0.1);
            BackgroundColor3 = theme.text;
            BackgroundTransparency = 0.3;
            BorderSizePixel = 0;
        },{
            description = roact.createElement("TextLabel",{
                BackgroundTransparency = 1;
                Size = UDim2.fromScale(0.4,0.5);
                Position = UDim2.fromScale(0.3,0.5);
                Text = desc;
                TextScaled = true;
                Font = Enum.Font.GothamBlack;
                TextColor3 = theme.background
            });
            name = roact.createElement("TextLabel",{
                BackgroundTransparency = 1;
                Size = UDim2.fromScale(0.7,0.5);
                Position = UDim2.fromScale(0.3,0);
                Text = name;
                TextSize = 20;
                Font = Enum.Font.GothamBlack;
                TextColor3 = theme.background
            });
            pfp = roact.createElement("ImageLabel",{
                Size = UDim2.fromScale(0.3,1);
                ScaleType = Enum.ScaleType.Fit;
                Image = self.state.friendsPfp[name];
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
            });
            border = roact.createElement("Frame",{
                Size = UDim2.fromScale(1,0.01);
                Position = UDim2.fromScale(0,0.99);
                BorderSizePixel = 0;
                BackgroundColor3 = theme.background;
            })
        })

    end

end

function squadList(self, squad, theme)
    local children = {
        UIList = roact.createElement("UIListLayout");
    }

    if squad then
        for i = 1, #squad.Members do
            local plr = game.Players:GetPlayerByUserId(squad.Members[i][2])
            children[i] = roact.createElement("Frame",{
                Size = UDim2.fromScale(1,0.1);
                BackgroundColor3 = theme.text;
                BackgroundTransparency = 0.3;
                BorderSizePixel = 0;
            },{
                name = roact.createElement("TextLabel",{
                    BackgroundTransparency = 1;
                    Size = UDim2.fromScale(0.7,0.5);
                    Position = UDim2.fromScale(0.3,0);
                    Text = plr.DisplayName;
                    TextSize = 20;
                    Font = Enum.Font.GothamBlack;
                    TextColor3 = theme.background
                });
                pfp = roact.createElement("ImageLabel",{
                    Size = UDim2.fromScale(0.3,1);
                    ScaleType = Enum.ScaleType.Fit;
                    Image = self.state.friendsPfp and self.state.friendsPfp[plr.DisplayName] or "rbxassetid://924320031";
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                });
                border = roact.createElement("Frame",{
                    Size = UDim2.fromScale(1,0.01);
                    Position = UDim2.fromScale(0,0.99);
                    BorderSizePixel = 0;
                    BackgroundColor3 = theme.background;
                })
            })

        end
    end

    return children
end

function friendList(self, friendObjs, theme)
    local children = {
        Ingame = {
            UIList = roact.createElement("UIListLayout")
        };
        Online = {
            UIList = roact.createElement("UIListLayout")
        };
    }
    if friendObjs then
        for _, obj in pairs(friendObjs) do
            if not(obj.Location == "Roblox Website" or  obj.Location == "Playing Another Game") then
                children.Ingame[obj.Name] = friendLabel(self, theme, obj.Name, obj.Location, obj.UserId, obj.SquadId)
            else
                children.Online[obj.Name] = friendLabel(self, theme, obj.Name, obj.Location, obj.UserId, obj.SquadId)           
            end
        end
    end

    return children

end

function Social:init()
    self.connection = nil
    self.inviteRef = roact.createRef()
    
    self.motor = flipper.SingleMotor.new(1)

	local binding, setBinding = roact.createBinding(self.motor:getValue())
	self.binding = binding

	self.motor:onStep(setBinding)
    self.motor:onComplete(function()
        self.motor:setGoal(spring.new(1, TWEEN_IN_SPRING))
    end)
    
    self:setState({
        socialPage = "Squad";
    })

    task.defer(function()-- maybe use task library, maybe.
        local friends = Players.LocalPlayer:GetFriendsOnline()
        local fromServer = remotes.GetFriendsOnline:InvokeServer(friends)
        local pfp = {};
        local userId = {}
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size420x420
        for _, friendObj in pairs(fromServer) do
          
           -- local id = Players:GetUserIdFromNameAsync(friendObj.Name)
            
            local pic, isReady = Players:GetUserThumbnailAsync(friendObj.UserId, thumbType, thumbSize)
            
            userId[friendObj.Name] = friendObj.UserId
            pfp[friendObj.Name] = pic
            

        end

       
        local squadCheck = remotes.GetSquadState:InvokeServer()
    
        local inviteCheck, canSend = pcall(SocialService.CanSendGameInviteAsync, SocialService, Players.LocalPlayer)
    
        self:setState({
            friends = fromServer;
            friendsPfp = pfp;
            friendsId = userId;
            inSquad = squadCheck;
            socialPage = "Squad";
            canInvite = inviteCheck;
        })
  
    end)
end

function Social:render()

    local theme = self.props.theme

    if self.state.socialPage == "Squad" then
        local children = {}

        children["Create Squad"] = roact.createElement("TextButton",{
            Text = self.props.currentSquad and "Leave Squad" or "Create Squad";
            Font = Enum.Font.GothamBlack;
            BackgroundTransparency = 0;
            BackgroundColor3 = theme.text;
            TextSize = 24;
            TextColor3 = theme.background;
            BorderSizePixel = 0;
            Size = UDim2.fromScale(0.8,0.2);
            Position = UDim2.fromScale(0.1,0.7);
            [roact.Event.Activated] = function(obj)
                spawn(function() -- avoiding any kind of yielding spawning new thread
               
                    if not self.props.currentSquad then
                        -- ask to create a squad
                        --self.motor:setGoal(spring.new(0, TWEEN_IN_SPRING)) --enable later when get to lobby scenes
               
                        local canCreateSquad = remotes.RequestSquadCreation:InvokeServer("GetAllowed")
                        if canCreateSquad then
                            local squad = remotes.RequestSquadCreation:InvokeServer("CreateSquad",self.props.squadSettings)
                            
                            self:setState(function()
                                return {
                                    inSquad = squad
                                }
                            end)
                        end

                        --self.motor:setGoal(spring.new(1, TWEEN_IN_SPRING))
               
                    else
                        -- ask to leave squad
                        remotes.RequestSquadLeave:FireServer()
                        obj.Text = "Create Squad"

                        self:setState(function()
                            return {
                                inSquad = false
                            }
                        end)
                     

                    end
                end)
            end;
        })

        children["Fade"] = roact.createElement("Frame",{
            Size = UDim2.fromScale(20,20);
            Position = UDim2.fromScale(-10,-5);
            ZIndex = 9;
            BackgroundColor3 = theme.background;
            BackgroundTransparency = self.binding;
        })

        if not(self.props.currentSquad) then
            children["Options"] = roact.createElement("Frame",{
                Size = UDim2.fromScale(1,0.5);
                BackgroundTransparency = 1;
            },{
                options = createFilterOptions(self, theme)
            })
            children["Tag"] = roact.createElement("Frame",{
                Size = UDim2.fromScale(1,0.2);
                BackgroundTransparency = 1;
                Position = UDim2.fromScale(0, 0.5);
            },{
                tag = createSquadTag(self, theme);
            })
        else
            local squaddies = squadList(self, self.props.currentSquad, theme)
            children["Tag"] = roact.createElement("TextLabel",{
                Size = UDim2.fromScale(1,0.1);
                BackgroundTransparency = 1;
                Text = self.props.currentSquad.Tag or "";
                TextColor3 = theme.text;
                Font = theme.font;
                TextSize = 10;
            })
            children["Squad"] = roact.createElement("ScrollingFrame",{
                Size = UDim2.fromScale(1,0.7);
                Position = UDim2.fromScale(0,0.1);
                BorderSizePixel = 0;
                BackgroundTransparency = 1;
            },
                squaddies
            );
        end

        
 
        return roact.createElement("Frame",{
            Size = UDim2.fromScale(0.255,.6);
            Position = UDim2.fromScale(0.7,0);
            BackgroundColor3 = theme.section;
            BackgroundTransparency = 0.4;
        },{
            SquadButton = createButton(
                self.state.socialPage, 
                theme, 
                "Squad",
                UDim2.fromScale(0,0),
                UDim2.fromScale(0.5,0.1),
                function()
                    self:setState({
                        socialPage = "Squad";
                    })
                end
            );
            InviteFrame = roact.createElement("TextButton",{
                Size = UDim2.fromScale(1,1);
                BackgroundColor3 = theme.background;
                Text = "";
                Visible = false;
                ZIndex = 10;
                [roact.Ref] = self.inviteRef;
            },{
                invite = roact.createElement("TextLabel",{
                    Size = UDim2.fromScale(1,0.2);
                    Text = "You have been invited to squad by ";
                    TextColor3 = theme.text;
                    ZIndex = 11;
                    BackgroundTransparency = 1;
                });
                yes = roact.createElement("TextButton",{
                    Text = "Join";
                    TextColor3 = theme.text;
                    Size = UDim2.fromScale(0.5,0.2);
                    Position = UDim2.fromScale(0,0.2);
                    BackgroundTransparency = 1;
                    ZIndex = 11;
                });
                no = roact.createElement("TextButton",{
                    Text = "Decline";
                    TextColor3 = theme.text;
                    Size = UDim2.fromScale(0.5,0.2);
                    Position = UDim2.fromScale(0.5,0.2);
                    BackgroundTransparency = 1;
                    ZIndex = 11;
                });
            });
            FriendButton = createButton(
                self.state.socialPage, 
                theme, 
                "Friends",
                UDim2.fromScale(0.5,0),
                UDim2.fromScale(0.5,0.1),
                function()
                    self:setState({
                        socialPage = "Friends";
                    })
                end
            );
            Container = roact.createElement("Frame",{
                BackgroundTransparency = 1;
                Size = UDim2.fromScale(1,0.9);
                Position = UDim2.fromScale(0,0.1);
                BorderSizePixel = 0;
            }, children);
        })
    elseif self.state.socialPage == "Friends" then


        local sortedFriends = friendList(self, self.state.friends, theme)
   
        return roact.createElement("Frame",{
            Size = UDim2.fromScale(0.255,.6);
            Position = UDim2.fromScale(0.7,0);
            BackgroundColor3 = theme.section;
            BackgroundTransparency = 0.4;
        },{
            SquadButton = createButton(
                self.state.socialPage, 
                theme, 
                "Squad",
                UDim2.fromScale(0,0),
                UDim2.fromScale(0.5,0.1),
                function()
                    self:setState({
                        socialPage = "Squad";
                    })
                end
            );
            InviteFrame = roact.createElement("TextButton",{
                Size = UDim2.fromScale(1,1);
                BackgroundColor3 = theme.background;
                Text = "";
                Visible = false;
                ZIndex = 10;
                [roact.Ref] = self.inviteRef;
            },{
                invite = roact.createElement("TextLabel",{
                    Size = UDim2.fromScale(1,0.2);
                    Text = "You have been invited to squad by ";
                    TextColor3 = theme.text;
                    ZIndex = 11;
                    BackgroundTransparency = 1;
                });
                yes = roact.createElement("TextButton",{
                    Text = "Join";
                    TextColor3 = theme.text;
                    Size = UDim2.fromScale(0.5,0.2);
                    Position = UDim2.fromScale(0,0.2);
                    BackgroundTransparency = 1;
                    ZIndex = 11;
                });
                no = roact.createElement("TextButton",{
                    Text = "Decline";
                    TextColor3 = theme.text;
                    Size = UDim2.fromScale(0.5,0.2);
                    Position = UDim2.fromScale(0.5,0.2);
                    BackgroundTransparency = 1;
                    ZIndex = 11;
                });
            });
            FriendButton = createButton(
                self.state.socialPage, 
                theme, 
                "Friends",
                UDim2.fromScale(0.5,0),
                UDim2.fromScale(0.5,0.1),
                function()
                    self:setState({
                        socialPage = "Friends";
                    })
                end
            );
            Container = roact.createElement("Frame",{
                BackgroundTransparency = 1;
                Size = UDim2.fromScale(1,0.9);
                Position = UDim2.fromScale(0,0.1);
                BorderSizePixel = 0;
            },{
                Border = roact.createElement("Frame",{
                    Size = UDim2.fromScale(1,0.001);
                    BackgroundColor3 = theme.text;
                    BorderSizePixel = 0;
                });
                IngameLabel = roact.createElement("TextLabel",{
                    Size = UDim2.fromScale(0.5,0.1);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    Text = "In game: ";
                    Font = Enum.Font.GothamBlack;
                    TextSize = 20;
                    TextColor3 = theme.text;
                });
                Refresh = roact.createElement("ImageButton",{
                    Image = "rbxassetid://257125640";
                    Size = UDim2.fromScale(0.2, 0.1);
                    Position = UDim2.fromScale(0.8,0);
                    ScaleType = Enum.ScaleType.Fit;
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    ImageColor3 = theme.text;
                    [roact.Event.Activated] = function()
                        spawn(function()
                            local friends = Players.LocalPlayer:GetFriendsOnline()
                            local fromServer = remotes.GetFriendsOnline:InvokeServer(friends)
                            local pfp = {};
                            local userId = {}
                            local thumbType = Enum.ThumbnailType.HeadShot
                            local thumbSize = Enum.ThumbnailSize.Size420x420
                            for _, friendObj in pairs(fromServer) do
          
                                -- local id = Players:GetUserIdFromNameAsync(friendObj.Name)
                                 
                                 local pic, isReady = Players:GetUserThumbnailAsync(friendObj.UserId, thumbType, thumbSize)
                                 
                                 userId[friendObj.Name] = friendObj.UserId
                                 pfp[friendObj.Name] = pic
                                 
                     
                            end
                            self:setState(function()
                                return {
                                friends = fromServer;
                                friendsPfp = pfp;
                                friendsId = userId
                                }
                            end)
                        end)
                    end;
                });
                ScrollingFrameInGame = roact.createElement("ScrollingFrame",{
                    Size = UDim2.fromScale(1,0.4);
                    Position = UDim2.fromScale(0,0.1);
                    BorderSizePixel = 0;
                    BackgroundTransparency = 1;
                },
                    sortedFriends.Ingame
                );
                OnlineLabel = roact.createElement("TextLabel",{
                    Size = UDim2.fromScale(0.5,0.1);
                    Position = UDim2.fromScale(0,0.5);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    Text = "Online: ";
                    Font = Enum.Font.GothamBlack;
                    TextSize = 20;
                    TextColor3 = theme.text;
                });
                InviteLabel = roact.createElement("TextButton",{
                    Size = UDim2.fromScale(0.4,0.08);
                    Position = UDim2.fromScale(0.55,0.52);
                    BackgroundTransparency = 0.5;
                    BorderSizePixel = 0;
                    Text = "Invite!";
                    Font = Enum.Font.GothamBlack;
                    TextSize = 20;
                    Visible = self.state.canInvite;
                    TextColor3 = theme.text;
                    [roact.Event.Activated] = function(obj)
                        local res, canInvite = pcall(SocialService.PromptGameInvite, SocialService, Players.LocalPlayer)
                                                
                    end;
                });
                ScrollingFrameOnline = roact.createElement("ScrollingFrame",{
                    Size = UDim2.fromScale(1,0.4);
                    Position = UDim2.fromScale(0,0.6);
                    BorderSizePixel = 0;
                    BackgroundTransparency = 1;
                },
                    sortedFriends.Online
                )
            })
 

        })
    end



end

function Social:didMount()
    SocialService.GameInvitePromptClosed:Connect(function(senderPlayer, recipientIds)

        if not self.props.currentSquad then
            -- ask to create a squad
            --self.motor:setGoal(spring.new(0, TWEEN_IN_SPRING)) --enable later when get to lobby scenes
    
            local canCreateSquad = remotes.RequestSquadCreation:InvokeServer("GetAllowed")
            if canCreateSquad then
                print("creating squad")
                local squad = remotes.RequestSquadCreation:InvokeServer("CreateSquad",self.props.squadSettings)
                

                self:setState(function()
                    return {
                        inSquad = squad
                    }
                end)
            end
        end
    end)
    
    remotes.PromptSquadInvite.OnClientInvoke = function(inviteData)

		local menu = self.inviteRef:getValue()
     
		menu.Visible = true
		menu.Text = inviteData.Inviter.." has sent you a squad invite:"
		local buttonClicks = {}
		local function disconnect()
			for i, v in pairs(buttonClicks) do
				v:disconnect()
			end
			buttonClicks = nil
			menu.Visible = false
		end
		local chosen = nil
		buttonClicks["Yes"] = menu.yes.Activated:connect(function()
			chosen = "Yes"
          --  self:setState(function()
          --      return {
          --          inSquad = true
          --      }
            --end)
			disconnect()
		end)
		buttonClicks["No"] = menu.no.Activated:connect(function()
			chosen = "No"
			disconnect()
		end)
		
		repeat
			wait()
		until chosen
		
		return chosen == "Yes" and true or false
	end

end

return roactRodux.connect(mapStateToProps, mapDispatchToProps)(Social)