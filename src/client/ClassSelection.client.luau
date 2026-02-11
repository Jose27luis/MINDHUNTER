local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Config = require(ReplicatedStorage.Shared.Config)

local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")
local remote = ReplicatedStorage:WaitForChild("SelectClass")

-- Crear GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ClassSelectionGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = pGui

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0.4, 0, 0.5, 0)
frame.Position = UDim2.new(0.3, 0, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
frame.Visible = false -- Solo visible en Lobby
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Text = "SELECT YOUR CLASS"
title.Size = UDim2.new(1, 0, 0.15, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = frame
listLayout.Padding = UDim.new(0, 10)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.VerticalAlignment = Enum.VerticalAlignment.Center

-- Generar botones
for className, data in pairs(Config.CLASSES) do
	local btn = Instance.new("TextButton")
	btn.Name = className
	btn.Size = UDim2.new(0.9, 0, 0.2, 0)
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = className .. ": " .. data.Description .. " (HP: " .. data.MaxHealth .. ")"
	btn.Font = Enum.Font.Gotham
	btn.TextScaled = true
	btn.Parent = frame
	
	btn.MouseButton1Click:Connect(function()
		remote:FireServer(className)
		-- Feedback local
		for _, child in ipairs(frame:GetChildren()) do
			if child:IsA("TextButton") then
				child.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			end
		end
		btn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Verde seleccionado
	end)
end

-- Mostrar/Ocultar segun estado del juego
local statusValue = ReplicatedStorage:WaitForChild("Status")

statusValue.Changed:Connect(function(val)
	if val == "Esperando jugadores..." or val:match("La partida comienza") then
		frame.Visible = true
	else
		frame.Visible = false
	end
end)

-- Check inicial
if statusValue.Value == "Esperando jugadores..." or statusValue.Value:match("La partida comienza") then
	frame.Visible = true
end
