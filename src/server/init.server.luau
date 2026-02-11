local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MapBuilder = require(script.MapBuilder)
local MonsterSpawner = require(script.MonsterSpawner)
local MonsterController = require(script.MonsterController)
local GameManager = require(script.GameManager)
local TheListener = require(script.TheListener)

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

-- 1. Construir el mapa
MapBuilder.build()

-- 2. Spawnear el monstruo
local monster = MonsterSpawner.spawn()

-- 3. Inicializar el controlador del monstruo
local lights = MapBuilder.getLights()
MonsterController.init(monster, lights)

-- 4. Iniciar el sistema de juego (llave + escape)
GameManager.init()

-- 5. Iniciar el sistema de escucha
TheListener.start()

print("[MindHunter] Todos los sistemas activos")
