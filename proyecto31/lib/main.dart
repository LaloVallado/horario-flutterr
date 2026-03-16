import 'package:flutter/material.dart';

void main() {
  runApp(const MiInventarioApp());
}

class MiInventarioApp extends StatelessWidget {
  const MiInventarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventario de Fragancias',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const PantallaListaEspaciada(),
    );
  }
}

class PantallaListaEspaciada extends StatelessWidget {
  const PantallaListaEspaciada({super.key});

  // Datos de ejemplo para poblar nuestra lista
  final List<Map<String, String>> fragancias = const [
    {
      'nombre': 'Dior Sauvage',
      'tipo': 'Diseñador',
      'descripcion': 'Notas frescas y especiadas, excelente rendimiento para el día a día.'
    },
    {
      'nombre': 'Azzaro The Most Wanted',
      'tipo': 'Diseñador',
      'descripcion': 'Aroma intenso, dulce y amaderado. La mejor opción para salidas nocturnas.'
    },
    {
      'nombre': 'Jean Paul Gaultier Le Male',
      'tipo': 'Diseñador',
      'descripcion': 'Un perfil clásico e inconfundible con toques de vainilla, menta y lavanda.'
    },
    {
      'nombre': 'Clon Árabe Premium',
      'tipo': 'Dupe',
      'descripcion': 'Alternativa de altísima duración con notas orientales y gran proyección.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Colección Aromática',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      // Implementación clave del tema: ListView.separated
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: fragancias.length,
        // El separatorBuilder es el encargado de crear el espacio entre elementos
        separatorBuilder: (context, index) {
          return const SizedBox(height: 24.0); // Espacio de 24 píxeles entre cada tarjeta
        },
        itemBuilder: (context, index) {
          final item = fragancias[index];
          return TarjetaElemento(
            nombre: item['nombre']!,
            tipo: item['tipo']!,
            descripcion: item['descripcion']!,
          );
        },
      ),
    );
  }
}

class TarjetaElemento extends StatelessWidget {
  final String nombre;
  final String tipo;
  final String descripcion;

  const TarjetaElemento({
    super.key,
    required this.nombre,
    required this.tipo,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono visual a la izquierda
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.water_drop, size: 30, color: Colors.blueGrey),
            ),
            const SizedBox(width: 16), // Espacio horizontal fijo
            // Expanded permite que la columna tome todo el ancho restante sin causar un overflow
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: tipo == 'Dupe' ? Colors.amber.shade100 : Colors.indigo.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tipo,
                      style: TextStyle(
                        fontSize: 12,
                        color: tipo == 'Dupe' ? Colors.amber.shade900 : Colors.indigo.shade900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    descripcion,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}