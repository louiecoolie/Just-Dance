

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

end

function Shop:render()
   
    local theme = self.props.theme;



    return roact.createElement("TextButton",{
        Size = UDim2.fromScale(0.2,0.1);
        Position = UDim2.fromScale(0.7,0.3);
        BackgroundTransparency = 1;
        TextSize = 24;
        Text = "Coming soon..";
        TextColor3 = theme.text;
        Font = theme.font;
    })

end

function Shop:didMount()

end

function Shop:willUnmount()


end

return roactRodux.connect(mapStateToProps, mapDispatchToProps)(Shop)





