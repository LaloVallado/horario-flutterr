import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: PantallaPrincipal()));

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Control')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dashboard, size: 80, color: Colors.teal),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('VER DETALLES DEL SENSOR'),
              onPressed: () {
                // NAVEGAR A LA SIGUIENTE PANTALLA (PUSH)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PantallaDetalles()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PantallaDetalles extends StatelessWidget {
  const PantallaDetalles({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Nodo'),
        // Flutter agrega automáticamente el botón de "Atrás" en el AppBar
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Humedad: 65% | Temperatura: 24°C'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // REGRESAR A LA PANTALLA ANTERIOR (POP)
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50]),
              child: const Text('CERRAR DETALLES', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}