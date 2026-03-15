import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyIndicatorPage(),
    );
  }
}

class MyIndicatorPage extends StatefulWidget {
  const MyIndicatorPage({super.key});

  @override
  State<MyIndicatorPage> createState() => _MyIndicatorPageState();
}

class _MyIndicatorPageState extends State<MyIndicatorPage> {
  bool _isLoading = false; // Estado para controlar el indicador

  void _simularCarga() {
    setState(() => _isLoading = true);
    // Esperamos 2 segundos y quitamos el indicador
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prueba de Indicador')),
      body: Center(
        child: _isLoading 
          ? const CircularProgressIndicator() // El indicador de carga
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('¡Todo listo! Pulse para cargar.'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _simularCarga, 
                  child: const Text('Iniciar Carga'),
                ),
              ],
            ),
      ),
    );
  }
}