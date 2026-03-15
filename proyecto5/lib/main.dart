import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'Proyecto 5 - Grid List';

    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false, // Quita la etiqueta roja de "Debug"
      home: Scaffold(
        appBar: AppBar(
          title: const Text(title),
          backgroundColor: Colors.blueGrey,
        ),
        body: GridView.count(
          crossAxisCount: 2,
          children: List.generate(100, (index) {
            return Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.blueAccent[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Item $index',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}