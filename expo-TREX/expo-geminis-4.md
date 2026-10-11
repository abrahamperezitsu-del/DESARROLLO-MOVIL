# 🦖 T-Rex Runner - Flame Engine Edition

Este repositorio contiene la implementación en Flutter utilizando el motor gráfico **Flame** del clásico juego del T-Rex sin conexión de Google. El proyecto está estructurado bajo el paradigma de desarrollo basado en componentes (`Component`) y un bucle de juego optimizado (`Game Loop`).

---

## 📂 1. Estructura de Módulos y Análisis Funcional del Código

El código fuente se divide en cuatro grandes bloques modulares que gestionan la arquitectura general, el personaje, el entorno y el sistema de colisiones/puntuación.

### A. Módulo Principal y Ciclo de Vida (`main.dart` y `TrexGame`)
Es el punto de entrada y el cerebro central que orquesta todo el ecosistema del juego.
*   **`main()`**: Inicializa el entorno de Flutter y monta el juego utilizando `GameWidget(game: TrexGame())`.
*   **`TrexGame` (Extiende de `FlameGame` con mixins de entrada):**
    *   `onLoad()`: Método asíncrono fundamental ejecutado al iniciar. Se encarga de cargar los recursos globales, inicializar el gestor de estados y montar la jerarquía inicial de componentes en el árbol del juego.
    *   `update(double dt)`: El núcleo del *Game Loop*. Se ejecuta en cada fotograma actualizando las variables globales, como el incremento progresivo de la velocidad del juego (`gameSpeed`) en función del tiempo transcurrido.
    *   `reset()`: Restablece la velocidad base, reinicia las puntuaciones y reposiciona las entidades tras un choque.
    *   Manejo de entradas (`onTapDown`, `keypressed`): Captura los eventos táctiles o del teclado para interactuar con la partida.

### B. Módulo del Personaje y Físicas (`TRex` Component)
Gestiona el comportamiento, la máquina de estados y las físicas de movimiento del dinosaurio.
*   **Clase `TRex` (Extiende de `SpriteAnimationComponent`):**
    *   **Estados (`TrexState`):** `waiting` (en espera), `running` (corriendo), `jumping` (saltando), `ducking` (agachado), `crashed` (chocado).
    *   `onLoad()`: Carga los fotogramas específicos (*spritesheets*) para cada animación visual.
    *   `update(double dt)`:
        *   Calcula la gravedad aplicada en el eje Y cuando el T-Rex está en el aire.
        *   Controla la velocidad vertical (`yVelocity`), simulando un salto parabólico natural (impulso inicial hacia arriba y aceleración de caída).
        *   Asegura el aterrizaje correcto al tocar la línea del suelo.
    *   `jump()`: Aplica velocidad negativa para elevar al personaje.
    *   `duck(bool isDucking)`: Modifica la animación y reduce la altura de la caja de colisión para esquivar obstáculos aéreos.

### C. Módulo de Entorno y Generación de Obstáculos (`Horizon` y `Obstacle`)
Simula el desplazamiento lateral (*infinite runner*) y la aparición procedural de elementos.
*   **Clase `Horizon` (Contenedor del escenario):**
    *   Coordina el movimiento continuo del suelo y las nubes de fondo para dar sensación de velocidad.
*   **Clase `Ground` (Suelo) y `Cloud` (Nubes):**
    *   `Ground`: Desplaza y repite texturas de suelo de manera fluida.
    *   `Cloud`: Genera nubes de fondo aleatorias a una velocidad menor (efecto *Parallax*).
*   **Clase `ObstacleManager` / `Obstacle` (Obstáculos):**
    *   Gestiona el *spawn* (aparición) procedural de cactus pequeños, cactus dobles/grandes y pterodáctilos voladores a intervalos de distancia variables.
    *   Ajusta la dificultad y el tipo de obstáculo según la puntuación actual.

### D. Módulo de Colisiones, Interfaz y Puntuación (`Collisions` y `ScoreBoard`)
Gestiona la lógica de impacto, el fin de la partida y el sistema de puntos.
*   **Sistema de Detección de Colisiones:**
    *   Cada entidad posee una caja delimitadora (*hitbox* o `Rectangle`).
    *   El método de verificación comprueba constantemente si las coordenadas del rectángulo del `TRex` se intersectan con las de los obstáculos activos en pantalla (`Rect.overlaps`).
    *   Si hay colisión, detiene el bucle de juego, cambia el estado del `TRex` a `crashed` y activa la pantalla de reinicio.
*   **Clase `ScoreBoard` (Puntuación):**
    *   `update(double dt)`: Incrementa la puntuación de forma proporcional a la distancia recorrida.
    *   Gestiona el formato de visualización en pantalla y guarda la puntuación máxima (*High Score*).

---

## 👥 2. División en Cuatro Partes para la Exposición

Para una presentación equitativa entre cuatro personas, el código se divide en cuatro bloques técnicos independientes y bien delimitados:

### 📌 Parte 1: Arquitectura General y Bucle de Juego (`main.dart` y `TrexGame`)
*   **Enfoque:** Explicar el funcionamiento general de **Flutter y Flame**, cómo se inicializa el juego mediante `GameWidget`, y cómo opera el bucle principal de actualización (`Game Loop`).
*   **Temas a exponer:**
    *   Configuración del punto de entrada (`main`).
    *   La clase `TrexGame`, el ciclo de vida `onLoad()` y la gestión de estados globales del juego.
    *   El control dinámico de la velocidad del juego (`gameSpeed`).

### 📌 Parte 2: Lógica del Jugador y Físicas (`TRex` Component)
*   **Enfoque:** Explicar cómo se modela al personaje principal, la gestión de animaciones por fotogramas (*spritesheets*) y la implementación matemática de las físicas.
*   **Temas a exponer:**
    *   La máquina de estados del T-Rex (`waiting`, `running`, `jumping`, `ducking`).
    *   La aplicación de la gravedad y el cálculo de la velocidad vertical en el método `update`.
    *   La captura de eventos de entrada (teclado y táctil) para saltar y agacharse.

### 📌 Parte 3: Entorno Visual y Generación de Obstáculos (`Horizon` y `Obstacle`)
*   **Enfoque:** Explicar cómo se logra la ilusión de movimiento infinito (*runner*) y cómo el juego decide cuándo y qué enemigos aparecen en pantalla.
*   **Temas a exponer:**
    *   El efecto *Parallax* con el suelo (`Ground`) y las nubes (`Cloud`) dentro de la clase `Horizon`.
    *   El sistema de generación procedural de obstáculos (`ObstacleManager`).
    *   La variedad de enemigos (cactus terrestres y pterodáctilos aéreos).

### 📌 Parte 4: Sistema de Colisiones y Puntuación (`Collisions` y `ScoreBoard`)
*   **Enfoque:** Explicar la lógica de interacción final del juego: cómo sabe la aplicación que el jugador ha perdido y cómo se miden los logros del usuario.
*   **Temas a exponer:**
    *   El concepto de cajas de colisión (*hitboxes*) y la función de intersección de rectángulos.
    *   El flujo de fin de partida (*Game Over*) y el reinicio de variables.
    *   El marcador de puntos (`ScoreBoard`) y la persistencia del récord máximo.

---

## 💡 3. Recomendación Estratégica para el Reparto de la Exposición

Para que la exposición sea fluida, lógica y mantenga la atención de la audiencia de principio a fin, se sugiere el siguiente orden de participación:

1.  **Integrante 1 (Arquitectura y Motor) 👉 Presenta la Parte 1:**
    *   *Por qué:* Abre la presentación introduciendo la tecnología (**Flutter + Flame**), explicando el lienzo de juego (`GameWidget`) y cómo el bucle principal pone en marcha todo el sistema.
2.  **Integrante 2 (El Jugador y sus Físicas) 👉 Presenta la Parte 2:**
    *   *Por qué:* Es la continuación natural, ya que introduce al protagonista en pantalla. Atrae mucho visualmente explicar cómo salta el T-Rex, cómo se aplican las físicas de gravedad y cómo reacciona a los controles.
3.  **Integrante 3 (El Mundo y los Enemigos) 👉 Presenta la Parte 3:**
    *   *Por qué:* Expone el escenario donde se desenvuelve el jugador, explicando la magia del desplazamiento infinito y la aparición aleatoria de los obstáculos que dan reto al juego.
4.  **Integrante 4 (Colisiones y Marcador) 👉 Presenta la Parte 4:**
    *   *Por qué:* Es el cierre técnico perfecto. Explica el "momento de tensión" del juego (la detección matemática de impactos y el fin de la partida) junto con el sistema de puntos, dando pie a una conclusión o demostración final.