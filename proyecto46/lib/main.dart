import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: PantallaHistorial()));

class PantallaHistorial extends StatelessWidget {
  const PantallaHistorial({super.key});

  @override
  Widget build(BuildContext context) {
    // Generamos una lista de prueba con 1000 elementos
    final List<String> registros = List.generate(1000, (i) => "Lectura #$i: ${20 + (i % 10)}°C");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Sensores (ITM)'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        // 1. Definimos la cantidad total de elementos
        itemCount: registros.length,
        // 2. Definimos cómo se construye cada fila (solo cuando sea necesario)
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: const Icon(Icons.history, color: Colors.teal),
              title: Text(registros[index]),
              subtitle: const Text("Humedad: 65% | Estado: Estable"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Aquí podrías navegar a los detalles del registro
                print("Tocaste el registro número $index");
              },
            ),
          );
        },
      ),
    );
  }
}