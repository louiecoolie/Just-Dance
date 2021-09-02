

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


local Shop = roact.Component:extend("Shop")

--animations

local TWEEN_IN_SPRING = {
    frequency = 5,
    dampingRatio = 1
}

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


-- component methods



function Shop:init()
    self.visualizer = roact.createRef()
end

function Shop:render()
   
    local theme = self.props.theme;



    return roact.createElement("Frame",{
        Size = UDim2.fromScale(0.2,0.2);
        Position = UDim2.fromScale(0.4,0.4);
        BackgroundTransparency = 0.7;
        BackgroundColor3 = theme.background;
        SizeConstraint = Enum.SizeConstraint.RelativeXX;
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
            BackgroundTransparency = 0.8;
            BackgroundColor3 = theme.section;
            SizeConstraint = Enum.SizeConstraint.RelativeXX;
            [roact.Ref] = self.visualizer
        },{
            corner = roact.createElement("UICorner",{
                CornerRadius = UDim.new(1,0);
            });
        })
    })

end

function Shop:didMount()
    self.connection = RunService.Heartbeat:Connect(function()
        if game:GetService("SoundService"):FindFirstChild("Sound").isPlaying then
            local sound =  game:GetService("SoundService"):FindFirstChild("Sound")
            self.visualizer:getValue().Size = UDim2.fromScale(1+(sound.PlaybackLoudness/500), 1+(sound.PlaybackLoudness/500))
   
        end
    
    end)
end

function Shop:willUnmount()


end

return roactRodux.connect(mapStateToProps, mapDispatchToProps)(Shop)





