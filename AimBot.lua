local AimBot = {}
AimBot.__index = AimBot

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    Enabled = true,
    TeamCheck = false,
    WallCheck = true,
    Smoothness = 0.15,
    FOV = 120,
    Prediction = 0.136,
    HeightOffset = 1.5,
    Keybind = "Q"
}

function AimBot.new()
    local self = setmetatable({}, AimBot)
    self.Target = nil
    self.Connections = {}
    return self
end

function AimBot:GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                if Settings.TeamCheck and player.Team == LocalPlayer.Team then
                    continue
                end
                
                local screenPoint, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                    
                    if distance < Settings.FOV and distance < shortestDistance then
                        if Settings.WallCheck then
                            local raycast = Ray.new(
                                Camera.CFrame.Position,
                                (rootPart.Position - Camera.CFrame.Position).Unit * 1000
                            )
                            local hit, position = workspace:FindPartOnRayWithIgnoreList(raycast, {LocalPlayer.Character})
                            
                            if hit and hit:IsDescendantOf(player.Character) then
                                closestPlayer = player
                                shortestDistance = distance
                            end
                        else
                            closestPlayer = player
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

function AimBot:AimAtTarget()
    if not self.Target or not self.Target.Character then return end
    
    local rootPart = self.Target.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local targetPosition = rootPart.Position
    
    if Settings.Prediction > 0 then
        local velocity = rootPart.Velocity * Settings.Prediction
        targetPosition = targetPosition + velocity
    end
    
    local currentCFrame = Camera.CFrame
    local targetCFrame = CFrame.lookAt(
        currentCFrame.Position,
        targetPosition + Vector3.new(0, Settings.HeightOffset, 0)
    )
    
    Camera.CFrame = currentCFrame:Lerp(targetCFrame, Settings.Smoothness)
end

function AimBot:CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local Toggle = Instance.new("TextButton")
    
    ScreenGui.Parent = game.CoreGui
    Frame.Parent = ScreenGui
    Toggle.Parent = Frame
    
    Frame.Size = UDim2.new(0, 100, 0, 30)
    Frame.Position = UDim2.new(0, 10, 0, 10)
    Frame.BackgroundColor3 = Color3.new(0, 0, 0)
    
    Toggle.Size = UDim2.new(1, 0, 1, 0)
    Toggle.Text = "AIM: ON"
    Toggle.TextColor3 = Color3.new(1, 1, 1)
    Toggle.BackgroundColor3 = Color3.new(0, 1, 0)
    
    Toggle.MouseButton1Click:Connect(function()
        Settings.Enabled = not Settings.Enabled
        Toggle.Text = "AIM: " .. (Settings.Enabled and "ON" or "OFF")
        Toggle.BackgroundColor3 = Settings.Enabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    end)
end

function AimBot:Initialize()
    self:CreateGUI()
    
    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        if not Settings.Enabled then return end
        
        self.Target = self:GetClosestPlayer()
        if self.Target then
            self:AimAtTarget()
        end
    end))
    
    table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode[Settings.Keybind] then
            Settings.Enabled = not Settings.Enabled
        end
    end))
end

return AimBot.new()
