import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Formulario con Validación';

    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: const MyCustomForm(),
      ),
    );
  }
}

// 1. Creamos el StatefulWidget
class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  // Creamos la GlobalKey para identificar el formulario
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // 2. Construimos el Form usando la llave
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3. Añadimos el campo de texto con lógica de validación
            TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                hintText: 'Escribe tu nombre',
                labelText: 'Nombre *',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingresa algo de texto';
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // 4. Validamos el formulario al presionar el botón
                  if (_formKey.currentState!.validate()) {
                    // Si es válido, mostramos un mensaje
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Procesando información...')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                child: const Text('Enviar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}