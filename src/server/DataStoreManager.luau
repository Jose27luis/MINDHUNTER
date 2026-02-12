local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local DataStoreManager = {}

-- DataStore para estadísticas de jugadores
local playerStatsStore
local isStudioMode = RunService:IsStudio()

-- Intentar obtener DataStore (puede fallar en Studio)
local success, result = pcall(function()
	return DataStoreService:GetDataStore("PlayerStats_v1")
end)

if success then
	playerStatsStore = result
	print("[DataStore] Conectado exitosamente")
else
	warn("[DataStore] No disponible en Studio (esto es normal)")
	warn("[DataStore] Para usar DataStore: Habilita 'Enable Studio Access to API Services' en Game Settings > Security")
	print("[DataStore] Usando modo de prueba (datos NO se guardarán)")
end

-- Estructura de datos por defecto
local DEFAULT_DATA = {
	TotalGames = 0,
	Wins = 0, -- Escapes exitosos
	Deaths = 0,
	BestEscapeTime = math.huge, -- Mejor tiempo (menor es mejor)
	TotalSurvivalTime = 0, -- Tiempo total sobrevivido en segundos
	ClassUsage = { -- Cuántas veces usó cada clase
		Runner = 0,
		Tank = 0,
		Scout = 0,
	},
	KeysCollected = 0, -- Total de llaves recogidas en toda su historia
	LastPlayed = os.time(),
}

-- Cache de datos en memoria
local playerDataCache = {}

-- Cargar datos de un jugador
function DataStoreManager.loadData(player: Player)
	local userId = player.UserId

	-- Si no hay DataStore (Studio mode), usar datos por defecto
	if not playerStatsStore then
		playerDataCache[userId] = table.clone(DEFAULT_DATA)
		print("[DataStore] Datos de prueba para " .. player.Name .. " (no se guardarán)")
		return playerDataCache[userId]
	end

	local success, data = pcall(function()
		return playerStatsStore:GetAsync("Player_" .. userId)
	end)

	if success and data then
		-- Datos existentes, mergear con defaults por si hay nuevos campos
		for key, value in pairs(DEFAULT_DATA) do
			if data[key] == nil then
				data[key] = value
			end
		end
		playerDataCache[userId] = data
		print("[DataStore] Datos cargados para " .. player.Name .. " - " .. data.TotalGames .. " partidas jugadas")
	else
		-- Primera vez jugando o error
		playerDataCache[userId] = table.clone(DEFAULT_DATA)
		print("[DataStore] Nuevos datos creados para " .. player.Name)
	end

	return playerDataCache[userId]
end

-- Guardar datos de un jugador
function DataStoreManager.saveData(player: Player)
	local userId = player.UserId
	local data = playerDataCache[userId]

	if not data then
		warn("[DataStore] No hay datos en cache para " .. player.Name)
		return false
	end

	-- Si no hay DataStore (Studio mode), solo simular guardado
	if not playerStatsStore then
		print("[DataStore] Simulando guardado para " .. player.Name .. " (modo prueba)")
		return true
	end

	-- Actualizar última vez jugado
	data.LastPlayed = os.time()

	local success, err = pcall(function()
		playerStatsStore:SetAsync("Player_" .. userId, data)
	end)

	if success then
		print("[DataStore] Datos guardados para " .. player.Name)
		return true
	else
		warn("[DataStore] Error al guardar datos de " .. player.Name .. ": " .. tostring(err))
		return false
	end
end

-- Obtener datos del cache
function DataStoreManager.getData(player: Player)
	return playerDataCache[player.UserId]
end

-- Actualizar estadísticas después de una ronda
function DataStoreManager.updateRoundStats(player: Player, roundData: {
	Escaped: boolean,
	Died: boolean,
	SurvivalTime: number,
	KeysCollected: number,
	Class: string,
	EscapeTime: number?,
})
	local data = playerDataCache[player.UserId]
	if not data then
		warn("[DataStore] No se encontraron datos para " .. player.Name)
		return
	end

	-- Actualizar estadísticas
	data.TotalGames += 1

	if roundData.Escaped then
		data.Wins += 1
		-- Actualizar mejor tiempo si es mejor
		if roundData.EscapeTime and roundData.EscapeTime < data.BestEscapeTime then
			data.BestEscapeTime = roundData.EscapeTime
		end
	end

	if roundData.Died then
		data.Deaths += 1
	end

	data.TotalSurvivalTime += roundData.SurvivalTime
	data.KeysCollected += roundData.KeysCollected

	-- Actualizar uso de clase
	if data.ClassUsage[roundData.Class] then
		data.ClassUsage[roundData.Class] += 1
	end

	print("[DataStore] Stats actualizadas para " .. player.Name .. " - Total partidas: " .. data.TotalGames)
end

-- Obtener clase favorita
function DataStoreManager.getFavoriteClass(player: Player): string
	local data = playerDataCache[player.UserId]
	if not data then return "Scout" end

	local maxUsage = 0
	local favoriteClass = "Scout"

	for className, usage in pairs(data.ClassUsage) do
		if usage > maxUsage then
			maxUsage = usage
			favoriteClass = className
		end
	end

	return favoriteClass
end

-- Obtener tasa de victoria
function DataStoreManager.getWinRate(player: Player): number
	local data = playerDataCache[player.UserId]
	if not data or data.TotalGames == 0 then return 0 end

	return math.floor((data.Wins / data.TotalGames) * 100)
end

-- Formatear tiempo en MM:SS
local function formatTime(seconds: number): string
	if seconds == math.huge then
		return "--:--"
	end
	local mins = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d", mins, secs)
end

-- Obtener resumen de stats formateado
function DataStoreManager.getStatsSummary(player: Player): {}
	local data = playerDataCache[player.UserId]
	if not data then return {} end

	return {
		TotalGames = data.TotalGames,
		Wins = data.Wins,
		Deaths = data.Deaths,
		WinRate = DataStoreManager.getWinRate(player),
		BestTime = formatTime(data.BestEscapeTime),
		TotalKeys = data.KeysCollected,
		FavoriteClass = DataStoreManager.getFavoriteClass(player),
		AvgSurvivalTime = data.TotalGames > 0 and formatTime(math.floor(data.TotalSurvivalTime / data.TotalGames)) or "00:00",
	}
end

-- Limpiar cache cuando el jugador sale
function DataStoreManager.clearCache(player: Player)
	playerDataCache[player.UserId] = nil
	print("[DataStore] Cache limpiado para " .. player.Name)
end

-- Inicializar: Cargar datos al unirse, guardar al salir
function DataStoreManager.init()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	-- Cargar datos cuando un jugador se une
	Players.PlayerAdded:Connect(function(player)
		DataStoreManager.loadData(player)
	end)

	-- Guardar datos cuando un jugador sale
	Players.PlayerRemoving:Connect(function(player)
		DataStoreManager.saveData(player)
		DataStoreManager.clearCache(player)
	end)

	-- Guardar todos los datos cada 5 minutos (por si acaso)
	task.spawn(function()
		while true do
			task.wait(300) -- 5 minutos
			for _, player in ipairs(Players:GetPlayers()) do
				DataStoreManager.saveData(player)
			end
			print("[DataStore] Auto-guardado completado")
		end
	end)

	-- RemoteFunction para que el cliente pida sus estadísticas
	local getStatsRemote = Instance.new("RemoteFunction")
	getStatsRemote.Name = "GetPlayerStats"
	getStatsRemote.OnServerInvoke = function(player)
		return DataStoreManager.getStatsSummary(player)
	end
	getStatsRemote.Parent = ReplicatedStorage

	-- RemoteEvent para refrescar stats en el cliente
	local refreshStatsEvent = Instance.new("RemoteEvent")
	refreshStatsEvent.Name = "RefreshStats"
	refreshStatsEvent.Parent = ReplicatedStorage

	print("[DataStore] Sistema inicializado")
end

return DataStoreManager
