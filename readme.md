# 🧠 MindHunter: AI-Powered Cooperative Horror

> **Un experimento de terror psicológico en Roblox donde el enemigo no solo oye... entiende.**

## 📖 Descripción del Proyecto

**MindHunter** es un juego de terror cooperativo (estilo _Escape Room_) que rompe la cuarta pared utilizando Inteligencia Artificial Generativa. A diferencia de los juegos tradicionales donde el enemigo patrulla aleatoriamente o reacciona al volumen del micrófono, en **MindHunter**, la entidad antagonista utiliza la **API de Google Gemini** para analizar semánticamente el chat de los jugadores en tiempo real.

Si los jugadores planean una estrategia en el chat (ej. _"Vamos a la cocina mientras el médico distrae"_), el monstruo procesa esa información y la utiliza para interceptarlos, creando una experiencia de paranoia única.

---

## 🛠 Stack Tecnológico

- **Motor:** Roblox Studio (Luau / Roblox-TS)
- **IA / Cerebro:** Google Gemini Pro API (vía `HttpService`)
- **Backend Lógico:** ServerScriptService (Arquitectura Modular)
- **Base de Datos:** DataStoreService (Persistencia de progreso y estadísticas)
- **Control de Versiones:** Rojo (Sincronización con VS Code/Git)

---

## 🎮 Mecánicas Principales (Core Loop)

### 1. El Sistema "The Listener" (Integración Gemini)

El núcleo diferenciador del juego.

- **Input:** Captura de eventos `Player.Chatted`.
- **Procesamiento:** El servidor envía el texto a Gemini con un _System Prompt_ diseñado para rol de "Cazador".
- **Output:** Una acción lógica (JSON) que dicta el comportamiento del NPC (ej. `IR_A_GENERADOR`, `APAGAR_LUCES`, `ESPERAR_EN_VENTILACION`).

### 2. Sistema de Clases (Dependencia Cooperativa)

Para escapar, el trabajo en equipo es obligatorio. Ningún rol puede sobrevivir solo.

| Rol               | Habilidad Activa (Q)                                              | Pasiva                                                       | Función Táctica             |
| :---------------- | :---------------------------------------------------------------- | :----------------------------------------------------------- | :-------------------------- |
| **🔧 Ingeniero**  | **Overclock:** Repara objetivos un 50% más rápido por 5s.         | **Visión Técnica:** Ve cables/objetivos a través de paredes. | **Progreso** (Objetivos)    |
| **❤️ Médico**     | **Triaje:** Cura estados críticos (cojera/sangrado).              | **Calma:** Reduce la pérdida de cordura en aliados cercanos. | **Supervivencia** (Sustain) |
| **🏃‍♂️ Explorador** | **Señuelo:** Lanza un objeto que genera una señal falsa de ruido. | **Sigilo:** Pasos silenciosos y mayor estamina.              | **Distracción** (Kiting)    |

---

## 🚀 Roadmap de Desarrollo

### Fase 1: El Prototipo "Cerebro" (MVP Técnico)

- [ ] Configurar `HttpService` en Roblox Studio (Habilitar Requests).
- [ ] Implementar módulo de conexión seguro con la API Key de Google Gemini.
- [ ] Crear script de prueba: Chat de jugador -> Respuesta de texto del Monstruo.

### Fase 2: El Cuerpo (Físicas y Pathfinding)

- [ ] "Greyboxing" del mapa (diseño de nivel básico sin texturas).
- [ ] Implementar `PathfindingService` o módulo _SimplePath_ para el movimiento del NPC.
- [ ] Conectar la respuesta de la IA a las acciones físicas (Output "IR_COCINA" -> NPC camina a nodo Cocina).

### Fase 3: Las Clases y Objetivos

- [ ] Programar herramientas: Wrench (Ingeniero) y Medkit (Médico).
- [ ] Crear el sistema de "Generadores" (Objetivo principal para escapar).
- [ ] Implementar UI básica (Barras de vida, Estamina, Chat Log).

### Fase 4: Atmósfera y Polish

- [ ] Diseño de sonido (Audio 3D, Gritos, Pasos).
- [ ] Iluminación dinámica y niebla (`Lighting`).
- [ ] Beta Testing privado.

---

## 📝 Notas de Ingeniería & Seguridad

### Optimización de API

Para evitar saturar la cuota de la API y mantener el rendimiento:

1.  **Rate Limiting:** No enviar cada mensaje individualmente. Implementar un "buffer" que envíe el chat acumulado cada 10-15 segundos o al detectar palabras clave.
2.  **Filtrado:** Ignorar mensajes cortos o irrelevantes (ej. "lol", "xd").

### Seguridad

- **Server-Side Only:** La API Key de Gemini **NUNCA** debe estar en un `LocalScript` o en `ReplicatedStorage`. Solo debe existir en `ServerScriptService` para evitar que sea robada por exploiters.

---

## 🏁 Instalación (Para colaboradores)

1.  Clonar el repositorio.
2.  Abrir el archivo `.rbxl` en Roblox Studio.
3.  Crear un script en `ServerScriptService` llamado `Secrets` (no incluido en git) con:
    ```lua
    local Secrets = {}
    Secrets.API_KEY = "TU_CLAVE_DE_GEMINI_AQUI"
    return Secrets
    ```
4.  Activar **HTTP Requests** en _Game Settings > Security_.
