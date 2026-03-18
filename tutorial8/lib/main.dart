import 'dart:convert';
import 'package:flutter/material.dart';

void main() {
  runApp(const Dart3PatternsApp());
}

// --- 1. DATOS SIMULADOS (JSON ROBUSTO) ---
const String documentJson = '''
{
  "metadata": {
    "title": "Reporte de Ingeniería ITM",
    "modified": "2026-03-17",
    "author": "Salvador Villamonte"
  },
  "blocks": [
    {"type": "header", "text": "Introducción a Dart 3"},
    {"type": "paragraph", "text": "Los patrones permiten desestructurar datos de forma segura."},
    {"type": "checkbox", "text": "Aprender Registros", "checked": true},
    {"type": "checkbox", "text": "Dominar Switch Expressions", "checked": false},
    {"type": "header", "text": "Conclusión"},
    {"type": "paragraph", "text": "Este código es 100% funcional y robusto."}
  ]
}
''';

// --- 2. MODELADO CON DART 3 (Sealed Classes & Records) ---

// Clase sellada para asegurar verificación exhaustiva en los switch
sealed class Block {
  final String text;
  Block(this.text);
}

class HeaderBlock extends Block {
  HeaderBlock(super.text);
}

class ParagraphBlock extends Block {
  ParagraphBlock(super.text);
}

class CheckboxBlock extends Block {
  final bool isChecked;
  CheckboxBlock(super.text, this.isChecked);
}

// Clase para manejar la lógica del documento
class Document {
  final Map<String, Object?> _json;
  
  Document(String jsonString) : _json = jsonDecode(jsonString) as Map<String, Object?>;

  // USO DE REGISTROS: Retorna múltiples valores de forma tipada
  (String, {DateTime modified, String author}) getMetadata() {
    // Patrón de desestructuración de Mapa
    if (_json case {
      'metadata': {
        'title': String title,
        'modified': String modifiedStr,
        'author': String author,
      }
    }) {
      return (title, modified: DateTime.parse(modifiedStr), author: author);
    } else {
      throw const FormatException('JSON de metadatos inválido');
    }
  }

  // USO DE PATRONES: Convierte JSON a objetos tipados
  List<Block> getBlocks() {
    if (_json case {'blocks': List<Object?> blocksJson}) {
      return blocksJson.map((item) {
        // Switch Expression: El nuevo estándar de Dart 3
        return switch (item) {
          {'type': 'header', 'text': String text} => HeaderBlock(text),
          {'type': 'paragraph', 'text': String text} => ParagraphBlock(text),
          {'type': 'checkbox', 'text': String text, 'checked': bool checked} 
            => CheckboxBlock(text, checked),
          _ => throw Exception('Tipo de bloque desconocido'),
        };
      }).toList();
    }
    return [];
  }
}

// --- 3. UI DE LA APLICACIÓN ---

class Dart3PatternsApp extends StatelessWidget {
  const Dart3PatternsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      home: const DocumentViewerScreen(),
    );
  }
}

class DocumentViewerScreen extends StatefulWidget {
  const DocumentViewerScreen({super.key});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  final Document doc = Document(documentJson);
  late List<Block> blocks;
  late String title;
  late DateTime lastModified;
  late String author;

  @override
  void initState() {
    super.initState();
    // Desestructuramos el Registro directamente en variables locales
    final metadata = doc.getMetadata();
    title = metadata.$1; // Acceso posicional
    lastModified = metadata.modified; // Acceso nombrado
    author = metadata.author;
    
    blocks = doc.getBlocks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dart 3 Explorer'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          _buildHeaderSliver(),
          _buildBlocksSliver(),
          _buildSummarySliver(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRawJson(context),
        label: const Text('Ver JSON Original'),
        icon: const Icon(Icons.code),
      ),
    );
  }

  // --- COMPONENTES DE LA INTERFAZ ---

  Widget _buildHeaderSliver() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.indigo.withOpacity(0.05),
          border: const Border(bottom: BorderSide(color: Colors.indigo, width: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16),
                const SizedBox(width: 4),
                Text('Autor: $author'),
                const SizedBox(width: 20),
                const Icon(Icons.calendar_today_outlined, size: 16),
                const SizedBox(width: 4),
                Text('Modificado: ${lastModified.day}/${lastModified.month}/${lastModified.year}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlocksSliver() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final block = blocks[index];
          
          // USO DE EXHAUSTIVE SWITCH: Si olvidas un tipo de bloque, Dart dará error
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: switch (block) {
              HeaderBlock(:final text) => _HeaderWidget(text: text),
              ParagraphBlock(:final text) => _ParagraphWidget(text: text),
              CheckboxBlock(:final text, :final isChecked) => _CheckboxWidget(text: text, value: isChecked),
            },
          );
        },
        childCount: blocks.length,
      ),
    );
  }

  Widget _buildSummarySliver() {
    // Lógica para contar usando patrones
    int headers = 0;
    int items = 0;
    for (var b in blocks) {
      if (b is HeaderBlock) headers++;
      if (b is CheckboxBlock) items++;
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const Divider(),
            const SizedBox(height: 10),
            Text('Estadísticas del Documento', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatChip(label: 'Encabezados', value: '$headers', color: Colors.blue),
                _StatChip(label: 'Tareas', value: '$items', color: Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRawJson(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 400,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Raw JSON Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Divider(),
              Text(documentJson, style: const TextStyle(fontFamily: 'monospace')),
            ],
          ),
        ),
      ),
    );
  }
}

// --- MINI-WIDGETS DE BLOQUE ---

class _HeaderWidget extends StatelessWidget {
  final String text;
  const _HeaderWidget({required this.text});
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87));
}

class _ParagraphWidget extends StatelessWidget {
  final String text;
  const _ParagraphWidget({required this.text});
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5));
}

class _CheckboxWidget extends StatelessWidget {
  final String text;
  final bool value;
  const _CheckboxWidget({required this.text, required this.value});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(value ? Icons.check_box : Icons.check_box_outline_blank, color: value ? Colors.green : Colors.grey),
      const SizedBox(width: 10),
      Text(text, style: TextStyle(decoration: value ? TextDecoration.lineThrough : null)),
    ],
  );
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ],
  );
}