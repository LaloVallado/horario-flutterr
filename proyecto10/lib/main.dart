import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MixedListApp(),
    ),
  );
}

// 1. Definimos la estructura base (Clase Abstracta)
abstract class ListItem {
  Widget buildTitle(BuildContext context);
  Widget buildSubtitle(BuildContext context);
}

// 2. Clase para los Encabezados
class HeadingItem implements ListItem {
  final String heading;
  HeadingItem(this.heading);

  @override
  Widget buildTitle(BuildContext context) {
    return Text(
      heading,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  @override
  Widget buildSubtitle(BuildContext context) => const SizedBox.shrink();
}

// 3. Clase para los Mensajes
class MessageItem implements ListItem {
  final String sender;
  final String body;
  MessageItem(this.sender, this.body);

  @override
  Widget buildTitle(BuildContext context) => Text(sender);

  @override
  Widget buildSubtitle(BuildContext context) => Text(body);
}

class MixedListApp extends StatelessWidget {
  const MixedListApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Generamos 1000 elementos: cada 6 será un encabezado
    final items = List<ListItem>.generate(
      1000,
      (i) => i % 6 == 0
          ? HeadingItem('Encabezado del grupo $i')
          : MessageItem('Remitente $i', 'Este es el cuerpo del mensaje número $i'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista con diferentes tipos'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          // El ListTile adapta su diseño según el tipo de objeto que sea
          return Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: ListTile(
              title: item.buildTitle(context),
              subtitle: item.buildSubtitle(context),
              leading: item is HeadingItem 
                ? const Icon(Icons.label, color: Colors.deepPurple)
                : const Icon(Icons.message_outlined),
            ),
          );
        },
      ),
    );
  }
}