# T‑Rex Game (Offline Chrome Dino) – Flame Framework

*Explicación detallada del código del ejemplo `trex` del repositorio **flame‑engine/flame** (ejemplos). El código se divide en tres partes para que tres personas puedan exponerlo de manera clara y estructurada.*

---

## Parte 1 – Lógica principal y gestión del estado (`trex_game.dart`)

Este módulo contiene el corazón del juego: el enum de estados, la clase `TRexGame` que extiende `FlameGame` y maneja el bucle de actualización, la entrada, la puntuación y la lógica de “game over”.

### Enum `GameState`
```dart
enum GameState() {
  playing,
  intro,
  gameOver,
}
```
- Define tres estados: `intro` ( pantalla de inicio ), `playing` (en curso) y `gameOver`.

### Clase `TRexGame`
```dart
class TRexGame()
    extends FlameGame
    with KeyboardEvents, TapCallbacks, HasCollisionDetection {
  static const String description = '''
    A game similar to the game in chrome that you get to play while offline.
    Press space or tap/click the screen to jump, the more obstacles you manage
    to survive, the more points you get.
  ''';

  final Random random = Random();
  late final Image spriteImage;

  @override
  Color backgroundColor() => const Color(0xFFFFFFFF);

  late final player = Player();
  late final horizon = Horizon();
  late final gameOverPanel = GameOverPanel();
  late final TextComponent scoreText;

  int _score = 0;
  int _highScore = 0;
  int get score => _score;
  set score(int newScore) {
    _score = newScore;
    scoreText.text = '${scoreString(_score)}  HI ${scoreString(_highScore)}';
  }

  String scoreString(int score) => score.toString().padLeft(5, '0');

  double _distanceTraveled = 0;
```
- **`description`**: descripción del juego que aparece en la documentación.
- **`spriteImage`**: imagen única que contiene todos los sprites (dinosaurio, nubes, obstáculos, UI).
- **`player`, `horizon`, `gameOverPanel`, `scoreText`**: componentes principales añadidos en `onLoad`.
- **`score` / `highScore`**: la puntuación actual y la máxima conseguida; se actualiza cada frame.
- **`_distanceTraveled`**: distancia recorrida, usada para calcular puntos (`score = _distanceTraveled ~/ 50`).

#### Método `onLoad`
```dart
@override
Future<void> onLoad() async {
  spriteImage = await Flame.images.load('assets/images/trex.png');
  add(horizon);
  add(player);
  add(gameOverPanel);

  // ... creación del renderer de fuente y del componente de texto de puntuación
  score = 0;
}
```
- Carga la imagen `trex.png` que contiene todos los sprites.
- Instancia y añade al árbol de componentes: `horizon`, `player`, `gameOverPanel`, y el `scoreText`.
- Inicializa la puntuación en 0.

#### Entrada de teclado y toque
```dart
@override
KeyEventResult onKeyEvent(
  KeyEvent event,
  Set<LogicalKeyboardKey> keysPressed,
) {
  if (keysPressed.contains(LogicalKeyboardKey.enter) ||
      keysPressed.contains(LogicalKeyboardKey.space)) {
    onAction();
  }
  return KeyEventResult.handled;
}

@override
void onTapDown(TapDownEvent event) {
  onAction();
}
```
- `onKeyEvent`: detecta pressionar **Enter** o **Space** y lanza `onAction`.
- `onTapDown`: detecta un toque en pantalla, también lanza `onAction`.

#### `onAction`
```dart
void onAction() {
  if (isGameOver || isIntro) {
    restart();
    return;
  }
  player.jump(currentSpeed);
}
```
- Si el juego ya terminó o está en modo intro, reinicia inmediatamente.
- De lo contrario, llama a `player.jump` pasando la velocidad actual (afecta la altura del salto).

#### `gameOver`
```dart
void gameOver() {
  gameOverPanel.visible = true;
  state = GameState.gameOver;
  player.current = PlayerState.crashed;
  currentSpeed = 0.0;
}
```
- Muestra el panel de “Game Over”, cambia el estado a `gameOver`, pone al jugador en la animación de caída y detiene la velocidad del horizonte.

#### `restart`
```dart
void restart() {
  state = GameState.playing;
  player.reset();
  horizon.reset();
  currentSpeed = startSpeed;
  gameOverPanel.visible = false;
  timePlaying = 0.0;
  if (score > _highScore) _highScore = score;
  score = 0;
  _distanceTraveled = 0;
}
```
- Reinicia todo: estado a `playing`, resetea jugador y horizonte, resetea la puntuación y la distancia.

#### Bucle de actualización (`update`)
```dart
@override
void update(double dt) {
  super.update(dt);
  if (isGameOver) return;

  if (isPlaying) {
    timePlaying += dt;
    _distanceTraveled += dt * currentSpeed;
    score = _distanceTraveled ~/ 50;

    if (currentSpeed < maxSpeed) {
      currentSpeed += acceleration * dt;
    }
  }
}
```
- Aumenta el tiempo de juego y la distancia recorrida.
- La puntuación se actualiza cada 50 píxeles de distancia.
- Acelera gradualmente el juego (`acceleration`) hasta alcanzar `maxSpeed`.

---

## Parte 2 – Componente del jugador y física (`player.dart`)

Este módulo define al **dinosaurio**: su animación, estado físicas (correr, saltar, morir) y detección de colisiones.

### Enum `PlayerState`
```dart
enum PlayerState() {
  crashed,
  jumping,
  running,
  waiting,
}
```
- Cuatro estados posibles:
  - `running`: movimiento normal sobre el suelo.
  - `jumping`: salto en curso.
  - `crashed`: colisión con obstáculo.
  - `waiting`: estado inicial/intro.

### Clase `Player`
```dart
class Player()
    extends SpriteAnimationGroupComponent<PlayerState>
    with HasGameRef<TRexGame>, CollisionCallbacks {
  this : super(size: Vector2(90, 88));

  final double gravity = 0.85;
  final double initialJumpVelocity = -16;
  final double introDuration = 1500.0;
  final double startXPosition = 50;

  double _jumpVelocity = 0.0;
```
- Extiende `SpriteAnimationGroupComponent<PlayerState>` para cambiar de animación según el estado.
- Mixin `HasGameRef<TRexGame>` para acceder al juego y `CollisionCallbacks` para recibir notificaciones de colisión.
- Tamaño fijo `90×88` píxeles.

#### Propiedad `groundYPos`
```dart
double get groundYPos {
  return (gameRef.size.y / 2) - height / 2;
}
```
- Devuelve la posición Y del suelo (centrada verticalmente).

#### `onLoad` – cargar animaciones y cajas de colisión
```dart
@override
Future<void> onLoad() async {
  // Caja de colisión corporal
  add(
    RectangleHitbox.relative(
      Vector2(0.7, 0.6),
      position: Vector2(0, height / 3),
      parentSize: size,
    ),
  );
  // Caja de colisión de la cabeza
  add(
    RectangleHitbox.relative(
      Vector2(0.45, 0.35),
      position: Vector2(width / 2, 0),
      parentSize: size,
    ),
  );

  animations = {
    PlayerState.running: _getAnimation(
      size: Vector2(88.0, 90.0),
      frames: [Vector2(1514.0, 4.0), Vector2(1602.0, 4.0)],
      stepTime: 0.2,
    ),
    PlayerState.waiting: _getAnimation(
      size: Vector2(88.0, 90.0),
      frames: [Vector2(76.0, 6.0)],
    ),
    PlayerState.jumping: _getAnimation(
      size: Vector2(88.0, 90.0),
      frames: [Vector2(1339.0, 6.0)],
    ),
    PlayerState.crashed: _getAnimation(
      size: Vector2(88.0, 90.0),
      frames: [Vector2(1782.0, 6.0)],
    ),
  };
  current = PlayerState.waiting;
}
```
- Añade dos `RectangleHitbox` relativas: una para el cuerpo y otra para la cabeza. Las posiciones están calculadas proporcionalmente al tamaño del sprite.
- Define un mapa `animations` que asocia cada `PlayerState` a una animación (lista de frames y tiempo por paso). Los frames vienen del sprite sheet `trex.png`.

#### `jump`
```dart
void jump(double speed) {
  if (current == PlayerState.jumping) return;
  current = PlayerState.jumping;
  _jumpVelocity = initialJumpVelocity - (speed / 500);
}
```
- Si ya está saltando, ignora el nuevo salto.
- Asigna `_jumpVelocity` basado en la velocidad actual del juego (cuanto más rápido vaya el horizonte, menor altura de salto).

#### `reset`
```dart
void reset() {
  y = groundYPos;
  _jumpVelocity = 0.0;
  current = PlayerState.running;
}
```
- Restablece la posición Y al suelo, reinicia la velocidad de salto y vuelve al estado `running`.

#### `update`
```dart
@override
void update(double dt) {
  super.update(dt);
  if (current == PlayerState.jumping) {
    y += _jumpVelocity;
    _jumpVelocity += gravity;
    if (y > groundYPos) {
      reset();
    }
  } else {
    y = groundYPos;
  }

  if (gameRef.isIntro && x < startXPosition) {
    x += (startXPosition / introDuration) * dt * 5000;
  }
}
```
- **Mientras salta**: actualiza la posición Y sumando la velocidad, aplica gravedad cada frame y, al tocar el suelo (`y > groundYPos`), llama a `reset`.
- **Cuando no salta**: fuerza la posición Y al suelo.
- Durante el **intro**, hace mover al jugador suavemente desde la izquierda (`startXPosition`) hacia su posición inicial.

#### `onCollisionStart`
```dart
@override
void onCollisionStart(
  List<Vector2> intersectionPoints,
  PositionComponent other,
) {
  super.onCollisionStart(intersectionPoints, other);
  gameRef.gameOver();
}
```
- Se llama cuando el jugador choca con cualquier componente que tenga detección de colisiones (obstáculos). Llama a `gameRef.gameOver()` para terminar la partida.

#### `_getAnimation` (método auxiliar)
```dart
SpriteAnimation _getAnimation({
  required Vector2 size,
  required List<Vector2> frames,
  double stepTime = double.infinity,
}) {
  return SpriteAnimation.spriteList(
    frames
        .map(
          (vector) => Sprite(
            gameRef.spriteImage,
            srcSize: size,
            srcPosition: vector,
          ),
        )
        .toList(),
    stepTime: stepTime,
  );
}
```
- Convierte una lista de posiciones `Vector2` (coordenadas en el sprite sheet) en un `SpriteAnimation` usable por Flame.

---

## Parte 3 – Interfaz de usuario, componentes visuales y entrada (`main.dart`, `trex_widget.dart`, `game_over.dart`, `horizon.dart`)

Este módulo se encarga de mostrar el juego en la pantalla, el panel de “Game Over”, la puntuación y el fondo desplazable.

### `main.dart` – Punto de entrada
```dart
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:trex_game/trex_game.dart';

void main() {
  runApp(
    GameWidget(game: TRexGame()),
  );
}
```
- Simplemente inicia la aplicación Flutter y coloca el `GameWidget` de Flame que ejecuta `TRexGame`.

### `trex_widget.dart` – Contenedor widget
```dart
import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart' hide Gradient, Image;
import 'package:trex_game/trex_game.dart';

class TRexWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'T-Rex',
      home: Container(
        color: Colors.black,
        margin: const EdgeInsets.all(45),
        child: ClipRect(
          child: GameWidget(
            game: TRexGame(),
            loadingBuilder: (_) => const Center(
              child: Text('Loading'),
            ),
          ),
        ),
      ),
    );
  }
}
```
- Envuelve el `GameWidget` en un `MaterialApp` con fondo negro y márgenes. El `loadingBuilder` muestra un texto mientras se cargan los activos.

### `game_over.dart` – Panel de fin de juego
```dart
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:trex_game/trex_game.dart';

class GameOverPanel() extends Component {
  bool visible = false;

  @override
  Future<void> onLoad() async {
    add(GameOverText());
    add(GameOverRestart());
  }

  @override
  void renderTree(Canvas canvas) {
    if (visible) {
      super.renderTree(canvas);
    }
  }
}

class GameOverText() extends SpriteComponent with HasGameRef<TRexGame> {
  this : super(size: Vector2(382, 25), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = Sprite(
      gameRef.spriteImage,
      srcPosition: Vector2(955.0, 26.0),
      srcSize: size,
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    x = size.x / 2;
    y = size.y * 0.25;
  }
}

class GameOverRestart() extends SpriteComponent with HasGameRef<TRexGame> {
  this : super(size: Vector2(72, 64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = Sprite(
      gameRef.spriteImage,
      srcPosition: Vector2.all(2.0),
      srcSize: size,
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    x = size.x / 2;
    y = size.y * 0.75;
  }
}
```
- **`GameOverPanel`**: componente raíz que contiene dos sub‑componentes y solo los renderiza cuando `visible` es `true`.
- **`GameOverText`**: muestra el sprite de “Game Over” (tomado del sprite sheet en la posición `955, 26`). Se centra horizontalmente y se coloca al 25 % de la altura vertical.
- **`GameOverRestart`**: sprite del botón de “Reinicio” (posición `2,2` del sprite sheet). Se sitúa al 75 % de la altura.

### `horizon.dart` – Fondo desplazable y gestión de obstáculos
```dart
class Horizon() extends PositionComponent with HasGameRef<TRexGame> {
  static final Vector2 lineSize = Vector2(1200, 24);
  final Queue<SpriteComponent> groundLayers = Queue();
  late final CloudManager cloudManager = CloudManager();
  late final ObstacleManager obstacleManager = ObstacleManager();

  // Sprites “suaves” y “bumpy” para la línea del suelo
  late final _softSprite = Sprite(
    gameRef.spriteImage,
    srcPosition: Vector2(2.0, 104.0),
    srcSize: lineSize,
  );
  late final _bumpySprite = Sprite(
    gameRef.spriteImage,
    srcPosition: Vector2(gameRef.spriteImage.width / 2, 104.0),
    srcSize: lineSize,
  );

  @override
  Future<void> onLoad() async {
    add(cloudManager);
    add(obstacleManager);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final increment = gameRef.currentSpeed * dt;
    for (final line in groundLayers) {
      line.x -= increment;
    }

    final firstLine = groundLayers.first;
    if (firstLine.x <= -firstLine.width) {
      firstLine.x = groundLayers.last.x + groundLayers.last.width;
      groundLayers.remove(firstLine);
      groundLayers.add(firstLine);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final newLines = _generateLines();
    groundLayers.addAll(newLines);
    addAll(newLines);
    y = (size.y / 2) + 21.0;
  }

  void reset() {
    cloudManager.reset();
    obstacleManager.reset();
    groundLayers.forEachIndexed((i, line) => line.x = i * lineSize.x);
  }

  List<SpriteComponent> _generateLines() {
    final number =
        1 + (gameRef.size.x / lineSize.x).ceil() - groundLayers.length;
    final lastX =
        (groundLayers.lastOrNull?.x ?? 0) +
        (groundLayers.lastOrNull?.width ?? 0);
    return List.generate(
      max(number, 0),
      (i) => SpriteComponent(
        sprite: (i + groundLayers.length).isEven ? _softSprite : _bumpySprite,
        size: lineSize,
      )..x = lastX + lineSize.x * i,
      growable: false,
    );
  }
}
```
- **Efecto de suelo infinito**: una cola de componentes `SpriteComponent` que se mueven hacia la izquierda a la velocidad actual del juego (`currentSpeed`).
- Cuando una línea sale completamente de la pantalla, se re‑posiciona al final de la cola, creando un bucle continuo.
- Añade `CloudManager` y `ObstacleManager` (no mostrados aquí pero responsables de nubes y cactus/obstáculos).
- `onGameResize` recrea la cantidad necesaria de líneas al cambiar el tamaño de la ventana.

### Renderizado de la puntuación (`trex_game.dart` – fragmento)
```dart
final renderer = SpriteFontRenderer.fromFont(
  SpriteFont(
    source: spriteImage,
    size: 23,
    ascent: 23,
    glyphs: [
      for (var i = 0; i < chars.length; i++)
        Glyph(chars[i], left: 954.0 + 20 * i, top: 0, width: 20),
    ],
  ),
  letterSpacing: 2,
);
add(
  scoreText = TextComponent(
    position: Vector2(20, 20),
    textRenderer: renderer,
  ),
);
```
- Se usa una fuente personalizada construida sobre el mismo sprite sheet (`trex.png`). Los glifos (números, letras “HI” y espacio) están definidos por coordenadas `left` y `top` dentro de la imagen. El `TextComponent` muestra la puntuación en la esquina superior izquierda.

---

## Recomendación de división de trabajo entre tres personas

| Persona | Módulo principal | Responsabilidades clave |
|---------|------------------|--------------------------|
| **Ana** | **Parte 1 – Lógica principal y estado** (`trex_game.dart`) | Implementar el `GameState`, el bucle `update`, el manejo de entrada (`onKeyEvent`, `onTapDown`), la lógica de puntuación, aceleración y reinicio. También encargarse de que el estado cambie correctamente (`gameOver`, `restart`). |
| **Luis** | **Parte 2 – Jugador y física** (`player.dart`, `horizon.dart`) | Crear y mantener la clase `Player` (animaciones, saltos, gravedad, cajas de colisión). Implementar el `Horizon` (movimiento del suelo, generador de líneas, gestión de nubes y obstáculos mediante `CloudManager` y `ObstacleManager`). Asegurar que la física sea coherente y que las colisiones se detecten adecuadamente. |
| **Marta** | **Parte 3 – UI, widgets y visuales** (`main.dart`, `trex_widget.dart`, `game_over.dart`) | Construir el widget `TRexWidget` que integra el juego en la app Flutter, el panel de “Game Over”, el texto de puntuación con fuente personalizada, y cualquier otro elemento visual (menús, animaciones de fondo). También se asegura de que los recursos (imágenes, fuentes) se carguen correctamente y de que la UI sea responsive (`onGameResize`). |

### Cómo coordinarse

1. **Repositorio compartido** – Los tres tendrán acceso al mismo branch. Cada uno creará una *feature branch* a partir de `main` (`feat/ana‑logic`, `feat/luis‑player`, `feat/marta‑ui`).
2. **Integración continua** – Al terminar cada módulo, se abrirá un *Pull Request* contra `main`. Se revisará que las interfaces (por ejemplo, los métodos `gameOver()` y `restart()`) sigan el contrato definido en `trex_game.dart`.
3. **Reuniones de sincronización** – Breves llamadas (15 min) cada día para verificar que los cambios de una persona no rompan la lógica de la otra (por ejemplo, si Luis cambia la velocidad `_jumpVelocity`, Marta debe actualizar el UI del panel de Game Over si es necesario).
4. **Documentación inline** – Cada función y método debe incluir un comentario de una línea que indique su propósito y efectos secundarios, facilitando la revisión del PR.

Con esta división, cada expositor puede dedicar su bloque de tiempo a explicar su parte con los detalles de código que se muestran arriba, y el equipo tendrá un código coherente y funcional al final del proyecto.