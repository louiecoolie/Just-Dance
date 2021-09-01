--[[
This is a complete example of Roact-Rodux that will create a 
TextButton that will increment its text when its .Activated event is fired!

1) Put Roact, Rodux and RoactRodux in ReplicatedStorage
2) Paste this script in a LocalScript
]]

--Init
local PlayerGui = game.Players.LocalPlayer.PlayerGui
local RS = game:GetService("ReplicatedStorage")
local Roact = require(RS:WaitForChild("Roact"))
local Rodux = require(RS:WaitForChild("Rodux"))
local RoactRodux = require(RS:WaitForChild("RoactRodux"))

--Rodux creates our store:
local function reducer(state, action)
	state = state or {
		value = 0,
	}
	if action.type == "increment" then
		return {
			value = state.value+1
		}
	end
	return state
end

local store = Rodux.Store.new(reducer)

--Roact creates our component:
local function MyComponent(props)
	--Roact.createElement(ClassName, {Class Properties}, [{Children}])
	return Roact.createElement("ScreenGui", {}, {
		Roact.createElement("TextButton", {
			Text = props.value,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 500, 0, 200),
			ZIndex = 0,

			[Roact.Event.Activated] = props.onClick,
		})
	})
end

--`RoactRodux.connect([mapStateToProps, [mapDispatchToProps]])` returns a function that we can pass our plain Roact component `MyComponent` created above as an argument, returning a new RoactRodux-connected component as our new `MyComponent` variable
MyComponent = RoactRodux.connect(
	function(state, props) 	--`mapStateToProps` accepts our store's state and returns props
		return {
			value = state.value,
		}
	end,
	function(dispatch) 		--`mapDispatchToProps` accepts a dispatch function and returns props
		print("RoactRodux mapDispatchToProps has run.")
		return {
			onClick = function()
				dispatch({
					type = "increment",
				})
			end,
		}
	end
)(MyComponent) --Here we are passing in our plain Roact component as an argument to RoactRodux.connect(...)
--`MyComponent` should now return a RoactRodux-connected component, which will update and re-render any time the store is changed.

--Here we will wrap a RoactRodux StoreProvider at the top of our Roact component tree. This will make our store readable to the elements & components below it via 
local app = Roact.createElement(RoactRodux.StoreProvider, {
	store = store,
}, {
	Main = Roact.createElement(MyComponent), --Due to the limitations of Roact, we can only have ONE(1) child under a StoreProvider element, so we have to call MyComponent to get the rest of the children. The Store will be passed to MyComponent as arguments.
})

--Roact will now put our app on the screen
Roact.mount(app, PlayerGui, "My Test App")