local Players = game:GetService("Players")
local Config = require(game.ReplicatedStorage.Shared.Config)
local MapData = require(game.ReplicatedStorage.Shared.MapData)

local MonsterSpawner = {}

-- Cooldowns de dano por jugador
local damageCooldowns: { [Player]: boolean } = {}

function MonsterSpawner.spawn(): Model?
	local spawnRoom = MapData.Rooms[MapData.MONSTER_SPAWN_ROOM]
	if not spawnRoom then
		warn("[MonsterSpawner] Habitacion de spawn no encontrada: " .. MapData.MONSTER_SPAWN_ROOM)
		return nil
	end

	-- Spawn ligeramente elevado para que caiga al piso
	local spawnPos = spawnRoom.position + Vector3.new(0, 5, 0)

	local model = Instance.new("Model")
	model.Name = "SenorBarriga" -- Nombre restaurado

	-- HumanoidRootPart (invisible, controla el movimiento)
	local rootPart = Instance.new("Part")
	rootPart.Name = "HumanoidRootPart"
	rootPart.Size = Vector3.new(2, 2, 1)
	rootPart.Transparency = 1
	rootPart.CanCollide = false
	rootPart.CFrame = CFrame.new(spawnPos)
	rootPart.Parent = model

	-- Torso (Ancho y gordo)
	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(2.5, 2.5, 1.5) -- Gordo
	torso.Color = Color3.fromRGB(30, 40, 60) -- Traje azul oscuro
	torso.Material = Enum.Material.Fabric
	torso.CanCollide = true
	torso.Parent = model

	-- Head
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.2, 1.2, 1.2)
	head.Color = Color3.fromRGB(255, 200, 180) -- Piel
	head.Material = Enum.Material.SmoothPlastic
	head.CanCollide = false
	head.Parent = model
	
	-- Camisa blanca (Decal o Parte)
	local shirt = Instance.new("Part")
	shirt.Name = "Shirt"
	shirt.Size = Vector3.new(1.5, 1.5, 1.6)
	shirt.Color = Color3.fromRGB(255, 255, 255)
	shirt.Material = Enum.Material.Fabric
	shirt.CanCollide = false
	shirt.Parent = model
	
	local shirtWeld = Instance.new("Weld")
	shirtWeld.Part0 = torso
	shirtWeld.Part1 = shirt
	shirtWeld.C0 = CFrame.new(0, 0.4, 0)
	shirtWeld.Parent = torso

	-- Glasses
	local glasses = Instance.new("Part")
	glasses.Name = "Glasses"
	glasses.Size = Vector3.new(1.3, 0.3, 0.1)
	glasses.Color = Color3.fromRGB(0, 0, 0)
	glasses.Parent = head
	
	local gWeld = Instance.new("Weld")
	gWeld.Part0 = head
	gWeld.Part1 = glasses
	gWeld.C1 = CFrame.new(0, -0.1, -0.6)
	gWeld.Parent = head

	-- Limbs (Cortos y gruesos)
	local limbSize = Vector3.new(1, 2.5, 1)
	local suitColor = Color3.fromRGB(30, 40, 60)

	-- Left Arm
	local leftArm = Instance.new("Part")
	leftArm.Name = "Left Arm"
	leftArm.Size = limbSize
	leftArm.Color = suitColor
	leftArm.Material = Enum.Material.Fabric
	leftArm.CanCollide = false
	leftArm.Parent = model

	-- Right Arm
	local rightArm = Instance.new("Part")
	rightArm.Name = "Right Arm"
	rightArm.Size = limbSize
	rightArm.Color = suitColor
	rightArm.Material = Enum.Material.Fabric
	rightArm.CanCollide = false
	rightArm.Parent = model
	
	-- Maletin (Briefcase)
	local briefcase = Instance.new("Part")
	briefcase.Name = "Briefcase"
	briefcase.Size = Vector3.new(0.5, 1.5, 2)
	briefcase.Color = Color3.fromRGB(60, 40, 20) -- Cuero
	briefcase.Material = Enum.Material.Wood -- Cuero-ish
	briefcase.Parent = rightArm
	
	local caseWeld = Instance.new("Weld")
	caseWeld.Part0 = rightArm
	caseWeld.Part1 = briefcase
	caseWeld.C1 = CFrame.new(0, 1.5, 0)
	caseWeld.Parent = rightArm

	-- Left Leg
	local leftLeg = Instance.new("Part")
	leftLeg.Name = "Left Leg"
	leftLeg.Size = limbSize
	leftLeg.Color = suitColor
	leftLeg.Material = Enum.Material.Fabric
	leftLeg.CanCollide = false
	leftLeg.Parent = model

	-- Right Leg
	local rightLeg = Instance.new("Part")
	rightLeg.Name = "Right Leg"
	rightLeg.Size = limbSize
	rightLeg.Color = suitColor
	rightLeg.Material = Enum.Material.Fabric
	rightLeg.CanCollide = false
	rightLeg.Parent = model

	-- Motor6D joints
	local rootJoint = Instance.new("Motor6D")
	rootJoint.Name = "RootJoint"
	rootJoint.Part0 = rootPart
	rootJoint.Part1 = torso
	rootJoint.Parent = rootPart

	local neck = Instance.new("Motor6D")
	neck.Name = "Neck"
	neck.Part0 = torso
	neck.Part1 = head
	neck.C0 = CFrame.new(0, 1.3, 0) 
	neck.C1 = CFrame.new(0, -0.6, 0)
	neck.Parent = torso

	local leftShoulder = Instance.new("Motor6D")
	leftShoulder.Name = "Left Shoulder"
	leftShoulder.Part0 = torso
	leftShoulder.Part1 = leftArm
	leftShoulder.C0 = CFrame.new(-1.8, 0.5, 0) -- Mas ancho
	leftShoulder.C1 = CFrame.new(0, 1.0, 0)
	leftShoulder.Parent = torso

	local rightShoulder = Instance.new("Motor6D")
	rightShoulder.Name = "Right Shoulder"
	rightShoulder.Part0 = torso
	rightShoulder.Part1 = rightArm
	rightShoulder.C0 = CFrame.new(1.8, 0.5, 0) -- Mas ancho
	rightShoulder.C1 = CFrame.new(0, 1.0, 0)
	rightShoulder.Parent = torso

	local leftHip = Instance.new("Motor6D")
	leftHip.Name = "Left Hip"
	leftHip.Part0 = torso
	leftHip.Part1 = leftLeg
	leftHip.C0 = CFrame.new(-0.8, -1.2, 0)
	leftHip.C1 = CFrame.new(0, 1.0, 0)
	leftHip.Parent = torso

	local rightHip = Instance.new("Motor6D")
	rightHip.Name = "Right Hip"
	rightHip.Part0 = torso
	rightHip.Part1 = rightLeg
	rightHip.C0 = CFrame.new(0.8, -1.2, 0)
	rightHip.C1 = CFrame.new(0, 1.0, 0)
	rightHip.Parent = torso

	-- Humanoid
	local humanoid = Instance.new("Humanoid")
	humanoid.WalkSpeed = Config.MONSTER_WALK_SPEED
	humanoid.MaxHealth = math.huge
	humanoid.Health = math.huge
	humanoid.HipHeight = 1.5 -- Altura normal
	humanoid.Parent = model

	model.PrimaryPart = rootPart

	-- Sonido de pasos (Mas pesado y lento)
	local footsteps = Instance.new("Sound")
	footsteps.Name = "Footsteps"
	footsteps.SoundId = "rbxassetid://9112854444" -- ID hipotetico mas grave
	footsteps.PlaybackSpeed = 0.8
	footsteps.Volume = 1
	footsteps.Looped = true
	footsteps.RollOffMode = Enum.RollOffMode.InverseTapered
	footsteps.RollOffMinDistance = 10
	footsteps.RollOffMaxDistance = 60
	footsteps.Parent = rootPart
	footsteps:Play()

	-- Sonido de golpe
	local hitSound = Instance.new("Sound")
	hitSound.Name = "HitSound"
	hitSound.SoundId = "rbxassetid://9114386017"
	hitSound.Volume = 1
	hitSound.RollOffMode = Enum.RollOffMode.InverseTapered
	hitSound.RollOffMinDistance = 5
	hitSound.RollOffMaxDistance = 40
	hitSound.Parent = rootPart
	
	-- Particulas de sombra (Humo negro)
	local particle = Instance.new("ParticleEmitter")
	particle.Texture = "rbxassetid://243026330" -- Textura de humo generica
	particle.Color = ColorSequence.new(Color3.new(0,0,0))
	particle.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 3)})
	particle.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)})
	particle.Lifetime = NumberRange.new(1, 2)
	particle.Rate = 20
	particle.Speed = NumberRange.new(1, 2)
	particle.SpreadAngle = Vector2.new(360, 360)
	particle.Parent = torso

	-- Sistema de dano por contacto (hitbox en el Torso)
	torso.Touched:Connect(function(hit: BasePart)
		local character = hit.Parent
		if not character then return end

		local player = Players:GetPlayerFromCharacter(character)
		if not player then return end

		-- Cooldown activo
		if damageCooldowns[player] then return end

		local playerHumanoid = character:FindFirstChildOfClass("Humanoid")
		if not playerHumanoid or playerHumanoid.Health <= 0 then return end

		-- Aplicar dano
		playerHumanoid:TakeDamage(Config.MONSTER_DAMAGE)
		hitSound:Play()
		print("[MonsterSpawner] Dano aplicado a " .. player.Name .. " (" .. playerHumanoid.Health .. " HP)")

		-- Activar cooldown
		damageCooldowns[player] = true
		task.delay(Config.DAMAGE_COOLDOWN, function()
			damageCooldowns[player] = nil
		end)
	end)

	model.Parent = workspace

	print("[MonsterSpawner] Shadow Hunter spawneado en " .. MapData.MONSTER_SPAWN_ROOM)
	return model
end

return MonsterSpawner
