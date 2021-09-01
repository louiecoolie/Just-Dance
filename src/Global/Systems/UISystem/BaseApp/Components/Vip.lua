local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local marketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

-- external stuff
local gameShared = ReplicatedStorage:WaitForChild("GameShared")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local util = gameShared:WaitForChild("Util")



--modules
local roactRodux = require(util:WaitForChild("Roact-Rodux"))
local roact = require(util:WaitForChild("Roact"))

local Vip = roact.Component:extend("Vip")


-- rodux methods

local function mapStateToProps(state)
    return {
        vip = state.playerHandler.VIP;
        serverType = state.playerHandler.ServerType
    }
end

local function mapDispatchToProps(dispatch)
    return {
        customSet = function(setting, value)
            dispatch(function(store)
    
                store:dispatch({
                    type = "SetVIPSetting";
                    setting = setting;
                    value = value;
                })
            
            end)
        end;
        ruleSet = function(setting, value)
            dispatch(function(store)
    
                store:dispatch({
                    type = "SetRuleSetting";
                    setting = setting;
                    value = value;
                })
            
            end)
        end;
        teamSet = function(setting, value)
     
            dispatch({
                type = "SetTeams";
                setting = setting;
                value = value;
            })
            


        end;
        modeSet = function(value)
            dispatch({
                type = "SetMode";
                value = value;
            })
        end;
        superSet = function(value, setting, super)
            dispatch({
                type = "SetSuper";
                super = super;
                value = value;
                setting = setting;
            })
        end;
        publicSet = function(value)
            dispatch({
                type = "PublicSetting";
                value = value; 
            })

        end
    }
end

local MAP_MODE_TO_NAME = {
    gamemode_bnb = "Build and Battle";
    gamemode_b = "Building Sandbox"
}

local MAP_TEAM_TO_COLOR = {
    TEAM_BLUE = "United Bloxxers";
    TEAM_RED = "League of 1x1x1x1";
    TEAM_PURPLE = "The New Monarchy";
}

local MAP_WORLD_SETTING_TO_NAME = {
	Gravity = "Gravity Multiplier";
	SeaLevel = "Sea Level Multiplier";
	WalkSpeed = "Walkspeed Multplier";
	Trees = "Toggle Trees";
}

local MAPS = {
    "Procedural City";
    "Procedural Sky Islands";
    "SnowDrift";
    "Canyon";
    "Procedural Hills";
    "Any";
}

local MAP_BASE_TO_NAME = {
    LandLightArmor = "Jeeps";
	LandArtillery = "Rocket Artillery";
	LandHeavyArmor = "Tanks/APC";
	AirHelicopterTransport = "Light/Transport Helis";
	AirHelicopterCombat = "Attack Helis";
	AirJet = "Jets";
    AirFighter = "Fighters";
}

local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

local function randomize(table,comparative,dispatch)
    for i, v in pairs(table) do
        if not(i == comparative) then
            dispatch(i)

            return i
        end
    end

end



local function createTopbar(self, theme, props)
    return roact.createElement("TextLabel",{
        Size = props.Size or UDim2.fromScale(.5,0.1);
        Position = props.Position or UDim2.fromScale(0.025,0.01);
        BorderColor3 = theme.border;
        BackgroundColor3 = theme.section;
        BorderSizePixel = 2;
        ZIndex = 5;
        TextColor3 = theme.text;
        Font = theme.font;
        Text = props.Text;
        --TextXAlignment = 0;
        --TextSize = 20;
        TextScaled = true;
    },{
        sizeConstraint = roact.createElement("UISizeConstraint",{
            MinSize = Vector2.new(60, 30);
            MaxSize = Vector2.new(120, 30);
        });
        textConstraint = roact.createElement("UITextSizeConstraint",{
            MaxTextSize = 20;
        })
    });


end

local function createButton(self, theme, props)
    return roact.createElement("Frame",{
        Size = UDim2.fromScale(.02,.02);
        Position = props.Position or UDim2.fromScale(0.44,0.44);
        BackgroundColor3 =  theme.border;
        Transparency = 0.5;
    },{ 
        inner = roact.createElement("TextButton",{
            Size = UDim2.fromScale(.6,.6);
            Position = UDim2.fromScale(0.2,0.2);
            Text = "";
            BorderSizePixel = 0;
            BackgroundColor3 = props.Value and theme.text or theme.background;
            [roact.Event.Activated] = function()
                props.Bindable()
                --self.props.ruleSet("UsesTimer", not(vip.customSettings.GameRules.RuleSet.UsesTimer))
            end
        });
        constraint = roact.createElement("UISizeConstraint",{
            MinSize = Vector2.new(30,30);
        })
    });
end

local function createText(self, theme, props)
    return roact.createElement("TextLabel",{
        Text = props.Text;
        Position = props.Position;
        LayoutOrder = props.Order;
        BackgroundTransparency = props.BackgroundTransparency or 0;
        Size = props.Size or UDim2.fromScale(1,0.01);
        BackgroundColor3 = props.Background or theme.text;
        TextColor3 = props.TextColor or theme.background;
        TextSize = props.TextSize or 12;
        Font = theme.font;
        ZIndex = 2;
    },{
        constraint = roact.createElement("UISizeConstraint",{
            MinSize = props.MinSize or  Vector2.new(0,30);
        })
    })

end

local function createTextButton(self, theme, props)
    return roact.createElement("TextButton",{
        Text = props.Text;
        Position = props.Position;
        LayoutOrder = props.Order;
        Size = props.Size or UDim2.fromScale(1,0.01);
        BackgroundColor3 = props.Background or theme.text;
        TextColor3 = props.TextColor or theme.background;
        TextSize = props.TextSize or 12;
        Font = theme.font;
        ZIndex = 2;
        [roact.Event.Activated] = function(obj)
            props.Bindable(obj)

        end
    },{
        constraint = roact.createElement("UISizeConstraint",{
            MinSize = Vector2.new(0,30);
        })
    })


end



local function createTextBox(self, theme, props)
    return roact.createElement("TextBox",{
        Text = props.Text;
        Position = props.Position;
        LayoutOrder = props.Order;
        Size = props.Size or UDim2.fromScale(1,0.01);
        BackgroundColor3 = props.Background or theme.text;
        TextColor3 = props.TextColor or theme.background;
        TextSize = props.TextSize or 12;
        Font = theme.font;
        ZIndex = 2;
        [roact.Event.FocusLost] = function(obj)
            props.Bindable(obj)

        end
    },{
        constraint = roact.createElement("UISizeConstraint",{
            MinSize = Vector2.new(0,30);
        })
    })


end


local function createWidget(self, theme, props)
    if props.Type == "ScrollingFrame" then
        return roact.createElement("Frame",{
            BackgroundTransparency = 1;
            Size = props.Size;
            Position = props.Position;
    
        },{
            topbar = createTopbar(self, theme, {
                Text = props.Text;
                Size = props.TextSize;
                Position = props.TextPosition;
            });
            settings = roact.createElement(props.Type,{
                Size = props.SettingSize or UDim2.fromScale(1,0.9);
                CanvasSize = (props.Type == "ScrollingFrame") and props.CanvasSize or UDim2.fromScale(0,3);
                Position = props.SettingPosition or UDim2.fromScale(0,0.1);
                BackgroundColor3 = theme.background;
                Transparency = 0.2;
            }, props.Children);
    
        })
    else
        return roact.createElement("Frame",{
            BackgroundTransparency = 1;
            Size = props.Size;
            Position = props.Position;
    
        },{
            topbar = createTopbar(self, theme, {
                Text = props.Text;
                Size = props.TextSize;
                Position = props.TextPosition;
            });
            settings = roact.createElement(props.Type,{
                Size = props.SettingSize or UDim2.fromScale(1,0.9);
                Position = props.SettingPosition or UDim2.fromScale(0,0.1);
                BackgroundColor3 = theme.background;
                Transparency = 0.2;
            }, props.Children);
    
        })
    end


end

local function createSetting(self, theme, props)
    return roact.createElement("Frame",{
        Size = props.Size or UDim2.new(.95,0,0,50);
        Position = props.Position;
        BackgroundColor3 = theme.option;
        BorderSizePixel = 2;
        BorderColor3 = theme.border;
        LayoutOrder = props.Order;
    },{
        title = roact.createElement("TextLabel",{
            Text = props.Title;
            Font = theme.font;
            TextXAlignment = 0;
            TextColor3 = theme.text;
            BackgroundTransparency = 1;
            TextSize = 18;
            Size = props.TitleSize or UDim2.fromScale(0.4,0.5);
            Position = UDim2.fromScale(0.01, 0);
        });
        desc = roact.createElement("TextLabel",{
            Text = props.Description;
            BackgroundTransparency = 1;
            TextXAlignment = 0;
            TextSize = 18;
            TextColor3 = Color3.fromRGB(150,150,150);
            Font = theme.font;
            --TextColor3 = theme.text;
            Size = props.DescriptionSize or UDim2.fromScale(0.5,0.5);
            Position = props.DescriptionPos or UDim2.fromScale(0.01,0.5);
        });
        constraint = roact.createElement("UISizeConstraint",{
            MinSize = props.Constraint or Vector2.new(0,75.5)
        });
        container = roact.createElement("Frame",{
            Size = UDim2.fromScale(1,1);
            BackgroundTransparency = 1;
        },
            props.Children
        );
    })

end

local function createDropdown(self, theme, props)
    return roact.createElement("ScrollingFrame",{
        Size = props.Size;
        Position = props.Position;
        Visible = props.Visible;
        ClipsDescendants = props.ClipsDescendants or false;
        BackgroundTransparency = props.Transparency or 1;

    },{
        layout = roact.createElement("UIListLayout",{
            SortOrder = 2
        });
        children = roact.createFragment(props.Children);
    })



end


local function createSuperSetting(self, theme, props)

    local table = props.Table
    local mapBase = props.Map
    return {
        content = createDropdown(self, theme, {
            Position = UDim2.fromScale(0.1,0.2);
            Size = UDim2.fromScale(0.8,0.8);
            Transparency = 1;
            ClipsDescendants = true;
            Children = (function()
                local generated = {}
                local count = 1;
                for i, value in pairs(table) do
            
                    count +=1
                    local type
                    if typeof(value) == "boolean" then
                        type = createButton
                    else
                        type = createTextBox
                    end
                    generated[i] = roact.createElement("Frame",{
                        BackgroundTransparency = 1;
                        Size = UDim2.new(1,0,0,50);
                    },{
                        desc = createText(self, theme, {
                            Text = mapBase and mapBase[i] or i;
                            TextColor = theme.text;
                            TextSize = 18;
                            Size = UDim2.fromScale(0.5, 0.1);
                            Background = theme.section;
                            BackgroundTransparency = 1;
                            MinSize = Vector2.new(0,50);
                            Order = count;
                        });
                        option = type(self, theme, {
                            Text = (typeof(value) == "string" or typeof(value) == "number") and value;
                            TextColor = theme.section;
                            Value = (typeof(value) == "boolean") and value;
                            TextSize = 18;
                            Size = UDim2.fromScale(0.5, 0.1);
                            Position = (typeof(value) == "boolean") and  UDim2.fromScale(0.717,0) or UDim2.fromScale(0.5,0);
                            Background = theme.text;
                            BackgroundTransparency = 1;
                            MinSize = Vector2.new(0,50);
                            Order = count;
                            Bindable = function(obj)
                    
                                if typeof(value) == "boolean" then
                                 
                                    self.props.superSet(not(value),i, props.Super)
                                elseif typeof(value) == "string" then
                                    self.props.superSet(obj.Text,i, props.Super)
                                elseif typeof(value) == "number" then
                                    if tonumber(obj.Text) == nil then
                                        obj.Text = 1;
                                    end

                                    if tonumber(obj.Text) < 0 then
                                        obj.Text = props.Min
                                        self.props.superSet(tonumber(obj.Text) or 0,i,props.Super)
                                    elseif tonumber(obj.Text) > props.Max then
                                        obj.Text = props.Max
                                        self.props.superSet(tonumber(obj.Text) or 0,i,props.Super)
                                    end
                                end


                            end;
                        })
    

                    })
                end
                    
                return generated
            end)()
        });
    }
end

function Vip:init()
    self:setState({
        options = false
    })

end

function Vip:render()
    local vip = self.props.vip

    local gameMode = vip.customSettings.GameRules.Gamemode
	local currentRules = copy(vip.customSettings.GameRules.RuleSet) -- -- copy to avoid mutation mkay.
   
    local theme = self.props.theme

    return roact.createElement("Frame",{
        Size = UDim2.fromScale(1,1);
        BackgroundTransparency = 1;
    },{
        InputProtect = roact.createElement("TextButton",{
            Size = UDim2.fromScale(1,1);
            BackgroundTransparency = 1;
            ZIndex = vip.customSettings.OwnerID == Players.LocalPlayer.UserId and -1 or 100;
        });
        Options = roact.createElement("Frame",{
            Size = UDim2.fromScale(1,1);
            BackgroundColor3 = theme.background;
            BackgroundTransparency = 0.4;
            Visible = true
        },{
            gameSetting = createWidget(self, theme,{
                Size = UDim2.fromScale(0.5,0.95);
                Position = UDim2.fromScale(0,0);
                CanvasSize = UDim2.fromScale(0,5);
                Text = "Rules:";
                Type = "ScrollingFrame";
                Children = {
                    UILayout = roact.createElement("UIListLayout",{
                        SortOrder = 2;
                        Padding = UDim.new(0,10);
                        HorizontalAlignment = 0;
                    });
                    Teams = createSetting(self, theme, {
                        Title = "Teams";
                        Order = 1;
                        Description = "Choose the factions";
                        Children = {
                            box1 = roact.createElement("TextButton",{
                                Size = UDim2.fromScale(.18,.4);
                                Position = UDim2.fromScale(0.6,0.1);
                                Font = theme.font;
                                TextScaled = true;
                                Text = MAP_TEAM_TO_COLOR[not(currentRules.Teams[2].Preset == currentRules.Teams[1].Preset) and currentRules.Teams[1].Preset or randomize(MAP_TEAM_TO_COLOR, currentRules.Teams[1].Preset, function(v) self.props.teamSet(1, v)end)];
                                TextSize = 16;
                                Transparency = 0.1;
                                TextColor3 = theme.background;
                                BackgroundColor3 = theme.text;
                                [roact.Event.Activated] = function(obj, enterPressed)
                          
                                    local content = obj:FindFirstChild("content")
                                    content.Visible = not(content.Visible);
                                end
                            },{
                                content = createDropdown(self, theme, {
                                    Size = UDim2.fromScale(0.95,3);
                                    Position = UDim2.fromScale(0,1);

                                    BackgroundColor3 = theme.section;
                                    Visible = false;
                                    Children = (function()
                                        local generated = {}
                                        local count = 1;
                                        for i, value in pairs(MAP_TEAM_TO_COLOR) do
                                            count +=1 ;
                                            generated[MAP_TEAM_TO_COLOR[i]] = createTextButton(self, theme, {
                                                Text = MAP_TEAM_TO_COLOR[i];
                                                TextColor = theme.text;
                                                Background = theme.section;
                                                Order = count;
                                                Bindable = function(obj)
                                                    obj.Parent.Visible = false;
                                                    self.props.teamSet(1, i)

                                                end;

                                            });
                                        end
                                            
                                        return generated
                                    
                                    end)()
                                })

                    
                            });
                            box2 = roact.createElement("TextButton",{
                                Size = UDim2.fromScale(.18,.4);
                                Position = UDim2.fromScale(0.8,0.1);
                                Font = theme.font;
                                TextScaled = true;
                                Text = MAP_TEAM_TO_COLOR[not(currentRules.Teams[2].Preset == currentRules.Teams[1].Preset) and currentRules.Teams[2].Preset or randomize(MAP_TEAM_TO_COLOR, currentRules.Teams[2].Preset, function(v) self.props.teamSet(2, v)end)];
                                TextSize = 16;
                                Transparency = 0.1;
                                TextColor3 = theme.background;
                                BackgroundColor3 = theme.text;
                                [roact.Event.Activated] = function(obj, enterPressed)
                               
                                    local content = obj:FindFirstChild("content")
                                    content.Visible = not(content.Visible);
                                end
                            },{
                                content = createDropdown(self, theme, {
                                    Size = UDim2.fromScale(0.95,3);
                                    Position = UDim2.fromScale(0,1);

                                    BackgroundColor3 = theme.section;
                                    Visible = false;
                                    Children = (function()
                                        local generated = {}
                                        local count = 1;
                                        for i, value in pairs(MAP_TEAM_TO_COLOR) do
                                            count +=1 ;
                                            generated[MAP_TEAM_TO_COLOR[i]] = createTextButton(self, theme, {
                                                Text = MAP_TEAM_TO_COLOR[i];
                                                TextColor = theme.text;
                                                Background = theme.section;
                                                Order = count;
                                                Bindable = function(obj)
                                                    obj.Parent.Visible = false;
                                                    self.props.teamSet(2, i)

                                                end;

                                            });
                                        end
                                            
                                        return generated
                                    
                                    end)()
                                })

                    
                            });
                        };
                    });
                    Timer = createSetting(self, theme, {
                        Title = "Round Timer";
                        Order = 2;
                        Description = "Choose the time limit, if any.";
                        Children = {
                            box = roact.createElement("TextBox",{
                                Size = UDim2.fromScale(.18,.4);
                                Position = UDim2.fromScale(0.7,0.1);
                                Font = theme.font;
                                TextScaled = true;
                                Text = vip.customSettings.GameRules.RuleSet.RoundTime or 3000;
                                TextSize = 16;
                                Visible = vip.customSettings.GameRules.RuleSet.UsesTimer;
                                Transparency = 0.1;
                                TextColor3 = theme.background;
                                BackgroundColor3 = theme.text;
                                [roact.Event.FocusLost] = function(obj, enterPressed)
                                    local value = tonumber(obj.Text)
                           
                                    if value == nil then
                                        obj.Text = 1000
                                    end
                                    if value <= 0 then
                                        obj.Text = "100"
                                        self.props.ruleSet("UsesTimer", not(vip.customSettings.GameRules.RuleSet.UsesTimer))
                                        self.props.ruleSet("RoundTime", tonumber(obj.Text))
                                    elseif value > 100000 then
                                        obj.Text = "100000"
                                        self.props.ruleSet("RoundTime", tonumber(obj.Text))
                                    end
                                   
                                end
                            });
                            button = roact.createElement("Frame",{
                                Size = UDim2.fromScale(.02,.02);
                                Position = UDim2.fromScale(0.9,0.1);
                                BackgroundColor3 =  theme.border;
                                Transparency = 0.5;
                            },{ 
                                inner = roact.createElement("TextButton",{
                                    Size = UDim2.fromScale(.6,.6);
                                    Position = UDim2.fromScale(0.2,0.2);
                                    Text = "";
                                    BorderSizePixel = 0;
                                    BackgroundColor3 = vip.customSettings.GameRules.RuleSet.UsesTimer and theme.text or theme.background;
                                    [roact.Event.Activated] = function()
                                        self.props.ruleSet("UsesTimer", not(vip.customSettings.GameRules.RuleSet.UsesTimer))
                                    end
                                });
                                constraint = roact.createElement("UISizeConstraint",{
                                    MinSize = Vector2.new(30,30);
                                })
                            });
                        }
                    });
                    TeamReinforcements = createSetting(self, theme, {
                        Title = "Team Reinforcements";
                        Order = 3;
                        Description = "The number of reinforcements per team";
                        Children = {
                            box = roact.createElement("TextBox",{
                                Size = UDim2.fromScale(.18,.4);
                                Position = UDim2.fromScale(0.7,0.1);
                                Font = theme.font;
                                TextScaled = true;
                                Text = vip.customSettings.GameRules.RuleSet.Teams[1].Reinforcements or "Enter Reinforcements";
                                TextSize = 16;
                                Transparency = 0.1;
                                TextColor3 = theme.background;
                                BackgroundColor3 = theme.text;
                                [roact.Event.FocusLost] = function(obj, enterPressed)
                                    local value = tonumber(obj.Text)
                                    if value == nil then
                                        obj.Text = 1000
                                    end
                                    if value <= 0 then
                                        obj.Text = 100
                                        local teams = copy(vip.customSettings.GameRules.RuleSet.Teams)
                                        teams[1].Reinforcements = tonumber(obj.Text)
                                        teams[2].Reinforcements = tonumber(obj.Text)

                                        self.props.ruleSet("Teams", teams)
                                    elseif value > 20000 then
                                        obj.Text = 20000
                                        local teams = copy(vip.customSettings.GameRules.RuleSet.Teams)
                                        teams[1].Reinforcements = tonumber(obj.Text)
                                        teams[2].Reinforcements = tonumber(obj.Text)
    
                                        self.props.ruleSet("Teams", teams)

                                    end
                                end
                            })
                        };

                    });
                    Points = createSetting(self, theme, {
                        Title = "Starting Points";
                        Order = 4;
                        Description = "How many points each player starts with.";
                        Children = {
                            box = roact.createElement("TextBox",{
                                Size = UDim2.fromScale(.18,.4);
                                Position = UDim2.fromScale(0.7,0.1);
                                Font = theme.font;
                                TextScaled = true;
                                Text = vip.customSettings.GameRules.RuleSet.StartingPoints or "Enter Starter Points";
                                TextSize = 16;
                                Transparency = 0.1;
                                TextColor3 = theme.background;
                                BackgroundColor3 = theme.text;
                                [roact.Event.FocusLost] = function(obj, enterPressed)
                                    local value = tonumber(obj.Text)
                                    if value == nil then
                                        obj.Text = 100
                                    end
                                    if value < 0 then
                                        obj.Text = "0"
                                        self.props.ruleSet("StartingPoints", tonumber(obj.Text))
                                    else
                                        self.props.ruleSet("StartingPoints", tonumber(obj.Text))
                                    end
                                   
                                end
                            })
                        };
                    });
                    Time = createSetting(self, theme, {
                        Title = "Time of Day";
                        Order = 5;
                        Description = "Hour between 0-23 that changes ingame time.";
                        Children = {
                            box = roact.createElement("TextBox",{
                                Size = UDim2.fromScale(.18,.4);
                                Position = UDim2.fromScale(0.7,0.1);
                                Font = theme.font;
                                TextScaled = true;
                                Text = vip.customSettings.GameRules.RuleSet.ClockTime or "Enter Time";
                                TextSize = 16;
                                Transparency = 0.1;
                                TextColor3 = theme.background;
                                BackgroundColor3 = theme.text;
                                [roact.Event.FocusLost] = function(obj, enterPressed)
                                    local value = tonumber(obj.Text)
                                    if value == nil then
                                        obj.Text = 12
                                    end
                                    if value < 0 then
                                        obj.Text = "0"
                                        self.props.ruleSet("ClockTime", tonumber(obj.Text))
                                    elseif value > 23 then
                                        obj.Text = "23"
                                        self.props.ruleSet("ClockTime", tonumber(obj.Text))
                                    end
                                end
                            })
                        };
                    });
                    VehicleCap = createSetting(self, theme, {
                        Title = "Vehicle Caps:";
                        Order = 6;
                        Size = UDim2.new(.95,0,0,400);
                        TitleSize = UDim2.new(1,0,0,40);
                        DescriptionSize = UDim2.new(1,0,0,40);
                        DescriptionPos = UDim2.new(0,0.01,0,40);
                        Description = "Choose a custom cap of each vehicle type per team.";
                        Children = createSuperSetting(self, theme, {
                            Table = currentRules.BaseVehicleCaps;
                            Super = "BaseVehicleCaps";
                            Map = MAP_BASE_TO_NAME;
                            Min = 0;
                            Max = 25;
                        })
                        
                        
                        
                    });
                    VehiclePoint = createSetting(self, theme, {
                        Title = "Vehicle Point Cost Multipliers:";
                        Order = 7;
                        Size = UDim2.new(.95,0,0,400);
                        TitleSize = UDim2.new(1,0,0,40);
                        DescriptionSize = UDim2.new(1,0,0,40);
                        DescriptionPos = UDim2.new(0,0.01,0,40);
                        Description = "This multiplies the base cost of the specified vehicles";
                        Children = createSuperSetting(self, theme, {
                            Table = currentRules.VehiclePointCostMultipliers;
                            Super = "VehiclePointCostMultipliers";
                            Map = MAP_BASE_TO_NAME;
                            Min = 0;
                            Max = 25;
                        })
                        
                    });
                    World = createSetting(self, theme, {
                        Title = "World Settings";
                        Order = 8;
                        Size = UDim2.new(.95,0,0,400);
                        TitleSize = UDim2.new(1,0,0,40);
                        DescriptionSize = UDim2.new(1,0,0,40);
                        DescriptionPos = UDim2.new(0,0.01,0,40);
                        Description = "Contains water level, walkspeed, trees, and gravity control";
                        Children = createSuperSetting(self, theme, {
                            Table = currentRules.WorldSettings;
                            Super = "WorldSettings";
                            Map = MAP_WORLD_SETTING_TO_NAME;
                            Min = -1;
                            Max = 10;
                        })
                    });
                    NBZ = createSetting(self, theme, {
                        Title = "No Build Zone Off";
                        Order = 9;
                        Description = "This option will toggle No Build Zones off";
                        Children = {
                            button = roact.createElement("Frame",{
                                Size = UDim2.fromScale(.02,.02);
                                Position = UDim2.fromScale(0.9,0.1);
                                BackgroundColor3 =  theme.border;
                                Transparency = 0.5;
                            },{ 
                                inner = roact.createElement("TextButton",{
                                    Size = UDim2.fromScale(.6,.6);
                                    Position = UDim2.fromScale(0.2,0.2);
                                    Text = "";
                                    BorderSizePixel = 0;
                                    BackgroundColor3 = vip.customSettings.GameRules.RuleSet.NBZ and theme.text or theme.background;
                                    [roact.Event.Activated] = function()
                                        self.props.ruleSet("NBZ", not(vip.customSettings.GameRules.RuleSet.NBZ))
                                    end
                                });
                                constraint = roact.createElement("UISizeConstraint",{
                                    MinSize = Vector2.new(30,30);
                                })
                            });
                        }
                    });
--                    Godmode = createSetting(self, theme, {
--                        Title = "Enable invincibility";
--                        Order = 10;
--                        Description = "This option will toggle invincility on and prevent death";
--                        Children = {
--                            button = roact.createElement("Frame",{
--                                Size = UDim2.fromScale(.02,.02);
--                                Position = UDim2.fromScale(0.9,0.1);
--                                BackgroundColor3 =  theme.border;
--                                Transparency = 0.5;
--                            },{ 
--                                inner = roact.createElement("TextButton",{
--                                    Size = UDim2.fromScale(.6,.6);
--                                    Position = UDim2.fromScale(0.2,0.2);
--                                    Text = "";
--                                    BorderSizePixel = 0;
--                                    BackgroundColor3 = vip.customSettings.GameRules.RuleSet.Godmode and theme.text or theme.background;
--                                    [roact.Event.Activated] = function()
--                                        self.props.ruleSet("Godmode", not(vip.customSettings.GameRules.RuleSet.Godmode))
 --                                   end
 --                               });
 --                               constraint = roact.createElement("UISizeConstraint",{
 --                                   MinSize = Vector2.new(30,30);
 --                               })
 --                           });
--                        }
--                    });
-- character settings are not able to be changed easily, implement when character system allows for adjustments.
                }
            });
            serverTitle = createWidget(self, theme,{
                Size = UDim2.fromScale(0.45,0.1);
                Position = UDim2.fromScale(0.54,0.01);
                TextSize = UDim2.fromScale(0.25, 1);
                TextPosition = UDim2.fromScale(0,0);
                SettingSize = UDim2.fromScale(0.75, 1);
                SettingPosition = UDim2.fromScale(0.2,0);
                Text = "Name:";
                Type = "Frame";
                Children = {
                    button = roact.createElement("TextBox",{
                        Size = UDim2.fromScale(.9,1);
                        Position = UDim2.fromScale(0.1,0);
                        Font = theme.font;
                        TextScaled = true;
                        Text = vip.customSettings.ServerInfo;
                        TextColor3 = theme.background;
                        BackgroundColor3 = theme.text;
                        [roact.Event.FocusLost] = function(obj, enterPressed)
                 
                            self.props.customSet("ServerInfo", obj.Text)
                        end
                    });
                };
            });
            imageSetting = createWidget(self, theme,{
                Size = UDim2.fromScale(0.285,0.4);
                Position = UDim2.fromScale(0.54,0.12);
                TextSize = UDim2.fromScale(0.25, 0.5);
                TextPosition = UDim2.fromScale(0,0);
                SettingSize = UDim2.fromScale(0.75, 1);
                SettingPosition = UDim2.fromScale(0,0);
                Text = "Image:";
                Type = "Frame";
                Children = {
                    button = roact.createElement("TextBox",{
                        Size = UDim2.fromScale(0.4,0.1);
                        Position = UDim2.fromScale(0.58,0.05);
                        Font = theme.font;
                        TextScaled = true;
                        Text = "Image ID";
                        TextColor3 = theme.background;
                        BackgroundColor3 = theme.text;
                        [roact.Event.FocusLost] = function(obj, enterPressed)
                       
                            self.props.customSet("ServerIcon", "rbxassetid://"..obj.Text)
                        end
                    });
                    image = roact.createElement("ImageLabel",{
                        Size = UDim2.fromScale(1,0.8);
                        Position = UDim2.fromScale(0,0.22);
                        Image = vip.customSettings.ServerIcon;
                        BackgroundTransparency = 0.8;
                        BackgroundColor3 = theme.section;
                    });
                };
            });
            descSetting = createWidget(self, theme,{
                Size = UDim2.fromScale(0.285,0.4);
                Position = UDim2.fromScale(0.775,0.12);
                TextSize = UDim2.fromScale(0.25, 0.5);
                TextPosition = UDim2.fromScale(0,0);
                SettingSize = UDim2.fromScale(0.8, 0.8);
                SettingPosition = UDim2.fromScale(0,0.22);
                Text = "Description:";
                Type = "Frame";
                Children = {

                    container = roact.createElement("ScrollingFrame",{
                        Size = UDim2.fromScale(1,1);
                        Position = UDim2.fromScale(0,0);
                        BackgroundTransparency = 0.8;
                        BackgroundColor3 = theme.section;
                    },{
                        box = roact.createElement("TextBox",{
                            Size = UDim2.fromScale(.95,.98);
                            Position = UDim2.fromScale(0,0.01);
                            Font = theme.font;
                          --  TextScaled = true;
                            TextSize = 16;
                            LineHeight = 1.2;
                            Text = vip.customSettings.ServerDescription;
                            TextYAlignment = 0;
                            TextWrapped = true;
                            TextColor3 = theme.background;
                            BackgroundColor3 = theme.text;
                            [roact.Event.FocusLost] = function(obj, enterPressed)
                    
                                self.props.customSet("ServerDescription", obj.Text)
                            end
                        });
                    });
                };
            });
            accessSetting = createWidget(self, theme,{
                Size = UDim2.fromScale(0.45,0.4);
                Position = UDim2.fromScale(0.54,0.55);
                SettingPosition = UDim2.fromScale(0,0.32);
                TextSize = UDim2.fromScale(0.25, 1);
                SettingSize = UDim2.fromScale(1,0.8);
                Text = "Settings:";
                Type = "ScrollingFrame";
                Children = {
                    UILayout = roact.createElement("UIListLayout",{
                        SortOrder = 2;
                        Padding = UDim.new(0,10);
                        HorizontalAlignment = 0;
                    });
                    Gamemode = createSetting(self, theme, {
                        Title = "Gamemode";
                        Order = 1;
                        Description = "Choose the gamemode, may define some rules";
                        Children = {
                            box = roact.createElement("TextButton",{
                                Size = UDim2.fromScale(.18,.4);
                                Position = UDim2.fromScale(0.7,0.1);
                                Font = theme.font;
                                TextScaled = true;
                                Text = MAP_MODE_TO_NAME[vip.customSettings.GameRules.GameMode];
                                TextSize = 16;
                                Transparency = 0.1;
                                TextColor3 = theme.background;
                                BackgroundColor3 = theme.text;
                                [roact.Event.Activated] = function(obj)
                                
                                    --self.props.ruleSet("ClockTime", obj.Text)
                                    local content = obj:FindFirstChild("content")
                                    content.Visible = not(content.Visible);
                                end
                            },{
                                content = createDropdown(self, theme, {
                                    Size = UDim2.fromScale(0.95,2);
                                    Position = UDim2.fromScale(0,1);

                                    BackgroundColor3 = theme.section;
                                    Visible = false;
                                    Children = (function()
                                        local generated = {}
                                        local count = 1;
                                        for i, value in pairs(MAP_MODE_TO_NAME) do
                                            count +=1 ;
                                            generated[MAP_MODE_TO_NAME[i]] = createTextButton(self, theme, {
                                                Text = MAP_MODE_TO_NAME[i];
                                                TextColor = theme.text;
                                                Background = theme.section;
                                                Order = count;
                                                Bindable = function(obj)
                                                    obj.Parent.Visible = false;
                                                    self.props.modeSet(i)

                                                end;

                                            });
                                        end
                                            
                                        return generated
                                    
                                    end)()
                                })
                            
                            })
                        };
                    });
                    Map = createSetting(self, theme, {
                        Title = "Map:";
                        Order = 3;
                        Description = "Choose your starting map";
                        Children = {
                            box = roact.createElement("TextButton",{
                                Size = UDim2.fromScale(.18,.4);
                                Position = UDim2.fromScale(0.7,0.1);
                                Font = theme.font;
                                TextScaled = true;
                                Text = vip.customSettings.GameRules.RuleSet.Map;
                                TextSize = 16;
                                Transparency = 0.1;
                                TextColor3 = theme.background;
                                BackgroundColor3 = theme.text;
                                [roact.Event.Activated] = function(obj)
                            
                                    --self.props.ruleSet("ClockTime", obj.Text)
                                    local content = obj:FindFirstChild("content")
                                    content.Visible = not(content.Visible);
                                end
                            },{
                                content = createDropdown(self, theme, {
                                    Size = UDim2.fromScale(0.95,3);
                                    Position = UDim2.fromScale(0,1);

                                    BackgroundColor3 = theme.section;
                                    Visible = false;
                                    Children = (function()
                                        local generated = {}
                                        local count = 1;
                                        for i, value in pairs(MAPS) do
                                            count +=1 ;
                                            generated[MAPS[i]] = createTextButton(self, theme, {
                                                Text = MAPS[i];
                                                TextColor = theme.text;
                                                Background = theme.section;
                                                Order = count;
                                                Bindable = function(obj)
                                                    obj.Parent.Visible = false;
                                                    self.props.ruleSet("Map", obj.Text)

                                                end;

                                            });
                                        end
                                            
                                        return generated
                                    
                                    end)()
                                })

                            })
                        };
                    });
                };
            });
            container = roact.createElement("Frame",{
                Size = UDim2.fromScale(0.4,0.07);
                Position = UDim2.fromScale(0.6,0.92);
                BackgroundTransparency = 1;
            },{
                Layout = roact.createElement("UIListLayout",{
                    FillDirection = 0;
                    HorizontalAlignment = 2;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    Padding = UDim.new(0.01,0);
                });
                openPublic = createSetting(self, theme,{
                    Size = UDim2.fromScale(0.45,0.9);
                   -- Position = UDim2.fromScale(0.75,0.9);
                    Title = "Open to public";
                    Description = "";
                    Constraint = Vector2.new(0,10);
                    Children = {
                        button = roact.createElement("Frame",{
                            Size = UDim2.fromScale(.02,.02);
                            Position = UDim2.fromScale(0.7,0.2);
                            BackgroundColor3 =  theme.border;
                            Transparency = 0.5;
                        },{ 
                            inner = roact.createElement("TextButton",{
                                Size = UDim2.fromScale(.6,.6);
                                Position = UDim2.fromScale(0.2,0.2);
                                Text = "";
                                BorderSizePixel = 0;
                                BackgroundColor3 = vip.customSettings.Settings.Public and theme.text or theme.background;
                                [roact.Event.Activated] = function()
                                    if vip.customSettings.Settings.BoughtPublicHost == true then
                                        self.props.publicSet(not(vip.customSettings.Settings.Public))
                                    --self.props.ruleSet("UsesTimer", not(vip.customSettings.GameRules.RuleSet.UsesTimer))
                                    else
                                       -- do the purchase thing
                                  
                                        marketplaceService:PromptProductPurchase(Players.LocalPlayer, 541536383)
                                    end
                                end
                            });
                            constraint = roact.createElement("UISizeConstraint",{
                                MinSize = Vector2.new(30,30);
                            })
                        });
                    };
                });
                join = roact.createElement("TextButton",{
                    BackgroundColor3 = theme.text;
                    TextColor3 = theme.background;
                    Font = theme.font;
                    Text = self.props.serverType == "VIP" and "Join Custom Server" or "Apply Changes";
                    TextScaled = true;
                    Size = UDim2.fromScale(0.45,0.9);
                    --Position = UDim2.fromScale(0.89,0.9);
                    [roact.Event.Activated] = function(obj)
            
                        spawn(function()
                            if self.props.serverType == "VIP" then
                                obj.Text = "Joining!"
                                --if self.props.vip.customSettings.OwnerID == game.Players.LocalPlayer.UserId then
                                    local isReady = remotes.RequestVIPSettings:InvokeServer("SettingsUpdate", self.props.vip.customSettings);
                                    if isReady then
                                        remotes.RequestMatchmaking:FireServer();
                                    end
                                --else
                                --  remotes.RequestMatchmaking:FireServer();
                                --end
                                
                            else
                            
                                if Players.LocalPlayer.UserId == self.props.vip.customSettings.OwnerID then
                                    obj.Text = "Applying changes..."
                                  
                                    local isReady = remotes.RequestVIPSettings:InvokeServer("SettingsUpdate", self.props.vip.customSettings);
                                else
                                    obj.Text = "Not Owner"
                                end
                                wait(0.2)
                                obj.Text = "Apply Changes";
                            end
    
                        
                        end)
                    

                    end;
                },{
                    uicorner = roact.createElement("UICorner")
                })
            })
        })
    })



end

function Vip:didMount()

end

return roactRodux.connect(mapStateToProps, mapDispatchToProps)(Vip)