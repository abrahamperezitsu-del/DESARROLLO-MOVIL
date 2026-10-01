import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

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