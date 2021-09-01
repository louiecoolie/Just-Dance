local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- external stuff
local gameShared = ReplicatedStorage:WaitForChild("GameShared")
local GuiService = game:GetService("GuiService")
local util = gameShared:WaitForChild("Util")

--modules
local roactRodux = require(util:WaitForChild("Roact-Rodux"))
local roact = require(util:WaitForChild("Roact"))
--animation modules
local flipper = require(util:WaitForChild("Flipper"))
local roactFlipper = require(util:WaitForChild("Roact-Flipper"))
local spring = flipper.Spring

local Topbar = roact.Component:extend("Topbar")

--animations

local TWEEN_IN_SPRING = {
    frequency = 5,
    dampingRatio = 1
}

-- rodux methods

local function mapStateToProps(state)
    return {
        open = state.playerHandler.Lobby.currentOpen;
        loadout = state.playerHandler.Loadout;
        serverType = state.playerHandler.ServerType;
        appTheme = state.playerHandler.Theme.Current; 
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
    }
end

-- component methods

local function createButton(self, theme, props)--open, theme, Name, Position, Dispatch, Size)
    local children = {}
    children["UIText"] = roact.createElement("UITextSizeConstraint", {
        MaxTextSize = 24;
    })
    if props.open ==  props.Name then
        return roact.createElement("TextButton",{
            Text = props.Name;
            Font = Enum.Font.GothamBlack;
            BackgroundTransparency = 0;
            BackgroundColor3 = theme.text;
           -- TextSize = 24;
            TextScaled = true;
            LayoutOrder = props.Order;
            TextColor3 = theme.background;
            BorderSizePixel = 0;
            ZIndex = 20;
            Size = props.Size or UDim2.fromScale(0.2,1);
            Position = props.Position;
            [roact.Event.Activated] = function(obj)
                props.Dispatch(obj)
            end;

        },
            children
        )
    else
        return roact.createElement("TextButton",{
            Text = props.Name;
            Font = Enum.Font.GothamBlack;
            BackgroundTransparency = 1;
            ZIndex = 20;
          --  TextSize = 24;
            TextScaled = true;
            LayoutOrder = props.Order;
            TextColor3 = theme.text;
            Size = props.Size or UDim2.fromScale(0.15,1);
            Position = props.Position;
            [roact.Event.Activated] = function(obj)
       
                self.motor:setGoal(spring.new(0, TWEEN_IN_SPRING))
               
                wait(0.1)
                props.Dispatch(obj)
            end;
            [roact.Event.MouseEnter] = function(obj)
                obj.TextColor3 = theme.border;
            end;
            [roact.Event.MouseLeave] = function(obj)
                obj.TextColor3 = theme.text;
            end;
        },
            children
        )

    end

end

function Topbar:init()
	self.motor = flipper.SingleMotor.new(1)

	local binding, setBinding = roact.createBinding(self.motor:getValue())
	self.binding = binding

	self.motor:onStep(setBinding)
    self.motor:onComplete(function()
        self.motor:setGoal(spring.new(1, TWEEN_IN_SPRING))
    end)

end

function Topbar:render()

    local theme = self.props.theme
    local open = self.props.open


    if game.PlaceId == 7175796352 then -- if lobby place then
        return roact.createElement("Frame",{
            Size = UDim2.fromScale(1,0.07);
            ZIndex = 20;
            BackgroundColor3 = theme.section;
            BorderSizePixel = 0;
            BackgroundTransparency = 0.1;
        },{
            Logo = roact.createElement("Frame",{
                Size = UDim2.fromScale(0.25, 1);
                Position = UDim2.fromScale(0.05,0);
                ZIndex = 20;
                BackgroundTransparency = 1;
            },{
                Text = roact.createElement("TextLabel",{
                    Font = Enum.Font.GothamBlack;
                    --TextSize = 48;
                    TextScaled = true;
                    ZIndex = 20;
                    TextColor3 = theme.text;
                    Text = "ATTRITION";
                    Size = UDim2.fromScale(1,0.7);
                    Position = UDim2.fromScale(0,0.15);
                    BackgroundTransparency = 1;
                });
                TopLine = roact.createElement("Frame",{
                    Size = UDim2.fromScale(1,0.04);
                    ZIndex = 20;
                    BackgroundColor3 = theme.text;
                    BorderSizePixel = 0;
                    Position = UDim2.fromScale(0,0.1);
                });
                BottomLine = roact.createElement("Frame",{
                    Size = UDim2.fromScale(1,0.04);
                    BackgroundColor3 = theme.text;
                    ZIndex = 20;
                    BorderSizePixel = 0;
                    Position = UDim2.fromScale(0,0.84);
                })
            });
            Container = roact.createElement("Frame",{
                Size = UDim2.fromScale(0.7, 1);
                Position = UDim2.fromScale(0.3,0);
                BackgroundTransparency = 1;
            },{
                Layout = roact.createElement("UIListLayout",{
                    FillDirection = 0;
                    HorizontalAlignment = 2;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    Padding = UDim.new(0.01,0);
                });
                Play = (function()
                    if self.props.serverType == "VIP" then
                        return createButton(self, theme, {
                            open = open, 
                            Name = "VIP",
                            Order = 1;
                            Position = UDim2.fromScale(0.40,0),
                            Dispatch =  function(obj) self.props.lobbyToggle(obj.Text) end,
                        });
                    else
                        return createButton(self, theme, {
                            open = open, 
                            Name = "PLAY",
                            Order = 1;
                            Position = UDim2.fromScale(0.40,0),
                            Dispatch =  function(obj) self.props.lobbyToggle(obj.Text) end,
                        });
                    end
                end)();
                Servers = (function()
                    if self.props.serverType == "VIP" then
                        return createButton(self, theme, {
                            open = open, 
                            Name = "SOCIAL",
                            Order = 2;
                            Position = UDim2.fromScale(0.50,0),
                            Dispatch =  function(obj) self.props.lobbyToggle(obj.Text) end,
                        });
                
                    else
                        return createButton(self, theme, {
                            open = open, 
                            Name = "SERVERS",
                            Order = 2;
                            Position = UDim2.fromScale(0.50,0),
                            Dispatch =  function(obj) self.props.lobbyToggle(obj.Text) end,
                        });
            
                    end
                end)();
                Loadouts = createButton(self, theme, {
                    open = open, 
                    Name = "LOADOUTS",
                    Position = UDim2.fromScale(0.625,0),
                    Order = 3;
                    Dispatch =  function(obj) 
                        self.props.lobbyToggle(obj.Text) 
                        self.props.loadout:Enable(self.props.appTheme)
                        game.Players.LocalPlayer.PlayerGui.LoadoutApp.Exit.Visible = false
                    end,
                });
                Store = createButton(self, theme, {
                    open = open, 
                    Name = "STORE",
                    Order = 4;
                    Position = UDim2.fromScale(0.745,0),
                    Dispatch =  function(obj) self.props.lobbyToggle(obj.Text) end,
                });

                Settings = createButton(self, theme, {
                    open = open, 
                    Name = "SETTINGS",
                    Order = 5;
                    Position = UDim2.fromScale(0.85,0),
                    Dispatch =  function(obj) self.props.lobbyToggle(obj.Text) end,
                });
            })
        
        })
    else


        return roact.createElement("Frame",{
            Size = UDim2.fromScale(1,0.07);
            ZIndex = 20;
            BackgroundColor3 = theme.section;
            BorderSizePixel = 0;
 
        },{
            Logo = roact.createElement("Frame",{
                Size = UDim2.fromScale(0.25, 1);
                ZIndex = 20;
                Position = UDim2.fromScale(0.05,0);
                BackgroundTransparency = 1;
            },{
                Text = roact.createElement("TextLabel",{
                    Font = Enum.Font.GothamBlack;
                    --TextSize = 48;
                    TextScaled = true;
                    TextColor3 = theme.text;
                    Text = "ATTRITION";
                    ZIndex = 20;
                    Size = UDim2.fromScale(1,0.7);
                    Position = UDim2.fromScale(0,0.15);
                    BackgroundTransparency = 1;
                });
                TopLine = roact.createElement("Frame",{
                    Size = UDim2.fromScale(1,0.04);
                    BackgroundColor3 = theme.text;
                    ZIndex = 20;
                    BorderSizePixel = 0;
                    Position = UDim2.fromScale(0,0.1);
                });
                BottomLine = roact.createElement("Frame",{
                    Size = UDim2.fromScale(1,0.04);
                    BackgroundColor3 = theme.text;
                    ZIndex = 20;
                    BorderSizePixel = 0;
                    Position = UDim2.fromScale(0,0.84);
                })
            });
            Container = roact.createElement("Frame",{
                Size = UDim2.fromScale(0.7, 1);
                Position = UDim2.fromScale(0.3,0);
                BackgroundTransparency = 1;
            },{
                Layout = roact.createElement("UIListLayout",{
                    FillDirection = 0;
                    HorizontalAlignment = 2;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    Padding = UDim.new(0.01,0);
                });
                
                Play = (function()
    
                    if self.props.serverType == "Server" or  self.props.serverType == "VIPServer" then
                        return createButton(self, theme, {
                            open = open, 
                            Name = "DEPLOY",
                            Order = 1;
                            Position = UDim2.fromScale(0.35,0),
                            Dispatch =  function(obj) self.props.lobbyToggle(obj.Text) end,
                        });
                    end
                end)();
                Loadouts = createButton(self, theme, {
                    open = open, 
                    Name = "LOADOUTS",
                    Order = 2,
                    Position = UDim2.fromScale(0.46,0),
                    Dispatch = function(obj) 
                        self.props.lobbyToggle(obj.Text)
                        self.props.loadout:Enable(self.props.appTheme)
                        if game.Players.LocalPlayer.PlayerGui.LoadoutApp then
                            game.Players.LocalPlayer.PlayerGui.LoadoutApp.Exit.Visible = false
                        end
                    end;
                });
                Store = createButton(self, theme, {
                    open = open, 
                    Name = "STORE",
                    Order = 3,
                    Position = UDim2.fromScale(0.57,0),
                    Dispatch =  function(obj) self.props.lobbyToggle(obj.Text) end,
                });
                Settings = createButton(self, theme, {
                    open = open, 
                    Name = "SETTINGS",
                    Order = 4,
                    Position = UDim2.fromScale(0.68,0),
                    Dispatch =  function(obj) self.props.lobbyToggle(obj.Text) end,
                });
                Return = createButton(self, theme, {
                    open = open, 
                    Name = "RETURN MAIN MENU",
                    Order = 5;
                    Position = UDim2.fromScale(0.78,0),
                    Size = UDim2.fromScale(0.2, 1);
                    Dispatch =  function(obj) self.props.lobbyToggle(obj.Text) end,
                });
            })
        })
    end

    

end



return roactRodux.connect(mapStateToProps, mapDispatchToProps)(Topbar)
