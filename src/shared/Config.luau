local Config = {}

-- Modelo de IA (Groq)
Config.AI_MODEL = "llama-3.3-70b-versatile"
Config.MAX_TOKENS = 350

-- Buffer de chat
Config.BUFFER_INTERVAL = 12 -- segundos entre envios a la API
Config.MIN_MESSAGE_LENGTH = 3 -- ignorar mensajes muy cortos ("lol", "xd", etc.)

-- Acciones validas del monstruo
Config.VALID_ACTIONS = {
	"PATROL",
	"GO_TO",
	"AMBUSH",
	"TURN_OFF_LIGHTS",
	"WAIT",
	"CHASE",
}

-- Monstruo
Config.MONSTER_WALK_SPEED = 14
Config.MONSTER_CHASE_SPEED = 18
Config.CHASE_UPDATE_INTERVAL = 0.5

-- Dificultad Progresiva
Config.MONSTER_SPEED_INITIAL = 14
Config.MONSTER_SPEED_MAX = 22
Config.DIFFICULTY_RAMP_RATE = 1 -- Aumento de velocidad por minuto

-- Luces
Config.LIGHTS_OFF_DURATION = 15

-- Dano del monstruo
Config.MONSTER_DAMAGE = 50
Config.DAMAGE_COOLDOWN = 1.5

-- Llave y escape
-- Llave y escape
Config.TOTAL_KEYS = 3
Config.KEY_ROOMS = { "Biblioteca", "Sala", "Cocina", "Dormitorio", "PasilloPrincipal", "Comedor", "Oficina", "Bano", "Almacen", "CuartoHuespedes" }

-- Linterna del jugador
Config.FLASHLIGHT_RANGE = 40
Config.FLASHLIGHT_BRIGHTNESS = 1.5
Config.FLASHLIGHT_ANGLE = 45

-- Proximidad del monstruo (efectos de horror)
Config.PROXIMITY_FAR = 60
Config.PROXIMITY_MID = 40
Config.PROXIMITY_CLOSE = 20

-- Luces de habitaciones
-- Luces de habitaciones
Config.ROOM_LIGHT_RANGE = 15

-- Sprint y Stamina
Config.WALK_SPEED_NORMAL = 16
Config.WALK_SPEED_RUN = 26
Config.STAMINA_MAX = 100
Config.STAMINA_DRAIN_RATE = 20 -- por segundo
Config.STAMINA_REGEN_RATE = 10 -- por segundo
Config.STAMINA_REGEN_RATE = 10 -- por segundo
Config.STAMINA_REGEN_DELAY = 1 -- segundos antes de regenerar

-- Sistema de Rondas
Config.MIN_PLAYERS = 1
Config.INTERMISSION_TIME = 10
Config.ROUND_TIME = 300 -- 5 minutos
Config.LOBBY_POSITION = Vector3.new(0, 500, 0) -- Cielo

-- Clases (Roles)
Config.CLASSES = {
	Runner = {
		WalkSpeed = 18,
		RunSpeed = 28,
		MaxHealth = 80,
		StaminaMax = 150,
		Description = "Rapido y agil, pero fragil."
	},
	Tank = {
		WalkSpeed = 14,
		RunSpeed = 24,
		MaxHealth = 150,
		StaminaMax = 80,
		Description = "Resistente (3 golpes), pero lento."
	},
	Scout = {
		WalkSpeed = 16,
		RunSpeed = 26,
		MaxHealth = 100,
		StaminaMax = 100,
		Description = "Balanceado."
	}
}

-- Fase 9: Memoria del monstruo
Config.MAX_ACTION_HISTORY = 6
Config.MAX_SIGHTINGS = 10
Config.SIGHTING_COOLDOWN = 10
Config.SIGHTING_RANGE = 60

-- Fase 9: Fases de personalidad (segundos desde inicio de ronda)
Config.PHASE_CAUTIOUS_END = 100
Config.PHASE_AGGRESSIVE_END = 200

-- Fase 9: Speech del monstruo
Config.MONSTER_SPEECH_COLOR = Color3.fromRGB(200, 30, 30)

return Config
