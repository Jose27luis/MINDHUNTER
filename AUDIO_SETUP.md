# 🎵 Guía de Setup de Audio Profesional

## ⚠️ IDs de Audio Actuales

Los IDs actuales son **placeholders** que funcionan pero no son ideales para un juego de horror. Aquí está cómo mejorarlos:

---

## 🎼 Música Recomendada (Busca en Toolbox)

### Para cada track, busca en Roblox Studio:

**Toolbox → Audio → Buscar:**

1. **Lobby**: "ambient peaceful calm"
2. **Exploration**: "horror ambient dark eerie"
3. **Tension**: "suspense building dramatic"
4. **Chase**: "intense action chase"
5. **Victory**: "victory triumph epic"
6. **Defeat**: "sad dark defeat"

### Cómo Reemplazar:

1. Encuentra el audio en Toolbox
2. Click derecho → **Copy Asset ID**
3. Abre `src/shared/AudioConfig.luau`
4. Reemplaza el ID en la línea correspondiente:

```lua
Lobby = {
    Id = "rbxassetid://TU_ID_AQUI",
    Volume = 0.3,
    Looped = true,
},
```

---

## 🔊 Efectos de Sonido Recomendados

| Efecto | Búsqueda en Toolbox | Ubicación en Config |
|--------|---------------------|---------------------|
| 🔑 Llave | "collect pickup coin" | `SFX.KeyPickup` |
| 🎉 Escape | "success achievement win" | `SFX.EscapeSuccess` |
| 💀 Muerte | "death scream hurt" | `SFX.PlayerDeath` |
| 💥 Daño | "hit impact punch" | `SFX.TakeDamage` |
| 💗 Heartbeat | "heartbeat pulse heart" | `SFX.Heartbeat` |
| 🚪 Puerta | "door creak open close" | `SFX.DoorCreak` |
| 👻 Susurros | "whisper ghost eerie" | `SFX.Whispers` |

---

## 👟 Pasos (Footsteps)

**Buscar en Toolbox:**
- "footsteps wood"
- "footsteps concrete"
- "footsteps metal"

**Ubicación:** `AudioConfig.Footsteps.Wood`, `.Concrete`, etc.

---

## 🌐 Sitios Web con Audio de Horror Gratis

### Para descargar y subir a Roblox:

1. **Freesound.org** (Requiere cuenta gratis)
   - Busca: "horror ambience", "heartbeat", "footsteps"
   - Descarga en MP3
   - Sube a Roblox

2. **YouTube Audio Library**
   - Busca: Horror, Suspense, Dark Ambient
   - Descarga gratis
   - Convierte a MP3 si es necesario

3. **Incompetech** (Kevin MacLeod)
   - Música libre de derechos
   - Perfecto para ambientes de horror

---

## 📋 Checklist de Mejora de Audio

- [ ] Reemplazar música de Lobby (algo tranquilo)
- [ ] Reemplazar música de Exploration (horror ambient)
- [ ] Reemplazar música de Tension (suspense)
- [ ] Reemplazar música de Chase (intensa)
- [ ] Reemplazar música de Victory
- [ ] Reemplazar música de Defeat
- [ ] Sonido de recoger llave (satisfactorio)
- [ ] Sonido de escape exitoso (triunfante)
- [ ] Sonido de muerte (impactante)
- [ ] Sonido de daño (golpe)
- [ ] Heartbeat loop (latido realista)
- [ ] Pasos en diferentes materiales
- [ ] Susurros espeluznantes

---

## 🎯 Recomendación Rápida

**Si quieres audio profesional YA:**

1. Ve a Roblox Create: https://create.roblox.com
2. Busca paquetes de audio de horror publicados por usuarios
3. Algunos creadores comparten paquetes completos gratis
4. Copia los IDs y reemplaza en `AudioConfig.luau`

---

## ⚡ Testing

Después de reemplazar IDs:
1. Guarda `AudioConfig.luau`
2. Reinicia el juego en Studio
3. Verifica en Output:
   - ✅ `[MusicController] 6 tracks cargados`
   - ✅ `[SFXController] 8 efectos cargados`
   - ❌ `Failed to load sound` = ID inválido

---

## 💡 Pro Tip

**Para encontrar audio de calidad rápidamente:**

En Roblox Studio Toolbox, filtra por:
- **Sort by:** Most Relevant
- **Creator:** Official Roblox (tienen biblioteca gratis)
- **Verified Creators** (audio de calidad)

Los audios de creadores verificados suelen ser mejores que los de usuarios random.
