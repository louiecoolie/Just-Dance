local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- external stuff
local gameShared = ReplicatedStorage:WaitForChild("GameShared")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local util = gameShared:WaitForChild("Util")

--modules
local roactRodux = require(util:WaitForChild("Roact-Rodux"))
local roact = require(util:WaitForChild("Roact"))

--subcomponents
local servers = require(script.Parent.Servers)
local social = require(script.Parent.Social)
local vip = require(script.Parent.Vip)
local settings = require(script.Parent.Settings)
local deploy = require(script.Parent.Deploy)
local shop = require(script.Parent.Shop)

local Page = roact.Component:extend("Page")

-- rodux methods

local function mapStateToProps(state)
    return {
        open = state.playerHandler.Lobby.currentOpen;
        playSettings = state.playerHandler.PlaySetting;
        loadout = state.playerHandler.Loadout;
        serverType = state.playerHandler.ServerType;
        currentSquad = state.playerHandler.CurrentSquad;
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
        filterUpdate = function(setting, value)

            dispatch({
                type = "ChangePlaySetting",
                setting = setting;
                value = value;
            })

        end;
    }
end

-- local functions






--local components

local function createOptionChild(self, theme, section, value, binding)
    return roact.createElement("TextButton",{
        Size = UDim2.fromScale(1,0.33);
        TextSize = 15;
        BackgroundColor3 = theme.text;
        TextColor3 = theme.section;
        ZIndex = 3;
        Text = value;
        [roact.Event.Activated] = function()

            self.props.filterUpdate(section, value)

            self:setState(function()
                return {
                   -- servers = serverList;
                    section = "";
                    options = not(self.state.options);
                }
            end)
            
        end

    })

end

local function createOptionChildren(self, theme, section)
    local children = {
        uilist = roact.createElement("UIListLayout")
    }


    if section == "" then
        return children
    elseif section == "Population" then
        children[1] = createOptionChild(self, theme, section, "Small")
        children[2] = createOptionChild(self, theme, section, "Medium")
        children[3] = createOptionChild(self, theme, section, "Large")
        return children
    elseif section == "PreferredMode" then
        children[1] = createOptionChild(self, theme, section, "Build and Battle")
        children[2] = createOptionChild(self, theme, section, "Free for all")
        children[3] = createOptionChild(self, theme, section, "Any")
        return children
    elseif section == "CustomFilter" then
        children[1] = createOptionChild(self, theme, section, "Official")
        children[2] = createOptionChild(self, theme, section, "Custom")
        children[3] = createOptionChild(self, theme, section, "Any")
        return children
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


function socialComponent(self, theme)
    return roact.createElement(social, {
        theme = theme;
    })


end

function vipComponent(self, theme)
    return roact.createElement(vip, {
        theme = theme;
    })

end
function playComponent(self, theme)
    local children = createOptionChildren(self, theme, self.state.section)
    return roact.createElement("Frame",{
        Size = UDim2.fromScale(1,1);
        BackgroundTransparency = 1;
    },{
        PlayButton = roact.createElement("TextButton",{
            [roact.Ref] = self.playRef;
            Size = UDim2.fromScale(0.255,0.1);
            Position = UDim2.fromScale(0.7,0.65);
            BackgroundTransparency = 0.1;
            BackgroundColor3 = theme.text;
            TextColor3 = theme.background;
            Text = "Play now";
            Font = Enum.Font.GothamBlack;
            TextSize = 30;
            [roact.Event.Activated] = function(obj)
                if self.props.currentSquad then
                    if self.props.currentSquad.Leader == game.Players.LocalPlayer.Name then
                    
                        remotes.RequestMatchmaking:FireServer("QuickMatch", nil, self.props.playSettings, 0)

                        obj.Text = "Searching for Servers..."
                    else
                        spawn(function()
                            obj.Text = "Not squad leader"
                            wait(0.5)
                            obj.Text = "Play now"
                        end)
                    end
                else
                    remotes.RequestMatchmaking:FireServer("QuickMatch", nil, self.props.playSettings, 0)

                    obj.Text = "Searching for Servers..."
                end

            end
        });
        Social = socialComponent(self, theme);
        Options = roact.createElement("Frame",{
            Size = UDim2.fromScale(0.255,0.18);
            Position = UDim2.fromScale(0.7, 0.78);
            BackgroundColor3 = theme.border;
            ZIndex = 2;
            Visible = self.state.options;
            BorderSizePixel = 0;

        },
            children
        );
        CurrentSetting = roact.createElement("Frame",{
            Size = UDim2.fromScale(0.255,0.18);
            Position = UDim2.fromScale(0.7, 0.78);
            BackgroundColor3 = theme.section;
            BorderSizePixel = 0;
        },{
            category = roact.createElement("Frame",{
                Size = UDim2.fromScale(0.5, 1);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
            },{
                uilist = roact.createElement("UIListLayout");
                gamemode = roact.createElement("TextLabel",{
                    Size = UDim2.fromScale(1,0.3);
                    Text = "Gamemode:";
                    TextSize = 16;
                    Font = Enum.Font.GothamBlack;
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    TextColor3 = theme.text;
                });
                server = roact.createElement("TextLabel",{
                    Size = UDim2.fromScale(1,0.3);
                    Text = "Server Type:";
                    TextSize = 16;
                    Font = Enum.Font.GothamBlack;
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    TextColor3 = theme.text;
                });
                population = roact.createElement("TextLabel",{
                    Size = UDim2.fromScale(1,0.3);
                    Text = "Population:";
                    TextSize = 16;
                    Font = Enum.Font.GothamBlack;
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    TextColor3 = theme.text;
                });
            });
            setting = roact.createElement("Frame",{
                Size = UDim2.fromScale(0.5, 1);
                Position = UDim2.fromScale(0.5,0);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
            },{
                uilist = roact.createElement("UIListLayout",{
                    Padding = UDim.new(0,3);
                });
                gamemode = roact.createElement("TextButton",{
                    Size = UDim2.fromScale(1,0.3);
                    Text = self.props.playSettings.PreferredMode;
                    TextSize = 16;
                    Font = Enum.Font.GothamBlack;
                    BackgroundTransparency = 0.5;
                    BorderSizePixel = 2;
                    BorderColor3 = theme.text;
                    TextColor3 = theme.text;
                    [roact.Event.Activated] = function()
                        self:setState(function()
                            return {
                               -- servers = serverList;
                                section = "PreferredMode";
                                options = not(self.state.options);
                            }
                        end)
                    end;
                });
                server = roact.createElement("TextButton",{
                    Size = UDim2.fromScale(1,0.3);
                    Text = self.props.playSettings.CustomFilter;
                    TextSize = 16;
                    Font = Enum.Font.GothamBlack;
                    BackgroundTransparency = 0.5;
                    BorderSizePixel = 2;
                    BorderColor3 = theme.text;
                    TextColor3 = theme.text;
                    [roact.Event.Activated] = function()
                        self:setState(function()
                            return {
                               -- servers = serverList;
                                section = "CustomFilter";
                                options = not(self.state.options);
                            }
                        end)
                    end;
                });
                population = roact.createElement("TextButton",{
                    Size = UDim2.fromScale(1,0.3);
                    Text = self.props.playSettings.Population;
                    TextSize = 16;
                    Font = Enum.Font.GothamBlack;
                    BackgroundTransparency = 0.5;
                    BorderSizePixel = 2;
                    BorderColor3 = theme.text;
                    TextColor3 = theme.text;
                    [roact.Event.Activated] = function()
                        self:setState(function()
                            return {
                               -- servers = serverList;
                                section = "Population";
                                options = not(self.state.options);
                            }
                        end)
                    end;
                });
            })
        })
    })

end

function settingComponent(self, theme)
    return roact.createElement(settings, {
        theme = theme;
    })

end

function serverComponent(self, theme)
    return roact.createElement(servers,{
        theme = theme;
    })

end
function deployComponent(self, theme)
    return roact.createElement(deploy,{
        theme = theme;
    })

end

function storeComponent(self, theme)
    return roact.createElement(shop, {
        theme = theme;
    })

end
function Page:init()
    self.playRef = roact.createRef();


-- get friends, though maybe move this logic to the server side instead 

 -- initializing the load in/out procedure for loadout here
    local function loadoutLoadInProcedure(loadout) 
       

        self.props.cameraToggle(70, CFrame.new(0,0,0), 1, 1, Enum.CameraType.Scriptable, false)
    
        
    end
    
    local function loadoutReturnProcedure(loadout)
     
        if game.PlaceId == 7175796352 then 
            self.props.cameraToggle(40, workspace.Terrain.CameraPosition.WorldCFrame, 0, 0, Enum.CameraType.Scriptable, true)
        else
            self.props.cameraToggle(40, workspace.CurrentCamera,0,0, Enum.CameraType.Scriptable, true)
        end

    end

    self.props.loadout:SetLoadingProcedures(loadoutLoadInProcedure, loadoutReturnProcedure)
--defining substate used for by the sub components  of this component

    self:setState({
        options = false;
        settings = false;
        section = "";
        infosort = "none";

    })
    


end

function Page:render()

    local serverType = self.props.serverType
    local theme = self.props.theme
    local page = self.props.open
    local currentPage 

    if not(page == "LOADOUTS") then --disable loadout if not on loadout page
        self.props.loadout:Disable()
    end
    if serverType == "Server" or serverType == "VIPServer" then
        if not(page == "DEPLOY") then
            Players.LocalPlayer.PlayerGui.DeploymentMenu.Enabled = false
        elseif page == "DEPLOY" then
            Players.LocalPlayer.PlayerGui.DeploymentMenu.Enabled = true
            Players.LocalPlayer.PlayerGui.DeploymentMenu.Main.DeploymentMain.TopBanner.Top:FindFirstChild("LoadoutMenu").BackgroundTransparency = 1;
            Players.LocalPlayer.PlayerGui.DeploymentMenu.Main.DeploymentMain.TopBanner.Top:FindFirstChild("LoadoutMenu").Text = "";
            Players.LocalPlayer.PlayerGui.DeploymentMenu.Main.DeploymentMain.TopBanner.Visible = false
            if Players.LocalPlayer.PlayerGui.DeploymentMenu.Main.DeploymentMain:FindFirstChild("SpawnSelection") then
                Players.LocalPlayer.PlayerGui.DeploymentMenu.Main.DeploymentMain:FindFirstChild("SpawnSelection"):Destroy()
            end
        end
    end

    if page == "PLAY" then --pull up component based on page
        currentPage = playComponent(self, theme)
    elseif page == "DEPLOY" then
        currentPage = deployComponent(self, theme)
    elseif page == "VIP" then
        currentPage = vipComponent(self, theme)
    elseif page == "SERVERS" then
        currentPage = serverComponent(self, theme)
    elseif page == "SOCIAL" then
        currentPage = socialComponent(self, theme);
    elseif page == "SETTINGS" then
        currentPage = settingComponent(self, theme);
    elseif page == "STORE" then
        currentPage = storeComponent(self, theme);
    elseif page == "RETURN MAIN MENU" then
        currentPage = roact.createElement("Frame",{
            BackgroundTransparency = 0;
            BackgroundColor3 = theme.background;
            Size = UDim2.fromScale(1,1);

        },{
            desc = roact.createElement("TextLabel",{
                Text = "Confirm, do you want to return to main menu?";
                TextColor3 = theme.text;
                BackgroundTransparency = 1;
                TextScaled = true;
                Font = theme.font;
                Size = UDim2.fromScale(0.4,0.3);
                Position = UDim2.fromScale(0.3,0.2);
            });
            confirm = roact.createElement("TextButton",{
                Text = "Yes";
                TextColor3 = theme.background;
                Position = UDim2.fromScale(0.3,0.7);
                Font = theme.font;
                TextSize = 16;
                Size = UDim2.fromScale(0.1,0.05);
                BackgroundColor3 = theme.text;
                [roact.Event.Activated] = function(obj)
                    obj.Text = "Loading..."
                    remotes.RequestMatchmaking:FireServer("MainMenu")


                end
            });
            deny = roact.createElement("TextButton",{
                Text = "No";
                TextColor3 = theme.background;
                BackgroundColor3 = theme.text;
                Position = UDim2.fromScale(0.6,0.7);
                Font = theme.font;
                TextSize = 16;
                Size = UDim2.fromScale(0.1,0.05);
                [roact.Event.Activated] = function(obj)
                    self.props.lobbyToggle("DEPLOY")

                end
            })
        })
    end

    return roact.createElement("Frame",{
        Size = UDim2.fromScale(1,0.92);
        Position = UDim2.fromScale(0,0.08);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    },{
        lobbyPage = currentPage
    })


end

function Page:didMount()
    remotes.RequestMatchmaking.OnClientEvent:connect(function(request, count)
		print("matchmaking event", request)
		local matchmakingStatusLabel = self.playRef:getValue();

        if matchmakingStatusLabel then

            if request == "JoiningServer" then
                -- show this menu if its not open
                matchmakingStatusLabel.Text = "Found Server, Joining..."
            elseif request == "Retry" then
                matchmakingStatusLabel.Text = "Retrying..."..count
                spawn(function()
                    wait(1) -- can't be abusing the server now can we?
                    remotes.RequestMatchmaking:FireServer("QuickMatch", nil, self.props.playSettings, count+1)
                end)
            elseif request == "New" then
                matchmakingStatusLabel.Text = "Creating new server..."
            elseif request == "Reconfigure" then
                matchmakingStatusLabel.Text = "No customs found, please check setting..."
            elseif request == "Default" then
                matchmakingStatusLabel.Text = "Could not find desired server, searching default..."
            elseif request == "JoiningVIPServer" then
                matchmakingStatusLabel.Text = "Joining VIP Server..."
            elseif request == "TeleportFailed" then
            
                matchmakingStatusLabel.Text = "Roblox Teleport Failed, please try again. \nKeyboard: (BACKSPACE) \nXBOX: (B)"
            elseif request == "LockedServer" then
              
                matchmakingStatusLabel.Text = "This server is private, please try a different one. \nKeyboard: (BACKSPACE) \nXBOX: (B)"
            elseif request == "NotReady" then
        
                matchmakingStatusLabel.Text = "Matchmaking Service Not Yet Initialized, please try again. \nKeyboard: (BACKSPACE) \nXBOX: (B)"
            elseif request == "ServerFull" then
           
                matchmakingStatusLabel.Text = "This server is full, please try a different one. \nKeyboard: (BACKSPACE) \nXBOX: (B)"
            elseif request == "ServerInactive" then
          
                matchmakingStatusLabel.Text = "This server is unable to be joined, please try a different one. \nKeyboard: (BACKSPACE) \nXBOX: (B)"
            end
        end
	end)
end




return roactRodux.connect(mapStateToProps, mapDispatchToProps)(Page)