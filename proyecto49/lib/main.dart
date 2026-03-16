import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: PantallaArrastre()));

class PantallaArrastre extends StatefulWidget {
  const PantallaArrastre({super.key});

  @override
  State<PantallaArrastre> createState() => _PantallaArrastreState();
}

class _PantallaArrastreState extends State<PantallaArrastre> {
  Color _colorZona = Colors.grey[300]!;
  String _mensaje = "Arrastra el sensor a la zona";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Control de Sensores - ITM')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. EL ELEMENTO ARRASTRABLE
          Draggable<String>(
            data: "Sensor_ESP32", // El dato que "viaja"
            feedback: const Icon(Icons.sensors, size: 80, color: Colors.teal),
            childWhenDragging: const Icon(Icons.sensors, size: 50, color: Colors.grey),
            child: const Icon(Icons.sensors, size: 50, color: Colors.teal),
          ),

          Text(_mensaje, style: const TextStyle(fontWeight: FontWeight.bold)),

          // 2. LA ZONA QUE RECIBE (DRAG TARGET)
          DragTarget<String>(
            onWillAcceptWithDetails: (details) => details.data == "Sensor_ESP32",
            onAcceptWithDetails: (details) {
              setState(() {
                _colorZona = Colors.greenAccent;
                _mensaje = "¡Sensor vinculado con éxito!";
              });
            },
            onLeave: (data) {
              setState(() => _colorZona = Colors.grey[300]!);
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: candidateData.isNotEmpty ? Colors.teal[100] : _colorZona,
                  border: Border.all(color: Colors.teal, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(child: Text("ZONA DE VINCULACIÓN")),
              );
            },
          ),
        ],
      ),
    );
  }
}