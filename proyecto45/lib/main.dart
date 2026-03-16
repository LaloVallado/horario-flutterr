import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false, 
  home: PantallaSensores()
));

class PantallaSensores extends StatelessWidget {
  const PantallaSensores({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoreo de Microclima'),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: Text('Toca el botón + para ver opciones'),
      ),
      
      // Implementación del FAB Expandible
      floatingActionButton: SpeedDial(
        icon: Icons.add, // Icono cuando está cerrado
        activeIcon: Icons.close, // Icono cuando está abierto
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        spacing: 12, // Espacio entre botones
        spaceBetweenChildren: 8,
        
        children: [
          SpeedDialChild(
            child: const Icon(Icons.refresh),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: 'Refrescar Sensores',
            onTap: () => _mostrarSnackBar(context, "Sincronizando con ESP32..."),
          ),
          SpeedDialChild(
            child: const Icon(Icons.save_alt),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            label: 'Exportar Log (CSV)',
            onTap: () => _mostrarSnackBar(context, "Generando reporte de humedad..."),
          ),
          SpeedDialChild(
            child: const Icon(Icons.priority_high),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            label: 'Configurar Alertas',
            onTap: () => _mostrarSnackBar(context, "Abriendo umbrales críticos..."),
          ),
        ],
      ),
    );
  }

  void _mostrarSnackBar(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), duration: const Duration(seconds: 1)),
    );
  }
}