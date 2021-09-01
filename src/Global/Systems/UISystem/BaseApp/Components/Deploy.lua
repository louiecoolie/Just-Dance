local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- external stuff
local gameShared = ReplicatedStorage:WaitForChild("GameShared")
local rs = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local util = gameShared:WaitForChild("Util")

--modules
local roactRodux = require(util:WaitForChild("Roact-Rodux"))
local roact = require(util:WaitForChild("Roact"))
--animation modules
local flipper = require(util:WaitForChild("Flipper"))
local roactFlipper = require(util:WaitForChild("Roact-Flipper"))
local spring = flipper.Spring

--migrated assets
local common = ReplicatedStorage:WaitForChild("Common")
local commonAssets = common:WaitForChild("Assets")
local remotes = commonAssets:WaitForChild("Remotes")
-- migrated remotes
local getGameInfo = remotes:WaitForChild("GetGameInfo")
local requestRespawn = remotes:WaitForChild("RequestRespawn")

local Deploy = roact.Component:extend("Deploy")

--animations

local TWEEN_IN_SPRING = {
    frequency = 5,
    dampingRatio = 1
}
local allowTweening = true
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

-- game methods

local function tweenCamera(location)
	local cam = workspace.CurrentCamera
	if cam and allowTweening then
		rs:UnbindFromRenderStep("SpawnViewTween")
		
		cam.CameraType = "Scriptable"
		local origCF = cam.CFrame
	
		local startTime = tick()
		
		local speed = 750
		local dist = (location.p-origCF.p).Magnitude
		local tweenTime = math.clamp(dist/speed, 1, 2)
		
		local tweenFunc = function(delta)
			local passedTime = tick()-startTime
			local percentageComplete = passedTime/tweenTime
			local tweenCF = origCF:Lerp(location, percentageComplete)
			cam.CFrame = tweenCF
			
			if passedTime >= tweenTime then
				rs:UnbindFromRenderStep("SpawnViewTween")
				cam.CFrame = location
			end
		end
		rs:BindToRenderStep("SpawnViewTween", Enum.RenderPriority.Camera.Value+1, tweenFunc)
	end
end

local function tweenNone(self)
    local loc = self.state.baseViewLocations[game.Players.LocalPlayer.TeamColor.Name]
    if loc then
        tweenCamera(loc)
    end
end

local function requestSpawn(self, loc)

    if allowTweening then
		allowTweening = false
		rs:UnbindFromRenderStep("SpawnViewTween")
	end

    rs:UnbindFromRenderStep("SpawnViewTween")
	workspace.CurrentCamera.CameraType = "Custom"
   
	local spawned = requestRespawn:InvokeServer({Objective = loc})
    if spawned then
        self.deploy = false;
    else
        allowTweening = true;
    end

    game.Players.LocalPlayer.PlayerGui.DeploymentMenu.Main.DeploymentMain.LoadoutSelection.Visible = false;

end

-- component methods


local function createSpawn(self, theme, props)
   
    return roact.createElement("Frame",{
        Size = UDim2.fromScale(1,0.2);
        BackgroundColor3 = theme.background;
        BackgroundTransparency = 0.2;
    },{
        Deploy = roact.createElement("TextButton",{
            Text = "";--props.Name;
            Font = Enum.Font.GothamBlack;
          --  BackgroundTransparency = 0;
            BackgroundColor3 = props.Owner and props.Owner.Color or Color3.new(1,1,1);
           -- TextSize = 24
            TextScaled = true;
            LayoutOrder = props.Order;
            TextColor3 = theme.background;
            BorderSizePixel = 0;
            ZIndex = 20;
            Size = props.Size or UDim2.fromScale(0.2,1);
            Position = props.Position or UDim2.fromScale(0.8,0);
            [roact.Event.Activated] = function(obj)
                if props.Owner == self.state.team and not props.Cooldown then
                    requestSpawn(self, props.Name)
                end


            end;
            [roact.Event.InputBegan] = function(obj)

                local loc = props.ViewLocations[game.Players.LocalPlayer.TeamColor.Name]
                print(loc)
                if loc then
                    if ((props.Owner and props.Owner.Color) and game.Players.LocalPlayer.TeamColor == props.Owner) then
                        tweenCamera(loc)
                    end
                end

            end;
            [roact.Event.InputEnded] = function(obj)
                tweenNone(self)

            end;
        });
        Description = roact.createElement("TextLabel",{
            Text = props.Name;
            Font = theme.font;
            TextColor3 = theme.text;
            BackgroundTransparency = 1;
            Size = UDim2.fromScale(0.6, 1);
            TextSize = 18;
        });
        Status = roact.createElement("TextLabel",{
            Text = self.state.bindings[props.Order];
            Font = theme.font;
            TextColor3 = theme.text;
            BackgroundTransparency = 1;
            Size = UDim2.fromScale(0.2, 1);
            Position = UDim2.fromScale(0.6,0);
            TextSize = 18;  
        })
    });
end


function Deploy:init()
    self.deploy = true;
    allowTweening = true;

    spawn(function()
        local spawns, baseViewLocations = getGameInfo:InvokeServer("GetSpawnableObjectives")

        if  game.Players.LocalPlayer.PlayerGui.DeploymentMenu.Main.DeploymentMain:FindFirstChild("LoadoutSelection") then
            game.Players.LocalPlayer.PlayerGui.DeploymentMenu.Main.DeploymentMain:FindFirstChild("LoadoutSelection").Visible = true;
        end

        

        local bindMap = {}
        local setMap = {}

        for i, spawn in pairs(spawns) do 
            local value = ((spawn.Owner and spawn.Owner.Color) and game.Players.LocalPlayer.TeamColor == spawn.Owner) and "Ready" or "--";
            local binding, Setter = roact.createBinding(value)
            bindMap[i] = binding
            setMap[i] = Setter
        end

        self:setState({
            deploy = true;
            team = game.Players.LocalPlayer.TeamColor;
            spawns = spawns;
            baseViewLocations = baseViewLocations;
            bindings = bindMap;
            setters = setMap;
        })

        tweenNone(self)
    end)
end

function Deploy:render()
   
    local theme = self.props.theme;
    local children = {}
    children["layout"] = roact.createElement("UIListLayout",{
        SortOrder = Enum.SortOrder.LayoutOrder;
        Padding = UDim.new(0.01,0);
    });

    if self.state.spawns then
  
        for i, props in pairs(self.state.spawns) do
            props["Order"] = i
            children[i] = createSpawn(self, theme, props)
        end
        
    end


    return roact.createElement("Frame",{
        Size = UDim2.fromScale(0.4,0.3);
        Position = UDim2.fromScale(0.4,0.4);
        BackgroundTransparency = 1;
    }, 
        children
    )

end

function Deploy:didMount()

        -- get this stuff every few seconds or so
        coroutine.wrap(function()
        
            while self.deploy do
                wait(1)
 
                local spawns, baseViewLocations = getGameInfo:InvokeServer("GetSpawnableObjectives")
         

                
                for i, spawn in pairs(spawns) do 
                    if spawn.Cooldown then
                        self.state.setters[i](math.ceil(spawn.Cooldown))
                    else
                        local value = ((spawn.Owner and spawn.Owner.Color) and game.Players.LocalPlayer.TeamColor == spawn.Owner) and "Ready" or "--";
                        self.state.setters[i](value)
                    end
                   
                end
                local success, error = pcall(self.setState, self, (function()
                    return {
                        spawns = spawns;
                        baseViewLocations = baseViewLocations;
           
                    }
                end))
            end
        end)()
end

function Deploy:willUnmount()

    self.deploy = false -- mutate state here to kill coroutine if we are paging somewhere else.
end

return roactRodux.connect(mapStateToProps, mapDispatchToProps)(Deploy)
