local MapData = require(game.ReplicatedStorage.Shared.MapData)
local Config = require(game.ReplicatedStorage.Shared.Config)

local MonsterMemory = {}

-- Estado interno
local visitedRooms: { [string]: number } = {}
local playerSightings: { { playerName: string, roomKey: string, timestamp: number } } = {}
local actionHistory: { { action: string, target: string?, result: string, timestamp: number } } = {}
local gameEvents: { { event: string, timestamp: number, detail: string? } } = {}
local roundStartTime: number = 0

-- Cooldowns de avistamientos por jugador
local sightingCooldowns: { [string]: number } = {}

-- Limpiar toda la memoria (entre rondas)
function MonsterMemory.reset()
	visitedRooms = {}
	playerSightings = {}
	actionHistory = {}
	gameEvents = {}
	sightingCooldowns = {}
	roundStartTime = os.clock()
	print("[MonsterMemory] Memoria reseteada")
end

-- Registrar visita a una habitacion
function MonsterMemory.recordVisit(roomKey: string)
	visitedRooms[roomKey] = os.clock()
end

-- Registrar avistamiento de jugador (con cooldown)
function MonsterMemory.recordSighting(playerName: string, roomKey: string)
	local now = os.clock()
	if sightingCooldowns[playerName] and (now - sightingCooldowns[playerName]) < Config.SIGHTING_COOLDOWN then
		return
	end

	sightingCooldowns[playerName] = now
	table.insert(playerSightings, {
		playerName = playerName,
		roomKey = roomKey,
		timestamp = now,
	})

	-- Limitar a MAX_SIGHTINGS
	while #playerSightings > Config.MAX_SIGHTINGS do
		table.remove(playerSightings, 1)
	end
end

-- Registrar accion del monstruo
function MonsterMemory.recordAction(action: string, target: string?, result: string)
	table.insert(actionHistory, {
		action = action,
		target = target,
		result = result,
		timestamp = os.clock(),
	})

	while #actionHistory > Config.MAX_ACTION_HISTORY do
		table.remove(actionHistory, 1)
	end
end

-- Registrar evento del juego
function MonsterMemory.recordGameEvent(event: string, detail: string?)
	table.insert(gameEvents, {
		event = event,
		timestamp = os.clock(),
		detail = detail,
	})
end

-- Tiempo transcurrido desde inicio de ronda
function MonsterMemory.getElapsedTime(): number
	return os.clock() - roundStartTime
end

-- Fase de personalidad segun tiempo
function MonsterMemory.getPersonalityPhase(): string
	local elapsed = MonsterMemory.getElapsedTime()
	if elapsed < Config.PHASE_CAUTIOUS_END then
		return "CAUTIOUS"
	elseif elapsed < Config.PHASE_AGGRESSIVE_END then
		return "AGGRESSIVE"
	else
		return "RELENTLESS"
	end
end

-- Determinar habitacion mas cercana a una posicion
function MonsterMemory.getRoomFromPosition(position: Vector3): string?
	local closestRoom: string? = nil
	local closestDist = math.huge

	for key, data in MapData.Rooms do
		local roomPos = data.position
		local dist = (Vector3.new(roomPos.X, 0, roomPos.Z) - Vector3.new(position.X, 0, position.Z)).Magnitude
		if dist < closestDist then
			closestDist = dist
			closestRoom = key
		end
	end

	return closestRoom
end

-- Construir texto compacto de memoria para el prompt de Groq
function MonsterMemory.buildContextString(): string
	local parts = {}
	local now = os.clock()
	local elapsed = math.floor(MonsterMemory.getElapsedTime())

	-- 1. Fase y tiempo
	table.insert(parts, "FASE: " .. MonsterMemory.getPersonalityPhase() .. " (" .. elapsed .. "s/" .. Config.ROUND_TIME .. "s)")

	-- 2. Habitaciones visitadas
	local visitedList = {}
	for roomKey, timestamp in visitedRooms do
		local secsAgo = math.floor(now - timestamp)
		table.insert(visitedList, roomKey .. " (hace " .. secsAgo .. "s)")
	end
	if #visitedList > 0 then
		table.insert(parts, "Visitadas: " .. table.concat(visitedList, ", "))
	end

	-- 3. Habitaciones NO visitadas
	local unvisited = {}
	for roomKey in MapData.Rooms do
		if not visitedRooms[roomKey] then
			table.insert(unvisited, roomKey)
		end
	end
	if #unvisited > 0 then
		table.insert(parts, "No visitadas: " .. table.concat(unvisited, ", "))
	end

	-- 4. Avistamientos recientes (ultimos 5)
	if #playerSightings > 0 then
		local sightingStrings = {}
		local start = math.max(1, #playerSightings - 4)
		for i = start, #playerSightings do
			local s = playerSightings[i]
			local secsAgo = math.floor(now - s.timestamp)
			table.insert(sightingStrings, s.playerName .. " en " .. s.roomKey .. " (hace " .. secsAgo .. "s)")
		end
		table.insert(parts, "Avistamientos: " .. table.concat(sightingStrings, ", "))
	end

	-- 5. Historial de acciones
	if #actionHistory > 0 then
		local actionStrings = {}
		for _, a in actionHistory do
			local entry = a.action
			if a.target then
				entry = entry .. " " .. a.target
			end
			table.insert(actionStrings, entry)
		end
		table.insert(parts, "Acciones recientes: " .. table.concat(actionStrings, ", "))
	end

	-- 6. Eventos del juego
	if #gameEvents > 0 then
		local eventStrings = {}
		for _, e in gameEvents do
			local secsAgo = math.floor(now - e.timestamp)
			local entry = e.event
			if e.detail then entry = entry .. " (" .. e.detail .. ")" end
			entry = entry .. " hace " .. secsAgo .. "s"
			table.insert(eventStrings, entry)
		end
		table.insert(parts, "Eventos: " .. table.concat(eventStrings, ", "))
	end

	return table.concat(parts, "\n")
end

return MonsterMemory
