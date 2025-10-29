local Movement = {}
Movement.__index = Movement

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Settings = {
    Flight = {
        Enabled = false,
        Speed = 50
    },
    Speed = {
        Enabled = false,
        Value = 50
    }
}

function Movement.new()
    local self = setmetatable({}, Movement)
    self.Connections = {}
    self.BodyVelocity = nil
    return self
end

function Movement:ToggleFlight()
    Settings.Flight.Enabled = not Settings.Flight.Enabled
    
    if Settings.Flight.Enabled then
        local Character = LocalPlayer.Character
        if not Character then return end
        
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if not HumanoidRootPart then return end
        
        self.BodyVelocity = Instance.new("BodyVelocity")
        self.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        self.BodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
        self.BodyVelocity.Parent = HumanoidRootPart
        
        table.insert(self.Connections, RunService.Heartbeat:Connect(function()
            if not self.BodyVelocity then return end
            
            local direction = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 1, 0)
            end
            
            self.BodyVelocity.Velocity = direction.Unit * Settings.Flight.Speed
        end))
    else
        if self.BodyVelocity then
            self.BodyVelocity:Destroy()
            self.BodyVelocity = nil
        end
    end
end

function Movement:ToggleSpeed()
    Settings.Speed.Enabled = not Settings.Speed.Enabled
    
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return end
    
    if Settings.Speed.Enabled then
        Humanoid.WalkSpeed = Settings.Speed.Value
    else
        Humanoid.WalkSpeed = 16
    end
end

function Movement:CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local FlightButton = Instance.new("TextButton")
    local SpeedButton = Instance.new("TextButton")
    
    ScreenGui.Parent = game.CoreGui
    Frame.Parent = ScreenGui
    
    Frame.Size = UDim2.new(0, 200, 0, 60)
    Frame.Position = UDim2.new(0, 120, 0, 10)
    Frame.BackgroundColor3 = Color3.new(0, 0, 0)
    
    FlightButton.Size = UDim2.new(0.45, 0, 0.8, 0)
    FlightButton.Position = UDim2.new(0.025, 0, 0.1, 0)
    FlightButton.Text = "FLIGHT: OFF"
    FlightButton.TextColor3 = Color3.new(1, 1, 1)
    FlightButton.BackgroundColor3 = Color3.new(1, 0, 0)
    FlightButton.Parent = Frame
    
    SpeedButton.Size = UDim2.new(0.45, 0, 0.8, 0)
    SpeedButton.Position = UDim2.new(0.525, 0, 0.1, 0)
    SpeedButton.Text = "SPEED: OFF"
    SpeedButton.TextColor3 = Color3.new(1, 1, 1)
    SpeedButton.BackgroundColor3 = Color3.new(1, 0, 0)
    SpeedButton.Parent = Frame
    
    FlightButton.MouseButton1Click:Connect(function()
        self:ToggleFlight()
        FlightButton.Text = "FLIGHT: " .. (Settings.Flight.Enabled and "ON" or "OFF")
        FlightButton.BackgroundColor3 = Settings.Flight.Enabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    end)
    
    SpeedButton.MouseButton1Click:Connect(function()
        self:ToggleSpeed()
        SpeedButton.Text = "SPEED: " .. (Settings.Speed.Enabled and "ON" or "OFF")
        SpeedButton.BackgroundColor3 = Settings.Speed.Enabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    end)
end

function Movement:Activate()
    self:CreateGUI()
    
    table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.F then
            self:ToggleFlight()
        elseif input.KeyCode == Enum.KeyCode.V then
            self:ToggleSpeed()
        end
    end))
end

return Movement.new()
