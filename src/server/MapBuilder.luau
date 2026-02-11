local MapData = require(game.ReplicatedStorage.Shared.MapData)
local Config = require(game.ReplicatedStorage.Shared.Config)

local MapBuilder = {}

local HALF_SIZE = MapData.ROOM_SIZE / 2
local HALF_WALL_H = MapData.WALL_HEIGHT / 2
local SIDE_WIDTH = (MapData.ROOM_SIZE - MapData.DOOR_WIDTH) / 2
local TOP_HEIGHT = MapData.WALL_HEIGHT - MapData.DOOR_HEIGHT
local TOP_CENTER_Y = MapData.DOOR_HEIGHT + TOP_HEIGHT / 2

local mansionFolder: Folder = nil

-- Crear una Part generica
local function createPart(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material?): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Material = material or Enum.Material.SmoothPlastic
	part.Parent = parent
	return part
end

-- Construir una pared (con o sin puerta)
local function buildWall(parent: Instance, roomPos: Vector3, side: string, hasDoor: boolean, wallColor: Color3?)
	local rx, rz = roomPos.X, roomPos.Z
	local thick = MapData.WALL_THICKNESS
	local color = wallColor or MapData.WALL_COLOR

	if side == "north" or side == "south" then
		local zOffset = if side == "north" then -HALF_SIZE else HALF_SIZE
		local wallZ = rz + zOffset

		if hasDoor then
			-- Seccion izquierda
			createPart(parent, side .. "_left",
				Vector3.new(SIDE_WIDTH, MapData.WALL_HEIGHT, thick),
				Vector3.new(rx - HALF_SIZE + SIDE_WIDTH / 2, HALF_WALL_H, wallZ),
				color,
				Enum.Material.Concrete
			)
			-- Seccion derecha
			createPart(parent, side .. "_right",
				Vector3.new(SIDE_WIDTH, MapData.WALL_HEIGHT, thick),
				Vector3.new(rx + HALF_SIZE - SIDE_WIDTH / 2, HALF_WALL_H, wallZ),
				color,
				Enum.Material.Concrete
			)
			-- Seccion superior (arriba de la puerta)
			if TOP_HEIGHT > 0 then
				createPart(parent, side .. "_top",
					Vector3.new(MapData.DOOR_WIDTH, TOP_HEIGHT, thick),
					Vector3.new(rx, TOP_CENTER_Y, wallZ),
					color,
					Enum.Material.Concrete
				)
			end
		else
			-- Pared solida
			createPart(parent, side .. "_wall",
				Vector3.new(MapData.ROOM_SIZE, MapData.WALL_HEIGHT, thick),
				Vector3.new(rx, HALF_WALL_H, wallZ),
				color,
				Enum.Material.Concrete
			)
		end
	else -- west o east
		local xOffset = if side == "west" then -HALF_SIZE else HALF_SIZE
		local wallX = rx + xOffset

		if hasDoor then
			-- Seccion frontal (Z negativo)
			createPart(parent, side .. "_front",
				Vector3.new(thick, MapData.WALL_HEIGHT, SIDE_WIDTH),
				Vector3.new(wallX, HALF_WALL_H, rz - HALF_SIZE + SIDE_WIDTH / 2),
				color,
				Enum.Material.Concrete
			)
			-- Seccion trasera (Z positivo)
			createPart(parent, side .. "_back",
				Vector3.new(thick, MapData.WALL_HEIGHT, SIDE_WIDTH),
				Vector3.new(wallX, HALF_WALL_H, rz + HALF_SIZE - SIDE_WIDTH / 2),
				color,
				Enum.Material.Concrete
			)
			-- Seccion superior
			if TOP_HEIGHT > 0 then
				createPart(parent, side .. "_top",
					Vector3.new(thick, TOP_HEIGHT, MapData.DOOR_WIDTH),
					Vector3.new(wallX, TOP_CENTER_Y, rz),
					color,
					Enum.Material.Concrete
				)
			end
		else
			-- Pared solida
			createPart(parent, side .. "_wall",
				Vector3.new(thick, MapData.WALL_HEIGHT, MapData.ROOM_SIZE),
				Vector3.new(wallX, HALF_WALL_H, rz),
				color,
				Enum.Material.Concrete
			)
		end
	end
end

-- Construir etiqueta flotante con el nombre de la habitacion
local function buildLabel(parent: Instance, pos: Vector3, displayName: string)
	local labelPart = Instance.new("Part")
	labelPart.Name = "Label"
	labelPart.Size = Vector3.new(1, 1, 1)
	labelPart.Position = Vector3.new(pos.X, MapData.WALL_HEIGHT - 2, pos.Z)
	labelPart.Anchored = true
	labelPart.Transparency = 1
	labelPart.CanCollide = false
	labelPart.Parent = parent

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "RoomLabel"
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 80
	billboard.Parent = labelPart

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Text"
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.BackgroundTransparency = 0.4
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.Text = displayName
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = billboard

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = textLabel
end

-- Construir una habitacion completa
local function buildRoom(roomName: string, roomData)
	local roomFolder = Instance.new("Folder")
	roomFolder.Name = roomName

	local pos = roomData.position
	local floorColor = roomData.floorColor or MapData.FLOOR_COLOR
	local wallColor = roomData.wallColor or MapData.WALL_COLOR

	-- Piso (color unico por habitacion)
	createPart(roomFolder, "Floor",
		Vector3.new(MapData.ROOM_SIZE, 0.5, MapData.ROOM_SIZE),
		Vector3.new(pos.X, 0.25, pos.Z),
		floorColor,
		Enum.Material.WoodPlanks
	)

	-- 4 paredes (color unico por habitacion)
	for _, side in { "north", "south", "west", "east" } do
		local hasDoor = roomData.doors[side] == true
		buildWall(roomFolder, pos, side, hasDoor, wallColor)
	end

	-- Luz de techo
	local lightPart = Instance.new("Part")
	lightPart.Name = "LightSource"
	lightPart.Size = Vector3.new(1, 0.5, 1)
	lightPart.Position = Vector3.new(pos.X, MapData.WALL_HEIGHT - 0.5, pos.Z)
	lightPart.Anchored = true
	lightPart.Transparency = 0.5
	lightPart.Color = Color3.fromRGB(255, 255, 200)
	lightPart.Material = Enum.Material.Neon
	lightPart.CanCollide = false
	lightPart.Parent = roomFolder

	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 1.5
	pointLight.Range = Config.ROOM_LIGHT_RANGE * 1.5 -- Rango aumentado por escala x2
	pointLight.Color = Color3.fromRGB(255, 220, 180)
	pointLight.Parent = lightPart

	-- Etiqueta con nombre de la habitacion
	buildLabel(roomFolder, pos, roomData.displayName or roomName)

	roomFolder.Parent = mansionFolder
end

-- Construir zona de escape en el Jardin
local function buildExitZone(): Part
	local jardin = MapData.Rooms.Jardin
	local pos = jardin.position

	local exitPart = Instance.new("Part")
	exitPart.Name = "ExitZone"
	exitPart.Size = Vector3.new(12, 1, 12) -- Plataforma en el suelo
	exitPart.Position = Vector3.new(pos.X, 0.5, pos.Z + HALF_SIZE - 20)
	exitPart.Anchored = true
	exitPart.CanCollide = false
	exitPart.Transparency = 0.5
	exitPart.Color = Color3.fromRGB(0, 255, 100)
	exitPart.Material = Enum.Material.Neon
	exitPart.Parent = mansionFolder

	-- Luz celestial
	local light = Instance.new("SurfaceLight")
	light.Face = Enum.NormalId.Top
	light.Brightness = 3
	light.Range = 20
	light.Color = Color3.fromRGB(150, 255, 200)
	light.Parent = exitPart

	-- Particulas de "Gateway" (Columnas de luz subiendo)
	local particles = Instance.new("ParticleEmitter")
	particles.Color = ColorSequence.new(Color3.fromRGB(100, 255, 150), Color3.fromRGB(255, 255, 255))
	particles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 2), NumberSequenceKeypoint.new(1, 0)})
	particles.Texture = "rbxassetid://243026330" 
	particles.Lifetime = NumberRange.new(3, 5)
	particles.Rate = 30
	particles.Speed = NumberRange.new(5, 8) -- Suben rapido
	particles.EmissionDirection = Enum.NormalId.Top
	particles.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)})
	particles.Parent = exitPart

	-- Etiqueta "SALIDA"
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ExitLabel"
	billboard.Size = UDim2.new(0, 200, 0, 60)
	billboard.StudsOffset = Vector3.new(0, 8, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 150
	billboard.Parent = exitPart

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundColor3 = Color3.fromRGB(0, 180, 70)
	textLabel.BackgroundTransparency = 0.3
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.Text = "SALIDA\n(Escapar)"
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = billboard

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = textLabel

	return exitPart
end

-- Construir toda la mansion
local exitZone: Part = nil

function MapBuilder.build()
	print("[MapBuilder] Construyendo mansion...")

	mansionFolder = Instance.new("Folder")
	mansionFolder.Name = "Mansion"
	mansionFolder.Parent = workspace

	local LockerSystem = require(script.Parent.LockerSystem)

	local count = 0
	for name, data in MapData.Rooms do
		-- Construir estructura basica (piso, paredes, techo)
		buildRoom(name, data)
		
		-- Generar Lockers en ciertas habitaciones
		if name == "PasilloPrincipal" or name == "Dormitorio" or name == "Pasillo Oscuro" or name == "Sotano" or name == "Almacen" then
			-- Colocar uno o dos lockers
			local roomPos = data.position
			-- Contra una pared lateral
			LockerSystem.createLocker(mansionFolder, roomPos + Vector3.new(15, 0, 15), 180) 
		end
		
		-- Agregar muebles
		if MapData.Furniture[name] then
			local roomFolder = mansionFolder:FindFirstChild(name)
			if roomFolder then
				for _, item in MapData.Furniture[name] do
					-- Ajustar posicion relativa a la habitacion
					-- Asumimos que la Y definida en MapData es relativa al centro (0), pero el suelo esta en 0.25
					-- Si el mueble apoya en el suelo, su Y deberia ser (Size.Y / 2)
					
					local size = item.Size
					local relPos = item.Position
					
					-- Si la Y es negativa en MapData, lo interpretamos como "pegado al suelo"
					-- Si es 0 o positiva, lo dejamos "flotando/centrado"
					local finalY = relPos.Y
					if relPos.Y < 0 then
						-- Calcular Y para que apoye en el suelo (0)
						finalY = (size.Y / 2)
					end
					
					local worldPos = data.position + Vector3.new(relPos.X, finalY, relPos.Z)
					
					local part = createPart(roomFolder, item.Name, size, worldPos, item.Color, item.Material)
					
					-- Manejo especial para pinturas (Painting)
					if item.Type == "Painting" then
						local decal = Instance.new("Decal")
						decal.Texture = "rbxassetid://9123896561" -- Textura de arte generica (Mona Lisa pixelada o similar)
						decal.Face = Enum.NormalId.Front
						decal.Parent = part
					end
				end
			end
		end

		-- Construir pasillos hacia vecinos
		-- Logica: Si tengo puerta SUR y mi vecino tiene puerta NORTE, conecto
		-- Solo procesamos SUR y ESTE para no duplicar pasillos (el vecino procesara SU sur/este)
		
		for dir, isActive in data.doors do
			if not isActive then continue end
			
			local neighborName = nil
			local neighborDir = nil
			local axis = nil -- "Z" or "X"
			
			-- Solo construimos conexiones "hacia adelante" o "hacia derecha" para no repetir
			if dir == "south" then
				-- Buscar vecino mas cercano al sur
				local minDist = math.huge
				
				for nName, nData in MapData.Rooms do
					-- Debe estar al sur (Z mayor) y alineado en X
					if nData.position.Z > data.position.Z and math.abs(nData.position.X - data.position.X) < 1 then
						if nData.doors and nData.doors.north then
							local dist = nData.position.Z - data.position.Z
							if dist < minDist then
								minDist = dist
								neighborName = nName
								neighborDir = "north"
								axis = "Z"
							end
						end
					end
				end
			elseif dir == "east" then
				-- Buscar vecino mas cercano al este
				local minDist = math.huge
				
				for nName, nData in MapData.Rooms do
					-- Debe estar al este (X mayor) y alineado en Z
					if nData.position.X > data.position.X and math.abs(nData.position.Z - data.position.Z) < 1 then
						if nData.doors and nData.doors.west then
							local dist = nData.position.X - data.position.X
							if dist < minDist then
								minDist = dist
								neighborName = nName
								neighborDir = "west"
								axis = "X"
							end
						end
					end
				end
			end
			
			if neighborName then
				print("[MapBuilder] CONECTANDO: " .. name .. " (" .. dir .. ") -> " .. neighborName)
				
				local nData = MapData.Rooms[neighborName]
				local p1 = data.position
				local p2 = nData.position
				
				local corridorLen = 0
				local centerPos = Vector3.new(0,0,0)
				local size = Vector3.new(0,0,0)
				
				-- Limitar la longitud del pasillo para evitar atravesar habitaciones si algo falla
				-- En grid 60, dist=60 -> Room=40 -> Corridor=20.
				-- Si dist=120, Corridor=80. Esto indicaria que saltamos una habitacion.
				
				if axis == "Z" then
					local dist = math.abs(p2.Z - p1.Z)
					corridorLen = dist - MapData.ROOM_SIZE
					
					if corridorLen > 0 then
						centerPos = (p1 + p2) / 2
						size = Vector3.new(MapData.DOOR_WIDTH, 0.5, corridorLen)
						
						createPart(mansionFolder, "CorridorFloor_" .. name .. "_" .. neighborName,
							size, Vector3.new(centerPos.X, 0.25, centerPos.Z), MapData.FLOOR_COLOR, Enum.Material.WoodPlanks)
							
						createPart(mansionFolder, "CorridorCeiling_" .. name .. "_" .. neighborName,
							size, Vector3.new(centerPos.X, MapData.WALL_HEIGHT, centerPos.Z), MapData.WALL_COLOR, Enum.Material.Concrete)
							
						local wallThick = 1
						createPart(mansionFolder, "CorridorWallW",
							Vector3.new(wallThick, MapData.WALL_HEIGHT, corridorLen),
							Vector3.new(centerPos.X - (MapData.DOOR_WIDTH/2) - (wallThick/2), HALF_WALL_H, centerPos.Z),
							MapData.WALL_COLOR, Enum.Material.Concrete)
							
						createPart(mansionFolder, "CorridorWallE",
							Vector3.new(wallThick, MapData.WALL_HEIGHT, corridorLen),
							Vector3.new(centerPos.X + (MapData.DOOR_WIDTH/2) + (wallThick/2), HALF_WALL_H, centerPos.Z),
							MapData.WALL_COLOR, Enum.Material.Concrete)
					end
				elseif axis == "X" then
					local dist = math.abs(p2.X - p1.X)
					corridorLen = dist - MapData.ROOM_SIZE
					
					if corridorLen > 0 then
						centerPos = (p1 + p2) / 2
						size = Vector3.new(corridorLen, 0.5, MapData.DOOR_WIDTH)
						
						createPart(mansionFolder, "CorridorFloor_" .. name .. "_" .. neighborName,
							size, Vector3.new(centerPos.X, 0.25, centerPos.Z), MapData.FLOOR_COLOR, Enum.Material.WoodPlanks)

						createPart(mansionFolder, "CorridorCeiling_" .. name .. "_" .. neighborName,
							size, Vector3.new(centerPos.X, MapData.WALL_HEIGHT, centerPos.Z), MapData.WALL_COLOR, Enum.Material.Concrete)
							
						local wallThick = 1
						createPart(mansionFolder, "CorridorWallN",
							Vector3.new(corridorLen, MapData.WALL_HEIGHT, wallThick),
							Vector3.new(centerPos.X, HALF_WALL_H, centerPos.Z - (MapData.DOOR_WIDTH/2) - (wallThick/2)),
							MapData.WALL_COLOR, Enum.Material.Concrete)
							
						createPart(mansionFolder, "CorridorWallS",
							Vector3.new(corridorLen, MapData.WALL_HEIGHT, wallThick),
							Vector3.new(centerPos.X, HALF_WALL_H, centerPos.Z + (MapData.DOOR_WIDTH/2) + (wallThick/2)),
							MapData.WALL_COLOR, Enum.Material.Concrete)
					end
				end
			else
				if dir == "south" or dir == "east" then
					warn("[MapBuilder] ERROR: " .. name .. " tiene conexion " .. dir .. " huerfana (sin vecino cercano).")
				end
			end
		end
		
		count += 1
	end

	exitZone = buildExitZone()

	print("[MapBuilder] Mansion construida: " .. count .. " habitaciones")
	return mansionFolder
end

-- Obtener todas las PointLights de la mansion
function MapBuilder.getLights(): { PointLight }
	if not mansionFolder then return {} end

	local lights = {}
	for _, roomFolder in mansionFolder:GetChildren() do
		local lightSource = roomFolder:FindFirstChild("LightSource")
		if lightSource then
			local pointLight = lightSource:FindFirstChildOfClass("PointLight")
			if pointLight then
				table.insert(lights, pointLight)
			end
		end
	end
	return lights
end

-- Obtener la zona de escape
function MapBuilder.getExitZone(): Part?
	print("Mapa generado correctamente.")
	return exitZone
end

function MapBuilder.buildLobby()
	local lobbyPos = Config.LOBBY_POSITION
	local lobbySize = 60
	local wallHeight = 25
	
	local folder = Instance.new("Folder")
	folder.Name = "Lobby"
	folder.Parent = workspace
	
	-- 1. PISO (Madera elegante)
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Size = Vector3.new(lobbySize, 1, lobbySize)
	floor.Position = lobbyPos
	floor.Anchored = true
	floor.Material = Enum.Material.WoodPlanks
	floor.Color = Color3.fromRGB(139, 69, 19) -- Cafe madera
	floor.Parent = folder
	
	-- 2. TECHO
	local ceil = Instance.new("Part")
	ceil.Name = "Ceiling"
	ceil.Size = Vector3.new(lobbySize, 1, lobbySize)
	ceil.Position = lobbyPos + Vector3.new(0, wallHeight, 0)
	ceil.Anchored = true
	ceil.Material = Enum.Material.Concrete
	ceil.Color = Color3.fromRGB(200, 200, 200)
	ceil.Parent = folder
	
	-- 3. PAREDES
	local wallThickness = 2
	local walls = {
		{Size = Vector3.new(lobbySize, wallHeight, wallThickness), Pos = lobbyPos + Vector3.new(0, wallHeight/2, -lobbySize/2)}, -- Norte
		{Size = Vector3.new(lobbySize, wallHeight, wallThickness), Pos = lobbyPos + Vector3.new(0, wallHeight/2, lobbySize/2)}, -- Sur
		{Size = Vector3.new(wallThickness, wallHeight, lobbySize), Pos = lobbyPos + Vector3.new(-lobbySize/2, wallHeight/2, 0)}, -- Oeste
		{Size = Vector3.new(wallThickness, wallHeight, lobbySize), Pos = lobbyPos + Vector3.new(lobbySize/2, wallHeight/2, 0)}, -- Este
	}
	
	for _, w in ipairs(walls) do
		local part = Instance.new("Part")
		part.Name = "Wall"
		part.Size = w.Size
		part.Position = w.Pos
		part.Anchored = true
		part.Material = Enum.Material.SmoothPlastic
		part.Color = Color3.fromRGB(230, 230, 220) -- Crema
		part.Parent = folder
	end
	
	-- 4. ILUMINACION (Calida)
	local lightPart = Instance.new("Part")
	lightPart.Name = "Chandelier"
	lightPart.Size = Vector3.new(5, 1, 5)
	lightPart.Position = lobbyPos + Vector3.new(0, wallHeight - 2, 0)
	lightPart.Anchored = true
	lightPart.Material = Enum.Material.Neon
	lightPart.Color = Color3.fromRGB(255, 230, 150)
	lightPart.Parent = folder
	
	local light = Instance.new("PointLight")
	light.Brightness = 1.5
	light.Range = 60
	light.Color = Color3.fromRGB(255, 220, 180)
	light.Shadows = true
	light.Parent = lightPart
	
	-- 5. INFO BOARD (Instrucciones)
	local board = Instance.new("Part")
	board.Name = "InfoBoard"
	board.Size = Vector3.new(16, 10, 1)
	board.Position = lobbyPos + Vector3.new(0, 10, -lobbySize/2 + 2) -- Pared Norte
	board.Anchored = true
	board.Color = Color3.fromRGB(0, 0, 0)
	board.Material = Enum.Material.Metal
	board.Parent = folder
	
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Parent = board
	surfaceGui.Face = Enum.NormalId.Back
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	frame.Parent = surfaceGui
	
	local title = Instance.new("TextLabel")
	title.Text = "MISION: ESCAPE"
	title.Size = UDim2.new(1, 0, 0.2, 0)
	title.TextColor3 = Color3.fromRGB(255, 50, 50)
	title.Font = Enum.Font.Creepster
	title.TextScaled = true
	title.BackgroundTransparency = 1
	title.Parent = frame
	
	local instructions = Instance.new("TextLabel")
	instructions.Text = "- Encuentra 3 Llaves\n- Evita a Señor Barriga\n- Usa SHIFT para correr\n- Escondete en Lockers\n- Elige tu CLASE"
	instructions.Size = UDim2.new(1, 0, 0.8, 0)
	instructions.Position = UDim2.new(0, 0, 0.2, 0)
	instructions.TextColor3 = Color3.fromRGB(255, 255, 255)
	instructions.Font = Enum.Font.GothamBold
	instructions.TextScaled = true
	instructions.BackgroundTransparency = 1
	instructions.Parent = frame

	-- 6. MUEBLES (Sofa area)
	local rug = Instance.new("Part")
	rug.Name = "Rug"
	rug.Size = Vector3.new(20, 0.1, 10)
	rug.Position = lobbyPos + Vector3.new(0, 0.6, 10)
	rug.Anchored = true
	rug.CanCollide = false
	rug.Color = Color3.fromRGB(100, 0, 0)
	rug.Material = Enum.Material.Fabric
	rug.Parent = folder
	
	-- Asiento
	local seat = Instance.new("Seat")
	seat.Name = "LobbySeat"
	seat.Size = Vector3.new(4, 1, 4)
	seat.Position = lobbyPos + Vector3.new(0, 2, 10)
	seat.Anchored = true
	seat.Color = Color3.fromRGB(80, 50, 30)
	seat.Material = Enum.Material.Fabric
	seat.Parent = folder
end

return MapBuilder
