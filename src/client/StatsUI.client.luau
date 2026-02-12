local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Crear ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StatsGUI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 10
screenGui.Parent = playerGui

-- Frame principal (panel de estadísticas)
local statsFrame = Instance.new("Frame")
statsFrame.Name = "StatsFrame"
statsFrame.Size = UDim2.new(0, 320, 0, 400)
statsFrame.AnchorPoint = Vector2.new(1, 0)
statsFrame.Position = UDim2.new(1, -20, 0, 80)
statsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
statsFrame.BackgroundTransparency = 0.1
statsFrame.BorderSizePixel = 0
statsFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = statsFrame

-- Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -20, 0, 40)
titleLabel.Position = UDim2.new(0, 10, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = " TUS ESTADÍSTICAS"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = statsFrame

-- Contenedor de stats
local statsContainer = Instance.new("Frame")
statsContainer.Name = "StatsContainer"
statsContainer.Size = UDim2.new(1, -20, 1, -60)
statsContainer.Position = UDim2.new(0, 10, 0, 50)
statsContainer.BackgroundTransparency = 1
statsContainer.Parent = statsFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 10)
listLayout.Parent = statsContainer

-- Función para crear una fila de estadística
local function createStatRow(icon: string, label: string, value: string, layoutOrder: number)
	local row = Instance.new("Frame")
	row.Name = label
	row.Size = UDim2.new(1, 0, 0, 35)
	row.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	row.BorderSizePixel = 0
	row.LayoutOrder = layoutOrder

	local rowCorner = Instance.new("UICorner")
	rowCorner.CornerRadius = UDim.new(0, 8)
	rowCorner.Parent = row

	-- Icono
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(0, 30, 1, 0)
	iconLabel.Position = UDim2.new(0, 5, 0, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = icon
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.TextSize = 18
	iconLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	iconLabel.TextXAlignment = Enum.TextXAlignment.Center
	iconLabel.Parent = row

	-- Label
	local labelText = Instance.new("TextLabel")
	labelText.Size = UDim2.new(0, 150, 1, 0)
	labelText.Position = UDim2.new(0, 40, 0, 0)
	labelText.BackgroundTransparency = 1
	labelText.Text = label
	labelText.Font = Enum.Font.Gotham
	labelText.TextSize = 14
	labelText.TextColor3 = Color3.fromRGB(200, 200, 200)
	labelText.TextXAlignment = Enum.TextXAlignment.Left
	labelText.Parent = row

	-- Value
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Name = "Value"
	valueLabel.Size = UDim2.new(0, 100, 1, 0)
	valueLabel.Position = UDim2.new(1, -110, 0, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = value
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 16
	valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = row

	return row
end

-- Función para actualizar las estadísticas
local function updateStats(stats)
	-- Limpiar stats anteriores
	for _, child in ipairs(statsContainer:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Crear filas de estadísticas
	createStatRow("🎮", "Partidas Jugadas", tostring(stats.TotalGames), 1).Parent = statsContainer
	createStatRow("🏆", "Victorias", tostring(stats.Wins), 2).Parent = statsContainer
	createStatRow("💀", "Muertes", tostring(stats.Deaths), 3).Parent = statsContainer
	createStatRow("📊", "Tasa de Victoria", stats.WinRate .. "%", 4).Parent = statsContainer
	createStatRow("⏱️", "Mejor Tiempo", stats.BestTime, 5).Parent = statsContainer
	createStatRow("⏳", "Tiempo Promedio", stats.AvgSurvivalTime, 6).Parent = statsContainer
	createStatRow("🔑", "Llaves Totales", tostring(stats.TotalKeys), 7).Parent = statsContainer
	createStatRow("🎭", "Clase Favorita", stats.FavoriteClass, 8).Parent = statsContainer

	print("[StatsUI] Estadísticas actualizadas")
end

-- Crear RemoteFunction para pedir estadísticas
local getStatsRemote = Instance.new("RemoteFunction")
getStatsRemote.Name = "GetPlayerStats"
getStatsRemote.Parent = ReplicatedStorage

-- Solicitar estadísticas al servidor
local success, stats = pcall(function()
	return getStatsRemote:InvokeServer()
end)

if success and stats then
	updateStats(stats)
else
	-- Mostrar stats por defecto si hay error
	updateStats({
		TotalGames = 0,
		Wins = 0,
		Deaths = 0,
		WinRate = 0,
		BestTime = "--:--",
		AvgSurvivalTime = "00:00",
		TotalKeys = 0,
		FavoriteClass = "Scout",
	})
	warn("[StatsUI] Error al obtener estadísticas: " .. tostring(stats))
end

-- Actualizar stats cada vez que el jugador vuelva del juego
ReplicatedStorage.ChildAdded:Connect(function(child)
	if child.Name == "RefreshStats" and child:IsA("RemoteEvent") then
		child.OnClientEvent:Connect(function(newStats)
			updateStats(newStats)
		end)
	end
end)

print("[StatsUI] Sistema de estadísticas inicializado")
