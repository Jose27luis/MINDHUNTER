local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MapBuilder = require(script.MapBuilder)
local MonsterSpawner = require(script.MonsterSpawner)
local MonsterController = require(script.MonsterController)
local GameManager = require(script.GameManager)
local TheListener = require(script.TheListener)
local DataStoreManager = require(script.DataStoreManager)

print("[MindHunter] Servidor iniciado")

-- 0. Crear RemoteEvents para comunicacion server-client
local function createRemote(name: string): RemoteEvent
	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = ReplicatedStorage
	return remote
end

createRemote("KeyCollected")
createRemote("PlayerEscaped")
createRemote("ShowMessage")

-- 1. Inicializar DataStore (cargar/guardar datos de jugadores)
DataStoreManager.init()

-- 2. Iniciar el sistema de juego (maneja mapa, rondas, y monstruo)
GameManager.init()

-- 3. Iniciar el sistema de escucha de IA
TheListener.start()

print("[MindHunter] Todos los sistemas activos")
