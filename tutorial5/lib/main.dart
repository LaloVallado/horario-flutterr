import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const HomeWidgetCodelab());
}

// --- MODELO DE DATOS ---
class NewsArticle {
  final String title;
  final String description;
  final String content;
  final Color color;

  NewsArticle({
    required this.title, 
    required this.description, 
    required this.content, 
    required this.color
  });
}

// --- SIMULADOR DE 'home_widget' PACKAGE ---
// En un proyecto real, esto guardaría datos en la memoria nativa del teléfono.
class HomeWidgetSimulator {
  static Map<String, dynamic> _sharedStorage = {};
  static StreamController<Map<String, dynamic>> _updateStream = StreamController.broadcast();

  static Future<void> saveWidgetData(String id, dynamic data) async {
    _sharedStorage[id] = data;
    _updateStream.add(_sharedStorage);
  }

  static dynamic getWidgetData(String id) => _sharedStorage[id];
  static Stream<Map<String, dynamic>> get widgetUpdates => _updateStream.stream;
}

// --- APP PRINCIPAL ---
class HomeWidgetCodelab extends StatelessWidget {
  const HomeWidgetCodelab({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'News App & Widgets',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepOrange),
      home: const NewsListScreen(),
    );
  }
}

// --- PANTALLA 1: LISTA DE NOTICIAS ---
class NewsListScreen extends StatelessWidget {
  const NewsListScreen({super.key});

  static final List<NewsArticle> articles = [
    NewsArticle(
      title: "Nuevo avance en Flutter 2026", 
      description: "Las IA ahora programan widgets nativos.",
      content: "Hoy se anunció que la integración entre Dart y el sistema operativo es total...",
      color: Colors.blue
    ),
    NewsArticle(
      title: "Mérida: Ciudad Tecnológica", 
      description: "El ITM destaca en desarrollo móvil.",
      content: "Estudiantes de ingeniería de sistemas en Mérida logran hitos en Flutter...",
      color: Colors.green
    ),
    NewsArticle(
      title: "Cozumel y el Turismo Digital", 
      description: "Apps que ayudan al viajero.",
      content: "Nuevas herramientas digitales permiten explorar la isla como nunca antes...",
      color: Colors.orange
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Noticias de Hoy')),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return ListTile(
                leading: CircleAvatar(backgroundColor: article.color),
                title: Text(article.title),
                subtitle: Text(article.description),
                trailing: IconButton(
                  icon: const Icon(Icons.send_to_mobile, color: Colors.deepOrange),
                  tooltip: 'Enviar al Widget',
                  onPressed: () {
                    HomeWidgetSimulator.saveWidgetData('headline', article.title);
                    HomeWidgetSimulator.saveWidgetData('desc', article.description);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡Widget actualizado! Sal a la pantalla principal.')),
                    );
                  },
                ),
                onTap: () => Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => DetailScreen(article: article))
                ),
              );
            },
          ),
          
          // --- SIMULACIÓN DEL WIDGET DE LA PANTALLA PRINCIPAL ---
          const Positioned(
            bottom: 20,
            right: 20,
            child: OSHomeScreenPreview(),
          ),
        ],
      ),
    );
  }
}

// --- PANTALLA 2: DETALLE CON CUSTOM PAINT ---
class DetailScreen extends StatelessWidget {
  final NewsArticle article;
  const DetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(article.title)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CustomPaint(
              size: const Size(double.infinity, 100),
              painter: HeaderGraphPainter(color: article.color),
            ),
            const SizedBox(height: 20),
            Text(article.content, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

// --- COMPONENTE: VISTA PREVIA DEL WIDGET (Simula iOS/Android Home) ---
class OSHomeScreenPreview extends StatelessWidget {
  const OSHomeScreenPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Draggable(
      feedback: const Material(child: _WidgetContent()),
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)],
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text("HOME SCREEN (SIM)", style: TextStyle(color: Colors.white54, fontSize: 10)),
            ),
            const Expanded(child: _WidgetContent()),
          ],
        ),
      ),
    );
  }
}

class _WidgetContent extends StatelessWidget {
  const _WidgetContent();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: HomeWidgetSimulator.widgetUpdates,
      builder: (context, snapshot) {
        final title = HomeWidgetSimulator.getWidgetData('headline') ?? "Sin noticias";
        final desc = HomeWidgetSimulator.getWidgetData('desc') ?? "Toca el icono en la app para actualizar.";

        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.newspaper, size: 20, color: Colors.deepOrange),
              const SizedBox(height: 5),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 2),
              const SizedBox(height: 5),
              Text(desc, style: const TextStyle(fontSize: 10, color: Colors.black54), maxLines: 3),
            ],
          ),
        );
      },
    );
  }
}

// --- PAINTER PARA EL GRÁFICO DEL DETALLE ---
class HeaderGraphPainter extends CustomPainter {
  final Color color;
  HeaderGraphPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.75, size.height, size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}