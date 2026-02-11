local Players = game:GetService("Players")
local Config = require(game.ReplicatedStorage.Shared.Config)
local GroqAPI = require(script.Parent.GroqAPI)
local MonsterController = require(script.Parent.MonsterController)

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

-- Enviar buffer acumulado a Groq y procesar respuesta
local function processBuffer()
	if #chatBuffer == 0 or isProcessing then
		return
	end

	isProcessing = true

	-- Copiar y limpiar el buffer
	local messages = table.clone(chatBuffer)
	table.clear(chatBuffer)

	local chatLog = table.concat(messages, "\n")
	print("[TheListener] Enviando " .. #messages .. " mensajes a Groq...")

	local actionData = GroqAPI.analyze(chatLog)

	if actionData then
		print("[TheListener] === ACCION DEL MONSTRUO ===")
		print("[TheListener] Accion: " .. actionData.action)
		print("[TheListener] Objetivo: " .. tostring(actionData.target or "ninguno"))
		print("[TheListener] Razon: " .. tostring(actionData.reason))
		print("[TheListener] ============================")

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
