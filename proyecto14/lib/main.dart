import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proyecto 14 - Swipe to Dismiss',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SwipeListScreen(),
    );
  }
}

class SwipeListScreen extends StatefulWidget {
  const SwipeListScreen({super.key});

  @override
  State<SwipeListScreen> createState() => _SwipeListScreenState();
}

class _SwipeListScreenState extends State<SwipeListScreen> {
  // 1. Creamos nuestra fuente de datos (20 elementos)
  final items = List<String>.generate(20, (i) => 'Elemento ${i + 1}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desliza para eliminar'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          // 2. Envolvemos el ListTile en un Dismissible
          return Dismissible(
            // La Key es obligatoria y debe ser única
            key: Key(item),
            
            // 3. Indicador visual que queda detrás al deslizar
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            
            // Qué hacer cuando se completa el deslizamiento
            onDismissed: (direction) {
              // Eliminamos el item del estado
              setState(() {
                items.removeAt(index);
              });

              // Mostramos confirmación
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$item eliminado')),
              );
            },
            
            child: ListTile(
              title: Text(item),
              subtitle: const Text('Desliza a la derecha para borrar'),
              leading: const Icon(Icons.mail),
            ),
          );
        },
      ),
    );
  }
}