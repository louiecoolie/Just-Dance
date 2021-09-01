local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- external stuff
local gameShared = ReplicatedStorage:WaitForChild("GameShared")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local util = gameShared:WaitForChild("Util")

--modules
local roactRodux = require(util:WaitForChild("Roact-Rodux"))
local roact = require(util:WaitForChild("Roact"))

local Servers = roact.Component:extend("Servers")


-- utilitly methods


local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

-- rodux methods

local function mapStateToProps(state)
    return {
        open = state.playerHandler.Lobby.currentOpen;
        playSettings = state.playerHandler.PlaySetting;
        loadout = state.playerHandler.Loadout;
        servers = state.playerHandler.Servers;
        currentSquad = state.playerHandler.CurrentSquad;
        filter = state.playerHandler.Filter;
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
        refreshListing = function()
            
            dispatch(function(store)
                local state = store:getState()
                local filter = copy(state.playerHandler.Filter) -- prevent mutation

                
                local servers = remotes.GetServerList:InvokeServer(filter)
                -- debug
              --  for i, v in pairs(servers) do
              --      for j, k in pairs(v) do
              --          print(j, k, "found in server listing")
              --          if type(k) == "table" then
               --             for l, p in pairs(k) do
               --                 print(l, p, "found sub setting")
              --              end
              --          end
              --      end
              --  end

                store:dispatch({
                    type = "SetServers";
                    servers = servers;
                })
    
        
            end)

        end;
        filterUpdate = function(setting, value)

            dispatch(function(store)
                local state = store:getState()
                local filter = copy(state.playerHandler.Filter) -- prevent mutation

                filter[setting] = value

                local servers = remotes.GetServerList:InvokeServer(filter)

                store:dispatch({
                    type = "SetServers";
                    servers = servers;
                })
    
                
                store:dispatch{
                    type = "SetFilter",
                    setting = setting;
                    value = value;
                }
        
            end)


        end;
        serverUpdate = function(servers)
            dispatch({
                type = "SetServers";
                servers = servers;
            })

        end;
    }
end

local function fetchServersWithFilter(filter)
    if not filter then 
        local filter = {}
        -- debug
        filter["IncludeSlowServers"] = true
        --
        local filterOptions = {};
        
        for i, v in pairs(filterOptions) do
            if v.Type == "Boolean" then
                filter[i] = v.Enabled
            elseif v.Type == "Options" then
                filter[i] = v.Enabled and v.Selected or nil
            end
        end
        
        return remotes.GetServerList:InvokeServer(filter)
    else
        return remotes.GetServerList:InvokeServer(filter)
    end
end

local function createServerListing(self, theme, server, serverCount)
    local color
    if (serverCount % 2) == 0 then
        color = theme.section;
    else
        color = theme.background;
    end

    return roact.createElement("TextButton",{
        Size = UDim2.fromScale(1,0.05);
        BackgroundColor3 = color;
        Text = "";
        LayoutOrder = serverCount;
        [roact.Event.Activated] = function()
    
            self:setState(function()
                return {
                    selection = true;
                    selectedInfo = server;
                }
            end)
        end;
    },{
        desc = roact.createElement("TextLabel",{
            Text = server.ServerInfo;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            TextColor3 = theme.text;
            Font = Enum.Font.GothamBlack;
            TextSize = 18;
            Size = UDim2.fromScale(0.4,1);
        });
        gamemode = roact.createElement("TextLabel",{
            Text = server.Gamemode;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            TextColor3 = theme.text;
            Font = Enum.Font.GothamBlack;
            TextSize = 18;
            Size = UDim2.fromScale(0.2,1);
            Position = UDim2.fromScale(0.4,0);
        });
        map = roact.createElement("TextLabel",{
            Text = server.Map;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            TextColor3 = theme.text;
            Font = Enum.Font.GothamBlack;
            TextSize = 18;
            Size = UDim2.fromScale(0.2,1);
            Position = UDim2.fromScale(0.6,0);
        });
        players = roact.createElement("TextLabel",{
            Size = UDim2.fromScale(0.1,1);
            Position = UDim2.fromScale(0.8,0);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            TextColor3 = theme.text;
            Font = Enum.Font.GothamBlack;
            TextSize = 18;
            Text = server.PlayerCount.Current.."/"..server.PlayerCount.Max;
        });
 
        status = roact.createElement("TextLabel",{
            Position = UDim2.fromScale(0.9,0);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            TextColor3 = theme.text;
            Font = Enum.Font.GothamBlack;
            TextSize = 18;
            Size = UDim2.fromScale(0.1,1);
            Text = ((server.Timer-server.Timer%60)/60)..":"..math.floor(server.Timer%60 > 10 and server.Timer%60 or ("0"..server.Timer%60));
        });
    })

end

local function createServerList(self, theme)
  --  local servers = fetchServersWithFilter
    local children = {
        UIList = roact.createElement("UIListLayout",{
            SortOrder = Enum.SortOrder.LayoutOrder;
        })
    }
    if self.props.servers then
        for n, server in pairs(self.props.servers) do
            children[n] = createServerListing(self, theme, server, n)
        end
    end
    return roact.createElement("Frame",{
        Size = UDim2.fromScale(0.8,1);
        Position = UDim2.fromScale(0.2,0);
    },{
    listings = roact.createElement("ScrollingFrame",{
        Size = UDim2.fromScale(1,.95);
        Position = UDim2.fromScale(0,0.05);
        BackgroundTransparency = 0.3;
        BorderSizePixel = 0;
        BackgroundColor3 = theme.section;
    }, children);
    description = roact.createElement("Frame",{
        Size = UDim2.fromScale(1,0.05);
        BackgroundColor3 = theme.option;
    },{
        Refresh = roact.createElement("ImageButton",{
            Image = "rbxassetid://257125640";
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Size = UDim2.fromScale(0.05,1);
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 4;
            [roact.Event.Activated] = function()
                self.props.refreshListing()
            end,
        });
        desc = roact.createElement("TextButton",{
            Text = "Server Info";
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            TextColor3 = theme.text;
            Font = Enum.Font.GothamBlack;
            TextSize = 18;
            Size = UDim2.fromScale(0.4,1);
            [roact.Event.Activated] = function()
                local serverList = copy(self.props.servers) --mutation is bad mkay
                local sort = self.state.infosort;

                if sort == "none" or sort == "up" then
                    local sortedTable = table.sort(serverList,
                        function(a,b)
                            return a.ServerInfo:lower() > b.ServerInfo:lower()
                        end
                        )

                    self.props.serverUpdate(serverList)     
                    self:setState(function()
                        return {
                           -- servers = serverList;
                            infosort = "down";
                        }
                    
                    end)
                elseif sort == "down" then
                    local sortedTable = table.sort(serverList,
                        function(a,b)
                            return a.ServerInfo:lower() < b.ServerInfo:lower()
                        end
                        )

                    self.props.serverUpdate(serverList)    

                    self:setState(function()
                        return {
                            --servers = serverList;
                            infosort = "up";
                        }
                    
                    end)
                end
     
            end
        });
        gamemode = roact.createElement("TextButton",{
            Text = "Gamemode";
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            TextColor3 = theme.text;
            Font = Enum.Font.GothamBlack;
            TextSize = 18;
            Size = UDim2.fromScale(0.2,1);
            Position = UDim2.fromScale(0.4,0);
            [roact.Event.Activated] = function()
                local serverList = copy(self.props.servers)
                local sort = self.state.gamesort;
                if sort == "none" or sort == "up" then
                    local sortedTable = table.sort(serverList,
                        function(a,b)
                            return a.Gamemode > b.Gamemode
                        end
                        )

                    self.props.serverUpdate(serverList)

                    self:setState(function()
                        return {
                            --servers = serverList;
                            gamesort = "down";
                        }
                    
                    end)
                elseif sort == "down" then
                    local sortedTable = table.sort(serverList,
                        function(a,b)
                            return a.Gamemode < b.Gamemode
                        end
                        )
                        
                    self.props.serverUpdate(serverList)

                    self:setState(function()
                        return {
                           -- servers = serverList;
                            gamesort = "up";
                        }
                    
                    end)
                end
            end;
        });
        map = roact.createElement("TextButton",{
            Text = "Map";
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            TextColor3 = theme.text;
            Font = Enum.Font.GothamBlack;
            TextSize = 18;
            Size = UDim2.fromScale(0.2,1);
            Position = UDim2.fromScale(0.6,0);
            [roact.Event.Activated] = function()
                local serverList = copy(self.props.servers)
                local sort = self.state.mapsort;
                if sort == "none" or sort == "up" then
                    local sortedTable = table.sort(serverList,
                        function(a,b)
                            return a.Map > b.Map
                        end
                        )

                    self.props.serverUpdate(serverList)
                    self:setState(function()
                        return {
                            --servers = serverList;
                            mapsort = "down";
                        }
                    
                    end)
                elseif sort == "down" then
                    local sortedTable = table.sort(serverList,
                        function(a,b)
                            return a.Map < b.Map
                        end
                        )

                    self.props.serverUpdate(serverList)
                    self:setState(function()
                        return {
                            --servers = serverList;
                            mapsort = "up";
                        }
                    
                    end)
                end
            end;
        });
        players = roact.createElement("TextButton",{
            Size = UDim2.fromScale(0.1,1);
            Position = UDim2.fromScale(0.8,0);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            TextColor3 = theme.text;
            Font = Enum.Font.GothamBlack;
            TextSize = 18;
            Text = "Players";
            [roact.Event.Activated] = function()
         
                local serverList = copy(self.props.servers)
                local sort = self.state.playersort;
                if sort == "none" or sort == "up" then
                    local sortedTable = table.sort(serverList,
                        function(a,b)
                            return a.PlayerCount.Current > b.PlayerCount.Current
                        end
                        )

                    self.props.serverUpdate(serverList)    
                    self:setState(function()
                        return {
                            --servers = serverList;
                            playersort = "down";
                        }
                    
                    end)
                elseif sort == "down" then
                    local sortedTable = table.sort(serverList,
                        function(a,b)
                            return a.PlayerCount.Current < b.PlayerCount.Current
                        end
                        )

                    self.props.serverUpdate(serverList)
                    self:setState(function()
                        return {
                           -- servers = serverList;
                            playersort = "up";
                        }
                    
                    end)
                end
            end;
        });
 
        status = roact.createElement("TextButton",{
            Position = UDim2.fromScale(0.9,0);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            TextColor3 = theme.text;
            Font = Enum.Font.GothamBlack;
            TextSize = 18;
            Size = UDim2.fromScale(0.1,1);
            Text = "Status";
            [roact.Event.Activated] = function()
                local serverList = copy(self.props.servers)
                local sort = self.state.statussort;
                if sort == "none" or sort == "up" then
                    local sortedTable = table.sort(serverList,
                        function(a,b)
                            return a.Timer > b.Timer
                        end
                        )

                    self.props.serverUpdate(serverList)
                    self:setState(function()
                        return {
                           -- servers = serverList;
                            statussort = "down";
                        }
                    
                    end)
                elseif sort == "down" then
                    local sortedTable = table.sort(serverList,
                        function(a,b)
                            return a.Timer < b.Timer
                        end
                        )

                    self.props.serverUpdate(serverList)
                    self:setState(function()
                        return {
                            --servers = serverList;
                            statussort = "up";
                        }
                    
                    end)
                end
            end;
        });
    })


    })


end

local function createFilterElement(theme, order, setting, value, binding)

    if type(value) == "string" then
        return roact.createElement("Frame",{
            Size = UDim2.fromScale(.95,0.05);
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
                Size = UDim2.fromScale(.95,0.05);
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
                Size = UDim2.fromScale(.95,0.05);
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
        Size = UDim2.fromScale(0.19,0.7);
        BorderSizePixel = 0;
        BackgroundColor3 = theme.section;
        BackgroundTransparency = 0.5;
    },{
        container = roact.createElement("ScrollingFrame",{
            Size = UDim2.fromScale(1,1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        },{
            uilist = roact.createElement("UIListLayout",{
                SortOrder = Enum.SortOrder.LayoutOrder;
                Padding = UDim.new(0.02,0);
            });
            mapSetting = createFilterElement(theme, 1, "Map selected: ", self.props.filter.PreferredMap, 
            function() 
                self:setState(function()
                    return {
                       -- servers = serverList;
                        section = "PreferredMap";
                        options = not(self.state.options);
                    }
                end)
            end);
            gameSetting = createFilterElement(theme, 2, "Gamemode selected: ", self.props.filter.PreferredMode, 
            function() 
                self:setState(function()
                    return {
                       -- servers = serverList;
                        section = "PreferredMode";
                        options = not(self.state.options);
                    }
                end)
            end);
            serverSetting = createFilterElement(theme, 2, "Server selected: ", self.props.filter.CustomFilter, 
            function() 
                self:setState(function()
                    return {
                       -- servers = serverList;
                        section = "CustomFilter";
                        options = not(self.state.options);
                    }
                end)
            end);
            emptySetting = createFilterElement(theme, 3, "Empty servers included: ", self.props.filter.EmptyFilter, 
            function()
                self.props.filterUpdate("EmptyFilter", not(self.props.filter.EmptyFilter))
            end);
            fullSetting = createFilterElement(theme,  4, "Full servers included: ", self.props.filter.FullFilter, 
            function()
                self.props.filterUpdate("FullFilter", not(self.props.filter.FullFilter))
            end);
            slowSetting = createFilterElement(theme, 5, "Slow servers included: ", self.props.filter.IncludeSlowServers, 
            function()
                self.props.filterUpdate("IncludeSlowServers", not(self.props.filter.IncludeSlowServers))
            end);

        })
    })
end

local function createServerPrompt(self, theme)
    local server = self.state.selectedInfo
    if server then
        return roact.createElement("Frame",{
            Size = UDim2.fromScale(0.4,0.5);
            Position = UDim2.fromScale(0.35, 0.3);
            BackgroundColor3 = theme.option;
     
            ZIndex = 4;
            Visible = self.state.selection;
        },{
            action = roact.createElement("TextLabel",{
                Text = "Join Server: ";
                TextSize = 20;
                Size = UDim2.fromScale(1,0.1);
                BorderSizePixel = 0;
                Font = theme.font;
                ZIndex = 5;
                TextColor3 = theme.text;
                BackgroundTransparency = 1;
            });
            desc = roact.createElement("TextLabel",{
                Text = self.state.selectedInfo.Description;
                TextSize = 20;
                Size = UDim2.fromScale(0.5,0.3);
                Position = UDim2.fromScale(0,0.1);
                TextWrapped = true;
                Font = theme.font;
                ZIndex = 5;
                TextColor3 = theme.text;
                BorderSizePixel = 0;
                BackgroundTransparency = 1;
            });
            img = roact.createElement("ImageLabel", {
                Image = server.Image or "rbxassetid://7315468476";
                Size = UDim2.fromScale(0.5,0.3);
                Position = UDim2.fromScale(0.5,0.1);
                ZIndex = 5;
                BackgroundTransparency = 1;
            });
            border = roact.createElement("Frame",{
                BackgroundColor3 = theme.border;
                BorderSizePixel = 0;
                Size = UDim2.fromScale(1,0.01);
                Position = UDim2.fromScale(0,0.39);
            });
            id = roact.createElement("TextLabel",{
                Text = "ID: "..server.ServerInfo;
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                TextColor3 = theme.text;
                ZIndex = 5;
                Font = Enum.Font.GothamBlack;
                TextSize = 18;
                Size = UDim2.fromScale(0.2,.1);
                Position = UDim2.fromScale(0.4,0.4);
            });
            gamemode = roact.createElement("TextLabel",{
                Text = "Gamemode: "..server.Gamemode;
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                TextColor3 = theme.text;
                ZIndex = 5;
                Font = Enum.Font.GothamBlack;
                TextSize = 18;
                Size = UDim2.fromScale(0.2,.1);
                Position = UDim2.fromScale(0.4,0.5);
            });
            map = roact.createElement("TextLabel",{
                Text = "Map: "..server.Map;
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                ZIndex = 5;
                TextColor3 = theme.text;
                Font = Enum.Font.GothamBlack;
                TextSize = 18;
                Size = UDim2.fromScale(0.2,.1);
                Position = UDim2.fromScale(0.4,0.6);
            });
            players = roact.createElement("TextLabel",{
                Size = UDim2.fromScale(0.1,.1);
                Position = UDim2.fromScale(0.45,0.7);
                BackgroundTransparency = 1;
                ZIndex = 5;
                BorderSizePixel = 0;
                TextColor3 = theme.text;
                Font = Enum.Font.GothamBlack;
                TextSize = 18;
                Text = "Players: "..server.PlayerCount.Current.."/"..server.PlayerCount.Max;
            });
    
            status = roact.createElement("TextLabel",{
                Position = UDim2.fromScale(0.45,0.8);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                TextColor3 = theme.text;
                ZIndex = 5;
                Font = Enum.Font.GothamBlack;
                TextSize = 18;
                Size = UDim2.fromScale(0.1,.1);
                Text = "Status: "..math.floor((server.Timer-server.Timer%60)/60)..":"..math.floor(server.Timer%60 > 10 and server.Timer%60 or ("0"..server.Timer%60));
            });

            cancel = roact.createElement("TextButton",{
                BackgroundColor3 = theme.text;
                TextColor3 = theme.background;
                Text = "Cancel";
                TextSize = 16;
                Font = theme.font;
                ZIndex = 5;
                BorderSizePixel = 0;
                Size = UDim2.fromScale(0.4,0.1);
                Position = UDim2.fromScale(0.05,0.9);
                [roact.Event.Activated] = function()
                    self:setState(function()
                        return {
                            selection = false;
                        }
                    end)

                end
            });
            join = roact.createElement("TextButton",{
                BackgroundColor3 = theme.text;
                TextColor3 = theme.background;
                Text = "Join";
                Font = theme.font;
                BorderSizePixel = 0;
                ZIndex = 5;
                TextSize = 16;
                Size = UDim2.fromScale(0.4,0.1);
                Position = UDim2.fromScale(0.55,0.9);
                [roact.Event.Activated] = function(obj)
                    if self.props.currentSquad then
                        if self.props.currentSquad.Leader == game.Players.LocalPlayer.Name then
                        
                            remotes.RequestMatchmaking:FireServer("JoinServer", {ServerID = server.ServerInfo})
    
                            obj.Text = "Joining..."
                        else
                            spawn(function()
                                obj.Text = "Not squad leader"
                                wait(0.5)
                                obj.Text = "Join"
                            end)
                        end
                    else
                        remotes.RequestMatchmaking:FireServer("JoinServer", {ServerID = server.ServerInfo})
                    
                    end
                   
                end
            });
        })
    end
end

local function createOptionChild(self, theme, section, value, binding)
    return roact.createElement("TextButton",{
        Size = UDim2.fromScale(1,0.05);
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
    elseif section == "PreferredMap" then
        children[1] = createOptionChild(self, theme, section, "Procedural City")
        children[2] = createOptionChild(self, theme, section, "SnowDrift")
        children[3] = createOptionChild(self, theme, section, "Procedural Sky Islands")
        children[4] = createOptionChild(self, theme, section, "Procedural Hills")
        children[5] = createOptionChild(self, theme, section, "Canyon")
        children[6] = createOptionChild(self, theme, section, "Any")
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

local function createOptions(self, theme)
    local children = createOptionChildren(self, theme, self.state.section)

    return roact.createElement("ScrollingFrame",{
        Size = UDim2.fromScale(0.2,0.5);
        Position = UDim2.fromScale(0.2,0);
        BackgroundColor3 = theme.section;
        BorderSizePixel = 0;
        BackgroundTransparency = 0.1;
        Visible = self.state.options;
        ZIndex = 2;
    },
        children
    )   


end


function Servers:init()
    spawn(function()
        self.props.refreshListing()
    
    end)
  

    self:setState({
        options = false;
        selection = false;
        section = "";
        infosort = "none";
        mapsort = "none";
        gamesort = "none";
        playersort = "none";
        statussort = "none";
    })
    

end


function Servers:render()
    local theme = self.props.theme;

    return roact.createElement("Frame",{
        Size = UDim2.fromScale(1,1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    },{
        serverList = createServerList(self, theme);
        filterOptions = createFilterOptions(self, theme);
        prompt = createServerPrompt(self, theme);
        filterDropdown = createOptions(self, theme);
    })

end





return roactRodux.connect(mapStateToProps, mapDispatchToProps)(Servers)