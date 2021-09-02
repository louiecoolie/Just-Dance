
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rs = game:GetService("RunService")
local GuiService = game:GetService("GuiService")


--modules
local util = ReplicatedStorage.Vendor
local roactRodux = require(util:WaitForChild("Roact-Rodux"))
local roact = require(util:WaitForChild("Roact"))
--animation modules
local flipper = require(util:WaitForChild("Flipper"))
local spring = flipper.Spring

--components
local components = script.Components
local context = require(components:FindFirstChild("Context"))
local hud = require(components:FindFirstChild("Hud"))


local BaseApp = roact.Component:extend("BaseApp")

-- rodux methods

local function mapStateToProps(state)

    return {

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

    local gameHud = context.with(function(theme)
        return roact.createElement(hud, {
            theme = theme;
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

            Hud = gameHud;

        })
    })
end

function BaseApp:didMount()

end

function BaseApp:willUnmount()
  
end


return roactRodux.connect(mapStateToProps, mapDispatchToProps)(BaseApp)
