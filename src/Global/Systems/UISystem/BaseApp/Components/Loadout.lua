local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lighting = game:GetService("Lighting")
-- external stuff
local gameShared = ReplicatedStorage:WaitForChild("GameShared")
local util = gameShared:WaitForChild("Util")

local existingLightingAssets = lighting:GetChildren()
local loadoutLightingSettings = gameShared:WaitForChild("SharedAssets"):WaitForChild("Loadout"):WaitForChild("Lighting"):Clone():GetChildren()

--modules
local roactRodux = require(util:WaitForChild("Roact-Rodux"))
local roact = require(util:WaitForChild("Roact"))


local Loadout = roact.Component:extend("Loadout")

-- rodux methods

local function mapStateToProps(state)
    return {
        loadout = state.playerHandler.Loadout;
        test = state.playerHandler.Test;
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

    }
end

-- component methods


function Loadout:init()
    
    local function loadoutLoadInProcedure(loadout)
       

        self.props.cameraToggle(70, CFrame.new(0,0,0), 1, 1, Enum.CameraType.Scriptable, false)
    
        
    end
    
    local function loadoutReturnProcedure(loadout)

        self.props.cameraToggle(40, workspace.Terrain.CameraPosition.WorldCFrame, 0, 0, Enum.CameraType.Scriptable, true)
    

    end

    self.props.loadout:SetLoadingProcedures(loadoutLoadInProcedure, loadoutReturnProcedure)
end

function Loadout:render()
    local theme = self.props.theme

    return roact.createElement("TextButton", {
        BackgroundColor3 = theme.background;
        Size = UDim2.fromScale(.1,.1);
        Position = UDim2.fromScale(0.6,0);
        BackgroundTransparency = 0.5;
        TextColor3 = theme.text;
        Text = self.props.test;
        [roact.Event.Activated] = function()
        
            self.props.loadout:Enable()
        end
    },{

    })
end



return roactRodux.connect(mapStateToProps, mapDispatchToProps)(Loadout)