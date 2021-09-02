-- base app that will be wrapped by context and hold the entire library of components which should be bound to update through roact-rodux 
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")



--modules
local util = ReplicatedStorage.Vendor
local roactRodux = require(util:WaitForChild("Roact-Rodux"))
local roact = require(util:WaitForChild("Roact"))

--components
local components = script.Components
local context = require(components:FindFirstChild("Context"))
local shop = require(components:FindFirstChild("Shop"))


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

    local gameShop = context.with(function(theme)
        return roact.createElement(gameShop, {
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

            Shop = gameShop;

        })
    })
end

function BaseApp:didMount()

end

function BaseApp:willUnmount()
  
end


return roactRodux.connect(mapStateToProps, mapDispatchToProps)(BaseApp)
