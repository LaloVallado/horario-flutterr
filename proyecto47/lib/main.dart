import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: PantallaMensajes()));

class PantallaMensajes extends StatelessWidget {
  const PantallaMensajes({super.key});

  // Función reutilizable para mostrar el SnackBar
  void _mostrarAviso(BuildContext context, String mensaje, {bool esError = false}) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            esError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(mensaje)),
        ],
      ),
      backgroundColor: esError ? Colors.redAccent : Colors.teal,
      behavior: SnackBarBehavior.floating, // Hace que flote sobre el contenido
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'OK',
        textColor: Colors.white,
        onPressed: () {
          // Lógica al presionar el botón del SnackBar
        },
      ),
    );

    // Limpia snacks anteriores y muestra el nuevo
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones de Sistema')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _mostrarAviso(context, "Lectura de sensor exitosa"),
              child: const Text("NOTIFICACIÓN ÉXITO"),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50]),
              onPressed: () => _mostrarAviso(context, "Fallo de conexión con ESP32", esError: true),
              child: const Text("NOTIFICACIÓN ERROR", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}