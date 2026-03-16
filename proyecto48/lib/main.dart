import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: PantallaLista(),
));

// --- PANTALLA 1: LA LISTA ---
class PantallaLista extends StatelessWidget {
  const PantallaLista({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monitoreo ITM')),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaDetalle()));
          },
          // El widget HERO envuelve al elemento que va a "viajar"
          child: const Hero(
            tag: 'sensor-temp', // Identificador ÚNICO
            child: Icon(Icons.thermostat, size: 100, color: Colors.teal),
          ),
        ),
      ),
    );
  }
}

// --- PANTALLA 2: EL DETALLE ---
class PantallaDetalle extends StatelessWidget {
  const PantallaDetalle({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Sensor')),
      body: Column(
        children: [
          const SizedBox(height: 50),
          Center(
            // El mismo widget HERO con el MISMO tag
            child: const Hero(
              tag: 'sensor-temp',
              child: Icon(Icons.thermostat, size: 250, color: Colors.teal),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "Nodo: ESP32-SectorA\nTemperatura: 24.5°C",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}