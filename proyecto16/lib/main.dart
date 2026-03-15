import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'Proyecto 16 - Lista Horizontal';

    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(title),
          backgroundColor: Colors.teal,
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          height: 200, // Es vital definir una altura cuando la lista es horizontal
          child: ListView(
            // AQUÍ está la clave del proyecto:
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              _buildCard('Tarjeta 1', Colors.red),
              _buildCard('Tarjeta 2', Colors.blue),
              _buildCard('Tarjeta 3', Colors.green),
              _buildCard('Tarjeta 4', Colors.yellow),
              _buildCard('Tarjeta 5', Colors.orange),
              _buildCard('Tarjeta 6', Colors.purple),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para no repetir código
  Widget _buildCard(String text, Color color) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2))
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}