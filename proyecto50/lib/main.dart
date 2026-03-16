import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: PantallaPrincipal(),
));

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Microclima'),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: Text('Desliza desde la izquierda o toca el menú'),
      ),
      // --- IMPLEMENTACIÓN DEL DRAWER ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, // Elimina el padding por defecto
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.teal, size: 40),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Eduardo Villamonte',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    'Ing. Sistemas - ITM',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard Principal'),
              onTap: () => Navigator.pop(context), // Cierra el Drawer
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historial de Sensores'),
              onTap: () {
                Navigator.pop(context);
                // Aquí podrías navegar a otra pantalla
              },
            ),
            const Divider(), // Línea divisoria decorativa
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ajustes del ESP32'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}