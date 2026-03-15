import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proyecto 12 - Gestos',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Manejando Toques'),
          backgroundColor: Colors.lightBlue,
        ),
        body: const Center(
          child: MyButton(),
        ),
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  const MyButton({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Envolvemos todo en el GestureDetector
    return GestureDetector(
      // 2. Definimos qué pasa al tocar
      onTap: () {
        const snackBar = SnackBar(
          content: Text('¡Acabas de tocar el botón personalizado!'),
          duration: Duration(seconds: 1),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      // 3. El diseño del botón (un simple contenedor azul)
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.lightBlue,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Text(
          'Mi Botón Personalizado',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}