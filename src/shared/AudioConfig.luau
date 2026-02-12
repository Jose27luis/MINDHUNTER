local AudioConfig = {}

-- ==========================================
-- MÚSICA (Tracks completos)
-- ==========================================
-- SETUP: Sube cada MP3 de src/audio/ a https://create.roblox.com/dashboard/creations
-- Click "Audio" → "Upload Audio" → sube el archivo → copia el Asset ID
-- Reemplaza cada "PONER_ID_AQUI" con el numero del asset (ejemplo: rbxassetid://123456789)

AudioConfig.Music = {
	Lobby = {
		Id = "rbxassetid://108573879834581",
		Volume = 0.3,
		Looped = true,
	},

	Exploration = {
		Id = "rbxassetid://99301663361898",
		Volume = 0.25,
		Looped = true,
	},

	Tension = {
		Id = "rbxassetid://102158293618829",
		Volume = 0.4,
		Looped = true,
	},

	Chase = {
		Id = "rbxassetid://70573032079710",
		Volume = 0.5,
		Looped = true,
	},

	Victory = {
		Id = "rbxassetid://86828154524889",
		Volume = 0.4,
		Looped = false,
	},

	Defeat = {
		Id = "rbxassetid://87118754302990",
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
