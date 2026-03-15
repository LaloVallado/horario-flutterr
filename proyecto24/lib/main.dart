import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para SystemChrome

void main() {
  // Opcional: Descomenta la línea de abajo si quieres BLOQUEAR la app en vertical
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OrientationConfigScreen(),
  ));
}

class OrientationConfigScreen extends StatelessWidget {
  const OrientationConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proyecto 24: UI Adaptable')),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return GridView.count(
            // Lógica de Ingeniería: 2 columnas en vertical, 3 en horizontal
            crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
            children: List.generate(20, (index) {
              return Container(
                margin: const EdgeInsets.all(8),
                color: orientation == Orientation.portrait 
                    ? Colors.blueGrey[400] 
                    : Colors.teal[400],
                child: Center(
                  child: Text(
                    'Item $index',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}