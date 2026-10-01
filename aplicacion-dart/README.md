# Flutter Dos Pantallas

Aplicación mínima en Flutter con dos pantallas que comparten un mensaje mediante navegación y argumentos.

## Descripción

La app tiene dos rutas (`/` y `/segunda`). La primera pantalla envía el mensaje "hola" a la segunda usando `Navigator.pushNamed` con un mapa de argumentos. La segunda pantalla recibe el mensaje y lo muestra en pantalla.

## Estructura

- `lib/main.dart`: Código completo con `MyApp`, `PrimeraPantalla` y `SegundaPantalla`.
- `pubspec.yaml`: Dependencias y configuración del SDK.
- `explicacion.md`: Documentación detallada del desarrollo.

## Cómo ejecutar

1. Abrir la carpeta en Android Studio (`File > Open`).
2. Ejecutar `flutter pub get` para instalar dependencias.
3. Conectar un emulador o dispositivo y pulsar el botón **Run**.

## Pantallas

- **Pantalla 1**: fondo negro, borde azul oscuro, botón flotante. Al tocarlo navega a la segunda pantalla enviando "hola".
- **Pantalla 2**: mismo diseño, muestra `Mensaje recibido: hola`.

## Tecnologías

Flutter, Dart, navegación declarativa con rutas nombradas.