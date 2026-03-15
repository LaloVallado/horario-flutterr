import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Proyecto 11 - Manejo de Focus',
      debugShowCheckedModeBanner: false,
      home: MyCustomForm(),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  State<MyCustomForm> createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<MyCustomForm> {
  // 1. Definimos el FocusNode
  late FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // 2. IMPORTANTE: Limpiar el nodo cuando ya no se use para evitar fugas de memoria
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Field Focus'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Este campo tendrá el foco apenas se abra la pantalla
            const TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Tengo foco automático',
              ),
            ),
            const SizedBox(height: 20),
            // Este campo solo tendrá foco cuando usemos el "cable" (myFocusNode)
            TextField(
              focusNode: myFocusNode,
              decoration: InputDecoration(
                hintText: 'Presiona el botón para darme foco',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // 3. Al presionar, pedimos el foco para el segundo campo
        onPressed: () => myFocusNode.requestFocus(),
        tooltip: 'Enfocar segundo campo',
        child: const Icon(Icons.edit),
      ),
    );
  }
}