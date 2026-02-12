local HttpService = game:GetService("HttpService")
local Secrets = require(script.Parent.Secrets)
local Config = require(game.ReplicatedStorage.Shared.Config)

local GroqAPI = {}

local API_URL = "https://api.groq.com/openai/v1/chat/completions"

-- Prompt base del monstruo (sin personalidad, esa se inyecta dinamicamente)
local BASE_SYSTEM_PROMPT = [[
Eres el cerebro de un monstruo cazador en un juego de terror cooperativo. Los jugadores se comunican entre si por chat y tu trabajo es analizar sus conversaciones para decidir tu proxima accion.

REGLAS:
- Analiza lo que los jugadores dicen para identificar: ubicaciones mencionadas, planes, estrategias, y emociones.
- Si mencionan un lugar especifico, intenta interceptarlos ahi.
- Si detectas miedo o panico, se mas agresivo.
- Si detectas que planean una estrategia elaborada, intenta anticiparte.
- Si no hay informacion util, usa tu memoria para tomar decisiones inteligentes.
- USA TU MEMORIA: revisa habitaciones visitadas, avistamientos y acciones previas. No repitas la misma accion en el mismo lugar.
- Prioriza habitaciones que NO has visitado recientemente.

DEBES responder UNICAMENTE con un JSON valido con esta estructura exacta:
{
  "action": "PATROL | GO_TO | AMBUSH | TURN_OFF_LIGHTS | WAIT | CHASE",
  "target": "nombre del lugar o null si no aplica",
  "reason": "explicacion breve",
  "speech": "frase amenazante corta o null"
}

Acciones disponibles:
- PATROL: Patrullar aleatoriamente.
- GO_TO: Ir a una ubicacion especifica.
- AMBUSH: Esconderte y esperar para emboscar.
- TURN_OFF_LIGHTS: Apagar las luces para generar panico.
- WAIT: Quedarte quieto y escuchar.
- CHASE: Perseguir activamente.

HABITACIONES del mapa (usa estos nombres exactos como "target"):
Biblioteca, Sala, Cocina, Dormitorio, Pasillo Principal, Comedor, Sotano, Jardin, Oficina, Bano, Almacen, Huespedes, Pasillo Oscuro, Pasillo Oeste, Pasillo Este, Galeria Oeste, Galeria Este

CAMPO "speech":
- Frase corta y amenazante que dices a los jugadores. En espanol.
- Debe ser contextual (menciona lo que escuchaste o donde vas).
- No siempre hables. Pon null si no quieres decir nada (~40% de las veces).
- Ejemplos: "Te escuche mencionar la Biblioteca...", "No pueden esconderse para siempre", "Huelo miedo..."
- Maximo 60 caracteres.

NO agregues texto fuera del JSON. NO uses markdown. Solo el JSON puro.
]]

-- Bloques de personalidad segun fase de la ronda
local PERSONALITY_PHASES = {
	CAUTIOUS = [[PERSONALIDAD ACTUAL: CAUTELOSO
Eres paciente y calculador. Prefiere PATROL, AMBUSH y WAIT. Evita CHASE a menos que estes seguro. Apaga luces para crear tension. Habla poco, susurra.
]],
	AGGRESSIVE = [[PERSONALIDAD ACTUAL: AGRESIVO
Eres directo y peligroso. Usa GO_TO y CHASE con mas frecuencia. Apaga luces antes de atacar. Si recogieron una llave, busca agresivamente. Habla con confianza amenazante.
]],
	RELENTLESS = [[PERSONALIDAD ACTUAL: IMPLACABLE
Eres imparable. Usa CHASE y GO_TO casi siempre. No esperes, no patrulles pasivamente. Persigue sin descanso. Habla con crueldad y burla. El tiempo se acaba para ellos.
]],
}

function GroqAPI.analyze(chatLog: string, memoryContext: string?, personalityPhase: string?): { action: string, target: string?, reason: string, speech: string? }?
	-- Construir system prompt con personalidad
	local phase = personalityPhase or "CAUTIOUS"
	local personalityBlock = PERSONALITY_PHASES[phase] or PERSONALITY_PHASES.CAUTIOUS
	local systemPrompt = personalityBlock .. "\n" .. BASE_SYSTEM_PROMPT

	-- Construir mensaje del usuario con memoria + chat
	local userContent = ""

	if memoryContext and memoryContext ~= "" then
		userContent = "=== TU MEMORIA ===\n" .. memoryContext .. "\n\n"
	end

	if chatLog and chatLog ~= "" then
		userContent = userContent .. "=== CHAT DE JUGADORES ===\n" .. chatLog
	else
		userContent = userContent .. "=== CHAT DE JUGADORES ===\n(Sin mensajes recientes. Decide basandote en tu memoria.)"
	end

	local body = HttpService:JSONEncode({
		model = Config.AI_MODEL,
		messages = {
			{
				role = "system",
				content = systemPrompt,
			},
			{
				role = "user",
				content = userContent,
			},
		},
		max_tokens = Config.MAX_TOKENS,
	})

	local success, result = pcall(function()
		return HttpService:RequestAsync({
			Url = API_URL,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
				["Authorization"] = "Bearer " .. Secrets.API_KEY,
			},
			Body = body,
		})
	end)

	if not success then
		warn("[GroqAPI] Error de conexion: " .. tostring(result))
		return nil
	end

	if result.StatusCode ~= 200 then
		warn("[GroqAPI] Error HTTP " .. result.StatusCode .. ": " .. result.Body)
		return nil
	end

	local responseSuccess, responseData = pcall(function()
		return HttpService:JSONDecode(result.Body)
	end)

	if not responseSuccess then
		warn("[GroqAPI] Error al decodificar respuesta: " .. tostring(responseData))
		return nil
	end

	local messageText = responseData.choices
		and responseData.choices[1]
		and responseData.choices[1].message
		and responseData.choices[1].message.content

	if not messageText then
		warn("[GroqAPI] Respuesta sin contenido de texto")
		return nil
	end

	-- Limpiar posible markdown
	messageText = messageText:gsub("```json%s*", ""):gsub("```%s*", ""):gsub("^%s+", ""):gsub("%s+$", "")

	-- Parsear el JSON de la accion del monstruo
	local actionSuccess, actionData = pcall(function()
		return HttpService:JSONDecode(messageText)
	end)

	if not actionSuccess then
		warn("[GroqAPI] La IA no devolvio JSON valido: " .. messageText)
		return nil
	end

	-- Validar accion
	local validAction = false
	for _, action in Config.VALID_ACTIONS do
		if actionData.action == action then
			validAction = true
			break
		end
	end

	if not validAction then
		warn("[GroqAPI] Accion no reconocida: " .. tostring(actionData.action))
		return nil
	end

	-- Validar speech (nullable)
	local speech = actionData.speech
	if speech ~= nil then
		if type(speech) ~= "string" or speech == "null" or speech == "" then
			speech = nil
		elseif #speech > 100 then
			speech = string.sub(speech, 1, 100)
		end
	end
	actionData.speech = speech

	return actionData
end

return GroqAPI
