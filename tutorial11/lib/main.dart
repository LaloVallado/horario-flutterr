import 'package:flutter/material.dart';

void main() {
  runApp(const DebuggingLabApp());
}

class DebuggingLabApp extends StatelessWidget {
  const DebuggingLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Layout Inspector Lab',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepOrange,
      ),
      home: const DebuggingHome(),
    );
  }
}

class DebuggingHome extends StatelessWidget {
  const DebuggingHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Layout Debugging Lab'),
        backgroundColor: Colors.orange.shade100,
      ),
      // Usamos un Column para agrupar los 3 ejemplos
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Menú de Depuración", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          
          // EJEMPLO 1: El error de Overflow (Corregido)
          const Example1(),
          
          const Divider(),

          // EJEMPLO 2: El error de Unbounded Height (Corregido con Expanded)
          // Nota: El ListView necesita un ancestro con altura definida
          const Expanded(child: Example2()),

          const Divider(),

          // EJEMPLO 3: El error de Invisibilidad (VerticalDivider)
          const Example3(),
        ],
      ),
    );
  }
}

// --- ESCENARIO 1: TEXT OVERFLOW ---
// Problema: El texto largo intenta ocupar más espacio del que el Row permite.
// Solución: Expanded obliga al texto a ajustarse al espacio restante.
class Example1 extends StatelessWidget {
  const Example1({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 40),
          const SizedBox(width: 10),
          // Sin Expanded, este texto causaría el banner amarillo/negro.
          const Expanded(
            child: Text(
              "Este es un texto extremadamente largo que solía causar un error de overflow en la fila de la aplicación.",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// --- ESCENARIO 2: UNBOUNDED HEIGHT ---
// Problema: ListView dentro de Column quiere altura infinita.
// Solución: Expanded le da al ListView la restricción de ocupar solo el espacio disponible.
class Example2 extends StatelessWidget {
  const Example2({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> menuItems = List.generate(10, (i) => "Platillo Especial #${i + 1}");

    return ListView.builder(
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.restaurant_menu),
          title: Text(menuItems[index]),
          onTap: () {},
        );
      },
    );
  }
}

// --- ESCENARIO 3: INVISIBLE VERTICAL DIVIDER ---
// Problema: VerticalDivider no tiene altura intrínseca y Row no la impone.
// Solución: Envolver el Row en un SizedBox con altura definida.
class Example3 extends StatelessWidget {
  const Example3({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80, // Clave: Darle altura al contenedor para que el divider sepa cuánto medir
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text("Editar"),
            ),
            const VerticalDivider(
              width: 20,
              thickness: 2,
              indent: 10,
              endIndent: 10,
              color: Colors.grey,
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Eliminar"),
            ),
          ],
        ),
      ),
    );
  }
}