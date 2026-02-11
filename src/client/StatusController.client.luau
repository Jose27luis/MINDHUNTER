local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local statusValue = ReplicatedStorage:WaitForChild("Status", 10)
local timeValue = ReplicatedStorage:WaitForChild("Time", 10)

if not statusValue or not timeValue then 
	warn("StatusController: No se encontraron valores de estado.")
	return 
end

local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- Crear GUI Superior
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StatusGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = pGui

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0.05, 0) -- 5% altura
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
topBar.BackgroundTransparency = 0.5
topBar.BorderSizePixel = 0
topBar.Parent = screenGui

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusText"
statusLabel.Size = UDim2.new(0.8, 0, 1, 0)
statusLabel.Position = UDim2.new(0.1, 0, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Text = statusValue.Value
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Parent = topBar

-- Actualizar texto
statusValue.Changed:Connect(function(val)
	statusLabel.Text = val
end)

-- (Opcional) Animacion de alerta si el texto cambia a algo critico
