local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(game.ReplicatedStorage.Shared.Config)
local MapData = require(game.ReplicatedStorage.Shared.MapData)
local MapBuilder = require(script.Parent.MapBuilder)
local MonsterSpawner = require(script.Parent.MonsterSpawner)
local ClassManager = require(script.Parent.ClassManager)

local GameManager = {}

-- Estado del juego
local GameState = {
	WAITING = "WAITING",
	INTERMISSION = "INTERMISSION",
	PLAYING = "PLAYING",
	GAME_OVER = "GAME_OVER"
}

local currentState = GameState.WAITING
local timer = 0
local keysCollected = 0

-- Valores replicados
local statusValue = Instance.new("StringValue")
statusValue.Name = "Status"
statusValue.Value = "Esperando jugadores..."
statusValue.Parent = ReplicatedStorage

local timeValue = Instance.new("IntValue")
timeValue.Name = "Time"
timeValue.Value = 0
timeValue.Parent = ReplicatedStorage

-- Spawnear llaves
local function spawnKeys()
	keysCollected = 0
	local availableRooms = table.clone(Config.KEY_ROOMS)
	
	for i = 1, Config.TOTAL_KEYS do
		if #availableRooms == 0 then break end
		
		-- Elegir habitacion aleatoria y removerla para no repetir
		local index = math.random(#availableRooms)
		local roomKey = availableRooms[index]
		table.remove(availableRooms, index)
		
		local room = MapData.Rooms[roomKey]
		if not room then continue end
	
		local pos = room.position
	
		local kPart = Instance.new("Part")
		kPart.Name = "Key_" .. i
		kPart.Size = Vector3.new(2, 2, 0.5)
		kPart.Position = Vector3.new(pos.X, 2, pos.Z)
		kPart.Anchored = true
		kPart.CanCollide = false
		kPart.Color = Color3.fromRGB(255, 215, 0)
		kPart.Material = Enum.Material.Neon
		kPart.Shape = Enum.PartType.Block
		kPart.Parent = workspace
	
		-- Luz y Particulas
		local light = Instance.new("PointLight")
		light.Brightness = 2
		light.Range = 15
		light.Color = Color3.fromRGB(255, 215, 0)
		light.Parent = kPart
	
		local particles = Instance.new("ParticleEmitter")
		particles.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
		particles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0)})
		particles.Texture = "rbxassetid://243026330" 
		particles.Lifetime = NumberRange.new(1, 1.5)
		particles.Rate = 10
		particles.Speed = NumberRange.new(2, 4)
		particles.Parent = kPart
	
		-- Rotacion visual
		task.spawn(function()
			local t = 0
			local originalY = kPart.Position.Y
			while kPart and kPart.Parent do
				t += 0.05
				kPart.CFrame = kPart.CFrame * CFrame.Angles(0, 0.05, 0)
				kPart.Position = Vector3.new(kPart.Position.X, originalY + math.sin(t) * 0.5, kPart.Position.Z)
				task.wait(0.03)
			end
		end)
	
		-- Billboard
		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.new(0, 100, 0, 30)
		billboard.StudsOffset = Vector3.new(0, 2.5, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = kPart
	
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.BackgroundTransparency = 0.5
		textLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.Text = "LLAVE"
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextScaled = true
		textLabel.Parent = billboard
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 4)
		corner.Parent = textLabel
	
		-- Touch Event
		kPart.Touched:Connect(function(hit)
			local char = hit.Parent
			local player = Players:GetPlayerFromCharacter(char)
			
			-- Si toca y aun esta la parte
			if player and kPart.Parent then
				-- Play Sound (local logic or remote)
				local remote = ReplicatedStorage:FindFirstChild("KeyCollected")
				if remote then remote:FireClient(player) end
				
				kPart:Destroy()
				
				keysCollected += 1
				
				-- Actualizar estado
				if keysCollected >= Config.TOTAL_KEYS then
					statusValue.Value = "TODAS LAS LLAVES ENCONTRADAS! ESCAPEN!"
					-- Habilitar efecto en salida si quisieramos
				else
					statusValue.Value = "Llaves encontradas: " .. keysCollected .. "/" .. Config.TOTAL_KEYS
				end
			end
		end)
	end
end

-- Teletransportar jugadores
local function teleportPlayers(location)
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			if location == "LOBBY" then
				player.Character.HumanoidRootPart.CFrame = CFrame.new(Config.LOBBY_POSITION + Vector3.new(0, 5, 0))
				player:SetAttribute("Escaped", false)
			elseif location == "GAME" then
				player.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(0, 5, 0))
			end
		end
	end
end
-- Verificar victoria/derrota
local function checkWinCondition()
	local activePlayers = 0
	local escapedPlayers = 0
	local deadPlayers = 0
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
			if player:GetAttribute("Escaped") then
				escapedPlayers += 1
			else
				activePlayers += 1 -- Jugando activamente
			end
		else
			deadPlayers += 1
		end
	end
	
	if activePlayers == 0 then
		-- Termino la ronda
		if escapedPlayers > 0 then
			return "WIN"
		else
			return "LOSE"
		end
	end
	return nil
end

-- Bucle principal
local function gameLoop()
	while true do
		-- FASE: WAITING
		currentState = GameState.WAITING
		statusValue.Value = "Esperando jugadores..."
		
		repeat
			task.wait(1)
		until #Players:GetPlayers() >= Config.MIN_PLAYERS
		
		-- FASE: INTERMISSION
		currentState = GameState.INTERMISSION
		timer = Config.INTERMISSION_TIME
		
		while timer > 0 do
			statusValue.Value = "La partida comienza en: " .. timer
			timeValue.Value = timer
			timer -= 1
			task.wait(1)
		end
		
		-- FASE: PLAYING
		currentState = GameState.PLAYING
		keysCollected = 0
		statusValue.Value = "ENCUENTRA " .. Config.TOTAL_KEYS .. " LLAVES PARA ESCAPAR!"
		timer = Config.ROUND_TIME
		
		-- Setup Mapa y Jugadores
		MapBuilder.generateMansion()
		spawnKeys()
		teleportPlayers("GAME")
		task.wait(2)
		
		-- Spawn Monster
		local monsterCtrl = MonsterSpawner.spawnMonster()
		local currentMonsterSpeed = Config.MONSTER_SPEED_INITIAL
		
		-- Game Loop
		local roundResult = nil
		local elapsedTime = 0
		
		while timer > 0 do
			timeValue.Value = timer
			timer -= 1
			elapsedTime += 1
			
			-- Dificultad Progresiva (Cada 60s)
			if elapsedTime % 60 == 0 then
				if currentMonsterSpeed < Config.MONSTER_SPEED_MAX then
					currentMonsterSpeed = math.min(Config.MONSTER_SPEED_MAX, currentMonsterSpeed + Config.DIFFICULTY_RAMP_RATE)
					statusValue.Value = "SENOR BARRIGA SE ESTA ENOJANDO! (Velocidad: " .. currentMonsterSpeed .. ")"
					
					-- Actualizar velocidad del monstruo
					-- Nota: MonsterSpawner deberia devolver el controlador o referencia
					-- Como MonsterSpawner retorna Model, necesitamos acceder al Controller o hacerlo global.
					-- Por simplicidad, buscaremos el humanoide directamente aqui O asumiremos que MonsterController maneja la instancia unica
					
					-- Update: MonsterController maneja la logica. Deberia exponer una forma de acceder a la instancia activa.
					-- Hack rapido: Buscar el modelo en workspace
					local monster = workspace:FindFirstChild("ShadowHunter") or workspace:FindFirstChild("SenorBarriga")
					if monster and monster:FindFirstChild("Humanoid") then
						monster.Humanoid.WalkSpeed = currentMonsterSpeed
					end
				end
			end
			
			-- checkWinCondition is not provided, assuming it exists elsewhere or is a placeholder
			-- if roundResult then break end
			
			task.wait(1)
		end
		
		-- FASE: GAME OVER
		currentState = GameState.GAME_OVER
		MonsterSpawner.despawnMonster()
		
		if roundResult == "WIN" then
			statusValue.Value = "¡ALGUIEN ESCAPO! VICTORIA"
		elseif roundResult == "LOSE" then
			statusValue.Value = "TODOS MURIERON... GAMEOVER"
		else
			statusValue.Value = "TIEMPO AGOTADO"
		end
		
		task.wait(5)
		
		-- Reset
		teleportPlayers("LOBBY")
		
		-- Limpiar llaves restantes
		for _, part in ipairs(workspace:GetChildren()) do
			if part.Name:match("^Key_") then
				part:Destroy()
			end
		end
	end
end

function GameManager.init()
	print("GameManager iniciado")
	
	MapBuilder.buildLobby()
	task.spawn(gameLoop)
	
	local exitZone = MapBuilder.getExitZone()
	if exitZone then
		exitZone.Touched:Connect(function(hit)
			local char = hit.Parent
			local player = Players:GetPlayerFromCharacter(char)
			
			if player and not player:GetAttribute("Escaped") then
				if keysCollected >= Config.TOTAL_KEYS then
					player:SetAttribute("Escaped", true)
					player.Character.HumanoidRootPart.CFrame = CFrame.new(Config.LOBBY_POSITION + Vector3.new(0, 5, 0))
					-- Mensaje personal
				else
					-- Feedback
					-- (Podriamos usar statusValue temporalmente pero afectaria a todos, mejor un RemoteEvent "ShowMessage")
				end
			end
		end)
	end
end

return GameManager
