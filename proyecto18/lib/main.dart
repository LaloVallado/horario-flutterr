import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'Proyecto 18 - Slivers';

    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // NOTA: No usamos el property 'appBar' del Scaffold
        body: CustomScrollView(
          slivers: <Widget>[
            // 1. El AppBar que flota y se expande
            SliverAppBar(
              // Si pinned es true, el título se queda fijo arriba al encogerse
              pinned: true,
              // Si floating es true, aparece en cuanto haces scroll hacia arriba
              floating: true,
              expandedHeight: 200.0,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Mi Perfil de Ingeniería'),
                background: Image.network(
                  'https://picsum.photos/800/400',
                  fit: BoxFit.cover,
                ),
              ),
              backgroundColor: Colors.indigo,
            ),
            
            // 2. La lista de items (usamos SliverList)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ListTile(
                  leading: const Icon(Icons.circle, size: 10),
                  title: Text('Elemento de la lista #$index'),
                  subtitle: const Text('Desliza para ver el efecto del AppBar'),
                ),
                childCount: 50, // 50 elementos para poder hacer scroll
              ),
            ),
          ],
        ),
      ),
    );
  }
}