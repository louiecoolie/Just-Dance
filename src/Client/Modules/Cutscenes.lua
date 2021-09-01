-- module to handle the cutscene state, in which camera is not controlled by the player
-- to be used primarily for meetings

-- cutscene mode has to be on or off, and when enabled must be given an initial orientation

local RunService: RunService = game:GetService("RunService")

local Players: Players = game:GetService("Players")
local player: Player = Players.LocalPlayer

-- privates
local unfadeCallback = nil
local cameraTweenCallback = nil

local sin = math.sin
local halfPi = math.pi/2

local function easingFunction(x: number)
    -- go for sin^2(xpi/2)
    return sin(x*halfPi)^2
end

local Cutscene = {}
Cutscene.__index = Cutscene

function Cutscene:StartCutscene(initialCF: CFrame, fadeToBlack: boolean):((number) -> void)
    if not self.Enabled then
        self.Enabled = true

        local callback:(number) -> void
        if fadeToBlack then
            callback = self:FadeToBlack()
        end

        -- gain camera control
        local cam: Camera = self.Camera
        cam.CameraType = Enum.CameraType.Scriptable
        cam.CFrame = initialCF

        -- return unfade callback if exists
        return callback
    end
end

function Cutscene:EndCutscene(fadeToBlack: boolean):((number) -> void)
    if self.Enabled then
        local callback:(number) -> void
        if fadeToBlack then
            callback = self:FadeToBlack(0.5)
        end
        
        if self.Interpolating then -- cancel camera movement if exists
            cameraTweenCallback()
        end

        -- restore camera control to the player
        local cam: Camera = self.Camera
        cam.CameraType = Enum.CameraType.Custom
        cam.CameraSubject = self.Player.Character and self.Player.Character:FindFirstChildOfClass("Humanoid")

        self.Enabled = false
        return callback
    end
end

function Cutscene:FadeToBlack(fadeInTime: number):((number) -> void)
    if not self.Enabled then return end

    -- if already faded, return the existing callback
    if not self.Faded then
        self.Faded = true

        -- create fade gui
        local gui: ScreenGui = Instance.new("ScreenGui")
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 10

        local frame: Frame = Instance.new("Frame")
        frame.BackgroundTransparency = 1
        frame.BackgroundColor3 = Color3.new(0,0,0)
        frame.BorderSizePixel = 0
        frame.Size = UDim2.new(1,0,1,0)

        frame.Parent = gui
        gui.Parent = self.Player.PlayerGui

        -- fade to black
        local function fade(fadeTime: number, direction: boolean)
            
            local rate: number = 1.0/fadeTime
            local startTime: number = tick()
            local complete: boolean = false
            repeat
                local t: number = tick()
                local progress: number = math.clamp(easingFunction(rate*(t-startTime)),0,1)
                frame.BackgroundTransparency = direction and (1.0-progress) or progress
                if (t-startTime) >= fadeTime or complete then
                    complete = true
                end
                
                RunService.RenderStepped:Wait()
            until complete
        end

        fade(fadeInTime or 0.5, true)
        unfadeCallback = function(fadeTime: number)
            fade(fadeTime, false)
            self.Faded = false
            unfadeCallback = nil

            frame:Destroy()
            gui:Destroy()
        end
    end
    return unfadeCallback
end

function Cutscene:MoveCamera(destination: CFrame, time: number):((number) -> void)
    if not self.Enabled then return end

    if self.Interpolating then
        -- cancel current interpolation using the callback we have, then start a new one using the current location
        cameraTweenCallback()
    end

    local cam: Camera = self.Camera
    local intitialCF: CFrame = cam.CFrame
    local complete: boolean = false

    if time == 0 then -- if time is 0, just instantly set to destination and return
        cam.CFrame = destination
        return
    end
    
    local rate: number = 1.0/time
    local startTime: number = tick()
    local function update(delta: number)
        -- lerp cam
        if not complete then
            local t: number = tick()
            local progress: number = math.clamp(easingFunction(rate*(t-startTime)),0,1)
            cam.CFrame = intitialCF:Lerp(destination, progress)
            if (t-startTime) >= time or complete then
                cameraTweenCallback() -- end interpolation
            end
        end
    end

    RunService:BindToRenderStep("CutsceneCameraInterpolation", Enum.RenderPriority.Camera.Value+1, update)
    self.Interpolating = true

    -- either async or return a callback that is
    cameraTweenCallback = function()
        RunService:UnbindFromRenderStep("CutsceneCameraInterpolation")
        complete = true
        self.Interpolating = false
        cameraTweenCallback = nil
    end
    return cameraTweenCallback
end

function Cutscene.new()
    local self = {
        Enabled = false;
        Faded = false;
        Interpolating = false;
        Player = player;
        Camera = workspace.CurrentCamera;
    }

    return setmetatable(self, Cutscene)
end

-- create cutscene singleton
return Cutscene.new()