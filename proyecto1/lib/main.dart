import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Page1(),
    ),
  );
}

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio - Proyecto 1')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Aquí llamamos a la función que crea la ruta animada
            Navigator.of(context).push(_createRoute());
          },
          child: const Text('¡Vamos a la Página 2!'),
        ),
      ),
    );
  }
}

// Función que define la animación personalizada
Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const Page2(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // 1. Definimos el punto de inicio (fuera de la pantalla, abajo)
      // y el punto final (posición original)
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      
      // 2. Definimos la curva de velocidad (comienza rápido, termina lento)
      const curve = Curves.ease;

      // 3. Combinamos los movimientos con la curva
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      // 4. Retornamos el widget de transición
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Página 2')),
      body: const Center(
        child: Text(
          'Esta página subió desde abajo',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}