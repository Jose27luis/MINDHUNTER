local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local Config = require(game.ReplicatedStorage.Shared.Config)
local MapData = require(game.ReplicatedStorage.Shared.MapData)

local MonsterController = {}

local monster: Model? = nil
local isMoving = false
local actionThread: thread? = nil
local lightsCache: { PointLight } = {}

-- Cancelar la accion actual
local function cancelAction()
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
			humanoid:MoveTo(rootPart.Position)
		end
	end
end

-- Navegar usando PathfindingService
local function navigateTo(targetPosition: Vector3)
	if not monster then return end

	local humanoid = monster:FindFirstChildOfClass("Humanoid")
	local rootPart = monster.PrimaryPart
	if not humanoid or not rootPart then return end

	local path = PathfindingService:CreatePath({
		AgentRadius = 3.5, -- Radio aumentado para la nueva escala
		AgentHeight = 9,   -- Altura aumentada para el Shadow Hunter (aprox 9 studs)
		AgentCanJump = false,
	})

	local success = pcall(function()
		path:ComputeAsync(rootPart.Position, targetPosition)
	end)

	if not success or path.Status ~= Enum.PathStatus.Success then
		warn("[MonsterController] Pathfinding fallido, moviendo directamente")
		if isMoving then
			humanoid:MoveTo(targetPosition)
			humanoid.MoveToFinished:Wait()
		end
		return
	end

	for _, waypoint in path:GetWaypoints() do
		if not isMoving then break end
		humanoid:MoveTo(waypoint.Position)
		humanoid.MoveToFinished:Wait()
	end
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

	actionThread = task.spawn(function()
		isMoving = true

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

return MonsterController
