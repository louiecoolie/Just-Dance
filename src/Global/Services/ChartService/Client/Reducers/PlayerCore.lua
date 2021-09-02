local ReplicatedStorage = game:GetService("ReplicatedStorage")

--modules
local util = ReplicatedStorage.Vendor
local rodux = require(util:WaitForChild("Rodux"))

local function copy(list)
    if list then
        local copy = {}
        for key, value in pairs(list) do
            copy[key] = value
        end
        return copy
    end
end
-- return a client reducer
return rodux.createReducer({
    Loadout = {};
    Camera = {
        position = (game.PlaceId == 7175796352) and workspace.Terrain.CameraPosition.WorldCFrame or workspace.CurrentCamera.CFrame;
        camType = Enum.CameraType.Scriptable;
        fov = 40;
        specular = 0;
        exposure = 0;
        lighting = true;
    };
    CurrentSquad = {};
    Lobby = {
        currentOpen =   (game.PlaceId == 7175796352) and "PLAY" or "DEPLOY";
    };
    SquadSetting = {
        AllowMemberInvites = false;
        AllowFriendJoins = false;
        SquadTag = "";
    };
    PlaySetting = {
        PreferredMode = "Build and Battle";
        PreferredMap = "Any";
        Population = "Small";
        SearchDevBranch = false;
		IncludeSlowServers = true;
		IncludeSoftban = false;
		CustomFilter = "Official"; -- false is offical, true is custom vip
		FullFilter = false; -- dont include full servers
		EmptyFilter = true; 
    };
    Settings = {
        Navigation = {
            tabRight = {Enum.KeyCode.A, Enum.KeyCode.ButtonR1};
            tabLeft = {Enum.KeyCode.D, Enum.KeyCode.ButtonL1};
        }
    };
    ServerType =  (game.PlaceId == 7175796352) and "Lobby" or "Server";
    Friends = {
        Ingame = {};
        Online = {};
    };
    TagEnabled = false;
    VIP = {
        isOwner = false;
        customSettings = {
            
        };
    };
    Theme = {
        Current = "darkTheme";
    };
    Filter = {
        SearchDevBranch = false;
        PreferredMap = "Any";
        PreferredMode = "Any";
		IncludeSlowServers = true;
		IncludeSoftban = false;
		CustomFilter = "Any";
		FullFilter = true; 
		EmptyFilter = true;
    };
    Servers = {};
    GameRules = {};
},{
    GetFriendsOnline = function(state, action)
        local newState = copy(state)

        newState.Test = action.Test
        
        return newState
    end,
    GetLoadout = function(state, action)
        local newState = copy(state) 

        newState.Loadout = action["loadout"]
        
        return newState
    end,
    ToggleCamera = function(state, action)

        local newState = copy(state) 

        newState.Camera.position = action.position;
        newState.Camera.fov = action.fov;
        newState.Camera.specular = action.specular;
        newState.Camera.exposure = action.exposure;
        newState.Camera.camType = action.camType;
        newState.Camera.lighting = action.lighting;
        
        return newState
    end,
    ToggleLobby = function(state, action)
        local newState = copy(state)

        newState.Lobby.currentOpen = action.toggleTo

        return newState

    end,
    ChangePlaySetting = function(state, action)
        local newState = copy(state) 
        newState.PlaySetting = copy(state.PlaySetting)

        if not(newState.PlaySetting[action.setting] == nil) then
            newState.PlaySetting[action.setting] = action.value
        else
            warn("passed an invalid setting")
        end

        return newState

    end,
    GetFriends = function(state, action)
        local newState = copy(state) 
        newState.Friends = copy(state.Friends)
        
        newState.Friends.Ingame = action.Ingame
        newState.Friends.Online = action.Online

        return newState
    end,
    SetFilter = function(state, action)
        local newState = copy(state)
        newState.Filter = copy(state.Filter)

        if not(newState.Filter[action.setting] == nil) then
            newState.Filter[action.setting] = action.value
        else
            warn("passed an invalid setting")
        end

        return newState
    end,
    SetSquad = function(state, action)
        local newState = copy(state)
        newState.SquadSetting = copy(state.SquadSetting)

        if not(newState.SquadSetting[action.setting] == nil) then
            newState.SquadSetting[action.setting] = action.value
        else
            warn("passed an invalid setting")
        end

        return newState
    end,
    SetServers = function(state, action)
        local newState = copy(state)
        newState.Servers = action.servers

        return newState
    end,
    TagPurchased = function(state, action)
        local newState = copy(state) 
        newState.TagEnabled = action.value

        return newState;

    end,
    ServerType = function(state, action)
        local newState = copy(state) 
        newState.ServerType = action.value
        return newState;
    end,
    GetSquad = function(state, action)
        local newState = copy(state)
        newState.CurrentSquad = action.squad 

        return newState
    end,
    GetVIPSetting = function(state, action)

        local newState = copy(state)
        newState.VIP = copy(state.VIP)

        newState.VIP.isOwner = action.isOwner;
        newState.VIP.customSettings = action.customSettings;

        return newState
    end,
    SetVIPSetting = function(state, action)
        print(action, state, "vip set")
        local newState = copy(state)
        newState.VIP = copy(state.VIP)
        newState.VIP.customSettings = copy(state.VIP.customSettings) -- no mutation >:()
        
        newState.VIP.customSettings[action.setting] = action.value

        return newState

    end,
    SetRuleSetting = function(state, action)
        print(action, state)
        local newState = copy(state)
        newState.VIP = copy(state.VIP)
        newState.VIP.customSettings = copy(state.VIP.customSettings) -- no mutation >:()
        newState.VIP.customSettings.GameRules = copy(state.VIP.customSettings.GameRules)
        newState.VIP.customSettings.GameRules.RuleSet = copy(state.VIP.customSettings.GameRules.RuleSet) -- >:(  )

        newState.VIP.customSettings.GameRules.RuleSet[action.setting] = action.value

        return newState
    end,
    SetTeams = function(state, action)
        local newState = copy(state)
        newState.VIP = copy(state.VIP)
        newState.VIP.customSettings = copy(state.VIP.customSettings) -- no mutation >:()
        newState.VIP.customSettings.GameRules = copy(state.VIP.customSettings.GameRules)
        newState.VIP.customSettings.GameRules.RuleSet = copy(state.VIP.customSettings.GameRules.RuleSet) -- >:(  )

        newState.VIP.customSettings.GameRules.RuleSet.Teams[action.setting].Preset = action.value

        return newState


    end,
    SetMode= function(state, action)
        local newState = copy(state)
        newState.VIP = copy(state.VIP)
        newState.VIP.customSettings = copy(state.VIP.customSettings) -- no mutation >:()
        newState.VIP.customSettings.GameRules = copy(state.VIP.customSettings.GameRules)
       
        newState.VIP.customSettings.GameRules.GameMode = action.value

        local setting = newState.GameRules[action.value].RuleSet
        local default = newState.GameRules[action.value].ServerInfo 
        
        newState.VIP.customSettings.ServerDescription = default.ServerDescription
        newState.VIP.customSettings.ServerIcon = default.ServerIcon
        newState.VIP.customSettings.ServerInfo = default.ServerInfo

       -- print(setting)

        newState.VIP.customSettings.GameRules.RuleSet = setting

        return newState


    end,
    GameRules = function(state, action)
        local newState = copy(state) 
        newState.GameRules = action.value

        return newState
    end,
    SetSuper = function(state, action)
        local newState = copy(state)
        newState.VIP = copy(state.VIP)
        newState.VIP.customSettings = copy(state.VIP.customSettings) -- no mutation >:()
        newState.VIP.customSettings.GameRules = copy(state.VIP.customSettings.GameRules)
        newState.VIP.customSettings.GameRules.RuleSet = copy(state.VIP.customSettings.GameRules.RuleSet) -- >:(  )

        newState.VIP.customSettings.GameRules.RuleSet[action.super][action.setting] = action.value

        return newState
    end,
    UpdateSetting = function(state, action)
        local newState = copy(state)
        newState.Settings = copy(state.Settings)
        newState.Settings[action.tree] = copy(state.Settings[action.tree])

        newState.Settings[action.tree][action.setting][action.key] = action.value

        return newState
    end,
    UpdateTheme = function(state, action)
        local newState = copy(state)
        newState.Theme = copy(state.Theme)

        newState.Theme[action.setting] = action.value;

        return newState
    end,
    ServerHost = function(state, action)
        local newState = copy(state)
        newState.VIP = copy(state.VIP)
        newState.VIP.customSettings = copy(state.VIP.customSettings) -- no mutation >:()
        newState.VIP.customSettings.Settings = copy(state.VIP.customSettings.Settings)

        newState.VIP.customSettings.Settings.BoughtPublicHost = action.value
        newState.VIP.customSettings.Settings.Public = action.value

        return newState
    end,
    PublicSetting = function(state, action)
   
        local newState = copy(state)
        newState.VIP = copy(state.VIP)
        newState.VIP.customSettings = copy(state.VIP.customSettings) -- no mutation >:()
        newState.VIP.customSettings.Settings = copy(state.VIP.customSettings.Settings)

        newState.VIP.customSettings.Settings.Public = action.value

        return newState
    end,



    

})

