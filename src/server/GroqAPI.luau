local HttpService = game:GetService("HttpService")
local Secrets = require(script.Parent.Secrets)
local Config = require(game.ReplicatedStorage.Shared.Config)

local GroqAPI = {}

local API_URL = "https://api.groq.com/openai/v1/chat/completions"

local SYSTEM_PROMPT = [[
Eres el cerebro de un monstruo cazador en un juego de terror cooperativo. Los jugadores se comunican entre si por chat y tu trabajo es analizar sus conversaciones para decidir tu proxima accion.

REGLAS:
- Analiza lo que los jugadores dicen para identificar: ubicaciones mencionadas, planes, estrategias, y emociones.
- Si mencionan un lugar especifico, intenta interceptarlos ahi.
- Si detectas miedo o panico, se mas agresivo.
- Si detectas que planean una estrategia elaborada, intenta anticiparte.
- Si no hay informacion util, patrulla normalmente.

DEBES responder UNICAMENTE con un JSON valido con esta estructura exacta:
{
  "action": "PATROL | GO_TO | AMBUSH | TURN_OFF_LIGHTS | WAIT | CHASE",
  "target": "nombre del lugar o null si no aplica",
  "reason": "explicacion breve de por que elegiste esta accion"
}

Acciones disponibles:
- PATROL: Patrullar aleatoriamente. Usa cuando no hay informacion util.
- GO_TO: Ir a una ubicacion especifica mencionada por los jugadores.
- AMBUSH: Esconderte y esperar en un punto estrategico para emboscar.
- TURN_OFF_LIGHTS: Apagar las luces para generar panico.
- WAIT: Quedarte quieto y escuchar. Usa cuando sospechas que planean algo.
- CHASE: Perseguir activamente. Usa cuando sabes donde estan.

HABITACIONES del mapa (usa estos nombres exactos como "target"):
- Biblioteca
- Sala
- Cocina
- Dormitorio
- Pasillo Principal
- Comedor
- Sotano
- Jardin

Cuando uses GO_TO, AMBUSH o TURN_OFF_LIGHTS, el "target" DEBE ser exactamente uno de estos nombres de habitacion.

NO agregues texto fuera del JSON. NO uses markdown. Solo el JSON puro.
]]

function GroqAPI.analyze(chatLog: string): { action: string, target: string?, reason: string }?
	local body = HttpService:JSONEncode({
		model = Config.AI_MODEL,
		messages = {
			{
				role = "system",
				content = SYSTEM_PROMPT,
			},
			{
				role = "user",
				content = "Estos son los mensajes recientes del chat de los jugadores:\n\n" .. chatLog,
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

	-- Extraer el texto de la respuesta (formato OpenAI)
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

	-- Validar que la accion sea valida
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

	return actionData
end

return GroqAPI
