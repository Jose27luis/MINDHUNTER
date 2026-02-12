local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local AudioConfig = require(ReplicatedStorage.Shared.AudioConfig)

local player = Players.LocalPlayer

-- SoundGroup para música
local musicGroup = Instance.new("SoundGroup")
musicGroup.Name = "MusicGroup"
musicGroup.Volume = AudioConfig.MasterVolume.Music
musicGroup.Parent = SoundService

-- Tracks de música
local currentTrack: Sound? = nil
local tracks = {}

-- Crear todos los tracks
local function createTracks()
	for trackName, config in pairs(AudioConfig.Music) do
		local sound = Instance.new("Sound")
		sound.Name = trackName
		sound.SoundId = config.Id
		sound.Volume = 0 -- Empezar en 0 para fade in
		sound.Looped = config.Looped
		sound.SoundGroup = musicGroup
		sound.Parent = SoundService

		tracks[trackName] = {
			Sound = sound,
			TargetVolume = config.Volume,
		}
	end

	print("[MusicController] " .. #tracks .. " tracks cargados")
end

-- Fade in un track
local function fadeIn(trackData, duration: number?)
	local sound = trackData.Sound
	local targetVolume = trackData.TargetVolume
	duration = duration or AudioConfig.Transitions.FadeInDuration

	sound.Volume = 0
	sound:Play()

	local tween = TweenService:Create(
		sound,
		TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		{Volume = targetVolume}
	)
	tween:Play()

	return tween
end

-- Fade out un track
local function fadeOut(trackData, duration: number?)
	local sound = trackData.Sound
	duration = duration or AudioConfig.Transitions.FadeOutDuration

	local tween = TweenService:Create(
		sound,
		TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{Volume = 0}
	)
	tween:Play()

	tween.Completed:Connect(function()
		sound:Stop()
	end)

	return tween
end

-- Cambiar a un nuevo track con crossfade
local function changeTrack(trackName: string, forceFade: boolean?)
	local newTrackData = tracks[trackName]
	if not newTrackData then
		warn("[MusicController] Track no encontrado: " .. trackName)
		return
	end

	-- Si es el mismo track y está sonando, no hacer nada
	if currentTrack and currentTrack == newTrackData.Sound and currentTrack.Playing then
		return
	end

	local crossfadeDuration = forceFade and 0.5 or AudioConfig.Transitions.CrossfadeDuration

	-- Fade out del track actual
	if currentTrack and currentTrack.Playing then
		local oldTrackData = nil
		for _, data in pairs(tracks) do
			if data.Sound == currentTrack then
				oldTrackData = data
				break
			end
		end
		if oldTrackData then
			fadeOut(oldTrackData, crossfadeDuration)
		end
	end

	-- Fade in del nuevo track
	fadeIn(newTrackData, crossfadeDuration)
	currentTrack = newTrackData.Sound

	print("[MusicController] Cambiando a: " .. trackName)
end

-- Detener toda la música
local function stopAll()
	for _, trackData in pairs(tracks) do
		fadeOut(trackData, 0.5)
	end
	currentTrack = nil
	print("[MusicController] Música detenida")
end

-- Inicializar
createTracks()

-- Escuchar cambios de estado del juego
local statusValue = ReplicatedStorage:WaitForChild("Status")

statusValue.Changed:Connect(function(newStatus)
	-- Lobby / Esperando
	if newStatus:match("Esperando") or newStatus:match("La partida comienza") then
		changeTrack("Lobby")

	-- Jugando - Exploración
	elseif newStatus:match("ENCUENTRA") or newStatus:match("Llaves encontradas") then
		changeTrack("Exploration")

	-- Victoria
	elseif newStatus:match("ESCAPO") or newStatus:match("VICTORIA") then
		changeTrack("Victory")

	-- Derrota
	elseif newStatus:match("MURIERON") or newStatus:match("GAMEOVER") then
		changeTrack("Defeat")

	-- Tiempo agotado
	elseif newStatus:match("TIEMPO AGOTADO") then
		changeTrack("Defeat")
	end
end)

-- Escuchar eventos de cambio de música
local changeMusicEvent = Instance.new("RemoteEvent")
changeMusicEvent.Name = "ChangeMusic"
changeMusicEvent.Parent = ReplicatedStorage

changeMusicEvent.OnClientEvent:Connect(function(trackName: string)
	changeTrack(trackName, true)
end)

-- Sistema de música adaptativa basado en proximidad al monstruo
task.spawn(function()
	while true do
		task.wait(2)

		-- Solo en fase de juego
		if not statusValue.Value:match("ENCUENTRA") then
			continue
		end

		if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
			continue
		end

		-- Buscar al monstruo
		local monster = workspace:FindFirstChild("SenorBarriga") or workspace:FindFirstChild("ShadowHunter")
		if not monster or not monster:FindFirstChild("HumanoidRootPart") then
			continue
		end

		-- Calcular distancia
		local distance = (player.Character.HumanoidRootPart.Position - monster.HumanoidRootPart.Position).Magnitude

		-- Cambiar música según distancia
		if distance < 30 then
			-- MUY CERCA - Persecución intensa
			if currentTrack ~= tracks.Chase.Sound then
				changeTrack("Chase", true)
			end
		elseif distance < 60 then
			-- CERCA - Tensión alta
			if currentTrack ~= tracks.Tension.Sound and currentTrack ~= tracks.Chase.Sound then
				changeTrack("Tension")
			end
		else
			-- LEJOS - Exploración normal
			if currentTrack ~= tracks.Exploration.Sound then
				changeTrack("Exploration")
			end
		end
	end
end)

-- Empezar con música de lobby
changeTrack("Lobby")

print("[MusicController] Sistema de música adaptativa inicializado")
