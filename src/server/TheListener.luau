local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(game.ReplicatedStorage.Shared.Config)
local GroqAPI = require(script.Parent.GroqAPI)
local MonsterController = require(script.Parent.MonsterController)
local MonsterMemory = require(script.Parent.MonsterMemory)

local TheListener = {}

-- Buffer de mensajes acumulados
local chatBuffer: { string } = {}
local isProcessing = false

-- Agregar mensaje al buffer (con filtro de longitud)
local function onPlayerChatted(player: Player, message: string)
	if #message < Config.MIN_MESSAGE_LENGTH then
		return
	end

	local entry = string.format("[%s]: %s", player.Name, message)
	table.insert(chatBuffer, entry)
	print("[TheListener] Mensaje capturado: " .. entry)
end

-- Conectar el evento Chatted de cada jugador
local function connectPlayer(player: Player)
	player.Chatted:Connect(function(message)
		onPlayerChatted(player, message)
	end)
end

-- Enviar speech del monstruo a todos los jugadores
local function handleMonsterSpeech(speech: string)
	local showMessageEvent = ReplicatedStorage:FindFirstChild("ShowMessage")
	if not showMessageEvent then return end

	local formattedSpeech = "\"" .. speech .. "\""

	for _, player in Players:GetPlayers() do
		showMessageEvent:FireClient(player, formattedSpeech, Config.MONSTER_SPEECH_COLOR)
	end

	print("[TheListener] Monster speech: " .. speech)
end

-- Enviar buffer acumulado a Groq y procesar respuesta
local function processBuffer()
	if isProcessing then return end

	-- Solo procesar si el monstruo existe en el mundo
	if not workspace:FindFirstChild("SenorBarriga") and not workspace:FindFirstChild("ShadowHunter") then
		return
	end

	isProcessing = true

	-- Copiar y limpiar el buffer
	local messages = table.clone(chatBuffer)
	table.clear(chatBuffer)

	local chatLog = ""
	if #messages > 0 then
		chatLog = table.concat(messages, "\n")
		print("[TheListener] Enviando " .. #messages .. " mensajes + memoria a Groq...")
	else
		print("[TheListener] Sin mensajes, enviando memoria a Groq...")
	end

	-- Construir contexto de memoria y personalidad
	local memoryContext = MonsterMemory.buildContextString()
	local personalityPhase = MonsterMemory.getPersonalityPhase()

	print("[TheListener] Fase: " .. personalityPhase)

	local actionData = GroqAPI.analyze(chatLog, memoryContext, personalityPhase)

	if actionData then
		print("[TheListener] === ACCION DEL MONSTRUO ===")
		print("[TheListener] Fase: " .. personalityPhase)
		print("[TheListener] Accion: " .. actionData.action)
		print("[TheListener] Objetivo: " .. tostring(actionData.target or "ninguno"))
		print("[TheListener] Razon: " .. tostring(actionData.reason))
		if actionData.speech then
			print("[TheListener] Speech: " .. actionData.speech)
		end
		print("[TheListener] ============================")

		-- Registrar accion en memoria
		MonsterMemory.recordAction(actionData.action, actionData.target, "ejecutando")

		-- Manejar speech (trash talk)
		if actionData.speech then
			handleMonsterSpeech(actionData.speech)
		end

		MonsterController.executeAction(actionData)
	else
		warn("[TheListener] No se obtuvo accion valida de Groq")
	end

	isProcessing = false
end

-- Iniciar el sistema
function TheListener.start()
	print("[TheListener] Iniciando sistema de escucha...")

	-- Conectar jugadores actuales
	for _, player in Players:GetPlayers() do
		connectPlayer(player)
	end

	-- Conectar jugadores que entren despues
	Players.PlayerAdded:Connect(connectPlayer)

	-- Loop principal: procesar buffer cada BUFFER_INTERVAL segundos
	task.spawn(function()
		while true do
			task.wait(Config.BUFFER_INTERVAL)
			processBuffer()
		end
	end)

	print("[TheListener] Sistema activo. Intervalo de analisis: " .. Config.BUFFER_INTERVAL .. "s")
end

return TheListener
