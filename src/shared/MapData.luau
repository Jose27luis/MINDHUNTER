local MapData = {}

-- Dimensiones de las habitaciones (Escala x2 para mas elegancia)
MapData.ROOM_SIZE = 40
MapData.WALL_HEIGHT = 18 -- Techos mas altos
MapData.WALL_THICKNESS = 2
MapData.DOOR_WIDTH = 12 -- Puertas mas anchas
MapData.DOOR_HEIGHT = 14

-- Colores del greybox
MapData.FLOOR_COLOR = Color3.fromRGB(50, 45, 40)
MapData.WALL_COLOR = Color3.fromRGB(75, 70, 65)

-- Habitaciones de la mansion
-- Grid layout (Step = 60 studs)
--       [Biblioteca]
--           |
-- [Cocina]-[Sala]-[Dormitorio]
--           |
-- [Comedor]-[Pasillo]-[Sotano]
--           |
--        [Jardin]

MapData.Rooms = {
	PasilloPrincipal = {
		position = Vector3.new(0, 0, 0),
		doors = { north = true, south = true, west = true, east = true },
		displayName = "Pasillo Principal",
		floorColor = Color3.fromRGB(45, 45, 45),
		wallColor = Color3.fromRGB(65, 65, 65),
	},
	Sala = {
		position = Vector3.new(0, 0, -60),
		doors = { north = true, south = true, west = true, east = true },
		displayName = "Sala",
		floorColor = Color3.fromRGB(60, 45, 35),
		wallColor = Color3.fromRGB(85, 70, 55),
	},
	Biblioteca = {
		position = Vector3.new(0, 0, -120),
		doors = { south = true, west = true, east = true, north = true }, -- Conecta con pasillo trasero
		displayName = "Biblioteca",
		floorColor = Color3.fromRGB(35, 40, 60),
		wallColor = Color3.fromRGB(55, 60, 80),
	},
	Cocina = {
		position = Vector3.new(-60, 0, -60),
		doors = { east = true, west = true }, -- Conecta con Sala y Bano
		displayName = "Cocina",
		floorColor = Color3.fromRGB(55, 55, 50),
		wallColor = Color3.fromRGB(80, 80, 75),
	},
	Dormitorio = {
		position = Vector3.new(60, 0, -60),
		doors = { west = true, east = true }, -- Conecta con Sala y Huespedes
		displayName = "Dormitorio",
		floorColor = Color3.fromRGB(50, 35, 55),
		wallColor = Color3.fromRGB(75, 60, 80),
	},
	Comedor = {
		position = Vector3.new(-60, 0, 0),
		doors = { east = true, west = true }, -- Conecta con Pasillo y Oficina
		displayName = "Comedor",
		floorColor = Color3.fromRGB(55, 30, 30),
		wallColor = Color3.fromRGB(80, 55, 55),
	},
	Sotano = {
		position = Vector3.new(60, 0, 0),
		doors = { west = true, east = true }, -- Conecta con Pasillo y Almacen
		displayName = "Sotano",
		floorColor = Color3.fromRGB(35, 35, 35),
		wallColor = Color3.fromRGB(55, 55, 55),
	},
	Jardin = {
		position = Vector3.new(0, 0, 60),
		doors = { north = true },
		displayName = "Jardin",
		floorColor = Color3.fromRGB(30, 50, 30),
		wallColor = Color3.fromRGB(50, 70, 50),
	},
	-- NUEVAS HABITACIONES (Expansion)
	Oficina = {
		position = Vector3.new(-120, 0, 0),
		doors = { east = true, north = true }, -- Conecta con Comedor y Bano
		displayName = "Oficina",
		floorColor = Color3.fromRGB(40, 30, 20),
		wallColor = Color3.fromRGB(60, 50, 40),
	},
	Bano = {
		position = Vector3.new(-120, 0, -60),
		doors = { south = true, east = true, north = true }, -- Loop oeste completo
		displayName = "Bano",
		floorColor = Color3.fromRGB(200, 200, 200),
		wallColor = Color3.fromRGB(220, 220, 220),
	},
	Almacen = {
		position = Vector3.new(120, 0, 0),
		doors = { west = true, north = true }, -- Conecta con Sotano y Huespedes
		displayName = "Almacen",
		floorColor = Color3.fromRGB(40, 40, 40),
		wallColor = Color3.fromRGB(60, 60, 60),
	},
	CuartoHuespedes = {
		position = Vector3.new(120, 0, -60),
		doors = { south = true, west = true, north = true }, -- Loop este completo
		displayName = "Huespedes",
		floorColor = Color3.fromRGB(60, 50, 60),
		wallColor = Color3.fromRGB(80, 70, 90),
	},
	PasilloTrasero = {
		position = Vector3.new(0, 0, -180),
		doors = { south = true, west = true, east = true }, -- Conecta Biblioteca, y extremos
		displayName = "Pasillo Oscuro",
		floorColor = Color3.fromRGB(20, 20, 20),
		wallColor = Color3.fromRGB(30, 30, 30),
	},
	CornerOeste = {
		position = Vector3.new(-120, 0, -120),
		doors = { south = true, east = true }, -- Conecta Bano y Biblioteca(via pasillo?) No, Bano esta en -60. 
		-- Ajuste: Bano(-120, -60) -> North -> Corner(-120, -120). 
		-- Biblioteca(0, -120) -> West -> Corner? NO, Corner esta en -120, Bib en 0. Falta uno en medio (-60, -120)
		-- Para simplificar: Conectamos directo Bano(-120,-60) con un pasillo largo? No, usemos grid.
		-- Agregamos nodos intermedios invisibles o habitaciones pequenas
		displayName = "Pasillo Oeste",
		floorColor = Color3.fromRGB(30, 30, 30),
		wallColor = Color3.fromRGB(50, 50, 50),
	},
	CornerEste = {
		position = Vector3.new(120, 0, -120),
		doors = { south = true, west = true }, -- Conecta Huespedes y hacia el centro
		displayName = "Pasillo Este",
		floorColor = Color3.fromRGB(30, 30, 30),
		wallColor = Color3.fromRGB(50, 50, 50),
	},
	-- Necesitamos conectar CornerOeste(-120,-120) con Biblioteca(0,-120)
	-- Agregamos un nexo
	NexoOeste = {
		position = Vector3.new(-60, 0, -120),
		doors = { west = true, east = true },
		displayName = "Galeria Oeste",
		floorColor = Color3.fromRGB(40, 40, 50),
		wallColor = Color3.fromRGB(60, 60, 70),
	},
	NexoEste = {
		position = Vector3.new(60, 0, -120),
		doors = { west = true, east = true },
		displayName = "Galeria Este",
		floorColor = Color3.fromRGB(40, 40, 50),
		wallColor = Color3.fromRGB(60, 60, 70),
	},
	-- PasilloTrasero eliminado, cubierto por Nexos y Biblio
}

-- Nombres legibles para el prompt de IA
MapData.ROOM_NAMES = {
	"Biblioteca", "Sala", "Cocina", "Dormitorio",
	"Pasillo Principal", "Comedor", "Sotano", "Jardin",
	"Oficina", "Bano", "Almacen", "Huespedes"
}

-- Mapeo de nombres del chat/IA a claves internas (lowercase para tolerancia)
MapData.NAME_TO_KEY = {
	["biblioteca"] = "Biblioteca",
	["sala"] = "Sala",
	["cocina"] = "Cocina",
	["dormitorio"] = "Dormitorio",
	["pasillo principal"] = "PasilloPrincipal",
	["pasillo"] = "PasilloPrincipal",
	["comedor"] = "Comedor",
	["sotano"] = "Sotano",
	["sótano"] = "Sotano",
	["jardin"] = "Jardin",
	["jardín"] = "Jardin",
	["oficina"] = "Oficina",
	["baño"] = "Bano",
	["bano"] = "Bano",
	["almacen"] = "Almacen",
	["almacén"] = "Almacen",
	["huespedes"] = "CuartoHuespedes",
	["cuarto de huespedes"] = "CuartoHuespedes",
}

-- Muebles y decoracion por habitacion (Reajustado para escala x2)
MapData.Furniture = {
	Biblioteca = {
		{ Name = "Estanteria1", Type = "Shelf", Size = Vector3.new(4, 14, 20), Position = Vector3.new(16, 0, 0), Color = Color3.fromRGB(80, 50, 30), Material = Enum.Material.Wood },
		{ Name = "Estanteria2", Type = "Shelf", Size = Vector3.new(4, 14, 20), Position = Vector3.new(-16, 0, 0), Color = Color3.fromRGB(80, 50, 30), Material = Enum.Material.Wood },
		{ Name = "MesaCentral", Type = "Table", Size = Vector3.new(12, 4, 20), Position = Vector3.new(0, -7, 0), Color = Color3.fromRGB(60, 40, 20), Material = Enum.Material.Wood },
		{ Name = "Alfombra", Type = "Rug", Size = Vector3.new(24, 0.2, 30), Position = Vector3.new(0, -8.9, 0), Color = Color3.fromRGB(120, 40, 40), Material = Enum.Material.Fabric },
	},
	Sala = {
		{ Name = "Sofa", Type = "Couch", Size = Vector3.new(14, 4, 6), Position = Vector3.new(0, -7, 10), Color = Color3.fromRGB(100, 30, 30), Material = Enum.Material.Fabric },
		{ Name = "MesaCentro", Type = "Table", Size = Vector3.new(8, 3, 8), Position = Vector3.new(0, -7.5, 0), Color = Color3.fromRGB(40, 40, 40), Material = Enum.Material.Wood },
		{ Name = "TV", Type = "Screen", Size = Vector3.new(12, 8, 1), Position = Vector3.new(0, -4, -18), Color = Color3.fromRGB(10, 10, 10), Material = Enum.Material.Metal },
		{ Name = "Alfombra", Type = "Rug", Size = Vector3.new(20, 0.2, 14), Position = Vector3.new(0, -8.9, 5), Color = Color3.fromRGB(200, 180, 150), Material = Enum.Material.Fabric },
		{ Name = "Cuadro1", Type = "Painting", Size = Vector3.new(6, 8, 0.2), Position = Vector3.new(-18, 5, 0), Color = Color3.fromRGB(100, 80, 40), Material = Enum.Material.Wood },
		{ Name = "Cuadro2", Type = "Painting", Size = Vector3.new(6, 8, 0.2), Position = Vector3.new(18, 5, 0), Color = Color3.fromRGB(100, 80, 40), Material = Enum.Material.Wood },
	},
	Cocina = {
		{ Name = "Meson", Type = "Counter", Size = Vector3.new(4, 6, 30), Position = Vector3.new(-16, -6, 0), Color = Color3.fromRGB(200, 200, 200), Material = Enum.Material.Marble },
		{ Name = "Refrigerador", Type = "Fridge", Size = Vector3.new(6, 12, 6), Position = Vector3.new(14, 0, 14), Color = Color3.fromRGB(220, 220, 220), Material = Enum.Material.Metal },
		{ Name = "Estufa", Type = "Stove", Size = Vector3.new(6, 6, 6), Position = Vector3.new(14, -6, -10), Color = Color3.fromRGB(50, 50, 50), Material = Enum.Material.Metal },
	},
	Dormitorio = {
		{ Name = "Cama", Type = "Bed", Size = Vector3.new(12, 4, 16), Position = Vector3.new(0, -7, -10), Color = Color3.fromRGB(200, 200, 200), Material = Enum.Material.Fabric },
		{ Name = "Ropero", Type = "Closet", Size = Vector3.new(6, 14, 4), Position = Vector3.new(14, 0, 14), Color = Color3.fromRGB(90, 60, 40), Material = Enum.Material.Wood },
		{ Name = "Escritorio", Type = "Desk", Size = Vector3.new(8, 4, 4), Position = Vector3.new(-12, -7, 14), Color = Color3.fromRGB(80, 50, 30), Material = Enum.Material.Wood },
		{ Name = "Alfombra", Type = "Rug", Size = Vector3.new(16, 0.2, 20), Position = Vector3.new(0, -8.9, -10), Color = Color3.fromRGB(60, 60, 100), Material = Enum.Material.Fabric },
	},
	Comedor = {
		{ Name = "MesaLarga", Type = "Table", Size = Vector3.new(10, 4, 28), Position = Vector3.new(0, -7, 0), Color = Color3.fromRGB(90, 50, 30), Material = Enum.Material.Wood },
		{ Name = "Silla1", Type = "Chair", Size = Vector3.new(4, 4, 4), Position = Vector3.new(8, -7, 0), Color = Color3.fromRGB(60, 40, 20), Material = Enum.Material.Wood },
		{ Name = "Silla2", Type = "Chair", Size = Vector3.new(4, 4, 4), Position = Vector3.new(-8, -7, 0), Color = Color3.fromRGB(60, 40, 20), Material = Enum.Material.Wood },
		{ Name = "CuadroGrande", Type = "Painting", Size = Vector3.new(10, 6, 0.2), Position = Vector3.new(0, 5, -18), Color = Color3.fromRGB(80, 60, 40), Material = Enum.Material.Wood },
	},
	Sotano = {
		{ Name = "Caja1", Type = "Box", Size = Vector3.new(6, 6, 6), Position = Vector3.new(10, -6, 10), Color = Color3.fromRGB(120, 100, 80), Material = Enum.Material.Wood },
		{ Name = "Caja2", Type = "Box", Size = Vector3.new(6, 6, 6), Position = Vector3.new(-12, -6, -8), Color = Color3.fromRGB(120, 100, 80), Material = Enum.Material.Wood },
		{ Name = "EstanteriaVieja", Type = "Shelf", Size = Vector3.new(4, 14, 12), Position = Vector3.new(0, 0, -16), Color = Color3.fromRGB(60, 50, 40), Material = Enum.Material.Wood },
	},
	Jardin = {
		{ Name = "Fuente", Type = "Fountain", Size = Vector3.new(12, 3, 12), Position = Vector3.new(0, -7.5, 0), Color = Color3.fromRGB(150, 150, 160), Material = Enum.Material.Concrete },
		{ Name = "Banco", Type = "Bench", Size = Vector3.new(8, 3, 3), Position = Vector3.new(10, -7.5, 10), Color = Color3.fromRGB(80, 60, 40), Material = Enum.Material.Wood },
		{ Name = "Arbol", Type = "Tree", Size = Vector3.new(6, 20, 6), Position = Vector3.new(-12, 0, -12), Color = Color3.fromRGB(40, 30, 10), Material = Enum.Material.Grass },
	},
	PasilloPrincipal = {
		{ Name = "Alfombra", Type = "Rug", Size = Vector3.new(8, 0.2, 30), Position = Vector3.new(0, -8.9, 0), Color = Color3.fromRGB(100, 20, 20), Material = Enum.Material.Fabric },
		{ Name = "Cuadro", Type = "Painting", Size = Vector3.new(4, 4, 0.2), Position = Vector3.new(18, 4, 0), Color = Color3.fromRGB(150, 100, 50), Material = Enum.Material.Wood },
	}
}

-- Habitacion donde aparece el monstruo
MapData.MONSTER_SPAWN_ROOM = "Sotano"

return MapData
