import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Navegación ITM',
    // 1. Definimos la ruta inicial
    initialRoute: '/',
    // 2. Definimos el mapa de rutas
    routes: {
      '/': (context) => const PantallaInicio(),
      '/sensores': (context) => const PantallaSensores(),
      '/ajustes': (context) => const PantallaAjustes(),
    },
  ));
}

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sistema de Microclima')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/sensores'),
              child: const Text('MONITOREO DE SENSORES'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/ajustes'),
              child: const Text('CONFIGURACIÓN'),
            ),
          ],
        ),
      ),
    );
  }
}

class PantallaSensores extends StatelessWidget {
  const PantallaSensores({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sensores en Tiempo Real')),
    body: const Center(child: Text('Datos del ESP32: 24.5°C')),
  );
}

class PantallaAjustes extends StatelessWidget {
  const PantallaAjustes({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ajustes del Sistema')),
    body: const Center(child: Text('Configuración de red y umbrales')),
  );
}