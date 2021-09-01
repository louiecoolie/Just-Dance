local Tool = {}

local ClientEvents = game:GetService("ReplicatedStorage"):WaitForChild("Events", 60)

local Events = {}

for _, event in ipairs(ClientEvents:GetChildren()) do
    ClientEvents:WaitForChild(event.Name, 5)

end

for _, event in ipairs(ClientEvents:GetChildren()) do
	Events[event.Name] = event
	
end


local function GetMousePoint(mouse_ray)
	local RayMag1 = mouse_ray
	local NewRay = Ray.new(RayMag1.Origin, RayMag1.Direction * 1000)
	local Target, Position = workspace:FindPartOnRay(NewRay)
	return Target, Position
end


function Tool.Inspect(action, input_state, input_object)
    if input_state == Enum.UserInputState.Begin then
        
        local forage_ray =  workspace.CurrentCamera:ScreenPointToRay(input_object.Position.X, input_object.Position.Y)
        local inspect, inspect_location = GetMousePoint(forage_ray)

        if inspect and inspect.Parent then
            if inspect.Parent.Parent:FindFirstChild("game_value") then
        
                Events["inspect_request"]:FireServer(inspect.Parent.Parent:FindFirstChild("game_value").Value,inspect.Parent.Parent)
            end
            
            if inspect.Parent:FindFirstChild("game_value") then
     
                Events["inspect_request"]:FireServer(inspect.Parent:FindFirstChild("game_value").Value,inspect.Parent)
            end
        end
    end
end

function Tool.MobileInspect(position, processed_ui)

	local unitRay = workspace.CurrentCamera:ViewportPointToRay(position[1].X, position[1].Y)
	local ray = Ray.new(unitRay.Origin, unitRay.Direction * 500)
    local inspect, inspect_location = game.Workspace:FindPartOnRay(ray)
    

    if inspect.Parent.Parent:FindFirstChild("game_value") then
   
        Events["inspect_request"]:FireServer(inspect.Parent.Parent:FindFirstChild("game_value").Value,inspect.Parent.Parent)
    end
    
    if inspect.Parent:FindFirstChild("game_value") then
    
        Events["inspect_request"]:FireServer(inspect.Parent:FindFirstChild("game_value").Value,inspect.Parent)
    end

        
end



function Tool.ChoosePlayer(action, input_state, input_object)
    if input_state == Enum.UserInputState.Begin then
        
        local forage_ray =  workspace.CurrentCamera:ScreenPointToRay(input_object.Position.X, input_object.Position.Y)
        local inspect, inspect_location = GetMousePoint(forage_ray)

        if inspect and inspect.Parent then
            if inspect.Parent.Parent:IsA("Model") then
               if inspect.Parent.Parent:FindFirstChild("Humanoid") then
      
                    Events["vote_request"]:FireServer(inspect.Parent.Parent.Name) 
               end
               --Events["inspect_request"]:FireServer(inspect.Parent.Parent:FindFirstChild("game_value").Value,inspect.Parent.Parent)
            end
            
            if inspect.Parent:IsA("Model") then
                if inspect.Parent:FindFirstChild("Humanoid") then
                    Events["vote_request"]:FireServer(inspect.Parent.Name)
                end
                --Events["inspect_request"]:FireServer(inspect.Parent:FindFirstChild("game_value").Value,inspect.Parent)
            end
        end
        
        if inspect and inspect.Parent and inspect.Parent.Parent then
            if inspect.Parent.Parent.Parent:IsA("Model") then
                if inspect.Parent.Parent.Parent:FindFirstChild("Humanoid") then
                    Events["vote_request"]:FireServer(inspect.Parent.Parent.Parent.Name) 
                
               --Events["inspect_request"]:FireServer(inspect.Parent.Parent:FindFirstChild("game_value").Value,inspect.Parent.Parent)
                end
            end
        end
    end
end

function Tool.MobileChoosePlayer(position, processed_ui)

	local unitRay = workspace.CurrentCamera:ViewportPointToRay(position[1].X, position[1].Y)
	local ray = Ray.new(unitRay.Origin, unitRay.Direction * 500)
    local inspect, inspect_location = game.Workspace:FindPartOnRay(ray)
    

    if inspect and inspect.Parent then
        if inspect.Parent.Parent:IsA("Model") then
           if inspect.Parent.Parent:FindFirstChild("Humanoid") then
  
                Events["vote_request"]:FireServer(inspect.Parent.Parent.Name) 
           end
           --Events["inspect_request"]:FireServer(inspect.Parent.Parent:FindFirstChild("game_value").Value,inspect.Parent.Parent)
        end
        
        if inspect.Parent:IsA("Model") then
            if inspect.Parent:FindFirstChild("Humanoid") then
                Events["vote_request"]:FireServer(inspect.Parent.Name)
            end
            --Events["inspect_request"]:FireServer(inspect.Parent:FindFirstChild("game_value").Value,inspect.Parent)
        end
    end
    
    if inspect and inspect.Parent and inspect.Parent.Parent then
        if inspect.Parent.Parent.Parent:IsA("Model") then
            if inspect.Parent.Parent.Parent:FindFirstChild("Humanoid") then
                Events["vote_request"]:FireServer(inspect.Parent.Parent.Parent.Name) 
            
           --Events["inspect_request"]:FireServer(inspect.Parent.Parent:FindFirstChild("game_value").Value,inspect.Parent.Parent)
            end
        end
    end
        
end

function Tool.PlayMouse(input_object)  
        local forage_ray =  workspace.CurrentCamera:ScreenPointToRay(input_object.Position.X, input_object.Position.Y)
        local inspect, inspect_location = GetMousePoint(forage_ray)

        if inspect and inspect.Parent then
            if inspect.Parent.Parent:IsA("Model") then
               if inspect.Parent.Parent:FindFirstChild("PlayObject") then
                    return inspect.Parent.Parent
             
               end
            
            end
            
            if inspect.Parent:IsA("Model") then
                if inspect.Parent:FindFirstChild("PlayObject") then
                   return inspect.Parent
                end
               
            end
        end
        
        if inspect and inspect.Parent and inspect.Parent.Parent then
            if inspect.Parent.Parent.Parent:IsA("Model") then
                if inspect.Parent.Parent.Parent:FindFirstChild("PlayObject") then
     
                    return inspect.Parent.Parent.Parent
        
                end
            end
        end
end

function Tool.PlayMobile(position, processed_ui)

	local unitRay = workspace.CurrentCamera:ViewportPointToRay(position[1].X, position[1].Y)
	local ray = Ray.new(unitRay.Origin, unitRay.Direction * 500)
    local inspect, inspect_location = game.Workspace:FindPartOnRay(ray)
    

    if inspect and inspect.Parent then
        if inspect.Parent.Parent:IsA("Model") then
           if inspect.Parent.Parent:FindFirstChild("PlayObject") then
                return inspect.Parent.Parent
         
           end
        
        end
        
        if inspect.Parent:IsA("Model") then
            if inspect.Parent:FindFirstChild("PlayObject") then
               return inspect.Parent
            end
           
        end
    end
    
    if inspect and inspect.Parent and inspect.Parent.Parent then
        if inspect.Parent.Parent.Parent:IsA("Model") then
            if inspect.Parent.Parent.Parent:FindFirstChild("PlayObject") then
 
                return inspect.Parent.Parent.Parent
    
            end
        end
    end
        
end


return Tool