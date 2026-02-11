# MindHunter — Lo que falta

## Completado

- [x] Fase 1: IA (chat → Groq → acciones JSON)
- [x] Fase 2: Mapa (8 habitaciones), NPC, pathfinding, patrulla autonoma
- [x] Fase 3: Dano por toque, llave, escape, HUD (vida + llave)
- [x] Fase 4: Atmosfera (oscuridad, linterna, heartbeat, proximidad, sonidos)

## Fase 5 — Pulido visual

- [x] Muebles/objetos en cada habitacion (mesas, estantes, camas, sillas)
- [x] Corredores fisicos conectando habitaciones (paredes + piso entre cuartos)
- [x] Modelo del monstruo mejorado (reemplazar placeholder R6)
- [x] Decoracion ambiental (cuadros, alfombras, candelabros)
- [x] Particulas/efectos en la llave y la zona de escape

## Fase 6 — Gameplay avanzado

- [x] Sprint del jugador (Shift para correr mas rapido)
- [x] Stamina (barra que se gasta al correr)
- [x] Sistema de rondas (lobby → countdown → juego → resultado)
- [x] Multiples llaves o puzzles cooperativos
- [ ] Dificultad progresiva (monstruo mas rapido con el tiempo)
- [x] Escondites (lockers, armarios donde el jugador se puede ocultar)
- [ ] Cooldown visual cuando recibes dano (pantalla roja flash)

## Fase 7 — Multijugador y social

- [x] Implementar roles cooperativos (Runner, Tank, Scout)
- [x] Lobby / sala de espera (Mejorada con UI y Muebles)
- [ ] Scoreboard (quien escapo, quien murio, tiempo de supervivencia)
- [ ] Estadisticas persistentes (DataStore)
- [ ] Roles cooperativos (uno distrae, otro busca la llave)

## Fase 8 — Audio y sonido

- [ ] Reemplazar Sound IDs placeholder por sonidos reales de horror
- [ ] Musica de fondo que cambia segun la situacion (patrulla vs chase)
- [ ] Sonido de pasos del jugador
- [ ] Sonido al recoger la llave
- [ ] Sonido al escapar (victoria)
- [ ] Sonido de puerta/ambiente por habitacion

## Fase 9 — IA mejorada

- [ ] Memoria del monstruo (recordar donde vio jugadores antes)
- [ ] Contexto de historial de acciones en el prompt de Groq
- [ ] Personalidad del monstruo que evoluciona durante la partida
- [ ] Frases del monstruo en chat (trash talk a los jugadores)

## Bugs conocidos / por verificar

- [ ] Verificar que los Sound IDs de Roblox funcionan (heartbeat, ambient, pasos, golpe)
- [ ] Verificar pathfinding entre habitaciones con corredores largos
- [ ] Probar respawn de llave cuando el jugador muere con ella
- [ ] Probar que la zona de escape funciona correctamente con/sin llave
- [ ] Ajustar valores de oscuridad si es demasiado oscuro o muy claro
- [ ] Verificar que el monstruo no se queda atascado en paredes
