
local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Roact = require(ReplicatedStorage:WaitForChild("Roact"))
local Otter = require(ReplicatedStorage:WaitForChild("Otter"))
local Events
local Modules


local PlayerGui = Players.LocalPlayer.PlayerGui

local Interface = Roact.Component:extend("CharacterSelection")

local componentHandle
local characterList
local characterRefs = {}
local connections = {}
local characterSlots
local slotRefs = {}
local slotDefaults = {}
local gridData = {
    collumn = 0,
    row = 0
}
local circle_spring = {
    dampingRatio = 0.01;
    frequency = 0.0005;
}
local Gui = workspace.CharacterSelection.Gui




local function createGrid(gridPos, gridAnchor, gridSize, maxCollumn, padding)
    if gridData.collumn < maxCollumn then
        if gridData.collumn == 0 then
            local pos = gridAnchor * CFrame.new((-gridSize.X *(gridData.row)), (-gridSize.Y * (gridData.collumn)),0)
            gridData.collumn = gridData.collumn + 1
            return pos
        else
            local pos = gridAnchor * CFrame.new((-gridSize.X *(gridData.row*(1+padding))), (-gridSize.Y * (gridData.collumn*(1+padding))),0)
            gridData.collumn = gridData.collumn + 1
            return pos
        end
    elseif gridData.collumn >= maxCollumn then
        gridData.collumn = 0
        gridData.row = gridData.row + 1
        local pos = gridAnchor * CFrame.new((-gridSize.X *(gridData.row*(1+padding))), (-gridSize.Y * (gridData.collumn)),0)
        gridData.collumn = gridData.collumn + 1
        return pos
    end
end

local function createSelection(properties)
--local a = game.StarterGui.ScreenGui.Frame.ViewportFrame;
-- a.bean:SetPrimaryPartCFrame(CFrame.new(0,0,0)); a.CurrentCamera.CFrame  = CFrame.new(-.5,1.6,-2.5); 
--a.CurrentCamera.CFrame = CFrame.new(a.CurrentCamera.CFrame.Position,( a.bean.PrimaryPart.Position+Vector3.new(0,1.7,0)));
   -- characterRefs
    characterRefs[properties.ref] = Roact.createRef()
    --properties.component.ref = Roact.createRef()
    return Roact.createElement("SurfaceGui",{
      -- Adornee = slotRefs[properties.ref]:getValue()
    },{

        character = Roact.createElement("ImageButton",{
            Size = UDim2.new(1,0,1,0),
            Image = "rbxassetid://6103351509",
            BackgroundTransparency = 1,

    
        },{
            viewport = Roact.createElement("ViewportFrame",{
                Size = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
                [Roact.Ref] = characterRefs[properties.ref]
            })
        })
    })


    
    


end

local function createCharacter(properties)
    --assert(properties.characterList, "Character list does not exist or an error occured receiving the list")
    local characterSelections = {}
    for key, character in pairs(properties.characters) do
        characterSelections[key] = Roact.createElement(createSelection, {
            ref = character,

        })
    end

    return Roact.createFragment(
        characterSelections
    )
end

local function createSlot(properties)
    slotRefs[properties.ref] = Roact.createRef()
    --properties.component.ref = Roact.createRef()
    local defaults = {
        CFrame = properties.pos,
    }

    slotDefaults[properties.ref] = defaults
    return Roact.createElement("Part",{
        [Roact.Ref] = slotRefs[properties.ref],
        Size = Gui.slotPos.Size + Vector3.new(0,0,.2),
        CFrame = properties.pos,
        Anchored = true,
        Transparency = 1,
    })
end

local function createSlots(properties)
    local slots = {}
    for key, character in pairs(properties.slots) do
        slots[key] = Roact.createElement(createSlot, {
            ref = character,
            pos = createGrid(key, Gui.slotPos.CFrame, Gui.slotPos.Size, 3, 0.1)

        })
    end

    return Roact.createFragment(
        slots
    )

end

function Interface:init()


    self.characterSelectionActive, self.updateSelectionActive = Roact.createBinding(false)
    self.background = Roact.createRef()
    self.backgroundImg = Roact.createRef()
    self.title = Roact.createRef()
    self.titleText = Roact.createRef()
    self.beanButton = Roact.createRef()
end

function Interface:render()
    return Roact.createElement("ScreenGui", {
        IgnoreGuiInset = true
    },{
        portal = Roact.createElement(Roact.Portal, {
            target = workspace
        },{
            background = Roact.createElement("Part",{
                [Roact.Ref] = self.background,
                Size = Gui.backgroundPos.Size,
                CFrame = Gui.backgroundPos.CFrame,
                Transparency = 1,
                Anchored = true
            }),
            title = Roact.createElement("Part",{
                [Roact.Ref] = self.title,
                Size = Gui.titlePos.Size,
                CFrame = Gui.titlePos.CFrame,
                Transparency = 1,
                Anchored = true
            }),
            slots = Roact.createElement(createSlots,{
                slots = characterList
            }),
        }),

        background = Roact.createElement("SurfaceGui",{
            [Roact.Ref] = self.backgroundImg
        },{
            Roact.createElement("ImageLabel",{
                Size = UDim2.new(1,0,1,0),
                Image = "rbxassetid://6170180545",
                BackgroundTransparency = 1,
            })
        }),

        title = Roact.createElement("SurfaceGui",{
            [Roact.Ref] = self.titleText,
            SizingMode = "PixelsPerStud"
        },{
            text = Roact.createElement("TextLabel",{
                Size = UDim2.new(1,0,1,0),
                Text = "Select Skin",
                TextScaled = true,
                BackgroundTransparency = 1
            })
        }),

        characterButton = Roact.createElement("ImageButton", {
            [Roact.Ref] = self.beanButton,
            Size = UDim2.new(0.1, 0, 0.1,0),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.01, 0, 0.5,0),
            Image = "rbxassetid://6103241942",
            SizeConstraint = Enum.SizeConstraint.RelativeXX,
            [Roact.Event.Activated] = function()

                if self.characterSelectionActive:getValue() == false then
                    self.updateSelectionActive(true)
                    workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
                    local depth = Instance.new("DepthOfFieldEffect", workspace.CurrentCamera)
                    local color = Instance.new("ColorCorrectionEffect", workspace.CurrentCamera)

                    workspace.CurrentCamera.FieldOfView = 86.816
                    workspace.CurrentCamera.CFrame = workspace.CharacterSelection.beanCamera.CFrame

                    depth.FarIntensity = 0.335
                    depth.FocusDistance = 0
                    depth.InFocusRadius = 12.715
                    depth.NearIntensity = 1

                    color.Brightness = 0.1
                    color.Contrast = 0.1
                    color.Saturation = 0.2
                    color.TintColor = Color3.fromRGB(255,255,246)

                else
                    self.updateSelectionActive(false)
                    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
                    for _, object in pairs(workspace.CurrentCamera:GetChildren()) do object:Destroy() end

                end
            end,
        }),
        characterSelection = Roact.createElement("Frame",{
            Size = UDim2.new(1,0,.1,0),
            Position = UDim2.new(0,0,.8,0),
            BackgroundTransparency = 1,
            Visible = self.characterSelectionActive
        },{
            layout = Roact.createElement("UIListLayout",{
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
            }),
            characters = Roact.createElement(createCharacter, {
                characters = characterList,
    
            }),
        })
    })
end

function Interface:didMount()
    for key, ref in pairs(characterRefs) do
        local viewframe = ref:getValue()
        local characterModel = key:Clone()
        local selectionCamera = Instance.new("Camera")

        characterModel.Parent = viewframe
        characterModel.PrimaryPart = characterModel:FindFirstChild("Body")
        selectionCamera.Parent = viewframe
        viewframe.CurrentCamera = selectionCamera

        characterModel:SetPrimaryPartCFrame(CFrame.new(0,0,0)); 
        viewframe.CurrentCamera.CFrame  = CFrame.new(-.5,1.6,-2.5); 
        viewframe.CurrentCamera.CFrame = CFrame.new(viewframe.CurrentCamera.CFrame.Position,(characterModel.PrimaryPart.Position+Vector3.new(0,1.7,0)));
       -- slotRefs[key]:getValue():Destroy()
        viewframe.Parent.Parent.Adornee = slotRefs[key]:getValue()

        connections[#connections+1] = viewframe.Parent.Activated:Connect(function()
            Events["update_skin"]:FireServer(characterModel.Name)
            self.updateSelectionActive(false)
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            for _, object in pairs(workspace.CurrentCamera:GetChildren()) do object:Destroy() end
           -- module.stop()
            --if connections[characterModel] then connections[characterModel]:stop() end

        end)
        connections[#connections+1] = viewframe.Parent.InputBegan:Connect(function()
            if not( connections[characterModel]) then
                connections[characterModel] = Otter.createSingleMotor(0)
                connections[characterModel]:setGoal(Otter.spring(0.5,{1,0.25}))
                connections[characterModel]:onStep(function(height)
                    slotRefs[key]:getValue().CFrame = slotDefaults[key].CFrame * CFrame.new(0, height, 0)
                end)
                connections[characterModel]:onComplete(function(callback)
                    slotRefs[key]:getValue().CFrame = slotDefaults[key].CFrame
                    connections[characterModel] = nil
                end)
               
            end
        end)
    end

    self.backgroundImg:getValue().Adornee = self.background:getValue()
    self.titleText:getValue().Adornee = self.title:getValue()
    
end

function Interface:willUnmount()
  --  self.background:getValue():Destroy()
  --  self.title:getValue():Destroy()

end


function module.init(modules, events, characters)

    Modules = modules
    Events = events
    characterList = characters

    componentHandle = Roact.mount(Roact.createElement(Interface), PlayerGui, "Character Selection")
end

function module.stop()
    if componentHandle then
        Roact.unmount(componentHandle)
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        for _, object in pairs(workspace.CurrentCamera:GetChildren()) do object:Destroy() end
        
        for k, v in pairs(characterRefs) do
            characterRefs[k] = nil
        end
        for k, v in pairs(characterRefs) do
            characterRefs[k] = nil
        end
        for k, v in pairs(connections) do
            if v then
                local success, response = pcall(function()
                    v:Disconnect()
                end)

                assert(success, response)
            end
            connections[k] = nil
        end
        for k, v in pairs(slotRefs) do
            slotRefs[k] = nil
        end

        gridData = {
            collumn = 0,
            row = 0
        }

        for k, v in pairs(slotDefaults) do
            slotDefaults[k] = nil
        end

        componentHandle = nil
    end

end




return module