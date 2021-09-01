local bone = workspace.Player1.Meanie.Body.LowerTorso.Spine.RightWrist;
local weapon = workspace.Player1.weapon;
weapon:SetPrimaryPartCFrame( bone.TransformedWorldCFrame*CFrame.new(0.2,.1,0.2)*CFrame.Angles(math.rad(190), math.rad(75),math.rad(90)));

local hatbone = workspace.Player1.Meanie.Body.LowerTorso.Spine.Neck;

local hat = workspace.Player1.hat;
hat.CFrame = hatbone.TransformedWorldCFrame*CFrame.new(0.1,.2,-0.18)*CFrame.Angles(math.rad(90), math.rad(0),math.rad(90));


local hatbone = workspace.Player1.Meanie.Body.LowerTorso.Spine.Neck;
local toy = workspace.Player1.toy;
toy.CFrame = hatbone.TransformedWorldCFrame*CFrame.new(0.1,.2,-0.18)*CFrame.Angles(math.rad(90), math.rad(0),math.rad(90));