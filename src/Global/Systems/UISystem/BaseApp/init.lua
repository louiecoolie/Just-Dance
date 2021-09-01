-- base app that will be wrapped by context and hold the entire library of components which should be bound to update through roact-rodux 
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local lighting = game:GetService("Lighting")
-- external stuff
local gameShared = ReplicatedStorage:WaitForChild("GameShared")
local util = gameShared:WaitForChild("Util")

--modules
local roactRodux = require(util:WaitForChild("Roact-Rodux"))
local roact = require(util:WaitForChild("Roact"))

--components
local components = script.Components
local context = require(components:FindFirstChild("Context"))
local vehicleLoadout = require(components:FindFirstChild("Loadout"))
local topBar = require(components:FindFirstChild("Topbar"))
local page = require(components:FindFirstChild("Page"))


--camera settingsData
local existingLightingAssets = lighting:GetChildren()
local loadoutLightingSettings = gameShared:WaitForChild("SharedAssets"):WaitForChild("Loadout"):WaitForChild("Lighting"):Clone():GetChildren()

local BaseApp = roact.Component:extend("BaseApp")

-- rodux methods

local function mapStateToProps(state)
    local cameraSettings = state.playerHandler.Camera
    return {
        camType = cameraSettings.camType;
        fov = cameraSettings.fov;
        exposure = cameraSettings.exposure;
        position = cameraSettings.position;
        specular = cameraSettings.specular;
        lighting = cameraSettings.lighting;
        open = state.playerHandler.Lobby.currentOpen;
        serverType = state.playerHandler.ServerType;
        themeType = state.playerHandler.Theme.Current;
    }
end

local function mapDispatchToProps(dispatch)
    return {

    }
end





function BaseApp:init()
 
    self.loadoutEnabled, self.toggleLoadout = roact.createBinding(false)

end

function BaseApp:render()

    if (game.PlaceId == 7175796352) then -- if base app for lobby then
        for i = 1, #existingLightingAssets do
            existingLightingAssets[i].Enabled = self.props.lighting
        end
        for i = 1, #loadoutLightingSettings do
            loadoutLightingSettings[i].Parent = nil
        end

        lighting.EnvironmentSpecularScale = self.props.specular
        lighting.ExposureCompensation = self.props.exposure

    --goBack()

        local camera = workspace.CurrentCamera
        camera.CameraType = self.props.camType;
        camera.FieldOfView = self.props.fov
        camera.CFrame = self.props.position
    else
        game.Players.LocalPlayer.PlayerGui.HudApp.Enabled = false
        game.Players.LocalPlayer.PlayerGui.HurtOverlay.Enabled = false
   
    end
        

    local topbar = context.with(function(theme)
        return roact.createElement(topBar, {
            theme = theme;
        })
    
    end)

    local lobbyPage = context.with(function(theme)
        return roact.createElement(page, {
            theme = theme;
            open = self.props.open;
        })
    
    end)
  
    return roact.createElement(context.Provider,{
        value = self.props.themeType;
    },{
    
        BaseApp = roact.createElement("ScreenGui", {
            IgnoreGuiInset = true;
            ResetOnSpawn = true;
            DisplayOrder = 10;
        }, { -- children

            Topbar = topbar;
            Page = lobbyPage;

        })
    })
end

function BaseApp:didMount()


    game:GetService("UserInputService").LastInputTypeChanged:Connect(function(input)
       
        if input == Enum.UserInputType.Gamepad1 then
            GuiService.SelectedObject = game.Players.LocalPlayer.PlayerGui:FindFirstChild("BaseApp").Topbar.Play
        else
            GuiService.SelectedObject = nil
        end
    end)

    if (game.PlaceId == 7175796352) then -- if lobby place then
        if not (self.props.serverType == "VIP") then
            game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
        end

        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
    end
end

function BaseApp:willUnmount()
    GuiService.SelectedObject = nil
end


return roactRodux.connect(mapStateToProps, mapDispatchToProps)(BaseApp)
