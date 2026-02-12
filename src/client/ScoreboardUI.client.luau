local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Crear ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ScoreboardGUI"
screenGui.ResetOnSpawn = false
screenGui.Enabled = false
screenGui.Parent = playerGui

-- Fondo semi-transparente
local backdrop = Instance.new("Frame")
backdrop.Name = "Backdrop"
backdrop.Size = UDim2.new(1, 0, 1, 0)
backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
backdrop.BackgroundTransparency = 0.5
backdrop.BorderSizePixel = 0
backdrop.Parent = screenGui

-- Frame principal del scoreboard
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 600, 0, 450)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Esquinas redondeadas
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Título
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -40, 0, 50)
title.Position = UDim2.new(0, 20, 0, 15)
title.BackgroundTransparency = 1
title.Text = "RESULTADOS DE LA RONDA"
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = mainFrame

-- Contenedor scrollable para la lista
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "PlayerList"
scrollFrame.Size = UDim2.new(1, -40, 1, -100)
scrollFrame.Position = UDim2.new(0, 20, 0, 75)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 8
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = scrollFrame

-- Función para crear una fila de jugador
local function createPlayerRow(data, index)
	local row = Instance.new("Frame")
	row.Name = "Row_" .. index
	row.Size = UDim2.new(1, -10, 0, 60)
	row.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	row.BorderSizePixel = 0
	row.LayoutOrder = index

	local rowCorner = Instance.new("UICorner")
	rowCorner.CornerRadius = UDim.new(0, 8)
	rowCorner.Parent = row

	-- Color según resultado
	local statusColor = Color3.fromRGB(100, 100, 100) -- Gris (default)
	local statusText = "SOBREVIVIÓ"

	if data.Escaped then
		statusColor = Color3.fromRGB(50, 200, 50) -- Verde (escapó)
		statusText = "✓ ESCAPÓ"
	elseif data.Died then
		statusColor = Color3.fromRGB(200, 50, 50) -- Rojo (murió)
		statusText = "✗ MURIÓ"
	end

	-- Barra de color lateral
	local statusBar = Instance.new("Frame")
	statusBar.Name = "StatusBar"
	statusBar.Size = UDim2.new(0, 6, 1, 0)
	statusBar.BackgroundColor3 = statusColor
	statusBar.BorderSizePixel = 0
	statusBar.Parent = row

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 8)
	barCorner.Parent = statusBar

	-- Nombre del jugador
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "PlayerName"
	nameLabel.Size = UDim2.new(0, 180, 0, 25)
	nameLabel.Position = UDim2.new(0, 20, 0, 8)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = data.PlayerName
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 16
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = row

	-- Clase
	local classLabel = Instance.new("TextLabel")
	classLabel.Name = "Class"
	classLabel.Size = UDim2.new(0, 100, 0, 20)
	classLabel.Position = UDim2.new(0, 20, 0, 33)
	classLabel.BackgroundTransparency = 1
	classLabel.Text = "Clase: " .. data.Class
	classLabel.Font = Enum.Font.Gotham
	classLabel.TextSize = 12
	classLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	classLabel.TextXAlignment = Enum.TextXAlignment.Left
	classLabel.Parent = row

	-- Estado (Escapó/Murió/Sobrevivió)
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "Status"
	statusLabel.Size = UDim2.new(0, 120, 1, 0)
	statusLabel.Position = UDim2.new(0, 220, 0, 0)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = statusText
	statusLabel.Font = Enum.Font.GothamBold
	statusLabel.TextSize = 14
	statusLabel.TextColor3 = statusColor
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Parent = row

	-- Tiempo de supervivencia
	local timeLabel = Instance.new("TextLabel")
	timeLabel.Name = "Time"
	timeLabel.Size = UDim2.new(0, 100, 1, 0)
	timeLabel.Position = UDim2.new(0, 360, 0, 0)
	timeLabel.BackgroundTransparency = 1
	timeLabel.Text = string.format("%d:%02d", math.floor(data.SurvivalTime / 60), data.SurvivalTime % 60)
	timeLabel.Font = Enum.Font.GothamBold
	timeLabel.TextSize = 18
	timeLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
	timeLabel.TextXAlignment = Enum.TextXAlignment.Center
	timeLabel.Parent = row

	-- Llaves recogidas
	local keysLabel = Instance.new("TextLabel")
	keysLabel.Name = "Keys"
	keysLabel.Size = UDim2.new(0, 60, 1, 0)
	keysLabel.Position = UDim2.new(1, -80, 0, 0)
	keysLabel.BackgroundTransparency = 1
	keysLabel.Text = "🔑 " .. data.KeysCollected
	keysLabel.Font = Enum.Font.GothamBold
	keysLabel.TextSize = 16
	keysLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	keysLabel.TextXAlignment = Enum.TextXAlignment.Center
	keysLabel.Parent = row

	return row
end

-- Función para mostrar el scoreboard
local function showScoreboard(scoresData)
	-- Limpiar lista anterior
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Crear filas para cada jugador
	for index, data in ipairs(scoresData) do
		local row = createPlayerRow(data, index)
		row.Parent = scrollFrame
	end

	-- Ajustar tamaño del canvas
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)

	-- Mostrar con animación
	screenGui.Enabled = true
	mainFrame.Size = UDim2.new(0, 0, 0, 0)

	local openTween = TweenService:Create(
		mainFrame,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = UDim2.new(0, 600, 0, 450)}
	)
	openTween:Play()

	print("[ScoreboardUI] Scoreboard mostrado con " .. #scoresData .. " jugadores")
end

-- Función para ocultar el scoreboard
local function hideScoreboard()
	local closeTween = TweenService:Create(
		mainFrame,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{Size = UDim2.new(0, 0, 0, 0)}
	)
	closeTween:Play()

	closeTween.Completed:Connect(function()
		screenGui.Enabled = false
	end)

	print("[ScoreboardUI] Scoreboard ocultado")
end

-- Escuchar eventos del servidor
local showScoreboardEvent = ReplicatedStorage:WaitForChild("ShowScoreboard")
local hideScoreboardEvent = ReplicatedStorage:WaitForChild("HideScoreboard")

showScoreboardEvent.OnClientEvent:Connect(showScoreboard)
hideScoreboardEvent.OnClientEvent:Connect(hideScoreboard)

print("[ScoreboardUI] Sistema inicializado")
