local module = {}

local offset = {
    Default = CFrame.new(0.1,.2,-0.18)*CFrame.Angles(math.rad(90), math.rad(0),math.rad(90)),
    Sword = CFrame.new(0.1,.2,-0.18)*CFrame.Angles(math.rad(90), math.rad(0),math.rad(90)),
    AncientBlade = CFrame.new(0.1,.2,-0.18)*CFrame.Angles(math.rad(90), math.rad(0),math.rad(90)),
    NeonBlade = CFrame.new(0.1,.2,-0.18)*CFrame.Angles(math.rad(90), math.rad(0),math.rad(90)),
    NeonHammer = CFrame.new(0.8,.3,-0.18)*CFrame.Angles(math.rad(90), math.rad(0),math.rad(90)),
    Fists =  CFrame.new(0.1,.2,-0.18)*CFrame.Angles(math.rad(90), math.rad(0),math.rad(90)),
    Rapier = CFrame.new(0.1,.2,-0.18)*CFrame.Angles(math.rad(90), math.rad(0),math.rad(90)),
}



function module.AccessLibrary(equip)
    if not(offset[equip] == nil) then
        return offset[equip]
    else
        return offset["Default"]
    end
end

return module