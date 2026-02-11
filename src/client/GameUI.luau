local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameUI = {}

local player = Players.LocalPlayer
local screenGui: ScreenGui = nil
local healthBar: Frame = nil
local healthFill: Frame = nil
local keyLabel: TextLabel = nil
local messageLabel: TextLabel = nil

-- Crear la interfaz
local function createUI()
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GameHUD"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = player.PlayerGui

	-- === BARRA DE VIDA ===
	local healthContainer = Instance.new("Frame")
	healthContainer.Name = "HealthContainer"
	healthContainer.Size = UDim2.new(0, 250, 0, 30)
	healthContainer.Position = UDim2.new(0, 20, 1, -50)
	healthContainer.AnchorPoint = Vector2.new(0, 1)
	healthContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	healthContainer.BorderSizePixel = 0
	healthContainer.Parent = screenGui

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 6)
	containerCorner.Parent = healthContainer

	healthFill = Instance.new("Frame")
	healthFill.Name = "HealthFill"
	healthFill.Size = UDim2.new(1, 0, 1, 0)
	healthFill.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
	healthFill.BorderSizePixel = 0
	healthFill.Parent = healthContainer

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 6)
	fillCorner.Parent = healthFill

	healthBar = Instance.new("TextLabel")
	healthBar.Name = "HealthText"
	healthBar.Size = UDim2.new(1, 0, 1, 0)
	healthBar.BackgroundTransparency = 1
	healthBar.TextColor3 = Color3.fromRGB(255, 255, 255)
	healthBar.Text = "100 HP"
	healthBar.TextScaled = true
	healthBar.Font = Enum.Font.GothamBold
	healthBar.ZIndex = 2
	healthBar.Parent = healthContainer

	-- === INDICADOR DE LLAVE ===
	keyLabel = Instance.new("TextLabel")
	keyLabel.Name = "KeyIndicator"
	keyLabel.Size = UDim2.new(0, 200, 0, 35)
	keyLabel.Position = UDim2.new(0, 20, 1, -90)
	keyLabel.AnchorPoint = Vector2.new(0, 1)
	keyLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	keyLabel.BackgroundTransparency = 0.3
	keyLabel.BorderSizePixel = 0
	keyLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	keyLabel.Text = "LLAVE: No"
	keyLabel.TextScaled = true
	keyLabel.Font = Enum.Font.GothamBold
	keyLabel.Parent = screenGui

	local keyCorner = Instance.new("UICorner")
	keyCorner.CornerRadius = UDim.new(0, 6)
	keyCorner.Parent = keyLabel

	-- === MENSAJES CENTRALES ===
	messageLabel = Instance.new("TextLabel")
	messageLabel.Name = "Message"
	messageLabel.Size = UDim2.new(0, 500, 0, 60)
	messageLabel.Position = UDim2.new(0.5, 0, 0.3, 0)
	messageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	messageLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	messageLabel.BackgroundTransparency = 0.4
	messageLabel.BorderSizePixel = 0
	messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	messageLabel.Text = ""
	messageLabel.TextScaled = true
	messageLabel.Font = Enum.Font.GothamBold
	messageLabel.Visible = false
	messageLabel.Parent = screenGui

	local msgCorner = Instance.new("UICorner")
	msgCorner.CornerRadius = UDim.new(0, 8)
	msgCorner.Parent = messageLabel
end

-- Actualizar barra de vida
local function updateHealth(health: number, maxHealth: number)
	local ratio = math.clamp(health / maxHealth, 0, 1)
	healthFill.Size = UDim2.new(ratio, 0, 1, 0)
	healthBar.Text = math.floor(health) .. " HP"

	-- Color segun vida
	if ratio > 0.5 then
		healthFill.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
	elseif ratio > 0.25 then
		healthFill.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
	else
		healthFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	end
end

-- Mostrar mensaje temporal
local function showMessage(text: string, duration: number?, color: Color3?)
	messageLabel.Text = text
	messageLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	messageLabel.Visible = true

	task.delay(duration or 3, function()
		if messageLabel.Text == text then
			messageLabel.Visible = false
		end
	end)
end

-- Conectar eventos de vida del personaje
local function connectCharacter(character: Model)
	local humanoid = character:WaitForChild("Humanoid")
	updateHealth(humanoid.Health, humanoid.MaxHealth)

	humanoid.HealthChanged:Connect(function(newHealth)
		updateHealth(newHealth, humanoid.MaxHealth)
	end)

	humanoid.Died:Connect(function()
		showMessage("Has muerto!", 3, Color3.fromRGB(255, 50, 50))
	end)
end

function GameUI.init()
	createUI()

	-- Conectar personaje actual
	if player.Character then
		connectCharacter(player.Character)
	end
	player.CharacterAdded:Connect(function(character)
		-- Reset llave al respawnear
		keyLabel.Text = "LLAVE: No"
		keyLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
		connectCharacter(character)
	end)

	-- Escuchar RemoteEvents
	local keyCollected = ReplicatedStorage:WaitForChild("KeyCollected")
	keyCollected.OnClientEvent:Connect(function()
		keyLabel.Text = "LLAVE: Si!"
		keyLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
		keyLabel.BackgroundColor3 = Color3.fromRGB(60, 50, 10)
		showMessage("Encontraste la LLAVE! Ve a la SALIDA en el Jardin!", 4, Color3.fromRGB(255, 215, 0))
	end)

	local playerEscaped = ReplicatedStorage:WaitForChild("PlayerEscaped")
	playerEscaped.OnClientEvent:Connect(function(playerName: string)
		if playerName == player.Name then
			showMessage("ESCAPASTE! Victoria!", 5, Color3.fromRGB(0, 255, 100))
		else
			showMessage(playerName .. " escapo de la mansion!", 4, Color3.fromRGB(0, 255, 100))
		end
	end)

	local showMsg = ReplicatedStorage:WaitForChild("ShowMessage")
	showMsg.OnClientEvent:Connect(function(text: string)
		showMessage(text, 3, Color3.fromRGB(255, 200, 50))
	end)
end

return GameUI
