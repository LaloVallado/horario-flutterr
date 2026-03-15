import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    title: 'Proyecto 22: Retorno de Datos',
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pantalla Principal')),
      body: const Center(
        child: SelectionButton(),
      ),
    );
  }
}

class SelectionButton extends StatefulWidget {
  const SelectionButton({super.key});

  @override
  State<SelectionButton> createState() => _SelectionButtonState();
}

class _SelectionButtonState extends State<SelectionButton> {
  
  // Este método es el corazón del proyecto
  Future<void> _navigateAndDisplaySelection(BuildContext context) async {
    // 1. Navegamos y esperamos el resultado (await)
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SelectionScreen()),
    );

    // 2. Verificamos que el widget siga en pantalla (Seguridad)
    if (!context.mounted) return;

    // 3. Si hay un resultado, lo mostramos en un SnackBar
    if (result != null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Seleccionaste: $result')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _navigateAndDisplaySelection(context),
      child: const Text('¡Ir a seleccionar una opción!'),
    );
  }
}

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elige una opción')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, '¡Acepto! ✅'),
                child: const Text('Yep!'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, 'No gracias... ❌'),
                child: const Text('Nope.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}