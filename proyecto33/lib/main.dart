import 'package:flutter/material.dart';

void main() {
  runApp(const ConfiguracionNodoApp());
}

class ConfiguracionNodoApp extends StatelessWidget {
  const ConfiguracionNodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Configuración de Nodo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const PantallaConfiguracion(),
    );
  }
}

class PantallaConfiguracion extends StatefulWidget {
  const PantallaConfiguracion({super.key});

  @override
  State<PantallaConfiguracion> createState() => _PantallaConfiguracionState();
}

class _PantallaConfiguracionState extends State<PantallaConfiguracion> {
  // El controlador es esencial para obtener el valor del TextField
  final TextEditingController _idNodoController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();
  String _mensajeStatus = "Esperando datos...";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Parámetros del Sistema', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Configuración del Dispositivo",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 8),
            const Text("Ingrese los datos para identificar el nodo en la red."),
            const SizedBox(height: 30),

            // --- TEXTFIELD 1: Estilo Moderno con Bordes ---
            TextField(
              controller: _idNodoController,
              decoration: InputDecoration(
                labelText: 'ID del Nodo (ESP32)',
                hintText: 'Ej. NODO_A1_MERIDA',
                prefixIcon: const Icon(Icons.developer_board),
                filled: true,
                fillColor: Colors.white,
                // Bordes cuando el campo no tiene el foco
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                ),
                // Bordes cuando el usuario está escribiendo
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.indigo, width: 2),
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // --- TEXTFIELD 2: Estilo Minimalista (Underline) ---
            TextField(
              controller: _ipController,
              keyboardType: TextInputType.number, // Optimizado para números/IPs
              decoration: const InputDecoration(
                labelText: 'Dirección IP del Servidor',
                helperText: 'Formato: 192.168.x.x',
                suffixIcon: Icon(Icons.dns),
                border: UnderlineInputBorder(), // Estilo de línea inferior
              ),
            ),

            const SizedBox(height: 40),

            // Botón para procesar la información
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _mensajeStatus = "Configurando: ${_idNodoController.text}\nIP: ${_ipController.text}";
                  });
                },
                icon: const Icon(Icons.save),
                label: const Text("GUARDAR CONFIGURACIÓN", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Visualización del resultado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.shade100),
              ),
              child: Text(
                _mensajeStatus,
                style: TextStyle(color: Colors.indigo.shade900, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Siempre libera los controladores para optimizar memoria en tu Mac
    _idNodoController.dispose();
    _ipController.dispose();
    super.dispose();
  }
}