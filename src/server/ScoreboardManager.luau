local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ScoreboardManager = {}

-- Datos de la ronda actual
local roundData = {}

-- Inicializar datos de ronda
function ScoreboardManager.initRound()
	roundData = {}

	for _, player in ipairs(Players:GetPlayers()) do
		roundData[player.UserId] = {
			PlayerName = player.Name,
			Class = player:GetAttribute("Class") or "Scout",
			StartTime = os.time(),
			Escaped = false,
			Died = false,
			DeathTime = nil,
			EscapeTime = nil,
			KeysCollected = 0,
			SurvivalTime = 0,
		}
	end

	print("[ScoreboardManager] Ronda iniciada - " .. #Players:GetPlayers() .. " jugadores registrados")
end

-- Registrar cuando un jugador recoge una llave
function ScoreboardManager.registerKeyCollected(player: Player)
	local data = roundData[player.UserId]
	if data then
		data.KeysCollected += 1
		print("[ScoreboardManager] " .. player.Name .. " recogió llave (" .. data.KeysCollected .. " total)")
	end
end

-- Registrar cuando un jugador escapa
function ScoreboardManager.registerEscape(player: Player)
	local data = roundData[player.UserId]
	if data then
		data.Escaped = true
		data.EscapeTime = os.time()
		data.SurvivalTime = os.time() - data.StartTime
		player:SetAttribute("Escaped", true)
		print("[ScoreboardManager] " .. player.Name .. " ESCAPÓ! (Tiempo: " .. data.SurvivalTime .. "s)")
	end
end

-- Registrar cuando un jugador muere
function ScoreboardManager.registerDeath(player: Player)
	local data = roundData[player.UserId]
	if data and not data.Died then
		data.Died = true
		data.DeathTime = os.time()
		data.SurvivalTime = os.time() - data.StartTime
		print("[ScoreboardManager] " .. player.Name .. " murió (Sobrevivió: " .. data.SurvivalTime .. "s)")
	end
end

-- Actualizar tiempos de supervivencia para jugadores vivos
function ScoreboardManager.updateSurvivalTimes()
	for userId, data in pairs(roundData) do
		if not data.Escaped and not data.Died then
			data.SurvivalTime = os.time() - data.StartTime
		end
	end
end

-- Obtener datos finales ordenados por resultado
function ScoreboardManager.getFinalScores(): {{}}
	-- Actualizar tiempos finales
	ScoreboardManager.updateSurvivalTimes()

	local scores = {}

	-- Convertir a array
	for _, data in pairs(roundData) do
		table.insert(scores, data)
	end

	-- Ordenar: Escapados primero, luego sobrevivientes, luego muertos
	table.sort(scores, function(a, b)
		-- Prioridad 1: Escapados
		if a.Escaped and not b.Escaped then return true end
		if b.Escaped and not a.Escaped then return false end

		-- Prioridad 2: Vivos
		if not a.Died and b.Died then return true end
		if a.Died and not b.Died then return false end

		-- Prioridad 3: Tiempo de supervivencia (mayor = mejor)
		return a.SurvivalTime > b.SurvivalTime
	end)

	return scores
end

-- Limpiar datos
function ScoreboardManager.cleanup()
	roundData = {}
	print("[ScoreboardManager] Datos limpiados")
end

return ScoreboardManager
