local module = {}

local Events
local Cast = require(game:GetService("ReplicatedStorage").Cast)

local moduleConnection
local currentHitBox
--local debug = true

local function hitDebug(Position)
    local part = Instance.new("Part", workspace)
    part.Size = Vector3.new(1,1,1)
    part.Position = Position
    part.Anchored = true
    part.CanCollide = false
end

function module.ActivateWeapon()
    local Tool = game:GetService("Players").LocalPlayer.Character:WaitForChild("weapon")
    Tool:WaitForChild("weaponRootPart").Anchored = false
    local ignoreToolParts = {}

    for _, part in pairs(Tool:GetChildren()) do
        if part:IsA("Part") then
            ignoreToolParts[#ignoreToolParts+1] = part
        end
    end

    local newHitbox = Cast:Initialize(Tool:FindFirstChild("boundary"), ignoreToolParts)
    newHitbox:PartMode(true)
    --newHitbox:DebugMode(true)
    if moduleConnection then moduleConnection:Disconnect() end


    moduleConnection = newHitbox.OnHit:Connect(function(hit, hum, raycastResult)
       

        if not(hit.Name == "RaycastHitboxDebugPart") then
            if not(hit.Parent and (hit.Parent.Parent == game:GetService("Players").LocalPlayer.Character or hit.Parent == game:GetService("Players").LocalPlayer.Character)) then
                Events.weapon_request:FireServer(hit, Tool.boundary.particlePoint.WorldPosition)

            end
        end

    end)

    currentHitBox = newHitbox

end

function module.init(events)
    Events = events

    Events.weapon_request.OnClientEvent:Connect(function(Tool)
        module.ActivateWeapon()

    end)
end

function module.activate()
    currentHitBox:HitStart()
end

function module.stop()
    currentHitBox:HitStop()
end


return module