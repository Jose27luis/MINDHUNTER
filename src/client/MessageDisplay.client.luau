local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Crear GUI para mensajes
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MessageGUI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 100
screenGui.Parent = playerGui

-- Frame del mensaje
local messageFrame = Instance.new("Frame")
messageFrame.Name = "MessageFrame"
messageFrame.Size = UDim2.new(0, 500, 0, 80)
messageFrame.AnchorPoint = Vector2.new(0.5, 0)
messageFrame.Position = UDim2.new(0.5, 0, 0.15, 0)
messageFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
messageFrame.BackgroundTransparency = 1
messageFrame.BorderSizePixel = 0
messageFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = messageFrame

-- Texto del mensaje
local messageLabel = Instance.new("TextLabel")
messageLabel.Name = "MessageLabel"
messageLabel.Size = UDim2.new(1, -20, 1, -20)
messageLabel.Position = UDim2.new(0, 10, 0, 10)
messageLabel.BackgroundTransparency = 1
messageLabel.Text = ""
messageLabel.Font = Enum.Font.GothamBold
messageLabel.TextSize = 20
messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
messageLabel.TextWrapped = true
messageLabel.TextXAlignment = Enum.TextXAlignment.Center
messageLabel.TextYAlignment = Enum.TextYAlignment.Center
messageLabel.Parent = messageFrame

-- Función para mostrar mensaje
local function showMessage(text: string, color: Color3?)
	-- Establecer color y texto
	messageFrame.BackgroundColor3 = color or Color3.fromRGB(50, 150, 255)
	messageLabel.Text = text

	-- Cancelar animaciones previas
	TweenService:Create(messageFrame, TweenInfo.new(0), {BackgroundTransparency = 1}):Play()

	-- Animar entrada
	messageFrame.BackgroundTransparency = 0.1
	local fadeIn = TweenService:Create(
		messageFrame,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{BackgroundTransparency = 0.1}
	)
	fadeIn:Play()

	-- Animar salida después de 4 segundos
	task.delay(4, function()
		local fadeOut = TweenService:Create(
			messageFrame,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{BackgroundTransparency = 1}
		)
		fadeOut:Play()
	end)
end

-- Escuchar eventos del servidor
local showMessageEvent = ReplicatedStorage:WaitForChild("ShowMessage")
showMessageEvent.OnClientEvent:Connect(showMessage)

print("[MessageDisplay] Sistema de mensajes inicializado")
