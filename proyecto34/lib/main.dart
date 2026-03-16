import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const AppPersistencia());

class AppPersistencia extends StatelessWidget {
  const AppPersistencia({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      home: const PantallaAjustes(),
    );
  }
}

class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  // Llaves para identificar nuestros datos en disco
  static const String keyNombre = 'nombre_usuario';
  static const String keyNotificaciones = 'notificaciones_activas';

  final TextEditingController _controller = TextEditingController();
  bool _notificaciones = false;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias(); // Leemos los datos al iniciar
  }

  // --- LEER DATOS ---
  Future<void> _cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Si la llave no existe, usamos un valor por defecto
      _controller.text = prefs.getString(keyNombre) ?? "";
      _notificaciones = prefs.getBool(keyNotificaciones) ?? false;
    });
  }

  // --- GUARDAR DATOS ---
  Future<void> _guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyNombre, _controller.text);
    await prefs.setBool(keyNotificaciones, _notificaciones);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Datos guardados en el disco!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Persistencia Local")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Nombre del Operador",
                border: OutlineInputBorder(),
              ),
            ),
            SwitchListTile(
              title: const Text("Activar Alertas Críticas"),
              value: _notificaciones,
              onChanged: (bool value) {
                setState(() => _notificaciones = value);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _guardarDatos,
              icon: const Icon(Icons.save),
              label: const Text("GUARDAR EN DISCO"),
            ),
            const Divider(height: 40),
            const Text(
              "Cierra la app y vuelve a abrirla: los datos seguirán aquí.",
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}