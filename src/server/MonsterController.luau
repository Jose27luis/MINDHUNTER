local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local Config = require(game.ReplicatedStorage.Shared.Config)
local MapData = require(game.ReplicatedStorage.Shared.MapData)
local MonsterMemory = require(script.Parent.MonsterMemory)

local MonsterController = {}

local monster: Model? = nil
local isMoving = false
local actionThread: thread? = nil
local lightsCache: { PointLight } = {}
local sightingCooldowns: { [string]: number } = {}

-- Cancelar la accion actual
local function cancelAction()
	print("[MonsterController] Cancelando acción actual")
	isMoving = false

	if actionThread then
		task.cancel(actionThread)
		actionThread = nil
	end

	if monster then
		local humanoid = monster:FindFirstChildOfClass("Humanoid")
		local rootPart = monster.PrimaryPart
		if humanoid and rootPart then
			humanoid.WalkSpeed = Config.MONSTER_WALK_SPEED
			humanoid:MoveTo(rootPart.Position) -- Detener movimiento
		end
	end
end

-- Navegar usando PathfindingService
local function navigateTo(targetPosition: Vector3)
	if not monster then
		warn("[MonsterController] navigateTo - monster es nil!")
		return
	end

	local humanoid = monster:FindFirstChildOfClass("Humanoid")
	local rootPart = monster.PrimaryPart
	if not humanoid or not rootPart then
		warn("[MonsterController] navigateTo - humanoid o rootPart faltante")
		return
	end

	print("[MonsterController] Navegando desde " .. tostring(rootPart.Position) .. " hacia " .. tostring(targetPosition))

	-- IMPORTANTE: Activar movimiento
	isMoving = true

	local path = PathfindingService:CreatePath({
		AgentRadius = 2, -- Radio reducido para que pase por las puertas (12 studs de ancho)
		AgentHeight = 7,   -- Altura del monstruo
		AgentCanJump = false,
		AgentCanClimb = false,
		Costs = {
			Water = math.huge, -- Evitar agua si hay
		}
	})

	local success = pcall(function()
		path:ComputeAsync(rootPart.Position, targetPosition)
	end)

	if not success then
		warn("[MonsterController] Pathfinding compute falló: " .. tostring(result))
		-- Fallback: mover directamente
		if isMoving then
			print("[MonsterController] Usando movimiento directo como fallback")
			humanoid:MoveTo(targetPosition)
			local timeout = humanoid.MoveToFinished:Wait()
		end
		return
	end

	if path.Status ~= Enum.PathStatus.Success then
		warn("[MonsterController] Path status: " .. tostring(path.Status))
		-- Fallback: mover directamente
		if isMoving then
			print("[MonsterController] Usando movimiento directo como fallback")
			humanoid:MoveTo(targetPosition)
			local timeout = humanoid.MoveToFinished:Wait()
		end
		return
	end

	local waypoints = path:GetWaypoints()
	print("[MonsterController] Path encontrado con " .. #waypoints .. " waypoints")

	-- Seguir cada waypoint del path
	for i, waypoint in ipairs(waypoints) do
		if not isMoving then
			print("[MonsterController] Movimiento cancelado")
			break
		end

		-- Saltar waypoints que requieran salto (el monstruo no puede saltar)
		if waypoint.Action == Enum.PathWaypointAction.Jump then
			print("[MonsterController] Saltando waypoint de salto")
			continue
		end

		-- Mover al waypoint
		humanoid:MoveTo(waypoint.Position)

		-- Esperar con timeout (5 segundos máximo por waypoint)
		local moveFinished = false
		local connection
		connection = humanoid.MoveToFinished:Connect(function(reached)
			moveFinished = true
			connection:Disconnect()
		end)

		-- Timeout de 5 segundos
		local startTime = tick()
		while not moveFinished and (tick() - startTime) < 5 do
			task.wait(0.1)
			if not isMoving then break end
		end

		if connection then
			connection:Disconnect()
		end

		-- Debug cada 3 waypoints
		if i % 3 == 0 then
			print("[MonsterController] Progreso: " .. i .. "/" .. #waypoints .. " waypoints")
		end
	end

	-- Registrar visita en memoria
	if monster and monster.PrimaryPart then
		local currentRoom = MonsterMemory.getRoomFromPosition(monster.PrimaryPart.Position)
		if currentRoom then
			MonsterMemory.recordVisit(currentRoom)
		end
	end

	print("[MonsterController] Llegó al destino")
end

-- Resolver nombre de habitacion a posicion Vector3
local function resolveRoomPosition(target: string?): Vector3?
	if not target then return nil end

	local key = MapData.NAME_TO_KEY[string.lower(target)]
	if not key or not MapData.Rooms[key] then
		warn("[MonsterController] Habitacion desconocida: " .. tostring(target))
		return nil
	end

	local pos = MapData.Rooms[key].position
	return Vector3.new(pos.X, 3, pos.Z)
end

-- Obtener la posicion del jugador mas cercano
local function getClosestPlayerPosition(): Vector3?
	if not monster or not monster.PrimaryPart then return nil end

	local monsterPos = monster.PrimaryPart.Position
	local closestDist = math.huge
	local closestPos: Vector3? = nil

	for _, player in Players:GetPlayers() do
		-- Ignorar jugadores escondidos
		if player:GetAttribute("Hidden") then continue end
		
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChild("Humanoid")
		
		-- Ignorar muertos
		if root and humanoid and humanoid.Health > 0 then
			local dist = (root.Position - monsterPos).Magnitude
			if dist < closestDist then
				closestDist = dist
				closestPos = root.Position
			end

			-- Registrar avistamiento si esta dentro del rango de deteccion
			if dist < Config.SIGHTING_RANGE then
				local now = os.clock()
				if not sightingCooldowns[player.Name] or (now - sightingCooldowns[player.Name]) > Config.SIGHTING_COOLDOWN then
					local playerRoom = MonsterMemory.getRoomFromPosition(root.Position)
					if playerRoom then
						MonsterMemory.recordSighting(player.Name, playerRoom)
						sightingCooldowns[player.Name] = now
					end
				end
			end
		end
	end

	return closestPos
end

-- Loop de patrulla autonoma (se ejecuta cuando no hay accion de IA activa)
local function autoPatrolLoop()
	local roomKeys = {}
	for key in MapData.Rooms do
		table.insert(roomKeys, key)
	end

	while true do
		isMoving = false
		task.wait(math.random(3, 6))

		local randomKey = roomKeys[math.random(#roomKeys)]
		local pos = MapData.Rooms[randomKey].position

		isMoving = true
		print("[MonsterController] Patrulla autonoma: " .. randomKey)
		navigateTo(Vector3.new(pos.X, 3, pos.Z))
	end
end

-- === ACCIONES ===

local function doGoTo(target: string?)
	local targetPos = resolveRoomPosition(target)
	if not targetPos then return end

	print("[MonsterController] GO_TO: " .. tostring(target))
	navigateTo(targetPos)
end

local function doPatrol()
	local roomKeys = {}
	for key in MapData.Rooms do
		table.insert(roomKeys, key)
	end

	local randomKey = roomKeys[math.random(#roomKeys)]
	local pos = MapData.Rooms[randomKey].position

	print("[MonsterController] PATROL: " .. randomKey)
	navigateTo(Vector3.new(pos.X, 3, pos.Z))
end

local function doAmbush(target: string?)
	local targetPos = resolveRoomPosition(target)
	if not targetPos then
		doPatrol()
	else
		print("[MonsterController] AMBUSH: " .. tostring(target))
		navigateTo(targetPos)
	end

	-- Quedarse en posicion hasta ser interrumpido
	print("[MonsterController] AMBUSH: En posicion, esperando...")
	while isMoving do
		task.wait(1)
	end
end

local function doChase()
	if not monster then return end

	local humanoid = monster:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	humanoid.WalkSpeed = Config.MONSTER_CHASE_SPEED
	print("[MonsterController] CHASE: Persiguiendo jugadores...")

	while isMoving do
		local targetPos = getClosestPlayerPosition()
		if targetPos then
			humanoid:MoveTo(targetPos)
		end
		task.wait(Config.CHASE_UPDATE_INTERVAL)
	end
end

local function doTurnOffLights(target: string?)
	print("[MonsterController] TURN_OFF_LIGHTS: Apagando luces por " .. Config.LIGHTS_OFF_DURATION .. "s")

	for _, light in lightsCache do
		light.Enabled = false
	end

	task.delay(Config.LIGHTS_OFF_DURATION, function()
		for _, light in lightsCache do
			light.Enabled = true
		end
		print("[MonsterController] Luces restauradas")
	end)

	local targetPos = resolveRoomPosition(target)
	if targetPos then
		navigateTo(targetPos)
	end
end

local function doWait()
	print("[MonsterController] WAIT: Detenido, escuchando...")
	while isMoving do
		task.wait(1)
	end
end

-- Inicializar con el modelo del monstruo y las luces
function MonsterController.init(npcModel: Model?, lights: { PointLight }?)
	monster = npcModel
	lightsCache = lights or {}
	sightingCooldowns = {}

	-- Registrar habitacion de spawn en memoria
	if monster and monster.PrimaryPart then
		local spawnRoom = MonsterMemory.getRoomFromPosition(monster.PrimaryPart.Position)
		if spawnRoom then
			MonsterMemory.recordVisit(spawnRoom)
		end
	end

	-- Iniciar patrulla autonoma al arrancar
	actionThread = task.spawn(function()
		task.wait(3)
		autoPatrolLoop()
	end)

	print("[MonsterController] Inicializado - patrullando")
end

-- Ejecutar una accion del monstruo (cancela la anterior automaticamente)
function MonsterController.executeAction(actionData: { action: string, target: string?, reason: string })
	cancelAction()

	local action = actionData.action
	local target = actionData.target

	-- Establecer isMoving ANTES de spawnear el thread
	isMoving = true

	actionThread = task.spawn(function()

		if action == "GO_TO" then
			doGoTo(target)
		elseif action == "PATROL" then
			doPatrol()
		elseif action == "AMBUSH" then
			doAmbush(target)
			return -- loop interno, no reanudar patrulla
		elseif action == "CHASE" then
			doChase()
			return -- loop interno, no reanudar patrulla
		elseif action == "TURN_OFF_LIGHTS" then
			doTurnOffLights(target)
		elseif action == "WAIT" then
			doWait()
			return -- loop interno, no reanudar patrulla
		end

		-- Acciones de un solo uso (GO_TO, PATROL, TURN_OFF_LIGHTS)
		-- reanudan patrulla autonoma al completarse
		autoPatrolLoop()
	end)
end

function MonsterController.setSpeed(speed)
	if monster then
		local humanoid = monster:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = speed
			-- Actualizar config local si fuera necesario, pero por ahora basta con el humanoide
			print("[MonsterController] Velocidad actualizada a: " .. speed)
		end
	end
end

return MonsterController
