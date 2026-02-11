local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Estado del sistema
local stamina = Config.STAMINA_MAX
local isRunning = false
local lastRunTime = 0

-- UI Stamina Bar
local playerGui = player:WaitForChild("PlayerGui")
local hud = playerGui:WaitForChild("HUD", 5) or Instance.new("ScreenGui", playerGui)
hud.Name = "HUD"
hud.ResetOnSpawn = false

local staminaFrame = Instance.new("Frame")
staminaFrame.Name = "StaminaBarContainer"
staminaFrame.Size = UDim2.new(0.3, 0, 0.02, 0)
staminaFrame.Position = UDim2.new(0.35, 0, 0.92, 0) -- Abajo al centro
staminaFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
staminaFrame.BorderSizePixel = 2
staminaFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
staminaFrame.Parent = hud

local staminaFill = Instance.new("Frame")
staminaFill.Name = "Fill"
staminaFill.Size = UDim2.new(1, 0, 1, 0)
staminaFill.BackgroundColor3 = Color3.fromRGB(255, 255, 50) -- Amarillo
staminaFill.BorderSizePixel = 0
staminaFill.Parent = staminaFrame

-- Actualizar referencia del personaje al morir
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = newChar:WaitForChild("Humanoid")
	stamina = Config.STAMINA_MAX
	isRunning = false
end)

-- Detectar Shift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.LeftShift then
		isRunning = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		isRunning = false
	end
end)

-- Loop principal
RunService.Heartbeat:Connect(function(dt)
	if not humanoid then return end

	-- Verificar movimiento
	local isMoving = humanoid.MoveDirection.Magnitude > 0
	
	-- Leer stats de la Clase actual (o usar default del Config)
	local runSpeed = player:GetAttribute("RunSpeed") or Config.WALK_SPEED_RUN
	local walkSpeed = player:GetAttribute("WalkSpeed") or Config.WALK_SPEED_NORMAL
	local staminaMax = player:GetAttribute("StaminaMax") or Config.STAMINA_MAX

	-- Logica de drenado
	if isRunning and isMoving and stamina > 0 then
		-- Corriendo
		humanoid.WalkSpeed = runSpeed
		stamina = math.max(0, stamina - (Config.STAMINA_DRAIN_RATE * dt))
		lastRunTime = tick()
		
		-- Efecto de cansancio (jadeo visual o FOV si quisieramos)
	else
		-- Caminando o parado
		humanoid.WalkSpeed = walkSpeed
		
		-- Regeneracion con delay
		if tick() - lastRunTime > Config.STAMINA_REGEN_DELAY then
			stamina = math.min(staminaMax, stamina + (Config.STAMINA_REGEN_RATE * dt))
		end
	end

	-- Actualizar UI
	local goalScale = stamina / staminaMax
	staminaFill.Size = UDim2.new(goalScale, 0, 1, 0)
	
	-- Color del Fill cambio segun cansancio
	if goalScale < 0.2 then
		staminaFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- Rojo si esta vacio
	else
		staminaFill.BackgroundColor3 = Color3.fromRGB(255, 255, 50) -- Amarillo normal
	end
	
	-- Ocultar si esta lleno (opcional, aqui siempre visible para feedback)
	staminaFrame.Visible = true 
end)
