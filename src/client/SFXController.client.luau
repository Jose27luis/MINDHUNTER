local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local AudioConfig = require(ReplicatedStorage.Shared.AudioConfig)

local player = Players.LocalPlayer

-- SoundGroup para SFX
local sfxGroup = Instance.new("SoundGroup")
sfxGroup.Name = "SFXGroup"
sfxGroup.Volume = AudioConfig.MasterVolume.SFX
sfxGroup.Parent = SoundService

-- Crear sonido de efecto
local function createSFX(config): Sound
	local sound = Instance.new("Sound")
	sound.SoundId = config.Id
	sound.Volume = config.Volume
	sound.Looped = config.Looped or false
	sound.SoundGroup = sfxGroup
	sound.Parent = SoundService
	return sound
end

-- Cache de sonidos
local sounds = {}

-- Pre-cargar todos los SFX
for sfxName, config in pairs(AudioConfig.SFX) do
	sounds[sfxName] = createSFX(config)
end

print("[SFXController] " .. #sounds .. " efectos de sonido cargados")

-- Reproducir un efecto
local function playSFX(sfxName: string, parent: Instance?)
	local sound = sounds[sfxName]
	if not sound then
		warn("[SFXController] Efecto no encontrado: " .. sfxName)
		return
	end

	-- Si tiene parent, crear una copia 3D
	if parent then
		local soundClone = sound:Clone()
		soundClone.Parent = parent
		soundClone:Play()
		soundClone.Ended:Connect(function()
			soundClone:Destroy()
		end)
	else
		-- Reproducir directamente
		sound:Play()
	end
end

-- Escuchar evento de llave recogida
local keyCollectedEvent = ReplicatedStorage:WaitForChild("KeyCollected")
keyCollectedEvent.OnClientEvent:Connect(function()
	playSFX("KeyPickup")
	print("[SFXController] Llave recogida - sonido reproducido")
end)

-- Escuchar evento de escape exitoso
local playerEscapedEvent = ReplicatedStorage:WaitForChild("PlayerEscaped")
playerEscapedEvent.OnClientEvent:Connect(function()
	playSFX("EscapeSuccess")
	print("[SFXController] Escape exitoso - sonido reproducido")
end)

-- Monitorear salud para sonido de daño
local function onCharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid")
	local lastHealth = humanoid.Health

	humanoid.HealthChanged:Connect(function(health)
		if health < lastHealth then
			-- Recibió daño
			playSFX("TakeDamage", character.HumanoidRootPart)
		end
		lastHealth = health
	end)

	-- Monitorear muerte
	humanoid.Died:Connect(function()
		playSFX("PlayerDeath")
	end)
end

if player.Character then
	onCharacterAdded(player.Character)
end

player.CharacterAdded:Connect(onCharacterAdded)

-- Sistema de heartbeat adaptativo (aumenta con proximidad)
local heartbeatSound = sounds.Heartbeat
local baseVolume = AudioConfig.SFX.Heartbeat.Volume

task.spawn(function()
	while true do
		task.wait(1)

		if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
			heartbeatSound:Stop()
			continue
		end

		-- Verificar si está en juego
		local status = ReplicatedStorage:FindFirstChild("Status")
		if not status or not status.Value:match("ENCUENTRA") then
			heartbeatSound:Stop()
			continue
		end

		-- Buscar monstruo
		local monster = workspace:FindFirstChild("SenorBarriga") or workspace:FindFirstChild("ShadowHunter")
		if not monster or not monster:FindFirstChild("HumanoidRootPart") then
			heartbeatSound:Stop()
			continue
		end

		-- Calcular distancia
		local distance = (player.Character.HumanoidRootPart.Position - monster.HumanoidRootPart.Position).Magnitude

		-- Ajustar heartbeat según distancia
		if distance < 60 then
			if not heartbeatSound.Playing then
				heartbeatSound:Play()
			end

			-- Volumen y velocidad según proximidad
			local intensity = math.clamp(1 - (distance / 60), 0.2, 1)
			heartbeatSound.Volume = baseVolume * intensity * 2
			heartbeatSound.PlaybackSpeed = 0.8 + (intensity * 0.4)
		else
			heartbeatSound:Stop()
		end
	end
end)

-- Susurros aleatorios en el ambiente
task.spawn(function()
	local whispersSound = sounds.Whispers

	while true do
		task.wait(math.random(30, 60))

		-- Solo en juego
		local status = ReplicatedStorage:FindFirstChild("Status")
		if status and status.Value:match("ENCUENTRA") then
			whispersSound:Play()
			task.wait(5)
			whispersSound:Stop()
		end
	end
end)

print("[SFXController] Sistema de efectos de sonido inicializado")
