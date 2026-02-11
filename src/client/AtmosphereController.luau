local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Config = require(game.ReplicatedStorage.Shared.Config)

local AtmosphereController = {}

local player = Players.LocalPlayer
local colorCorrection: ColorCorrectionEffect = nil
local blurEffect: BlurEffect = nil
local heartbeatSound: Sound = nil
local ambientSound: Sound = nil

-- Interpolar un valor entre min y max segun un factor 0-1
local function lerp(a: number, b: number, t: number): number
	return a + (b - a) * math.clamp(t, 0, 1)
end

-- Crear efectos de post-procesamiento en Lighting
local function createPostProcessing()
	colorCorrection = Instance.new("ColorCorrectionEffect")
	colorCorrection.Name = "HorrorCC"
	colorCorrection.Saturation = 0
	colorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
	colorCorrection.Brightness = 0
	colorCorrection.Contrast = 0
	colorCorrection.Parent = Lighting

	blurEffect = Instance.new("BlurEffect")
	blurEffect.Name = "HorrorBlur"
	blurEffect.Size = 0
	blurEffect.Parent = Lighting
end

-- Crear sonidos ambientales (locales al cliente)
local function createSounds()
	-- Sonido de heartbeat (sube con proximidad)
	heartbeatSound = Instance.new("Sound")
	heartbeatSound.Name = "Heartbeat"
	heartbeatSound.SoundId = "rbxassetid://9113088671"
	heartbeatSound.Volume = 0
	heartbeatSound.Looped = true
	heartbeatSound.Parent = player.PlayerGui
	heartbeatSound:Play()

	-- Sonido ambiente horror (constante, bajo volumen)
	ambientSound = Instance.new("Sound")
	ambientSound.Name = "Ambient"
	-- Sonidos de ambiente (IDs genericos de Roblox)
	local ambientSoundIds = {
		"rbxassetid://1839257625", -- Viento
		"rbxassetid://1843516309", -- Susurros
		"rbxassetid://9046903332", -- Latidos (o similar)
	}
	ambientSound.SoundId = ambientSoundIds[math.random(1, #ambientSoundIds)]
	ambientSound.Volume = 0.3
	ambientSound.Looped = true
	ambientSound.Parent = player.PlayerGui
	ambientSound:Play()
end

-- Agregar linterna al personaje
local function addFlashlight(character: Model)
	local head = character:WaitForChild("Head", 5)
	if not head then return end

	-- Evitar duplicados
	if head:FindFirstChild("Flashlight") then return end

	local spotlight = Instance.new("SpotLight")
	spotlight.Name = "Flashlight"
	spotlight.Brightness = Config.FLASHLIGHT_BRIGHTNESS
	spotlight.Range = Config.FLASHLIGHT_RANGE
	spotlight.Angle = Config.FLASHLIGHT_ANGLE
	spotlight.Face = Enum.NormalId.Front
	spotlight.Color = Color3.fromRGB(255, 250, 230)
	spotlight.Parent = head
end

-- Obtener distancia al monstruo
local function getMonsterDistance(): number
	local character = player.Character
	if not character then return math.huge end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return math.huge end

	local monster = workspace:FindFirstChild("SenorBarriga")
	if not monster then return math.huge end

	local monsterRoot = monster.PrimaryPart
	if not monsterRoot then return math.huge end

	return (rootPart.Position - monsterRoot.Position).Magnitude
end

-- Actualizar efectos segun proximidad al monstruo
local function updateProximityEffects()
	local dist = getMonsterDistance()

	-- Calcular intensidad (0 = lejos, 1 = muy cerca)
	local intensity = 0
	if dist < Config.PROXIMITY_FAR then
		intensity = 1 - (dist / Config.PROXIMITY_FAR)
	end

	-- Calcular nivel de peligro (para efectos mas fuertes)
	local danger = 0
	if dist < Config.PROXIMITY_MID then
		danger = 1 - (dist / Config.PROXIMITY_MID)
	end

	local critical = 0
	if dist < Config.PROXIMITY_CLOSE then
		critical = 1 - (dist / Config.PROXIMITY_CLOSE)
	end

	-- Heartbeat: sube de volumen con la proximidad
	if heartbeatSound then
		heartbeatSound.Volume = lerp(0, 1, intensity)
		-- Pitch sube cuando esta muy cerca (mas urgente)
		heartbeatSound.PlaybackSpeed = lerp(0.8, 1.3, danger)
	end

	-- Color correction: desaturacion + tinte rojizo
	if colorCorrection then
		colorCorrection.Saturation = lerp(0, -0.8, intensity)
		colorCorrection.Contrast = lerp(0, 0.15, danger)

		local r = lerp(255, 255, 0)
		local g = lerp(255, 200, danger)
		local b = lerp(255, 180, danger)
		colorCorrection.TintColor = Color3.fromRGB(r, g, b)
	end

	-- Blur: aumenta en proximidad critica
	if blurEffect then
		blurEffect.Size = lerp(0, 6, critical)
	end
end

function AtmosphereController.init()
	print("[AtmosphereController] Iniciando atmosfera de horror...")

	createPostProcessing()
	createSounds()

	-- Linterna al spawnear
	if player.Character then
		addFlashlight(player.Character)
	end
	player.CharacterAdded:Connect(function(character)
		task.wait(0.5) -- Esperar a que el personaje cargue
		addFlashlight(character)
	end)

	-- Loop de proximidad (cada frame)
	RunService.Heartbeat:Connect(updateProximityEffects)

	print("[AtmosphereController] Atmosfera activa")
end

return AtmosphereController
