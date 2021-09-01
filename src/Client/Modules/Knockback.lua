
local module = {}


local Events 

local connection = nil

local function createKnockback(value, origin, type)
    print(value)
    local hit = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
    local Debris = game:GetService("Debris")
    
    local reaction = Instance.new("BodyVelocity")
    local reactionDirection = CFrame.new(origin, hit.Position)
  -- local xVector = hit.Position.X - origin.x * 1.5
  ----  local zVector = hit.Position.Z - origin.Z * 1.5
   -- local yVector = (hit.Position.Y - origin.Z)*1.2

    --hit:SetPrimaryPartCFrame(hit.HumanoidRootPart.CFrame*CFrame.new(0,1,0))
    --reaction.Velocity = Vector3.new(xVector, yVector, zVector).Unit * value
    reaction.Velocity = (reactionDirection.lookVector + Vector3.new(0,1,0)) * value
    reaction.MaxForce = Vector3.new(99999,99999,99999)
    reaction.Parent = hit
    

    Debris:AddItem(reaction, 0.4)

end


function module.init(events)
    Events = events

    if connection == nil then
        connection = Events.knockback.OnClientEvent:Connect(createKnockback)
    end

end




return module