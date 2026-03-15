import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Importamos el paquete de fuentes

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Proyecto 3 - Fuentes Externas',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Package Fonts'),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Texto con fuente normal
            const Text('Esta es la fuente por defecto'),
            const SizedBox(height: 20),
            // Texto usando la fuente del paquete externo
            Text(
              'Usando la fuente Raleway del paquete externo',
              style: GoogleFonts.raleway(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Otras fuentes como Lato...',
              style: GoogleFonts.lato(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}