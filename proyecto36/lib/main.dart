import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const AppAnimaciones());

class AppAnimaciones extends StatelessWidget {
  const AppAnimaciones({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const PantallaAnimada(),
    );
  }
}

class PantallaAnimada extends StatefulWidget {
  const PantallaAnimada({super.key});

  @override
  State<PantallaAnimada> createState() => _PantallaAnimadaState();
}

class _PantallaAnimadaState extends State<PantallaAnimada> {
  // Variables de estado iniciales
  double _width = 100;
  double _height = 100;
  Color _color = Colors.teal;
  BorderRadiusGeometry _borderRadius = BorderRadius.circular(10);

  // Función para generar valores aleatorios
  void _cambiarForma() {
    final random = Random();

    setState(() {
      _width = random.nextInt(300).toDouble() + 50;
      _height = random.nextInt(300).toDouble() + 50;
      _color = Color.fromRGBO(
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
        1,
      );
      _borderRadius = BorderRadius.circular(random.nextInt(100).toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AnimatedContainer')),
      body: Center(
        child: AnimatedContainer(
          // Estas son las propiedades obligatorias para la animación
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn, // El estilo del movimiento
          
          width: _width,
          height: _height,
          decoration: BoxDecoration(
            color: _color,
            borderRadius: _borderRadius,
          ),
          child: const FlutterLogo(size: 50),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _cambiarForma,
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}