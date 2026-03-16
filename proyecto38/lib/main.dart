import 'package:flutter/material.dart';

void main() => runApp(const AppNavegacion());

class AppNavegacion extends StatelessWidget {
  const AppNavegacion({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PrimeraPantalla(),
    );
  }
}

class PrimeraPantalla extends StatelessWidget {
  const PrimeraPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(title: const Text('Pantalla 1')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Ir a Pantalla 2'),
          onPressed: () {
            Navigator.of(context).push(_crearRuta());
          },
        ),
      ),
    );
  }

  // --- FUNCIÓN DE TRANSICIÓN PERSONALIZADA ---
  Route _crearRuta() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const SegundaPantalla(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Animación de escala
        var scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOutBack),
        );

        // Animación de opacidad (fade)
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
    );
  }
}

class SegundaPantalla extends StatelessWidget {
  const SegundaPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(title: const Text('Pantalla 2')),
      body: const Center(
        child: Text('¡Transición exitosa!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}