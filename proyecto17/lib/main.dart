import 'package:flutter/material.dart';

void main() {
  runApp(MyApp(items: List<String>.generate(10000, (i) => 'Item $i')));
}

class MyApp extends StatelessWidget {
  final List<String> items;
  const MyApp({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Lista Larga para Test')),
        body: ListView.builder(
          key: const Key('long_list'), // Key para encontrar la lista
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                items[index],
                key: Key('item_${index}_text'), // Key única para cada texto
              ),
            );
          },
        ),
      ),
    );
  }
}