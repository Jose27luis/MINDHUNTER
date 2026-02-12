local AudioConfig = {}

-- ==========================================
-- MÚSICA (Tracks completos)
-- ==========================================

AudioConfig.Music = {
	-- Lobby - Música tranquila de espera
	Lobby = {
		Id = "rbxassetid://1845756489", -- Ambient calm
		Volume = 0.3,
		Looped = true,
	},

	-- Exploración - Tensión baja, atmósfera inquietante
	Exploration = {
		Id = "rbxassetid://9120386436", -- Eerie ambient
		Volume = 0.25,
		Looped = true,
	},

	-- Tensión - El monstruo está cerca
	Tension = {
		Id = "rbxassetid://9120386436", -- Suspense (mismo que exploration por ahora)
		Volume = 0.4,
		Looped = true,
	},

	-- Persecución - Música intensa de chase
	Chase = {
		Id = "rbxassetid://9120386436", -- Chase intense
		Volume = 0.5,
		Looped = true,
	},

	-- Victoria - Música épica al escapar
	Victory = {
		Id = "rbxassetid://1845756489", -- Victory
		Volume = 0.4,
		Looped = false,
	},

	-- Derrota - Música oscura y triste
	Defeat = {
		Id = "rbxassetid://9120386436", -- Defeat dark
		Volume = 0.35,
		Looped = false,
	},
}

-- ==========================================
-- EFECTOS DE SONIDO (SFX)
-- ==========================================

AudioConfig.SFX = {
	-- Recoger llave - Sonido satisfactorio
	KeyPickup = {
		Id = "rbxassetid://3398620867", -- Collectible pickup
		Volume = 0.6,
	},

	-- Escape exitoso - Sonido de logro
	EscapeSuccess = {
		Id = "rbxassetid://3398620867", -- Success chime
		Volume = 0.7,
	},

	-- Muerte del jugador - Sonido impactante
	PlayerDeath = {
		Id = "rbxassetid://5944809975", -- Death sound
		Volume = 0.5,
	},

	-- Daño recibido - Impacto
	TakeDamage = {
		Id = "rbxassetid://5943663093", -- Hit impact
		Volume = 0.5,
	},

	-- Heartbeat - Latido aumenta con peligro
	Heartbeat = {
		Id = "rbxassetid://9113621995", -- Heartbeat loop
		Volume = 0.4,
		Looped = true,
	},

	-- Puerta chirriante
	DoorCreak = {
		Id = "rbxassetid://5944809975", -- Door creaking
		Volume = 0.3,
	},

	-- Susurros espeluznantes
	Whispers = {
		Id = "rbxassetid://9120386436", -- Eerie whispers
		Volume = 0.2,
		Looped = true,
	},
}

-- ==========================================
-- PASOS (Footsteps por Material)
-- ==========================================

AudioConfig.Footsteps = {
	-- Pasos en madera
	Wood = {
		Id = "rbxassetid://5943663093",
		Volume = 0.4,
	},

	-- Pasos en concreto
	Concrete = {
		Id = "rbxassetid://5943663093",
		Volume = 0.35,
	},

	-- Pasos en metal
	Metal = {
		Id = "rbxassetid://5943663093",
		Volume = 0.45,
	},

	-- Pasos en alfombra/tela
	Fabric = {
		Id = "rbxassetid://5943663093",
		Volume = 0.25,
	},

	-- Pasos en mármol
	Marble = {
		Id = "rbxassetid://5943663093",
		Volume = 0.4,
	},

	-- Default
	Default = {
		Id = "rbxassetid://5943663093",
		Volume = 0.35,
	},
}

-- ==========================================
-- AUDIO AMBIENTAL (Por Habitación)
-- ==========================================

AudioConfig.Ambient = {
	-- Viento suave (general)
	Wind = {
		Id = "rbxassetid://9120386436",
		Volume = 0.15,
		Looped = true,
	},

	-- Goteras (baño, sótano)
	WaterDrip = {
		Id = "rbxassetid://5943663093",
		Volume = 0.2,
		Looped = true,
	},

	-- Reloj de péndulo (oficina, biblioteca)
	Clock = {
		Id = "rbxassetid://5943663093",
		Volume = 0.25,
		Looped = true,
	},

	-- Susurros lejanos
	DistantWhispers = {
		Id = "rbxassetid://9120386436",
		Volume = 0.1,
		Looped = true,
	},
}

-- ==========================================
-- CONFIGURACIÓN DE VOLUMEN MAESTRO
-- ==========================================

AudioConfig.MasterVolume = {
	Music = 0.7,      -- Multiplicador de música
	SFX = 0.8,        -- Multiplicador de efectos
	Ambient = 0.6,    -- Multiplicador de ambiente
	Footsteps = 0.7,  -- Multiplicador de pasos
}

-- ==========================================
-- CONFIGURACIÓN DE TRANSICIONES
-- ==========================================

AudioConfig.Transitions = {
	CrossfadeDuration = 2,    -- Segundos para crossfade entre tracks
	FadeInDuration = 1.5,     -- Fade in al iniciar
	FadeOutDuration = 1,      -- Fade out al terminar
}

return AudioConfig
