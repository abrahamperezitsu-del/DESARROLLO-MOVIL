# T‑Rex Game (Offline Chrome Dino) – Flame Framework
*Explicación detallada del código del ejemplo `trex` del repositorio **flame‑engine/flame** (ejemplos). El código se divide en **cuatro partes** para que **cuatro personas** puedan exponerlo de manera clara y estructurada.*

---

## Parte 1 – Estado del juego, puntuación y entrada (`trex_game.dart` – fragmento principal)

### Enum `GameState` y clase `TRexGame`
```dart
enum GameState() {
  playing,
  intro,
  gameOver,
}
```
- Define los tres estados del juego: `intro`, `playing` y `gameOver`.

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
**Responsabilidades de la Persona 1:**
- Gestionar el enum `GameState` y cambiar de estado en `onLoad`, `gameOver`, `restart`.
- Implementar los métodos de entrada: `onKeyEvent` (teclado **Enter/Space**) y `onTapDown` (toque).
- Lógica de `onAction`: si el juego ya terminó o está en intro, reinicia; de lo contrario llama a `player.jump(currentSpeed)`.
- `gameOver`: muestra el panel, cambia el estado a `gameOver`, pone al jugador en animación de caída y detiene la velocidad.
- `restart`: reinicia todos los componentes (estado, jugador, horizonte, puntuación, distancia).
- El bucle `update`: acumula tiempo, distancia, puntuación (`score = _distanceTraveled ~/ 50`) y acelera gradualmente el horizonte (`currentSpeed += acceleration * dt` hasta `maxSpeed`).

---

## Parte 2 – Jugador, física y cajas de colisión (`player.dart`)

### Enum `PlayerState` y clase `Player`
```dart
enum PlayerState() {
  crashed,
  jumping,
  running,
  waiting,
}
```
- Cuatro estados: `running` (correr), `jumping` (saltando), `crashed` (colisión), `waiting` (inicio).

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
- Se añaden dos `RectangleHitbox` relativas: una para el cuerpo y otra para la cabeza. Las posiciones están calculadas proporcionalmente al tamaño del sprite.
- Se define un mapa `animations` que asocia cada `PlayerState` a una animación (lista de frames y tiempo por paso). Los frames provienen del sprite sheet `trex.png`.

#### `jump`
```dart
void jump(double speed) {
  if (current == PlayerState.jumping) return;
  current = PlayerState.jumping;
  _jumpVelocity = initialJumpVelocity - (speed / 500);
}
```
- Si ya está saltando, ignora el nuevo salto.
- Asigna `_jumpVelocity` basado en la velocidad actual del juego (a mayor velocidad, menor altura de salto).

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
- **Mientras salta:** actualiza la posición Y sumando la velocidad, aplica gravedad cada frame y, al tocar el suelo (`y > groundYPos`), llama a `reset`.
- **Cuando no salta:** fuerza la posición Y al suelo.
- Durante el **intro**, mueve suavemente al jugador desde la izquierda (`startXPosition`) hacia su posición inicial.

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

**Responsabilidades de la Persona 2:**
- Implementar la clase `Player` completa: enum, físicas, animaciones, cajas de colisión y lógica de salto.
- Asegurar que la gravedad y la velocidad de salto sean coherentes con la velocidad del horizonte.
- Gestionar la detección de colisiones y la transición a `gameOver`.

---

## Parte 3 – Horizon, nubes, obstáculos y fondo desplazable (`horizon.dart`)

### Clase `Horizon`
```dart
class Horizon() extends PositionComponent with HasGameRef<TRexGame> {
  static final Vector2 lineSize = Vector2(1200, 24);
  final Queue<SpriteComponent> groundLayers = Queue();
  late final CloudManager cloudManager = CloudManager();
  late final ObstacleManager obstacleManager = ObstacleManager();

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
- **Efecto de suelo infinito:** una cola de componentes `SpriteComponent` que se mueven hacia la izquierda a la velocidad actual del juego (`currentSpeed`).
- Cuando una línea sale completamente de la pantalla, se re‑posiciona al final de la cola, creando un bucle continuo.
- Añade `CloudManager` y `ObstacleManager` (responsables de nubes y cactus/obstáculos). (Los archivos respectivos no se mostraron aquí, pero su API es `reset()`).
- `onGameResize` recrea la cantidad necesaria de líneas al cambiar el tamaño de la ventana.

**Responsabilidades de la Persona 3:**
- Implementar la clase `Horizon` y su método `update` para el desplazamiento infinito.
- Gestionar la generación de líneas (`_generateLines`) y su reposicionamiento.
- Integrar `CloudManager` y `ObstacleManager` para crear nubes y obstáculos aleatorios.
- Asegurar que la velocidad del horizonte (`currentSpeed`) sea la misma utilizada por el jugador para el cálculo de salto y puntuación.

---

## Parte 4 – UI, widgets, panel “Game Over” y punto de entrada (`main.dart`, `trex_widget.dart`, `game_over.dart`)

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
- Inicia la aplicación Flutter y coloca el `GameWidget` de Flame que ejecuta `TRexGame`.

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
- **`GameOverText`**: muestra el sprite de “Game Over” (posición `955, 26` del sprite sheet). Se centra horizontalmente y se coloca al 25 % de la altura vertical.
- **`GameOverRestart`**: sprite del botón de “Reinicio” (posición `2,2` del sprite sheet). Se sitúa al 75 % de la altura.

### Renderizado de la puntuación (fragmento en `trex_game.dart`)
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

**Responsabilidades de la Persona 4:**
- Crear el widget `TRexWidget` que integra el juego en la app Flutter, con márgenes y fondo negro.
- Implementar el panel `GameOverPanel`, `GameOverText` y `GameOverRestart`, controlando su visibilidad según el estado del juego.
- Asegurar que el `SpriteFont` y el `TextComponent` muestren la puntuación y el mejor registro correctamente.
- Gestionar el `loadingBuilder` para mostrar un indicador de carga mientras se descargan los sprites.

---

## Recomendación de división de trabajo entre cuatro personas

| Persona | Módulo principal | Responsabilidades clave |
|---------|------------------|--------------------------|
| **Ana** | **Parte 1 – Estado, puntuación y entrada** (`trex_game.dart`) | Gestionar el enum `GameState`, los métodos de entrada (`onKeyEvent`, `onTapDown`), la lógica de `onAction`, `gameOver`, `restart` y el bucle `update` (puntuación, aceleración). |
| **Luis** | **Parte 2 – Jugador y física** (`player.dart`) | Implementar la clase `Player`, el enum `PlayerState`, animaciones, salto con gravedad, cajas de colisión y la detección de colisiones que llama a `gameOver`. |
| **Marta** | **Parte 3 – Horizon, nubes y obstáculos** (`horizon.dart`, `cloud_manager`, `obstacle_manager`) | Crear y mantener la clase `Horizon` con el efecto de suelo infinito, gestionar `CloudManager` y `ObstacleManager` para generar nubes y cactus/obstáculos aleatorios. |
| **Sara** | **Parte 4 – UI, widgets y entrada** (`main.dart`, `trex_widget.dart`, `game_over.dart`) | Construir el widget `TRexWidget`, el panel “Game Over”, el texto de puntuación con fuente personalizada, y asegurar que los recursos se carguen correctamente y la UI sea responsive. |

### Cómo coordinarse

1. **Repositorio compartido** – Los cuatro tendrán acceso al mismo branch `main`. Cada uno creará una *feature branch* a partir de `main` (`feat/ana‑state`, `feat/luis‑player`, `feat/marta‑horizon`, `feat/sara‑ui`).
2. **Pull Requests** – Al terminar cada módulo, se abrirá un PR contra `main`. Se revisará que las interfaces (`gameOver()`, `restart()`, `jump(double speed)`) sigan el contrato definido en `trex_game.dart` y `player.dart`.
3. **Integración continua** – Después de fusionar los cuatro PRs, se realizará una compilación rápida para verificar que el juego arranca, que el jugador salta, que el horizonte se mueve y que el panel de Game Over aparece/oculta correctamente.
4. **Reuniones de sincronización** – Breves llamadas (15 min) cada dos días para verificar que los cambios de una persona no rompan la lógica de la otra (por ejemplo, si Luis cambia la variable `_jumpVelocity`, Sara debe actualizar el UI del panel de Game Over si la altura del salto afecta la posición visual).
5. **Documentación inline** – Cada función y método debe incluir un comentario de una línea que indique su propósito y efectos secundarios, facilitando la revisión del PR y la exposición en clase.

Con esta división, cada expositor puede dedicar su bloque de tiempo a explicar su parte con los detalles de código mostrados arriba, y el equipo tendrá un código coherente y funcional al final del proyecto.