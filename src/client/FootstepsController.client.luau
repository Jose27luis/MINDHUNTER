local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local AudioConfig = require(ReplicatedStorage.Shared.AudioConfig)

local player = Players.LocalPlayer

-- SoundGroup para pasos
local footstepsGroup = Instance.new("SoundGroup")
footstepsGroup.Name = "FootstepsGroup"
footstepsGroup.Volume = AudioConfig.MasterVolume.Footsteps
footstepsGroup.Parent = SoundService

-- Configuración
local STEP_INTERVAL = 0.4 -- Intervalo entre pasos (segundos)
local MIN_SPEED = 5 -- Velocidad mínima para hacer ruido
local RUN_SPEED_THRESHOLD = 18 -- Velocidad para considerar "corriendo"

-- Estado
local lastStepTime = 0
local currentSound: Sound? = nil
local isRunning = false

-- Crear sonido de pasos
local function createFootstepSound()
	local sound = Instance.new("Sound")
	sound.Name = "FootstepSound"
	sound.Volume = 0
	sound.PlaybackSpeed = 1
	sound.SoundGroup = footstepsGroup
	return sound
end

-- Detectar material del suelo debajo del jugador
local function getGroundMaterial(): Enum.Material?
	if not player.Character then return nil end

	local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return nil end

	-- Raycast hacia abajo
	local rayOrigin = rootPart.Position
	local rayDirection = Vector3.new(0, -5, 0)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {player.Character}

	local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

	if result and result.Instance then
		return result.Instance.Material
	end

	return nil
end

-- Obtener configuración de audio según material
local function getFootstepConfig(material: Enum.Material?): {}?
	if not material then
		return AudioConfig.Footsteps.Default
	end

	local materialName = material.Name

	-- Mapear materiales de Roblox a nuestros sonidos
	if materialName:match("Wood") then
		return AudioConfig.Footsteps.Wood
	elseif materialName:match("Concrete") or materialName:match("Slate") or materialName:match("Brick") then
		return AudioConfig.Footsteps.Concrete
	elseif materialName:match("Metal") or materialName:match("DiamondPlate") then
		return AudioConfig.Footsteps.Metal
	elseif materialName:match("Fabric") or materialName:match("Carpet") then
		return AudioConfig.Footsteps.Fabric
	elseif materialName:match("Marble") or materialName:match("Granite") then
		return AudioConfig.Footsteps.Marble
	else
		return AudioConfig.Footsteps.Default
	end
end

-- Reproducir sonido de paso
local function playFootstep(speed: number)
	local material = getGroundMaterial()
	local config = getFootstepConfig(material)

	if not config then return end

	-- Crear o reutilizar sonido
	if not currentSound then
		currentSound = createFootstepSound()
		currentSound.Parent = player.Character.HumanoidRootPart
	end

	-- Configurar sonido
	currentSound.SoundId = config.Id
	currentSound.Volume = config.Volume

	-- Ajustar pitch según velocidad (más rápido = pitch más alto)
	local speedFactor = math.clamp(speed / 20, 0.8, 1.3)
	currentSound.PlaybackSpeed = speedFactor

	-- Volumen mayor si está corriendo
	if isRunning then
		currentSound.Volume = config.Volume * 1.2
	end

	currentSound:Play()
end

-- Loop principal de detección de pasos
local function onCharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")

	-- Limpiar sonido anterior
	if currentSound then
		currentSound:Destroy()
		currentSound = nil
	end

	-- Monitorear movimiento
	RunService.Heartbeat:Connect(function()
		if not humanoid or not rootPart then return end

		local speed = humanoid.MoveDirection.Magnitude * humanoid.WalkSpeed

		-- Determinar si está corriendo
		isRunning = speed > RUN_SPEED_THRESHOLD

		-- Solo reproducir pasos si se está moviendo
		if speed > MIN_SPEED then
			local currentTime = tick()
			local interval = isRunning and (STEP_INTERVAL * 0.7) or STEP_INTERVAL

			if currentTime - lastStepTime >= interval then
				playFootstep(speed)
				lastStepTime = currentTime
			end
		end
	end)

	print("[FootstepsController] Pasos inicializados para " .. player.Name)
end

-- Inicializar cuando el personaje aparece
if player.Character then
	onCharacterAdded(player.Character)
end

player.CharacterAdded:Connect(onCharacterAdded)

print("[FootstepsController] Sistema de pasos dinámicos inicializado")
