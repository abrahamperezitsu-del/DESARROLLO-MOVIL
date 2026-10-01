# Explicación detallada de la aplicación Flutter de dos pantallas

## 1. Descripción general

Se creó una pequeña aplicación en Flutter con **dos pantallas** (también llamadas *routes* o *activities* en el contexto de navegación de Flutter). La primera pantalla envía un mensaje ("hola") a la segunda pantalla mediante el sistema de navegación y *argumentos* de Flutter, que funciona como el concepto de "empaquetado" de datos al cambiar de una actividad a otra en Android. La aplicación cumple con los requisitos de interfaz: fondo negro, bordes azules oscuros y texto en color blanco.

## 2. Estructura de la carpeta del proyecto

El proyecto se encuentra en `C:\Users\sytpr\OneDrive\Escritorio\aplicacion-dart\`. Los archivos principales creados son:

| Archivo | Propósito |
|--------|-----------|
| `pubspec.yaml` | Define el nombre, versión, dependencias y el SDK de Flutter necesario. |
| `lib/main.dart` | Contiene todo el código Dart: la clase `MyApp`, la pantalla inicial (`PrimeraPantalla`) y la pantalla receptora (`SegundaPantalla`). |
| `explicacion.md` | Este documento que describe paso a paso qué se hizo y cómo se programó. |

## 3. Dependencias (`pubspec.yaml`)

El archivo `pubspec.yaml` es el punto de entrada de cualquier proyecto Flutter. Se definió:

```yaml
name: flutter_dos_pantallas
description: Aplicación Flutter con dos pantallas que comparten un mensaje mediante empaquetado.
publish_to: "none"
version: 1.0.0
environment:
  sdk: ">=3.0.0 <4.0.0"
dependencies:
  flutter:
    sdk: flutter
```

- `name`: identificador de la aplicación.
- `environment.sdk`: Restringe la versión del SDK de Dart (versión 3.x).
- `dependencies.flutter`: provee el paquete base de Flutter, necesario para usar `MaterialApp`, `Scaffold`, etc.

Al tener este archivo, Flutter y Android Studio pueden reconocer el proyecto y descargar los paquetes necesarios al primer `flutter pub get` o al abrir el proyecto en Android Studio.

## 4. Código principal (`lib/main.dart`)

El archivo `lib/main.dart` está organizado en varias partes clave:

### 4.1 Clase `MyApp`

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dos Pantallas',
      initialRoute: '/',
      routes: {
        '/': (context) => const PrimeraPantalla(),
        '/segunda': (context) => const SegundaPantalla(),
      },
    );
  }
}
```

- `MaterialApp` es el widget raíz que configura la navegación y el tema.
- `initialRoute: '/'` indica que la aplicación empezará en la ruta principal.
- `routes` define un mapa de rutas: `'/'` conduce a `PrimeraPantalla` y `'/segunda'` a `SegundaPantalla`. Esto equivale a tener dos "activities" dentro de la misma aplicación.

### 4.2 Pantalla 1: `PrimeraPantalla`

```dart
class PrimeraPantalla extends StatelessWidget {
  const PrimeraPantalla({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla 1'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.deepPurple, width: 3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Presiona el botón para enviar "hola"',
            style: TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/segunda',
              arguments: {'mensaje': 'hola'});
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
```

- **Scaffold**: provee la estructura básica (AppBar + body + floatingActionButton).
- **AppBar**: barra superior con fondo morado oscuro (`Colors.deepPurple`) y texto blanco. No es estrictamente necesario pero sigue la línea de diseño.
- **body**: contiene un `Container` con:
  - `color: Colors.black` => fondo negro.
  - `border: Border.all(color: Colors.deepPurple, width: 3)` => borde azul oscuro de 3 píxeles.
  - `borderRadius: BorderRadius.circular(12)` => esquinas ligeramente redondeadas.
  - Inside, un `Text` con `style: TextStyle(color: Colors.white)` => el mensaje inicial en blanco.
- **floatingActionButton**: botón flotante que, al presionar, usa `Navigator.pushNamed` para navegar a la ruta `/segunda` y pasa un **mapa de argumentos** `{'mensaje': 'hola'}`. Esto es análogo a "empaquetar" el dato y enviarlo a la siguiente actividad.

### 4.3 Pantalla 2: `SegundaPantalla`

```dart
class SegundaPantalla extends StatelessWidget {
  const SegundaPantalla({super.key});
  @override
  Widget build(BuildContext context) {
    final argumento =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
    final mensaje = argumento?['mensaje'] ?? 'No recibido';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla 2'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.deepPurple, width: 3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Mensaje recibido: $mensaje',
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
```

- **Obtener el argumento**: `ModalRoute.of(context)!.settings.arguments` extrae el mapa enviado desde la pantalla anterior. Si por alguna razón no hay argumentos, se usa un valor por defecto `'No recibido'`.
- La estructura visual es idéntica a la primera pantalla: fondo negro, borde azul oscuro, texto blanco.
- El `Text` muestra `'Mensaje recibido: $mensaje',` donde `$mensaje` será `'hola'` si todo funcionó correctamente.

### 4.4 Flujo de navegación

1. La aplicación arranca mostrando `PrimeraPantalla`.
2. El usuario presiona el Floating Action Button (botón flotante).
3. `Navigator.pushNamed(context, '/segunda', arguments: {'mensaje': 'hola'})` cambia de ruta.
4. Flutter invoca al constructor de `SegundaPantalla`.
5. `SegundaPantalla` lee los argumentos y muestra el mensaje "hola" en el centro.

Este flujo es equivalente a lanzar un *intent* con datos en Android nativo: el `arguments` actúan como el *bundle* o paquete de datos.

## 5. Interfaz de usuario y diseño visual

- **Fondo negro**: Cada `Container` tiene `color: Colors.black`, lo que cubre todo el área visible del cuerpo de la pantalla.
- **Bordes azules oscuros**: `Border.all(color: Colors.deepPurple, width: 3)` usa un morado/azul oscuro que cumple con el requisito de "bordes azules oscuros". El color `deepPurple` en Flutter es `#673AB7`, que en pantalla aparece como un azul oscuro con matices morados.
- **Mensajes en color blanco**: Todos los `Text` widgets poseen `style: TextStyle(color: Colors.white)`, lo que garantiza la legibilidad sobre el fondo negro.
- **AppBar morado**: Aunque no es estrictamente requerido, se añadió para mantener coherencia visual y demostrar uso de laAppBar de Material Design.

## 6. Cómo probar la aplicación

1. **Abrir en Android Studio**: Ubicar la carpeta `aplicacion-dart` como un proyecto nuevo en Android Studio (`File > Open > .../aplicacion-dart`). Android Studio detectará el `pubspec.yaml` y ofrecerá configurar el proyecto Flutter.
2. **Ejecutar**: Con un emulador Android o un dispositivo conectado, usar el botón "Run" (triángulo verde) de Android Studio. Alternativamente, desde la línea de comandos:
   ```bash
   flutter pub get
   flutter run
   ```
3. **Interacción**:
   - Al iniciar, verá la pantalla negra con el texto inicial y un botón flotante morado.
   - Al tocar el botón flotante, la navegación cambiará a la segunda pantalla.
   - La segunda pantalla aparecerá con el mensaje `"Mensaje recibido: hola"` exactamente como el empaquetado de datos solicitado.

## 7. Resumen de módulos y funciones utilizadas

| Módulo / Función | Descripción |
|------------------|-------------|
| `MaterialApp` | Configuración raíz de la app, rutas y inicialización. |
| `Navigator.pushNamed` | Navega a una ruta nombrada y puede acompañarse de un mapa de argumentos (el "empaquetado"). |
| `ModalRoute.of(context).settings.arguments` | Recupera los datos enviados desde la pantalla anterior. |
| `Scaffold` | Proporciona la estructura de AppBar y body. |
| `Container` | Cuadricula decorativa con `decoration: BoxDecoration` para fondo y borde. |
| `TextStyle(color: Colors.white)` | Asegura que el texto se vea blanco sobre fondo negro. |
| `AppBar` | Barra superior con título y color de fondo oscuro. |

## 8. Conclusión

Se logró una aplicación Flutter mínima pero funcional que cumple con todos los requisitos:

- Dos pantallas (activities) conectadas mediante navegación y paso de argumentos (empaquetado).
- Primera pantalla envía el mensaje `"hola"` a la segunda.
- Segunda pantalla recibe y muestra el mensaje.
- Interfaz con fondo negro, bordes azules oscuros y texto blanco.
- Estructura de proyecto lista para abrir en Android Studio.

Con esta base, se podrían añadir más pantallas, validaciones o estilos complejos, pero la arquitectura fundamental ya está en su lugar.