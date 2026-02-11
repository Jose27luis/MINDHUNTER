local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Crear GUI de Daño
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DamageGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local flashFrame = Instance.new("Frame")
flashFrame.Name = "RedFlash"
flashFrame.Size = UDim2.new(1, 0, 1, 0)
flashFrame.Position = UDim2.new(0, 0, 0, 0)
flashFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
flashFrame.BackgroundTransparency = 1
flashFrame.BorderSizePixel = 0
flashFrame.Parent = screenGui

-- Sonido de latido/golpe
local damageSound = Instance.new("Sound")
damageSound.Name = "DamageSound"
damageSound.SoundId = "rbxassetid://12221976" -- Sonido de golpe clasico
damageSound.Volume = 0.5
damageSound.Parent = screenGui

local function onCharacterAdded(char)
	local humanoid = char:WaitForChild("Humanoid")
	local lastHealth = humanoid.Health
	
	humanoid.HealthChanged:Connect(function(health)
		if health < lastHealth then
			-- Recibio daño
			damageSound:Play()
			
			-- Flash Rojo
			flashFrame.BackgroundTransparency = 0.5
			TweenService:Create(flashFrame, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {BackgroundTransparency = 1}):Play()
		end
		lastHealth = health
	end)
end

if player.Character then
	onCharacterAdded(player.Character)
end

player.CharacterAdded:Connect(onCharacterAdded)
